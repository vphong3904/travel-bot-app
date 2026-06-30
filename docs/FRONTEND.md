# 🎨 Frontend Architecture & Features - AI Travel Advisor

## 📊 Tổng Quan Cấu Trúc

```
lib/
├── main.dart                          # App entry + Theme setup
├── main_navigation.dart               # Bottom tab navigation (4 tabs)
│
├── screens/
│   ├── auth/
│   │   └── login_register_screen.dart     # Đăng nhập/Đăng ký
│   ├── splash/
│   │   └── splash_screen.dart             # Loading animation
│   ├── home/
│   │   └── home_screen.dart               # Trang chủ (carousel + grid)
│   ├── chat/
│   │   ├── chatbot_screen.dart            # Chat AI
│   │   ├── chat_history_screen.dart       # Lịch sử
│   │   └── intent_setup_screen.dart       # Setup intent
│   ├── services/
│   │   └── services_screen.dart           # Tìm dịch vụ
│   ├── profile/
│   │   ├── profile_screen.dart            # Hồ sơ
│   │   └── settings_screen.dart           # Cài đặt
│   ├── admin/
│   │   └── admin_dashboard_screen.dart    # Admin panel
│   └── trip_detail/
│       ├── destination_detail_screen.dart # Chi tiết điểm đến
│       └── trip_details_screen.dart       # Chi tiết lịch trình
│
├── models/
│   ├── app_user.dart                  # User model
│   ├── destination.dart               # Destination model
│   ├── service.dart                   # Service model (hotel, tour, ticket)
│   ├── chat_message.dart              # Chat message model
│   ├── user_preferences.dart          # User settings model
│   └── ...
│
├── services/
│   ├── api_service.dart               # API base config
│   ├── destination_service.dart       # Destination repository
│   ├── service_repository.dart        # Service repository
│   ├── travel_api.dart                # Travel API calls
│   └── ...
│
├── providers/
│   ├── app_state.dart                 # AppState (user, token)
│   └── chat_provider.dart             # ChatProvider (messages, typing)
│
├── widgets/
│   ├── common_widgets.dart            # Colors, buttons, cards
│   ├── destination_card.dart          # Destination card widget
│   ├── service_card.dart              # Service card widget
│   ├── recommendation_carousel.dart   # Auto-sliding carousel
│   ├── loading_state_widgets.dart     # Loading, error, empty states
│   ├── dialog_helpers.dart            # Dialog utilities
│   ├── animations.dart                # Animation builders
│   ├── itinerary_card.dart            # Itinerary display
│   └── web_layout.dart                # Web responsive layout
│
└── theme/
    └── colors.dart                    # Color constants
```

---

## 🎯 Các Tính Năng Chính

### 1️⃣ **Trang Chủ (HomeScreen)**
- ✅ **Carousel gợi ý**: Tự động chuyển slide mỗi 4 giây
- ✅ **Lưới điểm đến**: Hiển thị 2 cột, lazy-load
- ✅ **Tìm kiếm**: Real-time search qua tên, miêu tả
- ✅ **Lọc theo thể loại**: Biển, Núi, Nghỉ dưỡng, Khám phá
- ✅ **Thông tin chi tiết**: Ngân sách, thời tiết, ẩm thực
- ✅ **Gợi ý AI**: Nút CTA dẫn tới chat AI

**Widgets sử dụng:**
- `RecommendationCarousel`: PageView tự động
- `DestinationCard`: Custom card với image, title, price
- `AppSearchBar`: Search field
- Loading/Empty states

### 2️⃣ **Chat AI (ChatBotScreen)**
- ✅ **Hỏi đáp**: Gửi pesan và nhận phản hồi AI
- ✅ **Intent Recognition**: Hiển thị intent (faq_info, itinerary, v.v.)
- ✅ **Độ tin cậy**: Hiển thị confidence score
- ✅ **Sources**: RAG sources (tài liệu tham khảo)
- ✅ **Lịch trình**: Hiển thị lịch trình trong chat
- ✅ **Quick prompts**: Gợi ý nhanh khi chat mới
- ✅ **Connection status**: RAG Active / Connecting

**Tính năng:**
- Typing indicator (AI đang suy nghĩ...)
- Message bubbles (User = primary, AI = white)
- Link to trip details screen
- Scrolling auto-smooth

### 3️⃣ **Tra Cứu Dịch Vụ (ServicesScreen)**
- ✅ **Multi-filter**: Tất cả / Khách sạn / Tour / Vé
- ✅ **Search**: Tìm theo tên, địa điểm
- ✅ **Service Cards**: Hiển thị image, rating, giá
- ✅ **Empty/Loading/Error states**

**Service Card hiển thị:**
- Loại dịch vụ (icon + label)
- Rating + số bình luận
- Tên, miêu tả
- Địa chỉ
- Giá

### 4️⃣ **Hồ Sơ (ProfileScreen)**
- ✅ **Avatar**: Chữ cái đầu tiên tên
- ✅ **Thống kê nhanh**: Chuyến đi, câu hỏi AI, yêu thích
- ✅ **Menu nhanh**:
  - Chat với AI
  - Lịch sử hội thoại
  - Địa điểm đã lưu
  - Admin panel (nếu admin)
  - Cài đặt
  - Về ứng dụng
  - Hỗ trợ

**Thiết kế:**
- Card menu với icon + title + subtitle
- Responsive layout
- Clean typography

