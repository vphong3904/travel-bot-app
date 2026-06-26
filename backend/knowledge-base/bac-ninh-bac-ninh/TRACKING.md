# 📊 TRACKING — Knowledge Base Bắc Ninh

**City slug:** `bac-ninh`
**Cập nhật lần cuối:** 2026-06-22
**Agent session:** T-014 mở rộng + hoàn thiện đầy đủ 12 file

---

## Trạng thái 12 file

| File | Task | Trạng thái | Ghi chú |
|---|---|---|---|
| `city.json` | T-001 | ✅ DONE (có sẵn) | UUID city: `3d01b622-f917-44bb-9054-c5b6001c52ee` |
| `destinations.json` | T-002 | ✅ DONE | 6 địa điểm |
| `hotels.json` | T-003 | ✅ DONE | 5 nơi lưu trú (1 homestay + 4 hotel) |
| `foods.json` | T-004 | ✅ DONE | 6 món đặc sản |
| `restaurants.json` | T-004 | ⚠️ PARTIAL | 3 nhà hàng — thiếu địa chỉ số nhà (chưa xác minh) |
| `transport.json` | T-005 | ✅ DONE | 4 tuyến getting_there + 6 phương tiện getting_around |
| `tours.json` | T-005 | ⚠️ PARTIAL | 3 tour — thiếu giá (chưa có nguồn Klook/Traveloka) |
| `events.json` | T-006 | ✅ DONE | 4 lễ hội, source: manual_curated |
| `shopping.json` | T-006 | ✅ DONE | 4 địa điểm mua sắm, source: manual_curated |
| `itineraries.json` | T-013 | ✅ DONE | 2 lịch trình (day trip + 2N1Đ), UUIDs khớp |
| `faq.md` | T-007 | ✅ DONE | 13 Q&A, 7 sections đầy đủ |
| `experiences.md` | T-008 | ✅ DONE | 6 địa điểm, 2 lịch trình, tips, bảng đặc sản |

---

## UUID Map — Tất cả Entity

### City
| Entity | UUID |
|---|---|
| Bắc Ninh (city) | `3d01b622-f917-44bb-9054-c5b6001c52ee` |

### Destinations
| Tên | UUID |
|---|---|
| Chùa Dâu (Pháp Vân) | `019eee91-da98-77e3-88cf-5a4eaa3b0000` |
| Chùa Bút Tháp (Ninh Phúc Tự) | `019eee91-da99-73ab-ed08-723eeaab0000` |
| Đền Đô (Đền Lý Bát Đế) | `019eee91-da9a-7187-0b60-85f0d79c0000` |
| Làng tranh dân gian Đông Hồ | `019eee91-da9b-7328-b2d5-0ed4fc216000` |
| Làng gốm Phù Lãng | `019eee91-da9c-739c-3d40-4492fb350000` |
| Đồi Lim – Hội Lim | `019eee91-da9d-726b-055c-bbf36add1000` |

### Hotels
| Tên | UUID |
|---|---|
| Aria Hotel Bắc Ninh | `019eee91-da9f-7163-9882-d33c84fb8000` |
| TTC Hotel Bắc Ninh | `019eee91-daa0-728b-37d8-47c5ba6f1000` |
| Khách sạn Phương Đông | `019eee91-daa1-7156-66e3-b8f56abf9000` |
| Bắc Ninh Palace Hotel | `019eee91-daa2-7378-5d05-1e35ebed7000` |
| Homestay Quan Họ Làng Diềm | `019eee91-daa3-7d44-3cc5-d90244910000` |

### Restaurants
| Tên | UUID |
|---|---|
| Quán Bún Cá Rô Bà Hoa | `019eee91-daa4-714e-659d-9719785b6000` |
| Khu ẩm thực phố Lý Thái Tổ | `019eee91-daa5-7121-62f9-e039ecadf000` |
| Nhà hàng Quan Họ Garden | `019eee91-daa6-71ec-a2a6-b15b0d938000` |

