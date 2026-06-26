# Task T-007 — Viết `faq.md` cho các thành phố du lịch

| Trường | Giá trị |
|---|---|
| **Task ID** | T-007 |
| **Status** | 🔄 IN_PROGRESS (partial — ha-noi, can-tho, bac-ninh, cao-bang, da-nang-hoi-an, an-giang-phu-quoc, ca-mau DONE; còn lại TODO) |
| **Priority** | 🔴 HIGH — dữ liệu chính cho RAG chatbot |
| **Depends on** | T-001, T-002, T-004, T-005 |

---

## 🎯 Mục tiêu

Tạo `faq.md` cho từng thành phố — đây là **nguồn chính** để chatbot trả lời câu hỏi thường gặp.

Mỗi file cần:
- **8–12 câu hỏi** chia theo 6 sections (xem template bên dưới)
- Câu trả lời đủ ý, trung thực, có nguồn rõ ràng
- Viết tiếng Việt tự nhiên, thân thiện
- Khi không có dữ liệu → nói thẳng + hướng dẫn tìm nguồn (xem RULE-19)

> ⚠️ **KHÔNG đặt giới hạn số từ tối thiểu** — đọc RULE-20 để hiểu lý do. Câu trả lời ngắn đúng tốt hơn câu dài bịa.

---

## 📖 Nguồn dữ liệu (theo thứ tự ưu tiên — RULE-18)

1. Tra cứu từ nguồn thực tế — xem `.agent/context/sql-table-mapping.md`
2. **Vietnam Tourism** vietnamtourism.gov.vn — thông tin điểm đến chính thức
3. **Sở Du lịch từng tỉnh** — thông tin địa phương
4. **Traveloka / Klook** — giá vé, tour (cần ≥ 2 nguồn khớp nhau)
5. **TripAdvisor VN / Google Maps** — tips thực tế, giờ mở cửa

> Bắt buộc ghi nguồn vào `data_sources` trong frontmatter. Nếu chỉ dùng SQL → ghi tên file SQL.

---

## 🔢 Template `faq.md`

```markdown
---
city: {slug-thành-phố}
city_name: {Tên thành phố}
task: T-007
generated_from: tra-cuu-nguon-thuc-te
last_updated: YYYY-MM-DD
data_sources:
  - "vietnamtourism.gov.vn (MM/YYYY)"  # thay bằng nguồn đã tra
  - "Vietnam Tourism: vietnamtourism.gov.vn (truy cập MM/YYYY)"
  - "Klook VN: klook.com/vi (truy cập MM/YYYY)"
status: complete | partial
---

# ❓ FAQ Du Lịch {Tên Thành Phố}

## 🗓️ Thời điểm & Thời tiết

**Q: Thời điểm đẹp nhất để đến {thành phố} là khi nào?**
A: [Tháng cụ thể + lý do ngắn. Nguồn: Vietnam Tourism / Sở Du lịch]

**Q: {thành phố} có bị ảnh hưởng bởi bão / mùa mưa không?**
A: [Thực tế thời tiết, không tô vẽ quá đẹp cũng không dọa quá]

---

## 💰 Chi phí & Ngân sách

**Q: Chi phí đi {thành phố} {N} ngày {M} đêm hết bao nhiêu?**
A: [Khoảng giá nếu có nguồn, kèm "(ước tính từ [nguồn], [tháng/năm])".
   Nếu không có nguồn → "Tham khảo Traveloka hoặc Klook để có giá cập nhật nhất."]

**Q: Có cần đặt phòng/tour trước không?**
A: [Hướng dẫn thực tế theo mùa]

---

## 🚗 Di chuyển

**Q: Từ TP.HCM / Hà Nội đến {thành phố} bằng phương tiện gì?**
A: [Phương tiện + thời gian + khoảng giá nếu có nguồn]

**Q: Di chuyển trong {thành phố} bằng gì?**
A: [Phương tiện nội địa thực tế]

---

## 🏨 Lưu trú

**Q: Nên ở khu vực nào tại {thành phố}?**
A: [Khu vực cụ thể + lý do]

**Q: Các loại hình lưu trú phổ biến tại {thành phố}?**
A: [Các loại + khoảng giá nếu có từ Booking/Agoda, kèm "(tham khảo Booking.com)"]

---

## 🍜 Ẩm thực

**Q: Đặc sản nổi tiếng nhất của {thành phố} là gì?**
A: [2–4 món cụ thể + mô tả ngắn]

**Q: Nên ăn ở đâu tại {thành phố}?**
A: [Khu vực hoặc tên quán nếu có trong SQL/sources đáng tin]

---

## ❓ Câu hỏi ngoài phạm vi (QUAN TRỌNG — bắt buộc có)

**Q: {Câu hỏi mà KB chưa có dữ liệu — ví dụ: giá vé vào cụ thể một điểm tham quan}**
A: Hiện chúng tôi chưa có thông tin cập nhật về [chủ đề này].
   Bạn có thể kiểm tra tại [nguồn phù hợp: Klook / trang chính thức điểm đến / Sở Du lịch tỉnh].

---

## ⚠️ An toàn & Lưu ý

**Q: Có lưu ý gì về an toàn khi đến {thành phố}?**
A: [Lưu ý thực tế, không dọa quá cũng không bỏ qua rủi ro thật]

**Q: Cần chuẩn bị gì trước khi đến {thành phố}?**
A: [Tips chuẩn bị thực tế]
```

---

## 📂 Phân công theo thành phố

### ✅ Đã có `faq.md`
- `ha-noi/` — status: partial (giá ước tính, cần xác nhận)
- `can-tho/` — status: complete
- `bac-ninh/` — status: complete
- `cao-bang/` — status: complete
- `da-nang-hoi-an/` — status: complete
- `an-giang-phu-quoc/` — status: complete
- `ca-mau/` — status: complete

### ⬜ Còn thiếu `faq.md` (theo thứ tự ưu tiên)
1. `lam-dong-da-lat/` — điểm đến có nhiều FAQ nhất, làm trước
2. `lao-cai-sa-pa/`
3. `quang-ninh-ha-long/`
4. `hue/`
5. `khanh-hoa-nha-trang/`
6. `tuyen-quang-ha-giang/`
7. `lam-dong-mui-ne/`
8. `ninh-binh/`
9. Các thành phố mới từ T-014 (sau khi có data thật)

---

## ✅ Checklist trước khi đánh DONE một thành phố

- [ ] Frontmatter YAML đầy đủ, có `data_sources`
- [ ] Có ít nhất 8 Q&A covering đủ 6 sections
- [ ] **Có ít nhất 1 câu hỏi out-of-scope** với câu trả lời hướng dẫn tìm nguồn
- [ ] Không có số liệu cụ thể (giá, giờ, rating) thiếu nguồn
- [ ] Kiểm tra chéo: số liệu trong FAQ khớp với `city.json` cùng thư mục (RULE-15)
- [ ] Không có placeholder `TBD`, `Lorem ipsum`, `[cần bổ sung]` không kèm hướng dẫn

---

### Partial note
```
Đã xong: ha-noi (partial), can-tho, bac-ninh, cao-bang, da-nang-hoi-an, an-giang-phu-quoc, ca-mau
Còn lại: lam-dong-da-lat, lao-cai-sa-pa, quang-ninh-ha-long, hue, khanh-hoa-nha-trang, tuyen-quang-ha-giang, lam-dong-mui-ne, ninh-binh
```
