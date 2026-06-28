# PDTrip AI — Chatbot Tư vấn Du lịch Việt Nam (RAG)

Hệ thống chatbot tư vấn du lịch ứng dụng **RAG** (Retrieval-Augmented Generation): truy hồi tri thức từ
**Qdrant** (vector) kết hợp **PostgreSQL FTS**, sinh câu trả lời bằng **Gemini** có kiểm soát ảo giác.
Backend **FastAPI**, ứng dụng **Flutter** đa nền tảng, phần **Web Admin** đang được mở rộng.

> Đồ án tốt nghiệp. Tài liệu phân tích – thiết kế đầy đủ (Use Case, ERD, CSDL, Sequence) xem file
> `PDTrip_AI_Phan_Tich_Thiet_Ke.docx` ở thư mục gốc.

## Kiến trúc tổng quan

| Tầng | Công nghệ |
|---|---|
| Backend API | FastAPI (async), Pydantic, SQLAlchemy 2.0 |
| CSDL quan hệ | PostgreSQL |
| CSDL tài liệu | MongoDB (Motor) — log, hành vi, audit |
| Vector DB | Qdrant |
| AI / LLM | Google Gemini + BGE-M3 embedding |
| RAG | Hybrid Search (RRF) + rerank + cache 2 lớp + hallucination guard |
| Frontend | Flutter (mobile + web) |
| Web Admin | React + Vite (theo spec `.agent/admin`, đang xây) |

## Tính năng chính

Người dùng: hỏi đáp du lịch (RAG, streaming SSE), lịch sử hội thoại, đánh giá câu trả lời, khám phá điểm
đến, yêu thích, đánh giá, lập kế hoạch chuyến đi, quản lý hồ sơ. Khách vãng lai: chat thử có giới hạn lượt.
Quản trị: CRUD Knowledge Base + embedding job, thống kê, quản lý user/chat-log, câu hỏi chưa trả lời &
câu trả lời nghi ảo giác.

## Bắt đầu nhanh

```bash
# Backend
cd backend
pip install -r requirements.txt -r requirements-rag.txt
cp .env.example .env          # rồi điền giá trị thật
docker compose up -d          # PostgreSQL (+ initdb) — xem docs/SETUP.md
python -m uvicorn app.main:app --reload   # http://localhost:8000  (Swagger: /docs)

# Frontend
cd frontend
flutter pub get
flutter run -d chrome
```

Chi tiết cài đặt, biến môi trường, Docker, gỡ lỗi: **[docs/SETUP.md](docs/SETUP.md)**.

## Tài liệu

| Tài liệu | Nội dung |
|---|---|
| [docs/SETUP.md](docs/SETUP.md) | Cài đặt, biến môi trường, Docker, gỡ lỗi |
| [docs/API.md](docs/API.md) | Tham chiếu API đầy đủ (8 nhóm route, gồm `/admin`) |
| [docs/FRONTEND.md](docs/FRONTEND.md) | Kiến trúc & cấu trúc ứng dụng Flutter |
| [docs/USE_CASES.md](docs/USE_CASES.md) | Đặc tả use case theo tác nhân |
| `PDTrip_AI_Phan_Tich_Thiet_Ke.docx` | Phân tích – thiết kế: Use Case, ERD, CSDL, 7 Sequence |
| `.agent/` | Agent Knowledge Base (T-001..016) |
| `.agent/admin/` | Agent Web Admin (TA-001..023) + skill `admin-web-agent` |
| `kb_tracking/` | Tổng hợp tiến độ Knowledge Base theo 34 tỉnh/thành |

## Cấu trúc thư mục (rút gọn)

```
backend/
  app/
    api/routes/      # auth, chat_*, travel, trips, favorites, reviews, search, admin
    core/            # config, security, sse
    db/              # database, models/, schemas/, mongo
    services/        # rag_pipeline, hybrid_search, hallucination_guard, nlp_preprocessor, ...
  initdb/            # SQL khởi tạo + seed
  knowledge-base/    # dữ liệu tri thức theo tỉnh/thành (JSON/MD)
frontend/            # ứng dụng Flutter
docs/                # tài liệu (file này trỏ tới)
.agent/              # workspace agent (KB + Admin)
```
