# TA-015 · Content Management — Destinations + Hotels (mẫu)
> **Phase:** P3  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-001 DONE, TA-009 DONE  |  **Estimated:** 5–6 giờ

## Mục tiêu
Xây generic content service (đọc/ghi file JSON). Làm 2 loại mẫu (destinations + hotels). TA-016 copy pattern cho 9 loại còn lại.

## Backend — Generic Content Service

**File mới:** `backend/app/services/content_service.py`

```python
"""
File-backed content service: đọc/ghi JSON trong knowledge-base/<city>/<type>.json
Một service dùng cho tất cả 11 content types.
"""
import json, uuid
from pathlib import Path
from datetime import date

KB_ROOT = Path("knowledge-base")

CONTENT_TYPES = {
    "destinations", "hotels", "tours", "foods", "restaurants",
    "shopping", "itineraries", "events", "transport", "faq", "experiences"
}

def _get_file_path(content_type: str, city_slug: str) -> Path:
    ext = ".md" if content_type in ("faq", "experiences") else ".json"
    return KB_ROOT / city_slug / f"{content_type}{ext}"

def _read_file(content_type: str, city_slug: str) -> dict:
    path = _get_file_path(content_type, city_slug)
    if not path.exists():
        return {"_meta": {"city": city_slug, "status": "partial"}, "data": []}
    return json.loads(path.read_text(encoding="utf-8"))

def _write_file(content_type: str, city_slug: str, data: dict):
    path = _get_file_path(content_type, city_slug)
    path.parent.mkdir(parents=True, exist_ok=True)
    data["_meta"]["last_updated"] = date.today().isoformat()
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")

async def list_items(content_type, city_slug, status=None, search=None, page=1, page_size=20):
    data = _read_file(content_type, city_slug)
    items = [i for i in data.get("data", []) if not i.get("is_deleted")]
    if status: items = [i for i in items if i.get("status") == status]
    if search:
        q = search.lower()
        items = [i for i in items if q in json.dumps(i, ensure_ascii=False).lower()]
    total = len(items)
    start = (page-1) * page_size
    return {"items": items[start:start+page_size], "total": total, "page": page}

async def create_item(content_type, city_slug, item_data: dict) -> dict:
    data = _read_file(content_type, city_slug)
    new_item = {"id": str(uuid.uuid4()), "status": "draft", "is_deleted": False,
                "created_at": date.today().isoformat(), **item_data}
    data["data"].append(new_item)
    _write_file(content_type, city_slug, data)
    return new_item

async def update_item(content_type, city_slug, item_id, updates: dict) -> dict | None:
    data = _read_file(content_type, city_slug)
    for i, item in enumerate(data["data"]):
        if item["id"] == item_id:
            data["data"][i] = {**item, **updates, "updated_at": date.today().isoformat()}
            _write_file(content_type, city_slug, data)
            return data["data"][i]
    return None

async def soft_delete_item(content_type, city_slug, item_id) -> bool:
    return await update_item(content_type, city_slug, item_id, {"is_deleted": True}) is not None

async def publish_item(content_type, city_slug, item_id) -> dict | None:
    return await update_item(content_type, city_slug, item_id, {"status": "published"})
```

**Router generic** — `backend/app/api/routes/content.py` (file mới):

```python
router = APIRouter(prefix="/admin/content", tags=["Content Management"])

VALID_TYPES = "destinations|hotels|tours|foods|restaurants|shopping|itineraries|events|transport|faq|experiences"

@router.get("/{content_type}")
async def list_content(content_type: str = Path(..., regex=f"^({VALID_TYPES})$"),
                       city_slug: str = Query(...), ...): ...

@router.post("/{content_type}", status_code=201)
async def create_content(content_type: str, city_slug: str = Query(...), body: dict = Body(...), ...):
    item = await content_service.create_item(content_type, city_slug, body)
    await log_audit(mongo_db, actor=current_user, action="create",
                    resource_type="content", resource_id=item["id"], after_value=item)
    return item

@router.patch("/{content_type}/{item_id}")
async def update_content(...): ...

@router.delete("/{content_type}/{item_id}", status_code=204)
async def delete_content(...): ...   # soft delete

@router.patch("/{content_type}/{item_id}/publish")
async def publish_content(...):
    # Set status=published → trigger embedding job cho city_slug
    item = await content_service.publish_item(content_type, city_slug, item_id)
    # Tạo EmbeddingJob cho toàn bộ city_slug (không phải từng item)
    job = EmbeddingJob(entity_id=city_slug_as_uuid_or_str, entity_type="city_content", status="pending")
    ...
```

Đăng ký router trong `__init__.py`: `app.include_router(content_router)`.

## Frontend

**CitySelector** (dùng chung): dropdown 34 thành phố từ `/admin/city-mappings/valid-slugs`.

**ContentPage** (template dùng lại):
```typescript
// src/pages/content/ContentPage.tsx
export function ContentPage({ contentType, columns, formSchema, formFields }) {
  const [citySlug, setCitySlug] = useState("");
  const [formOpen, setFormOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);

  const { data } = useQuery({
    queryKey: ["content", contentType, citySlug],
    queryFn: () => contentApi.list(contentType, citySlug).then(r => r.data),
    enabled: !!citySlug,
  });

  return (
    <div className="p-6 space-y-4">
      <PageHeader title={CONTENT_TYPE_LABELS[contentType]} action={<Button onClick={() => setFormOpen(true)}>+ Thêm</Button>} />
      <CitySelector value={citySlug} onChange={setCitySlug} />
      {!citySlug ? (
        <p className="text-muted-foreground text-sm">Chọn thành phố để xem dữ liệu</p>
      ) : (
        <DataTable data={data?.items || []} columns={columns} />
      )}
      <ContentFormSheet open={formOpen} contentType={contentType} citySlug={citySlug}
                        item={selectedItem} schema={formSchema} fields={formFields}
                        onClose={() => setFormOpen(false)} onSuccess={() => refetch()} />
    </div>
  );
}
```

**DestinationsPage** + **HotelsPage** — mỗi file chỉ 20-30 dòng định nghĩa columns + schema.

## Checklist DONE
- [ ] content_service.py đọc/ghi file JSON đúng `_meta` structure
- [ ] Soft delete không xóa khỏi file
- [ ] Publish → trigger EmbeddingJob
- [ ] CitySelector component hoạt động
- [ ] Destinations CRUD đầy đủ
- [ ] Hotels CRUD đầy đủ
- [ ] Audit log

```
completed_at:
```
