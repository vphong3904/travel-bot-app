"""
RAG Pipeline — Retrieval-Augmented Generation cho PDTrip chatbot.

Flow:
  1. Embed câu hỏi bằng BGE-M3 (async, thread-pool)
  2. Tìm top-K chunk gần nhất trong Qdrant
  3. Build prompt với history + context
  4. Gọi Gemini API → trả về answer (normal hoặc stream)

Tất cả I/O blocking (model, Qdrant) chạy trong asyncio.to_thread()
để không block event-loop của FastAPI.
"""

from __future__ import annotations

import asyncio
import time
from typing import AsyncGenerator, Optional
from uuid import UUID

import google.generativeai as genai
from qdrant_client import QdrantClient
from qdrant_client.http import models as qmodels
from sentence_transformers import SentenceTransformer

from app.core.config import settings
from app.utils import get_logger

logger = get_logger("rag_pipeline")

# ── Lazy singletons (khởi tạo lần đầu khi cần, không block import) ───────────

_embed_model: Optional[SentenceTransformer] = None
_qdrant: Optional[QdrantClient] = None
_gemini_model = None


def _get_embed_model() -> SentenceTransformer:
    global _embed_model
    if _embed_model is None:
        logger.info(f"Loading embedding model: {settings.EMBEDDING_MODEL}")
        _embed_model = SentenceTransformer(settings.EMBEDDING_MODEL)
    return _embed_model


def _get_qdrant() -> QdrantClient:
    global _qdrant
    if _qdrant is None:
        _qdrant = QdrantClient(url=settings.QDRANT_URL)
        logger.info(f"Connected to Qdrant at {settings.QDRANT_URL}")
    return _qdrant


def _get_gemini():
    global _gemini_model
    if _gemini_model is None:
        if not settings.GEMINI_API_KEY:
            raise RuntimeError("GEMINI_API_KEY chưa được cấu hình trong .env")
        genai.configure(api_key=settings.GEMINI_API_KEY)
        _gemini_model = genai.GenerativeModel(settings.GEMINI_MODEL)
        logger.info(f"Initialized Gemini model: {settings.GEMINI_MODEL}")
    return _gemini_model


# ── Helpers sync (chạy trong thread-pool) ─────────────────────────────────────

def _embed_sync(text: str) -> list[float]:
    model = _get_embed_model()
    vec = model.encode(text, normalize_embeddings=True)
    return vec.tolist()


def _search_qdrant_sync(query_vec: list[float], top_k: int) -> list[dict]:
    client = _get_qdrant()
    results = client.search(
        collection_name=settings.QDRANT_COLLECTION,
        query_vector=query_vec,
        limit=top_k,
        score_threshold=settings.RAG_SCORE_THRESHOLD,
    )
    return [
        {
            "id": str(r.id),
            "score": round(r.score, 4),
            "text": r.payload.get("text", ""),
            "title": r.payload.get("title", ""),
            "category": r.payload.get("category", ""),
        }
        for r in results
    ]


def _upsert_qdrant_sync(entries: list[dict]) -> int:
    """
    Upsert danh sách entries vào Qdrant.
    entries = [{"id": str, "text": str, "title": str, "category": str}]
    """
    client = _get_qdrant()
    model = _get_embed_model()

    texts = [e["text"] for e in entries]
    vectors = model.encode(texts, normalize_embeddings=True, batch_size=32).tolist()

    points = [
        qmodels.PointStruct(
            id=e["id"],
            vector=vec,
            payload={
                "text": e["text"],
                "title": e.get("title", ""),
                "category": e.get("category", ""),
            },
        )
        for e, vec in zip(entries, vectors)
    ]

    client.upsert(collection_name=settings.QDRANT_COLLECTION, points=points)
    return len(points)


def _delete_qdrant_sync(entry_id: str) -> None:
    client = _get_qdrant()
    client.delete(
        collection_name=settings.QDRANT_COLLECTION,
        points_selector=qmodels.PointIdsList(points=[entry_id]),
    )


def _build_prompt(question: str, context_chunks: list[dict], history: list[dict]) -> str:
    """Xây dựng prompt tiếng Việt với context RAG và lịch sử hội thoại."""
    context_text = ""
    if context_chunks:
        context_text = "\n\n".join(
            f"[{i+1}] {c['text']}" for i, c in enumerate(context_chunks)
        )

    history_text = ""
    if history:
        lines = []
        for msg in history[-6:]:  # giữ tối đa 6 lượt gần nhất
            role = "Người dùng" if msg["role"] == "user" else "Trợ lý"
            lines.append(f"{role}: {msg['content']}")
        history_text = "\n".join(lines)

    prompt = (
        "Bạn là trợ lý du lịch thông minh của PDTrip, chuyên tư vấn du lịch Việt Nam.\n"
        "Hãy trả lời bằng tiếng Việt, thân thiện, ngắn gọn và chính xác.\n"
        "Chỉ sử dụng thông tin từ ngữ cảnh được cung cấp. "
        "Nếu không đủ thông tin, hãy nói thật thay vì đoán mò.\n\n"
    )

    if context_text:
        prompt += f"=== Thông tin tham khảo ===\n{context_text}\n\n"

    if history_text:
        prompt += f"=== Lịch sử hội thoại ===\n{history_text}\n\n"

    prompt += f"=== Câu hỏi ===\n{question}\n\n=== Câu trả lời ==="
    return prompt


