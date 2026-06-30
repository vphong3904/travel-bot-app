# MIGRATION — JSON & Markdown → SQL (quản lý bằng Web Admin)

> Mục tiêu: chuyển **toàn bộ** dữ liệu knowledge-base hiện đang nằm ở file (`backend/knowledge-base/<tỉnh>/*.json` + `*.md`) và các file cấu hình (`backend/app/data/*.json`) **vào PostgreSQL**, để Web Admin CRUD quản lý trực tiếp, và RAG đọc từ SQL (`KNOWLEDGE_SOURCE=db`). Sau cùng: file KB chỉ còn là bản sao lưu/đầu vào, không phải nguồn vận hành.
> Khớp convention `.agent/` của dự án. Đọc kèm `.agent/rules/AGENT_RULES_SQL_MIGRATION.md` và `.agent/ROADMAP_V2.md`.

---

## 1. Hiện trạng (đã rà soát code)

### 1.1. Dữ liệu nguồn (file)

Mỗi thư mục tỉnh `backend/knowledge-base/<tỉnh>/` có:

| File | Nội dung | Đã vào SQL chưa? |
|---|---|---|
| `city.json` | Tổng quan tỉnh/thành | ✅ (→ `destinations` qua `seed_kb_to_sql.py`) |
| `hotels.json` | Khách sạn | ✅ (→ `hotels`) |
| `foods.json` | Đặc sản | ✅ (→ `knowledge_entries` category food) |
| `restaurants.json` | Quán ăn | ✅ (→ `knowledge_entries`) |
| `events.json` | Lễ hội | ✅ (→ `destination_events`) |
| `shopping.json` | Mua sắm | ✅ (→ `shopping_places`) |
| `transport.json` | Di chuyển | ✅ (→ `transport_options`) |
| `destinations.json` | **Địa điểm tham quan trong tỉnh** | ❌ CHƯA đổ — ✅ **bảng `locations` ĐÃ CÓ** (đúng mục đích) |
| `tours.json` | Tour | ❌ CHƯA đổ từ KB — ✅ **bảng `tours` ĐÃ CÓ** (đang dùng seed AI rời `22_seed_...sql`) |
| (tickets) | Vé tham quan | ❌ CHƯA đổ từ KB — ✅ **bảng `tickets` ĐÃ CÓ** (có FK `location_id`) |
| `faq.md` | Câu hỏi thường gặp | ❌ CHƯA |
| `experiences.md` | Kinh nghiệm/tips | ❌ CHƯA |
| `itineraries.json` | Lịch trình mẫu theo ngày | ❌ CHƯA — cần **bảng `itinerary_templates` MỚI** (xem ghi chú dưới) |

> ✅ **Đính chính (sau rà soát `02_schema_travel.sql`):** schema travel **đã có sẵn** các bảng `locations` (địa điểm tham quan trong tỉnh — đúng cho `destinations.json`), `tickets` (vé, có FK `location_id`), `tours`, `transport_options`, `destination_events`, `shopping_places`, và `trip_plans`/`trip_plan_items` (lịch trình của **user**, có `day_number`/`order_in_day`/`location_id`/`start_time`/`estimated_cost`). Vậy migration phần lớn là **đổ dữ liệu vào bảng có sẵn**, KHÔNG tạo bảng mới — trừ **itinerary mẫu của KB** (không thuộc user) cần bảng `itinerary_templates` riêng vì `trip_plans.user_id` là `NOT NULL`.

File cấu hình `backend/app/data/`:

| File | Nội dung | Đã vào SQL chưa? |
|---|---|---|
| `intent_patterns.json` | Keyword intent | ⚠️ admin TA-014 (cần xác nhận bảng) |
| `city_slug_alias.json`, `city_slug_display_name.json` | Map tỉnh cũ→mới | ⚠️ admin TA-013 city-mapping |
| `ward_alias_index.json`, `ward_old_to_new.json` | Map phường/xã | ❌ CHƯA (file lớn 2.8–3.3MB) |
| `province_old_to_new.json` | Map tỉnh cũ→mới | ❌ CHƯA |

