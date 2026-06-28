-- ============================================================
-- Migration: extend_user_role_to_4_levels
-- Mở rộng cột role từ VARCHAR(20) CHECK ('user','admin')
-- lên VARCHAR(30) với 5 role: user, admin, super_admin, content_manager, moderator
-- ============================================================

-- 1. Xoá constraint cũ
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;

-- 2. Mở rộng độ dài cột
ALTER TABLE users ALTER COLUMN role TYPE VARCHAR(30);

-- 3. Thêm constraint mới với đủ 5 role
ALTER TABLE users ADD CONSTRAINT users_role_check
    CHECK (role IN ('user', 'admin', 'super_admin', 'content_manager', 'moderator'));

-- 4. Seed tài khoản super_admin (chỉ chạy nếu chưa tồn tại)
-- UPDATE users SET role = 'super_admin' WHERE email = 'your_email@example.com';
