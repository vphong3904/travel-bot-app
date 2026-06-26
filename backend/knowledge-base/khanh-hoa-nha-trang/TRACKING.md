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