### 1.2. Hạ tầng SQL đã có

- `knowledge_entries` (`03_schema_ai.sql`): có `category` CHECK (destination/hotel/tour/transport/food/activity/shopping/event/safety/faq/tip), `destination_id`, `content`, `tags`, `source`, `qdrant_id`, `embedding`, `is_active`. **Thiếu** cột `city_slug` để route theo tỉnh không phụ thuộc `destination_id`.
- `embedding_jobs`: queue async → worker bge-m3 → upsert Qdrant (đã có `services/embedding_jobs.py`).
- `destinations`, `locations` (attractions), `hotels`, `tours`, `tickets`, `destination_events`, `transport_options`, `shopping_places`, `trip_plans`/`trip_plan_items` (`02_schema_travel.sql`).
- **Chưa có** bảng `itinerary_templates` (lịch trình mẫu KB, không thuộc user) — `trip_plans` chỉ chứa chuyến đi của user (`user_id NOT NULL`).
- `prompt_templates`, `chat_*` (đã có cột RAG metrics + feedback chi tiết), `conversation_memory`, `system_configs`, `media_files`.
- Script `seed_kb_to_sql.py` (idempotent, UUID deterministic theo slug) — **mở rộng** script này thay vì viết mới. Hiện đã đổ: city→destinations, hotels, foods, restaurants, events, shopping, transport. **Chưa đổ**: `destinations.json`→locations, `tours.json`→tours, tickets, faq.md, experiences.md, itineraries.json.

### 1.3. RAG đọc dữ liệu

`rag_pipeline._route_qdrant_search` đọc `settings.KNOWLEDGE_SOURCE` = `db | files | hybrid`. Mục tiêu cuối: **`db`** (mọi thứ qua `knowledge_entries` → `embedding_jobs` → Qdrant), bỏ phụ thuộc `import_knowledge_base.py` (file → Qdrant trực tiếp).

---

## 2. Kiến trúc đích

```
Web Admin (Flutter Web)
   │  CRUD
   ▼
PostgreSQL  ── nguồn sự thật duy nhất ──┐
  destinations / hotels / tours /        │
  tickets / events / shopping /          │  trigger tạo embedding_job
  transport / locations /                │
  itinerary_templates /                  │
  knowledge_entries (faq, tip, food...)  ▼
                              embedding_jobs (queue)
                                     │  worker bge-m3
                                     ▼
                                  Qdrant (vector)
                                     │
                                     ▼
                                RAG pipeline (KNOWLEDGE_SOURCE=db)

backend/knowledge-base/*.json|*.md  →  CHỈ là input một lần + backup (archive sau cutover)
```

Nguyên tắc: **mỗi loại thông tin có đúng 1 nguồn trong vector store** (tuân RULE-21) — tránh trùng chunk gây hallucination.

---

## 3. Task breakdown đầy đủ (series T-020 → T-031)

> Mỗi task có file card trong `.agent/tasks/`. Status: ⬜ TODO / 🔄 IN_PROGRESS / ✅ DONE / ⛔ BLOCKED.

