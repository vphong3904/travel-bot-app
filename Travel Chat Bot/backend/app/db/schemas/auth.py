# app/db/schemas/auth.py
"""
Pydantic schemas cho auth endpoints.

Validation rules:
  - Email:    Pydantic EmailStr (lowercase tự động, chuẩn RFC-5322)
  - Username: chỉ [a-z0-9_-], 3-50 ký tự, tự lowercase
  - Password: 8-128 ký tự, phải có CHỮ HOA + chữ thường + số + ký tự đặc biệt
              Hỗ trợ đầy đủ: !@#$%^&*()_+-=[]{}|;':\",./<>?
  - OTP:      6 chữ số

Ghi chú hoa/thường:
  - Email     → luôn lowercase trước khi lưu/tra cứu (validator @field_validator)
  - Username  → luôn lowercase
  - Password  → CASE-SENSITIVE (không normalize, bcrypt hash nguyên văn)
"""

import re
from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field, field_validator, model_validator


# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

_SPECIAL_CHARS = r"!@#$%^&*()\-_=+\[\]{}|;':\",./<>?"

_PASSWORD_RULES = (
    "Mật khẩu phải từ 8–128 ký tự, gồm ít nhất: "
    "1 chữ HOA (A-Z), 1 chữ thường (a-z), 1 chữ số (0-9) và "
    "1 ký tự đặc biệt (!@#$%^&*…)"
)


def _validate_password_strength(v: str) -> str:
    """
    Kiểm tra độ mạnh mật khẩu.
    Raise ValueError nếu không đạt yêu cầu.
    """
    if len(v) < 8:
        raise ValueError("Mật khẩu phải có ít nhất 8 ký tự")
    if len(v) > 128:
        raise ValueError("Mật khẩu không được quá 128 ký tự")
    if not re.search(r"[A-Z]", v):
        raise ValueError(_PASSWORD_RULES)
    if not re.search(r"[a-z]", v):
        raise ValueError(_PASSWORD_RULES)
    if not re.search(r"[0-9]", v):
        raise ValueError(_PASSWORD_RULES)
    if not re.search(rf"[{_SPECIAL_CHARS}]", v):
        raise ValueError(_PASSWORD_RULES)
    return v  # KHÔNG lowercase — password case-sensitive


def _validate_username(v: str) -> str:
    """Username: [a-z0-9_-], 3-50 ký tự, tự lowercase."""
    v = v.strip().lower()
    if len(v) < 3:
        raise ValueError("Username phải có ít nhất 3 ký tự")
    if len(v) > 50:
        raise ValueError("Username không được quá 50 ký tự")
    if not re.fullmatch(r"[a-z0-9_\-]+", v):
        raise ValueError("Username chỉ được chứa chữ cái thường, số, dấu _ hoặc -")
    # Không cho bắt đầu/kết thúc bằng _ hoặc -
    if v[0] in ("_", "-") or v[-1] in ("_", "-"):
        raise ValueError("Username không được bắt đầu hoặc kết thúc bằng _ hoặc -")
    return v


def _normalize_email(v: str) -> str:
    """Lowercase email trước khi dùng (EmailStr đã validate cú pháp)."""
    return str(v).lower().strip()


