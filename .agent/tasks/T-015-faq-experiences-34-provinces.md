# Task T-015 — `faq.md` & `experiences.md` cho 34 tỉnh/thành sau sáp nhập

| Trường | Giá trị |
|---|---|
| **Task ID** | T-015 |
| **Status** | ⬜ TODO |
| **Priority** | 🟡 MEDIUM — mở rộng sau khi 10 thành phố ban đầu DONE |
| **Depends on** | T-007, T-008, T-014, **T-016** (5 folder city.json còn thiếu phải tạo trước) |

---

## 🎯 Mục tiêu

Viết `faq.md` và `experiences.md` cho **25 tỉnh/thành còn lại** (ngoài 10 thành phố ban đầu) để phủ đủ 34/34 tỉnh sau sáp nhập theo Nghị quyết 202/2025/QH15.

**Phạm vi:** Chỉ những tỉnh có `is_active = true` trong `city.json` sau khi T-014 checklist đã được xác nhận (SQL seed thật, UUID thật, ngân sách/ảnh thật). Không viết content cho skeleton `is_active = false`.

---

## ⚠️ Ràng buộc quan trọng — ĐỌC TRƯỚC KHI BẮT ĐẦU

### 0. BỎ QUA HOÀN TOÀN file SQL/initdb cho task này
`backend/initdb/*.sql` **không áp dụng** cho 25 tỉnh trong task này — không đọc, không tham
chiếu, không cố "khớp" với SQL. Toàn bộ tra cứu **chỉ** dựa vào nguồn liệt kê ở RULE-18
(chính phủ / Vietnam Tourism / Sở Du lịch tỉnh → Traveloka/Klook/Booking.com/Agoda →
TripAdvisor/Google Maps/Foody để tham khảo tips). Đây là nguồn tra cứu hợp lệ duy nhất.

### 1. Không có SQL seed cho 25 tỉnh mới
25 tỉnh này **không có trong** `backend/initdb/*.sql`, và cũng **không cần** tạo thêm SQL nào
để hoàn thành task này. Điều này có nghĩa:
- **KHÔNG được bịa** giá vé, địa chỉ, số điện thoại, rating
- **PHẢI dùng** nguồn bên ngoài (Nhóm 1 & 2 theo RULE-18) và ghi nguồn vào `data_sources`
- Mọi thông tin cụ thể (giá, giờ) **bắt buộc** kèm ghi chú nguồn + tháng/năm

### 2. Xác minh chéo bắt buộc cho giá
> **Quy tắc vàng cho T-015:** Giá vé, giá phòng, giá tour → chỉ ghi khi ≥ 2 nguồn (ưu tiên Traveloka, Klook, Booking.com) khớp nhau trong vòng 6 tháng gần nhất. Nếu chỉ 1 nguồn → ghi `"Tham khảo [nguồn] để có giá cập nhật"`, không ghi số.

### 3. Thông tin tỉnh sau sáp nhập
Một số tỉnh vừa sáp nhập có thể chưa có thông tin du lịch thống nhất. Khi đó:
- Ghi thông tin theo **đơn vị du lịch thực tế** (thành phố/điểm đến), không theo địa giới hành chính mới
- Ví dụ: `gia-lai-pleiku` — viết về Pleiku + Bình Định (giờ cùng tỉnh Gia Lai), nhưng không bịa thông tin về "du lịch tỉnh Gia Lai mới"

---

## 📂 Danh sách 25 tỉnh/thành cần làm

Sắp xếp theo mức độ nổi tiếng du lịch (ưu tiên làm trước):

### Nhóm A — Điểm đến nổi tiếng, nhiều nguồn dữ liệu (làm trước)
| # | Folder | Tỉnh mới | Điểm đại diện | Tỉnh cũ (tham khảo) |
|---|---|---|---|---|
| 1 | `ha-noi/` | Hà Nội (không sáp nhập) | Hà Nội | — |
| 2 | `thanh-hoa-sam-son/` | Thanh Hóa (không sáp nhập) | Sầm Sơn | — |
| 3 | `nghe-an-cua-lo/` | Nghệ An (không sáp nhập) | Cửa Lò | — |
| 4 | `hai-phong-cat-ba/` | Hải Phòng (= HP + Hải Dương) | Cát Bà | Hải Phòng cũ |
| 5 | `quang-tri/` | Quảng Trị (= QB + QT) | Đồng Hới/Phong Nha | Quảng Bình cũ |
| 6 | `dak-lak-buon-ma-thuot/` | Đắk Lắk (= ĐL + Phú Yên) | Buôn Ma Thuột | — |

