# 🏗️ Data Role Design — Phân vai dữ liệu trong Knowledge Base

> Đây là tài liệu **kiến trúc quan trọng nhất** giải thích *tại sao* mỗi loại file tồn tại
> và *không được* trùng lặp lẫn nhau. Đọc trước khi viết bất kỳ nội dung mới nào.

---

## Vấn đề cần giải quyết

Nếu `faq.md` viết lại giá phòng (đã có trong `hotels.json`), tên quán ăn (đã có trong
`restaurants.json`), hay giờ mở cửa (đã có trong `destinations.json`) thì:

1. **Tốn công bảo trì** — giá thay đổi phải sửa 2 chỗ, dễ lệch nhau (vi phạm RULE-15)
2. **Tốn token RAG** — Qdrant retrieve cùng 1 thông tin từ 2 chunks khác nhau → prompt dài hơn,
   nguy cơ mâu thuẫn context cao hơn
3. **Agent mất thời gian sinh nội dung không cần thiết** — và dễ bịa số để lấp đầy

---

## Giải pháp: Phân vai theo "loại câu hỏi mà RAG cần xử lý"

Mỗi file type phục vụ **đúng 1 loại intent**. Không có file nào phục vụ 2 intent.

```
Intent người dùng                   File RAG retrieve
─────────────────────────────────   ───────────────────────────────
"Khách sạn ở Đà Lạt giá bao nhiêu?" → hotels.json
"Ăn gì ở Hội An?"                  → restaurants.json + foods.json
"Vé vào Phú Quốc bao nhiêu?"        → tickets.json + destinations.json
"Lịch trình 3 ngày Sapa"            → itineraries.json
"Đi Cần Thơ tháng mấy đẹp?"        → city.json (best_season)
"Từ HCM đến Đà Lạt đi bằng gì?"    → transport.json
"Mua gì ở Hội An?"                  → shopping.json

"Nên chuẩn bị gì khi đến Đà Lạt?"  → experiences.md (tips tổng hợp)
"Cần biết gì trước khi đi Phú Quốc?" → faq.md (câu hỏi thường gặp)
```

---

## Bảng phân vai rõ ràng

| File | Vai trò DUY NHẤT | KHÔNG viết gì vào đây |
|---|---|---|
| `city.json` | Tổng quan địa điểm: khí hậu, ngân sách tổng, đặc trưng | Chi tiết khách sạn, tên quán cụ thể |
| `destinations.json` | Danh sách địa điểm tham quan: địa chỉ, giờ, giá vé, tips ngắn | Lịch trình, đánh giá dài, so sánh |
| `hotels.json` | Danh sách khách sạn: tên, giá, loại, tiện ích | Tips du lịch chung, so sánh thành phố |
| `restaurants.json` | Danh sách quán ăn: tên, địa chỉ, giá, món | Đặc sản vùng miền (→ foods.json) |
| `foods.json` | Đặc sản & món ngon vùng miền: mô tả, nơi ăn chung | Tên quán cụ thể (→ restaurants.json) |
| `transport.json` | Cách di chuyển đến & trong thành phố | Tips an toàn chung, lịch trình |
| `tours.json` | Tour có thể đặt: tên, giá, gồm gì | Mô tả địa điểm (→ destinations.json) |
| `tickets.json` | Giá vé vào cửa từng điểm: người lớn/trẻ em | Mô tả địa điểm (→ destinations.json) |
| `events.json` | Lễ hội & sự kiện: ngày, địa điểm, chi phí | Tips tham quan chung |
| `shopping.json` | Nơi mua sắm cụ thể: tên, mặt hàng, giờ, giá | Đặc sản mang về (→ foods.json) |
| `itineraries.json` | Lịch trình chi tiết theo giờ: tham chiếu ID từ JSON khác | Mô tả địa điểm, giá riêng lẻ |
| **`faq.md`** | **Câu hỏi thường gặp dạng hội thoại** — THAM CHIẾU JSON, không copy số liệu | Bất kỳ số liệu cụ thể nào đã có trong JSON |
| **`experiences.md`** | **Tips tổng hợp & lịch trình định hướng** — THAM CHIẾU JSON, không copy số liệu | Bất kỳ số liệu cụ thể nào đã có trong JSON |

---

## Quy tắc vàng: faq.md và experiences.md THAM CHIẾU, không copy

Đây là nguyên tắc quan trọng nhất để tránh trùng lặp.

### ❌ Sai — copy số liệu từ JSON vào MD

```markdown
**Q: Khách sạn ở Đà Lạt giá bao nhiêu?**
A: Đà Lạt có nhiều loại khách sạn từ bình dân đến cao cấp. Khách sạn Dalat Palace
   giá khoảng 2.500.000đ/đêm, TTC Hotel giá 800.000đ/đêm, homestay từ 300.000đ/đêm.
```
*→ Vấn đề: giá thay đổi phải sửa 2 chỗ (JSON + MD). Dễ lệch.*

