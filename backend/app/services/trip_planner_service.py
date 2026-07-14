"""
AI Trip Planner Service — TP-001/TP-002 (.agent/trip-ai).

Nguyên tắc (TRIP_AI_RULES):
  TR-01: chỉ chọn khách sạn / quán ăn / địa điểm là bản ghi THẬT trong DB;
         Gemini chỉ viết summary, không sinh entity. Thiếu dữ liệu → slot
         "free" + ghi chú, không bịa.
  TR-02: Gemini optional — lỗi/không có API key vẫn trả plan (summary=None).
  TR-03: thiếu slot bắt buộc → status="need_info", không tự đoán.

Flow: detect_missing_slots → resolve_destination → build_plan → generate_summary.
"""
from __future__ import annotations

import asyncio
import json
import math
import re
from datetime import date, timedelta
from typing import Any, Optional

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.user_preference_service import keywords_for_tags, strip_accents
from app.utils import get_logger

logger = get_logger("trip_planner")

MAX_DAYS = 14
# Ước lượng chi phí ăn uống khi DB không có giá cụ thể (VND/người/bữa)
MEAL_COST_ESTIMATE = 150_000
# Ngân sách khách sạn tối đa ≈ 35% tổng ngân sách chia theo đêm
HOTEL_BUDGET_RATIO = 0.35

# Bug đã sửa: trước đây dùng "friends" — bảng trip_plans có CHECK constraint
# `travel_type IN ('solo','couple','family','group')`, KHÔNG có "friends".
# Mọi lần /trips/ai/confirm với nhóm bạn đều crash IntegrityError (browser
# thấy "Failed to fetch" vì response 500 không hoàn tất). Đổi sang "group"
# cho khớp DB (và khớp quy ước đã dùng ở admin web), chỉ đổi KEY nội bộ —
# nhãn hiển thị "nhóm bạn" giữ nguyên.
TRAVEL_TYPES = {"solo", "couple", "family", "group"}
_TRAVEL_TYPE_LABEL = {
    "solo": "một mình",
    "couple": "cặp đôi",
    "family": "gia đình",
    "group": "nhóm bạn",
}

# Quy mô nhóm chuẩn hoá theo travel_type thay vì nhân chi phí tự do theo đầu
# người user gõ: solo luôn 1, couple luôn 2, family/group luôn trong khoảng
# 3-7 (mặc định 4 khi không rõ, ép về 7 nếu user báo số đông hơn). Tránh việc
# user gõ "nhóm 20 người" khiến khách sạn/vé/ăn uống nhân vọt lên vô lý —
# áp dụng NGAY TRONG build_plan() nên có hiệu lực cho cả chat lẫn màn hình
# chọn kế hoạch (cả hai đều dùng chung engine này).
_FIXED_GROUP_SIZE = {"solo": 1, "couple": 2}
GROUP_MIN_TRAVELERS = 3
GROUP_MAX_TRAVELERS = 7
GROUP_DEFAULT_TRAVELERS = 4


def normalize_group_size(travel_type: str, travelers: Optional[int]) -> tuple[str, int]:
    """Trả về (travel_type hợp lệ, số người dùng để tính chi phí)."""
    if travel_type in _FIXED_GROUP_SIZE:
        return travel_type, _FIXED_GROUP_SIZE[travel_type]
    if travel_type in ("family", "group"):
        size = travelers or GROUP_DEFAULT_TRAVELERS
        return travel_type, max(GROUP_MIN_TRAVELERS, min(size, GROUP_MAX_TRAVELERS))
    # travel_type chưa rõ (hoặc không hợp lệ) — suy luận ngược từ số người
    if travelers == 1:
        return "solo", 1
    if travelers == 2:
        return "couple", 2
    if travelers and travelers >= 3:
        return "group", max(GROUP_MIN_TRAVELERS, min(travelers, GROUP_MAX_TRAVELERS))
    return "solo", 1

SLOT_QUESTIONS = {
    "destination": "Bạn muốn đi đâu? (ví dụ: Đà Lạt, Phú Quốc, Sa Pa...)",
    "days": "Bạn định đi mấy ngày? (hoặc cho mình ngày đi và ngày về)",
    "budget": "Ngân sách dự kiến cho cả chuyến là bao nhiêu? (có thể bỏ qua)",
    "travelers": "Chuyến đi có mấy người?",
    "travel_type": "Bạn đi một mình, cặp đôi, gia đình hay nhóm bạn?",
    "preferences": "Bạn thích kiểu du lịch nào? (biển, núi, healing, ẩm thực, văn hoá...)",
}