### Nhóm B — Điểm đến quen biết, thông tin tương đối đầy đủ
| # | Folder | Tỉnh mới | Điểm đại diện | Tỉnh cũ |
|---|---|---|---|---|
| 7 | `son-la-moc-chau/` | Sơn La (không sáp nhập) | Mộc Châu | — |
| 8 | `lai-chau/` | Lai Châu (không sáp nhập) | TP Lai Châu | — |
| 9 | `lang-son/` | Lạng Sơn (không sáp nhập) | TP Lạng Sơn | — |
| 10 | `thai-nguyen/` | Thái Nguyên (= TN + Bắc Kạn) | TP Thái Nguyên | — |
| 11 | `phu-tho/` | Phú Thọ (= PT + Vĩnh Phúc + Hòa Bình) | TP Việt Trì | — |
| 12 | `hung-yen/` | Hưng Yên (= HY + Thái Bình) | TP Hưng Yên | — |

> ⚠️ **Đã loại `lam-dong-da-lat`** khỏi danh sách T-015 — đây là 1 trong 10 thành phố ban đầu,
> đã có `faq.md`/`experiences.md` từ T-007/T-008 (DONE), KHÔNG thuộc phạm vi "25 tỉnh còn thiếu".
> Việc liệt kê nhầm vào đây trong bản trước là lỗi tham chiếu, không đối chiếu với T-014.

### Nhóm C — Điểm đến ít phổ biến hơn, thông tin có thể hạn chế
| # | Folder | Tỉnh mới | Điểm đại diện | Tỉnh cũ | Ghi chú |
|---|---|---|---|---|---|
| 14 | `cao-bang/` | Cao Bằng (không sáp nhập) | TP Cao Bằng | — | |
| 15 | `ha-tinh-thien-cam/` | Hà Tĩnh (không sáp nhập) | Thiên Cầm | — | |
| 16 | `dien-bien-dien-bien-phu/` | Điện Biên (không sáp nhập) | TP Điện Biên Phủ | — | |
| 17 | `quang-ngai-ly-son/` | Quảng Ngãi (= QN + Kon Tum) | Đảo Lý Sơn | — | ⚠️ folder chưa tồn tại — cần T-016 trước |
| 18 | `gia-lai-pleiku/` | Gia Lai (= GL + Bình Định) | Pleiku | — | ⚠️ folder chưa tồn tại — cần T-016 trước |
| 19 | `dong-nai/` | Đồng Nai (= ĐN + Bình Phước) | TP Biên Hòa | — | |
| 20 | `tay-ninh-nui-ba-den/` | Tây Ninh (= TN + Long An) | Núi Bà Đen | — | ⚠️ folder chưa tồn tại — cần T-016 trước |
| 21 | `vinh-long/` | Vĩnh Long (= VL + Bến Tre + Trà Vinh) | TP Vĩnh Long | — | ⚠️ folder chưa tồn tại — cần T-016 trước |
| 22 | `dong-thap/` | Đồng Tháp (= ĐT + Tiền Giang) | Làng hoa Sa Đéc | — | |
| 23 | `bac-ninh/` | Bắc Ninh (= BN + Bắc Giang) | TP Bắc Ninh | — | |
| 24 | `tp-ho-chi-minh/` | TP. Hồ Chí Minh (= HCM + Bình Dương + BR-VT) | TP.HCM | — | ⚠️ folder chưa tồn tại — cần T-016 trước; **thiếu trong bản T-015 trước, đã bổ sung** |
| 25 | `can-tho/` | Cần Thơ (= CT + Sóc Trăng + Hậu Giang) | TP Cần Thơ | — | folder đã tồn tại — **thiếu trong bản T-015 trước, đã bổ sung** |
| 26 | `ca-mau/` | Cà Mau (= CM + Bạc Liêu) | TP Cà Mau | — | folder đã tồn tại — **thiếu trong bản T-015 trước, đã bổ sung** |

