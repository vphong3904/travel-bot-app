-- PDTrip – Seed: Events + Shopping

INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee71-616e-7bdc-842f-2ce1429fc351', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Lễ hội Nghinh Ông (Cúng Cá Voi)', 'Tháng 4 (ngày 16–18 âm lịch hằng năm)',
  'Dinh Cậu và các làng chài ven biển Phú Quốc', 'Lễ hội truyền thống của ngư dân Phú Quốc, cúng tế cá Ông (cá voi) để cầu bình an và mùa đánh bắt bội thu. Có thuyền hoa diễu hành trên biển, múa lân và biểu diễn dân gian.',
  'free', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee71-616e-772a-8041-e05fdef01f27', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Tết Nguyên Đán trên đảo Phú Quốc', 'Tháng 1 hoặc 2 (theo lịch âm)',
  'Toàn đảo, tập trung tại khu Dương Đông', 'Dịp Tết tại Phú Quốc có không khí độc đáo: chợ hoa, pháo hoa đêm giao thừa trên biển, các đình chùa đông người cầu nguyện đầu năm. Cũng là mùa cao điểm du lịch nên cần đặt phòng sớm.',
  'free', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee71-616e-70c3-9096-4e1ec5f5eb24', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Lễ hội Khai Thác Mùa Cá (Ngày mở biển)', 'Tháng 10 âm lịch hằng năm (cuối mùa gió Nam)',
  'Các làng chài: Hàm Ninh, Gành Dầu, Cửa Cạn', 'Lễ mở đầu mùa đánh bắt sau mùa mưa giông, ngư dân cúng biển, thả thuyền ra khơi lần đầu trong mùa mới. Khách du lịch có thể quan sát nghi lễ truyền thống độc đáo của ngư dân đảo.',
  'free', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee71-616e-787f-ac3f-9df6920093b1', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Phú Quốc International Music Festival', 'Cuối năm (tháng 12) — thường vào dịp Giáng sinh/Năm mới',
  'Khu Sun World Hòn Thơm hoặc các khu resort lớn', 'Lễ hội âm nhạc quốc tế thu hút DJ và nghệ sĩ quốc tế, được tổ chức không thường xuyên theo kế hoạch năm. Kết hợp âm nhạc, vui chơi trên biển và pháo hoa.',
  NULL, FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee71-616e-7c51-a3d1-00f1857f77ec', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Chợ Đêm Dinh Cậu', 'night_market',
  'Đường Bạch Đằng, TP. Phú Quốc, tỉnh An Giang', '17:00–23:00 hằng ngày',
  'Thấp – trung bình, nên trả giá đồ lưu niệm', 'Mua nước mắm nhĩ và rượu sim tại đây thường rẻ hơn cửa hàng trong khách sạn. Hải sản giá niêm yết thường cao hơn thực tế, nên hỏi giá trước.',
  ARRAY['Hải sản nướng', 'Đồ lưu niệm', 'Nước mắm Phú Quốc', 'Rượu sim', 'Hạt điều'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee71-616e-7473-9d1a-48c1e47036f6', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Cơ sở nước mắm Khải Hoàn', 'specialty_store',
  'Khu Dương Đông, TP. Phú Quốc, tỉnh An Giang', '7:00–17:30 hằng ngày',
  '50.000–300.000đ/chai tùy dung tích', 'Là một trong những thương hiệu nước mắm Phú Quốc lâu đời nhất. Có thể tham quan nhà thùng, xem quy trình ủ cá. Mua trực tiếp tại cơ sở rẻ hơn nhiều so với siêu thị.',
  ARRAY['Nước mắm nhĩ nguyên chất', 'Nước mắm đóng chai quà tặng', 'Mắm ruốc'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee71-616e-772e-9021-259467b188cf', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Vincom Plaza Phú Quốc', 'mall',
  'Đường Trần Hưng Đạo, TP. Phú Quốc, tỉnh An Giang', '9:30–22:00 hằng ngày',
  'Giá niêm yết cố định theo nhãn hàng', 'Phù hợp mua sắm trong ngày mưa hoặc cần hàng hiệu. Có siêu thị mua đồ ăn vặt, nước uống tiện lợi.',
  ARRAY['Thời trang', 'Mỹ phẩm', 'Đồ điện tử', 'Ẩm thực', 'Siêu thị Vinmart'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee71-616e-7ed4-a5e0-9e690e9956e2', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Chợ Dương Đông (Chợ trung tâm)', 'market',
  'Khu Dương Đông, TP. Phú Quốc, tỉnh An Giang', '5:00–12:00 (chợ sáng sầm uất nhất)',
  'Giá người địa phương, nên trả giá', 'Đến sáng sớm 6:00–8:00 để mua hải sản tươi nhất với giá thấp nhất. Nơi người bản địa mua đồ hằng ngày, tránh mua đồ có giá quá khác nhau giữa các sạp.',
  ARRAY['Hải sản tươi sống', 'Rau củ quả', 'Đặc sản địa phương', 'Gia vị', 'Đồ khô'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee71-616e-732c-a657-af865094ae40', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Trang trại rượu sim Ngọc Hiền', 'specialty_store',
  'Khu vực Dương Đông – Cửa Cạn, TP. Phú Quốc, tỉnh An Giang', '8:00–17:00 hằng ngày',
  '80.000–250.000đ/chai (ƯỚC TÍNH)', 'Có thể thử rượu miễn phí trước khi mua. Mua trực tiếp tại trang trại thường rẻ hơn 20–30% so với chợ đêm.',
  ARRAY['Rượu sim Phú Quốc', 'Mứt sim', 'Sản phẩm từ quả sim'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee91-daab-728e-c5cd-d471b4834000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Hội Lim – Lễ hội Quan họ Bắc Ninh', 'Ngày 12–13 tháng Giêng âm lịch (thường vào tháng 2 dương lịch)',
  'Đồi Lim, thị trấn Lim, huyện Tiên Du, Bắc Ninh', 'Lễ hội quan họ lớn và nổi tiếng nhất tỉnh Bắc Ninh, thu hút hàng chục nghìn du khách mỗi năm. Tổ chức hát quan họ trên thuyền tại hồ Lim, trên đồi và trong các đình làng xung quanh. Quan họ Bắc Ninh được UNESCO công nhận là Di sản văn hóa phi vật thể đại diện của nhân loại năm 2009. Ngoài hát quan họ còn có các trò chơi dân gian truyền thống.',
  'Miễn phí vào cửa (một số hoạt động biểu diễn đặc biệt có thể mất phí — xác nhận tại chỗ)', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee91-daac-739c-8fa4-294624e60000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Lễ hội Đền Đô (Đền Lý Bát Đế)', 'Ngày 14–16 tháng 3 âm lịch (thường vào tháng 4–5 dương lịch)',
  'Đền Đô, làng Đình Bảng, phường Đình Bảng, thị xã Từ Sơn, Bắc Ninh', 'Lễ hội tưởng nhớ 8 vị vua triều Lý — triều đại đặt kinh đô Thăng Long và xây dựng Văn Miếu. Lễ hội có rước kiệu trang trọng, tế lễ, hát quan họ và các trò diễn dân gian. Đây là một trong những lễ hội lịch sử quan trọng nhất của người Kinh Bắc.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee91-daad-7344-75d7-83a492f6d000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Lễ hội Chùa Dâu', 'Ngày mùng 8 tháng 4 âm lịch (thường vào tháng 5 dương lịch)',
  'Chùa Dâu (Pháp Vân), xã Thanh Khương, huyện Thuận Thành, Bắc Ninh', 'Lễ hội thờ Tứ Pháp — bốn vị nữ thần bảo hộ nông nghiệp (Pháp Vân, Pháp Vũ, Pháp Lôi, Pháp Điện) tại ngôi chùa cổ nhất Việt Nam. Lễ hội gồm rước kiệu, tế lễ và các nghi lễ cầu mưa thuận gió hòa đặc trưng của nông nghiệp truyền thống. Di sản văn hóa phi vật thể Quốc gia.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee91-daad-7344-75d7-83a492f7e000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Lễ hội Tây Yên Tử (khu vực Bắc Giang cũ)', 'Mùng 10 tháng Giêng đến hết tháng 3 âm lịch',
  'Khu di tích Tây Yên Tử, huyện Sơn Động, tỉnh Bắc Ninh (khu vực Bắc Giang cũ sau sáp nhập)', 'Lễ hội hành hương về khu di tích Tây Yên Tử — sườn Tây của núi Yên Tử, nơi Phật hoàng Trần Nhân Tông đặt chân tu hành trên đường lên đỉnh. Dành cho người yêu leo núi tâm linh, kết hợp cảnh quan thiên nhiên rừng núi và các đền chùa cổ dọc đường lên đỉnh.',
  'Phí vào khu di tích — xác nhận tại Klook hoặc trang chính thức khu di tích', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee91-daae-7367-4fd7-6486e0219000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Làng tranh Đông Hồ – Xưởng nghệ nhân Nguyễn Đăng Chế', 'souvenir_shop',
  'Xã Song Hồ, huyện Thuận Thành, tỉnh Bắc Ninh (liên hệ trước để hẹn giờ)', '7:00–17:00 (xác nhận trước khi đến — gia đình nghệ nhân tự quản lý giờ)',
  'Tranh 50.000–500.000đ/tờ tùy loại và kích cỡ (tham khảo — xác nhận tại chỗ)', 'Mua tranh trực tiếp từ gia đình nghệ nhân đảm bảo authentic và ủng hộ người giữ nghề. Có thể hỏi xem quy trình in tranh thủ công miễn phí. Tranh cuộn dễ mang về hơn tranh đóng khung.',
  ARRAY['tranh dân gian Đông Hồ', 'tranh khắc gỗ', 'bộ in tranh DIY', 'tượng gỗ trang trí'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee91-daaf-70ab-8428-74ef698b0000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Làng gốm Phù Lãng – Lò gốm truyền thống', 'souvenir_shop',
  'Xã Phù Lãng, huyện Quế Võ, tỉnh Bắc Ninh', 'Sáng sớm đến chiều (làng nghề, giờ giấc linh hoạt — nên đến 8:00–11:00)',
  '30.000–500.000đ tùy sản phẩm (tham khảo — xác nhận tại lò gốm)', 'Mua gốm tại lò rẻ hơn đáng kể so với mua tại Hà Nội. Đồ gốm khá nặng — chuẩn bị túi xách thêm hoặc nhờ gói/gửi. Màu da lươn và đỏ gạch là đặc trưng của gốm Phù Lãng.',
  ARRAY['bình gốm Phù Lãng', 'bát đĩa gốm', 'chậu gốm trang trí', 'tượng gốm', 'ấm trà gốm da lươn'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee91-dab0-712b-a2b6-2e418a75f000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Làng Đình Bảng – Bánh phu thê & đặc sản', 'market',
  'Làng Đình Bảng, phường Đình Bảng, thị xã Từ Sơn, tỉnh Bắc Ninh', '7:00–18:00 (các hộ gia đình bán tại nhà — giờ linh hoạt)',
  'Bánh phu thê 5.000–8.000đ/cái (tham khảo — xác nhận tại chỗ)', 'Mua bánh phu thê tại làng Đình Bảng mới là bánh gốc nhất, ngon hơn mua ở Hà Nội hay các nơi khác. Nên mua buổi sáng khi bánh còn mới. Bảo quản trong ngăn mát tủ lạnh, dùng trong 2–3 ngày.',
  ARRAY['bánh phu thê Đình Bảng', 'bánh tro', 'xôi đặc sản', 'nem Bùi đóng hộp'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee91-dab2-71e1-2848-1d94faf59000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Chợ Trung tâm thành phố Bắc Ninh', 'market',
  'Khu vực trung tâm thành phố Bắc Ninh (xác nhận tên và địa chỉ chợ cụ thể tại Google Maps)', '5:00–18:00 hàng ngày (xác nhận trước khi đến)',
  NULL, 'Chợ là nơi tốt nhất để mua đặc sản với giá địa phương. Mặc cả lịch sự nếu mua nhiều. Đến sáng sớm để hàng tươi và đông vui nhất.',
  ARRAY['đặc sản địa phương', 'nem Bùi', 'rượu làng Vân', 'bánh kẹo', 'hàng nông sản', 'hàng lưu niệm'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '1254a0d8-af7a-4190-976e-56a1d35ffeae', '23431b56-3e63-4368-949f-8df24ab3c539', 'Lễ hội Nghinh Ông (Đua thuyền trên biển)', 'Rằm tháng 2 âm lịch hằng năm',
  'Thị trấn Sông Đốc, huyện Trần Văn Thời, Cà Mau', 'Lễ hội truyền thống lớn nhất của ngư dân Cà Mau, cầu nguyện cho mùa đánh cá bình an và bội thu. Có nghi lễ rước sắc thần Nghinh Ông trên biển, đua thuyền truyền thống, biểu diễn văn nghệ và hội chợ. Hàng chục nghìn ngư dân và du khách tập hợp tại cảng Sông Đốc.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '86dcae4d-db57-4c5e-9045-4784e94c22ed', '23431b56-3e63-4368-949f-8df24ab3c539', 'Lễ hội Ba khía Rạch Gốc', 'Tháng 10 âm lịch hằng năm',
  'Huyện Ngọc Hiển, Cà Mau', 'Lễ hội thường niên đặc trưng của vùng Ngọc Hiển, gắn với mùa thu hoạch ba khía — đặc sản muối mặn nổi tiếng. Có thi muối ba khía, trình diễn nghề truyền thống và chợ bán đặc sản địa phương. Đây là cơ hội hiếm để thấy toàn bộ quy trình làm ba khía từ đánh bắt đến muối ủ.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '8dfb2559-3781-4b6e-a1b3-ad6cc33b4485', '23431b56-3e63-4368-949f-8df24ab3c539', 'Lễ hội Đờn ca tài tử Bạc Liêu', 'Tháng 11–12 hằng năm (lịch cụ thể thay đổi)',
  'TP. Bạc Liêu (nay thuộc tỉnh Cà Mau)', 'Lễ hội tôn vinh đờn ca tài tử Nam Bộ — di sản văn hóa phi vật thể thế giới được UNESCO công nhận năm 2013. Bạc Liêu là cái nôi của đờn ca tài tử với nhạc sĩ Cao Văn Lầu và bài ''Dạ cổ hoài lang''. Có thi đấu đờn ca, triển lãm và biểu diễn đường phố.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '0dc5019b-9533-4c00-aceb-bfa4d1a984ee', '23431b56-3e63-4368-949f-8df24ab3c539', 'Ngày hội Văn hóa – Thể thao dân tộc Khmer Nam Bộ', 'Thường tổ chức vào tháng 11–12 (lịch thay đổi từng năm)',
  'TP. Cà Mau và các huyện có đông đồng bào Khmer', 'Sự kiện định kỳ vinh danh văn hóa người Khmer vùng Tây Nam Bộ, có đua ghe ngo, múa Lâm Thôn, triển lãm trang phục và ẩm thực Khmer. Đây là dịp để hiểu sâu hơn về cộng đồng dân tộc thiểu số đang sinh sống lâu đời tại đồng bằng Cửu Long.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  'b13447d0-437f-4127-93ed-d630c9672531', '23431b56-3e63-4368-949f-8df24ab3c539', 'Chợ Cà Mau (Chợ trung tâm)', 'market',
  'Khu vực trung tâm TP. Cà Mau', 'Thường 5:00–18:00 — xác nhận trước khi đến',
  NULL, 'Nơi tốt nhất để mua đặc sản mang về: tôm khô, ba khía, mật ong U Minh. Nên đến buổi sáng để hàng tươi nhất. Mặc cả là thông lệ, đặc biệt khi mua số lượng nhiều.',
  ARRAY['tôm khô', 'ba khía muối', 'mật ong rừng U Minh', 'cua biển tươi', 'hải sản khô', 'đặc sản địa phương'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  'bfe3ae3b-d9bb-4edc-8158-9cc6f933a572', '23431b56-3e63-4368-949f-8df24ab3c539', 'Cơ sở đặc sản Tôm khô Sông Đốc', 'souvenir_shop',
  'Khu vực thị trấn Sông Đốc, huyện Trần Văn Thời', NULL,
  NULL, 'Sông Đốc là cảng cá lớn nhất Cà Mau — tôm khô và hải sản khô ở đây tươi và chất lượng hơn chợ thành phố. Mua trực tiếp từ cơ sở sản xuất để được giá gốc.',
  ARRAY['tôm khô sông đốc', 'tôm khô cà mau', 'mực khô', 'cá khô'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '4a066f8f-7118-482c-8512-594382fbd761', '23431b56-3e63-4368-949f-8df24ab3c539', 'Chợ đặc sản Năm Căn', 'market',
  'Thị trấn Năm Căn, huyện Năm Căn, Cà Mau', 'Thường 4:00–10:00 (chợ sáng)',
  NULL, 'Chợ sáng sớm nhộn nhịp nhất vùng rừng đước — họp từ 4:00 sáng. Đặc biệt phong phú cua, cá đồng và các loại hải sản vùng rừng ngập mặn. Không khí chợ chồm hổm đặc trưng miền Tây rất thú vị.',
  ARRAY['cua biển tươi', 'ba khía sống', 'cá đồng', 'hải sản tươi sống', 'rau rừng'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  'f0827140-5534-491e-8e9b-cea5f874aac8', '23431b56-3e63-4368-949f-8df24ab3c539', 'Siêu thị Co.opmart Cà Mau', 'mall',
  'Khu vực trung tâm TP. Cà Mau', 'Thường 8:00–22:00',
  NULL, 'Lựa chọn an toàn cho khách muốn mua đặc sản đã được đóng gói, đảm bảo vệ sinh thực phẩm và tiêu chuẩn. Mật ong U Minh và tôm khô đóng hộp bán nhiều ở đây.',
  ARRAY['đặc sản đóng gói', 'thực phẩm địa phương', 'hàng tiêu dùng', 'quà lưu niệm'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  'b9530a7b-1f89-4162-974c-2266e6f51c98', '23431b56-3e63-4368-949f-8df24ab3c539', 'Chợ Bạc Liêu', 'market',
  'Khu vực trung tâm TP. Bạc Liêu (nay thuộc tỉnh Cà Mau)', 'Thường 5:00–18:00',
  NULL, 'Nếu ghé Bạc Liêu, đây là nơi mua đặc sản vùng này. Muối ớt Bạc Liêu và bánh tét lá cẩm là hai món quà ý nghĩa, giá bình dân.',
  ARRAY['đặc sản bạc liêu', 'bánh tét lá cẩm', 'muối ớt bạc liêu', 'sản vật địa phương'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '654f0dda-9d4e-47ca-8b50-0bda7d9a431d', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Lễ hội Óoc Om Bóc – Đua ghe Ngo', 'Tháng 10 âm lịch (thường tháng 11 dương lịch), hằng năm',
  'Sông Maspero (Sóc Trăng cũ) và các địa điểm trung tâm TP. Cần Thơ mới', 'Lễ hội lớn nhất của người Khmer Nam Bộ, gồm 2 phần: Lễ Cúng Trăng (dâng lễ vật cúng Mặt Trăng vào đêm rằm) và Hội đua ghe Ngo trên sông sáng hôm sau. Đua ghe Ngo là phần hấp dẫn nhất với hàng chục chiếc ghe dài 25–30m, mỗi ghe 40–60 tay chèo thi đấu trên đoạn sông. Sau sáp nhập 2025, lễ hội Sóc Trăng thuộc Cần Thơ.',
  'Miễn phí xem', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  'd08bd281-64ed-4536-8d46-df8b717b1850', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Lễ hội Du lịch Cần Thơ', 'Tháng 4 hằng năm (thường gần dịp 30/4)',
  'Bến Ninh Kiều và các địa điểm du lịch trung tâm TP. Cần Thơ', 'Lễ hội du lịch thường niên của TP. Cần Thơ với các hoạt động như: triển lãm ảnh sông nước miền Tây, biểu diễn đờn ca tài tử Nam Bộ, trình diễn nghề thủ công truyền thống, hội chợ ẩm thực đặc sản và các tour khám phá thành phố miễn phí hoặc giảm giá.',
  'Miễn phí hoặc giá thấp (tùy hoạt động)', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  'db26e9a5-3971-4cfe-9156-e9ea7f833260', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chợ phiên nổi Cái Răng cuối tuần', 'Thứ Bảy và Chủ Nhật hằng tuần',
  'Chợ nổi Cái Răng, Quận Cái Răng, TP. Cần Thơ', 'Cuối tuần chợ nổi Cái Răng sôi động hơn ngày thường với nhiều ghe thuyền hơn và một số hoạt động đặc biệt dành cho du khách như: trình diễn nấu ăn trên ghe, đặc sản mùa vụ, và cơ hội giao lưu với tiểu thương. Nhiều du khách chọn cuối tuần để kết hợp tham quan.',
  'Miễn phí vào (giá tour thuyền riêng)', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '9ce8a00b-4b77-4c87-b450-6025b634476a', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Mùa nước nổi miền Tây', 'Tháng 9 – 11 hằng năm',
  'Vùng đồng bằng sông Cửu Long, đặc biệt khu ngoại ô Cần Thơ và các huyện', 'Mùa nước từ thượng nguồn Mekong đổ về tạo nên cảnh sắc đặc trưng: đồng bằng mênh mông nước, cá linh theo nước đổ về, hoa điên điển nở vàng. Đây là mùa của những món đặc sản như cá linh kho mắm, bông điên điển nấu canh chua — trải nghiệm khó quên về văn hóa mùa nước của người miền Tây.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '507b4e4d-dbe8-43d1-9356-ad2886f46471', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Tết Nguyên Đán tại Cần Thơ', 'Tháng 1 hoặc tháng 2 dương lịch (âm lịch: 28 tháng Chạp – 10 tháng Giêng)',
  'Bến Ninh Kiều, chợ Cần Thơ và toàn thành phố', 'Tết tại Cần Thơ rất sôi động với chợ hoa Ninh Kiều bên sông, màn bắn pháo hoa đêm giao thừa tại bến Ninh Kiều, và không khí sum họp của người miền Tây. Lưu ý: nhiều nhà hàng và dịch vụ đóng cửa từ mùng 1–3, chợ nổi vắng hơn thường ngày trong 3 ngày Tết.',
  'Miễn phí xem', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '090f8d76-401d-442d-b6e9-e0fd5096e337', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chợ Cần Thơ (Chợ Trung tâm)', 'market',
  'Đường Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ', 'Thường 6:00–18:00 — xác nhận thực tế tại Google Maps',
  'Bình dân', 'Khu vực bán đặc sản và mắm ở tầng 1 phía trong chợ. Mặc cả được với hàng khô, không mặc cả với hàng ăn. Mua mắm nên chọn loại đóng hộp kín để mang về dễ hơn.',
  ARRAY['đặc sản miền Tây', 'mắm các loại', 'trái cây tươi', 'bánh tráng', 'vải thổ cẩm', 'quần áo', 'đồ gia dụng'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '8e4a6fa2-9cda-4940-86b8-3fc43487d32b', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Co.opmart Cần Thơ', 'mall',
  'Đường Nguyễn Văn Cừ, Quận Ninh Kiều, TP. Cần Thơ', '8:00–22:00 hằng ngày — xác nhận tại Google Maps',
  'Trung bình', 'Lựa chọn tốt nhất để mua đặc sản mang về với giá niêm yết rõ ràng và đóng gói sẵn. Nem nướng Cái Răng đóng gói chân không tiện mang xa.',
  ARRAY['đặc sản đóng gói', 'nem nướng Cái Răng', 'mắm thương hiệu', 'rượu nếp than', 'bánh kẹo', 'hàng tiêu dùng'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  'a3fa957f-c884-4278-9a7c-237c06df2a95', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chợ đêm Ninh Kiều', 'market',
  'Bến Ninh Kiều, Đường Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ', '18:00–22:00 hằng ngày',
  'Bình dân', 'Vừa ăn uống vừa mua sắm quà lưu niệm. Giá quà lưu niệm ở đây có thể cao hơn trong chợ chính — so sánh trước khi mua. Không khí buổi tối rất thú vị.',
  ARRAY['ẩm thực đường phố', 'trái cây nhiệt đới', 'quà lưu niệm', 'hàng thủ công', 'áo thun in hình'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  'f3b2e6d2-02b2-4dd9-83b5-3570c24968b3', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chợ nổi Cái Răng (mua sắm trực tiếp)', 'market',
  'Quận Cái Răng, TP. Cần Thơ', '5:00–9:00',
  'Bình dân – Rẻ', 'Mua trực tiếp từ ghe người bán với giá buôn. Hỏi giá và trả giá nhẹ nhàng. Chỉ có thể đến bằng thuyền. Không có bao bì nên chuẩn bị túi đựng.',
  ARRAY['trái cây tươi nguyên ghe', 'khóm (dứa)', 'dưa hấu', 'thanh long', 'sầu riêng (mùa vụ)', 'rau củ miền Tây'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '85f1c45f-2e77-4583-8999-9c4ed82ff019', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Cửa hàng đặc sản Mỹ Khánh', 'souvenir_shop',
  'Khu du lịch Mỹ Khánh, Xã Mỹ Khánh, Huyện Phong Điền, TP. Cần Thơ', '7:00–17:00 — xác nhận thực tế',
  'Bình dân – Trung bình', 'Mua trực tiếp tại khu du lịch sinh thái Mỹ Khánh khi đi tour vườn. Giá thường dễ chịu hơn trung tâm thành phố. Rượu đặc sản cần kiểm tra kỹ tem nhãn.',
  ARRAY['mắm Cần Thơ', 'kẹo dừa', 'rượu đặc sản miền Tây', 'trái cây sấy', 'bánh tráng mè', 'đường thốt nốt'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '3797edb5-23e2-4319-8809-61e61a5c1607', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Lễ Hội Lồng Tồng (Xuống Đồng)', 'Tháng Giêng âm lịch (thường tháng 1–2 dương lịch)',
  'Các xã nông thôn và bản làng toàn tỉnh Cao Bằng', 'Lễ hội truyền thống lớn nhất của người Tày-Nùng Cao Bằng, cầu mùa màng bội thu đầu năm mới. Bao gồm lễ cúng thần nông tại ruộng, hội tung còn, hát lượn, đánh pháo đất và các trò chơi dân gian truyền thống. Đây là dịp để con cháu về thăm gia đình và cộng đồng đoàn kết.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  'b41ce3e8-34ea-4511-9b7a-055659d57515', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Lễ Hội Nàng Hai', 'Tháng 2–3 âm lịch (thường tháng 3–4 dương lịch)',
  'Huyện Phục Hòa và các vùng người Tày, tỉnh Cao Bằng', 'Lễ hội đón Nàng Trăng và cầu phúc của người Tày Cao Bằng, mang đậm bản sắc tín ngưỡng tâm linh dân gian. Có các nghi lễ đặc trưng: hát then, đàn tính, múa và dâng lễ vật cho Nàng Hai (người con gái Mặt Trăng) để cầu an, cầu mưa thuận gió hòa. Di sản văn hóa phi vật thể quốc gia.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  'fcf16302-80b3-40e2-84da-375335ebe391', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Kỷ Niệm Ngày Thành Lập Quân Đội Nhân Dân Việt Nam', '22 tháng 12 hằng năm',
  'Khu Di tích Rừng Trần Hưng Đạo, huyện Nguyên Bình, tỉnh Cao Bằng', 'Lễ kỷ niệm ngày 22/12/1944 — ngày thành lập Đội Việt Nam Tuyên truyền Giải phóng quân tại khu rừng Trần Hưng Đạo, Cao Bằng. Sự kiện được tổ chức hằng năm với các nghi lễ dâng hương, biểu diễn văn nghệ và triển lãm lịch sử, thu hút đoàn thể từ khắp cả nước về tham dự.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '558d2683-d0ba-4b81-866d-0223bae35658', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Chợ Cao Bằng (Chợ Hợp Giang)', 'market',
  'Phường Hợp Giang, TP. Cao Bằng — xác nhận địa chỉ chi tiết tại Google Maps', '5:00–18:00 hằng ngày — xác nhận trước khi đến',
  '// TODO: xác nhận tại chợ — giá biến động theo mùa', 'Đến sáng sớm để mua hạt dẻ tươi nhất và có giá tốt nhất. Ngày chợ phiên đông hơn bình thường, có nhiều người dân tộc từ bản về bán đồ.',
  ARRAY['hạt dẻ Trùng Khánh', 'miến dong', 'thổ cẩm Tày-Nùng', 'rau rừng', 'thịt lợn đen', 'mật ong rừng', 'bánh khẩu sli'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '71f16e00-fa9e-4b73-9754-428017232233', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Cửa Hàng Đặc Sản Cao Bằng', 'souvenir_shop',
  'Trung tâm TP. Cao Bằng — xác nhận địa chỉ tại Google Maps', '8:00–20:00 hằng ngày — xác nhận trước khi đến',
  '// TODO: xác nhận tại cửa hàng', 'Chọn các cơ sở có chứng nhận nguồn gốc để đảm bảo hạt dẻ là loại Trùng Khánh chính gốc (được bảo hộ chỉ dẫn địa lý). Hỏi kỹ ngày thu hoạch nếu mua hạt dẻ.',
  ARRAY['hạt dẻ Trùng Khánh đóng gói', 'miến dong đóng gói', 'mật ong rừng', 'chè Cao Bằng', 'rượu ngô đặc sản'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '967b90f7-d5ce-4914-b83c-7b13969bbdd2', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Làng Nghề Thổ Cẩm Tày-Nùng', 'boutique',
  'Các bản làng quanh TP. Cao Bằng và huyện Hà Quảng — hỏi hướng dẫn viên địa phương', 'Không cố định — liên hệ trước',
  '// TODO: xác nhận tại cơ sở — hàng thủ công có giá biến động', 'Mua trực tiếp tại làng nghề để ủng hộ nghệ nhân địa phương và có giá tốt hơn. Tránh các sản phẩm in công nghiệp giả mẫu thổ cẩm.',
  ARRAY['vải thổ cẩm', 'túi thổ cẩm', 'khăn Piêu', 'trang phục dân tộc Tày-Nùng', 'đồ trang sức bạc'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  'f171b273-7fdf-4df8-9019-89724d2613be', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Chợ Phiên Huyện Trùng Khánh', 'market',
  'Thị trấn Trùng Khánh, huyện Trùng Khánh, tỉnh Cao Bằng', 'Chợ phiên họp vào thứ 3, thứ 6 và Chủ nhật — xác nhận lịch chính xác tại địa phương',
  '// TODO: xác nhận tại chợ — giá nông sản biến động', 'Chợ phiên Trùng Khánh là nơi mua hạt dẻ tươi rẻ nhất và tươi nhất, ngay tại vùng trồng. Kết hợp mua sắm khi đi thăm thác Bản Giốc (cách nhau ~15km).',
  ARRAY['hạt dẻ Trùng Khánh tươi', 'nông sản địa phương', 'gia vị bản địa (mắc mật, thảo quả)', 'gà đen', 'lợn rừng'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eeecc-64d3-745d-8f48-dd103fb4d1ea', '44444444-4444-4444-4444-444444444444', 'Đêm phố cổ không dùng điện (Đêm rằm Hội An)', 'Đêm 14 âm lịch hàng tháng',
  'Khu phố cổ Hội An', 'Mỗi tháng một lần vào đêm 14 âm lịch, khu phố cổ tắt điện, chỉ chiếu sáng bằng đèn lồng truyền thống, tạo không khí huyền ảo đặc trưng chỉ có ở Hội An.',
  NULL, FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eeecc-64d4-7cd2-8fba-1fe9d62fd284', '44444444-4444-4444-4444-444444444444', 'Lễ hội Pháo hoa Quốc tế Đà Nẵng (DIFF)', 'Thường tổ chức vào tháng 6 hàng năm — xác nhận lịch chính thức trước khi đến',
  'Ven sông Hàn, thành phố Đà Nẵng', 'Cuộc thi trình diễn pháo hoa quốc tế quy tụ các đội thi từ nhiều quốc gia, một trong những sự kiện du lịch lớn nhất của Đà Nẵng, thu hút đông đảo du khách trong và ngoài nước.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eeecc-64d4-705b-a1bd-5b156f0baa5b', '44444444-4444-4444-4444-444444444444', 'Lễ hội Quán Thế Âm Ngũ Hành Sơn', 'Thường tổ chức tháng 2–3 âm lịch hàng năm — xác nhận lịch chính thức trước khi đến',
  'Khu di tích Ngũ Hành Sơn, thành phố Đà Nẵng', 'Lễ hội Phật giáo lớn gắn với tín ngưỡng thờ Quán Thế Âm tại Ngũ Hành Sơn, gồm phần lễ trang nghiêm và phần hội với các hoạt động văn hóa dân gian.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '35ab4ec1-5248-50bd-8dee-0ae758d0a099', '44444444-4444-4444-4444-444444444444', 'Lễ hội Cầu Bông làng rau Trà Quế', 'Thường tổ chức đầu năm âm lịch — xác nhận lịch chính thức trước khi đến',
  'Làng rau Trà Quế, thành phố Hội An', 'Lễ hội cầu mong mùa màng tốt tươi của người dân làng rau Trà Quế, gồm nghi lễ cúng tổ nghề và các hoạt động hội làng truyền thống.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeecc-64d4-7cbf-8482-e5af3c53c0c5', '44444444-4444-4444-4444-444444444444', 'Chợ Hội An', 'market',
  'Đường Trần Quý Cáp, khu phố cổ Hội An', NULL,
  NULL, 'Mặc cả nhẹ nhàng với người bán, đặc biệt khi mua số lượng lớn đồ lưu niệm.',
  ARRAY['đèn lồng', 'vải may áo dài', 'đồ khô', 'đặc sản địa phương'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeecc-64d4-70ee-b80a-10a1c45b9332', '44444444-4444-4444-4444-444444444444', 'Phố đèn lồng Trần Phú', 'street',
  'Đường Trần Phú, khu phố cổ Hội An', NULL,
  NULL, 'Chọn đèn lồng gấp gọn (dạng xếp) nếu cần mang lên máy bay vì gọn nhẹ hơn loại khung cứng.',
  ARRAY['đèn lồng giấy lụa các kích cỡ', 'đèn lồng gấp gọn mang về'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeecc-64d4-7db4-ac3d-169b63c3cbec', '44444444-4444-4444-4444-444444444444', 'Chợ Cồn Đà Nẵng', 'market',
  'Đường Hùng Vương, thành phố Đà Nẵng', NULL,
  NULL, 'Chợ lớn nhất Đà Nẵng, phù hợp mua đặc sản khô làm quà như mực khô, tôm khô với giá tốt hơn khu du lịch.',
  ARRAY['đặc sản khô', 'quần áo', 'đồ lưu niệm', 'hải sản khô'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeecc-64d4-7b22-8b58-27546a626e1e', '44444444-4444-4444-4444-444444444444', 'Vincom Plaza Đà Nẵng', 'mall',
  'Đường Ngô Quyền, thành phố Đà Nẵng', NULL,
  NULL, 'Phù hợp cho khách muốn mua sắm trong không gian máy lạnh vào những ngày nắng gắt hoặc mưa.',
  ARRAY['thời trang', 'mỹ phẩm', 'đồ điện tử', 'ẩm thực trong trung tâm thương mại'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeecc-64d4-771b-b3f6-a240478319be', '44444444-4444-4444-4444-444444444444', 'Làng nghề may đo Hội An', 'boutique',
  'Khu vực phố Trần Hưng Đạo và phụ cận, Hội An', NULL,
  NULL, 'Đặt may trước 2–3 ngày để có thời gian thử và sửa đồ trước khi rời Hội An.',
  ARRAY['áo dài đo theo yêu cầu', 'veston may đo', 'túi da thủ công'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eeef1-4b2d-7cd6-97ff-443a6f2b9564', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Lễ hội Cà phê Buôn Ma Thuột', 'Định kỳ 2 năm/lần, thường vào đầu/giữa tháng 3 (lần gần nhất: 9–13/3/2025)',
  'Thành phố Buôn Ma Thuột và một số địa phương trong tỉnh Đắk Lắk', 'Lễ hội cấp quốc gia lớn nhất của tỉnh Đắk Lắk, được Thủ tướng Chính phủ công nhận, tổ chức định kỳ 2 năm/lần nhằm tôn vinh người trồng và kinh doanh cà phê, quảng bá thương hiệu ''Buôn Ma Thuột — Điểm đến của cà phê thế giới''. Gồm hội chợ triển lãm cà phê quốc tế, lễ hội đường phố, lễ hội ánh sáng, trình diễn cồng chiêng Tây Nguyên, hội voi Buôn Đôn, đua thuyền độc mộc.',
  'Miễn phí tham gia các hoạt động cộng đồng (hội chợ, lễ hội đường phố, uống cà phê miễn phí) — một số hoạt động/trải nghiệm riêng có thể có phí', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eeef1-4b2d-722d-ae5b-a3b72b0cb769', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Hội Voi Buôn Đôn', 'Thường gắn liền với chuỗi hoạt động Lễ hội Cà phê Buôn Ma Thuột (tháng 3, năm tổ chức lễ hội cà phê) — xác nhận lịch cụ thể từng năm',
  'Khu du lịch Buôn Đôn, huyện Buôn Đôn, tỉnh Đắk Lắk', 'Sự kiện văn hóa gắn với truyền thống thuần dưỡng voi của người Ê Đê, M''nông tại Buôn Đôn, thường được tổ chức như một phần hành trình du lịch trong khuôn khổ Lễ hội Cà phê Buôn Ma Thuột.',
  NULL, FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eeef1-4b2d-7607-8933-f4572e6a5797', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Hội đua thuyền độc mộc huyện Lắk', 'Thường tổ chức gắn với chuỗi hoạt động Lễ hội Cà phê Buôn Ma Thuột — xác nhận lịch cụ thể từng năm',
  'Hồ Lắk, huyện Lắk, tỉnh Đắk Lắk', 'Hoạt động đua thuyền độc mộc truyền thống của người M''nông trên hồ Lắk, là một trong các hành trình du lịch trải nghiệm văn hóa được tổ chức trong khuôn khổ các lễ hội lớn của tỉnh.',
  NULL, FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eeef1-4b2d-7a6d-b6ac-b9168b13f541', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Lễ hội Cồng chiêng Tây Nguyên', 'Không có thời gian tổ chức cố định, thường diễn ra vào khoảng tháng 11 đến tháng 1 (cuối năm theo âm lịch), tại các buôn làng',
  'Các buôn làng tại Buôn Ma Thuột và khu vực Tây Nguyên (Đắk Lắk, Gia Lai, Kon Tum)', 'Không gian Văn hóa Cồng chiêng Tây Nguyên đã được UNESCO công nhận là Di sản văn hóa phi vật thể đại diện của nhân loại. Tiếng cồng chiêng được xem là ngôn ngữ giao tiếp giữa con người với thần linh (Yang), xuất hiện trong các nghi lễ quan trọng như mừng lúa mới, cúng bến nước, cưới hỏi.',
  NULL, TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeef1-4b2d-74a1-ae2f-ef86dba7064a', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Chợ trung tâm Buôn Ma Thuột', 'market',
  'Đường Nguyễn Công Trứ, thành phố Buôn Ma Thuột', NULL,
  NULL, 'Khu C của chợ được đánh giá là khu vực tập trung đặc sản làm quà phong phú nhất — nên hỏi giá vài nơi trước khi mua vì giá có thể khác nhau giữa các sạp.',
  ARRAY['Cà phê nguyên chất', 'Bò một nắng', 'Muối kiến vàng', 'Mật ong rừng', 'Tiêu rừng', 'Măng le khô', 'Đồ thổ cẩm'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeef1-4b2d-7b6b-a518-2647ec3731ad', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Vincom Plaza Buôn Ma Thuột', 'mall',
  'Thành phố Buôn Ma Thuột, tỉnh Đắk Lắk', NULL,
  NULL, 'Phù hợp khi cần mua sắm hàng tiêu dùng thông thường hoặc tránh nắng/mưa giữa các điểm tham quan; không phải nơi mua đặc sản địa phương.',
  ARRAY['Thời trang', 'Hàng tiêu dùng', 'Ẩm thực', 'Giải trí'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeef1-4b2d-78bc-a25e-ac4677ba93d0', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Làng Cà phê Trung Nguyên', 'souvenir_shop',
  '153 Lý Thái Tổ và 222 Lê Thánh Tông, thành phố Buôn Ma Thuột', NULL,
  NULL, 'Có thể kết hợp tham quan kiến trúc nhà dài, vườn cây xanh và mua cà phê làm quà ngay trong khuôn viên trước khi sang Bảo tàng Thế giới Cà phê gần đó.',
  ARRAY['Cà phê đặc sản các loại', 'Cà phê chế biến sẵn', 'Quà tặng liên quan đến cà phê'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eeef1-4b2d-71e5-9c63-1a386b404b87', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Cửa hàng Quà Tây Nguyên', 'souvenir_shop',
  '36 Lê Đức Thọ, phường Thắng Lợi, thành phố Buôn Ma Thuột', NULL,
  NULL, 'Phù hợp cho du khách muốn mua đặc sản đóng gói sẵn, tiện mang theo máy bay hoặc làm quà mà không cần ghé chợ.',
  ARRAY['Cà phê đóng gói', 'Mắc ca', 'Hạt tiêu', 'Mật ong', 'Sầu riêng sấy'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '243669ed-ce70-4303-923d-7f7c31b0855d', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Lễ hội Sayangva (Cúng thần Lúa) của người Chơro', 'Tháng 3–4 âm lịch hằng năm (thường tháng 4–5 dương lịch)',
  'Huyện Long Khánh và một số xã người Chơro, Đồng Nai', 'Lễ hội truyền thống quan trọng nhất của người Chơro — dân tộc bản địa của vùng Đông Nam Bộ sinh sống lâu đời tại Đồng Nai. Lễ cúng thần Lúa (Yang Va) gồm nghi thức dâng lễ vật, hát múa truyền thống, chơi cồng chiêng và ăn uống cộng đồng. Là dịp hiếm để tiếp cận văn hóa bản địa đặc sắc.',
  'Miễn phí tham dự (cộng đồng mở cửa đón khách)', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  'e33b900e-66a3-481c-9971-c71994b7c957', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Lễ hội trái cây Đồng Nai', 'Tháng 6–7 hằng năm (mùa trái cây chính)',
  'TP. Biên Hòa và huyện Cẩm Mỹ, Long Khánh, Đồng Nai', 'Lễ hội tôn vinh các loại trái cây đặc sản Đồng Nai như bưởi Tân Triều, sầu riêng Cẩm Mỹ, chôm chôm Long Khánh, măng cụt... Có các hoạt động: trưng bày giống trái cây, thi bình trái cây, ẩm thực từ trái cây và chợ nông sản giá gốc tại vườn.',
  'Miễn phí hoặc giá thấp', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '143b2916-7b17-4e77-b0b1-4b32478bf67e', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Tết Chôl Chnăm Thmây (Tết Khmer)', 'Tháng 4 dương lịch (khoảng 13–16/4 hằng năm)',
  'Các chùa Khmer khu vực Bình Phước cũ (nay thuộc Đồng Nai), đặc biệt huyện Bù Đốp', 'Tết Năm Mới của người Khmer Nam Bộ — lễ hội lớn nhất trong năm của cộng đồng Khmer tại Bình Phước cũ, nay thuộc Đồng Nai sau sáp nhập 2025. Các nghi lễ tại chùa, múa Lâm Thol truyền thống, thả đèn nước và bữa tiệc cộng đồng kéo dài 3 ngày.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '4f9f0067-3a50-4fd6-9ccc-0d495b96d4fa', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Giỗ Tổ Hùng Vương tại Văn miếu Trấn Biên', 'Mùng 10 tháng 3 âm lịch hằng năm',
  'Văn miếu Trấn Biên, TP. Biên Hòa, Đồng Nai', 'Lễ Giỗ Tổ Hùng Vương tổ chức trọng thể tại Văn miếu Trấn Biên — ngôi văn miếu lớn nhất Nam Bộ. Nghi lễ dâng hương trang nghiêm, biểu diễn múa hát truyền thống và các hoạt động văn hóa giáo dục. Thu hút đông đảo người dân và học sinh toàn tỉnh về dự.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '02b42832-b25d-47c7-9cde-3e27e1a977ef', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Mùa trekking Nam Cát Tiên (mùa khô)', 'Tháng 12 – tháng 4 hằng năm',
  'Vườn Quốc gia Nam Cát Tiên, Huyện Tân Phú, Đồng Nai', 'Mùa khô là thời điểm lý tưởng nhất để trekking và quan sát thú ở Nam Cát Tiên: đường mòn khô ráo, động vật tập trung ra bàu uống nước dễ quan sát hơn, ít muỗi và côn trùng hơn mùa mưa. Ban quản lý VQG thường tổ chức thêm các tour đặc biệt và chương trình giáo dục môi trường.',
  'Theo giá tour (xem tours.json)', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  'e45cb3fa-e15f-4f93-8b4c-8e2af43c807d', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Tết Nguyên Đán tại Hà Nội', 'Tháng 1 hoặc 2 (theo lịch âm)',
  'Toàn thành phố, chợ hoa Hàng Lược', 'Lễ hội lớn nhất trong năm, phố cổ trang trí rực rỡ, chợ hoa Hàng Lược nhộn nhịp những ngày cận Tết.',
  'free', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  'd61bd410-80c6-4b5d-849a-85f1f0564804', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Lễ hội Gò Đống Đa', 'Mùng 5 Tết (lịch âm)',
  'Công viên Đống Đa, quận Đống Đa', 'Lễ hội tưởng nhớ chiến thắng Ngọc Hồi - Đống Đa của vua Quang Trung, có múa rồng, tái hiện lịch sử.',
  'free', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '863fb8d9-7e24-4a17-a9b0-4888e14e374d', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Trung Thu phố cổ Hà Nội', 'Tháng 8 (rằm tháng 8 âm lịch)',
  'Phố Hàng Mã và khu phố cổ', 'Phố Hàng Mã rực rỡ đèn lồng, mặt nạ, đồ chơi Trung Thu truyền thống, đông đúc về tối.',
  'free', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '2786d28f-64d4-4b71-99b4-d52fc7fd92e9', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Chợ Đồng Xuân', 'market',
  'Phố Đồng Xuân, quận Hoàn Kiếm, Hà Nội', '6:00–19:00 (chợ đêm cuối tuần đến muộn hơn)',
  'Trung bình – nên trả giá', 'Chợ truyền thống lớn nhất phố cổ, nên trả giá khi mua.',
  ARRAY['Vải vóc', 'Đồ gia dụng', 'Quà lưu niệm', 'Ẩm thực chợ'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '4655b539-053d-43b8-9243-10d6cc00dfed', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Phố Hàng Gai (phố lụa)', 'street',
  'Phố Hàng Gai, quận Hoàn Kiếm, Hà Nội', '8:00–21:00',
  'Trung bình – cao tùy chất liệu', 'So sánh vài cửa hàng trước khi mua vì giá có thể chênh nhiều.',
  ARRAY['Lụa tơ tằm', 'Khăn', 'Quần áo may đo'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '522982f6-5834-472e-9d8b-f31d7b735ee4', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Vincom Center Bà Triệu', 'mall',
  '191 Bà Triệu, quận Hai Bà Trưng, Hà Nội', '9:30–22:00',
  'Cố định, theo nhãn hàng', 'Phù hợp khi cần mua sắm trong không gian máy lạnh, giá niêm yết cố định.',
  ARRAY['Thời trang', 'Mỹ phẩm', 'Ẩm thực', 'Rạp chiếu phim'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eedf6-c8b1-75d4-b80c-d7588116bf76', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Lễ hội Tháp Bà Ponagar (Vía Bà)', 'Tháng 3 âm lịch (thường tháng 4–5 dương lịch), 3 ngày',
  'Tháp Bà Ponagar, TP. Nha Trang', 'Lễ hội truyền thống lớn nhất của người Chăm và người Kinh ở Khánh Hòa, thờ nữ thần Ponagar — thánh mẫu bảo hộ vùng đất. Nghi lễ tắm tượng, dâng hương, biểu diễn múa Chăm truyền thống thu hút hàng vạn người. Được Bộ Văn hóa công nhận là di sản văn hóa phi vật thể quốc gia.',
  'Miễn phí tham quan lễ hội — vé vào tháp theo quy định thường ngày', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eedf6-c8b1-7bc8-96ab-90110671bba3', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Festival Biển Nha Trang', 'Thường tổ chức tháng 6–7, cách năm (năm chẵn hoặc theo kế hoạch tỉnh)',
  'Quảng trường 2 tháng 4, bờ biển Trần Phú, TP. Nha Trang', 'Sự kiện du lịch - văn hóa lớn của tỉnh Khánh Hòa với các hoạt động: biểu diễn nghệ thuật, đua thuyền, lễ hội ẩm thực biển, trình diễn ánh sáng trên bờ biển. Thu hút hàng trăm nghìn du khách trong và ngoài nước.',
  'Nhiều hoạt động miễn phí — xác nhận chương trình từng năm tại khanhhoa.gov.vn', FALSE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eedf6-c8b1-762c-b573-39ce65963d9d', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Giải Marathon Quốc tế Nha Trang', 'Thường tháng 5–6 hàng năm — xác nhận lịch chính xác tại website giải',
  'Đường Trần Phú và các tuyến đường ven biển Nha Trang', 'Giải chạy marathon quốc tế với cung đường đẹp dọc bờ biển Nha Trang, thu hút vận động viên trong nước và quốc tế. Các cự ly: 5km, 10km, 21km (Half Marathon), 42km (Full Marathon).',
  'Phí đăng ký theo cự ly — xác nhận tại website đăng ký', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eedf6-c8b1-761e-b0a8-e7cc97f70d8e', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Lễ hội Ăn Tết Nguyên Đán tại Nha Trang', 'Tháng 1–2 (âm lịch) hàng năm',
  'Quảng trường 2 tháng 4, đường Trần Phú, chợ hoa Tết', 'Nha Trang tổ chức nhiều hoạt động đón Tết: chợ hoa Tết, màn pháo hoa đêm Giao Thừa trên biển, các chương trình văn nghệ. Đây cũng là thời điểm đông khách nhất — nên đặt phòng trước vài tháng.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eedf6-c8b1-7058-86c3-044960548ee9', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Chợ Đầm Nha Trang', 'market',
  'Chợ Đầm, TP. Nha Trang, Khánh Hòa', 'Thường 6:00–18:00 — xác nhận trước khi đến',
  'Bình dân — mặc cả được', 'Nơi tốt nhất mua hải sản khô và đặc sản mang về. Hỏi giá ít nhất 2 sạp trước khi mua. Tránh mua yến sào ở nơi không có tem kiểm định.',
  ARRAY['Hải sản khô', 'Yến sào Khánh Hòa', 'Nước mắm Nha Trang', 'Đặc sản địa phương', 'Hàng lưu niệm', 'Quần áo'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eedf6-c8b1-7dab-b060-e8dde5f9b3c2', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Yến Sào Khánh Hòa (Cửa hàng chính thức)', 'souvenir_shop',
  'Nhiều chi nhánh tại TP. Nha Trang — xem yensaokhanhhoa.com.vn', 'Thường 8:00–17:30 — xác nhận tại website hoặc gọi trước',
  'Cao cấp — phụ thuộc loại và trọng lượng', 'Chỉ mua yến sào tại cửa hàng chính thức của Công ty Yến Sào Khánh Hòa để đảm bảo chất lượng và tránh hàng giả. Có thể xuất hóa đơn VAT.',
  ARRAY['Tổ yến thô', 'Yến tinh chế đóng hộp', 'Nước yến đóng chai', 'Quà tặng yến cao cấp'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eedf6-c8b1-73d4-8d4c-5945f9d9d65c', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Nha Trang Center (Trung tâm thương mại)', 'mall',
  '20 Trần Phú, TP. Nha Trang, Khánh Hòa', 'Thường 9:30–22:00 — xác nhận trước khi đến',
  'Tầm trung đến cao cấp — giá niêm yết cố định', 'Địa điểm mua sắm hiện đại nhất Nha Trang, view biển từ tầng trên. Có siêu thị Big C bên trong phù hợp mua đặc sản đóng gói.',
  ARRAY['Thời trang', 'Điện tử', 'Mỹ phẩm', 'Siêu thị', 'Khu ăn uống', 'Rạp chiếu phim'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eedf6-c8b1-7abd-8b02-7f77ceab52a6', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Chợ đêm Nha Trang', 'market',
  'Đường 19 tháng 10, TP. Nha Trang, Khánh Hòa', '17:00–23:00',
  'Bình dân — mặc cả được', 'Kết hợp mua sắm và ăn uống buổi tối. Mặc cả 20–30% là bình thường với hàng lưu niệm.',
  ARRAY['Quần áo', 'Lưu niệm biển', 'Đồ thủ công mỹ nghệ', 'Mô hình tháp Chăm', 'Đặc sản địa phương'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eedf6-c8b1-71d8-bfac-d40b2b17704c', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Khu mua sắm đường Nguyễn Thiện Thuật', 'street',
  'Đường Nguyễn Thiện Thuật, TP. Nha Trang, Khánh Hòa', 'Thường 7:00–20:00',
  'Bình dân đến tầm trung — mặc cả được', 'Tuyến phố chuyên bán hải sản khô và đặc sản mang về. Mua nhiều để được giảm giá. Yêu cầu đóng gói chân không nếu mang lên máy bay.',
  ARRAY['Hải sản khô', 'Nước mắm', 'Tôm khô', 'Mực khô', 'Đặc sản vùng biển'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee06-3f91-7bf0-b70d-6cb0337983f6', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Tết Nguyên Đán Sài Gòn', 'Tháng 1 hoặc tháng 2 hàng năm (theo âm lịch, thường 29 tháng Chạp đến mùng 7 Tết)',
  'Toàn thành phố — trọng điểm: đường hoa Nguyễn Huệ (Quận 1), phố đi bộ Bùi Viện, công viên Tao Đàn', 'Tết Nguyên Đán là lễ hội lớn nhất năm tại TP. HCM. Đường hoa Nguyễn Huệ trưng bày hàng triệu hoa tươi và tác phẩm nghệ thuật suốt 1 tuần trước và sau giao thừa. Pháo hoa bắn tại nhiều điểm trên sông Sài Gòn đêm giao thừa. Chợ hoa Bình Điền và chợ hoa vỉa hè rực rỡ. Lưu ý: nhiều cửa hàng đóng cửa từ mùng 1–3 Tết.',
  'Miễn phí tham quan không gian chung — một số hoạt động có thu phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee06-3f91-75ec-a404-2b3e896e1c1f', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Lễ Giỗ Tổ Hùng Vương & Ngày Giải Phóng 30/4', '10 tháng 3 âm lịch (Giỗ Tổ) và 30/4–1/5 hàng năm',
  'Các điểm di tích lịch sử, Dinh Độc Lập, trung tâm Quận 1', 'Ngày 30/4 (Giải Phóng Miền Nam) là dịp lễ đặc biệt tại TP. HCM với diễu binh, bắn pháo hoa và các hoạt động văn hóa tại Dinh Độc Lập — địa điểm gắn liền với sự kiện lịch sử 1975. Đây là kỳ nghỉ lễ 4–5 ngày, thành phố rất đông người đổ về tham quan.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee06-3f91-714b-9454-3afff768fb43', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Lễ Hội Áo Dài TP. HCM', 'Tháng 3 hàng năm (thường tuần đầu tháng 3)',
  'Phố đi bộ Nguyễn Huệ, Bảo tàng Áo Dài, các điểm di tích lịch sử Quận 1', 'Lễ Hội Áo Dài là sự kiện văn hóa thường niên do Sở Du lịch TP. HCM tổ chức, tôn vinh trang phục truyền thống Việt Nam. Sự kiện gồm các buổi trình diễn áo dài trên phố đi bộ, triển lãm, workshop may áo dài, và diễu hành tập thể. Du khách được khuyến khích mặc áo dài tham gia.',
  'Miễn phí nhiều hoạt động — một số show diễn có vé', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO destination_events (id, destination_id, name, event_date, location_text, description, cost, annual, is_active) VALUES (
  '019eee06-3f91-7bf0-b70d-6cb0337983f7', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Lễ Hội Đền Hùng & Carnival Phố Đi Bộ Nguyễn Huệ', 'Các dịp cuối tuần định kỳ và lễ lớn trong năm',
  'Phố đi bộ Nguyễn Huệ, Quận 1', 'Phố đi bộ Nguyễn Huệ (mở cửa cuối tuần từ 19:00–24:00 thứ 6, 7, CN và dịp lễ) thường xuyên tổ chức các sự kiện văn hóa, âm nhạc đường phố, triển lãm nghệ thuật và carnival. Đây là không gian sinh hoạt cộng đồng sôi động nhất Sài Gòn — lý tưởng để hòa vào nhịp sống đêm thành phố.',
  'Miễn phí', TRUE, TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee06-3f91-7aec-896c-1f222d688931', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Chợ Bến Thành', 'market',
  'Công trường Quách Thị Trang, Phường Bến Thành, Quận 1, TP. HCM', 'Thường 6:00–18:00 (khu đêm đến ~23:00) — xác nhận tại Google Maps',
  'Dao động từ bình dân đến vừa — mặc cả là cần thiết', 'Mặc cả được khoảng 30–50% giá chào ban đầu. Không mua đồ điện tử hoặc hàng thương hiệu ở đây — chất lượng không đảm bảo. Khu ẩm thực bên trong ngon và đa dạng.',
  ARRAY['đồ lưu niệm', 'vải vóc quần áo', 'đặc sản khô', 'đồ thủ công mỹ nghệ', 'hương liệu', 'trái cây', 'ẩm thực đường phố'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee06-3f91-7346-a977-728aedd63b5b', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Phố Mua Sắm Đồng Khởi', 'street',
  'Đường Đồng Khởi, Phường Bến Nghé, Quận 1, TP. HCM', 'Các cửa hàng thường 9:00–21:00 — xác nhận từng shop tại Google Maps',
  'Từ trung cấp đến cao cấp', 'Đây là con phố mua sắm sang trọng nhất Sài Gòn. Phù hợp khách muốn mua đồ thủ công nghệ thuật chất lượng cao như lacquerware, silk, hay thương hiệu thời trang Việt. Đi bộ từ Nhà thờ Đức Bà xuống sông Sài Gòn qua phố này rất đẹp.',
  ARRAY['thời trang cao cấp', 'đồ thủ công nghệ thuật', 'thương hiệu quốc tế', 'cà phê và ăn uống', 'trang sức', 'đồ da'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee06-3f91-7982-88b2-ab9f46268f51', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Chợ An Đông', 'market',
  'Khu vực An Đông, Phường 9, Quận 5, TP. HCM', 'Thường 6:00–18:00 — xác nhận tại Google Maps',
  'Bình dân — giá sỉ và lẻ', 'Chợ An Đông nổi tiếng với vải vóc và quần áo may mặc giá tốt, thường mua sỉ. Khách du lịch lẻ cũng được nhưng nên biết mặc cả. Khu vực Quận 5 (Chợ Lớn) gần đây có nhiều điểm ẩm thực người Hoa thú vị.',
  ARRAY['vải vóc', 'quần áo may mặc', 'hàng Việt Nam sản xuất', 'đồ gia dụng', 'đặc sản miền Nam'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee06-3f91-7767-aa83-ae97b4f67cec', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Vincom Center Đồng Khởi', 'mall',
  '70-72 Lê Thánh Tôn, Phường Bến Nghé, Quận 1, TP. HCM', '10:00–22:00 hàng ngày — xác nhận tại Google Maps',
  'Trung cấp đến cao cấp — giá niêm yết, không mặc cả', 'Trung tâm thương mại hiện đại ngay trung tâm Quận 1. Lý tưởng để mua sắm có hóa đơn, xem phim CGV, hoặc thoát nắng giữa trưa. Siêu thị trong tòa có nhiều đặc sản Việt Nam đóng gói để làm quà mang về.',
  ARRAY['thương hiệu quốc tế', 'thời trang', 'điện tử', 'rạp phim', 'ẩm thực food court', 'siêu thị'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO shopping_places (id, destination_id, name, type, address, opening_hours, price_range, tips, items, is_active) VALUES (
  '019eee06-3f91-7767-aa83-ae97b4f67ced', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Phố Bùi Viện — Khu Phố Tây', 'street',
  'Đường Bùi Viện, Phường Phạm Ngũ Lão, Quận 1, TP. HCM', 'Mua sắm từ khoảng 10:00 — sầm uất nhất 20:00–24:00',
  'Bình dân đến trung cấp — mặc cả được', 'Khu phố Tây Phạm Ngũ Lão-Bùi Viện là thiên đường mua sắm đồ lưu niệm và giao lưu quốc tế. Buổi tối phố đóng xe, biến thành khu đi bộ rất sôi động. Giá đồ lưu niệm thường cao hơn chợ Bến Thành — mặc cả kỹ.',
  ARRAY['đồ lưu niệm', 'quần áo phượt', 'tranh ảnh nghệ thuật', 'bia hơi và đồ uống', 'sản phẩm thủ công địa phương'], TRUE
) ON CONFLICT (id) DO UPDATE SET tips=EXCLUDED.tips, updated_at=NOW();