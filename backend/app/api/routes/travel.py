"""
Routes: /travel/destinations  và các sub-resources
GET /travel/destinations               → list + filter
GET /travel/destinations/:id           → detail
GET /travel/destinations/:id/hotels    → hotels
GET /travel/destinations/:id/tours     → tours
GET /travel/destinations/:id/tickets   → tickets
GET /travel/destinations/:id/events    → events
GET /travel/destinations/:id/transport → transport
GET /travel/destinations/:id/shopping  → shopping
"""
from uuid import UUID
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func, or_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_db, get_current_user_optional
from app.db.models.travel import (
    Destination,
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


# ── Destinations list ─────────────────────────────────────────────────────────
@router.get("/destinations", response_model=list[DestinationListOut])
async def list_destinations(
    region: Optional[str] = Query(None, description="Miền Bắc | Miền Trung | Miền Nam | Tây Nguyên"),
    budget_max: Optional[int] = Query(None, description="Ngân sách tối đa (VND/ngày)"),
    category: Optional[str] = Query(None, description="Tên hoặc slug category"),
    q: Optional[str] = Query(None, description="Tìm kiếm fulltext"),
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Destination).options(selectinload(Destination.categories)).where(Destination.is_active.is_(True))

    if region:
        stmt = stmt.where(Destination.region == region)
    if budget_max:
        stmt = stmt.where(Destination.budget_low <= budget_max)
    if category:
        stmt = stmt.join(Destination.categories).where(
            or_(Category.slug == category, Category.name == category)
        ).distinct()
    if q:
        stmt = stmt.where(
            func.to_tsvector("simple",
                Destination.name + " " +
                func.coalesce(Destination.province, "") + " " +
                func.coalesce(Destination.description, "")
            ).op("@@")(func.plainto_tsquery("simple", q))
        )

    stmt = stmt.order_by(Destination.name).offset(skip).limit(limit)
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