> Ghi chú: `bac-ninh/`, `cao-bang/`, `ha-noi/` đã có `faq.md` từ T-007 — task này chỉ cần tạo thêm `experiences.md` cho các folder đó.
>
> **5 dòng đánh dấu ⚠️ phụ thuộc T-016**: `quang-ngai-ly-son`, `gia-lai-pleiku`, `tay-ninh-nui-ba-den`,
> `vinh-long`, `tp-ho-chi-minh` — T-014 báo các folder này đã DONE nhưng thực tế chưa được tạo
> trong `knowledge-base/`. Phải hoàn thành T-016 (tạo `city.json` skeleton) trước khi viết
> `faq.md`/`experiences.md` cho 5 tỉnh này.

---

## 📖 Nguồn dữ liệu theo từng tỉnh

### Nguồn chung (dùng cho mọi tỉnh)
- **Chính phủ:** chinhphu.vn — xác nhận tên tỉnh sau sáp nhập
- **Vietnam Tourism:** vietnamtourism.gov.vn — điểm đến chính thức
- **Google Maps:** giờ mở cửa (xác nhận chéo với website chính thức)

### Nguồn giá vé & tour (cần ≥ 2 khớp nhau)
| Loại | Nguồn ưu tiên |
|---|---|
| Vé tham quan | Klook (klook.com/vi) + website chính thức điểm đến |
| Tour trọn gói | Traveloka (traveloka.com/vi-vn) + Vietravel (vietravel.com) |
| Khách sạn | Booking.com + Agoda |
| Vé xe/máy bay | Traveloka + website nhà xe/hãng bay |

### Nguồn Sở Du lịch từng tỉnh
| Tỉnh | Website Sở Du lịch |
|---|---|
| Hà Nội | hanoi.gov.vn / dulichhanoi.org.vn |
| Đà Nẵng | dulichdanang.gov.vn |
| Lâm Đồng | dulichlamdong.gov.vn |
| Khánh Hòa | dulichkhanhhoa.gov.vn |
| Quảng Ninh | quangninh.gov.vn |
| Các tỉnh khác | Tra Google: "Sở Du lịch [tên tỉnh]" |

---

## 🔢 Quy trình làm mỗi tỉnh

```
Bước 1: Đọc city.json → xác nhận is_active, tên điểm đại diện, province mới
Bước 2: Tra 2–3 nguồn (Vietnam Tourism + Klook/Traveloka + Sở Du lịch tỉnh)
Bước 3: Ghi nhận thông tin + đánh dấu rõ nguồn nào
Bước 4: Xác minh chéo: giá từ ≥ 2 nguồn, giờ từ Google Maps + website
Bước 5: Viết faq.md → checklist T-007
Bước 6: Viết experiences.md → checklist T-008
Bước 7: Ghi data_sources đầy đủ vào frontmatter
Bước 8: Đánh dấu tỉnh đó DONE trong partial note
```

---

## ✅ Checklist tổng (đánh dấu khi cả tỉnh DONE)

- [ ] `faq.md` có ≥ 8 Q&A, có 1 câu out-of-scope
- [ ] `experiences.md` có ≥ 3 sections chính + ≥ 2 lịch trình
- [ ] `data_sources` ghi đầy đủ tên nguồn + tháng/năm truy cập
- [ ] Không có giá/địa chỉ cụ thể thiếu nguồn
- [ ] Field `province` dùng tên tỉnh MỚI (theo provinces-34.md)
- [ ] Khớp với `city.json` cùng thư mục (RULE-15)

---

### Partial note
```
Đã xong:
Đang làm:
Còn lại: 26 dòng ở bảng trên (23 folder đã tồn tại + 3 folder lệ thuộc T-016 thêm vào, trừ
quang-ngai-ly-son/gia-lai-pleiku/tay-ninh-nui-ba-den/vinh-long/tp-ho-chi-minh phải chờ T-016 xong)
```
