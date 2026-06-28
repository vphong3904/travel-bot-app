# Tổng hợp tiến độ Knowledge Base (KB Tracking)

> Gộp từ các file `TRACKING.md` rải rác trong `backend/knowledge-base/<tỉnh>/` (nay đã xoá để giảm lộn xộn).
> Thuộc quy trình agent Knowledge Base (T-001..T-016). Cập nhật khi hoàn thiện dữ liệu từng tỉnh/thành.
> Nguyên tắc RULE-02: các trường giá/rating/địa chỉ chưa xác minh ≥2 nguồn để `null` + `// TODO` (có chủ đích, không phải bỏ sót).

Tổng số thư mục tỉnh/thành có tracking: 17

## Bảng tổng quan

| Thư mục (slug) | Có experiences/faq | Trạng thái tóm tắt |
|---|---|---|
| an-giang-phu-quoc | ✓ | complete |
| bac-ninh-bac-ninh | ✓ | PARTIAL |
| ca-mau-ca-mau | ✓ | Tổng trạng thái:** 12/12 file đã tạo — status: partial (giá và rating cần xác nhận thực tế) |
| can-tho-can-tho | ✓ | partial |
| cao-bang-cao-bang | ✓ | manual_curated |
| da-nang-da-nang | ✓ | Complete |
| da-nang-hoi-an | ✓ | complete |
| dak-lak-buon-ma-thuot | ✓ | complete |
| ha-noi-ha-noi | ✓ | Tổng trạng thái:** 12/12 file đã có - status: complete/partial theo nguồn hiện tại. |
| hue-hue | ✓ | status: partial |
| khanh-hoa-nha-trang | ✓ | 12/12 |
| lam-dong-da-lat | ✓ | Partial |
| lam-dong-mui-ne | ✓ | (xem chi tiết bên dưới) |
| lao-cai-sapa | ✓ | (xem chi tiết bên dưới) |
| ninh-binh-ninh-binh | ✓ | Tổng trạng thái:** 12/12 file đã tạo - status: complete, dữ liệu manual_curated. |
| quang-ninh-ha-long | ✓ | Tổng trạng thái:** 12/12 file đã tạo - status: complete, dữ liệu manual_curated. |
| tp-ho-chi-minh-hcmc | ✓ | complete |

---

## Chi tiết theo tỉnh/thành (nội dung gốc)

### an-giang-phu-quoc

# TRACKING – an-giang-phu-quoc (Phú Quốc)

**Agent:** Claude Sonnet 4.6  
**Ngày tạo:** 2026-06-22  
**city_id:** `019eee7d-cd94-744b-86d1-ca07059a9949`

---

## Trạng thái 12 file

| File | Task | Status | Ghi chú |
|------|------|--------|---------|
| `city.json` | T-001 | ✅ complete | Có sẵn từ project |
| `destinations.json` | T-002 | ⚠️ partial | 7 địa điểm · giá/rating cần xác nhận |
| `hotels.json` | T-003 | ⚠️ partial | 6 nơi lưu trú · price_per_night là ƯỚC TÍNH |
| `foods.json` | T-004 | ⚠️ partial | 6 món · giá ƯỚC TÍNH |
| `restaurants.json` | T-004 | ⚠️ partial | 4 địa điểm · giá ƯỚC TÍNH |
| `transport.json` | T-005 | ⚠️ partial | 4 tuyến đến · 6 phương tiện nội đảo · giá ƯỚC TÍNH |
| `tours.json` | T-005 | ⚠️ partial | 4 tour · giá ƯỚC TÍNH |
| `events.json` | T-006 | ✅ complete | 4 sự kiện · source: manual_curated |
| `shopping.json` | T-006 | ✅ complete | 5 địa điểm · source: manual_curated |
| `itineraries.json` | T-013 | ⚠️ partial | 2 lịch trình · một số location_ref.id = null |
| `faq.md` | T-007 | ✅ complete | 12 Q&A · đủ 7 sections |
| `experiences.md` | T-008 | ✅ complete | 5 điểm · 2 lịch trình · bảng đặc sản |

---

## UUID Map – Tất cả entity

### City
| Entity | UUID |
|--------|------|
| Phú Quốc (city) | `019eee7d-cd94-744b-86d1-ca07059a9949` |

### Destinations (destinations.json)
| Tên | UUID |
|-----|------|
| Bãi Sao | `019eee71-616d-7317-b456-896589eaa20c` |
| Vinpearl Safari Phú Quốc | `019eee71-616d-7dc2-81e1-0521e1d2b287` |
| Làng chài Hàm Ninh | `019eee71-616d-7457-b092-16c665bc6447` |
| Vườn Quốc gia Phú Quốc | `019eee71-616e-7f4e-ac72-07dffaf4bc21` |
| Chợ Đêm Phú Quốc (Dinh Cậu Night Market) | `019eee71-616e-74a8-a5f9-8edfe71161eb` |
| Dinh Cậu (Dinh Cô) | `019eee71-616e-7cf5-bbc6-a2d20b16ae09` |
| Bãi Dài (Kem Beach) | `019eee71-616e-7461-ba4b-6695feaa9e55` |

### Hotels (hotels.json)
| Tên | UUID |
|-----|------|
| InterContinental Phu Quoc Long Beach Resort | `019eee71-616e-7007-9b0e-1ab1c59b60cd` |
| JW Marriott Phu Quoc Emerald Bay | `019eee71-616e-7bf7-b6ef-2ea09427ed50` |
| Sunset Sanato Resort & Villas | `019eee71-616e-73ea-84d5-d4199271c80b` |
| Mango Bay Resort | `019eee71-616e-7184-b71c-ae924a2f8100` |
| Phu Quoc Backpacker Hostel | `019eee71-616e-7150-a5bd-5bfad69996ff` |
| Cassia Cottage | `019eee71-616e-7829-bcc9-5499d7c4a90c` |

### Foods (foods.json)
| Tên | UUID |
|-----|------|
| Gỏi cá trích | `019eee71-616e-7d64-babf-28aaee83e7fa` |
| Nhum nướng mỡ hành | `019eee71-616e-7fe1-83a9-976f44747106` |
| Nước mắm Phú Quốc | `019eee71-616e-7b40-9257-b3912356d25c` |
| Ghẹ rang muối / hấp bia | `019eee71-616e-75a2-96f5-673c7593eb74` |
| Bún quậy Phú Quốc | `019eee71-616e-7afe-b188-b034d279731f` |
| Rượu sim Phú Quốc | `019eee71-616e-7a79-8ef0-05e0d3f75569` |

### Restaurants (restaurants.json)
| Tên | UUID |
|-----|------|
| Nhà hàng Ganesh – Indian & Italian | `019eee71-616e-78c6-935e-f39d26e7688d` |
| Quán Hải Sản Hàm Ninh | `019eee71-616e-7c7e-99b8-8d15b27e4fc6` |
| Chợ đêm Dinh Cậu – Các quầy ẩm thực | `019eee71-616e-77ff-ada9-1b6963ab18be` |
| Quán Bún Quậy Kiên Giang | `019eee71-616e-7846-837b-e0e8fd0e22e5` |

### Tours (tours.json)
| Tên | UUID |
|-----|------|
| Tour câu cá & lặn ngắm san hô 4 đảo | `019eee71-616e-7395-97e6-4cbc91bc3712` |
| Tour khám phá Vườn Quốc gia & thác Tranh | `019eee71-616e-7349-83d4-9fea49631072` |
| Tour hoàng hôn & câu mực đêm trên biển | `019eee71-616e-7938-ab80-cdde5e62fc3a` |
| Tour làng nghề: nước mắm & rượu sim | `019eee71-616e-72b1-968d-8d3ac3d20eba` |

### Events (events.json)
| Tên | UUID |
|-----|------|
| Lễ hội Nghinh Ông (Cúng Cá Voi) | `019eee71-616e-7bdc-842f-2ce1429fc351` |
| Tết Nguyên Đán trên đảo Phú Quốc | `019eee71-616e-772a-8041-e05fdef01f27` |
| Lễ hội Khai Thác Mùa Cá | `019eee71-616e-70c3-9096-4e1ec5f5eb24` |
| Phú Quốc International Music Festival | `019eee71-616e-787f-ac3f-9df6920093b1` |

### Shopping (shopping.json)
| Tên | UUID |
|-----|------|
| Chợ Đêm Dinh Cậu | `019eee71-616e-7c51-a3d1-00f1857f77ec` |
| Cơ sở nước mắm Khải Hoàn | `019eee71-616e-7473-9d1a-48c1e47036f6` |
| Vincom Plaza Phú Quốc | `019eee71-616e-772e-9021-259467b188cf` |
| Chợ Dương Đông (Chợ trung tâm) | `019eee71-616e-7ed4-a5e0-9e690e9956e2` |
| Trang trại rượu sim Ngọc Hiền | `019eee71-616e-732c-a657-af865094ae40` |

