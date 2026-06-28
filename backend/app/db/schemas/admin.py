# app/db/schemas/admin.py
from datetime import datetime
from typing import Any, Optional
from pydantic import BaseModel


class KnowledgeEntryCreate(BaseModel):
    title: str
    category: str
    content: str
    tags: list[str] = []
    source: Optional[str] = None
    destination_id: Optional[str] = None


class KnowledgeEntryUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    content: Optional[str] = None
    tags: Optional[list[str]] = None
    source: Optional[str] = None
    is_active: Optional[bool] = None


class KnowledgeEntryOut(BaseModel):
    id: str
    title: str
    category: str
    content: str
    tags: Optional[list[str]] = []
    source: Optional[str] = None
    is_active: bool
    qdrant_id: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class EmbeddingJobOut(BaseModel):
    id: str
    entity_type: str
    entity_id: str
    status: str
    error: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class UserAdminOut(BaseModel):
    id: str
    username: str
    email: str
    full_name: Optional[str] = None
    role: str
    is_active: bool
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


class UserAdminUpdate(BaseModel):
    role: Optional[str] = None
    is_active: Optional[bool] = None


class StatsQuestionsOut(BaseModel):
    total: int
    unanswered: int
    flagged: int


class StatsDestinationsOut(BaseModel):
    total: int
    popular: list[dict] = []


class StatsChatbotOut(BaseModel):
    total_sessions: int
    total_messages: int
    avg_confidence: float = 0.0


class StatsUsersOut(BaseModel):
    total: int
    new_this_month: int
    active: int


class ChatLogOut(BaseModel):
    session_id: str
    user_id: str
    messages: list[dict] = []
    created_at: Optional[datetime] = None


class SearchHistoryOut(BaseModel):
    id: str
    query: str
    results_count: int
    created_at: Optional[datetime] = None


class SearchResultOut(BaseModel):
    query: str
    results: list[dict] = []
    total: int = 0
