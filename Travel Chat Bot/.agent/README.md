# 🤖 PDTrip AI — Agent Workspace

> **Vai trò:** Folder này là "não bộ" của toàn bộ hệ thống agent.  
> Mọi agent (Claude, Cursor, Copilot...) đều đọc file này **đầu tiên** trước khi làm bất kỳ task nào.

---

## 📌 Dự án là gì?

**PDTrip AI** — Chatbot tư vấn du lịch Việt Nam tích hợp RAG (Retrieval-Augmented Generation).

| Layer | Tech |
|---|---|
| Backend | FastAPI + PostgreSQL + Qdrant (vector DB) + Redis |
| AI | Gemini + BGE-M3 embedding + Hybrid Search |
| Frontend | Flutter (mobile + web) |
| Knowledge Base | File JSON/MD → Qdrant vectors |

> ⚠️ **Nguồn dữ liệu:** SQL seed files (`backend/initdb/*.sql`) là dữ liệu AI sinh tự động,
> **không đáng tin cậy**. Nguồn duy nhất hợp lệ là tra cứu từ internet theo danh sách tại
> `.agent/context/sql-table-mapping.md`.

---

## 🗂️ Cấu trúc Knowledge Base

```
knowledge-base/
├── _global/
│   ├── categories.json         # 10 loại hình du lịch
│   └── vietnam-overview.md     # Tổng quan 3 miền
│
├── lam-dong-da-lat/            # ✅ EXAMPLE đã có
│   ├── city.json
│   ├── destinations.json
│   ├── hotels.json
│   ├── restaurants.json
│   ├── foods.json
│   ├── transport.json
│   ├── tours.json
│   ├── tickets.json
│   ├── events.json
│   ├── shopping.json
│   ├── itineraries.json        # ⭐ core feature
│   ├── faq.md
│   └── experiences.md
│
├── an-giang-phu-quoc/          (cấu trúc giống trên)
├── tuyen-quang-ha-giang/
├── da-nang-hoi-an/
├── lao-cai-sa-pa/
├── quang-ninh-ha-long/
├── hue/
├── khanh-hoa-nha-trang/
├── lam-dong-mui-ne/
├── ninh-binh/
└── ... (24 tỉnh/thành còn lại — xem city-slugs.json)
```

**Phạm vi:** Đủ 34 tỉnh/thành theo phân chia hành chính mới (Nghị quyết 202/2025/QH15).
Danh sách đầy đủ slug → `.agent/context/city-slugs.json`.

---

## 📋 Danh sách Tasks

| ID | Task | Status | File |
|---|---|---|---|
| T-001 | Tách `city.json` cho 34 tỉnh/thành | ✅ DONE (10/34) | tasks/T-001-city-json.md |
| T-002 | Tách `destinations.json` | ⬜ TODO | tasks/T-002-destinations-json.md |
| T-003 | Tách `hotels.json` | ⬜ TODO | tasks/T-003-hotels-json.md |
| T-004 | Tách `restaurants.json` + `foods.json` | ⬜ TODO | tasks/T-004-food-json.md |
| T-005 | Tách `transport.json` + `tours.json` | ⬜ TODO | tasks/T-005-transport-tours-json.md |
| T-006 | Tách `events.json` + `shopping.json` | ⬜ TODO | tasks/T-006-events-shopping-json.md |
| T-007 | Viết `faq.md` | ⬜ TODO | tasks/T-007-faq-md.md |
| T-008 | Viết `experiences.md` | ⬜ TODO | tasks/T-008-experiences-md.md |
| T-009 | Tạo `_global/` files | ⬜ TODO | tasks/T-009-global-files.md |
| T-010 | Validate toàn bộ JSON schema | ⬜ TODO | tasks/T-010-validate.md |
| T-011 | Script import knowledge-base → Qdrant | ⬜ TODO | tasks/T-011-qdrant-import.md |
| T-012 | Update RAG pipeline đọc từ file | ⬜ TODO | tasks/T-012-rag-update.md |
| T-013 | Tạo `itineraries.json` ⭐ core feature | ⬜ TODO | tasks/T-013-itineraries-json.md |
| T-014 | Hoàn thiện `city.json` cho 24 tỉnh còn lại | ⬜ TODO | tasks/T-014-expand-34-provinces.md |
| T-015 | `faq.md` + `experiences.md` cho 34 tỉnh | ⬜ TODO | tasks/T-015-faq-experiences-34-provinces.md |
| T-016 | Fix T-014 — folder/slug còn thiếu | ✅ DONE | tasks/T-016-fix-t014-missing-folders.md |

---

## ⚡ Nguyên tắc quan trọng cho Agent

1. **Mỗi task = 1 file MD riêng** — đọc file task trước khi làm
2. **Cập nhật STATUS** khi bắt đầu (`🔄 IN PROGRESS`) và xong (`✅ DONE`)
3. **Không sửa file đã DONE** — tạo task mới nếu cần sửa
4. **Hết token không sao** — mỗi task độc lập, resume từ STATUS file
5. **Đọc schema** tại `.agent/schemas/SCHEMAS.md` trước khi tạo JSON
6. **Không dùng SQL seed** — tra cứu từ nguồn thực tế (xem `.agent/context/sql-table-mapping.md`)

---

## 🔗 Context nhanh

- **34 tỉnh/thành sau sáp nhập — bắt buộc đọc trước khi sinh slug/province:**
  `.agent/context/provinces-34.md`
- **Slug + UUID mapping đầy đủ 34 tỉnh:** `.agent/context/city-slugs.json`
- **Nguồn dữ liệu hợp lệ:** `.agent/context/sql-table-mapping.md`
