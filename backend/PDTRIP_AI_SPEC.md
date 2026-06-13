
---

# PDTrip AI — Product Specification

> Dự án của Phong & Đạt · Dùng làm tài liệu tham chiếu cho coding agent

## 1. Tech Stack

| Layer | Công nghệ |
| --- | --- |
| Mobile client | Flutter (iOS + Android) |
| Communication | HTTP/REST + SSE streaming |
| Backend gateway | FastAPI (Python) |
| Auth | JWT |
| Primary DB | PostgreSQL (SQLAlchemy ORM) |
| Vector store | Qdrant |
| Caching Layer | **Redis** (Rate limiting, Feed caching) |
| Object Storage | **AWS S3** / Google Cloud Storage (Lưu trữ Media) |
| AI / LLM | Gemini 1.5 Flash (hoặc GPT-4o-mini) |
| Embedding | text-embedding-3-small · bge-m3 |
| Reranker | bge-reranker-v2-m3 |
| Local cache | SharedPreferences / Hive (Flutter) |

**Chi phí AI ước tính:** ~2,000–3,000 token/lượt ≈ 13–20 VNĐ/lượt

---

## 2. RAG Pipeline (AI Chat API)

```text
User query
  → [1] Tokenizer + Chunker (sentence-transformers · JSON/MD chunks)
  → [2] Embed → Qdrant (text-embedding-3-small · cosine similarity)
  → [3] Query Rewrite + Retrieve (top-k chunks từ Qdrant)
  → [4] Rerank (bge-reranker-v2-m3)
  → [5] Generate (Gemini 1.5 Flash · system prompt + context)
  → SSE stream → Flutter client

```

*(Pipeline core)*

**Nguồn dữ liệu RAG:**

* JSON structured: places · menus · hotels (offline ingestion).
* Markdown FAQs: tips · travel guides (offline ingestion).
* **UGC Reviews:** Các bài review có rating ≥ 4 sao sẽ tự động kích hoạt (trigger) Celery Background Task để tóm tắt và đưa vào (ingest) Qdrant, giúp AI luôn cập nhật dữ liệu realtime.

---

## 3. Backend Services (FastAPI)

### 3.1 FastAPI Gateway

* Auth (JWT) · Rate limit · Router · SSE endpoint.
* Route đến 3 service chính bên dưới.

### 3.2 Social API

* Feed · Post · Comment · Like · Follow · Story · Message · Notification.

### 3.3 Explore API

* Map · Place · Review · Check-in · Search · Filter.

### 3.4 AI Chat API

* RAG pipeline · SSE stream · Chat history · Rate limiting theo role.

---

## 4. Flutter — Lưu ý kết nối Backend

> Các điểm cần implement đúng trong `ChatBotScreen` và `IntentSetupScreen`:

| # | Điểm cần chú ý | File liên quan |
| --- | --- | --- |
| 1 | `ChatService.sendMessage()` — cần tạo file | `travel_api.dart` |
| 2 | `sources` chưa hiển thị trong UI — backend trả về nhưng bị bỏ qua | `chat_bubble.dart` |
| 3 | `has_itinerary` + `itinerary` — cần render card lịch trình | `itinerary_card.dart` |
| 4 | `confidence` của intent — cần dùng để quyết định fallback | `intent_setup_screen.dart` |
| 5 | SSE stream parsing — `text/event-stream` format | `sse_client.dart` |
| 6 | Guest cache sync — đọc local cache sau login, POST lên server | `auth_service.dart` |

**Backend response fields đầy đủ:**

```json
{
  "text": "...",
  "intent": "...",
  "confidence": 0.95,
  "sources": [...],
  "has_itinerary": true,
  "itinerary": {...},
  "destinations": [...],
  "services": [...]
}

```

---

## 5. Roles & Permissions

### Bảng so sánh nhanh

| Tính năng | GUEST | FREE | PREMIUM | CREATOR | ADMIN |
| --- | --- | --- | --- | --- | --- |
| Xem nội dung | ✅ | ✅ | ✅ | ✅ | ✅ |
| Like/Comment/Share | ❌ | ✅ | ✅ | ✅ | ✅ |
| Đăng bài (ảnh) | ❌ | 5/ngày | ∞ | ∞ | ✅ |
| Đăng bài (video) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Story 24h | ❌ | ❌ | ✅ | ✅ | ✅ |
| Check-in GPS | ❌ | ✅ | ✅ | ✅ | ✅ |
| AI Chat | 3 lượt | 20/ngày | ∞ | ∞ | ∞ |
| AI cá nhân hóa | ❌ | ❌ | ✅ | ✅ | ✅ |
| Voice/Ảnh AI | ❌ | ❌ | ✅ | ✅ | ✅ |
| Lịch trình AI | ❌ | ❌ | ✅ | ✅ | ✅ |
| Offline map | ❌ | ❌ | ✅ | ✅ | ✅ |
| Bookmark | ❌ | 20 | ∞ | ∞ | ✅ |
| Quảng cáo | Có | Có | Không | Không | — |
| Kiếm tiền từ bài | ❌ | ❌ | ❌ | ✅ | — |
| Cache chat local | ✅ | — | — | — | — |

