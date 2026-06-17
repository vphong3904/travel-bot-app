# 🚀 AI Travel Advisor - Hướng Dẫn Chạy Dự Án

## 📋 Yêu Cầu Hệ Thống

### Backend (FastAPI + RAG)
- Python 3.9+
- PostgreSQL 12+
- Docker Desktop (tùy chọn)

### Frontend (Flutter)
- Flutter SDK 3.0+
- Dart 3.0+
- Android SDK / iOS SDK (tuỳ nền tảng)

---

## 🔧 Hướng Dẫn Cài Đặt

### 1. Chuẩn Bị Backend

#### Cách 1: Chạy trực tiếp (không cần Docker)

```bash
cd backend
# Cài đặt dependencies
pip install -r requirements.txt
pip install -r requirements-rag.txt

# Cấu hình PostgreSQL
# Mở file: backend/app/core/config.py
# Sửa DATABASE_URL nếu cần

# Khởi tạo database
python -c "from app.db.database import engine; from app.db.models import Base; Base.metadata.create_all(bind=engine)"

# Chạy backend
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### Cách 2: Chạy với Docker (khuyến khích)

```bash
cd backend
docker-compose up -d
# Backend chạy tại http://localhost:8000
```

### 2. Chuẩn Bị Frontend (Flutter)

```bash
cd frontend

# Lấy dependencies
flutter pub get

# Sửa API endpoint (nếu cần)
# File: lib/services/api_service.dart
# Đổi BASE_URL nếu backend chạy ở địa chỉ khác

# Chạy trên Android
flutter run -d android

# Chạy trên iOS
flutter run -d ios

# Chạy trên Web
flutter run -d web

# Build APK (Android)
flutter build apk --release
```

---

## 📁 Cấu Trúc Dự Án

```
project/
├── backend/
│   ├── app/
│   │   ├── main.py                 # Entry point
│   │   ├── api/routes/              # API endpoints
│   │   ├── core/config.py           # Configuration
│   │   ├── db/models/               # Database models
│   │   ├── services/                # Business logic (RAG, NLP)
│   │   └── utils/logger.py          # Logging
│   ├── requirements.txt
│   ├── requirements-rag.txt
│   ├── docker-compose.yml
│   └── initdb/pdtrip_ai_db.sql      # Database schema
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart                # App entry
│   │   ├── main_navigation.dart      # Bottom tab navigation
│   │   ├── screens/
│   │   │   ├── home/home_screen.dart              # Trang chủ + Carousel
│   │   │   ├── chat/chatbot_screen.dart           # Chat với AI
│   │   │   ├── services/services_screen.dart      # Tìm kiếm dịch vụ
│   │   │   ├── profile/profile_screen.dart        # Hồ sơ người dùng
│   │   │   ├── profile/settings_screen.dart       # Cài đặt
│   │   │   └── admin/admin_dashboard_screen.dart  # Admin panel
│   │   ├── models/
│   │   │   ├── destination.dart
│   │   │   ├── service.dart
│   │   │   ├── chat_message.dart
│   │   │   └── app_user.dart
│   │   ├── services/
│   │   │   ├── destination_service.dart
│   │   │   ├── service_repository.dart
│   │   │   └── travel_api.dart
│   │   ├── widgets/
│   │   │   ├── common_widgets.dart
│   │   │   ├── destination_card.dart
│   │   │   ├── service_card.dart
│   │   │   ├── recommendation_carousel.dart
│   │   │   ├── loading_state_widgets.dart
│   │   │   └── dialog_helpers.dart
│   │   ├── providers/
│   │   │   ├── app_state.dart       # State management
│   │   │   └── chat_provider.dart
│   │   └── theme/
│   │       └── colors.dart
│   └── pubspec.yaml
│
└── README.md
```

---

## 🎨 Tính Năng Chính

### 🏠 Trang Chủ (Home)
- ✅ Carousel gợi ý tự động chuyển mỗi 4 giây
- ✅ Lưới hiển thị điểm đến nổi bật
- ✅ Tìm kiếm và lọc theo thể loại
- ✅ Thông tin ngân sách, thời tiết cho mỗi địa điểm

### 💬 Chat AI
- ✅ Tư vấn du lịch thông minh bằng NLP
- ✅ Intent Recognition (4 loại intent)
- ✅ RAG Pipeline (Retrieval-Augmented Generation)
- ✅ Lịch sử hội thoại
- ✅ Lên lịch trình tự động

### 🏨 Tra Cứu Dịch Vụ
- ✅ Tìm khách sạn, tour, vé
- ✅ Lọc theo loại dịch vụ
- ✅ Đánh giá sao & số bình luận
- ✅ Hiển thị giá & địa chỉ

### 👤 Hồ Sơ & Cài Đặt
- ✅ Quản lý thông tin người dùng
- ✅ Lịch sử trò chuyện
- ✅ Địa điểm yêu thích
- ✅ Ngôn ngữ, thông báo, chế độ tối
- ✅ Đăng xuất

### 🛠️ Bảng Điều Khiển Admin
- ✅ Quản lý Knowledge Base
- ✅ Xem thống kê người dùng
- ✅ Xem lịch sử chat
- ✅ Kích hoạt/vô hiệu hóa tài khoản

---

## 🔐 Tài Khoản Demo

**Tên:** admin@travel.ai  
**Mật khẩu:** admin123  
**Quyền:** Admin (truy cập dashboard quản trị)

---

## 🧪 Thử Nghiệm API

```bash
# Lấy danh sách điểm đến
curl http://localhost:8000/api/destinations

