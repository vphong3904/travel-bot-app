-- ============================================================
-- PDTrip AI — Dedupe + UNIQUE constraint chống trùng (T-039)
-- Nguyên nhân trùng: import_hotels/shopping/events/transport + faq/tip dùng
-- INSERT id tự sinh + "ON CONFLICT DO NOTHING" nhưng KHÔNG có unique constraint
-- → mỗi lần chạy seed lại nhân bản. (locations/foods/tours/restaurants dùng
-- uuid5 deterministic + ON CONFLICT(id) nên không trùng.)
--
-- Bước 1: xoá bản trùng (giữ bản cũ nhất theo created_at,id).
-- Bước 2: thêm UNIQUE để seed ON CONFLICT hoạt động + chặn tái diễn.
-- Idempotent: chạy lại không lỗi.
-- ============================================================

BEGIN;

-- ── 1. Dedupe ────────────────────────────────────────────────────────────────
DELETE FROM hotels a USING (
  SELECT id, row_number() OVER (PARTITION BY destination_id, name
                                ORDER BY created_at NULLS FIRST, id) rn FROM hotels
) b WHERE a.id = b.id AND b.rn > 1;

DELETE FROM shopping_places a USING (
  SELECT id, row_number() OVER (PARTITION BY destination_id, name
                                ORDER BY created_at NULLS FIRST, id) rn FROM shopping_places
) b WHERE a.id = b.id AND b.rn > 1;

DELETE FROM destination_events a USING (
  SELECT id, row_number() OVER (PARTITION BY destination_id, name
                                ORDER BY created_at NULLS FIRST, id) rn FROM destination_events
) b WHERE a.id = b.id AND b.rn > 1;

DELETE FROM transport_options a USING (
  SELECT id, row_number() OVER (
            PARTITION BY destination_id, type, COALESCE(provider,''), COALESCE(duration,'')
            ORDER BY created_at NULLS FIRST, id) rn FROM transport_options
) b WHERE a.id = b.id AND b.rn > 1;

DELETE FROM knowledge_entries a USING (
  SELECT id, row_number() OVER (PARTITION BY destination_id, category, title
                                ORDER BY created_at NULLS FIRST, id) rn FROM knowledge_entries
) b WHERE a.id = b.id AND b.rn > 1;

-- Dọn embedding_jobs trỏ tới entry đã xoá
DELETE FROM embedding_jobs ej
WHERE ej.entity_type = 'knowledge_entry'
  AND NOT EXISTS (SELECT 1 FROM knowledge_entries ke WHERE ke.id = ej.entity_id);

-- ── 2. UNIQUE constraint / index (idempotent) ────────────────────────────────
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_hotels_dest_name') THEN
    ALTER TABLE hotels ADD CONSTRAINT uq_hotels_dest_name UNIQUE (destination_id, name);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_shopping_dest_name') THEN
    ALTER TABLE shopping_places ADD CONSTRAINT uq_shopping_dest_name UNIQUE (destination_id, name);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_events_dest_name') THEN
    ALTER TABLE destination_events ADD CONSTRAINT uq_events_dest_name UNIQUE (destination_id, name);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='uq_knowledge_dest_cat_title') THEN
    ALTER TABLE knowledge_entries ADD CONSTRAINT uq_knowledge_dest_cat_title
      UNIQUE (destination_id, category, title);
  END IF;
END $$;

-- transport: dùng unique INDEX với COALESCE để xử lý provider/duration NULL
CREATE UNIQUE INDEX IF NOT EXISTS uq_transport_dest_type_provider
  ON transport_options (destination_id, type, COALESCE(provider,''), COALESCE(duration,''));

COMMIT;

-- Kiểm tra sau khi chạy:
-- SELECT category, count(*) FROM knowledge_entries GROUP BY category;
