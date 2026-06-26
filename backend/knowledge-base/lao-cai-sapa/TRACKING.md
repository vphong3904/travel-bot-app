# 📑 TRACKING FILE — LAO CAI SAPA

## 📊 Trạng Thái 12 File Knowledge Base

| File Name | Task ID | Status | Missing Fields / Notes |
|---|---|---|---|
| `city.json` | T-001 | ✅ DONE | Không |
| `destinations.json` | T-002 | ✅ DONE | Không |
| `hotels.json` | T-003 | ✅ DONE | `price_per_night.amount` set null do thiếu nguồn giá cố định mùa cao điểm |
| `foods.json` | T-004 | ✅ DONE | Không |
| `restaurants.json` | T-004 | ✅ DONE | Không |
| `transport.json` | T-005 | ✅ DONE | Không |
| `tours.json` | T-005 | ✅ DONE | `price.amount` set null (chờ cập nhật biểu giá theo mùa từ Klook) |
| `events.json` | T-006 | ✅ DONE | Không |
| `shopping.json` | T-006 | ✅ DONE | Không |
| `itineraries.json` | T-013 | ✅ DONE | Hoàn thiện 2 lịch trình đồng bộ khớp UUID 100% |
| `faq.md` | T-007 | ✅ DONE | Đủ 7 sections, tham chiếu JSON chuẩn chỉnh |
| `experiences.md` | T-008 | ✅ DONE | Đủ 5 sections, không trùng lặp số liệu thô |

## 🗺️ Bản Đồ Ánh Xạ Mã UUIDv7 Hệ Thống

- **Thành phố (City ID):** `019ef658-6c00-7100-8100-a12345678901`
- **Điểm đến (Destinations):**
  - Đỉnh Fansipan: `019ef658-6c00-7201-8201-b12345678902`
  - Bản Cát Cát: `019ef658-6c00-7202-8202-b12345678903`
  - Thung lũng Mường Hoa: `019ef658-6c00-7203-8203-b12345678904`
  - Thác Bạc: `019ef658-6c00-7204-8204-b12345678905`
  - Núi Hàm Rồng: `019ef658-6c00-7205-8205-b12345678906`
- **Cơ sở lưu trú (Hotels):**
  - Hotel de la Coupole: `019ef658-6c00-7301-8301-c12345678907`
  - Topas Ecolodge: `019ef658-6c00-7302-8302-c12345678908`
  - Sapa Clay House: `019ef658-6c00-7303-8303-c12345678909`
  - Mega Homestay Sapa: `019ef658-6c00-7304-8304-c12345678910`
- **Địa điểm ăn uống (Restaurants):**
  - Nhà hàng A Phủ: `019ef658-6c00-7401-8401-d12345678911`
  - Nhà hàng Đỗ Quyên: `019ef658-6c00-7402-8402-d12345678912`
  - Thắng Cố A Quỳnh: `019ef658-6c00-7403-8403-d12345678913`
- **Các tour đặc trưng (Tours):**
  - Tour Trekking Lao Chải - Tả Van: `019ef658-6c00-7501-8501-e12345678914`
  - Tour Cáp Treo Fansipan: `019ef658-6c00-7502-8502-e12345678915`
  - Tour Bản Tả Phìn Tắm Lá Thuốc: `019ef658-6c00-7503-8503-e12345678916`
- **Sự kiện & Lễ hội (Events):**
  - Lễ hội Roóng Poọc: `019ef658-6c00-7601-8601-f12345678917`
  - Lễ hội Gầu Tào: `019ef658-6c00-7602-8602-f12345678918`
  - Lễ hội mùa đông Sapa: `019ef658-6c00-7603-8603-f12345678919`
- **Mua sắm (Shopping):**
  - Chợ trung tâm Sapa: `019ef658-6c00-7701-8701-a12345678920`
  - HTX thổ cẩm Tả Phìn: `019ef658-6c00-7702-8702-a12345678921`
  - Đặc sản Sapa Lý Dao: `019ef658-6c00-7703-8703-a12345678922`
  - Chợ tình Sapa: `019ef658-6c00-7704-8704-a12345678923`

## 📝 Danh Sách Việc Cần Làm (Limbo TODO List)

- [ ] `hotels.json`: Cần bổ sung nguồn giá phòng xác thực cho mùa cao điểm lễ tết từ Agoda/Booking.
- [ ] `tours.json`: Liên hệ đại lý Klook/Traveloka để xin biểu giá chiết khấu đại lý cho năm 2026.