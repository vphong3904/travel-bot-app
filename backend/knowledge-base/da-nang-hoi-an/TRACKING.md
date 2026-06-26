# 📊 TRACKING — Knowledge Base Đà Nẵng – Hội An

**City:** Đà Nẵng – Hội An
**Slug:** `da-nang-hoi-an`
**City UUID:** `9193ad16-91b7-43cd-86bf-e208fcdc43f1` (giữ nguyên từ `city.json` đã có sẵn — không đổi)
**Generated:** 2026-06-22
**Agent:** Claude (Sonnet 4.6)

> ⚠️ Lưu ý: SQL seed (`backend/initdb/*.sql`) **không được dùng làm nguồn** cho bộ dữ liệu này theo RULE-06. Mọi giá/rating/địa chỉ số nhà chưa có nguồn xác thực ≥2 nguồn đáng tin cậy đều để `null` + `// TODO`.

---

## 📁 Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `city.json` | T-001 | ✅ complete (đã có sẵn, không sửa — RULE-08) | — |
| `destinations.json` | T-002 | 🟡 partial | coordinates cần xác minh GPS chính xác, entry_fee, stats.rating_avg/review_count |
| `hotels.json` | T-003 | 🟡 partial | price_per_night.amount, rating, booking_url (cần Booking.com/Agoda xác nhận) |
| `foods.json` | T-004 | 🟡 partial | price_range một số món (cần Foody.vn xác nhận) |
| `restaurants.json` | T-004 | 🟡 partial | rating, hours chính xác, price_range (cần Google Maps/Foody xác nhận) |
| `transport.json` | T-005 | 🟡 partial | price_range getting_there/getting_around (biến động, cần Traveloka/Klook) |
| `tours.json` | T-005 | 🟡 partial | price.amount (cần Klook/Traveloka xác nhận) |
| `events.json` | T-006 | 🟡 partial | cost, event_date chính xác hàng năm cho DIFF; 1 event chưa có UUID (chờ human review) |
| `shopping.json` | T-006 | 🟡 partial | price_range, opening_hours (cần Google Maps xác nhận) |
| `itineraries.json` | T-013 | 🟡 partial | estimated_cost từng block, total_estimated_cost (phụ thuộc giá chưa xác minh); thiếu hotel khu vực Đà Nẵng (Mỹ Khê) trong hotels.json nên 1 block dùng id: null |
| `faq.md` | T-007 | 🟡 partial | Một số mức ngân sách tổng hợp cần bổ sung khi có nguồn giá xác thực |
| `experiences.md` | T-008 | 🟡 partial | Giá/giờ cụ thể phụ thuộc các JSON liên quan đang còn null |
| `TRACKING.md` | — | ✅ complete | — |

> **Tổng kết status:** Toàn bộ nội dung chữ (tên, mô tả, địa điểm, tips) đã hoàn chỉnh và đúng schema. Các trường số liệu nhạy cảm (giá, rating, địa chỉ số nhà, giờ mở cửa chính xác) để `null` + `// TODO` vì **chưa được xác minh qua ≥2 nguồn đáng tin cậy** theo RULE-02 — đây là quyết định có chủ đích, không phải bỏ sót.

---

## 🔑 UUID Map — Tất Cả Entity

### City
| Entity | UUID |
|---|---|
| Đà Nẵng – Hội An (city) | `9193ad16-91b7-43cd-86bf-e208fcdc43f1` |

### Destinations (8) — nhóm theo chủ đề
| Chủ đề | Tên | UUID |
|---|---|---|
| Lịch sử / Di sản | Phố cổ Hội An | `019eeecc-64d1-71e5-b9ca-8993c73198db` |
| Tâm linh / Lịch sử | Chùa Cầu (Lai Viễn Kiều) | `019eeecc-64d1-7730-945b-dc7a7ad10e11` |
| Thách thức / Mạo hiểm | Sun World Bà Nà Hills (Cầu Vàng) | `019eeecc-64d1-78a2-89c5-77bc400ec43d` |
| Tâm linh | Ngũ Hành Sơn (Marble Mountains) | `019eeecc-64d2-791e-86ac-2e604ee1915e` |
| Thiên nhiên | Bán đảo Sơn Trà | `019eeecc-64d2-7604-8f87-3883849e438f` |
| Biển | Biển Mỹ Khê | `019eeecc-64d2-7a18-a390-f73a6157e65c` |
| Tâm linh | Chùa Linh Ứng Bãi Bụt (Sơn Trà) | `019eeecc-64d2-7131-b2a7-87332f4a5ac6` |
| Thách thức / Mạo hiểm | Rừng dừa Bảy Mẫu (Cẩm Thanh) | `019eeecc-64d2-7599-9783-d36c8180c213` |

### Hotels (5)
| Tên | UUID |
|---|---|
| Hoi An Coco Homestay | `019eeecc-64d2-7293-8074-579adc2abfa2` |
| Hoi An Backpacker Hostel | `019eeecc-64d3-72d5-a33a-2ab1d536ec9f` |
| Little Hoi An Boutique Hotel (4★) | `019eeecc-64d3-716f-8954-42dcc494892e` |
| Anantara Hoi An Resort (5★) | `019eeecc-64d3-7324-a1c3-66cffa63284c` |
| Four Seasons Resort The Nam Hai (5★) | `019eeecc-64d3-7e43-aa78-11a7c5e14ce2` |

