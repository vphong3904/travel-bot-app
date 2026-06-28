-- ============================================================
-- PDTrip AI – Schema: AI (knowledge_base, embedding_jobs, prompt_templates, chat_sessions, chat_messages, conversation_memory)
-- (Tách từ 01_pdtrip_ai_db.sql để dễ quản lý — xem README_INITDB.md)
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
    embedding      VECTOR(1024),             -- Cache local, chính vẫn ở Qdrant
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
