"""
Routes: /travel/destinations  và các sub-resources
GET /travel/categories                         → danh sách categories
GET /travel/destinations                       → list + filter + sort
GET /travel/destinations/:id                   → detail (+ tăng view_count)
GET /travel/destinations/:id/hotels            → hotels
GET /travel/destinations/:id/tours             → tours
GET /travel/destinations/:id/tickets           → tickets
GET /travel/destinations/:id/events            → events
GET /travel/destinations/:id/transport         → transport
GET /travel/destinations/:id/shopping          → shopping
"""
import time
from uuid import UUID
from typing import Optional, Literal
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func, or_, update, insert, text
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_db, get_current_user_optional, CurrentUser, DB
from sqlalchemy.exc import IntegrityError
from app.services import log_service
from app.utils import get_logger

logger = get_logger("travel")
from app.db.models.travel import (
    Destination,
    DestinationViewLog,
    Hotel,
    Tour,
    Ticket,
    DestinationEvent,
    TransportOption,
    ShoppingPlace,
    Location,
    Category,
)
from app.db.schemas.travel import (
    CategoryOut,
    DestinationOut,
    DestinationListOut,
    HotelOut,
    TourOut,
    TicketOut,
    DestinationEventOut,
    TransportOptionOut,
    ShoppingPlaceOut,
)

router = APIRouter(tags=["travel"])


# ── Categories list ───────────────────────────────────────────────────────────
@router.get("/categories", response_model=list[CategoryOut])
async def list_categories(
    db: AsyncSession = Depends(get_db),
):
    """Trả về toàn bộ categories đang active — dùng để render chip 'Theo sở thích'."""
    result = await db.execute(
        select(Category)
        .where(Category.is_active.is_(True))
        .order_by(Category.name)
    )
    return result.scalars().all()


# ── Global search (public) ─────────────────────────────────────────────────────
# Tra cứu tất cả loại: điểm đến, khách sạn, tour, nhà hàng, món ăn, mua sắm.
# Tìm không dấu (unaccent). Tìm theo tên thành phố cũng ra hotel/food… của TP đó.
_SEARCH_TYPES = ("destination", "hotel", "tour", "restaurant", "food", "shopping")

# ── Nhãn loại lấy từ bảng content_options (admin quản lý) ────────────────────────
# Ánh xạ cột thực tế của bảng → (content_type, field) trong content_options.
_OPTION_FIELD = {
    "food": ("foods", "type"),            # foods.category
    "restaurant": ("restaurants", "cuisine_type"),  # restaurants.type
    "shopping": ("shopping", "goods_type"),         # shopping_places.type
}
_OPT_CACHE: dict = {"data": None, "ts": 0.0}
_OPT_TTL = 300.0  # giây


async def _option_labels(db: AsyncSession) -> dict:
    """Nạp toàn bộ nhãn code→label (cache 5 phút). Key = (content_type, field, code)."""
    now = time.monotonic()
    if _OPT_CACHE["data"] is not None and (now - _OPT_CACHE["ts"]) < _OPT_TTL:
        return _OPT_CACHE["data"]
    rows = (await db.execute(text(
        "SELECT content_type, field, code, label FROM content_options WHERE is_active"
    ))).mappings().all()
    data = {(r["content_type"], r["field"], r["code"]): r["label"] for r in rows}
    _OPT_CACHE["data"] = data
    _OPT_CACHE["ts"] = now
    return data


def _label_for(labels: dict, item_type: str, code) -> Optional[str]:
    """Nhãn tiếng Việt cho 1 code theo loại; không có bảng/không khớp → trả code gốc."""
    if not code:
        return None
    key = _OPTION_FIELD.get(item_type)
    if key is None:
        return code
    return labels.get((key[0], key[1], code)) or code


def _fmt_vnd(n) -> Optional[str]:
    if n is None:
        return None
    try:
        n = int(n)
    except (TypeError, ValueError):
        return None
    if n == 0:
        return "Miễn phí"
    return f"{n:,}".replace(",", ".") + "đ"


