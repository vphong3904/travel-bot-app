-- ============================================================
-- PDTrip AI – Extensions & Functions (uuid_generate_v7, trigger updated_at)
-- (Tách từ 01_pdtrip_ai_db.sql để dễ quản lý — xem README_INITDB.md)
-- ============================================================

-- ============================================================
-- PDTrip AI – Database Schema + Seed Data (GỘP TOÀN BỘ)
-- Chatbot AI Tư Vấn Du Lịch Việt Nam
-- Stack: FastAPI + PostgreSQL + Qdrant + LangChain + Gemini
--
-- File này gộp lại từ:
--   01_pdtrip_ai_db.sql                       (schema + seed gốc)
--   02_knowledge_base_extended.sql            (knowledge base mở rộng + bảng tracking câu hỏi chưa trả lời)
--   03_chatbot_flagged_responses.sql          (bảng review câu trả lời nghi vấn)
--   06_knowledge_base_v3_new_destinations.sql (7 điểm đến mới: Hà Nội, Đà Nẵng, TP.HCM,
--                                               Phong Nha, Quy Nhơn, Côn Đảo, Mộc Châu)
-- (File 05_prompt_upgrade_and_comparisons.sql rỗng, không có nội dung để gộp)
--
-- Bố cục:
--   PHẦN 1: SCHEMA  — extension, function, toàn bộ CREATE TABLE theo nhóm
--            [AUTH] → [TRAVEL] → [AI] → [ANALYTICS]
--   PHẦN 2: SEED DATA — dữ liệu mẫu theo đúng thứ tự phụ thuộc khóa ngoại
--
-- Cách dùng:
--   psql -U postgres -c "CREATE DATABASE pdtrip_ai_db"
--   psql -U postgres -d pdtrip_ai_db -f 00_init_pdtrip_ai_db.sql
-- ============================================================

-- ============================================================
-- PDTrip AI – Database Schema (Đồ án tốt nghiệp)
-- Chatbot AI Tư Vấn Du Lịch
-- Stack: FastAPI + PostgreSQL + Qdrant + LangChain + Gemini
-- Scope: 2 người, ~4 tuần
-- ============================================================

-- DROP DATABASE IF EXISTS pdtrip_ai_db;
-- CREATE DATABASE pdtrip_ai_db;
-- \connect pdtrip_ai_db

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- UUIDv7 – time-sortable, RFC 9562 variant bits correct
-- ============================================================
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

-- ============================================================
-- TRIGGER: tự động cập nhật updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION fn_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

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

-- ============================================================
