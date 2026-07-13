# app/api/routes/auth.py
"""
Routes: /api/auth/*

1.  POST /auth/register/send-otp      → Bước 1 đăng ký: gửi OTP verify email
2.  POST /auth/register/confirm       → Bước 2 đăng ký: xác nhận OTP + tạo tài khoản
3.  POST /auth/otp/resend             → Gửi lại OTP (register | reset_password)
4.  POST /auth/login                  → Đăng nhập email+password → JWT
5.  POST /auth/google                 → Đăng nhập/đăng ký Google OAuth (không cần OTP)
6.  POST /auth/forgot-password        → Gửi OTP đặt lại mật khẩu
7.  POST /auth/reset-password         → Xác nhận OTP + đặt mật khẩu mới
8.  POST /auth/refresh                → Làm mới access_token (rotate refresh_token)
9.  POST /auth/logout                 → Thu hồi refresh_token
10. GET  /auth/me                     → Thông tin user hiện tại
11. PATCH /auth/me                    → Cập nhật profile (họ tên, avatar)
12. PATCH /auth/me/password           → Đổi mật khẩu (khi đã đăng nhập)

Security notes:
- Email luôn lowercase trước khi lưu/tra cứu (xử lý trong schema)
- Password CASE-SENSITIVE (không normalize), validate strength ở schema
- OTP chỉ 6 chữ số, hết hạn sau 10 phút, 1 lần dùng, tự hủy OTP cũ khi tạo mới
- Refresh token: rotate mỗi lần dùng (1 lần = 1 token)
- Forgot password luôn trả 202 (tránh user enumeration)
- Rate limiting: 5 lần gửi OTP / email / 10 phút (via OTP service)
"""

from datetime import datetime, timezone, timedelta
from typing import Optional
from uuid import UUID, uuid4
import os
import re

from fastapi import APIRouter, HTTPException, status, Request, UploadFile, File
from sqlalchemy import select, update

from app.api.deps import CurrentUser, DB
from app.core.security import (
    hash_password, verify_password,
    create_access_token, create_refresh_token, hash_token,
)
from app.db.models.user import User, RefreshToken, OtpCode, EmailVerification
from app.db.schemas.auth import (
    RegisterRequest, RegisterConfirmRequest,
    OtpVerifyRequest, OtpResendRequest,
    LoginRequest, GoogleLoginRequest,
    TokenResponse, RefreshRequest,
    UserResponse, UpdateProfileRequest, ChangePasswordRequest,
    ForgotPasswordRequest, ResetPasswordRequest,
)
from app.services.otp_service import create_otp, verify_otp, check_otp_rate_limit
from app.services.email_service import send_otp_email
from app.utils import get_logger
from app.utils.image_processing import process_image

logger = get_logger("auth")
router = APIRouter(tags=["auth"])


# ── Helpers ───────────────────────────────────────────────────────────────────

def _username_from_email(email: str) -> str:
    """Sinh username tạm từ phần trước @ của email (dùng cho Google OAuth)."""
    base = re.sub(r"[^a-z0-9_]", "_", email.split("@")[0].lower())
    base = base.strip("_")[:40] or "user"
    return base


async def _issue_tokens(user: User, db: DB) -> TokenResponse:
    """Tạo cặp access + refresh token, lưu refresh hash vào DB."""
    access = create_access_token(str(user.id), {"role": user.role})
    raw_refresh, expires_at = create_refresh_token(str(user.id))
    db.add(RefreshToken(
        user_id=user.id,
        token_hash=hash_token(raw_refresh),
        expires_at=expires_at,
    ))
    await db.commit()
    return TokenResponse(access_token=access, refresh_token=raw_refresh)


# ── 1. ĐĂNG KÝ — Bước 1: Gửi OTP ────────────────────────────────────────────

