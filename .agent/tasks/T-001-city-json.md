# Task T-001 — Tạo `city.json` cho 34 tỉnh/thành

| Trường | Giá trị |
|---|---|
| **Task ID** | T-001 |
| **Status** | ✅ DONE |
| **Priority** | 🔴 HIGH — task nền tảng, các task khác phụ thuộc |
| **Estimated** | ~30 phút |
| **Agent** | Claude — 2026-06-22 (lần 1) → cập nhật lại 2026-06-22 (T-017: áp dụng 34 tỉnh sau sáp nhập) |

---

## 🎯 Mục tiêu

Tạo file `city.json` cho **mỗi** trong 34 tỉnh/thành, chứa thông tin tổng quan.

> ⚠️ Không dùng SQL seed — tra cứu từ nguồn thực tế (xem `.agent/context/sql-table-mapping.md`).

## 📂 Output

```
knowledge-base/
├── lam-dong-da-lat/city.json
├── an-giang-phu-quoc/city.json
├── tuyen-quang-ha-giang/city.json
├── da-nang-hoi-an/city.json
├── lao-cai-sa-pa/city.json
├── quang-ninh-ha-long/city.json
├── hue/city.json
├── khanh-hoa-nha-trang/city.json
├── lam-dong-mui-ne/city.json
└── ninh-binh/city.json
```

## 📖 Nguồn dữ liệu

**Nguồn:** tra cứu theo `.agent/context/sql-table-mapping.md`  
**Bảng:** `destinations`  
**Join:** `destination_categories` → `categories` (để lấy category slugs)

## 🔢 Các bước thực hiện

1. Đọc `.agent/schemas/SCHEMAS.md` → section `city.json`
2. Đọc `.agent/context/city-slugs.json` → lấy UUID cho từng thành phố
3. Tra cứu thông tin từ nguồn thực tế (vietnamtourism.gov.vn, Sở Du lịch tỉnh):
   - Lấy INSERT INTO destinations VALUES (...)
   - Map từng row theo UUID
4. Parse categories cho từng thành phố từ `destination_categories`
5. Tạo từng file `city.json` theo schema
6. Validate: `_meta.status = "complete"` nếu đủ tất cả fields

## ✅ Checklist hoàn thành

- [x] 10 files `city.json` được tạo
- [x] Mỗi file có `_meta` block đúng schema
- [x] `budget.low` và `budget.high` là số nguyên VND (không phải string)
- [x] `best_months` là array số nguyên (ví dụ: [11, 12, 1, 2, 3, 4])
- [x] `categories` là array slug (ví dụ: ["beach", "resort", "luxury"])
- [x] `stats.rating_avg` là float (ví dụ: 4.5)
- [x] Không có field null không có lý do
- [x] **Đã áp dụng RULE-17**: 10 folder đổi tên theo slug `{tỉnh-mới}-{tên-thành-phố}`, field
  `province` = tỉnh mới, `province_old` = tỉnh trước sáp nhập (giữ để tham chiếu), `region` theo
  6 vùng kinh tế-xã hội mới (Nghị quyết 306/NQ-CP). UUID giữ nguyên, không đổi.

## 📝 Ghi chú agent

> Khi bắt đầu, cập nhật `status: 🔄 IN_PROGRESS` và ghi tên agent/ngày bắt đầu.

---

### Partial note (điền khi bị gián đoạn)

```
Đã xong: (liệt kê slug)
Còn lại: (liệt kê slug)
```
