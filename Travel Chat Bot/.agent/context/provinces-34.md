# 🇻🇳 34 tỉnh/thành Việt Nam sau sáp nhập (hiệu lực 12/6/2025, vận hành từ 1/7/2025)

> Căn cứ Nghị quyết 202/2025/QH15 (Quốc hội, 12/6/2025) và Nghị quyết 60-NQ/TW (12/4/2025).
> Cả nước giảm từ 63 → 34 đơn vị hành chính cấp tỉnh: **28 tỉnh + 6 thành phố trực thuộc TW**.
> Đây là **nguồn sự thật duy nhất** (single source of truth) về tên tỉnh/thành mà agent phải dùng
> khi sinh slug, field `province`, hoặc nội dung đề cập địa danh hành chính. KHÔNG dùng tên tỉnh
> cũ (trước 1/7/2025) trong dữ liệu mới, trừ khi ghi rõ là `province_old` / ghi chú lịch sử.

---

## 11 tỉnh/thành KHÔNG sáp nhập (giữ nguyên)

Hà Nội, Huế, Lai Châu, Điện Biên, Sơn La, Lạng Sơn, Quảng Ninh, Thanh Hóa, Nghệ An, Hà Tĩnh, Cao Bằng

> Lưu ý: "Thừa Thiên Huế" cũ đã đổi tên thành **"Huế"** (thành phố trực thuộc TW) — không sáp nhập
> nhưng có đổi tên, agent cần phân biệt với các tỉnh "giữ nguyên 100%".

---

## 23 tỉnh/thành mới hình thành từ sáp nhập (từ 52 đơn vị cũ)

//Phong làm
| # | Tên tỉnh/TP mới | Hợp nhất từ |
|---|---|---|
| 1 | Tuyên Quang | Hà Giang + Tuyên Quang |
| 2 | Lào Cai | Lào Cai + Yên Bái |
| 3 | Thái Nguyên | Thái Nguyên + Bắc Kạn |
| 4 | Phú Thọ | Phú Thọ + Vĩnh Phúc + Hòa Bình |
| 5 | Bắc Ninh | Bắc Giang + Bắc Ninh |
| 6 | Hưng Yên | Hưng Yên + Thái Bình |
| 7 | Hải Phòng | Hải Phòng + Hải Dương |
| 8 | Ninh Bình | Ninh Bình + Hà Nam + Nam Định |
| 9 | Quảng Trị | Quảng Bình + Quảng Trị |
| 10 | Đà Nẵng | Đà Nẵng + Quảng Nam |
| 11 | Quảng Ngãi | Quảng Ngãi + Kon Tum |


//Đạt làm phần này
| 12 | Gia Lai | Gia Lai + Bình Định |
| 13 | Khánh Hòa | Khánh Hòa + Ninh Thuận |
| 14 | Lâm Đồng | Lâm Đồng + Đắk Nông + Bình Thuận |
| 15 | Đắk Lắk | Đắk Lắk + Phú Yên |
| 16 | TP. Hồ Chí Minh | TP.HCM + Bình Dương + Bà Rịa - Vũng Tàu |
| 17 | Đồng Nai | Đồng Nai + Bình Phước |
| 18 | Tây Ninh | Tây Ninh + Long An |
| 19 | Cần Thơ | Cần Thơ + Sóc Trăng + Hậu Giang |
| 20 | Vĩnh Long | Vĩnh Long + Bến Tre + Trà Vinh |
| 21 | Đồng Tháp | Đồng Tháp + Tiền Giang |
| 22 | Cà Mau | Cà Mau + Bạc Liêu |
| 23 | An Giang | An Giang + Kiên Giang |

**Tổng: 11 (giữ nguyên) + 23 (mới) = 34 đơn vị hành chính cấp tỉnh.**

---

## Slug mapping cho 10 điểm đến ban đầu

| Thành phố | Tỉnh cũ | Tỉnh mới | Slug mới | Lưu ý |
|---|---|---|---|---|
| Đà Lạt | Lâm Đồng | **Lâm Đồng** | `lam-dong-da-lat` | |
| Phú Quốc | Kiên Giang | **An Giang** | `an-giang-phu-quoc` | |
| Hà Giang | Hà Giang | **Tuyên Quang** | `tuyen-quang-ha-giang` | |
| Hội An | Quảng Nam | **Đà Nẵng** | `da-nang-hoi-an` | |
| Sa Pa | Lào Cai | **Lào Cai** | `lao-cai-sa-pa` | tên tỉnh không đổi nhưng địa giới đổi (gộp Yên Bái) |
| Vịnh Hạ Long | Quảng Ninh | **Quảng Ninh** | `quang-ninh-ha-long` | tỉnh giữ nguyên 100% |
| Huế | Thừa Thiên Huế | **Huế** | `hue` | đổi tên tỉnh→thành phố, KHÔNG lặp slug |
| Nha Trang | Khánh Hòa | **Khánh Hòa** | `khanh-hoa-nha-trang` | tên tỉnh không đổi nhưng địa giới đổi (gộp Ninh Thuận) |
| Mũi Né | Bình Thuận | **Lâm Đồng** | `lam-dong-mui-ne` | cùng tỉnh mới với Đà Lạt — phân biệt bằng slug |
| Ninh Bình | Ninh Bình | **Ninh Bình** | `ninh-binh` | tên tỉnh không đổi nhưng địa giới đổi (gộp Hà Nam, Nam Định) — KHÔNG lặp slug |

### Quy tắc sinh slug

```
slug = "{slug-tỉnh-mới}-{slug-tên-thành-phố}"
NGOẠI LỆ: nếu slug-tỉnh-mới == slug-tên-thành-phố → chỉ giữ 1 lần (vd "hue", "ninh-binh")
```

### UUID của điểm đến

UUID trong `.agent/context/city-slugs.json` **giữ nguyên** khi sáp nhập tỉnh — sáp nhập chỉ đổi
`slug`/`folder`/`province`, không phải định danh (identity) của địa điểm du lịch.

### Khi viết content (city.json, faq.md, experiences.md...)

- Field `province` → dùng **tên tỉnh mới**.
- Nếu cần nhắc tỉnh cũ để giải thích bối cảnh (vd FAQ "Phú Quốc thuộc tỉnh nào?"), được phép nói
  rõ: *"Phú Quốc trước đây thuộc tỉnh Kiên Giang, từ 1/7/2025 thuộc tỉnh An Giang sau sáp nhập"* —
  không xóa hoàn toàn thông tin lịch sử, chỉ không dùng tên cũ làm dữ liệu chính.
- KHÔNG bịa thêm thông tin về việc sáp nhập ảnh hưởng thế nào đến du lịch (giá vé, thủ tục...) nếu
  không có nguồn — đây vẫn là phạm vi của RULE-02 (không hallucinate).