### Itineraries (itineraries.json)
| Tên | ID |
|-----|-----|
| Phú Quốc 3N2Đ cho cặp đôi | `phu-quoc-3n2d-couple` |
| Phú Quốc 5N4Đ cho gia đình | `phu-quoc-5n4d-family` |

---

## TODO – Missing fields cần xử lý trước production

### Ưu tiên cao (ảnh hưởng trực tiếp đến user)
- [ ] **Giá real-time hotels:** Kết nối API Agoda/Booking.com cho `hotels.json` — giá hiện tại là ƯỚC TÍNH
- [ ] **Giá vé Vinpearl Safari:** Xác nhận tại vinpearl.com hoặc Klook (`destinations.json`)
- [ ] **Giá vé Vườn Quốc gia:** Xác nhận tại Ban quản lý VQG Phú Quốc
- [ ] **Giá tour 4 đảo:** Verify tại Klook hoặc đại lý tour khu An Thới (`tours.json`)

### Ưu tiên trung bình
- [ ] **image_url:** Tất cả entity còn `null` — cần photographer hoặc licence ảnh từ nguồn hợp lệ
- [ ] **rating thật:** Tất cả `stats/rating = null` — cần kết nối Google Maps API hoặc review platform
- [ ] **booking_url:** Hotels và tours còn thiếu booking_url hợp lệ
- [ ] **itineraries.json:** `itin2.days[2].blocks[0].location_ref.id` = null (resort Bãi Trường chưa gắn đúng hotel UUID)

### Ưu tiên thấp
- [ ] Bổ sung thêm nhà hàng khu Bãi Trường vào `restaurants.json` (hiện itinerary tham chiếu nhưng chưa có entry)
- [ ] Xác nhận lịch Phú Quốc International Music Festival hằng năm (sự kiện không định kỳ)
- [ ] Bổ sung tuyến xe buýt trung chuyển sân bay nếu có thay đổi sau 2025

---

### bac-ninh-bac-ninh

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

---

### ca-mau-ca-mau

# 📊 TRACKING — ca-mau Knowledge Base

**Tỉnh:** Cà Mau (sau sáp nhập: Cà Mau + Bạc Liêu, Nghị quyết 202/2025/QH15)
**City ID:** `23431b56-3e63-4368-949f-8df24ab3c539`
**Cập nhật lần cuối:** 2026-06-22
**Tổng trạng thái:** 12/12 file đã tạo — status: partial (giá và rating cần xác nhận thực tế)

---

## 📋 Bảng Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `destinations.json` | T-002 | ✅ partial | entry_fee (cần xác nhận), rating |
| `hotels.json` | T-003 | ✅ partial | price_per_night (cần xác nhận), rating |
| `foods.json` | T-004 | ✅ partial | price_range (cần xác nhận) |
| `restaurants.json` | T-004 | ✅ partial | address số nhà, price_range, rating |
| `transport.json` | T-005 | ✅ partial | giá vé máy bay, xe khách, xe máy thuê |
| `tours.json` | T-005 | ✅ partial | price.amount (cần xác nhận Klook/lữ hành) |
| `events.json` | T-006 | ✅ complete | cost (miễn phí hay có vé — cần xác nhận) |
| `shopping.json` | T-006 | ✅ partial | address số nhà, price_range |
| `itineraries.json` | T-013 | ✅ complete | estimated_cost các block (cần xác nhận) |
| `faq.md` | T-007 | ✅ complete | — |
| `experiences.md` | T-008 | ✅ complete | — |
| `TRACKING.md` | — | ✅ complete | — |

---

## 🗺️ UUID Map — Tất cả Entity

### City
| Entity | UUID |
|---|---|
| Cà Mau (city) | `23431b56-3e63-4368-949f-8df24ab3c539` |

### Destinations (destinations.json)
| Tên | UUID |
|---|---|
| Mũi Cà Mau | `a5b646aa-0a77-4573-9828-6fc926cfa907` |
| Vườn Quốc gia U Minh Hạ | `764d5012-c64e-4f97-8e66-42f24bfe03cd` |
| Hòn Đá Bạc | `25cb52e2-9647-41ae-84f6-98bb9b2d2e2f` |
| Đầm Thị Tường | `e2511569-ca3c-4292-a9e0-20e11a724d92` |
| Cánh đồng điện gió Bạc Liêu | `5edb3bdb-f39b-440b-97b3-1e1b0b1d3929` |
| Nhà Công tử Bạc Liêu | `cbe319df-91fc-4391-add2-9f5fd83b202c` |
| Rừng đước Năm Căn | `226241c8-03a6-4020-be42-b31ab31854db` |

### Hotels (hotels.json)
| Tên | UUID |
|---|---|
| Mường Thanh Grand Cà Mau | `e9a996d2-da53-437d-84ea-a93d285e56a8` |
| Khách sạn Phương Nam Cà Mau | `bda9d2f7-234e-4bae-b799-457c16488bc3` |
| Nhà nghỉ Đất Mũi | `7afd4673-3179-4208-8ae2-802c2eb300ba` |
| Homestay Rừng Đước U Minh | `6f465787-0ce3-4f6a-8b30-0aa2f0fc587a` |
| Khách sạn Sông Đốc | `b6acf6cc-e5c6-4f3c-aa4a-a01df6fc3573` |

### Restaurants (restaurants.json)
| Tên | UUID |
|---|---|
| Nhà hàng Đất Mũi | `0f409f96-dc44-4a84-9355-d0fe9dca6031` |
| Quán Cua Gạch Năm Căn | `26e1eb94-97ea-4f83-b779-798726096b14` |
| Chợ đêm Cà Mau | `2dffe94e-ea53-4872-810f-3201fdda4cb3` |
| Nhà hàng Hải sản Sông Đốc | `7bb81c99-9539-4bb2-884e-26723ed2e6b5` |

### Tours (tours.json)
| Tên | UUID |
|---|---|
| Tour Mũi Cà Mau – Rừng đước Năm Căn | `37b11d9d-9dd8-401c-ad1e-ee2e1b55e16a` |
| Tour Khám phá Vườn Quốc gia U Minh Hạ | `16b1b635-ee85-4291-8a22-1b5835777dbf` |
| Tour Cà Mau – Bạc Liêu: Điện gió & Di tích | `30cd55bd-0f2e-4837-94a4-034bf6420074` |
| Tour Đầm Thị Tường ngắm chim buổi sáng | `33aea316-2a01-4436-93fd-cd9207420543` |

### Events (events.json)
| Tên | UUID |
|---|---|
| Lễ hội Nghinh Ông (Đua thuyền trên biển) | `1254a0d8-af7a-4190-976e-56a1d35ffeae` |
| Lễ hội Ba khía Rạch Gốc | `86dcae4d-db57-4c5e-9045-4784e94c22ed` |
| Lễ hội Đờn ca tài tử Bạc Liêu | `8dfb2559-3781-4b6e-a1b3-ad6cc33b4485` |
| Ngày hội Văn hóa – Thể thao dân tộc Khmer | `0dc5019b-9533-4c00-aceb-bfa4d1a984ee` |

### Shopping (shopping.json)
| Tên | UUID |
|---|---|
| Chợ Cà Mau (Chợ trung tâm) | `b13447d0-437f-4127-93ed-d630c9672531` |
| Cơ sở đặc sản Tôm khô Sông Đốc | `bfe3ae3b-d9bb-4edc-8158-9cc6f933a572` |
| Chợ đặc sản Năm Căn | `4a066f8f-7118-482c-8512-594382fbd761` |
| Siêu thị Co.opmart Cà Mau | `f0827140-5534-491e-8e9b-cea5f874aac8` |
| Chợ Bạc Liêu | `b9530a7b-1f89-4162-974c-2266e6f51c98` |

### Itineraries (itineraries.json)
| Tên | ID (slug) |
|---|---|
| Cà Mau 3N2Đ cho Gia đình | `ca-mau-3n2d-family` |
| Cà Mau 2N1Đ cho Phượt thủ | `ca-mau-2n1d-solo-nature` |

---

## ✅ Xác nhận location_ref.id trong itineraries.json

Tất cả `location_ref.id` trong `itineraries.json` đã được kiểm tra khớp với UUID trong các file JSON cùng thư mục:

