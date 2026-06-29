-- ============================================================
-- PDTrip AI — Migration: KB → SQL (T-020)
-- Schema đích để chứa toàn bộ dữ liệu knowledge-base trong PostgreSQL.
--
-- Rule: .agent/rules/AGENT_RULES_SQL_MIGRATION.md
--   MIG-04 — không phá schema/seed cũ: chỉ ADD COLUMN IF NOT EXISTS /
--            CREATE TABLE IF NOT EXISTS, không sửa 02/03_schema_*.sql.
--   MIG-02 — idempotent: chạy lại nhiều lần phải cho cùng kết quả.
--
-- Bao gồm:
--   1. knowledge_entries.city_slug (route theo tỉnh không cần destination_id)
--   2. Convention chuẩn hóa knowledge_entries.source
--   3. Bảng itineraries (lịch trình mẫu KB)
--   4. Bảng itinerary_items (chi tiết từng ngày của lịch trình)
--   5. Bảng config: intent_patterns + locations_alias
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1. knowledge_entries.city_slug
-- Cho phép route entry theo tỉnh/thành (city_slug) độc lập với
-- destination_id — FAQ/tip/experiences có thể không gắn 1 destination cụ thể.
-- ------------------------------------------------------------
ALTER TABLE knowledge_entries ADD COLUMN IF NOT EXISTS city_slug VARCHAR(80);
CREATE INDEX IF NOT EXISTS idx_knowledge_city_slug ON knowledge_entries(city_slug);

-- ------------------------------------------------------------
-- 2. Convention cho knowledge_entries.source (MIG-03)
-- Mỗi loại thông tin 1 nguồn rõ ràng để tránh chunk trùng trong vector store:
--   kb_md_faq          — sinh từ <tỉnh>/faq.md
--   kb_md_experiences  — sinh từ <tỉnh>/experiences.md
--   kb_json_<type>     — sinh từ <tỉnh>/<type>.json (vd kb_json_food)
-- (Cột source VARCHAR(100) đã có sẵn — chỉ ghi rõ quy ước bằng COMMENT.)
-- ------------------------------------------------------------
COMMENT ON COLUMN knowledge_entries.source IS
    'Nguồn entry. Convention migration KB→SQL: kb_md_faq | kb_md_experiences | kb_json_<type> (vd kb_json_food). Xem AGENT_RULES_SQL_MIGRATION MIG-03.';

