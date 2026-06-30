# Gom tất cả ORM models để SQLAlchemy nhận diện đầy đủ metadata

from .user import User, RefreshToken, OtpCode, EmailVerification
from .chat import ChatSession, ChatMessage
from .travel import (
    Destination, Location, Hotel, Tour, Ticket,
    TransportOption, DestinationEvent, ShoppingPlace,
    Review, UserFavorite,
)
from .trip import TripPlan, TripPlanItem
from .admin import KnowledgeEntry, EmbeddingJob
from .media import MediaFolder, MediaFile

__all__ = [
    "User", "RefreshToken", "OtpCode", "EmailVerification",
    "ChatSession", "ChatMessage",
    "Destination", "Location", "Hotel", "Tour", "Ticket",
    "TransportOption", "DestinationEvent", "ShoppingPlace",
    "Review", "UserFavorite",
    "TripPlan", "TripPlanItem",
    "KnowledgeEntry", "EmbeddingJob",
    "MediaFolder", "MediaFile",
    # SearchHistory & UserBehavior: đã chuyển sang MongoDB, xem app/services/log_service.py
]
