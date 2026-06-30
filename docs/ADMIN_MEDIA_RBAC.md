# Admin — Media Manager (CMS) · RBAC seed · Cột ảnh content · Seed T-037

> Nhánh: `feat/admin-media-rbac-images`. Tài liệu cho đợt hoàn thiện phần quản lý
> ảnh (TA-018), phân quyền RBAC và bổ sung cột ảnh cho các bảng content.

## 1. Migration & seed (backend/initdb)

Chạy theo thứ tự số (idempotent — chạy lại an toàn):

| File | Nội dung |
|---|---|
| `39_migration_media_folders_and_images.sql` | Bảng `media_folders` (cây thư mục) + `media_files.folder_id`; thêm `image_url` cho `restaurants`, `foods`, `tickets`, `destination_events`, `shopping_places` |
| `40_seed_rbac_accounts.sql` | Seed 4 tài khoản RBAC (mật khẩu `12345678`) |
| `41_seed_t037_entertainment.sql` | Seed 68 điểm vui chơi/giải trí (T-037) từ knowledge-base JSON vào bảng `locations` |

`41` được sinh tự động bởi `backend/scripts/gen_seed_t037_entertainment.py` (đọc
`knowledge-base/*/destinations.json`, lọc `type` vui chơi). `destination_id` được
resolve bằng subquery khớp `slug` **hoặc** tên thành phố → không vỡ FK nếu slug
trong DB không khớp tên thư mục; `ON CONFLICT (id) DO NOTHING` nên chạy lại không trùng.

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
