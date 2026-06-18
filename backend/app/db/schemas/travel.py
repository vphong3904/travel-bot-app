from pydantic import BaseModel, Field, field_validator
from uuid import UUID
from datetime import datetime
from typing import Optional
from decimal import Decimal


class CategoryOut(BaseModel):
    id: UUID
    name: str
    slug: str
    icon: Optional[str]
    description: Optional[str]

    model_config = {"from_attributes": True}


class DestinationListOut(BaseModel):
    id: UUID
    name: str
    province: Optional[str]
    region: Optional[str]
    budget_low: Optional[int]
    budget_high: Optional[int]
    categories: Optional[list[CategoryOut]]
    image_url: Optional[str]
    rating_avg: Optional[Decimal]
    review_count: Optional[int]
    favorite_count: Optional[int]
    view_count: Optional[int]      # thêm để card ngoài Home hiển thị được lượt xem

    model_config = {"from_attributes": True}


class DestinationOut(BaseModel):
    id: UUID
    name: str
    province: Optional[str]
    region: Optional[str]
    description: Optional[str]
    best_season: Optional[str]
    best_months: Optional[list[int]]   # [11,12,1,2,...] — tháng đẹp nhất
    weather: Optional[str]
    cuisine: Optional[str]
    special: Optional[str]
    budget_low: Optional[int]
    budget_high: Optional[int]
    categories: Optional[list[CategoryOut]]
    image_url: Optional[str]
    rating_avg: Optional[Decimal]
    review_count: Optional[int]
    favorite_count: Optional[int]
    view_count: Optional[int]

    model_config = {"from_attributes": True}


# ── Review schemas ─────────────────────────────────────────────────────────────

class ReviewCreate(BaseModel):
    rating: int = Field(..., ge=1, le=5, description="Điểm đánh giá từ 1 đến 5")
    content: Optional[str] = Field(None, max_length=2000)


class ReviewOut(BaseModel):
    id: UUID
    user_id: UUID
    destination_id: UUID
    rating: int
    content: Optional[str]
    created_at: Optional[datetime]

    model_config = {"from_attributes": True}


class ReviewWithUserOut(ReviewOut):
    """Review kèm thông tin người dùng (dùng cho public listing)."""
    username: Optional[str] = None
    avatar_url: Optional[str] = None

    model_config = {"from_attributes": True}


# ── UserFavorite schemas ───────────────────────────────────────────────────────

class FavoriteStatusOut(BaseModel):
    destination_id: UUID
    is_favorited: bool


class FavoriteDestinationOut(BaseModel):
    """Destination tóm tắt trong danh sách yêu thích."""
    destination_id: UUID
    created_at: Optional[datetime]
    destination: DestinationListOut

    model_config = {"from_attributes": True}


class HotelOut(BaseModel):
    id: UUID
    destination_id: UUID
    name: str
    type: Optional[str]
    stars: Optional[int]
    price_per_night: Optional[int]
    address: Optional[str]
    amenities: Optional[list[str]]
    description: Optional[str]
    image_url: Optional[str]
    rating: Optional[Decimal]

    model_config = {"from_attributes": True}


class TourOut(BaseModel):
    id: UUID
    destination_id: UUID
    name: str
    duration: Optional[str]
    price: Optional[int]
    group_size: Optional[str]
    description: Optional[str]
    includes: Optional[list[str]]
    excludes: Optional[list[str]]
    image_url: Optional[str]

    model_config = {"from_attributes": True}


class TicketOut(BaseModel):
    id: UUID
    destination_id: UUID
    name: str
    price_adult: Optional[int]
    price_child: Optional[int]
    description: Optional[str]
    hours: Optional[str]

    model_config = {"from_attributes": True}


class TransportOptionOut(BaseModel):
    id: UUID
    destination_id: UUID
    type: str
    is_local: bool
    price_info: Optional[str]
    duration: Optional[str]
    provider: Optional[str]
    notes: Optional[str]

    model_config = {"from_attributes": True}


class DestinationEventOut(BaseModel):
    id: UUID
    destination_id: UUID
    name: str
    event_date: Optional[str]
    location_text: Optional[str]
    cost: Optional[str]
    description: Optional[str]

    model_config = {"from_attributes": True}


class ShoppingPlaceOut(BaseModel):
    id: UUID
    destination_id: UUID
    name: str
    type: Optional[str]
    items: Optional[list[str]]
    address: Optional[str]
    opening_hours: Optional[str]
    price_range: Optional[str]

    model_config = {"from_attributes": True}


# Aliases tương thích ngược
DestinationResponse = DestinationOut
HotelResponse = HotelOut
TourResponse = TourOut
TicketResponse = TicketOut
TransportResponse = TransportOptionOut
EventResponse = DestinationEventOut
ShoppingResponse = ShoppingPlaceOut
ReviewResponse = ReviewOut
FavoriteResponse = FavoriteStatusOut
