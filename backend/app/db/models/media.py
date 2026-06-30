from sqlalchemy import Column, String, Text, Integer, TIMESTAMP, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.sql import func
import uuid
from app.db.database import Base


class MediaFolder(Base):
    """Thư mục trong trình quản lý ảnh (CMS). parent_id=NULL => thư mục gốc."""
    __tablename__ = "media_folders"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    parent_id = Column(
        UUID(as_uuid=True),
        ForeignKey("media_folders.id", ondelete="CASCADE"),
        nullable=True,
    )
    created_by = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"))
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class MediaFile(Base):
    """Ảnh đã upload. folder_id gắn ảnh vào 1 thư mục (NULL = chưa phân loại)."""
    __tablename__ = "media_files"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    filename = Column(String(255), nullable=False)
    original_name = Column(String(255))
    file_path = Column(Text, nullable=False)
    file_size = Column(Integer)
    mime_type = Column(String(100))
    width = Column(Integer)
    height = Column(Integer)
    tags = Column(ARRAY(Text), default=list)
    is_deleted = Column(Boolean, default=False)
    folder_id = Column(
        UUID(as_uuid=True),
        ForeignKey("media_folders.id", ondelete="SET NULL"),
        nullable=True,
    )
    uploaded_by = Column(UUID(as_uuid=True), ForeignKey("users.id"))
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
