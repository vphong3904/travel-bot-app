# 📜 AGENT RULES — PDTrip AI Knowledge Base
> ⚠️ **BẮT BUỘC ĐỌC** trước khi thực thi bất kỳ task nào.

---

## RULE-01 · Vòng đời một Task

```
CHƯA BẮT ĐẦU → ĐỌC task file → CẬP NHẬT status IN_PROGRESS
→ THỰC HIỆN → CẬP NHẬT status DONE / BLOCKED
```

Mỗi lần bắt đầu một session mới, agent phải:
1. Đọc `.agent/README.md`
2. Tìm task có status `⬜ TODO` hoặc `🔄 IN_PROGRESS`
3. Đọc file task đó trong `.agent/tasks/`
4. Xác nhận với user rồi mới làm

---

## RULE-02 · Không hallucinate data *(NGHIÊM NGẶT — vi phạm = dừng task ngay)*

### Nguyên tắc cốt lõi
Agent **chỉ được viết** thông tin khi thỏa ít nhất 1 trong 2 điều kiện:
- **Đã xác minh qua ≥ 2 nguồn đáng tin cậy** (xem RULE-18 về nguồn hợp lệ) và ghi rõ nguồn, HOẶC
- **Đã được human review và confirm** trực tiếp trong task / file context

### Các loại thông tin và yêu cầu xử lý

| Loại thông tin | Mức rủi ro | Yêu cầu bắt buộc |
|---|---|---|
| Giá vé, giá phòng, giá tour | 🔴 CAO | Chỉ lấy từ nguồn đã xác minh (RULE-18) hoặc ghi `null` + `// TODO` |
| Địa chỉ, số điện thoại | 🔴 CAO | Chỉ lấy từ nguồn đã xác minh (RULE-18) hoặc ghi `null` + `// TODO` |
| Giờ mở/đóng cửa | 🟡 TRUNG BÌNH | Nếu không có SQL → dùng khoảng ước tính rõ ràng, ví dụ: `"Thường 7:00–17:00, xác nhận trước khi đến"` |
| Tên địa danh, đặc sản | 🟢 THẤP | Được dùng kiến thức phổ biến nhưng không được bịa địa chỉ cụ thể |
| Thông tin lịch sử, văn hóa | 🟢 THẤP | Được dùng kiến thức phổ biến nhưng không thêm số liệu không có nguồn |
| Đánh giá, xếp hạng | 🔴 CAO | Tuyệt đối không bịa rating, điểm số — chỉ dùng từ mô tả chung |

### Khi thiếu dữ liệu — làm đúng như sau

```markdown
**Giờ mở cửa:** Thường 7:00–17:00 — xác nhận thực tế trước khi đến.
**Giá vé:** Cần bổ sung — xem trang chính thức hoặc liên hệ điểm đến.
```

```json
"price": null,
"price_note": "// TODO: chưa có nguồn xác thực — cần bổ sung từ trang chính thức"
```

### ❌ Tuyệt đối KHÔNG làm

- Không viết giá `150.000đ` nếu không có nguồn — sai giá trực tiếp gây hại cho người dùng
- Không viết `"mở cửa 8:00–22:00"` nếu không biết — gây khó chịu khi khách đến nhầm giờ
- Không bịa rating `"4.5/5 sao"` — đây là vi phạm nghiêm trọng
- Không rút ngắn câu trả lời FAQ xuống dưới 80 chữ để cho "đủ số lượng" — câu ngắn buộc agent bịa cho đủ, câu đủ ý không cần bịa

### ⚠️ Cảnh báo về giới hạn độ dài

**KHÔNG đặt giới hạn tối thiểu số từ cho mỗi câu trả lời FAQ** (ví dụ "tối thiểu 50 chữ" hay "tối thiểu 80 chữ"). Giới hạn kiểu này tạo áp lực buộc agent viết thêm khi không có dữ liệu — dẫn thẳng đến hallucination. Thay vào đó:

> **Câu trả lời phải đủ ý, không thiếu thông tin quan trọng. Nếu chỉ có 1 điều đáng nói thì nói 1 điều, không phải nói 3 điều.** Câu ngắn đúng tốt hơn câu dài bịa.

