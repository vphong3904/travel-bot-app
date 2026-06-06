from typing import Optional

from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import Destination, Hotel, Ticket, Tour
from app.schemas import DestinationResponse, HotelResponse, TicketResponse, TourResponse

router = APIRouter(prefix="/destinations", tags=["Destinations"])


@router.get("", response_model=list[DestinationResponse])
async def list_destinations(
    tag: Optional[str] = None,
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Destination)

    if tag:
        stmt = stmt.where(Destination.tags.ilike(f"%{tag}%"))

    if search:
        stmt = stmt.where(
            or_(
                Destination.name.ilike(f"%{search}%"),
                Destination.description.ilike(f"%{search}%"),
            )
        )

    result = await db.execute(stmt)
    return result.scalars().all()


@router.get("/{dest_id}", response_model=DestinationResponse)
async def get_destination(
    dest_id: int,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Destination).where(Destination.id == dest_id)
    )

    dest = result.scalar_one_or_none()

    if not dest:
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy địa điểm",
        )

    return dest


services_router = APIRouter(prefix="/services", tags=["Services"])


@services_router.get("/hotels", response_model=list[HotelResponse])
async def list_hotels(
    destination: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Hotel)

    if destination:
        stmt = stmt.where(
            Hotel.destination.ilike(f"%{destination}%")
        )

    result = await db.execute(stmt)
    return result.scalars().all()


@services_router.get("/tours", response_model=list[TourResponse])
async def list_tours(
    destination: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Tour)

    if destination:
        stmt = stmt.where(
            Tour.destination.ilike(f"%{destination}%")
        )

    result = await db.execute(stmt)
    return result.scalars().all()


@services_router.get("/tickets", response_model=list[TicketResponse])
async def list_tickets(
    destination: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Ticket)

    if destination:
        stmt = stmt.where(
            Ticket.destination.ilike(f"%{destination}%")
        )

    result = await db.execute(stmt)
    return result.scalars().all()


@services_router.get("/search")
async def search_services(
    q: str = Query(""),
    type: Optional[str] = None,
    destination: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    results = {
        "hotels": [],
        "tours": [],
        "tickets": [],
    }

    if type in (None, "hotel"):
        stmt = select(Hotel)

        if destination:
            stmt = stmt.where(
                Hotel.destination.ilike(f"%{destination}%")
            )

        if q:
            stmt = stmt.where(
                Hotel.name.ilike(f"%{q}%")
            )

        result = await db.execute(stmt.limit(10))
        results["hotels"] = [
            HotelResponse.model_validate(x)
            for x in result.scalars().all()
        ]

    if type in (None, "tour"):
        stmt = select(Tour)

        if destination:
            stmt = stmt.where(
                Tour.destination.ilike(f"%{destination}%")
            )

        if q:
            stmt = stmt.where(
                Tour.name.ilike(f"%{q}%")
            )

        result = await db.execute(stmt.limit(10))
        results["tours"] = [
            TourResponse.model_validate(x)
            for x in result.scalars().all()
        ]

    if type in (None, "ticket"):
        stmt = select(Ticket)

        if destination:
            stmt = stmt.where(
                Ticket.destination.ilike(f"%{destination}%")
            )

        if q:
            stmt = stmt.where(
                Ticket.name.ilike(f"%{q}%")
            )

        result = await db.execute(stmt.limit(10))
        results["tickets"] = [
            TicketResponse.model_validate(x)
            for x in result.scalars().all()
        ]

    return results