# Task T-011 — Script import Knowledge Base → Qdrant

| Trường | Giá trị |
|---|---|
| **Task ID** | T-011 |
| **Status** | ⬜ TODO |
| **Priority** | 🔴 HIGH — production integration |
| **Depends on** | T-010 DONE |
| **Estimated** | ~2 giờ |

---

## 🎯 Mục tiêu

Viết script Python để đọc toàn bộ files trong `knowledge-base/` và import vào Qdrant thay thế cho cơ chế seed từ SQL.

## 📂 Output

```
backend/scripts/import_knowledge_base.py
```

## 🔢 Logic script

```python
"""
import_knowledge_base.py
Đọc knowledge-base/ → chunk → embed (BGE-M3) → upsert vào Qdrant

Run: python backend/scripts/import_knowledge_base.py --env .env
"""

import json, os, glob
from pathlib import Path
# ... (agent viết full implementation)
```

### Chunking strategy

| File type | Chunk strategy |
|---|---|
| `city.json` | 1 chunk per city (summary) |
| `destinations.json` | 1 chunk per destination item |
| `hotels.json` | 1 chunk per hotel |
| `foods.json` | Gom 3 món / chunk |
| `faq.md` | 1 chunk per Q&A pair |
| `experiences.md` | 1 chunk per section (H2) |
| `transport.json` | 1 chunk per city (gom getting_there + getting_around) |

### Qdrant payload structure

```json
{
  "city": "lam-dong-da-lat",
  "city_name": "Đà Lạt",
  "source_file": "knowledge-base/lam-dong-da-lat/destinations.json",
  "item_name": "Hồ Xuân Hương",
  "category": "attraction",
  "content": "...",
  "tags": ["đà lạt", "hồ", "tham quan"]
}
```

## ✅ Checklist

- [ ] Script đọc được tất cả file types
- [ ] Có dry-run mode (`--dry-run`) không ghi vào Qdrant
- [ ] Có progress bar
- [ ] Log số chunks đã upsert
- [ ] Xử lý được partial files (status=partial)
- [ ] Idempotent — chạy lại không tạo duplicate
- [ ] Dùng **collection Qdrant riêng** cho knowledge-base files (ví dụ `QDRANT_COLLECTION_KB_FILES`), **không** ghi đè/lẫn vào collection cũ đang nhận data từ `embedding_jobs` (PostgreSQL). Lý do: tách collection giúp T-012 so sánh / rollback an toàn giữa 2 nguồn, và tránh 1 nguồn xấu (lỗi parse SQL) làm hỏng nguồn kia.

## ⚠️ Lưu ý quan trọng

`knowledge-base/` là nguồn dữ liệu **song song**, hoàn toàn tách biệt với pipeline RAG production hiện tại (`rag_pipeline.py` đang đọc từ bảng `KnowledgeEntry` trong PostgreSQL → embed → Qdrant, xem `app/services/knowledge.py` + `app/services/rag_pipeline.py`). Script T-011 **không** được tự động xoá hay ghi đè dữ liệu/collection hiện có của hệ thống cũ. T-012 mới là nơi quyết định cách 2 nguồn này phối hợp.

---

### Partial note
```
Đã xong:
Còn lại:
```
