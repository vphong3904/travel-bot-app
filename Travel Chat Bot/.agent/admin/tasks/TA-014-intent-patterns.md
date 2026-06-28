# TA-014 · Intent Pattern Manager + Test Live
> **Phase:** P2  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-001 DONE  |  **Estimated:** 4–5 giờ

## Mục tiêu
Cho phép sửa intent keywords mà không cần deploy lại. Phát hiện keyword là substring của tên tỉnh.

## Backend

### Bước 1 — Tạo file `intent_patterns.json`

```bash
# Tạo file từ dict hiện có trong nlp_preprocessor.py
# backend/app/data/intent_patterns.json
```

```json
{
  "ask_destination": ["điểm đến", "địa điểm", "tham quan", "nên đi đâu", "có gì chơi"],
  "find_hotel": ["khách sạn", "nhà nghỉ", "lưu trú", "ở đâu", "phòng"],
  "find_food": ["ăn gì", "quán ăn", "món ngon", "nhà hàng", "đặc sản"],
  "get_itinerary": ["lịch trình", "kế hoạch", "bao nhiêu ngày", "đi tour"],
  "ask_transport": ["đi bằng gì", "xe buýt", "máy bay", "tàu hỏa", "cách đi"],
  "ask_price": ["bao nhiêu tiền", "giá vé", "chi phí", "budget"],
  "general": []
}
```

### Bước 2 — Sửa nlp_preprocessor.py

```python
# Thay dict hardcode thành đọc từ file
import json
from pathlib import Path
from functools import lru_cache

@lru_cache(maxsize=1)
def _load_intent_patterns() -> dict:
    path = Path(__file__).parent.parent / "data" / "intent_patterns.json"
    return json.loads(path.read_text(encoding="utf-8"))

def reload_intent_patterns():
    """Gọi sau khi file được cập nhật qua API."""
    _load_intent_patterns.cache_clear()
```

### Bước 3 — Routes

```python
GET  /admin/intent-patterns
# Returns: { intent: { keywords: [], collision_warnings: [] } }
# collision_warnings: keywords là substring của bất kỳ tên tỉnh nào

POST /admin/intent-patterns/{intent}/keywords
# body: { keyword: "..." }
# Thêm keyword → lưu file → reload_intent_patterns()
# Audit log

DELETE /admin/intent-patterns/{intent}/keywords/{keyword}
# Xóa keyword → lưu file → reload

POST /admin/intent-patterns/test
# body: { text: "Tìm phòng ở Hải Phòng" }
# Gọi detect_intent() thật → trả { intent, confidence, matched_keywords }

GET /admin/intent-patterns/collision-warnings
# Tìm: keyword nào là substr của city name trong city_slug_display_name.json
```

## Frontend

**Layout:** List intents (sidebar trái dạng tabs) + Keyword list (phải)

**Keyword list:** Mỗi keyword hiện badge `⚠️ Collision` nếu là substr của tên tỉnh.

**Ô Test thử** (nổi bật, sticky top):
```
[________________________ Nhập câu hỏi để test...] [Test]
→ Intent: find_hotel (confidence: 0.72)
→ Matched keywords: "phòng" ⚠️ (collision với "Hải Phòng")
```

**Workflow thêm keyword:**
1. Click "+ Thêm keyword" → input nhỏ xuất hiện inline
2. Gõ keyword → nếu là collision → hiện warning ngay trước khi lưu
3. Confirm → lưu

## Checklist DONE
- [ ] INTENT_PATTERNS đọc từ file JSON (reload được không cần restart)
- [ ] Thêm/xóa keyword hoạt động, phản ánh ngay trong detect_intent()
- [ ] Test live gọi detect_intent() thật (không mock)
- [ ] Collision warning tự động (check với city display names)
- [ ] Audit log mỗi thay đổi

```
completed_at:
```
