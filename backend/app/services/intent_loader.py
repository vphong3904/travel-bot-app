"""
intent_loader.py — [OPT-3.1] Nạp intent patterns từ bảng DB `intent_patterns`.

Trước đây nlp_preprocessor chỉ đọc `app/data/intent_patterns.json`. Sau migration
T-026, dữ liệu intent đã nằm trong DB (admin sửa được). Module này đọc DB rồi áp
vào runtime của nlp_preprocessor.

Chiến lược MERGE (an toàn):
  - Lấy bộ keyword trong file làm NỀN (đảm bảo các intent bắt buộc như
    out_of_scope / greeting luôn tồn tại — detect_intent truy cập trực tiếp).
  - OVERLAY theo từng intent: intent nào có dòng trong DB thì thay danh sách
    keyword của intent đó bằng dữ liệu DB (admin là nguồn sự thật cho intent đó).
  - Intent không có dòng DB nào → giữ keyword từ file.

Gọi lúc startup và sau khi admin sửa (endpoint reload).
"""

from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.travel import IntentPattern
from app.services import nlp_preprocessor as nlp
from app.utils import get_logger

logger = get_logger("intent_loader")


async def load_intent_patterns_from_db(db: AsyncSession) -> int:
    """
    Đọc intent_patterns đang active từ DB, merge với file, áp vào nlp runtime.
    Trả về tổng số keyword đã áp (0 nếu DB trống → giữ nguyên file).
    """
    rows = (
        await db.execute(
            select(IntentPattern).where(IntentPattern.is_active == True)  # noqa: E712
        )
    ).scalars().all()

    if not rows:
        logger.info("[IntentLoader] DB chưa có intent_patterns active — giữ bộ từ file")
        return 0

    # Nền = bộ đang dùng (đã nạp từ file lúc import module)
    merged: dict[str, list[str]] = {
        intent: list(keywords) for intent, keywords in nlp.INTENT_PATTERNS.items()
    }

    # Gom keyword DB theo intent
    db_by_intent: dict[str, list[str]] = {}
    for r in rows:
        db_by_intent.setdefault(r.intent, []).append(r.keyword)

    # Overlay từng intent có trong DB
    for intent, keywords in db_by_intent.items():
        merged[intent] = keywords

    nlp.apply_intent_patterns(merged)
    total = sum(len(v) for v in merged.values())
    logger.info(
        f"[IntentLoader] Đã áp intent từ DB — {len(db_by_intent)} intent, "
        f"{sum(len(v) for v in db_by_intent.values())} keyword DB / {total} tổng"
    )
    return total
