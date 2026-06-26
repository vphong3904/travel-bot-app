from datetime import datetime

from sqlalchemy import (
    Column, String, Boolean, Text, TIMESTAMP, ForeignKey, func, Index
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, relationship
import uuid
from app.db.database import Base
from app.db.models.chat import ChatSession


class User(Base):
    __tablename__ = "users"

    id            = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username      = Column(String(50), unique=True, nullable=False)
    email         = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=True)   # nullable: Google OAuth user có thể không có password
    full_name     = Column(String(100))
    avatar_url    = Column(Text)
    role          = Column(String(20), default="user")
    is_active     = Column(Boolean, default=True)
    is_deleted    = Column(Boolean, default=False)
    # Google OAuth
    google_id     = Column(String(255), unique=True, nullable=True)
    auth_provider = Column(String(20), default="email")  # 'email' | 'google'
    created_at    = Column(TIMESTAMP(timezone=True), server_default=func.now(), nullable=False)
    updated_at    = Column(TIMESTAMP(timezone=True), server_default=func.now(),
                           server_onupdate=func.now(), nullable=False)

    sessions: Mapped[list["ChatSession"]] = relationship(
        "ChatSession", back_populates="user", lazy="noload"
    )
    refresh_tokens     = relationship("RefreshToken", back_populates="user")
    otp_codes          = relationship("OtpCode", back_populates="user")
    email_verification = relationship("EmailVerification", back_populates="user", uselist=False)


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id         = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id    = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    token_hash = Column(Text, nullable=False)
    expires_at = Column(TIMESTAMP(timezone=True), nullable=False)
    revoked    = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), nullable=False)

    user = relationship("User", back_populates="refresh_tokens")


class OtpCode(Base):
    """
    OTP một lần dùng cho:
      - purpose='register'       → xác thực email đăng ký
      - purpose='reset_password' → đặt lại mật khẩu
    user_id có thể NULL trong bước đăng ký (tài khoản chưa tạo).
    Tra cứu bằng email + purpose + used=False + expires_at > now.
    """
    __tablename__ = "otp_codes"

    id         = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id    = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=True)
    email      = Column(String(255), nullable=False)
    code       = Column(String(10), nullable=False)
    purpose    = Column(String(50), nullable=False)   # 'register' | 'reset_password'
    expires_at = Column(TIMESTAMP(timezone=True), nullable=False)
    used       = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now(), nullable=False)

    user = relationship("User", back_populates="otp_codes")


class EmailVerification(Base):
    """Trạng thái xác thực email của từng user."""
    __tablename__ = "email_verifications"

    id          = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id     = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"),
                         nullable=False, unique=True)
    email       = Column(String(255), nullable=False)
    is_verified = Column(Boolean, default=False)
    verified_at = Column(TIMESTAMP(timezone=True), nullable=True)
    created_at  = Column(TIMESTAMP(timezone=True), server_default=func.now(), nullable=False)

    user = relationship("User", back_populates="email_verification")
