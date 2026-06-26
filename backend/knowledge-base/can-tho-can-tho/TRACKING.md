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
