"""
Trip Chat Planner — tích hợp AI Trip Planner vào luồng chatbot (Req 2).

Khi user chat, nếu phát hiện ý định lên lịch trình, trợ lý sẽ hỏi TỪNG BƯỚC
(điểm đến → số ngày → tuỳ chọn) cho tới khi đủ dữ liệu rồi dựng lịch trình
NGAY TRONG CHAT (dùng entity thật từ DB qua trip_planner_service). User có
quyền lưu hoặc không — plan đính kèm dưới dạng itinerary + `ai_plan` để mobile
lưu qua /trips/ai/confirm.

Thiết kế STATELESS: mỗi lượt tự suy lại slot từ toàn bộ tin nhắn user trong
session (không thêm cột DB). "Đang trong chế độ lên lịch" nhận biết bằng
PLANNER_MARKER ở đầu câu hỏi trợ lý ở lượt trước.
"""
from __future__ import annotations

import re
from typing import Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.services import trip_planner_service
from app.services.nlp_preprocessor import extract_entities
from app.services.user_preference_service import PREFERENCE_TAXONOMY, score_text, strip_accents
from app.utils import get_logger

logger = get_logger("trip_chat_planner")

# Marker vô hình đầu câu hỏi slot-filling → nhận biết "đang lên lịch" ở lượt sau.
PLANNER_MARKER = "🧭"

# Kích hoạt chế độ lên lịch khi câu hỏi chứa 1 trong các cụm này.
_TRIGGER_KEYWORDS = (
    "lịch trình", "lên lịch", "lên kế hoạch", "kế hoạch đi", "sắp lịch",
    "plan trip", "lập kế hoạch", "gợi ý chuyến đi", "lên chuyến đi",
    "đi chơi mấy ngày", "book lịch", "itinerary",
)

_SKIP_WORDS = ("bỏ qua", "khong", "không", "tùy", "tuy", "sao cũng được",
               "gì cũng được", "skip", "thôi", "tuỳ bạn", "kh", "ko")


def has_trigger(text: str) -> bool:
    low = text.lower()
    return any(k in low for k in _TRIGGER_KEYWORDS)


def _last_assistant(history: list[dict]) -> Optional[str]:
    for m in reversed(history):
        if m.get("role") == "assistant":
            return m.get("content") or ""
    return None


def is_planning_turn(history: list[dict], message: str) -> bool:
    """Đang trong luồng lên lịch nếu: câu hiện tại kích hoạt, HOẶC câu trợ lý
    gần nhất là câu hỏi slot-filling (bắt đầu bằng PLANNER_MARKER)."""
    if has_trigger(message):
        return True
    last = _last_assistant(history)
    return bool(last and last.lstrip().startswith(PLANNER_MARKER))


def _asked_optional(history: list[dict]) -> bool:
    for m in history:
        if m.get("role") != "assistant":
            continue
        c = (m.get("content") or "").lstrip()
        if c.startswith(PLANNER_MARKER) and "mấy người" in c.lower():
            return True
    return False


# ── Slot extractors ──────────────────────────────────────────────────────────

def _extract_budget(text: str) -> Optional[int]:
    low = strip_accents(text)
    # "5 trieu", "5tr", "5 tr"
    m = re.search(r"(\d+(?:[.,]\d+)?)\s*(trieu|tr|cu)\b", low)
    if m:
        return int(float(m.group(1).replace(",", ".")) * 1_000_000)
    # "500k", "500 nghin", "500 ngan"
    m = re.search(r"(\d+(?:[.,]\d+)?)\s*(k|nghin|ngan)\b", low)
    if m:
        return int(float(m.group(1).replace(",", ".")) * 1_000)
    # số lớn dạng "3.000.000" hoặc "3000000" (kèm "dong"/"vnd" hoặc >= 100000)
    m = re.search(r"(\d[\d.]{5,})\s*(dong|vnd|d)?\b", low)
    if m:
        digits = m.group(1).replace(".", "")
        if digits.isdigit():
            val = int(digits)
            if val >= 100_000:
                return val
    return None


