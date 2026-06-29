-- ============================================================
-- PDTrip AI — Migration: Fix users.role CHECK constraint (T-032)
-- Mở rộng enum role từ ('user','admin') → 5 cấp RBAC.
-- app/api/deps.py đã dùng ADMIN_ROLES={'admin','super_admin','content_manager','moderator'}
-- nhưng DB chỉ có CHECK ('user','admin') → INSERT role khác bị chặn.
-- ============================================================

BEGIN;

-- Drop constraint cũ, thêm constraint mới cho phép đủ 5 cấp
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check
    CHECK (role IN ('user', 'moderator', 'content_manager', 'admin', 'super_admin'));

COMMIT;

-- Kiểm tra nhanh:
-- SELECT role, count(*) FROM users GROUP BY role;
-- INSERT INTO users (..., role) VALUES (..., 'moderator') -- phải thành công