@router.get("/search")
async def search_all(
    q: str = Query(..., min_length=1, description="Từ khoá (có thể gõ không dấu)"),
    types: Optional[str] = Query(
        None, description="Lọc loại, csv: destination,hotel,tour,restaurant,food,shopping"),
    limit_per_type: int = Query(10, ge=1, le=30),
    db: AsyncSession = Depends(get_db),
):
    like = f"%{q.strip()}%"
    want = (
        {t for t in (types or "").split(",") if t in _SEARCH_TYPES}
        if types else set(_SEARCH_TYPES)
    )
    labels = await _option_labels(db)
    results: list[dict] = []

    async def _run(typ: str, sql: str, mapper):
        if typ not in want:
            return
        rows = (await db.execute(text(sql), {"like": like, "lim": limit_per_type})).mappings().all()
        for r in rows:
            results.append(mapper(r))

    # ── Destinations ───────────────────────────────────────────────
    await _run("destination", """
        SELECT id::text AS id, name, province, region, image_url,
               rating_avg, budget_low, budget_high
        FROM destinations
        WHERE is_active = TRUE AND (
              unaccent(name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(province,'')) ILIKE unaccent(:like)
           OR unaccent(COALESCE(region,'')) ILIKE unaccent(:like)
           OR unaccent(COALESCE(description,'')) ILIKE unaccent(:like))
        ORDER BY rating_avg DESC NULLS LAST, view_count DESC NULLS LAST
        LIMIT :lim
    """, lambda r: {
        "type": "destination", "id": r["id"], "name": r["name"],
        "subtitle": r["province"] or r["region"] or "",
        "image_url": r["image_url"] or "",
        "rating": float(r["rating_avg"]) if r["rating_avg"] is not None else 0.0,
        "price": (f"{_fmt_vnd(r['budget_low'])} – {_fmt_vnd(r['budget_high'])}"
                  if (r["budget_low"] or r["budget_high"]) else None),
        "tag": None,
        "destination_id": r["id"],
    })

    # ── Hotels ─────────────────────────────────────────────────────
    await _run("hotel", """
        SELECT h.id::text AS id, h.name, h.type, h.stars, h.price_per_night,
               h.image_url, h.rating, d.name AS dest_name, d.province,
               d.id::text AS destination_id
        FROM hotels h JOIN destinations d ON d.id = h.destination_id
        WHERE unaccent(h.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(h.address,'')) ILIKE unaccent(:like)
           OR unaccent(COALESCE(h.description,'')) ILIKE unaccent(:like)
           OR unaccent(d.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(d.province,'')) ILIKE unaccent(:like)
        ORDER BY h.rating DESC NULLS LAST
        LIMIT :lim
    """, lambda r: {
        "type": "hotel", "id": r["id"], "name": r["name"],
        "subtitle": r["dest_name"] or r["province"] or "",
        "image_url": r["image_url"] or "",
        "rating": float(r["rating"]) if r["rating"] is not None else 0.0,
        "price": (_fmt_vnd(r["price_per_night"]) + "/đêm") if r["price_per_night"] else None,
        "tag": (f"{r['stars']}★" if r["stars"] else r["type"]),
        "destination_id": r["destination_id"],
    })

    # ── Tours ──────────────────────────────────────────────────────
    await _run("tour", """
        SELECT t.id::text AS id, t.name, t.duration, t.price, t.image_url,
               d.name AS dest_name, d.province, d.id::text AS destination_id
        FROM tours t JOIN destinations d ON d.id = t.destination_id
        WHERE unaccent(t.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(t.description,'')) ILIKE unaccent(:like)
           OR unaccent(d.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(d.province,'')) ILIKE unaccent(:like)
        ORDER BY t.price ASC NULLS LAST
        LIMIT :lim
    """, lambda r: {
        "type": "tour", "id": r["id"], "name": r["name"],
        "subtitle": r["dest_name"] or r["province"] or "",
        "image_url": r["image_url"] or "",
        "rating": 0.0,
        "price": _fmt_vnd(r["price"]),
        "tag": r["duration"],
        "destination_id": r["destination_id"],
    })

    # ── Restaurants ────────────────────────────────────────────────
    await _run("restaurant", """
        SELECT r.id::text AS id, r.name, r.type, r.address, r.price_range,
               r.rating, r.image_url, d.name AS dest_name, d.province,
               d.id::text AS destination_id
        FROM restaurants r JOIN destinations d ON d.id = r.destination_id
        WHERE unaccent(r.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(r.address,'')) ILIKE unaccent(:like)
           OR unaccent(COALESCE(array_to_string(r.specialties,' '),'')) ILIKE unaccent(:like)
           OR unaccent(d.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(d.province,'')) ILIKE unaccent(:like)
        ORDER BY r.rating DESC NULLS LAST
        LIMIT :lim
    """, lambda r: {
        "type": "restaurant", "id": r["id"], "name": r["name"],
        "subtitle": r["dest_name"] or r["province"] or "",
        "image_url": r["image_url"] or "",
        "rating": float(r["rating"]) if r["rating"] is not None else 0.0,
        "price": r["price_range"],
        "tag": _label_for(labels, "restaurant", r["type"]),
        "destination_id": r["destination_id"],
    })

    # ── Foods ──────────────────────────────────────────────────────
    await _run("food", """
        SELECT f.id::text AS id, f.name, f.local_name, f.category, f.price_range,
               f.image_url, d.name AS dest_name, d.province,
               d.id::text AS destination_id
        FROM foods f JOIN destinations d ON d.id = f.destination_id
        WHERE unaccent(f.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(f.local_name,'')) ILIKE unaccent(:like)
           OR unaccent(COALESCE(f.description,'')) ILIKE unaccent(:like)
           OR unaccent(COALESCE(array_to_string(f.tags,' '),'')) ILIKE unaccent(:like)
           OR unaccent(d.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(d.province,'')) ILIKE unaccent(:like)
        ORDER BY f.must_try DESC NULLS LAST
        LIMIT :lim
    """, lambda r: {
        "type": "food", "id": r["id"], "name": r["name"],
        "subtitle": r["dest_name"] or r["province"] or "",
        "image_url": r["image_url"] or "",
        "rating": 0.0,
        "price": r["price_range"],
        "tag": (r["local_name"] if (r["local_name"] and r["local_name"] != r["name"])
                else _label_for(labels, "food", r["category"])),
        "destination_id": r["destination_id"],
    })

    # ── Shopping ───────────────────────────────────────────────────
    await _run("shopping", """
        SELECT s.id::text AS id, s.name, s.type, s.address, s.price_range,
               s.image_url, d.name AS dest_name, d.province,
               d.id::text AS destination_id
        FROM shopping_places s JOIN destinations d ON d.id = s.destination_id
        WHERE unaccent(s.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(s.address,'')) ILIKE unaccent(:like)
           OR unaccent(COALESCE(array_to_string(s.items,' '),'')) ILIKE unaccent(:like)
           OR unaccent(d.name) ILIKE unaccent(:like)
           OR unaccent(COALESCE(d.province,'')) ILIKE unaccent(:like)
        ORDER BY s.name
        LIMIT :lim
    """, lambda r: {
        "type": "shopping", "id": r["id"], "name": r["name"],
        "subtitle": r["dest_name"] or r["province"] or "",
        "image_url": r["image_url"] or "",
        "rating": 0.0,
        "price": r["price_range"],
        "tag": _label_for(labels, "shopping", r["type"]),
        "destination_id": r["destination_id"],
    })

    counts = {t: 0 for t in _SEARCH_TYPES}
    for it in results:
        counts[it["type"]] += 1

    return {"query": q, "total": len(results), "counts": counts, "results": results}


