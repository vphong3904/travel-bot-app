"""
structured_search.py — [OPT-2.2] Lấy dữ liệu có cấu trúc (Postgres) làm nguồn
grounding cho chatbot.

Vấn đề: RAG cũ chỉ tìm trong `knowledge_entries` (faq/food/tip). Các bảng
hotels / tours / tickets / transport_options / shopping_places / locations /
destination_events / itineraries KHÔNG được chatbot đọc → hỏi "khách sạn Đà Lạt"
bị miss dù DB có 16 khách sạn.

Giải: theo INTENT, query đúng bảng theo destination rồi trả về list "source"
(cùng shape với RAG sources: title/text/category) để:
  - Gemini soạn câu trả lời tự nhiên + ĐỀ XUẤT theo sở thích, dựa trên DỮ LIỆU
    THẬT trong DB (không bịa).
  - No-context guard không kích hoạt nhầm khi DB thực sự có dữ liệu.

Destination được resolve theo ENTITY LOCATION ("Đà Lạt") trước — đáng tin hơn
city_slug (vốn đôi khi resolve sai sang tỉnh khác).
"""

from __future__ import annotations

from typing import Optional
from uuid import UUID

from sqlalchemy import text

from app.utils import get_logger

logger = get_logger("structured_search")

# Intent → có cần structured data không (và bảng nào). ask_food để KB lo (đã có
# category food trong knowledge_entries). greeting/out_of_scope/ask_faq bỏ qua.
_STRUCTURED_INTENTS = {
    "find_hotel", "find_tour", "ask_transport", "ask_shopping",
    "ask_activity", "ask_destination", "ask_budget", "plan_trip",
    "ask_food",
}

_MAX_ROWS = 12          # số dòng tối đa mỗi bảng đưa vào context
_MAX_CONTENT = 320      # cắt mô tả mỗi dòng cho gọn prompt


def _fmt_price(v: Optional[int]) -> str:
    if v is None:
        return ""
    try:
        return f"{int(v):,}đ".replace(",", ".")
    except (ValueError, TypeError):
        return str(v)


def _clip(s: Optional[str], n: int = _MAX_CONTENT) -> str:
    if not s:
        return ""
    s = " ".join(str(s).split())
    return s if len(s) <= n else s[: n - 1] + "…"


def _arr(v) -> str:
    if not v:
        return ""
    if isinstance(v, (list, tuple)):
        return ", ".join(str(x) for x in v if x)
    return str(v)


async def resolve_destination(
    db, location: Optional[str], city_slug: Optional[str]
) -> tuple[Optional[UUID], Optional[str]]:
    """
    Tìm destination (id, name). Ưu tiên LOCATION (tên hiển thị, đáng tin), rồi
    mới tới city_slug. Trả (None, None) nếu không khớp.
    """
    if location:
        row = (await db.execute(
            text("SELECT id, name FROM destinations WHERE name ILIKE :loc ORDER BY length(name) LIMIT 1"),
            {"loc": location.strip()},
        )).first()
        if row:
            return row[0], row[1]
        # thử khớp lỏng (substring)
        row = (await db.execute(
            text("SELECT id, name FROM destinations WHERE name ILIKE :loc ORDER BY length(name) LIMIT 1"),
            {"loc": f"%{location.strip()}%"},
        )).first()
        if row:
            return row[0], row[1]

    if city_slug:
        row = (await db.execute(
            text("SELECT id, name FROM destinations WHERE slug = :s LIMIT 1"),
            {"s": city_slug},
        )).first()
        if row:
            return row[0], row[1]

    return None, None


# ── Query + format từng bảng → list[source dict] ──────────────────────────────

async def _q(db, sql: str, did: UUID) -> list:
    return list((await db.execute(text(sql), {"did": str(did)})).mappings().all())


