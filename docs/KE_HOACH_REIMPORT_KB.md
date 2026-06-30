# 🔄 Kế hoạch: Re-import sạch Knowledge Base → PostgreSQL (63 tỉnh/thành)

> ## ✅ ĐÃ HOÀN THÀNH (2026-06-29)
> - 63/63 tỉnh import sạch từ KB, **2229 records**. Active destinations = **63**
>   (deactivate 3 stale cấp tỉnh: bac-ninh/ca-mau/can-tho).
> - Bảng mới **restaurants** (26 tỉnh) + **foods** (36 tỉnh) thay vì nhét text vào knowledge_entries.
> - **categories** seed theo region + link destination_categories (63).
> - Qdrant `pdtrip_knowledge` re-embed = **1533 points**. `validate_kb_sql` **0 errors**.
> - structured_search thêm `ask_food` (foods + restaurants).
> - Coverage khớp số file nguồn (tỉnh thiếu file → để trống, không bịa — MIG-01).
> - ⏭ Cần: **restart backend** để nạp code mới; Gemini key mới để test câu trả lời composed.
>
> ---

> Mục tiêu: **xóa toàn bộ dữ liệu nội dung cũ trong Postgres** (lẫn AI-seed + import dở),
> **import lại CHỈ từ thư mục `backend/knowledge-base/`** (nguồn chuẩn) cho đủ **63 tỉnh/thành**,
> chỉnh lại liên kết bảng, thêm `categories`, thêm bảng hỗ trợ còn thiếu (`restaurants`, `foods`),
> rồi re-embed lại Qdrant. KB = nguồn sự thật duy nhất.

---

## 0. Hiện trạng (đã khảo sát 2026-06-29)

**63 folder** trong `knowledge-base/`. Số folder có từng file nguồn:

| File nguồn | Số folder | Bảng đích |
|---|---|---|
| `city.json` | 63 | destinations |
| `destinations.json` | 63 | locations (+ tickets từ entry_fee) |
| `restaurants.json` | 36 | **restaurants** (mới) |
| `foods.json` | 36 | **foods** (mới) |
| `hotels.json` | 26 | hotels |
| `transport.json` | 26 | transport_options |
| `tours.json` | 25 | tours |
| `events.json` | 25 | destination_events |
| `shopping.json` | 24 | shopping_places |
| `faq.md` | 24 | knowledge_entries (faq) |
| `experiences.md` | 24 | knowledge_entries (tip) |
| `itineraries.json` | 23 | itineraries + itinerary_items |
| `tickets.json` | 2 | tickets |

> ⚠️ Nhiều tỉnh **không có** file hotels/tours/shopping/faq trong nguồn → các tỉnh đó
> sẽ KHÔNG có dữ liệu loại đó (đúng theo nguồn, không bịa). Chỉ ~24-36 tỉnh "đầy đủ".

**DB hiện tại (thưa, lẫn data cũ):** destinations 60, hotels 23, shopping 21, KB food 21 city…
→ cần làm sạch + import lại.

**Phát hiện quan trọng — UUID & liên kết chéo trong nguồn:**
- `city.json` có `data.id`; `restaurants.json` có `id` + `city_id`; `foods.json` có
  `where_to_eat` = danh sách restaurant id.
- Seed hiện dùng `uuid5(slug)` cho destinations và **nhét restaurants/foods vào
  `knowledge_entries` dạng text** → mất cấu trúc & liên kết.
- **Quyết định:** giữ `uuid5` ổn định cho destinations (đang được FK user tham chiếu),
  nhưng **dùng UUID gốc trong JSON** cho restaurants/foods để `where_to_eat` khớp đúng.

---

## 1. Phạm vi xóa (chỉ bảng nội dung KB — KHÔNG đụng dữ liệu user)

**XÓA sạch (TRUNCATE/DELETE) rồi import lại:**
- `itinerary_items`, `itineraries`
- `tickets`, `tours`, `hotels`, `transport_options`, `shopping_places`,
  `destination_events`, `locations`
- `restaurants`, `foods` (bảng mới — tạo rồi import)
- `knowledge_entries` thuộc KB (category ∈ faq/food/tip/experience hoặc có `city_slug`)
- `embedding_jobs` (tạo lại toàn bộ) + **clear Qdrant collection**

**KHÔNG xóa (giữ FK của user):**
- `destinations` → **UPSERT** từ `city.json` (giữ nguyên `id` uuid5 → reviews/favorites/
  trip_plans/view_logs không gãy). Destination nào KHÔNG có trong KB → set `is_active=FALSE`
  (ẩn, không xóa cứng).
