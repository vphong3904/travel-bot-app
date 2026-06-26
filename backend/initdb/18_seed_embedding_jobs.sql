-- ============================================================
-- PDTrip AI – Seed: AI embedding_jobs (pending jobs cho knowledge_entries)
-- (Tách từ 01_pdtrip_ai_db.sql để dễ quản lý — xem README_INITDB.md)
-- ============================================================

-- [AI] EMBEDDING JOBS — job mẫu cho các knowledge_entries vừa thêm
-- (worker Python sẽ pick up các job pending để embed + upsert Qdrant)
-- ============================================================
INSERT INTO embedding_jobs (entity_type, entity_id, status)
SELECT 'knowledge_entry', id, 'pending'
FROM knowledge_entries
WHERE source = 'manual';