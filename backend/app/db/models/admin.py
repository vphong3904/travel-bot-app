from sqlalchemy import Column, String, Text, Integer, TIMESTAMP, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, ARRAY
import uuid
from app.db.database import Base


class KnowledgeEntry(Base):
    __tablename__ = "knowledge_entries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(300), nullable=False)
    category = Column(String(100))
    destination_id = Column(
        UUID(as_uuid=True),
        ForeignKey("destinations.id", ondelete="SET NULL"),
        nullable=True,
    )
    content = Column(Text, nullable=False)
    tags = Column(ARRAY(Text), default=[])
    source = Column(String(300))
    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))


class EmbeddingJob(Base):
    __tablename__ = "embedding_jobs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entity_type = Column(String(50), nullable=False)   # "knowledge_entry"
    entity_id = Column(UUID(as_uuid=True), nullable=False)
    status = Column(String(20), default="pending")     # pending / processing / done / failed
    error = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))


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
