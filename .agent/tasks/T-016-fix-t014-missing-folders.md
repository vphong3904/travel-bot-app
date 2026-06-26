# Task T-016 — Fix: bổ sung 5 folder `city.json` mà T-014 báo DONE nhưng chưa tạo

| Trường | Giá trị |
|---|---|
| **Task ID** | T-016 |
| **Status** | ✅ DONE |
| **Priority** | 🔴 HIGH — chặn T-015 vì city.json là input bắt buộc |
| **Liên quan** | T-014 (frozen, không sửa trực tiếp theo RULE-08) |

---

## 🎯 Vấn đề

T-014 khai báo Status `✅ DONE` và liệt kê 25 folder output, nhưng đối chiếu thực tế
`knowledge-base/` chỉ có **20/25** folder tồn tại. **5 folder bị thiếu hoàn toàn:**

| # | Folder | Tỉnh mới | Điểm đại diện |
|---|---|---|---|
| 1 | `quang-ngai-ly-son/` | Quảng Ngãi | Đảo Lý Sơn |
| 2 | `gia-lai-pleiku/` | Gia Lai | Pleiku |
| 3 | `tp-ho-chi-minh/` | TP. Hồ Chí Minh | TP.HCM |
| 4 | `tay-ninh-nui-ba-den/` | Tây Ninh | Núi Bà Đen |
| 5 | `vinh-long/` | Vĩnh Long | TP Vĩnh Long |

T-015 (faq.md/experiences.md cho 25 tỉnh) **không thể bắt đầu đúng cho 5 tỉnh này** vì
chưa có `city.json` skeleton để tham chiếu `province`, `is_active`, tên điểm đại diện.

## ✅ Việc cần làm

1. Tạo `city.json` cho 5 folder trên, theo đúng format/checklist của T-014 (skeleton,
   `is_active: false`, `id` là UUID tạm, `budget/stats/image_url = null`, không bịa số liệu —
   RULE-02).
2. Cập nhật `.agent/context/city-slugs.json` nếu 5 entry này chưa có.
3. **Không động vào file SQL/initdb** — 5 tỉnh này không có trong SQL seed gốc, không cần và
   không được tạo migration giả ở bước này (việc tạo migration thật + UUID thật là bước sau,
   khi có dữ liệu thật, theo đúng checklist T-014).
4. Sau khi 5 folder này tồn tại → T-015 mới được coi là unblock cho đủ 25/25 tỉnh.

## ✅ Kết quả thực hiện (2026-06-22)

- Đã tạo 5 folder + `city.json` skeleton: `quang-ngai-ly-son`, `gia-lai-pleiku`, `tp-ho-chi-minh`,
  `tay-ninh-nui-ba-den`, `vinh-long` — đúng format T-014 (`is_active: false`, `budget/stats/image_url: null`).
- **UUID tạm sinh bằng `uuid_v7.py`** (time-ordered, theo yêu cầu) thay vì UUID v4 ngẫu nhiên:
  | Folder | UUID v7 tạm |
  |---|---|
  | `quang-ngai-ly-son` | `019eeda8-d830-7d4c-9ef2-6de207ce2bdb` |
  | `gia-lai-pleiku` | `019eeda8-d830-762e-8f70-18a66f56fa5c` |
  | `tp-ho-chi-minh` | `019eeda8-d830-72fe-8479-3d24a2698ee8` |
  | `tay-ninh-nui-ba-den` | `019eeda8-d830-7a83-8b89-527da5de9455` |
  | `vinh-long` | `019eeda8-d830-700b-a117-253a6c24a6f8` |
- Đã đồng bộ UUID này vào `.agent/context/city-slugs.json` (5 entry tương ứng đã có sẵn nhưng
  dùng UUID v4 cũ — đã thay bằng UUID v7 mới, ghi `uuid_status` cập nhật bởi T-016) — RULE-15.
- **Không tạo/không sửa file SQL/initdb** — đúng yêu cầu, các UUID này vẫn là tạm, chỉ thay khi có
  migration thật.
- T-015 giờ unblock hoàn toàn cho đủ 25/25 (26 dòng bảng) tỉnh.
