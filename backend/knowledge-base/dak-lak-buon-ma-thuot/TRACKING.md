# 📊 TRACKING — Knowledge Base Đắk Lắk – Buôn Ma Thuột

**City:** Buôn Ma Thuột (tỉnh Đắk Lắk, sau sáp nhập 1/7/2025: Đắk Lắk + Phú Yên)
**Slug:** `dak-lak-buon-ma-thuot`
**City UUID:** `9193ad16-91b7-43cd-86bf-e208fcdc43f1` (giữ nguyên từ `city.json` đã có sẵn trước đó — không sửa theo RULE-08)
**Generated:** 2026-06-22
**Agent:** Claude (Sonnet 4.6)

> ⚠️ Lưu ý: SQL seed (`backend/initdb/*.sql`) **không được dùng làm nguồn** cho bộ dữ liệu này theo RULE-06. Mọi giá/rating/địa chỉ số nhà chưa có nguồn xác thực ≥2 nguồn đáng tin cậy đều để `null` + ghi rõ trong `missing_fields`.

---

## 📁 Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `city.json` | T-001 | ✅ complete (đã có sẵn từ trước, không sửa — RULE-08) | id (UUID tạm chưa xác nhận DB thật), budget, stats, image_url |
| `destinations.json` | T-002 | 🟡 partial | coordinates chính xác cho Buôn Ako Dhong/Buôn Đôn, entry_fee Buôn Ako Dhong/Nhà đày, stats.rating_avg/review_count toàn bộ |
| `hotels.json` | T-003 | 🟡 partial | price_per_night cho 4/5 khách sạn (trừ homestay Buôn Đôn), rating, booking_url |
| `foods.json` | T-004 | 🟡 partial | price_range cho cà phê và bò một nắng (giá lẻ rất đa dạng) |
| `restaurants.json` | T-004 | 🟡 partial | rating toàn bộ, hours chính xác cho 2/4 quán, price_range Gà nướng Chicky |
| `transport.json` | T-005 | 🟡 partial | price_range chặng bay Đà Nẵng, price_info xe buýt nội thành |
| `tours.json` | T-005 | 🟡 partial | price.amount toàn bộ 4 tour (chưa có ≥2 nguồn khớp), group_size |
| `events.json` | T-006 | 🟡 partial (source: manual_curated) | cost chi tiết cho từng hoạt động con, event_date chính xác theo năm cho 2/4 sự kiện |
| `shopping.json` | T-006 | 🟡 partial (source: manual_curated) | opening_hours cho 2/4 địa điểm, price_range toàn bộ |
| `itineraries.json` | T-013 | 🟡 partial | estimated_cost từng block và total_estimated_cost (phụ thuộc các giá còn null ở JSON nguồn); khách sạn khu vực hồ Lắk chưa có nên 1 đêm trong lịch 3N2Đ không có entity lưu trú cụ thể tại đó |
| `faq.md` | T-007 | 🟡 partial | Một số mức ngân sách tổng hợp cần bổ sung khi có nguồn giá xác thực |
| `experiences.md` | T-008 | 🟡 partial | Giá/giờ cụ thể phụ thuộc các JSON liên quan đang còn null |
| `TRACKING.md` | — | ✅ complete | — |

> **Tổng kết status:** Toàn bộ nội dung chữ (tên, mô tả, địa điểm, tips, văn hóa, lịch sử) đã hoàn chỉnh, dựa trên thông tin tra cứu thực tế và đúng schema. Các trường số liệu nhạy cảm (giá phòng/tour/vé chính xác, rating, địa chỉ số nhà đầy đủ) để `null` + ghi rõ lý do trong `missing_fields` vì **chưa được xác minh qua ≥2 nguồn đáng tin cậy** theo RULE-02 — đây là quyết định có chủ đích, không phải bỏ sót.

---

## 🔑 UUID Map — Tất Cả Entity

### City
| Entity | UUID |
|---|---|
| Buôn Ma Thuột (city) | `9193ad16-91b7-43cd-86bf-e208fcdc43f1` |