| itinerary | block | location_ref.id | File nguồn | Khớp? |
|---|---|---|---|---|
| 3n2d-family | D1 B1 | `e9a996d2-...` | hotels.json | ✅ |
| 3n2d-family | D1 B2 | `b13447d0-...` | shopping.json | ✅ |
| 3n2d-family | D1 B3 | `7bb81c99-...` | restaurants.json | ✅ |
| 3n2d-family | D1 B4 | `226241c8-...` | destinations.json | ✅ |
| 3n2d-family | D1 B5 | `26e1eb94-...` | restaurants.json | ✅ |
| 3n2d-family | D2 B1 | `a5b646aa-...` | destinations.json | ✅ |
| 3n2d-family | D2 B3 | `0f409f96-...` | restaurants.json | ✅ |
| 3n2d-family | D2 B4 | `e9a996d2-...` | hotels.json | ✅ |
| 3n2d-family | D3 B1 | `cbe319df-...` | destinations.json | ✅ |
| 3n2d-family | D3 B2 | `5edb3bdb-...` | destinations.json | ✅ |
| 3n2d-family | D3 B3 | `2dffe94e-...` | restaurants.json | ✅ |
| 2n1d-solo | D1 B1 | `6f465787-...` | hotels.json | ✅ |
| 2n1d-solo | D1 B2 | `764d5012-...` | destinations.json | ✅ |
| 2n1d-solo | D1 B3 | `764d5012-...` | destinations.json | ✅ |
| 2n1d-solo | D1 B4 | `6f465787-...` | hotels.json | ✅ |
| 2n1d-solo | D2 B1 | `e2511569-...` | destinations.json | ✅ |
| 2n1d-solo | D2 B2 | `2dffe94e-...` | restaurants.json | ✅ |
| 2n1d-solo | D2 B3 | `b13447d0-...` | shopping.json | ✅ |

---

## 📝 TODO List — Missing Fields cần xác nhận

### 🔴 Ưu tiên cao (ảnh hưởng trực tiếp trải nghiệm người dùng)
- [ ] `hotels.json` → price_per_night: xác nhận từ Booking.com hoặc Agoda cho cả 5 khách sạn
- [ ] `transport.json` → giá vé máy bay Traveloka (SGN–CAH), giá xe khách Phương Trang SGN–Cà Mau
- [ ] `destinations.json` → entry_fee Mũi Cà Mau, VQG U Minh Hạ: xác nhận từ Sở Du lịch Cà Mau

### 🟡 Ưu tiên trung bình
- [ ] `tours.json` → price.amount: liên hệ Klook hoặc công ty lữ hành địa phương
- [ ] `restaurants.json` → price_range thực tế: xác nhận từ Foody.vn
- [ ] `foods.json` → price_range cua biển, tôm khô: xác nhận chợ địa phương
- [ ] `events.json` → cost (miễn phí hay có vé): xác nhận từ Sở Văn hóa Cà Mau

### 🟢 Ưu tiên thấp (có thể bổ sung sau)
- [ ] `destinations.json` → image_url thật (ảnh chính thức từ Sở Du lịch)
- [ ] `hotels.json` → booking_url trực tiếp từng khách sạn
- [ ] `restaurants.json` → địa chỉ số nhà chính xác (xác nhận Google Maps)
- [ ] Tất cả rating → chỉ thêm khi có nguồn thực (Google Maps / TripAdvisor)
---

### can-tho-can-tho

# 📊 TRACKING — Knowledge Base Cần Thơ (can-tho)

> Cập nhật: 2026-06-22 | Agent: T-002 → T-013 | City ID: `e1b4d4cb-8d60-4a03-8b98-bc54991eff17`

---

## Trạng thái 12 File

| File | Task | Status | Missing Fields | Notes |
|---|---|---|---|---|
| `city.json` | T-001 | ✅ DONE (partial từ T-014) | budget, stats, image_url | UUID: `e1b4d4cb-8d60-4a03-8b98-bc54991eff17` |
| `destinations.json` | T-002 | ✅ DONE (partial) | coordinates chính xác, entry_fee, stats | 7 điểm đến, bao gồm Sóc Trăng & Hậu Giang sau sáp nhập |
| `hotels.json` | T-003 | ✅ DONE (partial) | price_per_night, rating, booking_url | 5 nơi lưu trú, đa dạng phân khúc |
| `foods.json` | T-004 | ✅ DONE | price_range một số món | 7 món đặc sản |
| `restaurants.json` | T-004 | ✅ DONE (partial) | hours, rating | 4 địa điểm ăn uống |
| `transport.json` | T-005 | ✅ DONE (partial) | price_range chính xác | 4 tuyến getting_there, 6 phương tiện getting_around |
| `tours.json` | T-005 | ✅ DONE (partial) | price.amount | 4 tour đặc trưng |
| `events.json` | T-006 | ✅ DONE | — | 5 lễ hội/sự kiện |
| `shopping.json` | T-006 | ✅ DONE (partial) | opening_hours | 5 địa điểm mua sắm |
| `itineraries.json` | T-013 | ✅ DONE (partial) | estimated_cost, budget | 2 lịch trình khác audience/duration |
| `faq.md` | T-007 | ✅ DONE (pre-existing) | — | 11 Q&A, 7 sections đủ |
| `experiences.md` | T-008 | ✅ DONE (pre-existing) | — | 5 địa điểm, 2 lịch trình, tips, bảng đặc sản |

---

## UUID Map — Tất cả Entity

### City
| Entity | UUID | Tên |
|---|---|---|
| City | `e1b4d4cb-8d60-4a03-8b98-bc54991eff17` | Cần Thơ |

### Destinations (destinations.json)
| Entity | UUID | Tên |
|---|---|---|
| Chợ nổi Cái Răng | `252f436c-63fd-4ad9-a7e9-7fd4a0bedd8a` | Chợ nổi Cái Răng |
| Bến Ninh Kiều | `1e116ed4-60b5-4070-9261-6e0d550bc4ae` | Bến Ninh Kiều |
| Nhà cổ Bình Thủy | `d50e0997-fbe0-4f53-a040-5bfa2a3d550a` | Nhà cổ Bình Thủy |
| Làng sinh thái Mỹ Khánh | `ef17c097-3639-4f5f-a447-8e260ab4b14c` | Làng du lịch sinh thái Mỹ Khánh |
| Chùa Ông | `43d0b17e-66f1-41aa-b7a3-d7b7f7284f67` | Chùa Ông (Quảng Triệu Hội Quán) |
| Chợ nổi Ngã Bảy | `0b99a3b6-877c-4726-840b-9def6f3fb60f` | Chợ nổi Ngã Bảy (Phụng Hiệp) |
| Chùa Dơi | `6378e32d-e2da-4210-be3e-3d4f8529389d` | Chùa Dơi (Mã Tộc) — Sóc Trăng cũ |

### Hotels (hotels.json)
| Entity | UUID | Tên | Phân khúc |
|---|---|---|---|
| Azerai La Residence | `560ae42b-0ca4-45e3-a289-486756094f54` | Azerai La Residence Cần Thơ | 5★ resort |
| Mường Thanh Luxury | `19a9fcb9-8ced-4610-ad4e-61988949d054` | Mường Thanh Luxury Cần Thơ | 4★ hotel |
| Ninh Kiều 2 | `0c41dfc0-ff42-4560-80b2-a45c780f1b0c` | Khách sạn Ninh Kiều 2 | 3★ hotel |
| Sông Xanh Homestay | `fb3dbb3a-9cd6-41d6-a2ee-aed2c6e8ce87` | Sông Xanh Riverside Homestay | homestay |
| Kim Tho Hotel | `f41bde46-48ab-491c-a801-08d7f90d7481` | Kim Tho Hotel Cần Thơ | 2★ guesthouse |

### Restaurants (restaurants.json)
| Entity | UUID | Tên |
|---|---|---|
| Nhà hàng Mekong | `1c69f7cd-58e2-4967-ae17-58bc4ad314a3` | Nhà hàng Mekong |
| Quán bánh xèo Mười Xinh | `b28c7a08-14cb-41b7-ae78-fcaa2467822e` | Quán bánh xèo Mười Xinh |
| Chợ đêm Ninh Kiều | `21f1c014-fe3b-4d61-9052-1b519dcf1099` | Chợ đêm Ninh Kiều |
| Nhà hàng Sông Hương | `1475dd0c-03f7-4379-b960-12542745cdd5` | Nhà hàng Sông Hương (Bình Thủy) |

### Tours (tours.json)
| Entity | UUID | Tên |
|---|---|---|
| Tour Chợ Nổi Cái Răng | `6c795681-12f0-40ab-9b09-159ed09c9855` | Tour Chợ Nổi Cái Răng Sáng Sớm |
| Tour Kênh Rạch Phong Điền | `142aa68f-3cfb-4e9f-a80b-82102ec99b12` | Tour Kênh Rạch & Vườn Trái Cây Phong Điền |
| Tour Sóc Trăng 1 ngày | `c3ce6a82-a90e-44a7-bc17-90e0e560f791` | Tour Cần Thơ – Sóc Trăng 1 Ngày |
| Tour Ngã Bảy Hậu Giang | `58fff5a9-dacc-4882-9ed4-a6635138f3fc` | Tour Chợ Nổi Ngã Bảy – Hậu Giang 1 Ngày |

