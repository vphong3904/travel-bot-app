# 📈 TRACKING — PDTrip AI Knowledge Base (lam-dong-mui-ne)

Thư mục thành phố: `lam-dong-mui-ne`  
Trạng thái tổng thể: **✅ HOÀN THÀNH 100% CẤU TRÚC KNOWLEDGE BASE**

## 📊 Bảng trạng thái 12 File

| STT | Tên File | Loại | Trạng thái | Ghi chú / Tham chiếu UUID |
|---|---|---|---|---|
| 1 | `city.json` | JSON | ✅ DONE | Lưu thông tin tổng quan thành phố |
| 2 | `destinations.json` | JSON | ✅ DONE | Khởi tạo 5 địa điểm du lịch văn hóa tự nhiên |
| 3 | `hotels.json` | JSON | ✅ DONE | Đầy đủ 4 phân khúc từ homestay đến resort 5★ |
| 4 | `foods.json` | JSON | ✅ DONE | Danh sách 5 đặc sản ẩm thực biển trứ danh |
| 5 | `restaurants.json` | JSON | ✅ DONE | 3 tọa độ ăn uống phân bổ theo trục đường và khu bờ kè |
| 6 | `transport.json` | JSON | ✅ DONE | 3 tuyến đến thành phố + 4 phương tiện nội tỉnh di chuyển |
| 7 | `tours.json` | JSON | ✅ DONE | 3 chương trình tour xe Jeep ngắm bình minh/hoàng hôn độc đáo |
| 8 | `tickets.json` | JSON | ✅ DONE | Quản lý thông tin giá vé tham quan |
| 9 | `events.json` | JSON | ✅ DONE | 3 lễ hội truyền thống văn hóa đặc sắc địa phương |
| 10 | `shopping.json` | JSON | ✅ DONE | 4 tọa độ mua quà lưu niệm tranh cát đặc sản |
| 11 | `itineraries.json` | JSON | ✅ DONE | 2 lịch trình chuẩn khớp UUID hai chiều |
| 12 | `faq.md` | MD | ✅ DONE | 11 câu hỏi đáp đủ 7 danh mục phân loại chuẩn |
| 13 | `experiences.md` | MD | ✅ DONE | Tips hành vi thực tế, cẩm nang chống chặt chém ăn uống |

---

## 🗺️ Bản đồ Ánh xạ UUID Thực tế (Entity UUID Map)

Để đảm bảo chatbot RAG không bị lỗi liên kết chéo dữ liệu, toàn bộ ID dưới đây được khởi tạo bằng cấu trúc **UUIDv7** chuẩn:

### 🏙️ Thành phố (City Definition)
*   **Mũi Né (Bình Thuận):** `01904a43-6df2-7000-8451-ab73e215d8f1`

### 📍 Địa điểm tham quan (`destinations.json`)
*   **Đồi Cát Bay:** `01904a43-6df2-7000-8d5b-fc135d57b282`
*   **Suối Tiên (Fairy Stream):** `01904a43-6df2-7000-bf64-32ae7021ad01`
*   **Bại biển Hòn Rơm:** `01904a43-6df3-7000-9941-fa2b8744c803`
*   **Tháp Chàm Poshanư:** `01904a43-6df3-7000-a51b-5e2831ca233a`
*   **Làng Chài Mũi Né:** `01904a43-6df3-7000-b6f1-a201bcf5ff1a`

### 🏨 Cơ sở lưu trú (`hotels.json`)
*   **Anantara Mui Ne Resort:** `01904a43-6df3-7000-cd4c-1f544971cb32`
*   **Bamboo Village Beach Resort:** `01904a43-6df3-7000-df34-2e1cbfe8f5b8`
*   **Mui Ne Hills Bliss Hotel:** `01904a43-6df3-7000-ebe5-3a0cb8b30f81`
*   **iHome Homestay Mui Ne:** `01904a43-6df3-7000-f925-b827cb658514`

### 🍽️ Nhà hàng & Quán ăn (`restaurants.json`)
*   **Nhà hàng Cây Bàng:** `01904a44-0158-7000-84cf-cb0179a405ef`
*   **Quán hải sản Bờ Kè Mr. Crabs:** `01904a44-0158-7000-9ef2-5b96782f25b2`
*   **Chameleon Beach Bar:** `01904a44-0158-7000-acc5-0377461c3cbf`

### 🛒 Địa điểm mua sắm (`shopping.json`)
*   **Chợ Mũi Né:** `01904a44-cd4a-7000-8c9f-3d1cb5aa70f5`
*   **Cửa hàng Con Cá Vàng:** `01904a44-cd4a-7000-9eb4-9fa0cb782b12`
*   **Tranh cát Phi Long:** `01904a44-cd4a-7000-abf2-ea01bc58df14`
*   **Lotte Mart Phan Thiết:** `01904a44-cd4a-7000-bc4d-17e0ab41f4bc`

---

## 📝 TODO List - Missing Fields Tracking

> Nhằm chống hiện tượng AI tự bịa đặt số liệu (Hallucination) theo quy định **RULE-02**, các trường dữ liệu biến động liên tục dưới đây được đánh dấu `null` để chờ nhân sự cập nhật thực tế tại điểm đến:

- [ ] **Hotels:** Bổ sung giá phòng thực tế theo mùa (`price_per_night.amount`) cho 4 khách sạn từ các API đại lý Booking/Agoda vào mùa cao điểm cuối năm.
- [ ] **Restaurants & Destinations:** Phối hợp cùng cộng đồng kiểm tra chéo và cập nhật điểm đánh giá trung bình thực tế (`rating_avg`) dựa trên Google Maps để hiển thị bảng xếp hạng.
- [ ] **Tours:** Xác minh và bổ sung biểu phí dịch vụ xe địa hình ATV chạy cát tự túc tại khu vực Bàu Trắng để cập nhật đầy đủ chi phí ẩn ngoài chương trình tour xe Jeep.