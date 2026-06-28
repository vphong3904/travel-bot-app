# 📐 SCHEMAS — PDTrip AI Knowledge Base

> Agent **phải đọc file này** trước khi tạo bất kỳ file output nào.  
> File này là **nguồn duy nhất** về cấu trúc dữ liệu — không đọc file schema khác.

---

## Mục lục nhanh

| Loại file | Section |
|---|---|
| `city.json` | [→ city.json](#cityjson) |
| `destinations.json` | [→ destinations.json](#destinationsjson) |
| `hotels.json` | [→ hotels.json](#hotelsjson) |
| `restaurants.json` | [→ restaurants.json](#restaurantsjson) |
| `foods.json` | [→ foods.json](#foodsjson) |
| `transport.json` | [→ transport.json](#transportjson) |
| `tours.json` | [→ tours.json](#toursjson) |
| `tickets.json` | [→ tickets.json](#ticketsjson) |
| `events.json` | [→ events.json](#eventsjson) |
| `shopping.json` | [→ shopping.json](#shoppingjson) |
| `itineraries.json` | [→ itineraries.json](#itinerariesjson) |
| `faq.md` | [→ faq.md](#faqmd) |
| `experiences.md` | [→ experiencesmd](#experiencesmd) |

---

## _meta block (dùng chung cho mọi JSON file)

```json
"_meta": {
  "city": "lam-dong-da-lat",
  "last_updated": "YYYY-MM-DD",
  "agent_task": "T-002",
  "status": "complete | partial | empty",
  "partial_note": "string | null",
  "missing_fields": [],
  "data_sources": []
}
```

> `data_sources` bắt buộc điền — ghi tên nguồn thực tế đã tra cứu + tháng/năm.
> Xem danh sách nguồn hợp lệ tại `.agent/context/sql-table-mapping.md`.

---

## city.json

**Task:** T-001 | 

```json
{
  "_meta": { "...": "xem _meta block ở trên" },
  "data": {
    "id": "string (UUID từ SQL)",
    "name": "string",
    "slug": "string (kebab-case, theo provinces-34.md)",
    "province": "string (tên tỉnh MỚI sau sáp nhập)",
    "region": "Miền Bắc | Miền Trung | Miền Nam | Tây Nguyên",
    "description": "string",
    "special": "string",
    "best_season": "string",
    "best_months": [1, 3, 10],
    "weather": "string",
    "budget": {
      "low": "int (VND) | null",
      "high": "int (VND) | null",
      "currency": "VND"
    },
    "cuisine_summary": "string",
    "image_url": "string | null",
    "stats": {
      "rating_avg": "float | null",
      "review_count": "int | null",
      "favorite_count": "int | null",
      "view_count": "int | null"
    },
    "categories": ["string (slug)"],
    "is_active": "boolean"
  }
}
```

⚠️ `budget`, `stats`, `image_url` → dùng `null` nếu không có nguồn SQL. Không ước đoán số.

---

## destinations.json

**Task:** T-002 | 

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (UUID từ SQL)",
      "city_id": "string (city UUID)",
      "name": "string",
      "type": "attraction | beach | mountain | museum | temple | market | nature",
      "address": "string | null",
      "coordinates": { "lat": "float | null", "lng": "float | null" },
      "hours": "string | null",
      "description": "string",
      "tips": "string | null",
      "image_url": "string | null",
      "stats": { "rating_avg": "float | null", "review_count": "int | null" },
      "verified": "boolean",
      "entry_fee": "string | null"
    }
  ]
}
```

---

## hotels.json

**Task:** T-003 | 

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (UUID từ SQL)",
      "city_id": "string (city UUID)",
      "name": "string",
      "type": "hotel | resort | homestay | hostel | villa | guesthouse",
      "stars": "int (1-5) | null",
      "price_per_night": { "amount": "int (VND) | null", "currency": "VND" },
      "address": "string | null",
      "amenities": ["string"],
      "description": "string",
      "image_url": "string | null",
      "rating": "float | null",
      "booking_url": "string | null"
    }
  ]
}
```

---

## restaurants.json

**Task:** T-004 | 

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (UUID từ SQL)",
      "city_id": "string (city UUID)",
      "name": "string",
      "type": "restaurant | street_food | cafe | market_stall",
      "address": "string | null",
      "hours": "string | null",
      "price_range": "string | null",
      "specialties": ["string"],
      "description": "string",
      "tips": "string | null",
      "rating": "float | null",
      "must_try": "boolean"
    }
  ]
}
```

---

## foods.json

**Task:** T-004 |  category=food

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "name": "string",
      "local_name": "string",
      "category": "main_dish | snack | dessert | drink | specialty",
      "description": "string",
      "where_to_eat": ["string"],
      "price_range": "string | null",
      "must_try": "boolean",
      "vegetarian": "boolean | null",
      "tags": ["string"]
    }
  ]
}
```

---

## transport.json

**Task:** T-005 | 

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": {
    "getting_there": [
      {
        "type": "airplane | train | bus | car | motorbike | boat",
        "from": "string",
        "duration": "string",
        "price_range": "string | null",
        "providers": ["string"],
        "notes": "string | null"
      }
    ],
    "getting_around": [
      {
        "type": "taxi | grab | xe_om | bus | bicycle | motorbike_rental | walking",
        "price_info": "string | null",
        "notes": "string | null",
        "recommended": "boolean"
      }
    ]
  }
}
```

---

## tours.json

**Task:** T-005 | 

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (UUID từ SQL)",
      "city_id": "string (city UUID)",
      "name": "string",
      "duration": "string",
      "price": { "amount": "int (VND) | null", "currency": "VND", "per": "person | group" },
      "group_size": "string | null",
      "description": "string",
      "includes": ["string"],
      "excludes": ["string"],
      "image_url": "string | null",
      "difficulty": "easy | moderate | hard | null"
    }
  ]
}
```

---

## tickets.json

**Task:** T-006 |  hoặc Klook (≥2 nguồn)

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (UUID từ SQL)",
      "city_id": "string (city UUID)",
      "location_id": "string (UUID) | null",
      "name": "string",
      "price": {
        "adult": "int (VND) | null",
        "child": "int (VND) | null",
        "currency": "VND"
      },
      "price_source": "string (tên nguồn + tháng/năm — BẮT BUỘC nếu không từ SQL)",
      "hours": "string | null",
      "description": "string",
      "booking_required": "boolean | null"
    }
  ]
}
```

---

## events.json

**Task:** T-006 | 

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (UUID từ SQL)",
      "city_id": "string (city UUID)",
      "name": "string",
      "event_date": "string (tháng, năm, hoặc ngày cụ thể)",
      "location_text": "string",
      "cost": "string | null",
      "description": "string",
      "annual": "boolean",
      "highlight": "boolean"
    }
  ]
}
```

---

## shopping.json

**Task:** T-006 | 

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (UUID từ SQL)",
      "city_id": "string (city UUID)",
      "name": "string",
      "type": "market | mall | souvenir_shop | boutique | street",
      "items": ["string"],
      "address": "string | null",
      "opening_hours": "string | null",
      "price_range": "string | null",
      "tips": "string | null"
    }
  ]
}
```

---

## itineraries.json

**Task:** T-013 | **Nguồn:** destinations.json + hotels.json + restaurants.json cùng thành phố

> File quan trọng nhất cho chức năng "gợi ý lịch trình". RAG retrieve trực tiếp từ đây.  
> Sai địa điểm ở đây = chatbot đưa ra lịch trình không khả thi = trải nghiệm tệ nhất.

```json
{
  "_meta": { "...": "xem _meta block" },
  "data": [
    {
      "id": "string (slug, vd: lam-dong-da-lat-2n1d-couple)",
      "title": "string (vd: 'Đà Lạt 2N1Đ cho cặp đôi')",
      "duration_days": "int",
      "duration_nights": "int",
      "audience": "couple | family | solo | friends_group | any",
      "travel_style": "relax | explore | adventure | culture | mixed",
      "estimated_budget": {
        "low": "int (VND/người) | null",
        "high": "int (VND/người) | null",
        "currency": "VND"
      },
      "best_for_season": ["string"],
      "summary": "string (2-3 câu)",
      "days": [
        {
          "day_number": 1,
          "theme": "string",
          "blocks": [
            {
              "time_of_day": "morning | noon | afternoon | evening",
              "start_time": "string | null (HH:MM)",
              "activity": "string",
              "location_ref": {
                "type": "destination | hotel | restaurant | tour | shopping",
                "id": "string (UUID — PHẢI khớp id trong file json cùng thành phố) | null",
                "name": "string (phải khớp tên trong file gốc)"
              },
              "estimated_cost": "int (VND) | null",
              "notes": "string | null"
            }
          ]
        }
      ],
      "total_estimated_cost": {
        "amount": "int (VND/người) | null",
        "currency": "VND"
      },
      "tags": ["string"]
    }
  ]
}
```

**Quy tắc bắt buộc:**
1. Mỗi `location_ref.id` phải tồn tại trong file JSON nguồn cùng thành phố. Nếu chưa có → `id: null`, ghi `missing_fields`.
2. Các điểm trong cùng ngày phải di chuyển được hợp lý (kiểm tra `coordinates` từ `destinations.json`).
3. Tối thiểu 2 lịch trình/thành phố, khác `audience` hoặc `duration`.
4. `experiences.md` chỉ **tham chiếu** `id` lịch trình này, không viết lại giờ giấc chi tiết.

---

## faq.md

> **Vai trò:** Câu hỏi thường gặp dạng hội thoại — context, lý do, cảnh báo, out-of-scope.  
> **Không viết:** Số liệu cụ thể (giá, giờ, địa chỉ) đã có trong file JSON → thay bằng tham chiếu.  
> Xem chi tiết: `.agent/context/data-role-design.md`

**Task:** T-007 | **Nguồn:** vietnamtourism.gov.vn + Klook/Traveloka (≥2 nguồn cho giá)

### Frontmatter bắt buộc

```yaml
---
city: lam-dong-da-lat
city_name: Đà Lạt
task: T-007
generated_from: tra-cuu-nguon-thuc-te  # xem .agent/context/sql-table-mapping.md
last_updated: YYYY-MM-DD
data_sources:
  - "vietnamtourism.gov.vn (MM/YYYY)"  # thay bằng nguồn thực tế đã tra
  - "Vietnam Tourism: vietnamtourism.gov.vn (MM/YYYY)"
