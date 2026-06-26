# Task T-008 — Viết `experiences.md` cho các thành phố du lịch

| Trường | Giá trị |
|---|---|
| **Task ID** | T-008 |
| **Status** | 🔄 IN_PROGRESS (partial — can-tho, bac-ninh, cao-bang, da-nang-hoi-an, an-giang-phu-quoc, ca-mau DONE; còn lại TODO) |
| **Priority** | 🔴 HIGH — RAG context cho itinerary planner |
| **Depends on** | T-002, T-004, T-005 |

---

## 🎯 Mục tiêu

`experiences.md` là file **giàu context nhất** — chatbot dùng để tạo lịch trình và đưa ra gợi ý thực tế.

Mỗi file cần:
- Danh sách địa điểm với tips thực tế (không bịa địa chỉ nếu không có nguồn)
- Ít nhất **2 lịch trình gợi ý** tóm tắt (chi tiết giờ giấc → để trong `itineraries.json`)
- Tips an toàn, tiết kiệm, thực tế
- Thông tin mua sắm đặc sản

> ⚠️ **Không viết giá cụ thể** nếu không có nguồn xác thực. Không bịa địa chỉ, số điện thoại. Xem RULE-02, RULE-18, RULE-19.

---

## 📖 Nguồn dữ liệu (theo thứ tự ưu tiên — RULE-18)

1. Tra cứu từ nguồn thực tế — xem `.agent/context/sql-table-mapping.md`
2. **Vietnam Tourism** vietnamtourism.gov.vn
3. **Sở Du lịch từng tỉnh**
4. **Klook / Traveloka** — giá vé tham quan cụ thể (cần ≥ 2 nguồn khớp)
5. **TripAdvisor / Google Maps** — tips thực tế, giờ mở cửa

---

## 🔢 Template `experiences.md`

```markdown
---
city: {slug-thành-phố}
city_name: {Tên thành phố}
task: T-008
generated_from: tra-cuu-nguon-thuc-te
last_updated: YYYY-MM-DD
data_sources:
  - "vietnamtourism.gov.vn (MM/YYYY)"  # thay bằng nguồn đã tra
  - "Vietnam Tourism: vietnamtourism.gov.vn (MM/YYYY)"
  - "Klook VN: klook.com/vi (MM/YYYY)"
status: complete | partial
---

# 🌟 Kinh Nghiệm Du Lịch {Tên Thành Phố}

> Tổng hợp tips thực tế từ du khách và nguồn du lịch đáng tin cậy.

---

## 📍 Địa Điểm Không Thể Bỏ Qua

### 1. {Tên địa điểm 1}
**Loại:** {type}
**Khu vực:** {khu vực — KHÔNG ghi địa chỉ cụ thể nếu không có nguồn SQL}
**Giờ mở cửa:** {giờ từ SQL hoặc Google Maps} *(xác nhận trước khi đến)*
**Giá vé:** {giá từ Klook/nguồn đáng tin, tháng/năm} HOẶC *Liên hệ điểm đến để có giá cập nhật*
**Tip:** {tip thực tế từ SQL hoặc kiến thức chung đã xác minh}

[Lặp lại cho các địa điểm quan trọng khác — chỉ ghi địa chỉ khi có trong SQL]

---

## 🎒 Lịch Trình Gợi Ý

> Chi tiết giờ giấc từng buổi → xem `itineraries.json`.
> Ở đây chỉ ghi tóm tắt định hướng để chatbot hiểu flow chung.

### {N} Ngày {M} Đêm — [Loại hình: Gia đình / Cặp đôi / Phượt / Nghỉ dưỡng]
Xem lịch trình đầy đủ tại `itineraries.json` → id: **`{city-slug}-{N}n{M}d-{type}`**

**Định hướng:**
- Ngày 1: [2–3 điểm/hoạt động chính, không ghi giờ cụ thể]
- Ngày 2: [...]
[...]

### {N} Ngày {M} Đêm — [Loại hình khác]
[Tương tự]

---

## 🚨 Kinh Nghiệm An Toàn

- ⚠️ **[Cảnh báo 1 thực tế]:** [Mô tả + cách phòng tránh]
- ⚠️ **[Cảnh báo 2]:** [...]
[Chỉ ghi những lưu ý thực sự có cơ sở — không bịa nguy hiểm không có thật]

---

## 💡 Tips Thực Tế

- 💰 **Tiết kiệm:** [Tip cụ thể, không ghi số tiền nếu không có nguồn]
- 📸 **Chụp ảnh đẹp:** [Góc máy, thời điểm tốt — từ kiến thức chung đáng tin]
- 🕐 **Thời điểm lý tưởng:** [Giờ hoặc mùa tốt nhất]
- 🍽️ **Ẩm thực:** [Gợi ý thực tế]

---

## 🛒 Mua Sắm & Đặc Sản Mang Về

| Sản phẩm | Mua ở đâu | Ghi chú |
|---|---|---|
| {đặc sản 1} | {khu vực/chợ — không ghi địa chỉ nếu không có nguồn} | {tip mua} |
| {đặc sản 2} | ... | ... |

> Giá tham khảo: kiểm tra Traveloka Shop, Klook hoặc hỏi trực tiếp tại điểm bán.

---

## 📞 Thông Tin Hữu Ích

- **Đường dây hỗ trợ du lịch:** 1800-xxxx *(tra số cụ thể tại vietnamtourism.gov.vn)*
- **Ứng dụng hữu ích:** Grab (di chuyển), Google Maps (điều hướng), Foody (quán ăn)
- **Bệnh viện / Cơ sở y tế:** [Nếu có trong SQL — nếu không có → bỏ dòng này, KHÔNG bịa]
```

