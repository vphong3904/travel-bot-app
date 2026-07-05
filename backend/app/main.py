import asyncio
from contextlib import asynccontextmanager

import os

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.routes import api_router
from app.api.deps import require_admin
from app.db.models.user import User
from app.utils import get_logger
from app.db.database import Base, engine
from app.db.mongo import connect_mongo, close_mongo
from app.core.config import settings

logger = get_logger("main")


async def _init_qdrant(retries: int = 5, delay: float = 2.0) -> bool:
    """
    Thử kết nối Qdrant và tạo collection với retry.
    Trả về True nếu thành công.
    """
    from app.services.rag_pipeline import RAGPipeline
    rag = RAGPipeline()
    for attempt in range(1, retries + 1):
        try:
            await rag.ensure_collection()
            logger.info(f"Qdrant collection sẵn sàng (attempt {attempt})")
            return True
        except Exception as e:
            logger.warning(f"Qdrant attempt {attempt}/{retries} failed: {e}")
            if attempt < retries:
                await asyncio.sleep(delay)
    logger.error("Không thể kết nối Qdrant sau tất cả retry — collection sẽ được tạo khi có request đầu tiên")
    return False


# [OPT-1.1 + OPT-4.1] Tham số throttle worker embedding.
# - BATCH nhỏ + nghỉ giữa batch ⇒ worker nền KHÔNG nuốt hết CPU, nhường chỗ cho
#   embedding câu hỏi của user (sửa nghẽn 6-8s khi tải nặng).
# - Poll liên tục ⇒ entry mới tạo ở Admin (status=pending) được embed vào Qdrant
#   trong vài giây mà không cần bấm tay (KB realtime).
_EMBED_BATCH_SIZE: int = 4        # số job xử lý mỗi vòng
_EMBED_BUSY_SLEEP: float = 1.0    # nghỉ giữa các batch khi còn job (nhường CPU)
_EMBED_IDLE_SLEEP: float = 5.0    # khi hết job: poll lại sau 5s (phát hiện entry mới)


async def _embedding_worker_loop() -> None:
    """
    [OPT-1.1/OPT-4.1] Worker embedding chạy nền liên tục, có throttle.

    Thay cho cách cũ (nuốt 500 job một lần lúc startup → tranh CPU với query của
    user → phản hồi 6-8s). Mỗi vòng chỉ xử lý _EMBED_BATCH_SIZE job rồi nghỉ
    ngắn để event loop + thread CPU rảnh cho embedding câu hỏi trực tiếp.

    Đồng thời đây là cơ chế KB realtime: thêm/sửa knowledge ở Admin sinh
    embedding_jobs(pending) → worker này tự nhặt và đẩy vào Qdrant.
    """
    from app.db.database import AsyncSessionLocal
    from app.services.embedding_jobs import EmbeddingJobService

    logger.info(
        f"[EmbedWorker] Bắt đầu vòng lặp throttle — batch={_EMBED_BATCH_SIZE} "
        f"busy_sleep={_EMBED_BUSY_SLEEP}s idle_sleep={_EMBED_IDLE_SLEEP}s"
    )
    while True:
        try:
            async with AsyncSessionLocal() as db:
                service = EmbeddingJobService(db)
                result = await service.run_pending(limit=_EMBED_BATCH_SIZE)

            processed = result["done"] + result["failed"]
            # Còn job → nghỉ ngắn rồi làm tiếp; hết job → nghỉ dài chờ entry mới.
            await asyncio.sleep(_EMBED_BUSY_SLEEP if processed else _EMBED_IDLE_SLEEP)
        except asyncio.CancelledError:
            logger.info("[EmbedWorker] Dừng vòng lặp (shutdown)")
            raise
        except Exception as e:
            logger.error(f"[EmbedWorker] Lỗi vòng lặp: {e}", exc_info=True)
            await asyncio.sleep(_EMBED_IDLE_SLEEP)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ──

    # 0. Kết nối MongoDB (log: search_history, user_behavior, flagged/unanswered)
    await connect_mongo()

    # 0b. [OPT-3.1] Nạp intent patterns từ DB (admin sửa được) — fallback file nếu DB trống
    try:
        from app.db.database import AsyncSessionLocal
        from app.services.intent_loader import load_intent_patterns_from_db
        async with AsyncSessionLocal() as db:
            await load_intent_patterns_from_db(db)
    except Exception as e:
        logger.warning(f"[Startup] Không nạp được intent từ DB, dùng bộ từ file: {e}")

    # 1. Tạo Qdrant collection với retry
    qdrant_ok = await _init_qdrant(retries=5, delay=2.0)

    # 2. Warm-up embedding model rồi khởi động worker embedding throttle (nền)
    worker_task: asyncio.Task | None = None

    async def _warmup_then_start_worker():
        try:
            # Bước 2a: load embedding model trước (blocking ~10-30s lần đầu)
            from app.services.rag_pipeline import _get_embed_model
            await asyncio.to_thread(_get_embed_model)
            logger.info("[Startup] Embedding model warm-up complete")
        except Exception as e:
            logger.warning(f"[Startup] Warm-up embedding model failed: {e}")

        # Bước 2a': [OPT-2.4] nạp sẵn Q&A phổ biến vào cache (trả lời không cần API)
        try:
            from app.services.prewarm import prewarm_common_qa
            await prewarm_common_qa()
        except Exception as e:
            logger.warning(f"[Startup] Prewarm cache failed: {e}")

        # Bước 2b: khởi động worker embedding throttle liên tục (OPT-1.1/OPT-4.1).
        # Chỉ chạy nếu Qdrant sẵn sàng để tránh lỗi kết nối lặp.
        nonlocal worker_task
        if qdrant_ok:
            worker_task = asyncio.create_task(_embedding_worker_loop())
            logger.info("[Startup] Embedding worker loop đã khởi động")
        else:
            logger.warning(
                "[Startup] Bỏ qua worker embedding vì Qdrant chưa sẵn sàng. "
                "Gọi POST /debug/qdrant/init rồi POST /admin/embedding-jobs/run để embed thủ công."
            )

    warmup_task = asyncio.create_task(_warmup_then_start_worker())

    # 3. Auto backup database — chạy pg_dump lúc 00:00 hằng ngày.
    from app.services.backup_service import run_scheduled_backup
    scheduler = AsyncIOScheduler(timezone="Asia/Ho_Chi_Minh")
    scheduler.add_job(
        run_scheduled_backup,
        CronTrigger(hour=0, minute=0),
        id="daily_db_backup",
    )
    scheduler.start()
    logger.info("[Startup] Scheduler backup DB 00:00 hằng ngày đã khởi động")

    logger.info("PDTrip Chatbot API started")
    yield

    # ── Shutdown ──
    scheduler.shutdown(wait=False)
    # Dừng worker embedding + warm-up gọn gàng trước khi đóng kết nối DB.
    for task in (worker_task, warmup_task):
        if task and not task.done():
            task.cancel()
            try:
                await task
            except (asyncio.CancelledError, Exception):
                pass
    await engine.dispose()
    await close_mongo()
    logger.info("PDTrip Chatbot API stopped")


