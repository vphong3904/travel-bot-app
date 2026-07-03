from sqlalchemy import Column, String, Text, Integer, TIMESTAMP, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, ARRAY, JSONB
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


class ContentItem(Base):
    """
    CMS content cho Admin (khách sạn, điểm đến, tour, ẩm thực...). Tách khỏi
    knowledge_entries: mỗi loại lưu chung 1 bảng, phân biệt bằng content_type;
    dữ liệu động lưu trong `data` (JSONB). `image_url` lưu link ảnh chọn từ Media.
    status draft|published — mobile chỉ đọc published qua API public /content/{type}.
    """
    __tablename__ = "content_items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_type = Column(String(50), nullable=False, index=True)
    city_slug = Column(String(120), index=True)
    name = Column(String(300), nullable=False)
    data = Column(JSONB, default=dict)
    image_url = Column(Text)
    status = Column(String(20), default="draft")   # draft | published
    is_deleted = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())


class ContentOption(Base):
    """Taxonomy: danh sách "loại" theo content_type + field, admin quản lý.
    Form content đọc options động từ đây thay cho hardcode. Xem 04_schema_media.sql."""
    __tablename__ = "content_options"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    content_type = Column(String(50), nullable=False)
    field = Column(String(50), nullable=False)
    code = Column(String(100), nullable=False)
    label = Column(String(200), nullable=False)
    sort_order = Column(Integer, default=0)
    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())
    updated_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), onupdate=func.now())