def _extract_travelers(text: str) -> Optional[int]:
    low = strip_accents(text)
    m = re.search(r"(\d+)\s*(nguoi|khach|thanh vien|ban|dua)\b", low)
    if m:
        n = int(m.group(1))
        if 1 <= n <= 50:
            return n
    words = {"mot minh": 1, "hai": 2, "ba nguoi": 3, "bon": 4}
    for w, n in words.items():
        if w in low:
            return n
    return None


_TRAVEL_TYPE_KEYWORDS = {
    "couple": ("cap doi", "couple", "nguoi yeu", "vo chong", "honeymoon", "tuan trang mat"),
    "family": ("gia dinh", "family", "ca nha", "bo me", "con nho", "tre em"),
    "friends": ("nhom ban", "ban be", "hoi ban", "friends", "dong nghiep", "team"),
    "solo": ("mot minh", "solo", "di bui", "phuot mot minh"),
}


def _extract_travel_type(text: str) -> Optional[str]:
    low = strip_accents(text)
    for ttype, kws in _TRAVEL_TYPE_KEYWORDS.items():
        if any(k in low for k in kws):
            return ttype
    return None


def _extract_prefs(text: str) -> set[str]:
    scores = score_text(text, weight=1.0)
    return set(scores.keys())


def collect_slots(history: list[dict], message: str) -> dict:
    """Gộp slot từ tất cả tin nhắn user trong session (tin mới ghi đè tin cũ)."""
    user_texts = [m.get("content", "") for m in history if m.get("role") == "user"]
    user_texts.append(message)

    slots: dict = {"preferences": set()}
    for t in user_texts:
        if not t:
            continue
        ent = extract_entities(t)
        if ent.get("location"):
            slots["destination"] = ent["location"]
        if ent.get("duration_days"):
            slots["days"] = ent["duration_days"]
        b = _extract_budget(t)
        if b:
            slots["budget"] = b
        tv = _extract_travelers(t)
        if tv:
            slots["travelers"] = tv
        tt = _extract_travel_type(t)
        if tt:
            slots["travel_type"] = tt
        slots["preferences"] |= _extract_prefs(t)
    slots["preferences"] = list(slots["preferences"])
    return slots


# ── Chuyển plan → itinerary payload cho mobile (ItineraryCard + save) ─────────

_SLOT_LABELS = {"morning": "Sáng", "lunch": "Trưa", "afternoon": "Chiều", "evening": "Tối"}


def _to_itinerary_payload(plan: dict) -> dict:
    days = []
    for d in plan.get("days", []):
        acts = []
        for it in d.get("items", []):
            slot = _SLOT_LABELS.get(it.get("time_slot"), "")
            title = it.get("title") or ""
            acts.append(f"{slot}: {title}" if slot else title)
        days.append({
            "day": d.get("day_number"),
            "title": f"Ngày {d.get('day_number')}",
            "activities": acts,
        })
    hotel = plan.get("hotel") or {}
    hotels = []
    if hotel:
        hotels.append({
            "name": hotel.get("name"),
            "stars": hotel.get("stars"),
            "price": hotel.get("price_per_night"),
        })
    return {
        "destination": plan.get("destination_name"),
        "destination_id": plan.get("destination_id"),
        "duration": f"{plan.get('days_count')} ngày",
        "duration_days": plan.get("days_count"),
        "group": plan.get("travel_type"),
        "budget_low": None,
        "budget_high": plan.get("estimated_cost"),
        "days": days,
        "hotels": hotels,
        # Payload đầy đủ để lưu qua /trips/ai/confirm (mobile ưu tiên khi có).
        "ai_plan": {
            "title": plan.get("title"),
            "destination_id": plan.get("destination_id"),
            "start_date": plan.get("start_date"),
            "end_date": plan.get("end_date"),
            "days_count": plan.get("days_count"),
            "travelers": plan.get("travelers"),
            "travel_type": plan.get("travel_type"),
            "budget": plan.get("budget"),
            "estimated_cost": plan.get("estimated_cost"),
            "summary": plan.get("summary"),
            "days": plan.get("days"),
        },
    }


def _fmt_vnd(v: Optional[int]) -> str:
    if not v:
        return ""
    return f"{int(v):,}".replace(",", ".") + "đ"


