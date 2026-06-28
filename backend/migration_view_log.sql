-- Migration: thêm bảng destination_view_logs + cột best_months (nếu chưa có)
-- Chạy 1 lần: psql -h localhost -U user -d pdtrip_ai_db -f migration_view_log.sql

-- 1. Bảng dedup view
CREATE TABLE IF NOT EXISTS destination_view_logs (
    id              SERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id  UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    view_date       VARCHAR(10) NOT NULL,   -- 'YYYY-MM-DD'
    created_at      TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT uq_view_per_user_day UNIQUE (user_id, destination_id, view_date)
);
CREATE INDEX IF NOT EXISTS idx_view_log_dest ON destination_view_logs(destination_id);

-- 2. best_months nếu chưa có (safe idempotent)
ALTER TABLE destinations ADD COLUMN IF NOT EXISTS best_months SMALLINT[];

-- 3. Seed best_months cho 11 destination mẫu (idempotent)
UPDATE destinations SET best_months = ARRAY[11,12,1,2,3,4]  WHERE name = 'Đà Lạt'       AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[11,12,1,2,3,4]  WHERE name = 'Phú Quốc'     AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[9,10,11,3,4,5]  WHERE name = 'Hà Giang'     AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[2,3,4]          WHERE name = 'Hội An'       AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[9,10,11,3,4,5]  WHERE name = 'Sa Pa'        AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[3,4,5,10,11]    WHERE name = 'Vịnh Hạ Long' AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[1,2,3,4]        WHERE name = 'Huế'          AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[1,2,3,4,5,6,7,8] WHERE name = 'Nha Trang'   AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[11,12,1,2,3,4]  WHERE name = 'Mũi Né'       AND best_months IS NULL;
UPDATE destinations SET best_months = ARRAY[9,10,11,1,2,3]  WHERE name = 'Ninh Bình'    AND best_months IS NULL;
