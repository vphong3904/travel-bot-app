# Knowledge-base — Format 1 thành phố (mẫu: Đà Lạt)

> Dùng để build thư mục KB cho thành phố mới rồi nạp vào SQL bằng
> `backend/scripts/seed_kb_to_sql.py`. Field đầy đủ: `.agent/schemas/SCHEMAS.md`.
> Mẫu tham chiếu thực tế: `backend/knowledge-base/lam-dong-da-lat/`.

## 1. Cấu trúc thư mục

Tên thư mục = `<tỉnh-mới>-<khu-vực>` (vd `lam-dong-da-lat`). Gồm **12 file**:

```
city.json          ← thông tin thành phố (1 object)
destinations.json  ← điểm tham quan + điểm vui chơi T-037 (mảng)
hotels.json        ← khách sạn (mảng)
restaurants.json   ← nhà hàng/quán (mảng)
foods.json         ← đặc sản/món ăn (mảng) — link tới restaurants
tours.json         ← tour (mảng)
events.json        ← lễ hội/sự kiện (mảng)
shopping.json      ← mua sắm (mảng)
transport.json     ← di chuyển (object: getting_there / getting_around)
itineraries.json   ← lịch trình mẫu (mảng)
faq.md             ← Q&A hội thoại → bảng knowledge_entries (category=faq)
experiences.md     ← kinh nghiệm/tips → bảng knowledge_entries (category=tip)
```

Bảng đích trong SQL (qua `seed_kb_to_sql.py`):

| File | Bảng SQL |
|---|---|
| city.json | `destinations` (1 row/thành phố) |
| destinations.json | `locations` (+ `tickets` nếu có `entry_fee`) |
| hotels / tours / events / shopping / transport / restaurants / foods | bảng cùng tên |
| itineraries.json | `itineraries` + `itinerary_items` |
| faq.md / experiences.md | `knowledge_entries` |

## 2. Khối `_meta` (bắt buộc đầu mỗi file JSON)

```json
{
  "_meta": {
    "city": "lam-dong-da-lat",
    "last_updated": "2026-06-23",
    "agent_task": "T-002",
    "status": "complete | partial | empty",
    "missing_fields": [],
    "data_sources": ["vietnamtourism.gov.vn (06/2026)"]
  },
  "data": "..."
}
```

## 3. city.json (object)

```json
{ "_meta": {}, "data": {
  "id": "019ef504-6d4c-7eb7-885f-583deab45385",
  "name": "Đà Lạt", "slug": "lam-dong-da-lat",
  "province": "Lâm Đồng", "region": "Tây Nguyên",
  "description": "...", "special": "Thành phố Ngàn Hoa",
  "best_season": "...", "best_months": [11,12,1,2,3],
  "weather": "...", "cuisine_summary": "...",
  "budget": { "low": null, "high": null, "currency": "VND" },
  "image_url": null,
  "stats": { "rating_avg": null, "review_count": null, "favorite_count": null, "view_count": null },
  "categories": ["explore","relax","nature"], "is_active": true
}}
```

> `id` ở đây dùng làm `city_id` cho mọi file khác trong cùng thư mục.

## 4. Mẫu 1 entry mỗi file (mảng `data`)

**destinations.json** — `type`: `nature|beach|mountain|museum|temple|market` … +
điểm vui chơi (T-037): `entertainment|amusement_park|water_park|theme_park|aquarium|zoo|kids_zone`.
```json
{ "id":"<uuid>", "city_id":"<id city.json>", "name":"Hồ Xuân Hương",
  "type":"nature", "address":"...", "coordinates":{"lat":null,"lng":null},
  "hours":"24/7", "description":"...", "tips":"...", "entry_fee":null,
  "image_url":null, "stats":{"rating_avg":null,"review_count":null}, "verified":true }
```

**hotels.json** — `type` hotel/homestay/resort/hostel/villa; `stars` 1–5;
`price_per_night:{amount,currency:"VND"}`; `amenities[]`.

**restaurants.json** — `id` (UUID **quan trọng** — foods trỏ vào), `type`,
`specialties[]`, `must_try`.

**foods.json** — `category` main_dish/snack/dessert/drink/specialty;
`where_to_eat:["<restaurant.id>"]` (phải khớp UUID restaurant cùng thư mục).

**tours.json** — `price:{amount,currency,per}`, `includes[]`, `excludes[]`, `difficulty`.

**events.json** — `event_date`, `cost`, `annual`, `highlight`.

**shopping.json** — `type` market/mall/street/specialty_store, `items[]`.

**transport.json** — object:
```json
{ "_meta": {}, "data": {
  "getting_there":  [{ "type":"airplane", "from":"...", "duration":"...", "price_range":null, "providers":["..."], "notes":"..." }],
  "getting_around": [{ "type":"taxi", "price_info":null, "notes":"...", "recommended":true }]
}}
```

**itineraries.json** — `id` dạng slug (vd `dalat-2n1d-couple`);
`days[].blocks[].location_ref:{type,id,name}` trỏ tới điểm cùng thư mục.

## 5. faq.md / experiences.md

Frontmatter YAML:
```yaml
---
city: lam-dong-da-lat
city_name: Đà Lạt
task: T-007            # experiences.md dùng T-008
last_updated: 2026-06-23
data_sources: ["vietnamtourism.gov.vn (06/2026)"]
status: complete
---
```

- **faq.md** — sections: Thời điểm & Thời tiết · Chi phí & Ngân sách · Di chuyển ·
  Lưu trú · Ẩm thực · Câu hỏi ngoài phạm vi · An toàn & Lưu ý.
  Mỗi mục: `**Q: ...**` rồi dòng `A: ...`.
- **experiences.md** — sections: Địa Điểm Không Thể Bỏ Qua · Lịch Trình Gợi Ý ·
  Kinh Nghiệm An Toàn · Tips Thực Tế · Mua Sắm & Đặc Sản.

## 6. Quy tắc bắt buộc

- **Không bịa số**: giá/giờ chưa chắc → `null` + ghi `missing_fields`; giá phải có **≥2 nguồn** (RULE-18).
- `city_id` mọi file = `id` trong `city.json` cùng thư mục.
- `restaurants[].id` ↔ `foods[].where_to_eat` phải khớp UUID.
- faq/experiences **không** lặp số liệu đã có trong JSON → trỏ `*(xem city.json)*`.
- Build xong → `python backend/scripts/seed_kb_to_sql.py` (tự sinh UUID deterministic
  theo slug+tên, ON CONFLICT idempotent, auto-enqueue embedding job).

## 7. Cách chạy import (Windows)

```powershell
cd F:\trip_advisor_chatbot_project\backend
python scripts\seed_kb_to_sql.py                 # tất cả thành phố có city.json
python scripts\seed_kb_to_sql.py --city <slug>   # 1 thành phố
python scripts\seed_kb_to_sql.py --dry-run       # chỉ in, không ghi DB
```

> Lưu ý môi trường: nếu máy có Postgres local chiếm cổng 5432, trỏ
> `DATABASE_URL=postgresql://user:12345678@127.0.0.1:<cổng-docker>/pdtrip_ai_db`
> tới Postgres trong Docker trước khi chạy.