# Location.type gợi ý là chỗ ăn uống (đã bỏ dấu) — còn lại coi là điểm tham quan
_FOOD_LOCATION_TYPES = ("restaurant", "food", "cafe", "quan", "am thuc", "an uong")
# Từ khoá nhận diện điểm hợp buổi tối
_EVENING_HINTS = ("cho dem", "dem ", "night", "pho di bo", "bar", "pub", "ngam den")


# ══════════════════════════════════════════════════════════════════════════════
# SLOT FILLING (TR-03)
# ══════════════════════════════════════════════════════════════════════════════

def _extract_days(slots: dict) -> Optional[int]:
    days = slots.get("days")
    if isinstance(days, int) and days >= 1:
        return min(days, MAX_DAYS)
    start, end = slots.get("start_date"), slots.get("end_date")
    if start and end and isinstance(start, date) and isinstance(end, date) and end >= start:
        return min((end - start).days + 1, MAX_DAYS)
    return None


def detect_missing_slots(slots: dict, skip_optional: bool = False) -> tuple[list[str], dict]:
    """
    Trả về (missing_fields, slots_đã_chuẩn_hoá).
    - Bắt buộc: destination, days (hoặc start_date+end_date).
    - Phụ: budget/travelers/travel_type/preferences — hỏi 1 lượt; nếu
      skip_optional=True thì điền default (travelers=1, travel_type=solo).
    """
    normalized = dict(slots)
    missing: list[str] = []

    if not (slots.get("destination") or "").strip():
        missing.append("destination")

    days = _extract_days(slots)
    if days is None:
        missing.append("days")
    else:
        normalized["days"] = days

    optional_missing = []
    if slots.get("budget") is None:
        optional_missing.append("budget")
    if not slots.get("travelers"):
        optional_missing.append("travelers")
    if not (slots.get("travel_type") or "").strip():
        optional_missing.append("travel_type")
    if not slots.get("preferences"):
        optional_missing.append("preferences")

    if skip_optional:
        normalized.setdefault("budget", slots.get("budget"))
        if not normalized.get("travelers"):
            normalized["travelers"] = 1
        if not (normalized.get("travel_type") or "").strip():
            normalized["travel_type"] = "solo"
        normalized.setdefault("preferences", slots.get("preferences") or [])
    else:
        missing.extend(optional_missing)

    if normalized.get("travel_type") and normalized["travel_type"] not in TRAVEL_TYPES:
        normalized["travel_type"] = "solo"
    if normalized.get("travelers"):
        normalized["travelers"] = max(1, min(int(normalized["travelers"]), 50))

    return missing, normalized


def questions_for(missing: list[str]) -> list[str]:
    return [SLOT_QUESTIONS[f] for f in missing if f in SLOT_QUESTIONS]


# ══════════════════════════════════════════════════════════════════════════════
# DB LOOKUPS (TR-01 — entity thật)
# ══════════════════════════════════════════════════════════════════════════════

async def resolve_destination(db: AsyncSession, name: str) -> Optional[dict]:
    """Fuzzy match destinations theo name/slug/province, ưu tiên khớp chính xác."""
    q = (name or "").strip()
    if not q:
        return None
    row = (
        await db.execute(
            text(
                """
                SELECT id::text AS id, name, slug, province, region, description,
                       special, budget_low, budget_high, image_url
                FROM destinations
                WHERE is_active IS NOT FALSE AND (
                      unaccent(lower(name)) = unaccent(lower(:q))
                   OR slug = lower(replace(:q, ' ', '-'))
                   OR unaccent(name) ILIKE unaccent(:like)
                   OR unaccent(COALESCE(province,'')) ILIKE unaccent(:like)
                )
                ORDER BY (unaccent(lower(name)) = unaccent(lower(:q))) DESC,
                         review_count DESC NULLS LAST, rating_avg DESC NULLS LAST
                LIMIT 1
                """
            ),
            {"q": q, "like": f"%{q}%"},
        )
    ).mappings().first()
    return dict(row) if row else None


