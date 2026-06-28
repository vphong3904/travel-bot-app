# TA-018 · Media Management
> **Phase:** P3  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-001 DONE  |  **Estimated:** 4 giờ

## Backend — Model + Routes

```bash
alembic revision --autogenerate -m "add_media_files_table"
```

```python
class MediaFile(Base):
    __tablename__ = "media_files"
    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    filename: Mapped[str] = mapped_column(String(255))
    original_name: Mapped[str | None] = mapped_column(String(255))
    file_path: Mapped[str] = mapped_column(Text)
    file_size: Mapped[int | None] = mapped_column(Integer)
    mime_type: Mapped[str | None] = mapped_column(String(100))
    width: Mapped[int | None] = mapped_column(Integer)
    height: Mapped[int | None] = mapped_column(Integer)
    tags: Mapped[list[str]] = mapped_column(ARRAY(Text), default=list, server_default="{}")
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)
    uploaded_by: Mapped[UUID | None] = mapped_column(ForeignKey("users.id"))
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
```

**Upload handler** (Pillow resize → WebP, max 5MB, chỉ jpg/png/webp):
```python
POST /admin/media/upload    # multipart/form-data
GET  /admin/media?tag=&page=
DELETE /admin/media/{id}    # soft delete
```

Serve ảnh qua `StaticFiles`: `app.mount("/uploads", StaticFiles(directory="static/uploads"))`.

Thêm vào `requirements.txt`: `pillow>=10.0.0`

## Frontend

**Grid 4 cột:** thumbnail 180×180, hover → overlay tên + nút xóa.

**Upload zone:** Drag & drop hoặc click chọn file. Progress bar khi upload.

**Click ảnh:** Dialog xem full size + metadata (size, upload bởi, ngày, dimensions).

## Checklist DONE
- [ ] Upload validate type + size
- [ ] Pillow resize về max 1920px, save WebP
- [ ] Grid gallery render
- [ ] Soft delete (không xóa file thật khỏi disk)

```
completed_at:
```
