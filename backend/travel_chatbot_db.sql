-- =============================================================================
-- VietTravel AI - PostgreSQL Database
-- Tổng hợp từ SQLite (app demo) + SQL Server script (data mở rộng)
-- =============================================================================

-- Xóa và tạo lại nếu cần (comment dòng này khi production)
-- DROP SCHEMA public CASCADE; CREATE SCHEMA public;

-- =============================================================================
-- 1. EXTENSIONS
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS unaccent;

-- =============================================================================
-- 2. TABLES
-- =============================================================================

CREATE TABLE IF NOT EXISTS users (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(120)  NOT NULL,
    email       VARCHAR(120)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role        VARCHAR(20)   NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    is_active   BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_users_id    ON users (id);
CREATE UNIQUE INDEX IF NOT EXISTS ix_users_email ON users (email);

-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS destinations (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(100)  NOT NULL,
    region       VARCHAR(100),
    description  TEXT          NOT NULL,
    highlights   TEXT,
    best_season  VARCHAR(100),
    weather      VARCHAR(200),
    cuisine      TEXT,
    budget_low   INTEGER,
    budget_high  INTEGER,
    tags         VARCHAR(200),
    image_url    VARCHAR(500)
);

CREATE INDEX IF NOT EXISTS ix_destinations_id ON destinations (id);

-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS hotels (
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(200) NOT NULL,
    destination    VARCHAR(100) NOT NULL,
    type           VARCHAR(50),
    price_per_night INTEGER,
    rating         FLOAT,
    address        VARCHAR(300),
    amenities      VARCHAR(300)
);

CREATE INDEX IF NOT EXISTS ix_hotels_id ON hotels (id);

-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tours (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    duration    VARCHAR(50),
    price       INTEGER,
    description TEXT,
    includes    TEXT
);

CREATE INDEX IF NOT EXISTS ix_tours_id ON tours (id);

-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tickets (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    price       INTEGER,
    description TEXT
);

CREATE INDEX IF NOT EXISTS ix_tickets_id ON tickets (id);

-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS knowledge_entries (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    category    VARCHAR(50)  NOT NULL,
    destination VARCHAR(100),
    content     TEXT         NOT NULL,
    tags        VARCHAR(300),
    created_at  TIMESTAMP    DEFAULT NOW(),
    updated_at  TIMESTAMP    DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_knowledge_entries_id ON knowledge_entries (id);

-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS chat_logs (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER,
    user_name   VARCHAR(120),
    message     TEXT         NOT NULL,
    response    TEXT         NOT NULL,
    intent      VARCHAR(50),
    destination VARCHAR(100),
    created_at  TIMESTAMP    DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS ix_chat_logs_id ON chat_logs (id);

-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS popular_queries (
    id         SERIAL PRIMARY KEY,
    query_text VARCHAR(300) NOT NULL,
    count      INTEGER      DEFAULT 1,
    intent     VARCHAR(50)
);

CREATE INDEX IF NOT EXISTS ix_popular_queries_id ON popular_queries (id);


-- =============================================================================
-- 3. TRIGGER: auto-update updated_at cho knowledge_entries
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_knowledge_entries_updated_at ON knowledge_entries;
CREATE TRIGGER trg_knowledge_entries_updated_at
    BEFORE UPDATE ON knowledge_entries
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();


-- =============================================================================
-- 4. SEED DATA - USERS
-- Giữ nguyên 3 user từ app demo (password hash bcrypt hợp lệ)
-- Thêm 1 user mới từ File 2
-- =============================================================================
INSERT INTO users (name, email, password_hash, role, is_active, created_at) VALUES
('Admin',          'admin@travel.ai', '$2b$12$X7EQKak34ahfWcKK3UzA9.KYlV3G50z/JRWUTuJMlxQ.4Ypb.5hRy', 'admin', TRUE, '2026-06-03 14:40:14'),
('Nguyễn Văn A',   'user@travel.ai',  '$2b$12$IuW8UNrK3MkECHW8KwhyveSlxuMpCKgo1Wo.gfMF.npaJRwVgBIHi', 'user',  TRUE, '2026-06-03 14:40:14'),
('Trần Thị B',     'demo@travel.ai',  '$2b$12$gM71gnyaHQQ3n36fdtNPiear75FKkUM0lWR7SHt4po6Lwpd4Djc/u', 'user',  TRUE, '2026-06-03 14:40:14'),
('Lê Minh Cường',  'cuong@travel.ai', '$2b$12$X7EQKak34ahfWcKK3UzA9.KYlV3G50z/JRWUTuJMlxQ.4Ypb.5hRy', 'user',  FALSE,'2026-06-03 14:40:14')
ON CONFLICT (email) DO NOTHING;


-- =============================================================================
-- 5. SEED DATA - DESTINATIONS
-- File 1 có: Đà Lạt, Phú Quốc, Hội An, Hà Giang, Nha Trang, Sa Pa
-- File 2 bổ sung: Đà Nẵng, Hạ Long (2 điểm mới)
-- =============================================================================
INSERT INTO destinations (name, region, description, highlights, best_season, weather, cuisine, budget_low, budget_high, tags, image_url) VALUES

-- ── Từ File 1 (app demo) ──────────────────────────────────────────────────────
('Đà Lạt', 'Lâm Đồng',
 'Thành phố ngàn hoa với khí hậu mát mẻ quanh năm, nổi tiếng với đồi thông, hồ nước và kiến trúc Pháp cổ.',
 'Hồ Xuân Hương, Thung lũng Tình Yêu, Chợ Đà Lạt, Dinh Bảo Đại, Langbiang',
 'Tháng 11 - tháng 3 (hoa dã quỳ, mùa khô mát)',
 'Nhiệt độ 15-25°C, mát mẻ, sương mù buổi sáng',
 'Bánh căn, bánh tráng nướng, lẩu gà lá é, kem bơ, atiso',
 800000, 5000000,
 'núi,nghỉ dưỡng,romantic,khám phá',
 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800'),

('Phú Quốc', 'Kiên Giang',
 'Đảo ngọc với bãi biển trong xanh, resort sang trọng và hải sản tươi ngon.',
 'Bãi Sao, Grand World, VinWonders, Chợ đêm Dinh Cậu, Nhà tù Phú Quốc',
 'Tháng 11 - tháng 4 (mùa khô, biển êm)',
 'Nhiệt độ 27-32°C, nắng đẹp, mùa mưa từ tháng 5-10',
 'Gỏi cá trích, nhum biển nướng, bún quậy Kiến Xây, hải sản tươi',
 1500000, 15000000,
 'biển,resort,gia đình,cặp đôi',
 'https://images.unsplash.com/photo-1559592413-7cec025d7d8e?w=800'),

('Hội An', 'Quảng Nam',
 'Phố cổ UNESCO với đèn lồng lung linh, kiến trúc cổ kính và ẩm thực đa dạng.',
 'Phố cổ, chùa Cầu, An Bàng, làng gốm Thanh Hà, đèn lồng',
 'Tháng 2 - tháng 4 (mát mẻ, ít mưa)',
 'Nhiệt độ 22-30°C, mùa mưa từ tháng 9-12',
 'Cao lầu, mì Quảng, bánh mì Phương, bánh bao bánh vạc',
 600000, 4000000,
 'văn hóa,cặp đôi,ẩm thực,khám phá',
 'https://images.unsplash.com/photo-1559592413-7cec025d7d8e?w=800'),

('Hà Giang', 'Hà Giang',
 'Vùng đất địa đầu Tổ quốc với cột mốc Lũng Cú, đèo Mã Pí Lèng hùng vĩ và văn hóa các dân tộc.',
 'Cột cờ Lũng Cú, đèo Mã Pí Lèng, Sủng Là, Hoàng Su Phì, cao nguyên đá Đồng Văn',
 'Tháng 9 - tháng 11 (hoa tam giác mạch), tháng 3-5 (hoa đào)',
 'Mát mẻ vùng núi, sương mù, nhiệt độ 10-25°C tùy mùa',
 'Thắng cố, bánh tam giác mạch, thịt trâu gác bếp, rượu ngô',
 500000, 3000000,
 'núi,khám phá,solo,phiêu lưu',
 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800'),

('Nha Trang', 'Khánh Hòa',
 'Thành phố biển năng động với VinWonders, tắm biển và ẩm thực hải sản phong phú.',
 'VinWonders, Tháp Bà Ponagar, Hòn Mun, Bãi Tranh',
 'Tháng 1 - tháng 8',
 'Nhiệt độ 26-32°C, nắng đẹp',
 'Bún cá Nha Trang, nem nướng, bánh căn chả cá',
 700000, 6000000,
 'biển,gia đình,resort',
 'https://images.unsplash.com/photo-1559592413-7cec025d7d8e?w=800'),

('Sa Pa', 'Lào Cai',
 'Thị trấn sương mù trên núi Fansipan với ruộng bậc thang và văn hóa dân tộc thiểu số.',
 'Fansipan, Cát Cát, Ta Phin, ruộng bậc thang Mù Cang Chải',
 'Tháng 9 - tháng 11 (lúa chín), tháng 12-2 (tuyết)',
 'Mát lạnh 8-20°C, sương mù dày',
 'Thịt trâu gác bếp, cá hồi, rượu táo mèo',
 600000, 5000000,
 'núi,khám phá,solo,phiêu lưu',
 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800'),

-- ── Từ File 2 (bổ sung mới) ──────────────────────────────────────────────────
('Đà Nẵng', 'Miền Trung',
 'Thành phố biển năng động với cầu Rồng, Bà Nà Hills và bãi biển Mỹ Khê được Forbes bình chọn.',
 'Cầu Rồng phun lửa, Bà Nà Hills, Ngũ Hành Sơn, biển Mỹ Khê, ẩm thực hải sản',
 'Tháng 2 - tháng 8 (mùa khô)',
 'Nhiệt độ 25-33°C, nắng đẹp. Tránh tháng 10-12 có bão.',
 'Mì Quảng, bún chả cá, bánh xèo, hải sản tươi',
 800000, 8000000,
 'biển,thành phố,gia đình,khám phá',
 'https://images.unsplash.com/photo-1559592413-7cec025d7d8e?w=800'),

('Hạ Long', 'Quảng Ninh',
 'Vịnh di sản thế giới với hàng nghìn đảo đá vôi kỳ vĩ trên biển.',
 'Du thuyền vịnh, hang Sửng Sốt, đảo Titop, làng chài Cửa Vạn',
 'Tháng 10 - tháng 4',
 'Nhiệt độ 20-28°C, mùa hè nóng ẩm, mùa đông se lạnh',
 'Hải sản tươi trên vịnh, chả mực Hạ Long, sá sùng',
 1200000, 10000000,
 'biển,du thuyền,gia đình,khám phá',
 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=800');


-- =============================================================================
-- 6. SEED DATA - HOTELS
-- Giữ 6 từ File 1 + thêm mới từ File 2 (Đà Nẵng, Hạ Long, Sa Pa mở rộng)
-- =============================================================================
INSERT INTO hotels (name, destination, type, price_per_night, rating, address, amenities) VALUES

-- ── Từ File 1 ────────────────────────────────────────────────────────────────
('Dalat Palace Heritage Hotel', 'Đà Lạt',   'hotel',    2500000, 4.8, '12 Trần Phú, Đà Lạt',          'Spa, Pool, Restaurant'),
('Homestay The Kupid',          'Đà Lạt',   'homestay',  600000, 4.5, 'Ward 5, Đà Lạt',               'View đồi thông, Cafe'),
('JW Marriott Phu Quoc',        'Phú Quốc', 'resort',  8500000, 4.9, 'Bai Khem, Phú Quốc',           'Beach, Spa, Pool'),
('Homestay Mango Bay',          'Phú Quốc', 'homestay',  800000, 4.3, 'Bãi Trường, Phú Quốc',         'Gần biển, BBQ'),
('Hoi An Ancient House',        'Hội An',   'homestay',  900000, 4.6, 'Phố cổ Hội An',                'Kiến trúc cổ, Bike rental'),
('Sapa Clay House',             'Sa Pa',    'homestay',  700000, 4.5, 'Ta Van, Sa Pa',                'View ruộng bậc thang'),

-- ── Từ File 2 (bổ sung) ──────────────────────────────────────────────────────
('InterContinental Đà Nẵng',   'Đà Nẵng',  'resort',  8500000, 4.9, 'Bãi Bắc, Sơn Trà, Đà Nẵng',   'Beach, Spa, Pool, View biển'),
('Mường Thanh Luxury Đà Nẵng', 'Đà Nẵng',  'hotel',   1200000, 4.2, '962 Ngô Quyền, Đà Nẵng',       'Pool, Restaurant, Gym'),
('Furama Resort Đà Nẵng',      'Đà Nẵng',  'resort',  4500000, 4.7, '105 Võ Nguyên Giáp, Đà Nẵng',  'Bãi biển riêng, Pool vô cực'),
('Vinpearl Resort Phú Quốc',   'Phú Quốc', 'resort',  5500000, 4.8, 'Bãi Dài, Phú Quốc',            'Đảo riêng, Cáp treo, Water park'),
('Salinda Resort Phú Quốc',    'Phú Quốc', 'resort',  3200000, 4.6, 'Cửa Dương, Phú Quốc',          'Boutique, Spa, Pool'),
('Hotel de la Coupole Sapa',   'Sa Pa',    'hotel',   4800000, 4.8, '1 Hoàng Liên, Sa Pa',          'View Fansipan, Spa, Phong cách Pháp'),
('Anantara Hội An Resort',     'Hội An',   'resort',  4200000, 4.8, '1 Đường Cửa Đại, Hội An',      'Ven sông Thu Bồn, Pool, Spa'),
('Novotel Hạ Long Bay',        'Hạ Long',  'hotel',   1800000, 4.3, '160 Hạ Long, Quảng Ninh',      'View vịnh, Pool, Restaurant'),
('Vinpearl Resort Nha Trang',  'Nha Trang','resort',  3800000, 4.7, 'Đảo Hòn Tre, Nha Trang',       'Đảo riêng, Cáp treo biển, Pool');


-- =============================================================================
-- 7. SEED DATA - TOURS
-- Giữ 5 từ File 1 + thêm mới từ File 2
-- =============================================================================
INSERT INTO tours (name, destination, duration, price, description, includes) VALUES

-- ── Từ File 1 ────────────────────────────────────────────────────────────────
('Tour Hội An - Rừng dừa 1 ngày',   'Hội An',   '1 ngày', 350000,  'Rừng dừa Bảy Mẫu, làng gốm Thanh Hà',              'Thuyền thúng, HDV'),
('Tour Đà Lạt City 1 ngày',         'Đà Lạt',   '1 ngày', 350000,  'Langbiang, Dinh Bảo Đại, Thung lũng Tình Yêu',      'Xe, HDV, vé tham quan'),
('Tour Hà Giang Loop 3 ngày',       'Hà Giang', '3 ngày', 2800000, 'Lũng Cú, Mã Pí Lèng, Đồng Văn',                    'Xe máy, homestay, ăn uống'),
('Tour 3 Đảo Nha Trang',            'Nha Trang','1 ngày', 380000,  'Hòn Mun, Hòn Tằm, lặn ngắm san hô',                'Cano, lặn, ăn trưa'),
('Tour Bắc Đảo Phú Quốc 1 ngày',   'Phú Quốc', '1 ngày', 480000,  'Vinpearl Safari, Gành Dầu, Bãi Dài',               'Xe, HDV, ăn trưa'),

-- ── Từ File 2 (bổ sung) ──────────────────────────────────────────────────────
('Tour Bà Nà Hills 1 ngày',          'Đà Nẵng',  '1 ngày', 850000,  'Cáp treo, Làng Pháp, Fantasy Park, Cầu Vàng',      'Xe đưa đón, HDV, vé cáp treo'),
('Tour Ngũ Hành Sơn & Làng nghề',   'Đà Nẵng',  '1 ngày', 450000,  'Khám phá hang động, chùa Linh Ứng, làng đá',       'Xe, HDV, vé tham quan'),
('Tour 3 đảo Phú Quốc',             'Phú Quốc', '1 ngày', 650000,  'Lặn ngắm san hô, câu cá, bữa trưa hải sản biển',   'Tàu, lặn, ăn trưa'),
('Tour Bình Minh & Chợ Dương Đông', 'Phú Quốc', '1 ngày', 350000,  'Ngắm bình minh bãi Dài, khám phá chợ địa phương',  'Xe, HDV'),
('Trek Fansipan 2 ngày 1 đêm',      'Sa Pa',    '2 ngày', 2500000, 'Chinh phục đỉnh Fansipan qua cung đường cổ điển',   'Hướng dẫn viên, homestay, ăn uống'),
('Tour bản Cát Cát & Ta Phìn',      'Sa Pa',    '1 ngày', 380000,  'Trải nghiệm văn hóa H''Mông và Dao đỏ',            'Xe, HDV, vé tham quan'),
('Tour phố cổ & thả đèn hoa đăng',  'Hội An',   '1 ngày', 280000,  'Dạo phố cổ buổi tối, thả đèn hoa đăng sông Hoài',  'HDV, đèn hoa đăng'),
('Du thuyền vịnh Hạ Long 1 ngày',   'Hạ Long',  '1 ngày', 1200000, 'Hang Sửng Sốt, chèo kayak, tắm biển Titop',        'Tàu, HDV, ăn trưa, kayak'),
('Du thuyền Hạ Long 2N1Đ',          'Hạ Long',  '2 ngày', 3500000, 'Ngủ đêm trên vịnh, BBQ hải sản, ngắm bình minh',   'Tàu, phòng cabin, ăn uống, kayak'),
('Tour 4 đảo Nha Trang',            'Nha Trang','1 ngày', 550000,  'Hòn Mun, Hòn Tằm, Hòn Một, Hòn Rơm',              'Tàu, lặn, ăn trưa, HDV');


-- =============================================================================
-- 8. SEED DATA - TICKETS
-- Giữ 6 từ File 1 + thêm mới từ File 2
-- =============================================================================
INSERT INTO tickets (name, destination, price, description) VALUES

-- ── Từ File 1 ────────────────────────────────────────────────────────────────
('VinWonders Nha Trang',            'Nha Trang', 900000,  'Công viên giải trí trên đảo Hòn Tre'),
('Cáp treo Fansipan',               'Sa Pa',     750000,  'Vé cáp treo khứ hồi lên đỉnh Fansipan'),
('Vé tham quan Phố cổ Hội An',      'Hội An',    120000,  '5 điểm tham quan trong phố cổ'),
('Vinpearl Safari Phú Quốc',        'Phú Quốc',  750000,  'Safari bán hoang dã'),
('Grand World Phú Quốc',            'Phú Quốc',  0,       'Miễn phí vào cổng, trả phí trò chơi'),
('VinWonders Phú Quốc',             'Phú Quốc',  900000,  'Vé công viên giải trí cả ngày'),

-- ── Từ File 2 (bổ sung) ──────────────────────────────────────────────────────
('Vé cáp treo Bà Nà Hills',         'Đà Nẵng',   900000,  'Vé cáp treo 2 chiều, không bao gồm buffet'),
('Vé Cầu Vàng + Fantasy Park',      'Đà Nẵng',   650000,  'Combo tham quan Cầu Vàng và công viên giải trí'),
('Vé cáp treo Hòn Thơm Phú Quốc',  'Phú Quốc',  550000,  'Cáp treo 3 dây dài nhất thế giới qua biển'),
('Vé tham quan bản Cát Cát',        'Sa Pa',      70000,  'Vé vào cổng làng văn hóa Cát Cát'),
('Vé đêm phố cổ (đèn lồng)',        'Hội An',     80000,  'Vé tham quan phố cổ buổi tối cuối tuần'),
('Vé hang Sửng Sốt',                'Hạ Long',   250000,  'Vé tham quan hang động lớn nhất vịnh Hạ Long'),
('Vé Vinpearl Nha Trang',           'Nha Trang', 880000,  'Vé cáp treo + công viên nước Vinpearl'),
('Vé Viện Hải dương học',           'Nha Trang', 180000,  'Tham quan bể cá và show cá heo');


-- =============================================================================
-- 9. SEED DATA - KNOWLEDGE ENTRIES
-- Giữ 10 từ File 1 + thêm 8 từ File 2 (không trùng)
-- =============================================================================
INSERT INTO knowledge_entries (title, category, destination, content, tags, created_at, updated_at) VALUES

-- ── Từ File 1 ────────────────────────────────────────────────────────────────
('Thời tiết Đà Lạt theo mùa',
 'weather', 'Đà Lạt',
 'Đà Lạt có khí hậu mát mẻ quanh năm. Mùa khô (tháng 11-3): nắng đẹp, hoa dã quỳ nở rộ tháng 11-12. Mùa mưa (tháng 4-10): mưa chiều, sương mù dày buổi sáng. Nhiệt độ trung bình 15-25°C.',
 'thời tiết,mùa du lịch,đà lạt',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Chi phí du lịch Phú Quốc 3 ngày 2 đêm',
 'budget', 'Phú Quốc',
 'Ngân sách tiết kiệm: 3-5 triệu/người (homestay, ăn quán). Tầm trung: 6-10 triệu (khách sạn 3-4 sao, tour). Cao cấp: 12-20 triệu (resort 5 sao, VinWonders). Vé máy bay khứ hồi SGN-PQC: 1.5-3 triệu.',
 'chi phí,ngân sách,phú quốc',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Ẩm thực Hà Giang đặc sắc',
 'cuisine', 'Hà Giang',
 'Thắng cố - món ăn truyền thống người Mông. Bánh tam giác mạch - đặc sản mùa thu. Thịt trâu gác bếp - đặc sản cao nguyên. Rượu ngô - thức uống truyền thống.',
 'ẩm thực,hà giang,đặc sản',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Kinh nghiệm du lịch Hội An',
 'tips', 'Hội An',
 'Nên đi phố cổ buổi tối để ngắm đèn lồng. Thuê xe đạp khám phá làng gốm Thanh Hà. Mua vé tham quan phố cổ 120.000đ (5 điểm). Tránh mùa mưa bão tháng 9-12.',
 'kinh nghiệm,hội an,tips',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Lịch trình Phú Quốc 3 ngày 2 đêm gia đình',
 'itinerary', 'Phú Quốc',
 'Ngày 1: Đáp sân bay, nhận phòng, Grand World buổi chiều, chợ đêm Dinh Cậu. Ngày 2: Bãi Sao sáng, VinWonders cả ngày. Ngày 3: Nhà tù Phú Quốc, mua quà, ra sân bay.',
 'lịch trình,phú quốc,gia đình,3 ngày 2 đêm',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Lịch trình Đà Lạt 2 ngày 1 đêm cặp đôi',
 'itinerary', 'Đà Lạt',
 'Ngày 1: Hồ Xuân Hương, Dinh Bảo Đại, Thung lũng Tình Yêu, chợ đêm. Ngày 2: Langbiang sáng sớm, cafe view đẹp, về.',
 'lịch trình,đà lạt,cặp đôi,2 ngày 1 đêm',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Phương tiện di chuyển Hà Giang',
 'transport', 'Hà Giang',
 'Từ Hà Nội: xe khách giường nằm 8-10 tiếng (250-350k). Thuê xe máy tại Hà Giang: 150-200k/ngày. Tour xe ô tô 3 ngày: 2-3 triệu/người. Lưu ý: đèo dốc, cần kinh nghiệm lái xe.',
 'di chuyển,hà giang,xe máy',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Điểm đến theo sở thích biển',
 'recommendation', NULL,
 'Biển đẹp: Phú Quốc, Nha Trang, Quy Nhon, Phú Yên. Biển yên tĩnh: Côn Đảo, Bình Ba. Biển gần HCM: Vũng Tàu, Mũi Né.',
 'tư vấn,biển,sở thích',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Điểm đến theo sở thích núi',
 'recommendation', NULL,
 'Núi cao: Fansipan Sa Pa, Langbiang Đà Lạt. Trekking: Hà Giang, Pu Luong. Ruộng bậc thang: Mù Cang Chải, Hoàng Su Phì.',
 'tư vấn,núi,sở thích',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Điểm đến phù hợp ngân sách thấp',
 'recommendation', NULL,
 'Ngân sách dưới 3 triệu: Đà Lạt, Ninh Bình, Vũng Tàu. 3-5 triệu: Hội An, Nha Trang, Sa Pa. Trên 5 triệu: Phú Quốc, Đà Nẵng-Hội An combo.',
 'tư vấn,ngân sách,điểm đến',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

-- ── Từ File 2 (bổ sung - không trùng với File 1) ─────────────────────────────
('Visa và nhập cảnh Việt Nam',
 'visa', NULL,
 'Công dân ASEAN được miễn visa 14-30 ngày. Châu Âu, Mỹ, Úc cần xin e-visa. Hộ chiếu còn hạn ít nhất 6 tháng. Khai báo hải quan điện tử khi nhập cảnh.',
 'visa,nhập cảnh,hộ chiếu,e-visa',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Thời tiết Đà Nẵng theo mùa',
 'weather', 'Đà Nẵng',
 'Mùa khô (tháng 2-8): nắng đẹp, thích hợp biển và Bà Nà Hills. Mùa mưa (tháng 9-12): mưa rào ngắn, giá dịch vụ thấp hơn. Nhiệt độ trung bình 25-33°C. Tránh đi biển khi có bão từ tháng 10.',
 'đà nẵng,thời tiết,mùa khô,mùa mưa',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Ẩm thực Phú Quốc nên thử',
 'cuisine', 'Phú Quốc',
 'Gỏi cá trích, nhum biển nướng mỡ hành, bún kèn, bún quậy Kiến Xây. Hải sản tươi tại Dương Đông và bãi Khem. Nước mắm Phú Quốc là đặc sản nổi tiếng. Giá hải sản dao động 150.000-500.000đ/kg.',
 'phú quốc,ẩm thực,hải sản,đặc sản',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Lưu ý khi trek Sa Pa',
 'tips', 'Sa Pa',
 'Mang giày chống trượt, áo khoác vì nhiệt độ có thể xuống 5°C. Thuê porter nếu mang hành lý nặng (200.000-300.000đ/ngày). Đặt homestay trước mùa cao điểm tháng 9-11. Cần giấy phép leo núi Fansipan nếu trek.',
 'sa pa,trek,fansipan,lưu ý',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Phí tham quan phố cổ Hội An',
 'pricing', 'Hội An',
 'Vé tham quan 120.000đ/người, sử dụng trong 24 giờ cho 5 điểm di tích. Miễn phí phố đi bộ sau 21h hàng ngày. Phí đèn hoa đăng: 20.000-50.000đ/chiếc. Nên thuê xe đạp 30.000đ/ngày.',
 'hội an,vé,phí,phố cổ',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Du thuyền Hạ Long chọn tàu nào?',
 'tips', 'Hạ Long',
 'Tàu 3-4 sao: 1.200.000-2.500.000đ/người (1 ngày). Tàu 5 sao: 3.500.000-8.000.000đ (2N1Đ). Nên chọn tàu có giấy phép UBND Quảng Ninh. Tàu nhỏ 20-30 khách trải nghiệm tốt hơn tàu lớn.',
 'hạ long,du thuyền,tàu,giá',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Di chuyển giữa các thành phố du lịch',
 'transport', NULL,
 'Hà Nội - Đà Nẵng: bay 1h15 (~1.500.000đ) hoặc tàu SE (~700.000đ). Đà Nẵng - Hội An: xe bus 30 phút (30.000đ). Nha Trang - Đà Lạt: xe limousine 3-4h (250.000đ). Đặt vé sớm dịp lễ 30/4, 2/9.',
 'di chuyển,xe bus,máy bay,tàu hỏa',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14'),

('Mùa lúa chín Sa Pa khi nào?',
 'weather', 'Sa Pa',
 'Ruộng bậc thang chuyển vàng cuối tháng 9 đến đầu tháng 11. Mùa xuân (tháng 3-5) ruộng nước phản chiếu bầu trời rất đẹp. Tránh tháng 7-8 vì mưa nhiều, sương mù dày che khuất view.',
 'sa pa,ruộng bậc thang,mùa lúa chín,thời tiết',
 '2026-06-03 14:40:14', '2026-06-03 14:40:14');


-- =============================================================================
-- 10. SEED DATA - CHAT LOGS (giữ nguyên từ File 1)
-- =============================================================================
INSERT INTO chat_logs (user_id, user_name, message, response, intent, destination, created_at) VALUES
(1, 'Admin',
 'Lên lịch trình đi Phú Quốc 3 ngày 2 đêm cho nhóm bạn, ngân sách Cao cấp, sở thích Biển',
 '✨ Lịch trình Phú Quốc - 3 ngày 2 đêm (Nhóm: nhóm bạn). Ngày 1: Đáp sân bay, nhận phòng, Grand World buổi chiều, chợ đêm Dinh Cậu. Ngày 2: Bãi Sao sáng, VinWonders cả ngày. Ngày 3: Nhà tù Phú Quốc, mua quà, ra sân bay. 💡 Chi phí dự kiến: 4.000.000 - 15.000.000 VNĐ/người',
 'itinerary', 'Phú Quốc', '2026-06-03 14:59:16'),

(2, 'Nguyễn Văn A',
 'tôi đi biển ở đâu đẹp',
 '🔍 Dựa trên Knowledge Base (RAG): Biển đẹp: Phú Quốc, Nha Trang, Quy Nhon, Phú Yên. Biển yên tĩnh: Côn Đảo, Bình Ba. Biển gần HCM: Vũng Tàu, Mũi Né.',
 'faq_info', NULL, '2026-06-03 15:01:05'),

(2, 'Nguyễn Văn A',
 'có khách sạn nào gần giá rẻ ko',
 '🏨 Khách sạn & Homestay gợi ý: Dalat Palace Heritage Hotel (hotel) - Đà Lạt ⭐ 4.8 | 💰 2.500.000 VNĐ/đêm. Homestay The Kupid (homestay) - Đà Lạt ⭐ 4.5 | 💰 600.000 VNĐ/đêm.',
 'service_search', NULL, '2026-06-03 15:01:28'),

(2, 'Nguyễn Văn A',
 'khách sạn ở phú quốc nha',
 '🏨 Khách sạn & Homestay gợi ý: JW Marriott Phu Quoc (resort) - Phú Quốc ⭐ 4.9 | 💰 8.500.000 VNĐ/đêm. Homestay Mango Bay (homestay) - Phú Quốc ⭐ 4.3 | 💰 800.000 VNĐ/đêm.',
 'service_search', 'Phú Quốc', '2026-06-03 15:01:49'),

(1, 'Admin',
 'Cho tôi biết thông tin chi tiết về Hà Giang',
 '🔍 Dựa trên Knowledge Base (RAG): **Ẩm thực Hà Giang đặc sắc** - Thắng cố, bánh tam giác mạch, thịt trâu gác bếp, rượu ngô.',
 'faq_info', 'Hà Giang', '2026-06-03 15:05:52'),

(3, 'Khách',
 'Cho tôi biết thông tin chi tiết về Đà Lạt',
 '🔍 Dựa trên Knowledge Base (RAG): **Thời tiết Đà Lạt theo mùa** - Đà Lạt có khí hậu mát mẻ quanh năm. Mùa khô (tháng 11-3): nắng đẹp, hoa dã quỳ nở rộ. Mùa mưa (tháng 4-10): mưa chiều, sương mù.',
 'faq_info', 'Đà Lạt', '2026-06-06 07:37:59');


-- =============================================================================
-- 11. SEED DATA - POPULAR QUERIES (giữ từ File 1)
-- =============================================================================
INSERT INTO popular_queries (query_text, count, intent) VALUES
('Cho tôi biết thông tin chi tiết về Đà Lạt',            2, 'faq_info'),
('Cho tôi biết thông tin chi tiết về Hà Giang',           1, 'faq_info'),
('khách sạn ở phú quốc nha',                              1, 'service_search'),
('có khách sạn nào gần giá rẻ ko',                        1, 'service_search'),
('tôi đi biển ở đâu đẹp',                                 1, 'faq_info'),
('Lên lịch trình đi Phú Quốc 3 ngày 2 đêm cho nhóm bạn', 1, 'itinerary');