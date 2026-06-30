# DB SCHEMA REVIEW — PDTrip AI

> Đánh giá tính hợp lý của database cho **Web Admin** và **Mobile**, dựa trên rà soát toàn bộ schema (`initdb/01…29`) + ORM models + Mongo.
> Kết luận: **không cần thiết kế lại** — kiến trúc hợp lý; chỉ bổ sung/sửa một số điểm (đã tạo task T-032 → T-036).

---

## 1. Kiến trúc dữ liệu (polyglot — hợp lý)

| Tầng | Dùng cho | Ghi chú |
|---|---|---|
| **PostgreSQL** | Dữ liệu nghiệp vụ quan hệ | auth, travel, AI (knowledge/chat), trip_plans |
| **MongoDB** | Log append-only | `search_history`, `user_behavior`, `chatbot_unanswered_questions`, `chatbot_flagged_responses`, `admin_audit_logs` |
| **Qdrant** | Vector (RAG) | embed từ `knowledge_entries` qua `embedding_jobs` |

Phân tách đúng: dữ liệu cần JOIN/ACID ở Postgres; log event-only ở Mongo; vector ở Qdrant.

---

## 2. Những gì ĐÃ TỐT (không cần đụng)

- **Triggers tự duy trì counter**: `favorite_count`, `rating_avg`, `review_count`, `view_count` (trigger trên `user_favorites`, `reviews`, dedup `destination_view_logs`).
- **Index đầy đủ**: FTS GIN (destinations/hotels/tours/knowledge), HNSW (embedding), partial index (`is_active`, `revoked=false`, `is_flagged`).
- **Travel schema giàu**: `destinations`, `locations` (attractions), `categories` (M2M), `hotels`, `tours`, `tickets` (FK location), `transport_options`, `destination_events`, `shopping_places`.
- **Trip planning đầy đủ**: `trip_plans` (status draft/saved/completed, travel_type, ai_generated, budget, dates) + `trip_plan_items` (day_number, order_in_day, location_id, start/end time, estimated_cost).
- **Hạ tầng webadmin**: `system_configs` (tunable: chatbot_enabled, gemini_temperature, rag_top_k…), `media_files` (TA-018), `prompt_templates` (versioned), `embedding_jobs` (queue).
- **RAG observability**: `chat_messages` có `confidence_score`, `search_method`, `search_ms`, `llm_ms`, `cache_hit`, `chunk_count` (migration 27); `chat_sessions` có `tags`, `is_flagged`.
- **Feedback hạ tầng**: `chat_messages.feedback (-1/1)` + `feedback_reason`, `feedback_category`, `feedback_resolved`, `feedback_resolved_by` (migration 28) — đủ cho like/unlike + report.
- **Auth**: users + refresh_tokens + OTP + email_verifications + Google OAuth.

---

## 3. Cần SỬA / BỔ SUNG (đã tạo task)

| # | Vấn đề | Mức | Task |
|---|---|---|---|
| 1 | `users.role` CHECK chỉ cho `('user','admin')` nhưng app dùng 4 cấp; `07_migration_extend_user_role.sql` (README tham chiếu) **không tồn tại** trong `initdb/` → insert super_admin/moderator bị chặn | 🔴 Bug | **T-032** |
| 2 | `knowledge_entries` thiếu `city_slug` → khó route KB theo tỉnh | 🔴 | **T-020** |
| 3 | Lịch trình mẫu KB (`itineraries.json`) không có chỗ — `trip_plans.user_id NOT NULL` chỉ chứa trip của user | 🟡 | **T-033** |
| 4 | Multi-turn sửa kế hoạch (CB-4) không có chỗ lưu kế hoạch hiện tại | 🟡 | **T-034** |
| 5 | Feedback like/unlike + báo cáo sai sót: **schema đủ**, thiếu nút ở mobile + mở rộng reason/category | 🟡 | **T-035** |
| 6 | Seed `20…26_*_full.sql` là **AI sinh chưa kiểm chứng**; cần seed từ nguồn xác thực + cột provenance (`data_source`, `verified`) | 🔴 | **T-036** |

### Tùy chọn (chưa tạo task riêng, ghi nhận)
- `intent_patterns` thành bảng để admin sửa không cần deploy (gộp trong **T-026**).
- `device_tokens` + `notifications` nếu làm push thật (settings hiện giả lập) — chỉ khi mở scope push.
- Trigger DELETE cho `reviews` (hiện chỉ có trigger INSERT; xóa review recompute bằng code trong `reviews.py` — chạy được nhưng bất đối xứng với favorites).
- **Audit log ở Mongo "non-fatal"**: `mongo.py` không raise khi Mongo down → audit có thể mất khi Mongo offline. Nếu audit là yêu cầu tuân thủ, cân nhắc ghi đệm/ghi kép.

---

## 4. Đánh giá riêng theo phía

### Mobile — đủ ở tầng DB
Mọi thứ mobile cần (destinations/locations/hotels/tours/tickets/events/transport/shopping, favorites, reviews, trip_plans, chat) đều có bảng + route. **Phần thiếu chủ yếu là frontend dùng chưa hết** (vd `trip_plans` đã có nhưng mobile chưa lưu chuyến đi — xem `KE_HOACH_HOAN_THIEN_MOBILE.md`).

### Web Admin — nền tảng tốt, thiếu vài mảnh
Có: users (role mgmt), knowledge CRUD, embedding_jobs, system_configs, media_files, prompt_templates, audit (Mongo), flagged/unanswered (Mongo), RAG metrics. **Thiếu**: enum role (T-032), CRUD cho locations/tours/tickets/itinerary_templates (T-028), provenance/verified badge (T-036).

---

## 5. Kết luận

Database **hợp lý cho cả webadmin và mobile**. Không cần redesign. Việc cần làm gói gọn trong 6 task **T-032 → T-036** + các task migration T-020 → T-031 đã có. Ưu tiên: **T-032 (fix role — bug)** và **T-036 (seed xác thực)** trước, vì ảnh hưởng tính đúng đắn dữ liệu và RBAC.