def _plan_reply_text(plan: dict) -> str:
    lines = [f"Mình đã lên **{plan['title']}** dựa trên dữ liệu thật trong hệ thống 🎉\n"]
    if plan.get("hotel"):
        h = plan["hotel"]
        lines.append(f"🏨 Khách sạn gợi ý: **{h['name']}**"
                     + (f" · {_fmt_vnd(h.get('price_per_night'))}/đêm" if h.get('price_per_night') else ""))
    for d in plan.get("days", []):
        titles = " → ".join(it["title"] for it in d["items"][:4])
        lines.append(f"**Ngày {d['day_number']}:** {titles}")
    if plan.get("estimated_cost"):
        lines.append(f"\n💰 Chi phí ước tính: **{_fmt_vnd(plan['estimated_cost'])}** "
                     f"cho {plan.get('travelers', 1)} người.")
    if plan.get("budget_warning"):
        lines.append(f"\n⚠️ {plan['budget_warning']}")
    lines.append("\nBạn xem thử nhé — hợp ý thì bấm **Lưu Chuyến Đi**, không lưu cũng "
                 "được vì lịch trình vẫn nằm trong lịch sử chat này.")
    return "\n".join(lines)


# ── Entry point ──────────────────────────────────────────────────────────────

async def handle_planning_turn(
    db: AsyncSession,
    user_id: Optional[str],
    history: list[dict],
    message: str,
) -> Optional[dict]:
    """
    Trả None nếu lượt này KHÔNG thuộc luồng lên lịch (để RAG xử lý bình thường).
    Ngược lại trả dict:
      {"reply": str, "status": "asking"|"planned", "itinerary": dict|None}
    """
    if not is_planning_turn(history, message):
        return None

    slots = collect_slots(history, message)

    # Bước 1: thiếu điểm đến
    if not slots.get("destination"):
        return {
            "status": "asking",
            "itinerary": None,
            "reply": f"{PLANNER_MARKER} Tuyệt vời, mình giúp bạn lên lịch trình nhé! "
                     "Bạn muốn đi đâu? (ví dụ: Đà Lạt, Phú Quốc, Sa Pa...)",
        }

    # Bước 2: thiếu số ngày
    if not slots.get("days"):
        return {
            "status": "asking",
            "itinerary": None,
            "reply": f"{PLANNER_MARKER} Bạn định đi **{slots['destination']}** trong mấy ngày?",
        }

    # Bước 3: hỏi tuỳ chọn 1 lần (nếu chưa có thông tin nào & chưa hỏi)
    low_msg = strip_accents(message)
    user_skipped = any(w in low_msg for w in (strip_accents(s) for s in _SKIP_WORDS))
    has_optional = any(slots.get(k) for k in ("travelers", "travel_type")) or slots.get("preferences")
    if not has_optional and not user_skipped and not _asked_optional(history):
        return {
            "status": "asking",
            "itinerary": None,
            "reply": f"{PLANNER_MARKER} Gần xong rồi! Đi **mấy người** và bạn thích kiểu gì "
                     "(biển, núi, chill/healing, ẩm thực, văn hoá...)? Ngân sách dự kiến bao "
                     "nhiêu? Bạn có thể trả lời hoặc gõ *bỏ qua* để mình lên luôn nhé.",
        }

    # Đủ dữ liệu → dựng plan (dùng profile khi user không nêu sở thích)
    profile_tags: list[str] = []
    if user_id and not slots.get("preferences"):
        try:
            from app.services.user_preference_service import get_profile
            profile = await get_profile(db, user_id)
            profile_tags = [p["tag"] for p in profile]
        except Exception as e:
            logger.warning(f"[handle_planning_turn] Bỏ profile do lỗi: {e}")

    result = await trip_planner_service.build_plan(db, slots, profile_tags)
    if result["status"] != "draft":
        # build_plan không resolve được điểm đến → hỏi lại
        q = (result.get("questions") or ["Bạn thử nhập tên điểm đến khác nhé?"])[0]
        return {"status": "asking", "itinerary": None, "reply": f"{PLANNER_MARKER} {q}"}

    plan = result["plan"]
    return {
        "status": "planned",
        "itinerary": _to_itinerary_payload(plan),
        "reply": _plan_reply_text(plan),
    }
