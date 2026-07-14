-- ============================================================
-- PDTrip AI – Schema: TRAVEL
-- categories · destinations · locations · hotels · tours · tickets ·
-- transport_options · destination_events · shopping_places ·
-- restaurants · foods · user_favorites · reviews · trip_plans ·
-- trip_plan_items · destination_view_logs
-- ------------------------------------------------------------
-- Cột provenance (data_source/source_url/verified/verified_at) và image_url
-- cho content được khai báo trực tiếp tại đây (trước đây thêm bằng migration
-- 33/37/39 — nay gộp vào schema cho gọn).
-- UNIQUE chống trùng (hotels/shopping/events/transport) đặt ở bước hậu-seed
-- 31_dedupe_and_constraints.sql để không vỡ khi seed có sẵn bản trùng.
-- ============================================================

-- ── CATEGORIES ──────────────────────────────────────────────
CREATE TABLE categories (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    slug        VARCHAR(100) NOT NULL UNIQUE,
    icon        VARCHAR(100),
    description TEXT,
    is_active   BOOLEAN     DEFAULT TRUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_categories_active ON categories(is_active) WHERE is_active = TRUE;
SELECT _attach_updated_at('categories');

-- ── CITIES (master list điểm đến cho dropdown/filter Admin) ─
-- Mỗi city = 1 slug (khớp destinations.slug / content_items.city_slug), đính kèm
-- tên tỉnh MỚI (34) + old_aliases (tên tỉnh cũ 63) để search. Enrich bằng
-- backend/scripts/seed_cities.py (đọc app/data/*.json).
CREATE TABLE cities (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    slug        VARCHAR(100) UNIQUE NOT NULL,
    name        VARCHAR(200) NOT NULL,
    province    VARCHAR(100),                 -- tên tỉnh MỚI (34 đơn vị)
    old_aliases TEXT[]       NOT NULL DEFAULT '{}',  -- tên tỉnh cũ (63) + không dấu
    region      VARCHAR(50),
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_cities_province ON cities(province);

-- ── DESTINATIONS (thành phố/điểm đến lớn, slug = city_slug) ─
CREATE TABLE destinations (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    name        VARCHAR(200) NOT NULL,
    slug        VARCHAR(100) UNIQUE,
    city_id     UUID         REFERENCES cities(id),  -- NULLABLE: import JSON→SQL không gãy
    province    VARCHAR(100),
    region      VARCHAR(50),   -- nhãn vùng miền (seed dùng nhiều cách gọi, không ràng buộc CHECK)
    description TEXT,
    best_season VARCHAR(200),
    best_months SMALLINT[],
    weather     TEXT,
    cuisine     TEXT,
    budget_low  INT          CHECK (budget_low >= 0),
    budget_high INT          CHECK (budget_high >= 0),
    CHECK (budget_high IS NULL OR budget_high >= budget_low),
    image_url   TEXT,
    special     TEXT,
    -- Stats / social
    rating_avg     DECIMAL(2,1) DEFAULT 0,
    review_count   INT          DEFAULT 0,
    favorite_count INT          DEFAULT 0,
    view_count     INT          DEFAULT 0,
    -- Provenance
    data_source TEXT,
    source_url  TEXT,
    verified    BOOLEAN      DEFAULT FALSE,
    verified_at TIMESTAMPTZ,
    is_active   BOOLEAN      DEFAULT TRUE,
    created_at  TIMESTAMPTZ  DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_dest_region   ON destinations(region);
CREATE INDEX idx_dest_province ON destinations(province);
CREATE INDEX idx_dest_budget   ON destinations(budget_low, budget_high);
CREATE INDEX idx_dest_active   ON destinations(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_dest_fts      ON destinations
    USING GIN(to_tsvector('simple',
        name || ' ' || COALESCE(province,'') || ' ' || COALESCE(description,'')
    ));
SELECT _attach_updated_at('destinations');

-- ── DESTINATION CATEGORIES (m2m) ────────────────────────────
CREATE TABLE destination_categories (
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    category_id    UUID NOT NULL REFERENCES categories(id)   ON DELETE CASCADE,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (destination_id, category_id)
);
CREATE INDEX idx_dest_cat_dest ON destination_categories(destination_id);
CREATE INDEX idx_dest_cat_cat  ON destination_categories(category_id);

-- ── LOCATIONS (điểm tham quan cụ thể trong destination) ─────
-- Phải tạo trước tickets + trip_plan_items (cả 2 FK location_id).
CREATE TABLE locations (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         REFERENCES destinations(id) ON DELETE CASCADE,
    name         VARCHAR(200) NOT NULL,
    type         VARCHAR(50),
    address      TEXT,
    lat          DECIMAL(10,7),
    lng          DECIMAL(10,7),
    hours        VARCHAR(200),
    description  TEXT,
    tips         TEXT,
    image_url    TEXT,
    rating_avg   DECIMAL(3,2) DEFAULT 0,
    review_count INT          DEFAULT 0,
    verified     BOOLEAN      DEFAULT FALSE,
    -- Provenance
    data_source  TEXT,
    source_url   TEXT,
    verified_at  TIMESTAMPTZ,
    created_at   TIMESTAMPTZ  DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_locations_dest ON locations(destination_id);
CREATE INDEX idx_locations_type ON locations(type);
SELECT _attach_updated_at('locations');

-- ── HOTELS ──────────────────────────────────────────────────
CREATE TABLE hotels (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id  UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    type            VARCHAR(50)
                    CHECK (type IN ('hotel','homestay','resort','hostel','villa')),
    stars           SMALLINT     CHECK (stars BETWEEN 1 AND 5),
    price_per_night INT          CHECK (price_per_night >= 0),
    address         TEXT,
    amenities       TEXT[]       DEFAULT '{}',
    description     TEXT,
    image_url       TEXT,
    rating          DECIMAL(3,2) DEFAULT 0,
    data_source     TEXT,
    source_url      TEXT,
    verified        BOOLEAN      DEFAULT FALSE,
    verified_at     TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_hotels_dest  ON hotels(destination_id);
CREATE INDEX idx_hotels_price ON hotels(price_per_night);
CREATE INDEX idx_hotels_stars ON hotels(stars);
CREATE INDEX idx_hotels_fts   ON hotels
    USING GIN(to_tsvector('simple', name || ' ' || COALESCE(address,'')));
SELECT _attach_updated_at('hotels');

-- ── TOURS ───────────────────────────────────────────────────
CREATE TABLE tours (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    duration       VARCHAR(50),
    price          INT          CHECK (price >= 0),
    group_size     VARCHAR(50),
    description    TEXT,
    includes       TEXT[]       DEFAULT '{}',
    excludes       TEXT[]       DEFAULT '{}',
    image_url      TEXT,
    data_source    TEXT,
    source_url     TEXT,
    verified       BOOLEAN      DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_tours_dest  ON tours(destination_id);
CREATE INDEX idx_tours_price ON tours(price);
CREATE INDEX idx_tours_fts   ON tours
    USING GIN(to_tsvector('simple', name || ' ' || COALESCE(description,'')));
SELECT _attach_updated_at('tours');

-- ── TICKETS (vé tham quan) ──────────────────────────────────
CREATE TABLE tickets (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    location_id    UUID         REFERENCES locations(id) ON DELETE SET NULL,
    name           VARCHAR(200) NOT NULL,
    price_adult    INT          CHECK (price_adult >= 0),
    price_child    INT          CHECK (price_child >= 0),
    description    TEXT,
    hours          VARCHAR(200),
    image_url      TEXT,
    data_source    TEXT,
    source_url     TEXT,
    verified       BOOLEAN      DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_tickets_dest     ON tickets(destination_id);
CREATE INDEX idx_tickets_location ON tickets(location_id);

-- ── TRANSPORT OPTIONS ───────────────────────────────────────
CREATE TABLE transport_options (
    id             UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID        NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    is_local       BOOLEAN     DEFAULT FALSE,
    type           VARCHAR(50) NOT NULL,
    price_info     TEXT,
    duration       VARCHAR(50),
    provider       VARCHAR(200),
    notes          TEXT,
    created_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_transport_dest  ON transport_options(destination_id);
CREATE INDEX idx_transport_local ON transport_options(destination_id, is_local);

-- ── DESTINATION EVENTS (lễ hội/sự kiện) ─────────────────────
CREATE TABLE destination_events (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    event_date     VARCHAR(100),
    location_text  TEXT,
    cost           VARCHAR(100),
    description    TEXT,
    image_url      TEXT,
    data_source    TEXT,
    source_url     TEXT,
    verified       BOOLEAN      DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_events_dest ON destination_events(destination_id);

-- ── SHOPPING PLACES ─────────────────────────────────────────
CREATE TABLE shopping_places (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    type           VARCHAR(50)
                   CHECK (type IN ('market','mall','street','specialty_store','other')),
    items          TEXT[]       DEFAULT '{}',
    address        TEXT,
    opening_hours  VARCHAR(100),
    price_range    VARCHAR(100),
    image_url      TEXT,
    data_source    TEXT,
    source_url     TEXT,
    verified       BOOLEAN      DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_shopping_dest ON shopping_places(destination_id);

-- ── RESTAURANTS (nhà hàng/quán — cấu trúc, structured fast-path) ─
-- PK = id gốc trong restaurants.json để foods.where_to_eat trỏ đúng.
CREATE TABLE restaurants (
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
    image_url      TEXT,
    data_source    TEXT,
    source_url     TEXT,
    verified       BOOLEAN     DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_restaurants_dest ON restaurants(destination_id);
SELECT _attach_updated_at('restaurants');

-- ── FOODS (đặc sản/món ăn) ──────────────────────────────────
-- where_to_eat: mảng UUID trỏ tới restaurants.id (không đặt FK cho ARRAY).
CREATE TABLE foods (
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
    image_url      TEXT,
    data_source    TEXT,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (destination_id, name)
);
CREATE INDEX idx_foods_dest ON foods(destination_id);
SELECT _attach_updated_at('foods');

-- ── USER FAVORITES ──────────────────────────────────────────
CREATE TABLE user_favorites (
    user_id        UUID NOT NULL REFERENCES users(id)        ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, destination_id)
);
CREATE INDEX idx_fav_dest ON user_favorites(destination_id);
CREATE INDEX idx_fav_user ON user_favorites(user_id);

CREATE OR REPLACE FUNCTION increase_favorite() RETURNS TRIGGER AS $$
BEGIN
    UPDATE destinations SET favorite_count = favorite_count + 1
    WHERE id = NEW.destination_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrease_favorite() RETURNS TRIGGER AS $$
BEGIN
    UPDATE destinations SET favorite_count = GREATEST(favorite_count - 1, 0)
    WHERE id = OLD.destination_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_favorite_insert AFTER INSERT ON user_favorites
    FOR EACH ROW EXECUTE FUNCTION increase_favorite();
CREATE TRIGGER trg_favorite_delete AFTER DELETE ON user_favorites
    FOR EACH ROW EXECUTE FUNCTION decrease_favorite();

-- ── REVIEWS ─────────────────────────────────────────────────
CREATE TABLE reviews (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id        UUID NOT NULL REFERENCES users(id)        ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    rating         INT  CHECK (rating BETWEEN 1 AND 5),
    content        TEXT,
    created_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_review_dest ON reviews(destination_id);

CREATE OR REPLACE FUNCTION update_review_stats() RETURNS TRIGGER AS $$
BEGIN
    UPDATE destinations
    SET review_count = review_count + 1,
        rating_avg   = (
            SELECT COALESCE(AVG(rating), 0)
            FROM reviews WHERE destination_id = NEW.destination_id
        )
    WHERE id = NEW.destination_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_insert AFTER INSERT ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_review_stats();

-- ── TRIP PLANS + ITEMS (lịch trình của user) ────────────────
CREATE TABLE trip_plans (
    id             UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id        UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID        REFERENCES destinations(id)   ON DELETE SET NULL,
    title          VARCHAR(300),
    budget         INT         CHECK (budget >= 0),
    start_date     DATE,
    end_date       DATE,
    CHECK (end_date IS NULL OR end_date >= start_date),
    travelers      INT         DEFAULT 1 CHECK (travelers > 0),
    travel_type    VARCHAR(50)
                   CHECK (travel_type IN ('solo','couple','family','group')),
    status         VARCHAR(20) DEFAULT 'draft'
                   CHECK (status IN ('draft','saved','completed')),
    ai_generated   BOOLEAN     DEFAULT FALSE,
    -- Trước đây /trips/ai/confirm nhận estimated_cost nhưng bỏ trống khi lưu
    -- → chuyến đi đã lưu không hiện lại được chi phí ước tính.
    estimated_cost INT         CHECK (estimated_cost >= 0),
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_trips_user ON trip_plans(user_id);
CREATE INDEX idx_trips_dest ON trip_plans(destination_id);
SELECT _attach_updated_at('trip_plans');

CREATE TABLE trip_plan_items (
    id           UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    trip_plan_id UUID        NOT NULL REFERENCES trip_plans(id) ON DELETE CASCADE,
    day_number   INT         NOT NULL CHECK (day_number >= 1),
    order_in_day INT         DEFAULT 0,
    title        VARCHAR(200),
    description  TEXT,
    location_id  UUID        REFERENCES locations(id) ON DELETE SET NULL,
    start_time   TIME,
    end_time     TIME,
    CHECK (end_time IS NULL OR end_time >= start_time),
    estimated_cost INT       CHECK (estimated_cost >= 0),
    notes        TEXT,
    -- time_slot/type/ref_id/image_url: trước đây bị bỏ trống khi lưu
    -- (/trips/ai/confirm) nên mọi ảnh + buổi trong ngày + loại mục (khách
    -- sạn/quán ăn/điểm) mất vĩnh viễn sau khi lưu. ref_id KHÔNG đặt FK vì có
    -- thể trỏ hotels/restaurants/locations tuỳ `type`.
    time_slot    VARCHAR(20),
    type         VARCHAR(20) DEFAULT 'free',
    ref_id       UUID,
    image_url    TEXT
);
CREATE INDEX idx_trip_items_plan ON trip_plan_items(trip_plan_id, day_number);

-- ── DESTINATION VIEW LOGS (dedup view_count theo user + ngày) ─
CREATE TABLE destination_view_logs (
    id             SERIAL PRIMARY KEY,
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    view_date      VARCHAR(10) NOT NULL,   -- 'YYYY-MM-DD'
    created_at     TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT uq_view_per_user_day UNIQUE (user_id, destination_id, view_date)
);
CREATE INDEX idx_view_log_dest ON destination_view_logs(destination_id);

-- ── UNIQUE chống trùng (để seed_kb_to_sql ON CONFLICT hoạt động) ─
-- foods đã có UNIQUE(destination_id,name) inline; các bảng còn lại khai báo ở đây.
ALTER TABLE hotels             ADD CONSTRAINT uq_hotels_dest_name   UNIQUE (destination_id, name);
ALTER TABLE shopping_places    ADD CONSTRAINT uq_shopping_dest_name UNIQUE (destination_id, name);
ALTER TABLE destination_events ADD CONSTRAINT uq_events_dest_name   UNIQUE (destination_id, name);
-- transport: provider/duration có thể NULL → unique index với COALESCE.
CREATE UNIQUE INDEX uq_transport_dest_type_provider
    ON transport_options (destination_id, type, COALESCE(provider,''), COALESCE(duration,''));
