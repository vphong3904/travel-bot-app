-- ============================================================
-- PDTrip AI – Seed: AUTH users
-- password_hash của tất cả tài khoản dưới đây ⇒ mật khẩu: 12345678
-- ============================================================

-- ── User thường (mobile app) ────────────────────────────────
INSERT INTO users (id, username, email, password_hash, full_name, role) VALUES
('11111111-1111-1111-1111-111111111111', 'admin',     'admin@pdtrip.vn',      '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Quản trị viên', 'admin'),
('22222222-2222-2222-2222-222222222222', 'tranlan',   'tranlan@gmail.com',    '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Trần Lan',   'user'),
('33333333-3333-3333-3333-333333333333', 'minhhieu',  'minhhieu@gmail.com',   '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Minh Hiếu',  'user'),
('44444444-4444-4444-4444-444444444444', 'ngochuong', 'ngochuong@gmail.com',  '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Ngọc Hương', 'user'),
('55555555-5555-5555-5555-555555555555', 'quangkhai', 'quangkhai@gmail.com',  '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Quang Khải', 'user'),
('66666666-6666-6666-6666-666666666666', 'thuylinh',  'thuylinh@gmail.com',   '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Thùy Linh',  'user')
ON CONFLICT (email) DO NOTHING;

-- ── 4 cấp RBAC cho Web Admin (mật khẩu 12345678) ────────────
INSERT INTO users (id, username, email, password_hash, full_name, role) VALUES
('a0000000-0000-0000-0000-00000000000a', 'superadmin', 'superadmin@pdtrip.vn', '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Super Admin',      'super_admin'),
('a0000000-0000-0000-0000-00000000000c', 'contentmgr', 'content@pdtrip.vn',    '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Quản lý nội dung', 'content_manager'),
('a0000000-0000-0000-0000-00000000000d', 'moderator',  'moderator@pdtrip.vn',  '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Kiểm duyệt viên',  'moderator')
ON CONFLICT (email) DO UPDATE SET
  role          = EXCLUDED.role,
  password_hash = EXCLUDED.password_hash,
  full_name     = EXCLUDED.full_name,
  is_active     = TRUE,
  is_deleted    = FALSE,
  updated_at    = NOW();