| Task | Mô tả | Phụ thuộc | Status |
|---|---|---|---|
| **T-020** | Thiết kế & migration schema đích (`initdb/30_migration_kb_sql.sql`) | — | ⬜ TODO |
| **T-021** | Migrate `destinations.json` → **bảng `locations` đã có** + tickets | T-020 | ⬜ TODO |
| **T-022** | Migrate `tours.json` → **bảng `tours` đã có** (thay seed AI) | T-020 | ⬜ TODO |
| **T-023** | Migrate `faq.md` → `knowledge_entries` (faq) | T-020 | ⬜ TODO |
| **T-024** | Migrate `experiences.md` → `knowledge_entries` (tip/activity) | T-020 | ⬜ TODO |
| **T-025** | Migrate `itineraries.json` → **bảng `itinerary_templates` mới** | T-020,T-021,T-033 | ⬜ TODO |
| **T-026** | Migrate config JSON (`intent_patterns`, city/ward/province map) → bảng config | T-020 | ⬜ TODO |
| **T-027** | Embedding pipeline từ SQL + trigger + set `KNOWLEDGE_SOURCE=db` | T-021…T-024 | ⬜ TODO |
| **T-028** | Web Admin CRUD cho mọi loại content + intent/config | T-021…T-026 | ⬜ TODO |
| **T-029** | Validation, idempotency, rollback | T-021…T-027 | ⬜ TODO |
| **T-030** | Cutover RAG sang `db` + archive file KB | T-027,T-029 | ⬜ TODO |
| **T-031** | Eval hồi quy retrieval sau cutover (tái dùng `eval_questions.json`) | T-030 | ⬜ TODO |
| **T-032** | 🔴 Fix schema — mở rộng enum `users.role` (RBAC 4 cấp) | — | ⬜ TODO |
| **T-033** | Schema — bảng `itinerary_templates` (lịch trình mẫu KB) | T-020 | ⬜ TODO |
| **T-034** | Schema — `chat_sessions.last_itinerary` + `chat_messages.suggested_questions` | T-020 | ⬜ TODO |
| **T-035** | Feedback & report chatbot (like/unlike + báo cáo sai sót) | — | ⬜ TODO |
| **T-036** | 🔴 Seed data từ **nguồn đã xác thực** + provenance (thay seed AI chưa kiểm chứng) | T-020,T-021,T-022 | ⬜ TODO |

### T-020 · Thiết kế & migration schema đích
- Thêm cột `knowledge_entries.city_slug VARCHAR(80)` (+ index) để route theo tỉnh không cần `destination_id`.
- Bổ sung `source` chuẩn hóa: `kb_json_<type>` / `kb_md_faq` / `kb_md_experiences`.
- Tạo bảng config: `intent_patterns` (intent, keyword, weight, is_active), `admin_locations_alias` (old_name, new_slug, level ward|district|province) nếu chưa có (đối chiếu TA-013).
- (Bảng `itinerary_templates` tách sang **T-033**; cột `last_itinerary`/`suggested_questions` tách sang **T-034**.)
- Viết migration SQL `initdb/30_migration_kb_sql.sql` (CREATE TABLE IF NOT EXISTS + ALTER ADD COLUMN IF NOT EXISTS) — **không phá seed cũ**.
- DoD: chạy migration trên DB hiện có không lỗi; cột + bảng config mới tồn tại.

### T-021 · destinations.json → `locations` (đã có) + tickets
- Mở rộng `seed_kb_to_sql.py`: hàm `import_attractions()` đọc `destinations.json` → upsert vào **bảng `locations` đã có** (`destination_id` = city, `name`, `type`, `address`, `hours`, `lat`/`lng`, `description`, `tips`, `image_url`). KHÔNG tạo bảng mới.
- `import_tickets()` từ giá vé trong `destinations.json`/`tickets` → **bảng `tickets` đã có** (gắn `location_id` vừa tạo).
- UUID deterministic theo `(city_slug, name)` (idempotent).
- DoD: 1 tỉnh mẫu (da-nang) có đủ `locations` + `tickets` trong SQL khớp file; không bịa giá/giờ thiếu (NULL).

### T-022 · tours.json → `tours` (đã có)
- `import_tours()` đọc `tours.json` → **bảng `tours` đã có** (name, price, duration, group_size, includes, excludes, destination_id) — thay thế dữ liệu seed AI rời `22_seed_...sql`.
- DoD: tours tỉnh mẫu vào DB; `/travel/destinations/:id/tours` trả dữ liệu từ KB; giá thiếu → NULL.

### T-023 · faq.md → knowledge_entries
- Parser markdown: tách frontmatter + từng cặp **Q/A** → 1 `knowledge_entry` (category `faq`, `city_slug`, `title`=Q, `content`=A, `source`=`kb_md_faq`, `tags`).
- Tuân RULE-21: KHÔNG copy số liệu đã có ở JSON; giữ nguyên tham chiếu.
- DoD: FAQ tỉnh mẫu thành các entry; đếm khớp số Q/A trong file.