### Destinations (8) — nhóm theo chủ đề
| Chủ đề | Tên | UUID |
|---|---|---|
| Thiên nhiên | Thác Dray Nur | `019eeef1-4b2d-7f2b-a944-c1c953ef1d9e` |
| Thiên nhiên | Hồ Lắk | `019eeef1-4b2d-75e1-9af4-406063c4dabd` |
| Lịch sử / Văn hóa | Khu du lịch Buôn Đôn | `019eeef1-4b2d-7f0b-aaea-66ade05b139c` |
| Thách thức / Mạo hiểm | Vườn quốc gia Yok Đôn | `019eeef1-4b2d-7439-92ba-060ea5aa057d` |
| Lịch sử | Nhà đày Buôn Ma Thuột | `019eeef1-4b2d-737a-a66b-b552346011e1` |
| Văn hóa cà phê | Bảo tàng Thế giới Cà phê | `019eeef1-4b2d-7083-a193-d75897a81e30` |
| Lịch sử / Văn hóa | Buôn Ako Dhong (Buôn Cô Thôn) | `019eeef1-4b2d-7cfc-b46b-658eca9794ac` |
| Thách thức / Mạo hiểm | Thác Thủy Tiên | `019eeef1-4b2d-7ade-bd84-975cde5f84d0` |

### Hotels (5) — đa dạng phân khúc
| Tên | Phân khúc | UUID |
|---|---|---|
| Homestay khu du lịch Buôn Đôn | Homestay | `019eeef1-4b2d-7732-9bc1-71acddf3dc81` |
| Troh Bư's Bungalows | Guesthouse 2★ | `019eeef1-4b2d-71ee-a58e-f4022c21fc16` |
| Sài Gòn Ban Mê Hotel | Hotel 4★ | `019eeef1-4b2d-7b30-94a7-9c1cd187a1d5` |
| Tru by Hilton Buon Ma Thuot City Centre | Hotel 4★ | `019eeef1-4b2d-7b36-a74c-9cec4ba6bdee` |
| Mường Thanh Luxury Buôn Ma Thuột | Hotel 5★ | `019eeef1-4b2d-7b7e-a3e1-a0b80b390e1d` |

### Restaurants (4)
| Tên | UUID |
|---|---|
| Quán Yang Sin – Ẩm thực Tây Nguyên | `019eeef1-4b2d-7401-873d-d340f37ea263` |
| Bún đỏ Đạt Lý | `019eeef1-4b2d-7f0a-b16f-3b8e42ef143d` |
| Chợ đêm Buôn Ma Thuột (khu vực Ngã Sáu) | `019eeef1-4b2d-71d7-aafc-3f6e642b47c3` |
| Gà nướng Chicky | `019eeef1-4b2d-778b-aadb-4038a7bc1db9` |

### Tours (4)
| Tên | UUID |
|---|---|
| Tour khám phá thác Dray Nur & Vườn quốc gia Yok Đôn | `019eeef1-4b2d-7113-aaa6-ac03188193dc` |
| Tour văn hóa Buôn Đôn — Sông Sêrêpôk & làng voi | `019eeef1-4b2d-7849-8767-774f0dda201f` |
| Tour Hồ Lắk & buôn làng M'nông | `019eeef1-4b2d-76f2-b002-d69664620197` |
| Tour văn hóa cà phê — Làng Cà phê Trung Nguyên & Bảo tàng Thế giới Cà phê | `019eeef1-4b2d-7c4d-b6f2-9277a05d8c0e` |

### Events (4, source: manual_curated)
| Tên | UUID |
|---|---|
| Lễ hội Cà phê Buôn Ma Thuột | `019eeef1-4b2d-7cd6-97ff-443a6f2b9564` |
| Hội Voi Buôn Đôn | `019eeef1-4b2d-722d-ae5b-a3b72b0cb769` |
| Hội đua thuyền độc mộc huyện Lắk | `019eeef1-4b2d-7607-8933-f4572e6a5797` |
| Lễ hội Cồng chiêng Tây Nguyên | `019eeef1-4b2d-7a6d-b6ac-b9168b13f541` |

