# TA-010 · DB Migration — RAG Metrics Columns
> **Phase:** P2  |  **Nhãn:** [BE]  |  **Status:** ⬜ TODO  
> **Dependency:** P1 ≥ 3/5 tasks DONE  |  **Estimated:** 1 giờ

## Mục tiêu
Thêm 6 cột vào `chat_messages` để lưu RAG metrics đã tính trong pipeline.

## Làm gì

### 1 — Sửa Model

```python
# backend/app/db/models/chat.py — thêm vào class ChatMessage
confidence_score: Mapped[float | None]  = mapped_column(Float,       nullable=True)
search_method:   Mapped[str | None]     = mapped_column(String(20),  nullable=True)
search_ms:       Mapped[int | None]     = mapped_column(Integer,     nullable=True)
llm_ms:          Mapped[int | None]     = mapped_column(Integer,     nullable=True)
cache_hit:       Mapped[str | None]     = mapped_column(String(10),  nullable=True)
chunk_count:     Mapped[int | None]     = mapped_column(Integer,     nullable=True)
```

### 2 — Tạo Migration

```bash
cd backend
alembic revision --autogenerate -m "add_rag_metrics_to_chat_messages"
# Review file sinh ra: phải là ADD COLUMN, không DROP gì
alembic upgrade head
```

## Checklist DONE
- [ ] 6 cột nullable xuất hiện trong DB
- [ ] Query ChatMessage hiện tại không bị lỗi
- [ ] Migration file đã commit

```
migration_file:
completed_at:
```
