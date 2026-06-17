# Gom tất cả ORM models để SQLAlchemy nhận diện đầy đủ metadata

from .user import User, RefreshToken, OtpCode
from .chat import ChatSession, ChatMessage
from .travel import (
    Destination, Location, Hotel, Tour, Ticket,
    TransportOption, DestinationEvent, ShoppingPlace,
    Review, UserFavorite,
)
from .trip import TripPlan, TripPlanItem
from .admin import KnowledgeEntry, EmbeddingJob, SearchHistory, UserBehavior

__all__ = [
    "User", "RefreshToken", "OtpCode",
    "ChatSession", "ChatMessage",
    "Destination", "Location", "Hotel", "Tour", "Ticket",
    "TransportOption", "DestinationEvent", "ShoppingPlace",
    "Review", "UserFavorite",
    "TripPlan", "TripPlanItem",
    "KnowledgeEntry", "EmbeddingJob", "SearchHistory", "UserBehavior",
]
