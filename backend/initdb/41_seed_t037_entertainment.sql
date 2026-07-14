-- ============================================================
-- PDTrip AI — Seed 41: Điểm vui chơi / giải trí (T-037) → locations
-- ------------------------------------------------------------
-- TỰ ĐỘNG SINH bởi scripts/gen_seed_t037_entertainment.py
-- 59 thư mục · 68 điểm. KHÔNG sửa tay — chạy lại script.
-- destination_id resolve qua subquery (slug HOẶC tên thành phố) → an toàn FK.
-- Idempotent: ON CONFLICT (id) DO NOTHING.
-- ============================================================

BEGIN;

-- ── an-giang-phu-quoc (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '898d29a8-36c1-5205-9a38-61cba08da9e5', d.id, 'VinWonders Phú Quốc', 'theme_park', 'Khu Bãi Dài, đặc khu Phú Quốc, tỉnh An Giang', NULL, NULL,
       '9:00–19:30 hằng ngày; Thế giới phiêu lưu 10:00–18:00, công viên nước (Thế giới lốc xoáy) 10:00–17:30', 'Công viên chủ đề lớn nhất Phú Quốc với khu trò chơi cảm giác mạnh, công viên nước, thủy cung, làng bí mật và show Once buổi tối. Vé trọn gói bao gồm toàn bộ trò chơi và show, không phụ phí.', 'Đi cả ngày để chơi hết các phân khu; xem show Once tại lâu đài trung tâm khoảng 18:45.', NULL, TRUE, 'vietnamtourism.gov.vn; Google Maps (tên + toạ độ); Sở Du lịch tỉnh Kiên Giang (nay thuộc An Giang); T-037: VinWonders Phú Quốc — vinwonders.com & Traveloka (2025)'
FROM destinations d WHERE d.slug = 'an-giang-phu-quoc' OR d.name = 'Phú Quốc'
ORDER BY (d.slug = 'an-giang-phu-quoc') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── bac-ninh-bac-giang (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '5dfc22f4-3cfd-5dac-8424-8afa26eb5c67', d.id, 'Khu du lịch Tây Yên Tử (cáp treo)', 'entertainment', 'Thị trấn Tây Yên Tử, huyện Sơn Động, Bắc Giang', NULL, NULL,
       'Cáp treo 7:00–17:00 hằng ngày', 'Khu du lịch tâm linh - sinh thái sườn tây Yên Tử với hệ thống cáp treo lên khu chùa Thượng (đường tùng, chùa Đồng), kết hợp khám phá rừng nguyên sinh Tây Yên Tử.', 'Đi cáp treo để lên nhanh; mùa xuân (lễ hội Tây Yên Tử) đông, nên đi sớm.', NULL, TRUE, 'T-037: Khu du lịch Tây Yên Tử — tayyentu.vn & PYS Travel (2025)'
FROM destinations d WHERE d.slug = 'bac-ninh-bac-giang' OR d.name = 'Bắc Giang'
ORDER BY (d.slug = 'bac-ninh-bac-giang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── bac-ninh-bac-ninh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '8ed35fea-c201-5d89-807d-cf82ae18a669', d.id, 'TiNiWorld Vincom Bắc Ninh', 'kids_zone', 'Tầng 2, TTTM Vincom Plaza Bắc Ninh, khu Ngã 6, phường Kinh Bắc (Suối Hoa cũ), TP. Bắc Ninh', NULL, NULL,
       'T2–T6 10:00–21:30; T7 & Chủ nhật 9:30–21:30', 'Khu vui chơi trong nhà cho trẻ em tại TTTM Vincom với nhà bóng, cầu trượt, trò chơi vận động và khu hóa trang — điểm giải trí cho gia đình có trẻ nhỏ ở trung tâm Bắc Ninh.', 'Mang tất (vớ) cho trẻ theo quy định khu chơi; vé combo cuối tuần có thể khác ngày thường.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn; Cổng thông tin điện tử tỉnh Bắc Ninh: bacninh.gov.vn; Cục Di sản Văn hóa: dsvh.gov.vn; Google Maps (giờ mở cửa tham khảo); T-037: TiNiWorld Vincom Bắc Ninh — VinWonders Wonderpedia & Việt Global (2025)'
FROM destinations d WHERE d.slug = 'bac-ninh-bac-ninh' OR d.name = 'Bắc Ninh'
ORDER BY (d.slug = 'bac-ninh-bac-ninh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── ca-mau-bac-lieu (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '26255885-d5ba-52c4-a277-69011e50c37f', d.id, 'Khu du lịch Nhà Mát Bạc Liêu', 'entertainment', 'Đường Bạch Đằng, phường Nhà Mát, TP. Bạc Liêu (cách trung tâm ~7km)', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Khu du lịch giải trí rộng hơn 21ha ở Bạc Liêu với bãi tắm nhân tạo, công viên trò chơi (tàu lượn siêu tốc, xe điện đụng, nhà cười, rạp phim 6D, đu quay) và khu thương mại - lưu trú.', 'Vé gồm tắm biển + tham quan công viên; nhiều trò chơi cảm giác mạnh trong khu giải trí.', NULL, TRUE, 'T-037: Khu du lịch Nhà Mát — dulichnhamat.vn & Viet Fun Travel (2025)'
FROM destinations d WHERE d.slug = 'ca-mau-bac-lieu' OR d.name = 'Bạc Liêu'
ORDER BY (d.slug = 'ca-mau-bac-lieu') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── ca-mau-ca-mau (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '7b087043-0db6-5a06-921d-e0c66d79fa50', d.id, 'Khu du lịch sinh thái Khai Long', 'entertainment', 'Xã Đất Mũi, huyện Ngọc Hiển, Cà Mau (cách TP. Cà Mau ~130km)', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Khu du lịch sinh thái lớn ở vùng Đất Mũi với bãi biển Khai Long hoang sơ (~230ha), hoa viên 12 con giáp, hồ núi nhân tạo, lâu đài cổ tích và nhiều công trình check-in — kết hợp vui chơi, nghỉ dưỡng và văn hóa địa phương.', 'Kết hợp tham quan Mũi Cà Mau (mốc tọa độ GPS 0001) trong cùng chuyến; đường xa nên đi sớm.', NULL, TRUE, 'vietnamtourism.gov.vn; Google Maps (tọa độ ước tính); Sở Du lịch Cà Mau: camau.gov.vn; T-037: Khu du lịch Khai Long — muicamau.gov.vn & TripAdvisor (2025)'
FROM destinations d WHERE d.slug = 'ca-mau-ca-mau' OR d.name = 'Cà Mau'
ORDER BY (d.slug = 'ca-mau-ca-mau') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── can-tho-can-tho (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '7a251104-0250-5505-8a64-f9f096523c15', d.id, 'Làng du lịch sinh thái Ông Đề', 'entertainment', 'Tổ 26, ấp Mỹ Ái, xã Mỹ Khánh, huyện Phong Điền, TP. Cần Thơ (cách trung tâm ~11km)', NULL, NULL,
       '8:00–18:00 hằng ngày', 'Làng du lịch sinh thái miệt vườn với chèo thuyền tham quan vườn, nhiều trò chơi dân gian (đua heo, bắt cá, cầu khỉ) và ẩm thực đồng quê — điểm vui chơi đậm chất miền Tây.', 'Đi theo nhóm để chơi các trò dân gian; nên liên hệ trước để biết giá vé/combo hiện hành.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026); Sở Du lịch Cần Thơ: cantho.gov.vn (06/2026); Google Maps (06/2026); Foody.vn (06/2026); T-037: Làng du lịch Ông Đề — vietnamtourism.gov.vn & Mia.vn (2025)'
FROM destinations d WHERE d.slug = 'can-tho-can-tho' OR d.name = 'Cần Thơ'
ORDER BY (d.slug = 'can-tho-can-tho') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── can-tho-soc-trang (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '45c41c85-f2c8-5114-be83-0fb8d5d1c21a', d.id, 'Khu văn hóa Hồ Nước Ngọt Sóc Trăng', 'entertainment', 'Số 2 đường Hùng Vương, trung tâm TP. Sóc Trăng', NULL, NULL,
       'Mở cửa tự do hằng ngày (chợ đêm vào buổi tối)', 'Khu văn hóa - giải trí rộng ~20ha quanh hồ nước ngọt giữa trung tâm Sóc Trăng, có khu vui chơi thiếu nhi, chợ đêm, hồ bơi Hoàng Châu, sân khấu ngoài trời và khu hội chợ - triển lãm.', 'Vào cổng thường miễn phí (trừ dịp sự kiện lớn); buổi tối có chợ đêm sôi động.', NULL, TRUE, 'T-037: Khu văn hóa Hồ Nước Ngọt — vietnamtourism.gov.vn & Mia.vn (2025)'
FROM destinations d WHERE d.slug = 'can-tho-soc-trang' OR d.name = 'Sóc Trăng'
ORDER BY (d.slug = 'can-tho-soc-trang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── can-tho-vi-thanh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'd13ef814-378d-52a7-a65f-500bf977eb2d', d.id, 'Khu du lịch sinh thái Mùa Xuân', 'entertainment', '236 Hoàng Hoa Thám, xã Tân Phước Hưng, huyện Phụng Hiệp, Hậu Giang', NULL, NULL,
       'Ban ngày — nên liên hệ trước khi đến', 'Khu du lịch sinh thái ~130ha rừng tràm với hồ nước, vườn cây ăn trái, tháp quan sát chim cùng các hoạt động chèo kayak, trượt dây, leo trèo, xe đạp trên cầu, câu cá và đờn ca tài tử.', 'Liên hệ trước để đặt dịch vụ; trải nghiệm xe điện/xe đạp xuyên rừng tràm và đi vỏ lãi.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Mùa Xuân — dulich.haugiang.gov.vn & Bazaar Vietnam (2025)'
FROM destinations d WHERE d.slug = 'can-tho-vi-thanh' OR d.name = 'Vị Thanh (Hậu Giang)'
ORDER BY (d.slug = 'can-tho-vi-thanh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── da-nang-da-nang (2 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '9704147f-fca8-52d9-ab66-89640a656436', d.id, 'Mikazuki Water Park 365 (Da Nang Mikazuki)', 'water_park', 'Bãi biển Xuân Thiều, đường Nguyễn Tất Thành, phường Hòa Hiệp Nam, quận Liên Chiểu, Đà Nẵng', NULL, NULL,
       '9:00–19:00 hằng ngày', 'Tổ hợp công viên nước kết hợp tắm khoáng nóng Onsen kiểu Nhật bên bãi biển Xuân Thiều: dòng sông lười 450m, bể tạo sóng, khu trượt nước, cùng khu Onsen trong nhà (xông hơi, bể nóng/lạnh) hoạt động quanh năm.', 'Mua vé online thường rẻ hơn quầy; nên dành cả ngày để trải nghiệm cả khu nước ngoài trời và Onsen trong nhà.', NULL, TRUE, 'danangtourism.gov.vn (06/2026); Google Maps (06/2026); T-037: Sun World Da Nang Downtown / Asia Park — sunworld.vn & Klook (2025); T-037: Mikazuki Water Park 365 — Klook & Traveloka (2025)'
FROM destinations d WHERE d.slug = 'da-nang-da-nang' OR d.name = 'Đà Nẵng'
ORDER BY (d.slug = 'da-nang-da-nang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'cf3fa8c1-b955-54bd-9255-9c3c42461267', d.id, 'Công viên Châu Á — Sun World Da Nang Downtown (Asia Park)', 'amusement_park', '1 Phan Đăng Lưu, phường Hòa Cường Bắc, quận Hải Châu, Đà Nẵng', NULL, NULL,
       'Thường mở buổi chiều đến tối (khoảng 15:00–22:00) — xác nhận trước khi đến', 'Công viên giải trí giữa trung tâm Đà Nẵng với vòng quay Sun Wheel cao 115m (top 5 thế giới), nhiều trò chơi cảm giác mạnh và khu công viên văn hóa các nước châu Á thu nhỏ.', 'Đẹp nhất vào buổi tối khi Sun Wheel và toàn khu lên đèn; kết hợp dạo cầu Rồng gần đó.', NULL, TRUE, 'danangtourism.gov.vn (06/2026); Google Maps (06/2026); T-037: Sun World Da Nang Downtown / Asia Park — sunworld.vn & Klook (2025); T-037: Mikazuki Water Park 365 — Klook & Traveloka (2025)'
FROM destinations d WHERE d.slug = 'da-nang-da-nang' OR d.name = 'Đà Nẵng'
ORDER BY (d.slug = 'da-nang-da-nang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── da-nang-hoi-an (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '129b25fd-2619-53b7-9c2a-43f243cfc74a', d.id, 'VinWonders Nam Hội An', 'theme_park', 'Đường Võ Chí Công, khu Nam Hội An (xã Thăng An), Quảng Nam — gần Hội An', NULL, NULL,
       '9:00–19:00 hằng ngày; một số khu (Water World, River Safari) đóng sớm khoảng 17:30', 'Tổ hợp công viên chủ đề lớn gần Hội An gồm 5 khu: River Safari (thú hoang dã bên sông), Đảo Văn hóa Dân gian, Adventure Land (trò chơi cảm giác mạnh), Water World (công viên nước) và Bến cảng giao thương.', 'Đi từ sáng để chơi hết 5 khu; ưu tiên Water World và River Safari buổi sáng vì đóng sớm hơn.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026); Sở Du lịch Đà Nẵng; UNESCO World Heritage (Hội An Ancient Town); Google Maps (xác nhận giờ mở cửa, 06/2026); T-037: VinWonders Nam Hội An — vinwonders.com & Klook (2026)'
FROM destinations d WHERE d.slug = 'da-nang-hoi-an' OR d.name = 'Hội An'
ORDER BY (d.slug = 'da-nang-hoi-an') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── dak-lak-buon-ma-thuot (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '13d83be7-bb55-52cc-832e-08a495edbb6f', d.id, 'Khu du lịch sinh thái KoTam', 'entertainment', '789 Phạm Văn Đồng, TP. Buôn Ma Thuột, Đắk Lắk', NULL, NULL,
       '7:30–18:30 hằng ngày', 'Khu du lịch sinh thái rộng khoảng 13ha với hồ nước, vườn hoa, nhà dài Ê Đê, trải nghiệm văn hóa Tây Nguyên cùng khu vui chơi và ẩm thực — điểm dã ngoại quen thuộc gần Buôn Ma Thuột.', 'Phù hợp dã ngoại gia đình; có biểu diễn cồng chiêng và món ăn đặc trưng Tây Nguyên.', NULL, TRUE, 'Traveloka: traveloka.com/vi-vn (06/2026); MIA.vn — cẩm nang du lịch Đắk Lắk (06/2026); Nam Thiên Travel: namthientravel.com.vn (06/2026); Xanh SM: xanhsm.com/news (06/2026); Vexere blog cẩm nang Buôn Ma Thuột (06/2026); Mường Thanh booking — thông tin Yok Đôn, Buôn Đôn (06/2026); Google Maps (xác nhận khu vực, 06/2026); T-037: Khu du lịch KoTam — Du lịch Việt Du & Xanh SM (2025)'
FROM destinations d WHERE d.slug = 'dak-lak-buon-ma-thuot' OR d.name = 'Buôn Ma Thuột'
ORDER BY (d.slug = 'dak-lak-buon-ma-thuot') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── dak-lak-tuy-hoa (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'e4ec9940-9f1e-5a72-bc89-0b08b8e5f90b', d.id, 'Công viên Hồ Sơn (giải trí dưới nước)', 'entertainment', 'Hồ điều hòa Hồ Sơn, TP. Tuy Hòa, Phú Yên (tỉnh Đắk Lắk)', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Hồ điều hòa giữa lòng TP. Tuy Hòa với các dịch vụ giải trí dưới nước như chèo SUP, kayak, đạp vịt và xe đạp nước — điểm trải nghiệm mới cho người dân và du khách.', 'Đi chiều mát để chèo SUP/kayak ngắm hoàng hôn; dịch vụ tính phí theo lượt.', NULL, TRUE, 'T-037: Công viên Hồ Sơn Tuy Hòa — Báo Phú Yên & Xanh SM (2025)'
FROM destinations d WHERE d.slug = 'dak-lak-tuy-hoa' OR d.name = 'Tuy Hòa (Phú Yên)'
ORDER BY (d.slug = 'dak-lak-tuy-hoa') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── dong-nai-binh-phuoc (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '03bb3a33-66fb-57a3-9a73-b7bf16c957e2', d.id, 'Khu du lịch sinh thái Mỹ Lệ', 'entertainment', 'Đường ĐT741, thôn 1, xã Long Hưng, huyện Phú Riềng, Bình Phước (tỉnh Đồng Nai)', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Khu du lịch sinh thái lớn nhất Bình Phước (~72ha, được công nhận khu du lịch cấp tỉnh) với hồ nước, vườn cây ăn trái, các trò chơi giải trí và dịch vụ nghỉ dưỡng.', 'Có hái trái cây theo mùa; phù hợp dã ngoại gia đình và nhóm bạn.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Mỹ Lệ — binhphuoc.gov.vn & Mia.vn (2025)'
FROM destinations d WHERE d.slug = 'dong-nai-binh-phuoc' OR d.name = 'Bình Phước (Đồng Xoài)'
ORDER BY (d.slug = 'dong-nai-binh-phuoc') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── dong-nai-dong-nai (2 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'e07c042f-bc3f-58aa-9b7d-558b2fd9d050', d.id, 'Khu du lịch Sơn Tiên (The Amazing Bay)', 'theme_park', 'Quốc lộ 51, xã An Hòa, TP. Biên Hòa, Đồng Nai', NULL, NULL,
       'T2–T6 9:00–17:00; T7 & Chủ nhật 9:00–18:00', 'Tổ hợp vui chơi giải trí lớn do tập đoàn Suối Tiên phát triển (~200ha), nổi bật với công viên nước The Amazing Bay nhiều chủ đề cùng các khu trò chơi cảm giác mạnh và không gian văn hóa.', 'Mang đồ bơi để chơi công viên nước The Amazing Bay; cuối tuần mở cửa muộn hơn ngày thường.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026); Sở Du lịch Đồng Nai: dongnai.gov.vn (06/2026); Google Maps (06/2026); Klook VN: klook.com/vi (06/2026); T-037: Khu du lịch Sơn Tiên — Traveloka & Bazaar Vietnam (2025); T-037: Công viên Suối Mơ — Bửu Long & Mia.vn (2025)'
FROM destinations d WHERE d.slug = 'dong-nai-dong-nai' OR d.name = 'Đồng Nai'
ORDER BY (d.slug = 'dong-nai-dong-nai') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'e81de744-e6de-5c5c-8025-1fa09fe665ac', d.id, 'Công viên Suối Mơ', 'entertainment', NULL, NULL, NULL,
       '8:00–18:00 hằng ngày — xác nhận trước khi đến', 'Công viên sinh thái ven khu vực hồ Trị An với thác nước, khu vui chơi cho trẻ em, khu cắm trại và ẩm thực địa phương — điểm dã ngoại cuối tuần gần Biên Hòa.', 'Giá vé thay đổi theo khu vực/dịch vụ; phù hợp nhóm bạn và gia đình cắm trại.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026); Sở Du lịch Đồng Nai: dongnai.gov.vn (06/2026); Google Maps (06/2026); Klook VN: klook.com/vi (06/2026); T-037: Khu du lịch Sơn Tiên — Traveloka & Bazaar Vietnam (2025); T-037: Công viên Suối Mơ — Bửu Long & Mia.vn (2025)'
FROM destinations d WHERE d.slug = 'dong-nai-dong-nai' OR d.name = 'Đồng Nai'
ORDER BY (d.slug = 'dong-nai-dong-nai') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── dong-thap-dong-thap (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '1fce32b6-6268-51b5-89f0-40b53eae4f09', d.id, 'Khu vui chơi Happy Land Hùng Thy', 'entertainment', 'Đối diện 113A đường Hoa, Khóm Tân Hiệp, phường Sa Đéc, TP. Sa Đéc, Đồng Tháp', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Khu vui chơi giải trí miệt vườn nằm tại làng hoa Sa Đéc, phục vụ ẩm thực đồng quê, tham quan check-in và các trò chơi dân gian gần gũi của miền Tây.', 'Kết hợp tham quan làng hoa Sa Đéc và chùa Lá Sen trong cùng chuyến đi.', NULL, TRUE, 'vietnamtourism.gov.vn; Sở VHTTDL tỉnh Đồng Tháp; T-037: Happy Land Hùng Thy — vietnamtourism.gov.vn & dulich.dongthap.gov.vn (2025)'
FROM destinations d WHERE d.slug = 'dong-thap-dong-thap' OR d.name = 'Đồng Tháp'
ORDER BY (d.slug = 'dong-thap-dong-thap') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── gia-lai-pleiku (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '6d157ced-c9e4-573f-a642-a0741fbd9724', d.id, 'Công viên Đồng Xanh', 'entertainment', 'Thôn 5, xã An Phú, TP. Pleiku, Gia Lai', NULL, NULL,
       '7:00–17:15 hằng ngày', 'Công viên văn hóa Tây Nguyên ở Pleiku với vườn hoa, vườn thú mini, công viên nước mùa hè cùng nhiều tiểu cảnh check-in và không gian văn hóa cồng chiêng.', 'Mùa hè có công viên nước cho trẻ; nhiều góc chụp hoa và tiểu cảnh đẹp.', NULL, TRUE, 'T-037: Công viên Đồng Xanh — gialaitourist.com.vn & Xanh SM (2025)'
FROM destinations d WHERE d.slug = 'gia-lai-pleiku' OR d.name = 'Pleiku'
ORDER BY (d.slug = 'gia-lai-pleiku') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── gia-lai-quy-nhon (2 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '13fdc86a-4212-51d0-bb8b-07cedf007644', d.id, 'Seagate Park (Khu vui chơi Cửa Biển)', 'entertainment', 'Phía Bắc cầu Thị Nại, khu Nhơn Hội, TP. Quy Nhơn, Bình Định (tỉnh Gia Lai)', NULL, NULL,
       'Theo lịch khu vui chơi — xác nhận trước khi đến', 'Tổ hợp vui chơi ngoài trời ở Quy Nhơn với hàng chục trò chơi vận động như leo núi, bắn cung, cầu tuột, cưỡi bò tót — điểm giải trí cho nhóm bạn và gia đình.', 'Phù hợp nhóm bạn trẻ thích vận động; nên đi buổi chiều cho mát.', NULL, TRUE, 'T-037: Seagate Park & FLC Zoo Safari Quy Nhơn — BestPrice & Xanh SM / FLC Resorts (2025)'
FROM destinations d WHERE d.slug = 'gia-lai-quy-nhon' OR d.name = 'Quy Nhơn (Bình Định)'
ORDER BY (d.slug = 'gia-lai-quy-nhon') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '007e18ed-2afa-5495-af82-ac54457bdbb4', d.id, 'FLC Zoo Safari Park Quy Nhơn', 'zoo', 'Khu 4, xã Nhơn Lý, TP. Quy Nhơn, Bình Định (tỉnh Gia Lai)', NULL, NULL,
       'Theo lịch quần thể FLC — xác nhận trước khi đến', 'Công viên bán hoang dã trong quần thể FLC Quy Nhơn với hơn 1.000 cá thể động vật thuộc nhiều loài — điểm tham quan, vui chơi cho gia đình.', 'Kết hợp tham quan quần thể FLC và các bãi biển Nhơn Lý, Kỳ Co lân cận.', NULL, TRUE, 'T-037: Seagate Park & FLC Zoo Safari Quy Nhơn — BestPrice & Xanh SM / FLC Resorts (2025)'
FROM destinations d WHERE d.slug = 'gia-lai-quy-nhon' OR d.name = 'Quy Nhơn (Bình Định)'
ORDER BY (d.slug = 'gia-lai-quy-nhon') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── ha-noi-ha-noi (3 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '8bf8a346-6c00-5b39-a3ec-388428ce4ab8', d.id, 'Công viên nước Hồ Tây', 'water_park', '614 đường Lạc Long Quân, phường Nhật Tân, quận Tây Hồ, Hà Nội', NULL, NULL,
       'Hoạt động theo mùa hè (khoảng tháng 4–9), thường 9:00–19:00; có thể thay đổi theo thời tiết — xác nhận trước khi đến', 'Công viên nước lớn bậc nhất Hà Nội nằm bên bờ Hồ Tây, có bể tạo sóng, dòng sông lười, nhiều đường trượt cảm giác mạnh và khu vui chơi cho trẻ em — điểm giải trí mùa hè quen thuộc của người dân thủ đô.', 'Cuối tuần mùa hè rất đông, nên đi sớm. Mang theo đồ bơi; công viên không cho mang đồ ăn, thức uống từ ngoài vào.', NULL, TRUE, 'Kiến thức địa danh Hà Nội phổ biến đã xác minh tên/địa chỉ thật; vietnamtourism.gov.vn (tham khảo tên địa điểm); Giá vé là ước tính thị trường — cần xác minh lại từ Klook/Traveloka trước production; T-037 điểm vui chơi: congvienhotay.vn (06/2026); T-037 điểm vui chơi: vinwonders.com — VinKE & Thủy cung Times City (06/2026); T-037 điểm vui chơi: Klook VN klook.com/vi (06/2026); T-037 điểm vui chơi: baosonparadise.vn — Thiên đường Bảo Sơn (09/2025)'
FROM destinations d WHERE d.slug = 'ha-noi-ha-noi' OR d.name = 'Hà Nội'
ORDER BY (d.slug = 'ha-noi-ha-noi') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '18f2c5d8-e7e2-5166-8ea6-72f856585df7', d.id, 'VinKE & Vinpearl Aquarium (Thủy cung Times City)', 'aquarium', 'Tầng B1, Vincom Mega Mall Times City, 458 Minh Khai, quận Hai Bà Trưng, Hà Nội', NULL, NULL,
       'Thứ 2–Thứ 6: 10:00–22:00; cuối tuần & ngày lễ: 9:30–22:00', 'Tổ hợp thủy cung rộng ~4.000m² với hơn 30.000 sinh vật biển (có chim cánh cụt, cua nhện) cùng các show Ocean Dance, Mermaid; liền kề là VinKE — khu vui chơi giáo dục, trò chơi và trải nghiệm hướng nghiệp cho trẻ em.', 'Mua vé online (Klook/VinWonders) thường rẻ hơn quầy. Đi cả thủy cung và VinKE nên chọn vé combo và dành nửa ngày.', NULL, TRUE, 'Kiến thức địa danh Hà Nội phổ biến đã xác minh tên/địa chỉ thật; vietnamtourism.gov.vn (tham khảo tên địa điểm); Giá vé là ước tính thị trường — cần xác minh lại từ Klook/Traveloka trước production; T-037 điểm vui chơi: congvienhotay.vn (06/2026); T-037 điểm vui chơi: vinwonders.com — VinKE & Thủy cung Times City (06/2026); T-037 điểm vui chơi: Klook VN klook.com/vi (06/2026); T-037 điểm vui chơi: baosonparadise.vn — Thiên đường Bảo Sơn (09/2025)'
FROM destinations d WHERE d.slug = 'ha-noi-ha-noi' OR d.name = 'Hà Nội'
ORDER BY (d.slug = 'ha-noi-ha-noi') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '56e5b797-1b05-5307-aa12-0acd01eae984', d.id, 'Công viên Thiên đường Bảo Sơn', 'theme_park', 'Km5+200 đường Lê Trọng Tấn, xã An Khánh, huyện Hoài Đức, Hà Nội', NULL, NULL,
       '8:00–17:00 (Thứ 3–Chủ nhật), đóng cửa Thứ 2; lịch có thể thay đổi theo mùa — xác nhận trước khi đến', 'Công viên chủ đề lớn ở phía tây Hà Nội gồm thủy cung 4 tầng, khu Safari thế giới động vật, nông trại vui vẻ cho trẻ làm nông dân nhí và khu tái hiện làng nghề truyền thống Việt Nam.', 'Phù hợp gia đình có trẻ nhỏ, nên đi trọn ngày. Cuối tuần giá vé cao hơn ngày thường; kiểm tra lịch hoạt động trước vì đóng cửa Thứ 2.', NULL, TRUE, 'Kiến thức địa danh Hà Nội phổ biến đã xác minh tên/địa chỉ thật; vietnamtourism.gov.vn (tham khảo tên địa điểm); Giá vé là ước tính thị trường — cần xác minh lại từ Klook/Traveloka trước production; T-037 điểm vui chơi: congvienhotay.vn (06/2026); T-037 điểm vui chơi: vinwonders.com — VinKE & Thủy cung Times City (06/2026); T-037 điểm vui chơi: Klook VN klook.com/vi (06/2026); T-037 điểm vui chơi: baosonparadise.vn — Thiên đường Bảo Sơn (09/2025)'
FROM destinations d WHERE d.slug = 'ha-noi-ha-noi' OR d.name = 'Hà Nội'
ORDER BY (d.slug = 'ha-noi-ha-noi') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── ha-tinh-ha-tinh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'd04a8d80-3f2d-5c13-a727-ef793d63f7e4', d.id, 'Công viên nước VinWonders Hà Tĩnh', 'water_park', 'Cửa Sót, xã Thịnh Lộc, huyện Lộc Hà, Hà Tĩnh', NULL, NULL,
       '9:00–18:00 hằng ngày (hoạt động theo mùa)', 'Công viên nước lớn nhất khu vực Bắc Trung Bộ tại Hà Tĩnh với nhiều đường trượt, bể tạo sóng và khu trò chơi dưới nước cho gia đình.', 'Hoạt động theo mùa hè; mua vé online thường có ưu đãi.', NULL, TRUE, 'T-037: Công viên nước VinWonders Hà Tĩnh — vinwonders.com & PYS Travel (2025)'
FROM destinations d WHERE d.slug = 'ha-tinh-ha-tinh' OR d.name = 'Hà Tĩnh'
ORDER BY (d.slug = 'ha-tinh-ha-tinh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── hai-phong-hai-duong (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '5994c066-0988-5ed8-acc0-fb67560633d0', d.id, 'Khu sinh thái Đảo Cò Chi Lăng Nam', 'entertainment', 'Xã Chi Lăng Nam (nay xã Nam Thanh Miện), huyện Thanh Miện, Hải Dương', NULL, NULL,
       'Ban ngày — đẹp nhất sáng sớm và chiều tối', 'Khu du lịch sinh thái trên hồ An Dương rộng ~69ha, nơi cư trú của hàng vạn cò, vạc; trải nghiệm đi thuyền quanh đảo ngắm chim — danh lam thắng cảnh cấp quốc gia của Hải Dương.', 'Đi tháng 9–4 khi cò vạc tụ về đông; ngắm chim lúc sáng sớm hoặc chiều tối khi chúng bay về tổ.', NULL, TRUE, 'T-037: Đảo Cò Chi Lăng Nam — vietnamtourism.gov.vn & VinWonders Wonderpedia (2025)'
FROM destinations d WHERE d.slug = 'hai-phong-hai-duong' OR d.name = 'Hải Dương'
ORDER BY (d.slug = 'hai-phong-hai-duong') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── hai-phong-hai-phong (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'da2b8a58-de97-5b55-8fb2-9b8e1eafff77', d.id, 'Hòn Dấu Resort (công viên nước Đồ Sơn)', 'entertainment', 'Khu 3, phường Vạn Hương, quận Đồ Sơn, TP. Hải Phòng (cách trung tâm ~27km)', NULL, NULL,
       'Công viên nước hoạt động theo mùa hè — xác nhận trước khi đến', 'Khu nghỉ dưỡng - vui chơi ở Đồ Sơn với công viên nước lọc nước biển (cầu trượt, nhà phao, mê cung mini) và quần thể kiến trúc mô phỏng lâu đài, phố cổ châu Âu để check-in.', 'Công viên nước đông vào cuối tuần hè; kết hợp tham quan khu kiến trúc châu Âu để chụp ảnh.', NULL, TRUE, 'T-037: Hòn Dấu Resort — vietnamtourism.gov.vn & hondauresort.com (2025)'
FROM destinations d WHERE d.slug = 'hai-phong-hai-phong' OR d.name = 'Hải Phòng'
ORDER BY (d.slug = 'hai-phong-hai-phong') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── hue-hue (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '75e49225-c4f2-5450-be89-b03b62858088', d.id, 'Suối khoáng nóng Alba Thanh Tân', 'water_park', 'Xã Phong Sơn, huyện Phong Điền, Huế (cách trung tâm Huế ~30km về phía Tây Bắc)', NULL, NULL,
       'Mở cửa ban ngày theo lịch khu nghỉ — nên đặt trước và xác nhận giờ trước khi đến', 'Khu suối khoáng nóng (nhiệt độ tới ~68°C) kết hợp công viên nước, zipline, hệ thống highwire và làng nghề Alba — điểm vui chơi, ngâm khoáng và thư giãn gần Huế.', 'Chọn combo gồm vé vào + công viên nước + 1 lượt zipline + ăn trưa sẽ tiết kiệm; nhớ mang đồ bơi.', NULL, TRUE, 'Trung tâm Bảo tồn Di tích Cố đô Huế: hueworldheritage.org.vn (06/2025); luhanhvietnam.com.vn — Giá vé tham quan Huế 2025 (06/2025); sovaba.travel — Giá vé lăng tẩm Huế 2026 (02/2026); daivietourist.vn — Giá vé tham quan Huế (06/2025); Vietnam Tourism: vietnamtourism.gov.vn; T-037: Suối khoáng nóng Alba Thanh Tân — eholiday & BestPrice (2026)'
FROM destinations d WHERE d.slug = 'hue-hue' OR d.name = 'Huế'
ORDER BY (d.slug = 'hue-hue') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── hung-yen-hung-yen (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '0df0f9e2-2210-560f-b81a-d667b55a755a', d.id, 'Công viên hồ Thiên Nga (Ecopark Swan Lake)', 'entertainment', 'Khu đô thị Ecopark, xã Xuân Quan, huyện Văn Giang, Hưng Yên', NULL, NULL,
       'Ban ngày; chợ phiên EcoSunday T7 17:00–22:00, CN 7:00–15:00', 'Tổ hợp công viên xanh trong khu đô thị Ecopark với hồ Thiên Nga (~50ha nuôi thiên nga), 4 công viên theo mùa, chèo kayak, bể bơi, cắm trại và chợ phiên cuối tuần.', 'Tham quan khu đô thị miễn phí; vào công viên Mùa Xuân/khu trò chơi mới tính phí.', NULL, TRUE, 'T-037: Công viên hồ Thiên Nga — Ecopark Swan Lake — Ecoparker & Traveloka (2025)'
FROM destinations d WHERE d.slug = 'hung-yen-hung-yen' OR d.name = 'Hưng Yên'
ORDER BY (d.slug = 'hung-yen-hung-yen') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── hung-yen-thai-binh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '85bc2dea-ab59-580c-9ab1-bf236e88ec05', d.id, 'Khu du lịch sinh thái biển Cồn Vành', 'entertainment', 'Xã Nam Phú, huyện Tiền Hải, Thái Bình (cách TP. Thái Bình ~25km)', NULL, NULL,
       'Mở cửa tự do 24/7', 'Khu du lịch sinh thái biển với bãi tắm Cồn Vành hoang sơ dài ~6km và rừng ngập mặn phong phú; trải nghiệm cào ngao cùng ngư dân và thưởng thức hải sản tươi.', 'Đi mùa hè (tháng 4–9); trải nghiệm cào ngao và ăn hải sản ngay tại chỗ.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Cồn Vành — dulichthaibinh.gov.vn & Traveloka (2025)'
FROM destinations d WHERE d.slug = 'hung-yen-thai-binh' OR d.name = 'Thái Bình'
ORDER BY (d.slug = 'hung-yen-thai-binh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── khanh-hoa-nha-trang (3 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'e51076a0-fd19-51e4-a785-75f1b57dbafe', d.id, 'Skylight Nha Trang (Đài quan sát 360°)', 'entertainment', 'Tầng 43, khách sạn Premier Havana, 38 Trần Phú, phường Lộc Thọ, Nha Trang, Khánh Hòa', NULL, NULL,
       'Thứ 3–Chủ nhật; Skydeck 360° 17:00–23:30; Rooftop Beach Club 17:00–00:45 — xác nhận trước khi đến', 'Đài quan sát 360° đầu tiên của Nha Trang trên tầng cao khách sạn Havana, có sàn kính Skywalk và Rooftop Beach Club, nơi ngắm toàn cảnh vịnh Nha Trang, thành phố và đồi núi lúc hoàng hôn về đêm.', 'Lên lúc chiều tối để xem hoàng hôn rồi ở lại cảnh đêm. Vé vào đã kèm 1 welcome drink; đi giày thoải mái cho sàn kính.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026); Google Maps (06/2026); Klook VN: klook.com/vi (06/2026); Sở Du lịch Khánh Hòa: khanhhoa.gov.vn (06/2026); T-037 điểm vui chơi: skylightnhatrang.com & KKday (06/2026); T-037 điểm vui chơi: vinwonders.com & Traveloka — Nhà hát Đó / Rối Mơ (2026); T-037 điểm vui chơi: galina.vn & Klook — Galina Mud Bath (06/2026)'
FROM destinations d WHERE d.slug = 'khanh-hoa-nha-trang' OR d.name = 'Nha Trang'
ORDER BY (d.slug = 'khanh-hoa-nha-trang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'e307d6d7-4877-5e12-9ea1-c88fdca7d918', d.id, 'Nhà hát Đó — Show Rối Mơ (Life Puppets)', 'entertainment', 'Nhà hát Đó, Vega City Nha Trang, khu Bãi Tiên, phường Vĩnh Hòa, Nha Trang, Khánh Hòa', NULL, NULL,
       'Suất diễn buổi tối theo lịch (thường khoảng 18:00 hoặc 19:30), thời lượng ~60 phút — đặt vé trước để xác nhận suất', 'Nhà hát biểu tượng hình chiếc đó (ngư cụ truyền thống) tại Vega City, nơi trình diễn show Rối Mơ kết hợp rối nước, rối dây, rối bóng và múa đương đại cùng nhạc sống — một trải nghiệm nghệ thuật văn hóa bản địa nổi bật của Nha Trang.', 'Đặt vé trước qua kênh chính thức vì hay kín chỗ dịp cao điểm. Đến sớm để chụp ảnh kiến trúc nhà hát bên biển lúc hoàng hôn.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026); Google Maps (06/2026); Klook VN: klook.com/vi (06/2026); Sở Du lịch Khánh Hòa: khanhhoa.gov.vn (06/2026); T-037 điểm vui chơi: skylightnhatrang.com & KKday (06/2026); T-037 điểm vui chơi: vinwonders.com & Traveloka — Nhà hát Đó / Rối Mơ (2026); T-037 điểm vui chơi: galina.vn & Klook — Galina Mud Bath (06/2026)'
FROM destinations d WHERE d.slug = 'khanh-hoa-nha-trang' OR d.name = 'Nha Trang'
ORDER BY (d.slug = 'khanh-hoa-nha-trang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'fb38c15a-3e07-56bb-be55-da90b74aa666', d.id, 'Galina Mud Bath & Spa (Tắm bùn khoáng)', 'entertainment', 'Tầng 4, khách sạn Galina, số 5 Hùng Vương, Nha Trang, Khánh Hòa', NULL, NULL,
       '9:00–18:00 hằng ngày; nên đặt trước tối thiểu 2 giờ', 'Khu tắm bùn khoáng nóng ngay trung tâm Nha Trang với bồn jacuzzi, xông hơi và hồ khoáng, cách biển và chợ đêm vài phút — lựa chọn thư giãn tiện lợi không phải ra ngoại ô.', 'Đặt trước để giữ chỗ; mang theo đồ bơi. Tắm bùn xong nên nghỉ ngơi, uống nhiều nước trước khi ra biển.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026); Google Maps (06/2026); Klook VN: klook.com/vi (06/2026); Sở Du lịch Khánh Hòa: khanhhoa.gov.vn (06/2026); T-037 điểm vui chơi: skylightnhatrang.com & KKday (06/2026); T-037 điểm vui chơi: vinwonders.com & Traveloka — Nhà hát Đó / Rối Mơ (2026); T-037 điểm vui chơi: galina.vn & Klook — Galina Mud Bath (06/2026)'
FROM destinations d WHERE d.slug = 'khanh-hoa-nha-trang' OR d.name = 'Nha Trang'
ORDER BY (d.slug = 'khanh-hoa-nha-trang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── khanh-hoa-phan-rang (2 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '2a742990-0adb-5edf-bf40-dccae708834c', d.id, 'Khu du lịch Tanyoli', 'entertainment', 'Xã Phước Dinh, huyện Ninh Phước, Ninh Thuận (tỉnh Khánh Hòa)', NULL, NULL,
       'Theo lịch khu du lịch — xác nhận trước khi đến', 'Khu cắm trại phong cách du mục Mông Cổ với lều trắng, đồng cừu và đồi cát, có các hoạt động bắn cung, chèo kayak trên hồ, cưỡi ngựa và zipline — điểm check-in, vui chơi nổi bật ở Ninh Thuận.', 'Đẹp nhất lúc chiều khi nắng dịu; mang giày phù hợp để đi trên đồi cát.', NULL, TRUE, 'vietnamtourism.gov.vn; Sở Văn hóa Thể thao và Du lịch Ninh Thuận - Khánh Hòa; T-037: Khu du lịch Tanyoli — VinWonders Wonderpedia & Ninh Thuận Green (2025); T-037: Công viên nước TTC Resort Ninh Chữ — TTC Hospitality & Booking.com (2025)'
FROM destinations d WHERE d.slug = 'khanh-hoa-phan-rang' OR d.name = 'Khánh Hòa - Phan Rang'
ORDER BY (d.slug = 'khanh-hoa-phan-rang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '66d2d973-9652-5a78-b933-742818b0861e', d.id, 'Công viên nước TTC Resort (Ninh Chữ)', 'water_park', 'Biển Ninh Chữ, đường Yên Ninh, Văn Hải, TP. Phan Rang - Tháp Chàm, Ninh Thuận', NULL, NULL,
       '8:00–18:00 hằng ngày', 'Công viên nước trong khuôn viên TTC Resort sát biển Ninh Chữ với các đường trượt, hồ bơi và khu vui chơi dưới nước — điểm giải nhiệt cho gia đình ở Phan Rang.', 'Vé đã gồm nước khoáng, ghế và ô che nắng, gửi xe miễn phí.', NULL, TRUE, 'vietnamtourism.gov.vn; Sở Văn hóa Thể thao và Du lịch Ninh Thuận - Khánh Hòa; T-037: Khu du lịch Tanyoli — VinWonders Wonderpedia & Ninh Thuận Green (2025); T-037: Công viên nước TTC Resort Ninh Chữ — TTC Hospitality & Booking.com (2025)'
FROM destinations d WHERE d.slug = 'khanh-hoa-phan-rang' OR d.name = 'Khánh Hòa - Phan Rang'
ORDER BY (d.slug = 'khanh-hoa-phan-rang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── lai-chau-lai-chau (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '8b3f4394-d0ff-5842-9c4c-235385670d3b', d.id, 'Khu du lịch Cầu kính Rồng Mây', 'entertainment', 'QL4D, đèo Ô Quy Hồ, xã Sơn Bình, huyện Tam Đường, Lai Châu (gần Sa Pa)', NULL, NULL,
       '7:30–18:00 hằng ngày', 'Khu du lịch sinh thái với hệ thống thang máy lồng kính và cầu kính cao nhất Việt Nam bên đèo Ô Quy Hồ — điểm săn mây, check-in giữa mây trời Tây Bắc, kèm trò xích đu mạo hiểm.', 'Đi sáng sớm hoặc khi trời quang để săn mây; có vé xích đu trải nghiệm riêng.', NULL, TRUE, 'T-037: Cầu kính Rồng Mây — caukinhrongmay.net & dulich.laichau.gov.vn (2025)'
FROM destinations d WHERE d.slug = 'lai-chau-lai-chau' OR d.name = 'Lai Châu'
ORDER BY (d.slug = 'lai-chau-lai-chau') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── lam-dong-da-lat (2 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '3b888dac-f98e-55c0-82ed-9fd1889a51b3', d.id, 'Đường hầm điêu khắc Đất sét Đà Lạt (Clay Tunnel)', 'entertainment', 'Khu hồ Tuyền Lâm, cách trung tâm Đà Lạt khoảng 7km hướng Đông Bắc, Lâm Đồng', NULL, NULL,
       '7:30–17:30 hằng ngày', 'Công trình độc đáo được điêu khắc hoàn toàn bằng đất sét, tái hiện lịch sử hình thành Đà Lạt qua các tiểu cảnh, kèm nhiều góc check-in và ngôi nhà đất sét từng lập kỷ lục.', 'Kết hợp tham quan hồ Tuyền Lâm gần đó; đi buổi sáng mát mẻ và ít đông.', NULL, TRUE, 'manual_curated; T-037: Đường hầm điêu khắc & Thung lũng Tình Yêu — Klook & Hoa Đà Lạt Travel (2025)'
FROM destinations d WHERE d.slug = 'lam-dong-da-lat' OR d.name = 'Đà Lạt'
ORDER BY (d.slug = 'lam-dong-da-lat') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'f8614131-eb27-5c10-9e7c-5478a736673f', d.id, 'Thung lũng Tình Yêu (Valley of Love)', 'amusement_park', 'Cách trung tâm Đà Lạt khoảng 5km hướng Đông Bắc, Phường 8, Đà Lạt, Lâm Đồng', NULL, NULL,
       'Khoảng 7:00–17:00 — xác nhận trước khi đến', 'Khu du lịch thung lũng rộng giữa rừng thông và hồ nước, có cầu tình yêu, đồi vọng nguyệt, vườn hoa cùng dịch vụ thuyền, đạp vịt và tàu điện tham quan.', 'Vé trọn gói đã gồm thuyền/đạp vịt và tàu điện; mặc ấm nếu đi sáng sớm.', NULL, TRUE, 'manual_curated; T-037: Đường hầm điêu khắc & Thung lũng Tình Yêu — Klook & Hoa Đà Lạt Travel (2025)'
FROM destinations d WHERE d.slug = 'lam-dong-da-lat' OR d.name = 'Đà Lạt'
ORDER BY (d.slug = 'lam-dong-da-lat') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── lam-dong-dak-nong (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'dfa580e4-5b2e-503a-b29d-e7bfb0e848e9', d.id, 'Khu du lịch sinh thái Phước Sơn', 'entertainment', 'Thôn 13, xã Đắk Wer, huyện Đắk R''Lấp, Đắk Nông', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Khu du lịch sinh thái ở Đắk Nông với hệ thống ao hồ, vườn hoa, chòi câu cá, nhà thờ vua Hùng và nhà hàng — điểm dã ngoại, câu cá thư giãn gần Gia Nghĩa.', 'Mùa khô (tháng 11–4) đẹp nhất; trải nghiệm câu cá tại hồ và chụp ảnh vườn hoa.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Phước Sơn — dulich.daknong.gov.vn & Lữ Hành Việt Nam (2025)'
FROM destinations d WHERE d.slug = 'lam-dong-dak-nong' OR d.name = 'Đắk Nông (Gia Nghĩa)'
ORDER BY (d.slug = 'lam-dong-dak-nong') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── lam-dong-mui-ne (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '998d7559-5b42-5501-bb49-7d2e94c1a3cb', d.id, 'Bàu Trắng — Bàu Sen (đồi cát trắng)', 'entertainment', 'Xã Hòa Thắng, huyện Bắc Bình, tỉnh Bình Thuận (tỉnh Lâm Đồng), cách Mũi Né ~35km', NULL, NULL,
       'Tham quan cả ngày; dịch vụ xe jeep/trượt cát ban ngày — đẹp nhất sáng sớm hoặc chiều muộn', 'Quần thể đồi cát trắng bên hồ sen (Bàu Sen) với các trải nghiệm vui chơi: trượt cát, xe jeep địa hình vượt đồi, mô tô địa hình và cưỡi lạc đà chụp ảnh — ''tiểu sa mạc'' nổi tiếng của Bình Thuận.', 'Vào cửa miễn phí; nên thỏa thuận giá dịch vụ trước. Đi sáng sớm hoặc chiều muộn để tránh nắng và có ánh sáng đẹp.', NULL, TRUE, 'vietnamtourism.gov.vn; Google Maps; T-037: Bàu Trắng — Bàu Sen — Du lịch Bình Thuận & SaigonStar Travel (2025)'
FROM destinations d WHERE d.slug = 'lam-dong-mui-ne' OR d.name = 'Mũi Né'
ORDER BY (d.slug = 'lam-dong-mui-ne') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── lang-son-lang-son (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '46551d19-ea19-5a5c-93eb-186daa2bcc6d', d.id, 'Khu vui chơi Phú Lộc Plaza', 'kids_zone', 'TTTM Phú Lộc Plaza, khu đô thị Phú Lộc 4, phường Hoàng Văn Thụ, TP. Lạng Sơn', NULL, NULL,
       'Theo giờ trung tâm thương mại — xác nhận trước khi đến', 'Khu vui chơi trong nhà ở trung tâm Lạng Sơn với công viên nước trong nhà, nhà bóng liên hoàn, sàn nhún trampoline, cầu trượt cầu vồng và hơn 60 trò chơi cho trẻ em.', 'Mang tất (vớ) cho trẻ; phù hợp gia đình có trẻ nhỏ vào những ngày thời tiết lạnh.', NULL, TRUE, 'T-037: Khu vui chơi Phú Lộc Plaza — Phú Lộc Plaza & Công ty thiết kế khu vui chơi (2025)'
FROM destinations d WHERE d.slug = 'lang-son-lang-son' OR d.name = 'Lạng Sơn'
ORDER BY (d.slug = 'lang-son-lang-son') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── lao-cai-sapa (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '7bdcc6d4-db68-538c-9bed-0bf2e480b07d', d.id, 'Sun World Fansipan Legend (Cáp treo & khu vui chơi)', 'entertainment', 'Thị xã Sa Pa, tỉnh Lào Cai (ga đi tại khu Sun Plaza, trung tâm Sa Pa)', NULL, NULL,
       'Cáp treo Fansipan thường 7:30–17:30 hằng ngày — xác nhận lịch trước khi đến', 'Quần thể du lịch với tuyến cáp treo ba dây kỷ lục lên đỉnh Fansipan, tàu hỏa leo núi Mường Hoa, khu tâm linh trên đỉnh và các khu vui chơi, lễ hội theo mùa.', 'Giữ vé khứ hồi để dùng chiều xuống (vé chỉ có giá trị trong ngày in trên vé); có thể đi thêm tàu hỏa leo núi Mường Hoa.', NULL, TRUE, 'Vietnam Tourism: vietnamtourism.gov.vn (06/2026, 07/2026); Google Maps (06/2026, 07/2026) — chỉ dùng chéo kiểm địa chỉ/giờ mở cửa; Traveloka (07/2026); TripAdvisor (07/2026); T-037: Sun World Fansipan Legend — Traveloka (2025-2026)'
FROM destinations d WHERE d.slug = 'lao-cai-sapa' OR d.name = 'Sa Pa'
ORDER BY (d.slug = 'lao-cai-sapa') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── lao-cai-yen-bai (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '62cc8736-4e7d-5938-b5eb-ca1f2b94f3ab', d.id, 'Le Champ Tú Lệ Resort (suối khoáng & khu vui chơi Aeris Hill)', 'entertainment', 'Bản Nước Nóng, xã Tú Lệ, huyện Văn Chấn, Yên Bái (tỉnh Lào Cai)', NULL, NULL,
       'Dịch vụ trong ngày 8:00–15:00 và 18:00–20:50 hằng ngày', 'Khu nghỉ dưỡng - vui chơi giữa thung lũng Tú Lệ với suối khoáng nóng Onsen, khu vui chơi Aeris Hill (zipline, trò chơi mạo hiểm) và động Tiên Nữ, nằm giữa các bản người Thái.', 'Vé chia nhiều hạng (gồm/không gồm zipline); kết hợp ngắm ruộng bậc thang Tú Lệ - Mù Cang Chải.', NULL, TRUE, 'T-037: Le Champ Tú Lệ Resort — Booking.com & Lữ Hành Việt Nam (2025)'
FROM destinations d WHERE d.slug = 'lao-cai-yen-bai' OR d.name = 'Yên Bái'
ORDER BY (d.slug = 'lao-cai-yen-bai') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── nghe-an-nghe-an (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '163d0c4e-e777-5985-acfe-dd9f60c8738b', d.id, 'VinWonders Cửa Hội', 'theme_park', 'Bãi biển Cửa Lò, đường Bình Minh, TP. Vinh, Nghệ An', NULL, NULL,
       'Theo mùa/lịch khu — xác nhận trước khi đến', 'Quần thể du lịch - giải trí lớn nhất Bắc Trung Bộ với công viên nước (17 cụm đường trượt đa cấp độ), công viên giải trí, hội chợ Phù Hoa và cáp treo vượt biển ra đảo Song Ngư.', 'Mua combo nhiều phân khu để tiết kiệm; combo cáp treo bao gồm trải nghiệm đảo Song Ngư.', NULL, TRUE, 'T-037: VinWonders Cửa Hội — vinwonders.com & BestPrice (2025)'
FROM destinations d WHERE d.slug = 'nghe-an-nghe-an' OR d.name = 'Nghệ An (Vinh)'
ORDER BY (d.slug = 'nghe-an-nghe-an') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── ninh-binh-ha-nam (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '043c8c54-b887-544b-975f-8c72d97ac9a4', d.id, 'Công viên nước Sun World Hà Nam', 'water_park', 'Phường Lam Hạ, TP. Phủ Lý, Hà Nam', NULL, NULL,
       'Mở cửa hằng ngày mùa hè; có suất tối 3 ngày cuối tuần — xác nhận trước khi đến', 'Công viên nước Sun World lấy cảm hứng múa rối nước với 14 tổ hợp trò chơi và 40 đường trượt, bể tạo sóng, sông lười — điểm giải nhiệt mùa hè lớn ở Hà Nam.', 'Khung giờ 17:00–19:00 cuối tuần có vé ưu đãi; khách địa phương được giảm giá.', NULL, TRUE, 'T-037: Sun World Hà Nam (công viên nước) — sunworld.vn & Tuổi Trẻ (2025)'
FROM destinations d WHERE d.slug = 'ninh-binh-ha-nam' OR d.name = 'Hà Nam'
ORDER BY (d.slug = 'ninh-binh-ha-nam') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── ninh-binh-nam-dinh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'f748d94b-0c2e-5dd7-8389-b8bda13764d7', d.id, 'Khu du lịch sinh thái Núi Ngăm', 'entertainment', 'Thôn Kim Thái, xã Minh Tân, huyện Vụ Bản, Nam Định (cách TP. Nam Định ~10km)', NULL, NULL,
       '7:00–22:00 hằng ngày', 'Khu du lịch sinh thái dưới chân núi Ngăm với cảnh quan xanh, hồ nước, vườn hoa, khu vui chơi, đi thuyền và ẩm thực địa phương — điểm dã ngoại quen thuộc của Nam Định.', 'Một số trò chơi bán vé riêng; phù hợp dã ngoại gia đình cuối tuần.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Núi Ngăm — vietnamtourism.gov.vn & Booking.com (2025)'
FROM destinations d WHERE d.slug = 'ninh-binh-nam-dinh' OR d.name = 'Nam Định'
ORDER BY (d.slug = 'ninh-binh-nam-dinh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── ninh-binh-ninh-binh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '8c6a6496-e831-5deb-98aa-5d66c12f4cf7', d.id, 'Khu du lịch sinh thái Thung Nham (Vườn chim)', 'entertainment', 'Thôn Hải Nham, xã Ninh Hải, huyện Hoa Lư, Ninh Bình (trong quần thể Tràng An)', NULL, NULL,
       'Mùa hè 7:00–18:00; mùa đông 7:30–17:30', 'Khu du lịch sinh thái trong quần thể Tràng An với vườn chim tự nhiên hàng vạn cá thể, hệ thống hang động nguyên sơ, hồ nước và dịch vụ chèo thuyền — điểm tham quan, vui chơi sinh thái nổi bật.', 'Đến khoảng 16:00–18:00 để xem đàn chim bay về tổ; vé đã gồm đi thuyền và tham quan hang.', NULL, TRUE, 'manual_curated; vietnamtourism.gov.vn; kiến thức du lịch địa phương phổ biến; T-037: Khu sinh thái Thung Nham — thungnham.com & The Sinh Tour (2025)'
FROM destinations d WHERE d.slug = 'ninh-binh-ninh-binh' OR d.name = 'Ninh Bình'
ORDER BY (d.slug = 'ninh-binh-ninh-binh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── phu-tho-hoa-binh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'e3fba9ed-bf47-54d7-8187-9d25663d59e8', d.id, 'Suối khoáng nóng Serena Resort Kim Bôi', 'entertainment', 'Huyện Kim Bôi, Hòa Bình (cách Hà Nội ~2 giờ xe)', NULL, NULL,
       'Ban ngày cho khách tham quan/tắm khoáng — xác nhận trước khi đến', 'Khu nghỉ dưỡng suối khoáng nóng tự nhiên Kim Bôi (34–36°C) với bể bơi khoáng trong nhà, bể vô cực ngoài trời, khu tắm Onsen kiểu Nhật cùng các hoạt động kayak, đạp xe, yoga giữa thiên nhiên.', 'Vé tham quan/tắm khoáng trong ngày tính riêng; có gói nghỉ dưỡng 2N1Đ trọn gói. Nhớ mang đồ bơi.', NULL, TRUE, 'T-037: Serena Resort Kim Bôi — serena.com.vn & Eholiday (2025)'
FROM destinations d WHERE d.slug = 'phu-tho-hoa-binh' OR d.name = 'Hòa Bình'
ORDER BY (d.slug = 'phu-tho-hoa-binh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── phu-tho-phu-tho (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '319da7df-90ec-584d-be81-204e17ff5fc5', d.id, 'Khu khoáng nóng Wyndham Thanh Thủy (OHAYO Onsen)', 'entertainment', 'Xã La Phù, huyện Thanh Thủy, Phú Thọ (cách Hà Nội ~65km)', NULL, NULL,
       'Ban ngày cho khách tắm khoáng — xác nhận trước khi đến', 'Khu nghỉ dưỡng khoáng nóng ~87ha với tổ hợp tắm khoáng OHAYO Onsen kiểu Nhật (Natural/Themed/Herbal/Foot Onsen, sauna), phố đi bộ Nhật Bản, hồ cá Koi và khu vui chơi trẻ em trong nhà.', 'Mua vé Onsen riêng hoặc combo gồm phòng + vé VIP + buffet; nhớ mang đồ bơi.', NULL, TRUE, 'T-037: Wyndham Thanh Thủy (OHAYO Onsen) — wyndham-thanhthuy.com & Booking.com (2025)'
FROM destinations d WHERE d.slug = 'phu-tho-phu-tho' OR d.name = 'Phú Thọ'
ORDER BY (d.slug = 'phu-tho-phu-tho') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── phu-tho-vinh-phuc (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '5119ab0b-5eea-5a1b-8db3-ddcbb23306c5', d.id, 'Flamingo Đại Lải Resort', 'entertainment', 'Đại Quang, Ngọc Thanh, TP. Phúc Yên, Vĩnh Phúc', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Tổ hợp nghỉ dưỡng - giải trí ven hồ Đại Lải với bãi tắm hồ, bể bơi, khu vui chơi trẻ em, bảo tàng nghệ thuật, rạp chiếu phim và chuỗi nhà hàng Á - Âu.', 'Vé vào cổng đã cho dùng một số tiện ích; nhiều dịch vụ vui chơi giải trí tính phí riêng.', NULL, TRUE, 'T-037: Flamingo Đại Lải Resort — flamingoresortdailai.com & VTeambuilding (2025)'
FROM destinations d WHERE d.slug = 'phu-tho-vinh-phuc' OR d.name = 'Vĩnh Phúc'
ORDER BY (d.slug = 'phu-tho-vinh-phuc') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── quang-ngai-kon-tum (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '1fc27fe4-5289-5dba-9fa1-544ccf60e761', d.id, 'Khu du lịch sinh thái Măng Đen (Thác Pa Sỹ)', 'entertainment', 'Thôn Măng Đen, xã Đắk Long, huyện Kon Plông, Kon Tum (tỉnh Quảng Ngãi)', NULL, NULL,
       'Ban ngày — Thác Pa Sỹ đẹp nhất sau 16:00', 'Khu du lịch sinh thái Măng Đen (''Đà Lạt thứ hai'' của Tây Nguyên) với thác Pa Sỹ, vườn tượng gỗ, nhà rông và hồ Đăk Ke giữa rừng thông mát lạnh.', 'Khí hậu se lạnh quanh năm; thác Pa Sỹ đẹp nhất buổi chiều khi nắng dịu.', NULL, TRUE, 'T-037: Khu sinh thái Măng Đen (Thác Pa Sỹ) — mangdentrip.com & VinWonders Wonderpedia (2025)'
FROM destinations d WHERE d.slug = 'quang-ngai-kon-tum' OR d.name = 'Kon Tum'
ORDER BY (d.slug = 'quang-ngai-kon-tum') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── quang-ngai-quang-ngai (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'fa23c83e-e115-5268-9a46-20b2cdf5e72d', d.id, 'Khu du lịch sinh thái Suối Chí', 'entertainment', 'Xã Thiện Tín (Nghĩa Hành), Quảng Ngãi (cách TP. Quảng Ngãi ~25km về phía Tây Nam)', NULL, NULL,
       '7:30–17:30 hằng ngày', 'Khu du lịch sinh thái suối với cảnh sơn thủy hữu tình, có chèo thuyền, đạp vịt, kayak, trượt cáp (zipline), cầu treo và đạp xe dưới nước — điểm trốn nóng cuối tuần gần Quảng Ngãi.', 'Có thể thuê lều hoặc nghỉ resort qua đêm; đi mùa hè để tắm suối.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Suối Chí — Traveloka & Touring.vn (2025)'
FROM destinations d WHERE d.slug = 'quang-ngai-quang-ngai' OR d.name = 'Quảng Ngãi'
ORDER BY (d.slug = 'quang-ngai-quang-ngai') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── quang-ninh-ha-long (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '58df25ad-bbe2-5f75-912b-c49ac1d666fd', d.id, 'Sun World Hạ Long (Đồi Mặt Trời — Cáp treo Nữ Hoàng)', 'amusement_park', 'Ga Đại Dương, đường Hạ Long, Bãi Cháy, TP. Hạ Long, Quảng Ninh (cạnh Cầu Bãi Cháy)', NULL, NULL,
       'Cáp treo Nữ Hoàng & các khu trên đồi thường 14:00–21:00; nghỉ trưa 12:00–13:30 — xác nhận lịch trước khi đến', 'Tổ hợp giải trí rộng hơn 214ha tại Bãi Cháy với cáp treo Nữ Hoàng cabin 2 tầng (kỷ lục thế giới), vòng quay Mặt Trời, công viên Rồng nhiều trò chơi và công viên nước, nhìn thẳng ra vịnh Hạ Long.', 'Lên cáp treo lúc chiều để ngắm vịnh và hoàng hôn; kiểm tra lịch vì một số khu nghỉ trưa.', NULL, TRUE, 'manual_curated; vietnamtourism.gov.vn; kiến thức du lịch địa phương phổ biến; T-037: Sun World Hạ Long (Cáp treo Nữ Hoàng) — sunworld.vn & Saigontourist (2025)'
FROM destinations d WHERE d.slug = 'quang-ninh-ha-long' OR d.name = 'Hạ Long'
ORDER BY (d.slug = 'quang-ninh-ha-long') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── quang-tri-phong-nha (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '70d65305-790f-549a-a1ca-1a77b5fa50f2', d.id, 'Công viên Ozo Treetop Park', 'entertainment', 'Đường 20 Quyết Thắng, xã Sơn Trạch (Phong Nha), huyện Bố Trạch, Quảng Bình — trong VQG Phong Nha - Kẻ Bàng', NULL, NULL,
       'Khoảng 7:00–17:00 hằng ngày (có dịch vụ cắm trại qua đêm) — xác nhận trước khi đến', 'Công viên phiêu lưu sinh thái gần 5ha trong VQG Phong Nha - Kẻ Bàng, nổi bật hệ thống trò chơi trên cây dài nhất Việt Nam (~800m), zipline xuyên rừng, chèo kayak/SUP và thuyền xuôi suối Ozo.', 'Trò chơi trên cây áp dụng cho người cao từ 1m4 và dưới 80kg; vé full đã gồm HDV, thiết bị an toàn và ăn trưa.', NULL, TRUE, 'vietnamtourism.gov.vn; BQL Vườn quốc gia Phong Nha - Kẻ Bàng; T-037: Ozo Treetop Park — phongnhaexplorer.com & PYS Travel (2025)'
FROM destinations d WHERE d.slug = 'quang-tri-phong-nha' OR d.name = 'Quảng Trị'
ORDER BY (d.slug = 'quang-tri-phong-nha') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── quang-tri-quang-tri (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '9cb4c953-1ad8-5ba6-b875-c34ad616415c', d.id, 'Khu du lịch sinh thái Trằm Trà Lộc', 'entertainment', 'Làng Trà Lộc, xã Hải Xuân, huyện Hải Lăng, Quảng Trị (cách TP. Quảng Trị ~8km về phía Nam)', NULL, NULL,
       'Ban ngày — đẹp nhất từ tháng 4 đến tháng 9', 'Khu du lịch sinh thái gần 100ha quanh hồ Trằm Trà Lộc với rừng cây xanh quanh năm cùng các hoạt động đi bộ đường mòn, tắm suối, câu cá, đạp xe, tham quan vườn thú và trò chơi dân gian.', 'Đi tháng 4–9 khi khô ráo; thưởng thức cháo vạt giường, cháo bánh canh cá lóc Hải Lăng.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Trằm Trà Lộc — ipa.quangtri.gov.vn & Mia.vn (2025)'
FROM destinations d WHERE d.slug = 'quang-tri-quang-tri' OR d.name = 'Quảng Trị (Đông Hà)'
ORDER BY (d.slug = 'quang-tri-quang-tri') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── son-la-son-la (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'db98c246-f865-577b-b9e5-05f2aa089e99', d.id, 'Mộc Châu Island (cầu kính Bạch Long)', 'entertainment', 'Mường Sang, Mộc Châu, Sơn La', NULL, NULL,
       '8:00–17:30 hằng ngày', 'Siêu quần thể nghỉ dưỡng - giải trí ở Mộc Châu, nổi bật với cầu kính Bạch Long dài nhất thế giới (~600m), cùng zipline, đường trượt Airslide và Kart Club.', 'Cầu kính Bạch Long đông vào cuối tuần; chọn combo Play All gồm nhiều trò chơi để tiết kiệm.', NULL, TRUE, 'T-037: Mộc Châu Island — mocchauisland.com & BestPrice (2025)'
FROM destinations d WHERE d.slug = 'son-la-son-la' OR d.name = 'Sơn La (Mộc Châu)'
ORDER BY (d.slug = 'son-la-son-la') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tay-ninh-long-an (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '4644e929-5eb5-5969-b7b6-1e1f8bc53444', d.id, 'Khu du lịch Làng nổi Tân Lập', 'entertainment', 'Xã Tân Lập, huyện Mộc Hóa, Long An (tỉnh Tây Ninh)', NULL, NULL,
       '7:30–17:30 (dịch vụ trong ngày); nghỉ qua đêm 24/7', 'Khu du lịch sinh thái giữa rừng tràm Đồng Tháp Mười với con đường xuyên rừng tràm dài, đi xuồng/tắc ráng ngắm chim cùng các hoạt động dã ngoại, cắm trại.', 'Đi tháng 11–4 (mùa khô) để tránh mưa; trải nghiệm xuyên rừng tràm cả đường bộ và xuồng.', NULL, TRUE, 'T-037: Làng nổi Tân Lập — langnoitanlap.com.vn & Klook (2025)'
FROM destinations d WHERE d.slug = 'tay-ninh-long-an' OR d.name = 'Long An (Tân An)'
ORDER BY (d.slug = 'tay-ninh-long-an') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tay-ninh-my-tho (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '90f8112d-f8fc-5003-8d46-c18bf2ec2fa6', d.id, 'Trại rắn Đồng Tâm', 'zoo', 'Ấp Tân Thuận, xã Bình Đức, huyện Châu Thành, Tiền Giang (tỉnh Tây Ninh)', NULL, NULL,
       '7:00–17:00 hằng ngày', 'Trung tâm nuôi rắn lớn nhất miền Tây (''vương quốc rắn'') với hơn 1.000 cá thể thuộc khoảng 44 loài, kèm bảo tàng rắn và vườn thú nhỏ — điểm tham quan, giáo dục thú vị cho gia đình.', 'Kết hợp tham quan cù lao Thới Sơn và chợ nổi Cái Bè gần đó; xem cho rắn ăn theo giờ.', NULL, TRUE, 'T-037: Trại rắn Đồng Tâm — trairandongtam.vn & Viet Fun Travel (2025)'
FROM destinations d WHERE d.slug = 'tay-ninh-my-tho' OR d.name = 'Mỹ Tho (Tiền Giang)'
ORDER BY (d.slug = 'tay-ninh-my-tho') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tay-ninh-tay-ninh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '35229d3c-8770-566b-9b8b-8086184d44bf', d.id, 'Sun World Núi Bà Đen (Cáp treo & khu vui chơi)', 'entertainment', 'Khu phố Ninh Phú, phường Ninh Sơn, TP. Tây Ninh, tỉnh Tây Ninh (cách trung tâm ~11km)', NULL, NULL,
       'Cáp treo tuyến Chùa Hang: T2–T6 7:00–18:00, T7 7:00–19:15, CN 6:00–19:15; tuyến Vân Sơn theo khung giờ riêng — xác nhận trước khi đến', 'Quần thể du lịch trên núi Bà Đen (nóc nhà Nam Bộ) với hệ thống cáp treo hiện đại gồm 2 tuyến chính — Chùa Hang (lên khu tâm linh Điện Bà ở độ cao ~350m) và Vân Sơn (lên đỉnh núi, khu tượng Phật Bà) — cùng vườn hoa và các trải nghiệm check-in biển mây. Ga cáp treo Bà Đen từng được ghi nhận kỷ lục nhà ga cáp treo lớn nhất thế giới.', 'Lên đỉnh bằng tuyến Vân Sơn để chiêm bái tượng Phật Bà và ngắm biển mây; tuyến Chùa Hang để viếng Điện Bà. Đi sáng sớm để tránh nắng và né đông khách cuối tuần; mang áo khoác nhẹ vì trên đỉnh gió khá mạnh.', NULL, TRUE, 'Traveloka (07/2026); TripAdvisor (07/2026); Sở Văn hóa Thể thao và Du lịch Tây Ninh; vietnamtourism.gov.vn; Google Maps (chéo kiểm địa chỉ/giờ mở cửa, 07/2026)'
FROM destinations d WHERE d.slug = 'tay-ninh-tay-ninh' OR d.name = 'Núi Bà Đen'
ORDER BY (d.slug = 'tay-ninh-tay-ninh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── thai-nguyen-ba-be (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '7b0c4df8-3805-5f70-a872-0759369e4aba', d.id, 'Du thuyền tham quan hồ Ba Bể', 'entertainment', 'Vườn quốc gia Ba Bể, xã Nam Mẫu, huyện Ba Bể, Bắc Kạn (nay xã Ba Bể, tỉnh Thái Nguyên)', NULL, NULL,
       'Ban ngày — xác nhận lịch thuyền trước khi đến', 'Trải nghiệm du thuyền/xuồng tham quan hồ Ba Bể - hồ nước ngọt tự nhiên lớn nhất Việt Nam, ghé động Puông, ao Tiên, thác Đầu Đẳng và đền An Mã giữa rừng núi đá vôi.', 'Thuê thuyền theo tuyến (tính theo thuyền, đi nhóm tiết kiệm); kết hợp tham quan động Hua Mạ.', NULL, TRUE, 'T-037: Du thuyền hồ Ba Bể — Tour.Pro.Vn & homestay Ba Bể (2025)'
FROM destinations d WHERE d.slug = 'thai-nguyen-ba-be' OR d.name = 'Ba Bể (Bắc Kạn)'
ORDER BY (d.slug = 'thai-nguyen-ba-be') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── thai-nguyen-thai-nguyen (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '1808cb05-237c-52b3-a87f-f04841a2661d', d.id, 'Khu du lịch Hồ Núi Cốc', 'entertainment', 'Xóm Tân Lập, xã Tân Thái, huyện Đại Từ, Thái Nguyên (cách TP. Thái Nguyên ~18,5km)', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Khu du lịch ven hồ Núi Cốc với công viên nước ~3,4ha, hệ thống hang động nhân tạo (huyền thoại nàng Công - chàng Cốc), vườn thú, biểu diễn nhạc nước và 8 trò chơi cảm giác mạnh.', 'Vé trọn gói gồm tham quan + công viên nước + trò chơi; phù hợp gia đình đi cả ngày.', NULL, TRUE, 'T-037: Khu du lịch Hồ Núi Cốc — dulichhonuicoc.vn & Leadtour (2025)'
FROM destinations d WHERE d.slug = 'thai-nguyen-thai-nguyen' OR d.name = 'Thái Nguyên'
ORDER BY (d.slug = 'thai-nguyen-thai-nguyen') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── thanh-hoa-thanh-hoa (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'da6f7c15-0dd6-52e4-91d3-7548be0471ad', d.id, 'Sun World Sầm Sơn', 'amusement_park', 'Đại lộ Nam Sông Mã, phường Quảng Tiến, TP. Sầm Sơn, Thanh Hóa', NULL, NULL,
       'Dịp hè thường 9:00–19:00; hoạt động theo mùa — xác nhận trước khi đến', 'Tổ hợp giải trí hơn 33,5ha tại Sầm Sơn với công viên nước (bể tạo sóng, đường trượt cảm giác mạnh), khu vui chơi trẻ em, khu ẩm thực và chương trình biểu diễn nghệ thuật.', 'Khung giờ vàng 17:00–19:00 thường có vé ưu đãi; công viên nước hoạt động theo mùa hè.', NULL, TRUE, 'T-037: Sun World Sầm Sơn — sunworld.vn & Traveloka (2025)'
FROM destinations d WHERE d.slug = 'thanh-hoa-thanh-hoa' OR d.name = 'Thanh Hóa (Sầm Sơn)'
ORDER BY (d.slug = 'thanh-hoa-thanh-hoa') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tp-ho-chi-minh-binh-duong (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '55772030-7fa5-523b-b2a6-45395b8a550b', d.id, 'Khu du lịch Đại Nam (Lạc cảnh Đại Nam Văn Hiến)', 'theme_park', '1765A Đại lộ Bình Dương, phường Hiệp An, TP. Thủ Dầu Một, Bình Dương (cách TP.HCM ~40km)', NULL, NULL,
       '8:00–17:00 (cuối tuần đến ~17:30)', 'Tổ hợp du lịch khổng lồ với đền thờ Đại Nam, biển nhân tạo, vườn thú safari và khu trò chơi cảm giác mạnh — một trong những khu giải trí lớn nhất phía Nam.', 'Vé chia theo phân khu (biển, vườn thú, trò chơi); đi sớm để chơi hết vì diện tích rất rộng.', NULL, TRUE, 'T-037: Khu du lịch Đại Nam — khudulichdainam.com.vn & Mia.vn (2025)'
FROM destinations d WHERE d.slug = 'tp-ho-chi-minh-binh-duong' OR d.name = 'Bình Dương (Thủ Dầu Một)'
ORDER BY (d.slug = 'tp-ho-chi-minh-binh-duong') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tp-ho-chi-minh-hcmc (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '1382fbdc-de43-5b02-9c7a-9da61ae805db', d.id, 'Công viên nước Đầm Sen', 'water_park', 'Số 3 Hòa Bình, Phường 3, Quận 11, TP. Hồ Chí Minh', NULL, NULL,
       'T2–T7: 9:00–18:00; Chủ nhật & ngày lễ: 8:30–18:00', 'Công viên nước lớn trung tâm Sài Gòn với hơn 36 trò chơi nước hiện đại, khu tạo sóng, nhiều đường trượt và khu vui chơi riêng cho trẻ em.', 'Đi ngày thường để vắng hơn; mang đồ bơi và kem chống nắng, gửi đồ tại tủ khóa.', NULL, TRUE, 'vietnamtourism.gov.vn (06/2026); Sở Du lịch TP. HCM: tourism.hochiminhcity.gov.vn (06/2026); Google Maps (06/2026); Klook Việt Nam: klook.com/vi (06/2026); TripAdvisor: tripadvisor.com.vn (06/2026); T-037: Công viên nước Đầm Sen — Tin Việt Travel & Bonbon Car (2025)'
FROM destinations d WHERE d.slug = 'tp-ho-chi-minh-hcmc' OR d.name = 'TP. Hồ Chí Minh'
ORDER BY (d.slug = 'tp-ho-chi-minh-hcmc') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tp-ho-chi-minh-vung-tau (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '0fed698e-79fc-5d2a-9368-a36360dae79a', d.id, 'Khu du lịch Hồ Mây Park (Cáp treo Hồ Mây)', 'amusement_park', 'Số 1A Trần Phú, Phường 1, TP. Vũng Tàu, Bà Rịa — Vũng Tàu', NULL, NULL,
       'Cáp treo khoảng 8:00–23:00; khu trò chơi & công viên nước 8:00–18:00 — xác nhận lịch trước khi đến', 'Khu giải trí trên đỉnh Núi Lớn đi bằng cáp treo, có hơn 70 trò chơi, công viên nước trên núi (đường trượt từ độ cao ~10m), rạp phim 7D và chương trình nhạc nước, view toàn cảnh biển Vũng Tàu.', 'Đi T2–T5 thường được giảm ~20% giá vé; lên đỉnh ngắm hoàng hôn trên biển.', NULL, TRUE, 'Sở Du lịch TP.HCM; Sở Du lịch tỉnh Bà Rịa - Vũng Tàu; T-037: Hồ Mây Park — homaypark.com & Traveloka (2025); Traveloka (địa chỉ Bạch Dinh, Hải Đăng, Tượng Chúa; explore articles, 07/2026); TripAdvisor (review_count Tượng Chúa Kitô Vua, 07/2026)'
FROM destinations d WHERE d.slug = 'tp-ho-chi-minh-vung-tau' OR d.name = 'TP. Hồ Chí Minh - Vũng Tàu'
ORDER BY (d.slug = 'tp-ho-chi-minh-vung-tau') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tuyen-quang-ha-giang (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT 'd5cbbe39-abb4-5628-ba59-43664bf5d728', d.id, 'Khu du lịch H''Mong Village', 'entertainment', 'Khu Tráng Kìm, xã Đông Hà, huyện Quản Bạ, Hà Giang (trên QL4C đi cao nguyên đá Đồng Văn, cách TP. Hà Giang ~50km)', NULL, NULL,
       'Theo lịch khu nghỉ dưỡng — xác nhận trước khi đến', 'Khu du lịch cấp tỉnh đầu tiên của Hà Giang theo phong cách bản người Mông, có bungalow trình tường đất, bể bơi vô cực, sân bóng, sân tennis, Sky Bar ngoài trời và trải nghiệm văn hóa vùng cao.', 'Dừng chân trên đường lên Đồng Văn; bể bơi vô cực và Sky Bar ngắm núi rất đẹp.', NULL, TRUE, 'Traveloka (07/2026); vietnamtourism.gov.vn (07/2026); Vietravel (07/2026); TripAdvisor (07/2026 — chỉ tham khảo mô tả); T-037: H''Mong Village Resort — hmongvillage.com.vn & Booking.com (2025)'
FROM destinations d WHERE d.slug = 'tuyen-quang-ha-giang' OR d.name = 'Hà Giang'
ORDER BY (d.slug = 'tuyen-quang-ha-giang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── tuyen-quang-tuyen-quang (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '4c442b54-884b-505e-85bd-39f247225ea9', d.id, 'Suối khoáng nóng Mỹ Lâm', 'entertainment', 'Xã Phú Lâm, huyện Yên Sơn, Tuyên Quang (cách trung tâm TP. Tuyên Quang ~13km)', NULL, NULL,
       'Ban ngày cho khách tắm khoáng — xác nhận trước khi đến', 'Khu suối khoáng nóng tự nhiên duy nhất của Tuyên Quang (mạch khoáng sâu hơn 150m), nay phát triển thành quần thể nghỉ dưỡng - giải trí Mỹ Lâm với dịch vụ tắm khoáng, Onsen kiểu Nhật, spa và bể bơi.', 'Có nhiều cơ sở (Vinpearl, khách sạn Á Châu, Hà Phú...); chọn gói tắm khoáng cơ bản hoặc combo tắm bùn + massage.', NULL, TRUE, 'T-037: Suối khoáng nóng Mỹ Lâm — soctrangtourism.vn & wyndham-thanhthuy.com (2025)'
FROM destinations d WHERE d.slug = 'tuyen-quang-tuyen-quang' OR d.name = 'Tuyên Quang'
ORDER BY (d.slug = 'tuyen-quang-tuyen-quang') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── vinh-long-tra-vinh (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '1c843dc1-df24-5b60-b4df-be604ea00a02', d.id, 'Khu du lịch sinh thái Huỳnh Kha', 'entertainment', 'Xã Long Đức, huyện Châu Thành, Trà Vinh (cách TP. Trà Vinh ~10km)', NULL, NULL,
       'Ban ngày — xác nhận trước khi đến', 'Khu du lịch sinh thái rộng ~57.000m² ở Trà Vinh với nhiều hạng mục vui chơi giải trí, hồ nước, cây xanh và khu ẩm thực — điểm dã ngoại gần thành phố.', 'Phù hợp gia đình, nhóm bạn dã ngoại; kết hợp tham quan ao Bà Om và các chùa Khmer gần đó.', NULL, TRUE, 'T-037: Khu du lịch sinh thái Huỳnh Kha — Lữ Hành Việt Nam & Du Lịch Việt (2025)'
FROM destinations d WHERE d.slug = 'vinh-long-tra-vinh' OR d.name = 'Trà Vinh'
ORDER BY (d.slug = 'vinh-long-tra-vinh') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

-- ── vinh-long-vinh-long (1 điểm) ──
INSERT INTO locations
  (id, destination_id, name, type, address, lat, lng,
   hours, description, tips, image_url, verified, data_source)
SELECT '3d9c9d25-f1ba-57cd-b08b-2b2d1df7ab17', d.id, 'Khu du lịch Vinh Sang (cù lao An Bình)', 'entertainment', 'Tổ 14, ấp An Thuận, xã An Bình, huyện Long Hồ, Vĩnh Long (đầu cù lao An Bình)', NULL, NULL,
       '8:00–18:00 hằng ngày', 'Khu du lịch sinh thái miệt vườn trên cù lao An Bình ven sông Cổ Chiên với khu bảo tồn thú (gấu, hươu sao, khỉ), đàn đà điểu châu Phi (trải nghiệm cưỡi đà điểu), câu cá sấu và trò chơi dân gian.', 'Đặt ăn trước 24 giờ thường được miễn phí vé vào cổng; thử cưỡi đà điểu và tát mương bắt cá.', NULL, TRUE, 'T-037: Khu du lịch Vinh Sang — vinhsang.com & vinhlongtourist.vn (2025)'
FROM destinations d WHERE d.slug = 'vinh-long-vinh-long' OR d.name = 'Vĩnh Long'
ORDER BY (d.slug = 'vinh-long-vinh-long') DESC LIMIT 1
ON CONFLICT (id) DO NOTHING;

COMMIT;
