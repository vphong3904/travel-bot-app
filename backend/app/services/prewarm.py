"""
prewarm.py — [OPT-2.4] Nạp sẵn bộ Q&A phổ biến (city-agnostic) vào response cache
lúc startup, để câu hỏi quen thuộc được trả lời NGAY mà không gọi Gemini — kể cả
lần hỏi đầu tiên.

Mỗi entry được lưu kèm embedding → khớp cả:
  - exact-match (gõ đúng câu), VÀ
  - semantic cache (câu gần giống, cosine ≥ ngưỡng).

Chỉ chứa câu hỏi CHUNG (tiền tệ, sim, visa, an toàn, thời điểm...) — không phụ
thuộc thành phố, nên an toàn khi cache theo key toàn cục.
"""

from __future__ import annotations

import asyncio
import json
from pathlib import Path

from app.services import cache_layer
from app.utils import get_logger

logger = get_logger("prewarm")

_COMMON_QA_PATH = Path(__file__).resolve().parent.parent / "data" / "common_qa.json"
_PREWARM_TTL = 30 * 24 * 3600  # 30 ngày (refresh mỗi lần startup)


async def prewarm_common_qa() -> int:
    """Embed + nạp common_qa.json vào cache. Trả số entry đã nạp (0 nếu lỗi/thiếu)."""
    try:
        items = json.loads(_COMMON_QA_PATH.read_text(encoding="utf-8"))
    except FileNotFoundError:
        logger.warning("[Prewarm] Không tìm thấy common_qa.json — bỏ qua")
        return 0
    except Exception as e:
        logger.warning(f"[Prewarm] Lỗi đọc common_qa.json: {e}")
        return 0

    # import trễ để tránh load model khi import module
    from app.services.rag_pipeline import _embed_sync

    count = 0
    for it in items:
        q = (it.get("q") or "").strip()
        a = (it.get("a") or "").strip()
        if not q or not a:
            continue
        try:
            vec = await asyncio.to_thread(_embed_sync, q)
        except Exception as e:
            logger.warning(f"[Prewarm] Embed lỗi '{q[:40]}': {e}")
            vec = None
        result = {
            "answer": a,
            "sources": [],
            "suggested_questions": [],
            "intent": "faq",
            "prompt_tokens": 0,
            "completion_tokens": 0,
            "hallucination_confidence": 1.0,
            "confidence_score": 1.0,
            "cache_hit": "prewarm",
        }
        await cache_layer.set_cached_response(
            q, result, category="prewarm", embedding=vec, ttl_seconds=_PREWARM_TTL
        )
        count += 1

    logger.info(f"[Prewarm] Đã nạp {count} câu Q&A phổ biến vào cache (không cần API)")
    return count