async def pick_suggested_destination(
    db: AsyncSession, profile_tags: Optional[list[str]] = None
) -> Optional[dict]:
    """Chọn 1 điểm đến để GỢI Ý khi user muốn đi "ngẫu nhiên / đâu cũng được".

    Lấy 30 điểm đến active ngẫu nhiên; nếu có profile_tags (sở thích user) thì
    ưu tiên điểm khớp keyword sở thích nhất, còn lại random. Trả về cùng shape
    với resolve_destination để build_plan dùng thẳng."""
    import random as _random

    rows = (
        await db.execute(
            text(
                """
                SELECT id::text AS id, name, slug, province, region, description,
                       special, budget_low, budget_high, image_url
                FROM destinations
                WHERE is_active IS NOT FALSE
                ORDER BY random()
                LIMIT 30
                """
            )
        )
    ).mappings().all()
    if not rows:
        return None
    dests = [dict(r) for r in rows]

    kws = keywords_for_tags(profile_tags or [])
    if kws:
        kws_na = [strip_accents(k.lower()) for k in kws]

        def _score(d: dict) -> int:
            hay = strip_accents(
                " ".join(
                    str(d.get(k) or "")
                    for k in ("name", "description", "special", "province")
                ).lower()
            )
            return sum(1 for k in kws_na if k in hay)

        dests.sort(key=_score, reverse=True)
        if _score(dests[0]) > 0:
            return dests[0]

    return _random.choice(dests)


async def _fetch_hotels(db: AsyncSession, destination_id: str, limit: int = 12) -> list[dict]:
    rows = (
        await db.execute(
            text(
                """
                SELECT id::text AS id, name, type, stars, price_per_night,
                       address, description, image_url, rating
                FROM hotels
                WHERE destination_id = :d
                ORDER BY rating DESC NULLS LAST, stars DESC NULLS LAST
                LIMIT :lim
                """
            ),
            {"d": destination_id, "lim": limit},
        )
    ).mappings().all()
    return [dict(r) for r in rows]


async def _fetch_restaurants(db: AsyncSession, destination_id: str, limit: int = 20) -> list[dict]:
    rows = (
        await db.execute(
            text(
                """
                SELECT id::text AS id, name, type, address, price_range,
                       rating, image_url,
                       COALESCE(array_to_string(specialties, ', '), '') AS specialties
                FROM restaurants
                WHERE destination_id = :d
                ORDER BY rating DESC NULLS LAST
                LIMIT :lim
                """
            ),
            {"d": destination_id, "lim": limit},
        )
    ).mappings().all()
    return [dict(r) for r in rows]


async def _fetch_locations(db: AsyncSession, destination_id: str, limit: int = 40) -> list[dict]:
    rows = (
        await db.execute(
            text(
                """
                SELECT l.id::text AS id, l.name, l.type, l.address, l.hours,
                       l.description, l.tips, l.image_url, l.rating_avg,
                       t.price_adult
                FROM locations l
                LEFT JOIN LATERAL (
                    SELECT price_adult FROM tickets
                    WHERE tickets.location_id = l.id
                    ORDER BY price_adult ASC NULLS LAST LIMIT 1
                ) t ON TRUE
                WHERE l.destination_id = :d
                ORDER BY l.rating_avg DESC NULLS LAST, l.review_count DESC NULLS LAST
                LIMIT :lim
                """
            ),
            {"d": destination_id, "lim": limit},
        )
    ).mappings().all()
    return [dict(r) for r in rows]


# ══════════════════════════════════════════════════════════════════════════════
# CHỌN & SẮP LỊCH
# ══════════════════════════════════════════════════════════════════════════════

def _pref_bonus(item: dict, pref_keywords: list[str]) -> float:
    """Điểm cộng khi mô tả/tips/tên item khớp sở thích user."""
    if not pref_keywords:
        return 0.0
    blob = strip_accents(
        " ".join(
            str(item.get(k) or "")
            for k in ("name", "description", "tips", "special", "specialties", "type")
        )
    )
    return sum(0.5 for kw in pref_keywords if kw.strip() and kw.strip() in blob)


def _rank(items: list[dict], pref_keywords: list[str], rating_key: str = "rating") -> list[dict]:
    def key(it: dict) -> float:
        rating = it.get(rating_key) or it.get("rating_avg") or 0
        return float(rating) + _pref_bonus(it, pref_keywords)

    return sorted(items, key=key, reverse=True)


def _is_food_location(loc: dict) -> bool:
    t = strip_accents(loc.get("type") or "")
    return any(h in t for h in _FOOD_LOCATION_TYPES)


def _is_evening_spot(loc: dict) -> bool:
    blob = strip_accents((loc.get("name") or "") + " " + (loc.get("type") or ""))
    return any(h in blob for h in _EVENING_HINTS)


def _location_item(loc: dict, time_slot: str, start: str, end: str, order: int) -> dict:
    return {
        "time_slot": time_slot,
        "start_time": start,
        "end_time": end,
        "order_in_day": order,
        "type": "location",
        "ref_id": loc["id"],
        "title": loc["name"],
        "description": (loc.get("description") or "")[:400] or None,
        "estimated_cost": int(loc["price_adult"]) if loc.get("price_adult") else None,
        "notes": (loc.get("tips") or "")[:300] or None,
        "image_url": loc.get("image_url"),
        "address": loc.get("address"),
    }


