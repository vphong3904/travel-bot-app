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

-- ── CONTENT ITEMS (CMS content cho Admin; tách khỏi knowledge_entries) ─────────
-- Mỗi loại (hotel/destination/tour/food...) lưu chung 1 bảng, phân biệt bằng
-- content_type; dữ liệu động lưu trong `data` (JSONB). `city_slug` khớp cities.slug.
-- status draft|published (mobile chỉ đọc published qua API public /content/{type}).
CREATE TABLE content_items (
    id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type VARCHAR(50)  NOT NULL,
    city_slug    VARCHAR(120),
    name         VARCHAR(300) NOT NULL,
    data         JSONB        NOT NULL DEFAULT '{}'::jsonb,
    image_url    TEXT,
    status       VARCHAR(20)  NOT NULL DEFAULT 'draft',
    is_deleted   BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_content_items_type    ON content_items(content_type);
CREATE INDEX idx_content_items_city    ON content_items(city_slug);
CREATE INDEX idx_content_items_created ON content_items(created_at DESC);

-- ── CONTENT OPTIONS (taxonomy: danh sách "loại" theo content_type + field) ─────
-- Admin quản lý options cho dropdown form + nhãn hiển thị. Form đọc động từ đây,
-- thay cho hardcode trong Flutter. Seed ở 13_seed_content_options.sql.
CREATE TABLE content_options (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type VARCHAR(50)  NOT NULL,   -- destinations/foods/restaurants/...
    field        VARCHAR(50)  NOT NULL,   -- type / cuisine_type / goods_type / vehicle...
    code         VARCHAR(100) NOT NULL,   -- giá trị lưu trong data (vd 'nature')
    label        VARCHAR(200) NOT NULL,   -- nhãn hiển thị tiếng Việt (vd 'Thiên nhiên')
    sort_order   INT          NOT NULL DEFAULT 0,
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    UNIQUE (content_type, field, code)
);
CREATE INDEX idx_content_options_lookup ON content_options(content_type, field, is_active);
