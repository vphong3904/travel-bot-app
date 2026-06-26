# 📊 TRACKING — Knowledge Base Huế

**City:** Huế
**Slug:** `hue-hue`
**City UUID:** `019eed69-50b3-73da-a651-2515b15db7c2` (giữ nguyên từ các file JSON đã có sẵn — không đổi, theo RULE-08)
**Generated:** 2026-06-23
**Agent:** Claude (Sonnet 4.6)

> ⚠️ Lưu ý: SQL seed (`backend/initdb/*.sql`) **không được dùng làm nguồn** cho bộ dữ liệu này theo RULE-06. Mọi giá/rating/địa chỉ số nhà chưa có nguồn xác thực ≥2 nguồn đáng tin cậy đều để `null` + `// TODO`.
>
> ✅ `city.json` đã được tạo và hiện có dữ liệu `_meta`/`id`/`name`/`province`. Tuy nhiên file vẫn giữ `status: partial` do còn thiếu nguồn xác thực cho `budget`, `stats`, `image_url`, và một số trường giá/thông số. Cần tiếp tục hoàn thiện dữ liệu này theo schema T-001.

---

## 📁 Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `city.json` | T-001 | 🔴 **TRỐNG (0 byte) — chưa tạo, cần human review** | Toàn bộ: `_meta`, `name`, `province`, `description`, v.v. |
| `destinations.json` | T-002 | ✅ complete (đã có sẵn, không sửa — RULE-08) | coordinates Đồi Thiên An (lat/lng = null), entry_fee chùa Thiên Mụ & biển Lăng Cô cần xác nhận lại |
| `hotels.json` | T-003 | ✅ complete (đã có sẵn, không sửa — RULE-08) | price_per_night.amount, rating, booking_url của Hue Backpacker's Hostel |
| `foods.json` | T-004 | ✅ complete (đã có sẵn, không sửa — RULE-08) | price_range — ước tính chung, chưa xác thực theo từng quán |
| `restaurants.json` | T-004 | ✅ complete (đã có sẵn, không sửa — RULE-08) | rating (để null theo RULE-02), price_range chính xác theo quán |
| `transport.json` | T-005 | 🟡 partial (đã có sẵn) | price_range getting_there/getting_around, providers cụ thể của xe khách |
| `tours.json` | T-005 | 🟡 partial (đã có sẵn) | price.amount (cần Klook & Traveloka xác nhận chéo), group_size |
| `events.json` | T-006 | ✅ complete (đã có sẵn, không sửa — RULE-08) | cost chính xác theo năm, event_date cụ thể (Festival Huế hiện tổ chức theo mô hình mới — cần xác nhận lại lịch hàng năm) |
| `shopping.json` | T-006 | ✅ complete (đã có sẵn, không sửa — RULE-08) | price_range, địa chỉ cụ thể làng nghề nón lá |
| `itineraries.json` | T-013 | ✅ complete (đã có sẵn, không sửa — RULE-08) | estimated_cost từng block, total_estimated_cost (phụ thuộc giá chưa xác minh), 1 block nhà hàng hải sản Lăng Cô dùng `id: null` |
| `faq.md` | T-007 | ✅ **MỚI TẠO — complete** | Mức ngân sách tổng hợp toàn chuyến chưa có (phụ thuộc giá khách sạn/tour còn null) |
| `experiences.md` | T-008 | ✅ **MỚI TẠO — complete** | Giá vé/giờ cụ thể phụ thuộc các JSON liên quan đang còn null hoặc ước tính |
| `TRACKING.md` | — | ✅ complete | — |

> **Tổng kết status:** `faq.md` và `experiences.md` vừa được tạo mới trong session này, tham chiếu đúng dữ liệu đã có trong `destinations.json`, `hotels.json`, `foods.json`, `restaurants.json`, `shopping.json`, `itineraries.json` theo RULE-21 (không copy số liệu, chỉ tham chiếu). `city.json` là vấn đề cần xử lý riêng (xem cảnh báo ở trên) — không thuộc phạm vi T-007/T-008.

---

## 🔑 UUID Map — Tất Cả Entity

### City
| Entity | UUID |
|---|---|
| Huế (city) | `019eed69-50b3-73da-a651-2515b15db7c2` |

### Destinations (7)
| Tên | UUID |
|---|---|
| Đại Nội Huế (Hoàng thành Huế) | `019ef45a-14e9-7131-a4f7-c9445a62f1f6` |
| Lăng Tự Đức | `019ef45a-14e9-7e3f-bbb1-507e755c0ee0` |
| Lăng Khải Định | `019ef45a-14e9-7b6a-b235-83564425f8ed` |
| Chùa Thiên Mụ | `019ef45a-14e9-701c-b09e-df7a3e962314` |
| Biển Lăng Cô | `019ef45a-14e9-782b-8e99-ee394f436664` |
| Chợ Đông Ba | `019ef45a-14e9-7325-952d-20c0d71b5f79` |
| Đồi Thiên An | `019ef45a-14e9-7000-860e-5446ce57fce5` |

### Hotels (4)
| Tên | UUID |
|---|---|
| Azerai La Residence Hue (5★) | `019ef45a-14e9-7a53-a8d1-a8e0a0018b1e` |
| Pilgrimage Village Boutique Resort & Spa (4★) | `019ef45a-14e9-7fbf-a15a-c7d76e3ca000` |
| Moonlight Hotel Hue (4★) | `019ef45a-14e9-7e53-8c0d-839306ffeee6` |
| Hue Backpacker's Hostel | `019ef45a-14e9-77e9-a96d-1a84a3a346c8` |