@router.post("/register/send-otp", status_code=202)
async def register_send_otp(body: RegisterRequest, db: DB):
    """
    Bước 1 đăng ký:
    - Validate email/username/password strength (qua Pydantic schema)
    - Kiểm tra email/username chưa tồn tại
    - Kiểm tra rate limit (max 5 OTP/email/10 phút)
    - Tạo OTP 6 số, lưu DB, gửi email
    - Trả 202 Accepted (tài khoản chưa tạo ở bước này)
    """
    # Kiểm tra trùng email/username
    dup = await db.execute(
        select(User).where(
            (User.email == body.email) | (User.username == body.username),
            User.is_deleted == False,
        )
    )
    existing = dup.scalar_one_or_none()
    if existing:
        if existing.email == body.email:
            raise HTTPException(400, "Email này đã được đăng ký")
        raise HTTPException(400, "Username này đã được sử dụng")

    # Kiểm tra rate limit OTP
    allowed = await check_otp_rate_limit(db, body.email, "register")
    if not allowed:
        raise HTTPException(
            status.HTTP_429_TOO_MANY_REQUESTS,
            "Bạn đã gửi quá nhiều yêu cầu. Vui lòng đợi 10 phút trước khi thử lại."
        )

    # Tạo và gửi OTP
    code = await create_otp(db, body.email, "register")
    await db.commit()

    sent = await send_otp_email(body.email, code, "register")
    if not sent:
        raise HTTPException(500, "Không thể gửi email xác nhận. Vui lòng thử lại.")

    return {
        "message": "Mã OTP đã được gửi đến email của bạn. Mã có hiệu lực 10 phút.",
        "email": body.email,
    }


# ── 2. ĐĂNG KÝ — Bước 2: Xác nhận OTP + Tạo tài khoản ──────────────────────

@router.post("/register/confirm", response_model=TokenResponse, status_code=201)
async def register_confirm(body: RegisterConfirmRequest, db: DB):
    """
    Bước 2 đăng ký:
    - Kiểm tra OTP hợp lệ (6 số, đúng email, chưa dùng, chưa hết hạn)
    - Kiểm tra trùng email/username lần cuối (tránh race condition)
    - Tạo user (is_active=True) + email_verification (is_verified=True)
    - Trả JWT để đăng nhập ngay (không cần login riêng)
    """
    # Kiểm tra trùng lần cuối
    dup = await db.execute(
        select(User).where(
            (User.email == body.email) | (User.username == body.username),
            User.is_deleted == False,
        )
    )
    if dup.scalar_one_or_none():
        raise HTTPException(400, "Email hoặc username đã được sử dụng")

    # Verify OTP
    valid = await verify_otp(db, body.email, body.otp_code, "register")
    if not valid:
        raise HTTPException(400, "Mã OTP không đúng hoặc đã hết hạn. Vui lòng yêu cầu mã mới.")

    # Tạo user
    now = datetime.now(timezone.utc)
    user = User(
        username=body.username,
        email=body.email,              # đã lowercase từ schema
        password_hash=hash_password(body.password),
        full_name=body.full_name,
        auth_provider="email",
        created_at=now,
        updated_at=now,
    )
    db.add(user)
    await db.flush()  # lấy user.id

    # Đánh dấu email đã xác thực (OTP đã verify)
    db.add(EmailVerification(
        user_id=user.id,
        email=body.email,
        is_verified=True,
        verified_at=now,
    ))

    logger.info(f"[auth] Đăng ký thành công: {user.email} (id={user.id})")
    return await _issue_tokens(user, db)


# ── 3. GỬI LẠI OTP ───────────────────────────────────────────────────────────

@router.post("/otp/resend", status_code=202)
async def resend_otp(body: OtpResendRequest, db: DB):
    """
    Gửi lại OTP. Dùng cho register hoặc reset_password.
    Rate limit: max 5 lần / email / 10 phút.
    """
    if body.purpose == "reset_password":
        # Phải có user tồn tại (không lộ thông tin — trả 202 giả nếu không tìm thấy)
        result = await db.execute(
            select(User).where(User.email == body.email, User.is_deleted == False)
        )
        if not result.scalar_one_or_none():
            return {"message": "Nếu email hợp lệ, OTP sẽ được gửi lại"}

    allowed = await check_otp_rate_limit(db, body.email, body.purpose)
    if not allowed:
        raise HTTPException(
            status.HTTP_429_TOO_MANY_REQUESTS,
            "Bạn đã gửi quá nhiều yêu cầu. Vui lòng đợi trước khi thử lại."
        )

    code = await create_otp(db, body.email, body.purpose)
    await db.commit()
    await send_otp_email(body.email, code, body.purpose)
    return {"message": "OTP đã được gửi lại. Mã có hiệu lực 10 phút."}


