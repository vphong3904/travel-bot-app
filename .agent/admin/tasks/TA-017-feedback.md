# TA-017 · Feedback Management
> **Phase:** P3  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-001 DONE  |  **Estimated:** 3–4 giờ

## Backend — Migration + Routes

```bash
alembic revision --autogenerate -m "add_feedback_fields_to_chat_messages"
```

```python
# Thêm vào ChatMessage model
feedback_reason:   Mapped[str | None] = mapped_column(Text,        nullable=True)
feedback_category: Mapped[str | None] = mapped_column(String(50),  nullable=True)
# wrong_info|irrelevant|too_long|hallucination|rude|other
feedback_resolved:    Mapped[bool | None] = mapped_column(Boolean, nullable=True)
feedback_resolved_by: Mapped[UUID | None] = mapped_column(ForeignKey("users.id"), nullable=True)
```

**Routes:**
```python
GET   /admin/feedback?type=positive|negative&category=&intent=&page=
PATCH /admin/feedback/{message_id}/resolve
GET   /admin/stats/feedback   # tỉ lệ 👍/👎 theo ngày
```

## Frontend

**Tabs:** Tất cả | 👍 | 👎 | Chờ xử lý

**Bảng:** Câu trả lời (preview 60 ký tự) | Feedback | Category | Intent | Action [Đã xử lý]

**Stats mini:** 2 donut charts (👍/👎 breakdown + Category breakdown) ở trên bảng.

## Checklist DONE
- [ ] Migration
- [ ] Filter type/category/intent hoạt động
- [ ] Mark resolved + audit log
- [ ] Stats mini charts

```
completed_at:
```
