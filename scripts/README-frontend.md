# AI Travel Advisor - Frontend (Flutter)

Giao diện demo chatbot tư vấn du lịch.

## Chạy

```bash
flutter pub get
flutter run -d chrome
```

## Cấu hình API

Sửa `lib/services/api_service.dart`:

- Web/Desktop: `http://localhost:8000/api`
- Android emulator: `http://10.0.2.2:8000/api`

## Tính năng

- Khám phá điểm đến, AI Chat (RAG), tra cứu dịch vụ
- Admin: KB, users, logs, thống kê (đăng nhập admin@travel.ai)
