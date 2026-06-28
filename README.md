# PDTrip AI — Travel Advisor Chatbot

Hệ thống chatbot AI tư vấn du lịch Việt Nam với **NLP**, **Intent Recognition**, **RAG** (Retrieval Augmented Generation), và trang quản trị Web Admin tích hợp trong app Flutter.

## Tính năng

### Người dùng
- Hỏi đáp thông tin du lịch (địa điểm, thời tiết, ẩm thực, chi phí, kinh nghiệm)
- Tư vấn điểm đến theo ngân sách, thời gian, sở thích
- Gợi ý lịch trình (2N1Đ, 3N2Đ, theo nhóm gia đình/cặp đôi/solo)
- Tra cứu dịch vụ: khách sạn, tour, vé tham quan
- Đánh giá và yêu thích điểm đến

### Quản trị (Web Admin — Flutter Web)
- Phân quyền 4 cấp: Super Admin / Admin / Content Manager / Moderator
- Dashboard thống kê: câu hỏi phổ biến, intent NLP, điểm đến, biểu đồ
- Quản lý người dùng + đổi role
- Quản lý Knowledge Base (CRUD + embedding job)
- Xem log hội thoại + audit log mọi thao tác admin
- RAG Monitoring, City/Intent Mapping, System Config

## Công nghệ

| Layer | Stack |
|---|---|
| Backend | Python FastAPI (async) |
| Database | PostgreSQL (SQLAlchemy async) + MongoDB (Motor) |
| Vector DB | Qdrant |
| AI | Google Gemini + RAG pipeline |
| Frontend | Flutter (Material 3) — Mobile + Web |
| Auth | JWT (access token) + httpOnly refresh cookie |

## Cấu trúc dự án

```
trip_advisor_chatbot_project/
├── backend/
│   ├── app/
│   │   ├── api/routes/     # auth, admin, chat, travel, search, ...
│   │   ├── db/models/      # User (UserRole 4 cấp), ChatSession, KnowledgeEntry, ...
│   │   ├── services/       # rag_pipeline, audit_service, log_service, ...
│   │   └── core/           # config, security, sse
│   ├── initdb/             # SQL schema + seed + migration scripts
│   ├── tests/admin/        # Unit tests RBAC, audit log
│   └── requirements.txt
└── frontend/
    └── lib/
        ├── admin/          # Web Admin module (Flutter Web)
        │   ├── api/        # AdminApiClient, knowledge_api, users_api, ...
        │   ├── models/     # AdminUser, UserRole enum
        │   ├── providers/  # AdminAuthProvider
        │   ├── screens/    # dashboard, users, knowledge, rag_monitoring, ...
        │   └── widgets/    # AdminLayout, AdminSidebar, PlaceholderPage
        ├── screens/        # App screens (chat, explore, profile, ...)
        └── services/       # api_service, chat_api_service, ...
```

## Chạy Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt

# Copy .env.example → .env và điền các key
cp .env.example .env

uvicorn app.main:app --reload --port 8000
```

API docs: http://localhost:8000/docs

### Biến môi trường cần thiết (`.env`)
```
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/pdtrip_ai_db
MONGODB_URL=mongodb://localhost:27017
MONGODB_DB_NAME=pdtrip_ai_logs
QDRANT_URL=http://localhost:6333
GEMINI_API_KEY=...
GEMINI_MODEL=gemini-2.0-flash
JWT_SECRET_KEY=...
```

### Tài khoản demo
| Email | Password | Role |
|---|---|---|
| superadmin@pdtrip.vn | 12345678 | super_admin |
| admin@pdtrip.vn | 12345678 | admin |
| user@pdtrip.vn | 12345678 | user |

> Set role super_admin thủ công sau khi seed: xem `backend/initdb/07_migration_extend_user_role.sql`

## Chạy Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome    # Web Admin + App
```

> Cập nhật `lib/services/api_service.dart` nếu backend không chạy trên `localhost:8000`.

## RAG Pipeline

```
User query (tiếng Việt)
  → Intent Classifier (nhận diện ý định + entity)
  → Qdrant vector search (top-K chunks từ Knowledge Base)
  → Gemini tổng hợp câu trả lời từ context
  → Lưu log + RAG metrics (confidence, latency, chunk_count)
```

## API chính

```
POST  /auth/login               Đăng nhập
POST  /auth/refresh             Refresh token

GET   /admin/audit-logs         Xem audit log (ADMIN+)
PATCH /admin/users/{id}/role    Đổi role (SUPER_ADMIN only)
GET   /admin/knowledge          Danh sách Knowledge Base
GET   /admin/stats/chatbot      Thống kê chatbot
GET   /admin/embedding-jobs     Trạng thái embedding jobs
```