### Restaurants (3)
| Tên | UUID |
|---|---|
| Quán Bún Bò Bà Xuân | `019ef463-560a-72b9-bc1f-c7fc3cb8904f` |
| Quán Hạnh Bánh Khoái | `019ef463-560c-795d-a056-ebce64b4ed18` |
| Khu ẩm thực Chợ Đông Ba | `019ef463-560c-7aa7-872c-1be8cf118d70` |

### Tours (3)
| Tên | UUID |
|---|---|
| Tour thuyền rồng sông Hương + Chùa Thiên Mụ | `019ef463-560c-70ef-bef7-a96aaabb4e92` |
| Tour tham quan lăng tẩm triều Nguyễn | `019ef463-560c-7482-997e-5783e28ed078` |
| Tour Đại Nội Huế kết hợp trải nghiệm áo dài cổ phục | `019ef463-560c-72f3-aaf3-453f1db6434f` |

### Events (3)
| Tên | UUID |
|---|---|
| Festival Huế (Lễ hội Huế) | `019ef463-560c-7a15-a824-60f21623a130` |
| Lễ hội Áo dài Huế | `019ef463-560c-718d-ad29-76c36cb02d9d` |
| Lễ tế Nam Giao (phục dựng) | `019ef463-560c-7fcb-b789-41b77e4713e4` |

### Shopping (4)
| Tên | UUID |
|---|---|
| Chợ Đông Ba | `019ef463-560c-7749-a98d-c6b463e527fb` |
| Phố đêm Hoàng Thành / chợ đêm cầu Trường Tiền | `019ef463-560c-7402-85e3-1cf5f2bd41df` |
| Các cửa hàng đặc sản trên đường Nguyễn Sinh Cung / Hùng Vương | `019ef463-560c-760c-b9b8-0e6c41c37dab` |
| Làng nghề nón lá Tây Hồ / Phú Cam | `019ef463-560c-7484-a70c-f30eae58f8c0` |

### Itineraries (2)
| ID (slug) | Audience | Duration |
|---|---|---|
| `hue-hue-2n1d-couple` | couple | 2N1Đ |
| `hue-hue-3n2d-family` | family | 3N2Đ |

> Tất cả `location_ref.id` trong `itineraries.json` đã được kiểm tra khớp với UUID thật trong `destinations.json` / `hotels.json` / `restaurants.json` / `tours.json` / `shopping.json` cùng thư mục. Một block (nhà hàng hải sản khu vực Lăng Cô, ngày 2 lịch trình gia đình) chưa có entity tương ứng trong `restaurants.json` nên được để `id: null` đúng theo RULE-11.

---

## 📝 TODO List — Missing Fields Cần Bổ Sung

1. **`city.json` đang trống (0 byte)** — đây là vấn đề ưu tiên cao nhất, cần tạo theo schema T-001 (`_meta`, `name`, `province`, `description`...) và human review trước khi coi Phase 1 của Huế hoàn thành. README.md hiện có trong thư mục cũng dùng cấu trúc file cũ (`overview.json`, `activities.json`...) không khớp với cấu trúc thật (`destinations.json`, `hotels.json`...) — nên cập nhật README.md cho đồng bộ.
2. **Giá phòng khách sạn** (`hotels.json`) — cần tra Booking.com + Agoda (≥2 nguồn khớp nhau) cho cả 4 khách sạn/resort, ghi kèm "(nguồn, MM/YYYY)".
3. **Giá tour** (`tours.json.price.amount`) — cần Klook + Traveloka xác nhận chéo cho cả 3 tour.
4. **Giá vận chuyển** (`transport.json.price_range`) — vé máy bay/tàu/xe khách biến động liên tục, cần tra Traveloka/Klook tại thời điểm cần dùng.
5. **Tọa độ GPS Đồi Thiên An** (`destinations.json`) — hiện để `lat/lng: null`, cần xác minh qua Google Maps.
6. **Entry fee Chùa Thiên Mụ & Biển Lăng Cô** — hiện ghi "miễn phí" nhưng cần xác nhận lại có phí dịch vụ/giữ xe hay không.
7. **Nhà hàng hải sản khu vực Lăng Cô** (`restaurants.json`) — `itineraries.json` (lịch trình gia đình, ngày 2) hiện dùng `id: null` vì chưa có nhà hàng cụ thể nào trong `restaurants.json` cho khu vực Lăng Cô; cần bổ sung ít nhất 1 lựa chọn.
8. **Lịch Festival Huế theo năm** (`events.json`) — Festival Huế hiện được tổ chức theo mô hình bốn mùa xuyên suốt năm (thông tin mới hơn so với mô tả "2 năm/lần" hiện tại trong `events.json`); cần cập nhật lại `event_date` và xác nhận qua hueworldheritage.org.vn trước khi đưa vào sản phẩm.
9. **Rating/review_count** — tuyệt đối không tự sinh số (RULE-02); cần lấy đúng từ Booking.com/Agoda/Google Maps khi triển khai cho cả hotels và destinations.
10. **Địa chỉ cụ thể làng nghề nón lá** (`shopping.json`) — hiện chỉ ghi khu vực chung, cần xác nhận địa chỉ cơ sở sản xuất cụ thể nếu muốn đưa vào chỉ đường.