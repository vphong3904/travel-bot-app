-- ============================================================
-- PDTrip AI — Seed: intent_patterns (keyword nhận diện intent)
-- Bảng tạo ở 03_schema_ai.sql. Bộ keyword này nạp sẵn để chatbot chạy
-- ngay; admin có thể chỉnh thêm qua /admin/intent-patterns.
-- Idempotent: ON CONFLICT (intent, keyword) DO NOTHING.
-- ============================================================

INSERT INTO intent_patterns (intent, keyword, weight, is_active)
VALUES
    -- ask_activity: câu "có gì đặc biệt/nổi tiếng..."
    ('ask_activity', 'có gì đặc biệt',  1, TRUE),
    ('ask_activity', 'có gì nổi tiếng', 1, TRUE),
    ('ask_activity', 'nổi tiếng',       1, TRUE),
    ('ask_activity', 'điểm tham quan',  1, TRUE),
    ('ask_activity', 'danh lam',        1, TRUE),
    ('ask_activity', 'thắng cảnh',      1, TRUE),
    ('ask_activity', 'bãi biển',        1, TRUE),
    ('ask_activity', 'khám phá gì',     1, TRUE),
    ('ask_activity', 'nên ghé',         1, TRUE),
    -- out_of_scope: tài chính/tin tức ngoài du lịch
    ('out_of_scope', 'giá vàng',        1, TRUE),
    ('out_of_scope', 'tỷ giá',          1, TRUE),
    ('out_of_scope', 'xổ số',           1, TRUE),
    ('out_of_scope', 'lô đề',           1, TRUE),
    ('out_of_scope', 'thời sự',         1, TRUE),
    -- ask_shopping: chợ/TTTM/mua sắm
    ('ask_shopping', 'chợ',                  1, TRUE),
    ('ask_shopping', 'chợ đêm',              1, TRUE),
    ('ask_shopping', 'trung tâm thương mại', 1, TRUE),
    ('ask_shopping', 'tttm',                 1, TRUE),
    ('ask_shopping', 'siêu thị',             1, TRUE),
    ('ask_shopping', 'mua sắm',              1, TRUE),
    ('ask_shopping', 'quà lưu niệm',         1, TRUE),
    ('ask_shopping', 'mua gì',               1, TRUE),
    ('ask_shopping', 'shopping',             1, TRUE),
    ('ask_shopping', 'outlet',               1, TRUE),
    ('ask_shopping', 'mua quà',              1, TRUE)
ON CONFLICT (intent, keyword) DO NOTHING;