# ── 4. ĐĂNG NHẬP EMAIL + PASSWORD ────────────────────────────────────────────

@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, db: DB):
    """
    Đăng nhập email + password.
    Email case-insensitive (schema đã lowercase).
    Password case-sensitive (bcrypt verify).
    """
    result = await db.execute(
        select(User).where(User.email == body.email, User.is_deleted == False)
    )
    user = result.scalar_one_or_none()

    # Thông báo chung để tránh user enumeration
    _invalid = HTTPException(status.HTTP_401_UNAUTHORIZED, "Sai email hoặc mật khẩu")

    if not user or not user.password_hash:
        raise _invalid

    if not verify_password(body.password, user.password_hash):
        raise _invalid

    if not user.is_active:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Tài khoản đã bị khóa. Liên hệ hỗ trợ.")

    logger.info(f"[auth] Đăng nhập thành công: {user.email}")
    return await _issue_tokens(user, db)


# ── 5. ĐĂNG NHẬP GOOGLE OAUTH ────────────────────────────────────────────────

@router.post("/google", response_model=TokenResponse)
async def google_login(body: GoogleLoginRequest, db: DB):
    """
    Đăng nhập / Đăng ký bằng Google.

    Frontend gửi id_token từ Google Sign-In SDK.
    Backend verify → upsert user → trả JWT.

    - Lần đầu: tự tạo tài khoản (KHÔNG cần OTP — Google đã verify email)
    - Lần sau: đăng nhập bình thường, cập nhật google_id nếu cần
    - Tài khoản Google tự động có email_verified=True
    """
    from app.services.google_auth_service import verify_google_id_token, GoogleTokenError

    try:
        info = await verify_google_id_token(body.id_token)
    except GoogleTokenError as e:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, str(e))

    if not info.get("email_verified"):
        raise HTTPException(400, "Email Google chưa được xác thực")

    email     = info["email"].lower().strip()  # normalize email Google
    google_id = info["google_id"]
    now       = datetime.now(timezone.utc)

    # Tìm user theo google_id hoặc email
    result = await db.execute(
        select(User).where(
            (User.google_id == google_id) | (User.email == email),
            User.is_deleted == False,
        )
    )
    user = result.scalar_one_or_none()

    if user is None:
        # Tạo user mới từ Google (không cần password, không cần OTP)
        base_username = _username_from_email(email)
        username = base_username
        suffix = 0
        while True:
            taken = await db.execute(select(User.id).where(User.username == username))
            if not taken.scalar_one_or_none():
                break
            suffix += 1
            username = f"{base_username}_{suffix}"

        user = User(
            username=username,
            email=email,
            password_hash=None,         # Google user chưa có password
            full_name=info.get("full_name"),
            avatar_url=info.get("avatar_url"),
            google_id=google_id,
            auth_provider="google",
            created_at=now,
            updated_at=now,
        )
        db.add(user)
        await db.flush()

        # Email Google đã verified — tự động tạo bản ghi verified
        db.add(EmailVerification(
            user_id=user.id,
            email=email,
            is_verified=True,
            verified_at=now,
        ))
        logger.info(f"[auth] Tạo user qua Google OAuth: {email}")

    else:
        # Cập nhật thông tin nếu thiếu
        if not user.google_id:
            user.google_id = google_id
            # Nếu user đăng ký email trước, link thêm Google
            if user.auth_provider == "email":
                user.auth_provider = "email+google"
        if not user.avatar_url and info.get("avatar_url"):
            user.avatar_url = info["avatar_url"]
        if not user.is_active:
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Tài khoản đã bị khóa. Liên hệ hỗ trợ.")
        user.updated_at = now

    logger.info(f"[auth] Đăng nhập Google thành công: {email}")
    return await _issue_tokens(user, db)


