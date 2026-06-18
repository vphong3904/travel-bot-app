from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import api_router
from app.utils import get_logger
from app.db.database import Base, engine

logger = get_logger("main")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ──
    # Tạo bảng DB (chỉ dùng dev — production dùng Alembic)
    # async with engine.begin() as conn:
    #     await conn.run_sync(Base.metadata.create_all)

    # Đảm bảo Qdrant collection tồn tại
    try:
        from app.services.rag_pipeline import RAGPipeline
        rag = RAGPipeline()
        await rag.ensure_collection()
    except Exception as e:
        logger.warning(f"Qdrant không sẵn sàng khi startup: {e}")

    logger.info("PDTrip Chatbot API started")
    yield

    # ── Shutdown ──
    await engine.dispose()
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
