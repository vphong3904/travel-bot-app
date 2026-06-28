-- ============================================================
-- PDTrip AI – Schema: TRAVEL
-- categories · destinations · locations · hotels · tours ·
-- tickets · transport_options · destination_events ·
-- shopping_places · trip_plans · trip_plan_items
-- ============================================================
-- THỨ TỰ TẠO (phụ thuộc FK):
--   categories → destinations → destination_categories
--   destinations → locations → tickets / trip_plan_items
--   destinations → hotels / tours / transport_options /
--                  destination_events / shopping_places
--   users → trip_plans → trip_plan_items
-- ============================================================


-- ============================================================
-- [TRAVEL] CATEGORIES
-- Phân loại điểm đến: biển, núi, nghỉ dưỡng, khám phá…
-- ============================================================
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


-- ============================================================
-- [TRAVEL] DESTINATIONS
-- Điểm đến du lịch (Đà Lạt, Phú Quốc, Hà Giang…)
-- slug = city_slug từ knowledge-base (vd: lam-dong-da-lat)
-- ============================================================
CREATE TABLE destinations (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    name        VARCHAR(200) NOT NULL,
    slug        VARCHAR(100) UNIQUE,          -- FIX: thêm slug, nullable cho seed cũ
    province    VARCHAR(100),
    region      VARCHAR(50)
                CHECK (region IN (
                    'Miền Bắc', 'Miền Trung', 'Miền Nam', 'Tây Nguyên',
                    -- Mở rộng theo thực tế seed data
                    'Đồng bằng sông Hồng', 'Đồng bằng sông Cửu Long',
                    'Duyên hải Nam Trung Bộ và Tây Nguyên',
                    'Đông Bắc', 'Tây Bắc'
                )),
    description TEXT,
    best_season VARCHAR(200),
    best_months SMALLINT[],      -- tháng đẹp nhất, vd: ARRAY[11,12,1,2,3,4]
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


-- ============================================================
-- [TRAVEL] DESTINATION CATEGORIES (many-to-many)
-- ============================================================
CREATE TABLE destination_categories (
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    category_id    UUID NOT NULL REFERENCES categories(id)   ON DELETE CASCADE,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (destination_id, category_id)
);
CREATE INDEX idx_dest_cat_dest ON destination_categories(destination_id);
CREATE INDEX idx_dest_cat_cat  ON destination_categories(category_id);


-- ============================================================
-- [TRAVEL] LOCATIONS
-- Điểm tham quan cụ thể bên trong destination
-- (chùa, thác, bãi biển, bảo tàng…)
-- FIX: bảng này PHẢI tạo trước tickets + trip_plan_items
-- vì cả 2 đều có FK location_id → locations(id)
-- ============================================================
CREATE TABLE locations (
    id           UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID        REFERENCES destinations(id) ON DELETE CASCADE,
    name         VARCHAR(200) NOT NULL,
    type         VARCHAR(50),           -- 'beach','temple','waterfall','museum'…
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
    created_at   TIMESTAMPTZ  DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_locations_dest ON locations(destination_id);
CREATE INDEX idx_locations_type ON locations(type);
SELECT _attach_updated_at('locations');


-- ============================================================
-- [TRAVEL] HOTELS
-- ============================================================
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
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_hotels_dest  ON hotels(destination_id);
CREATE INDEX idx_hotels_price ON hotels(price_per_night);
CREATE INDEX idx_hotels_stars ON hotels(stars);
CREATE INDEX idx_hotels_fts   ON hotels
    USING GIN(to_tsvector('simple', name || ' ' || COALESCE(address,'')));
SELECT _attach_updated_at('hotels');


-- ============================================================
-- [TRAVEL] TOURS
-- ============================================================
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
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_tours_dest  ON tours(destination_id);
CREATE INDEX idx_tours_price ON tours(price);
CREATE INDEX idx_tours_fts   ON tours
    USING GIN(to_tsvector('simple', name || ' ' || COALESCE(description,'')));
SELECT _attach_updated_at('tours');


-- ============================================================
-- [TRAVEL] TICKETS
-- Vé tham quan — location_id là optional (SET NULL nếu location bị xoá)
-- ============================================================
CREATE TABLE tickets (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    location_id    UUID         REFERENCES locations(id) ON DELETE SET NULL,
    name           VARCHAR(200) NOT NULL,
    price_adult    INT          CHECK (price_adult >= 0),
    price_child    INT          CHECK (price_child >= 0),
    description    TEXT,
    hours          VARCHAR(200),
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_tickets_dest     ON tickets(destination_id);
CREATE INDEX idx_tickets_location ON tickets(location_id);


-- ============================================================
-- [TRAVEL] TRANSPORT OPTIONS
-- Phương tiện di chuyển đến / nội đô
-- ============================================================
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


-- ============================================================
-- [TRAVEL] DESTINATION EVENTS
-- Lễ hội, sự kiện theo mùa / hàng năm
-- ============================================================
CREATE TABLE destination_events (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    event_date     VARCHAR(100),
    location_text  TEXT,
    cost           VARCHAR(100),
    description    TEXT,
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_events_dest ON destination_events(destination_id);


-- ============================================================
-- [TRAVEL] SHOPPING PLACES
-- ============================================================
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
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_shopping_dest ON shopping_places(destination_id);


-- ============================================================
-- [TRAVEL] USER FAVORITES
-- ============================================================
CREATE TABLE user_favorites (
    user_id        UUID NOT NULL REFERENCES users(id)        ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, destination_id)
);
CREATE INDEX idx_fav_dest ON user_favorites(destination_id);
CREATE INDEX idx_fav_user ON user_favorites(user_id);

-- Trigger: favorite_count
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


-- ============================================================
-- [TRAVEL] REVIEWS
-- ============================================================
CREATE TABLE reviews (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id        UUID NOT NULL REFERENCES users(id)        ON DELETE CASCADE,
    destination_id UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    rating         INT  CHECK (rating BETWEEN 1 AND 5),
    content        TEXT,
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE
);
CREATE INDEX idx_review_dest ON reviews(destination_id);

-- Trigger: review_count + rating_avg
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


-- ============================================================
-- [TRAVEL] TRIP PLANS + ITEMS
-- location_id trong trip_plan_items là optional
-- ============================================================
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
    notes        TEXT
);
CREATE INDEX idx_trip_items_plan ON trip_plan_items(trip_plan_id, day_number);