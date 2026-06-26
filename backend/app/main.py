import asyncio
from contextlib import asynccontextmanager

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware

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


async def _run_pending_embedding_jobs() -> None:
    """
    ✅ FIX BUG CHÍNH: Tự động xử lý tất cả embedding jobs pending khi startup.

    Vấn đề gốc:
    - SQL seed data INSERT knowledge_entries + tạo embedding_jobs với status='pending'
    - Nhưng KHÔNG có worker nào tự động chạy → Qdrant luôn trống → search 0 kết quả
    - Chatbot không có context RAG → trả lời "không có thông tin"

    Fix: Gọi run_pending() ngay khi startup để embed toàn bộ knowledge base vào Qdrant.
    Chạy trong background task để không block server startup.
    """
    logger.info("[Startup] Bắt đầu xử lý pending embedding jobs...")
    try:
        from app.db.database import AsyncSessionLocal
        from app.services.embedding_jobs import EmbeddingJobService

        async with AsyncSessionLocal() as db:
            service = EmbeddingJobService(db)
            # Xử lý tất cả pending jobs (limit cao để cover toàn bộ seed data)
            result = await service.run_pending(limit=500)
            logger.info(
                f"[Startup] Embedding jobs hoàn tất — "
                f"done={result['done']} failed={result['failed']}"
            )

            # Log trạng thái Qdrant sau khi embed
            from app.services.rag_pipeline import RAGPipeline
            rag = RAGPipeline()
            try:
                info = await rag.debug_collection()
                logger.info(
                    f"[Startup] Qdrant collection '{info['collection']}' — "
                    f"points={info['points_count']} vectors={info.get('vectors_count', 'N/A')}"
                )
            except Exception as e:
                logger.warning(f"[Startup] Không thể lấy Qdrant info: {e}")

    except Exception as e:
        logger.error(f"[Startup] Lỗi khi xử lý embedding jobs: {e}", exc_info=True)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ──

    # 0. Kết nối MongoDB (log: search_history, user_behavior, flagged/unanswered)
    await connect_mongo()

    # 1. Tạo Qdrant collection với retry
    qdrant_ok = await _init_qdrant(retries=5, delay=2.0)

    # 2. Warm-up embedding model + chạy pending jobs (song song)
    async def _warmup_and_embed():
        try:
            # Bước 2a: load embedding model trước (blocking ~10-30s lần đầu)
            from app.services.rag_pipeline import _get_embed_model
            await asyncio.to_thread(_get_embed_model)
            logger.info("[Startup] Embedding model warm-up complete")
        except Exception as e:
            logger.warning(f"[Startup] Warm-up embedding model failed: {e}")

        # Bước 2b: sau khi model loaded, process pending jobs
        # (chỉ chạy nếu Qdrant sẵn sàng để tránh lỗi kết nối)
        if qdrant_ok:
            await _run_pending_embedding_jobs()
        else:
            logger.warning(
                "[Startup] Bỏ qua embedding jobs vì Qdrant chưa sẵn sàng. "
                "Gọi POST /debug/qdrant/init rồi POST /admin/embedding-jobs/run để embed thủ công."
            )

    asyncio.create_task(_warmup_and_embed())
    logger.info("PDTrip Chatbot API started")
    yield

    # ── Shutdown ──
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
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router)


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