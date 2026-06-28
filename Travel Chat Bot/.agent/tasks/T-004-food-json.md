# Task T-004 — Tạo `restaurants.json` + `foods.json` cho 34 tỉnh/thành

| Trường | Giá trị |
|---|---|
| **Task ID** | T-004 |
| **Status** | ⬜ TODO |
| **Priority** | 🟡 MEDIUM |
| **Depends on** | T-001 |
| **Estimated** | ~45 phút |

---

## 🎯 Mục tiêu

### restaurants.json
Tạo từ bảng `locations` với `type = 'restaurant'`.  
⚠️ SQL hiện tại có thể chưa có locations type restaurant → tạo file rỗng + ghi note.

### foods.json
Tạo từ **2 nguồn kết hợp**:
1. `destinations.cuisine` (field text, cần parse danh sách món)
2. `knowledge_entries` WHERE `category = 'food'` AND `destination_id = {uuid}`

## 📖 Nguồn dữ liệu

| File | Bảng | Filter |
|---|---|---|
| restaurants.json | `locations` | type = 'restaurant' |
| foods.json | `destinations` | field `cuisine` |
| foods.json | `knowledge_entries` | category = 'food' |

**SQL files:**
- Foody, Google Maps (quán ăn)
- Sở Du lịch tỉnh, vietnamtourism.gov.vn (đặc sản)
- Xem đầy đủ: `.agent/context/sql-table-mapping.md`

## 🔢 Cách parse `destinations.cuisine`

Ví dụ: `'Bánh tráng nướng, lẩu gà lá é, sữa đậu nành nóng, dâu tây, atiso'`

→ Split bởi dấu phẩy → tạo array  
→ Mỗi món tạo 1 object trong `foods.json` với:
```json
{
  "name": "Bánh tráng nướng",
  "category": "snack",
  "description": "Đặc sản địa phương",
  "source": "destinations.cuisine"
}
```

→ Nếu có `knowledge_entries` category=food cho món đó → merge thêm `description` từ đó.

## ✅ Checklist

- [ ] 10 files `foods.json` — mỗi file ít nhất 3 món ăn
- [ ] 10 files `restaurants.json` (kể cả file rỗng)
- [ ] `must_try: true` cho các món được mention trong `knowledge_entries`
- [ ] Không trùng lặp món ăn trong cùng 1 file

---

### Partial note
```
Đã xong:
Còn lại:
```