### Restaurants (4)
| Tên | UUID |
|---|---|
| Bánh mì Phượng | `019eeecc-64d3-7d8e-b647-0b12d38a2b2f` |
| Morning Glory Restaurant | `019eeecc-64d3-7073-aff1-0d8a889c7913` |
| Khu ẩm thực Chợ Hội An | `019eeecc-64d3-781b-aad7-6606a007adfc` |
| Quán hải sản đường Võ Nguyên Giáp | `019eeecc-64d3-709e-bb5d-7436a60d0a2c` |

### Tours (4)
| Tên | UUID |
|---|---|
| Tour Bà Nà Hills & Cầu Vàng 1 ngày | `019eeecc-64d3-7c81-900d-6e2d97315134` |
| Tour thuyền thúng Cẩm Thanh & Trà Quế | `019eeecc-64d3-761f-9882-dae977a1a0df` |
| Tour Ngũ Hành Sơn & Bán đảo Sơn Trà | `019eeecc-64d3-7108-86da-195236056be5` |
| Tour đêm thuyền hoa đăng sông Hoài | `019eeecc-64d3-722e-8af8-37624714b5b3` |

### Events (4, 1 chưa có UUID chờ review)
| Tên | UUID |
|---|---|
| Đêm phố cổ không dùng điện (đêm rằm) | `019eeecc-64d3-745d-8f48-dd103fb4d1ea` |
| Lễ hội Pháo hoa Quốc tế Đà Nẵng (DIFF) | `019eeecc-64d4-7cd2-8fba-1fe9d62fd284` |
| Lễ hội Quán Thế Âm Ngũ Hành Sơn | `019eeecc-64d4-705b-a1bd-5b156f0baa5b` |
| Lễ hội Cầu Bông làng rau Trà Quế | `null` — chờ human review trước khi cấp UUID |

### Shopping (5)
| Tên | UUID |
|---|---|
| Chợ Hội An | `019eeecc-64d4-7cbf-8482-e5af3c53c0c5` |
| Phố đèn lồng Trần Phú | `019eeecc-64d4-70ee-b80a-10a1c45b9332` |
| Chợ Cồn Đà Nẵng | `019eeecc-64d4-7db4-ac3d-169b63c3cbec` |
| Vincom Plaza Đà Nẵng | `019eeecc-64d4-7b22-8b58-27546a626e1e` |
| Làng nghề may đo Hội An | `019eeecc-64d4-771b-b3f6-a240478319be` |

### Itineraries (2)
| ID (slug) | Audience | Duration |
|---|---|---|
| `da-nang-hoi-an-2n1d-couple-heritage` | couple | 2N1Đ |
| `da-nang-hoi-an-3n2d-family-adventure` | family | 3N2Đ |

> Tất cả `location_ref.id` trong `itineraries.json` đã được kiểm tra khớp với UUID thật trong `destinations.json` / `hotels.json` / `restaurants.json` / `tours.json` / `shopping.json` cùng thư mục. Hai block không có entity tương ứng (sân bay Đà Nẵng; khách sạn khu Mỹ Khê) được để `id: null` đúng theo RULE-11 / SCHEMAS.md.

---

## 📝 TODO List — Missing Fields Cần Bổ Sung

1. **Giá phòng khách sạn** (`hotels.json`) — cần tra Booking.com + Agoda (≥2 nguồn khớp nhau) cho từng khách sạn, ghi kèm "(nguồn, MM/YYYY)".
2. **Giá vé tham quan** (`destinations.json.entry_fee`) — Bà Nà Hills, Ngũ Hành Sơn, vé phố cổ Hội An cần Klook/Traveloka xác nhận.
3. **Giá tour** (`tours.json.price.amount`) — cần Klook + Traveloka xác nhận chéo.
4. **Giá món ăn / quán ăn** (`foods.json`, `restaurants.json`) — cần Foody.vn + Google Maps xác nhận.
5. **Giờ mở cửa chính xác** (`shopping.json`, `restaurants.json`) — cần Google Maps xác nhận từng địa điểm.
6. **Tọa độ GPS chính xác** (`destinations.json.coordinates`) — tọa độ hiện tại là ước lượng khu vực, cần xác minh lại qua Google Maps trước khi dùng cho tính năng chỉ đường.
7. **Rating/review_count** — tuyệt đối không tự sinh số (RULE-02); cần lấy đúng từ Booking.com/Agoda/Google Maps khi triển khai.
8. **Khách sạn khu vực Đà Nẵng (Mỹ Khê)** — `hotels.json` hiện chỉ có lựa chọn tại Hội An; cần bổ sung ít nhất 1–2 khách sạn khu biển Đà Nẵng để `itineraries.json` (lịch trình gia đình) không phải dùng `id: null`.
9. **UUID cho "Lễ hội Cầu Bông làng rau Trà Quế"** (`events.json`) — cần human review và xác nhận thông tin trước khi cấp UUID chính thức, hiện để `id: null`.
10. **event_date chính xác theo năm** cho Lễ hội Pháo hoa Quốc tế Đà Nẵng (DIFF) và Lễ hội Quán Thế Âm — lịch tổ chức có thể thay đổi theo năm, cần xác nhận lại gần ngày đi.
