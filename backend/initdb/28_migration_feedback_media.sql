-- TA-017: Add feedback detail columns to chat_messages
ALTER TABLE chat_messages
    ADD COLUMN IF NOT EXISTS feedback_reason      TEXT,
    ADD COLUMN IF NOT EXISTS feedback_category    VARCHAR(50),
    ADD COLUMN IF NOT EXISTS feedback_resolved    BOOLEAN,
    ADD COLUMN IF NOT EXISTS feedback_resolved_by UUID REFERENCES users(id);

-- TA-018: Create media_files table
CREATE TABLE IF NOT EXISTS media_files (
    id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    filename      VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    file_path     TEXT        NOT NULL,
    file_size     INTEGER,
    mime_type     VARCHAR(100),
    width         INTEGER,
    height        INTEGER,
    tags          TEXT[]      DEFAULT '{}',
    is_deleted    BOOLEAN     DEFAULT FALSE,
    uploaded_by   UUID        REFERENCES users(id),
    created_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_media_files_not_deleted ON media_files(created_at DESC) WHERE NOT is_deleted;
