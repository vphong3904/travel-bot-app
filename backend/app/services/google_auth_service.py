"""
Service xác thực Google OAuth.
Flow:
  1. Frontend dùng Google Sign-In SDK → lấy id_token (JWT từ Google)
  2. Gửi id_token lên backend POST /auth/google
  3. Backend verify id_token bằng google-auth library
  4. Trích xuất email, google_id, name, avatar
  5. Upsert user → trả JWT của hệ thống

Cấu hình: GOOGLE_CLIENT_ID trong .env
"""
from __future__ import annotations

import os
from typing import Optional

from app.utils import get_logger

logger = get_logger("google_auth")

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "")


class GoogleTokenError(Exception):
    """id_token không hợp lệ hoặc không verify được."""
    pass


async def verify_google_id_token(id_token: str) -> dict:
    """
    Xác thực Google id_token và trả về dict thông tin user:
      {
        "google_id": str,
        "email": str,
        "full_name": str | None,
        "avatar_url": str | None,
        "email_verified": bool,
      }

    Raises:
        GoogleTokenError: nếu token không hợp lệ
    """
    if not GOOGLE_CLIENT_ID:
        raise GoogleTokenError(
            "GOOGLE_CLIENT_ID chưa được cấu hình trong .env. "
            "Thêm GOOGLE_CLIENT_ID=<your-client-id> để dùng Google OAuth."
        )

    try:
        from google.auth.transport import requests as google_requests
        from google.oauth2 import id_token as google_id_token

        # google-auth verify chạy sync — chạy trong threadpool để không block event loop
        import asyncio
        loop = asyncio.get_event_loop()

        def _verify():
            return google_id_token.verify_oauth2_token(
                id_token,
                google_requests.Request(),
                GOOGLE_CLIENT_ID,
            )

        idinfo = await loop.run_in_executor(None, _verify)

    except ValueError as e:
        raise GoogleTokenError(f"Token Google không hợp lệ: {e}") from e
    except ImportError:
        raise GoogleTokenError(
            "Package google-auth chưa được cài. Chạy: pip install google-auth"
        )

    if idinfo.get("aud") != GOOGLE_CLIENT_ID:
        raise GoogleTokenError("Token không thuộc client_id này")

    return {
        "google_id":      idinfo["sub"],
        "email":          idinfo.get("email", ""),
        "full_name":      idinfo.get("name"),
        "avatar_url":     idinfo.get("picture"),
        "email_verified": idinfo.get("email_verified", False),
    }
