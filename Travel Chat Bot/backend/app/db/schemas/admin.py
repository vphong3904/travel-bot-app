from pydantic import BaseModel, Field, field_validator
from uuid import UUID
from datetime import datetime
from typing import Optional
from app.db.models.user import UserRole


# ── Knowledge Base ────────────────────────────────────────────────────────────

class KnowledgeEntryCreate(BaseModel):
    title: str = Field(..., max_length=300)
    category: str
    destination_id: Optional[UUID] = None
    content: str
    tags: list[str] = []
    source: Optional[str] = None


class KnowledgeEntryUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    content: Optional[str] = None
    tags: Optional[list[str]] = None
    is_active: Optional[bool] = None


class KnowledgeEntryOut(BaseModel):
    id: UUID
    title: str
    category: Optional[str]
    destination_id: Optional[UUID]
    content: str
    tags: Optional[list[str]]
    source: Optional[str]
    is_active: bool
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    model_config = {"from_attributes": True}


# ── Embedding Jobs ────────────────────────────────────────────────────────────

class EmbeddingJobOut(BaseModel):
    id: UUID
    entity_type: str
    entity_id: UUID
    status: str
    error: Optional[str]
    created_at: Optional[datetime]
    updated_at: Optional[datetime]

    model_config = {"from_attributes": True}


# ── Users (admin view) ────────────────────────────────────────────────────────

class UserAdminOut(BaseModel):
    id: UUID
    username: str
    email: str
    full_name: Optional[str]
    role: str
    is_active: bool
    created_at: Optional[datetime]

    model_config = {"from_attributes": True}


class UserAdminUpdate(BaseModel):
    role: Optional[str] = None
    is_active: Optional[bool] = None


# ── Stats ─────────────────────────────────────────────────────────────────────

class StatsQuestionsOut(BaseModel):
    period_days: int
    top_keywords: list[dict]


class StatsDestinationsOut(BaseModel):
    period_days: int
    top_destinations: list[dict]


class StatsChatbotOut(BaseModel):
    period_days: int
    total_messages: int
    avg_latency_ms: float
    total_tokens: int
    thumbs_up: int
    thumbs_down: int


class StatsUsersOut(BaseModel):
    period_days: int
    total_users: int
    new_users: int
    active_users: int


# ── Chat logs ─────────────────────────────────────────────────────────────────

class ChatLogOut(BaseModel):
    id: UUID
    session_id: UUID
    role: str
    content: str
    intent: Optional[str]
    prompt_tokens: int
    completion_tokens: int
    latency_ms: Optional[int]
    feedback: Optional[int]
    created_at: Optional[datetime]

    model_config = {"from_attributes": True}


# ── Search (dùng trong search route) ─────────────────────────────────────────

class SearchHistoryOut(BaseModel):
    id: str
    keyword: str
    result_count: int
    created_at: Optional[datetime]

    model_config = {"from_attributes": True}


class SearchResultOut(BaseModel):
    query: str
    total: int
    destinations: list[dict]
    hotels: list[dict]
    tours: list[dict]


# ── RBAC ─────────────────────────────────────────────────────────────────────

class UserRoleUpdate(BaseModel):
    role: UserRole

    @field_validator("role")
    @classmethod
    def cannot_assign_super_admin_via_api(cls, v: UserRole) -> UserRole:
        if v == UserRole.SUPER_ADMIN:
            raise ValueError("Không thể gán role super_admin qua API")
        return v


# ── Aliases tương thích ngược ─────────────────────────────────────────────────
KnowledgeCreate = KnowledgeEntryCreate
KnowledgeUpdate = KnowledgeEntryUpdate
KnowledgeResponse = KnowledgeEntryOut
EmbeddingJobResponse = EmbeddingJobOut
UserAdminResponse = UserAdminOut
