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
from datetime import date, datetime
from decimal import Decimal
from typing import Any, Optional

from sqlalchemy.ext.asyncio import AsyncSession

from app.services import trip_planner_service
from app.services.nlp_preprocessor import _keyword_in_text, extract_entities
from app.services.user_preference_service import PREFERENCE_TAXONOMY, score_text, strip_accents
from app.utils import get_logger

logger = get_logger("trip_chat_planner")

# Marker vô hình đầu câu hỏi slot-filling → nhận biết "đang lên lịch" ở lượt sau.
PLANNER_MARKER = "🧭"
# Marker đầu câu trả lời khi ĐÃ dựng xong plan → cho phép lượt sau tiếp tục SỬA
# (đổi ngày/người/nơi/ngân sách) mà không cần gõ lại "lên lịch trình".
PLAN_DONE_MARKER = "🗺️"

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


# Từ/cụm để hỏi (đã bỏ dấu, khớp ranh giới từ) — dấu hiệu câu hiện tại là một
# CÂU HỎI THẬT (thông tin/tư vấn) chứ không phải trả lời ngắn gọn cho slot
# đang chờ. "gi" (gì), "sao", "dau" (đâu) rất đặc trưng cho câu hỏi tiếng Việt.
_QUESTION_HINTS = ("gi", "sao", "dau", "the nao", "bao nhieu", "khi nao", "co khong")


def _looks_like_new_question(message: str) -> bool:
    """
    Bug đã sửa: trước đây, một khi câu trợ lý gần nhất là câu hỏi slot-filling
    (bắt đầu bằng PLANNER_MARKER), MỌI tin nhắn sau đó của user đều bị coi là
    "đang lên lịch" — kể cả khi user chuyển sang hỏi chuyện hoàn toàn khác
    ("Đà Lạt có món gì ngon", "thời tiết Huế tháng 12"...). Vì mọi câu hỏi
    slot-filling đều bắt đầu bằng cùng 1 marker, planner tự khoá chat vào
    luồng lên lịch vĩnh viễn, RAG không bao giờ chạy lại được nữa.

    Heuristic thoát: câu trả lời slot thường NGẮN và không có dấu hỏi/từ để
    hỏi (vd "Đà Lạt", "3 ngày", "2 người", "bỏ qua"). Câu hỏi thật thường có
    "?" hoặc từ để hỏi ("gì", "sao", "đâu"...) VÀ đủ dài (>3 từ) — ngưỡng độ
    dài để không exit nhầm khi câu trả lời slot tình cờ có dấu hỏi tu từ
    ("Đà Lạt nhé?"). KHÔNG dùng riêng tín hiệu "có địa danh/số liệu" để giữ
    chân trong luồng lên lịch, vì địa danh/số liệu vẫn có thể xuất hiện TRONG
    một câu hỏi khác (vd "Đà Lạt có món gì ngon" chứa "Đà Lạt" nhưng rõ ràng
    đang hỏi ẩm thực, không phải trả lời "bạn muốn đi đâu").
    """
    low = strip_accents(message.lower())
    has_hint = "?" in message or any(_keyword_in_text(h, low) for h in _QUESTION_HINTS)
    if not has_hint:
        return False
    return len(message.split()) > 3


# Dấu hiệu câu SỬA plan sau khi đã dựng xong (đổi ngày/người/nơi/ngân sách).
# Cần vì sau khi trả plan, câu như "5 ngày đi", "qua đà lạt", "2 người thôi"
# KHÔNG có trigger "lên lịch trình" và cũng không phải câu hỏi — trước đây rơi
# xuống RAG nên plan không sửa được. Chỉ tiếp tục khi câu có TÍN HIỆU sửa để
# tránh "cảm ơn"/"ok đẹp đấy" vô tình dựng lại plan.
_EDIT_VERBS = ("doi", "thay", "tang", "giam", "them", "bot", "chuyen", "sua",
               "khac", "lai", "nua", "thanh")
_SLOT_UNIT_HINTS = ("ngay", "nguoi", "dem", "trieu", "nghin", "ngan sach",
                    "gia dinh", "cap doi", "nguoi yeu", "mot minh",
                    "nhom", "ban be", "solo", "couple")