### T-024 · experiences.md → knowledge_entries
- Parser tách theo section (`##`/`###`) → entry category `tip` (hoặc `activity`), `city_slug`, `title`=tiêu đề section, `content`=nội dung.
- DoD: experiences tỉnh mẫu thành entry; không trùng số liệu với JSON.

### T-025 · itineraries.json → `itinerary_templates` (bảng mới ở T-033)
- `import_itineraries()`: mỗi itinerary → 1 row `itinerary_templates` + N row `itinerary_template_items` (theo `days[].activities`/`location_ref`).
- Map `location_ref.id` → `ref_id` thật trong `locations`/`hotels`/... (tuân RULE-11: phải khớp UUID có thật, không mồ côi).
- DoD: lịch trình mẫu hiển thị được từ SQL; dùng cho chatbot CB-3 (gợi ý lịch trình) và webadmin quản lý.

### T-026 · config JSON → bảng config
- `intent_patterns.json` → bảng `intent_patterns` (admin sửa keyword không cần deploy; `nlp_preprocessor.reload_intent_patterns()` đọc lại — hiện đọc file, đổi sang đọc DB hoặc export DB→file khi save).
- `city_slug_alias` / `ward_alias_index` / `province_old_to_new` → bảng alias (đối chiếu admin TA-013). File lớn → import theo batch.
- DoD: admin sửa 1 keyword intent → chatbot nhận diện đổi theo (sau reload).

### T-027 · Embedding pipeline từ SQL
- Trigger SQL: INSERT/UPDATE trên `knowledge_entries` (+ optionally destinations/hotels/...) → tạo row `embedding_jobs(status='pending')`.
- Worker `services/embedding_jobs.py` (đã có): xử lý pending → bge-m3 → upsert Qdrant với payload `{text,title,category,city,source_id}`.
- Set `KNOWLEDGE_SOURCE=db`; đảm bảo payload đủ field cho `_search_qdrant_sync`.
- DoD: thêm 1 entry qua admin → trong vài giây Qdrant có point → chatbot trả lời được câu liên quan.

### T-028 · Web Admin CRUD content
- Mở rộng KB management (admin TA-008/TA-015-016): CRUD cho `knowledge_entries` (faq/tip/food...), `destinations`/attractions, `hotels`, `tours`, `tickets`, `itineraries`, `events`, `shopping`, `transport`.
- CRUD `intent_patterns` (TA-014) + alias mapping (TA-013).
- Mỗi save → enqueue embedding job (T-027). Có filter theo `city_slug` + `category`.
- DoD: admin tạo/sửa/xóa từng loại, dữ liệu phản ánh trong app + chatbot.

### T-029 · Validation, idempotency, rollback
- Script `scripts/validate_kb_sql.py`: đếm record mỗi tỉnh vs file; phát hiện `destination_id`/`ref_id` mồ côi; field bắt buộc null.
- Bảo đảm `seed_kb_to_sql.py` chạy lại **không nhân đôi** (ON CONFLICT theo UUID/slug).
- Rollback: mọi migration trong transaction; có script `--rollback` xóa theo `source` prefix.
- DoD: chạy migrate 2 lần → cùng số record; validate pass.

### T-030 · Cutover + archive file KB
- Bật `KNOWLEDGE_SOURCE=db` ở `.env` prod.
- Đánh dấu `import_knowledge_base.py` (file→Qdrant) là legacy; chuyển `backend/knowledge-base/` sang `backend/knowledge-base-archive/` (chỉ backup).
- Cập nhật README + RULE-12 (KB giờ là DB).
- DoD: chatbot chạy hoàn toàn từ DB; tắt file vẫn hoạt động.

### T-031 · Eval hồi quy sau cutover
- Chạy `eval_questions.json` trước/sau cutover, so retrieval accuracy không giảm.
- DoD: report so sánh; accuracy ≥ baseline.