---

## RULE-03 · Cấu trúc file output

### JSON files
```json
{
  "_meta": {
    "city": "lam-dong-da-lat",
    "last_updated": "YYYY-MM-DD",
    "agent_task": "T-002",
    "status": "complete | partial",
    "missing_fields": [],
    "data_sources": []
  },
  "data": [ ... ]
}
```

> `data_sources` ghi tên nguồn thực tế đã tra cứu (vietnamtourism.gov.vn, Booking.com, v.v.)
> — xem danh sách nguồn hợp lệ tại `.agent/context/sql-table-mapping.md`.

### Markdown files (faq.md, experiences.md)
```markdown
---
city: lam-dong-da-lat
task: T-007
last_updated: YYYY-MM-DD
data_sources:
  - "Vietnam Tourism: vietnamtourism.gov.vn"
  - "Sở Du lịch Lâm Đồng: lamdong.gov.vn"
status: complete | partial
---
```

---

## RULE-04 · Khi hết token giữa chừng

Nếu task chưa xong mà sắp hết token:
1. Lưu file hiện tại với `"status": "partial"` trong `_meta`
2. Ghi `partial_note` mô tả còn thiếu phần nào
3. Cập nhật task file: đổi status thành `🔄 IN_PROGRESS (partial — tiếp tục từ thành phố X)`
4. Session sau đọc `partial_note` và tiếp tục

```json
"_meta": {
  "status": "partial",
  "partial_note": "Đã xong: lam-dong-da-lat, an-giang-phu-quoc. Còn lại: tuyen-quang-ha-giang → ninh-binh"
}
```

---

## RULE-05 · Naming convention

| Loại | Convention | Ví dụ |
|---|---|---|
| Folder thành phố | kebab-case | `lam-dong-da-lat/`, `an-giang-phu-quoc/` |
| File JSON | kebab-case | `city.json`, `hotels.json` |
| Task ID | T-NNN | `T-001`, `T-012` |
| City slug | kebab-case | `lam-dong-da-lat`, `quang-ninh-ha-long` |
| City ID (UUID) | Dùng từ SQL | `11111111-1111-1111-1111-111111111111` |

---

## RULE-06 · Thứ tự ưu tiên data

Khi có conflict giữa các nguồn:
```
chinhphu.vn / vietnamtourism.gov.vn / Sở Du lịch tỉnh
  > booking.com / agoda.com / traveloka / klook
  > tripadvisor / google maps / foody
  > tự suy luận (KHÔNG DÙNG — vi phạm RULE-02)
```

> SQL seed (`backend/initdb/*.sql`) là dữ liệu AI sinh tự động, không đáng tin cậy.
> **Không dùng SQL seed làm nguồn dữ liệu** cho knowledge-base/.

Nếu dữ liệu giữa các nguồn mâu thuẫn → ghi cả hai vào `_conflicts` và flag để human review.

---

## RULE-07 · Schema validation

Trước khi đánh DONE bất kỳ JSON nào:
- Mở `.agent/schemas/SCHEMAS.md` → đọc schema tương ứng
- Validate thủ công: kiểm tra từng required field, kiểu dữ liệu, không có `undefined`/`NaN`
- Đặc biệt: `destination_id` phải khớp UUID có thật trong `city-slugs.json`

---

## RULE-08 · Không sửa file đã DONE

- File task với status `✅ DONE` = **frozen**
- Muốn sửa → tạo task mới `T-XXX-fix-YYY.md`
- Không overwrite output đã được validated

---

## RULE-09 · Tiếng Việt trong content

- Mọi `description`, `tips`, `content` → **tiếng Việt tự nhiên**
- Field `slug`, `id`, `type` → **English / kebab-case**
- FAQ title → tiếng Việt, có dấu
- Không dùng từ viết tắt lạ không có trong SQL gốc

---

## RULE-10 · Checklist trước khi đánh dấu DONE

