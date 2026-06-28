# TA-019 · System Configuration (Super Admin Only)
> **Phase:** P4  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-002 DONE (audit log)  |  **Estimated:** 3–4 giờ

## Backend

```bash
alembic revision --autogenerate -m "add_system_configs_table"
```

```sql
CREATE TABLE system_configs (
    key         VARCHAR(100) PRIMARY KEY,
    value       JSONB NOT NULL,
    description TEXT,
    updated_by  UUID REFERENCES users(id),
    updated_at  TIMESTAMPTZ DEFAULT now()
);

INSERT INTO system_configs VALUES
('chatbot_enabled',     'true',  'Bật/tắt toàn bộ chatbot endpoint'),
('gemini_temperature',  '0.7',   'Temperature Gemini (0.0-1.0)'),
('rag_top_k_default',   '5',     'Số chunks mặc định mỗi query'),
('use_reranking',       'true',  'Bật/tắt cross-encoder rerank'),
('fallback_to_llm',     'false', '⚠️ Cho phép Gemini trả lời khi không có context');
```

```python
GET   /admin/system-config        # ADMIN+ read
PATCH /admin/system-config/{key}  # SUPER_ADMIN only
# Bắt buộc: audit log with before/after value
```

**Trong chat endpoint:** Đọc `chatbot_enabled` từ DB. Nếu False → trả 503 maintenance.

## Frontend

**Layout card theo nhóm:**

- **Nhóm Chatbot:** `chatbot_enabled` (toggle, label "Bật/Tắt chatbot") · `fallback_to_llm` (toggle đỏ + warning "Nguy cơ hallucination")
- **Nhóm RAG:** `gemini_temperature` (slider 0-1) · `rag_top_k_default` (number input) · `use_reranking` (toggle)

**Trước khi lưu:** `<AlertDialog>` confirm "Thay đổi cấu hình hệ thống ảnh hưởng toàn bộ chatbot. Tiếp tục?"

ADMIN thấy trang read-only (không có nút Lưu). MODERATOR/CONTENT_MANAGER không thấy menu này.

## Checklist DONE
- [ ] Migration + seed 5 config keys
- [ ] SUPER_ADMIN only có thể PATCH
- [ ] chatbot_enabled=false → chat endpoint trả 503
- [ ] Audit log before/after cho mọi thay đổi
- [ ] Confirm dialog trước khi lưu

```
completed_at:
```