# ─────────────────────────────────────────────────────────────────────────────
# REGISTER — Bước 1: gửi OTP
# ─────────────────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    """
    Bước 1 đăng ký: kiểm tra email/username chưa tồn tại, gửi OTP.
    Password được validate strength ở đây để frontend biết lỗi sớm
    (không cần chờ đến bước confirm).
    """
    username:  str      = Field(..., min_length=3, max_length=50)
    email:     EmailStr
    password:  str      = Field(..., min_length=8, max_length=128)
    full_name: Optional[str] = Field(None, max_length=100)

    @field_validator("username")
    @classmethod
    def validate_username(cls, v: str) -> str:
        return _validate_username(v)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v) -> str:
        return _normalize_email(v)

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        return _validate_password_strength(v)

    @field_validator("full_name")
    @classmethod
    def strip_full_name(cls, v: Optional[str]) -> Optional[str]:
        if v:
            v = v.strip()
            return v if v else None
        return None


# ─────────────────────────────────────────────────────────────────────────────
# REGISTER — Bước 2: xác nhận OTP + tạo tài khoản
# ─────────────────────────────────────────────────────────────────────────────

class RegisterConfirmRequest(BaseModel):
    """
    Bước 2 đăng ký: Frontend gửi kèm OTP + lại thông tin đăng ký.
    Validate lại đầy đủ để tránh tamper giữa 2 bước.
    """
    username:  str      = Field(..., min_length=3, max_length=50)
    email:     EmailStr
    password:  str      = Field(..., min_length=8, max_length=128)
    full_name: Optional[str] = Field(None, max_length=100)
    otp_code:  str      = Field(..., min_length=6, max_length=6,
                                description="OTP 6 chữ số nhận qua email",
                                pattern=r"^\d{6}$")

    @field_validator("username")
    @classmethod
    def validate_username(cls, v: str) -> str:
        return _validate_username(v)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v) -> str:
        return _normalize_email(v)

    @field_validator("password")
    @classmethod
    def validate_password(cls, v: str) -> str:
        return _validate_password_strength(v)

    @field_validator("full_name")
    @classmethod
    def strip_full_name(cls, v: Optional[str]) -> Optional[str]:
        if v:
            v = v.strip()
            return v if v else None
        return None


# ─────────────────────────────────────────────────────────────────────────────
# OTP — Verify / Resend
# ─────────────────────────────────────────────────────────────────────────────

class OtpVerifyRequest(BaseModel):
    email:    EmailStr
    otp_code: str = Field(..., min_length=6, max_length=6, pattern=r"^\d{6}$")
    purpose:  str = Field(..., pattern=r"^(register|reset_password)$")

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v) -> str:
        return _normalize_email(v)


class OtpResendRequest(BaseModel):
    email:   EmailStr
    purpose: str = Field(..., pattern=r"^(register|reset_password)$")

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v) -> str:
        return _normalize_email(v)


# ─────────────────────────────────────────────────────────────────────────────
# LOGIN
# ─────────────────────────────────────────────────────────────────────────────

class LoginRequest(BaseModel):
    """
    Đăng nhập email + password.
    Email tự lowercase (không phân biệt hoa thường khi đăng nhập).
    Password KHÔNG lowercase — case-sensitive.
    """
    email:    EmailStr
    password: str = Field(..., min_length=1, max_length=128)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v) -> str:
        return _normalize_email(v)


# ─────────────────────────────────────────────────────────────────────────────
# GOOGLE OAUTH
# ─────────────────────────────────────────────────────────────────────────────

class GoogleLoginRequest(BaseModel):
    id_token: str = Field(..., description="Google id_token từ Google Sign-In SDK")


# ─────────────────────────────────────────────────────────────────────────────
# TOKENS
# ─────────────────────────────────────────────────────────────────────────────

class TokenResponse(BaseModel):
    access_token:  str
    refresh_token: str
    token_type:    str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


# ─────────────────────────────────────────────────────────────────────────────
# FORGOT / RESET PASSWORD
# ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordRequest(BaseModel):
    email: EmailStr

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v) -> str:
        return _normalize_email(v)


class ResetPasswordRequest(BaseModel):
    email:        EmailStr
    otp_code:     str = Field(..., min_length=6, max_length=6, pattern=r"^\d{6}$")
    new_password: str = Field(..., min_length=8, max_length=128)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, v) -> str:
        return _normalize_email(v)

    @field_validator("new_password")
    @classmethod
    def validate_new_password(cls, v: str) -> str:
        return _validate_password_strength(v)


# ─────────────────────────────────────────────────────────────────────────────
# PROFILE
# ─────────────────────────────────────────────────────────────────────────────

class UserResponse(BaseModel):
    id:            UUID
    username:      str
    email:         str
    full_name:     Optional[str]
    avatar_url:    Optional[str]
    role:          str
    is_active:     bool
    auth_provider: str   # 'email' | 'google' | 'email+google'
    created_at:    datetime

    model_config = {"from_attributes": True}


class UpdateProfileRequest(BaseModel):
    full_name:  Optional[str] = Field(None, max_length=100)
    avatar_url: Optional[str] = Field(None, max_length=500)

    @field_validator("full_name")
    @classmethod
    def strip_full_name(cls, v: Optional[str]) -> Optional[str]:
        if v:
            v = v.strip()
            return v if v else None
        return None


class ChangePasswordRequest(BaseModel):
    """
    Đổi mật khẩu khi đã đăng nhập.
    old_password KHÔNG validate strength — dùng để xác nhận.
    new_password phải đủ mạnh VÀ khác old_password.
    """
    old_password: str = Field(..., min_length=1, max_length=128)
    new_password: str = Field(..., min_length=8, max_length=128)

    @field_validator("new_password")
    @classmethod
    def validate_new_password(cls, v: str) -> str:
        return _validate_password_strength(v)

    @model_validator(mode="after")
    def passwords_must_differ(self) -> "ChangePasswordRequest":
        if self.old_password == self.new_password:
            raise ValueError("Mật khẩu mới phải khác mật khẩu cũ")
        return self