# Chat AI
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Gợi ý 3 ngày ở Phú Quốc",
    "user_id": 1,
    "user_name": "User"
  }'

# Tìm dịch vụ
curl http://localhost:8000/api/services/search?q=phú%20quốc
```

---

## 🚨 Gỡ Lỗi

### Backend không kết nối được
1. Kiểm tra PostgreSQL: `psql -U postgres -d pdtrip_ai_db`
2. Kiểm tra API: `curl http://localhost:8000/api/destinations`
3. Xem logs: `docker-compose logs backend`

### Frontend không tải được dữ liệu
1. Kiểm tra API endpoint trong `lib/services/api_service.dart`
2. Mở Developer Tools: `flutter run -d chrome --web-launch-url="about:blank"`
3. Kiểm tra lỗi mạng trong Console

### Lỗi Port
- Backend mặc định: `8000`
- Nếu bận, chỉnh sửa command: `--port 8001`

---

## 📦 Các Dependencies Chính

### Backend
- FastAPI (web framework)
- SQLAlchemy (ORM)
- Pydantic (validation)
- Sentence Transformers (embeddings)
- FAISS (vector DB)

### Frontend
- Flutter Material 3
- Provider (state management)
- HTTP (networking)
- Google Fonts
- FL Chart

---

## 📝 Lưu Ý

1. **Database**: Đảm bảo PostgreSQL chạy trước khi khởi động backend
2. **API Base URL**: Sửa trong `frontend/lib/services/api_service.dart` nếu backend ở máy khác
3. **CORS**: Backend đã cấu hình CORS cho Flutter
4. **RAG**: Yêu cầu kết nối internet để download embeddings model lần đầu

---

## ✨ Tính Năng Trong Tương Lai

- [ ] Tích hợp thanh toán (Stripe, VNPay)
- [ ] Đặt tour trực tiếp
- [ ] Hình ảnh 360° cho điểm đến
- [ ] Thống kê chuyến đi
- [ ] Chia sẻ lịch trình

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề, kiểm tra:
- Logs backend: `docker-compose logs`
- Flutter debug output: `flutter run -v`
- Network requests: Chrome DevTools

**Đồ án tốt nghiệp - AI Travel Advisor v1.0**