def _restaurant_item(r: dict, time_slot: str, start: str, end: str, order: int) -> dict:
    desc = None
    if r.get("specialties"):
        desc = f"Đặc sản: {r['specialties']}"[:300]
    return {
        "time_slot": time_slot,
        "start_time": start,
        "end_time": end,
        "order_in_day": order,
        "type": "restaurant",
        "ref_id": r["id"],
        "title": f"Ăn tại {r['name']}",
        "description": desc,
        "estimated_cost": None,  # price_range là text — chi phí ăn tính chung ở tổng
        "notes": r.get("price_range"),
        "image_url": r.get("image_url"),
        "address": r.get("address"),
    }


def _free_item(time_slot: str, start: str, end: str, order: int, title: str, notes: str) -> dict:
    # TR-01: DB không có dữ liệu cho slot → item "free" ghi chú rõ, không bịa entity
    return {
        "time_slot": time_slot,
        "start_time": start,
        "end_time": end,
        "order_in_day": order,
        "type": "free",
        "ref_id": None,
        "title": title,
        "description": None,
        "estimated_cost": None,
        "notes": notes,
        "image_url": None,
        "address": None,
    }


def schedule_days(
    days_count: int,
    sights: list[dict],
    eateries: list[dict],
    hotel: Optional[dict],
) -> list[dict]:
    """
    Sắp lịch thuần rule-based (test được không cần DB):
    mỗi ngày morning(location) → lunch(ăn) → afternoon(location) → evening;
    ngày 1 chèn nhận phòng; không lặp lại item giữa các ngày.
    """
    sight_idx = 0
    eat_idx = 0
    evening_spots = [s for s in sights if _is_evening_spot(s)]
    used_ids: set[str] = set()

    def next_sight() -> Optional[dict]:
        nonlocal sight_idx
        while sight_idx < len(sights):
            s = sights[sight_idx]
            sight_idx += 1
            if s["id"] not in used_ids:
                used_ids.add(s["id"])
                return s
        return None

    def next_eatery() -> Optional[dict]:
        nonlocal eat_idx
        if not eateries:
            return None
        # quán ăn cho phép xoay vòng khi ít quán hơn số bữa
        r = eateries[eat_idx % len(eateries)]
        eat_idx += 1
        return r

    days: list[dict] = []
    for day_no in range(1, days_count + 1):
        items: list[dict] = []
        order = 0

        if day_no == 1 and hotel:
            items.append(
                {
                    "time_slot": "morning",
                    "start_time": "07:30",
                    "end_time": "08:30",
                    "order_in_day": order,
                    "type": "hotel_checkin",
                    "ref_id": hotel["id"],
                    "title": f"Nhận phòng {hotel['name']}",
                    "description": (hotel.get("description") or "")[:300] or None,
                    "estimated_cost": None,
                    "notes": hotel.get("address"),
                    "image_url": hotel.get("image_url"),
                    "address": hotel.get("address"),
                }
            )
            order += 1

        s1 = next_sight()
        if s1:
            items.append(_location_item(s1, "morning", "08:30", "11:30", order))
        else:
            items.append(_free_item(
                "morning", "08:30", "11:30", order,
                "Tự do khám phá",
                "Chưa có dữ liệu điểm tham quan trong hệ thống cho buổi này.",
            ))
        order += 1

        r1 = next_eatery()
        if r1:
            items.append(_restaurant_item(r1, "lunch", "11:45", "13:00", order))
        else:
            items.append(_free_item(
                "lunch", "11:45", "13:00", order,
                "Ăn trưa tự do",
                "Chưa có dữ liệu quán ăn trong hệ thống — bạn có thể hỏi PDTrip AI gợi ý món đặc sản.",
            ))
        order += 1

        s2 = next_sight()
        if s2:
            items.append(_location_item(s2, "afternoon", "14:00", "17:00", order))
        else:
            items.append(_free_item(
                "afternoon", "14:00", "17:00", order,
                "Nghỉ ngơi / tự do",
                "Thư giãn tại khách sạn hoặc dạo quanh khu trung tâm.",
            ))
        order += 1

        # Buổi tối: ưu tiên điểm về đêm (chợ đêm/phố đi bộ) chưa dùng, xen kẽ ăn tối
        ev = next(
            (s for s in evening_spots if s["id"] not in used_ids), None
        )
        r2 = next_eatery()
        if r2:
            items.append(_restaurant_item(r2, "evening", "18:00", "19:30", order))
            order += 1
        if ev:
            used_ids.add(ev["id"])
            items.append(_location_item(ev, "evening", "19:45", "21:30", order))
        elif not r2:
            items.append(_free_item(
                "evening", "18:00", "21:00", order,
                "Buổi tối tự do",
                "Dạo phố, thưởng thức ẩm thực đêm địa phương.",
            ))

        days.append({"day_number": day_no, "items": items})
    return days


