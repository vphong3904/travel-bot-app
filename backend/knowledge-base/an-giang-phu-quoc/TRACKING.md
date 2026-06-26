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