### Tours
| Tên | UUID |
|---|---|
| Tour Chùa Cổ Bắc Ninh – Cụm Thuận Thành | `019eee91-daa7-72ff-ca99-8bfe30797000` |
| Tour Làng Nghề Truyền Thống Bắc Ninh | `019eee91-daa8-736e-28f8-a166bd8ec000` |
| Tour Văn Hóa Quan Họ & Đền Đô | `019eee91-daaa-72eb-1148-8e80e32c8000` |

### Events
| Tên | UUID |
|---|---|
| Hội Lim – Lễ hội Quan họ | `019eee91-daab-728e-c5cd-d471b4834000` |
| Lễ hội Đền Đô | `019eee91-daac-739c-8fa4-294624e60000` |
| Lễ hội Chùa Dâu | `019eee91-daad-7344-75d7-83a492f6d000` |
| Lễ hội Tây Yên Tử | `019eee91-daad-7344-75d7-83a492f7e000` |

### Shopping
| Tên | UUID |
|---|---|
| Làng tranh Đông Hồ – Xưởng nghệ nhân | `019eee91-daae-7367-4fd7-6486e0219000` |
| Làng gốm Phù Lãng – Lò gốm | `019eee91-daaf-70ab-8428-74ef698b0000` |
| Làng Đình Bảng – Bánh phu thê | `019eee91-dab0-712b-a2b6-2e418a75f000` |
| Chợ Trung tâm thành phố Bắc Ninh | `019eee91-dab2-71e1-2848-1d94faf59000` |

### Itineraries
| ID slug | Mô tả |
|---|---|
| `bac-ninh-1n-daytrip` | Day trip 1 ngày từ Hà Nội |
| `bac-ninh-2n1d-culture` | 2 Ngày 1 Đêm — Văn hóa sâu & Làng nghề |

---

## ✅ Validation Checklist

- [x] Tất cả JSON có `_meta` block đầy đủ
- [x] Không có field `undefined` hoặc `NaN`
- [x] `city_id` trong mọi entity = `3d01b622-f917-44bb-9054-c5b6001c52ee`
- [x] `itineraries.json` — mọi `location_ref.id` đã có trong JSON cùng thư mục (hoặc `null` nếu không có entity tương ứng)
- [x] `faq.md` có 13 Q&A, đủ 7 sections
- [x] `experiences.md` có 6 địa điểm, 2 lịch trình, tips phân loại, bảng đặc sản
- [x] `faq.md` và `experiences.md` không copy số liệu từ JSON (RULE-21)
- [x] Không có placeholder `Lorem ipsum` hay `TBD`
- [x] Thông tin thiếu được đánh dấu `null` + `price_note: "// TODO"`

---

## TODO — Missing Fields cần bổ sung

### 🔴 Ưu tiên cao (ảnh hưởng UX)
- [ ] `restaurants.json`: Xác minh địa chỉ số nhà các quán ăn tại Foody.vn hoặc Google Maps
- [ ] `tours.json`: Xác minh giá tour tại Klook (klook.com/vi) hoặc Vietravel
- [ ] `hotels.json`: Xác minh giá phòng tại Booking.com hoặc Agoda + thêm booking_url

### 🟡 Ưu tiên trung bình
- [ ] `destinations.json`: Bổ sung tọa độ GPS (lat/lng) từ Google Maps
- [ ] `destinations.json`: Xác minh phí vào cửa (nếu có) từ trang chính thức
- [ ] `restaurants.json`: Thêm ít nhất 1–2 quán ăn khu vực huyện Thuận Thành (gần cụm chùa)
- [ ] `foods.json`: Bổ sung price_range từ Foody.vn

### 🟢 Ưu tiên thấp
- [ ] `hotels.json`: Bổ sung rating từ Booking.com hoặc Agoda
- [ ] `city.json`: Cập nhật `id` UUID thật khi đã có trong DB production
- [ ] `city.json`: Bổ sung `budget` (low/high) sau khi có dữ liệu giá thực tế
- [ ] Khu vực Bắc Giang cũ (Tây Yên Tử, Lục Ngạn): Cần task riêng để bổ sung destinations/foods cho khu vực này sau sáp nhập 2025