def estimate_total_cost(
    days_count: int,
    travelers: int,
    hotel: Optional[dict],
    days: list[dict],
) -> int:
    nights = max(days_count - 1, 1)
    rooms = max(1, math.ceil(travelers / 2))
    total = 0
    if hotel and hotel.get("price_per_night"):
        total += int(hotel["price_per_night"]) * nights * rooms
    # vé tham quan có giá trong DB
    ticket_cost = sum(
        (it.get("estimated_cost") or 0)
        for d in days
        for it in d["items"]
        if it["type"] == "location"
    )
    total += ticket_cost * travelers
    # ăn uống ước lượng 2 bữa chính/ngày
    total += MEAL_COST_ESTIMATE * 2 * days_count * travelers
    return total


# ══════════════════════════════════════════════════════════════════════════════
# AI SCHEDULE SELECTION (hybrid, optional) — Gemini chỉ được CHỌN id trong đúng
# danh sách ứng viên thật (TR-01 vẫn giữ nguyên); không bao giờ sinh nội dung.
# Bất kỳ bước nào lỗi/không hợp lệ → trả None, build_plan tự fallback về
# `schedule_days` rule-based (đã test, luôn ra 1 lịch hoàn chỉnh). LLM chỉ là
# lớp tối ưu thêm cho đa dạng/ngân sách, KHÔNG phải điểm lỗi duy nhất.
# ══════════════════════════════════════════════════════════════════════════════

AI_SCHEDULE_TIMEOUT = 15


def _sight_brief(items: list[dict]) -> list[dict]:
    return [
        {
            "id": it["id"],
            "name": it["name"],
            "rating": it.get("rating_avg") or 0,
            "ticket_price": it.get("price_adult") or 0,
            "evening_spot": _is_evening_spot(it),
        }
        for it in items
    ]


def _eatery_brief(items: list[dict]) -> list[dict]:
    return [
        {
            "id": it["id"],
            "name": it["name"],
            "rating": it.get("rating") or it.get("rating_avg") or 0,
            "price_range": it.get("price_range") or "",
        }
        for it in items
    ]


def _extract_json(text_: str) -> Optional[dict]:
    text_ = (text_ or "").strip()
    if text_.startswith("```"):
        text_ = re.sub(r"^```(?:json)?\s*|\s*```$", "", text_, flags=re.IGNORECASE).strip()
    try:
        return json.loads(text_)
    except Exception:
        m = re.search(r"\{.*\}", text_, re.DOTALL)
        if not m:
            return None
        try:
            return json.loads(m.group(0))
        except Exception:
            return None


def _ai_day_items(
    day_no: int,
    d: dict,
    sight_by_id: dict[str, dict],
    eatery_by_id: dict[str, dict],
    hotel: Optional[dict],
) -> list[dict]:
    items: list[dict] = []
    order = 0

    if day_no == 1 and hotel:
        items.append({
            "time_slot": "morning", "start_time": "07:30", "end_time": "08:30",
            "order_in_day": order, "type": "hotel_checkin", "ref_id": hotel["id"],
            "title": f"Nhận phòng {hotel['name']}",
            "description": (hotel.get("description") or "")[:300] or None,
            "estimated_cost": None, "notes": hotel.get("address"),
            "image_url": hotel.get("image_url"), "address": hotel.get("address"),
        })
        order += 1

    morning = sight_by_id.get(d.get("morning"))
    if morning:
        items.append(_location_item(morning, "morning", "08:30", "11:30", order))
    else:
        items.append(_free_item("morning", "08:30", "11:30", order, "Tự do khám phá",
                                 "Chưa có dữ liệu điểm tham quan phù hợp cho buổi này."))
    order += 1

    lunch = eatery_by_id.get(d.get("lunch"))
    if lunch:
        items.append(_restaurant_item(lunch, "lunch", "11:45", "13:00", order))
    else:
        items.append(_free_item("lunch", "11:45", "13:00", order, "Ăn trưa tự do",
                                 "Chưa có dữ liệu quán ăn trong hệ thống."))
    order += 1

    afternoon = sight_by_id.get(d.get("afternoon"))
    if afternoon:
        items.append(_location_item(afternoon, "afternoon", "14:00", "17:00", order))
    else:
        items.append(_free_item("afternoon", "14:00", "17:00", order, "Nghỉ ngơi / tự do",
                                 "Thư giãn tại khách sạn hoặc dạo quanh khu trung tâm."))
    order += 1

    evening_eat = eatery_by_id.get(d.get("evening_eat"))
    if evening_eat:
        items.append(_restaurant_item(evening_eat, "evening", "18:00", "19:30", order))
        order += 1
    evening_sight = sight_by_id.get(d.get("evening_sight"))
    if evening_sight:
        items.append(_location_item(evening_sight, "evening", "19:45", "21:30", order))
    elif not evening_eat:
        items.append(_free_item("evening", "18:00", "21:00", order, "Buổi tối tự do",
                                 "Dạo phố, thưởng thức ẩm thực đêm địa phương."))

    return items


