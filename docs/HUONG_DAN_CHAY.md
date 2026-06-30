# 🚀 Hướng dẫn chạy toàn bộ dự án PDTrip AI

Hướng dẫn từng bước để **người mới** chạy được cả hệ thống: hạ tầng (PostgreSQL +
Qdrant + MongoDB) → Backend (FastAPI) → nạp dữ liệu → Frontend (Flutter app + Web Admin).

> Stack: FastAPI · PostgreSQL (pgvector) · MongoDB · Qdrant · Google Gemini · Flutter.

---

## 0. Yêu cầu cài sẵn

| Công cụ | Phiên bản | Ghi chú |
|---|---|---|
| Docker Desktop | mới nhất | chạy PostgreSQL + Qdrant + MongoDB |
| Python | 3.10–3.12 | backend (FastAPI) |
| Flutter SDK | 3.x (Dart 3.x) | frontend (app + web admin) |
| Git | — | clone repo |

Kiểm tra nhanh: `docker --version`, `python --version`, `flutter --version`.

---

## 1. Lấy mã nguồn

```bash
git clone https://github.com/vphong3904/travel-bot-app.git
cd travel-bot-app
```

---

## 2. Tạo file cấu hình backend (`.env`)

```bash
cd backend
cp .env.example .env        # Windows PowerShell: Copy-Item .env.example .env
```

Mở `backend/.env` và điền các khoá quan trọng (mặc định đã chạy được với Docker local):

```ini
DATABASE_URL=postgresql+asyncpg://user:12345678@localhost:5432/pdtrip_ai_db
MONGODB_URL=mongodb://localhost:27017
MONGODB_DB_NAME=pdtrip_ai_logs
QDRANT_URL=http://localhost:6333
GEMINI_API_KEY=<điền API key Google Gemini>
GEMINI_MODEL=gemini-2.0-flash
JWT_SECRET_KEY=<chuỗi ngẫu nhiên bất kỳ>
KNOWLEDGE_SOURCE=hybrid
```

> ⚠️ Không commit `.env` thật. `GEMINI_API_KEY` lấy ở https://aistudio.google.com/apikey.

---

## 3. Khởi động hạ tầng (1 lệnh)

`backend/docker-compose.yml` đã có sẵn 3 service. Lần đầu chạy, PostgreSQL **tự nạp
schema + tài khoản** từ `backend/initdb/*.sql`.

```bash
cd backend
docker compose up -d
docker ps          # thấy: travel_postgres, travel_qdrant, travel_mongo (healthy)
```

Kiểm tra DB đã tạo bảng + tài khoản:

```bash
docker exec -it travel_postgres psql -U user -d pdtrip_ai_db -c "\dt"
docker exec -it travel_postgres psql -U user -d pdtrip_ai_db -c "SELECT email, role FROM users WHERE role<>'user';"
```

> Lúc này **bảng nội dung (destinations, hotels, …) còn trống** — sẽ nạp ở bước 5.

---

## 4. Chạy Backend (FastAPI)

```bash
cd backend
python -m venv venv
# Windows:        venv\Scripts\activate
# macOS/Linux:    source venv/bin/activate
pip install -r requirements.txt -r requirements-rag.txt

python -m uvicorn app.main:app --reload --port 8000
```

- API docs (Swagger): http://localhost:8000/docs
- Lần đầu chạy cần **internet** để tải model embedding BGE-M3 (~vài trăm MB).

---

## 5. Nạp dữ liệu Knowledge Base → SQL

Nội dung (địa điểm, khách sạn, món ăn, FAQ, lịch trình, điểm vui chơi…) nằm ở
`backend/knowledge-base/` và được nạp vào SQL bằng script:

```bash
cd backend
# Windows: set PYTHONUTF8=1  (tránh lỗi in tiếng Việt trên console)
python scripts/seed_kb_to_sql.py            # nạp tất cả thành phố
# python scripts/seed_kb_to_sql.py --city lam-dong-da-lat   # 1 thành phố
# python scripts/seed_kb_to_sql.py --dry-run                # chỉ in, không ghi
```

Mỗi `knowledge_entries` (FAQ/kinh nghiệm) mới sẽ tự tạo **embedding job**. Để đẩy
vector lên Qdrant: chạy backend (worker nền tự xử lý) hoặc gọi
`POST /admin/embedding-jobs/run`. Khi vector đủ + kiểm thử ổn, đổi
`KNOWLEDGE_SOURCE=db` trong `.env` rồi restart backend.

> 📄 Cách build thư mục KB cho thành phố mới: xem [KB_CITY_FORMAT.md](KB_CITY_FORMAT.md).

---

## 6. Chạy Frontend (Flutter)

```bash
cd frontend
flutter pub get
```

**App người dùng (mobile/web):**
```bash
flutter run -d chrome                 # web
flutter run -d android                # Android (emulator: đổi base URL → http://10.0.2.2:8000)
```

**Web Admin (trang quản trị):**
```bash
flutter run -d chrome --target lib/main_admin.dart
# Backend khác localhost:8000 thì thêm: --dart-define=API_BASE_URL=http://<host>:8000/api
```

> Base URL API của app mobile chỉnh ở `lib/services/api_service.dart`.

---

## 7. Tài khoản đăng nhập mặc định (mật khẩu `12345678`)

| Email | Role | Dùng cho |
|---|---|---|
| `superadmin@pdtrip.vn` | super_admin | Web Admin — toàn quyền |
| `admin@pdtrip.vn` | admin | Web Admin |
| `content@pdtrip.vn` | content_manager | Web Admin — nội dung/KB |
| `moderator@pdtrip.vn` | moderator | Web Admin — chat/feedback |
| `tranlan@gmail.com` … | user | App người dùng |

---

## 8. Thứ tự khởi động tóm tắt

```
docker compose up -d              # 1) Postgres + Qdrant + Mongo (tự seed schema + tài khoản)
uvicorn app.main:app --reload     # 2) Backend API :8000
python scripts/seed_kb_to_sql.py  # 3) Nạp nội dung từ knowledge-base
flutter run -d chrome ...         # 4) App / Web Admin
```

---

## 9. Gỡ lỗi thường gặp

| Triệu chứng | Cách xử lý |
|---|---|
| `password authentication failed` khi nạp KB | Máy có **PostgreSQL local** chiếm cổng 5432, che container Docker. Tắt service Postgres local, hoặc trỏ `DATABASE_URL=postgresql://user:12345678@127.0.0.1:<cổng-docker>/pdtrip_ai_db` tới container. |
| `UnicodeEncodeError ... cp1252` khi chạy script | Windows console: chạy `set PYTHONUTF8=1` trước (script `seed_kb_to_sql.py` đã tự ép UTF-8). |
| Backend không kết nối DB | `docker ps` xem container chạy chưa; kiểm tra `DATABASE_URL`; `docker logs travel_postgres`. |
| RAG không trả kết quả | Qdrant chưa có vector → chạy worker/`POST /admin/embedding-jobs/run`; lần đầu cần internet tải model embedding. |
| Muốn làm lại DB từ đầu | `docker compose down -v` rồi `docker compose up -d` (xoá sạch dữ liệu, init lại). |
| OTP email không gửi | Kiểm tra nhóm `SMTP_*` trong `.env`. |
