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