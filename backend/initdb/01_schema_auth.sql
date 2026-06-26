-- ============================================================
-- PDTrip AI – Schema: AUTH (users, refresh_tokens)
-- (Tách từ 01_pdtrip_ai_db.sql để dễ quản lý — xem README_INITDB.md)
-- ============================================================

-- [AUTH] USERS
-- Người dùng đăng ký sử dụng chatbot
-- ============================================================
CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    username      VARCHAR(50)  UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    avatar_url    TEXT,
    role          VARCHAR(20)  DEFAULT 'user'
                  CHECK (role IN ('user', 'admin')),
    is_active     BOOLEAN      DEFAULT TRUE,
    is_deleted    BOOLEAN      DEFAULT FALSE,
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW(),
    -- Google OAuth
    google_id      VARCHAR(255) UNIQUE,
    auth_provider  VARCHAR(20)  DEFAULT 'email'
                   CHECK (auth_provider IN ('email', 'google', 'email+google'))
);
CREATE INDEX idx_users_email      ON users(email);
CREATE INDEX idx_users_google_id  ON users(google_id) WHERE google_id IS NOT NULL;
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role     ON users(role);
SELECT _attach_updated_at('users');

-- ============================================================
-- [AUTH] REFRESH TOKENS
-- Lưu refresh token cho JWT authentication
-- ============================================================
CREATE TABLE refresh_tokens (
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT        NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked    BOOLEAN     DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_reftokens_user    ON refresh_tokens(user_id);
CREATE INDEX idx_reftokens_active  ON refresh_tokens(revoked, expires_at)
    WHERE revoked = FALSE;