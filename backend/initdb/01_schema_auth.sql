-- ============================================================
-- PDTrip AI – Schema: AUTH
-- users · refresh_tokens · otp_codes · email_verifications
-- ============================================================

-- ── USERS ───────────────────────────────────────────────────
-- role: 5 cấp RBAC cho Web Admin (user < moderator < content_manager < admin < super_admin)
CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    username      VARCHAR(50)  UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    avatar_url    TEXT,
    role          VARCHAR(20)  DEFAULT 'user'
                  CHECK (role IN ('user', 'moderator', 'content_manager', 'admin', 'super_admin')),
    is_active     BOOLEAN      DEFAULT TRUE,
    is_deleted    BOOLEAN      DEFAULT FALSE,
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  DEFAULT NOW(),
    -- Google OAuth
    google_id     VARCHAR(255) UNIQUE,
    auth_provider VARCHAR(20)  DEFAULT 'email'
                  CHECK (auth_provider IN ('email', 'google', 'email+google'))
);
CREATE INDEX idx_users_email     ON users(email);
CREATE INDEX idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;
CREATE INDEX idx_users_username  ON users(username);
CREATE INDEX idx_users_role      ON users(role);
SELECT _attach_updated_at('users');

-- ── REFRESH TOKENS (JWT) ────────────────────────────────────
CREATE TABLE refresh_tokens (
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT        NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked    BOOLEAN     DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_reftokens_user   ON refresh_tokens(user_id);
CREATE INDEX idx_reftokens_active ON refresh_tokens(revoked, expires_at)
    WHERE revoked = FALSE;

-- ── OTP CODES (register / reset_password / change_email) ────
-- user_id nullable: gửi OTP trước khi tài khoản tồn tại (register flow).
CREATE TABLE otp_codes (
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id    UUID        REFERENCES users(id) ON DELETE CASCADE,
    email      VARCHAR(255) NOT NULL,
    code       VARCHAR(10) NOT NULL,
    purpose    VARCHAR(50) NOT NULL
               CHECK (purpose IN ('register', 'reset_password', 'change_email')),
    expires_at TIMESTAMPTZ NOT NULL,
    used       BOOLEAN     DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_otp_email_purpose ON otp_codes(email, purpose, used, expires_at)
    WHERE used = FALSE;
CREATE INDEX idx_otp_user ON otp_codes(user_id) WHERE user_id IS NOT NULL;

-- ── EMAIL VERIFICATIONS ─────────────────────────────────────
CREATE TABLE email_verifications (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id     UUID        NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    email       VARCHAR(255) NOT NULL,
    is_verified BOOLEAN     DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_email_ver_user  ON email_verifications(user_id);
CREATE INDEX idx_email_ver_email ON email_verifications(email);
