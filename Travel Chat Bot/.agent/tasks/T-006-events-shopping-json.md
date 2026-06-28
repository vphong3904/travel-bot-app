# Task T-006 — Tạo `events.json` + `shopping.json` cho 34 tỉnh/thành

| Trường | Giá trị |
|---|---|
| **Task ID** | T-006 |
| **Status** | ⬜ TODO |
| **Priority** | 🟢 LOW |
| **Depends on** | T-001 |
| **Estimated** | ~30 phút |

---

## 🎯 Mục tiêu

### events.json → bảng `destination_events`
### shopping.json → bảng `shopping_places`

Cả 2 bảng có thể chưa có seed data → tạo file rỗng với note.

## 📖 Nguồn

Nguồn: Sở Du lịch tỉnh, vietnamtourism.gov.vn — xem `.agent/context/sql-table-mapping.md`

## 💡 Nếu bảng rỗng

Với `events.json`, có thể bổ sung thủ công các lễ hội nổi tiếng:
- Đà Lạt: Festival Hoa Đà Lạt (tháng 12)
- Hội An: Lễ hội đèn lồng (mỗi tháng)
- Huế: Festival Huế (2 năm/lần)
- Sa Pa: Chợ phiên (cuối tuần)

Nhưng **phải ghi rõ** `"source": "manual_curated"` trong `_meta`.

## ✅ Checklist

- [ ] 10 files `events.json`
- [ ] 10 files `shopping.json`
- [ ] File manual có `"source": "manual_curated"` trong `_meta`
- [ ] `annual: true` cho lễ hội hàng năm

---

### Partial note
```
Đã xong:
Còn lại:
```
