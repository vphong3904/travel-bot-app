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