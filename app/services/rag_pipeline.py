"""
RAG Pipeline — Retrieval-Augmented Generation cho PDTrip chatbot.

SDK: google-genai >= 2.0 (thay thế google-generativeai cũ)

Flow:
  1. Embed câu hỏi bằng BGE-M3 (asyncio.to_thread)
  2. Tìm top-K chunk trong Qdrant (asyncio.to_thread)
  3. Build prompt với history + context
  4. Gọi Gemini qua client.aio (async native):
     - query()        → generate_content (non-stream)
     - stream_query() → generate_content_stream (async iterator thật sự)

Không còn dùng asyncio.to_thread cho Gemini call.
"""

from __future__ import annotations

import asyncio
import time
import uuid
from typing import AsyncGenerator, Optional

from google import genai
from google.genai import types as genai_types
from qdrant_client import QdrantClient
from qdrant_client.http import models as qmodels
from sentence_transformers import SentenceTransformer

from app.core.config import settings
from app.utils import get_logger

logger = get_logger("rag_pipeline")


# ── Lazy singletons ───────────────────────────────────────────────────────────

_embed_model: Optional[SentenceTransformer] = None
_qdrant: Optional[QdrantClient] = None
_genai_client: Optional[genai.Client] = None


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


def _get_genai_client() -> genai.Client:
    """
    Trả về singleton google-genai Client.
    Client này thread-safe và có thể dùng chung toàn app.
    client.aio.models.* cung cấp async API native.
    """
    global _genai_client
    if _genai_client is None:
        if not settings.GEMINI_API_KEY:
            raise RuntimeError("GEMINI_API_KEY chưa được cấu hình trong .env")
        _genai_client = genai.Client(api_key=settings.GEMINI_API_KEY)
        logger.info(f"Initialized google-genai Client (model: {settings.GEMINI_MODEL})")
    return _genai_client


# ── Sync helpers (chạy trong thread-pool) ────────────────────────────────────

def _embed_sync(text: str) -> list[float]:
    model = _get_embed_model()
    vec = model.encode(text, normalize_embeddings=True)
    return vec.tolist()


