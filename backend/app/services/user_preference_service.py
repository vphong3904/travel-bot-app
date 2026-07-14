"""
User Preference Service — TP-003 (.agent/trip-ai).

Suy ra hồ sơ sở thích du lịch của user từ dữ liệu ĐÃ CÓ (TR-05, không thêm
bảng mới):
  - chat_messages (role='user' của user, 50 tin gần nhất)   → trọng số ×3
  - Mongo search_history (keyword đã tìm)                    → trọng số ×2
  - user_favorites + destination_view_logs (mô tả điểm đến)  → trọng số ×1

Kết quả: top 3 tag trong PREFERENCE_TAXONOMY với score chuẩn hoá 0..1,
cache in-memory TTL 600s. Mongo/DB lỗi từng nguồn thì bỏ nguồn đó,
không fail cả profile.
"""
from __future__ import annotations

import time
import unicodedata
from typing import Optional

from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.utils import get_logger

logger = get_logger("user_preference")

# ── Taxonomy sở thích (mục 3 roadmap — keyword đã bỏ dấu, so khớp không dấu) ──
PREFERENCE_TAXONOMY: dict[str, dict] = {
    "biển": {
        # Bug: keyword bỏ dấu "bien" trùng cả "biên" (biên giới/biên phòng —
        # KHÔNG liên quan biển) và "vinh " trùng "Vĩnh" (tên riêng rất phổ biến:
        # Vĩnh Nghiêm, Vĩnh Long, Vĩnh Phúc...). Phát hiện qua test thật trên DB:
        # Châu Đốc ("biên giới") và Bắc Giang ("chùa Vĩnh Nghiêm") bị gán nhầm tag
        # "Biển đảo". Bỏ 2 keyword mơ hồ này, giữ các cụm đặc trưng đủ để nhận
        # diện biển (đã verify Nha Trang/Đà Nẵng/Vũng Tàu vẫn khớp đúng).
        "label": "Biển đảo",
        "keywords": ["dao ", "hon ", "bai tam", "bai bien",
                     "lan bien", "san ho", "cat trang", "tam bien", "hai dang"],
    },
    "núi": {
        "label": "Núi rừng",
        "keywords": ["nui", "deo ", "trekking", "leo nui", "dinh ", "cao nguyen",
                     "ban lang", "ruong bac thang"],
    },
    "thiên_nhiên": {
        "label": "Thiên nhiên",
        "keywords": ["thien nhien", "ngam may", "san may", "ngam hoa", "mua hoa",
                     "thac ", "rung ", "ho ", "phong canh", "canh dep", "hoang so"],
    },
    "healing": {
        "label": "Chill / Healing",
        "keywords": ["chill", "healing", "thu gian", "yen tinh", "nghi duong",
                     "binh yen", "chua lanh", "tinh lang", "cham", "yen binh"],
    },
    "văn_hoá": {
        "label": "Văn hoá – Lịch sử",
        "keywords": ["van hoa", "di tich", "bao tang", "lich su", "lang nghe",
                     "pho co", "co kinh", "den ", "dinh lang", "kien truc"],
    },
    "ẩm_thực": {
        "label": "Ẩm thực",
        "keywords": ["am thuc", "mon ngon", "dac san", "quan an", "an gi",
                     "food tour", "hai san", "an vat", "quan ngon", "an uong"],
    },
    "phượt": {
        "label": "Phượt / Khám phá",
        "keywords": ["phuot", "xe may", "du lich bui", "camping", "cam trai",
                     "kham pha", "off road", "xuyen viet"],
    },
    "gia_đình": {
        "label": "Gia đình",
        "keywords": ["gia dinh", "tre em", "con nho", "cho be", "ca nha",
                     "bo me", "nguoi lon tuoi"],
    },
    "sống_ảo": {
        "label": "Sống ảo / Check-in",
        "keywords": ["song ao", "check in", "check-in", "chup anh", "chup hinh",
                     "goc chup", "instagram"],
    },
    "mua_sắm": {
        "label": "Mua sắm",
        "keywords": ["mua sam", "cho dem", "shopping", "outlet", "qua luu niem",
                     "mua gi ve"],
    },
    "tâm_linh": {
        "label": "Tâm linh",
        "keywords": ["tam linh", "chua ", "hanh huong", "le chua", "cau an",
                     "thien vien"],
    },
    "giải_trí": {
        "label": "Vui chơi giải trí",
        "keywords": ["vui choi", "giai tri", "cong vien", "vinwonders", "bar ",
                     "pub ", "nightlife", "khu vui choi", "cong vien nuoc"],
    },
}

_CACHE_TTL_SECONDS = 600
_profile_cache: dict[str, tuple[float, list[dict]]] = {}


