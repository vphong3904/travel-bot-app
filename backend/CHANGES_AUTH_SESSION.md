# TripMate AI — JWT Auth, Phân quyền & Chat Session History
> File này tóm tắt các thay đổi đã thực hiện + việc bạn cần làm tiếp theo.
> Đặt file này ở: `chatbot_app/backend/CHANGES_AUTH_SESSION.md` (cùng cấp với `PDTRIP_AI_SPEC.md`).

---

## 1. Các file đã thêm / sửa

### Backend (`backend/app/`)
| File | Thay đổi |
|---|---|
| `auth.py` (mới) | JWT verify (`get_current_user`, `get_optional_user`), phân quyền (`require_roles`, `require_admin`), rate limit AI (`check_and_consume_ai_quota`). |
| `models.py` | Thêm bảng `AiUsage` (đếm lượt chat AI theo user/ngày). |
| `schemas.py` | Thêm `session_id` vào `ChatRequest`/`ChatResponse`; thêm `ChatSessionResponse`, `ChatMessageResponse`, `ChatSessionDetailResponse`. |
| `routers/auth.py` | Thêm `GET /auth/me`. |
| `routers/chat.py` | Viết lại: tạo/quản lý `ChatSession` thật, gắn `user_id` từ JWT (chống giả mạo), enforce rate limit, thêm `GET /chat/sessions`, `GET /chat/sessions/{id}`, `DELETE /chat/sessions/{id}`. |
| `routers/admin.py` | Toàn bộ route yêu cầu `Authorization: Bearer <token>` + role `admin`. |
| `app/api/` (cũ) | **Đã xoá** — là bản trùng lặp, không được `main.py` dùng, code lỗi (tham chiếu field không tồn tại). |

### Frontend (`frontend/lib/`)
| File | Thay đổi |
|---|---|
| `services/token_storage.dart` (mới) | Lưu JWT bằng `shared_preferences`, cung cấp `authHeader()`. |
| `services/travel_api.dart` | `AuthService.login/register` tự lưu token, thêm `me()/logout()`; `ChatService` gắn Bearer token + hỗ trợ `sessionId`, thêm `getSessions/getSessionDetail/deleteSession`; `AdminService.*` gắn Bearer token. |
| `screens/chat/chat_history_screen.dart` (mới) | UI danh sách session + xem lại nội dung 1 session. |

---

## 2. Việc bạn cần làm tiếp (theo thứ tự)

### Bước 1 — Tạo bảng `ai_usage` trong DB
Bảng `AiUsage` mới chỉ có trong `models.py`, DB Postgres chưa có bảng này.
- Nếu dùng `init_db()` (tạo bảng qua `Base.metadata.create_all`) và DB đang **trống** → tự tạo, không cần làm gì.
- Nếu DB **đã có data** (đã chạy seed trước đó) → cần tạo bảng thủ công, ví dụ chạy 1 lần:
  ```python
  # chạy trong backend/, với venv đã activate
  from app.database import Base, engine
  from app import models  # noqa: import để đăng ký model
  Base.metadata.create_all(bind=engine)
  ```
  Hoặc nếu bạn dùng Alembic, tạo migration mới:
  ```bash
  cd backend
  alembic revision --autogenerate -m "add ai_usage table"
  alembic upgrade head
  ```

### Bước 2 — Cập nhật `pubspec.yaml` (frontend)
`shared_preferences` đã có sẵn trong `pubspec.yaml` → chỉ cần:
```bash
cd frontend
flutter pub get
```

### Bước 3 — Đăng ký màn hình lịch sử chat
Mở file điều hướng chính của bạn (ví dụ `main.dart` hoặc bottom nav trong `chatbot_screen.dart`) và thêm route tới `ChatHistoryScreen`:
```dart
import 'package:.../screens/chat/chat_history_screen.dart';

// ví dụ: thêm 1 IconButton trên AppBar của ChatbotScreen
IconButton(
  icon: const Icon(Icons.history),
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ChatHistoryScreen()),
  ),
)
```

### Bước 4 — Giữ `session_id` khi chat tiếp
Trong `chatbot_screen.dart`, khi gọi `ChatService.sendMessage(...)` hoặc
`sendMessageStream(...)`:
- Lần đầu: không truyền `sessionId` (hoặc `null`) → server tự tạo session mới
  và trả về `session_id` trong response (`ChatResponse.session_id`) hoặc
  qua event `session` (SSE).
- Lưu `session_id` đó vào state của màn hình.
- Các tin nhắn tiếp theo trong cùng cuộc hội thoại: truyền lại `sessionId` đó
  để backend nối vào đúng `ChatSession`.

### Bước 5 — Test phân quyền Admin
- Login bằng user `role=admin` (xem `seed_data.py`) → copy `access_token`.
- Gọi `GET /api/admin/stats` với header `Authorization: Bearer <token>` → 200.
- Gọi lại **không có token** → phải nhận `401`.
- Login bằng user `role=user` (free) rồi gọi `/api/admin/stats` → phải nhận `403`.

### Bước 6 — Test rate limit FREE (20 lượt/ngày)
- Login user role `user` (free), gọi `/api/chat/json` 21 lần liên tiếp.
- Lượt thứ 21 phải trả `429` với body:
  ```json
  {"detail": {"reason": "daily_limit", "limit": 20, "upgrade": true, "message": "..."}}
  ```
- Để test nhanh, có thể tạm sửa `FREE_DAILY_LIMIT` trong `app/auth.py`.
- Trên Flutter, bắt lỗi `429` ở `ChatService.sendMessage` → hiện popup "Nâng cấp Premium"
  (theo **Premium Gate UI Pattern** đã mô tả trong `PDTRIP_AI_SPEC.md` §5).

---

## 3. Việc còn lại / cần lưu ý (chưa làm trong lần này)

1. **Guest (3 lượt)**: backend hiện **không** chặn Guest ở server — theo đúng
   spec, FE quản lý qua Hive local cache. Nếu muốn chặn cứng ở server (ví dụ
   theo IP/device id), cần thiết kế thêm — hãy cho mình biết nếu cần.
2. **WebSocket chat** (`screens/services/chat_service.dart` đang gọi
   `ws://.../api/chat/ws/{user_id}`): endpoint này **chưa tồn tại** ở backend
   (file `websocket_manager.py` chỉ là class quản lý connection, chưa có route
   WS nào dùng nó). Cần quyết định: bỏ hẳn WS (chỉ dùng SSE đang có), hay tạo
   route WS mới + xác thực JWT qua query param (`?token=...`) vì WebSocket
   không gửi được header `Authorization` từ Flutter `web_socket_channel` dễ dàng.
3. **`/auth/sync-guest-chat`**, **`/premium/trial`, `/premium/subscribe`,
   `/premium/status`** trong spec §Premium chưa được implement.
4. **Đổi role → creator/premium**: chưa có endpoint admin để set role; hiện
   `User.role` chỉ là string tự do, không có validate "đủ điều kiện creator"
   theo mục 6 trong spec.