status: complete | partial
---
```

### Cấu trúc bắt buộc (6 sections, ≥ 8 Q&A tổng)

```
# ❓ FAQ Du Lịch {Tên thành phố}

## 🗓️ Thời điểm & Thời tiết          ← ≥ 2 câu hỏi
## 💰 Chi phí & Ngân sách             ← ≥ 2 câu hỏi
## 🚗 Di chuyển                       ← ≥ 2 câu hỏi
## 🏨 Lưu trú                         ← ≥ 1 câu hỏi
## 🍜 Ẩm thực                         ← ≥ 1 câu hỏi
## ❓ Câu hỏi ngoài phạm vi           ← BẮT BUỘC ≥ 1 câu (xử lý out-of-scope)
## ⚠️ An toàn & Lưu ý                ← ≥ 1 câu hỏi
```

### Format mỗi Q&A

```markdown
**Q: [Câu hỏi cụ thể của người dùng]**
A: [Thông tin chính]. [Nguồn nếu có số liệu cụ thể]. [Gợi ý thực tế nếu cần]
```

### Mẫu câu out-of-scope (BẮT BUỘC có trong mỗi file)

```markdown
## ❓ Câu hỏi ngoài phạm vi

**Q: Giá vé vào [địa điểm cụ thể] là bao nhiêu?**
A: Hiện chúng tôi chưa có thông tin giá vé cập nhật cho địa điểm này.
   Bạn có thể kiểm tra tại Klook (klook.com/vi) hoặc liên hệ trực tiếp điểm đến.
