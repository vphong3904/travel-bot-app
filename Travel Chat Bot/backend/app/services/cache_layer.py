"""
Cache Layer — YÊU CẦU 4.

Không có Redis trong stack hiện tại (xem requirements.txt) nên cache được
triển khai in-memory, an toàn cho asyncio (asyncio.Lock), đủ dùng cho quy mô
đồ án (1 process FastAPI, KB vài trăm entries).

3 lớp cache:
  1. Exact-match response cache: key = câu hỏi đã normalize.
  2. Semantic response cache: so khớp bằng cosine similarity giữa embedding
     câu hỏi mới với các câu hỏi đã cache trước đó (threshold cao, tránh
     trả nhầm câu trả lời cho câu hỏi khác nghĩa).
  3. Embedding cache: tránh encode lại câu hỏi giống/gần giống.

Cache có TTL đơn giản (mặc định 1 giờ) và có thể invalidate theo category
khi knowledge base được cập nhật (upsert/delete entry). 
"""

from __future__ import annotations

import asyncio
import math
import re
import time
import unicodedata
from dataclasses import dataclass, field
from typing import Optional

DEFAULT_TTL_SECONDS = 3600
SEMANTIC_MATCH_THRESHOLD = 0.97  # cao vì rủi ro trả nhầm câu trả lời
EMBEDDING_CACHE_MAX_SIZE = 2000
RESPONSE_CACHE_MAX_SIZE = 1000


def _normalize_key(text: str) -> str:
    """Chuẩn hoá câu hỏi để làm cache key: lower, bỏ khoảng trắng dư, bỏ dấu câu nhẹ."""
    text = unicodedata.normalize("NFC", text.strip().lower())
    text = re.sub(r"\s+", " ", text)
    text = re.sub(r"\s+([?!.,;:])", r"\1", text)  # bỏ khoảng trắng trước dấu câu
    text = re.sub(r"[?!.,;:]+$", "", text)
    return text.strip()


def _cosine(a: list[float], b: list[float]) -> float:
    if not a or not b or len(a) != len(b):
        return 0.0
    dot = sum(x * y for x, y in zip(a, b))
    norm_a = math.sqrt(sum(x * x for x in a))
    norm_b = math.sqrt(sum(y * y for y in b))
    if norm_a == 0 or norm_b == 0:
        return 0.0
    return dot / (norm_a * norm_b)


@dataclass
class _ResponseCacheEntry:
    payload: dict
    category: str
    embedding: Optional[list[float]]
    expires_at: float


@dataclass
class _Store:
    response_cache: dict[str, _ResponseCacheEntry] = field(default_factory=dict)
    embedding_cache: dict[str, tuple[list[float], float]] = field(default_factory=dict)
    lock: asyncio.Lock = field(default_factory=asyncio.Lock)


_store = _Store()


def _is_expired(expires_at: float) -> bool:
    return time.time() > expires_at


def _evict_if_needed(d: dict, max_size: int) -> None:
    if len(d) <= max_size:
        return
    # Loại bỏ ~10% phần tử cũ nhất theo thứ tự chèn (dict giữ insertion order)
    n_to_remove = max(1, len(d) // 10)
    for key in list(d.keys())[:n_to_remove]:
        d.pop(key, None)


# ── Response cache (exact-match) ────────────────────────────────────────────

async def get_cached_response(question: str) -> Optional[dict]:
    key = _normalize_key(question)
    async with _store.lock:
        entry = _store.response_cache.get(key)
        if entry is None:
            return None
        if _is_expired(entry.expires_at):
            _store.response_cache.pop(key, None)
            return None
        return dict(entry.payload)


async def set_cached_response(
    question: str,
    result: dict,
    category: str = "default",
    embedding: Optional[list[float]] = None,
    ttl_seconds: int = DEFAULT_TTL_SECONDS,
) -> None:
    key = _normalize_key(question)
    async with _store.lock:
        _store.response_cache[key] = _ResponseCacheEntry(
            payload=dict(result),
            category=category,
            embedding=list(embedding) if embedding else None,
            expires_at=time.time() + ttl_seconds,
        )
        _evict_if_needed(_store.response_cache, RESPONSE_CACHE_MAX_SIZE)


async def find_semantic_cache_match(
    query_vec: list[float], threshold: float = SEMANTIC_MATCH_THRESHOLD
) -> Optional[dict]:
    """So khớp embedding câu hỏi mới với các câu hỏi đã cache. Trả về None nếu
    không có entry nào đủ giống (threshold cao để tránh false positive)."""
    async with _store.lock:
        now = time.time()
        best_score = 0.0
        best_payload: Optional[dict] = None
        for key, entry in list(_store.response_cache.items()):
            if entry.embedding is None:
                continue
            if _is_expired(entry.expires_at):
                _store.response_cache.pop(key, None)
                continue
            score = _cosine(query_vec, entry.embedding)
            if score > best_score:
                best_score = score
                best_payload = entry.payload
        if best_payload is not None and best_score >= threshold:
            return dict(best_payload)
        return None


# ── Embedding cache ──────────────────────────────────────────────────────────

async def get_cached_embedding(text: str) -> Optional[list[float]]:
    key = _normalize_key(text)
    async with _store.lock:
        cached = _store.embedding_cache.get(key)
        if cached is None:
            return None
        vec, expires_at = cached
        if _is_expired(expires_at):
            _store.embedding_cache.pop(key, None)
            return None
        return list(vec)


async def set_cached_embedding(
    text: str, vector: list[float], ttl_seconds: int = DEFAULT_TTL_SECONDS * 6
) -> None:
    key = _normalize_key(text)
    async with _store.lock:
        _store.embedding_cache[key] = (list(vector), time.time() + ttl_seconds)
        _evict_if_needed(_store.embedding_cache, EMBEDDING_CACHE_MAX_SIZE)


# ── Invalidation khi knowledge base thay đổi ────────────────────────────────

async def invalidate_category(category: str) -> None:
    async with _store.lock:
        keys_to_remove = [
            k for k, e in _store.response_cache.items() if e.category == category
        ]
        for k in keys_to_remove:
            _store.response_cache.pop(k, None)


async def invalidate_all() -> None:
    async with _store.lock:
        _store.response_cache.clear()
        _store.embedding_cache.clear()


def stats() -> dict:
    """Dùng cho debug endpoint nếu cần."""
    return {
        "response_cache_size": len(_store.response_cache),
        "embedding_cache_size": len(_store.embedding_cache),
    }