- [ ] File JSON có `_meta` block đầy đủ
- [ ] Không có field `undefined` hoặc `NaN`
- [ ] Mọi `destination_id` đúng UUID đã được định nghĩa trong `city.json` cùng thư mục
- [ ] `faq.md` có ít nhất 8 Q&A đủ ý
- [ ] `experiences.md` có ít nhất 3 sections
- [ ] Không có placeholder text như `"Lorem ipsum"` hay `"TBD"`
- [ ] Mọi thông tin có nguồn hoặc được đánh dấu `// TODO`

---

## RULE-11 · `itineraries.json` là dữ liệu bắt buộc

Task **T-013 (`itineraries.json`)** bắt buộc phải DONE trước khi coi Phase 1 hoàn thành.
Mọi `location_ref.id` trong `itineraries.json` PHẢI khớp với UUID có thật trong các file JSON cùng thư mục thành phố đó (`destinations.json`, `hotels.json`, v.v.).

---

## RULE-12 · Đồng bộ giữa kế hoạch dữ liệu và code RAG thật

`knowledge-base/` hiện là nguồn dữ liệu **song song**, tách biệt hoàn toàn với pipeline RAG đang chạy thật. Không giả định `knowledge-base/` đã "tự động" cải thiện chatbot cho đến khi T-011/T-012 DONE.

---

## RULE-13 · Đo lường được, không chỉ "có vẻ đúng"

Khi hoàn thành T-010 và T-012, phải tạo **bộ câu hỏi test cố định** (tối thiểu 20 câu, phủ đủ 4 loại intent: FAQ, tư vấn điểm đến, lịch trình, tra cứu dịch vụ), lưu tại `backend/tests/eval_questions.json`.

---

## RULE-14 · Knowledge Base phải đủ sâu để chịu được câu hỏi "khó"

Mỗi thành phố cần ít nhất 1 câu FAQ xử lý tình huống "không có dữ liệu" một cách lịch sự — để kiểm chứng cơ chế `hallucination_guard.py` hoạt động đúng.

---

## RULE-15 · Khớp dữ liệu hai chiều giữa Markdown và JSON

Khi `faq.md` / `experiences.md` đề cập tới giá cả, tên địa điểm, hoặc lịch trình đã có trong các file JSON cùng thư mục, nội dung phải **khớp số liệu**, không được viết một số khác "cho tự nhiên hơn".

---

## RULE-16 · Ghi lại quyết định, không chỉ kết quả

Với mỗi thành phố có dữ liệu nguồn yếu, agent phải ghi rõ trong `_meta.missing_fields` đó là **thiếu do chưa có nguồn xác thực** chứ không phải agent quên làm.

---

## RULE-17 · Tỉnh/thành phải theo 34 đơn vị hành chính sau sáp nhập (hiệu lực 1/7/2025)

Việt Nam đã sáp nhập từ 63 xuống 34 tỉnh/thành theo Nghị quyết 202/2025/QH15. **Bắt buộc** đọc `.agent/context/provinces-34.md` trước khi viết bất kỳ field `province` hoặc sinh `slug`/`folder` mới. Tên tỉnh cũ chỉ được dùng khi giải thích bối cảnh lịch sử.

---

## RULE-18 · Nguồn dữ liệu hợp lệ cho `faq.md` và `experiences.md` *(MỚI — BẮT BUỘC)*

Agent **chỉ được dùng** các nguồn sau (theo thứ tự ưu tiên). Mọi thông tin **bắt buộc ghi nguồn vào `data_sources` trong frontmatter** của file markdown.

### Nhóm 1 — Nguồn chính phủ & cơ quan nhà nước (ưu tiên cao nhất)
| Nguồn | URL | Dùng cho |
|---|---|---|
| Cổng thông tin điện tử Chính phủ | chinhphu.vn | Thông tin hành chính, tỉnh thành |
| Vietnam Tourism (Tổng cục Du lịch) | vietnamtourism.gov.vn | Điểm đến chính thức, lễ hội |
| Sở Du lịch từng tỉnh | (domain của từng tỉnh) | Thông tin địa phương chính xác nhất |
| Cục Di sản Văn hóa | dsvh.gov.vn | Thông tin di tích, di sản |

