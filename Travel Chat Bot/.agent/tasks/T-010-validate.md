# Task T-010 — Validate toàn bộ JSON Schema

| Trường | Giá trị |
|---|---|
| **Task ID** | T-010 |
| **Status** | ⬜ TODO |
| **Priority** | 🟡 MEDIUM |
| **Depends on** | T-001 → T-009 và T-013 phải DONE hết |
| **Estimated** | ~30 phút |

---

## 🎯 Mục tiêu

Chạy validation toàn bộ files trong `knowledge-base/` trước khi import vào Qdrant.

## 🔢 Checklist validation từng file type

### city.json (×10)
- [ ] `id` là UUID hợp lệ
- [ ] `region` ∈ {Miền Bắc, Miền Trung, Miền Nam, Tây Nguyên}
- [ ] `budget.low < budget.high`
- [ ] `best_months` là array int [1..12]
- [ ] `stats.rating_avg` ∈ [1.0, 5.0]

### destinations.json (×10)
- [ ] `destination_id` khớp với UUID trong city-slugs.json
- [ ] `type` ∈ {attraction, beach, mountain, museum, temple, market, nature}
- [ ] `coordinates.lat` ∈ [-90, 90] nếu không null
- [ ] `coordinates.lng` ∈ [-180, 180] nếu không null

### hotels.json (×10)
- [ ] `type` ∈ {hotel, resort, homestay, hostel, villa, guesthouse}
- [ ] `stars` ∈ [1..5] hoặc null
- [ ] `price_per_night.amount > 0`

### foods.json (×10)
- [ ] Không trùng lặp `name` trong cùng file
- [ ] `category` ∈ {main_dish, snack, dessert, drink, specialty}

### itineraries.json (×10) ⭐ ưu tiên cao — đây là dữ liệu dễ hallucinate nhất
- [ ] Mỗi file có tối thiểu 2 lịch trình (khác `audience` hoặc `duration_days`)
- [ ] **Mọi `location_ref.id` khác null phải tồn tại** trong `destinations.json`/`hotels.json`/
      `restaurants.json`/`tours.json` **của cùng thành phố** — đây là check quan trọng nhất,
      sai ở đây nghĩa là chatbot sẽ gợi ý đi tới 1 địa điểm không có thật
- [ ] `total_estimated_cost.amount` ≈ tổng `estimated_cost` của các block (cho phép sai số nhỏ
      do làm tròn, không được lệch lớn — dấu hiệu của số liệu bịa)
- [ ] Không có 2 block liên tiếp cùng ngày mà địa điểm cách xa nhau bất hợp lý (đối chiếu
      `coordinates` trong `destinations.json` nếu có)

### Markdown files
- [ ] Tất cả file có frontmatter YAML
- [ ] `city` field khớp với slug trong city-slugs.json
- [ ] `task` field khớp với task ID thực tế
- [ ] Phần "Lịch Trình Gợi Ý" trong `experiences.md` tham chiếu đúng `id` có thật trong
      `itineraries.json` cùng thành phố (không trỏ tới id không tồn tại)

## 🛠️ Script validation (nếu có Python)

```bash
# Tạo script validation đơn giản
python -c "
import json, os, sys
errors = []
cities = ['lam-dong-da-lat', 'an-giang-phu-quoc', 'tuyen-quang-ha-giang', 'da-nang-hoi-an', 'lao-cai-sa-pa',
          'quang-ninh-ha-long', 'hue', 'khanh-hoa-nha-trang', 'lam-dong-mui-ne', 'ninh-binh']
for city in cities:
    for f in ['city.json', 'destinations.json', 'hotels.json',
              'foods.json', 'transport.json', 'itineraries.json']:
        path = f'knowledge-base/{city}/{f}'
        if not os.path.exists(path):
            errors.append(f'MISSING: {path}')
            continue
        try:
            data = json.load(open(path))
            if '_meta' not in data:
                errors.append(f'NO _meta: {path}')
        except Exception as e:
            errors.append(f'INVALID JSON: {path}: {e}')

    # Cross-reference check: itineraries.json -> location_ref.id phải tồn tại
    itin_path = f'knowledge-base/{city}/itineraries.json'
    if os.path.exists(itin_path):
        try:
            itin = json.load(open(itin_path))
            known_ids = set()
            for f in ['destinations.json', 'hotels.json', 'restaurants.json', 'tours.json']:
                p = f'knowledge-base/{city}/{f}'
                if os.path.exists(p):
                    d = json.load(open(p))
                    items = d.get('data', [])
                    if isinstance(items, list):
                        known_ids.update(item.get('id') for item in items if 'id' in item)
            for itinerary in itin.get('data', []):
                for day in itinerary.get('days', []):
                    for block in day.get('blocks', []):
                        ref = block.get('location_ref', {})
                        ref_id = ref.get('id')
                        if ref_id and ref_id not in known_ids:
                            errors.append(
                                f'{city}: itineraries.json -> {itinerary.get(\"id\")} '
                                f'references unknown id {ref_id}'
                            )
        except Exception as e:
            errors.append(f'INVALID itineraries.json: {itin_path}: {e}')

if errors:
    print('\n'.join(errors))
    sys.exit(1)
else:
    print('All files valid!')
"
```

## 📝 Ghi chú

Mọi lỗi tìm được → tạo task mới `T-010-fix-{issue}.md` thay vì sửa trực tiếp.

---

### Kết quả validation
```
Ngày chạy:
Tổng files checked:
Errors found:
```
