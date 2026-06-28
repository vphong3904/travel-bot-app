from sqlalchemy import DateTime, String, Text, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
import uuid
from app.db.database import Base


class KnowledgeEntry(Base):
    __tablename__ = "knowledge_entries"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),   # ✅ FIX: auto-gen UUID khi tạo mới
    )
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
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )


class EmbeddingJob(Base):
    __tablename__ = "embedding_jobs"

    id: Mapped[str] = mapped_column(
        UUID(as_uuid=False),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),   # ✅ FIX: auto-gen UUID
    )
    entity_type: Mapped[str] = mapped_column(String(50), default="knowledge_entry")
    entity_id: Mapped[str] = mapped_column(UUID(as_uuid=False), nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="pending")
    error: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

# ✅ SearchHistory & UserBehavior đã chuyển sang MongoDB (app/services/log_service.py)
# — xem app/db/mongo.py để biết collection tương ứng.
