# 🗺️ PDTrip AI — Project Roadmap

## Phase 1: Knowledge Base (Tasks T-001 → T-010, T-013)
> **Mục tiêu:** Tạo file JSON/MD cho 34 tỉnh/thành từ nguồn dữ liệu thực tế

```
T-001 ──► T-002 ──► T-007 ──► T-008
   │          │                   │
   │          └──► T-013 ─────────┤  (itineraries — cần T-002+T-003+T-004+T-005)
   ├──► T-003 ──────┘             │
   ├──► T-004 ──────┘             │
   ├──► T-005 ──────┘             │
   ├──► T-006                     │
   └──► T-009 ──────────────────► T-010 ──► T-011 ──► T-012
```

### Dependency order

| Bước | Tasks |
|---|---|
| 1 | T-001 (nền tảng — phải xong trước) |
| 2 | T-002, T-003, T-004, T-005, T-006, T-009 (parallel) |
| 3 | T-007, T-008 (cần T-002 + T-004 + T-005) |
| 4 | T-013 (cần T-002 + T-003 + T-004 + T-005 — **core feature, không để cuối**) |
| 5 | T-010 (validation — chạy cuối phase 1) |

> ⚠️ T-013 (`itineraries.json`) là 1 trong 3 chức năng AI cốt lõi — xem RULE-11.

## Phase 2: Integration (Tasks T-011 → T-012)
> **Mục tiêu:** Kết nối knowledge-base/ vào RAG pipeline

```
T-010 DONE ──► T-011 (import script) ──► T-012 (update RAG, flag KNOWLEDGE_SOURCE)
```

## Phase 3: Enhancement (Tương lai — sau khi Phase 1 + 2 hoàn thành)

- T-017: Bộ câu hỏi eval cố định ≥20 câu + script đo retrieval accuracy (xem RULE-13)

---

## 📊 Progress Tracker

| Task | Mô tả | Status | Ngày xong |
|---|---|---|---|
| T-001 | `city.json` cho 34 tỉnh/thành | 🔄 IN_PROGRESS (10/34 xong) | — |
| T-002 | `destinations.json` | ⬜ TODO | — |
| T-003 | `hotels.json` | ⬜ TODO | — |
| T-004 | `restaurants.json` + `foods.json` | ⬜ TODO | — |
| T-005 | `transport.json` + `tours.json` | ⬜ TODO | — |
| T-006 | `events.json` + `shopping.json` | ⬜ TODO | — |
| T-007 | `faq.md` | ⬜ TODO | — |
| T-008 | `experiences.md` | ⬜ TODO | — |
| T-009 | `_global/` files | ⬜ TODO | — |
| T-010 | Validate toàn bộ JSON schema | ⬜ TODO | — |
| T-011 | Import knowledge-base → Qdrant | ⬜ TODO | — |
| T-012 | Update RAG pipeline | ⬜ TODO | — |
| T-013 | `itineraries.json` ⭐ | ⬜ TODO | — |
| T-014 | Hoàn thiện `city.json` cho 24 tỉnh còn lại | ⬜ TODO | — |
| T-015 | `faq.md` + `experiences.md` cho 34 tỉnh | ⬜ TODO | — |
| T-016 | Fix T-014 — folder/slug còn thiếu | ✅ DONE | 2026-06-22 |

**Tổng:** 1/16 tasks hoàn thành (T-001 đang dở — 10/34 tỉnh)

---

## 🔑 Đã có sẵn

- ✅ Danh sách 34 tỉnh/thành + slug mapping đầy đủ (`city-slugs.json`)
- ✅ Schema JSON/MD đã định nghĩa (`schemas/SCHEMAS.md`)
- ✅ Example files cho Đà Lạt (`city.json`, `faq.md`, `experiences.md`)
- ✅ Agent rules + task breakdown
- ✅ Danh sách nguồn dữ liệu thực tế (`context/sql-table-mapping.md`)