### Chi tiết Phân quyền

* **GUEST:** Cho xem đủ để thích, chặn đúng lúc để đăng ký. Chỉ được Chat AI 3 lượt và lưu cache local. Khi đến lượt 4 sẽ hiện popup yêu cầu đăng nhập và đồng bộ cache.
* **FREE USER:** AI 20 lượt/ngày (reset 00:00). Có thể làm nhiệm vụ để kiếm thêm lượt (đăng nhập liên tiếp, check-in, mời bạn...).
* **PREMIUM USER:** Không giới hạn AI. Hỗ trợ AI nhớ dài hạn, nhận diện ảnh/voice, offline map, xuất PDF lịch trình. Có 3 ngày trial lần đầu.
* **CREATOR:** Dành cho tài khoản Premium được duyệt (500 followers, 50 bài ảnh thật). Có badge xanh, đăng video 10 phút và nhận % doanh thu quảng cáo.
* **ADMIN:** Quản lý toàn bộ nội dung, người dùng, data địa điểm, log AI và analytics.

---

## 6. Screens Index

### Bottom Navigation Bar

* 🏠 Home | 🔍 Explore | ➕ Post (FAB) | 🤖 AI | 👤 Profile
* Floating bar, bo tròn 2 đầu, blur glass effect. FAB nổi cao hơn.

### Các Màn hình Chính

*(Các luồng màn hình giữ nguyên logic gốc)*

* **HOME (H1-H4):** Feed chính, Thông báo, Danh sách tin nhắn, Chat 1-1, Bình luận.
* **EXPLORE (E1-E3):** Explore chính (Map/List), Kết quả tìm kiếm, Chi tiết địa điểm (có nút "Hỏi AI" tự điền context).
* **POST (P1-P2):** Chọn loại bài, Tạo bài viết (bắt buộc có ảnh + địa điểm + rating).
* **AI CHAT (A1-A2):** Chat với AI, Lịch sử chat.
* **PROFILE (PR1-PR8):** Profile cá nhân, Profile người khác, Chỉnh sửa, Cài đặt, Follow, Badges, Lịch sử chuyến đi.
* **AUTH & PREMIUM:** Onboarding, Đăng nhập (Google/SĐT), Trial, Mua gói.

---

## 7. Key UX Behaviors

* **Gated Actions:** Khách (Guest) thao tác các nút tương tác (Like, Comment, Share, Save...) sẽ bị yêu cầu đăng nhập.
* **Check-in Flow:** GPS check phải trong vòng 200m → xác nhận → gợi ý viết review ngay.
* **AI Context từ E3:** E3 → "Hỏi AI" → Tab A1 mở với context địa điểm tự động điền, user không cần gõ lại.
* **Lưu nháp (P2):** Thoát P2 → popup "Lưu nháp không?" [Lưu nháp / Bỏ / Tiếp tục sửa].
* **Premium Gate UI Pattern:** Tính năng bị khóa → hiển thị 🔒 + mờ → tap → mở PM1 Giới thiệu Premium (không chặn hard).

---

## 8. Database Tables (PostgreSQL)

*(Đã bổ sung chuẩn Timestamps, Soft Deletes và Metrics)*

```text
users           — id, role, phone, email, display_name, avatar, bio, is_premium, trial_used, created_at, updated_at, is_deleted
posts           — id, user_id, type, visibility, content, location_id, rating, cost, media[], created_at, updated_at, is_deleted
locations       — id, name, type, address, province, lat, lng, hours, rating_avg, verified, created_at
reviews         — id, user_id, location_id, rating_overall, rating_detail{}, content, created_at, updated_at, is_deleted
checkins        — id, user_id, location_id, lat, lng, verified, created_at
follows         — follower_id, following_id, created_at
likes           — user_id, post_id, created_at
comments        — id, post_id, user_id, parent_id, content, created_at, updated_at, is_deleted
bookmarks       — user_id, location_id, collection_id, created_at
collections     — id, user_id, name, created_at
chat_sessions   — id, user_id, title, created_at, updated_at, is_deleted
chat_messages   — id, session_id, role, content, sources[], intent, prompt_tokens, completion_tokens, created_at
notifications   — id, user_id, type, ref_id, read, created_at
badges          — id, user_id, badge_type, earned_at
ai_usage        — user_id, date, count (cho rate limiting FREE)

```

