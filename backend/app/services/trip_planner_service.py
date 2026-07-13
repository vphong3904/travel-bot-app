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
import math
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
    travelers: int = slots.get("travelers") or 1
    budget: Optional[int] = slots.get("budget")
    travel_type: str = slots.get("travel_type") or "solo"
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