---

## 📂 Phân công theo thành phố

### ✅ Đã có `experiences.md`
- `can-tho/` — status: complete
- `bac-ninh/` — status: complete
- `cao-bang/` — status: complete
- `da-nang-hoi-an/` — status: complete
- `an-giang-phu-quoc/` — status: complete
- `ca-mau/` — status: complete

### ⬜ Còn thiếu (thứ tự ưu tiên)
1. `lam-dong-da-lat/` — nhiều dữ liệu SQL nhất
2. `lao-cai-sa-pa/`
3. `quang-ninh-ha-long/`
4. `hue/`
5. `khanh-hoa-nha-trang/`
6. `tuyen-quang-ha-giang/`
7. `lam-dong-mui-ne/`
8. `ninh-binh/`

### Lịch trình gợi ý cần bao gồm (ít nhất 2/thành phố)
- `lam-dong-da-lat`: 2N1Đ cặp đôi + 3N2Đ gia đình
- `lao-cai-sa-pa`: 2N1Đ + 3N2Đ trekking
- `quang-ninh-ha-long`: 2N1Đ du thuyền + 1N1Đ day trip
- `hue`: 2N1Đ văn hóa lịch sử + 3N2Đ kết hợp Quảng Trị
- `khanh-hoa-nha-trang`: 3N2Đ biển đảo + 4N3Đ gia đình
- `tuyen-quang-ha-giang`: 3N2Đ + 4N3Đ phượt loop
- `lam-dong-mui-ne`: 2N1Đ lướt ván + 3N2Đ nghỉ dưỡng
- `ninh-binh`: 1N1Đ day trip + 2N1Đ Tam Cốc + Tràng An

---

## ✅ Checklist trước khi đánh DONE

- [ ] Frontmatter YAML đầy đủ, có `data_sources`
- [ ] Có section: Địa điểm, Lịch trình, An toàn, Tips, Mua sắm
- [ ] Lịch trình chỉ ghi tóm tắt định hướng, KHÔNG viết lại giờ giấc từ `itineraries.json`
- [ ] **Không có địa chỉ cụ thể nào thiếu nguồn SQL**
- [ ] **Không có giá cụ thể nào thiếu nguồn + tháng/năm**
- [ ] Kiểm tra chéo: nội dung khớp với `city.json` và `itineraries.json` (RULE-15)

---

### Partial note
```
Đã xong: can-tho, bac-ninh, cao-bang, da-nang-hoi-an, an-giang-phu-quoc, ca-mau
Còn lại: lam-dong-da-lat, lao-cai-sa-pa, quang-ninh-ha-long, hue, khanh-hoa-nha-trang, tuyen-quang-ha-giang, lam-dong-mui-ne, ninh-binh
```
