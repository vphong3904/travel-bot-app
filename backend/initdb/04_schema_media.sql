-- ============================================================
-- PDTrip AI – Schema: MEDIA (trình quản lý ảnh CMS)
-- media_folders (cây thư mục) · media_files (ảnh)
-- (Trước đây: media_files ở migration 28, folders/folder_id ở migration 39.)
-- ============================================================

-- ── MEDIA FOLDERS (cây thư mục; parent_id NULL = thư mục gốc) ─
CREATE TABLE media_folders (
    id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    name       VARCHAR(255) NOT NULL,
    parent_id  UUID         REFERENCES media_folders(id) ON DELETE CASCADE,
    created_by UUID         REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ  DEFAULT NOW(),
    updated_at TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_media_folders_parent ON media_folders(parent_id);
-- Không trùng tên trong cùng thư mục cha (NULL parent xử lý riêng vì NULL không so sánh).
CREATE UNIQUE INDEX uq_media_folders_child_name
    ON media_folders(parent_id, name) WHERE parent_id IS NOT NULL;
CREATE UNIQUE INDEX uq_media_folders_root_name
    ON media_folders(name) WHERE parent_id IS NULL;

-- ── MEDIA FILES (ảnh đã upload; soft delete) ────────────────
CREATE TABLE media_files (
    id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    filename      VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    file_path     TEXT         NOT NULL,
    file_size     INTEGER,
    mime_type     VARCHAR(100),
    width         INTEGER,
    height        INTEGER,
    tags          TEXT[]       DEFAULT '{}',
    is_deleted    BOOLEAN      DEFAULT FALSE,
    folder_id     UUID         REFERENCES media_folders(id) ON DELETE SET NULL,
    uploaded_by   UUID         REFERENCES users(id),
    created_at    TIMESTAMPTZ  DEFAULT NOW()
);
CREATE INDEX idx_media_files_not_deleted ON media_files(created_at DESC) WHERE NOT is_deleted;
CREATE INDEX idx_media_files_folder      ON media_files(folder_id, created_at DESC);
