"""
Routes: /search
GET /search           → Tìm kiếm chung (destinations + hotels + knowledge)
GET /search/history   → Lịch sử tìm kiếm
DEL /search/history   → Xoá lịch sử
"""
from uuid import UUID
from typing import Optional

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy import select, delete, func, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.db.models.user import User
from app.db.models.travel import Destination, Hotel, Tour
from app.db.models.admin import SearchHistory
from app.db.schemas.admin import SearchResultOut, SearchHistoryOut

router = APIRouter(tags=["search"])


# ── Full-text search ──────────────────────────────────────────────────────────
@router.get("/", response_model=SearchResultOut)
async def search(
    q: str = Query(..., min_length=1, description="Từ khoá tìm kiếm"),
    limit: int = Query(10, le=30),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Tìm kiếm song song trên: destinations, hotels, tours.
    Lưu keyword vào search_history.
    """
    ts_query = func.plainto_tsquery("simple", q)

    # Search destinations
    dest_stmt = (
        select(Destination.id, Destination.name, Destination.province, Destination.region)
        .where(
            Destination.is_active.is_(True),
            func.to_tsvector(
                "simple",
                Destination.name + " " +
                func.coalesce(Destination.province, "") + " " +
                func.coalesce(Destination.description, "")
            ).op("@@")(ts_query)
        )
        .limit(limit)
    )

    # Search hotels
    hotel_stmt = (
        select(Hotel.id, Hotel.name, Hotel.destination_id, Hotel.type, Hotel.stars)
        .where(
            func.to_tsvector(
                "simple",
                Hotel.name + " " + func.coalesce(Hotel.address, "")
            ).op("@@")(ts_query)
        )
        .limit(limit)
    )

    # Search tours
    tour_stmt = (
        select(Tour.id, Tour.name, Tour.destination_id, Tour.price)
        .where(
            func.to_tsvector(
                "simple",
                Tour.name + " " + func.coalesce(Tour.description, "")
            ).op("@@")(ts_query)
        )
        .limit(limit)
    )

    dest_res, hotel_res, tour_res = (
        await db.execute(dest_stmt),
        await db.execute(hotel_stmt),
        await db.execute(tour_stmt),
    )

    destinations = [dict(r._mapping) for r in dest_res.all()]
    hotels = [dict(r._mapping) for r in hotel_res.all()]
    tours = [dict(r._mapping) for r in tour_res.all()]

    total = len(destinations) + len(hotels) + len(tours)

    # Lưu lịch sử tìm kiếm
    history_entry = SearchHistory(
        user_id=current_user.id,
        keyword=q,
        result_count=total,
    )
    db.add(history_entry)
    await db.commit()

    return SearchResultOut(
        query=q,
        total=total,
        destinations=destinations,
        hotels=hotels,
        tours=tours,
    )


# ── Search history ────────────────────────────────────────────────────────────
@router.get("/history", response_model=list[SearchHistoryOut])
async def get_search_history(
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(SearchHistory)
        .where(SearchHistory.user_id == current_user.id)
        .order_by(SearchHistory.created_at.desc())
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()


# ── Delete search history ─────────────────────────────────────────────────────
@router.delete("/history", status_code=status.HTTP_204_NO_CONTENT)
async def clear_search_history(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await db.execute(
        delete(SearchHistory).where(SearchHistory.user_id == current_user.id)
    )
    await db.commit()