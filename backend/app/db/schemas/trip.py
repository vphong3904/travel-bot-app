from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime, date, time
from typing import Optional


class TripPlanItemCreate(BaseModel):
    day_number: int = Field(..., ge=1)
    order_in_day: int = 0
    title: Optional[str] = None
    description: Optional[str] = None
    location_id: Optional[UUID] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    estimated_cost: Optional[int] = None
    notes: Optional[str] = None


class TripPlanItemUpdate(BaseModel):
    day_number: Optional[int] = None
    order_in_day: Optional[int] = None
    title: Optional[str] = None
    description: Optional[str] = None
    location_id: Optional[UUID] = None
    start_time: Optional[time] = None
    end_time: Optional[time] = None
    estimated_cost: Optional[int] = None
    notes: Optional[str] = None


class TripPlanItemOut(BaseModel):
    id: UUID
    trip_plan_id: UUID
    day_number: int
    order_in_day: int
    title: Optional[str]
    description: Optional[str]
    location_id: Optional[UUID]
    start_time: Optional[time]
    end_time: Optional[time]
    estimated_cost: Optional[int]
    notes: Optional[str]

    model_config = {"from_attributes": True}


class TripPlanCreate(BaseModel):
    destination_id: Optional[UUID] = None
    title: Optional[str] = None
    budget: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    travelers: int = 1
    travel_type: Optional[str] = None


class TripPlanUpdate(BaseModel):
    title: Optional[str] = None
    budget: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    travelers: Optional[int] = None
    travel_type: Optional[str] = None
    status: Optional[str] = None


class TripPlanOut(BaseModel):
    id: UUID
    user_id: UUID
    destination_id: Optional[UUID]
    title: Optional[str]
    budget: Optional[int]
    start_date: Optional[date]
    end_date: Optional[date]
    travelers: int
    travel_type: Optional[str]
    status: str
    ai_generated: bool
    created_at: Optional[datetime]
    updated_at: Optional[datetime]
    items: list[TripPlanItemOut] = []

    model_config = {"from_attributes": True}


class TripPlanListOut(BaseModel):
    id: UUID
    user_id: UUID
    destination_id: Optional[UUID]
    title: Optional[str]
    start_date: Optional[date]
    end_date: Optional[date]
    travelers: int
    status: str
    ai_generated: bool
    created_at: Optional[datetime]

    model_config = {"from_attributes": True}


# ── AI Trip Planner (TP-001/002 — contract .agent/trip-ai/TRIP_AI_ROADMAP.md §2)
class AiPlanRequest(BaseModel):
    destination: Optional[str] = None
    days: Optional[int] = Field(None, ge=1, le=14)
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    budget: Optional[int] = Field(None, ge=0)
    travelers: Optional[int] = Field(None, ge=1, le=50)
    travel_type: Optional[str] = None      # solo|couple|family|friends
    preferences: list[str] = []
    skip_optional: bool = False


class AiPlanItemIn(BaseModel):
    time_slot: Optional[str] = None
    start_time: Optional[str] = None       # "HH:MM"
    end_time: Optional[str] = None
    order_in_day: int = 0
    type: str = "free"                     # location|restaurant|hotel_checkin|free
    ref_id: Optional[UUID] = None
    title: Optional[str] = None
    description: Optional[str] = None
    estimated_cost: Optional[int] = None
    notes: Optional[str] = None


class AiPlanDayIn(BaseModel):
    day_number: int = Field(..., ge=1)
    items: list[AiPlanItemIn] = []


class AiPlanConfirmRequest(BaseModel):
    """Body = object `plan` từ /trips/ai/plan (user có thể đã đổi lựa chọn)."""
    title: str
    destination_id: Optional[UUID] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    days_count: int = Field(..., ge=1, le=14)
    travelers: int = Field(1, ge=1, le=50)
    travel_type: Optional[str] = None
    budget: Optional[int] = None
    estimated_cost: Optional[int] = None
    summary: Optional[str] = None
    days: list[AiPlanDayIn]


# Aliases tương thích ngược
TripCreate = TripPlanCreate
TripUpdate = TripPlanUpdate
TripResponse = TripPlanOut
TripItemCreate = TripPlanItemCreate
TripItemUpdate = TripPlanItemUpdate
TripItemResponse = TripPlanItemOut