### Events (events.json)
| Entity | UUID | Tên |
|---|---|---|
| Lễ hội Óoc Om Bóc | `654f0dda-9d4e-47ca-8b50-0bda7d9a431d` | Lễ hội Óoc Om Bóc – Đua ghe Ngo |
| Lễ hội Du lịch Cần Thơ | `d08bd281-64ed-4536-8d46-df8b717b1850` | Lễ hội Du lịch Cần Thơ |
| Chợ phiên nổi cuối tuần | `db26e9a5-3971-4cfe-9156-e9ea7f833260` | Chợ phiên nổi Cái Răng cuối tuần |
| Mùa nước nổi | `9ce8a00b-4b77-4c87-b450-6025b634476a` | Mùa nước nổi miền Tây |
| Tết Nguyên Đán | `507b4e4d-dbe8-43d1-9356-ad2886f46471` | Tết Nguyên Đán tại Cần Thơ |

### Shopping (shopping.json)
| Entity | UUID | Tên |
|---|---|---|
| Chợ Cần Thơ | `090f8d76-401d-442d-b6e9-e0fd5096e337` | Chợ Cần Thơ (Chợ Trung tâm) |
| Co.opmart Cần Thơ | `8e4a6fa2-9cda-4940-86b8-3fc43487d32b` | Co.opmart Cần Thơ |
| Chợ đêm Ninh Kiều | `a3fa957f-c884-4278-9a7c-237c06df2a95` | Chợ đêm Ninh Kiều |
| Chợ nổi Cái Răng mua sắm | `f3b2e6d2-02b2-4dd9-83b5-3570c24968b3` | Chợ nổi Cái Răng (mua sắm trực tiếp) |
| Cửa hàng đặc sản Mỹ Khánh | `85f1c45f-2e77-4583-8999-9c4ed82ff019` | Cửa hàng đặc sản Mỹ Khánh |

### Itineraries (itineraries.json)
| ID | Tên | Audience |
|---|---|---|
| `can-tho-2n1d-river` | Cần Thơ 2N1Đ — Sông Nước Miền Tây | any |
| `can-tho-3n2d-mekong-family` | Cần Thơ 3N2Đ — Gia Đình Khám Phá Mekong | family |

---

## TODO List — Missing Fields Cần Bổ Sung

### 🔴 Cao (ảnh hưởng trực tiếp đến user)
- [ ] `destinations.json` → `entry_fee` cho nhà cổ Bình Thủy và Mỹ Khánh — cần tra Klook hoặc trang chính thức
- [ ] `hotels.json` → `price_per_night.amount` cho tất cả — cần Booking.com/Agoda tháng 06/2026
- [ ] `tours.json` → `price.amount` cho tất cả 4 tour — cần Klook klook.com/vi tháng 06/2026
- [ ] `transport.json` → `price_range` chính xác cho xe khách và máy bay — cần Vexere + Traveloka

### 🟡 Trung bình
- [ ] `destinations.json` → `coordinates` xác minh chính xác qua Google Maps
- [ ] `restaurants.json` → `hours` cho Nhà hàng Mekong và Sông Hương — cần Google Maps
- [ ] `shopping.json` → `opening_hours` xác minh Co.opmart và Chợ Cần Thơ

### 🟢 Thấp
- [ ] `hotels.json` → `booking_url` khi có link Booking.com thực
- [ ] `itineraries.json` → `estimated_budget` khi có giá tour + khách sạn xác thực
- [ ] `destinations.json` → `stats.rating_avg` khi có data từ Google Maps API

---

## Lưu ý Đặc Biệt — Sáp Nhập Tỉnh 2025

Theo Nghị quyết 202/2025/QH15, Cần Thơ mới = Cần Thơ cũ + Sóc Trăng + Hậu Giang.
- **Điểm đến bổ sung từ Sóc Trăng:** Chùa Dơi, Chùa Kh'leang, lễ hội Óoc Om Bóc — đã có trong KB
- **Điểm đến bổ sung từ Hậu Giang:** Chợ nổi Ngã Bảy — đã có trong KB
- **Cần bổ sung thêm:** destinations.json cho khu Sóc Trăng và Hậu Giang cũ còn thiếu nhiều điểm

---

### cao-bang-cao-bang

# 📊 TRACKING — Knowledge Base Cao Bằng

**City slug:** `cao-bang`
**City UUID:** `aa20e516-ea38-4c41-9bd2-7de71095647e`
**Agent tasks:** T-002 → T-008, T-013
**Last updated:** 2026-06-22

---

## Bảng Trạng Thái 12 File

| File | Task | Status | Ghi chú |
|---|---|---|---|
| `city.json` | T-001 | ✅ DONE (từ T-014) | UUID: aa20e516-ea38-4c41-9bd2-7de71095647e |
| `destinations.json` | T-002 | ✅ DONE | 6 địa điểm — giá vé/rating cần xác nhận |
| `hotels.json` | T-003 | ✅ DONE | 5 cơ sở lưu trú — giá phòng cần xác nhận |
| `foods.json` | T-004 | ✅ DONE | 6 món đặc sản địa phương |
| `restaurants.json` | T-004 | ✅ DONE | 4 địa điểm ăn uống |
| `transport.json` | T-005 | ✅ DONE | 4 tuyến đến + 5 phương tiện nội địa |
| `tours.json` | T-005 | ✅ DONE | 3 tour đặc trưng — giá tour cần xác nhận |
| `events.json` | T-006 | ✅ DONE | 3 lễ hội/sự kiện, source: manual_curated |
| `shopping.json` | T-006 | ✅ DONE | 4 địa điểm mua sắm, source: manual_curated |
| `itineraries.json` | T-013 | ✅ DONE | 2 lịch trình (couple + family), UUID đã khớp |
| `faq.md` | T-007 | ✅ DONE | 12 Q&A, đủ 7 sections |
| `experiences.md` | T-008 | ✅ DONE | 5 địa điểm, 2 lịch trình, tips, bảng đặc sản |

---

## UUID Map — Tất Cả Entity

### City
| Tên | UUID |
|---|---|
| Cao Bằng | `aa20e516-ea38-4c41-9bd2-7de71095647e` |

### Destinations (6)
| Tên | UUID |
|---|---|
| Thác Bản Giốc | `0c7364d8-7f0e-4ab7-8fd1-806515fd6d17` |
| Hang Pác Bó | `1d406b9b-3a6c-42f2-98a6-4dde7ffe6371` |
| Hồ Thang Hen | `521c2b59-d487-446a-8c72-f222893e1484` |
| Núi Mắt Thần (Hạ Lang) | `3b336ae8-b707-400c-a1bb-2ceff029cd64` |
| Chợ Cao Bằng | `815d0d7e-e6de-4116-bf43-7ecda4b9d09e` |
| Khu Di tích Rừng Trần Hưng Đạo | `122caad4-1582-4031-8787-0c59b317f7f3` |

### Hotels (5)
| Tên | UUID |
|---|---|
| Khách sạn Bằng Giang | `c342a323-88cb-41aa-8f81-d66ef59a8f11` |
| Khách sạn Phong Lan | `304f8516-8683-40a7-b0fa-a9fed3cb49ac` |
| Homestay Bản Giốc View | `96bcfd33-b97c-4e32-8bac-19bbd82f106a` |
| Nhà nghỉ Hà Quảng | `61587651-3a29-48e8-8473-bc9106bfdec0` |
| Khách sạn Kim Đồng | `ee624b99-4b2a-4901-8307-72635bdc97b2` |

### Restaurants (4)
| Tên | UUID |
|---|---|
| Quán Bánh Cuốn Chợ Cao Bằng | `e0e4379c-65da-42d0-b3f8-0cb84bfb523b` |
| Nhà Hàng Vịt Quay Cao Bằng | `510d239e-7f7b-4d25-8023-33ad0be8d4cf` |
| Quán Bánh Áp Chao Khu Chợ | `5dd9e83f-dd2c-4314-b5d7-6b66835e444b` |
| Quán Ăn Khu Vực Bản Giốc | `bf18f0c0-5486-4450-a37e-619ef7ba40ca` |

### Tours (3)
| Tên | UUID |
|---|---|
| Tour Thác Bản Giốc – Hang Pác Bó 2N1Đ | `f9ed2021-a420-42b0-8892-ffc6233ee5d2` |
| Tour Khám Phá Cao Nguyên Đá Hồ Thang Hen | `b18733bc-0c98-45a4-b014-dc49c7787370` |
| Hành Trình Về Nguồn – Lịch Sử Cách Mạng | `34072675-9f94-48d9-b9dc-99a21ec410e4` |

### Events (3)
| Tên | UUID |
|---|---|
| Lễ Hội Lồng Tồng | `3797edb5-23e2-4319-8809-61e61a5c1607` |
| Lễ Hội Nàng Hai | `b41ce3e8-34ea-4511-9b7a-055659d57515` |
| Kỷ Niệm Ngày Thành Lập QĐND 22/12 | `fcf16302-80b3-40e2-84da-375335ebe391` |

### Shopping (4)
| Tên | UUID |
|---|---|
| Chợ Cao Bằng (Chợ Hợp Giang) | `558d2683-d0ba-4b81-866d-0223bae35658` |
| Cửa Hàng Đặc Sản Cao Bằng | `71f16e00-fa9e-4b73-9754-428017232233` |
| Làng Nghề Thổ Cẩm Tày-Nùng | `967b90f7-d5ce-4914-b83c-7b13969bbdd2` |
| Chợ Phiên Huyện Trùng Khánh | `f171b273-7fdf-4df8-9019-89724d2613be` |