### Nhóm 2 — Nền tảng du lịch lớn tại Việt Nam (có giá thực tế)
| Nguồn | URL | Dùng cho |
|---|---|---|
| Traveloka | traveloka.com/vi-vn | Giá vé máy bay, khách sạn, tour |
| Klook Việt Nam | klook.com/vi | Giá vé tham quan, hoạt động |
| Booking.com | booking.com | Giá phòng khách sạn |
| Agoda | agoda.com/vi-vn | Giá phòng khách sạn |
| VieON / Vietravel | vietravel.com | Tour nội địa, giá tour |
| VNTRIP | vntrip.vn | Khách sạn, tour trong nước |
| Ivivu | ivivu.com | Khách sạn, vé máy bay |

### Nhóm 3 — Nguồn đánh giá & cộng đồng (dùng cho tips, không dùng cho giá)
| Nguồn | URL | Dùng cho |
|---|---|---|
| TripAdvisor | tripadvisor.com.vn | Tips thực tế, đánh giá địa điểm |
| Google Maps | maps.google.com | Giờ mở cửa (xác nhận chéo) |
| Foody | foody.vn | Quán ăn, món ngon |

### Quy tắc xác minh chéo (QUAN TRỌNG)
- **Thông tin về giá** → bắt buộc ≥ 2 nguồn Nhóm 2 khớp nhau → mới ghi vào file, kèm ghi chú `"(nguồn: Traveloka & Klook, tháng MM/YYYY — có thể thay đổi)"`
- **Thông tin về giờ mở cửa** → ưu tiên Google Maps + website chính thức. Nếu chỉ có 1 nguồn → thêm `"— xác nhận trước khi đến"`
- **Thông tin mâu thuẫn** giữa các nguồn → ghi cả hai, để `status: partial`, ghi vào `_conflicts`
- **Không tìm thấy ở nguồn nào** → dùng mô tả chung (không có số cụ thể), hoặc `null`

---

## RULE-19 · Viết FAQ và experiences.md chống hallucination *(MỚI — BẮT BUỘC)*

### Cấu trúc câu trả lời FAQ

Mỗi câu trả lời FAQ phải theo cấu trúc:
```
[Thông tin chính] + [Nguồn hoặc ghi chú độ tin cậy] + [Gợi ý thực tế nếu có]
```

**Ví dụ ĐÚNG:**
```
A: Mùa đẹp nhất là tháng 3–5 và tháng 10–12 khi trời mát, ít mưa.
   (Nguồn: Vietnam Tourism / Sở Du lịch địa phương)
   Nếu đi tháng 6–9 cần chuẩn bị áo mưa vì đây là mùa mưa chính.
```

**Ví dụ SAI (tuyệt đối không làm):**
```
A: Thời điểm đẹp nhất là tháng 10, khi nhiệt độ dao động 18–22°C,
   độ ẩm 65%, lượng mưa trung bình 45mm. [← số liệu bịa]
```

### Khi không có dữ liệu chính xác — mẫu câu lịch sự

```markdown
**Q: Giá vé vào [địa điểm] là bao nhiêu?**
A: Hiện chúng tôi chưa có thông tin giá vé cập nhật cho địa điểm này.
   Bạn có thể kiểm tra trực tiếp tại trang Klook (klook.com) hoặc Traveloka,
   hoặc liên hệ địa điểm trước khi đến để có giá chính xác nhất.
```

```markdown
**Q: [Địa điểm ngoài phạm vi knowledge base]?**
A: Thông tin chi tiết về [địa điểm] hiện chưa có trong hệ thống của chúng tôi.
   Để có thông tin chính xác nhất, bạn có thể tham khảo Vietnam Tourism tại
   vietnamtourism.gov.vn hoặc Sở Du lịch [tỉnh].
```

### Quy tắc viết experiences.md

1. **Địa điểm** — Chỉ ghi địa chỉ cụ thể khi có từ SQL. Nếu không → chỉ ghi tên khu vực (ví dụ: "khu phố cổ Hội An", không ghi "123 Nguyễn Thái Học")
2. **Giờ mở cửa** — Chỉ ghi nếu có nguồn. Nếu không → `"Liên hệ địa điểm để xác nhận giờ mở cửa"`
3. **Giá** — Bắt buộc ghi nguồn và tháng/năm thu thập. Format: `~150.000đ/người (Klook, 06/2025 — có thể thay đổi)`
4. **Tips thực tế** — Được viết từ kiến thức chung nhưng không được thêm số liệu cụ thể không có nguồn

