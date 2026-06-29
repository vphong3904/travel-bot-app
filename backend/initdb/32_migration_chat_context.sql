-- ============================================================
-- PDTrip AI — Migration: Chat session context + suggested questions (T-034)
-- Lưu kế hoạch itinerary gần nhất cho multi-turn chatbot (CB-4)
-- và suggested_questions để hiện lại khi load lại lịch sử.
-- ============================================================

BEGIN;

-- chat_sessions: lưu itinerary JSON gần nhất để multi-turn chỉnh sửa
ALTER TABLE chat_sessions
    ADD COLUMN IF NOT EXISTS last_itinerary JSONB;

-- chat_messages: lưu gợi ý câu hỏi tiếp theo sinh bởi RAG pipeline
ALTER TABLE chat_messages
    ADD COLUMN IF NOT EXISTS suggested_questions JSONB DEFAULT '[]';

COMMIT;