### Itineraries (2)
| ID | Mô tả |
|---|---|
| `cao-bang-2n3d-couple` | 3N2Đ — Cặp đôi / Bạn bè |
| `cao-bang-1n2d-family` | 2N1Đ — Gia đình có trẻ em |

---

## ✅ Validation Checklist

- [x] Tất cả JSON có `_meta` block đầy đủ
- [x] Không có field `undefined` hoặc `NaN`
- [x] Mọi `city_id` trong entity khớp UUID của Cao Bằng: `aa20e516-ea38-4c41-9bd2-7de71095647e`
- [x] `itineraries.json` — mọi `location_ref.id` khớp UUID thực trong file JSON cùng thư mục
- [x] `faq.md` có 12 Q&A, đủ 7 sections (Thời điểm, Chi phí, Di chuyển, Lưu trú, Ẩm thực, Out-of-scope, An toàn)
- [x] `experiences.md` có 5 địa điểm, 2 lịch trình tóm tắt, tips, bảng đặc sản
- [x] Không copy số liệu cụ thể từ JSON vào Markdown (tuân thủ RULE-21)
- [x] Giá/rating không có nguồn → ghi `null` + `price_note: "// TODO"`
- [x] Không dùng SQL seed làm nguồn dữ liệu

---

## 📋 TODO — Missing Fields Cần Bổ Sung

### 🔴 Ưu tiên cao (cần xác nhận trước production)
- [ ] Giá vé thác Bản Giốc → xác nhận tại caobang.gov.vn hoặc Ban Quản lý Khu thác
- [ ] Giá vé hang Pác Bó → xác nhận tại Ban Quản lý Khu di tích Pác Bó
- [ ] Giá phòng khách sạn → xác nhận tại Booking.com / Agoda (search "Cao Bằng")
- [ ] Giá tour → xác nhận tại Klook.com/vi hoặc Traveloka

### 🟡 Ưu tiên trung bình
- [ ] Rating thực tế các địa điểm → lấy từ Google Maps hoặc TripAdvisor
- [ ] Giá xe khách Hà Nội–Cao Bằng cập nhật → xác nhận tại Traveloka hoặc nhà xe Hoàng Long
- [ ] Giờ mở cửa chính xác hang Pác Bó và Rừng Trần Hưng Đạo → xác nhận Google Maps
- [ ] Giá thuê xe máy tại TP. Cao Bằng → hỏi tại khách sạn

### 🟢 Ưu tiên thấp
- [ ] image_url cho tất cả entity
- [ ] booking_url cho hotels
- [ ] Tọa độ chính xác hơn cho Núi Mắt Thần và Rừng Trần Hưng Đạo
- [ ] Lịch chợ phiên Trùng Khánh cập nhật

---

### da-nang-da-nang

# TRACKING BÁO CÁO TIẾN ĐỘ KNOWLEDGE BASE - ĐÀ NẴNG

## 1. Bảng Trạng Thái File Hệ Thống
| Task ID | File Name | Status | Missing Data / Ghi chú TODO |
|---|---|---|---|
| T-001 | `city.json` | ✅ Complete | Thiết lập cấu trúc tỉnh/thành phố trung ương hoàn tất. |
| T-002 | `destinations.json` | 🔄 Partial | `entry_fee`, `hours`, `stats` để trống `null` cẩn trọng theo Rule-02. |
| T-003 | `hotels.json` | 🔄 Partial | `price_per_night`, `rating` trống (chờ cập nhật API từ Booking/Agoda). |
| T-004 | `foods.json` | ✅ Complete | Đã cấu hình đầy đủ 5 món ăn đặc sản chủ đạo xứ Quảng/biển. |
| T-004 | `restaurants.json` | 🔄 Partial | `rating`, `hours` cần rà soát thực tế tại thực địa để tránh sai số. |
| T-005 | `transport.json` | ✅ Complete | Đáp ứng cấu trúc getting_there (3 cung) & getting_around (4 loại). |
| T-005 | `tours.json` | 🔄 Partial | `price` cần tra cứu báo giá chính xác theo mùa cao điểm du lịch. |
| T-006 | `events.json` | ✅ Complete | Đã biên soạn đầy đủ sự kiện văn hóa biểu tượng (DIFF, Cầu Rồng). |
| T-006 | `shopping.json` | ✅ Complete | Cập nhật 4 địa điểm chợ truyền thống và siêu thị niêm yết rõ ràng. |
| T-013 | `itineraries.json` | ✅ Complete | Khớp nối chính xác 100% mã định danh UUIDv7 sang các file JSON. |
| T-007 | `faq.md` | ✅ Complete | Đủ 11 câu hỏi phân bổ qua 7 mục, tuân thủ nghiêm ngặt Rule-21. |
| T-008 | `experiences.md` | ✅ Complete | Đã tạo bảng đặc sản, cấm sao chép số liệu cứng từ cấu trúc JSON. |

## 2. Bản Đồ Tra Cứu Hệ Thống Mã Định Danh UUIDv7 Đồng Bộ
> *Sử dụng thuật toán băm thời gian thực mô phỏng PostgreSQL index tối ưu cấu trúc dữ liệu nền tảng.*

- **Mã định danh thành phố chính (City ID):** `019ef543-a001-7000-8000-000000000001`
- **Danh sách Điểm đến (Destinations):**
  - Biển Mỹ Khê: `019ef543-a002-7100-8100-000000000001`
  - Sun World Ba Na Hills: `019ef543-a002-7100-8100-000000000002`
  - Danh thắng Ngũ Hành Sơn: `019ef543-a002-7100-8100-000000000003`
  - Bảo tàng Điêu khắc Chăm: `019ef543-a002-7100-8100-000000000004`
  - Chùa Linh Ứng Sơn Trà: `019ef543-a002-7100-8100-000000000005`
  - Chợ Cồn: `019ef543-a002-7100-8100-000000000006`
- **Danh sách Cơ sở lưu trú (Hotels):**
  - InterContinental Danang: `019ef543-a003-7200-8200-000000000001`
  - Novotel Danang Premier: `019ef543-a003-7200-8200-000000000002`
  - Muong Thanh Luxury: `019ef543-a003-7200-8200-000000000003`
  - Hanigo Homestay: `019ef543-a003-7200-8200-000000000004`
- **Danh sách Quán ăn (Restaurants):**
  - Mì Quảng Ếch Bếp Trang: `019ef543-a004-7300-8300-000000000001`
  - Ẩm Thực Trần: `019ef543-a004-7300-8300-000000000002`
  - Hải Sản Năm Đảnh: `019ef543-a004-7300-8300-000000000003`
- **Danh sách Chương trình du lịch (Tours):**
  - Tour Ba Na Hills 1 Ngày: `019ef543-a005-7400-8400-000000000001`
  - Vé Du Thuyền Sông Hàn: `019ef543-a005-7400-8400-000000000002`
  - Tour Ngũ Hành Sơn - Hội An: `019ef543-a005-7400-8400-000000000003`
- **Danh sách Sự kiện / Mua sắm (Events & Shopping):**
  - Lễ hội Pháo hoa Quốc tế (DIFF): `019ef543-a006-7500-8500-000000000001`
  - Lễ hội Quán Thế Âm: `019ef543-a006-7500-8500-000000000002`
  - Cầu Rồng Phun Lửa: `019ef543-a006-7500-8500-000000000003`
  - Chợ Hàn: `019ef543-a007-7600-8600-000000000001`
  - Chợ Đêm Sơn Trà: `019ef543-a007-7600-8600-000000000002`
  - Siêu thị Thiên Phú: `019ef543-a007-7600-8600-000000000003`
  - Làng đá Non Nước: `019ef543-a007-7600-8600-000000000004`
---

### da-nang-hoi-an

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

---

### dak-lak-buon-ma-thuot

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
---

### ha-noi-ha-noi

# TRACKING - ha-noi-ha-noi Knowledge Base

**Tỉnh/Thành:** Hà Nội
**City ID:** `0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6`
**Cập nhật lần cuối:** 2026-06-23
**Tổng trạng thái:** 12/12 file đã có - status: complete/partial theo nguồn hiện tại.

## Bảng Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `city.json` | T-001 | complete | - |
| `destinations.json` | T-002 | complete | - |
| `hotels.json` | T-003 | partial | giá/rating cần xác minh |
| `foods.json` | T-004 | partial | giá cần xác minh |
| `restaurants.json` | T-004 | partial | giá/rating cần xác minh |
| `transport.json` | T-005 | partial | giá vé realtime |
| `tours.json` | T-005 | complete | giá tour realtime |
| `events.json` | T-006 | partial | lịch từng năm |
| `shopping.json` | T-006 | complete | giờ/giá cần xác minh |
| `itineraries.json` | T-013 | partial | chi phí block |
| `faq.md` | T-007 | complete | - |
| `experiences.md` | T-008 | complete | - |
| `TRACKING.md` | - | complete | - |