---

## 3b. Task bổ sung — Schema fix + Feedback + Seed xác thực

### T-032 · 🔴 Fix schema — mở rộng enum `users.role` (RBAC 4 cấp)
**Vấn đề:** `01_schema_auth.sql` đặt `CHECK (role IN ('user','admin'))`, nhưng README + module admin dùng 4 cấp (super_admin / admin / content_manager / moderator) và tham chiếu `07_migration_extend_user_role.sql` — **file này KHÔNG tồn tại** trong `initdb/`. Insert `super_admin`/`moderator` sẽ bị CHECK chặn.
- Migration `initdb/31_migration_user_role.sql`: `ALTER TABLE users DROP CONSTRAINT` cũ → `ADD CONSTRAINT` mới cho phép `('user','moderator','content_manager','admin','super_admin')` (khớp đúng các role admin module dùng — xác minh lại trong `routes/admin.py`).
- Cập nhật ORM/enum tầng app cho khớp.
- DoD: seed super_admin/moderator không lỗi; admin đổi role 4 cấp hoạt động; không phá user hiện có.

### T-033 · Schema — bảng `itinerary_templates` (lịch trình mẫu KB)
**Lý do:** `trip_plans.user_id` là `NOT NULL` → không chứa lịch trình mẫu của KB (không thuộc user nào).
- Tạo `itinerary_templates` (id, destination_id, city_slug, title, duration_days, group_type, budget_low, budget_high, tags, is_active, source, timestamps).
- Tạo `itinerary_template_items` (id, template_id FK, day_no, order_no, time_slot, title, description, ref_type, ref_id).
- DoD: bảng tồn tại; dùng được cho T-025 (import) + CB-3 (chatbot) + webadmin CRUD.

### T-034 · Schema — context kế hoạch + suggested questions
- `ALTER TABLE chat_sessions ADD COLUMN last_itinerary JSONB` — lưu kế hoạch gần nhất để chatbot multi-turn chỉnh sửa (CB-4).
- `ALTER TABLE chat_messages ADD COLUMN suggested_questions JSONB DEFAULT '[]'` — để chip gợi ý hiện lại khi load lại lịch sử (hiện chỉ có trong stream meta).
- DoD: cột tồn tại; chatbot lưu/đọc được `last_itinerary`.

### T-035 · Feedback & report chatbot (like / unlike / báo cáo sai sót)
**Hiện trạng:** schema **đã đủ** — `chat_messages.feedback SMALLINT CHECK (-1,1)` (like/unlike) + `feedback_reason`, `feedback_category`, `feedback_resolved`, `feedback_resolved_by` (migration 28, TA-017); endpoint `PATCH /chat/messages/{id}/feedback` đã có; câu trả lời kém ghi vào Mongo `chatbot_unanswered_questions` + `chatbot_flagged_responses`. **Gap chính ở mobile** (chưa có nút).
- **Backend:** mở rộng `FeedbackUpdate` schema nhận thêm `reason` + `category` (vd `sai_thong_tin`, `khong_lien_quan`, `thieu_nguon`, `khac`); khi `feedback=-1` + có lý do → ghi thêm vào Mongo unanswered/flagged để admin review (RAG monitoring TA-012/TA-017 đã có UI).
- **Frontend (`chatbot_screen.dart`):** mỗi bong bóng trả lời của AI thêm nút 👍/👎; bấm 👎 mở sheet chọn lý do + ô "Báo cáo sai sót" → gọi feedback endpoint; trạng thái like/unlike hiển thị lại khi load history.
- (Tùy chọn) Nếu muốn tách riêng luồng report khỏi feedback: thêm bảng `chatbot_reports` (message_id, user_id, reason, status) — nhưng khuyến nghị **tái dùng cột feedback có sẵn** để tránh trùng.
- DoD: user like/unlike + báo cáo sai sót từ mobile; admin xem được feedback/report trong RAG monitoring; thống kê % hài lòng theo intent.

