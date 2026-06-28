# Task T-002 — Tạo `destinations.json` cho 34 tỉnh/thành

| Trường | Giá trị |
|---|---|
| **Task ID** | T-002 |
| **Status** | ⬜ TODO |
| **Priority** | 🔴 HIGH |
| **Depends on** | T-001 (cần city UUID) |
| **Estimated** | ~45 phút |

---

## 🎯 Mục tiêu

Tạo file `destinations.json` cho mỗi thành phố, chứa danh sách các **địa điểm tham quan** (không bao gồm nhà hàng).

> Bao gồm: attraction, beach, mountain, museum, temple, market, nature  
> **Không bao gồm:** type = 'restaurant' (→ T-004)

## 📂 Output

```
knowledge-base/{city-slug}/destinations.json  (×10)
```

## 📖 Nguồn dữ liệu

**Nguồn:** Google Maps, Klook, website chính thức — xem `.agent/context/sql-table-mapping.md`  
**Bảng:** `locations`  
**Filter:** `destination_id = {city_uuid}` AND `type != 'restaurant'`  
**Join:** `tickets` ON `tickets.location_id = locations.id` (để lấy giá vé)

## 🔢 Các bước thực hiện

1. Đọc schema tại `.agent/schemas/SCHEMAS.md` → section `destinations.json`
2. Với mỗi thành phố (lấy UUID từ `.agent/context/city-slugs.json`):
   a. Filter `locations` theo `destination_id`
   b. Loại bỏ type = 'restaurant'
   c. Tìm trong `tickets` để lấy giá vé cho từng location_id
   d. Build object theo schema
3. Tạo file với `_meta` đầy đủ

## ✅ Checklist

- [ ] 10 files `destinations.json` tạo thành công
- [ ] `coordinates.lat` và `coordinates.lng` là float (không phải string)
- [ ] `entry_fee` được điền từ bảng `tickets` (null nếu không có vé)
- [ ] `type` chỉ dùng các giá trị hợp lệ trong schema
- [ ] `verified` là boolean (true/false)
- [ ] Mỗi thành phố có ít nhất 2 địa điểm

## 📝 Ghi chú

Ưu tiên làm Đà Lạt, Hội An, Sa Pa, Hạ Long trước (điểm đến phổ biến nhất).  
Hãy kiểm tra kỹ các thành phố ít data hơn.

---

### Partial note
```
Đã xong:
Còn lại:
```
