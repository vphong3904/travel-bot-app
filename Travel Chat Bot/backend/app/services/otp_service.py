# app/services/otp_service.py
"""
Service tạo, xác thực và hủy OTP.

- Sinh 6 chữ số ngẫu nhiên (secrets.choice để an toàn hơn random)
- Lưu vào bảng otp_codes (PostgreSQL)
- Tự hủy OTP cũ chưa dùng cùng email+purpose trước khi tạo mới
- Thời hạn: 10 phút
- Rate limit: tối đa MAX_OTP_PER_WINDOW lần gửi / email / purpose / WINDOW phút
"""
from __future__ import annotations

import secrets
import string
from datetime import datetime, timedelta, timezone
from typing import Optional

from sqlalchemy import select, update, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.user import OtpCode
from app.utils import get_logger

logger = get_logger("otp_service")

OTP_EXPIRE_MINUTES  = 10
OTP_LENGTH          = 6
MAX_OTP_PER_WINDOW  = 5   # tối đa 5 lần gửi / email / purpose / OTP_EXPIRE_MINUTES
DIGITS              = string.digits


def _generate_otp() -> str:
    """Sinh 6 chữ số ngẫu nhiên dùng secrets (cryptographically secure)."""
    return "".join(secrets.choice(DIGITS) for _ in range(OTP_LENGTH))


async def check_otp_rate_limit(
    db: AsyncSession,
    email: str,
    purpose: str,
) -> bool:
    """
    Kiểm tra rate limit: trong WINDOW phút gần nhất, email+purpose
    đã được tạo bao nhiêu OTP (kể cả đã dùng).
    Trả True nếu còn trong giới hạn, False nếu vượt quá.
    """
    window_start = datetime.now(timezone.utc) - timedelta(minutes=OTP_EXPIRE_MINUTES)
    result = await db.execute(
        select(func.count(OtpCode.id)).where(
            OtpCode.email == email,
            OtpCode.purpose == purpose,
            OtpCode.created_at >= window_start,
        )
    )
    count = result.scalar() or 0
    if count >= MAX_OTP_PER_WINDOW:
        logger.warning(
            f"[otp_service] Rate limit exceeded: email={email} purpose={purpose} count={count}"
        )
        return False
    return True


async def create_otp(
    db: AsyncSession,
    email: str,
    purpose: str,
    user_id: Optional[str] = None,
    expire_minutes: int = OTP_EXPIRE_MINUTES,
) -> str:
    """
    Tạo OTP mới và lưu vào DB.
    Hủy các OTP cũ chưa dùng cùng email+purpose trước khi tạo mới.
    Trả về chuỗi OTP 6 chữ số.

    Note: KHÔNG commit — caller tự commit cùng với các thao tác khác.
    """
    # Hủy OTP cũ chưa dùng (tránh nhiều OTP còn hiệu lực cùng lúc)
    await db.execute(
        update(OtpCode)
        .where(
            OtpCode.email == email,
            OtpCode.purpose == purpose,
            OtpCode.used == False,
        )
        .values(used=True)
    )

    code = _generate_otp()
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=expire_minutes)

    otp = OtpCode(
        email=email,
        code=code,
        purpose=purpose,
        expires_at=expires_at,
        used=False,
        user_id=user_id,
    )
    db.add(otp)
    await db.flush()
    logger.info(
        f"[otp_service] Tạo OTP purpose={purpose} → {email} "
        f"(expires {expires_at.strftime('%H:%M:%S UTC')})"
    )
    return code


async def verify_otp(
    db: AsyncSession,
    email: str,
    code: str,
    purpose: str,
    mark_used: bool = True,
) -> bool:
    """
    Kiểm tra OTP hợp lệ.
    Điều kiện: đúng email, đúng code (exact match), đúng purpose,
                chưa dùng (used=False), chưa hết hạn (expires_at > now).
    Nếu hợp lệ và mark_used=True → đánh dấu đã dùng.
    Trả về True/False.
    """
    now = datetime.now(timezone.utc)
    result = await db.execute(
        select(OtpCode).where(
            OtpCode.email == email,
            OtpCode.code == code,
            OtpCode.purpose == purpose,
            OtpCode.used == False,
            OtpCode.expires_at > now,
        )
    )
    otp = result.scalar_one_or_none()

    if not otp:
        logger.warning(
            f"[otp_service] OTP không hợp lệ/hết hạn: email={email} purpose={purpose}"
        )
        return False

    if mark_used:
        otp.used = True
        await db.flush()

    logger.info(f"[otp_service] OTP xác thực thành công: email={email} purpose={purpose}")
    return True