### 5️⃣ **Cài Đặt (SettingsScreen)**
- ✅ **Hiển thị**: Chế độ tối, ngôn ngữ
- ✅ **Thông báo**: Bật/tắt, email
- ✅ **Dữ liệu**: Xóa lịch sử, yêu thích
- ✅ **Về ứng dụng**: Phiên bản, ToS, Privacy
- ✅ **Tài khoản**: Đăng xuất

**Thiết kế:**
- Grouped settings tiles
- Toggle switches
- Dialog confirmations
- Section headers

### 6️⃣ **Admin Dashboard**
- ✅ **Thống kê**: Người dùng, chat
- ✅ **Quản lý KB**: Thêm, sửa, xóa tài liệu
- ✅ **Xem chat logs**
- ✅ **Quản lý users**: Kích hoạt/vô hiệu hóa

---

## 🎨 UI/UX Components

### Common Widgets

#### **AppSearchBar**
```dart
AppSearchBar(
  controller: _searchCtrl,
  hint: 'Tìm...',
  onChanged: _search,
  onClear: _clear,
)
```

#### **GradientCard**
```dart
GradientCard(
  colors: [Color1, Color2], // optional
  child: YourWidget(),
)
```

#### **AppPrimaryButton**
```dart
AppPrimaryButton(
  label: 'Thử ngay',
  icon: Icons.rocket,
  loading: false,
  onPressed: () {},
)
```

#### **SectionTitle**
```dart
SectionTitle(
  title: 'Điểm đến nổi bật',
  action: 'Xem tất cả',
  onAction: () {},
)
```

### State Management Widgets

#### **LoadingScreen**
```dart
LoadingScreen(message: 'Đang tải...')
```

#### **ErrorScreen**
```dart
ErrorScreen(
  message: 'Có lỗi xảy ra',
  onRetry: _reload,
)
```

#### **EmptyScreen**
```dart
EmptyScreen(
  title: 'Không có dữ liệu',
  message: 'Hãy thử lại',
  icon: Icons.inbox_outlined,
  onRetry: _reload,
)
```

### Animations

#### **FadeInAnimation**
```dart
FadeInAnimation(
  duration: Duration(milliseconds: 500),
  child: YourWidget(),
)
```

#### **SlideUpAnimation**
```dart
SlideUpAnimation(
  offset: 50,
  child: YourWidget(),
)
```

#### **Page Transitions**
```dart
Navigator.push(context, fadePageRoute(YourScreen()))
Navigator.push(context, slideUpPageRoute(YourScreen()))
```

---

## 🔌 State Management

### AppState (Provider)
```dart
final appState = context.watch<AppState>();
appState.user          // Current user
appState.token         // Auth token
appState.isLoggedIn    // Login status
appState.logout()      // Logout function
```

### ChatProvider (Provider)
```dart
final chatProvider = context.watch<ChatProvider>();
chatProvider.messages   // List of messages
chatProvider.isTyping   // AI typing status
chatProvider.isConnected // Connection status
```

---

## 🎯 Color Palette

| Tên | Hex | Sử dụng |
|-----|-----|--------|
| Primary | #2563EB | Buttons, highlights |
| Secondary | #F97316 | Accents, prices |
| Dark | #1E293B | Text, titles |
| Muted | #64748B | Subtitles, hints |
| BG | #F8FAFC | Background |
| Success | #10B981 | Success messages |
| Error | #EF4444 | Errors |
| Card | #FFFFFF | Cards |

---

## 📱 Responsive Design

### Breakpoints
- **Mobile**: < 600px (default)
- **Tablet**: 600px - 1200px
- **Desktop**: > 1200px

### Adaptations
- CustomScrollView với SliverAppBar
- Grid 2 cột (mobile) / 3-4 cột (tablet)
- Fixed width cho containers
- Flexible padding/margins

---

## 🔄 Navigation Flow

```
Splash Screen (3s)
     ↓
Login/Register
     ↓
Main Navigation (4 tabs)
├── Home → Detail → Chat/Services
├── Chat → History
├── Services → Detail
└── Profile → Settings/Admin
```

---

## 📦 Dependencies Chính

```yaml
provider: ^6.1.2              # State management
http: ^1.2.2                  # HTTP requests
google_fonts: ^6.2.1          # Fonts
shared_preferences: ^2.3.3    # Local storage
fl_chart: ^0.69.2             # Charts (future)
web_socket_channel: ^3.0.1    # WebSocket
```

---

## ✨ Best Practices Áp Dụng

1. **Separation of Concerns**
   - Models: Data structures
   - Services: API calls
   - Providers: State management
   - Screens: UI logic
   - Widgets: Reusable components

2. **Error Handling**
   - Try-catch blocks
   - Custom error screens
   - Snackbar notifications
   - Logging

3. **Performance**
   - Lazy loading
   - Image caching
   - Efficient rebuilds
   - IndexedStack for tab nav

4. **UX**
   - Animations for transitions
   - Loading indicators
   - Empty states
   - Error recovery

5. **Code Quality**
   - Const constructors
   - Proper naming
   - Documentation
   - No magic numbers

---

## 🚀 Hướng Phát Triển Tương Lai

- [ ] Dark mode support
- [ ] Offline caching
- [ ] Push notifications
- [ ] Payment integration
- [ ] Social sharing
- [ ] Favorites management
- [ ] Real-time collaboration
- [ ] Video tutorials

---

**Version**: 1.0.0  
**Last Updated**: 2026-06-16  
**Status**: ✅ Production Ready
