# Task T-009 — Tạo `_global/` files

| Trường | Giá trị |
|---|---|
| **Task ID** | T-009 |
| **Status** | ⬜ TODO |
| **Priority** | 🟡 MEDIUM |
| **Depends on** | T-001 |
| **Estimated** | ~20 phút |

## 🎯 Mục tiêu

Tạo các file global dùng chung cho toàn bộ chatbot:

### `_global/categories.json`
Từ bảng `categories` — 10 loại hình du lịch:
```json
{
  "_meta": { "task": "T-009", "data_sources": ["vietnamtourism.gov.vn"] },
  "data": [
    { "id": "...", "name": "Beach", "slug": "beach", "icon": "beach_access", "description": "..." }
  ]
}
```

### `_global/vietnam-overview.md`
Tổng quan 3 miền từ `knowledge_entries` WHERE `destination_id IS NULL`:
- Câu hỏi tổng quan về Việt Nam
- So sánh 3 miền
- Gợi ý theo mùa / loại hình du lịch

## ✅ Checklist

- [ ] `_global/categories.json` với đủ 10 categories
- [ ] `_global/vietnam-overview.md` với ít nhất 500 chữ
- [ ] File overview có frontmatter YAML

---

### Partial note
```
Đã xong:
Còn lại:
```