# ── RAGPipeline class ─────────────────────────────────────────────────────────

class RAGPipeline:
    """
    Async RAG pipeline dùng cho FastAPI.
    Tất cả blocking I/O chạy qua asyncio.to_thread().
    """

    async def _embed(self, text: str) -> list[float]:
        return await asyncio.to_thread(_embed_sync, text)

    async def _search(self, query_vec: list[float]) -> list[dict]:
        return await asyncio.to_thread(
            _search_qdrant_sync, query_vec, settings.RAG_TOP_K
        )

    async def query(
        self,
        question: str,
        history: list[dict],
        session_id: str,
    ) -> dict:
        """
        Xử lý câu hỏi đầy đủ, trả về dict:
        {answer, sources, intent, prompt_tokens, completion_tokens, latency_ms}
        """
        t0 = time.monotonic()

        # 1. Embed + search
        query_vec = await self._embed(question)
        sources = await self._search(query_vec)

        # 2. Build prompt
        prompt = _build_prompt(question, sources, history)

        # 3. Gọi Gemini (blocking → thread)
        def _call_gemini() -> tuple[str, int, int]:
            model = _get_gemini()
            resp = model.generate_content(prompt)
            answer = resp.text or ""
            # Gemini trả về usage metadata nếu có
            usage = getattr(resp, "usage_metadata", None)
            p_tok = getattr(usage, "prompt_token_count", 0) or 0
            c_tok = getattr(usage, "candidates_token_count", 0) or 0
            return answer, p_tok, c_tok

        answer, prompt_tokens, completion_tokens = await asyncio.to_thread(_call_gemini)

        latency_ms = int((time.monotonic() - t0) * 1000)
        logger.info(
            f"[RAG] session={session_id} sources={len(sources)} "
            f"tokens={prompt_tokens}+{completion_tokens} latency={latency_ms}ms"
        )

        return {
            "answer": answer,
            "sources": sources,
            "intent": None,
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "latency_ms": latency_ms,
        }

    async def stream_query(
        self,
        question: str,
        history: list[dict],
        session_id: str,
    ) -> AsyncGenerator[dict, None]:
        """
        Streaming version: yield các chunk text, cuối cùng yield meta.
        Dùng Gemini stream API.
        """
        t0 = time.monotonic()

        query_vec = await self._embed(question)
        sources = await self._search(query_vec)
        prompt = _build_prompt(question, sources, history)

        # Gemini streaming — chạy trong thread để lấy iterator,
        # sau đó yield từng chunk về event-loop
        def _start_stream():
            model = _get_gemini()
            return model.generate_content(prompt, stream=True)

        stream = await asyncio.to_thread(_start_stream)

        full_answer = []
        prompt_tokens = 0
        completion_tokens = 0

        # Gemini stream trả về các GenerateContentResponse chunk
        for chunk in stream:
            text = getattr(chunk, "text", None)
            if text:
                full_answer.append(text)
                yield {"type": "chunk", "content": text}
            # Cập nhật usage từ chunk cuối
            usage = getattr(chunk, "usage_metadata", None)
            if usage:
                prompt_tokens = getattr(usage, "prompt_token_count", 0) or 0
                completion_tokens = getattr(usage, "candidates_token_count", 0) or 0
            # Nhường event-loop giữa các chunk
            await asyncio.sleep(0)

        latency_ms = int((time.monotonic() - t0) * 1000)
        logger.info(
            f"[RAG:stream] session={session_id} sources={len(sources)} "
            f"tokens={prompt_tokens}+{completion_tokens} latency={latency_ms}ms"
        )

        yield {
            "type": "meta",
            "sources": sources,
            "intent": None,
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "latency_ms": latency_ms,
        }

    # ── Quản lý vector store (gọi từ admin/embedding job) ─────────────────────

    async def upsert_knowledge(self, entries: list[dict]) -> int:
        """Embed và upsert danh sách knowledge entries vào Qdrant."""
        count = await asyncio.to_thread(_upsert_qdrant_sync, entries)
        logger.info(f"[RAG] Upserted {count} entries vào Qdrant")
        return count

    async def delete_knowledge(self, entry_id: str) -> None:
        """Xoá một entry khỏi Qdrant theo ID."""
        await asyncio.to_thread(_delete_qdrant_sync, entry_id)
        logger.info(f"[RAG] Deleted entry {entry_id} khỏi Qdrant")

    @staticmethod
    def chunk_text(text: str, chunk_size: int = 200) -> list[str]:
        """Chia văn bản thành các chunk theo số từ."""
        words = text.split()
        return [
            " ".join(words[i : i + chunk_size])
            for i in range(0, len(words), chunk_size)
        ]

    async def ensure_collection(self) -> None:
        """Tạo Qdrant collection nếu chưa tồn tại (gọi khi startup)."""
        def _create():
            client = _get_qdrant()
            existing = [c.name for c in client.get_collections().collections]
            if settings.QDRANT_COLLECTION not in existing:
                client.create_collection(
                    collection_name=settings.QDRANT_COLLECTION,
                    vectors_config=qmodels.VectorParams(
                        size=settings.EMBEDDING_DIM,
                        distance=qmodels.Distance.COSINE,
                    ),
                )
                logger.info(f"Created Qdrant collection: {settings.QDRANT_COLLECTION}")
            else:
                logger.info(f"Qdrant collection '{settings.QDRANT_COLLECTION}' already exists")

        await asyncio.to_thread(_create)