def strip_accents(s: str) -> str:
    """Bỏ dấu tiếng Việt để so khớp keyword không phân biệt dấu."""
    if not s:
        return ""
    s = s.replace("đ", "d").replace("Đ", "D")
    nfkd = unicodedata.normalize("NFD", s)
    return "".join(c for c in nfkd if not unicodedata.combining(c)).lower()


def score_text(text_value: str, weight: float = 1.0) -> dict[str, float]:
    """Đếm keyword taxonomy xuất hiện trong 1 đoạn text (đã áp trọng số)."""
    scores: dict[str, float] = {}
    plain = " " + strip_accents(text_value) + " "
    for tag, cfg in PREFERENCE_TAXONOMY.items():
        hits = sum(1 for kw in cfg["keywords"] if kw in plain)
        if hits:
            scores[tag] = scores.get(tag, 0.0) + hits * weight
    return scores


def _merge(into: dict[str, float], other: dict[str, float]) -> None:
    for k, v in other.items():
        into[k] = into.get(k, 0.0) + v


def _finalize(raw: dict[str, float], top_n: int = 3) -> list[dict]:
    """Chuẩn hoá theo max → 0..1, giữ top N tag có score tương đối ≥ 0.15."""
    if not raw:
        return []
    max_score = max(raw.values())
    if max_score <= 0:
        return []
    normalized = sorted(
        ({"tag": t, "score": round(v / max_score, 3), "label": PREFERENCE_TAXONOMY[t]["label"]}
         for t, v in raw.items()),
        key=lambda x: x["score"],
        reverse=True,
    )
    return [x for x in normalized[:top_n] if x["score"] >= 0.15]


async def _scores_from_chat(db: AsyncSession, user_id: str) -> dict[str, float]:
    rows = await db.execute(
        text(
            """
            SELECT m.content
            FROM chat_messages m
            JOIN chat_sessions s ON s.id = m.session_id
            WHERE s.user_id = :uid AND m.role = 'user'
            ORDER BY m.created_at DESC
            LIMIT 50
            """
        ),
        {"uid": str(user_id)},
    )
    scores: dict[str, float] = {}
    for r in rows:
        _merge(scores, score_text(r.content or "", weight=3.0))
    return scores


async def _scores_from_search_history(user_id: str) -> dict[str, float]:
    from app.services import log_service

    scores: dict[str, float] = {}
    history = await log_service.get_search_history(str(user_id), limit=30)
    for h in history:
        _merge(scores, score_text(h.get("keyword") or "", weight=2.0))
    return scores


async def _scores_from_destinations(db: AsyncSession, user_id: str) -> dict[str, float]:
    """Sở thích ngầm từ điểm đến đã favorite / đã xem (mô tả của destination)."""
    rows = await db.execute(
        text(
            """
            SELECT DISTINCT d.description, d.special, d.region
            FROM destinations d
            WHERE d.id IN (
                SELECT destination_id FROM user_favorites WHERE user_id = :uid
                UNION
                SELECT destination_id FROM destination_view_logs
                WHERE user_id = :uid
                ORDER BY destination_id
                LIMIT 20
            )
            LIMIT 20
            """
        ),
        {"uid": str(user_id)},
    )
    scores: dict[str, float] = {}
    for r in rows:
        blob = " ".join(filter(None, [r.description, r.special, r.region]))
        _merge(scores, score_text(blob, weight=1.0))
    return scores


async def get_profile(db: AsyncSession, user_id: str) -> list[dict]:
    """
    Trả về [{tag, score, label}] (tối đa 3, score 0..1 giảm dần).
    Rỗng = chưa đủ tín hiệu (user mới) → caller tự fallback.
    """
    uid = str(user_id)
    cached = _profile_cache.get(uid)
    now = time.monotonic()
    if cached and cached[0] > now:
        return cached[1]

    raw: dict[str, float] = {}
    for source_fn, name in (
        (lambda: _scores_from_chat(db, uid), "chat"),
        (lambda: _scores_from_search_history(uid), "search_history"),
        (lambda: _scores_from_destinations(db, uid), "destinations"),
    ):
        try:
            _merge(raw, await source_fn())
        except Exception as e:  # từng nguồn lỗi thì bỏ, không fail profile
            logger.warning(f"[get_profile] Bỏ nguồn {name} do lỗi: {e}")

    profile = _finalize(raw)
    _profile_cache[uid] = (now + _CACHE_TTL_SECONDS, profile)
    return profile


def invalidate_profile_cache(user_id: Optional[str] = None) -> None:
    if user_id is None:
        _profile_cache.clear()
    else:
        _profile_cache.pop(str(user_id), None)


def keywords_for_tags(tags: list[str], max_per_tag: int = 6) -> list[str]:
    """Lấy keyword đại diện cho list tag — dùng cho planner ưu tiên item khớp."""
    kws: list[str] = []
    for tag in tags:
        cfg = PREFERENCE_TAXONOMY.get(tag)
        if cfg:
            kws.extend(cfg["keywords"][:max_per_tag])
    return kws