```

### Quy tắc nội dung

| Loại thông tin | Làm gì |
|---|---|
| Giá cụ thể | Chỉ ghi nếu có nguồn + ghi rõ nguồn và tháng/năm |
| Giờ mở cửa | Ghi nếu có Google Maps / website chính thức, thêm "— xác nhận trước khi đến" |
| Không có dữ liệu | Ghi hướng dẫn tìm nguồn, không để trống, không bịa |
| Rating / điểm số | Tuyệt đối không bịa — bỏ qua field này |

> ⚠️ Không đặt giới hạn số từ tối thiểu cho câu trả lời — câu ngắn đúng tốt hơn câu dài bịa. Xem RULE-20.

---

## experiences.md

> **Vai trò:** Tips hành vi, timing, cảnh báo thực tế, flow lịch trình tổng — những thứ KHÔNG có field JSON nào lưu được.  
> **Không viết:** Địa chỉ, giờ mở cửa, giá đã có trong `destinations.json` / `hotels.json` / `tickets.json` → thay bằng `*(xem file.json)*`.  
> Xem chi tiết: `.agent/context/data-role-design.md`

**Task:** T-008 | **Nguồn:** vietnamtourism.gov.vn + Klook/Traveloka (≥2 nguồn cho giá)

### Frontmatter bắt buộc

```yaml
---
city: lam-dong-da-lat
city_name: Đà Lạt
task: T-008
generated_from: tra-cuu-nguon-thuc-te  # xem .agent/context/sql-table-mapping.md
last_updated: YYYY-MM-DD
data_sources:
  - "vietnamtourism.gov.vn (MM/YYYY)"  # thay bằng nguồn thực tế đã tra
  - "Vietnam Tourism: vietnamtourism.gov.vn (MM/YYYY)"
  - "Klook VN: klook.com/vi (MM/YYYY)"
