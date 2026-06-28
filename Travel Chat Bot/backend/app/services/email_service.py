"""
Service gửi email qua SMTP async (aiosmtplib).
Cấu hình qua biến môi trường:
  SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASSWORD, SMTP_FROM
  SMTP_USE_TLS (default True)

Nếu SMTP_HOST chưa được cấu hình, email sẽ được in ra console
(mock mode — tiện cho dev/test không cần SMTP thật).
"""
from __future__ import annotations

import os
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import Optional

from app.utils import get_logger

logger = get_logger("email_service")

# ── Đọc config từ env ────────────────────────────────────────────────────────
SMTP_HOST     = os.getenv("SMTP_HOST", "")
SMTP_PORT     = int(os.getenv("SMTP_PORT", "587"))
SMTP_USER     = os.getenv("SMTP_USER", "")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM     = os.getenv("SMTP_FROM", "noreply@pdtrip.ai")
SMTP_USE_TLS  = os.getenv("SMTP_USE_TLS", "true").lower() == "true"

APP_NAME = os.getenv("APP_NAME", "PDTrip AI")


# ── Template HTML ────────────────────────────────────────────────────────────
def _otp_html(otp: str, purpose: str, expires_minutes: int = 10) -> str:
    action = "xác nhận đăng ký" if purpose == "register" else "đặt lại mật khẩu"
    return f"""
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="UTF-8"></head>
<body style="font-family:Arial,sans-serif;background:#f4f4f4;padding:20px;">
  <div style="max-width:480px;margin:auto;background:#fff;border-radius:12px;padding:32px;">
    <h2 style="color:#2563eb;margin-bottom:8px;">{APP_NAME}</h2>
    <p style="color:#374151;">Mã OTP để <strong>{action}</strong> của bạn là:</p>
    <div style="text-align:center;margin:24px 0;">
      <span style="font-size:36px;font-weight:bold;letter-spacing:8px;color:#1d4ed8;
                   background:#eff6ff;padding:16px 32px;border-radius:8px;">
        {otp}
      </span>
    </div>
    <p style="color:#6b7280;font-size:14px;">
      Mã có hiệu lực trong <strong>{expires_minutes} phút</strong>.
      Không chia sẻ mã này với bất kỳ ai.
    </p>
    <hr style="border:none;border-top:1px solid #e5e7eb;margin:24px 0;">
    <p style="color:#9ca3af;font-size:12px;">
      Nếu bạn không yêu cầu hành động này, hãy bỏ qua email này.
    </p>
  </div>
</body>
</html>
"""


async def send_otp_email(
    to_email: str,
    otp: str,
    purpose: str,
    expires_minutes: int = 10,
) -> bool:
    """
    Gửi email chứa mã OTP.
    Trả về True nếu gửi thành công, False nếu lỗi.
    Nếu SMTP chưa cấu hình → in ra console (mock mode).
    """
    subject_map = {
        "register":       f"[{APP_NAME}] Mã xác nhận đăng ký tài khoản",
        "reset_password": f"[{APP_NAME}] Mã đặt lại mật khẩu",
        "change_email":   f"[{APP_NAME}] Mã xác nhận đổi email",
    }
    subject = subject_map.get(purpose, f"[{APP_NAME}] Mã OTP")
    html_body = _otp_html(otp, purpose, expires_minutes)

    # ── Mock mode khi không có SMTP ──────────────────────────────────────────
    if not SMTP_HOST:
        logger.warning(
            f"[email_service] SMTP chưa cấu hình — MOCK MODE\n"
            f"  TO:      {to_email}\n"
            f"  SUBJECT: {subject}\n"
            f"  OTP:     {otp}\n"
            f"  PURPOSE: {purpose}"
        )
        return True

    # ── Gửi thật qua aiosmtplib ─────────────────────────────────────────────
    try:
        import aiosmtplib  # import lazy để không crash khi chưa install

        msg = MIMEMultipart("alternative")
        msg["Subject"] = subject
        msg["From"]    = f"{APP_NAME} <{SMTP_FROM}>"
        msg["To"]      = to_email
        msg.attach(MIMEText(html_body, "html", "utf-8"))

        await aiosmtplib.send(
            msg,
            hostname=SMTP_HOST,
            port=SMTP_PORT,
            username=SMTP_USER,
            password=SMTP_PASSWORD,
            start_tls=SMTP_USE_TLS,
        )
        logger.info(f"[email_service] Gửi OTP {purpose} thành công → {to_email}")
        return True

    except Exception as e:
        logger.error(f"[email_service] Gửi email thất bại → {to_email}: {e}")
        return False
