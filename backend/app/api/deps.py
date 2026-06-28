# app/api/deps.py
from typing import Annotated, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import decode_access_token
from app.db.database import get_db
from app.db.models.user import User

_bearer = HTTPBearer(auto_error=True)
_bearer_optional = HTTPBearer(auto_error=False)

# ── Role constants ─────────────────────────────────────────────────────────────
ADMIN_ROLES = {"admin", "super_admin", "content_manager", "moderator"}


# ── Core dependency: resolve token → User ─────────────────────────────────────

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    user_id = decode_access_token(credentials.credentials)
    if not user_id:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Token không hợp lệ hoặc đã hết hạn")

    result = await db.execute(
        select(User).where(User.id == user_id, User.is_deleted == False)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Tài khoản không tồn tại")
    if not user.is_active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Tài khoản đã bị khoá")
    return user


async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(_bearer_optional),
    db: AsyncSession = Depends(get_db),
) -> Optional[User]:
    if not credentials:
        return None
    user_id = decode_access_token(credentials.credentials)
    if not user_id:
        return None
    result = await db.execute(
        select(User).where(User.id == user_id, User.is_deleted == False, User.is_active == True)
    )
    return result.scalar_one_or_none()


# ── Annotated shortcuts ────────────────────────────────────────────────────────

CurrentUser = Annotated[User, Depends(get_current_user)]
DB = Annotated[AsyncSession, Depends(get_db)]


# ── Role guards ────────────────────────────────────────────────────────────────

async def require_admin(current_user: CurrentUser) -> User:
    """Yêu cầu role admin hoặc super_admin."""
    if current_user.role not in ADMIN_ROLES:
        raise HTTPException(
            status.HTTP_403_FORBIDDEN,
            "Yêu cầu quyền admin",
        )
    return current_user


def require_role(roles: list[str]):
    """
    Factory tạo dependency check role linh hoạt.
    Dùng: Depends(require_role(['admin', 'super_admin']))
    """
    async def _check(user: CurrentUser) -> User:
        if user.role not in roles:
            raise HTTPException(
                status.HTTP_403_FORBIDDEN,
                f"Yêu cầu một trong các role: {roles}",
            )
        return user
    return _check
