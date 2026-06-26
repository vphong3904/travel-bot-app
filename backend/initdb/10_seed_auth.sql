-- ============================================================
-- PDTrip AI – Seed: AUTH users mẫu
-- (Tách từ 01_pdtrip_ai_db.sql để dễ quản lý — xem README_INITDB.md)
-- ============================================================

-- [AUTH] USERS — 1 admin + 2 user mẫu
-- password_hash dưới đây là placeholder, hãy thay bằng bcrypt hash thật
-- ============================================================
INSERT INTO users (id, username, email, password_hash, full_name, role) VALUES
('11111111-1111-1111-1111-111111111111', 'admin', 'admin@pdtrip.vn', '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Quản trị viên', 'admin'),
('22222222-2222-2222-2222-222222222222', 'tranlan', 'tranlan@gmail.com', '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Trần Lan', 'user'),
('33333333-3333-3333-3333-333333333333', 'minhhieu', 'minhhieu@gmail.com', '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Minh Hiếu', 'user'),
('44444444-4444-4444-4444-444444444444', 'ngochuong', 'ngochuong@gmail.com', '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Ngọc Hương', 'user'),
('55555555-5555-5555-5555-555555555555', 'quangkhai', 'quangkhai@gmail.com', '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Quang Khải', 'user'),
('66666666-6666-6666-6666-666666666666', 'thuylinh', 'thuylinh@gmail.com', '$2a$12$9AlNwb7FystnU1gST7pLlOU42gb4.KF1KT50isbMraGDArJsUhoOq', 'Thùy Linh', 'user');

-- ============================================================
