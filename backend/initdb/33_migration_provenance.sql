-- ============================================================
-- PDTrip AI — Migration: Provenance columns (T-036)
-- Thêm data_source, source_url, verified, verified_at vào các bảng
-- content để mỗi row có nguồn gốc rõ ràng (MIG-11 / RULE-06).
-- Chỉ row có data_source hợp lệ + đã xác minh mới đặt verified=TRUE.
-- ============================================================

BEGIN;

-- destinations
ALTER TABLE destinations
    ADD COLUMN IF NOT EXISTS data_source  TEXT,
    ADD COLUMN IF NOT EXISTS source_url   TEXT,
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ;

-- locations (điểm tham quan — bảng đã có cột verified BOOLEAN nhưng chưa có source)
ALTER TABLE locations
    ADD COLUMN IF NOT EXISTS data_source  TEXT,
    ADD COLUMN IF NOT EXISTS source_url   TEXT,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ;
-- Lưu ý: locations.verified đã tồn tại (khỏi ADD IF NOT EXISTS)

-- hotels
ALTER TABLE hotels
    ADD COLUMN IF NOT EXISTS data_source  TEXT,
    ADD COLUMN IF NOT EXISTS source_url   TEXT,
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ;

-- tours
ALTER TABLE tours
    ADD COLUMN IF NOT EXISTS data_source  TEXT,
    ADD COLUMN IF NOT EXISTS source_url   TEXT,
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ;

-- tickets
ALTER TABLE tickets
    ADD COLUMN IF NOT EXISTS data_source  TEXT,
    ADD COLUMN IF NOT EXISTS source_url   TEXT,
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ;

-- destination_events
ALTER TABLE destination_events
    ADD COLUMN IF NOT EXISTS data_source  TEXT,
    ADD COLUMN IF NOT EXISTS source_url   TEXT,
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ;

-- shopping_places
ALTER TABLE shopping_places
    ADD COLUMN IF NOT EXISTS data_source  TEXT,
    ADD COLUMN IF NOT EXISTS source_url   TEXT,
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ;

-- knowledge_entries: thêm verified flag (source đã có sẵn)
ALTER TABLE knowledge_entries
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS source_url   TEXT;

-- itineraries (mới từ T-020 — đã có source, thêm verified)
ALTER TABLE itineraries
    ADD COLUMN IF NOT EXISTS verified     BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS verified_at  TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS data_source  TEXT;

COMMIT;
