from sqlalchemy import Column, DateTime, String, Text, Integer, TIMESTAMP, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
import uuid
from app.db.database import Base


class KnowledgeEntry(Base):
    __tablename__ = "knowledge_entries"
 
    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True)
    title: Mapped[str] = mapped_column(String(300), nullable=False)
    category: Mapped[str] = mapped_column(String(50), nullable=False)
    destination_id: Mapped[str | None] = mapped_column(
        UUID(as_uuid=False), ForeignKey("destinations.id", ondelete="SET NULL")
    )
    content: Mapped[str] = mapped_column(Text, nullable=False)
    tags: Mapped[list | None] = mapped_column(ARRAY(String), default=list)
    source: Mapped[str | None] = mapped_column(String(100))
    qdrant_id: Mapped[str | None] = mapped_column(UUID(as_uuid=False))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
 
 
class EmbeddingJob(Base):
    __tablename__ = "embedding_jobs"
 
    id: Mapped[str] = mapped_column(UUID(as_uuid=False), primary_key=True)
    entity_type: Mapped[str] = mapped_column(String(50), default="knowledge_entry")
    entity_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="pending")
    error: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class SearchHistory(Base):
    __tablename__ = "search_history"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    keyword = Column(String(300), nullable=False)
    result_count = Column(Integer, default=0)
    created_at = Column(TIMESTAMP(timezone=True))


class UserBehavior(Base):
    __tablename__ = "user_behavior"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    event_type = Column(String(100))    # "view_destination", "search", ...
    entity_type = Column(String(50))    # "destination", "hotel", ...
    entity_id = Column(UUID(as_uuid=True))
    created_at = Column(TIMESTAMP(timezone=True))
