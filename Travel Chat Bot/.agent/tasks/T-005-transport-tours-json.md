# Task T-005 — Tạo `transport.json` + `tours.json` cho 34 tỉnh/thành

| Trường | Giá trị |
|---|---|
| **Task ID** | T-005 |
| **Status** | ⬜ TODO |
| **Priority** | 🟡 MEDIUM |
| **Depends on** | T-001 |
| **Estimated** | ~40 phút |

---

## 🎯 Mục tiêu

### transport.json
Từ bảng `transport_options` + `knowledge_entries` category='transport'.  
Cấu trúc 2 sections:
- `getting_there` (is_local = false) — di chuyển ĐẾN thành phố
- `getting_around` (is_local = true) — di chuyển TRONG thành phố

### tours.json
Từ bảng `tours`. Có thể rỗng → tạo file với `data: []`.

## 📖 Nguồn

- Traveloka, 12go.asia, website nhà xe (transport)
- Klook, Vietravel, Traveloka (tours)
- Xem đầy đủ: `.agent/context/sql-table-mapping.md`

## 🔢 Cách build transport.json

```
knowledge_entries WHERE category='transport' AND destination_id={uuid}
→ Parse nội dung để bổ sung vào getting_there
→ Ví dụ: "Từ Hà Nội đến Hạ Long mất 2.5-3 giờ bằng xe khách..."
→ → type: "bus", from: "Hà Nội", duration: "2.5-3 giờ", price_range: "150.000-250.000đ"
```

## ✅ Checklist

- [ ] 10 files `transport.json` — mỗi file có cả `getting_there` và `getting_around`
- [ ] 10 files `tours.json` (kể cả rỗng)
- [ ] `price.amount` là int VND
- [ ] `duration` là string tiếng Việt ("2.5-3 giờ", "1 ngày", ...)
- [ ] `recommended: true` cho phương tiện phổ biến nhất

---

### Partial note
```
Đã xong:
Còn lại:
```
