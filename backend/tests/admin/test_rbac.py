"""
Unit tests cho RBAC 4 role.
Không cần DB thật — inject user giả vào dependency.
"""
import pytest
from uuid import uuid4
from fastapi import HTTPException

from app.db.models.user import User, UserRole
from app.api.deps import require_role, require_admin


def _make_user(role: str) -> User:
    u = User()
    u.id = uuid4()
    u.email = f"{role}@test.com"
    u.role = role
    u.is_active = True
    u.is_deleted = False
    return u


@pytest.mark.asyncio
async def test_require_role_admin_ok():
    user = _make_user(UserRole.ADMIN)
    result = await require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])(current_user=user)
    assert result is user


@pytest.mark.asyncio
async def test_require_role_super_admin_ok():
    user = _make_user(UserRole.SUPER_ADMIN)
    result = await require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])(current_user=user)
    assert result is user


@pytest.mark.asyncio
async def test_require_role_wrong_role_403():
    user = _make_user(UserRole.MODERATOR)
    with pytest.raises(HTTPException) as exc:
        await require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])(current_user=user)
    assert exc.value.status_code == 403


@pytest.mark.asyncio
async def test_require_admin_accepts_super_admin():
    user = _make_user(UserRole.SUPER_ADMIN)
    result = await require_admin(user=user)
    assert result is user


@pytest.mark.asyncio
async def test_require_admin_rejects_user():
    user = _make_user(UserRole.USER)
    with pytest.raises(HTTPException) as exc:
        await require_admin(user=user)
    assert exc.value.status_code == 403


def test_user_role_update_valid():
    from app.db.schemas.admin import UserRoleUpdate
    payload = UserRoleUpdate(role=UserRole.MODERATOR)
    assert payload.role == UserRole.MODERATOR


def test_user_role_update_blocks_super_admin():
    from pydantic import ValidationError
    from app.db.schemas.admin import UserRoleUpdate
    with pytest.raises(ValidationError):
        UserRoleUpdate(role=UserRole.SUPER_ADMIN)


def test_user_role_enum_values():
    values = {r.value for r in UserRole}
    assert values == {"super_admin", "admin", "content_manager", "moderator", "user"}
