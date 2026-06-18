-- ============================================================
-- PDTrip AI – Database Schema (Đồ án tốt nghiệp)
-- Chatbot AI Tư Vấn Du Lịch
-- Stack: FastAPI + PostgreSQL + Qdrant + LangChain + Gemini
-- Scope: 2 người, ~4 tuần
-- ============================================================

-- DROP DATABASE IF EXISTS pdtrip_ai_db;
-- CREATE DATABASE pdtrip_ai_db;
-- \connect pdtrip_ai_db

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- UUIDv7 – time-sortable, RFC 9562 variant bits correct
-- ============================================================
CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS UUID
LANGUAGE sql
AS $$
    SELECT encode(
        set_byte(
            set_byte(
                overlay(
                    gen_random_bytes(16)
                    PLACING substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::bigint) FROM 3)
                    FROM 1 FOR 6
                ),
                6, (get_byte(gen_random_bytes(1), 0) & 15) | 112   -- version = 7
            ),
            8, (get_byte(gen_random_bytes(1), 0) & 63) | 128       -- variant = 10xx
        ),
        'hex'
    )::uuid;
$$;

-- ============================================================
-- TRIGGER: tự động cập nhật updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION _attach_updated_at(tbl TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'CREATE TRIGGER trg_%I_updated
         BEFORE UPDATE ON %I
         FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at()',
        tbl, tbl
    );
END;
$$;

-- ============================================================
-- [AUTH] USERS
-- Người dùng đăng ký sử dụng chatbot
-- ============================================================
CREATE TABLE users (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    username      VARCHAR(50)  UNIQUE NOT NULL,
    email         VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100),
    avatar_url    TEXT,
    role          VARCHAR(20)  DEFAULT 'user'
                  CHECK (role IN ('user', 'admin')),
    is_active     BOOLEAN      DEFAULT TRUE,
    is_deleted    BOOLEAN      DEFAULT FALSE,
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_users_email    ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role     ON users(role);
SELECT _attach_updated_at('users');

