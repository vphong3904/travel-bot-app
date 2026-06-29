-- ============================================================
-- PDTrip AI — Migration: Embedding trigger từ SQL (T-027)
-- Mọi INSERT/UPDATE trên knowledge_entries → tạo embedding_job pending
-- → worker services/embedding_jobs.py xử lý async → upsert Qdrant.
-- ============================================================

BEGIN;

-- Hàm: enqueue embedding job khi knowledge_entries được INSERT hoặc UPDATE content/title
CREATE OR REPLACE FUNCTION fn_enqueue_embedding_job()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    -- Chỉ queue khi row active; UPDATE chỉ trigger khi content/title thay đổi
    IF (TG_OP = 'INSERT' OR
        (TG_OP = 'UPDATE' AND (NEW.content <> OLD.content OR NEW.title <> OLD.title)))
       AND NEW.is_active = TRUE
    THEN
        INSERT INTO embedding_jobs (entity_type, entity_id, status)
        VALUES ('knowledge_entry', NEW.id, 'pending')
        ON CONFLICT DO NOTHING;
    END IF;
    RETURN NEW;
END;
$$;

-- Trigger trên knowledge_entries
DROP TRIGGER IF EXISTS trg_knowledge_embedding ON knowledge_entries;
CREATE TRIGGER trg_knowledge_embedding
    AFTER INSERT OR UPDATE ON knowledge_entries
    FOR EACH ROW EXECUTE FUNCTION fn_enqueue_embedding_job();

COMMIT;
