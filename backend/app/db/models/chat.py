from sqlalchemy import Column, String, Text, Integer, TIMESTAMP, Boolean, ForeignKey, JSON
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.db.database import Base

class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    title = Column(String(300))
    summary = Column(Text)
    model_name = Column(String(100), default="gemini-1.5-flash")
    total_messages = Column(Integer, default=0)
    total_tokens = Column(Integer, default=0)
    pinned = Column(Boolean, default=False)
    is_deleted = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))

    messages = relationship("ChatMessage", back_populates="session")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = Column(UUID(as_uuid=True), ForeignKey("chat_sessions.id", ondelete="CASCADE"))
    role = Column(String(20))
    content = Column(Text, nullable=False)
    sources = Column(JSON, default=[])
    intent = Column(String(100))
    prompt_tokens = Column(Integer, default=0)
    completion_tokens = Column(Integer, default=0)
    latency_ms = Column(Integer)
    feedback = Column(Integer)  # -1 hoặc 1
    created_at = Column(TIMESTAMP(timezone=True))

    session = relationship("ChatSession", back_populates="messages")