status: complete | partial
---
```

### Cấu trúc bắt buộc (5 sections)

```
# 🌟 Kinh Nghiệm Du Lịch {Tên thành phố}

## 📍 Địa Điểm Không Thể Bỏ Qua      ← ≥ 3 địa điểm
## 🎒 Lịch Trình Gợi Ý               ← ≥ 2 lịch trình (tóm tắt, trỏ tới itineraries.json)
## 🚨 Kinh Nghiệm An Toàn             ← ≥ 2 lưu ý thực tế
## 💡 Tips Thực Tế                    ← ≥ 4 tips phân loại
## 🛒 Mua Sắm & Đặc Sản Mang Về      ← bảng đặc sản + nơi mua
```

### Format địa điểm

```markdown
### N. {Tên địa điểm}
**Loại:** {type}
**Khu vực:** {khu vực chung — không ghi địa chỉ số nhà nếu không có SQL}
**Giờ mở cửa:** {giờ} *(xác nhận trước khi đến)*
**Giá vé:** {giá + "(nguồn, MM/YYYY)"} HOẶC *Liên hệ điểm đến để có giá cập nhật*
**Tip:** {tip thực tế ngắn gọn}
```

### Format lịch trình (CHỈ tóm tắt — không viết giờ giấc chi tiết)

```markdown
### {N} Ngày {M} Đêm — [Loại hình]
> Chi tiết → `itineraries.json` id: **`{id-lịch-trình}`**

- Ngày 1: [2-3 hoạt động chính theo flow]
- Ngày 2: [...]
```

> Không viết lại toàn bộ lịch trình ở đây — tránh hai nguồn lệch nhau khi update.

### Quy tắc nội dung

| Thông tin | Yêu cầu |
|---|---|
| Địa chỉ số nhà cụ thể | Chỉ ghi nếu có trong SQL |
| Giá | Phải kèm nguồn + tháng/năm |
| Tên quán ăn / khách sạn | Ưu tiên lấy từ `restaurants.json` / `hotels.json` cùng thành phố |
| Số điện thoại, website | Chỉ từ SQL hoặc website chính thức — không bịa |

