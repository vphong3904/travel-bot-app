# AI Travel Advisor Chatbot

Hệ thống chatbot AI tư vấn du lịch với **NLP**, **Intent Recognition**, **RAG** (Retrieval Augmented Generation) và giao diện demo Flutter.

## Tính năng

### Người dùng
- Hỏi đáp thông tin du lịch (địa điểm, thời tiết, ẩm thực, chi phí, kinh nghiệm)
- Tư vấn điểm đến theo ngân sách, thời gian, sở thích
- Gợi ý lịch trình (2N1Đ, 3N2Đ, theo nhóm gia đình/cặp đôi/solo)
- Tra cứu dịch vụ: khách sạn, tour, vé tham quan
- Khám phá điểm đến với bộ lọc theo tag

### Quản trị (Admin)
- Quản lý Knowledge Base (CRUD)
- Quản lý người dùng (bật/tắt tài khoản)
- Xem log hội thoại chatbot
- Thống kê: câu hỏi phổ biến, intent NLP, điểm đến quan tâm, biểu đồ 7 ngày

## Công nghệ

| Layer | Stack |
|-------|-------|
| Backend | Python FastAPI |
| Frontend | Flutter (Material 3) |
| Database | SQLite (demo) / PostgreSQL |
| Vector DB | FAISS + sentence-transformers |
| AI | RAG + Rule-based Intent (Vietnamese) |

## Cấu trúc dự án

```
trip_advisor_chatbot_project/
├── backend/          # FastAPI API
│   └── app/
│       ├── services/ # intent_classifier, rag_service, chat_service
│       ├── routers/  # auth, chat, destinations, admin
│       └── seed_data.py
└── frontend/         # Flutter demo app
    └── lib/screens/
        ├── auth/
        ├── explore/
        ├── chat/
        ├── services/
        ├── profile/
        └── admin/
```

## Cấu trúc nhánh Git

| Nhánh | Nội dung |
|-------|----------|
| `main` | Monorepo đầy đủ (backend + frontend) |
| `backend` | Chỉ mã nguồn FastAPI (ở root nhánh) |
| `frontend` | Chỉ mã nguồn Flutter (ở root nhánh) |

## Chạy Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

API docs: http://localhost:8000/docs

### Tài khoản demo
| Email | Password | Role |
|-------|----------|------|
| admin@pdtrip.vn | 12345678 | Admin |
| user@travel.ai | 12345678 | User |

## Chạy Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome    # Web demo
# hoặc
flutter run              # Android/iOS/Desktop
```

> **Lưu ý:** Cập nhật `lib/services/api_service.dart` nếu backend không chạy trên `localhost:8000`.
> - Android emulator: `http://10.0.2.2:8000/api`
> - Web: `http://localhost:8000/api`

Frontend có **Demo Mode** — vẫn hoạt động khi backend chưa chạy (dữ liệu mock).

## Intent Recognition (NLP)

| Intent | Mô tả | Ví dụ |
|--------|-------|-------|
| `faq_info` | Hỏi thông tin du lịch | "Thời tiết Đà Lạt tháng 12?" |
| `destination_advice` | Tư vấn điểm đến | "Gợi ý đi biển ngân sách tầm trung" |
| `itinerary` | Lập lịch trình | "Lịch trình Phú Quốc 3 ngày 2 đêm" |
| `service_search` | Tìm dịch vụ | "Tìm khách sạn Phú Quốc" |

## RAG Pipeline

1. User gửi câu hỏi tiếng Việt
2. Intent Classifier nhận diện ý định + entities
3. FAISS truy xuất top-K documents từ Knowledge Base
4. Chat Service tổng hợp câu trả lời từ context (giảm hallucination)
5. Lưu log hội thoại cho admin analytics

## API Endpoints chính

- `POST /api/auth/login` — Đăng nhập
- `POST /api/chat` — Chat với AI
- `GET /api/destinations` — Danh sách điểm đến
- `GET /api/services/search` — Tra cứu dịch vụ
- `GET /api/admin/stats` — Thống kê admin
- `GET/POST/PUT/DELETE /api/admin/kb` — Quản lý KB