def _validate_ai_schedule(
    days: list[dict], days_count: int, sights: list[dict], eateries: list[dict]
) -> bool:
    if len(days) != days_count:
        return False
    for expected, d in zip(range(1, days_count + 1), days):
        if d["day_number"] != expected:
            return False
    loc_ids = [it["ref_id"] for d in days for it in d["items"] if it["type"] == "location" and it["ref_id"]]
    if len(sights) >= len(loc_ids) and len(loc_ids) != len(set(loc_ids)):
        return False  # đủ sight để không lặp mà vẫn lặp -> coi như không đạt
    eat_ids = [it["ref_id"] for d in days for it in d["items"] if it["type"] == "restaurant" and it["ref_id"]]
    if len(eateries) >= len(eat_ids) and len(eat_ids) != len(set(eat_ids)):
        return False
    return True


async def ai_select_schedule(
    days_count: int,
    sights: list[dict],
    eateries: list[dict],
    hotel: Optional[dict],
    travelers: int,
    budget: Optional[int],
    preferences: list[str],
    destination_name: str,
) -> Optional[list[dict]]:
    """Nhờ Gemini chọn & sắp thứ tự sight/eatery cho từng ngày, CHỈ trong đúng
    id ứng viên thật đã fetch từ DB. Trả None nếu Gemini lỗi/timeout/trả JSON
    hỏng/tự bịa id không có thật/không đạt yêu cầu đa dạng — build_plan sẽ
    fallback về `schedule_days` rule-based, không bao giờ chặn user."""
    if not sights and not eateries:
        return None
    try:
        from google.genai import types as genai_types

        from app.core.config import settings
        from app.services.rag_pipeline import _get_genai_client

        sight_by_id = {s["id"]: s for s in sights}
        eatery_by_id = {e["id"]: e for e in eateries}

        prompt = (
            "Bạn là hệ thống sắp lịch trình du lịch. CHỈ được chọn id có trong danh sách "
            "cho sẵn bên dưới, TUYỆT ĐỐI không bịa id/tên mới. Mỗi ngày cần: 1 sight buổi "
            "sáng, 1 eatery buổi trưa, 1 sight buổi chiều, 1 eatery buổi tối (thêm 1 sight "
            "evening_spot=true buổi tối nếu hợp lý, để null nếu không có). Ưu tiên: (1) KHÔNG "
            "lặp lại cùng 1 id trong toàn bộ chuyến trừ khi danh sách không đủ cho số ngày, "
            "(2) đa dạng thể loại giữa các ngày, (3) nếu ngân sách hạn chế thì ưu tiên "
            "sight/eatery có giá thấp hơn.\n\n"
            f"Điểm đến: {destination_name}. Số ngày: {days_count}. Số người: {travelers}. "
            f"Ngân sách cả chuyến: {budget or 'không giới hạn'}. "
            f"Sở thích: {', '.join(preferences) or 'không rõ'}.\n\n"
            f"Danh sách sight: {json.dumps(_sight_brief(sights), ensure_ascii=False)}\n\n"
            f"Danh sách eatery: {json.dumps(_eatery_brief(eateries), ensure_ascii=False)}\n\n"
            "Trả về CHỈ JSON theo đúng format sau, không thêm chữ nào khác:\n"
            '{"days": [{"day": 1, "morning": "<sight_id>", "lunch": "<eatery_id>", '
            '"afternoon": "<sight_id>", "evening_eat": "<eatery_id>", '
            '"evening_sight": "<sight_id hoặc null>"}]}'
        )

        # Tắt "thinking" (Gemini 2.5 mặc định bật, ăn hết max_output_tokens
        # bằng suy luận nội bộ trước khi ra JSON → JSON bị cắt cụt giữa chừng
        # với lịch nhiều ngày). Xem app/services/gemini_optimizer.py::_thinking_off.
        gen_config_kwargs = dict(temperature=0.4, max_output_tokens=4000)
        try:
            gen_config_kwargs["thinking_config"] = genai_types.ThinkingConfig(thinking_budget=0)
        except Exception:
            pass

        client = _get_genai_client()
        response = await asyncio.wait_for(
            client.aio.models.generate_content(
                model=settings.GEMINI_MODEL,
                contents=prompt,
                config=genai_types.GenerateContentConfig(**gen_config_kwargs),
            ),
            timeout=AI_SCHEDULE_TIMEOUT,
        )
        data = _extract_json(response.text or "")
        if not data or not isinstance(data.get("days"), list) or len(data["days"]) != days_count:
            logger.warning(
                f"[ai_select_schedule] JSON không hợp lệ hoặc thiếu ngày "
                f"(raw={(response.text or '')[:300]!r})"
            )
            return None

        days: list[dict] = []
        for idx, d in enumerate(data["days"], start=1):
            if not isinstance(d, dict) or d.get("day") != idx:
                logger.warning(f"[ai_select_schedule] Ngày thứ {idx} sai cấu trúc: {d!r}")
                return None
            days.append({"day_number": idx, "items": _ai_day_items(idx, d, sight_by_id, eatery_by_id, hotel)})

        if not _validate_ai_schedule(days, days_count, sights, eateries):
            logger.warning("[ai_select_schedule] Không đạt validate (lặp id dù đủ candidate) — fallback rule-based")
            return None
        return days
    except Exception as e:
        logger.warning(f"[ai_select_schedule] Bỏ qua LLM schedule, fallback rule-based: {e}")
        return None