async def _hotels(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, stars, price_per_night, address, amenities, description, rating
        FROM hotels WHERE destination_id = :did
        ORDER BY rating DESC NULLS LAST, stars DESC NULLS LAST LIMIT 12
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["stars"]:           parts.append(f"{r['stars']}★")
        if r["price_per_night"]: parts.append(f"~{_fmt_price(r['price_per_night'])}/đêm")
        if r["rating"]:          parts.append(f"đánh giá {r['rating']}")
        head = " — ".join(parts)
        body = []
        if r["address"]:   body.append(f"Địa chỉ: {r['address']}")
        if r["amenities"]: body.append(f"Tiện nghi: {_arr(r['amenities'])}")
        if r["description"]: body.append(_clip(r["description"]))
        out.append({"title": f"Khách sạn {name}", "category": "hotel",
                    "text": head + (". " + " ".join(body) if body else ""),
                    "source": "db_structured", "score": 0.95})
    return out


async def _tours(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, duration, price, group_size, description, includes
        FROM tours WHERE destination_id = :did ORDER BY price ASC NULLS LAST LIMIT 12
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["duration"]:   parts.append(str(r["duration"]))
        if r["price"]:      parts.append(_fmt_price(r["price"]))
        if r["group_size"]: parts.append(f"nhóm {r['group_size']}")
        body = []
        if r["includes"]:    body.append(f"Bao gồm: {_arr(r['includes'])}")
        if r["description"]: body.append(_clip(r["description"]))
        out.append({"title": f"Tour {name}", "category": "tour",
                    "text": " — ".join(parts) + (". " + " ".join(body) if body else ""),
                    "source": "db_structured", "score": 0.95})
    return out


async def _transport(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT type, is_local, price_info, duration, provider, notes
        FROM transport_options WHERE destination_id = :did LIMIT 20
    """, did)
    out = []
    for r in rows:
        parts = [r["type"] or "Phương tiện"]
        if r["provider"]:   parts.append(str(r["provider"]))
        if r["price_info"]: parts.append(_clip(r["price_info"], 80))
        if r["duration"]:   parts.append(str(r["duration"]))
        body = _clip(r["notes"], 160)
        scope = "nội đô" if r["is_local"] else "liên tỉnh/đến nơi"
        out.append({"title": f"Di chuyển {name} ({scope})", "category": "transport",
                    "text": " — ".join(p for p in parts if p) + (". " + body if body else ""),
                    "source": "db_structured", "score": 0.95})
    return out


async def _shopping(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, type, items, address, opening_hours, price_range
        FROM shopping_places WHERE destination_id = :did LIMIT 12
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["type"]:        parts.append(str(r["type"]))
        if r["price_range"]: parts.append(str(r["price_range"]))
        body = []
        if r["items"]:         body.append(f"Mặt hàng: {_arr(r['items'])}")
        if r["address"]:       body.append(f"Địa chỉ: {r['address']}")
        if r["opening_hours"]: body.append(f"Giờ mở: {r['opening_hours']}")
        out.append({"title": f"Mua sắm {name}", "category": "shopping",
                    "text": " — ".join(parts) + (". " + " ".join(body) if body else ""),
                    "source": "db_structured", "score": 0.95})
    return out


async def _locations(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, type, address, hours, description, tips, rating_avg
        FROM locations WHERE destination_id = :did
        ORDER BY rating_avg DESC NULLS LAST LIMIT 14
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["type"]:       parts.append(str(r["type"]))
        if r["rating_avg"] and float(r["rating_avg"]) > 0: parts.append(f"đánh giá {r['rating_avg']}")
        body = []
        if r["description"]: body.append(_clip(r["description"]))
        if r["address"]:     body.append(f"Địa chỉ: {r['address']}")
        if r["hours"]:       body.append(f"Giờ: {r['hours']}")
        if r["tips"]:        body.append(f"Mẹo: {_clip(r['tips'], 120)}")
        out.append({"title": f"Điểm đến {name}", "category": "attraction",
                    "text": " — ".join(parts) + (". " + " ".join(body) if body else ""),
                    "source": "db_structured", "score": 0.95})
    return out


async def _events(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, event_date, location_text, cost, description
        FROM destination_events WHERE destination_id = :did LIMIT 8
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["event_date"]: parts.append(str(r["event_date"]))
        body = []
        if r["location_text"]: body.append(f"Tại: {r['location_text']}")
        if r["cost"]:          body.append(f"Chi phí: {r['cost']}")
        if r["description"]:   body.append(_clip(r["description"], 160))
        out.append({"title": f"Sự kiện {name}", "category": "event",
                    "text": " — ".join(parts) + (". " + " ".join(body) if body else ""),
                    "source": "db_structured", "score": 0.9})
    return out


async def _tickets(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, price_adult, price_child, hours, description
        FROM tickets WHERE destination_id = :did LIMIT 12
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["price_adult"] is not None: parts.append(f"người lớn {_fmt_price(r['price_adult'])}")
        if r["price_child"] is not None: parts.append(f"trẻ em {_fmt_price(r['price_child'])}")
        body = []
        if r["hours"]:       body.append(f"Giờ: {r['hours']}")
        if r["description"]: body.append(_clip(r["description"], 160))
        out.append({"title": f"Vé/giá {name}", "category": "ticket",
                    "text": " — ".join(parts) + (". " + " ".join(body) if body else ""),
                    "source": "db_structured", "score": 0.9})
    return out


async def _itineraries(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT id, title, duration_days, group_type, budget_low, budget_high, description
        FROM itineraries WHERE destination_id = :did AND is_active LIMIT 6
    """, did)
    out = []
    for r in rows:
        parts = [r["title"]]
        if r["duration_days"]: parts.append(f"{r['duration_days']} ngày")
        if r["group_type"]:    parts.append(str(r["group_type"]))
        if r["budget_low"] or r["budget_high"]:
            parts.append(f"ngân sách {_fmt_price(r['budget_low'])}–{_fmt_price(r['budget_high'])}")
        body = _clip(r["description"], 220)
        out.append({"title": f"Lịch trình {name}", "category": "itinerary",
                    "text": " — ".join(p for p in parts if p) + (". " + body if body else ""),
                    "source": "db_structured", "score": 0.92})
    return out


async def _foods(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, local_name, category, description, price_range, must_try, vegetarian, tags
        FROM foods WHERE destination_id = :did
        ORDER BY must_try DESC NULLS LAST LIMIT 14
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["local_name"] and r["local_name"] != r["name"]: parts.append(f"({r['local_name']})")
        if r["price_range"]: parts.append(str(r["price_range"]))
        if r["must_try"]:    parts.append("nên thử")
        if r["vegetarian"]:  parts.append("có món chay")
        body = _clip(r["description"], 200)
        out.append({"title": f"Món ăn {name}", "category": "food",
                    "text": " — ".join(p for p in parts if p) + (". " + body if body else ""),
                    "source": "db_structured", "score": 0.95})
    return out


async def _restaurants(db, did, name) -> list[dict]:
    rows = await _q(db, """
        SELECT name, type, address, hours, price_range, specialties, description, rating
        FROM restaurants WHERE destination_id = :did
        ORDER BY rating DESC NULLS LAST, must_try DESC NULLS LAST LIMIT 12
    """, did)
    out = []
    for r in rows:
        parts = [r["name"]]
        if r["type"]:        parts.append(str(r["type"]))
        if r["price_range"]: parts.append(str(r["price_range"]))
        if r["rating"]:      parts.append(f"đánh giá {r['rating']}")
        body = []
        if r["specialties"]: body.append(f"Món: {_arr(r['specialties'])}")
        if r["address"]:     body.append(f"Địa chỉ: {r['address']}")
        if r["hours"]:       body.append(f"Giờ: {r['hours']}")
        if r["description"]: body.append(_clip(r["description"], 140))
        out.append({"title": f"Nhà hàng/quán {name}", "category": "restaurant",
                    "text": " — ".join(parts) + (". " + " ".join(body) if body else ""),
                    "source": "db_structured", "score": 0.95})
    return out


# Intent → danh sách handler (có thể nhiều bảng).
_INTENT_TABLES = {
    "find_hotel":      [_hotels],
    "find_tour":       [_tours],
    "ask_transport":   [_transport],
    "ask_shopping":    [_shopping],
    "ask_activity":    [_locations, _events],
    "ask_destination": [_locations, _events],
    "ask_budget":      [_tickets, _hotels],
    "plan_trip":       [_itineraries, _locations],
    "ask_food":        [_foods, _restaurants],
}


# [Anti-hallucination theo nhóm] intent → (bảng chính, nhãn hiển thị).
# Khi user hỏi đúng 1 nhóm mà thành phố KHÔNG có dữ liệu nhóm đó → trả câu
# "chưa có dữ liệu" thay vì để Qdrant/PG trả faq lạc rồi Gemini bịa.
_INTENT_PRIMARY_TABLE = {
    "find_hotel":    ("hotels",            "🏨 khách sạn"),
    "find_tour":     ("tours",             "🧳 tour"),
    "ask_shopping":  ("shopping_places",   "🛍 địa điểm mua sắm"),
    "ask_transport": ("transport_options", "🚗 thông tin di chuyển"),
    "ask_food":      ("foods",             "🍜 ẩm thực / nhà hàng"),
}

# Bảng → nhãn, để liệt kê "thành phố này hiện có dữ liệu về gì".
_COVERAGE_TABLES = [
    ("📍 điểm tham quan", "locations"),
    ("🏨 khách sạn",      "hotels"),
    ("🍜 ẩm thực",        "foods"),
    ("🛍 mua sắm",        "shopping_places"),
    ("🚗 di chuyển",      "transport_options"),
    ("🧳 tour",           "tours"),
    ("🎉 sự kiện",        "destination_events"),
    ("🗺 lịch trình",     "itineraries"),
]


# Tất cả bảng cần đếm để quyết định gap-message (bảng chính của intent +
# các bảng coverage gợi ý). table chỉ lấy từ hằng số nội bộ → an toàn để
# nội suy thẳng vào SQL (không phải input user).
_ALL_COUNT_TABLES: list[str] = [
    "locations", "hotels", "foods", "restaurants", "shopping_places",
    "transport_options", "tours", "destination_events", "itineraries",
]


async def _count_all(db, did) -> dict[str, int]:
    """
    Đếm số dòng của TẤT CẢ bảng liên quan cho 1 destination trong DUY NHẤT
    một round-trip DB (UNION ALL), thay vì tối đa 9 lượt `await` tuần tự như
    trước (1 cho bảng chính + tới 8 cho coverage) — giảm độ trễ mỗi lượt
    category_gap_message chạy (nó chạy trên MỌI câu hỏi có intent + địa danh,
    kể cả khi kết quả cuối cùng là "có dữ liệu, bỏ qua").
    """
    union_sql = " UNION ALL ".join(
        f"SELECT '{tbl}' AS tbl, count(*) AS c FROM {tbl} WHERE destination_id = :d"
        for tbl in _ALL_COUNT_TABLES
    )
    rows = (await db.execute(text(union_sql), {"d": str(did)})).all()
    return {r[0]: r[1] for r in rows}


async def category_gap_message(
    intent: Optional[str],
    location: Optional[str],
    city_slug: Optional[str],
    confidence: float = 1.0,
) -> Optional[str]:
    """
    Trả câu "chưa có dữ liệu [nhóm] cho [thành phố]" (kèm gợi ý nhóm CÓ data) khi:
      - intent thuộc nhóm có bảng cấu trúc riêng, VÀ
      - CONFIDENCE của intent đủ cao (mặc định >= 0.6) — nếu intent chỉ là
        phỏng đoán yếu (câu mơ hồ khớp nhầm 1 keyword), tuyên bố "chưa có dữ
        liệu" dựa trên intent sai sẽ chặn oan câu hỏi mà RAG/LLM đáng lẽ trả
        lời được bình thường, VÀ
      - resolve được destination (user nêu địa danh cụ thể), VÀ
      - bảng tương ứng KHÔNG có dòng nào cho destination đó.
    Trả None nếu có data (để pipeline trả lời bình thường) hoặc không xác định
    được địa danh (để luồng RAG thường xử lý). KHÔNG raise.
    """
    if not intent or intent not in _INTENT_PRIMARY_TABLE:
        return None
    if confidence < 0.6:
        return None
    if not location and not city_slug:
        return None
    try:
        from app.db.database import AsyncSessionLocal
        async with AsyncSessionLocal() as db:
            did, name = await resolve_destination(db, location, city_slug)
            if not did:
                return None

            counts = await _count_all(db, did)
            if intent == "ask_food":
                cnt = counts.get("foods", 0) + counts.get("restaurants", 0)
            else:
                table, _ = _INTENT_PRIMARY_TABLE[intent]
                cnt = counts.get(table, 0)
            if cnt > 0:
                return None  # có dữ liệu → trả lời bình thường

            _, label = _INTENT_PRIMARY_TABLE[intent]
            avail = [lbl for lbl, tbl in _COVERAGE_TABLES if counts.get(tbl, 0) > 0]

            msg = (
                f"Hiện PDTrip chưa có dữ liệu {label} cho **{name}**, nên mình "
                f"chưa thể tư vấn phần này (mình không muốn đưa thông tin chưa kiểm chứng) 🙏"
            )
            if avail:
                msg += f"\n\nVới {name}, mình có thể giúp bạn về: " + ", ".join(avail) + "."
            else:
                msg += f"\n\n{name} hiện chưa có nhiều dữ liệu trong hệ thống — bạn thử hỏi một điểm đến khác nhé."
            return msg
    except Exception as e:
        logger.warning(f"[Structured] category_gap_message lỗi: {e}")
        return None


_GROUP_LABEL = {
    "couple": "Cặp đôi", "family": "Gia đình", "solo": "Một mình", "group": "Nhóm bạn",
}


def _duration_text(days: Optional[int]) -> str:
    if not days or days < 1:
        return ""
    return "1 ngày" if days == 1 else f"{days} ngày {days - 1} đêm"


async def build_itinerary(
    location: Optional[str], city_slug: Optional[str], entities: Optional[dict] = None,
) -> Optional[dict]:
    """
    [P1] Dựng lịch trình CÓ CẤU TRÚC cho intent plan_trip từ bảng itineraries +
    itinerary_items (dữ liệu thật, không bịa). Trả dict cho ItineraryCard/
    TripDetailsScreen, hoặc None nếu thành phố chưa có lịch trình mẫu.

    Shape: {destination, destination_id, itinerary_id, duration, duration_days,
            group, budget_low, budget_high, days:[{day,title,activities[]}], hotels[]}
    """
    if not location and not city_slug:
        return None
    ent = entities or {}
    want_days = ent.get("duration_days")
    try:
        from app.db.database import AsyncSessionLocal
        async with AsyncSessionLocal() as db:
            did, dname = await resolve_destination(db, location, city_slug)
            if not did:
                return None

            templates = await _q(db, """
                SELECT id, title, duration_days, group_type, budget_low, budget_high
                FROM itineraries WHERE destination_id = :did AND is_active
                ORDER BY duration_days NULLS LAST
            """, did)
            if not templates:
                return None

            # Chọn template khớp số ngày user muốn nhất (nếu có), else cái đầu
            chosen = templates[0]
            if want_days:
                for t in templates:
                    if t["duration_days"] == want_days:
                        chosen = t
                        break

            items = await _q(db, """
                SELECT day_no, order_no, time_slot, title, description
                FROM itinerary_items WHERE itinerary_id = :did
                ORDER BY day_no, order_no
            """, chosen["id"])

            # gom theo ngày
            by_day: dict = {}
            for it in items:
                d = it["day_no"] or 1
                acts = by_day.setdefault(d, [])
                slot = (it["time_slot"] or "").strip()
                title = (it["title"] or "").strip()
                acts.append(f"{slot}: {title}" if slot else title)
            days = [
                {"day": d, "title": f"Ngày {d}", "activities": by_day[d]}
                for d in sorted(by_day)
            ]

            # vài khách sạn thật (gợi ý kèm)
            hotel_rows = await _q(db, """
                SELECT name, stars, price_per_night FROM hotels
                WHERE destination_id = :did
                ORDER BY rating DESC NULLS LAST, stars DESC NULLS LAST LIMIT 3
            """, did)
            hotels = [
                {"name": h["name"], "stars": h["stars"],
                 "price": h["price_per_night"]}
                for h in hotel_rows
            ]

            return {
                "destination": dname,
                "destination_id": str(did),
                "itinerary_id": str(chosen["id"]),
                "duration": _duration_text(chosen["duration_days"]),
                "duration_days": chosen["duration_days"],
                # "group" = nhãn hiển thị (vd "Nhóm bạn"); "group_type" = key
                # THẬT khớp CHECK constraint trip_plans.travel_type ở DB
                # ('solo'/'couple'/'family'/'group'). Bug đã sửa: trước đây
                # chỉ có "group" (label) — nếu FE lỡ gửi thẳng label này làm
                # travel_type khi lưu chuyến đi sẽ crash IntegrityError.
                "group": _GROUP_LABEL.get(chosen["group_type"] or "", chosen["group_type"] or ""),
                "group_type": chosen["group_type"],
                "budget_low": chosen["budget_low"] or 0,
                "budget_high": chosen["budget_high"] or 0,
                "days": days,
                "hotels": hotels,
            }
    except Exception as e:
        logger.warning(f"[Structured] build_itinerary lỗi: {e}")
        return None


async def fetch_structured_sources(
    intent: Optional[str],
    location: Optional[str],
    city_slug: Optional[str],
) -> list[dict]:
    """
    Trả về list source dict từ DB có cấu trúc theo intent + destination.
    [] nếu intent không cần structured, hoặc không resolve được destination.
    Tự mở session riêng, không bao giờ raise (lỗi → log + trả []).
    """
    if not intent or intent not in _STRUCTURED_INTENTS:
        return []
    if not location and not city_slug:
        return []

    try:
        from app.db.database import AsyncSessionLocal
        async with AsyncSessionLocal() as db:
            did, dname = await resolve_destination(db, location, city_slug)
            if not did:
                return []
            handlers = _INTENT_TABLES.get(intent, [])
            sources: list[dict] = []
            for h in handlers:
                try:
                    sources.extend(await h(db, did, dname))
                except Exception as e:
                    logger.warning(f"[Structured] handler {h.__name__} lỗi: {e}")
            if len(sources) > _MAX_ROWS:
                sources = sources[:_MAX_ROWS]
            logger.info(
                f"[Structured] intent={intent} dest={dname} → {len(sources)} nguồn DB"
            )
            return sources
    except Exception as e:
        logger.warning(f"[Structured] fetch lỗi: {e}")
        return []
