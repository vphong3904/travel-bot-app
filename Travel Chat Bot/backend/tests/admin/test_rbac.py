"""
Unit tests cho TA-001 — RBAC 4 Role.

Các tests này KHÔNG cần DB thật: mock get_current_user để inject user giả.
"""
import pytest
from unittest.mock import AsyncMock, MagicMock
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


# ── require_role ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_require_role_admin_ok():
    """User có role ADMIN truy cập route cần ADMIN → trả về user."""
    user = _make_user(UserRole.ADMIN)
    checker = require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])
    result = await checker(current_user=user)
    assert result is user


@pytest.mark.asyncio
async def test_require_role_super_admin_ok():
    """SUPER_ADMIN truy cập route cần ADMIN → trả về user."""
    user = _make_user(UserRole.SUPER_ADMIN)
    checker = require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])
    result = await checker(current_user=user)
    assert result is user


@pytest.mark.asyncio
async def test_require_role_wrong_role_403():
    """MODERATOR truy cập route cần ADMIN → 403."""
    user = _make_user(UserRole.MODERATOR)
    checker = require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])
    with pytest.raises(HTTPException) as exc_info:
        await checker(current_user=user)
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_require_role_content_manager_403():
    """CONTENT_MANAGER truy cập route cần SUPER_ADMIN → 403."""
    user = _make_user(UserRole.CONTENT_MANAGER)
    checker = require_role([UserRole.SUPER_ADMIN])
    with pytest.raises(HTTPException) as exc_info:
        await checker(current_user=user)
    assert exc_info.value.status_code == 403


# ── require_admin (backward compat) ──────────────────────────────────────────

@pytest.mark.asyncio
async def test_require_admin_accepts_admin():
    """require_admin cũ chấp nhận role 'admin'."""
    user = _make_user(UserRole.ADMIN)
    result = await require_admin(user=user)
    assert result is user


@pytest.mark.asyncio
async def test_require_admin_accepts_super_admin():
    """require_admin cũ chấp nhận role 'super_admin' (backward compat)."""
    user = _make_user(UserRole.SUPER_ADMIN)
    result = await require_admin(user=user)
    assert result is user


@pytest.mark.asyncio
async def test_require_admin_rejects_user_role():
    """require_admin từ chối role 'user'."""
    user = _make_user(UserRole.USER)
    with pytest.raises(HTTPException) as exc_info:
        await require_admin(user=user)
    assert exc_info.value.status_code == 403


# ── UserRoleUpdate schema ─────────────────────────────────────────────────────

def test_user_role_update_valid():
    from app.db.schemas.admin import UserRoleUpdate
    payload = UserRoleUpdate(role=UserRole.MODERATOR)
    assert payload.role == UserRole.MODERATOR


def test_user_role_update_cannot_assign_super_admin():
    from pydantic import ValidationError
    from app.db.schemas.admin import UserRoleUpdate
    with pytest.raises(ValidationError) as exc_info:
        UserRoleUpdate(role=UserRole.SUPER_ADMIN)
    assert "super_admin" in str(exc_info.value).lower()


# ── UserRole enum ─────────────────────────────────────────────────────────────

def test_user_role_enum_has_5_values():
    values = {r.value for r in UserRole}
    assert values == {"super_admin", "admin", "content_manager", "moderator", "user"}
