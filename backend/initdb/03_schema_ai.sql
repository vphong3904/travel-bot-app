-- ============================================================
-- PDTrip AI – Schema: AI / CHAT / KB-config
-- knowledge_entries · embedding_jobs · prompt_templates ·
-- chat_sessions · chat_messages · conversation_memory ·
-- itineraries · itinerary_items · intent_patterns ·
-- locations_alias · system_configs
-- ------------------------------------------------------------
-- Các cột/bảng trước đây thêm bằng migration 27/28/29/30/32 nay gộp tại đây.
-- Trigger enqueue embedding (knowledge_entries) đặt ở hậu-seed
-- 30_triggers_and_backfill.sql để không sinh job khi đang seed.
-- ============================================================

-- ── KNOWLEDGE ENTRIES (RAG) ─────────────────────────────────
CREATE TABLE knowledge_entries (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    title          VARCHAR(300) NOT NULL,
    category       VARCHAR(50)  NOT NULL
                   CHECK (category IN (
                       'destination','hotel','tour','transport','food',
                       'activity','shopping','event','safety','faq','tip'
                   )),
    destination_id UUID         REFERENCES destinations(id) ON DELETE SET NULL,
    city_slug      VARCHAR(80),             -- route theo tỉnh độc lập destination_id
    content        TEXT         NOT NULL,
    tags           TEXT[]       DEFAULT '{}',
    source         VARCHAR(100),            -- kb_md_faq | kb_md_experiences | kb_json_<type> | manual
    qdrant_id      UUID,
    embedding      VECTOR(1024),            -- cache local; chính ở Qdrant
    verified       BOOLEAN      DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    source_url     TEXT,
    is_active      BOOLEAN      DEFAULT TRUE,
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
COMMENT ON COLUMN knowledge_entries.source IS
    'Convention KB→SQL: kb_md_faq | kb_md_experiences | kb_json_<type> (vd kb_json_food).';
CREATE INDEX idx_knowledge_category    ON knowledge_entries(category);
CREATE INDEX idx_knowledge_destination ON knowledge_entries(destination_id);
CREATE INDEX idx_knowledge_city_slug   ON knowledge_entries(city_slug);
CREATE INDEX idx_knowledge_tags        ON knowledge_entries USING GIN(tags);
CREATE INDEX idx_knowledge_fts         ON knowledge_entries
    USING GIN(to_tsvector('simple', title || ' ' || content));
CREATE INDEX idx_knowledge_embedding   ON knowledge_entries
    USING hnsw(embedding vector_cosine_ops);
CREATE INDEX idx_knowledge_active      ON knowledge_entries(is_active) WHERE is_active = TRUE;
-- UNIQUE để seed_kb_to_sql ON CONFLICT (faq/tip) không nhân đôi.
ALTER TABLE knowledge_entries
    ADD CONSTRAINT uq_knowledge_dest_cat_title UNIQUE (destination_id, category, title);
SELECT _attach_updated_at('knowledge_entries');

-- ── EMBEDDING JOBS (queue async embed → Qdrant) ─────────────
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

-- Trigger: INSERT/UPDATE knowledge_entries → enqueue embedding job (T-027).
-- seed_kb_to_sql thêm knowledge_entries → tự tạo job → worker embed → Qdrant.
CREATE OR REPLACE FUNCTION fn_enqueue_embedding_job()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR
        (TG_OP = 'UPDATE' AND (NEW.content <> OLD.content OR NEW.title <> OLD.title)))
       AND NEW.is_active = TRUE
    THEN
        INSERT INTO embedding_jobs (entity_type, entity_id, status)
        VALUES ('knowledge_entry', NEW.id, 'pending')
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_knowledge_embedding ON knowledge_entries;
CREATE TRIGGER trg_knowledge_embedding
    AFTER INSERT OR UPDATE ON knowledge_entries
    FOR EACH ROW EXECUTE FUNCTION fn_enqueue_embedding_job();

-- ── PROMPT TEMPLATES ────────────────────────────────────────
CREATE TABLE prompt_templates (
    id            UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    name          VARCHAR(100) UNIQUE NOT NULL,
    system_prompt TEXT         NOT NULL,
    version       VARCHAR(20)  DEFAULT '1.0',
    is_active     BOOLEAN      DEFAULT TRUE,
    created_at    TIMESTAMPTZ  DEFAULT NOW(),
    updated_at    TIMESTAMPTZ  DEFAULT NOW()
);
SELECT _attach_updated_at('prompt_templates');

