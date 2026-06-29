"""
Hybrid Search — YÊU CẦU 7.

Chạy song song 2 nhánh tìm kiếm:
  - Qdrant (semantic / dense vector)
  - PostgreSQL Full-Text Search (keyword / sparse)

Hợp nhất bằng Reciprocal Rank Fusion (RRF) — không cần normalize score giữa
2 hệ thống khác thang đo (cosine similarity vs ts_rank/trigram similarity),
chỉ cần dùng RANK của mỗi item trong từng nhánh.

Sau RRF, re-rank lại top kết quả bằng cross-encoder
(BAAI/bge-reranker-v2-m3, theo đúng kế hoạch RAG ban đầu của đồ án) để có thứ
hạng chính xác hơn theo mức độ liên quan thực sự với câu hỏi. Cross-encoder
được load lazy và có fallback an toàn: nếu model chưa được tải / lỗi (ví dụ
chưa có mạng để download lần đầu), hệ thống tự động bỏ qua bước rerank và
dùng thẳng kết quả RRF — không làm sập pipeline.
"""

from __future__ import annotations

import asyncio
from typing import Awaitable, Callable, Optional

from app.utils import get_logger

logger = get_logger("hybrid_search")

RRF_K = 60  # hằng số RRF chuẩn (giảm ảnh hưởng của rank quá cao/thấp)

_reranker = None
_reranker_failed = False


def _dedup_key(item: dict) -> str:
    """Khoá khử trùng giữa 2 nhánh: ưu tiên title, fallback sang id/text đầu."""
    title = (item.get("title") or "").strip().lower()
    if title:
        return f"title::{title}"
    return f"text::{(item.get('text') or '')[:80].strip().lower()}"


def _reciprocal_rank_fusion(
    qdrant_results: list[dict], pg_results: list[dict], k: int = RRF_K
) -> list[dict]:
    """Hợp nhất 2 danh sách đã sắp hạng (rank 0 = tốt nhất) bằng RRF."""
    scores: dict[str, float] = {}
    items: dict[str, dict] = {}

    for rank, item in enumerate(qdrant_results):
        key = _dedup_key(item)
        scores[key] = scores.get(key, 0.0) + 1.0 / (k + rank + 1)
        if key not in items:
            items[key] = item

    for rank, item in enumerate(pg_results):
        key = _dedup_key(item)
        scores[key] = scores.get(key, 0.0) + 1.0 / (k + rank + 1)
        if key not in items:
            items[key] = item
        else:
            # Nếu đã có từ Qdrant, giữ nguyên item Qdrant (score semantic cao hơn ý nghĩa)
            # nhưng đánh dấu là tìm thấy ở cả 2 nhánh (đáng tin hơn).
            items[key] = dict(items[key])
            items[key]["found_in_both"] = True

    fused = sorted(items.values(), key=lambda it: scores[_dedup_key(it)], reverse=True)
    for it in fused:
        it["rrf_score"] = round(scores[_dedup_key(it)], 5)
    return fused


def _get_reranker():
    """Lazy-load cross-encoder. Trả về None nếu load thất bại (offline, thiếu RAM...)."""
    global _reranker, _reranker_failed
    if _reranker_failed:
        return None
    if _reranker is None:
        try:
            from sentence_transformers import CrossEncoder

            # [OPT-1.3] Dùng GPU nếu có (NVIDIA + torch CUDA), ngược lại CPU.
            device = "cpu"
            try:
                import torch
                if torch.cuda.is_available():
                    device = "cuda"
            except Exception:
                pass

            _reranker = CrossEncoder("BAAI/bge-reranker-v2-m3", max_length=512, device=device)
            logger.info(f"[Hybrid Search] Đã load cross-encoder BAAI/bge-reranker-v2-m3 | device={device}")
        except Exception as e:
            logger.warning(
                f"[Hybrid Search] Không load được cross-encoder, bỏ qua rerank: {e}"
            )
            _reranker_failed = True
            return None
    return _reranker


def _rerank_sync(question: str, candidates: list[dict], top_k: int) -> list[dict]:
    reranker = _get_reranker()
    if reranker is None or not candidates:
        return candidates[:top_k]

    pairs = [(question, c.get("text", "")) for c in candidates]
    try:
        scores = reranker.predict(pairs)
    except Exception as e:
        logger.warning(f"[Hybrid Search] Rerank lỗi, dùng kết quả RRF: {e}")
        return candidates[:top_k]

    for c, s in zip(candidates, scores):
        c["rerank_score"] = round(float(s), 4)

    reranked = sorted(candidates, key=lambda c: c["rerank_score"], reverse=True)
    return reranked[:top_k]


async def hybrid_search(
    question: str,
    qdrant_search_fn: Callable[[], Awaitable[list[dict]]],
    postgres_search_fn: Callable[[], Awaitable[list[dict]]],
    rrf_top_k: int = 15,
    final_top_k: int = 5,
    use_reranking: bool = True,
) -> tuple[list[dict], dict]:
    """
    Chạy song song 2 nhánh search, hợp nhất bằng RRF, rerank (nếu khả dụng),
    trả về (kết quả cuối, meta).

    meta["method"] cho biết nguồn dữ liệu thực tế đã dùng:
      - "hybrid": cả 2 nhánh đều có kết quả
      - "qdrant_only": chỉ Qdrant có kết quả
      - "postgres_only": chỉ PostgreSQL FTS có kết quả
      - "none": cả 2 nhánh đều trống
    """
    qdrant_results, pg_results = await asyncio.gather(
        qdrant_search_fn(), postgres_search_fn(), return_exceptions=False
    )
    qdrant_results = qdrant_results or []
    pg_results = pg_results or []

    if qdrant_results and pg_results:
        method = "hybrid"
    elif qdrant_results:
        method = "qdrant_only"
    elif pg_results:
        method = "postgres_only"
    else:
        method = "none"

    if method == "none":
        return [], {"method": method, "qdrant_count": 0, "pg_count": 0}

    fused = _reciprocal_rank_fusion(qdrant_results, pg_results)
    fused = fused[:rrf_top_k]

    if use_reranking and fused:
        final_results = await asyncio.to_thread(_rerank_sync, question, fused, final_top_k)
    else:
        final_results = fused[:final_top_k]

    meta = {
        "method": method,
        "qdrant_count": len(qdrant_results),
        "pg_count": len(pg_results),
        "reranked": use_reranking and _reranker is not None,
    }
    return final_results, meta