# ── Destinations list ─────────────────────────────────────────────────────────
@router.get("/destinations", response_model=list[DestinationListOut])
async def list_destinations(
    region: Optional[str] = Query(None, description="Miền Bắc | Miền Trung | Miền Nam | Tây Nguyên"),
    budget_max: Optional[int] = Query(None, description="Ngân sách tối đa (VND/ngày)"),
    budget_min: Optional[int] = Query(None, description="Ngân sách tối thiểu (VND/ngày) — dùng cho tab 'ngân sách cao'"),
    category: Optional[str] = Query(None, description="Tên hoặc slug category"),
    q: Optional[str] = Query(None, description="Tìm kiếm fulltext"),
    sort_by: Literal["name", "popular", "rating", "favorite"] = Query(
        "name",
        description="Sắp xếp: name | popular (view_count) | rating (rating_avg) | favorite (favorite_count)",
    ),
    month: Optional[int] = Query(None, ge=1, le=12, description="Lọc theo tháng đẹp nhất (1–12)"),
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Destination)
        .options(selectinload(Destination.categories))
        .where(Destination.is_active.is_(True))
    )

    # ── Filters ──
    if region:
        stmt = stmt.where(Destination.region == region)
    if budget_max is not None:
        stmt = stmt.where(Destination.budget_low <= budget_max)
    if budget_min is not None:
        stmt = stmt.where(Destination.budget_low >= budget_min)
    if category:
        stmt = stmt.join(Destination.categories).where(
            or_(Category.slug == category, Category.name == category)
        ).distinct()
    if q:
        stmt = stmt.where(
            func.to_tsvector(
                "simple",
                Destination.name + " "
                + func.coalesce(Destination.province, "")
                + " "
                + func.coalesce(Destination.description, ""),
            ).op("@@")(func.plainto_tsquery("simple", q))
        )
    if month is not None:
        # best_months là SMALLINT[] — lọc những destination có tháng này trong mảng
        stmt = stmt.where(Destination.best_months.contains([month]))

    # ── Sort ──
    sort_map = {
        "popular": Destination.view_count.desc(),
        "rating": Destination.rating_avg.desc(),
        "favorite": Destination.favorite_count.desc(),
        "name": Destination.name.asc(),
    }
    stmt = stmt.order_by(sort_map[sort_by]).offset(skip).limit(limit)

    result = await db.execute(stmt)
    return result.scalars().all()


