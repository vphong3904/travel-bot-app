-- ============================================================
-- PDTrip AI — Migration 39: Media folders (CMS) + cột ảnh cho content
-- ------------------------------------------------------------
-- 1) media_folders: cây thư mục (root + folder con) cho trình quản lý ảnh.
-- 2) media_files.folder_id: gắn ảnh vào thư mục.
-- 3) Thêm image_url cho các bảng content còn thiếu (restaurants, foods,
--    tickets, destination_events, shopping_places) — phục vụ CMS chọn ảnh.
--
-- Idempotent (MIG-04): IF NOT EXISTS, không sửa/đổi schema cũ.
-- Phụ thuộc: 28_migration_feedback_media.sql (media_files), TA-001 (users).
-- ============================================================

BEGIN;

-- ── 1) media_folders ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS media_folders (
    id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(255) NOT NULL,
    parent_id  UUID         REFERENCES media_folders(id) ON DELETE CASCADE,
    created_by UUID         REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    updated_at TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_media_folders_parent ON media_folders(parent_id);

-- Không trùng tên trong cùng 1 thư mục cha.
-- (parent NULL = thư mục gốc — dùng partial index riêng vì NULL không so sánh được)
CREATE UNIQUE INDEX IF NOT EXISTS uq_media_folders_child_name
    ON media_folders(parent_id, name) WHERE parent_id IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_media_folders_root_name
    ON media_folders(name) WHERE parent_id IS NULL;

-- ── 2) media_files.folder_id ────────────────────────────────
ALTER TABLE media_files
    ADD COLUMN IF NOT EXISTS folder_id UUID REFERENCES media_folders(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_media_files_folder ON media_files(folder_id, created_at DESC);

-- ── 3) image_url cho các bảng content còn thiếu ─────────────
ALTER TABLE restaurants        ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE foods              ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE tickets            ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE destination_events ADD COLUMN IF NOT EXISTS image_url TEXT;
ALTER TABLE shopping_places    ADD COLUMN IF NOT EXISTS image_url TEXT;

COMMIT;

-- Kiểm tra:
-- \d media_folders
-- \d media_files
-- SELECT column_name FROM information_schema.columns
--   WHERE table_name='restaurants' AND column_name='image_url';
