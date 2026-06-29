-- ============================================================
-- PDTrip AI — [Re-import KB] Bảng restaurants + foods (T-038)
-- restaurants.json / foods.json trước đây bị nhét vào knowledge_entries dạng
-- text → mất cấu trúc. Tạo bảng riêng để structured fast-path "nhà hàng / món ăn"
-- query trực tiếp + giữ liên kết foods.where_to_eat → restaurants.id.
--
-- Idempotent (MIG-04): CREATE TABLE IF NOT EXISTS, không sửa schema cũ.
-- ============================================================

BEGIN;

-- ── restaurants (nhà hàng / quán ăn — cấu trúc) ──────────────────────────────
-- PK = id GỐC trong restaurants.json (để foods.where_to_eat khớp đúng).
-- destination_id = uuid5(slug) thống nhất với các bảng khác (KHÔNG dùng city_id
-- gốc vì destinations dùng uuid5, không dùng id trong city.json).
CREATE TABLE IF NOT EXISTS restaurants (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    type           VARCHAR(50),
    address        TEXT,
    hours          VARCHAR(200),
    price_range    VARCHAR(100),
    specialties    TEXT[],
    description    TEXT,
    tips           TEXT,
    rating         DECIMAL(3,2),
    must_try       BOOLEAN     DEFAULT FALSE,
    -- provenance (đồng bộ với 33_migration_provenance)
    data_source    TEXT,
    source_url     TEXT,
    verified       BOOLEAN     DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_restaurants_dest ON restaurants(destination_id);

DROP TRIGGER IF EXISTS trg_restaurants_updated ON restaurants;
CREATE TRIGGER trg_restaurants_updated
    BEFORE UPDATE ON restaurants
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

-- ── foods (đặc sản / món ăn) ─────────────────────────────────────────────────
-- where_to_eat: mảng UUID trỏ tới restaurants.id (không đặt FK cho ARRAY).
-- UNIQUE(destination_id, name) để seed idempotent.
CREATE TABLE IF NOT EXISTS foods (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    local_name     VARCHAR(200),
    category       VARCHAR(50),
    description    TEXT,
    price_range    VARCHAR(100),
    must_try       BOOLEAN     DEFAULT FALSE,
    vegetarian     BOOLEAN     DEFAULT FALSE,
    tags           TEXT[],
    where_to_eat   UUID[],
    data_source    TEXT,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (destination_id, name)
);
CREATE INDEX IF NOT EXISTS idx_foods_dest ON foods(destination_id);

DROP TRIGGER IF EXISTS trg_foods_updated ON foods;
CREATE TRIGGER trg_foods_updated
    BEFORE UPDATE ON foods
    FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at();

COMMIT;

-- Kiểm tra:
-- \d restaurants
-- \d foods