### Shopping (4, source: manual_curated)
| Tên | UUID |
|---|---|
| Chợ trung tâm Buôn Ma Thuột | `019eeef1-4b2d-74a1-ae2f-ef86dba7064a` |
| Vincom Plaza Buôn Ma Thuột | `019eeef1-4b2d-7b6b-a518-2647ec3731ad` |
| Làng Cà phê Trung Nguyên | `019eeef1-4b2d-78bc-a25e-ac4677ba93d0` |
| Cửa hàng Quà Tây Nguyên | `019eeef1-4b2d-71e5-9c63-1a386b404b87` |

### Itineraries (2)
| ID (slug) | Audience | Duration |
|---|---|---|
| `dak-lak-buon-ma-thuot-2n1d-couple-cafe` | couple | 2N1Đ |
| `dak-lak-buon-ma-thuot-3n2d-family-nature-culture` | family | 3N2Đ |

> Đã chạy kiểm tra chéo bằng script Python: toàn bộ `location_ref.id` (khác null) trong `itineraries.json` khớp 100% với UUID thật trong `destinations.json` / `hotels.json` / `restaurants.json` / `tours.json` / `shopping.json` cùng thư mục — 0 lỗi mismatch. Các block không có entity tương ứng (sân bay Buôn Ma Thuột; quán ăn cụ thể tại Bản Đôn; lưu trú khu vực hồ Lắk) được để `id: null` đúng theo RULE-11 / SCHEMAS.md.

---

## 📝 TODO List — Missing Fields Cần Bổ Sung

1. **Giá phòng khách sạn** (`hotels.json`) — cần tra Booking.com + Agoda (≥2 nguồn khớp nhau) cho Sài Gòn Ban Mê, Tru by Hilton, Mường Thanh Luxury, Troh Bư's Bungalows; ghi kèm "(nguồn, MM/YYYY)".
2. **Giá vé tham quan** (`destinations.json.entry_fee`) — Buôn Ako Dhong, Nhà đày Buôn Ma Thuột, Thác Thủy Tiên cần Klook/Traveloka hoặc Google Maps xác nhận; Thác Dray Nur có giá tham khảo từ 1 nguồn (Kumho Samco, 30.000–40.000đ) nhưng chưa có nguồn thứ 2 khớp nên vẫn để null.
3. **Giá tour** (`tours.json.price.amount`) — cả 4 tour cần Klook + Traveloka xác nhận chéo vì hiện chưa tìm được giá công khai cụ thể cho gói ghép đoàn tại Buôn Ma Thuột.
4. **Giá món ăn / quán ăn** (`foods.json`, `restaurants.json`) — cà phê, bò một nắng, rượu cần, bún chìa cần Foody.vn + Google Maps xác nhận giá lẻ cụ thể.
5. **Giờ mở cửa chính xác** (`shopping.json`, một số `restaurants.json`) — cần Google Maps xác nhận từng địa điểm.
6. **Tọa độ GPS chính xác** (`destinations.json.coordinates`) — tọa độ Buôn Ako Dhong và Khu du lịch Buôn Đôn hiện là ước lượng khu vực, cần xác minh lại qua Google Maps trước khi dùng cho tính năng chỉ đường.
7. **Rating/review_count** — tuyệt đối không tự sinh số (RULE-02); cần lấy đúng từ Booking.com/Agoda/Google Maps khi triển khai production.
8. **Khách sạn khu vực hồ Lắk** — `hotels.json` hiện chỉ có lựa chọn tại trung tâm Buôn Ma Thuột và Buôn Đôn; cần bổ sung ít nhất 1 lựa chọn lưu trú gần hồ Lắk (ví dụ nhà dài homestay buôn Jun/buôn Lê) để các lịch trình mở rộng tới khu vực này không phải dùng `id: null` cho phần nghỉ đêm.
9. **event_date chính xác theo năm** cho Hội Voi Buôn Đôn và Hội đua thuyền độc mộc huyện Lắk — các hoạt động này thường gắn theo chu kỳ Lễ hội Cà phê (2 năm/lần) nhưng lịch cụ thể từng năm cần xác nhận lại gần ngày đi.
10. **Quán ăn cụ thể tại khu du lịch Bản Đôn** — hiện `restaurants.json` chưa có entity riêng cho khu vực này (chỉ có Gà nướng Chicky trong nội thành), khiến block "ăn trưa tại Bản Đôn" trong lịch trình 3N2Đ phải để `location_ref.id: null`.