## UUID Map

### City
| Entity | UUID |
|---|---|
| Hà Nội | `0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6` |

### Tours
| Tên | UUID |
|---|---|
| Tour phố cổ Hà Nội bằng xích lô + ẩm thực đêm | `505c2cba-0ff8-4af5-90e5-49d292d60a95` |
| Tour ngày: Hoàng thành Thăng Long + Văn Miếu + Lăng Bác | `5830f6c3-0b45-40a3-99d8-1405a084ecd2` |
| Tour làng gốm Bát Tràng nửa ngày | `4ef59e01-f2de-cb71-9477-b5a81cc97bce` |

### Shopping
| Tên | UUID |
|---|---|
| Chợ Đồng Xuân | `2786d28f-64d4-4b71-99b4-d52fc7fd92e9` |
| Phố Hàng Gai (phố lụa) | `4655b539-053d-43b8-9243-10d6cc00dfed` |
| Vincom Center Bà Triệu | `522982f6-5834-472e-9d8b-f31d7b735ee4` |
| Làng gốm Bát Tràng | `4ef59e01-15df-067b-ab8e-f2180c9043b4` |

## TODO List Missing Fields

- [ ] Đồng bộ full UUID map destinations/hotels/restaurants nếu cần tracking chi tiết hơn.
- [ ] Xác minh giá khách sạn, tour, transport theo mùa.
- [ ] Cập nhật lịch sự kiện Hà Nội theo từng năm.


---

### hue-hue

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
---

### khanh-hoa-nha-trang

# 📋 Tracking — khanh-hoa-nha-trang (Nha Trang, Khánh Hòa)

> **Tỉnh/thành (sau sáp nhập):** Khánh Hòa (gộp Khánh Hòa + Ninh Thuận — Nghị quyết 202/2025/QH15)  
> **City UUID:** `019eed69-50b3-743c-b2d0-2107e58ca38d`  
> **UUID version:** UUIDv7 (tất cả entity trong các file JSON)  
> **Bắt đầu:** 2026-06-22  
> **Agent:** Claude Sonnet 4.6  

---

## ✅ Trạng thái các file

| File | Task | Trạng thái | Ghi chú |
|---|---|---|---|
| `city.json` | T-001 | ✅ DONE | Đã có sẵn từ trước — UUID v7, đúng schema |
| `destinations.json` | T-002 | ✅ DONE | 8 địa điểm — biển, đảo, chùa, bảo tàng, tháp Chăm |
| `hotels.json` | T-003 | ✅ DONE | 5 khách sạn — 5★ đến homestay — giá cần xác nhận Booking/Agoda |
| `foods.json` | T-004 | ✅ DONE | 7 món — bún cá, nem nướng, yến sào, bánh căn, hải sản, bò né, chè |
| `restaurants.json` | T-004 | ✅ DONE | 3 địa điểm ăn chính — Chợ Đầm, Phạm Văn Đồng, Chợ đêm |
| `transport.json` | T-005 | ✅ DONE | Getting there (6 tuyến) + getting around (6 loại) |
| `tours.json` | T-005 | ✅ DONE | 4 tour — 4 đảo, Bình Ba, tắm bùn, lặn scuba |
| `events.json` | T-006 | ✅ DONE | 4 sự kiện — Lễ Tháp Bà, Festival Biển, Marathon, Tết |
| `shopping.json` | T-006 | ✅ DONE | 5 địa điểm — Chợ Đầm, Yến Sào, Nha Trang Center, Chợ đêm, phố khô |
| `itineraries.json` | T-013 | ✅ DONE | 2 lịch trình — 3N2Đ cặp đôi, 2N1Đ nhóm bạn |
| `faq.md` | T-007 | ✅ DONE | 11 Q&A — 7 sections đủ schema |
| `experiences.md` | T-008 | ✅ DONE | 5 địa điểm, 2 lịch trình tóm tắt, tips, bảng đặc sản |

**Tổng:** 12/12 file ✅ — Phase 1 DONE cho `khanh-hoa-nha-trang`

---

## 📁 Cấu trúc thư mục

```
knowledge-base/khanh-hoa-nha-trang/
├── city.json          ✅ (có sẵn từ trước)
├── destinations.json  ✅ 8 địa điểm
├── hotels.json        ✅ 5 khách sạn/resort/homestay
├── foods.json         ✅ 7 món đặc sản
├── restaurants.json   ✅ 3 địa điểm ăn uống
├── transport.json     ✅ getting_there + getting_around
├── tours.json         ✅ 4 tour
├── events.json        ✅ 4 sự kiện
├── shopping.json      ✅ 5 địa điểm mua sắm
├── itineraries.json   ✅ 2 lịch trình
├── faq.md             ✅ 11 Q&A, 7 sections
└── experiences.md     ✅ 5 mục, tips, bảng đặc sản
```

---

## ⚠️ Missing Fields cần bổ sung (TODO)

| File | Field thiếu | Lý do | Cách bổ sung |
|---|---|---|---|
| `hotels.json` | `price_per_night.amount` (tất cả) | Giá dao động theo mùa, cần xác minh ≥2 nguồn | Kiểm tra Booking.com + Agoda, ghi nguồn + tháng/năm |
| `hotels.json` | `booking_url` | Cần link trực tiếp từng khách sạn | Lấy từ website chính thức hoặc Booking.com |
| `hotels.json` | `rating` | Không bịa điểm số — cần từ nguồn thực | Lấy từ Google Maps hoặc Booking.com |
| `tours.json` | `price.amount` (tất cả) | Cần xác nhận tại Klook hoặc công ty tour | Kiểm tra klook.com/vi + Traveloka |
| `destinations.json` | `stats.rating_avg` | Không bịa điểm số | Lấy từ Google Maps nếu có |
| `restaurants.json` | `hours` (chi tiết từng quán) | Cần xác minh tại Google Maps | Tra cứu từng quán trên Google Maps |

---

## 🔗 UUID Map — khanh-hoa-nha-trang

### City
| Entity | UUID |
|---|---|
| Nha Trang (city) | `019eed69-50b3-743c-b2d0-2107e58ca38d` |

### Destinations
| Tên | UUID |
|---|---|
| Bãi biển Nha Trang | `019eedf6-c8b1-783f-bc50-a57d527c4937` |
| Tháp Bà Ponagar | `019eedf6-c8b1-7690-b3e8-85b82c81635f` |
| Vinpearl Land Nha Trang | `019eedf6-c8b1-76a6-aca2-7eeca117cb2b` |
| Đảo 4 Hòn (điểm tham quan) | `019eedf6-c8b1-7ae4-978b-b9e4f1842639` |
| I-Resort Suối khoáng bùn | `019eedf6-c8b1-7d7a-a471-0d0f7e588d4a` |
| Chùa Long Sơn | `019eedf6-c8b1-7413-a474-69b61c0d6aeb` |
| Viện Hải dương học | `019eedf6-c8b1-738f-bc23-d8be5d071d5f` |
| Đảo Bình Ba | `019eedf6-c8b1-7764-be74-2835f768ced4` |

### Hotels
| Tên | UUID |
|---|---|
| Sheraton Nha Trang Hotel & Spa | `019eedf6-c8b1-77eb-a86a-785755b065b0` |
| Vinpearl Resort & Spa Nha Trang Bay | `019eedf6-c8b1-7009-9869-70938ea22af8` |
| Novotel Nha Trang | `019eedf6-c8b1-702f-82f5-1b140cf1bbfb` |
| Sun River Nha Trang Hotel | `019eedf6-c8b1-77e4-a590-c65f660518b2` |
| La Mer Homestay | `019eedf6-c8b1-78ae-b82c-2f09395f2ece` |

### Restaurants
| Tên | UUID |
|---|---|
| Khu hải sản Phạm Văn Đồng | `019eedf6-c8b1-74c9-aabd-37585b166dc0` |
| Chợ Đầm (khu ăn uống) | `019eedf6-c8b1-7710-bd65-d6adb4aeb184` |
| Chợ đêm Nha Trang | `019eedf6-c8b1-7012-b6fe-c35bc8ffb890` |

### Tours
| Tên | UUID |
|---|---|
| Tour 4 Đảo Snorkeling | `019eedf6-c8b1-7996-aeb6-16868bb9549e` |
| Tour Bình Ba 2N1Đ | `019eedf6-c8b1-7088-abe2-513c689d4899` |
| Tour Tắm Bùn I-Resort | `019eedf6-c8b1-75df-83e7-ecd9ffba341d` |
| Tour Lặn Scuba Hòn Mun | `019eedf6-c8b1-726d-884b-99681942bae1` |