# ── Destination detail ────────────────────────────────────────────────────────
@router.get("/destinations/{destination_id}", response_model=DestinationOut)
async def get_destination(
    destination_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Destination)
        .options(selectinload(Destination.categories))
        .where(
            Destination.id == destination_id,
            Destination.is_active.is_(True),
        )
    )
    dest = result.scalar_one_or_none()
    if not dest:
        raise HTTPException(status_code=404, detail="Destination not found")

    return dest


# ── Track view (dedup theo user + ngày) ────────────────────────────────────────
@router.post("/destinations/{destination_id}/view", status_code=204)
async def track_destination_view(
    destination_id: UUID,
    current_user: CurrentUser,
    db: DB,
):
    """
    Tăng view_count cho destination.
    Mỗi user chỉ được đếm 1 lần / destination / ngày (dedup qua destination_view_logs).
    """
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

    # Thử INSERT vào log; nếu vi phạm unique constraint → bỏ qua (đã xem hôm nay)
    try:
        await db.execute(
            insert(DestinationViewLog).values(
                user_id=current_user.id,
                destination_id=destination_id,
                view_date=today,
            )
        )
        # Chỉ increment khi INSERT thành công (lần đầu xem hôm nay)
        await db.execute(
            update(Destination)
            .where(Destination.id == destination_id)
            .values(view_count=Destination.view_count + 1)
        )
        await db.commit()
        # Ghi behavior log vào MongoDB (non-blocking, không ảnh hưởng response)
        await log_service.log_behavior(
            user_id=str(current_user.id),
            event_type="view_destination",
            entity_type="destination",
            entity_id=str(destination_id),
        )
    except IntegrityError:
        # UniqueViolationError: user đã xem hôm nay — dedup, bỏ qua bình thường
        await db.rollback()
    except Exception as e:
        # Lỗi không mong đợi (mất kết nối DB, v.v.) — log để phát hiện kịp thời
        await db.rollback()
        logger.warning(f"[track_destination_view] Lỗi không mong đợi: {e}")


