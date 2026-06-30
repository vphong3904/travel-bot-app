-- ============================================================
-- PDTrip AI – Extensions & Functions
-- Stack: FastAPI + PostgreSQL (pgvector) + Qdrant + Gemini
-- Chạy đầu tiên: extension + helper function dùng chung cho schema.
-- ============================================================

-- ── EXTENSIONS ──────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ── UUIDv7 – time-sortable, RFC 9562 ────────────────────────
CREATE OR REPLACE FUNCTION uuid_generate_v7()
RETURNS UUID
LANGUAGE sql
AS $$
    SELECT encode(
        set_byte(
            set_byte(
                overlay(
                    gen_random_bytes(16)
                    PLACING substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::bigint) FROM 3)
                    FROM 1 FOR 6
                ),
                6, (get_byte(gen_random_bytes(1), 0) & 15) | 112   -- version = 7
            ),
            8, (get_byte(gen_random_bytes(1), 0) & 63) | 128       -- variant = 10xx
        ),
        'hex'
    )::uuid;
$$;

-- ── Trigger updated_at + helper gắn nhanh ───────────────────
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- _attach_updated_at('table'): tạo trigger BEFORE UPDATE gọi fn_set_updated_at.
-- Giữ lại sau khi tạo schema (vô hại) để các seed/migration sau dùng nếu cần.
CREATE OR REPLACE FUNCTION _attach_updated_at(tbl TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    EXECUTE format(
        'CREATE TRIGGER trg_%I_updated
         BEFORE UPDATE ON %I
         FOR EACH ROW EXECUTE FUNCTION fn_set_updated_at()',
        tbl, tbl
    );
END;
$$;