# ── 6. QUÊN MẬT KHẨU — Gửi OTP ──────────────────────────────────────────────

@router.post("/forgot-password", status_code=202)
async def forgot_password(body: ForgotPasswordRequest, db: DB):
    """
    Gửi OTP đặt lại mật khẩu qua email.
    Luôn trả 202 (không lộ email có tồn tại hay không — tránh user enumeration).
    Tài khoản Google cũng có thể đặt password qua flow này.
    """
    result = await db.execute(
        select(User).where(User.email == body.email, User.is_deleted == False)
    )
    user = result.scalar_one_or_none()

    if user:
        # Kiểm tra rate limit
        allowed = await check_otp_rate_limit(db, body.email, "reset_password")
        if not allowed:
            # Vẫn trả 202 (tránh lộ thông tin), nhưng không gửi
            logger.warning(f"[auth] Rate limit forgot-password: {body.email}")
            return {"message": "Nếu email tồn tại, mã OTP đã được gửi"}

        code = await create_otp(db, body.email, "reset_password", str(user.id))
        await db.commit()
        await send_otp_email(body.email, code, "reset_password")
        logger.info(f"[auth] Gửi OTP reset password: {body.email}")
    else:
        logger.warning(f"[auth] forgot-password: email không tồn tại {body.email}")

    return {"message": "Nếu email tồn tại, mã OTP đã được gửi"}


# ── 7. ĐẶT LẠI MẬT KHẨU ─────────────────────────────────────────────────────

@router.post("/reset-password", status_code=200)
async def reset_password(body: ResetPasswordRequest, db: DB):
    """
    Xác nhận OTP và đặt mật khẩu mới.
    Password mới phải đủ mạnh (validate trong schema).
    Thu hồi tất cả refresh token cũ → buộc đăng nhập lại.
    """
    result = await db.execute(
        select(User).where(User.email == body.email, User.is_deleted == False)
    )
    user = result.scalar_one_or_none()
    if not user:
        # Trả lỗi generic (tránh user enumeration qua endpoint này)
        raise HTTPException(400, "Mã OTP không đúng hoặc đã hết hạn")

    valid = await verify_otp(db, body.email, body.otp_code, "reset_password")
    if not valid:
        raise HTTPException(400, "Mã OTP không đúng hoặc đã hết hạn")

    user.password_hash = hash_password(body.new_password)
    if user.auth_provider == "google":
        user.auth_provider = "email+google"  # link cả 2 provider
    user.updated_at = datetime.now(timezone.utc)

    # Thu hồi tất cả refresh token cũ (bảo mật: force login lại)
    await db.execute(
        update(RefreshToken)
        .where(RefreshToken.user_id == user.id)
        .values(revoked=True)
    )
    await db.commit()
    logger.info(f"[auth] Reset password thành công: {user.email}")
    return {"message": "Mật khẩu đã được đặt lại thành công. Vui lòng đăng nhập lại."}


# ── 8. REFRESH TOKEN ──────────────────────────────────────────────────────────

@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, db: DB):
    """Làm mới access_token. Rotate refresh_token (1 lần dùng = 1 token)."""
    token_hash = hash_token(body.refresh_token)
    result = await db.execute(
        select(RefreshToken).where(
            RefreshToken.token_hash == token_hash,
            RefreshToken.revoked == False,
            RefreshToken.expires_at > datetime.now(timezone.utc),
        )
    )
    rt = result.scalar_one_or_none()    
    if not rt:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Refresh token không hợp lệ hoặc đã hết hạn")

    user_result = await db.execute(
        select(User).where(User.id == rt.user_id, User.is_deleted == False)
    )
    user = user_result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Tài khoản không hợp lệ")

    # Rotate: thu hồi cũ, cấp mới
    rt.revoked = True
    access = create_access_token(str(user.id), {"role": user.role})
    raw_refresh, expires_at = create_refresh_token(str(user.id))
    db.add(RefreshToken(
        user_id=user.id,
        token_hash=hash_token(raw_refresh),
        expires_at=expires_at,
    ))
    await db.commit()
    return TokenResponse(access_token=access, refresh_token=raw_refresh)