# ── Hotels ────────────────────────────────────────────────────────────────────
@router.get("/destinations/{destination_id}/hotels", response_model=list[HotelOut])
async def list_hotels(
    destination_id: UUID,
    stars: Optional[int] = Query(None, ge=1, le=5),
    price_max: Optional[int] = None,
    hotel_type: Optional[str] = None,
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
):
    await _get_dest_or_404(db, destination_id)

    stmt = select(Hotel).where(Hotel.destination_id == destination_id)
    if stars:
        stmt = stmt.where(Hotel.stars == stars)
    if price_max:
        stmt = stmt.where(Hotel.price_per_night <= price_max)
    if hotel_type:
        stmt = stmt.where(Hotel.type == hotel_type)

    stmt = stmt.order_by(Hotel.rating.desc()).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


# ── Tours ─────────────────────────────────────────────────────────────────────
@router.get("/destinations/{destination_id}/tours", response_model=list[TourOut])
async def list_tours(
    destination_id: UUID,
    price_max: Optional[int] = None,
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
):
    await _get_dest_or_404(db, destination_id)

    stmt = select(Tour).where(Tour.destination_id == destination_id)
    if price_max:
        stmt = stmt.where(Tour.price <= price_max)
    stmt = stmt.order_by(Tour.price.asc()).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


