# Task T-014 — Mở rộng `city.json` cho 25 tỉnh/thành còn thiếu (đủ 34/34)

| Trường | Giá trị |
|---|---|
| **Task ID** | T-014 |
| **Status** | ✅ DONE (partial data — xem ghi chú) |
| **Priority** | 🟡 MEDIUM — mở rộng phạm vi, không phải nền tảng |
| **Agent** | Claude — 2026-06-22 |

---

## 🎯 Mục tiêu

Sau khi áp dụng 34 tỉnh/thành sau sáp nhập (RULE-17), 10 thành phố cũ chỉ phủ **9/34 tỉnh**.
Task này tạo `city.json` cho 25 tỉnh/thành còn lại để đủ 34/34, mỗi tỉnh chọn 1 điểm đến đại diện
(thường là tỉnh lỵ hoặc điểm du lịch nổi tiếng nhất).

## ⚠️ Khác biệt quan trọng so với T-001 — ĐỌC KỸ TRƯỚC KHI DÙNG DATA NÀY

**25 file `city.json` này không có trong DB hiện tại** — cần tra cứu từ nguồn thực tế
chỉ seed 10 thành phố ban đầu, không có dữ liệu cho 25 tỉnh mới này. Vì vậy:

- `_meta.status = "partial"` và ghi rõ nguồn đã tra cứu trong `_meta.data_sources`.
- `data.id` là UUID **tạm** (random), KHÔNG khớp với DB thật — nếu dùng cho RAG/production phải
  tạo migration `INSERT INTO destinations` thật trước, rồi thay UUID tạm bằng UUID thật.
- `data.budget`, `data.stats`, `data.image_url` đều là `null` — **không bịa số liệu** theo RULE-02.
  Đây là field cần con người (hoặc agent task khác có nguồn rõ ràng) bổ sung sau.
- `data.is_active = false` — đánh dấu rõ đây là "khung" (skeleton), chưa sẵn sàng hiển thị cho
  người dùng cuối cho đến khi có UUID thật + budget/stats/ảnh thật.
- `description`, `special`, `best_season`, `weather`, `cuisine_summary`, `categories` là kiến thức
  địa lý/văn hóa phổ biến (capital, danh lam nổi tiếng, đặc sản) — không phải số liệu nhạy cảm nên
  được viết trực tiếp, nhưng vẫn nên có người review trước khi public.

## 📂 Output — 25 folder mới

```
knowledge-base/
├── ha-noi/city.json
├── lai-chau/city.json
├── dien-bien-dien-bien-phu/city.json
├── son-la-moc-chau/city.json
├── lang-son/city.json
├── thanh-hoa-sam-son/city.json
├── nghe-an-cua-lo/city.json
├── ha-tinh-thien-cam/city.json
├── cao-bang/city.json
├── thai-nguyen/city.json
├── phu-tho/city.json
├── bac-ninh/city.json
├── hung-yen/city.json
├── hai-phong-cat-ba/city.json
├── quang-tri/city.json
├── quang-ngai-ly-son/city.json
├── gia-lai-pleiku/city.json
├── dak-lak-buon-ma-thuot/city.json
├── tp-ho-chi-minh/city.json
├── dong-nai/city.json
├── tay-ninh-nui-ba-den/city.json
├── can-tho/city.json
├── vinh-long/city.json
├── dong-thap/city.json
└── ca-mau/city.json
```

`.agent/context/city-slugs.json` đã được thêm 25 entries này (tổng 35 điểm đến / 34 tỉnh, vì
Đà Lạt + Mũi Né cùng thuộc Lâm Đồng).

## ✅ Checklist trước khi coi tỉnh nào "thật sự xong" (khác T-001)

- [ ] Thêm UUID vào DB app mobile khi triển khai (không cần SQL seed)
- [ ] Thay `data.id` tạm bằng UUID thật từ SQL
- [ ] Có nguồn giá thật (khảo sát/đối tác) cho `budget` — KHÔNG đoán số
- [ ] Có ảnh thật upload CDN cho `image_url`
- [ ] Đổi `is_active` thành `true`
- [ ] Người review nội dung (description/cuisine) xác nhận không sai sự thật địa phương
- [ ] Sau đó mới chạy tiếp T-002 → T-013 cho tỉnh đó (destinations, hotels, foods...)

## 📝 Việc CHƯA làm trong task này (để task khác)

- `destinations.json`, `hotels.json`, `restaurants.json`... cho 25 tỉnh mới — vẫn `⬜ TODO`,
  cần task riêng vì khối lượng lớn và cần nguồn dữ liệu thật (không thể viết khung rồi để trống
  như `city.json`, vì hotel/giá vé sai sẽ gây hậu quả trực tiếp cho người dùng).
- `faq.md`, `experiences.md` cho 25 tỉnh mới.
- Cross-check `is_active = false` ở các route/API để đảm bảo 25 tỉnh "khung" này không vô tình
  hiện ra cho người dùng cuối trước khi có data thật — **ĐÃ KIỂM TRA**: `backend/app/api/routes/travel.py`
  (dòng 89, 141, 307) và `Category`/`Destination` model đều filter `is_active.is_(True)` trước khi
  trả về cho client. Vậy chỉ cần giữ `is_active: false` khi insert SQL thật, 25 tỉnh khung sẽ tự
  động không hiển thị cho user — không cần sửa code backend.

---

> **Ghi chú bổ sung (2026-06-22):** Đối chiếu thực tế phát hiện 5/25 folder ở trên ("Output" phía
> trên) **chưa từng được tạo** dù task này ghi DONE: `quang-ngai-ly-son`, `gia-lai-pleiku`,
> `tp-ho-chi-minh`, `tay-ninh-nui-ba-den`, `vinh-long`. Đã tạo task fix **T-016** để bổ sung — xem
> `.agent/tasks/T-016-fix-t014-missing-folders.md` (đã DONE). Nội dung gốc của T-014 ở trên giữ
> nguyên không sửa, theo RULE-08.