### T-036 · 🔴 Seed data từ nguồn ĐÃ XÁC THỰC + provenance
**Vấn đề:** seed `initdb/20_…26_*_full.sql` là **dữ liệu AI sinh tự động, chưa kiểm chứng** (RULE-06 ghi rõ "không dùng SQL seed làm nguồn"). Người dùng yêu cầu chỉ dùng dữ liệu từ nguồn rõ ràng đã lọc.
- **Nguồn hợp lệ** (đã định nghĩa ở RULE-18 / `sql-table-mapping.md`): cơ quan nhà nước (chinhphu.vn, vietnamtourism.gov.vn, Cục Du lịch, Sở Du lịch tỉnh, dsvh.gov.vn), trang chính thức của địa điểm, fanpage chính chủ nhiều lượt theo dõi (đã xác minh), nền tảng du lịch lớn có tỉ lệ verify cao (Traveloka/Klook/Booking/Agoda/Vietravel). Giá → cần ≥2 nguồn khớp.
- **Cách làm:** `knowledge-base/*.json|*.md` **đã có `data_sources` rõ ràng** → dùng làm nguồn seed (qua T-021/T-022 + `seed_kb_to_sql.py`), **ngừng dùng** seed AI 20–26.
- **Provenance:** thêm cột `data_source TEXT`, `source_url TEXT`, `verified BOOLEAN DEFAULT FALSE`, `verified_at TIMESTAMPTZ` vào các bảng content (`destinations`, `locations`, `hotels`, `tours`, `tickets`, `destination_events`, `shopping_places`) — chỉ row có `data_sources` hợp lệ mới `verified=true`.
- Webadmin hiển thị badge "đã xác thực" + nguồn; row chưa verify hiển thị cảnh báo.
- Đánh dấu seed AI `20_…26_*_full.sql` là legacy (chỉ dùng demo nhanh); prod seed từ KB đã xác thực.
- DoD: bảng content có cột provenance; tỉnh mẫu seed từ KB có `verified=true` + `data_source` đúng; không còn phụ thuộc seed AI cho dữ liệu hiển thị thật.

---

## 4. Rủi ro & lưu ý

- **File lớn** (`ward_alias_index.json` 2.8MB, `ward_old_to_new.json` 3.3MB): import theo batch, có thể giữ ở file nếu admin không cần CRUD (cân nhắc — đây là dữ liệu hành chính tĩnh).
- **Trùng dữ liệu vào vector store** (RULE-21): khi đưa faq/experiences vào SQL, đảm bảo không nhân đôi với JSON đã import → mỗi thông tin 1 nguồn.
- **Idempotency**: bắt buộc UUID deterministic + ON CONFLICT, tránh nhân bản khi re-run.
- **Tính đúng dữ liệu**: tuân RULE-02 (không bịa giá/giờ); migration chỉ chuyển dữ liệu đã có, không "làm đầy".
- **Thứ tự**: schema (T-020) trước; embedding/cutover (T-027/T-030) sau cùng; đừng bật `db` khi chưa migrate đủ.

---

## 5. Định nghĩa hoàn thành (toàn migration)

- [ ] Mọi loại dữ liệu KB của 34 tỉnh nằm trong SQL, quản lý được qua Web Admin.
- [ ] `itinerary_templates` có trong SQL và dùng được cho chatbot (CB-3).
- [ ] `KNOWLEDGE_SOURCE=db`, chatbot chạy không cần file KB.
- [ ] Embedding tự động khi admin CRUD.
- [ ] Validation + eval pass, không nhân đôi dữ liệu.
- [ ] File KB chuyển sang archive/backup.
- [ ] **Enum role 4 cấp** hoạt động (T-032); RBAC webadmin không lỗi.
- [ ] **Feedback like/unlike + báo cáo sai sót** chạy được trên mobile, admin xem được (T-035).
- [ ] **Mọi dữ liệu hiển thị thật** có `data_source` hợp lệ + `verified=true`; không còn dùng seed AI chưa kiểm chứng (T-036).
