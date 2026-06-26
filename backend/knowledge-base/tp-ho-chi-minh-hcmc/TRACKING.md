# 📊 TRACKING — Knowledge Base TP. Hồ Chí Minh (Sài Gòn)

**City:** TP. Hồ Chí Minh
**Slug:** `tp-ho-chi-minh`
**City UUID:** `019eeda8-d830-72fe-8479-3d24a2698ee8`
**Generated:** 2026-06-22
**Agent:** Claude (Sonnet 4.6)

---

## 📁 Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `destinations.json` | T-002 | ✅ complete | coordinates (cần xác minh GPS), entry_fee một số điểm |
| `hotels.json` | T-003 | ✅ complete | price_per_night (cần Booking.com/Agoda), rating, booking_url |
| `foods.json` | T-004 | ✅ complete | price_range một số món (cần Foody.vn xác nhận) |
| `restaurants.json` | T-004 | ✅ complete | rating (không điền tự sinh), hours (xác nhận Google Maps) |
| `transport.json` | T-005 | ✅ complete | price_range getting_there (biến động, cần Traveloka) |
| `tours.json` | T-005 | ✅ complete | price.amount (cần Klook/Traveloka xác nhận) |
| `events.json` | T-006 | ✅ complete | — |
| `shopping.json` | T-006 | ✅ complete | price_range, opening_hours (xác nhận Google Maps) |
| `itineraries.json` | T-013 | ✅ complete | estimated_cost blocks (phụ thuộc giá chưa xác minh), total_estimated_cost |
| `faq.md` | T-007 | ✅ complete | — |
| `experiences.md` | T-008 | ✅ complete | — |
| `TRACKING.md` | — | ✅ complete | — |

---

## 🔑 UUID Map — Tất Cả Entity

### City
| Entity | UUID |
|---|---|
| TP. Hồ Chí Minh (city) | `019eeda8-d830-72fe-8479-3d24a2698ee8` |

### Destinations (7)
| Tên | UUID |
|---|---|
| Chợ Bến Thành | `019eee06-3f91-788d-9915-e65782ad4e85` |
| Dinh Độc Lập | `019eee06-3f91-77e4-a3c7-48acf0b9c31a` |
| Nhà thờ Đức Bà | `019eee06-3f91-7da8-9742-5d6f0abd16f5` |
| Bảo tàng Chứng tích Chiến tranh | `019eee06-3f91-7357-927f-0bb11a498d86` |
| Chùa Ngọc Hoàng | `019eee06-3f91-72fa-984b-77095ef88e7d` |
| Làng Du lịch Bình Quới | `019eee06-3f91-79cf-a456-1ee9d8b2bfc8` |
| Địa đạo Củ Chi | `019eee06-3f91-7f60-a2f0-f82d3a3e029e` |

### Hotels (5)
| Tên | UUID |
|---|---|
| Caravelle Saigon (5★) | `019eee06-3f91-768f-9249-b6d38342a711` |
| Hotel Nikko Saigon (5★) | `019eee06-3f91-7b23-ac37-d628425203d1` |
| Rex Hotel Saigon (4★) | `019eee06-3f91-7d1f-bbed-db572f618040` |
| Liberty Central Saigon Citypoint (4★) | `019eee06-3f91-71af-aaa9-76dff9405217` |
| Mango Backpackers Hostel | `019eee06-3f91-74d9-a826-c3474ca5b2c0` |

### Restaurants (4)
| Tên | UUID |
|---|---|
| Nhà Hàng Ngon | `019eee06-3f91-7537-8e66-4f523e0063c5` |
| Quán 94 Cơm Tấm Kiều Giang | `019eee06-3f91-79eb-8447-c8266f11f104` |
| Phở Hòa Pasteur | `019eee06-3f91-7af3-890b-aa8cca2afd2c` |
| Cục Gạch Quán | `019eee06-3f91-7404-be6a-065bd7f1aabe` |

### Tours (3)
| Tên | UUID |
|---|---|
| Tour Địa Đạo Củ Chi Nửa Ngày | `019eee06-3f91-75ea-9c91-fc5ad50cc5f0` |
| Tour Đồng Bằng Sông Cửu Long 1 Ngày | `019eee06-3f91-74b3-bae4-44b73d261c37` |
| Tour Khám Phá Sài Gòn Cổ — Walking & Food Tour | `019eee06-3f91-783b-a969-efcdf11f388b` |

