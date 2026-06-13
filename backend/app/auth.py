# app/auth.py
"""
JWT authentication & role-based authorization dependencies.

Roles (theo PDTRIP_AI_SPEC.md): guest, user (free), premium, creator, admin
"""
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.config import settings
from app.database import get_db
from app.models import User

ALGORITHM = "HS256"

# tokenUrl chỉ dùng để hiển thị trong Swagger UI (nút Authorize)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login", auto_error=False)


class CurrentUser:
    """Đối tượng user rút gọn lấy từ JWT, gắn kèm thông tin DB (is_active...)."""

    def __init__(self, id: int, email: str, role: str, name: str, is_active: bool):
        self.id = id
        self.email = email
        self.role = role
        self.name = name
        self.is_active = is_active


def _decode_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[ALGORITHM])
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token không hợp lệ hoặc đã hết hạn",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return payload


async def get_current_user(
    token: Optional[str] = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> CurrentUser:
    """Bắt buộc phải có Bearer token hợp lệ. Dùng cho các route cần đăng nhập."""
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Thiếu Authorization Bearer token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    payload = _decode_token(token)
    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(status_code=401, detail="Token không hợp lệ")

    result = await db.execute(select(User).where(User.id == int(user_id)))
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=401, detail="Người dùng không tồn tại")
    if not user.is_active:
        raise HTTPException(status_code=403, detail="Tài khoản đã bị khóa")

    # Luôn ưu tiên role hiện tại trong DB (phòng trường hợp admin đổi role
    # sau khi token đã được cấp), không tin tuyệt đối vào payload["role"].
    return CurrentUser(
        id=user.id,
        email=user.email,
        role=user.role,
        name=user.name,
        is_active=user.is_active,
    )


async def get_optional_user(
    token: Optional[str] = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> Optional[CurrentUser]:
    """Không bắt buộc đăng nhập (dùng cho Guest). Nếu có token hợp lệ thì trả về user,
    nếu không có token thì trả về None (Guest), nếu token sai thì lỗi 401."""
    if not token:
        return None
    return await get_current_user(token=token, db=db)


def require_roles(*allowed_roles: str):
    """Factory tạo dependency kiểm tra role.

    Ví dụ: Depends(require_roles("admin"))
           Depends(require_roles("admin", "creator"))
    """

    async def _checker(user: CurrentUser = Depends(get_current_user)) -> CurrentUser:
        if user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Yêu cầu quyền: {', '.join(allowed_roles)}",
            )
        return user

    return _checker


# Alias tiện dùng cho route chỉ Admin
require_admin = require_roles("admin")


# ── Rate limiting theo role (PDTRIP_AI_SPEC §5) ──────────────────────────────
# GUEST   : 3 lượt (lưu local Hive, FE tự chặn — không tính ở đây)
# FREE    : 20 lượt/ngày (reset 00:00 UTC)
# PREMIUM/CREATOR/ADMIN : không giới hạn
FREE_DAILY_LIMIT = 20
UNLIMITED_ROLES = {"premium", "creator", "admin"}


async def check_and_consume_ai_quota(user: Optional[CurrentUser], db: AsyncSession) -> None:
    """Kiểm tra & trừ lượt chat AI trong ngày cho user FREE.

    - Guest (user=None): không kiểm tra ở backend (FE quản lý 3 lượt qua Hive).
    - PREMIUM/CREATOR/ADMIN: bỏ qua, không giới hạn.
    - FREE (mọi role khác, mặc định "user"): tối đa FREE_DAILY_LIMIT lượt/ngày,
      vượt quá -> 429 kèm payload để FE hiện popup nâng cấp Premium.
    """
    if user is None or user.role in UNLIMITED_ROLES:
        return

    from datetime import date as _date
    from app.models import AiUsage

    today = _date.today().isoformat()
    result = await db.execute(
        select(AiUsage).where(AiUsage.user_id == user.id, AiUsage.date == today)
    )
    usage = result.scalar_one_or_none()

    if usage is None:
        usage = AiUsage(user_id=user.id, date=today, count=0)
        db.add(usage)

    if usage.count >= FREE_DAILY_LIMIT:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail={
                "reason": "daily_limit",
                "limit": FREE_DAILY_LIMIT,
                "upgrade": True,
                "message": f"Bạn đã dùng hết {FREE_DAILY_LIMIT} lượt chat AI miễn phí hôm nay. Nâng cấp Premium để chat không giới hạn.",
            },
        )

    usage.count += 1
    await db.commit()
