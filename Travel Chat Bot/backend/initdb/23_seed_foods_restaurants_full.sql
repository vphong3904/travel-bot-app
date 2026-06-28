-- PDTrip – Seed: Foods + Restaurants

INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '019eee71-616e-7d64-babf-28aaee83e7fa', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Gỏi cá trích', 'seafood', 'Đặc sản nổi tiếng nhất Phú Quốc. Cá trích tươi lọc xương, trộn với dừa nạo, sả, rau thơm và nước cốt chanh. Ăn kèm bánh tráng và rau sống. Hương vị tươi mát, đặc trưng vùng biển.',
  '50.000–80.000đ/đĩa (ƯỚC TÍNH)', 'Các quán ven biển khu Dương Đông, nhà hàng Hàm Ninh', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '019eee71-616e-7fe1-83a9-976f44747106', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Nhum nướng mỡ hành', 'seafood', 'Nhum biển (cầu gai) nướng mỡ hành, một trong những món hải sản đặc trưng nhất Phú Quốc. Thịt nhum màu cam, béo ngậy, ăn kèm bánh mì hoặc cơm. Chỉ có theo mùa (thường tháng 11–4).',
  '150.000–250.000đ/con (ƯỚC TÍNH, tùy kích cỡ)', 'Chợ đêm Dinh Cậu, làng chài Hàm Ninh', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '019eee71-616e-7b40-9257-b3912356d25c', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Nước mắm Phú Quốc', 'condiment', 'Nước mắm nổi tiếng nhất Việt Nam, được làm từ cá cơm đảo ngâm ủ tối thiểu 12–18 tháng trong thùng gỗ. Màu nâu đỏ, thơm đặc trưng, đạm cao. Là đặc sản mua về làm quà số 1.',
  '50.000–200.000đ/chai tùy loại (ƯỚC TÍNH)', 'Làng nghề nước mắm Dương Đông, các cơ sở Khải Hoàn, Thanh Hà', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '019eee71-616e-75a2-96f5-673c7593eb74', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Ghẹ rang muối / hấp bia', 'seafood', 'Ghẹ biển Phú Quốc tươi sống, chế biến theo phong cách rang muối ớt hoặc hấp bia lá sả. Thịt ghẹ chắc, ngọt tự nhiên. Ăn tại chỗ ở chợ đêm hoặc nhà hàng ven biển.',
  '150.000–300.000đ/con (ƯỚC TÍNH, tùy trọng lượng)', 'Chợ đêm Dinh Cậu, nhà hàng khu Bãi Trường', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '019eee71-616e-7afe-b188-b034d279731f', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Bún quậy Phú Quốc', 'noodle', 'Món bún đặc sản địa phương ít ai biết, sợi bún tươi lớn hơn bún thường, chan nước lèo từ hải sản (ghẹ, mực, tôm), ăn kèm rau thơm và tôm tươi. Tên ''quậy'' do người ăn tự khuấy đều bát trước khi thưởng thức.',
  '40.000–70.000đ/tô (ƯỚC TÍNH)', 'Các quán bún quậy ở khu Dương Đông, chợ sáng Phú Quốc', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '019eee71-616e-7a79-8ef0-05e0d3f75569', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Rượu sim Phú Quốc', 'beverage', 'Rượu vang làm từ quả sim tươi trên núi Phú Quốc, màu tím đỏ, vị ngọt nhẹ, nồng độ thấp. Là đặc sản uống tại chỗ hoặc mua về làm quà. Cơ sở Tám Nhàn và Ngọc Hiền nổi tiếng nhất.',
  '80.000–200.000đ/chai (ƯỚC TÍNH)', 'Trang trại rượu sim khu Dương Đông, các cửa hàng quà lưu niệm', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee71-616e-78c6-935e-f39d26e7688d', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Nhà hàng Ganesh – Indian & Italian Restaurant', 'Bãi Trường (Long Beach)', 'Đường Trần Hưng Đạo, Bãi Trường, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Ấn Độ', 'Ý', 'Châu Âu'], '150.000–350.000đ/người (ƯỚC TÍNH)', '10:00–22:30',
  ARRAY['Cà ri bơ gà', 'Pizza lò đất', 'Naan'], 'Phù hợp khách quốc tế và ai muốn đổi vị sau nhiều bữa hải sản. Đặt bàn trước vào mùa cao điểm.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee71-616e-7c7e-99b8-8d15b27e4fc6', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Quán Hải Sản Hàm Ninh', 'Làng chài Hàm Ninh (phía đông đảo)', 'Cầu cảng Hàm Ninh, xã Hàm Ninh, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Hải sản', 'Việt Nam'], '100.000–300.000đ/người (ƯỚC TÍNH, tùy hải sản chọn)', '7:00–20:00',
  ARRAY['Ghẹ hấp bia', 'Mực nướng sa tế', 'Tôm sú hấp sả', 'Gỏi cá trích'], 'Nhiều quán tương tự dọc cầu cảng, so sánh giá hải sản tươi sống trước khi đặt. Ăn trưa xem hoàng hôn chiều rất đẹp.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee71-616e-77ff-ada9-1b6963ab18be', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Chợ đêm Dinh Cậu – Các quầy ẩm thực', 'Khu Dinh Cậu – Dương Đông', 'Đường Bạch Đằng, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Hải sản nướng', 'Ẩm thực đường phố', 'Nước ép'], '30.000–150.000đ/món (ƯỚC TÍNH)', '17:00–23:00',
  ARRAY['Mực nướng muối ớt', 'Nhum nướng', 'Bắp nướng bơ', 'Nước dừa'], 'Nên thử nhum nướng mỡ hành tại đây (theo mùa). Ăn sớm lúc 17:30–18:30 trước khi quầy ngon bán hết.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee71-616e-7846-837b-e0e8fd0e22e5', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Quán Bún Quậy Kiên Giang', 'Dương Đông (trung tâm)', 'Đường 30 Tháng 4, khu Dương Đông, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Việt Nam', 'Bún'], '40.000–80.000đ/tô (ƯỚC TÍNH)', '6:00–13:00 (chỉ buổi sáng)',
  ARRAY['Bún quậy hải sản', 'Bánh canh ghẹ'], 'Đây là món bữa sáng địa phương, đến trước 9:00 để tránh hết. Nhiều quán cùng khu, tìm quán đông khách địa phương là ngon nhất.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'da0a5de7-d5fa-5a49-acbb-6f991aad1a0d', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Bánh phu thê Đình Bảng', 'specialty', 'Bánh vuông nhỏ làm từ bột gạo nếp hoặc bột sắn dây, nhân đậu xanh ngọt trộn dừa nạo, vỏ bánh trong mờ bọc trong lá dong xanh. Mềm dẻo, thơm nhẹ, ngọt thanh. Đặc sản nổi tiếng nhất Bắc Ninh và là quà biếu tặng truyền thống.',
  NULL, '[''Làng Đình Bảng, phường Đình Bảng, thị xã Từ Sơn (mua tại các hộ gia đình làng nghề)'', ''Khu vực gần Đền Đô (các quầy hàng lưu niệm)'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '8f41baad-8bb4-5d49-aae0-c163da55f8a1', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Nem Bùi', 'specialty', 'Nem cuốn truyền thống của Bắc Ninh làm từ thịt lợn giã nhuyễn, trộn bì, gia vị và lá đinh lăng, bọc trong lá chuối lên men chua nhẹ. Ăn kèm với tỏi, ớt và lá sung, lá ổi. Hương vị đặc trưng chua ngọt mặn không nơi nào có.',
  NULL, '[''Chợ Bùi, thành phố Bắc Ninh'', ''Các quán đặc sản trên phố Ngô Gia Tự'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'cbaeb6a7-87ef-5c6f-875e-0c4a1109c4b1', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Bún cá rô Bắc Ninh', 'main_dish', 'Món bún sáng đặc trưng của người Bắc Ninh, nước dùng từ cá rô đồng ngọt tự nhiên, ăn kèm bún tươi, rau sống và chả cá chiên vàng. Vị thanh đạm, nhẹ nhàng khác hẳn bún bò hay bún riêu miền Nam.',
  NULL, '[''Các quán bún sáng quanh chợ trung tâm thành phố Bắc Ninh'', ''Phố Ngô Gia Tự và khu vực hồ Hoàn Kiếm Bắc Ninh'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '92f72e6d-167c-5b83-80ba-8104926c8c86', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Rượu làng Vân', 'drink', 'Rượu gạo nếp cái hoa vàng được nấu thủ công tại làng Vân (nay thuộc huyện Việt Yên, Bắc Ninh sau sáp nhập). Nồng độ 40–50 độ, màu trong suốt, hương thơm đặc trưng của nếp cái. Từng là rượu tiến vua thời phong kiến.',
  NULL, '[''Làng Vân, huyện Việt Yên (mua trực tiếp tại làng)'', ''Các cửa hàng đặc sản tại thành phố Bắc Ninh'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '18018d84-4833-5dd4-b0a9-7212e0540649', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Bánh tro Bắc Ninh', 'snack', 'Bánh làm từ gạo nếp ngâm nước tro đốt từ củi tre, gói lá dong, luộc chín có màu vàng nâu trong suốt. Ăn kèm mật mía hoặc đường. Vị thanh nhẹ, không ngấy, mát lành. Thường xuất hiện vào dịp Tết Đoan Ngọ (5/5 âm lịch) nhưng có bán quanh năm.',
  NULL, '[''Chợ trung tâm thành phố Bắc Ninh'', ''Các chợ làng quê trong tỉnh'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '20726147-4233-525f-9faa-f6d831fddc32', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Xôi lúa (xôi ngô)', 'snack', 'Xôi nếp nấu cùng ngô non xay vỡ, hạt dền hoặc đậu, rắc dừa nạo và đường. Vị ngọt bùi đặc trưng, là món ăn sáng hoặc ăn vặt phổ biến của người Bắc Ninh.',
  NULL, '[''Các xe đẩy gánh xôi sáng trước cổng chợ'', ''Khu phố ẩm thực trung tâm thành phố'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee91-daa4-714e-659d-9719785b6000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Quán Bún Cá Rô Bà Hoa', '', 'Khu vực phố Ngô Gia Tự, thành phố Bắc Ninh (xác nhận địa chỉ tại Foody hoặc Google Maps)',
  ARRAY['restaurant'], '', '6:00–10:30 (buổi sáng — xác nhận trước khi đến)',
  ARRAY['bún cá rô đồng', 'chả cá chiên', 'bún riêu'], 'Đến trước 8:00 để có chỗ ngồi và bún còn nóng. Quán đông nhất từ 7:00–8:30.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee91-daa5-7121-62f9-e039ecadf000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Khu ẩm thực phố Lý Thái Tổ', '', 'Đường Lý Thái Tổ, thành phố Bắc Ninh (khu tập trung quán ăn vỉa hè buổi tối)',
  ARRAY['street_food'], '', '17:00–22:00 (tham khảo — xác nhận trước khi đến)',
  ARRAY['nem Bùi', 'thịt nướng', 'hải sản nướng', 'nộm bò khô', 'bia hơi'], 'Nên đặt chỗ trước nếu đi nhóm đông vào cuối tuần. Nhiều quán mở theo mùa hoặc thay đổi địa điểm — hỏi người dân địa phương để có gợi ý mới nhất.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee91-daa6-71ec-a2a6-b15b0d938000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Nhà hàng Quan Họ Garden', '', 'Khu vực ngoại ô thành phố Bắc Ninh (xác nhận địa chỉ tại Google Maps)',
  ARRAY['restaurant'], '', '10:00–21:00 (xác nhận trước khi đến)',
  ARRAY['bánh phu thê', 'nem Bùi', 'bún cá rô', 'gà đồi hấp lá chanh', 'xôi lúa'], 'Phù hợp cho đoàn gia đình hoặc nhóm đông. Gọi trước nếu muốn đặt bàn hoặc thực đơn riêng cho đoàn.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '55cb6ba8-98a3-53b7-a02a-a19afe7961c7', '23431b56-3e63-4368-949f-8df24ab3c539', 'Cua Cà Mau', 'main_dish', 'Cua biển Cà Mau nổi tiếng khắp cả nước với thịt chắc, gạch béo và hương vị đậm đà nhờ nguồn nước mặn vùng ngập mặn. Có thể chế biến nhiều cách: hấp gừng, rang muối, nướng, nấu canh chua hoặc bún cua. Đặc biệt ngon nhất vào mùa cua gạch (tháng 9–11 âm lịch).',
  NULL, '[''Chợ Cà Mau'', ''Các nhà hàng hải sản TP. Cà Mau'', ''Bến Năm Căn'', ''Chợ cua Cà Mau'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '8535fb38-6b67-5cc6-b62d-076d01f84611', '23431b56-3e63-4368-949f-8df24ab3c539', 'Ba khía muối', 'specialty', 'Đặc sản nổi tiếng của vùng Rạch Gốc - Ngọc Hiển, Cà Mau. Ba khía là loài cua nhỏ sống ở bìa rừng đước, được ướp muối theo phương pháp truyền thống tạo nên món ăn mặn mà hương vị biển rừng. Ăn kèm cơm nóng, bún hoặc làm nước chấm. Hằng năm có Lễ hội Ba khía vào tháng 10 âm lịch.',
  NULL, '[''Chợ Cà Mau'', ''Chợ Năm Căn'', ''Các cơ sở đặc sản địa phương'', ''Huyện Ngọc Hiển'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '5a839e3f-19c2-529d-9c18-b2ae2de3e310', '23431b56-3e63-4368-949f-8df24ab3c539', 'Cá thòi lòi nướng', 'main_dish', 'Cá thòi lòi là loài cá kỳ lạ có thể sống trên cạn và leo cây đước — đặc trưng chỉ có ở vùng rừng ngập mặn. Thịt cá săn chắc, nướng than với sả ớt hoặc kho tiêu có vị ngọt tự nhiên và thơm đặc biệt. Hiện ngày càng khan hiếm nên là đặc sản quý.',
  NULL, '[''Nhà hàng đặc sản Cà Mau'', ''Khu vực Năm Căn'', ''Đất Mũi'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '9b5d2d59-26f9-5e1e-ab8d-0f48d890b7e7', '23431b56-3e63-4368-949f-8df24ab3c539', 'Mật ong rừng U Minh', 'specialty', 'Mật ong khai thác từ đàn ong mật tự nhiên trong rừng tràm U Minh Hạ — có màu vàng đậm, độ sánh cao và hương thơm đặc trưng của hoa tràm. Nổi tiếng là một trong những loại mật ong ngon và sạch nhất Việt Nam, được bán rộng rãi làm quà.',
  NULL, '[''Vườn Quốc gia U Minh Hạ'', ''Chợ Cà Mau'', ''Cơ sở đặc sản địa phương'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '22ee0872-33e8-5c63-8a42-cf80fc75fdc9', '23431b56-3e63-4368-949f-8df24ab3c539', 'Bánh tét lá cẩm', 'specialty', 'Bánh tét đặc trưng miền Tây Nam Bộ nhưng phiên bản Cà Mau được gói bằng lá cẩm tạo màu tím đẹp mắt. Nhân bánh gồm đậu xanh và thịt heo. Thường được làm dịp Tết Nguyên Đán và bán quanh năm tại các chợ. Vừa ngon vừa có giá trị làm quà.',
  NULL, '[''Chợ Cà Mau'', ''Chợ TP. Bạc Liêu'', ''Cơ sở làm bánh truyền thống'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'eb2e7705-1321-564e-8793-ce018ab5e664', '23431b56-3e63-4368-949f-8df24ab3c539', 'Tôm khô Cà Mau', 'specialty', 'Tôm sú và tôm thẻ phơi khô theo phương pháp truyền thống — đặc sản nổi tiếng nhất Cà Mau sau cua biển. Màu đỏ hồng tự nhiên, vị ngọt đậm, dùng nấu canh chua, xào dưa kiệu hoặc ăn kèm cơm. Được bán nhiều tại cảng cá và chợ, phổ biến làm quà biếu.',
  NULL, '[''Chợ Cà Mau'', ''Cảng cá Sông Đốc'', ''Năm Căn'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '0f409f96-dc44-4a84-9355-d0fe9dca6031', '23431b56-3e63-4368-949f-8df24ab3c539', 'Nhà hàng Đất Mũi', '', 'Khu vực Đất Mũi, huyện Ngọc Hiển, tỉnh Cà Mau',
  ARRAY['restaurant'], '// TODO: xác nhận giá bàn cơm tại Foody hoặc Google Maps', 'Thường 7:00–21:00 — xác nhận trước khi đến',
  ARRAY['cua biển hấp', 'ba khía rang muối', 'cá thòi lòi nướng', 'tôm sú hấp'], 'Gọi trước nếu đến theo đoàn đông. Chú ý hỏi giá trước khi gọi — một số nơi tính theo ký hải sản sống.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '26e1eb94-97ea-4f83-b779-798726096b14', '23431b56-3e63-4368-949f-8df24ab3c539', 'Quán Cua Gạch Năm Căn', '', 'Khu vực thị trấn Năm Căn, huyện Năm Căn, tỉnh Cà Mau',
  ARRAY['restaurant'], '// TODO: xác nhận giá cua theo ký tại Foody', 'Thường 8:00–21:00 — xác nhận trước khi đến',
  ARRAY['cua gạch hấp', 'cua rang me', 'lẩu cua', 'gỏi sứa'], 'Mùa cua gạch đẹp nhất tháng 9–11 âm lịch. Hỏi cua đực hay cái trước khi chọn để phù hợp khẩu vị.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '2dffe94e-ea53-4872-810f-3201fdda4cb3', '23431b56-3e63-4368-949f-8df24ab3c539', 'Chợ đêm Cà Mau', '', 'Khu vực chợ trung tâm TP. Cà Mau',
  ARRAY['market_stall'], '// TODO: xác nhận giá các món tại Foody', 'Thường 17:00–22:00',
  ARRAY['bánh canh cua', 'bún bò Huế', 'gỏi cuốn', 'chè ba màu', 'bánh chuối nướng'], 'Đi từ 18:00–19:00 khi hàng quán đông và đồ ăn còn tươi nhất.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '7bb81c99-9539-4bb2-884e-26723ed2e6b5', '23431b56-3e63-4368-949f-8df24ab3c539', 'Nhà hàng Hải sản Sông Đốc', '', 'Khu vực cảng cá Sông Đốc, huyện Trần Văn Thời, tỉnh Cà Mau',
  ARRAY['restaurant'], '// TODO: xác nhận giá tại Google Maps hoặc Foody', 'Thường 7:00–21:00 — xác nhận trước khi đến',
  ARRAY['tôm sú nướng muối ớt', 'mực xào cần tỏi', 'ghẹ hấp sả', 'canh chua cá bớp'], 'Đến sáng sớm để chọn hải sản tươi nhất vừa về cảng. Mặc cả nhẹ nhàng khi mua hải sản theo ký.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'dac09969-2a48-5a46-aad0-ac106e534c4f', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Bánh xèo miền Tây', 'main_dish', 'Bánh xèo miền Tây to hơn và dày hơn bánh xèo miền Trung, nhân tôm thịt hoặc hải sản, ăn kèm rau sống (lá điều, lá lốt, giá...) và nước mắm chua ngọt pha loãng. Cách ăn đặc trưng là cuốn bánh vào lá điều hay lá lốt trước khi chấm.',
  NULL, '[''Quán bánh xèo Mười Xinh (Quận Ninh Kiều)'', ''Chợ đêm Ninh Kiều'', ''Các quán dọc đường Đề Thám'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '3bbe27cd-b2cb-52a4-a824-35aab63b2fa5', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Lẩu mắm miền Tây', 'main_dish', 'Lẩu nấu từ mắm cá linh hoặc mắm sặc — đặc sản miền Tây Nam Bộ có vị ngọt ngào và thơm đặc trưng không nơi nào có được. Ăn cùng cá lóc, tôm, mực, thịt heo quay và nhiều loại rau đặc trưng như bông súng, rau muống, chuối xanh.',
  NULL, '[''Nhà hàng Mekong (khu Ninh Kiều)'', ''Các nhà hàng nổi trên sông Bình Thủy'', ''Chợ đêm Ninh Kiều'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'f1941797-cb1c-5136-9a1e-74e48dd86e28', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Nem nướng Cái Răng', 'main_dish', 'Nem nướng Cần Thơ nổi tiếng với thịt heo xay viên nướng than hoa, ăn cùng bánh tráng, bún, rau sống, chuối xanh, dưa leo và nước chấm từ mắm nêm. Cái Răng (quận cách trung tâm ~5km) là nơi được coi là cái nôi của món này.',
  NULL, '[''Các quán nem nướng khu Cái Răng'', ''Đường Phan Đình Phùng (Ninh Kiều)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'a9eaede8-14c7-5d51-b738-f2c953efd8ec', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Cá lóc nướng trui', 'main_dish', 'Cá lóc đồng (cá rô đồng) được nướng nguyên con bằng lửa rơm không cần ướp gia vị, khi chín lột da bỏ đi còn lại phần thịt trắng ngần thơm ngon. Ăn cuốn với bánh tráng, rau sống và mắm nêm — là món ăn dân dã đặc trưng nhất của người miền Tây.',
  NULL, '[''Các nhà hàng sân vườn ven sông'', ''Khu ẩm thực Bình Thủy'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'fb73d2aa-3c6b-51bc-adf0-7662f96a5ed3', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Hủ tiếu Nam Vang Cần Thơ', 'main_dish', 'Hủ tiếu phong cách Campuchia (Nam Vang) được biến tấu theo khẩu vị miền Tây — nước dùng trong, ngọt từ xương heo và mực khô, ăn kèm thịt heo xay, tôm, lòng heo và nhiều rau giá. Cần Thơ có nhiều quán hủ tiếu Nam Vang nổi tiếng lâu đời.',
  NULL, '[''Hủ tiếu Nam Vang Mỹ Khánh (Phong Điền)'', ''Các quán sáng sớm ven kênh Ninh Kiều'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '8b30bc2b-9855-5d01-9954-93e4df29d60e', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Bánh tráng nướng miền Tây', 'snack', 'Bánh tráng (bánh đa) nướng trên lửa than, phết mỡ hành, trứng cút và các loại topping như tôm khô, nem chà bông. Món ăn vặt đường phố rất phổ biến ở Cần Thơ, đặc biệt tại các chợ đêm và bến Ninh Kiều.',
  NULL, '[''Chợ đêm Ninh Kiều'', ''Vỉa hè đường Hai Bà Trưng'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '6748d498-8661-5052-b7fc-e1f978df8705', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chè bưởi / chè đậu miền Tây', 'dessert', 'Các loại chè miền Tây phong phú: chè bưởi (múi bưởi ngâm siro cùng thạch dừa, nước cốt dừa), chè đậu xanh lá dứa, chè thập cẩm... Vị ngọt dịu, béo nhẹ từ nước cốt dừa là điểm đặc trưng của chè Nam Bộ.',
  NULL, '[''Chợ đêm Ninh Kiều'', ''Các quán chè dọc đường Đề Thám'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '1c69f7cd-58e2-4967-ae17-58bc4ad314a3', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Nhà hàng Mekong', '', 'Khu vực bến Ninh Kiều, Quận Ninh Kiều, TP. Cần Thơ',
  ARRAY['restaurant'], 'Trung bình – Cao', NULL,
  ARRAY['lẩu mắm miền Tây', 'cá lóc nướng trui', 'tôm càng xanh hấp', 'canh chua cá bông lau'], 'Đặt bàn trước vào cuối tuần. Thử combo lẩu mắm + cá nướng là bộ đôi kinh điển.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'b28c7a08-14cb-41b7-ae78-fcaa2467822e', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Quán bánh xèo Mười Xinh', '', 'Đường Đề Thám hoặc khu vực Ninh Kiều, TP. Cần Thơ',
  ARRAY['street_food'], 'Bình dân', 'Thường 10:00–21:00 — xác nhận thực tế tại Foody.vn trước khi đến',
  ARRAY['bánh xèo miền Tây', 'bánh khọt', 'gỏi cuốn'], 'Đến vào buổi trưa hoặc chiều tối khi bánh ra mẻ mới. Chỗ ngồi có thể chật vào giờ cao điểm.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '21f1c014-fe3b-4d61-9052-1b519dcf1099', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chợ đêm Ninh Kiều', '', 'Bến Ninh Kiều, Đường Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ',
  ARRAY['market_stall'], 'Bình dân', '18:00–22:00 hàng ngày — xác nhận thực tế trước khi đến',
  ARRAY['bánh tráng nướng', 'nem nướng', 'bún bì chả', 'chè các loại', 'trái cây miền Tây'], 'Vừa ăn vừa ngắm sông về đêm rất thơ mộng. Cuối tuần thường có biểu diễn đờn ca tài tử gần đây.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '1475dd0c-03f7-4379-b960-12542745cdd5', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Nhà hàng Sông Hương (Bình Thủy)', '', 'Khu vực Quận Bình Thủy, TP. Cần Thơ',
  ARRAY['restaurant'], 'Trung bình', NULL,
  ARRAY['cá lóc nướng trui', 'lẩu cá kèo', 'hủ tiếu mực', 'tôm sú nướng muối ớt'], 'Kết hợp với tham quan Nhà cổ Bình Thủy ngay gần đó trong cùng buổi chiều.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '4710c1cf-86d2-573a-ada9-cefd3552b532', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Bánh Cuốn Cao Bằng', 'main_dish', 'Bánh cuốn Cao Bằng có lớp vỏ mỏng làm từ bột gạo tẻ địa phương, cuộn nhân thịt lợn băm xào mộc nhĩ và nấm hương. Điểm khác biệt so với bánh cuốn miền xuôi là nước chấm pha từ nước dùng thịt lợn hầm xương đậm đà, kèm thêm chả rán và giò lụa. Món ăn sáng phổ biến nhất ở Cao Bằng.',
  '// TODO: xác nhận tại Foody.vn hoặc Google Maps', '[''Chợ Cao Bằng'', ''Các quán ăn sáng khu trung tâm TP. Cao Bằng'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'ba6fc637-43cd-54b2-880d-58d1e9706312', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Hạt Dẻ Trùng Khánh', 'specialty', 'Hạt dẻ trồng tại huyện Trùng Khánh — loại đặc sản nổi tiếng nhất Cao Bằng được bảo hộ chỉ dẫn địa lý. Hạt to, bùi, ngọt tự nhiên hơn hẳn hạt dẻ nơi khác. Thường nướng hoặc luộc ăn trực tiếp, hay làm thành bánh hạt dẻ và chè hạt dẻ. Mùa thu hoạch tháng 9–11.',
  '// TODO: xác nhận tại chợ địa phương — giá theo mùa', '[''Chợ Cao Bằng'', ''Chợ Trùng Khánh'', ''Các cửa hàng đặc sản TP. Cao Bằng'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '99074f97-808f-50bf-abc7-9d757d96ff76', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Vịt Quay 7 Vị', 'main_dish', 'Vịt quay đặc trưng của người Tày-Nùng Cao Bằng, ướp bảy loại gia vị bản địa gồm mắc mật, gừng, tỏi, sả, hồi, quế và thảo quả. Da giòn vàng óng, thịt thơm đậm đà hương núi rừng, khác hoàn toàn so với vịt quay Bắc Kinh hay vịt quay Long Sơn. Thường bán nguyên con hoặc theo phần.',
  '// TODO: xác nhận tại Foody.vn hoặc Google Maps', '[''Các quán vịt quay ở TP. Cao Bằng'', ''Chợ Cao Bằng'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'a50b08e3-687b-58d4-9419-09bf7e27ba2f', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Miến Dong Cao Bằng', 'main_dish', 'Miến làm từ tinh bột dong riềng trồng trên đất đồi Cao Bằng, sợi dai trong vắt, nấu không bị nhũn. Thường nấu với xương lợn, gà hoặc vịt, ăn cùng giò, chả và rau thơm địa phương. Là món chủ đạo của bữa giỗ, đám cưới người Tày và được bán phổ biến tại chợ.',
  '// TODO: xác nhận tại Foody.vn', '[''Chợ Cao Bằng'', ''Các quán bún phở khu trung tâm'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'c180fb92-b6bc-57df-95ea-0c916ec0171e', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Bánh Áp Chao', 'snack', 'Bánh rán giòn đặc sản của người Nùng Cao Bằng, làm từ bột gạo trộn nhân thịt vịt hoặc thịt lợn và nấm hương, chiên ngập dầu cho đến khi vỏ ngoài giòn rụm vàng đẹp. Thường ăn kèm tương ớt và rau sống. Món ăn vặt buổi sáng và chiều tối rất phổ biến.',
  '// TODO: xác nhận tại Foody.vn hoặc Google Maps', '[''Chợ Cao Bằng'', ''Khu chợ đêm TP. Cao Bằng'', ''Các hàng rong ven đường'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '8994489a-0954-5234-ba1b-02803b8d039d', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Lợn Quay Lá Mắc Mật', 'main_dish', 'Lợn bản địa giống Lũng Pù được nuôi thả trên đồi, quay bằng củi và nhồi nhân lá mắc mật — loại lá rừng đặc trưng của vùng núi Đông Bắc. Da giòn tan, thịt mềm thơm mùi lá, khó tìm thấy ở nơi khác. Thường dùng trong dịp lễ Tết và đặc biệt phổ biến vào cuối năm.',
  '// TODO: xác nhận tại Google Maps hoặc Foody.vn', '[''Nhà hàng và quán ăn TP. Cao Bằng'', ''Chợ phiên các huyện'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'e0e4379c-65da-42d0-b3f8-0cb84bfb523b', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Quán Bánh Cuốn Chợ Cao Bằng', '', 'Khu vực chợ Hợp Giang, TP. Cao Bằng — xác nhận địa chỉ cụ thể tại Google Maps',
  ARRAY['street_food'], '// TODO: xác nhận tại Foody.vn', '5:30–11:00 hằng ngày — xác nhận trước khi đến',
  ARRAY['bánh cuốn Cao Bằng', 'chả rán', 'giò lụa'], 'Đến trước 8:00 để không phải chờ lâu. Gọi thêm chả rán để có trải nghiệm đầy đủ nhất.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '510d239e-7f7b-4d25-8023-33ad0be8d4cf', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Nhà Hàng Vịt Quay Cao Bằng', '', 'Khu trung tâm TP. Cao Bằng — xác nhận địa chỉ cụ thể tại Google Maps',
  ARRAY['restaurant'], '// TODO: xác nhận tại Foody.vn hoặc Google Maps', '10:00–21:00 hằng ngày — xác nhận trước khi đến',
  ARRAY['vịt quay 7 vị', 'lợn quay lá mắc mật', 'miến vịt'], 'Nên gọi trước nếu đi nhóm lớn hoặc muốn đặt vịt quay nguyên con. Hỏi thêm về các món theo mùa.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '5dd9e83f-dd2c-4314-b5d7-6b66835e444b', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Quán Bánh Áp Chao Khu Chợ', '', 'Khu chợ TP. Cao Bằng — xác nhận địa chỉ cụ thể tại Google Maps',
  ARRAY['street_food'], '// TODO: xác nhận tại Foody.vn', '6:00–12:00 và 16:00–20:00 — xác nhận trước khi đến',
  ARRAY['bánh áp chao', 'bánh rán nhân thịt vịt'], 'Mua nóng sẽ ngon hơn nhiều. Có thể mua về làm quà vặt dọc đường.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'bf18f0c0-5486-4450-a37e-619ef7ba40ca', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Quán Ăn Khu Vực Bản Giốc', '', 'Khu vực gần thác Bản Giốc, huyện Trùng Khánh, tỉnh Cao Bằng',
  ARRAY['restaurant'], '// TODO: xác nhận tại Google Maps — giá vùng du lịch thường cao hơn thành phố', '7:00–18:00 hằng ngày (theo giờ thăm quan thác) — xác nhận trước khi đến',
  ARRAY['cơm lam', 'gà nướng mắc mật', 'rau rừng xào tỏi', 'cá suối nướng'], 'Ăn trưa tại đây sau khi tham quan thác để tiết kiệm thời gian. Giá thường cao hơn trong thành phố.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '288801ff-a847-5be2-b599-242a4ad233c7', '44444444-4444-4444-4444-444444444444', 'Cao lầu', 'main_dish', 'Món mì đặc trưng chỉ có tại Hội An, sợi mì dày và giòn hơn các loại mì khác vì được nhúng nước từ giếng Bá Lễ và tro củi tràm, ăn kèm thịt heo xá xíu, tóp mỡ và rau sống.',
  NULL, '[''Quán trong hẻm khu phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'fe44f037-f799-5407-967b-73ab33df15fc', '44444444-4444-4444-4444-444444444444', 'Mì Quảng', 'main_dish', 'Sợi mì gạo vàng nghệ ăn với rất ít nước dùng (khác phở/bún), kèm tôm, thịt heo, trứng cút, đậu phộng rang và bánh tráng nướng bẻ vụn rắc lên trên.',
  NULL, '[''Các quán ăn tại Đà Nẵng và Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'cbc8dd4f-040a-5a47-9955-1a775f4fd26a', '44444444-4444-4444-4444-444444444444', 'Cơm gà Hội An', 'main_dish', 'Cơm nấu với nước luộc gà và nghệ cho màu vàng đặc trưng, ăn cùng thịt gà xé hoặc gà luộc chặt miếng, rau răm, hành phi và nước mắm gừng.',
  NULL, '[''Khu vực phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'b04ceaa3-63bc-566e-8147-28500acbe288', '44444444-4444-4444-4444-444444444444', 'Bánh mì Phượng', 'snack', 'Bánh mì kẹp thịt phong cách Hội An nổi tiếng toàn thế giới sau khi được đầu bếp Anthony Bourdain ca ngợi trong show truyền hình, nhân đầy đặn với pate, thịt nguội, rau và sốt đặc trưng.',
  NULL, '[''Quán Bánh mì Phượng, khu phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '23bbca79-1964-53ae-ac72-bf56016e10bd', '44444444-4444-4444-4444-444444444444', 'Bánh bao bánh vạc (White Rose)', 'snack', 'Hai loại bánh hấp làm từ bột gạo mỏng trong suốt, nhân tôm hoặc thịt băm, tạo hình như bông hồng trắng nhỏ, chỉ làm được ngon đúng vị bởi vài gia đình gốc Hội An.',
  NULL, '[''Một số tiệm gia truyền trong khu phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '46e44e42-7b07-598c-a380-6cd72c5b3f0b', '44444444-4444-4444-4444-444444444444', 'Bê thui Cầu Mống', 'specialty', 'Thịt bê thui nguyên con da vàng giòn, thái mỏng cuộn với rau sống, chuối chát, khế và bánh tráng, chấm mắm nêm — món đặc sản gắn liền với vùng Cầu Mống, Quảng Nam (cũ).',
  NULL, '[''Khu vực ngoại ô Đà Nẵng/Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '74a089b6-5180-5ea9-b945-a3ddfa7e2afc', '44444444-4444-4444-4444-444444444444', 'Mít trộn', 'snack', 'Món gỏi làm từ mít non luộc trộn cùng tôm, da heo, đậu phộng rang và rau thơm, rưới nước mắm chua ngọt, thường ăn kèm bánh tráng nướng — món vặt đặc trưng đường phố Đà Nẵng.',
  NULL, '[''Các quán ăn vặt tại Đà Nẵng (xem restaurants.json)'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-7d8e-b647-0b12d38a2b2f', '44444444-4444-4444-4444-444444444444', 'Bánh mì Phượng', '', '02B Phan Châu Trinh, khu phố cổ Hội An',
  ARRAY['street_food'], '', 'Thường 6:30–21:30 — xác nhận trước khi đến',
  ARRAY['Bánh mì Phượng'], 'Đi giờ thấp điểm (giữa trưa) để giảm thời gian chờ; quán chỉ bán mang đi nhanh, không có nhiều chỗ ngồi.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-7073-aff1-0d8a889c7913', '44444444-4444-4444-4444-444444444444', 'Morning Glory Restaurant', '', '106 Nguyễn Thái Học, khu phố cổ Hội An',
  ARRAY['restaurant'], '', 'Thường 10:00–22:00 — xác nhận trước khi đến',
  ARRAY['Cao lầu', 'Mì Quảng', 'các món Hội An truyền thống'], 'Nên đặt bàn trước vào buổi tối cao điểm; có thể đăng ký tham gia lớp học nấu ăn ngắn ngay tại nhà hàng.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-781b-aad7-6606a007adfc', '44444444-4444-4444-4444-444444444444', 'Khu ẩm thực Chợ Hội An', '', 'Chợ Hội An, đường Trần Quý Cáp',
  ARRAY['market_stall'], '', 'Thường 6:00–19:00 — xác nhận trước khi đến',
  ARRAY['Cao lầu', 'Cơm gà', 'bánh xèo', 'chè'], 'Quan sát quán nào đông người dân địa phương ăn để chọn quán ngon; mang tiền mặt vì hầu hết không nhận chuyển khoản.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-709e-bb5d-7436a60d0a2c', '44444444-4444-4444-4444-444444444444', 'Quán hải sản đường Võ Nguyên Giáp', '', 'Đường Võ Nguyên Giáp, ven biển Mỹ Khê, Đà Nẵng',
  ARRAY['restaurant'], '', 'Thường 10:00–23:00 — xác nhận trước khi đến',
  ARRAY['hải sản tươi', 'mì Quảng', 'ốc'], 'Hỏi giá hải sản trước khi chọn theo kg, đặc biệt với cua/tôm hùm để tránh phát sinh chi phí.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '825e2c0c-ec1e-538a-8ff8-94b9a4998be3', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Cao lầu', 'main_dish', 'Món mì đặc trưng chỉ có tại Hội An, sợi mì dày và giòn hơn các loại mì khác vì được nhúng nước từ giếng Bá Lễ và tro củi tràm, ăn kèm thịt heo xá xíu, tóp mỡ và rau sống.',
  NULL, '[''Quán trong hẻm khu phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'e9399b6f-049a-5fc8-ae03-5bf36ee8bb3c', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Mì Quảng', 'main_dish', 'Sợi mì gạo vàng nghệ ăn với rất ít nước dùng (khác phở/bún), kèm tôm, thịt heo, trứng cút, đậu phộng rang và bánh tráng nướng bẻ vụn rắc lên trên.',
  NULL, '[''Các quán ăn tại Đà Nẵng và Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'a69786f0-ca5f-57ea-92ea-dfba68bbca37', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Cơm gà Hội An', 'main_dish', 'Cơm nấu với nước luộc gà và nghệ cho màu vàng đặc trưng, ăn cùng thịt gà xé hoặc gà luộc chặt miếng, rau răm, hành phi và nước mắm gừng.',
  NULL, '[''Khu vực phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '25a5bf9c-4caa-5ed6-9bf3-e97f0a6d6040', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Bánh mì Phượng', 'snack', 'Bánh mì kẹp thịt phong cách Hội An nổi tiếng toàn thế giới sau khi được đầu bếp Anthony Bourdain ca ngợi trong show truyền hình, nhân đầy đặn với pate, thịt nguội, rau và sốt đặc trưng.',
  NULL, '[''Quán Bánh mì Phượng, khu phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '01555ffd-94e6-5783-ba5b-c8651fd6fa84', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Bánh bao bánh vạc (White Rose)', 'snack', 'Hai loại bánh hấp làm từ bột gạo mỏng trong suốt, nhân tôm hoặc thịt băm, tạo hình như bông hồng trắng nhỏ, chỉ làm được ngon đúng vị bởi vài gia đình gốc Hội An.',
  NULL, '[''Một số tiệm gia truyền trong khu phố cổ Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'cc0521fb-f71e-5048-9691-2db319ebf179', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Bê thui Cầu Mống', 'specialty', 'Thịt bê thui nguyên con da vàng giòn, thái mỏng cuộn với rau sống, chuối chát, khế và bánh tráng, chấm mắm nêm — món đặc sản gắn liền với vùng Cầu Mống, Quảng Nam (cũ).',
  NULL, '[''Khu vực ngoại ô Đà Nẵng/Hội An (xem restaurants.json)'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '666d4d26-95d3-5dd5-9b46-7ef9cb85e7ef', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Mít trộn', 'snack', 'Món gỏi làm từ mít non luộc trộn cùng tôm, da heo, đậu phộng rang và rau thơm, rưới nước mắm chua ngọt, thường ăn kèm bánh tráng nướng — món vặt đặc trưng đường phố Đà Nẵng.',
  NULL, '[''Các quán ăn vặt tại Đà Nẵng (xem restaurants.json)'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-7d8e-b647-0b12d38a2b2f', '44444444-4444-4444-4444-444444444444', 'Bánh mì Phượng', '', '02B Phan Châu Trinh, khu phố cổ Hội An',
  ARRAY['street_food'], '', 'Thường 6:30–21:30 — xác nhận trước khi đến',
  ARRAY['Bánh mì Phượng'], 'Đi giờ thấp điểm (giữa trưa) để giảm thời gian chờ; quán chỉ bán mang đi nhanh, không có nhiều chỗ ngồi.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-7073-aff1-0d8a889c7913', '44444444-4444-4444-4444-444444444444', 'Morning Glory Restaurant', '', '106 Nguyễn Thái Học, khu phố cổ Hội An',
  ARRAY['restaurant'], '', 'Thường 10:00–22:00 — xác nhận trước khi đến',
  ARRAY['Cao lầu', 'Mì Quảng', 'các món Hội An truyền thống'], 'Nên đặt bàn trước vào buổi tối cao điểm; có thể đăng ký tham gia lớp học nấu ăn ngắn ngay tại nhà hàng.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-781b-aad7-6606a007adfc', '44444444-4444-4444-4444-444444444444', 'Khu ẩm thực Chợ Hội An', '', 'Chợ Hội An, đường Trần Quý Cáp',
  ARRAY['market_stall'], '', 'Thường 6:00–19:00 — xác nhận trước khi đến',
  ARRAY['Cao lầu', 'Cơm gà', 'bánh xèo', 'chè'], 'Quan sát quán nào đông người dân địa phương ăn để chọn quán ngon; mang tiền mặt vì hầu hết không nhận chuyển khoản.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eeecc-64d3-709e-bb5d-7436a60d0a2c', '44444444-4444-4444-4444-444444444444', 'Quán hải sản đường Võ Nguyên Giáp', '', 'Đường Võ Nguyên Giáp, ven biển Mỹ Khê, Đà Nẵng',
  ARRAY['restaurant'], '', 'Thường 10:00–23:00 — xác nhận trước khi đến',
  ARRAY['hải sản tươi', 'mì Quảng', 'ốc'], 'Hỏi giá hải sản trước khi chọn theo kg, đặc biệt với cua/tôm hùm để tránh phát sinh chi phí.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '77741728-9811-5f7b-a273-0da74bd51070', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Xôi Nếp Nương', 'main_dish', 'Xôi nấu từ giống nếp nương đặc sản vùng cao Điện Biên — hạt dài, trắng trong, thơm dịu tự nhiên. Được đồ trong chõ gỗ truyền thống của người Thái, xôi dẻo mà không dính tay, vị ngọt thanh. Thường ăn cùng muối vừng, thịt gà bản hoặc cá suối nướng. Là món ăn sáng và bữa chính quan trọng trong bếp người Thái Tây Bắc.',
  '// TODO: xác nhận tại Foody.vn hoặc Google Maps', '[''Chợ Điện Biên Phủ'', ''Nhà hàng ẩm thực Thái trong thành phố'', ''Homestay nhà sàn'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '70abc176-8726-564a-a080-ace67e3c972d', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Gà Bản Nướng', 'main_dish', 'Gà ta nuôi thả vườn của đồng bào dân tộc Thái, thịt chắc săn và đậm vị hơn gà công nghiệp. Ướp gia vị bản địa gồm mắc khén (hạt tiêu rừng Tây Bắc), gừng, sả, tỏi, ớt rừng rồi nướng trên than củi. Mùi thơm mắc khén rất đặc trưng — không thể lẫn với bất kỳ món nướng nào khác. Thường ăn kèm xôi nếp nương.',
  '// TODO: xác nhận tại Foody.vn', '[''Nhà hàng ẩm thực Thái TP. Điện Biên Phủ'', ''Homestay bản Thái'', ''Chợ đêm'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'b8d3f566-ab84-5494-9690-aa0266e6f0d6', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Cá Suối Nướng Mắc Khén', 'main_dish', 'Cá bắt từ các suối núi sạch quanh Điện Biên — thường là cá chép suối, cá trầm hoặc cá niếc. Nhồi nhân sả, gừng, mắc khén vào bụng cá rồi kẹp tre nướng trên bếp than. Thịt cá ngọt, thơm mùi gia vị rừng, da giòn nhẹ. Đặc trưng của bếp ăn người Thái và là món không thể thiếu trong các bữa nhậu vùng cao.',
  '// TODO: xác nhận tại Foody.vn hoặc Google Maps', '[''Nhà hàng ẩm thực Thái'', ''Bản văn hóa Thái'', ''Quán ăn ven suối'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '4d6c3ddc-e5b7-559d-a0f7-10c3afc7bb10', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Rượu Cần Điện Biên', 'drink', 'Rượu ủ từ gạo nếp nương và các loại lá cây rừng trong chum đất, uống chung qua cần trúc dài. Nồng độ cồn thấp, vị ngọt thanh, đậm hương thảo mộc rừng núi. Uống rượu cần là nghi thức quan trọng trong văn hóa tiếp đón khách của người Thái, Mường tại Tây Bắc. Không thể từ chối nếu muốn được chủ nhà quý mến!',
  '// TODO: xác nhận tại cơ sở địa phương', '[''Homestay nhà sàn'', ''Bản văn hóa Thái'', ''Lễ hội địa phương'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'd725effb-e643-55bb-bf15-b507fb1482a7', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Pa Pỉnh Tộp (Cá Gập Nướng)', 'main_dish', 'Đặc sản cá nướng độc đáo của người Thái — cá được mổ dọc sống lưng, gập đôi, kẹp nhân gồm sả, gừng, mắc khén, lá chanh và ớt rồi nướng trên lửa than. Cách gấp đặc biệt giúp gia vị ngấm sâu vào từng thớ thịt. Là món nhậu cao cấp và thường xuất hiện trong mâm cỗ đãi khách quý.',
  '// TODO: xác nhận tại Foody.vn', '[''Nhà hàng ẩm thực Thái TP. Điện Biên Phủ'', ''Homestay bản Thái'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '6c2617f5-a8bb-588b-b3b7-41e93de24c22', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Nậm Pịa', 'soup', 'Canh đặc sản người Thái làm từ lòng dê hoặc lòng bò nấu với mắc khén, sả, gừng và đặc biệt là dịch tiêu hóa (pịa) — nghe lạ nhưng tạo ra vị đắng nhẹ độc đáo rất cuốn. Dành cho người dạn thử đặc sản ''thách thức'' của Tây Bắc. Không phải ai cũng hợp khẩu vị, nhưng là trải nghiệm ẩm thực không thể quên.',
  '// TODO: xác nhận tại Foody.vn', '[''Nhà hàng ẩm thực Thái'', ''Chợ địa phương'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'f944702b-0414-4c40-92fb-523574be0abb', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Nhà Hàng Mường Thanh', '', 'Khu trung tâm TP. Điện Biên Phủ — xác nhận địa chỉ tại Google Maps',
  ARRAY['restaurant'], '// TODO: xác nhận tại Foody.vn hoặc Google Maps', '10:00–21:30 hằng ngày — xác nhận trước khi đến',
  ARRAY['xôi nếp nương', 'gà bản nướng mắc khén', 'cá suối nướng', 'pa pỉnh tộp', 'rượu cần'], 'Đặt bàn trước vào dịp lễ kỷ niệm 7/5 hoặc cuối tuần vì nhà hàng thường kín chỗ.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '47ca5c6f-5208-43bc-9f77-9e2a029f59e3', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Quán Xôi Sáng Chợ Điện Biên', '', 'Khu vực chợ trung tâm TP. Điện Biên Phủ — xác nhận địa chỉ tại Google Maps',
  ARRAY['street_food'], '// TODO: xác nhận tại Foody.vn', '5:30–10:30 hằng ngày — xác nhận trước khi đến',
  ARRAY['xôi nếp nương', 'xôi ngũ sắc', 'muối vừng', 'thịt gà bản'], 'Đến trước 8:00 để chọn được xôi còn nóng và đủ loại. Mua gói lá chuối mang đi ăn khi thăm di tích buổi sáng.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'c62ddea2-5c59-423c-99a6-9d93257e1e4d', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Quán Nướng Ẩm Thực Tây Bắc', '', 'Trung tâm TP. Điện Biên Phủ — xác nhận địa chỉ tại Google Maps',
  ARRAY['restaurant'], '// TODO: xác nhận tại Foody.vn', '11:00–22:00 hằng ngày — xác nhận trước khi đến',
  ARRAY['gà bản nướng mắc khén', 'cá suối nướng', 'thịt trâu gác bếp', 'nậm pịa'], 'Gọi thêm rượu cần để trải nghiệm đầy đủ văn hóa ẩm thực Tây Bắc. Nên gọi gà bản trước vì cần thời gian nướng lâu hơn.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '1bdc7f28-0ff2-4c8a-b5ca-ed6141814a4c', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Nhà Hàng Khách Sạn Mường Thanh Holiday', '', 'Him Lam, TP. Điện Biên Phủ, tỉnh Điện Biên',
  ARRAY['restaurant'], '// TODO: xác nhận tại khách sạn — giá phân khúc 4 sao', '6:30–22:00 hằng ngày — xác nhận trước khi đến',
  ARRAY['buffet sáng', 'xôi nếp nương', 'gà bản', 'lẩu Thái Tây Bắc'], 'Khách không ở khách sạn vẫn có thể ăn tại nhà hàng. Buffet sáng có nhiều món đặc sản địa phương — đáng thử ngay lần đầu đến Điện Biên.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '6dafd2aa-3aea-51bf-8aff-0ec747607433', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Gỏi cá Biên Hòa', 'main_dish', 'Đặc sản nổi tiếng nhất Biên Hòa — cá lóc hoặc cá trắm thái lát mỏng ướp gia vị chua ngọt, ăn kèm với bánh tráng, rau sống, bún và nước mắm pha đặc trưng. Khác với gỏi cá miền Trung (ăn sống), gỏi cá Biên Hòa dùng cá đã ướp giấm chanh ''chín'' nhẹ.',
  NULL, '[''Các quán đặc sản dọc đường Nguyễn Ái Quốc, Biên Hòa'', ''Nhà hàng ven sông Đồng Nai'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '70e849a4-c555-5d58-8e2b-991a75675cb8', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Bưởi Tân Triều', 'fruit', 'Giống bưởi đặc sản nổi tiếng nhất Đồng Nai, có hai loại: bưởi da xanh (vỏ xanh, múi hồng ngọt) và bưởi đường lá cam (vỏ vàng, múi trắng ngọt dịu). Bưởi Tân Triều được trồng tại xã Tân Bình, Vĩnh Cửu — mùa chính tháng 11 đến tháng 2, ngon nhất dịp Tết.',
  NULL, '[''Vườn bưởi Tân Triều (hái trực tiếp)'', ''Chợ Biên Hòa'', ''Các cửa hàng đặc sản'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '5f219766-0e95-5b6d-a955-e62b9f63d4a1', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Dế chiên giòn', 'snack', 'Món ăn đặc trưng của vùng Đông Nam Bộ, dế được nuôi hoặc bắt tự nhiên, làm sạch rồi chiên giòn với tỏi ớt. Có thể ăn kèm với muối chanh hoặc tương ớt. Mặc dù lạ miệng nhưng là trải nghiệm ẩm thực không thể bỏ qua khi đến Đồng Nai và các tỉnh Đông Nam Bộ.',
  NULL, '[''Các quán ăn địa phương khu Biên Hòa'', ''Chợ đêm Biên Hòa'', ''Khu ẩm thực gần bến xe'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'e74937d1-4cc5-540a-82ad-abe27922d4df', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Bánh canh Trảng Bom', 'main_dish', 'Bánh canh bột gạo sợi to, nước dùng từ xương heo ninh lâu trong vắt và ngọt tự nhiên, ăn kèm chả cua hoặc tôm. Huyện Trảng Bom nổi tiếng với phiên bản bánh canh đặc trưng địa phương, nhiều quán lâu đời giữ công thức truyền thống qua nhiều thế hệ.',
  NULL, '[''Các quán bánh canh sáng dọc QL1A, Trảng Bom'', ''Chợ Trảng Bom'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '1d45e941-7332-5ee5-b924-06e103048057', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Lẩu cá lăng sông Đồng Nai', 'main_dish', 'Cá lăng — loài cá nước ngọt sống tự nhiên trên sông Đồng Nai — thịt trắng dai ngọt, ít xương. Nấu lẩu chua cay với me, cà chua, thơm (dứa) và rau nhúng phong phú. Là đặc sản sông nước đặc trưng của các nhà hàng ven sông Đồng Nai và hồ Trị An.',
  NULL, '[''Nhà hàng ven sông Đồng Nai, Biên Hòa'', ''Khu ẩm thực ven hồ Trị An'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '77632dd8-bcb2-581b-903e-9d3ecdb13d4e', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Nem Bình Xuyên', 'main_dish', 'Nem chua lên men đặc sản của huyện Bình Xuyên (tên cũ), nay là khu vực Long Thành, Nhơn Trạch — được làm từ thịt heo tươi giã mịn, bọc lá vông hoặc lá chuối, lên men tự nhiên. Nem Đồng Nai có vị chua nhẹ, giòn dai đặc trưng khác nem Thanh Hóa.',
  NULL, '[''Chợ Biên Hòa'', ''Cửa hàng đặc sản Đồng Nai'', ''Các quán ăn khu vực Long Thành'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '67b62cfc-98e9-569b-9c68-df9ce6c5bb1d', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Cơm tấm Biên Hòa', 'main_dish', 'Cơm tấm phong cách Biên Hòa có thêm đặc điểm riêng so với cơm tấm Sài Gòn: sườn nướng dày hơn, bì heo giòn hơn và mỡ hành thơm đặc trưng. Nhiều quán cơm tấm nổi tiếng lâu đời ở Biên Hòa phục vụ từ sáng sớm đến tận nửa đêm.',
  NULL, '[''Các quán cơm tấm dọc đường Nguyễn Văn Trị'', ''Khu ẩm thực trung tâm Biên Hòa'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'a155d51c-baca-4bef-8763-65d36a775561', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Nhà hàng Ven Sông Đồng Nai', '', 'Khu vực ven sông Đồng Nai, TP. Biên Hòa, Đồng Nai',
  ARRAY['restaurant'], 'Trung bình – Cao', NULL,
  ARRAY['gỏi cá Biên Hòa', 'lẩu cá lăng', 'tôm sú nướng muối ớt', 'cá lóc hấp bầu'], 'Đặt bàn trước vào cuối tuần. Hỏi về cá lăng tươi đánh bắt từ sông vì không phải lúc nào cũng có.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'd4eda6f1-3930-4c5a-b475-490b554ea077', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Quán Gỏi Cá Mười Chính', '', 'Khu vực đường Nguyễn Ái Quốc, TP. Biên Hòa, Đồng Nai',
  ARRAY['street_food'], 'Bình dân', 'Thường 10:00–21:00 — xác nhận tại Foody.vn trước khi đến',
  ARRAY['gỏi cá Biên Hòa', 'bánh tráng cuốn', 'gỏi bò'], 'Gọi thêm bánh tráng nướng ăn kèm. Không gian có thể chật vào giờ trưa.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '681f9f0d-a74e-45ce-abbb-57df3f211fdb', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Nhà hàng Nam Cát Tiên (trong VQG)', '', 'Trung tâm Du lịch Sinh thái VQG Nam Cát Tiên, Huyện Tân Phú, Đồng Nai',
  ARRAY['restaurant'], 'Trung bình', 'Theo giờ khu du lịch — xác nhận khi đặt tour VQG',
  ARRAY['cơm rừng', 'gà nướng đất sét', 'rau rừng xào tỏi', 'canh bí rừng'], 'Đặt bữa ăn trước cùng lúc đặt tour lưu trú để đảm bảo chỗ. Thực đơn hạn chế — đừng kỳ vọng như nhà hàng thành phố.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'e9aee27a-d70a-435b-8433-b89426d1328d', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Chợ đêm Biên Hòa', '', 'Khu vực trung tâm TP. Biên Hòa, gần chợ Biên Hòa',
  ARRAY['market_stall'], 'Bình dân', '18:00–23:00 hằng ngày — xác nhận thực tế',
  ARRAY['dế chiên', 'nem Bình Xuyên', 'bánh tráng nướng', 'cơm tấm đêm', 'chè các loại'], 'Thử dế chiên nếu chưa bao giờ ăn — giòn, thơm, không tanh. Mang tiền mặt.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '2f7de5c3-35c2-50f2-8f13-6aaee81eebbd', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'Phở Hà Nội', 'main_dish', 'Món nước với bánh phở, nước dùng ninh xương trong nhiều giờ, ăn cùng thịt bò hoặc gà.',
  '35.000–60.000đ', '[''Phở Thìn Lò Đúc'', ''Phở Bát Đàn'', ''Phở Gia Truyền'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'ad13385f-e501-5374-9c63-90d6c8c3878c', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'Bún chả', 'main_dish', 'Chả thịt nướng than ăn cùng bún, nước mắm chua ngọt và rau sống.',
  '40.000–80.000đ', '[''Bún Chả Hương Liên'', ''Bún chả Đắc Kim'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'a961b98f-e75e-55ee-b38c-5e701cadd0df', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'Chả cá Lã Vọng', 'main_dish', 'Cá lăng/cá quả nướng trên than, ăn kèm bún, thì là, lạc rang, mắm tôm.',
  '100.000–200.000đ', '[''Chả Cá Lã Vọng'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'a7329a5e-2093-50a1-bcb4-f25b3bd5f1ce', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'Cà phê trứng', 'drink', 'Cà phê đánh cùng lòng đỏ trứng và sữa tạo lớp kem béo phía trên.',
  '25.000–40.000đ', '[''Cà phê Giảng'', ''Cà phê Đinh'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '7719a27b-b858-5ec1-ac44-23e3159936b4', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'Bánh cuốn Thanh Trì', 'snack', 'Bánh bột gạo tráng mỏng, nhân thịt mộc nhĩ, ăn cùng nước mắm và chả lụa.',
  '30.000–50.000đ', '[''Bánh cuốn Bà Hoành'', ''Khu Thanh Trì'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '1f5fd727-6031-561e-81e0-30bcbc11f82e', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'Nem chua rán', 'snack', 'Nem chua chiên giòn, ăn kèm tương ớt/mù tạt, món ăn vặt phổ biến phố cổ về đêm.',
  '20.000–40.000đ', '[''Phố Tạ Hiện'', ''Hàng đêm các quán nhậu vỉa hè'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '456b771e-a3ff-4f31-94a5-2b07aa0f5bbb', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Phở Thìn Lò Đúc', '', '13 Lò Đúc, quận Hai Bà Trưng, Hà Nội',
  ARRAY['restaurant'], '40.000–60.000đ/người', '6:00–22:00',
  ARRAY['Phở bò tái lăn'], 'Giờ ăn trưa/tối thường đông, nên đi sớm hoặc chờ.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  'f0332008-50ce-408f-8b29-8489151940e0', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Bún Chả Hương Liên', '', '24 Lê Văn Hưu, quận Hai Bà Trưng, Hà Nội',
  ARRAY['restaurant'], '50.000–80.000đ/người', '9:00–21:00',
  ARRAY['Bún chả'], 'Có bàn ''Combo Obama'' lưu lại đúng món đã dùng.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '0e3849c5-b470-4744-9b14-9942b631f980', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Chả Cá Lã Vọng', '', '14 Chả Cá, quận Hoàn Kiếm, Hà Nội',
  ARRAY['restaurant'], '100.000–200.000đ/người', '11:00–21:00',
  ARRAY['Chả cá'], 'Chỉ phục vụ duy nhất món chả cá, giá theo set ăn.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '126714a4-fb81-44a0-9b79-3b3c3e9fa5c6', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Cà phê Giảng (cà phê trứng)', '', '39 Nguyễn Hữu Huân, quận Hoàn Kiếm, Hà Nội',
  ARRAY['cafe'], '25.000–40.000đ/ly', '7:00–22:00',
  ARRAY['Cà phê trứng'], 'Quán nhỏ, giờ cao điểm hết bàn nhanh.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '3fc00e14-4952-4469-aab5-b394def94347', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Phố ăn đêm Tạ Hiện', '', 'Phố Tạ Hiện, quận Hoàn Kiếm, Hà Nội',
  ARRAY['street_food'], '20.000–100.000đ/món', '17:00–24:00 (sôi động nhất buổi tối)',
  ARRAY['Bia hơi', 'Nem chua rán', 'Chân gà nướng'], 'Cẩn thận giữ đồ cá nhân khi ngồi vỉa hè đông người.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '819fe447-b8b2-58c3-ae8b-4ca2b70cc248', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Bún cá Nha Trang', 'main_dish', 'Món bún đặc trưng của Nha Trang với nước dùng từ cá tươi nấu trong vắt, thanh ngọt. Thường ăn kèm chả cá chiên giòn, rau sống và mắm ruốc. Khác bún bò Huế ở chỗ nước dùng nhẹ hơn, hương vị biển đặc trưng.',
  'Tầm 30.000–60.000đ/tô (ước tính — xác nhận tại quán)', '[''Chợ Đầm Nha Trang'', ''Các quán bún cá khu vực trung tâm thành phố'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'e7b58943-5160-5832-ab0a-5fb9229ec452', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Nem nướng Ninh Hòa', 'specialty', 'Nem nướng làm từ thịt heo xay trộn gia vị, nướng trên than hồng, cuốn cùng bánh đa, rau sống và chấm nước mắm tỏi ớt ngọt. Ninh Hòa (huyện thuộc Khánh Hòa) là nơi khai sinh món này và được công nhận là đặc sản vùng.',
  'Tầm 50.000–100.000đ/phần (ước tính — xác nhận tại quán)', '[''Các quán nem nướng khu trung tâm Nha Trang'', ''Thị trấn Ninh Hòa nếu đi xa hơn'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'b0299406-ae32-5bc0-a32a-10c841e4630f', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Yến sào Khánh Hòa', 'specialty', 'Tổ yến (tổ chim yến) được khai thác từ các đảo đá ven biển Khánh Hòa — vùng yến sào nổi tiếng nhất Việt Nam. Chế biến thành chè yến, súp yến, nước yến đóng chai. Được coi là thực phẩm bổ dưỡng cao cấp.',
  'Cao — phụ thuộc loại yến và hình thức chế biến (xác nhận tại cửa hàng)', '[''Các cửa hàng yến sào Khánh Hòa chính thức'', ''Nhà hàng cao cấp tại Nha Trang'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '1fa52364-2393-5f44-9da2-b852ac26c07f', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Bánh căn', 'snack', 'Bánh làm từ bột gạo đổ vào khuôn đất nung nhỏ, nướng trên bếp than, thường kèm trứng cút hoặc hải sản. Ăn kèm nước chấm cá hoặc mắm nêm. Món ăn vặt quen thuộc của người dân Nha Trang, đặc biệt phổ biến buổi chiều tối.',
  'Bình dân — tầm 20.000–40.000đ/phần (ước tính)', '[''Chợ đêm Nha Trang'', ''Các xe bánh căn vỉa hè khu trung tâm'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'dcbc1645-ffbb-5bf4-9105-a5726474a760', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Hải sản tươi sống', 'main_dish', 'Nha Trang là thiên đường hải sản với tôm hùm, ghẹ, mực, cá mú, hào, sò điệp tươi sống từ các làng chài và đảo gần bờ. Chế biến đa dạng: hấp, nướng, xào tỏi, lẩu. Giá cả cạnh tranh hơn các thành phố lớn.',
  'Dao động rộng theo loại hải sản — nên hỏi giá trước khi gọi', '[''Khu hải sản đường Phạm Văn Đồng'', ''Nhà hàng dọc bờ biển'', ''Chợ Đầm'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '9216d942-af9a-5668-ad20-c2339008cf8d', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Bò né Nha Trang', 'main_dish', 'Bít tết bò áp chảo nóng hổi ăn kèm trứng ốp la, bánh mì giòn và nước sốt pate. Phong trào bò né phổ biến khắp Việt Nam nhưng Nha Trang có phiên bản riêng với nhiều quán ngon, giá bình dân.',
  'Tầm 50.000–90.000đ/phần (ước tính — xác nhận tại quán)', '[''Các quán bò né khu trung tâm thành phố'', ''Chợ đêm Nha Trang'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'a74307ad-e35a-5401-b5de-1098a7509a95', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Chè Nha Trang', 'dessert', 'Các loại chè đặc trưng miền Trung: chè thập cẩm, chè đậu xanh, chè bắp, chè yến. Đặc biệt có chè yến sào — đặc sản Khánh Hòa. Ăn kèm đá bào mát lạnh, phù hợp thời tiết nóng ở Nha Trang.',
  'Tầm 15.000–50.000đ/ly (ước tính — xác nhận tại quán)', '[''Các quán chè khu trung tâm'', ''Chợ đêm Nha Trang'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eedf6-c8b1-74c9-aabd-37585b166dc0', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Khu hải sản Phạm Văn Đồng', '', 'Đường Phạm Văn Đồng, TP. Nha Trang, Khánh Hòa',
  ARRAY['restaurant'], 'Dao động — hỏi giá từng loại hải sản trước khi gọi', 'Thường 10:00–22:00 — xác nhận từng quán trước khi đến',
  ARRAY['Tôm hùm', 'Ghẹ', 'Mực nướng', 'Cá mú hấp', 'Hào nướng mỡ hành'], 'Hỏi giá từng con trước khi đồng ý — giá hải sản tính theo cân. So sánh giá ít nhất 2–3 quán. Tránh khu vực mà nhân viên mời chào quá nhiệt tình.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eedf6-c8b1-7710-bd65-d6adb4aeb184', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Chợ Đầm Nha Trang (khu ăn uống)', '', 'Chợ Đầm, TP. Nha Trang, Khánh Hòa',
  ARRAY['market_stall'], 'Bình dân — tầm 30.000–80.000đ/món', 'Sáng sớm từ 5:00 — đông nhất 6:00–9:00 cho bữa sáng',
  ARRAY['Bún cá Nha Trang', 'Bánh căn', 'Bánh mì hải sản', 'Cháo cá'], 'Đến sớm trước 8:00 để có đồ ngon. Dùng tiếng Việt cơ bản hoặc chỉ tay — không cần lo ngại ngôn ngữ.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eedf6-c8b1-7012-b6fe-c35bc8ffb890', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Chợ đêm Nha Trang', '', 'Đường 19 tháng 10, TP. Nha Trang, Khánh Hòa',
  ARRAY['street_food'], 'Bình dân đến tầm trung — 20.000–100.000đ/món', 'Thường 17:00–23:00',
  ARRAY['Bánh căn', 'Nem nướng', 'Hải sản nướng', 'Chè các loại', 'Trái cây nhiệt đới'], 'Mặc cả trước khi mua hàng lưu niệm. Thử nhiều món nhỏ thay vì ăn no ở một quán.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'af8f0494-e263-5163-b359-e83bc703451a', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Hủ Tiếu Nam Vang', 'main_dish', 'Hủ tiếu Nam Vang là món ăn đặc trưng của người Hoa-Khmer gốc Nam Vang (Phnom Penh) định cư tại Sài Gòn. Nước dùng trong ngọt từ xương heo hầm lâu, sợi hủ tiếu dai mềm, ăn kèm thịt heo, tôm, lòng heo và rau thơm. Có thể ăn nước hoặc ăn khô (trụng sợi, chan nước dùng riêng).',
  'Khoảng 40.000–80.000đ/tô — xác nhận tại Foody.vn', '[''Chợ Bến Thành'', ''khu Quận 5 (Cholon)'', ''các quán hủ tiếu xe vỉa hè toàn thành phố'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'c511f584-74cd-57b0-be6e-df33fb142ebe', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Bánh Mì Sài Gòn', 'snack', 'Bánh mì Sài Gòn là biểu tượng ẩm thực đường phố của thành phố, được CNN và nhiều tạp chí quốc tế vinh danh. Ổ bánh mì giòn vỏ mềm ruột, nhân đa dạng: thịt nguội, pate, chả, trứng, dưa leo, hành ngò và tương ớt. Sài Gòn có nhiều biến thể khác nhau tùy tiệm.',
  'Khoảng 20.000–50.000đ/ổ — xác nhận tại Foody.vn', '[''Bánh Mì Huỳnh Hoa (Lê Thị Riêng, Quận 1)'', ''các xe bánh mì vỉa hè toàn thành phố'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  'c3c2702b-e63e-5fbc-a0ef-20a3f1ff55ee', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Cơm Tấm', 'main_dish', 'Cơm tấm (cơm gạo tấm) là món ăn quốc dân của người Sài Gòn, ăn từ sáng đến tối. Cơm tấm thật sự dùng gạo nát/gạo bể, có hương vị đặc biệt. Thường ăn kèm sườn nướng, bì, chả trứng hấp, mỡ hành và nước mắm pha chua ngọt đặc trưng.',
  'Khoảng 40.000–100.000đ/phần — xác nhận tại Foody.vn', '[''Cơm Tấm Thuận Kiều (Quận 11)'', ''các quán cơm tấm vỉa hè toàn thành phố'', ''khu Quận 3, Quận 1'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '90bf77cd-7481-5af5-b00e-23958cf573a6', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Bún Bò Huế kiểu Sài Gòn', 'main_dish', 'Bún bò Huế du nhập vào Sài Gòn được biến tấu theo khẩu vị địa phương — ít cay hơn, nước dùng ngọt hơn. Sợi bún tròn to, nước dùng đỏ sóng sánh từ sả, mắm ruốc và ớt, ăn kèm bò, chả heo, giò heo và rau sống.',
  'Khoảng 50.000–100.000đ/tô — xác nhận tại Foody.vn', '[''khu Quận 3'', ''khu Bình Thạnh'', ''các quán bún bò vỉa hè'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '79a1d544-e9cd-54e2-a452-e807c53d9ce4', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Chè Sài Gòn', 'dessert', 'Chè Sài Gòn (hay chè Nam Bộ) nổi tiếng với hương vị ngọt béo đặc trưng từ nước cốt dừa. Có hàng chục loại: chè đậu đỏ, chè bưởi, chè thập cẩm, chè chuối, sâm bổ lượng... Các xe chè vỉa hè và tiệm chè rải rác khắp thành phố phục vụ cả ngày lẫn đêm.',
  'Khoảng 20.000–50.000đ/ly — xác nhận tại Foody.vn', '[''phố chè Võ Văn Tần (Quận 3)'', ''khu Cholon Quận 5'', ''các xe chè vỉa hè'']', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO foods (id, destination_id, name, category, description, price_range, best_at, is_vegetarian, is_active) VALUES (
  '11fa9ab6-c968-5ace-92e4-808f230d2f2a', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Gỏi Cuốn', 'snack', 'Gỏi cuốn (chả giò tươi) là món khai vị nhẹ nhàng của ẩm thực Nam Bộ, được du khách quốc tế yêu thích. Bánh tráng ướt cuốn với tôm, thịt luộc, bún, rau sống và chấm với nước mắm hoặc tương hoisin pha đậu phộng giã. Thanh mát, lành mạnh và đẹp mắt.',
  'Khoảng 30.000–70.000đ/đĩa (4–6 cuốn) — xác nhận tại Foody.vn', '[''Nhà Hàng Ngon (Pasteur, Quận 1)'', ''các nhà hàng ẩm thực Nam Bộ'', ''chợ ẩm thực đêm'']', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee06-3f91-7537-8e66-4f523e0063c5', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Nhà Hàng Ngon', '', '160 Pasteur, Phường Bến Nghé, Quận 1, TP. HCM',
  ARRAY['restaurant'], 'Khoảng 100.000–250.000đ/người — xác nhận tại Foody.vn', '7:00–22:00 hàng ngày — xác nhận tại Google Maps trước khi đến',
  ARRAY['gỏi cuốn', 'bánh xèo', 'cơm tấm', 'bún bò', 'chè'], 'Đặt bàn trước vào buổi trưa và tối cuối tuần. Giá cao hơn quán bình dân nhưng không gian và vệ sinh tốt hơn — phù hợp gia đình và nhóm đông.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee06-3f91-79eb-8447-c8266f11f104', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Quán 94 Cơm Tấm Kiều Giang', '', 'Khu Quận 3-4, TP. HCM (chuỗi nhiều chi nhánh)',
  ARRAY['street_food'], 'Khoảng 50.000–100.000đ/suất — xác nhận tại Foody.vn', '6:00–22:00 — xác nhận chi nhánh gần nhất tại Google Maps',
  ARRAY['cơm tấm sườn nướng', 'cơm tấm bì chả', 'trứng ốp la'], 'Đây là địa chỉ quen thuộc của người Sài Gòn — không gian bình dân nhưng chất lượng ổn định. Gọi thêm chả trứng hấp nếu muốn no bụng.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee06-3f91-7af3-890b-aa8cca2afd2c', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Phở Hòa Pasteur', '', '260C Pasteur, Phường 8, Quận 3, TP. HCM',
  ARRAY['restaurant'], 'Khoảng 80.000–150.000đ/tô — xác nhận tại Foody.vn', '6:00–11:00 và 18:00–24:00 — xác nhận tại Google Maps',
  ARRAY['phở bò tái', 'phở bò chín', 'phở bò đặc biệt'], 'Bắt buộc thêm tương đen và tương đỏ để hòa vào tô phở theo phong cách Nam. Giờ sáng rất đông — đến trước 7:30 nếu không muốn chờ.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();
INSERT INTO restaurants (id, destination_id, name, area, address, cuisine, price_range, opening_hours, specialties, tips, image_url, is_active) VALUES (
  '019eee06-3f91-7404-be6a-065bd7f1aabe', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Cục Gạch Quán', '', '10 Đặng Tất, Phường Tân Định, Quận 1, TP. HCM',
  ARRAY['restaurant'], 'Khoảng 150.000–350.000đ/người — xác nhận tại Foody.vn', '11:00–14:00 và 17:30–22:00 — xác nhận tại Google Maps',
  ARRAY['cá kho tộ', 'canh chua', 'thịt kho hột vịt', 'rau muống xào tỏi'], 'Đặt bàn trước là bắt buộc, đặc biệt cuối tuần và dịp lễ. Quán không nhận khách drop-in vào giờ cao điểm. Phong cách phục vụ chậm rãi — đây là trải nghiệm, không phải nhược điểm.', NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=NOW();