# ══════════════════════════════════════════════════════════════════════════════
# BUILD PLAN
# ══════════════════════════════════════════════════════════════════════════════

async def build_plan(db: AsyncSession, slots: dict, profile_tags: list[str]) -> dict:
    """slots đã qua detect_missing_slots (đủ bắt buộc). Trả plan draft (mục 2.1)."""
    dest = await resolve_destination(db, slots["destination"])
    if not dest:
        return {
            "status": "need_info",
            "missing_fields": ["destination"],
            "questions": [
                f"Mình chưa tìm thấy \"{slots['destination']}\" trong hệ thống. "
                "Bạn thử tên khác gần đó nhé? (ví dụ: Đà Lạt, Nha Trang, Phú Quốc...)"
            ],
            "collected": {k: v for k, v in slots.items() if k != "destination"},
        }

    days_count: int = slots["days"]
    budget: Optional[int] = slots.get("budget")
    travel_type, travelers = normalize_group_size(slots.get("travel_type") or "", slots.get("travelers"))
    preferences: list[str] = slots.get("preferences") or profile_tags or []
    pref_keywords = keywords_for_tags(preferences)

    hotels, restaurants, locations = await asyncio.gather(
        _fetch_hotels(db, dest["id"]),
        _fetch_restaurants(db, dest["id"]),
        _fetch_locations(db, dest["id"]),
    )

    # Hotel: lọc theo ngân sách nếu có (TR: ≤35% budget / đêm / phòng)
    nights = max(days_count - 1, 1)
    rooms = max(1, math.ceil(travelers / 2))
    ranked_hotels = _rank(hotels, pref_keywords, rating_key="rating")
    if budget:
        per_night_cap = int(budget * HOTEL_BUDGET_RATIO / nights / rooms)
        in_budget = [
            h for h in ranked_hotels
            if not h.get("price_per_night") or h["price_per_night"] <= per_night_cap
        ]
        if in_budget:
            ranked_hotels = in_budget
        elif hotels:  # không KS nào vừa ngân sách → lấy rẻ nhất, note cho user
            ranked_hotels = sorted(
                hotels, key=lambda h: h.get("price_per_night") or 10**12
            )
    hotel = ranked_hotels[0] if ranked_hotels else None
    alt_hotels = ranked_hotels[1:4]

    # Điểm tham quan vs chỗ ăn: locations tách nhóm + bảng restaurants
    food_locs = [l for l in locations if _is_food_location(l)]
    sights = _rank([l for l in locations if not _is_food_location(l)], pref_keywords, "rating_avg")
    eateries = _rank(restaurants, pref_keywords, "rating") + _rank(food_locs, pref_keywords, "rating_avg")

    days = await ai_select_schedule(
        days_count, sights, eateries, hotel, travelers, budget, preferences, dest["name"]
    )
    if days is None:
        days = schedule_days(days_count, sights, eateries, hotel)
    estimated = estimate_total_cost(days_count, travelers, hotel, days)

    start_date = slots.get("start_date")
    end_date = slots.get("end_date")
    if start_date and not end_date:
        end_date = start_date + timedelta(days=days_count - 1)

    used_ids = {it["ref_id"] for d in days for it in d["items"] if it["ref_id"]}
    plan = {
        "title": f"{dest['name']} {days_count} ngày"
                 + (f" {days_count - 1} đêm" if days_count > 1 else "")
                 + f" cho {_TRAVEL_TYPE_LABEL.get(travel_type, travel_type)}",
        "destination_id": dest["id"],
        "destination_name": dest["name"],
        "destination_image": dest.get("image_url"),
        "start_date": start_date.isoformat() if start_date else None,
        "end_date": end_date.isoformat() if end_date else None,
        "days_count": days_count,
        "travelers": travelers,
        "travel_type": travel_type,
        "preferences": preferences,
        "budget": budget,
        "estimated_cost": estimated,
        "summary": None,  # Gemini điền sau (TR-02)
        "hotel": hotel,
        "days": days,
        "alternatives": {
            "hotels": alt_hotels,
            "restaurants": [r for r in restaurants if r["id"] not in used_ids][:5],
            "locations": [s for s in sights if s["id"] not in used_ids][:5],
        },
    }
    if budget and estimated > budget:
        plan["budget_warning"] = (
            f"Chi phí ước tính ({estimated:,.0f}đ) đang vượt ngân sách "
            f"({budget:,.0f}đ) — bạn có thể đổi khách sạn rẻ hơn hoặc giảm số ngày."
        )
    return {"status": "draft", "plan": plan}