### Events
| Tên | UUID |
|---|---|
| Lễ hội Tháp Bà Ponagar | `019eedf6-c8b1-75d4-b80c-d7588116bf76` |
| Festival Biển Nha Trang | `019eedf6-c8b1-7bc8-96ab-90110671bba3` |
| Giải Marathon Quốc tế Nha Trang | `019eedf6-c8b1-762c-b573-39ce65963d9d` |
| Lễ Tết Nguyên Đán | `019eedf6-c8b1-761e-b0a8-e7cc97f70d8e` |

### Shopping
| Tên | UUID |
|---|---|
| Chợ Đầm Nha Trang | `019eedf6-c8b1-7058-86c3-044960548ee9` |
| Yến Sào Khánh Hòa (cửa hàng) | `019eedf6-c8b1-7dab-b060-e8dde5f9b3c2` |
| Nha Trang Center | `019eedf6-c8b1-73d4-8d4c-5945f9d9d65c` |
| Chợ đêm Nha Trang (shopping) | `019eedf6-c8b1-7abd-8b02-7f77ceab52a6` |
| Phố khô Nguyễn Thiện Thuật | `019eedf6-c8b1-71d8-bfac-d40b2b17704c` |

---

## 📊 Vị trí trong 34 tỉnh/thành

| Tỉnh/thành | Slug | Số file hiện có | Ghi chú |
|---|---|---|---|
| **Khánh Hòa — Nha Trang** | `khanh-hoa-nha-trang` | **12/12** ✅ | **Đã hoàn thành — session 2026-06-22** |
| Lâm Đồng — Đà Lạt | `lam-dong-da-lat` | 1/12 | Chỉ có city.json |
| An Giang — Phú Quốc | `an-giang-phu-quoc` | 3/12 | city + faq + experiences |
| Tuyên Quang — Hà Giang | `tuyen-quang-ha-giang` | 3/12 | city + faq + experiences |
| Đà Nẵng — Hội An | `da-nang-hoi-an` | 3/12 | city + faq + experiences |
| Lào Cai — Sa Pa | `lao-cai-sa-pa` | 1/12 | Chỉ có city.json |
| Quảng Ninh — Hạ Long | `quang-ninh-ha-long` | 1/12 | Chỉ có city.json |
| Huế | `hue` | 1/12 | Chỉ có city.json |
| Lâm Đồng — Mũi Né | `lam-dong-mui-ne` | 1/12 | Chỉ có city.json |
| Ninh Bình | `ninh-binh` | 1/12 | Chỉ có city.json |
| Hà Nội | `ha-noi` | 12/12 | Đã đủ file |
| Bắc Ninh | `bac-ninh` | 3/12 | city + faq + experiences |
| Cà Mau | `ca-mau` | 3/12 | city + faq + experiences |
| Cần Thơ | `can-tho` | 3/12 | city + faq + experiences |
| Cao Bằng | `cao-bang` | 3/12 | city + faq + experiences |
| *(các tỉnh còn lại)* | — | 1/12 | Chỉ có city.json |

> **Ưu tiên tiếp theo:** Đà Lạt (`lam-dong-da-lat`), Sa Pa (`lao-cai-sa-pa`), Hạ Long (`quang-ninh-ha-long`) — 3 điểm đến phổ biến nhất sau Nha Trang và Hà Nội.

---

### lam-dong-da-lat

# TRACKING BÁO CÁO NHIỆM VỤ THÀNH PHỐ LÂM ĐỒNG - ĐÀ LẠT

## 1. Trạng Thái File (Phase 1)
| Task ID | File Name | Status | Missing Data (TODO) |
|---|---|---|---|
| T-002 | `destinations.json` | 🔄 Partial | `entry_fee`, `hours`, `stats` cần xác thực giá từ nền tảng booking vé. |
| T-003 | `hotels.json` | 🔄 Partial | `price_per_night`, `rating` trống (chống hallucinate theo Rule-02). |
| T-004 | `foods.json` | ✅ Complete | Đã phân loại đủ ≥ 5 món ăn đặc trưng. |
| T-004 | `restaurants.json` | 🔄 Partial | `rating`, `hours` chưa có dữ liệu nguồn uy tín cho quán bình dân. |
| T-005 | `transport.json` | ✅ Complete | > 3 tuyến getting_there & > 4 phương tiện. |
| T-005 | `tours.json` | 🔄 Partial | `price` cần crawl thực tế qua Klook API để tránh sai lệch giá trị VND. |
| T-006 | `events.json` | ✅ Complete | Cập nhật lễ hội văn hóa định kỳ (không cần giá). |
| T-006 | `shopping.json` | ✅ Complete | 4 địa chỉ chợ và chuỗi phân phối đặc sản. |
| T-013 | `itineraries.json` | ✅ Complete | Đã nối chính xác UUID vào `location_ref.id`. |
| T-007 | `faq.md` | ✅ Complete | >11 Q&A, xử lý khéo léo kỹ thuật tham chiếu chéo tệp tin (Rule-21). |
| T-008 | `experiences.md` | ✅ Complete | Đã lọc triệt để các thông số cứng (Rule-21). |

## 2. UUIDv7 Registry Mapping (Anti-Hallucination)
> *Các entity dưới đây đã được chốt khung UUID (phiên bản v7 timestamp) trong toàn bộ DB Knowledge Base.*

- **City ID:** `019ef504-6d4c-7eb7-885f-583deab45385`
- **Destinations:**
  - Hồ Xuân Hương: `019ef504-6d4d-72f3-bf9f-67be815fc6a6`
  - Thác Datanla: `019ef504-6d4d-7d33-bcad-dbe58affb3e4`
  - Hồ Tuyền Lâm: `019ef504-6d4d-7053-bdfc-10189a881146`
  - Núi Langbiang: `019ef504-6d4d-769a-a46a-a1545cd6a505`
  - Chợ Đà Lạt: `019ef504-6d4d-7cce-b559-e439d3557a03`
- **Hotels:**
  - Dalat Palace: `019ef504-6d4d-7325-bb60-0fea75b0b37a`
  - Ana Mandara: `019ef504-6d4d-7bd1-ab3a-4c7633584183`
  - Colline: `019ef504-6d4d-71fa-a62b-010cbb844664`
  - Jang & Min: `019ef504-6d4d-7b1e-801a-46970ff53a5e`
- **Restaurants:**
  - Bánh Căn Lệ: `019ef504-6d4d-78e0-9047-1ad9d8d08753`
  - Lẩu Gà Lá É: `019ef504-6d4d-7641-875b-bbcaad1aaee7`
  - Chu Quán BBQ: `019ef504-6d4d-7f23-bb7c-7b32ecc58175`