---

## RULE-20 · Không sử dụng giới hạn số từ để kiểm soát chất lượng *(MỚI)*

**Lý do:** Giới hạn "tối thiểu X từ" tạo ra incentive sai — agent viết thêm để đủ số từ, không phải để thêm thông tin có giá trị. Điều này là nguyên nhân trực tiếp của hallucination trong FAQ.

**Thay thế đúng:**
- Checklist nội dung: *"Câu trả lời có đề cập [yếu tố cốt lõi của câu hỏi] chưa?"*
- Kiểm tra thông tin thiếu: *"Có thông tin quan trọng nào mà người đọc cần biết nhưng chưa được đề cập?"*
- Test out-of-scope: *"Nếu không biết → câu trả lời có nói rõ 'không có dữ liệu' không?"*

**Checklist nội dung cho từng loại câu FAQ:**

| Loại câu hỏi | Phải có trong câu trả lời |
|---|---|
| Thời điểm đi | Tháng cụ thể tốt nhất + lý do ngắn |
| Chi phí | Khoảng giá (nếu có nguồn) HOẶC hướng dẫn tìm giá |
| Di chuyển | Phương tiện + xuất phát điểm phổ biến |
| Lưu trú | Khu vực gợi ý + loại hình |
| Ẩm thực | Ít nhất 2–3 món/địa điểm cụ thể |
| An toàn | Ít nhất 1 lưu ý thực tế |
| Out-of-scope | Hướng dẫn tìm nguồn chính thức |

---

## RULE-21 · faq.md và experiences.md THAM CHIẾU JSON — không copy số liệu *(MỚI — NGHIÊM NGẶT)*

Đọc `.agent/context/data-role-design.md` để hiểu đầy đủ. Tóm tắt nhanh:

**Trước khi viết bất kỳ câu nào vào faq.md hoặc experiences.md, hỏi:**
> "Thông tin này đã có trong file JSON nào chưa?"
> - **Có** → KHÔNG copy. Thay bằng tham chiếu: `*(xem hotels.json)*` hoặc `*(giá cụ thể: xem tickets.json)*`
> - **Không** → Đây là nội dung hợp lệ — tips hành vi, context hội thoại, cảnh báo thực tế, so sánh lựa chọn

**Các loại thông tin KHÔNG được copy vào MD (đã có trong JSON):**

| Thông tin | Đã có ở |
|---|---|
| Tên + giá + địa chỉ khách sạn | `hotels.json` |
| Tên + địa chỉ + giờ + giá vé địa điểm | `destinations.json` + `tickets.json` |
| Tên + địa chỉ + giờ + giá quán ăn | `restaurants.json` |
| Cách di chuyển đến + trong thành phố | `transport.json` |
| Lịch trình chi tiết theo giờ | `itineraries.json` |
| Tour + giá tour | `tours.json` |
| Nơi mua sắm + giờ + hàng hóa | `shopping.json` |

**Các loại thông tin ĐƯỢC viết vào MD (không có trong JSON):**
- Lý do / ngữ cảnh chọn lựa ("tại sao nên ở khu trung tâm")
- Tips hành vi ("đặt vé cáp treo trước vào dịp lễ")
- Tips chụp ảnh / timing tốt nhất
- Cảnh báo thực tế từ kinh nghiệm
- Flow tổng lịch trình (không ghi giờ cụ thể — để itineraries.json)
- Xử lý câu hỏi out-of-scope

**Lý do kỹ thuật (RAG):** Nếu copy số liệu từ JSON vào MD, Qdrant sẽ retrieve cùng 1 thông tin từ 2 chunks khác nhau → prompt dài hơn, context mâu thuẫn, tốn token, tăng hallucination. Mỗi loại thông tin nên có đúng 1 nguồn duy nhất trong vector store.
