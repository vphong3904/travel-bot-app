# Admin — Media Manager (CMS) · RBAC seed · Cột ảnh content · Dọn initdb

> Nhánh: `feat/admin-media-rbac-images`. Tài liệu cho đợt hoàn thiện phần quản lý
> ảnh (TA-018), phân quyền RBAC, bổ sung cột ảnh cho các bảng content, và **dọn
> gọn `backend/initdb` từ 40 → 8 file** (gộp migration vào schema, bỏ seed
> content/demo — content nạp từ knowledge-base).

## 1. Database (backend/initdb — đã dọn gọn còn 8 file)

`backend/initdb` chỉ chứa **schema + bootstrap tối thiểu**; **content** (địa điểm,
khách sạn, món ăn, KB, điểm vui chơi T-037…) nạp riêng từ knowledge-base bằng
`backend/scripts/seed_kb_to_sql.py`, **không** seed trong initdb.

| File | Vai trò |
|---|---|
| `00_extensions_and_functions.sql` | extension + `uuid_generate_v7` + trigger helper |
| `01_schema_auth.sql` | users (role 5 cấp RBAC), refresh_tokens, otp_codes, email_verifications |
| `02_schema_travel.sql` | destinations/locations/hotels/tours/tickets/transport/events/shopping/**restaurants**/**foods** + cột `image_url` + provenance + UNIQUE chống trùng + view_logs |
| `03_schema_ai.sql` | knowledge_entries, embedding_jobs (+ trigger enqueue), chat_sessions/messages, itineraries, intent_patterns, locations_alias, system_configs |
| `04_schema_media.sql` | `media_folders` (cây thư mục CMS) + `media_files` (folder_id, soft delete) |
| `10_seed_auth.sql` | tài khoản: 4 cấp RBAC + user mẫu (mật khẩu `12345678`) |
| `11_seed_system_config.sql` | giá trị `system_configs` mặc định |
| `12_seed_intent_patterns.sql` | bộ keyword intent cơ bản |

> Toàn bộ cột `image_url`/provenance và bảng media trước đây nằm rải rác ở các file
> migration 27–41 nay đã **gộp thẳng vào schema** (init sạch, không còn vệt migration).
> Đã validate bằng `pgvector/pgvector:pg17`: init thành công, 34 bảng, 4 role RBAC.
> T-037 (điểm vui chơi) vào DB qua `seed_kb_to_sql.py` (import `destinations.json`).

### Tài khoản RBAC (mật khẩu `12345678`)

| Email | Username | Role |
|---|---|---|
| `superadmin@pdtrip.vn` | superadmin | `super_admin` |
| `admin@pdtrip.vn` | admin | `admin` |
| `content@pdtrip.vn` | contentmgr | `content_manager` |
| `moderator@pdtrip.vn` | moderator | `moderator` |

Hash bcrypt dùng lại y nguyên của các user seed (`10_seed_auth.sql`).

## 2. Backend — Media API (`/api/admin/media`)

Lưu file ở `static/uploads`, phục vụ tại `/uploads/<filename>` (mount StaticFiles
trong `app/main.py`). Upload dùng Pillow resize ≤1920px → WebP (best-effort: thiếu
Pillow vẫn lưu được ảnh gốc). Model: `app/db/models/media.py`.

| Method | Endpoint | Quyền | Mô tả |
|---|---|---|---|
| GET | `/admin/media/folders` | mọi admin | Danh sách thư mục (phẳng) + `image_count` + `last_added` |
| POST | `/admin/media/folders` | admin/super/content | Tạo thư mục (`name`, `parent_id?`) |
| PATCH | `/admin/media/folders/{id}` | admin/super/content | Đổi tên |
| DELETE | `/admin/media/folders/{id}` | admin/super/content | Xoá (cascade con; ảnh giữ lại) |
| GET | `/admin/media?folder_id=&page=` | mọi admin | Ảnh trong thư mục |
| POST | `/admin/media/upload?folder_id=` | admin/super/content | Upload **nhiều** ảnh 1 lần (field `files`) |
| DELETE | `/admin/media/{id}` | admin/super/content | Soft delete |

## 3. Frontend (Flutter admin)

- `web/screens/media_screen.dart` — trình quản lý: breadcrumb, lưới thư mục (sắp xếp
  theo lần thêm ảnh gần nhất, gắn nhãn "Mới"), tạo/đổi tên/xoá thư mục, tạo thư mục
  con, nút **Thêm ảnh** (multi-select) upload vào thư mục đang mở, lưới ảnh + phân trang.
- `shared/{models,data,providers}` — model `MediaFolderModel`/`MediaFileModel`,
  repository + provider theo folder. URL ảnh tuyệt đối qua `mediaUrl()` (gốc server,
  bỏ hậu tố `/api`).
- Route `/media` đăng ký trong `admin_router.dart`; nav có ở mục **Media** (top) và
  **Quản lý ảnh** trong nhóm **Nội dung** (`admin_sidebar.dart`).

## 4. Việc còn lại (ngoài đợt này)

- CRUD content (destinations/hotels/...) gắn nút "Chọn ảnh từ thư viện" mở Media
  manager để gán `image_url` (hiện cột đã sẵn sàng ở DB + form).
- Audit log cho thao tác media (hiện các route admin khác cũng chưa gắn đồng bộ).
