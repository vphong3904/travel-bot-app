-- PDTrip – Seed: Tours

INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee71-616e-7395-97e6-4cbc91bc3712', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Tour câu cá & lặn ngắm san hô 4 đảo', '1 ngày (7:00–17:00)',
  350000, '10–30 người', 'Tour nổi tiếng nhất Phú Quốc, ghé 4 hòn đảo nhỏ: Hòn Thơm, Hòn Móng Tay, Hòn Gầm Ghì, Hòn Vú. Kết hợp lặn ngắm san hô, câu cá, ăn hải sản trên biển và tắm biển tại các điểm ghé.',
  ARRAY['Thuyền gỗ', 'Hướng dẫn viên', 'Thiết bị lặn ngắm san hô', 'Bữa trưa hải sản trên thuyền', 'Nước uống'], ARRAY['Đón tiễn khách sạn', 'Đồ uống có cồn', 'Tip thuyền trưởng', 'Lặn sâu có bình khí (phí riêng)'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee71-616e-7349-83d4-9fea49631072', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Tour khám phá Vườn Quốc gia & thác Tranh', 'Nửa ngày (buổi sáng, ~4 giờ)',
  NULL, '2–15 người', 'Trekking nhẹ vào rừng nguyên sinh Vườn Quốc gia Phú Quốc, thăm thác Tranh và suối tự nhiên. Hướng dẫn viên địa phương giới thiệu hệ sinh thái rừng nhiệt đới đặc trưng của đảo.',
  ARRAY['Hướng dẫn viên địa phương', 'Vé vào VQG', 'Nước uống'], ARRAY['Đưa đón', 'Ăn uống', 'Bảo hiểm du lịch'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee71-616e-7938-ab80-cdde5e62fc3a', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Tour hoàng hôn & câu mực đêm trên biển', 'Buổi tối (~4 giờ, 17:30–21:30)',
  300000, '5–20 người', 'Lên thuyền ra biển xem hoàng hôn, sau đó câu mực đêm dưới ánh đèn cao áp. Hải sản câu được có thể nướng ngay trên thuyền. Trải nghiệm độc đáo không thể bỏ qua khi đến Phú Quốc.',
  ARRAY['Thuyền gỗ truyền thống', 'Cần câu mực', 'Mồi câu', 'Nướng mực tươi trên thuyền', 'Nước uống cơ bản'], ARRAY['Đưa đón', 'Bia/rượu', 'Tip'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee71-616e-72b1-968d-8d3ac3d20eba', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Tour làng nghề: nước mắm & rượu sim Phú Quốc', 'Nửa ngày (buổi sáng, ~3 giờ)',
  200000, '2–20 người', 'Tham quan nhà thùng nước mắm truyền thống (Khải Hoàn hoặc Thanh Hà), xem quy trình ủ cá cơm làm nước mắm nhĩ. Tiếp theo thăm trang trại rượu sim, thử rượu và mua đặc sản về.',
  ARRAY['Hướng dẫn tham quan', 'Thử nếm nước mắm và rượu sim'], ARRAY['Mua sản phẩm mang về', 'Đưa đón'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee91-daa7-72ff-ca99-8bfe30797000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Tour Chùa Cổ Bắc Ninh – Cụm Thuận Thành', 'Nửa ngày (4–5 tiếng)',
  NULL, '2–30 người', 'Tour tham quan cụm di tích Phật giáo cổ nhất Việt Nam tại huyện Thuận Thành: Chùa Dâu (Pháp Vân) — ngôi chùa cổ nhất VN — và Chùa Bút Tháp với kiến trúc thế kỷ 17 nguyên vẹn. Hướng dẫn viên giải thích lịch sử Phật giáo Giao Chỉ và ý nghĩa các công trình.',
  ARRAY['Xe đưa đón từ Hà Nội hoặc Bắc Ninh (tùy tour)', 'Hướng dẫn viên tiếng Việt', 'Nước uống'], ARRAY['Ăn trưa', 'Phí vào cổng (nếu có)', 'Chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee91-daa8-736e-28f8-a166bd8ec000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Tour Làng Nghề Truyền Thống Bắc Ninh', 'Một ngày (6–7 tiếng)',
  NULL, '4–20 người', 'Tour trải nghiệm hai làng nghề đặc sắc nhất Bắc Ninh: Làng tranh dân gian Đông Hồ (xem và thử in tranh) và Làng gốm Phù Lãng (xem thợ làm gốm thủ công). Kết hợp ăn trưa đặc sản bánh phu thê và nem Bùi tại nhà hàng địa phương.',
  ARRAY['Xe đưa đón', 'Hướng dẫn viên', 'Trải nghiệm in tranh Đông Hồ', 'Ăn trưa đặc sản'], ARRAY['Mua sắm tranh/gốm', 'Chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee91-daaa-72eb-1148-8e80e32c8000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Tour Văn Hóa Quan Họ & Đền Đô', 'Một ngày (6–8 tiếng)',
  NULL, '2–30 người', 'Tour văn hóa đặc sắc kết hợp thăm Đền Đô (đền thờ 8 vua triều Lý tại Từ Sơn), mua bánh phu thê Đình Bảng và thưởng thức chương trình hát quan họ dân gian. Tour được tổ chức đặc biệt vào dịp lễ hội Đền Đô (tháng 3 âm lịch) và Hội Lim (tháng 1 âm lịch).',
  ARRAY['Xe đưa đón', 'Hướng dẫn viên am hiểu văn hóa quan họ', 'Vé xem biểu diễn quan họ (nếu có)', 'Bánh phu thê Đình Bảng mang về'], ARRAY['Ăn trưa', 'Chi phí mua sắm', 'Chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '37b11d9d-9dd8-401c-ad1e-ee2e1b55e16a', '23431b56-3e63-4368-949f-8df24ab3c539', 'Tour Mũi Cà Mau – Rừng đước Năm Căn', '2 ngày 1 đêm',
  NULL, NULL, 'Tour đặc trưng nhất Cà Mau: xuất phát từ TP. Cà Mau, di chuyển bằng tàu cao tốc qua huyện Năm Căn ngắm rừng đước, dừng chợ nổi Năm Căn, tiếp tục vào Đất Mũi, đặt chân lên cột mốc quốc gia số 0 — điểm cực Nam Tổ quốc. Đêm nghỉ tại nhà nghỉ Đất Mũi hoặc quay về Năm Căn.',
  ARRAY['vé tàu cao tốc', 'hướng dẫn viên địa phương', 'bữa trưa hải sản', 'vé tham quan Mũi'], ARRAY['vé máy bay/xe đến Cà Mau', 'bữa tối và sáng', 'chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '16b1b635-ee85-4291-8a22-1b5835777dbf', '23431b56-3e63-4368-949f-8df24ab3c539', 'Tour Khám phá Vườn Quốc gia U Minh Hạ', '1 ngày',
  NULL, NULL, 'Hành trình vào lòng rừng tràm U Minh Hạ bằng thuyền chèo, khám phá hệ sinh thái đất than bùn độc đáo, quan sát chim và động vật hoang dã. Thăm cơ sở nuôi ong mật và thưởng thức mật ong tươi ngay tại rừng. Phù hợp cho người yêu thiên nhiên và eco-tourism.',
  ARRAY['vé vào rừng', 'thuyền + người chèo thuyền', 'hướng dẫn viên sinh thái', 'bữa trưa'], ARRAY['vé xe đến U Minh', 'thức uống riêng', 'chi phí mua mật ong'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '30cd55bd-0f2e-4837-94a4-034bf6420074', '23431b56-3e63-4368-949f-8df24ab3c539', 'Tour Cà Mau – Bạc Liêu: Điện gió & Di tích', '1 ngày',
  NULL, NULL, 'Tour kết hợp hai điểm du lịch của tỉnh Cà Mau sau sáp nhập: tham quan cánh đồng điện gió biển Bạc Liêu — cảnh quan kỳ vĩ turbine giữa biển, thăm nhà Công tử Bạc Liêu, khu lưu niệm Cao Văn Lầu, Khu du lịch sinh thái Hồ Nam — trong ngày từ TP. Cà Mau.',
  ARRAY['xe đưa đón TP. Cà Mau – Bạc Liêu', 'vé tham quan', 'hướng dẫn viên', 'bữa trưa'], ARRAY['chi phí mua sắm', 'thức uống riêng'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '33aea316-2a01-4436-93fd-cd9207420543', '23431b56-3e63-4368-949f-8df24ab3c539', 'Tour Đầm Thị Tường ngắm chim buổi sáng', 'Nửa ngày (4–6 tiếng)',
  NULL, NULL, 'Khởi hành lúc 4:30–5:00 sáng để đến Đầm Thị Tường trước bình minh, thuê thuyền nhỏ tiến sâu vào đầm quan sát hàng nghìn con chim nước bay lên khi mặt trời mọc. Trải nghiệm đặc biệt chỉ có từ tháng 11 đến tháng 3 khi chim di cư về trú đông.',
  ARRAY['xe đưa đón', 'thuyền tham quan đầm', 'hướng dẫn viên chim địa phương'], ARRAY['ống nhòm (nên mang theo)', 'bữa sáng'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '6c795681-12f0-40ab-9b09-159ed09c9855', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Tour Chợ Nổi Cái Răng Sáng Sớm', '3–4 tiếng (xuất phát 5:00–5:30)',
  NULL, 'Nhóm nhỏ 2–15 người, hoặc thuyền riêng', 'Tour thuyền máy xuất phát sáng sớm từ bến Ninh Kiều, di chuyển khoảng 6km để đến chợ nổi Cái Răng — chợ nổi lớn nhất miền Tây. Tham quan cảnh mua bán trên sông, mua trái cây trực tiếp từ ghe và thưởng thức bữa sáng trên thuyền (hủ tiếu/bánh mì).',
  ARRAY['hướng dẫn viên tiếng Việt', 'thuyền máy khứ hồi', 'bữa sáng đơn giản trên thuyền (tùy gói)'], ARRAY['đồ uống riêng', 'mua sắm trên chợ nổi', 'tip hướng dẫn viên'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '142aa68f-3cfb-4e9f-a80b-82102ec99b12', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Tour Kênh Rạch & Vườn Trái Cây Phong Điền', 'Nửa ngày (4–5 tiếng) hoặc cả ngày',
  NULL, 'Nhóm 2–12 người', 'Khám phá hệ thống kênh rạch vùng ngoại ô Cần Thơ bằng xuồng ba lá hoặc thuyền nhỏ, ghé thăm vườn trái cây khu Phong Điền, hái và thưởng thức trái cây tươi tại chỗ, quan sát đời sống người dân ven kênh rạch miền Tây. Kết hợp bữa trưa đặc sản tại nhà vườn.',
  ARRAY['thuyền và hướng dẫn viên', 'trái cây tại vườn', 'bữa trưa đặc sản (gói cả ngày)'], ARRAY['đồ uống riêng', 'mua thêm trái cây', 'tip'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  'c3ce6a82-a90e-44a7-bc17-90e0e560f791', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Tour Cần Thơ – Sóc Trăng 1 Ngày (Chùa Dơi & Lễ hội Khmer)', 'Cả ngày (~10 tiếng)',
  NULL, 'Nhóm 6–30 người', 'Tour kết hợp từ Cần Thơ đến Sóc Trăng (khoảng 60km) khám phá văn hóa Khmer Nam Bộ: Chùa Dơi (hàng chục nghìn con dơi quạ), chùa Kh''leang, bảo tàng Khmer, và tìm hiểu lễ hội Óoc Om Bóc đặc sắc của người Khmer. Khu Sóc Trăng cũ nay thuộc Cần Thơ sau sáp nhập 2025.',
  ARRAY['xe đưa đón', 'hướng dẫn viên', 'vé tham quan', 'bữa trưa'], ARRAY['mua sắm', 'đồ uống riêng', 'tip'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '58fff5a9-dacc-4882-9ed4-a6635138f3fc', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Tour Chợ Nổi Ngã Bảy – Hậu Giang 1 Ngày', 'Cả ngày (~8 tiếng)',
  NULL, 'Nhóm 4–20 người', 'Khám phá chợ nổi Ngã Bảy (Phụng Hiệp) — điểm giao thoa 7 con kênh, thuộc Hậu Giang cũ nay là Cần Thơ sau sáp nhập 2025. Tham quan làng nghề truyền thống, vườn cây ăn trái vùng Hậu Giang và thưởng thức đặc sản địa phương ít được biết đến hơn.',
  ARRAY['xe đưa đón', 'hướng dẫn viên', 'thuyền tham quan chợ nổi', 'bữa trưa'], ARRAY['mua sắm', 'đồ uống riêng', 'tip'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  'f9ed2021-a420-42b0-8892-ffc6233ee5d2', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Tour Thác Bản Giốc – Hang Pác Bó 2 Ngày 1 Đêm', '2 ngày 1 đêm',
  NULL, NULL, 'Tour trọn gói ghép hai điểm nổi tiếng nhất Cao Bằng: thác Bản Giốc hùng vĩ và hang Pác Bó lịch sử. Ngày 1 di chuyển từ TP. Cao Bằng đến Trùng Khánh, thăm thác Bản Giốc và nghỉ đêm tại khu vực lân cận hoặc homestay. Ngày 2 thăm Pác Bó và về thành phố.',
  ARRAY['xe đưa đón', 'hướng dẫn viên địa phương', 'bữa trưa ngày 1', '1 đêm khách sạn/homestay'], ARRAY['vé tham quan', 'bữa tối', 'chi tiêu cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  'b18733bc-0c98-45a4-b014-dc49c7787370', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Tour Khám Phá Cao Nguyên Đá Hồ Thang Hen', '1 ngày',
  NULL, NULL, 'Tour 1 ngày khám phá hồ Thang Hen và các vùng cao nguyên đá vôi xung quanh huyện Trà Lĩnh. Tham quan quần thể 36 hồ liên thông, ngắm cảnh núi non đá vôi, tìm hiểu đời sống người Tày-Nùng địa phương. Phù hợp nhiếp ảnh gia và người yêu thiên nhiên.',
  ARRAY['xe đưa đón', 'hướng dẫn viên', 'bữa trưa'], ARRAY['vé tham quan (nếu có)', 'đồ uống', 'chi tiêu cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '34072675-9f94-48d9-b9dc-99a21ec410e4', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Hành Trình Về Nguồn – Lịch Sử Cách Mạng Cao Bằng', '1 ngày',
  NULL, NULL, 'Tour chuyên đề lịch sử thăm hang Pác Bó, suối Lê-nin, núi Các Mác và Rừng Trần Hưng Đạo — cái nôi cách mạng Việt Nam. Phù hợp nhóm trường học, đoàn thể chính trị, hoặc khách quan tâm lịch sử. Có hướng dẫn viên am hiểu lịch sử địa phương.',
  ARRAY['xe đưa đón', 'hướng dẫn viên chuyên lịch sử', 'bữa trưa', 'tài liệu tham khảo'], ARRAY['vé vào cửa di tích', 'chi tiêu cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeecc-64d3-7c81-900d-6e2d97315134', '44444444-4444-4444-4444-444444444444', 'Tour Bà Nà Hills & Cầu Vàng 1 ngày', '1 ngày',
  NULL, NULL, 'Tour khám phá khu nghỉ dưỡng núi Bà Nà Hills bằng cáp treo, tham quan Cầu Vàng, làng Pháp và vườn hoa, kết thúc trong ngày.',
  ARRAY['xe đưa đón', 'vé cáp treo & khu vui chơi', 'hướng dẫn viên'], ARRAY['ăn trưa (tùy gói)', 'chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeecc-64d3-761f-9882-dae977a1a0df', '44444444-4444-4444-4444-444444444444', 'Tour thuyền thúng rừng dừa Cẩm Thanh & làng rau Trà Quế', 'Nửa ngày',
  NULL, NULL, 'Trải nghiệm ngồi thuyền thúng len lỏi rừng dừa nước Cẩm Thanh, sau đó tham gia hái rau và học nấu ăn tại làng rau Trà Quế truyền thống.',
  ARRAY['vé thuyền thúng', 'lớp học nấu ăn cơ bản', 'nguyên liệu'], ARRAY['đồ uống', 'tip cho người chèo thuyền'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeecc-64d3-7108-86da-195236056be5', '44444444-4444-4444-4444-444444444444', 'Tour Ngũ Hành Sơn & Bán đảo Sơn Trà', '1 ngày',
  NULL, NULL, 'Kết hợp tham quan quần thể núi đá Ngũ Hành Sơn, làng đá Non Nước và bán đảo Sơn Trà với chùa Linh Ứng, ngắm voọc chà vá chân nâu.',
  ARRAY['xe đưa đón', 'hướng dẫn viên', 'vé tham quan Ngũ Hành Sơn'], ARRAY['ăn uống', 'chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeecc-64d3-722e-8af8-37624714b5b3', '44444444-4444-4444-4444-444444444444', 'Tour đêm thuyền hoa đăng sông Hoài', '~2 giờ buổi tối',
  NULL, NULL, 'Đi thuyền dọc sông Hoài giữa lòng phố cổ Hội An, thả hoa đăng và ngắm đèn lồng phản chiếu trên mặt nước về đêm.',
  ARRAY['vé thuyền', 'đèn hoa đăng'], ARRAY['đồ ăn/uống trên thuyền'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeef1-4b2d-7113-aaa6-ac03188193dc', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Tour khám phá thác Dray Nur & Vườn quốc gia Yok Đôn', '1 ngày',
  NULL, NULL, 'Tour ngày kết hợp tham quan cụm thác Dray Nur hùng vĩ và trải nghiệm sinh thái tại Vườn quốc gia Yok Đôn — phù hợp cho người yêu thiên nhiên và muốn vận động nhẹ (đi bộ, tắm suối).',
  ARRAY['Xe đưa đón trong ngày', 'Hướng dẫn viên', 'Vé vào cổng các điểm tham quan'], ARRAY['Ăn uống dọc đường (trừ khi ghi rõ trong gói)', 'Chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeef1-4b2d-7849-8767-774f0dda201f', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Tour văn hóa Buôn Đôn — Sông Sêrêpôk & làng voi', '1 ngày',
  NULL, NULL, 'Tour tìm hiểu văn hóa, lịch sử nghề thuần dưỡng voi tại Buôn Đôn, đi qua cầu treo bắc qua sông Sêrêpôk, tham quan mộ vua săn voi và trải nghiệm các hoạt động du lịch thân thiện với voi.',
  ARRAY['Xe đưa đón', 'Hướng dẫn viên địa phương', 'Vé vào khu du lịch'], ARRAY['Bữa ăn (trừ khi ghi rõ trong gói)', 'Chi phí cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeef1-4b2d-76f2-b002-d69664620197', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Tour Hồ Lắk & buôn làng M''nông', '1 ngày (có thể nghỉ đêm tại khu vực hồ)',
  NULL, NULL, 'Trải nghiệm ngồi thuyền độc mộc trên hồ Lắk, tham quan buôn Jun – buôn Lê của người M''nông, xem trình diễn cồng chiêng, đàn đá, đàn T''rưng và tìm hiểu đời sống nhà dài truyền thống.',
  ARRAY['Xe đưa đón', 'Thuyền độc mộc trên hồ', 'Hướng dẫn viên'], ARRAY['Bữa ăn (trừ khi ghi rõ trong gói)', 'Lưu trú nếu nghỉ đêm'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eeef1-4b2d-7c4d-b6f2-9277a05d8c0e', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Tour văn hóa cà phê — Làng Cà phê Trung Nguyên & Bảo tàng Thế giới Cà phê', 'Nửa ngày',
  NULL, NULL, 'Tour khám phá văn hóa cà phê Buôn Ma Thuột tại Làng Cà phê Trung Nguyên và Bảo tàng Thế giới Cà phê, gồm trải nghiệm thưởng thức nhiều loại cà phê và tìm hiểu hành trình hạt cà phê từ khắp thế giới qua không gian trưng bày tương tác.',
  ARRAY['Vé vào bảo tàng (xem thêm destinations.json)', 'Hướng dẫn tham quan'], ARRAY['Đồ lưu niệm', 'Workshop pha chế (nếu có phụ thu riêng)'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '6f7cf1ad-1699-49e3-a9d8-cf94474824fb', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Tour Di Tích Lịch Sử Điện Biên Phủ Trọn Gói 1 Ngày', '1 ngày',
  NULL, NULL, 'Tour 1 ngày thăm toàn bộ cụm di tích lịch sử Điện Biên Phủ: Bảo tàng Chiến thắng, Đồi A1, Hầm Đờ Cát, Nghĩa trang Liệt sĩ A1, Đồi D1 (Dominique 2) và Him Lam. Hướng dẫn viên am hiểu lịch sử sẽ kể lại diễn biến 56 ngày đêm chiến dịch tại từng địa điểm.',
  ARRAY['xe đưa đón', 'hướng dẫn viên lịch sử', 'vé tham quan (một số điểm)', 'bữa trưa ẩm thực Thái'], ARRAY['vé tham quan các điểm tính phí riêng', 'đồ uống', 'chi tiêu cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '1d04eb5c-30aa-47b9-83da-a9d2e0f62073', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Tour Văn Hóa Bản Thái & Cánh Đồng Mường Thanh', '1 ngày',
  NULL, NULL, 'Tour 1 ngày kết hợp khám phá văn hóa bản địa: thăm bản người Thái trắng, trải nghiệm múa xòe và rượu cần, tham quan cánh đồng Mường Thanh vào mùa lúa, tìm hiểu nghề dệt thổ cẩm Thái và thưởng thức bữa trưa ẩm thực bản Thái truyền thống tại nhà sàn.',
  ARRAY['xe đưa đón', 'hướng dẫn viên văn hóa', 'bữa trưa tại bản', 'trải nghiệm múa xòe'], ARRAY['rượu cần (tính thêm nếu có)', 'chi tiêu cá nhân', 'mua sắm thổ cẩm'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  'c9e5b3f3-9fb7-41e8-b688-6babd279283e', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Hành Trình Điện Biên – Sơn La 3 Ngày 2 Đêm', '3 ngày 2 đêm',
  NULL, NULL, 'Hành trình mở rộng kết hợp Điện Biên Phủ và Sơn La trong 3 ngày: di tích lịch sử Điện Biên (ngày 1–2), cánh đồng Mường Thanh và bản Thái (ngày 2 chiều), di chuyển qua đèo Pha Đin về Sơn La và thăm Nhà tù Sơn La (ngày 3). Tour đường dài phù hợp nhóm muốn trải nghiệm Tây Bắc đầy đủ.',
  ARRAY['xe đưa đón toàn tuyến', 'hướng dẫn viên', '2 đêm khách sạn', '3 bữa sáng', '2 bữa trưa'], ARRAY['vé tham quan', 'bữa tối', 'chi tiêu cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  'c6096a08-881a-49cf-86d8-a6024b498bd9', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Tour Trekking Nam Cát Tiên 2 Ngày 1 Đêm', '2 ngày 1 đêm',
  NULL, '2–15 người', 'Gói lưu trú và trekking trong Vườn Quốc gia Nam Cát Tiên: ngày 1 đi bộ rừng quan sát chim thú, tắm suối Đatanla nhỏ, chiều thăm Bàu Sấu; tối quan sát thú ban đêm bằng đèn pin. Ngày 2 thăm Đảo Tiên và về. Lưu trú tại ecolodge trong vườn.',
  ARRAY['hướng dẫn viên sinh thái', 'vé vào VQG', 'lưu trú 1 đêm', '2 bữa ăn chính', 'tour quan sát thú ban đêm'], ARRAY['đồ uống riêng', 'bảo hiểm du lịch', 'tip hướng dẫn viên', 'chi phí di chuyển đến VQG'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '8f39689d-8f35-4783-9647-fdcab26ce717', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Tour Thác Giang Điền Ngày (từ TP.HCM)', '1 ngày (~8 tiếng)',
  NULL, '4–30 người', 'Tour ngày từ TP.HCM đến khu du lịch Thác Giang Điền — gồm: tắm thác, chèo kayak, cáp treo tham quan, leo núi nhẹ và picnic. Về TP.HCM buổi tối. Phù hợp gia đình và nhóm bạn muốn dã ngoại cuối tuần gần thành phố.',
  ARRAY['xe đưa đón TP.HCM – Giang Điền', 'vé vào khu du lịch', 'hướng dẫn viên', 'bữa trưa BBQ'], ARRAY['hoạt động trả phí riêng (kayak, cáp treo)', 'đồ uống', 'tip'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '96306272-2169-450b-8b64-3dad596f361f', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Tour Vườn Bưởi Tân Triều & Văn miếu Trấn Biên', 'Nửa ngày (4–5 tiếng)',
  NULL, '2–20 người', 'Tour khám phá văn hóa và đặc sản nổi tiếng của Đồng Nai: tham quan Văn miếu Trấn Biên — công trình văn hóa lớn nhất Nam Bộ — và vườn bưởi Tân Triều trứ danh. Hái bưởi tươi, thử đặc sản địa phương và mua quà về. Phù hợp cả gia đình và nhóm nhỏ.',
  ARRAY['xe đưa đón khu vực Biên Hòa', 'hướng dẫn viên', 'thử bưởi tại vườn'], ARRAY['mua bưởi mang về', 'đồ uống', 'tip'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  'fa4e339d-3f15-46ea-ab73-543f53400427', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Tour Câu Cá & Cắm Trại Hồ Trị An', '1 ngày hoặc 2 ngày 1 đêm',
  NULL, '2–12 người', 'Trải nghiệm câu cá trên hồ Trị An — hồ nhân tạo khổng lồ bao quanh rừng. Gói bao gồm thuyền câu, dụng cụ câu, hướng dẫn viên địa phương và có thể nấu ăn bằng cá câu được ngay trên thuyền hoặc bờ hồ. Gói cắm trại qua đêm có lửa trại và BBQ.',
  ARRAY['thuyền câu', 'dụng cụ câu cơ bản', 'hướng dẫn địa phương', 'bữa trưa (BBQ cá tự câu)'], ARRAY['phí cắm trại qua đêm (gói riêng)', 'đồ uống', 'tip'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '505c2cba-0ff8-4af5-90e5-49d292d60a95', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Tour phố cổ Hà Nội bằng xích lô + ẩm thực đêm', 'Nửa ngày (buổi tối, ~3 giờ)',
  450000, '2–15 người', 'Tham quan phố cổ bằng xích lô, dừng chân tại các điểm ăn vặt nổi tiếng (cà phê trứng, nem chua rán, bún chả).',
  ARRAY['Xích lô', 'Hướng dẫn viên', '1 món ăn thử'], ARRAY['Đồ uống thêm', 'Tip hướng dẫn viên'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '5830f6c3-0b45-40a3-99d8-1405a084ecd2', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Tour ngày: Hoàng thành Thăng Long + Văn Miếu + Lăng Bác', '1 ngày',
  600000, '2–20 người', 'Khám phá các di tích lịch sử trung tâm Hà Nội cùng hướng dẫn viên thuyết minh.',
  ARRAY['Xe đưa đón', 'Hướng dẫn viên', 'Vé vào các điểm'], ARRAY['Ăn trưa', 'Chi tiêu cá nhân'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eedf6-c8b1-7996-aeb6-16868bb9549e', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Tour 4 Đảo Nha Trang (Snorkeling & Lặn ngắm san hô)', '1 ngày (khoảng 8:00–17:00)',
  NULL, 'Đoàn lớn (20–40 người) hoặc tour nhỏ (8–12 người) tùy gói', 'Tour tàu tham quan 4 đảo: Hòn Mun (lặn ngắm san hô), Hòn Miễu, Hòn Tằm và Hòn Một. Bao gồm thiết bị lặn snorkel, bữa trưa hải sản trên thuyền, thời gian tự do bơi lội. Một số tour có option lặn scuba thêm phí.',
  ARRAY['Tàu đưa đón', 'Thiết bị snorkel', 'Bữa trưa trên thuyền', 'Hướng dẫn viên'], ARRAY['Vé lặn scuba (thêm phí)', 'Đồ uống ngoài bữa', 'Bảo hiểm du lịch'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eedf6-c8b1-7088-abe2-513c689d4899', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Tour Bình Ba — Đảo Tôm Hùm', '2 ngày 1 đêm',
  NULL, 'Nhóm nhỏ 6–15 người', 'Tour khám phá đảo Bình Ba (Cam Ranh), nổi tiếng với tôm hùm tươi sống giá tốt và bãi biển hoang sơ. Chương trình bao gồm tàu ra đảo, lưu trú nhà dân hoặc resort nhỏ, ăn hải sản đảo, bơi lội tự do.',
  ARRAY['Tàu đi về', 'Lưu trú 1 đêm tại đảo', 'Các bữa ăn theo chương trình'], ARRAY['Chi tiêu cá nhân', 'Hải sản ăn thêm ngoài chương trình'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eedf6-c8b1-75df-83e7-ecd9ffba341d', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Tour Tắm Bùn I-Resort Nha Trang', 'Nửa ngày (khoảng 4–5 giờ)',
  NULL, 'Không giới hạn (đặt trước vào cuối tuần)', 'Trải nghiệm tắm bùn khoáng thiên nhiên tại I-Resort — địa điểm tắm bùn nổi tiếng nhất Nha Trang. Bùn khoáng từ nguồn tự nhiên, nhiều gói: tắm bùn đôi, gia đình, cá nhân. Kết hợp ngâm suối khoáng nóng và hồ bơi.',
  ARRAY['Vé vào cổng', 'Bùn khoáng', 'Phòng thay đồ', 'Khăn tắm'], ARRAY['Buffet (tùy gói)', 'Đồ uống', 'Dịch vụ spa thêm'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eedf6-c8b1-726d-884b-99681942bae1', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Tour Lặn Scuba Hòn Mun (Diving)', '1 ngày',
  NULL, 'Nhóm nhỏ tối đa 6 người/hướng dẫn viên lặn', 'Lặn scuba khám phá vùng biển Hòn Mun — khu bảo tồn biển quốc gia với san hô đa dạng và cá nhiều màu sắc. Có chương trình dành cho người chưa có chứng chỉ (fun dive kèm hướng dẫn viên) và cho người có chứng chỉ PADI.',
  ARRAY['Tàu ra đảo', 'Thiết bị lặn', 'Hướng dẫn viên lặn', 'Bữa trưa nhẹ'], ARRAY['Phí xin chứng chỉ PADI (nếu muốn học)', 'Bảo hiểm'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee06-3f91-75ea-9c91-fc5ad50cc5f0', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Tour Địa Đạo Củ Chi Nửa Ngày', 'Nửa ngày (khoảng 4–5 tiếng)',
  NULL, 'Nhóm nhỏ 10–20 người hoặc tour riêng', 'Tour khám phá hệ thống địa đạo lịch sử Củ Chi — di tích quốc gia đặc biệt cách trung tâm ~70km. Hướng dẫn viên giải thích lịch sử kháng chiến, tham quan bẫy địa đạo, thử chui qua đường hầm được mở rộng, xem biểu diễn vũ khí thủ công và thưởng thức khoai mì (sắn) — thức ăn của du kích năm xưa.',
  ARRAY['xe đưa đón từ trung tâm Quận 1', 'hướng dẫn viên tiếng Anh hoặc Việt', 'vé vào cửa'], ARRAY['bữa ăn', 'đồ uống', 'phí chụp ảnh chuyên nghiệp'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee06-3f91-74b3-bae4-44b73d261c37', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Tour Đồng Bằng Sông Cửu Long 1 Ngày', '1 ngày (khoảng 9–10 tiếng)',
  NULL, 'Nhóm 10–25 người hoặc tour riêng', 'Day trip từ TP. HCM xuống miền Tây sông nước, thường đến Mỹ Tho (Tiền Giang) hoặc Bến Tre. Đi thuyền nhỏ len lỏi các kênh rạch, thăm làng nghề làm kẹo dừa, nghe đờn ca tài tử, ăn trưa miệt vườn với cá tai tượng chiên xù và rau vườn. Trải nghiệm đời sống sông nước đặc trưng Nam Bộ.',
  ARRAY['xe đưa đón từ trung tâm TP. HCM', 'thuyền tham quan kênh rạch', 'hướng dẫn viên', 'bữa trưa (tùy gói tour)'], ARRAY['đồ uống', 'phí dịch vụ thêm tại điểm tham quan'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();
INSERT INTO tours (id, destination_id, name, duration, price, group_size, description, includes, excludes, meeting_point, is_active) VALUES (
  '019eee06-3f91-783b-a969-efcdf11f388b', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Tour Khám Phá Sài Gòn Cổ — Walking & Food Tour', 'Nửa ngày (khoảng 3–4 tiếng)',
  NULL, 'Nhóm nhỏ 5–12 người', 'Tour đi bộ khám phá kiến trúc và ẩm thực Sài Gòn xưa, thường xuất phát từ Chợ Bến Thành qua Nhà thờ Đức Bà, Bưu điện Thành phố, phố ẩm thực Phạm Ngũ Lão và khu Chợ Lớn người Hoa. Dọc đường thử nhiều món ăn đường phố như bánh mì, gỏi cuốn, hủ tiếu và chè. Phù hợp người mới đến lần đầu.',
  ARRAY['hướng dẫn viên địa phương', 'thử 4–6 món ăn đường phố', 'nước uống'], ARRAY['di chuyển bằng xe', 'bữa ăn chính'],
  NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, price=EXCLUDED.price, description=EXCLUDED.description, updated_at=NOW();