# Dấu hiệu user muốn đi "ngẫu nhiên / đâu cũng được / bạn chọn giúp" → planner
# tự gợi ý 1 điểm đến (theo sở thích nếu có, else random) thay vì hỏi "đi đâu?".
_RANDOM_DEST_HINTS = (
    "ngau nhien", "bat ky", "bat cu", "dau cung duoc", "cho nao cung duoc",
    "noi nao cung duoc", "di dau cung duoc", "di dau cung", "tuy ban", "tuy ai",
    "ban chon", "chon giup", "chon ho", "goi y giup", "goi y dia diem",
    "goi y diem den", "goi y noi", "goi y cho", "random", "sao cung duoc",
    "gi cung duoc", "chua biet di dau", "chua biet di", "muon di dau do",
    "di dau do", "o dau cung duoc",
)


def _wants_random_destination(message: str) -> bool:
    low = strip_accents(message.lower())
    return any(h in low for h in _RANDOM_DEST_HINTS)


def _looks_like_edit(message: str) -> bool:
    low = strip_accents(message.lower())
    if any(_keyword_in_text(v, low) for v in _EDIT_VERBS):
        return True
    if any(h in low for h in _SLOT_UNIT_HINTS):
        return True
    # có địa danh mới ("qua đà lạt", "sang nha trang") cũng là yêu cầu đổi nơi
    if extract_entities(message).get("location"):
        return True
    return False


# Danh từ chỉ MỘT hạng mục trong lịch (khách sạn/quán/điểm) — dùng để nhận biết
# yêu cầu đổi riêng 1 mục (khác với đổi tham số chuyến: ngày/người/nơi/ngân sách).
_ITEM_SWAP_NOUNS = ("khach san", "hotel", "resort", "homestay", "quan an", "quan",
                    "nha hang", "cho an", "diem", "dia diem", "cho choi", "cho tham quan")


def _is_item_swap_request(message: str) -> bool:
    low = strip_accents(message.lower())
    has_swap = any(_keyword_in_text(v, low) for v in ("doi", "thay", "khac", "chuyen"))
    has_item = any(n in low for n in _ITEM_SWAP_NOUNS)
    if not (has_swap and has_item):
        return False
    # Nếu câu có kèm tham số chuyến (số ngày/người/đêm hoặc địa danh mới) thì
    # đó là đổi CHUYẾN chứ không phải đổi riêng 1 mục → để flow re-plan xử lý.
    import re as _re
    if _re.search(r"\d+\s*(ngay|nguoi|dem)", low):
        return False
    if extract_entities(message).get("location"):
        return False
    return True


def is_planning_turn(history: list[dict], message: str) -> bool:
    """Đang trong luồng lên lịch nếu: câu hiện tại kích hoạt, HOẶC câu trợ lý
    gần nhất là câu hỏi slot-filling (PLANNER_MARKER) và câu này không phải câu
    hỏi khác hẳn, HOẶC câu trợ lý gần nhất là PLAN ĐÃ XONG (PLAN_DONE_MARKER) và
    câu này là một yêu cầu SỬA (đổi ngày/người/nơi/ngân sách)."""
    if has_trigger(message):
        return True
    last = _last_assistant(history)
    if not last:
        return False
    lastl = last.lstrip()
    if lastl.startswith(PLANNER_MARKER):
        return not _looks_like_new_question(message)
    if lastl.startswith(PLAN_DONE_MARKER):
        # Sau khi plan xong: chỉ tiếp tục nếu là yêu cầu sửa rõ ràng, KHÔNG phải
        # câu hỏi mới (để "Đà Nẵng có gì ăn ngon?" vẫn ra RAG).
        return _looks_like_edit(message) and not _looks_like_new_question(message)
    return False


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