# ── Tickets ───────────────────────────────────────────────────────────────────
@router.get("/destinations/{destination_id}/tickets", response_model=list[TicketOut])
async def list_tickets(
    destination_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    await _get_dest_or_404(db, destination_id)
    result = await db.execute(
        select(Ticket)
        .where(Ticket.destination_id == destination_id)
        .order_by(Ticket.name)
    )
    return result.scalars().all()


# ── Events ────────────────────────────────────────────────────────────────────
@router.get("/destinations/{destination_id}/events", response_model=list[DestinationEventOut])
async def list_events(
    destination_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    await _get_dest_or_404(db, destination_id)
    result = await db.execute(
        select(DestinationEvent)
        .where(DestinationEvent.destination_id == destination_id)
        .order_by(DestinationEvent.name)
    )
    return result.scalars().all()


# ── Transport ─────────────────────────────────────────────────────────────────
@router.get("/destinations/{destination_id}/transport", response_model=list[TransportOptionOut])
async def list_transport(
    destination_id: UUID,
    is_local: Optional[bool] = Query(None, description="True=nội đô, False=đến địa điểm"),
    db: AsyncSession = Depends(get_db),
):
    await _get_dest_or_404(db, destination_id)

    stmt = select(TransportOption).where(TransportOption.destination_id == destination_id)
    if is_local is not None:
        stmt = stmt.where(TransportOption.is_local == is_local)
    result = await db.execute(stmt.order_by(TransportOption.type))
    return result.scalars().all()


# ── Shopping ──────────────────────────────────────────────────────────────────
@router.get("/destinations/{destination_id}/shopping", response_model=list[ShoppingPlaceOut])
async def list_shopping(
    destination_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    await _get_dest_or_404(db, destination_id)
    result = await db.execute(
        select(ShoppingPlace)
        .where(ShoppingPlace.destination_id == destination_id)
        .order_by(ShoppingPlace.name)
    )
    return result.scalars().all()


# ── Single-item detail (hotel/tour/restaurant/food/shopping) ───────────────────
# 1 endpoint chung, trả full record + tên điểm đến chứa nó (để mở link).
_ITEM_DETAIL_SQL = {
    "hotel": """
        SELECT h.id::text AS id, h.name, h.type, h.stars, h.price_per_night,
               h.address, h.amenities, h.description, h.image_url, h.rating,
               d.id::text AS destination_id, d.name AS destination_name,
               d.province, d.region
        FROM hotels h JOIN destinations d ON d.id = h.destination_id
        WHERE h.id = :id
    """,
    "tour": """
        SELECT t.id::text AS id, t.name, t.duration, t.price, t.group_size,
               t.description, t.includes, t.excludes, t.image_url,
               d.id::text AS destination_id, d.name AS destination_name,
               d.province, d.region
        FROM tours t JOIN destinations d ON d.id = t.destination_id
        WHERE t.id = :id
    """,
    "restaurant": """
        SELECT r.id::text AS id, r.name, r.type, r.address, r.hours, r.price_range,
               r.specialties, r.description, r.tips, r.rating, r.must_try, r.image_url,
               d.id::text AS destination_id, d.name AS destination_name,
               d.province, d.region
        FROM restaurants r JOIN destinations d ON d.id = r.destination_id
        WHERE r.id = :id
    """,
    "food": """
        SELECT f.id::text AS id, f.name, f.local_name, f.category, f.description,
               f.price_range, f.must_try, f.vegetarian, f.tags, f.image_url,
               d.id::text AS destination_id, d.name AS destination_name,
               d.province, d.region
        FROM foods f JOIN destinations d ON d.id = f.destination_id
        WHERE f.id = :id
    """,
    "shopping": """
        SELECT s.id::text AS id, s.name, s.type, s.items, s.address, s.opening_hours,
               s.price_range, s.image_url,
               d.id::text AS destination_id, d.name AS destination_name,
               d.province, d.region
        FROM shopping_places s JOIN destinations d ON d.id = s.destination_id
        WHERE s.id = :id
    """,
}


@router.get("/items/{item_type}/{item_id}")
async def get_item_detail(
    item_type: str,
    item_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    sql = _ITEM_DETAIL_SQL.get(item_type)
    if sql is None:
        raise HTTPException(status_code=404, detail="Loại không hợp lệ")
    row = (await db.execute(text(sql), {"id": str(item_id)})).mappings().first()
    if not row:
        raise HTTPException(status_code=404, detail="Không tìm thấy")
    data = dict(row)
    data["type"] = item_type

    # Nhãn loại tiếng Việt từ content_options (admin quản lý)
    labels = await _option_labels(db)
    if item_type == "food":
        data["category_label"] = _label_for(labels, "food", data.get("category"))
    elif item_type in ("restaurant", "shopping"):
        data["type_label"] = _label_for(labels, item_type, data.get("type"))
    return data


# ── Destination overview (gộp mọi loại để màn chi tiết hiển thị đầy đủ) ─────────
# Trả danh sách rút gọn cho từng nhóm; mỗi item tap được → mở EntityDetail.
@router.get("/destinations/{destination_id}/overview")
async def destination_overview(
    destination_id: UUID,
    limit: int = Query(10, ge=1, le=20),
    db: AsyncSession = Depends(get_db),
):
    did = str(destination_id)

    async def rows(sql: str):
        return [dict(r) for r in
                (await db.execute(text(sql), {"d": did, "lim": limit})).mappings().all()]

    hotels = await rows("""
        SELECT id::text AS id, name, image_url, stars, price_per_night, rating, type
        FROM hotels WHERE destination_id = :d
        ORDER BY rating DESC NULLS LAST LIMIT :lim
    """)
    foods = await rows("""
        SELECT id::text AS id, name, image_url, local_name, price_range, must_try
        FROM foods WHERE destination_id = :d
        ORDER BY must_try DESC NULLS LAST, name LIMIT :lim
    """)
    restaurants = await rows("""
        SELECT id::text AS id, name, image_url, type, price_range, rating
        FROM restaurants WHERE destination_id = :d
        ORDER BY rating DESC NULLS LAST LIMIT :lim
    """)
    tours = await rows("""
        SELECT id::text AS id, name, image_url, duration, price
        FROM tours WHERE destination_id = :d
        ORDER BY price ASC NULLS LAST LIMIT :lim
    """)
    shopping = await rows("""
        SELECT id::text AS id, name, image_url, type, price_range
        FROM shopping_places WHERE destination_id = :d
        ORDER BY name LIMIT :lim
    """)

    return {
        "hotels": hotels,
        "foods": foods,
        "restaurants": restaurants,
        "tours": tours,
        "shopping": shopping,
    }


# ── Itineraries (gợi ý lịch trình + thống kê chi phí) ───────────────────────────
_GROUP_LABEL = {
    "solo": "Solo / 1 người",
    "couple": "Cặp đôi",
    "family": "Gia đình",
    "group": "Nhóm bạn",
}


def _cost_block(r) -> dict:
    """Gói breakdown chi phí (VND/người) + tổng. None → 0 để tính tổng an toàn."""
    t = r["cost_transport"] or 0
    a = r["cost_accommodation"] or 0
    f = r["cost_food"] or 0
    ac = r["cost_activities"] or 0
    o = r["cost_other"] or 0
    return {
        "transport": t, "accommodation": a, "food": f,
        "activities": ac, "other": o, "total": t + a + f + ac + o,
        "per_person": True,
    }


def _itin_summary(r) -> dict:
    return {
        "id": r["id"], "title": r["name"],
        "duration_days": r["duration_days"],
        "group_type": r["group_type"],
        "group_label": _GROUP_LABEL.get(r["group_type"] or "", "Mọi nhóm"),
        "budget_low": r["budget_low"], "budget_high": r["budget_high"],
        "description": r["description"],
        "cost": _cost_block(r),
    }


@router.get("/destinations/{destination_id}/itineraries")
async def destination_itineraries(
    destination_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Gợi ý lịch trình của điểm đến (ưu tiên có số ngày), kèm chi phí ước tính."""
    rows = (await db.execute(text("""
        SELECT id::text AS id, title AS name, duration_days, group_type,
               budget_low, budget_high, description,
               cost_transport, cost_accommodation, cost_food, cost_activities, cost_other
        FROM itineraries
        WHERE destination_id = :d AND is_active AND duration_days IS NOT NULL
        ORDER BY duration_days,
                 CASE group_type WHEN 'solo' THEN 0 WHEN 'couple' THEN 1
                                 WHEN 'family' THEN 2 ELSE 3 END
    """), {"d": str(destination_id)})).mappings().all()
    return [_itin_summary(r) for r in rows]


@router.get("/itineraries/{itinerary_id}")
async def itinerary_detail(
    itinerary_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Chi tiết 1 lịch trình: thông tin + chi phí + lịch theo từng ngày."""
    r = (await db.execute(text("""
        SELECT i.id::text AS id, i.title AS name, i.duration_days, i.group_type,
               i.budget_low, i.budget_high, i.description,
               i.cost_transport, i.cost_accommodation, i.cost_food,
               i.cost_activities, i.cost_other,
               d.id::text AS destination_id, d.name AS destination_name, d.province
        FROM itineraries i
        LEFT JOIN destinations d ON d.id = i.destination_id
        WHERE i.id = :id
    """), {"id": str(itinerary_id)})).mappings().first()
    if not r:
        raise HTTPException(status_code=404, detail="Không tìm thấy lịch trình")

    items = (await db.execute(text("""
        SELECT day_no, time_slot, title, description
        FROM itinerary_items WHERE itinerary_id = :id
        ORDER BY day_no NULLS LAST, order_no NULLS LAST
    """), {"id": str(itinerary_id)})).mappings().all()

    days: list[dict] = []
    by_day: dict = {}
    for it in items:
        dno = it["day_no"] or 1
        if dno not in by_day:
            by_day[dno] = {"day_no": dno, "items": []}
            days.append(by_day[dno])
        by_day[dno]["items"].append({
            "time_slot": it["time_slot"],
            "title": it["title"],
            "description": it["description"],
        })

    out = _itin_summary(r)
    out.update({
        "destination_id": r["destination_id"],
        "destination_name": r["destination_name"],
        "province": r["province"],
        "days": days,
    })
    return out


# ── Gợi ý cá nhân hoá "Dành cho bạn" (TP-003 — TRIP_AI_ROADMAP §2.3) ──────────
@router.get("/suggestions/for-you")
async def suggestions_for_you(
    limit: int = Query(10, ge=1, le=30),
    db: AsyncSession = Depends(get_db),
    current_user=Depends(get_current_user_optional),
):
    """
    Gợi ý điểm đến theo hồ sơ sở thích suy từ hành vi (chat/tìm kiếm/yêu thích).
    User mới hoặc guest → fallback điểm đến nổi bật, tags=[] (không lỗi).
    """
    from app.services import user_preference_service as prefs

    profile: list[dict] = []
    if current_user is not None:
        try:
            profile = await prefs.get_profile(db, str(current_user.id))
        except Exception as e:
            logger.warning(f"[for-you] Lỗi lấy profile, dùng fallback: {e}")

    items: list[dict] = []
    seen: set[str] = set()

    def _dest_dict(r, matched: list[str]) -> dict:
        return {
            "id": r.id,
            "name": r.name,
            "province": r.province,
            "region": r.region,
            "image_url": r.image_url,
            "rating_avg": float(r.rating_avg) if r.rating_avg is not None else 0.0,
            "favorite_count": r.favorite_count or 0,
            "matched_tags": matched,
        }

    for p in profile:
        kws = prefs.keywords_for_tags([p["tag"]], max_per_tag=6)
        if not kws:
            continue
        like_ors = " OR ".join(f"unaccent(blob) ILIKE :kw{i}" for i in range(len(kws)))
        params: dict = {f"kw{i}": f"%{kw.strip()}%" for i, kw in enumerate(kws)}
        params["lim"] = limit
        rows = await db.execute(
            text(
                f"""
                SELECT id, name, province, region, image_url, rating_avg, favorite_count
                FROM (
                    SELECT id::text, name, province, region, image_url, rating_avg,
                           favorite_count,
                           name || ' ' || COALESCE(description,'') || ' ' ||
                           COALESCE(special,'') || ' ' || COALESCE(region,'') AS blob
                    FROM destinations WHERE is_active IS NOT FALSE
                ) d
                WHERE {like_ors}
                ORDER BY rating_avg DESC NULLS LAST, favorite_count DESC NULLS LAST
                LIMIT :lim
                """
            ),
            params,
        )
        for r in rows:
            if r.id in seen:
                for it in items:
                    if it["id"] == r.id and p["tag"] not in it["matched_tags"]:
                        it["matched_tags"].append(p["tag"])
                continue
            seen.add(r.id)
            items.append(_dest_dict(r, [p["tag"]]))

    # Fallback / bù cho đủ limit: điểm đến nổi bật
    if len(items) < limit:
        rows = await db.execute(
            text(
                """
                SELECT id::text AS id, name, province, region, image_url,
                       rating_avg, favorite_count
                FROM destinations
                WHERE is_active IS NOT FALSE
                ORDER BY favorite_count DESC NULLS LAST, rating_avg DESC NULLS LAST
                LIMIT :lim
                """
            ),
            {"lim": limit},
        )
        for r in rows:
            if len(items) >= limit:
                break
            if r.id not in seen:
                seen.add(r.id)
                items.append(_dest_dict(r, []))

    reason = None
    if profile:
        labels = ", ".join(p["label"] for p in profile)
        reason = f"Dựa trên các câu hỏi và tìm kiếm gần đây của bạn về: {labels}"

    return {
        "tags": [{"tag": p["tag"], "label": p["label"], "score": p["score"]} for p in profile],
        "items": items[:limit],
        "reason": reason,
    }


# ── Helper ────────────────────────────────────────────────────────────────────
async def _get_dest_or_404(db: AsyncSession, destination_id: UUID) -> Destination:
    result = await db.execute(
        select(Destination).where(
            Destination.id == destination_id,
            Destination.is_active.is_(True),
        )
    )
    dest = result.scalar_one_or_none()
    if not dest:
        raise HTTPException(status_code=404, detail="Destination not found")
    return dest