-- ============================================================
-- [AUTH] REFRESH TOKENS
-- Lưu refresh token cho JWT authentication
-- ============================================================
CREATE TABLE refresh_tokens (
    id         UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT        NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked    BOOLEAN     DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_reftokens_user    ON refresh_tokens(user_id);
CREATE INDEX idx_reftokens_active  ON refresh_tokens(revoked, expires_at)
    WHERE revoked = FALSE;

-- ============================================================
-- [TRAVEL] CATEGORIES
-- Phân loại điểm đến: biển, núi, nghỉ dưỡng, khám phá, văn hóa, ẩm thực…
-- ============================================================
CREATE TABLE categories (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    name        VARCHAR(100) NOT NULL UNIQUE,
    slug        VARCHAR(100) NOT NULL UNIQUE,
    icon        VARCHAR(100),
    description TEXT,
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_categories_active
    ON categories(is_active)
    WHERE is_active = TRUE;

SELECT _attach_updated_at('categories');

-- ============================================================
-- [TRAVEL] DESTINATIONS
-- Điểm đến du lịch (Đà Lạt, Phú Quốc, Hà Giang…)
-- ============================================================
-- =========================
-- DESTINATIONS TABLE
-- =========================
CREATE TABLE destinations (
    id          UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    name        VARCHAR(200) NOT NULL,
    province    VARCHAR(100),
    region      VARCHAR(50) CHECK (region IN ('Miền Bắc', 'Miền Trung', 'Miền Nam', 'Tây Nguyên')),
    description TEXT,
    best_season VARCHAR(200),
    best_months SMALLINT[],                -- tháng đẹp nhất để đi, vd: ARRAY[11,12,1,2,3,4]
    weather     TEXT,
    cuisine     TEXT,
    budget_low  INT CHECK (budget_low >= 0),
    budget_high INT CHECK (budget_high >= 0),
    CHECK (budget_high IS NULL OR budget_high >= budget_low),
    image_url   TEXT,
    special     TEXT,

    -- ranking / social stats
    rating_avg     DECIMAL(2,1) DEFAULT 0,
    review_count    INT DEFAULT 0,
    favorite_count  INT DEFAULT 0,
    view_count INT DEFAULT 0,

    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- =========================
-- INDEXES
-- =========================
CREATE INDEX idx_dest_region   ON destinations(region);
CREATE INDEX idx_dest_province ON destinations(province);
CREATE INDEX idx_dest_budget   ON destinations(budget_low, budget_high);
CREATE INDEX idx_dest_active   ON destinations(is_active) WHERE is_active = TRUE;

CREATE INDEX idx_dest_fts ON destinations
USING GIN (
    to_tsvector(
        'simple',
        name || ' ' || COALESCE(province,'') || ' ' || COALESCE(description,'')
    )
);

-- =========================
-- USER FAVORITES TABLE
-- =========================
CREATE TABLE user_favorites (
    user_id UUID NOT NULL,
    destination_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    PRIMARY KEY (user_id, destination_id),

    FOREIGN KEY (destination_id)
        REFERENCES destinations(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_fav_dest ON user_favorites(destination_id);
CREATE INDEX idx_fav_user ON user_favorites(user_id);

-- =========================
-- REVIEWS TABLE
-- =========================
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id UUID NOT NULL,
    destination_id UUID NOT NULL,

    rating INT CHECK (rating BETWEEN 1 AND 5),
    content TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    FOREIGN KEY (destination_id)
        REFERENCES destinations(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_review_dest ON reviews(destination_id);

-- =========================
-- FAVORITE COUNT TRIGGERS
-- =========================
CREATE OR REPLACE FUNCTION increase_favorite()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE destinations
    SET favorite_count = favorite_count + 1
    WHERE id = NEW.destination_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrease_favorite()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE destinations
    SET favorite_count = GREATEST(favorite_count - 1, 0)
    WHERE id = OLD.destination_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_favorite_insert
AFTER INSERT ON user_favorites
FOR EACH ROW EXECUTE FUNCTION increase_favorite();

CREATE TRIGGER trg_favorite_delete
AFTER DELETE ON user_favorites
FOR EACH ROW EXECUTE FUNCTION decrease_favorite();

-- =========================
-- REVIEW STATS TRIGGER
-- =========================
CREATE OR REPLACE FUNCTION update_review_stats()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE destinations
    SET review_count = review_count + 1,
        rating_avg = (
            SELECT COALESCE(AVG(rating), 0)
            FROM reviews
            WHERE destination_id = NEW.destination_id
        )
    WHERE id = NEW.destination_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_review_insert
AFTER INSERT ON reviews
FOR EACH ROW EXECUTE FUNCTION update_review_stats();

-- =========================
-- UPDATED_AT TRIGGER (OPTIONAL)
-- =========================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_dest_updated
BEFORE UPDATE ON destinations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ============================================================
-- [TRAVEL] DESTINATION CATEGORIES
-- Một destination có thể thuộc nhiều category
-- ============================================================
CREATE TABLE destination_categories (
    destination_id UUID NOT NULL
        REFERENCES destinations(id) ON DELETE CASCADE,

    category_id UUID NOT NULL
        REFERENCES categories(id) ON DELETE CASCADE,

    created_at TIMESTAMPTZ DEFAULT NOW(),

    PRIMARY KEY(destination_id, category_id)
);

CREATE INDEX idx_dest_cat_destination
    ON destination_categories(destination_id);

CREATE INDEX idx_dest_cat_category
    ON destination_categories(category_id);

-- ============================================================
-- [TRAVEL] LOCATIONS
-- Địa điểm cụ thể trong một destination
-- (bãi biển, chùa, núi, công viên, nhà hàng…)
-- ============================================================
CREATE TABLE locations (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    type           VARCHAR(50)
                   CHECK (type IN ('attraction','restaurant','cafe','market',
                                   'beach','mountain','temple','museum','other')),
    address        TEXT,
    lat            DECIMAL(10,7),
    lng            DECIMAL(10,7),
    hours          VARCHAR(200),
    description    TEXT,
    tips           TEXT,            -- Kinh nghiệm, lưu ý khi đến
    image_url      TEXT,
    rating_avg     DECIMAL(3,2)    DEFAULT 0,
    review_count   INT             DEFAULT 0,
    verified       BOOLEAN         DEFAULT FALSE,
    created_at     TIMESTAMPTZ     DEFAULT NOW(),
    updated_at     TIMESTAMPTZ     DEFAULT NOW()
);
CREATE INDEX idx_loc_destination ON locations(destination_id);
CREATE INDEX idx_loc_type        ON locations(type);
CREATE INDEX idx_loc_coords      ON locations(lat, lng);
CREATE INDEX idx_loc_fts         ON locations
    USING GIN(to_tsvector('simple', name || ' ' || COALESCE(address,'')));
SELECT _attach_updated_at('locations');

-- ============================================================
-- [TRAVEL] HOTELS
-- Khách sạn / Homestay / Resort
-- ============================================================
CREATE TABLE hotels (
    id              UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id  UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    type            VARCHAR(50)
                    CHECK (type IN ('hotel','homestay','resort','hostel','villa')),
    stars           SMALLINT     CHECK (stars BETWEEN 1 AND 5),
    price_per_night INT          CHECK (price_per_night >= 0),   -- VND
    address         TEXT,
    amenities       TEXT[]       DEFAULT '{}',
    description     TEXT,
    image_url       TEXT,
    rating          DECIMAL(3,2) DEFAULT 0,
    created_at      TIMESTAMPTZ  DEFAULT NOW(),
    updated_at      TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_hotels_destination ON hotels(destination_id);
CREATE INDEX idx_hotels_price       ON hotels(price_per_night);
CREATE INDEX idx_hotels_stars       ON hotels(stars);
CREATE INDEX idx_hotels_fts         ON hotels
    USING GIN(to_tsvector('simple', name || ' ' || COALESCE(address,'')));
SELECT _attach_updated_at('hotels');

-- ============================================================
-- [TRAVEL] TOURS
-- Tour du lịch trọn gói
-- ============================================================
CREATE TABLE tours (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    duration       VARCHAR(50),    -- "3N2Đ", "1 ngày"
    price          INT          CHECK (price >= 0),   -- VND/người
    group_size     VARCHAR(50),    -- "2–15 người"
    description    TEXT,
    includes       TEXT[]       DEFAULT '{}',   -- Bao gồm gì
    excludes       TEXT[]       DEFAULT '{}',   -- Không bao gồm gì
    image_url      TEXT,
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_tours_destination ON tours(destination_id);
CREATE INDEX idx_tours_price       ON tours(price);
CREATE INDEX idx_tours_fts         ON tours
    USING GIN(to_tsvector('simple', name || ' ' || COALESCE(description,'')));
SELECT _attach_updated_at('tours');

-- ============================================================
-- [TRAVEL] TICKETS
-- Vé tham quan địa điểm
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
CREATE INDEX idx_tickets_destination ON tickets(destination_id);
CREATE INDEX idx_tickets_location    ON tickets(location_id);

-- ============================================================
-- [TRAVEL] TRANSPORT OPTIONS
-- Phương tiện di chuyển đến/nội đô
-- ============================================================
CREATE TABLE transport_options (
    id             UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID        NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    is_local       BOOLEAN     DEFAULT FALSE,  -- FALSE: đến địa điểm, TRUE: nội đô
    type           VARCHAR(50) NOT NULL,       -- máy bay, xe khách, taxi, xe máy...
    price_info     TEXT,
    duration       VARCHAR(50),
    provider       VARCHAR(100),
    notes          TEXT,
    created_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_transport_dest  ON transport_options(destination_id);
CREATE INDEX idx_transport_local ON transport_options(destination_id, is_local);

-- ============================================================
-- [TRAVEL] DESTINATION EVENTS
-- Lễ hội, sự kiện tại điểm đến
-- ============================================================
CREATE TABLE destination_events (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    event_date     VARCHAR(100),   -- "Tháng 3 âm lịch", "15/8 hàng năm"
    location_text  TEXT,
    cost           VARCHAR(100),
    description    TEXT,
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_events_dest ON destination_events(destination_id);

-- ============================================================
-- [TRAVEL] SHOPPING PLACES
-- Chợ, trung tâm mua sắm, đặc sản
-- ============================================================
CREATE TABLE shopping_places (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    name           VARCHAR(200) NOT NULL,
    type           VARCHAR(50)
                   CHECK (type IN ('market','mall','street','specialty_store','other')),
    items          TEXT[]       DEFAULT '{}',   -- Hàng hóa, đặc sản nổi bật
    address        TEXT,
    opening_hours  VARCHAR(100),
    price_range    VARCHAR(100),
    created_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_shopping_dest ON shopping_places(destination_id);

-- ============================================================
-- [TRAVEL] TRIP PLANS
-- Lịch trình do AI gợi ý hoặc user tự tạo
-- ============================================================
CREATE TABLE trip_plans (
    id             UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id        UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id UUID        REFERENCES destinations(id) ON DELETE SET NULL,
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
    ai_generated   BOOLEAN     DEFAULT FALSE,   -- Lịch trình do AI tạo hay user tự tạo
    created_at     TIMESTAMPTZ DEFAULT NOW(),
    updated_at     TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_trips_user        ON trip_plans(user_id);
CREATE INDEX idx_trips_destination ON trip_plans(destination_id);
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

-- ============================================================
-- [AI] KNOWLEDGE BASE
-- Dữ liệu RAG: câu trả lời mẫu, tips, FAQ, kinh nghiệm
-- Tương ứng với: faq.json, safety.json, activities.json…
-- Bản ghi ở đây → chunk → embed → lưu vector vào Qdrant
-- ============================================================
CREATE TABLE knowledge_entries (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    title          VARCHAR(300) NOT NULL,
    category       VARCHAR(50)  NOT NULL
                   CHECK (category IN (
                       'destination',   -- Thông tin điểm đến
                       'hotel',         -- Khách sạn, lưu trú
                       'tour',          -- Tour du lịch
                       'transport',     -- Phương tiện di chuyển
                       'food',          -- Ẩm thực
                       'activity',      -- Hoạt động trải nghiệm
                       'shopping',      -- Mua sắm
                       'event',         -- Lễ hội, sự kiện
                       'safety',        -- An toàn, lưu ý
                       'faq',           -- Câu hỏi thường gặp
                       'tip'            -- Kinh nghiệm du lịch
                   )),
    destination_id UUID         REFERENCES destinations(id) ON DELETE SET NULL,
    content        TEXT         NOT NULL,
    tags           TEXT[]       DEFAULT '{}',
    source         VARCHAR(100),            -- 'faq.json', 'manual', 'crawl'...
    -- Vector được lưu ở Qdrant, id này là qdrant_point_id
    qdrant_id      UUID,
    embedding      VECTOR(768),             -- Cache local, chính vẫn ở Qdrant
    is_active      BOOLEAN      DEFAULT TRUE,
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_knowledge_category    ON knowledge_entries(category);
CREATE INDEX idx_knowledge_destination ON knowledge_entries(destination_id);
CREATE INDEX idx_knowledge_tags        ON knowledge_entries USING GIN(tags);
CREATE INDEX idx_knowledge_fts         ON knowledge_entries
    USING GIN(to_tsvector('simple', title || ' ' || content));
CREATE INDEX idx_knowledge_embedding   ON knowledge_entries
    USING hnsw(embedding vector_cosine_ops);
CREATE INDEX idx_knowledge_active      ON knowledge_entries(is_active) WHERE is_active = TRUE;
SELECT _attach_updated_at('knowledge_entries');

-- ============================================================
-- [AI] EMBEDDING JOBS
-- Queue async để embed knowledge_entries mới hoặc đã sửa
-- Worker Python đọc bảng này → gọi bge-m3 → upsert Qdrant
-- ============================================================
CREATE TABLE embedding_jobs (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    entity_type VARCHAR(50) DEFAULT 'knowledge_entry',
    entity_id   UUID        NOT NULL,
    status      VARCHAR(20) DEFAULT 'pending'
                CHECK (status IN ('pending','processing','done','failed')),
    error       TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_embjobs_pending ON embedding_jobs(status, created_at)
    WHERE status IN ('pending','processing');
SELECT _attach_updated_at('embedding_jobs');

-- ============================================================
-- [AI] PROMPT TEMPLATES
-- Quản lý system prompt theo version (admin thay đổi không cần deploy lại)
-- ============================================================
CREATE TABLE prompt_templates (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    name          VARCHAR(100) UNIQUE NOT NULL,  -- 'travel_advisor', 'itinerary_planner'
    system_prompt TEXT         NOT NULL,
    version       VARCHAR(20)  DEFAULT '1.0',
    is_active     BOOLEAN      DEFAULT TRUE,
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  DEFAULT NOW()
);
SELECT _attach_updated_at('prompt_templates');

-- ============================================================
-- [AI] CHAT SESSIONS
-- Mỗi session = 1 cuộc trò chuyện với chatbot
-- ============================================================
CREATE TABLE chat_sessions (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id        UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title          VARCHAR(300),           -- Auto-generated từ tin nhắn đầu
    summary        TEXT,                   -- Tóm tắt session (sau khi kết thúc)
    model_name     VARCHAR(100) DEFAULT 'gemini-1.5-flash',
    total_messages INT          DEFAULT 0,
    total_tokens   INT          DEFAULT 0,
    pinned         BOOLEAN      DEFAULT FALSE,
    is_deleted     BOOLEAN      DEFAULT FALSE,
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_sessions_user    ON chat_sessions(user_id);
CREATE INDEX idx_sessions_updated ON chat_sessions(user_id, updated_at DESC)
    WHERE is_deleted = FALSE;
CREATE INDEX idx_sessions_pinned  ON chat_sessions(user_id, pinned)
    WHERE pinned = TRUE;
SELECT _attach_updated_at('chat_sessions');

-- ============================================================
-- [AI] CHAT MESSAGES
-- Tin nhắn trong từng session (user + assistant)
-- sources: mảng knowledge_entry id được RAG retrieve
-- ============================================================
CREATE TABLE chat_messages (
    id                UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    session_id        UUID        NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    role              VARCHAR(20) NOT NULL CHECK (role IN ('user','assistant','system')),
    content           TEXT        NOT NULL,
    -- RAG metadata
    sources           JSONB       DEFAULT '[]',   -- [{id, title, score}]
    intent            VARCHAR(100),               -- 'ask_destination', 'plan_trip', 'find_hotel'...
    -- Performance
    prompt_tokens     INT         DEFAULT 0,
    completion_tokens INT         DEFAULT 0,
    latency_ms        INT,
    -- User feedback
    feedback          SMALLINT    CHECK (feedback IN (-1, 1)),  -- thumbs down/up
    created_at        TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_messages_session ON chat_messages(session_id, created_at);
CREATE INDEX idx_messages_intent  ON chat_messages(intent);

-- Trigger: tăng counter + cập nhật updated_at của session
CREATE OR REPLACE FUNCTION fn_update_session_on_message()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    UPDATE chat_sessions
    SET updated_at     = NOW(),
        total_messages = total_messages + 1,
        total_tokens   = total_tokens
                         + COALESCE(NEW.prompt_tokens, 0)
                         + COALESCE(NEW.completion_tokens, 0)
    WHERE id = NEW.session_id;
    RETURN NEW;
END;
$$;
CREATE TRIGGER trg_update_session_on_message
    AFTER INSERT ON chat_messages
    FOR EACH ROW EXECUTE FUNCTION fn_update_session_on_message();

-- ============================================================
-- [AI] CONVERSATION MEMORY
-- Thông tin AI nhớ về user qua các session:
-- sở thích, ngân sách hay dùng, điểm đến đã hỏi…
-- ============================================================
CREATE TABLE conversation_memory (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    memory_type VARCHAR(50) NOT NULL
                CHECK (memory_type IN (
                    'preference',    -- sở thích (biển, núi, nghỉ dưỡng...)
                    'budget',        -- ngân sách thường dùng
                    'visited',       -- điểm đến đã đi
                    'interested',    -- điểm đến đang quan tâm
                    'travel_style'   -- cặp đôi, gia đình, solo...
                )),
    content     JSONB       NOT NULL DEFAULT '{}',
    confidence  DECIMAL(4,3) DEFAULT 0.8,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_memory_user ON conversation_memory(user_id);
CREATE INDEX idx_memory_type ON conversation_memory(user_id, memory_type);
SELECT _attach_updated_at('conversation_memory');

-- ============================================================
-- [ANALYTICS] SEARCH HISTORY
-- Lịch sử tìm kiếm / câu hỏi của user
-- Phục vụ: báo cáo "câu hỏi phổ biến" cho admin
-- ============================================================
CREATE TABLE search_history (
    id           UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id      UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    keyword      VARCHAR(300) NOT NULL,
    intent       VARCHAR(100),
    result_count INT          DEFAULT 0,
    session_id   UUID         REFERENCES chat_sessions(id) ON DELETE SET NULL,
    created_at   TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_search_user    ON search_history(user_id);
CREATE INDEX idx_search_keyword ON search_history
    USING GIN(to_tsvector('simple', keyword));
CREATE INDEX idx_search_intent  ON search_history(intent);
CREATE INDEX idx_search_created ON search_history(created_at DESC);

-- ============================================================
-- [ANALYTICS] USER BEHAVIOR
-- Hành vi user: xem điểm đến, click khách sạn, lưu lịch trình…
-- Phục vụ: thống kê "điểm đến được quan tâm" cho admin
-- ============================================================
CREATE TABLE user_behavior (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    event_type  VARCHAR(50) NOT NULL
                CHECK (event_type IN (
                    'view_destination',
                    'view_hotel',
                    'view_tour',
                    'save_trip',
                    'feedback_positive',
                    'feedback_negative',
                    'ask_chatbot'
                )),
    entity_type VARCHAR(50),   -- 'destination', 'hotel', 'tour', 'trip_plan'
    entity_id   UUID,
    session_id  UUID        REFERENCES chat_sessions(id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_behavior_user    ON user_behavior(user_id);
CREATE INDEX idx_behavior_event   ON user_behavior(event_type);
CREATE INDEX idx_behavior_entity  ON user_behavior(entity_type, entity_id);
CREATE INDEX idx_behavior_created ON user_behavior(created_at DESC);

-- ============================================================
-- CLEANUP
-- ============================================================
DROP FUNCTION _attach_updated_at(TEXT);

-- ============================================================
-- PDTrip AI – Seed Data (Dữ liệu mẫu)
-- Chạy SAU khi đã tạo schema (pdtrip_db_schema.sql)
-- \connect pdtrip_ai_db
-- \i pdtrip_seed_data.sql
-- ============================================================

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
-- [TRAVEL] Categories — 10 loại hình du lịch phổ biến
-- ============================================================
INSERT INTO categories (id, name, slug, icon) VALUES
('c1111111-1111-1111-1111-111111111111', 'Beach',       'beach',       'beach_access'),
('c2222222-2222-2222-2222-222222222222', 'Mountain',    'mountain',    'terrain'),
('c3333333-3333-3333-3333-333333333333', 'Resort',      'resort',      'spa'),
('c4444444-4444-4444-4444-444444444444', 'Adventure',   'adventure',   'hiking'),
('c5555555-5555-5555-5555-555555555555', 'Food',        'food',        'restaurant'),
('c6666666-6666-6666-6666-666666666666', 'Culture',     'culture',     'museum'),
('c7777777-7777-7777-7777-777777777777', 'Nature',      'nature',      'forest'),
('c8888888-8888-8888-8888-888888888888', 'Photography', 'photography', 'camera'),
('c9999999-9999-9999-9999-999999999999', 'Family',      'family',      'family_restroom'),
('caaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Luxury',      'luxury',      'diamond');

-- ============================================================
-- [TRAVEL] DESTINATIONS — 5 điểm đến phổ biến
-- ============================================================
INSERT INTO destinations (id, name, province, region, description, best_season, weather, cuisine, budget_low, budget_high, image_url, special, rating_avg, review_count, view_count) VALUES
('11111111-1111-1111-1111-111111111111', 'Đà Lạt',  'Lâm Đồng',   'Tây Nguyên',
 'Thành phố ngàn hoa với khí hậu mát mẻ quanh năm, nổi tiếng với đồi chè, thác nước và kiến trúc Pháp cổ.',
 'Tháng 11–4 (mùa khô, ít mưa)',
 'Mát mẻ quanh năm, nhiệt độ 15–24°C, mùa mưa từ tháng 5–10',
 'Bánh tráng nướng, lẩu gà lá é, sữa đậu nành nóng, dâu tây, atiso',
 1500000, 4000000,
 'https://cdn.pdtrip.vn/destinations/dalat.jpg', 'Thành phố ngàn hoa, khí hậu mát mẻ quanh năm, nổi tiếng với đồi chè, thác nước và kiến trúc Pháp cổ', 4.5, 120, 5000),

('22222222-2222-2222-2222-222222222222', 'Phú Quốc', 'Kiên Giang', 'Miền Nam',
 'Đảo ngọc lớn nhất Việt Nam với bãi biển trong xanh, hải sản tươi sống và các khu nghỉ dưỡng cao cấp.',
 'Tháng 11–4 (mùa khô, biển êm)',
 'Nóng ẩm, 25–32°C, mùa mưa tháng 5–10 có bão nhẹ',
 'Hải sản, nước mắm Phú Quốc, gỏi cá trích, nhum nướng mỡ hành',
 3000000, 8000000,
 'https://cdn.pdtrip.vn/destinations/phuquoc.jpg', 'Đảo ngọc với biển xanh và resort cao cấp', 4.7, 150, 6000),

('33333333-3333-3333-3333-333333333333', 'Hà Giang', 'Hà Giang',   'Miền Bắc',
 'Vùng núi đá hùng vĩ với cung đường đèo Mã Pí Lèng, ruộng bậc thang và văn hóa dân tộc đặc sắc.',
 'Tháng 9–11 (mùa hoa tam giác mạch) hoặc Tháng 3–5',
 'Lạnh về đêm, 10–25°C, có thể có sương mù và rét đậm vào mùa đông',
 'Thắng cố, mèn mén, rượu ngô, cháo ấu tẩu, thịt trâu khô',
 1500000, 5000000,
 'https://cdn.pdtrip.vn/destinations/hagiang.jpg', 'Vùng núi đá hùng vĩ với cung đường đèo Mã Pí Lèng, cao nguyên đá Đồng Văn và văn hóa dân tộc đặc sắc', 4.3, 90, 4000),

('44444444-4444-4444-4444-444444444444', 'Hội An',  'Quảng Nam',  'Miền Trung',
 'Phố cổ di sản UNESCO với kiến trúc cổ kính, đèn lồng rực rỡ và ẩm thực đường phố nổi tiếng.',
 'Tháng 2–4 (khô, mát, ít mưa)',
 'Nóng vào hè (28–35°C), mùa mưa bão tháng 9–12',
 'Cao lầu, mì Quảng, cơm gà, bánh mì Phượng, bánh bao bánh vạc',
 1000000, 3500000,
 'https://cdn.pdtrip.vn/destinations/hoian.jpg', 'Phố cổ di sản UNESCO và lễ hội đèn lồng rực rỡ', 4.6, 110, 5500),

('55555555-5555-5555-5555-555555555555', 'Sa Pa',   'Lào Cai',    'Miền Bắc',
 'Thị trấn trong mây với ruộng bậc thang, đỉnh Fansipan và văn hóa các dân tộc H''Mông, Dao, Tày.',
 'Tháng 9–11 (lúa chín vàng) hoặc Tháng 3–5 (hoa nở)',
 'Lạnh, 10–20°C, có thể có băng giá vào tháng 12–1',
 'Thắng cố, lợn cắp nách, cá hồi Sa Pa, rau cải mèo, rượu táo mèo',
 1500000, 4500000,
 'https://cdn.pdtrip.vn/destinations/sapa.jpg', 'Thị trấn trong mây với ruộng bậc thang và đỉnh Fansipan', 4.8, 200, 7000),
('66666666-6666-6666-6666-666666666666', 'Vịnh Hạ Long', 'Quảng Ninh', 'Miền Bắc',
 'Di sản thiên nhiên thế giới với hàng nghìn đảo đá vôi nhô lên từ mặt biển xanh ngọc.',
 'Tháng 3–5 và Tháng 10–11 (ít mưa, biển êm)',
 'Mát mẻ mùa xuân/thu 20–28°C, nóng ẩm mùa hè, có bão tháng 7–9',
 'Chả mực Hạ Long, sam biển, ngán, sá sùng, bánh cuốn chả mực',
 2000000, 6000000,
 'https://cdn.pdtrip.vn/destinations/halong.jpg', 'Di sản thiên nhiên thế giới với hàng nghìn đảo đá vôi nhô lên từ mặt biển xanh ngọc', 4.9, 250, 8000),
 
('77777777-7777-7777-7777-777777777777', 'Huế', 'Thừa Thiên Huế', 'Miền Trung',
 'Cố đô triều Nguyễn với hệ thống lăng tẩm, đại nội cổ kính và sông Hương thơ mộng.',
 'Tháng 1–4 (mát, ít mưa)',
 'Mùa hè nóng 30–38°C, mùa mưa bão tháng 9–11',
 'Bún bò Huế, cơm hến, bánh bèo, bánh khoái, chè Huế',
 1200000, 3500000,
 'https://cdn.pdtrip.vn/destinations/hue.jpg', 'Cố đô triều Nguyễn với hệ thống lăng tẩm, đại nội cổ kính và sông Hương thơ mộng', 4.5, 120, 5000),
 
('88888888-8888-8888-8888-888888888888', 'Nha Trang', 'Khánh Hòa', 'Miền Trung',
 'Thành phố biển sôi động với các đảo san hô, hoạt động lặn biển và ẩm thực hải sản phong phú.',
 'Tháng 1–8 (khô, biển đẹp, ít mưa)',
 'Nóng 25–34°C quanh năm, mùa mưa tháng 9–12',
 'Bún cá, nem nướng Ninh Hòa, bánh căn, hải sản tươi sống',
 2000000, 5500000,
 'https://cdn.pdtrip.vn/destinations/nhatrang.jpg', 'Thành phố biển sôi động với các đảo san hô, hoạt động lặn biển và ẩm thực hải sản phong phú.', 4.6, 140, 6000),
 
('99999999-9999-9999-9999-999999999999', 'Mũi Né', 'Bình Thuận', 'Miền Nam',
 'Thiên đường đồi cát và lướt ván diều, nổi tiếng với Đồi Cát Bay và Suối Tiên.',
 'Tháng 11–4 (gió mạnh, thích hợp lướt ván diều)',
 'Nóng khô 26–33°C, gió mạnh quanh năm đặc trưng vùng duyên hải',
 'Hải sản nướng, bánh căn, gỏi cá mai, nước mắm Phan Thiết',
 1500000, 4000000,
 'https://cdn.pdtrip.vn/destinations/muine.jpg', 'Thiên đường đồi cát và lướt ván diều, nổi tiếng với Đồi Cát Bay và Suối Tiên.', 4.4, 100, 4500),
 
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Ninh Bình', 'Ninh Bình', 'Miền Bắc',
 'Vịnh Hạ Long trên cạn với Tam Cốc, Tràng An và quần thể hang động sông nước hữu tình.',
 'Tháng 9–11 (mùa lúa chín vàng) hoặc Tháng 1–3',
 'Mát mẻ mùa thu 22–28°C, lạnh nhẹ mùa đông, nóng ẩm mùa hè',
 'Cơm cháy, dê núi, ốc núi, rượu Kim Sơn, nem chua Yên Mạc',
 800000, 2800000,
 'https://cdn.pdtrip.vn/destinations/ninhbinh.jpg', 'Vịnh Hạ Long trên cạn với Tam Cốc, Tràng An và quần thể hang động sông nước hữu tình.', 4.7, 130, 5500);

-- ============================================================
-- [TRAVEL] DESTINATIONS — Seed dữ liệu best_months
-- Cột best_months SMALLINT[] đã được khai báo trong CREATE TABLE destinations ở trên.
-- ============================================================
UPDATE destinations SET best_months = ARRAY[11,12,1,2,3,4]  WHERE name = 'Đà Lạt';
UPDATE destinations SET best_months = ARRAY[11,12,1,2,3,4]  WHERE name = 'Phú Quốc';
UPDATE destinations SET best_months = ARRAY[9,10,11,3,4,5] WHERE name = 'Hà Giang';
UPDATE destinations SET best_months = ARRAY[2,3,4]          WHERE name = 'Hội An';
UPDATE destinations SET best_months = ARRAY[9,10,11,3,4,5] WHERE name = 'Sa Pa';
UPDATE destinations SET best_months = ARRAY[3,4,5,10,11]   WHERE name = 'Vịnh Hạ Long';
UPDATE destinations SET best_months = ARRAY[1,2,3,4]       WHERE name = 'Huế';
UPDATE destinations SET best_months = ARRAY[1,2,3,4,5,6,7,8] WHERE name = 'Nha Trang';
UPDATE destinations SET best_months = ARRAY[11,12,1,2,3,4]  WHERE name = 'Mũi Né';
UPDATE destinations SET best_months = ARRAY[9,10,11,1,2,3] WHERE name = 'Ninh Bình';

-- ============================================================
-- [TRAVEL] Destination Categories — Mỗi điểm đến có 4–5 category
-- ============================================================
 INSERT INTO destination_categories(destination_id, category_id) VALUES
('11111111-1111-1111-1111-111111111111','c2222222-2222-2222-2222-222222222222'), -- Mountain
('11111111-1111-1111-1111-111111111111','c3333333-3333-3333-3333-333333333333'), -- Resort
('11111111-1111-1111-1111-111111111111','c4444444-4444-4444-4444-444444444444'), -- Adventure
('11111111-1111-1111-1111-111111111111','c5555555-5555-5555-5555-555555555555'), -- Food
('11111111-1111-1111-1111-111111111111','c8888888-8888-8888-8888-888888888888'); -- Photography
INSERT INTO destination_categories(destination_id, category_id) VALUES
('22222222-2222-2222-2222-222222222222','c1111111-1111-1111-1111-111111111111'), -- Beach
('22222222-2222-2222-2222-222222222222','c3333333-3333-3333-3333-333333333333'), -- Resort
('22222222-2222-2222-2222-222222222222','c5555555-5555-5555-5555-555555555555'), -- Food
('22222222-2222-2222-2222-222222222222','c9999999-9999-9999-9999-999999999999'), -- Family
('22222222-2222-2222-2222-222222222222','caaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'); -- Luxury
INSERT INTO destination_categories(destination_id, category_id) VALUES
('33333333-3333-3333-3333-333333333333','c2222222-2222-2222-2222-222222222222'),
('33333333-3333-3333-3333-333333333333','c4444444-4444-4444-4444-444444444444'),
('33333333-3333-3333-3333-333333333333','c7777777-7777-7777-7777-777777777777'),
('33333333-3333-3333-3333-333333333333','c8888888-8888-8888-8888-888888888888');
INSERT INTO destination_categories(destination_id, category_id) VALUES
('44444444-4444-4444-4444-444444444444','c5555555-5555-5555-5555-555555555555'),
('44444444-4444-4444-4444-444444444444','c6666666-6666-6666-6666-666666666666'),
('44444444-4444-4444-4444-444444444444','c8888888-8888-8888-8888-888888888888'),
('44444444-4444-4444-4444-444444444444','c9999999-9999-9999-9999-999999999999');
INSERT INTO destination_categories(destination_id, category_id) VALUES
('55555555-5555-5555-5555-555555555555','c2222222-2222-2222-2222-222222222222'),
('55555555-5555-5555-5555-555555555555','c4444444-4444-4444-4444-444444444444'),
('55555555-5555-5555-5555-555555555555','c7777777-7777-7777-7777-777777777777'),
('55555555-5555-5555-5555-555555555555','c8888888-8888-8888-8888-888888888888');
INSERT INTO destination_categories(destination_id, category_id) VALUES
('66666666-6666-6666-6666-666666666666','c1111111-1111-1111-1111-111111111111'),
('66666666-6666-6666-6666-666666666666','c7777777-7777-7777-7777-777777777777'),
('66666666-6666-6666-6666-666666666666','c8888888-8888-8888-8888-888888888888'),
('66666666-6666-6666-6666-666666666666','c9999999-9999-9999-9999-999999999999');
INSERT INTO destination_categories(destination_id, category_id) VALUES
('77777777-7777-7777-7777-777777777777','c5555555-5555-5555-5555-555555555555'),
('77777777-7777-7777-7777-777777777777','c6666666-6666-6666-6666-666666666666'),
('77777777-7777-7777-7777-777777777777','c9999999-9999-9999-9999-999999999999');
INSERT INTO destination_categories(destination_id, category_id) VALUES
('88888888-8888-8888-8888-888888888888','c1111111-1111-1111-1111-111111111111'),
('88888888-8888-8888-8888-888888888888','c3333333-3333-3333-3333-333333333333'),
('88888888-8888-8888-8888-888888888888','c5555555-5555-5555-5555-555555555555'),
('88888888-8888-8888-8888-888888888888','c9999999-9999-9999-9999-999999999999');
INSERT INTO destination_categories(destination_id, category_id) VALUES
('99999999-9999-9999-9999-999999999999','c1111111-1111-1111-1111-111111111111'),
('99999999-9999-9999-9999-999999999999','c4444444-4444-4444-4444-444444444444'),
('99999999-9999-9999-9999-999999999999','c7777777-7777-7777-7777-777777777777');
INSERT INTO destination_categories(destination_id, category_id) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','c7777777-7777-7777-7777-777777777777'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','c6666666-6666-6666-6666-666666666666'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','c8888888-8888-8888-8888-888888888888'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','c9999999-9999-9999-9999-999999999999');

-- ============================================================
-- [TRAVEL] USER FAVORITES — user lưu điểm đến yêu thích
-- ============================================================
INSERT INTO user_favorites (user_id, destination_id) VALUES
-- Trần Lan thích Đà Lạt + Phú Quốc + Hội An
('11111111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111111'),
('11111111-1111-1111-1111-111111111112', '22222222-2222-2222-2222-222222222222'),
('11111111-1111-1111-1111-111111111112', '44444444-4444-4444-4444-444444444444'),

-- Minh Hiếu thích Hà Giang + Sa Pa + Hạ Long
('11111111-1111-1111-1111-111111111113', '33333333-3333-3333-3333-333333333333'),
('11111111-1111-1111-1111-111111111113', '55555555-5555-5555-5555-555555555555'),
('11111111-1111-1111-1111-111111111113', '66666666-6666-6666-6666-666666666666'),

-- Ngọc Hương thích Hội An + Huế
('11111111-1111-1111-1111-111111111114', '44444444-4444-4444-4444-444444444444'),
('11111111-1111-1111-1111-111111111114', '77777777-7777-7777-7777-777777777777'),

-- Quang Khải thích biển (Phú Quốc + Nha Trang + Mũi Né)
('11111111-1111-1111-1111-111111111115', '22222222-2222-2222-2222-222222222222'),
('11111111-1111-1111-1111-111111111115', '88888888-8888-8888-8888-888888888888'),
('11111111-1111-1111-1111-111111111115', '99999999-9999-9999-9999-999999999999');

-- ============================================================
-- [TRAVEL] REVIEWS — user đánh giá điểm đến
-- ============================================================
INSERT INTO reviews (user_id, destination_id, rating, content) VALUES

-- Đà Lạt
('22222222-2222-2222-2222-222222222222','11111111-1111-1111-1111-111111111111',5,'Không khí rất chill, đi hoài không chán'),
('44444444-4444-4444-4444-444444444444','11111111-1111-1111-1111-111111111111',4,'Đẹp nhưng hơi đông khách'),

-- Phú Quốc
('55555555-5555-5555-5555-555555555555','22222222-2222-2222-2222-222222222222',5,'Biển xanh đẹp, resort rất ok'),
('22222222-2222-2222-2222-222222222222','22222222-2222-2222-2222-222222222222',4,'Đồ ăn ngon nhưng hơi đắt'),

-- Hà Giang
('33333333-3333-3333-3333-333333333333','33333333-3333-3333-3333-333333333333',5,'Cung đường quá đẹp, đáng đi'),
('44444444-4444-4444-4444-444444444444','33333333-3333-3333-3333-333333333333',4,'Khá lạnh nhưng cảnh rất hùng vĩ'),

-- Hội An
('55555555-5555-5555-5555-555555555555','44444444-4444-4444-4444-444444444444',5,'Phố cổ rất đẹp về đêm'),
('33333333-3333-3333-3333-333333333333','44444444-4444-4444-4444-444444444444',5,'Rất nhiều góc chụp ảnh đẹp'),

-- Sa Pa
('44444444-4444-4444-4444-444444444444','55555555-5555-5555-5555-555555555555',5,'Sương mù rất đẹp, khí hậu mát'),
('22222222-2222-2222-2222-222222222222','55555555-5555-5555-5555-555555555555',4,'Đi trekking hơi mệt nhưng đáng'),

-- Hạ Long
('33333333-3333-3333-3333-333333333333','66666666-6666-6666-6666-666666666666',5,'Cảnh vịnh quá đẹp, nên đi cruise'),

-- Huế
('22222222-2222-2222-2222-222222222222','77777777-7777-7777-7777-777777777777',4,'Yên bình, nhiều di tích lịch sử'),

-- Nha Trang
('33333333-3333-3333-3333-333333333333','88888888-8888-8888-8888-888888888888',4,'Biển đẹp nhưng hơi đông du khách'),

-- Mũi Né
('55555555-5555-5555-5555-555555555555','99999999-9999-9999-9999-999999999999',5,'Đồi cát rất đặc biệt, đáng trải nghiệm');

-- ============================================================
-- [TRAVEL] LOCATIONS — địa điểm cụ thể tại từng destination
-- ============================================================
INSERT INTO locations (destination_id, name, type, address, lat, lng, hours, description, tips, rating_avg, review_count, verified) VALUES
-- Đà Lạt
('11111111-1111-1111-1111-111111111111', 'Hồ Xuân Hương', 'attraction', 'Trung tâm TP. Đà Lạt', 11.9404, 108.4421, '24/7',
 'Hồ nước nhân tạo nằm giữa trung tâm thành phố, biểu tượng của Đà Lạt.',
 'Nên đi bộ dạo quanh hồ vào sáng sớm để tránh nắng và ngắm sương mù.', 4.6, 1850, TRUE),
('11111111-1111-1111-1111-111111111111', 'Đồi chè Cầu Đất', 'attraction', 'Xã Trạm Hành, Đà Lạt', 11.8456, 108.5102, '07:00–17:00',
 'Đồn điền chè cổ xưa nhất Việt Nam với view đồi chè xanh mướt trải dài.',
 'Mang giày thể thao vì đường đồi khá dốc, nên đi vào buổi sáng để ánh sáng đẹp.', 4.8, 920, TRUE),
('11111111-1111-1111-1111-111111111111', 'Chợ Đà Lạt', 'market', 'Đường Nguyễn Thị Minh Khai, Đà Lạt', 11.9433, 108.4380, '06:00–22:00',
 'Chợ đêm sầm uất với đặc sản, đồ len, trái cây và món ăn vặt địa phương.',
 'Trả giá khi mua đồ lưu niệm, thử bánh tráng nướng và sữa đậu nành nóng.', 4.5, 2300, TRUE),
-- Phú Quốc
('22222222-2222-2222-2222-222222222222', 'Bãi Sao', 'beach', 'Xã An Thới, Phú Quốc', 10.0136, 104.0083, '24/7',
 'Bãi biển cát trắng mịn, nước biển trong xanh được mệnh danh đẹp nhất Phú Quốc.',
 'Đi sớm trước 9h để tránh đông khách, mang theo kem chống nắng.', 4.9, 3100, TRUE),
('22222222-2222-2222-2222-222222222222', 'Vinpearl Safari', 'attraction', 'Bãi Dài, Gành Dầu, Phú Quốc', 10.3722, 103.8556, '08:00–17:30',
 'Vườn thú bán hoang dã lớn nhất Việt Nam với hơn 3000 cá thể động vật.',
 'Nên dành cả ngày để tham quan, đặt vé online để được giảm giá.', 4.7, 1650, TRUE),
-- Hà Giang
('33333333-3333-3333-3333-333333333333', 'Đèo Mã Pí Lèng', 'mountain', 'Xã Pải Lủng, Mèo Vạc, Hà Giang', 23.2722, 105.3361, '24/7',
 'Một trong tứ đại đỉnh đèo Việt Nam, view nhìn xuống sông Nho Quế hùng vĩ.',
 'Cẩn thận khi lái xe vì đường đèo hẹp và nhiều cua, nên đi vào ban ngày.', 4.9, 1420, TRUE),
('33333333-3333-3333-3333-333333333333', 'Dinh thự Vua Mèo', 'museum', 'Xã Sà Phìn, Đồng Văn, Hà Giang', 23.2944, 105.1219, '07:30–17:30',
 'Kiến trúc cổ độc đáo của dòng họ Vương, vua Mèo một thời cai quản vùng cao nguyên đá.',
 'Vé vào khoảng 20.000đ, kết hợp tham quan chợ Đồng Văn gần đó.', 4.6, 780, TRUE),
-- Hội An
('44444444-4444-4444-4444-444444444444', 'Chùa Cầu', 'attraction', 'Đường Nguyễn Thị Minh Khai, Hội An', 15.8767, 108.3250, '24/7',
 'Biểu tượng của Hội An, cây cầu cổ hơn 400 năm tuổi do người Nhật xây dựng.',
 'Đi vào buổi tối để chụp ảnh đèn lồng lung linh, mua vé tham quan phố cổ tại đây.', 4.8, 2900, TRUE),
('44444444-4444-4444-4444-444444444444', 'Làng rau Trà Quế', 'attraction', 'Cẩm Hà, Hội An', 15.9050, 108.2967, '06:00–18:00',
 'Làng nghề trồng rau hữu cơ truyền thống, có thể trải nghiệm làm nông dân.',
 'Đặt tour trải nghiệm trồng rau và học nấu ăn cùng người dân địa phương.', 4.7, 540, TRUE),
-- Sa Pa
('55555555-5555-5555-5555-555555555555', 'Đỉnh Fansipan', 'mountain', 'Sa Pa, Lào Cai', 22.3033, 103.7750, '07:00–17:00',
 'Nóc nhà Đông Dương cao 3.143m, có thể lên bằng cáp treo hoặc trekking.',
 'Mặc áo ấm vì nhiệt độ trên đỉnh rất thấp, mua vé cáp treo trước để tránh chờ lâu.', 4.9, 2200, TRUE),
('55555555-5555-5555-5555-555555555555', 'Bản Cát Cát', 'attraction', 'Xã San Sả Hồ, Sa Pa', 22.3267, 103.8311, '07:00–18:00',
 'Bản làng dân tộc H''Mông cổ với ruộng bậc thang và thác nước đẹp.',
 'Đi giày thoải mái vì phải đi bộ xuống bản khá xa, có thể thuê xe ôm về.', 4.6, 1340, TRUE),
-- Hạ Long
('66666666-6666-6666-6666-666666666666', 'Hang Sửng Sốt', 'attraction', 'Đảo Bồ Hòn, Vịnh Hạ Long', 20.8736, 107.0822, '07:00–17:00',
 'Hang động lớn và đẹp nhất Vịnh Hạ Long với nhũ đá hình thù kỳ lạ.',
 'Kết hợp tour du thuyền tham quan vịnh, nên đi giày chống trượt.', 4.8, 1980, TRUE),
('66666666-6666-6666-6666-666666666666', 'Đảo Titop', 'beach', 'Vịnh Hạ Long', 20.8550, 107.0494, '07:00–16:30',
 'Đảo nhỏ với bãi biển đẹp và điểm ngắm toàn cảnh vịnh từ trên cao.',
 'Leo khoảng 100 bậc thang lên đỉnh để ngắm toàn cảnh, mang giày thể thao.', 4.7, 1340, TRUE),
-- Huế
('77777777-7777-7777-7777-777777777777', 'Đại Nội Huế', 'museum', 'Đường 23/8, TP. Huế', 16.4698, 107.5796, '07:00–17:30',
 'Hoàng thành cổ của triều Nguyễn, di sản văn hóa thế giới UNESCO.',
 'Thuê hướng dẫn viên hoặc audio guide để hiểu rõ lịch sử, nên đi vào sáng sớm tránh nắng.', 4.7, 2650, TRUE),
('77777777-7777-7777-7777-777777777777', 'Sông Hương', 'attraction', 'TP. Huế', 16.4637, 107.5909, '24/7',
 'Dòng sông thơ mộng chảy qua lòng thành phố, nổi tiếng với các tour du thuyền nghe ca Huế.',
 'Đi thuyền rồng vào buổi tối để nghe ca Huế truyền thống trên sông.', 4.6, 1120, TRUE),
-- Nha Trang
('88888888-8888-8888-8888-888888888888', 'Đảo Hòn Mun', 'beach', 'Vịnh Nha Trang', 12.1822, 109.3017, '07:00–17:00',
 'Khu bảo tồn biển với rạn san hô đa dạng, điểm lặn biển nổi tiếng nhất Nha Trang.',
 'Đặt tour lặn biển ngắm san hô vào buổi sáng khi nước trong nhất.', 4.8, 1760, TRUE),
('88888888-8888-8888-8888-888888888888', 'Tháp Bà Ponagar', 'temple', 'Đường 2/4, Nha Trang', 12.2658, 109.1961, '06:00–17:30',
 'Quần thể tháp Chăm cổ hơn 1000 năm tuổi thờ nữ thần Ponagar.',
 'Mặc trang phục lịch sự khi vào tháp, kết hợp tham quan vào buổi chiều mát.', 4.5, 890, TRUE),
-- Mũi Né
('99999999-9999-9999-9999-999999999999', 'Đồi Cát Bay', 'attraction', 'Phường Mũi Né, Phan Thiết', 10.9333, 108.2833, '05:00–19:00',
 'Đồi cát vàng khổng lồ thay đổi hình dạng theo gió, đẹp nhất lúc hoàng hôn.',
 'Đi vào sáng sớm hoặc chiều tối để tránh nắng gắt, thuê xe trượt cát tại chỗ.', 4.6, 1450, TRUE),
('99999999-9999-9999-9999-999999999999', 'Suối Tiên Mũi Né', 'attraction', 'Phường Hàm Tiến, Phan Thiết', 10.9486, 108.2419, '06:00–18:00',
 'Suối nước cạn chảy qua hẻm cát đỏ tạo nên cảnh quan độc đáo như tiểu sa mạc.',
 'Đi chân trần lội suối, nên mặc đồ gọn nhẹ và mang theo nước uống.', 4.4, 670, TRUE),
-- Ninh Bình
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Tam Cốc - Bích Động', 'attraction', 'Ninh Hải, Hoa Lư, Ninh Bình', 20.2106, 105.9367, '07:00–17:00',
 'Hệ thống hang động xuyên núi đi bằng thuyền nan giữa cánh đồng lúa và sông nước.',
 'Đi mùa lúa chín (tháng 5–6 hoặc 9–10) để có ảnh đẹp nhất, nên đi thuyền vào sáng sớm.', 4.8, 2240, TRUE),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Tràng An', 'attraction', 'Ninh Xuân, Hoa Lư, Ninh Bình', 20.2486, 105.9133, '07:00–17:00',
 'Quần thể danh thắng UNESCO với hang động, đền chùa giữa non nước hữu tình.',
 'Đặt vé thuyền theo tuyến (ngắn/dài), tuyến dài khoảng 3 giờ tham quan hết các điểm.', 4.8, 1980, TRUE);

-- ============================================================
-- [TRAVEL] HOTELS — khách sạn/homestay mẫu
-- ============================================================
INSERT INTO hotels (destination_id, name, type, stars, price_per_night, address, amenities, description, rating) VALUES
('11111111-1111-1111-1111-111111111111', 'Dalat Palace Heritage Hotel', 'hotel', 5, 2800000, '12 Trần Phú, Đà Lạt',
 ARRAY['Hồ bơi','Spa','Nhà hàng','WiFi miễn phí','Bãi đỗ xe'],
 'Khách sạn mang phong cách kiến trúc Pháp cổ điển, view hồ Xuân Hương.', 4.7),
('11111111-1111-1111-1111-111111111111', 'Đà Lạt Cozy Homestay', 'homestay', 3, 450000, '25 Khe Sanh, Đà Lạt',
 ARRAY['WiFi miễn phí','Bếp chung','Sân vườn'],
 'Homestay ấm cúng phong cách vintage, gần chợ đêm Đà Lạt.', 4.5),
('22222222-2222-2222-2222-222222222222', 'Vinpearl Resort Phú Quốc', 'resort', 5, 2500000, 'Bãi Dài, Phú Quốc',
 ARRAY['Hồ bơi','WiFi','Đón sân bay','Spa','Bãi biển riêng'],
 'Khu nghỉ dưỡng 5 sao view biển, gần Vinwonders và Safari.', 4.9),
('22222222-2222-2222-2222-222222222222', 'Mai House Phú Quốc Homestay', 'homestay', 3, 600000, 'Dương Đông, Phú Quốc',
 ARRAY['WiFi miễn phí','Xe máy cho thuê','Bữa sáng'],
 'Homestay giá tốt gần chợ đêm Dinh Cậu, chủ nhà thân thiện.', 4.4),
('33333333-3333-3333-3333-333333333333', 'H''Mong Village Homestay', 'homestay', 3, 350000, 'Đồng Văn, Hà Giang',
 ARRAY['Bữa tối truyền thống','WiFi','Đốt lửa trại'],
 'Homestay sàn gỗ truyền thống, trải nghiệm văn hóa H''Mông bản địa.', 4.6),
('44444444-4444-4444-4444-444444444444', 'Hoi An Ancient House Resort', 'resort', 4, 1500000, 'Cẩm Châu, Hội An',
 ARRAY['Hồ bơi','Xe đạp miễn phí','Spa','Nhà hàng'],
 'Resort yên tĩnh cách phố cổ 2km, kiến trúc nhà cổ Hội An.', 4.7),
('55555555-5555-5555-5555-555555555555', 'Sapa Jade Hill Hotel', 'hotel', 4, 1200000, 'Đường Mường Hoa, Sa Pa',
 ARRAY['View núi','Lò sưởi','Nhà hàng','WiFi'],
 'Khách sạn view thung lũng Mường Hoa, gần trung tâm thị trấn.', 4.6),
('66666666-6666-6666-6666-666666666666', 'Vinhomes Dragon Bay Hạ Long', 'resort', 5, 3200000, 'Bãi Cháy, Hạ Long',
 ARRAY['Hồ bơi','Spa','View vịnh','WiFi','Nhà hàng'],
 'Resort cao cấp view trực diện vịnh Hạ Long, gần cảng tàu du lịch.', 4.7),
('66666666-6666-6666-6666-666666666666', 'Hạ Long Bay Cruise Cabin', 'hotel', 4, 1800000, 'Trên du thuyền, Vịnh Hạ Long',
 ARRAY['Bữa ăn trên thuyền','View biển','Hướng dẫn viên'],
 'Du thuyền ngủ đêm trên vịnh, trải nghiệm độc đáo ngắm hoàng hôn và bình minh.', 4.8),
('77777777-7777-7777-7777-777777777777', 'Azerai La Residence Hue', 'hotel', 5, 2600000, '5 Lê Lợi, TP. Huế',
 ARRAY['Hồ bơi','Spa','View sông Hương','WiFi'],
 'Khách sạn phong cách Đông Dương cổ điển ven sông Hương.', 4.8),
('77777777-7777-7777-7777-777777777777', 'Huế Charm Homestay', 'homestay', 3, 400000, 'Đường Hùng Vương, TP. Huế',
 ARRAY['WiFi miễn phí','Cho thuê xe máy','Bữa sáng'],
 'Homestay giá rẻ gần Đại Nội, chủ nhà nhiệt tình hỗ trợ tour.', 4.5),
('88888888-8888-8888-8888-888888888888', 'Vinpearl Resort Nha Trang', 'resort', 5, 2900000, 'Đảo Hòn Tre, Nha Trang',
 ARRAY['Hồ bơi','Bãi biển riêng','Công viên giải trí','Spa'],
 'Khu nghỉ dưỡng trên đảo riêng, kết hợp với VinWonders Nha Trang.', 4.8),
('99999999-9999-9999-9999-999999999999', 'Mui Ne Bay Resort', 'resort', 4, 1600000, 'Hàm Tiến, Mũi Né',
 ARRAY['Hồ bơi','Bãi biển','Lướt ván diều','WiFi'],
 'Resort ven biển chuyên phục vụ dân lướt ván diều quốc tế.', 4.6),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Tam Coc Garden Homestay', 'homestay', 3, 350000, 'Ninh Hải, Hoa Lư, Ninh Bình',
 ARRAY['View ruộng lúa','Xe đạp miễn phí','Bữa sáng'],
 'Homestay giữa cánh đồng lúa, gần bến thuyền Tam Cốc.', 4.7);

-- ============================================================
-- [TRAVEL] TOURS — tour du lịch trọn gói
-- ============================================================
INSERT INTO tours (destination_id, name, duration, price, group_size, description, includes, excludes) VALUES
('11111111-1111-1111-1111-111111111111', 'Tour Đà Lạt 3N2Đ - Khám phá thành phố ngàn hoa', '3N2Đ', 2200000, '4–20 người',
 'Tham quan hồ Xuân Hương, đồi chè Cầu Đất, thung lũng Tình Yêu và chợ đêm Đà Lạt.',
 ARRAY['Xe đưa đón','Khách sạn 3 sao','Ăn sáng','HDV tiếng Việt','Vé tham quan'],
 ARRAY['Ăn trưa/tối','Chi phí cá nhân','Vé máy bay']),
('22222222-2222-2222-2222-222222222222', 'Tour Phú Quốc 4N3Đ - Đảo ngọc trọn vẹn', '4N3Đ', 5500000, '2–15 người',
 'Khám phá Bãi Sao, Vinwonders, câu cá - lặn ngắm san hô và chợ đêm Dinh Cậu.',
 ARRAY['Vé máy bay khứ hồi','Resort 4 sao','Ăn 3 bữa/ngày','Vé Vinwonders','Tour câu cá'],
 ARRAY['Chi phí cá nhân','Đồ uống có cồn']),
('33333333-3333-3333-3333-333333333333', 'Tour Hà Giang Loop 3N2Đ - Cung đường huyền thoại', '3N2Đ', 3200000, '6–12 người',
 'Chạy xe máy/ô tô qua đèo Mã Pí Lèng, cao nguyên đá Đồng Văn, dinh Vua Mèo.',
 ARRAY['Xe máy + xăng','Homestay','Ăn sáng + tối','HDV địa phương','Mũ bảo hiểm'],
 ARRAY['Ăn trưa','Chi phí cá nhân','Bảo hiểm du lịch']),
('44444444-4444-4444-4444-444444444444', 'Tour Hội An 2N1Đ - Phố cổ về đêm', '2N1Đ', 1500000, '2–10 người',
 'Tham quan Chùa Cầu, phố cổ về đêm, làng rau Trà Quế và học nấu ăn truyền thống.',
 ARRAY['Khách sạn 3 sao','Ăn sáng','Vé tham quan phố cổ','Lớp học nấu ăn'],
 ARRAY['Ăn trưa/tối','Đồ uống','Chi phí cá nhân']),
('55555555-5555-5555-5555-555555555555', 'Tour Sa Pa 3N2Đ - Săn mây Fansipan', '3N2Đ', 2800000, '4–16 người',
 'Trekking bản Cát Cát, cáp treo Fansipan và tham quan chợ tình Sa Pa.',
 ARRAY['Xe đưa đón từ Hà Nội','Khách sạn view núi','Ăn sáng + tối','Vé cáp treo','HDV'],
 ARRAY['Ăn trưa','Chi phí cá nhân','Đồ ấm cá nhân']),
('66666666-6666-6666-6666-666666666666', 'Du thuyền Hạ Long 2N1Đ - Ngủ đêm trên vịnh', '2N1Đ', 3800000, '2–20 người',
 'Trải nghiệm ngủ đêm trên du thuyền, tham quan hang Sửng Sốt, chèo kayak và ngắm hoàng hôn.',
 ARRAY['Du thuyền 4 sao','Ăn 3 bữa','Vé tham quan hang động','Kayak','HDV'],
 ARRAY['Đồ uống có cồn','Massage trên thuyền','Chi phí cá nhân']),
('77777777-7777-7777-7777-777777777777', 'Tour Huế 1 ngày - Hoàng thành và lăng tẩm', '1 ngày', 900000, '2–25 người',
 'Tham quan Đại Nội, lăng Khải Định, lăng Minh Mạng và đi thuyền sông Hương nghe ca Huế.',
 ARRAY['Xe đưa đón','Vé tham quan','Ăn trưa','HDV tiếng Việt'],
 ARRAY['Vé thuyền ca Huế (tùy chọn)','Chi phí cá nhân']),
('88888888-8888-8888-8888-888888888888', 'Tour 4 đảo Nha Trang - Lặn ngắm san hô', '1 ngày', 650000, '4–30 người',
 'Khám phá đảo Hòn Mun, Hòn Tằm, lặn ngắm san hô và ăn hải sản trên thuyền.',
 ARRAY['Tàu cao tốc','Ăn trưa hải sản','Dụng cụ lặn','Vé tham quan đảo'],
 ARRAY['Đồ uống','Chụp ảnh dưới nước','Chi phí cá nhân']),
('99999999-9999-9999-9999-999999999999', 'Tour Mũi Né 2N1Đ - Đồi cát và lướt ván diều', '2N1Đ', 1900000, '2–12 người',
 'Tham quan Đồi Cát Bay, Suối Tiên, trải nghiệm trượt cát và học lướt ván diều cơ bản.',
 ARRAY['Khách sạn 3 sao','Ăn sáng','Xe đưa đón','Dụng cụ trượt cát'],
 ARRAY['Khóa học lướt ván diều chuyên sâu','Ăn trưa/tối']),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Tour Ninh Bình 1 ngày - Tràng An và Tam Cốc', '1 ngày', 750000, '2–20 người',
 'Đi thuyền Tràng An, tham quan chùa Bái Đính và Tam Cốc - Bích Động trong ngày.',
 ARRAY['Xe đưa đón từ Hà Nội','Vé thuyền','Ăn trưa','HDV'],
 ARRAY['Chi phí cá nhân','Đồ lưu niệm']);

-- ============================================================
-- [TRAVEL] TICKETS — vé tham quan
-- ============================================================
INSERT INTO tickets (destination_id, name, price_adult, price_child, description, hours) VALUES
('11111111-1111-1111-1111-111111111111', 'Vé Thung lũng Tình Yêu', 150000, 75000,
 'Vé vào cổng tham quan thung lũng, chưa bao gồm xe điện và các dịch vụ chụp ảnh.', '07:00–17:00'),
('22222222-2222-2222-2222-222222222222', 'Vé VinWonders Phú Quốc', 750000, 600000,
 'Vé vào công viên giải trí và thủy cung VinWonders, đã bao gồm các trò chơi.', '09:00–21:00'),
('22222222-2222-2222-2222-222222222222', 'Vé Vinpearl Safari', 650000, 520000,
 'Vé tham quan vườn thú bán hoang dã, bao gồm xe bus tham quan safari.', '08:00–17:30'),
('33333333-3333-3333-3333-333333333333', 'Vé Dinh thự Vua Mèo', 20000, 10000,
 'Vé tham quan dinh thự cổ của dòng họ Vương tại Đồng Văn.', '07:30–17:30'),
('44444444-4444-4444-4444-444444444444', 'Vé tham quan Phố cổ Hội An', 120000, 60000,
 'Vé tham quan 5 điểm di tích trong khu phố cổ, gồm Chùa Cầu, nhà cổ, hội quán.', '08:00–21:30'),
('55555555-5555-5555-5555-555555555555', 'Vé cáp treo Fansipan', 800000, 600000,
 'Vé cáp treo 2 chiều lên đỉnh Fansipan, đã bao gồm tàu hỏa leo núi.', '07:00–17:00'),
('66666666-6666-6666-6666-666666666666', 'Vé tham quan Vịnh Hạ Long (tuyến 2)', 290000, 145000,
 'Vé tham quan các điểm trong vịnh gồm hang Sửng Sốt, đảo Titop, hang Luồn.', '07:00–17:00'),
('77777777-7777-7777-7777-777777777777', 'Vé Đại Nội Huế', 200000, 40000,
 'Vé vào tham quan Hoàng thành và các di tích trong Đại Nội.', '07:00–17:30'),
('77777777-7777-7777-7777-777777777777', 'Vé lăng Khải Định', 150000, 30000,
 'Vé tham quan lăng tẩm pha trộn kiến trúc Đông - Tây độc đáo.', '07:00–17:30'),
('88888888-8888-8888-8888-888888888888', 'Vé VinWonders Nha Trang (gồm cáp treo)', 850000, 680000,
 'Vé công viên giải trí kèm cáp treo vượt biển dài nhất Việt Nam.', '08:00–21:00'),
('99999999-9999-9999-9999-999999999999', 'Vé Đồi Cát Bay + xe trượt', 50000, 30000,
 'Vé vào khu vực đồi cát, đã gồm phí thuê tấm trượt cát.', '05:00–19:00'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Vé thuyền Tràng An', 250000, 125000,
 'Vé đi thuyền tham quan tuyến hang động và đền chùa tại Tràng An.', '07:00–17:00'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Vé thuyền Tam Cốc', 150000, 75000,
 'Vé đi thuyền nan tham quan ba hang xuyên núi tại Tam Cốc.', '07:00–17:00');

-- ============================================================
-- [TRAVEL] TRANSPORT OPTIONS — phương tiện di chuyển
-- ============================================================
INSERT INTO transport_options (destination_id, is_local, type, price_info, duration, provider, notes) VALUES
('11111111-1111-1111-1111-111111111111', FALSE, 'xe khách', '250.000–350.000đ/người', '6–7 giờ từ TP.HCM', 'Thành Bưởi, Phương Trang', 'Nên đặt vé trước vào dịp lễ Tết.'),
('11111111-1111-1111-1111-111111111111', TRUE,  'xe máy',  '100.000–150.000đ/ngày', NULL, 'Các tiệm cho thuê tại trung tâm', 'Cần đặt cọc CCCD hoặc passport.'),
('22222222-2222-2222-2222-222222222222', FALSE, 'máy bay', '1.200.000–2.500.000đ/khứ hồi', '1 giờ 10 phút từ TP.HCM', 'Vietnam Airlines, Vietjet', 'Đặt sớm 1–2 tháng để có giá tốt.'),
('22222222-2222-2222-2222-222222222222', TRUE,  'taxi/grab', '15.000–20.000đ/km', NULL, 'Mai Linh, Grab', 'Grab hoạt động phổ biến ở khu trung tâm Dương Đông.'),
('33333333-3333-3333-3333-333333333333', FALSE, 'xe khách giường nằm', '300.000–400.000đ/người', '6–7 giờ từ Hà Nội', 'Cầu Mè, Hải Vân', 'Xe giường nằm chạy đêm, nên mang theo áo ấm.'),
('33333333-3333-3333-3333-333333333333', TRUE,  'xe máy',  '150.000–200.000đ/ngày', NULL, 'Các tiệm tại TP. Hà Giang', 'Nên thuê xe số, tay côn nếu chưa quen địa hình đèo núi.'),
('44444444-4444-4444-4444-444444444444', FALSE, 'máy bay + taxi', '~2.000.000đ khứ hồi (đến Đà Nẵng)', '1 giờ 20 phút + 45 phút taxi', 'Vietjet, Vietnam Airlines', 'Hạ cánh sân bay Đà Nẵng rồi taxi/grab về Hội An.'),
('55555555-5555-5555-5555-555555555555', FALSE, 'tàu hỏa + xe khách', '400.000–700.000đ/người', '8 giờ tàu + 1 giờ xe', 'Đường sắt Việt Nam, xe Sapa Express', 'Tàu đêm từ Hà Nội đến Lào Cai, sau đó đi xe lên Sa Pa.'),
('66666666-6666-6666-6666-666666666666', FALSE, 'xe khách', '150.000–250.000đ/người', '2.5–3 giờ từ Hà Nội', 'Kumho Việt Thanh, Long Phương', 'Có xe limousine đón tận nhà giá cao hơn xe khách thường.'),
('66666666-6666-6666-6666-666666666666', TRUE,  'tàu/thuyền', '290.000đ/vé tham quan', NULL, 'Ban quản lý vịnh Hạ Long', 'Phải mua vé tham quan vịnh trước khi lên thuyền.'),
('77777777-7777-7777-7777-777777777777', FALSE, 'máy bay', '1.000.000–2.200.000đ/khứ hồi', '1 giờ 15 phút từ Hà Nội/TP.HCM', 'Vietnam Airlines, Vietjet, Bamboo', 'Sân bay Phú Bài cách trung tâm Huế khoảng 15km.'),
('77777777-7777-7777-7777-777777777777', TRUE,  'xích lô/taxi', '50.000–150.000đ/chuyến', NULL, 'Mai Linh, xích lô địa phương', 'Xích lô phù hợp tham quan phố cổ, nên thỏa thuận giá trước.'),
('88888888-8888-8888-8888-888888888888', FALSE, 'máy bay', '1.000.000–2.000.000đ/khứ hồi', '1 giờ 20 phút từ Hà Nội/TP.HCM', 'Vietjet, Vietnam Airlines', 'Sân bay Cam Ranh cách trung tâm khoảng 30km, nên đặt xe đón trước.'),
('99999999-9999-9999-9999-999999999999', FALSE, 'xe khách giường nằm', '180.000–280.000đ/người', '4–5 giờ từ TP.HCM', 'Phương Trang, Hoàng Long', 'Nhiều xe limousine 9 chỗ đón tận nơi tại TP.HCM.'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', FALSE, 'xe khách/limousine', '120.000–200.000đ/người', '2 giờ từ Hà Nội', 'Xe Kim Ngân, limousine Ninh Bình', 'Có thể đi tour ngày từ Hà Nội không cần ngủ lại.');

-- ============================================================
-- [TRAVEL] DESTINATION EVENTS — lễ hội, sự kiện
-- ============================================================
INSERT INTO destination_events (destination_id, name, event_date, location_text, cost, description) VALUES
('11111111-1111-1111-1111-111111111111', 'Festival Hoa Đà Lạt', 'Tháng 12 (2 năm/lần)', 'Trung tâm TP. Đà Lạt', 'Miễn phí một số khu vực',
 'Lễ hội hoa lớn nhất Việt Nam với các vườn hoa nghệ thuật và diễu hành đường phố.'),
('33333333-3333-3333-3333-333333333333', 'Mùa hoa Tam giác mạch', 'Tháng 10–11 hàng năm', 'Cao nguyên đá Đồng Văn', 'Miễn phí',
 'Hoa tam giác mạch nở rộ khắp các sườn núi, thu hút đông đảo khách du lịch chụp ảnh.'),
('44444444-4444-4444-4444-444444444444', 'Đêm phố cổ Hội An', '14 hàng tháng (âm lịch)', 'Phố cổ Hội An', 'Miễn phí vào, có phí dịch vụ',
 'Toàn phố cổ tắt điện, chỉ thắp sáng bằng đèn lồng, có hoạt động thả đèn hoa đăng trên sông.'),
('55555555-5555-5555-5555-555555555555', 'Chợ tình Sa Pa', 'Tối thứ 7 hàng tuần', 'Trung tâm thị trấn Sa Pa', 'Miễn phí',
 'Nét văn hóa độc đáo của người dân tộc, nơi trai gái H''Mông tìm hiểu nhau qua câu hát.'),
('66666666-6666-6666-6666-666666666666', 'Carnaval Hạ Long', 'Cuối tháng 4 hoặc tháng 5 hàng năm', 'Bãi Cháy, Hạ Long', 'Miễn phí',
 'Lễ hội đường phố với diễu hành, pháo hoa và các hoạt động văn hóa quy mô lớn.'),
('77777777-7777-7777-7777-777777777777', 'Festival Huế', 'Tháng 6 (năm chẵn)', 'TP. Huế', 'Một số chương trình có phí',
 'Lễ hội văn hóa nghệ thuật quốc tế lớn nhất miền Trung, tái hiện lễ tế Nam Giao và các show nghệ thuật.'),
('88888888-8888-8888-8888-888888888888', 'Festival Biển Nha Trang', 'Tháng 6 (năm chẵn)', 'TP. Nha Trang', 'Miễn phí một số khu vực',
 'Lễ hội biển với các hoạt động thể thao nước, diễu hành thuyền hoa và pháo hoa.'),
('99999999-9999-9999-9999-999999999999', 'Giải lướt ván diều quốc tế Mũi Né', 'Tháng 2 hàng năm', 'Bãi biển Mũi Né', 'Miễn phí xem',
 'Giải đấu lướt ván diều thu hút vận động viên quốc tế, gió mạnh và sóng đẹp nhất trong năm.');


-- ============================================================
-- [TRAVEL] SHOPPING PLACES — mua sắm, đặc sản
-- ============================================================
INSERT INTO shopping_places (destination_id, name, type, items, address, opening_hours, price_range) VALUES
('11111111-1111-1111-1111-111111111111', 'Chợ đêm Đà Lạt', 'market',
 ARRAY['Mứt dâu','Atiso','Áo len','Bánh tráng nướng'], 'Đường Nguyễn Thị Minh Khai, Đà Lạt', '17:00–23:00', '20.000–300.000đ'),
('22222222-2222-2222-2222-222222222222', 'Chợ đêm Dinh Cậu', 'market',
 ARRAY['Hải sản khô','Nước mắm','Hồ tiêu','Ngọc trai'], 'Dương Đông, Phú Quốc', '17:00–22:00', '50.000–1.000.000đ'),
('33333333-3333-3333-3333-333333333333', 'Chợ Đồng Văn', 'market',
 ARRAY['Thổ cẩm dân tộc','Rượu ngô','Mật ong bạc hà'], 'Trung tâm Đồng Văn, Hà Giang', 'Chủ nhật hàng tuần', '30.000–500.000đ'),
('44444444-4444-4444-4444-444444444444', 'Chợ Hội An', 'market',
 ARRAY['Đèn lồng','Vải lụa','Đồ thủ công mỹ nghệ'], 'Đường Trần Phú, Hội An', '06:00–18:00', '20.000–500.000đ'),
('66666666-6666-6666-6666-666666666666', 'Chợ Hạ Long', 'market',
 ARRAY['Chả mực','Hải sản khô','Ngọc trai'], 'Trần Hưng Đạo, Bãi Cháy, Hạ Long', '06:00–20:00', '50.000–500.000đ'),
('77777777-7777-7777-7777-777777777777', 'Chợ Đông Ba', 'market',
 ARRAY['Mè xửng','Nón lá','Áo dài','Đồ lưu niệm cung đình'], 'Trần Hưng Đạo, TP. Huế', '06:00–20:00', '20.000–300.000đ'),
('88888888-8888-8888-8888-888888888888', 'Chợ Đầm Nha Trang', 'market',
 ARRAY['Hải sản khô','Yến sào','Nước mắm','Đồ lưu niệm'], 'Trung tâm TP. Nha Trang', '06:00–21:00', '30.000–1.000.000đ'),
('99999999-9999-9999-9999-999999999999', 'Chợ Phan Thiết', 'market',
 ARRAY['Nước mắm Phan Thiết','Thanh long','Mực khô'], 'TP. Phan Thiết, Bình Thuận', '05:00–19:00', '20.000–400.000đ');

-- ============================================================
-- [AI] PROMPT TEMPLATES — system prompts cho chatbot
-- ============================================================
INSERT INTO prompt_templates (name, system_prompt, version, is_active) VALUES
('travel_advisor',
 'Bạn là PDTrip AI, trợ lý tư vấn du lịch thông minh am hiểu Việt Nam. Hãy trả lời ngắn gọn, chính xác bằng tiếng Việt tự nhiên, dựa trên dữ liệu được cung cấp trong phần ngữ cảnh (context). Nếu không có thông tin trong ngữ cảnh, hãy nói rõ rằng bạn không chắc chắn, không tự suy diễn hoặc bịa đặt thông tin.',
 '1.0', TRUE),
('itinerary_planner',
 'Bạn là chuyên gia lập lịch trình du lịch của PDTrip AI. Dựa trên điểm đến, số ngày, ngân sách và loại hình du lịch (solo/couple/family/group) mà người dùng cung cấp, hãy tạo lịch trình chi tiết theo từng ngày, từng buổi, có giờ giấc, địa điểm và chi phí ước tính. Ưu tiên dữ liệu thực tế từ knowledge base.',
 '1.0', TRUE),
('intent_classifier',
 'Phân loại ý định của câu hỏi người dùng vào một trong các nhóm: ask_destination (hỏi thông tin điểm đến), plan_trip (lập lịch trình), find_hotel (tìm khách sạn), find_tour (tìm tour), find_ticket (tìm vé tham quan), ask_faq (câu hỏi chung). Chỉ trả về tên nhãn, không giải thích thêm.',
 '1.0', TRUE);


-- ============================================================
-- [AI] KNOWLEDGE ENTRIES — dữ liệu RAG mẫu
-- ============================================================
INSERT INTO knowledge_entries (title, category, destination_id, content, tags, source) VALUES
('Mùa du lịch đẹp nhất Đà Lạt', 'destination', '11111111-1111-1111-1111-111111111111',
 'Đà Lạt đẹp nhất vào tháng 11 đến tháng 4 năm sau, đây là mùa khô, ít mưa, trời trong xanh, thuận lợi cho việc tham quan và chụp ảnh. Tháng 12 hàng năm thường có Festival Hoa Đà Lạt.',
 ARRAY['đà lạt','mùa du lịch','thời tiết'], 'manual'),
('Chi phí du lịch Phú Quốc 3 ngày 2 đêm', 'tip', '22222222-2222-2222-2222-222222222222',
 'Chi phí trung bình cho chuyến Phú Quốc 3N2Đ dao động 3.000.000–8.000.000đ/người tùy hạng khách sạn, bao gồm vé máy bay khứ hồi (~1.500.000đ), lưu trú (~600.000–2.500.000đ/đêm), ăn uống và tham quan VinWonders.',
 ARRAY['phú quốc','chi phí','ngân sách'], 'manual'),
('Kinh nghiệm đi Hà Giang Loop an toàn', 'safety', '33333333-3333-3333-3333-333333333333',
 'Khi đi xe máy cung đường Hà Giang Loop cần lưu ý: kiểm tra phanh và lốp xe trước khi đi, không chạy quá tốc độ ở các đoạn đèo cua tay áo như Mã Pí Lèng, mang theo áo mưa và đèn pin, tránh đi vào ban đêm vì sương mù dày.',
 ARRAY['hà giang','an toàn','xe máy'], 'manual'),
('Ẩm thực đặc trưng Hội An', 'food', '44444444-4444-4444-4444-444444444444',
 'Hội An nổi tiếng với cao lầu (mì sợi dày ăn cùng thịt heo, giá đỗ), mì Quảng, cơm gà Hội An, bánh mì Phượng được CNN vinh danh, và bánh bao bánh vạc (white rose) làm từ bột gạo.',
 ARRAY['hội an','ẩm thực','đặc sản'], 'manual'),
('Lịch trình Sa Pa 2 ngày 1 đêm cho cặp đôi', 'tip', '55555555-5555-5555-5555-555555555555',
 'Ngày 1: di chuyển từ Hà Nội, nhận phòng, tham quan bản Cát Cát buổi chiều, ăn tối tại nhà hàng view núi. Ngày 2: cáp treo lên đỉnh Fansipan buổi sáng, tham quan nhà thờ đá Sa Pa, mua đặc sản tại chợ trước khi về.',
 ARRAY['sa pa','lịch trình','cặp đôi'], 'manual'),
('Câu hỏi thường gặp: có cần đặt phòng trước khi đi Đà Lạt mùa cao điểm?', 'faq', '11111111-1111-1111-1111-111111111111',
 'Có, vào các kỳ nghỉ lễ và mùa Festival Hoa (tháng 12), khách sạn và homestay tại Đà Lạt thường hết phòng nhanh, nên đặt trước ít nhất 2–3 tuần để có giá tốt và phòng đẹp.',
 ARRAY['đà lạt','đặt phòng','faq'], 'manual'),
('An toàn khi tắm biển Phú Quốc', 'safety', '22222222-2222-2222-2222-222222222222',
 'Một số bãi biển ở Phú Quốc có dòng chảy xa bờ vào mùa mưa (tháng 7–9), nên tắm ở khu vực có biển báo an toàn, tránh xa các khu vực có đá ngầm, trẻ em cần có người lớn giám sát.',
 ARRAY['phú quốc','an toàn','biển'], 'manual'),
('Tổng quan du lịch Việt Nam theo vùng miền', 'faq', NULL,
 'Việt Nam chia thành 3 miền chính: Miền Bắc (Hà Giang, Sa Pa, Hà Nội) phù hợp khám phá núi và văn hóa dân tộc, Miền Trung (Hội An, Đà Nẵng, Huế) nổi bật di sản và biển, Miền Nam (Phú Quốc, TP.HCM) thế mạnh biển đảo và đô thị sôi động.',
 ARRAY['tổng quan','vùng miền','việt nam'], 'manual'),
('Cách di chuyển từ Hà Nội đến Vịnh Hạ Long', 'transport', '66666666-6666-6666-6666-666666666666',
 'Từ Hà Nội đến Hạ Long mất khoảng 2.5–3 giờ bằng xe khách hoặc limousine, giá vé 150.000–250.000đ/người. Nên đặt vé limousine để được đón tận nơi.',
 ARRAY['hạ long','di chuyển','xe khách'], 'manual'),
('Kinh nghiệm chọn tour du thuyền Hạ Long', 'tour', '66666666-6666-6666-6666-666666666666',
 'Nên chọn du thuyền có ngủ đêm 4–5 sao để trải nghiệm ngắm hoàng hôn và bình minh trên vịnh, đặt trước ít nhất 1 tuần vào mùa cao điểm hè và lễ Tết.',
 ARRAY['hạ long','du thuyền','tour'], 'manual'),
('Thời điểm đẹp nhất tham quan Đại Nội Huế', 'destination', '77777777-7777-7777-7777-777777777777',
 'Nên tham quan Đại Nội vào buổi sáng sớm (7h–9h) để tránh nắng gắt và đông khách, kết hợp xem lễ đổi gác diễn ra vào một số ngày trong tuần.',
 ARRAY['huế','đại nội','tham quan'], 'manual'),
('Chi phí du lịch Nha Trang 3 ngày 2 đêm', 'tip', '88888888-8888-8888-8888-888888888888',
 'Chi phí trung bình 2.000.000–5.500.000đ/người cho 3N2Đ tại Nha Trang, gồm vé máy bay (~1.000.000đ), khách sạn (300.000–2.900.000đ/đêm), tour 4 đảo (~650.000đ) và ăn uống.',
 ARRAY['nha trang','chi phí','ngân sách'], 'manual'),
('An toàn khi lướt ván diều tại Mũi Né', 'safety', '99999999-9999-9999-9999-999999999999',
 'Người mới nên thuê HLV hướng dẫn, tránh tự tập khi gió quá mạnh (cấp 6 trở lên), luôn mặc áo phao và kiểm tra dây an toàn trước khi xuống nước.',
 ARRAY['mũi né','lướt ván diều','an toàn'], 'manual'),
('Lịch trình Ninh Bình 1 ngày từ Hà Nội', 'tip', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 'Khởi hành sớm 6h từ Hà Nội, tham quan Tràng An buổi sáng (3 giờ đi thuyền), ăn trưa đặc sản dê núi, chiều tham quan Tam Cốc hoặc chùa Bái Đính, về Hà Nội trước 19h.',
 ARRAY['ninh bình','lịch trình','tour ngày'], 'manual'),
('So sánh Tam Cốc và Tràng An nên chọn đâu', 'faq', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
 'Tràng An có quy mô lớn hơn, hang động dài và nhiều đền chùa, phù hợp người thích khám phá sâu (3 giờ). Tam Cốc ngắn hơn (2 giờ), giá rẻ hơn, phù hợp đi vào mùa lúa chín để chụp ảnh.',
 ARRAY['ninh bình','tam cốc','tràng an','faq'], 'manual'),
('Câu hỏi thường gặp: du lịch Việt Nam cần chuẩn bị gì', 'faq', NULL,
 'Khi du lịch Việt Nam nên chuẩn bị: giấy tờ tùy thân (CCCD/passport), tiền mặt và thẻ ATM, đồ chống nắng/áo mưa tùy mùa, thuốc cá nhân cơ bản, sạc dự phòng và tải sẵn bản đồ offline khu vực sẽ đến.',
 ARRAY['chuẩn bị','kinh nghiệm','faq'], 'manual'),
('Mùa mưa bão ảnh hưởng đến du lịch miền Trung như thế nào', 'safety', NULL,
 'Miền Trung (Huế, Đà Nẵng, Hội An, Nha Trang) thường có mưa bão từ tháng 9–12, dễ gây hủy chuyến bay và ngập lụt cục bộ. Nên tránh đặt tour vào giai đoạn này hoặc theo dõi sát dự báo thời tiết trước khi đi.',
 ARRAY['miền trung','mùa mưa','an toàn'], 'manual');
-- ============================================================
-- [TRAVEL] TRIP PLANS — lịch trình mẫu (AI tạo + user tự tạo)
-- ============================================================
INSERT INTO trip_plans (id, user_id, destination_id, title, budget, start_date, end_date, travelers, travel_type, status, ai_generated)
SELECT
    'b0000000-0000-0000-0000-000000000001',
    u.id,
    '44444444-4444-4444-4444-444444444444',
    'Hội An 3 ngày 2 đêm cho cặp đôi',
    4500000,
    '2026-07-10', '2026-07-12',
    2, 'couple', 'saved', TRUE
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO trip_plans (id, user_id, destination_id, title, budget, start_date, end_date, travelers, travel_type, status, ai_generated)
SELECT
    'b0000000-0000-0000-0000-000000000002',
    u.id,
    '33333333-3333-3333-3333-333333333333',
    'Hà Giang Loop 4 ngày tự túc',
    3200000,
    '2026-10-01', '2026-10-04',
    1, 'solo', 'draft', FALSE
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO trip_plans (id, user_id, destination_id, title, budget, start_date, end_date, travelers, travel_type, status, ai_generated)
SELECT
    'b0000000-0000-0000-0000-000000000003',
    u.id,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Ninh Bình gia đình 2 ngày 1 đêm',
    6000000,
    '2026-08-15', '2026-08-16',
    4, 'family', 'completed', TRUE
FROM users u WHERE u.username = 'ngochuong';
 
-- ============================================================
-- [TRAVEL] TRIP PLAN ITEMS — chi tiết lịch trình theo ngày
-- ============================================================
-- Trip 1: Hội An 3N2Đ
INSERT INTO trip_plan_items (trip_plan_id, day_number, order_in_day, title, description, start_time, end_time, estimated_cost, notes) VALUES
('b0000000-0000-0000-0000-000000000001', 1, 1, 'Nhận phòng resort', 'Check-in Hoi An Ancient House Resort', '14:00', '15:00', 1500000, 'Đặt phòng trước qua app'),
('b0000000-0000-0000-0000-000000000001', 1, 2, 'Tham quan Chùa Cầu', 'Dạo phố cổ, chụp ảnh đèn lồng về tối', '17:00', '19:30', 120000, 'Mua vé tham quan phố cổ tại quầy'),
('b0000000-0000-0000-0000-000000000001', 1, 3, 'Ăn tối cao lầu', 'Thưởng thức cao lầu và mì Quảng', '19:30', '21:00', 200000, NULL),
('b0000000-0000-0000-0000-000000000001', 2, 1, 'Làng rau Trà Quế', 'Trải nghiệm trồng rau và nấu ăn cùng người dân', '08:00', '11:00', 350000, 'Đặt tour trải nghiệm trước'),
('b0000000-0000-0000-0000-000000000001', 2, 2, 'Nghỉ ngơi tại resort', 'Bơi hồ và spa thư giãn', '14:00', '17:00', 500000, NULL),
('b0000000-0000-0000-0000-000000000001', 3, 1, 'Mua sắm tại chợ Hội An', 'Mua đèn lồng và quà lưu niệm', '09:00', '11:00', 300000, 'Trả giá khi mua đồ'),
('b0000000-0000-0000-0000-000000000001', 3, 2, 'Trả phòng và rời Hội An', 'Check-out resort', '12:00', '13:00', 0, NULL);
 
-- Trip 3: Ninh Bình gia đình 2N1Đ
INSERT INTO trip_plan_items (trip_plan_id, day_number, order_in_day, title, description, start_time, end_time, estimated_cost, notes) VALUES
('b0000000-0000-0000-0000-000000000003', 1, 1, 'Khởi hành từ Hà Nội', 'Di chuyển bằng xe limousine', '06:30', '08:30', 800000, 'Đặt xe 7 chỗ cho 4 người'),
('b0000000-0000-0000-0000-000000000003', 1, 2, 'Tham quan Tràng An', 'Đi thuyền tuyến dài 3 giờ', '09:00', '12:00', 1000000, 'Mua vé thuyền cho cả gia đình'),
('b0000000-0000-0000-0000-000000000003', 1, 3, 'Ăn trưa đặc sản dê núi', 'Thưởng thức dê núi Ninh Bình', '12:30', '14:00', 600000, NULL),
('b0000000-0000-0000-0000-000000000003', 1, 4, 'Nhận phòng homestay', 'Check-in Tam Coc Garden Homestay', '14:30', '15:30', 700000, NULL),
('b0000000-0000-0000-0000-000000000003', 2, 1, 'Tham quan Tam Cốc', 'Đi thuyền nan ngắm ba hang xuyên núi', '08:00', '10:00', 600000, 'Mùa lúa chín ảnh đẹp nhất'),
('b0000000-0000-0000-0000-000000000003', 2, 2, 'Về Hà Nội', 'Di chuyển bằng xe limousine', '13:00', '15:00', 0, 'Đã gồm trong chi phí khởi hành');
 
-- ============================================================
-- [AI] CHAT SESSIONS — phiên hội thoại mẫu
-- ============================================================
INSERT INTO chat_sessions (id, user_id, title, summary, total_messages, total_tokens, pinned)
SELECT
    'c0000000-0000-0000-0000-000000000001',
    u.id,
    'Lịch trình Hội An 3 ngày 2 đêm',
    'Người dùng hỏi về lịch trình Hội An cho cặp đôi, AI gợi ý chi tiết theo ngày dựa trên knowledge base.',
    4, 860, TRUE
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO chat_sessions (id, user_id, title, summary, total_messages, total_tokens, pinned)
SELECT
    'c0000000-0000-0000-0000-000000000002',
    u.id,
    'Phú Quốc hay Côn Đảo?',
    'Người dùng so sánh hai điểm đến biển đảo, AI tư vấn dựa trên ngân sách và sở thích.',
    4, 720, FALSE
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO chat_sessions (id, user_id, title, summary, total_messages, total_tokens, pinned)
SELECT
    'c0000000-0000-0000-0000-000000000003',
    u.id,
    'Chi phí du lịch Sa Pa cuối tuần',
    'Người dùng hỏi về ngân sách dự kiến cho chuyến Sa Pa 2 ngày 1 đêm.',
    2, 380, FALSE
FROM users u WHERE u.username = 'ngochuong';
 
-- ============================================================
-- [AI] CHAT MESSAGES — nội dung hội thoại mẫu (kèm RAG sources)
-- ============================================================
-- Session 1: Hội An
INSERT INTO chat_messages (session_id, role, content, sources, intent, prompt_tokens, completion_tokens, latency_ms) VALUES
('c0000000-0000-0000-0000-000000000001', 'user',
 'Cho mình lịch trình Hội An 3 ngày 2 đêm đi với người yêu, ngân sách khoảng 4-5 triệu',
 '[]', 'plan_trip', 28, 0, NULL),
('c0000000-0000-0000-0000-000000000001', 'assistant',
 'Với ngân sách 4-5 triệu cho 2 người, mình gợi ý lịch trình 3N2Đ tại Hội An: Ngày 1 nhận phòng resort, dạo phố cổ ngắm đèn lồng về tối và ăn cao lầu. Ngày 2 trải nghiệm làng rau Trà Quế buổi sáng, nghỉ ngơi spa buổi chiều. Ngày 3 mua sắm tại chợ trước khi rời đi. Tổng chi phí ước tính khoảng 4.500.000đ.',
 '[{"id":"k1","title":"Ẩm thực đặc trưng Hội An","score":0.89},{"id":"k2","title":"Lịch trình Sa Pa 2 ngày 1 đêm cho cặp đôi","score":0.71}]',
 'plan_trip', 0, 180, 1450),
('c0000000-0000-0000-0000-000000000001', 'user',
 'Resort nào view đẹp mà giá hợp lý không bạn?',
 '[]', 'find_hotel', 16, 0, NULL),
('c0000000-0000-0000-0000-000000000001', 'assistant',
 'Bạn có thể chọn Hoi An Ancient House Resort, giá khoảng 1.500.000đ/đêm, có hồ bơi, xe đạp miễn phí và cách phố cổ chỉ 2km, rất phù hợp cho cặp đôi muốn không gian yên tĩnh.',
 '[{"id":"k3","title":"Hotel: Hoi An Ancient House Resort","score":0.93}]',
 'find_hotel', 0, 95, 980);
 
-- Session 2: Phú Quốc vs Côn Đảo
INSERT INTO chat_messages (session_id, role, content, sources, intent, prompt_tokens, completion_tokens, latency_ms) VALUES
('c0000000-0000-0000-0000-000000000002', 'user',
 'Mình đang phân vân giữa Phú Quốc và Côn Đảo, nên chọn đâu cho chuyến đi 4 ngày?',
 '[]', 'ask_destination', 24, 0, NULL),
('c0000000-0000-0000-0000-000000000002', 'assistant',
 'Hiện tại dữ liệu của mình chưa có thông tin chi tiết về Côn Đảo. Với Phú Quốc, đây là lựa chọn phù hợp cho chuyến 4 ngày với nhiều hoạt động: VinWonders, Safari, lặn ngắm san hô và resort cao cấp, ngân sách trung bình 3.000.000-8.000.000đ/người.',
 '[{"id":"k4","title":"Chi phí du lịch Phú Quốc 3 ngày 2 đêm","score":0.85}]',
 'ask_destination', 0, 110, 1120),
('c0000000-0000-0000-0000-000000000002', 'user',
 'OK vậy mình chọn Phú Quốc, có tour nào trọn gói không?',
 '[]', 'find_tour', 18, 0, NULL),
('c0000000-0000-0000-0000-000000000002', 'assistant',
 'Có tour "Phú Quốc 4N3Đ - Đảo ngọc trọn vẹn" giá 5.500.000đ/người, bao gồm vé máy bay khứ hồi, resort 4 sao, ăn 3 bữa/ngày, vé VinWonders và tour câu cá lặn ngắm san hô.',
 '[{"id":"k5","title":"Tour: Phú Quốc 4N3Đ - Đảo ngọc trọn vẹn","score":0.91}]',
 'find_tour', 0, 88, 940);
 
-- Session 3: Sa Pa
INSERT INTO chat_messages (session_id, role, content, sources, intent, prompt_tokens, completion_tokens, latency_ms) VALUES
('c0000000-0000-0000-0000-000000000003', 'user',
 'Đi Sa Pa 2 ngày 1 đêm cuối tuần này tốn khoảng bao nhiêu tiền?',
 '[]', 'ask_faq', 20, 0, NULL),
('c0000000-0000-0000-0000-000000000003', 'assistant',
 'Chuyến Sa Pa 2N1Đ thường dao động 1.500.000-4.500.000đ/người tùy hạng khách sạn, bao gồm di chuyển (tàu/xe khoảng 400.000-700.000đ), lưu trú, vé cáp treo Fansipan (800.000đ) và ăn uống.',
 '[{"id":"k6","title":"Lịch trình Sa Pa 2 ngày 1 đêm cho cặp đôi","score":0.82}]',
 'ask_faq', 0, 92, 1050);
 
-- ============================================================
-- [AI] CONVERSATION MEMORY — bộ nhớ AI ghi nhận về user
-- ============================================================
INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
SELECT u.id, 'travel_style', '{"style": "couple", "note": "Thường đi du lịch cùng người yêu, ưu tiên không gian lãng mạn yên tĩnh"}', 0.85
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
SELECT u.id, 'budget', '{"range": "4-5 trieu", "per": "2 nguoi", "note": "Ngân sách tầm trung cho chuyến 3N2Đ"}', 0.8
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
SELECT u.id, 'preference', '{"likes": ["biển", "đảo"], "note": "Quan tâm các điểm đến biển đảo, từng hỏi Phú Quốc và Côn Đảo"}', 0.75
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
SELECT u.id, 'visited', '{"destinations": ["Hội An", "Phú Quốc"], "note": "Đã từng hỏi review khách sạn bình dân Hội An"}', 0.7
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
SELECT u.id, 'travel_style', '{"style": "family", "members": 4, "note": "Đi cùng gia đình, có nhu cầu lịch trình nhẹ nhàng"}', 0.82
FROM users u WHERE u.username = 'ngochuong';
 
-- ============================================================
-- [ANALYTICS] SEARCH HISTORY — lịch sử tìm kiếm/câu hỏi
-- ============================================================
INSERT INTO search_history (user_id, keyword, intent, result_count, session_id)
SELECT u.id, 'lịch trình hội an 3 ngày 2 đêm', 'plan_trip', 5, 'c0000000-0000-0000-0000-000000000001'
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO search_history (user_id, keyword, intent, result_count, session_id)
SELECT u.id, 'resort hội an giá rẻ', 'find_hotel', 3, 'c0000000-0000-0000-0000-000000000001'
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO search_history (user_id, keyword, intent, result_count, session_id)
SELECT u.id, 'phú quốc hay côn đảo', 'ask_destination', 2, 'c0000000-0000-0000-0000-000000000002'
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO search_history (user_id, keyword, intent, result_count, session_id)
SELECT u.id, 'tour phú quốc trọn gói', 'find_tour', 4, 'c0000000-0000-0000-0000-000000000002'
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO search_history (user_id, keyword, intent, result_count, session_id)
SELECT u.id, 'chi phí du lịch sa pa', 'ask_faq', 1, 'c0000000-0000-0000-0000-000000000003'
FROM users u WHERE u.username = 'ngochuong';
 
INSERT INTO search_history (user_id, keyword, intent, result_count)
SELECT u.id, 'ninh bình tam cốc hay tràng an', 'ask_faq', 2
FROM users u WHERE u.username = 'quangkhai';
 
INSERT INTO search_history (user_id, keyword, intent, result_count)
SELECT u.id, 'mũi né lướt ván diều an toàn', 'ask_faq', 1
FROM users u WHERE u.username = 'thuylinh';
 
INSERT INTO search_history (user_id, keyword, intent, result_count)
SELECT u.id, 'nha trang 3 ngày 2 đêm bao nhiêu tiền', 'ask_faq', 1
FROM users u WHERE u.username = 'quangkhai';
 
-- ============================================================
-- [ANALYTICS] USER BEHAVIOR — hành vi người dùng
-- ============================================================
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id, session_id)
SELECT u.id, 'view_destination', 'destination', '44444444-4444-4444-4444-444444444444', 'c0000000-0000-0000-0000-000000000001'
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id, session_id)
SELECT u.id, 'ask_chatbot', NULL, NULL, 'c0000000-0000-0000-0000-000000000001'
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id)
SELECT u.id, 'save_trip', 'trip_plan', 'b0000000-0000-0000-0000-000000000001'
FROM users u WHERE u.username = 'tranlan';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id, session_id)
SELECT u.id, 'view_destination', 'destination', '22222222-2222-2222-2222-222222222222', 'c0000000-0000-0000-0000-000000000002'
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id, session_id)
SELECT u.id, 'ask_chatbot', NULL, NULL, 'c0000000-0000-0000-0000-000000000002'
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id)
SELECT u.id, 'feedback_positive', 'chat_message', NULL
FROM users u WHERE u.username = 'minhhieu';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id)
SELECT u.id, 'view_destination', 'destination', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'
FROM users u WHERE u.username = 'ngochuong';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id)
SELECT u.id, 'save_trip', 'trip_plan', 'b0000000-0000-0000-0000-000000000003'
FROM users u WHERE u.username = 'ngochuong';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id)
SELECT u.id, 'view_tour', 'tour', NULL
FROM users u WHERE u.username = 'quangkhai';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id)
SELECT u.id, 'view_destination', 'destination', '99999999-9999-9999-9999-999999999999'
FROM users u WHERE u.username = 'thuylinh';
 
INSERT INTO user_behavior (user_id, event_type, entity_type, entity_id)
SELECT u.id, 'view_hotel', 'hotel', NULL
FROM users u WHERE u.username = 'thuylinh';
 
-- ============================================================
-- [AI] EMBEDDING JOBS — job mẫu cho các knowledge_entries vừa thêm
-- (worker Python sẽ pick up các job pending để embed + upsert Qdrant)
-- ============================================================
INSERT INTO embedding_jobs (entity_type, entity_id, status)
SELECT 'knowledge_entry', id, 'pending'
FROM knowledge_entries
WHERE source = 'manual'
LIMIT 8;