# ── 9. LOGOUT ─────────────────────────────────────────────────────────────────

@router.post("/logout", status_code=204)
async def logout(body: RefreshRequest, db: DB):
    """Thu hồi refresh_token hiện tại."""
    await db.execute(
        update(RefreshToken)
        .where(RefreshToken.token_hash == hash_token(body.refresh_token))
        .values(revoked=True)
    )
    await db.commit()


# ── 10. GET ME ────────────────────────────────────────────────────────────────

@router.get("/me", response_model=UserResponse)
async def me(current_user: CurrentUser):
    """Thông tin user đang đăng nhập."""
    return current_user


# ── 11. UPDATE PROFILE ────────────────────────────────────────────────────────

@router.patch("/me", response_model=UserResponse)
async def update_me(body: UpdateProfileRequest, current_user: CurrentUser, db: DB):
    """Cập nhật họ tên, avatar."""
    if body.full_name is not None:
        current_user.full_name = body.full_name
    if body.avatar_url is not None:
        current_user.avatar_url = body.avatar_url
    current_user.updated_at = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(current_user)
    return current_user


# ── 11b. UPLOAD AVATAR ───────────────────────────────────────────────────────

_AVATAR_DIR = os.path.join("static", "uploads", "avatars")
_AVATAR_ALLOWED_EXT = {"jpg", "jpeg", "png", "webp"}
_AVATAR_MAX_BYTES = 5 * 1024 * 1024  # 5MB


@router.post("/me/avatar", response_model=UserResponse)
async def upload_avatar(current_user: CurrentUser, db: DB, file: UploadFile = File(...)):
    """Upload ảnh đại diện từ thiết bị, resize ≤512px + convert WebP, lưu avatar_url."""
    ext = (os.path.splitext(file.filename or "")[1].lstrip(".") or "jpg").lower()
    if ext not in _AVATAR_ALLOWED_EXT:
        raise HTTPException(status.HTTP_400_BAD_REQUEST,
                             "Định dạng không hỗ trợ (chỉ jpg/png/webp)")
    content = await file.read()
    if len(content) > _AVATAR_MAX_BYTES:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Ảnh quá lớn (>5MB)")

    out, out_ext, _mime, _w, _h = process_image(content, ext, max_side=512)

    os.makedirs(_AVATAR_DIR, exist_ok=True)
    filename = f"{uuid4()}.{out_ext}"
    with open(os.path.join(_AVATAR_DIR, filename), "wb") as f:
        f.write(out)

    current_user.avatar_url = f"/uploads/avatars/{filename}"
    current_user.updated_at = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(current_user)
    return current_user


# ── 12. ĐỔI MẬT KHẨU (đã đăng nhập) ─────────────────────────────────────────

@router.patch("/me/password", status_code=200)
async def change_password(body: ChangePasswordRequest, current_user: CurrentUser, db: DB):
    """
    Đổi mật khẩu khi đã đăng nhập.
    Yêu cầu mật khẩu cũ đúng.
    Mật khẩu mới phải đủ mạnh và khác mật khẩu cũ (validate trong schema).
    """
    if not current_user.password_hash:
        raise HTTPException(
            400,
            "Tài khoản Google chưa có mật khẩu. "
            "Dùng /forgot-password để đặt mật khẩu lần đầu."
        )

    if not verify_password(body.old_password, current_user.password_hash):
        raise HTTPException(400, "Mật khẩu hiện tại không đúng")

    current_user.password_hash = hash_password(body.new_password)
    current_user.updated_at = datetime.now(timezone.utc)
    await db.commit()
    logger.info(f"[auth] Đổi mật khẩu thành công: {current_user.email}")
    return {"message": "Đổi mật khẩu thành công"}
