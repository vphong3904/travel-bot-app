-- ============================================================
-- PDTrip AI — Backfill embedding_jobs cho knowledge_entries hiện có (T-030 prep)
-- Trigger T-027 chỉ kích hoạt cho INSERT/UPDATE SAU KHI tạo trigger.
-- Các entry đã seed TRƯỚC khi tạo trigger cần được backfill tại đây.
--
-- Chạy TRƯỚC khi đặt KNOWLEDGE_SOURCE=db.
-- MIG-07: chỉ bật db mode sau khi embedding đủ và eval pass.
-- ============================================================

INSERT INTO embedding_jobs (entity_type, entity_id, status)
SELECT 'knowledge_entry', ke.id, 'pending'
FROM knowledge_entries ke
WHERE ke.is_active = TRUE
  AND ke.qdrant_id IS NULL
  AND NOT EXISTS (
      SELECT 1 FROM embedding_jobs ej
      WHERE ej.entity_id = ke.id
        AND ej.status IN ('pending','processing','done')
  );

-- Kiểm tra nhanh:
-- SELECT status, count(*) FROM embedding_jobs GROUP BY status;