### ✅ Đúng — tham chiếu sang JSON, chỉ viết ngữ cảnh

```markdown
**Q: Khách sạn ở Đà Lạt giá bao nhiêu?**
A: Đà Lạt có đủ mọi phân khúc từ hostel đến resort 5 sao. Khu trung tâm quanh Hồ
   Xuân Hương và chợ Đà Lạt có mật độ khách sạn cao nhất, tiện di chuyển bộ.
   → Danh sách và giá cụ thể: xem `hotels.json`
```

---

### ❌ Sai — experiences.md viết lại địa chỉ, giờ mở cửa đã có trong destinations.json

```markdown
### Hồ Xuân Hương
**Địa chỉ:** Trần Quốc Toản, Phường 1, Đà Lạt
**Giờ:** 6:00–22:00
**Giá:** Miễn phí
**Tip:** Đi bộ quanh hồ sáng sớm rất đẹp...
```
*→ Vấn đề: địa chỉ/giờ đã có trong `destinations.json`. Nếu thay đổi phải sửa 2 nơi.*

### ✅ Đúng — chỉ viết context và tip không có trong structured data

```markdown
### Hồ Xuân Hương
*(Xem địa chỉ và giờ mở cửa tại `destinations.json` → id: `ho-xuan-huong`)*

**Tip thực tế:** Đi bộ vòng quanh hồ (khoảng 45 phút) lúc sáng sớm hoặc chiều tà
cho ảnh đẹp nhất — ánh sáng vàng chiếu vào mặt hồ. Tránh đến cuối tuần vì đông xe.
```

---

## Vậy faq.md và experiences.md viết GÌ?

Chúng viết những thứ **không thể có trong structured JSON** vì bản chất không phải data:

| Loại nội dung | Ví dụ | File |
|---|---|---|
| **Context hội thoại** | "Đà Lạt phù hợp đi mùa nào? Phụ thuộc vào bạn thích gì..." | faq.md |
| **Lý do chọn** | "Tại sao nên ở khu trung tâm thay vì ngoại ô?" | faq.md |
| **Out-of-scope graceful** | "Thông tin X chưa có trong hệ thống, tham khảo tại..." | faq.md |
| **Tips hành vi** | "Không mang tiền lẻ vào chợ đêm — dễ bị mất" | experiences.md |
| **Tips chụp ảnh / timing** | "Ruộng bậc thang đẹp nhất tháng 9–10 khi lúa chín vàng" | experiences.md |
| **Tips di chuyển giữa điểm** | "Từ điểm A sang điểm B đi xe ôm ~15 phút, không nên đi bộ" | experiences.md |
| **Cảnh báo thực tế** | "Cáp treo Fansipan hay kẹt vé dịp lễ — đặt online trước" | experiences.md |
| **So sánh lựa chọn** | "Homestay ngắm ruộng bậc thang vs khách sạn trung tâm..." | experiences.md |
| **Flow lịch trình tổng** | "Ngày 1 tập trung phố cổ, ngày 2 ra đảo..." | experiences.md |

**Những thứ này không có field nào trong JSON để lưu** — đó là lý do MD tồn tại.

---

## Áp dụng vào chunking strategy T-011

Khi import vào Qdrant, mỗi loại file được chunk và tag khác nhau:

| File | Chunk unit | Tag `intent` |
|---|---|---|
| `hotels.json` | 1 chunk / hotel | `accommodation` |
| `restaurants.json` | 1 chunk / restaurant | `food_specific` |
| `foods.json` | 3 món / chunk | `food_general` |
| `destinations.json` | 1 chunk / destination | `attraction` |
| `tickets.json` | 1 chunk / ticket | `ticket_price` |
| `transport.json` | 1 chunk / city | `transport` |
| `itineraries.json` | 1 chunk / itinerary | `itinerary` |
| `faq.md` | 1 chunk / Q&A pair | `faq` |
| `experiences.md` | 1 chunk / H2 section | `tips_context` |

**Khi RAG retrieve:**
- Query hỏi giá phòng → retrieve từ `hotels.json` chunks (tag=`accommodation`)
- Query hỏi tips chung → retrieve từ `experiences.md` chunks (tag=`tips_context`)
- Query hỏi câu hỏi dạng FAQ → retrieve từ `faq.md` chunks (tag=`faq`)
- Không bao giờ cả `faq.md` lẫn `hotels.json` trả về cùng 1 thông tin giá phòng

---

## Tóm tắt cho agent khi viết content

Trước khi viết bất kỳ câu/đoạn nào vào `faq.md` hoặc `experiences.md`, tự hỏi:

> **"Thông tin này đã có trong file JSON nào chưa?"**
> - Có → KHÔNG copy vào MD. Thay bằng tham chiếu: `*(xem hotels.json)*`
> - Không → đây là nội dung hợp lệ để viết vào MD

