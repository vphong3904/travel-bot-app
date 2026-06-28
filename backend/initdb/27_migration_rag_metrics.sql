-- Migration: TA-007 chat_sessions tags/is_flagged + TA-010 RAG metrics columns
-- Run once against existing DB (idempotent via IF NOT EXISTS / DO blocks)

-- chat_sessions: tags & is_flagged (TA-007 BE)
ALTER TABLE chat_sessions
    ADD COLUMN IF NOT EXISTS tags       TEXT[]  DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS is_flagged BOOLEAN DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS idx_sessions_flagged
    ON chat_sessions(is_flagged)
    WHERE is_flagged = TRUE;

-- chat_messages: RAG metrics (TA-010)
ALTER TABLE chat_messages
    ADD COLUMN IF NOT EXISTS confidence_score FLOAT,
    ADD COLUMN IF NOT EXISTS search_method   VARCHAR(20),
    ADD COLUMN IF NOT EXISTS search_ms       INTEGER,
    ADD COLUMN IF NOT EXISTS llm_ms          INTEGER,
    ADD COLUMN IF NOT EXISTS cache_hit       VARCHAR(10),
    ADD COLUMN IF NOT EXISTS chunk_count     INTEGER;

CREATE INDEX IF NOT EXISTS idx_messages_search_method
    ON chat_messages(search_method)
    WHERE search_method IS NOT NULL;