-- ── CHAT SESSIONS ───────────────────────────────────────────
CREATE TABLE chat_sessions (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id        UUID         NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title          VARCHAR(300),
    summary        TEXT,
    model_name     VARCHAR(100) DEFAULT 'gemini-1.5-flash',
    total_messages INT          DEFAULT 0,
    total_tokens   INT          DEFAULT 0,
    pinned         BOOLEAN      DEFAULT FALSE,
    is_deleted     BOOLEAN      DEFAULT FALSE,
    -- Admin chat management (TA-007)
    tags           TEXT[]       DEFAULT '{}',
    is_flagged     BOOLEAN      DEFAULT FALSE,
    -- Multi-turn context (T-034): itinerary gần nhất để chỉnh sửa
    last_itinerary JSONB,
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_sessions_user    ON chat_sessions(user_id);
CREATE INDEX idx_sessions_updated ON chat_sessions(user_id, updated_at DESC)
    WHERE is_deleted = FALSE;
CREATE INDEX idx_sessions_pinned  ON chat_sessions(user_id, pinned)
    WHERE pinned = TRUE;
CREATE INDEX idx_sessions_flagged ON chat_sessions(is_flagged) WHERE is_flagged = TRUE;
SELECT _attach_updated_at('chat_sessions');

-- ── CHAT MESSAGES ───────────────────────────────────────────
CREATE TABLE chat_messages (
    id                UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    session_id        UUID        NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    role              VARCHAR(20) NOT NULL CHECK (role IN ('user','assistant','system')),
    content           TEXT        NOT NULL,
    sources           JSONB       DEFAULT '[]',
    intent            VARCHAR(100),
    prompt_tokens     INT         DEFAULT 0,
    completion_tokens INT         DEFAULT 0,
    latency_ms        INT,
    feedback          SMALLINT    CHECK (feedback IN (-1, 1)),
    -- RAG metrics (TA-010)
    confidence_score  FLOAT,
    search_method     VARCHAR(20),
    search_ms         INTEGER,
    llm_ms            INTEGER,
    cache_hit         VARCHAR(10),
    chunk_count       INTEGER,
    -- Feedback detail (TA-017)
    feedback_reason      TEXT,
    feedback_category    VARCHAR(50),
    feedback_resolved    BOOLEAN,
    feedback_resolved_by UUID     REFERENCES users(id),
    -- Suggested follow-up questions (T-034)
    suggested_questions  JSONB    DEFAULT '[]',
    created_at        TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_messages_session ON chat_messages(session_id, created_at);
CREATE INDEX idx_messages_intent  ON chat_messages(intent);
CREATE INDEX idx_messages_search_method ON chat_messages(search_method)
    WHERE search_method IS NOT NULL;

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

-- ── CONVERSATION MEMORY ─────────────────────────────────────
CREATE TABLE conversation_memory (
    id          UUID        PRIMARY KEY DEFAULT uuid_generate_v7(),
    user_id     UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    memory_type VARCHAR(50) NOT NULL
                CHECK (memory_type IN (
                    'preference','budget','visited','interested','travel_style'
                )),
    content     JSONB       NOT NULL DEFAULT '{}',
    confidence  DECIMAL(4,3) DEFAULT 0.8,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_memory_user ON conversation_memory(user_id);
CREATE INDEX idx_memory_type ON conversation_memory(user_id, memory_type);
SELECT _attach_updated_at('conversation_memory');

-- ── ITINERARIES (lịch trình mẫu KB, không thuộc user) ───────
CREATE TABLE itineraries (
    id             UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    destination_id UUID         REFERENCES destinations(id) ON DELETE SET NULL,
    city_slug      VARCHAR(80),
    title          VARCHAR(300) NOT NULL,
    duration_days  SMALLINT     CHECK (duration_days IS NULL OR duration_days >= 1),
    group_type     VARCHAR(50)
                   CHECK (group_type IS NULL OR group_type IN ('solo','couple','family','group')),
    budget_low     INT          CHECK (budget_low  IS NULL OR budget_low  >= 0),
    budget_high    INT          CHECK (budget_high IS NULL OR budget_high >= 0),
    CHECK (budget_high IS NULL OR budget_low IS NULL OR budget_high >= budget_low),
    -- Thống kê chi phí trung bình / người (VND) — ước tính theo số ngày × nhóm.
    cost_transport     INT       CHECK (cost_transport     IS NULL OR cost_transport     >= 0),
    cost_accommodation INT       CHECK (cost_accommodation IS NULL OR cost_accommodation >= 0),
    cost_food          INT       CHECK (cost_food          IS NULL OR cost_food          >= 0),
    cost_activities    INT       CHECK (cost_activities    IS NULL OR cost_activities    >= 0),
    cost_other         INT       CHECK (cost_other         IS NULL OR cost_other         >= 0),
    description    TEXT,
    tags           TEXT[]       DEFAULT '{}',
    source         VARCHAR(100),
    data_source    TEXT,
    verified       BOOLEAN      DEFAULT FALSE,
    verified_at    TIMESTAMPTZ,
    is_active      BOOLEAN      DEFAULT TRUE,
    created_at     TIMESTAMPTZ  DEFAULT NOW(),
    updated_at     TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_itineraries_dest   ON itineraries(destination_id);
CREATE INDEX idx_itineraries_city   ON itineraries(city_slug);
CREATE INDEX idx_itineraries_active ON itineraries(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_itineraries_tags   ON itineraries USING GIN(tags);
SELECT _attach_updated_at('itineraries');

-- ── ITINERARY ITEMS (chi tiết từng hoạt động) ───────────────
-- ref_type/ref_id tham chiếu đa hình locations/hotels/tours/tickets (không FK cứng).
CREATE TABLE itinerary_items (
    id           UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    itinerary_id UUID         NOT NULL REFERENCES itineraries(id) ON DELETE CASCADE,
    day_no       SMALLINT     NOT NULL CHECK (day_no >= 1),
    order_no     SMALLINT     DEFAULT 0,
    time_slot    VARCHAR(50),
    title        VARCHAR(300),
    description  TEXT,
    ref_type     VARCHAR(20)
                 CHECK (ref_type IS NULL OR ref_type IN ('location','hotel','tour','ticket','transport')),
    ref_id       UUID,
    created_at   TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_itinerary_items_itin ON itinerary_items(itinerary_id, day_no, order_no);

-- ── INTENT PATTERNS (keyword nhận diện intent, admin sửa được) ─
CREATE TABLE intent_patterns (
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    intent     VARCHAR(50)  NOT NULL,
    keyword    VARCHAR(200) NOT NULL,
    weight     SMALLINT     DEFAULT 1 CHECK (weight >= 0),
    is_active  BOOLEAN      DEFAULT TRUE,
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    updated_at TIMESTAMPTZ  DEFAULT NOW(),
    UNIQUE (intent, keyword)
);
CREATE INDEX idx_intent_patterns_intent ON intent_patterns(intent);
CREATE INDEX idx_intent_patterns_active ON intent_patterns(is_active) WHERE is_active = TRUE;
SELECT _attach_updated_at('intent_patterns');

-- ── LOCATIONS ALIAS (tên hành chính cũ → slug mới) ──────────
CREATE TABLE locations_alias (
    id         UUID         PRIMARY KEY DEFAULT uuid_generate_v7(),
    old_name   VARCHAR(200) NOT NULL,
    new_slug   VARCHAR(80)  NOT NULL,
    level      VARCHAR(20)  NOT NULL CHECK (level IN ('ward','district','province')),
    is_active  BOOLEAN      DEFAULT TRUE,
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    UNIQUE (old_name, level)
);
CREATE INDEX idx_locations_alias_slug  ON locations_alias(new_slug);
CREATE INDEX idx_locations_alias_level ON locations_alias(level);

-- ── SYSTEM CONFIGS (admin chỉnh runtime, TA-019) ────────────
CREATE TABLE system_configs (
    key         VARCHAR(100) PRIMARY KEY,
    value       JSONB        NOT NULL,
    description TEXT,
    updated_by  UUID         REFERENCES users(id),
    updated_at  TIMESTAMPTZ  DEFAULT NOW()
);