def _search_qdrant_sync(query_vec: list[float], top_k: int) -> list[dict]:
    client = _get_qdrant()
    results = client.query_points(
        collection_name=settings.QDRANT_COLLECTION,
        query=query_vec,
        limit=top_k,
        score_threshold=settings.RAG_SCORE_THRESHOLD,
    ).points                          # ← .points để lấy list

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
    Embed + upsert danh sách knowledge entries vào Qdrant.
    Point ID dùng UUID5 deterministic từ (entry_id, chunk_index)
    để tránh trùng lặp khi re-embed.
    """
    client = _get_qdrant()
    model = _get_embed_model()

    texts = [e["text"] for e in entries]
    vectors = model.encode(texts, normalize_embeddings=True, batch_size=32).tolist()

    points = []
    for e, vec in zip(entries, vectors):
        # e["id"] = "{entry_uuid}_{chunk_index}" — dùng UUID5 để ra UUID hợp lệ
        point_uuid = str(uuid.uuid5(uuid.NAMESPACE_OID, e["id"]))
        points.append(
            qmodels.PointStruct(
                id=point_uuid,
                vector=vec,
                payload={
                    "text": e["text"],
                    "title": e.get("title", ""),
                    "category": e.get("category", ""),
                    "source_id": e["id"],  # giữ lại ID gốc để tra cứu
                },
            )
        )

    client.upsert(collection_name=settings.QDRANT_COLLECTION, points=points)
    return len(points)


def _delete_qdrant_sync(entry_id: str) -> None:
    """Xoá tất cả chunk của một entry (filter theo payload source_id)."""
    client = _get_qdrant()
    client.delete(
        collection_name=settings.QDRANT_COLLECTION,
        points_selector=qmodels.FilterSelector(
            filter=qmodels.Filter(
                must=[
                    qmodels.FieldCondition(
                        key="source_id",
                        match=qmodels.MatchText(text=entry_id),
                    )
                ]
            )
        ),
    )


def _build_prompt(
    question: str,
    context_chunks: list[dict],
    history: list[dict],
) -> str:
    """Xây dựng prompt tiếng Việt với context RAG và lịch sử hội thoại."""
    context_text = ""
    if context_chunks:
        context_text = "\n\n".join(
            f"[{i + 1}] {c['text']}" for i, c in enumerate(context_chunks)
        )

    history_text = ""
    if history:
        lines = []
        for msg in history[-6:]:
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


# ── Gemini config dùng chung ──────────────────────────────────────────────────

def _gemini_config() -> genai_types.GenerateContentConfig:
    return genai_types.GenerateContentConfig(
        max_output_tokens=2048,
        temperature=0.7,
    )


# ── RAGPipeline ───────────────────────────────────────────────────────────────

class RAGPipeline:
    """
    Async RAG pipeline dùng cho FastAPI.

    - Embedding / Qdrant: asyncio.to_thread (sync libs)
    - Gemini: client.aio.models.* (async native, không cần to_thread)
    """

    # ── Private helpers ───────────────────────────────────────────────────────

    async def _embed(self, text: str) -> list[float]:
        return await asyncio.to_thread(_embed_sync, text)

    async def _search(self, query_vec: list[float]) -> list[dict]:
        return await asyncio.to_thread(
            _search_qdrant_sync, query_vec, settings.RAG_TOP_K
        )

    # ── Public: non-stream ────────────────────────────────────────────────────

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

        query_vec = await self._embed(question)
        sources = await self._search(query_vec)
        prompt = _build_prompt(question, sources, history)

        client = _get_genai_client()

        # ✅ Async native — không block event loop
        response = await client.aio.models.generate_content(
            model=settings.GEMINI_MODEL,
            contents=prompt,
            config=_gemini_config(),
        )

        answer = response.text or ""
        usage = response.usage_metadata
        prompt_tokens = (usage.prompt_token_count or 0) if usage else 0
        completion_tokens = (usage.candidates_token_count or 0) if usage else 0

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

    # ── Public: SSE stream ────────────────────────────────────────────────────

    async def stream_query(
        self,
        question: str,
        history: list[dict],
        session_id: str,
    ) -> AsyncGenerator[dict, None]:
        """
        Streaming version: yield chunk text từng phần, cuối yield meta.

        Dùng client.aio.models.generate_content_stream — AsyncIterator thật sự,
        không block event loop, không cần asyncio.to_thread.
        """
        t0 = time.monotonic()

        query_vec = await self._embed(question)
        sources = await self._search(query_vec)
        prompt = _build_prompt(question, sources, history)

        client = _get_genai_client()

        prompt_tokens = 0
        completion_tokens = 0

        # ✅ async for — stream từng chunk ngay khi Gemini trả về
        async for chunk in await client.aio.models.generate_content_stream(
            model=settings.GEMINI_MODEL,
            contents=prompt,
            config=_gemini_config(),
        ):
            text = chunk.text  # None hoặc str
            if text:
                yield {"type": "chunk", "content": text}

            # usage_metadata chỉ có ở chunk cuối
            usage = chunk.usage_metadata
            if usage:
                prompt_tokens = usage.prompt_token_count or 0
                completion_tokens = usage.candidates_token_count or 0

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

    # ── Quản lý vector store ──────────────────────────────────────────────────

    async def upsert_knowledge(self, entries: list[dict]) -> int:
        count = await asyncio.to_thread(_upsert_qdrant_sync, entries)
        logger.info(f"[RAG] Upserted {count} chunks vào Qdrant")
        return count

    async def delete_knowledge(self, entry_id: str) -> None:
        await asyncio.to_thread(_delete_qdrant_sync, entry_id)
        logger.info(f"[RAG] Deleted entry {entry_id} khỏi Qdrant")

    @staticmethod
    def chunk_text(text: str, chunk_size: int = 200) -> list[str]:
        """Chia văn bản thành các chunk theo số từ."""
        words = text.split()
        return [
            " ".join(words[i: i + chunk_size])
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
                logger.info(
                    f"Qdrant collection '{settings.QDRANT_COLLECTION}' already exists"
                )

        await asyncio.to_thread(_create)