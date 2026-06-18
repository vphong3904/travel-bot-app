from app.db.schemas.auth import (
    RegisterRequest, LoginRequest, TokenResponse,
    RefreshRequest, UserResponse, UpdateProfileRequest,
)
from app.db.schemas.chat import (
    ChatSessionCreate, ChatSessionUpdate, ChatSessionOut, ChatSessionListOut,
    ChatMessageCreate, ChatMessageOut, FeedbackUpdate,
)
from app.db.schemas.travel import (
    DestinationOut, DestinationListOut, HotelOut,
    TourOut, TicketOut, TransportOptionOut,
    DestinationEventOut, ShoppingPlaceOut,
)
from app.db.schemas.trip import (
    TripPlanCreate, TripPlanUpdate, TripPlanOut, TripPlanListOut,
    TripPlanItemCreate, TripPlanItemUpdate, TripPlanItemOut,
)
from app.db.schemas.admin import (
    KnowledgeEntryCreate, KnowledgeEntryUpdate, KnowledgeEntryOut,
    EmbeddingJobOut, UserAdminOut, UserAdminUpdate,
    StatsQuestionsOut, StatsDestinationsOut, StatsChatbotOut, StatsUsersOut,
    ChatLogOut, SearchHistoryOut, SearchResultOut,
)
