# Hướng dẫn cài đặt & chạy — PDTrip AI

Gộp từ `HƯỚNG_DẪN_CHẠY.md` và `Cách chạy postgresql trên docker desktop….txt` (đã cập nhật cho đúng
stack thật: PostgreSQL + Qdrant + MongoDB + Gemini).

## 1. Yêu cầu hệ thống

Backend: Python 3.10+, PostgreSQL 14+ (khuyến nghị image `pgvector/pgvector:pg17`), Docker Desktop (tuỳ chọn),
Qdrant, MongoDB. Frontend: Flutter SDK 3.x, Dart 3.x.

## 2. Biến môi trường

Backend đọc cấu hình từ `backend/.env`. Sao chép mẫu rồi điền giá trị thật:

```bash
cd backend
cp .env.example .env
```

Các nhóm khoá chính (xem `.env.example` để biết đầy đủ): `DATABASE_URL`, `MONGODB_URL`/`MONGODB_DB_NAME`,
`QDRANT_URL`/`QDRANT_COLLECTION`/`QDRANT_API_KEY`, `GEMINI_API_KEY`/`GEMINI_MODEL`,
`EMBEDDING_MODEL`/`EMBEDDING_DIM`, `JWT_SECRET_KEY`, nhóm `SMTP_*` (gửi OTP email), `GOOGLE_CLIENT_ID`,
và các tham số RAG (`RAG_TOP_K`, `RAG_SCORE_THRESHOLD`, `KNOWLEDGE_SOURCE`).

> Không commit `.env` thật. Chỉ commit `.env.example`.

## 3. PostgreSQL bằng Docker (kèm seed tự động)

`backend/docker-compose.yml` đã cấu hình sẵn. Thư mục `backend/initdb/*.sql` được nạp tự động lần đầu container khởi tạo.

```bash
cd backend
docker compose up -d                 # tạo & chạy container postgres
docker ps                            # kiểm tra container (vd: travel_postgres)
docker logs -f travel_postgres       # xem log init: CREATE TABLE / INSERT ... → "ready to accept connections"
```

Kiểm tra dữ liệu:

```bash
docker exec -it travel_postgres psql -U user -d pdtrip_ai_db
# trong psql:  \dt   (liệt kê bảng)   |   \q  (thoát)
SELECT COUNT(*) FROM destinations;
SELECT COUNT(*) FROM users;
```

Làm lại từ đầu (xoá cả dữ liệu): `docker compose down -v` rồi `docker compose up -d`.

## 4. Qdrant & MongoDB

```bash
docker run -p 6333:6333 qdrant/qdrant         # Qdrant (hoặc dùng Qdrant Cloud qua QDRANT_URL/API_KEY)
docker run -p 27017:27017 mongo               # MongoDB (hoặc Mongo Atlas qua MONGODB_URL)
```

Sau khi có dữ liệu KB, nạp/đồng bộ vector vào Qdrant qua tiến trình embedding (xem `app/services/embedding_jobs.py`
và endpoint `POST /admin/embedding-jobs/run`).

## 5. Chạy Backend

```bash
cd backend
python -m venv venv
# Windows: venv\Scripts\activate   |   macOS/Linux: source venv/bin/activate
pip install -r requirements.txt -r requirements-rag.txt
python -m uvicorn app.main:app --reload      # http://localhost:8000
```

Swagger UI: `http://localhost:8000/docs`. Đổi cổng: thêm `--port 8001`.

## 6. Chạy Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run -d chrome        # web
flutter run -d android       # Android (emulator dùng base URL http://10.0.2.2:8000)
flutter build apk --release  # đóng gói APK
```

Cập nhật base URL API trong tầng service của Flutter (`lib/services/...`) nếu backend không ở `localhost:8000`.

## 7. Gỡ lỗi thường gặp

Backend không kết nối DB: kiểm tra container chạy (`docker ps`), đúng `DATABASE_URL`, log (`docker logs travel_postgres`).
RAG không trả kết quả: kiểm tra Qdrant đã được nạp vector (`GET /admin/qdrant-debug`); lần đầu chạy cần internet để tải model embedding (BGE-M3).
OTP không gửi: kiểm tra nhóm `SMTP_*`. Lỗi 401: access token hết hạn → gọi `/auth/refresh`.
