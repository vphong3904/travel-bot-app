# TA-002 · Audit Log Service + MongoDB Collection
> **Phase:** P0 — Nền tảng  
> **Nhãn:** [BE]  
> **Status:** ⬜ TODO  
> **Priority:** 🔴 CRITICAL  
> **Dependency:** TA-001 DONE (cần UserRole enum)  
> **Estimated:** 2–3 giờ

---

## Mục tiêu

Tạo `audit_service.py` có thể tái sử dụng ở mọi route admin. Tạo MongoDB collection `admin_audit_logs` với index đúng. Không cần middleware toàn cục — chỉ gọi `log_audit()` thủ công sau mỗi mutating action (rõ ràng hơn, dễ audit khi review code).

---

## Bước 1 — Thêm collection vào mongo.py

**File:** `backend/app/db/mongo.py` (MỞ RỘNG — không xoá code cũ)

```python
# Thêm constant
COLLECTION_AUDIT_LOGS = "admin_audit_logs"

# Trong hàm _ensure_indexes() hoặc startup event — thêm:
async def ensure_audit_log_indexes(db):
    """Tạo index cho admin_audit_logs nếu chưa có."""
    await db[COLLECTION_AUDIT_LOGS].create_index("actor_id")
    await db[COLLECTION_AUDIT_LOGS].create_index([("created_at", -1)])
    await db[COLLECTION_AUDIT_LOGS].create_index("resource_type")
    await db[COLLECTION_AUDIT_LOGS].create_index("action")
    # Compound index cho query phổ biến nhất: lọc theo actor + ngày
    await db[COLLECTION_AUDIT_LOGS].create_index(
        [("actor_id", 1), ("created_at", -1)]
    )
```

Gọi `ensure_audit_log_indexes()` trong startup event của `main.py`.

---

## Bước 2 — Tạo Audit Service

**File mới:** `backend/app/services/audit_service.py`

```python
"""
Audit Log Service — ghi lại mọi thao tác admin vào MongoDB.

Cách dùng:
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="update",
        resource_type="knowledge_entry",
        resource_id=str(entry_id),
        before_value=before_dict,
        after_value=after_dict,
        request=request,  # optional, để lấy IP + user_agent
    )
"""

import uuid
from datetime import datetime, timezone
from typing import Any

from fastapi import Request
from app.db.mongo import COLLECTION_AUDIT_LOGS
from app.db.models.user import User


VALID_ACTIONS = frozenset({
    "create", "update", "delete",
    "login", "logout", "login_failed",
    "role_change", "config_change",
    "embed_trigger", "promote_to_kb",
})

VALID_RESOURCE_TYPES = frozenset({
    "knowledge_entry", "user", "chat_session",
    "system_config", "content", "media",
    "intent_pattern", "city_mapping", "notification",
})


async def log_audit(
    mongo_db,
    actor: User,
    action: str,
    resource_type: str,
    resource_id: str = "",
    before_value: dict[str, Any] | None = None,
    after_value: dict[str, Any] | None = None,
    request: Request | None = None,
    extra: dict[str, Any] | None = None,
) -> str:
    """
    Ghi 1 audit log entry vào MongoDB.
    
    Returns: id của document vừa tạo
    """
    ip_address = ""
    user_agent = ""
    
    if request:
        # Lấy IP thật sau reverse proxy
        forwarded_for = request.headers.get("X-Forwarded-For")
        ip_address = forwarded_for.split(",")[0].strip() if forwarded_for else str(request.client.host)
        user_agent = request.headers.get("User-Agent", "")
    
    doc = {
        "id": str(uuid.uuid4()),
        "actor_id": str(actor.id),
        "actor_email": actor.email,       # snapshot email để dễ đọc log
        "actor_role": actor.role,
        "action": action,
        "resource_type": resource_type,
        "resource_id": resource_id,
        "before_value": before_value,
        "after_value": after_value,
        "ip_address": ip_address,
        "user_agent": user_agent,
        "extra": extra or {},
        "created_at": datetime.now(timezone.utc),
    }
    
    result = await mongo_db[COLLECTION_AUDIT_LOGS].insert_one(doc)
    return str(result.inserted_id)


def model_to_audit_dict(obj) -> dict:
    """
    Convert SQLAlchemy model instance thành dict để lưu vào before/after_value.
    Tự động loại trừ các field nhạy cảm.
    """
    EXCLUDE_FIELDS = {"password_hash", "hashed_password"}
    
    if hasattr(obj, "__dict__"):
        return {
            k: str(v) if hasattr(v, "__str__") else v
            for k, v in obj.__dict__.items()
            if not k.startswith("_") and k not in EXCLUDE_FIELDS
        }
    return {}
```

---

## Bước 3 — Pydantic Schemas cho Audit Log API

**File:** `backend/app/db/schemas/admin.py` (thêm vào)

```python
class AuditLogResponse(BaseModel):
    id: str
    actor_id: str
    actor_email: str
    actor_role: str
    action: str
    resource_type: str
    resource_id: str
    before_value: dict | None
    after_value: dict | None
    ip_address: str
    created_at: datetime

class AuditLogListResponse(BaseModel):
    items: list[AuditLogResponse]
    total: int
    page: int
    page_size: int
```

---

## Bước 4 — GET /admin/audit-logs endpoint

**File:** `backend/app/api/routes/admin.py` (thêm route mới)

```python
@router.get("/audit-logs", response_model=AuditLogListResponse)
async def get_audit_logs(
    actor_id: str | None = Query(None),
    action: str | None = Query(None),
    resource_type: str | None = Query(None),
    from_date: datetime | None = Query(None),
    to_date: datetime | None = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])),
    mongo_db = Depends(get_mongo_db),
):
    """Xem audit log — chỉ ADMIN và SUPER_ADMIN."""
    query = {}
    if actor_id:
        query["actor_id"] = actor_id
    if action:
        query["action"] = action
    if resource_type:
        query["resource_type"] = resource_type
    if from_date or to_date:
        query["created_at"] = {}
        if from_date:
            query["created_at"]["$gte"] = from_date
        if to_date:
            query["created_at"]["$lte"] = to_date
    
    total = await mongo_db[COLLECTION_AUDIT_LOGS].count_documents(query)
    skip = (page - 1) * page_size
    
    cursor = mongo_db[COLLECTION_AUDIT_LOGS].find(query).sort(
        "created_at", -1
    ).skip(skip).limit(page_size)
    
    items = await cursor.to_list(length=page_size)
    
    return AuditLogListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
    )
```

---

## Checklist DONE

- [ ] `COLLECTION_AUDIT_LOGS = "admin_audit_logs"` thêm vào `mongo.py`
- [ ] Indexes đã được tạo khi startup
- [ ] `audit_service.py` tạo đúng — có docstring, type hints đầy đủ
- [ ] `model_to_audit_dict()` không leak `password_hash`
- [ ] Route `GET /admin/audit-logs` hoạt động, filter được theo actor/action/date
- [ ] Test thủ công: tạo 1 entry thủ công qua MongoDB shell → GET → thấy kết quả
- [ ] Unit test: mock mongo_db và kiểm tra document được insert đúng fields

---

## Ghi chú khi DONE

```
completed_at:
notes:
```