### Events (4)
| Tên | UUID |
|---|---|
| Tết Nguyên Đán Sài Gòn | `019eee06-3f91-7bf0-b70d-6cb0337983f6` |
| Lễ Giỗ Tổ Hùng Vương & Ngày Giải Phóng 30/4 | `019eee06-3f91-75ec-a404-2b3e896e1c1f` |
| Lễ Hội Áo Dài TP. HCM | `019eee06-3f91-714b-9454-3afff768fb43` |
| Phố Đi Bộ Nguyễn Huệ Carnival | `019eee06-3f91-7bf0-b70d-6cb0337983f7` |

### Shopping (5)
| Tên | UUID |
|---|---|
| Chợ Bến Thành (shopping) | `019eee06-3f91-7aec-896c-1f222d688931` |
| Phố Mua Sắm Đồng Khởi | `019eee06-3f91-7346-a977-728aedd63b5b` |
| Chợ An Đông | `019eee06-3f91-7982-88b2-ab9f46268f51` |
| Vincom Center Đồng Khởi | `019eee06-3f91-7767-aa83-ae97b4f67cec` |
| Phố Bùi Viện — Khu Phố Tây | `019eee06-3f91-7767-aa83-ae97b4f67ced` |

### Itineraries (2)
| ID | Audience | Duration |
|---|---|---|
| `tp-ho-chi-minh-2n1d-firsttime` | any | 2 ngày 1 đêm |
| `tp-ho-chi-minh-3n2d-family` | family | 3 ngày 2 đêm |

---

## ✅ Checklist RULE Compliance

- [x] UUID tất cả entity: UUIDv7 generate mới (trừ city UUID lấy từ city-slugs.json)
- [x] city_id trong mọi entity = `019eeda8-d830-72fe-8479-3d24a2698ee8`
- [x] Không dùng SQL seed làm nguồn dữ liệu
- [x] Không hallucinate giá, rating, số liệu không có nguồn → ghi null + price_note TODO
- [x] Mọi `_meta` block có đủ: city, last_updated, agent_task, status, missing_fields, data_sources
- [x] faq.md: 11+ Q&A, đủ 7 sections (Thời điểm, Chi phí, Di chuyển, Lưu trú, Ẩm thực, Out-of-scope, An toàn)
- [x] experiences.md: 6 địa điểm, 2 lịch trình tóm tắt, tips phân loại, bảng đặc sản
- [x] faq.md và experiences.md KHÔNG copy số liệu từ JSON — dùng tham chiếu *(xem file.json)*
- [x] itineraries.json: 2 lịch trình khác audience và duration
- [x] Mọi location_ref.id trong itineraries.json khớp UUID thực trong file JSON cùng thư mục (hoặc null khi không có)
- [x] source: manual_curated ghi trong events.json và shopping.json

---

## 📝 TODO List — Missing Fields Cần Bổ Sung

### 🔴 Ưu tiên cao (ảnh hưởng trực tiếp trả lời chatbot)

1. **Giá vé địa điểm tham quan** — `destinations.json` → `entry_fee`:
   - Dinh Độc Lập: tra tại `tourism.hochiminhcity.gov.vn` hoặc Klook
   - Bảo tàng Chứng tích Chiến tranh: tra tại trang bảo tàng chính thức
   - Địa đạo Củ Chi: tra tại Klook (`klook.com/vi`)
   - Làng Bình Quới: liên hệ trực tiếp điểm đến

2. **Giá tour** — `tours.json` → `price.amount`:
   - Tour Củ Chi, Tour Mekong, Tour Walking Food: tra tại Klook (`klook.com/vi`) và Traveloka

3. **Giá phòng khách sạn** — `hotels.json` → `price_per_night.amount`:
   - Tất cả 5 khách sạn: tra tại Booking.com và Agoda (cần ≥2 nguồn khớp nhau)

### 🟡 Ưu tiên trung bình

4. **Tọa độ GPS** — `destinations.json` → `coordinates`:
   - Tất cả 7 địa điểm: xác minh lat/lng chính xác qua Google Maps

5. **Giá ăn uống** — `restaurants.json` → `price_range` và `foods.json` → `price_range`:
   - Xác nhận tại Foody.vn cho từng địa điểm

6. **Giờ mở cửa chính xác** — nhiều địa điểm:
   - Xác nhận cross-check Google Maps + website chính thức

7. **Booking URL** — `hotels.json`:
   - Lấy URL thực tế từ Booking.com hoặc Agoda cho từng khách sạn

### 🟢 Ưu tiên thấp

8. **Image URL** — hầu hết entity: cần URL ảnh thực từ nguồn chính thức
9. **Rating & review_count** — không tự sinh; cần từ Foody.vn hoặc Google Maps API
10. **estimated_cost trong itineraries** — tính lại sau khi xác minh giá vé và giá ăn uống