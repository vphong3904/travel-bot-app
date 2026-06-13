from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, EmailStr, ConfigDict, field_validator


class UserCreate(BaseModel):
    name: str
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
    is_active: bool

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class ChatRequest(BaseModel):
    message: str
    user_id: int = 0
    user_name: str = "Khách"
    session_id: Optional[int] = None


class ChatResponse(BaseModel):
    text: str
    intent: str
    confidence: float
    has_itinerary: bool = False
    itinerary: Optional[dict] = None
    destinations: Optional[list] = None
    services: Optional[list] = None
    sources: list[str] = []
    session_id: Optional[int] = None


class ChatMessageResponse(BaseModel):
    id: int
    session_id: Optional[int] = None
    message: str
    response: str
    intent: str
    created_at: datetime

    class Config:
        from_attributes = True


class ChatSessionResponse(BaseModel):
    id: int
    user_id: int
    user_name: str
    title: Optional[str] = None
    summary: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ChatSessionDetailResponse(ChatSessionResponse):
    messages: list[ChatMessageResponse] = []


class DestinationResponse(BaseModel):
    id: int
    name: str
    region: str = ""
    description: str = ""
    highlights: str = ""
    best_season: str = ""
    weather: str = ""
    cuisine: str = ""
    budget_low: int = 0
    budget_high: int = 0
    tags: str = ""
    image_url: str = ""

    model_config = ConfigDict(from_attributes=True)

    @field_validator(
        "region",
        "description",
        "highlights",
        "best_season",
        "weather",
        "cuisine",
        "tags",
        "image_url",
        mode="before",
    )
    def _fill_string_fields(cls, value):
        return value or ""

    @field_validator("budget_low", "budget_high", mode="before")
    def _fill_int_fields(cls, value):
        return value or 0


class HotelResponse(BaseModel):
    id: int
    name: str
    destination: str
    type: str = ""
    price_per_night: int = 0
    rating: float = 0.0
    address: str = ""
    amenities: str = ""

    model_config = ConfigDict(from_attributes=True)

    @field_validator(
        "type",
        "address",
        "amenities",
        mode="before",
    )
    def _fill_string_fields(cls, value):
        return value or ""

    @field_validator("price_per_night", "rating", mode="before")
    def _fill_numeric_fields(cls, value):
        return value or 0


class TourResponse(BaseModel):
    id: int
    name: str
    destination: str
    duration: str = ""
    price: int = 0
    description: str = ""
    includes: str = ""

    model_config = ConfigDict(from_attributes=True)

    @field_validator(
        "duration",
        "description",
        "includes",
        mode="before",
    )
    def _fill_string_fields(cls, value):
        return value or ""

    @field_validator("price", mode="before")
    def _fill_price(cls, value):
        return value or 0


class TicketResponse(BaseModel):
    id: int
    name: str
    destination: str
    price: int = 0
    description: str = ""

    model_config = ConfigDict(from_attributes=True)

    @field_validator("description", mode="before")
    def _fill_string_fields(cls, value):
        return value or ""

    @field_validator("price", mode="before")
    def _fill_price(cls, value):
        return value or 0


class KBEntryCreate(BaseModel):
    title: str
    category: str
    destination: str = ""
    content: str
    tags: str = ""


class KBEntryUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    destination: Optional[str] = None
    content: Optional[str] = None
    tags: Optional[str] = None


class KBEntryResponse(BaseModel):
    id: int
    title: str
    category: str
    destination: str
    content: str
    tags: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ChatLogResponse(BaseModel):
    id: int
    user_id: int
    user_name: str
    message: str
    response: str
    intent: str
    destination: str
    created_at: datetime

    class Config:
        from_attributes = True


class StatsResponse(BaseModel):
    total_users: int
    total_chats: int
    total_kb_entries: int
    popular_questions: list[dict]
    popular_destinations: list[dict]
    intent_distribution: list[dict]
    daily_chats: list[dict]