-- ------------------------------------------------------------
-- 3. itineraries — lịch trình mẫu của KB (không thuộc user)
-- trip_plans.user_id là NOT NULL → không chứa được lịch trình mẫu KB,
-- nên cần bảng riêng. Dữ liệu nạp ở T-025 từ <tỉnh>/itineraries.json.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS itineraries (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID        REFERENCES destinations(id) ON DELETE SET NULL,
    city_slug     VARCHAR(80),
    title         VARCHAR(300) NOT NULL,
    duration_days SMALLINT     CHECK (duration_days IS NULL OR duration_days >= 1),
    group_type    VARCHAR(50)
                  CHECK (group_type IS NULL OR group_type IN ('solo','couple','family','group')),
    budget_low    INT          CHECK (budget_low  IS NULL OR budget_low  >= 0),
    budget_high   INT          CHECK (budget_high IS NULL OR budget_high >= 0),
    CHECK (budget_high IS NULL OR budget_low IS NULL OR budget_high >= budget_low),
    description   TEXT,
    tags          TEXT[]       DEFAULT '{}',
    source        VARCHAR(100),            -- kb_json_itineraries
    is_active     BOOLEAN      DEFAULT TRUE,
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_itineraries_dest      ON itineraries(destination_id);
CREATE INDEX IF NOT EXISTS idx_itineraries_city      ON itineraries(city_slug);
CREATE INDEX IF NOT EXISTS idx_itineraries_active    ON itineraries(is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_itineraries_tags      ON itineraries USING GIN(tags);

-- Gắn trigger updated_at (idempotent: drop trước khi tạo lại).
-- Dùng fn_set_updated_at() trực tiếp vì helper _attach_updated_at đã bị
-- DROP sau setup ban đầu (xem 05_schema_destination_view_logs.sql).
DROP TRIGGER IF EXISTS trg_itineraries_updated ON itineraries;
CREATE TRIGGER trg_itineraries_updated
    BEFORE UPDATE ON itineraries
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ------------------------------------------------------------
-- 4. itinerary_items — chi tiết từng hoạt động trong itinerary
-- ref_type/ref_id là tham chiếu đa hình tới locations/hotels/tours/tickets.
-- KHÔNG đặt FK cứng (đa hình); T-025 phải map ref_id tới UUID có thật (RULE-11).
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS itinerary_items (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    itinerary_id  UUID         NOT NULL REFERENCES itineraries(id) ON DELETE CASCADE,
    day_no        SMALLINT     NOT NULL CHECK (day_no >= 1),
    order_no      SMALLINT     DEFAULT 0,
    time_slot     VARCHAR(50),             -- 'morning','afternoon','evening' hoặc '08:00-10:00'
    title         VARCHAR(300),
    description   TEXT,
    ref_type      VARCHAR(20)
                  CHECK (ref_type IS NULL OR ref_type IN ('location','hotel','tour','ticket','transport')),
    ref_id        UUID,
    created_at    TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_itinerary_items_itin ON itinerary_items(itinerary_id, day_no, order_no);

-- ------------------------------------------------------------
-- 5a. intent_patterns — keyword nhận diện intent (admin sửa không cần deploy)
-- Nguồn nạp: app/data/intent_patterns.json (T-026).
-- nlp_preprocessor đọc lại qua reload sau khi admin sửa.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS intent_patterns (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    intent      VARCHAR(50)  NOT NULL,    -- 'find_hotel','plan_trip','ask_food'...
    keyword     VARCHAR(200) NOT NULL,
    weight      SMALLINT     DEFAULT 1 CHECK (weight >= 0),
    is_active   BOOLEAN      DEFAULT TRUE,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  DEFAULT NOW(),
    UNIQUE (intent, keyword)
);
CREATE INDEX IF NOT EXISTS idx_intent_patterns_intent ON intent_patterns(intent);
CREATE INDEX IF NOT EXISTS idx_intent_patterns_active ON intent_patterns(is_active) WHERE is_active = TRUE;

DROP TRIGGER IF EXISTS trg_intent_patterns_updated ON intent_patterns;
CREATE TRIGGER trg_intent_patterns_updated
    BEFORE UPDATE ON intent_patterns
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ------------------------------------------------------------
-- 5b. locations_alias — map tên hành chính cũ → slug mới
-- Nguồn nạp: city_slug_alias.json / ward_alias_index.json /
--            province_old_to_new.json (T-026). Đối chiếu admin TA-013 (city-mapping).
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS locations_alias (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    old_name    VARCHAR(200) NOT NULL,    -- tên cũ / biến thể (có/không dấu)
    new_slug    VARCHAR(80)  NOT NULL,    -- slug đích (vd 'an-giang-phu-quoc')
    level       VARCHAR(20)  NOT NULL
                CHECK (level IN ('ward','district','province')),
    is_active   BOOLEAN      DEFAULT TRUE,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    UNIQUE (old_name, level)
);
CREATE INDEX IF NOT EXISTS idx_locations_alias_slug  ON locations_alias(new_slug);
CREATE INDEX IF NOT EXISTS idx_locations_alias_level ON locations_alias(level);

COMMIT;

-- ============================================================
-- DoD (T-020):
--   [x] CREATE TABLE IF NOT EXISTS + ALTER ADD COLUMN IF NOT EXISTS (MIG-04)
--   [x] itineraries / itinerary_items + knowledge_entries.city_slug
--   [x] config tables intent_patterns + locations_alias
--   [x] idempotent — chạy lại không lỗi, không nhân đôi (DROP TRIGGER IF EXISTS)
-- ============================================================