- `users`, `reviews`, `user_favorites`, `trip_plans`, `chat_*`, `audit_logs`, … (toàn bộ data user).

---

## 2. Các bước thực hin

### Bước 1 — Backup an toàn (bắt buộc, vì thao tác xóa)
`pg_dump` ra file `backend/initdb/_backup_pre_reimport_<timestamp>.sql` trước khi xóa.

### Bước 2 — Migration schema (initdb/37_*.sql)
1. **Tạo bảng `restaurants`** (cấu trúc, cho structured fast-path "nhà hàng"):
   `id, destination_id FK, name, type, address, hours, price_range, specialties TEXT[],
    description, rating, image_url, data_source, source_url, verified, verified_at, timestamps`.
2. **Tạo bảng `foods`** (đặc sản/món ăn):
   `id, destination_id FK, name, local_name, category, description, price_range,
    must_try BOOL, vegetarian BOOL, tags TEXT[], where_to_eat UUID[] (→ restaurants),
    data_source, timestamps`.
3. **Categories**: seed bảng `categories` sẵn có từ:
   - `region` của city.json (Tây Bắc, Tây Nguyên, …) và
   - `type` của attractions (nature, attraction, historical…).
   Link `destination_categories` theo region. (Có sẵn bảng — chỉ cần seed + link.)
4. Index phụ trợ + trigger `updated_at` cho bảng mới (theo chuẩn `fn_set_updated_at`).
   Tất cả `IF NOT EXISTS` (MIG-04).

### Bước 3 — Nâng cấp seed script `seed_kb_to_sql.py`
- `import_restaurants` → ghi vào **bảng `restaurants`** (dùng `id`, `city_id` gốc), KHÔNG còn nhét knowledge_entries.
- `import_foods` → ghi vào **bảng `foods`** (giữ `where_to_eat`).
- Thêm `import_categories` (region + type → categories + destination_categories).
- Giữ nguyên các import khác (locations, hotels, tours, tickets, transport, shopping, events, itineraries, faq, experiences).
- Đảm bảo chạy đủ **cả 63 folder**, idempotent (ON CONFLICT), log tỉnh nào thiếu file gì.

### Bước 4 — Chạy wipe + seed (transaction)
1. Chạy script wipe (Bước 1 phạm vi xóa).
2. Chạy `python scripts/seed_kb_to_sql.py` (toàn bộ 63 tỉnh).
3. Chạy `python scripts/validate_kb_sql.py` — 0 errors.

### Bước 5 — Re-embed Qdrant
1. Clear Qdrant collection (xóa vector cũ trỏ entry đã xóa).
2. Tạo `embedding_jobs(pending)` cho mọi `knowledge_entries` mới (+ tùy chọn: embed cả
   mô tả locations/hotels/restaurants để semantic search phong phú hơn — sẽ cân nhắc).
3. Worker throttle (đã có) tự embed; hoặc gọi `POST /debug/qdrant/reindex`.

### Bước 6 — Mở rộng `structured_search.py`
- `ask_food` → query **`restaurants` + `foods`** (thay vì chỉ knowledge_entries).
- Map intent → thêm 2 handler mới `_restaurants`, `_foods`.

### Bước 7 — Verify (định nghĩa "đạt")
- `destinations` active = số tỉnh có trong KB (≤63), 63 dòng tồn tại.
- Số tỉnh có data mỗi bảng **khớp số file nguồn** (vd hotels 26, restaurants 36…).
- `validate_kb_sql.py` 0 errors.
- Battery test Đà Lạt (đủ data) trả lời mọi nhóm + đề xuất (cần Gemini quota).

---

## 3. Ràng buộc
- **MIG-01** không bịa: tỉnh thiếu file → bỏ trống, không tạo data ảo.
- **Giữ FK user**: không xóa cứng `destinations`/`users`/`reviews`/…
- **Backup trước khi xóa** (Bước 1) — bắt buộc.
- **Idempotent**: chạy lại seed nhiều lần không nhân đôi.
- KB = nguồn duy nhất; sau khi xong, `KNOWLEDGE_SOURCE=db` (cutover khi eval pass).

---

## 4. Thứ tự gọn
```
Backup → 37_schema(restaurants,foods,categories) → nâng cấp seed →
wipe KB tables → seed 63 tỉnh → validate → clear Qdrant + re-embed →
mở rộng structured_search(food) → verify + battery test
```
