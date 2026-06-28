-- ============================================================
-- [AUTH] OTP CODES
-- Mã xác thực một lần dùng cho:
--   'register'       → xác thực email khi đăng ký
--   'reset_password' → đặt lại mật khẩu
--   'change_email'   → đổi email (tương lai)
-- ============================================================
CREATE TABLE otp_codes (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id     UUID        REFERENCES users(id) ON DELETE CASCADE,
    -- user_id nullable: cho phép gửi OTP trước khi tài khoản tồn tại (register flow)
    -- Khi purpose='register', tra cứu theo email thay vì user_id
    email       VARCHAR(255) NOT NULL,
    code        VARCHAR(10) NOT NULL,
    purpose     VARCHAR(50) NOT NULL
                CHECK (purpose IN ('register', 'reset_password', 'change_email')),
    expires_at  TIMESTAMPTZ NOT NULL,
    used        BOOLEAN     DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_otp_email_purpose ON otp_codes(email, purpose, used, expires_at)
    WHERE used = FALSE;
CREATE INDEX idx_otp_user ON otp_codes(user_id)
    WHERE user_id IS NOT NULL;

-- ============================================================
-- [AUTH] EMAIL VERIFICATIONS
-- Trạng thái xác thực email của user
-- (tách khỏi bảng users để dễ query và mở rộng)
-- ============================================================
CREATE TABLE email_verifications (
    id              UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id         UUID        NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    email           VARCHAR(255) NOT NULL,
    is_verified     BOOLEAN     DEFAULT FALSE,
    verified_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_email_ver_user    ON email_verifications(user_id);
CREATE INDEX idx_email_ver_email   ON email_verifications(email);
