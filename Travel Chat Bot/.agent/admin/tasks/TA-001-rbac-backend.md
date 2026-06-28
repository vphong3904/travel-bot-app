# TA-001 · RBAC 4 Role — Backend
> **Phase:** P0 — Nền tảng  
> **Nhãn:** [BE]  
> **Status:** ✅ DONE  
> **Priority:** 🔴 CRITICAL — Mọi task khác phụ thuộc  
> **Dependency:** Không có  
> **Estimated:** 3–4 giờ

---

## Mục tiêu

Nâng cấp hệ thống phân quyền từ `user.role` dạng string 2 cấp (`user`/`admin`) lên **4 cấp enum** và thay thế `require_admin` bằng `require_role` linh hoạt. Đây là nền tảng bắt buộc cho toàn bộ Web Admin.

---

## Bước 1 — Sửa UserRole Enum trong model

**File:** `backend/app/db/models/user.py`

```python
# Thêm enum trước class User
from enum import Enum as PyEnum

class UserRole(str, PyEnum):
    SUPER_ADMIN     = "super_admin"
    ADMIN           = "admin"
    CONTENT_MANAGER = "content_manager"
    MODERATOR       = "moderator"
    USER            = "user"          # giữ nguyên cho app user thường

# Trong class User — SỬA cột role:
# TRƯỚC: role: Mapped[str] = mapped_column(String(20), default="user")
# SAU:
role: Mapped[str] = mapped_column(
    String(30),
    default=UserRole.USER,
    nullable=False
)
```

> ⚠️ KHÔNG xoá giá trị `"user"` — app hiện tại vẫn dùng cho người dùng cuối.

---

## Bước 2 — Tạo Alembic Migration

```bash
cd backend
alembic revision --autogenerate -m "extend_user_role_to_4_levels"
```

Kiểm tra file migration tự sinh:
- Phải thấy `ALTER COLUMN role TYPE VARCHAR(30)` hoặc tương đương
- KHÔNG được có DROP TABLE hay DROP COLUMN nào

```bash
alembic upgrade head
```

> Ghi tên file migration vào task này khi tạo xong: `migration: alembic/versions/XXX_extend_user_role_to_4_levels.py`

---

## Bước 3 — Viết require_role dependency

**File mới:** `backend/app/api/deps.py` (MỞ RỘNG — không xoá code cũ)

```python
# Thêm vào deps.py — giữ nguyên require_admin cũ để tránh break
from app.db.models.user import UserRole

def require_role(allowed_roles: list[UserRole]):
    """
    Dependency factory trả về dependency function kiểm tra role.
    
    Dùng:
        current_user = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN]))
    """
    async def _checker(
        current_user: User = Depends(get_current_user)
    ) -> User:
        if current_user.role not in [r.value for r in allowed_roles]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Yêu cầu role: {[r.value for r in allowed_roles]}"
            )
        return current_user
    return _checker

# Giữ require_admin cũ để không break routes hiện tại
# (sẽ migrate dần trong các task sau)
async def require_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role not in [UserRole.ADMIN.value, UserRole.SUPER_ADMIN.value]:
        raise HTTPException(status_code=403, detail="Admin required")
    return current_user
```

---

## Bước 4 — Thêm API đổi role (Super Admin only)

**File:** `backend/app/api/routes/admin.py`

Thêm route sau (đừng sửa routes hiện có):

```python
from app.db.schemas.admin import UserRoleUpdate  # schema mới — xem dưới

@router.patch("/users/{user_id}/role", response_model=UserResponse)
async def update_user_role(
    user_id: UUID,
    body: UserRoleUpdate,
    current_user: User = Depends(require_role([UserRole.SUPER_ADMIN])),
    db: AsyncSession = Depends(get_db),
    mongo_db = Depends(get_mongo_db),
):
    """Chỉ Super Admin được đổi role người dùng."""
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(404, "User không tồn tại")
    
    before_role = user.role
    user.role = body.role
    await db.commit()
    await db.refresh(user)
    
    # Audit log bắt buộc cho role change
    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="role_change",
        resource_type="user",
        resource_id=str(user_id),
        before_value={"role": before_role},
        after_value={"role": body.role},
    )
    
    return user
```

**Schema cần thêm vào** `backend/app/db/schemas/admin.py`:

```python
class UserRoleUpdate(BaseModel):
    role: UserRole
    
    @validator("role")
    def cannot_assign_super_admin_via_api(cls, v):
        # Super Admin chỉ có thể được set trực tiếp trong DB
        # để tránh privilege escalation qua API
        if v == UserRole.SUPER_ADMIN:
            raise ValueError("Không thể gán role super_admin qua API")
        return v
```

---

## Bước 5 — Unit Tests

**File mới:** `backend/tests/admin/test_rbac.py`

Các test cases bắt buộc:
- [ ] `test_require_role_admin_ok` — user có role ADMIN truy cập route cần ADMIN → 200
- [ ] `test_require_role_wrong_role_403` — MODERATOR truy cập route cần ADMIN → 403
- [ ] `test_require_role_unauthenticated_401` — không có token → 401
- [ ] `test_update_role_by_super_admin_ok` — SUPER_ADMIN đổi role → 200
- [ ] `test_update_role_by_admin_403` — ADMIN cố đổi role → 403
- [ ] `test_cannot_assign_super_admin_via_api` — payload `role: super_admin` → 422

---

## Checklist DONE

- [ ] UserRole enum có 5 giá trị (super_admin, admin, content_manager, moderator, user)
- [ ] Migration đã chạy thành công trên DB dev
- [ ] `require_role([...])` hoạt động đúng với mọi combination role
- [ ] `require_admin` cũ vẫn hoạt động (backward compat)
- [ ] Route PATCH /users/{id}/role chỉ SUPER_ADMIN được gọi
- [ ] Tất cả unit tests pass
- [ ] Không có file Python nào bị break sau thay đổi (chạy `pytest` toàn bộ)

---

## Ghi chú khi DONE

```
migration_file: backend/initdb/07_migration_extend_user_role.sql
completed_at: 2026-06-28
notes: Project dùng SQL initdb scripts thay vì Alembic. Migration SQL thủ công tại 07_migration_extend_user_role.sql. 10/10 unit tests pass.
```
