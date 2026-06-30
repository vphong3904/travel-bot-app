-- ============================================================
-- PDTrip AI — Seed 40: 4 tài khoản RBAC mẫu cho Web Admin
-- ------------------------------------------------------------
-- 4 cấp quyền theo migration 31 (users_role_check):
--   super_admin · admin · content_manager · moderator
--
-- password_hash dùng lại y nguyên hash của các user seed (10_seed_auth.sql)
-- → mật khẩu đăng nhập: 12345678
--
-- Idempotent: ON CONFLICT (email) — chạy lại không tạo trùng.
-- Phụ thuộc: 31_migration_user_role.sql (CHECK role 5 cấp).
-- ============================================================

BEGIN;

INSERT INTO users (id, username, email, password_hash, full_name, role) VALUES
  ('a0000000-0000-0000-0000-00000000000a', 'superadmin', 'superadmin@pdtrip.vn',
   '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Super Admin',       'super_admin'),
  ('a0000000-0000-0000-0000-00000000000b', 'admin',      'admin@pdtrip.vn',
   '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Quản trị viên',      'admin'),
  ('a0000000-0000-0000-0000-00000000000c', 'contentmgr', 'content@pdtrip.vn',
   '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Quản lý nội dung',   'content_manager'),
  ('a0000000-0000-0000-0000-00000000000d', 'moderator',  'moderator@pdtrip.vn',
   '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Kiểm duyệt viên',    'moderator')
ON CONFLICT (email) DO UPDATE SET
  role          = EXCLUDED.role,
  password_hash = EXCLUDED.password_hash,
  full_name     = EXCLUDED.full_name,
  is_active     = TRUE,
  is_deleted    = FALSE,
  updated_at    = NOW();

COMMIT;

-- Kiểm tra:
-- SELECT username, email, role FROM users WHERE role <> 'user' ORDER BY role;