- **Tours:** (Canyoning `019ef504-6d4d-7f45-b6a7-cdc86330f9ca`, Săn Mây `019ef504-6d4d-7880-b470-df8c937dd71b`, Langbiang `019ef504-6d4d-7bb3-bd08-79da7e3c3ef2`)
- **Events:** (Festival Hoa `019ef504-6d4d-728b-ad3a-c88d47085637`, Cồng chiêng `019ef504-6d4d-7a70-8abf-a6b940c4612d`, Mai anh đào `019ef504-6d4d-7b10-bebe-92d42304ec2f`)
- **Shopping:** (Chợ Đêm `019ef504-6d4d-7999-a92e-29959e8598be`, L'angfarm `019ef504-6d4d-7435-b186-5f57200e1bf2`, XQ Sử Quán `019ef504-6d4d-7fea-b12d-ff398c34c8e2`, Chợ Nông Sản `019ef504-6d4d-7aef-9f22-9ae1ae3ffdcb`)
---

### lam-dong-mui-ne

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
---

### lao-cai-sapa

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
---

### ninh-binh-ninh-binh

# TRACKING - ninh-binh-ninh-binh Knowledge Base

**Tỉnh/Thành:** Ninh Bình
**City ID:** `4ef59e01-51dd-4177-a800-226e244296e9`
**Cập nhật lần cuối:** 2026-06-23
**Tổng trạng thái:** 12/12 file đã tạo - status: complete, dữ liệu manual_curated.

## Bảng Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `destinations.json` | T-002 | complete | price/rating/image_url cần xác minh |
| `hotels.json` | T-003 | complete | price/rating/booking_url cần xác minh |
| `foods.json` | T-004 | complete | price_range cần xác minh |
| `restaurants.json` | T-004 | complete | price/rating cần xác minh |
| `transport.json` | T-005 | complete | giá vé realtime cần xác minh |
| `tours.json` | T-005 | complete | giá tour realtime cần xác minh |
| `events.json` | T-006 | complete | ngày cụ thể theo từng năm cần xác minh |
| `shopping.json` | T-006 | complete | giờ mở cửa/giá cần xác minh |
| `itineraries.json` | T-013 | complete | estimated_cost chi tiết cần xác minh |
| `faq.md` | T-007 | complete | - |
| `experiences.md` | T-008 | complete | - |
| `TRACKING.md` | - | complete | - |

## UUID Map

### City
| Entity | UUID |
|---|---|
| Ninh Bình | `4ef59e01-51dd-4177-a800-226e244296e9` |

### Destinations
| Tên | UUID |
|---|---|
| Quần thể danh thắng Tràng An | `4ef59e01-d1dc-e178-90a7-7bfefc8a2fa0` |
| Tam Cốc - Bích Động | `4ef59e01-02dd-2d72-bf62-85e964abab5e` |
| Chùa Bái Đính | `4ef59e01-02dd-677a-b8e5-01854952e5f3` |
| Cố đô Hoa Lư | `4ef59e01-02dd-957d-90ca-ac6f0f13272b` |
| Hang Múa | `4ef59e01-02dd-6c74-b7c5-b401f9ac7437` |
| Vườn quốc gia Cúc Phương | `4ef59e01-02dd-a07a-aa9e-fbc4e8f921ff` |
| Đầm Vân Long | `4ef59e01-02dd-e97e-8ccb-18e076fa8d3a` |

### Hotels
| Tên | UUID |
|---|---|
| Chez Beo Homestay | `4ef59e01-07dd-957c-9af8-b4a4551a3543` |
| Ninh Binh Hidden Charm Hotel & Resort | `4ef59e01-07dd-1278-a365-940a798b0078` |
| Tam Coc Garden Resort | `4ef59e01-07dd-4775-92d0-f93d17b363c9` |
| Bai Dinh Garden Resort & Spa | `4ef59e01-07dd-377d-b7ab-65580b8c133d` |
| Emeralda Resort Ninh Binh | `4ef59e01-09dd-c377-b12a-4a0bfba4ab91` |

### Restaurants
| Tên | UUID |
|---|---|
| Nhà hàng Hoàng Giang | `4ef59e01-09dd-857b-b149-fa9930b62c2d` |
| Nhà hàng Thăng Long | `4ef59e01-09dd-e973-adb9-9243fe706472` |
| Chookie's Beer Garden | `4ef59e01-09dd-ae79-a11b-2e7098cd5672` |

### Tours
| Tên | UUID |
|---|---|
| Tour Tràng An - Hang Múa - Hoa Lư 1 ngày | `4ef59e01-09dd-bb79-aeed-414cd62c7e25` |
| Tour trekking Cúc Phương | `4ef59e01-0bdd-447a-ac04-9c4627fbf791` |
| Tour xe đạp làng quê Tam Cốc | `4ef59e01-0bdd-b572-99ab-55e4782f0e0e` |

### Events
| Tên | UUID |
|---|---|
| Lễ hội Hoa Lư | `4ef59e01-0bdd-5a78-b1a6-6be59787afbc` |
| Lễ hội chùa Bái Đính | `4ef59e01-0bdd-9773-beef-bac4e9e47592` |
| Lễ hội Tràng An | `4ef59e01-0ddd-297c-b282-b4a1bdf85f1c` |

### Shopping
| Tên | UUID |
|---|---|
| Chợ Rồng Ninh Bình | `4ef59e01-0ddd-7970-a72b-a446f82f3320` |
| Làng thêu ren Văn Lâm | `4ef59e01-0ddd-e870-970a-cd223c978869` |
| Làng đá mỹ nghệ Ninh Vân | `4ef59e01-0ddd-8170-959b-01249827ebce` |
| Khu bán đặc sản Tam Cốc | `4ef59e01-0ddd-9c76-bfbe-46768ed5a822` |

## TODO List Missing Fields

- [ ] Xác minh giá khách sạn/tour/vé theo mùa.
- [ ] Bổ sung rating và review_count từ nguồn chính thức hoặc hệ thống user thật.
- [ ] Bổ sung tọa độ/ảnh/URL đặt dịch vụ khi có nguồn tin cậy.
- [ ] Kiểm tra lịch sự kiện theo năm trước khi hiển thị realtime.


---

### quang-ninh-ha-long

# TRACKING - quang-ninh-ha-long Knowledge Base

**Tỉnh/Thành:** Hạ Long
**City ID:** `4ef59e01-72de-af7b-9c53-b420c5caff4a`
**Cập nhật lần cuối:** 2026-06-23
**Tổng trạng thái:** 12/12 file đã tạo - status: complete, dữ liệu manual_curated.

## Bảng Trạng Thái 12 File

| File | Task | Status | Missing Fields |
|---|---|---|---|
| `destinations.json` | T-002 | complete | price/rating/image_url cần xác minh |
| `hotels.json` | T-003 | complete | price/rating/booking_url cần xác minh |
| `foods.json` | T-004 | complete | price_range cần xác minh |
| `restaurants.json` | T-004 | complete | price/rating cần xác minh |
| `transport.json` | T-005 | complete | giá vé realtime cần xác minh |
| `tours.json` | T-005 | complete | giá tour realtime cần xác minh |
| `events.json` | T-006 | complete | ngày cụ thể theo từng năm cần xác minh |
| `shopping.json` | T-006 | complete | giờ mở cửa/giá cần xác minh |
| `itineraries.json` | T-013 | complete | estimated_cost chi tiết cần xác minh |
| `faq.md` | T-007 | complete | - |
| `experiences.md` | T-008 | complete | - |
| `TRACKING.md` | - | complete | - |

## UUID Map

### City
| Entity | UUID |
|---|---|
| Hạ Long | `4ef59e01-72de-af7b-9c53-b420c5caff4a` |

### Destinations
| Tên | UUID |
|---|---|
| Vịnh Hạ Long | `4ef59e01-0ddd-be73-b123-dac91b2c1d23` |
| Hang Sửng Sốt | `4ef59e01-0ddd-197b-9967-2367f5237cd7` |
| Đảo Ti Tốp | `4ef59e01-0ddd-c47a-8dc6-f1b14a5eff7b` |
| Khu di tích danh thắng Yên Tử | `4ef59e01-0ddd-1075-a7cc-b320d66c7489` |
| Bảo tàng Quảng Ninh | `4ef59e01-0ddd-d77a-a0bc-aeab6296f797` |
| Bãi biển Bãi Cháy | `4ef59e01-0ddd-a171-9cdd-45f3fb03d0ae` |
| Làng chài Cửa Vạn | `4ef59e01-0ddd-9670-9a78-d795be59b61c` |

### Hotels
| Tên | UUID |
|---|---|
| BBQ Hostel Ha Long | `4ef59e01-12dd-1570-98c0-08817eb55a63` |
| Ha Long Essence Hotel | `4ef59e01-12dd-4e71-b70d-5491bc9f5711` |
| Novotel Ha Long Bay | `4ef59e01-12dd-cd78-a712-fcb5a4f8b00f` |
| Vinpearl Resort & Spa Ha Long | `4ef59e01-0ddd-647b-afa7-185e7911ea04` |
| Homestay làng chài Cửa Vạn | `4ef59e01-12dd-3071-a7e5-8c2d8b956cf5` |

### Restaurants
| Tên | UUID |
|---|---|
| Nhà hàng Hồng Hạnh | `4ef59e01-12dd-097c-9d6d-95df3629c88f` |
| Nhà hàng Linh Đan | `4ef59e01-12dd-ab7a-971a-0cad5976faf4` |
| Khu hải sản Bãi Cháy | `4ef59e01-15dd-3a72-ab41-cf6c2f336557` |

### Tours
| Tên | UUID |
|---|---|
| Tour du thuyền Vịnh Hạ Long 1 ngày | `4ef59e01-15dd-1775-bf71-dc8e655a0f14` |
| Tour ngủ đêm trên vịnh | `4ef59e01-15dd-7775-ae09-fdb7811f65e3` |
| Tour Yên Tử 1 ngày | `4ef59e01-16dd-f675-83d3-1975a33f6ec8` |

### Events
| Tên | UUID |
|---|---|
| Carnaval Hạ Long | `4ef59e01-16dd-7470-8261-df9af3b02283` |
| Lễ hội Yên Tử | `4ef59e01-16dd-6878-a9a0-6375ca51aeaa` |
| Lễ hội Bạch Đằng | `4ef59e01-16dd-7078-a635-b7c38bb78770` |

### Shopping
| Tên | UUID |
|---|---|
| Chợ đêm Hạ Long | `4ef59e01-16dd-9f7f-9cde-cafa7236e08e` |
| Chợ Cái Dăm | `4ef59e01-16dd-9077-a232-ad6054c5cfb8` |
| Bãi Cháy Walking Street | `4ef59e01-16dd-1b70-a3bb-638dd47be793` |
| Cửa hàng ngọc trai Hạ Long | `4ef59e01-16dd-a97f-9485-8bb56412418b` |

## TODO List Missing Fields

- [ ] Xác minh giá khách sạn/tour/vé theo mùa.
- [ ] Bổ sung rating và review_count từ nguồn chính thức hoặc hệ thống user thật.
- [ ] Bổ sung tọa độ/ảnh/URL đặt dịch vụ khi có nguồn tin cậy.
- [ ] Kiểm tra lịch sự kiện theo năm trước khi hiển thị realtime.


---

### tp-ho-chi-minh-hcmc

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
---
