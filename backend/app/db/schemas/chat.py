from pydantic import BaseModel, Field
from uuid import UUID
from datetime import datetime
from typing import Optional, Any


# ── Session ───────────────────────────────────────────────────────────────────

class ChatSessionCreate(BaseModel):
    title: Optional[str] = None
    model_name: Optional[str] = None


class ChatSessionUpdate(BaseModel):
    title: Optional[str] = None
    pinned: Optional[bool] = None


class ChatSessionOut(BaseModel):
    id: UUID
    user_id: UUID
    title: Optional[str]
    model_name: str
    total_messages: int
    total_tokens: int
    pinned: bool
    created_at: datetime
    updated_at: Optional[datetime]

    model_config = {"from_attributes": True}


# List view (rút gọn, không cần summary)
ChatSessionListOut = ChatSessionOut

# Aliases tương thích ngược
SessionCreate = ChatSessionCreate
SessionUpdate = ChatSessionUpdate
SessionResponse = ChatSessionOut


# ── Message ───────────────────────────────────────────────────────────────────

class ChatMessageCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=4000)


class ChatMessageOut(BaseModel):
    id: UUID
    session_id: UUID
    role: str
    content: str
    sources: Optional[list[dict[str, Any]]] = []
    intent: Optional[str]
    prompt_tokens: int
    completion_tokens: int
    latency_ms: Optional[int]
    feedback: Optional[int]
    created_at: Optional[datetime]

    model_config = {"from_attributes": True}


class FeedbackUpdate(BaseModel):
    feedback: int = Field(..., ge=-1, le=1)


# Aliases tương thích ngược
MessageCreate = ChatMessageCreate
MessageResponse = ChatMessageOut
FeedbackRequest = FeedbackUpdate