# ══════════════════════════════════════════════════════════════════════════════
# GEMINI SUMMARY (TR-02 — optional)
# ══════════════════════════════════════════════════════════════════════════════

async def generate_summary(plan: dict) -> Optional[str]:
    """Nhờ Gemini viết đoạn mở đầu ≤120 từ cho lịch trình. Lỗi → None."""
    try:
        from google.genai import types as genai_types

        from app.core.config import settings
        from app.services.rag_pipeline import _get_genai_client

        lines = [f"Lịch trình: {plan['title']}"]
        if plan.get("hotel"):
            lines.append(f"Khách sạn: {plan['hotel']['name']}")
        for d in plan["days"][:5]:
            titles = ", ".join(it["title"] for it in d["items"][:4])
            lines.append(f"Ngày {d['day_number']}: {titles}")
        prompt = (
            "Viết đoạn giới thiệu ngắn (tối đa 120 từ, tiếng Việt, giọng thân "
            "thiện) cho lịch trình du lịch sau. KHÔNG thêm địa danh/giá cả nào "
            "ngoài thông tin đã cho, không dùng markdown:\n\n" + "\n".join(lines)
        )
        client = _get_genai_client()
        response = await asyncio.wait_for(
            client.aio.models.generate_content(
                model=settings.GEMINI_MODEL,
                contents=prompt,
                config=genai_types.GenerateContentConfig(
                    temperature=0.5, max_output_tokens=300
                ),
            ),
            timeout=12,
        )
        summary = (response.text or "").strip()
        return summary or None
    except Exception as e:
        logger.warning(f"[generate_summary] Bỏ qua summary Gemini: {e}")
        return None


async def plan_trip(
    db: AsyncSession,
    user_id: str,
    payload: dict,
) -> dict[str, Any]:
    """Entry point cho POST /trips/ai/plan."""
    missing, slots = detect_missing_slots(payload, skip_optional=payload.get("skip_optional", False))
    if missing:
        return {
            "status": "need_info",
            "missing_fields": missing,
            "questions": questions_for(missing),
            "collected": {
                k: (v.isoformat() if isinstance(v, date) else v)
                for k, v in slots.items()
                if k not in missing and k != "skip_optional" and v is not None
            },
        }

    profile_tags: list[str] = []
    if not slots.get("preferences"):
        try:
            from app.services.user_preference_service import get_profile

            profile = await get_profile(db, user_id)
            profile_tags = [p["tag"] for p in profile]
        except Exception as e:
            logger.warning(f"[plan_trip] Không lấy được preference profile: {e}")

    result = await build_plan(db, slots, profile_tags)
    if result["status"] == "draft":
        result["plan"]["summary"] = await generate_summary(result["plan"])
    return result
