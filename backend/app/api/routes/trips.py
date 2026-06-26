"""
Routes: /trips  &  /trips/:id/items
POST   /trips               → Tạo lịch trình
GET    /trips               → Danh sách của tôi
GET    /trips/:id           → Chi tiết + items
PATCH  /trips/:id           → Cập nhật
DEL    /trips/:id           → Xoá

POST   /trips/:id/items         → Thêm item
PATCH  /trips/:id/items/:item_id → Sửa item
DEL    /trips/:id/items/:item_id → Xoá item
"""
from uuid import UUID
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.db.models.user import User
from app.db.models.trip import TripPlan, TripPlanItem
from app.services import log_service
from app.db.schemas.trip import (
    TripPlanCreate,
    TripPlanUpdate,
    TripPlanOut,
    TripPlanListOut,
    TripPlanItemCreate,
    TripPlanItemUpdate,
    TripPlanItemOut,
)

router = APIRouter(tags=["trips"])


# ── List trips ────────────────────────────────────────────────────────────────
@router.get("/", response_model=list[TripPlanListOut])
async def list_trips(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    stmt = select(TripPlan).where(TripPlan.user_id == current_user.id)
    if status:
        stmt = stmt.where(TripPlan.status == status)
    stmt = stmt.order_by(TripPlan.updated_at.desc()).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


# ── Create trip ───────────────────────────────────────────────────────────────
@router.post("/", response_model=TripPlanOut, status_code=status.HTTP_201_CREATED)
async def create_trip(
    payload: TripPlanCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    trip = TripPlan(
        user_id=current_user.id,
        **payload.model_dump(exclude_unset=True),
    )
    db.add(trip)
    await db.commit()
    await db.refresh(trip)
    # Ghi behavior log vào MongoDB
    await log_service.log_behavior(
        user_id=str(current_user.id),
        event_type="save_trip",
        entity_type="trip",
        entity_id=str(trip.id),
    )
    return trip


# ── Get trip detail (with items) ──────────────────────────────────────────────
@router.get("/{trip_id}", response_model=TripPlanOut)
async def get_trip(
    trip_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(TripPlan)
        .options(selectinload(TripPlan.items))
        .where(TripPlan.id == trip_id, TripPlan.user_id == current_user.id)
    )
    trip = result.scalar_one_or_none()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")
    return trip


# ── Update trip ───────────────────────────────────────────────────────────────
@router.patch("/{trip_id}", response_model=TripPlanOut)
async def update_trip(
    trip_id: UUID,
    payload: TripPlanUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    trip = await _get_trip_or_404(db, trip_id, current_user.id)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(trip, field, value)
    await db.commit()
    await db.refresh(trip)
    return trip


# ── Delete trip ───────────────────────────────────────────────────────────────
@router.delete("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_trip(
    trip_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    trip = await _get_trip_or_404(db, trip_id, current_user.id)
    await db.delete(trip)
    await db.commit()


# ── Add item to trip ──────────────────────────────────────────────────────────
@router.post("/{trip_id}/items", response_model=TripPlanItemOut, status_code=status.HTTP_201_CREATED)
async def add_trip_item(
    trip_id: UUID,
    payload: TripPlanItemCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await _get_trip_or_404(db, trip_id, current_user.id)

    item = TripPlanItem(
        trip_plan_id=trip_id,
        **payload.model_dump(exclude_unset=True),
    )
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


# ── Update item ───────────────────────────────────────────────────────────────
@router.patch("/{trip_id}/items/{item_id}", response_model=TripPlanItemOut)
async def update_trip_item(
    trip_id: UUID,
    item_id: UUID,
    payload: TripPlanItemUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await _get_trip_or_404(db, trip_id, current_user.id)
    item = await _get_item_or_404(db, item_id, trip_id)

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(item, field, value)
    await db.commit()
    await db.refresh(item)
    return item


# ── Delete item ───────────────────────────────────────────────────────────────
@router.delete("/{trip_id}/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_trip_item(
    trip_id: UUID,
    item_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await _get_trip_or_404(db, trip_id, current_user.id)
    item = await _get_item_or_404(db, item_id, trip_id)
    await db.delete(item)
    await db.commit()


# ── Helpers ───────────────────────────────────────────────────────────────────
async def _get_trip_or_404(db: AsyncSession, trip_id: UUID, user_id: UUID) -> TripPlan:
    result = await db.execute(
        select(TripPlan).where(TripPlan.id == trip_id, TripPlan.user_id == user_id)
    )
    trip = result.scalar_one_or_none()
    if not trip:
        raise HTTPException(status_code=404, detail="Trip not found")
    return trip


async def _get_item_or_404(db: AsyncSession, item_id: UUID, trip_id: UUID) -> TripPlanItem:
    result = await db.execute(
        select(TripPlanItem).where(
            TripPlanItem.id == item_id,
            TripPlanItem.trip_plan_id == trip_id,
        )
    )
    item = result.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item