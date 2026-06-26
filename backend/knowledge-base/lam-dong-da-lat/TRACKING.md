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