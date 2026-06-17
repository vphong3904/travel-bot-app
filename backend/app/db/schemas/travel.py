from pydantic import BaseModel
from uuid import UUID
from datetime import datetime
from typing import Optional
from decimal import Decimal


class DestinationListOut(BaseModel):
    id: UUID
    name: str
    province: Optional[str]
    region: Optional[str]
    budget_low: Optional[int]
    budget_high: Optional[int]
    travel_type: Optional[list[str]]
    image_url: Optional[str]

    model_config = {"from_attributes": True}


class DestinationOut(BaseModel):
    id: UUID
    name: str
    province: Optional[str]
    region: Optional[str]
    description: Optional[str]
    best_season: Optional[str]
    weather: Optional[str]
    cuisine: Optional[str]
    budget_low: Optional[int]
    budget_high: Optional[int]
    travel_type: Optional[list[str]]
    image_url: Optional[str]

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
