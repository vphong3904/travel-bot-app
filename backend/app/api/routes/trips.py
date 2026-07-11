"""
Routes: /trips  &  /trips/:id/items
POST   /trips/ai/plan       → AI lên lịch trình (need_info | draft) — TP-001
POST   /trips/ai/confirm    → Lưu plan user đã chốt vào lịch sử — TP-002
POST   /trips               → Tạo lịch trình
GET    /trips               → Danh sách của tôi
GET    /trips/:id           → Chi tiết + items
PATCH  /trips/:id           → Cập nhật
DEL    /trips/:id           → Xoá

POST   /trips/:id/items         → Thêm item
PATCH  /trips/:id/items/:item_id → Sửa item
DEL    /trips/:id/items/:item_id → Xoá item
"""
from datetime import time as time_type
from uuid import UUID
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.db.models.user import User
from app.db.models.trip import TripPlan, TripPlanItem
from app.services import log_service, trip_planner_service
from app.db.schemas.trip import (
    AiPlanConfirmRequest,
    AiPlanRequest,
    TripPlanCreate,
    TripPlanUpdate,
    TripPlanOut,
    TripPlanListOut,
    TripPlanItemCreate,
    TripPlanItemUpdate,
    TripPlanItemOut,
)

router = APIRouter(tags=["trips"])


# ── AI Trip Planner (TR-06: khai báo TRƯỚC các route /{trip_id}) ──────────────
@router.post("/ai/plan")
async def ai_plan_trip(
    payload: AiPlanRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Slot-filling + lên lịch trình draft (contract TRIP_AI_ROADMAP §2.1).
    Thiếu slot → {status:"need_info"}; đủ → {status:"draft", plan:{...}}.
    KHÔNG lưu gì vào DB (TR-04) — lưu qua /trips/ai/confirm.
    """
    return await trip_planner_service.plan_trip(
        db, str(current_user.id), payload.model_dump()
    )


def _parse_time(value: Optional[str]) -> Optional[time_type]:
    if not value:
        return None
    try:
        return time_type.fromisoformat(value)
    except ValueError:
        return None


@router.post("/ai/confirm", response_model=TripPlanOut, status_code=status.HTTP_201_CREATED)
async def ai_confirm_trip(
    payload: AiPlanConfirmRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """User chốt plan (có thể đã đổi lựa chọn) → lưu vào lịch sử chuyến đi."""
    trip = TripPlan(
        user_id=current_user.id,
        destination_id=payload.destination_id,
        title=payload.title,
        budget=payload.budget,
        start_date=payload.start_date,
        end_date=payload.end_date,
        travelers=payload.travelers,
        travel_type=payload.travel_type,
        status="planned",
        ai_generated=True,
    )
    db.add(trip)
    await db.flush()

    for day in payload.days:
        for item in day.items:
            db.add(
                TripPlanItem(
                    trip_plan_id=trip.id,
                    day_number=day.day_number,
                    order_in_day=item.order_in_day,
                    title=item.title,
                    description=item.description,
                    location_id=item.ref_id if item.type == "location" else None,
                    start_time=_parse_time(item.start_time),
                    end_time=_parse_time(item.end_time),
                    estimated_cost=item.estimated_cost,
                    notes=item.notes,
                )
            )
    await db.commit()

    result = await db.execute(
        select(TripPlan)
        .options(selectinload(TripPlan.items))
        .where(TripPlan.id == trip.id)
    )
    trip = result.scalar_one()

    await log_service.log_behavior(
        user_id=str(current_user.id),
        event_type="save_trip",
        entity_type="trip",
        entity_id=str(trip.id),
    )
    return trip


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