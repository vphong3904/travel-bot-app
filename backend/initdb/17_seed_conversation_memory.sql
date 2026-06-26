-- -- ============================================================
-- -- PDTrip AI – Seed: AI conversation_memory
-- -- (Tách từ 01_pdtrip_ai_db.sql để dễ quản lý — xem README_INITDB.md)
-- -- ============================================================
-- -- search_history & user_behavior seed mẫu đã CHUYỂN SANG MONGODB.
-- -- Chạy: python mongo_seed_logs.py (sau khi docker-compose up -d mongo)
-- -- ============================================================

-- -- [AI] CONVERSATION MEMORY — bộ nhớ AI ghi nhận về user
-- -- ============================================================
-- INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
-- SELECT u.id, 'travel_style', '{"style": "couple", "note": "Thường đi du lịch cùng người yêu, ưu tiên không gian lãng mạn yên tĩnh"}', 0.85
-- FROM users u WHERE u.username = 'tranlan';
 
-- INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
-- SELECT u.id, 'budget', '{"range": "4-5 trieu", "per": "2 nguoi", "note": "Ngân sách tầm trung cho chuyến 3N2Đ"}', 0.8
-- FROM users u WHERE u.username = 'tranlan';
 
-- INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
-- SELECT u.id, 'preference', '{"likes": ["biển", "đảo"], "note": "Quan tâm các điểm đến biển đảo, từng hỏi Phú Quốc và Côn Đảo"}', 0.75
-- FROM users u WHERE u.username = 'minhhieu';
 
-- INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
-- SELECT u.id, 'visited', '{"destinations": ["Hội An", "Phú Quốc"], "note": "Đã từng hỏi review khách sạn bình dân Hội An"}', 0.7
-- FROM users u WHERE u.username = 'minhhieu';
 
-- INSERT INTO conversation_memory (user_id, memory_type, content, confidence)
-- SELECT u.id, 'travel_style', '{"style": "family", "members": 4, "note": "Đi cùng gia đình, có nhu cầu lịch trình nhẹ nhàng"}', 0.82
-- FROM users u WHERE u.username = 'ngochuong';

-- -- ============================================================