# Key "group" khớp CHECK constraint trip_plans.travel_type ở DB
# ('solo','couple','family','group') — trước đây dùng "friends" khiến
# /trips/ai/confirm crash IntegrityError khi user chọn đi nhóm bạn.
_TRAVEL_TYPE_KEYWORDS = {
    "couple": ("cap doi", "couple", "nguoi yeu", "vo chong", "honeymoon", "tuan trang mat"),
    "family": ("gia dinh", "family", "ca nha", "bo me", "con nho", "tre em"),
    "group": ("nhom ban", "ban be", "hoi ban", "friends", "dong nghiep", "team"),
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
    """Gộp slot từ các tin user THUỘC lượt lên lịch hiện tại (tin mới ghi đè cũ).

    Bug đã sửa: trước đây gom slot từ TOÀN BỘ tin user trong session → số liệu
    của câu hỏi KHÁC lẫn vào plan. Ví dụ thật: user hỏi "khách sạn hội an 1
    ngày 500k" (hỏi khách sạn), rồi sau đó "gợi ý lịch trình đi hội an" —
    "1 ngày" từ câu khách sạn rò rỉ thành days=1, khiến planner BỎ QUA bước hỏi
    số ngày và tự dựng lịch 1 ngày. Tương tự "4 người", "500k" ở câu vu vơ.

    Chỉ lấy từ câu trigger "lên lịch trình" GẦN NHẤT trở đi: một lượt lên lịch
    luôn bắt đầu bằng trigger; các tin trước đó là chuyện khác, không tính."""
    user_texts = [m.get("content", "") for m in history if m.get("role") == "user"]
    user_texts.append(message)

    start = 0
    for i in range(len(user_texts) - 1, -1, -1):
        if has_trigger(user_texts[i]):
            start = i
            break
    user_texts = user_texts[start:]

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

    # Khôi phục điểm đến khi user KHÔNG tự nêu (trường hợp planner đã tự gợi ý
    # ngẫu nhiên). Thiết kế stateless nên phải đọc lại từ các câu trợ lý trong
    # lượt lên lịch: chúng luôn nhắc tên điểm đến ("Bạn định đi **Đà Lạt**...",
    # tiêu đề plan...). BỎ QUA câu hỏi "đi đâu?" vì nó chứa danh sách ví dụ
    # (Đà Lạt, Phú Quốc...) sẽ bị nhận nhầm thành điểm đã chọn.
    if not slots.get("destination"):
        for m in reversed(history):
            if m.get("role") != "assistant":
                continue
            c = (m.get("content") or "").lstrip()
            if not (c.startswith(PLANNER_MARKER) or c.startswith(PLAN_DONE_MARKER)):
                continue
            if "đi đâu" in c.lower():
                continue
            loc = extract_entities(c).get("location")
            if loc:
                slots["destination"] = loc
                break
    return slots


# ── Chuyển plan → itinerary payload cho mobile (ItineraryCard + save) ─────────

_SLOT_LABELS = {"morning": "Sáng", "lunch": "Trưa", "afternoon": "Chiều", "evening": "Tối"}


def _json_safe(obj: Any) -> Any:
    """Chuyển payload về kiểu JSON thuần: Decimal→int/float, date/datetime→ISO
    string, đệ quy qua dict/list.

    Bắt buộc vì payload itinerary từ CHAT đi thẳng qua `json.dumps` thô ở 2 chỗ
    KHÔNG dùng FastAPI jsonable_encoder: (1) `format_sse` khi stream event,
    (2) lưu vào cột JSON `chat_sessions.last_itinerary`. Giá lấy từ DB là cột
    NUMERIC → `Decimal`, và `hotel`/`alternatives` (mới thêm để FE render chi
    tiết) mang theo Decimal `price_per_night`/`rating`/`price_adult` → nếu không
    ép kiểu, json.dumps raise TypeError giữa chừng stream → client thấy
    "network error" (endpoint /trips/ai/plan KHÔNG dính vì FastAPI tự encode)."""
    if isinstance(obj, bool):
        return obj
    if isinstance(obj, Decimal):
        as_int = int(obj)
        return as_int if as_int == obj else float(obj)
    if isinstance(obj, (date, datetime)):
        return obj.isoformat()
    if isinstance(obj, dict):
        return {k: _json_safe(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_json_safe(v) for v in obj]
    return obj


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
    return _json_safe({
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
        # Thêm destination_image/hotel/alternatives (trước đây thiếu) để FE
        # render được UI chi tiết (ảnh, đổi lựa chọn) giống hệt màn hình
        # AiPlannerScreen dù plan đến từ chat, không phải /trips/ai/plan.
        "ai_plan": {
            "title": plan.get("title"),
            "destination_id": plan.get("destination_id"),
            "destination_image": plan.get("destination_image"),
            "start_date": plan.get("start_date"),
            "end_date": plan.get("end_date"),
            "days_count": plan.get("days_count"),
            "travelers": plan.get("travelers"),
            "travel_type": plan.get("travel_type"),
            "budget": plan.get("budget"),
            "estimated_cost": plan.get("estimated_cost"),
            "budget_warning": plan.get("budget_warning"),
            "summary": plan.get("summary"),
            "hotel": plan.get("hotel"),
            "days": plan.get("days"),
            "alternatives": plan.get("alternatives"),
        },
    })


def _fmt_vnd(v: Optional[int]) -> str:
    if not v:
        return ""
    return f"{int(v):,}".replace(",", ".") + "đ"


def _plan_reply_text(plan: dict) -> str:
    """
    Bug đã sửa: các dòng trước đây nối bằng "\n" ĐƠN (`"\n".join(lines)`) —
    Markdown coi 1 newline đơn là soft-break, nhiều renderer (kể cả widget
    chat của app) GỘP LUÔN vào cùng 1 đoạn, nên "Ngày 1: ..." và "**Ngày 2:**
    ..." bị dính liền thành 1 dòng dài. Nối bằng "\n\n" (dòng trắng — đúng
    ngữ nghĩa "đoạn mới" của Markdown) để mỗi mục xuống dòng thật.
    """
    # PLAN_DONE_MARKER ở đầu → lượt sau nhận biết "plan đã xong" để cho phép SỬA
    # (đổi ngày/người/nơi/ngân sách) mà không cần gõ lại "lên lịch trình".
    lines = [f"{PLAN_DONE_MARKER} Mình đã lên **{plan['title']}** dựa trên dữ liệu "
             "thật trong hệ thống 🎉"]
    if plan.get("hotel"):
        h = plan["hotel"]
        lines.append(f"🏨 Khách sạn gợi ý: **{h['name']}**"
                     + (f" · {_fmt_vnd(h.get('price_per_night'))}/đêm" if h.get('price_per_night') else ""))
    for d in plan.get("days", []):
        titles = " → ".join(it["title"] for it in d["items"][:4])
        lines.append(f"**Ngày {d['day_number']}:** {titles}")
    if plan.get("estimated_cost"):
        lines.append(f"💰 Chi phí ước tính: **{_fmt_vnd(plan['estimated_cost'])}** "
                     f"cho {plan.get('travelers', 1)} người.")
    if plan.get("budget_warning"):
        lines.append(f"⚠️ {plan['budget_warning']}")
    lines.append("Bạn xem thử nhé — muốn **đổi số ngày, số người, nơi khác hay "
                 "ngân sách** cứ nhắn tiếp, hoặc bấm **Lưu Chuyến Đi**. Muốn đổi "
                 "riêng khách sạn/điểm nào thì bấm nút **Đổi** ngay tại mục đó nhé.")
    return "\n\n".join(lines)


# ── Entry point ──────────────────────────────────────────────────────────────

async def _profile_tags(db: AsyncSession, user_id: Optional[str]) -> list[str]:
    """Lấy tag sở thích của user từ profile (rỗng nếu chưa đăng nhập/ lỗi)."""
    if not user_id:
        return []
    try:
        from app.services.user_preference_service import get_profile
        profile = await get_profile(db, user_id)
        return [p["tag"] for p in profile]
    except Exception as e:
        logger.warning(f"[trip_chat_planner] Bỏ profile do lỗi: {e}")
        return []


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

    # Yêu cầu ĐỔI RIÊNG khách sạn/quán/điểm (không đổi ngày/người/nơi) → không
    # dựng lại plan (build_plan luôn chọn lại đúng khách sạn top → ra y hệt,
    # gây hiểu nhầm). Hướng user bấm nút "Đổi" ngay tại mục đó (TripPlanView có
    # sẵn danh sách thay thế), đổi tức thì không cần gọi lại AI.
    if _is_item_swap_request(message):
        return {
            "status": "asking",
            "itinerary": None,
            "reply": f"{PLAN_DONE_MARKER} Để đổi riêng **khách sạn** hoặc **một "
                     "điểm/quán** trong lịch, bạn bấm nút **Đổi** ngay cạnh mục đó "
                     "trong lịch trình bên trên nhé — mình sẽ thay bằng lựa chọn "
                     "khác trong khu vực ngay. Còn muốn đổi **số ngày, số người, "
                     "nơi đến hay ngân sách** thì cứ nhắn cho mình.",
        }

    slots = collect_slots(history, message)

    # Bước 1: thiếu điểm đến
    if not slots.get("destination"):
        # User muốn "ngẫu nhiên / đâu cũng được / bạn chọn giúp" → tự gợi ý 1
        # điểm đến (ưu tiên sở thích trong profile), thay vì hỏi lại "đi đâu?".
        if _wants_random_destination(message):
            profile_tags = await _profile_tags(db, user_id)
            picked = await trip_planner_service.pick_suggested_destination(
                db, profile_tags)
            if picked:
                slots["destination"] = picked["name"]
                reason = ("— khá hợp gu của bạn"
                          if profile_tags else "— một điểm đến rất đáng đi")
                if not slots.get("days"):
                    return {
                        "status": "asking",
                        "itinerary": None,
                        "reply": f"{PLANNER_MARKER} Mình gợi ý bạn tới "
                                 f"**{picked['name']}** {reason} 🎒 Bạn muốn đi "
                                 "mấy ngày?",
                    }
                # đủ điểm đến (vừa gợi ý) + đã có ngày → rơi xuống các bước sau
            else:
                return {
                    "status": "asking",
                    "itinerary": None,
                    "reply": f"{PLANNER_MARKER} Hiện mình chưa lấy được điểm đến "
                             "nào để gợi ý. Bạn cho mình 1 nơi cụ thể nhé? "
                             "(ví dụ: Đà Lạt, Phú Quốc, Sa Pa...)",
                }
        else:
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

    # Bước 3: hỏi 1 lần cho nhóm thông tin quyết định độ CHÍNH XÁC của lịch:
    # số người/đi với ai (quyết định chi phí) + ngân sách + sở thích.
    # Điều kiện bỏ qua CHỈ dựa trên "đã biết quy mô nhóm chưa" (travelers/
    # travel_type) — KHÔNG dựa vào preferences, vì score_text đôi khi tự bắt
    # nhầm 1 tag từ câu chung chung ("gợi ý lịch trình đi hội an" → 'thiên_nhiên')
    # khiến trước đây planner tưởng đủ optional rồi bỏ qua hỏi số người/ngân
    # sách → tự dựng lịch "1 người" thiếu chính xác.
    low_msg = strip_accents(message)
    user_skipped = any(w in low_msg for w in (strip_accents(s) for s in _SKIP_WORDS))
    has_group_info = bool(slots.get("travelers") or slots.get("travel_type"))
    if not has_group_info and not user_skipped and not _asked_optional(history):
        return {
            "status": "asking",
            "itinerary": None,
            "reply": f"{PLANNER_MARKER} Để mình lên lịch **{slots['destination']} "
                     f"{slots['days']} ngày** cho chính xác nhé — cho mình hỏi thêm:\n\n"
                     "• Bạn đi **một mình, với người yêu, hay cùng gia đình/bạn bè** "
                     "(khoảng mấy người)?\n"
                     "• **Ngân sách** dự kiến cả chuyến khoảng bao nhiêu?\n"
                     "• Bạn thích kiểu gì (biển, núi, chill/healing, ẩm thực, văn hoá...)?\n\n"
                     "Trả lời giúp mình, hoặc gõ *bỏ qua* để mình lên luôn theo mặc định nhé.",
        }

    # Đủ dữ liệu → dựng plan (dùng profile khi user không nêu sở thích)
    profile_tags: list[str] = []
    if user_id and not slots.get("preferences"):
        profile_tags = await _profile_tags(db, user_id)

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