---

## 9. API Endpoints (FastAPI)

### Auth & User Profile

```text
POST /auth/google          — OAuth2 Google
POST /auth/otp/send        — Gửi OTP về SĐT
POST /auth/otp/verify      — Xác nhận OTP → JWT
POST /auth/sync-guest-chat — Sync cache chat từ Guest
PUT  /users/profile        — Cập nhật Avatar, Bio, Links

```

### Social & Media

```text
GET  /upload/presigned-url — Lấy link upload S3 trực tiếp
GET  /feed                 — Home feed (trending / following)
POST /posts                — Tạo bài viết
GET  /posts/{id}           — Chi tiết bài viết
DELETE /posts/{id}/media   — Xóa ảnh/video trong bài đăng
POST /posts/{id}/like      — Like/unlike
POST /posts/{id}/comments  — Thêm comment
POST /follow/{user_id}     — Follow/unfollow
GET  /notifications        — Danh sách thông báo
GET  /messages             — Danh sách conversation
GET  /messages/{user_id}   — Lịch sử chat 1-1
POST /messages/{user_id}   — Gửi tin nhắn

```

### Explore

```text
GET  /locations            — Danh sách địa điểm (filter, pagination)
GET  /locations/{id}       — Chi tiết địa điểm
GET  /locations/nearby     — Địa điểm gần (lat, lng, radius)
POST /checkins             — Check-in tại địa điểm
GET  /search               — Tìm kiếm toàn bộ (locations, posts, users, hashtags)

```

### AI Chat

```text
POST /chat                 — Gửi message → SSE stream response
GET  /chat/sessions        — Danh sách lịch sử chat
GET  /chat/sessions/{id}   — Lịch sử messages của session
DELETE /chat/sessions/{id} — Xóa session
GET  /chat/usage           — Số lượt còn lại hôm nay

```

### Premium

```text
POST /premium/trial        — Kích hoạt 3-ngày trial
POST /premium/subscribe    — Mua gói
GET  /premium/status       — Trạng thái gói hiện tại

```

---

## 10. Ghi chú Tối quan trọng cho Coding Agent

1. **Rate limit AI Chat:** Luôn check bảng `ai_usage` trước khi gọi LLM. Reset daily lúc 00:00 VN time. Khuyến khích dùng **Redis** để đếm TTL nhằm giảm tải cho Database.
2. **SSE streaming:** endpoint `/chat` phải dùng `StreamingResponse` với `media_type="text/event-stream"`.
3. **Guest AI cache:** Flutter lưu vào Hive, sau login POST lên `/auth/sync-guest-chat` với array messages.
4. **Check-in GPS verify:** Backend kiểm tra haversine distance(user_lat, user_lng, location_lat, location_lng) ≤ 200m.
5. **Re-embed trigger:** Khi Admin upload data mới, gọi background job re-index Qdrant collection. Không block API response.
6. **Creator badge:** Chỉ Admin mới set được `role = 'creator'`. Validate đủ điều kiện trước khi cho phép.
7. **Bookmark limit:** Middleware check: FREE user > 20 bookmark → trả 403 với `{"reason": "bookmark_limit", "upgrade": true}`.
8. **Post media:** FREE: max 5 ảnh, no video. PREMIUM: max 10 ảnh + video ≤ 3 phút. Validate server-side, không chỉ client.
9. **Cursor-based Pagination:** Mọi API trả về danh sách (Feed, Explore, Comments...) **bắt buộc** dùng `next_cursor` thay vì Offset/Limit để đảm bảo UI Flutter scroll mượt mà và không miss data.
10. **File Upload Flow:** Mobile Client phải gọi `GET /upload/presigned-url` để lấy link và đẩy file thẳng lên AWS S3. Bắt buộc không cho upload file raw dạng multipart/form-data trực tiếp qua FastAPI nhằm chống nghẽn băng thông server.
11. **Soft Delete Rule:** Các lệnh Xóa (Post, Comment, Session) trên UI chỉ được cập nhật field `is_deleted = true` trong database, tuyệt đối không dùng lệnh `DELETE FROM...` để giữ liệu nguyên vẹn cho RAG/Analytics model.