# API Reference — PDTrip AI

Base URL mặc định: `http://localhost:8000`. Tài liệu tương tác (Swagger): `http://localhost:8000/docs`.
Xác thực: **Bearer JWT** ở header `Authorization: Bearer <access_token>`; refresh token lưu ở httpOnly cookie.

> Tài liệu này thay thế các file cũ `endpoint api.txt` và `backend/all_endpoint.txt` (đã gộp).

## 1. Auth — `/auth`

| Method & Path | Mô tả |
|---|---|
| POST `/auth/register/send-otp` | Gửi OTP tới email đăng ký |
| POST `/auth/register/confirm` | Xác nhận OTP + tạo tài khoản |
| POST `/auth/otp/resend` | Gửi lại OTP |
| POST `/auth/login` | Đăng nhập → access token (+ refresh cookie) |
| POST `/auth/google` | Đăng nhập bằng Google OAuth |
| POST `/auth/forgot-password` | Yêu cầu đặt lại mật khẩu (OTP) |
| POST `/auth/reset-password` | Đặt lại mật khẩu bằng OTP |
| POST `/auth/refresh` | Làm mới access token từ refresh cookie |
| POST `/auth/logout` | Thu hồi refresh token |
| GET `/auth/me` | Thông tin user hiện tại |
| PATCH `/auth/me` | Cập nhật hồ sơ |
| PATCH `/auth/me/password` | Đổi mật khẩu |

## 2. Chat Sessions — `/chat/sessions`

| Method & Path | Mô tả |
|---|---|
| GET `/chat/sessions/` | Danh sách phiên của user |
| POST `/chat/sessions/` | Tạo phiên mới |
| GET `/chat/sessions/{session_id}` | Chi tiết phiên |
| PATCH `/chat/sessions/{session_id}` | Đổi title / pin |
| DELETE `/chat/sessions/{session_id}` | Xoá (mềm) phiên |

## 3. Chat Messages (RAG) — `/chat`

| Method & Path | Mô tả |
|---|---|
| GET `/chat/sessions/{session_id}/messages` | Lịch sử tin nhắn |
| POST `/chat/sessions/{session_id}/messages/stream` | Gửi tin nhắn → trả lời RAG dạng **SSE stream** |
| PATCH `/chat/messages/{message_id}/feedback` | Đánh giá câu trả lời 👍/👎 |

## 4. Guest Chat — `/chat/guest`

| Method & Path | Mô tả |
|---|---|
| GET `/chat/guest/status` | Số lượt còn lại của khách |
| POST `/chat/guest/stream` | Chat thử (SSE), giới hạn lượt, không lưu lịch sử |

## 5. Travel Content — `/travel`

| Method & Path | Mô tả |
|---|---|
| GET `/travel/categories` | Danh mục loại hình du lịch |
| GET `/travel/destinations` | Danh sách điểm đến + filter |
| GET `/travel/destinations/{id}` | Chi tiết điểm đến |
| POST `/travel/destinations/{id}/view` | Ghi lượt xem (dedup theo user/ngày) |
| GET `/travel/destinations/{id}/hotels` | Khách sạn |
| GET `/travel/destinations/{id}/tours` | Tour |
| GET `/travel/destinations/{id}/tickets` | Vé tham quan |
| GET `/travel/destinations/{id}/events` | Sự kiện / lễ hội |
| GET `/travel/destinations/{id}/transport` | Phương tiện di chuyển |
| GET `/travel/destinations/{id}/shopping` | Địa điểm mua sắm |

## 6. Trip Plans — `/trips`

| Method & Path | Mô tả |
|---|---|
| GET `/trips/` | Danh sách kế hoạch của tôi |
| POST `/trips/` | Tạo kế hoạch |
| GET `/trips/{trip_id}` | Chi tiết + items theo ngày |
| PATCH `/trips/{trip_id}` | Cập nhật kế hoạch |
| DELETE `/trips/{trip_id}` | Xoá kế hoạch |
| POST `/trips/{trip_id}/items` | Thêm hoạt động |
| PATCH `/trips/{trip_id}/items/{item_id}` | Sửa hoạt động |
| DELETE `/trips/{trip_id}/items/{item_id}` | Xoá hoạt động |

## 7. Favorites / Reviews / Search

| Method & Path | Mô tả |
|---|---|
| POST `/favorites` | Thêm điểm đến yêu thích |
| GET `/favorites` | Danh sách yêu thích |
| GET `/favorites/...` | Kiểm tra/đếm yêu thích |
| DELETE `/favorites/{destination_id}` | Bỏ yêu thích |
| POST `/reviews` | Viết đánh giá điểm đến |
| GET `/reviews` (theo destination) | Danh sách đánh giá |
| GET `/reviews/...` | Đánh giá của tôi |
| DELETE `/reviews/{id}` | Xoá đánh giá |
| GET `/search/` | Tìm kiếm |
| GET `/search/history` | Lịch sử tìm kiếm |
| DELETE `/search/history` | Xoá lịch sử |

## 8. Admin — `/admin`

> Hiện dùng `require_admin` (2 cấp). Theo roadmap `.agent/admin` (TA-001) sẽ nâng lên `require_role` 4 cấp
> (SUPER_ADMIN > ADMIN > CONTENT_MANAGER > MODERATOR).

| Method & Path | Mô tả |
|---|---|
| GET `/admin/knowledge` | Danh sách knowledge entry |
| POST `/admin/knowledge` | Tạo entry → tự tạo embedding job |
| PATCH `/admin/knowledge/{entry_id}` | Cập nhật entry |
| DELETE `/admin/knowledge/{entry_id}` | Xoá entry |
| POST `/admin/knowledge/{entry_id}/embed-now` | Embed ngay lập tức |
| GET `/admin/embedding-jobs` | Danh sách job (filter status) |
| POST `/admin/embedding-jobs/run` | Chạy toàn bộ job pending |
| GET `/admin/stats/questions` | Top câu hỏi |
| GET `/admin/stats/destinations` | Top điểm đến được hỏi |
| GET `/admin/stats/chatbot` | Thống kê chatbot |
| GET `/admin/stats/users` | Thống kê người dùng |
| GET `/admin/users` | Danh sách user |
| PATCH `/admin/users/{user_id}` | Cập nhật user (is_active…) |
| GET `/admin/chat-logs` | Log hội thoại |
| GET `/admin/unanswered-questions` | Câu hỏi chưa trả lời (Mongo) |
| PATCH `/admin/unanswered-questions/{id}/resolve` | Đánh dấu đã xử lý |
| GET `/admin/flagged-responses` | Câu trả lời nghi ảo giác (Mongo) |
| PATCH `/admin/flagged-responses/{id}/review` | Đánh dấu đã review |
| GET `/admin/qdrant-debug` | Trạng thái Qdrant |

## Ghi chú kỹ thuật

- **SSE streaming**: endpoint `.../messages/stream` trả các event `start` → `chunk`* → metadata cuối (sources, intent, tokens, latency).
- **Embedding job**: tạo entry/cập nhật KB sẽ INSERT `embedding_jobs (status='pending')`; worker nền tự pick up và upsert vector vào Qdrant.
- **Phân quyền hiện tại** đặt ở `app/api/deps.py` (`get_current_user`, `require_admin`).
