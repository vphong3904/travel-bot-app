-- ============================================================
-- PDTrip AI — [OPT-3.2] Bổ sung keyword ask_activity vào intent_patterns
-- Câu hỏi "có gì đặc biệt / nổi tiếng / điểm tham quan ..." rất phổ biến nhưng
-- trước đây không khớp intent nào → rơi về ask_destination/unknown.
--
-- Idempotent: ON CONFLICT (intent, keyword) DO NOTHING (UNIQUE đã có ở bảng).
-- Chạy được nhiều lần. Sau khi chạy, gọi POST /admin/intent-patterns/reload
-- (hoặc restart) để chatbot nạp lại từ DB.
-- ============================================================

INSERT INTO intent_patterns (intent, keyword, weight, is_active)
VALUES
    -- ask_activity: câu "có gì đặc biệt/nổi tiếng..."
    ('ask_activity', 'có gì đặc biệt',  1.0, TRUE),
    ('ask_activity', 'có gì nổi tiếng', 1.0, TRUE),
    ('ask_activity', 'nổi tiếng',       1.0, TRUE),
    ('ask_activity', 'điểm tham quan',  1.0, TRUE),
    ('ask_activity', 'danh lam',        1.0, TRUE),
    ('ask_activity', 'thắng cảnh',      1.0, TRUE),
    ('ask_activity', 'bãi biển',        1.0, TRUE),
    ('ask_activity', 'khám phá gì',     1.0, TRUE),
    ('ask_activity', 'nên ghé',         1.0, TRUE),
    -- out_of_scope: tài chính/tin tức ngoài du lịch (vd "giá vàng hôm nay")
    ('out_of_scope', 'giá vàng',        1.0, TRUE),
    ('out_of_scope', 'tỷ giá',          1.0, TRUE),
    ('out_of_scope', 'xổ số',           1.0, TRUE),
    ('out_of_scope', 'lô đề',           1.0, TRUE),
    ('out_of_scope', 'thời sự',         1.0, TRUE),
    -- ask_shopping: chợ/TTTM/mua sắm (bảng shopping_places)
    ('ask_shopping', 'chợ',                  1.0, TRUE),
    ('ask_shopping', 'chợ đêm',              1.0, TRUE),
    ('ask_shopping', 'trung tâm thương mại', 1.0, TRUE),
    ('ask_shopping', 'tttm',                 1.0, TRUE),
    ('ask_shopping', 'siêu thị',             1.0, TRUE),
    ('ask_shopping', 'mua sắm',              1.0, TRUE),
    ('ask_shopping', 'quà lưu niệm',         1.0, TRUE),
    ('ask_shopping', 'mua gì',               1.0, TRUE),
    ('ask_shopping', 'shopping',             1.0, TRUE),
    ('ask_shopping', 'outlet',               1.0, TRUE),
    ('ask_shopping', 'mua quà',              1.0, TRUE)
ON CONFLICT (intent, keyword) DO NOTHING;

-- [OPT-3.2] Bỏ keyword "du lịch" khỏi ask_destination — quá chung chung, gây
-- nhận nhầm (vd "đổi tiền khi du lịch" → ask_destination thay vì ask_faq).
DELETE FROM intent_patterns WHERE intent = 'ask_destination' AND keyword = 'du lịch';

-- Kiểm tra nhanh:
-- SELECT intent, count(*) FROM intent_patterns WHERE is_active GROUP BY intent ORDER BY intent;
