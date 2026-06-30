-- ============================================================
-- PDTrip AI — Seed: system_configs mặc định (TA-019)
-- Bảng tạo ở 03_schema_ai.sql; đây chỉ nạp giá trị mặc định.
-- ============================================================

INSERT INTO system_configs (key, value, description) VALUES
    ('chatbot_enabled',    'true',  'Bật/tắt toàn bộ chatbot endpoint'),
    ('gemini_temperature', '0.7',   'Temperature Gemini (0.0-1.0)'),
    ('rag_top_k_default',  '5',     'Số chunks mặc định mỗi query'),
    ('use_reranking',      'true',  'Bật/tắt cross-encoder rerank'),
    ('fallback_to_llm',    'false', 'Cho phép Gemini trả lời khi không có context')
ON CONFLICT (key) DO NOTHING;
