-- Mở rộng cột role từ VARCHAR(20) lên VARCHAR(30) với 5 role
-- Chạy một lần trên DB đã có dữ liệu

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ALTER COLUMN role TYPE VARCHAR(30);
ALTER TABLE users ADD CONSTRAINT users_role_check
    CHECK (role IN ('user', 'admin', 'super_admin', 'content_manager', 'moderator'));

-- Để gán super_admin: UPDATE users SET role = 'super_admin' WHERE email = '...';
