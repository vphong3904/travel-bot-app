# Task T-003 — Tạo `hotels.json` cho 34 tỉnh/thành

| Trường | Giá trị |
|---|---|
| **Task ID** | T-003 |
| **Status** | ⬜ TODO |
| **Priority** | 🟡 MEDIUM |
| **Depends on** | T-001 |
| **Estimated** | ~30 phút |

## 🎯 Mục tiêu

Tạo `hotels.json` từ bảng `hotels`. **Lưu ý:** bảng `hotels` có thể chưa có seed data — kiểm tra SQL trước, nếu rỗng thì tạo file với `data: []` và ghi `status: empty`.

## 📖 Nguồn

**Nguồn:** Booking.com, Agoda, Traveloka — xem `.agent/context/sql-table-mapping.md`

## ✅ Checklist

- [ ] 10 files tạo xong (kể cả file rỗng)
- [ ] `price_per_night.amount` là số nguyên VND
- [ ] `amenities` là array string tiếng Việt
- [ ] `stars` là int 1–5 hoặc null (nếu homestay/hostel)
- [ ] File rỗng có ghi chú `"status": "empty — cần bổ sung data hotels"`

---

### Partial note
```
Đã xong:
Còn lại:
```
