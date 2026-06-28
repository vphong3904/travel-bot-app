-- ============================================================
-- PDTrip AI – Schema: destination_view_logs
-- (Tách từ 01_pdtrip_ai_db.sql để dễ quản lý — xem README_INITDB.md)
-- ============================================================
-- [AI] CHATBOT QUALITY CONTROL (chatbot_unanswered_questions,
-- chatbot_flagged_responses) đã CHUYỂN SANG MONGODB.
-- Xem app/db/mongo.py + app/services/log_service.py.
-- ============================================================

-- ============================================================
-- [TRAVEL] DESTINATION_VIEW_LOGS — dedup view_count theo user + ngày
-- Giữ ở Postgres (không chuyển Mongo) vì cần UNIQUE constraint
-- (user_id, destination_id, view_date) đảm bảo ACID khi dedup view count,
-- và có FK quan hệ chặt với users/destinations.
-- ============================================================
CREATE TABLE destination_view_logs (
    id              SERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id  UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    view_date       VARCHAR(10) NOT NULL,   -- 'YYYY-MM-DD'
    created_at      TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT uq_view_per_user_day UNIQUE (user_id, destination_id, view_date)
);
CREATE INDEX idx_view_log_dest ON destination_view_logs(destination_id);

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