app = FastAPI(
    title="PDTrip Chatbot API",
    version="1.0.0",
    description="Backend cho chatbot du lịch với RAG pipeline",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    # Flutter web (`flutter run -d chrome`) dùng cổng ngẫu nhiên mỗi lần chạy →
    # cho phép mọi cổng localhost/127.0.0.1 bằng regex để preflight không bị 400.
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1)(:\d+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)

# ── Static: ảnh upload từ Media manager (admin) ────────────────────────────────
# Lưu ở static/uploads, phục vụ tại /uploads/<filename>. Tạo sẵn để mount không lỗi.
_UPLOADS_DIR = os.path.join("static", "uploads")
os.makedirs(_UPLOADS_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=_UPLOADS_DIR), name="uploads")


# ── Debug / Admin endpoints (no auth) ──────────────────────────────────────────

@app.get("/debug/qdrant", tags=["debug"])
async def debug_qdrant(
    _: User = Depends(require_admin),
):
    """Kiểm tra Qdrant collection status. Yêu cầu quyền admin."""
    try:
        from app.services.rag_pipeline import RAGPipeline
        rag = RAGPipeline()
        return await rag.debug_collection()
    except Exception as e:
        return {"error": str(e)}


@app.post("/debug/qdrant/init", tags=["debug"])
async def init_qdrant_collection(
    _: User = Depends(require_admin),
):
    """
    Tạo Qdrant collection nếu chưa tồn tại.
    Gọi endpoint này nếu gặp lỗi: 'Collection does not exist'.
    """
    try:
        from app.services.rag_pipeline import RAGPipeline
        rag = RAGPipeline()
        await rag.ensure_collection()
        info = await rag.debug_collection()
        return {"status": "ok", "detail": "Collection đã sẵn sàng", **info}
    except Exception as e:
        return {"status": "error", "detail": str(e)}


@app.post("/debug/qdrant/reindex", tags=["debug"])
async def reindex_all_knowledge(
    _: User = Depends(require_admin),
):
    """
    ✅ Manual trigger: Re-embed toàn bộ knowledge base vào Qdrant.
    Dùng khi Qdrant bị reset hoặc cần sync lại dữ liệu từ PostgreSQL.

    Steps:
    1. Reset tất cả embedding_jobs đang done/failed về pending
    2. Chạy embedding worker
    """
    try:
        from app.db.database import AsyncSessionLocal
        from app.db.models.admin import EmbeddingJob, KnowledgeEntry
        from app.services.embedding_jobs import EmbeddingJobService
        from sqlalchemy import select, update
        from datetime import datetime, timezone

        async with AsyncSessionLocal() as db:
            # Reset các jobs failed về pending để retry
            await db.execute(
                update(EmbeddingJob)
                .where(EmbeddingJob.status.in_(["failed", "done"]))
                .values(status="pending", error=None, updated_at=datetime.now(timezone.utc))
            )

            # Tạo mới jobs cho entries chưa có job nào
            result = await db.execute(select(KnowledgeEntry).where(KnowledgeEntry.is_active == True))
            entries = result.scalars().all()

            existing = await db.execute(select(EmbeddingJob.entity_id))
            existing_ids = {str(r) for r in existing.scalars().all()}

            new_jobs = [
                EmbeddingJob(
                    entity_type="knowledge_entry",
                    entity_id=e.id,
                    status="pending",
                )
                for e in entries if str(e.id) not in existing_ids
            ]
            if new_jobs:
                db.add_all(new_jobs)

            await db.commit()

            service = EmbeddingJobService(db)
            embed_result = await service.run_pending(limit=1000)

        from app.services.rag_pipeline import RAGPipeline
        info = await RAGPipeline().debug_collection()
        return {
            "status": "ok",
            "embedding": embed_result,
            "qdrant": info,
        }
    except Exception as e:
        return {"status": "error", "detail": str(e)}