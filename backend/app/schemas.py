from datetime import datetime
from typing import Any, Optional

from pydantic import BaseModel, EmailStr


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


class ChatResponse(BaseModel):
    text: str
    intent: str
    confidence: float
    has_itinerary: bool = False
    itinerary: Optional[dict] = None
    destinations: Optional[list] = None
    services: Optional[list] = None
    sources: list[str] = []


class DestinationResponse(BaseModel):
    id: int
    name: str
    region: str
    description: str
    highlights: str
    best_season: str
    weather: str
    cuisine: str
    budget_low: int
    budget_high: int
    tags: str
    image_url: str

    class Config:
        from_attributes = True


class HotelResponse(BaseModel):
    id: int
    name: str
    destination: str
    type: str
    price_per_night: int
    rating: float
    address: str
    amenities: str

    class Config:
        from_attributes = True


class TourResponse(BaseModel):
    id: int
    name: str
    destination: str
    duration: str
    price: int
    description: str
    includes: str

    class Config:
        from_attributes = True


class TicketResponse(BaseModel):
    id: int
    name: str
    destination: str
    price: int
    description: str

    class Config:
        from_attributes = True


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
