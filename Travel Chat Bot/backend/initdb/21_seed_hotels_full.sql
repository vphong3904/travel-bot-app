-- PDTrip – Seed: Hotels

INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee71-616e-7007-9b0e-1ab1c59b60cd', '019eee7d-cd94-744b-86d1-ca07059a9949', 'InterContinental Phu Quoc Long Beach Resort', 'resort',
  5, NULL, 'Bãi Trường, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Hồ bơi vô cực ra biển', 'Spa', '5 nhà hàng & bar', 'Gym', 'Wifi miễn phí', 'Đưa đón sân bay', 'Bãi biển riêng'], 'Resort 5 sao sang trọng nằm trên bãi Trường, có hồ bơi vô cực nhìn ra biển đẹp nổi tiếng. Kiến trúc lấy cảm hứng từ văn hóa Khmer, phù hợp trăng mật và du lịch sang.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee71-616e-7bf7-b6ef-2ea09427ed50', '019eee7d-cd94-744b-86d1-ca07059a9949', 'JW Marriott Phu Quoc Emerald Bay', 'resort',
  5, NULL, 'Khem Beach, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Bãi biển riêng Bãi Khem', 'Hồ bơi nhiều khu', 'Spa LaGrace', '6 nhà hàng', 'Gym', 'Kids club', 'Wifi miễn phí'], 'Resort đẳng cấp thế giới nằm tại bãi Khem, được bình chọn là một trong những resort đẹp nhất châu Á. Thiết kế lấy cảm hứng từ trường đại học phong cách Pháp, view biển tuyệt đỉnh.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee71-616e-73ea-84d5-d4199271c80b', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Sunset Sanato Resort & Villas', 'resort',
  4, 2800000, 'Bãi Khem, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Hồ bơi', 'Bãi biển riêng', 'Nhà hàng', 'Wifi miễn phí', 'Đưa đón sân bay (phí thêm)'], 'Resort 4 sao vừa túi tiền, vị trí đắc địa tại bãi Khem yên tĩnh. Phù hợp gia đình và cặp đôi muốn nghỉ dưỡng không quá xa hoa nhưng vẫn tiện nghi.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee71-616e-7184-b71c-ae924a2f8100', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Mango Bay Resort', 'resort',
  3, 1500000, 'Vũng Bầu, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Hồ bơi', 'Nhà hàng hải sản', 'Wifi miễn phí', 'Bãi biển riêng nhỏ'], 'Resort eco-friendly 3 sao ở phía bắc đảo, bungalow xây từ vật liệu tự nhiên, yên tĩnh và gần gũi thiên nhiên. Phù hợp du lịch xanh, gia đình trẻ.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee71-616e-7150-a5bd-5bfad69996ff', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Phu Quoc Backpacker Hostel', 'hostel',
  None, 200000, 'Đường 30 Tháng 4, khu Dương Đông, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Phòng dorm máy lạnh', 'Khu bếp chung', 'Wifi miễn phí', 'Cho thuê xe máy', 'Tour ghép đoàn'], 'Hostel bình dân ngay trung tâm Dương Đông, thuận tiện di chuyển và gần chợ đêm. Phù hợp du lịch bụi solo hoặc nhóm bạn trẻ ngân sách thấp.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee71-616e-7829-bcc9-5499d7c4a90c', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Cassia Cottage', 'guesthouse',
  3, 900000, 'Bãi Trường, TP. Phú Quốc, tỉnh An Giang',
  ARRAY['Hồ bơi nhỏ', 'Nhà hàng', 'Wifi miễn phí', 'Sân vườn nhiệt đới'], 'Guesthouse nhỏ xinh với thiết kế nhiệt đới, phong cách boutique, nằm ngay bãi Trường. Nhiều du khách quay lại vì không khí ấm cúng và chủ nhà thân thiện.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee91-da9f-7163-9882-d33c84fb8000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Aria Hotel Bắc Ninh', 'hotel',
  3, NULL, 'Khu vực trung tâm thành phố Bắc Ninh (xác nhận địa chỉ chính xác tại Google Maps)',
  ARRAY['wifi', 'điều hòa', 'bãi đỗ xe', 'nhà hàng', 'lễ tân 24/7'], 'Khách sạn 3 sao kinh doanh phổ biến tại trung tâm thành phố Bắc Ninh, phù hợp cho khách công vụ và du lịch ngắn ngày. Phòng ốc sạch sẽ, tiện nghi cơ bản đầy đủ, vị trí thuận tiện di chuyển đến các điểm tham quan.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee91-daa0-728b-37d8-47c5ba6f1000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'TTC Hotel Bắc Ninh', 'hotel',
  4, NULL, 'Khu vực trung tâm thành phố Bắc Ninh (xác nhận địa chỉ chính xác tại Google Maps)',
  ARRAY['wifi', 'hồ bơi', 'gym', 'nhà hàng', 'phòng họp', 'điều hòa', 'bãi đỗ xe'], 'Khách sạn 4 sao thuộc chuỗi TTC Hotel, một trong những lựa chọn cao cấp nhất tại Bắc Ninh. Phù hợp cho đoàn doanh nghiệp, hội nghị, và du khách muốn tiện nghi đầy đủ. Có nhà hàng phục vụ ẩm thực Á - Âu.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee91-daa1-7156-66e3-b8f56abf9000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Khách sạn Phương Đông', 'hotel',
  2, NULL, 'Khu vực phố Ngô Gia Tự, thành phố Bắc Ninh (xác nhận số nhà tại Google Maps)',
  ARRAY['wifi', 'điều hòa', 'lễ tân', 'bãi đỗ xe'], 'Khách sạn 2 sao bình dân phổ biến, phù hợp với du khách ngân sách thấp. Vị trí tốt ở khu phố trung tâm, dễ dàng đi bộ đến các quán ăn và chợ. Phòng đơn giản nhưng sạch sẽ, phục vụ thân thiện.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee91-daa2-7378-5d05-1e35ebed7000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Bắc Ninh Palace Hotel', 'hotel',
  3, NULL, 'Khu vực đường Lý Thái Tổ, thành phố Bắc Ninh (xác nhận số nhà tại Google Maps)',
  ARRAY['wifi', 'điều hòa', 'nhà hàng', 'bãi đỗ xe', 'lễ tân 24/7'], 'Khách sạn 3 sao tầm trung, được đánh giá tốt về vị trí và dịch vụ lễ tân. Phù hợp cho cả khách công vụ lẫn khách du lịch gia đình. Nhà hàng có thực đơn ẩm thực địa phương.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee91-daa3-7d44-3cc5-d90244910000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Homestay Quan Họ Làng Diềm', 'homestay',
  None, NULL, 'Làng Diềm (Viêm Xá), xã Hòa Long, thành phố Bắc Ninh',
  ARRAY['wifi', 'bữa sáng địa phương', 'trải nghiệm văn hóa quan họ'], 'Homestay đặc biệt tại làng Diềm — một trong những cái nôi của dân ca Quan họ. Cơ hội hiếm có để ngủ lại trong nhà người dân địa phương, thưởng thức bữa cơm quê và nghe các liền anh liền chị hát quan họ buổi tối. Phù hợp với du khách muốn trải nghiệm văn hóa sâu.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'e9a996d2-da53-437d-84ea-a93d285e56a8', '23431b56-3e63-4368-949f-8df24ab3c539', 'Mường Thanh Grand Cà Mau', 'hotel',
  4, NULL, 'Khu trung tâm TP. Cà Mau, tỉnh Cà Mau',
  ARRAY['wifi', 'hồ bơi', 'nhà hàng', 'phòng gym', 'đỗ xe', 'lễ tân 24h'], 'Khách sạn 4 sao thuộc chuỗi Mường Thanh — thương hiệu khách sạn uy tín hàng đầu Việt Nam. Vị trí trung tâm thành phố, thuận tiện di chuyển. Phù hợp cho cả du khách lẻ và đoàn công tác.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'bda9d2f7-234e-4bae-b799-457c16488bc3', '23431b56-3e63-4368-949f-8df24ab3c539', 'Khách sạn Phương Nam Cà Mau', 'hotel',
  3, NULL, 'Khu vực trung tâm TP. Cà Mau',
  ARRAY['wifi', 'nhà hàng', 'đỗ xe', 'điều hòa'], 'Khách sạn 3 sao quen thuộc tại trung tâm TP. Cà Mau với vị trí thuận tiện. Phòng sạch sẽ, thoáng mát, phù hợp cho du khách tham quan thành phố với ngân sách vừa phải.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '7afd4673-3179-4208-8ae2-802c2eb300ba', '23431b56-3e63-4368-949f-8df24ab3c539', 'Nhà nghỉ Đất Mũi', 'guesthouse',
  None, NULL, 'Xã Đất Mũi, huyện Ngọc Hiển, tỉnh Cà Mau',
  ARRAY['wifi', 'quạt/điều hòa', 'bữa sáng (một số phòng)'], 'Nhà nghỉ dạng guesthouse tại khu vực Đất Mũi — lựa chọn lý tưởng để nghỉ qua đêm gần Mũi Cà Mau. Tuy tiện nghi khiêm tốn nhưng giá tốt và vị trí sát điểm tham quan, phù hợp cho các hành trình khám phá cực Nam đất nước.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '6f465787-0ce3-4f6a-8b30-0aa2f0fc587a', '23431b56-3e63-4368-949f-8df24ab3c539', 'Homestay Rừng Đước U Minh', 'homestay',
  None, NULL, 'Khu vực U Minh Hạ, huyện U Minh, tỉnh Cà Mau',
  ARRAY['wifi', 'bữa ăn theo gói', 'thuyền tham quan rừng', 'võng'], 'Homestay trong lòng rừng tràm U Minh Hạ — trải nghiệm sống cùng người dân địa phương, ngủ trong ngôi nhà gỗ trên mặt nước, ăn bữa cơm miền Tây đạm bạc và thức dậy nghe tiếng chim. Phù hợp cho những ai muốn trải nghiệm văn hóa miền sông nước sâu sắc.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'b6acf6cc-e5c6-4f3c-aa4a-a01df6fc3573', '23431b56-3e63-4368-949f-8df24ab3c539', 'Khách sạn Sông Đốc', 'hotel',
  2, NULL, 'Thị trấn Sông Đốc, huyện Trần Văn Thời, tỉnh Cà Mau',
  ARRAY['wifi', 'điều hòa', 'đỗ xe'], 'Khách sạn nhỏ tại thị trấn Sông Đốc — cảng cá lớn nhất Cà Mau. Phù hợp cho du khách muốn khám phá cảnh sinh hoạt ngư dân và thưởng thức hải sản tươi sống ngay tại nguồn. Lựa chọn budget thực dụng.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '560ae42b-0ca4-45e3-a289-486756094f54', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Azerai La Residence Cần Thơ', 'resort',
  5, NULL, 'Đường Lê Lợi, Quận Ninh Kiều, TP. Cần Thơ',
  ARRAY['hồ bơi', 'spa', 'nhà hàng', 'bar', 'wifi miễn phí', 'dịch vụ đưa đón sân bay', 'phòng ven sông'], 'Khu nghỉ dưỡng 5 sao sang trọng ven sông Cần Thơ với kiến trúc thuộc địa Pháp được phục hồi tinh tế. Sở hữu hồ bơi ngoài trời nhìn ra sông, spa cao cấp và nhà hàng phục vụ ẩm thực Nam Bộ và quốc tế. Là lựa chọn hàng đầu cho kỳ nghỉ dưỡng cao cấp tại miền Tây.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '19a9fcb9-8ced-4610-ad4e-61988949d054', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Mường Thanh Luxury Cần Thơ', 'hotel',
  4, NULL, 'Đường Ngô Quyền, Quận Ninh Kiều, TP. Cần Thơ',
  ARRAY['hồ bơi', 'phòng gym', 'nhà hàng', 'wifi miễn phí', 'bãi đỗ xe', 'phòng hội nghị'], 'Khách sạn 4 sao thuộc chuỗi Mường Thanh, tọa lạc trung tâm thành phố, dễ dàng di chuyển đến bến Ninh Kiều và các điểm tham quan. Phòng rộng rãi, hiện đại với view thành phố hoặc sông Cần Thơ.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '0c41dfc0-ff42-4560-80b2-a45c780f1b0c', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Khách sạn Ninh Kiều 2', 'hotel',
  3, NULL, 'Đường Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ',
  ARRAY['nhà hàng', 'wifi miễn phí', 'bãi đỗ xe', 'view sông'], 'Khách sạn 3 sao truyền thống nằm ngay bến Ninh Kiều, nhìn thẳng ra sông Cần Thơ. Vị trí đắc địa ngay trung tâm, thuận tiện đi bộ đến chợ đêm, bến tàu và phố ẩm thực. Là lựa chọn tầm trung được nhiều du khách trong nước ưa thích.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'fb3dbb3a-9cd6-41d6-a2ee-aed2c6e8ce87', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Sông Xanh Riverside Homestay', 'homestay',
  None, NULL, 'Huyện Phong Điền, TP. Cần Thơ (khu vực vườn trái cây)',
  ARRAY['wifi miễn phí', 'bữa sáng', 'cho thuê xe đạp', 'tour xuồng ba lá', 'vườn trái cây'], 'Homestay phong cách nhà vườn miền Tây nằm ven kênh rạch khu Phong Điền, cách trung tâm Cần Thơ khoảng 15km. Trải nghiệm sống cùng người dân địa phương, ăn sáng với đặc sản miền Tây, và đi xuồng ba lá qua kênh rạch trong vườn trái cây.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'f41bde46-48ab-491c-a801-08d7f90d7481', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Kim Tho Hotel Cần Thơ', 'guesthouse',
  2, NULL, 'Đường Châu Văn Liêm, Quận Ninh Kiều, TP. Cần Thơ',
  ARRAY['wifi miễn phí', 'máy lạnh', 'bãi đỗ xe'], 'Nhà nghỉ bình dân 2 sao giá cả phải chăng, phòng sạch sẽ, nằm trong khu trung tâm gần chợ Cần Thơ và bến Ninh Kiều. Phù hợp cho khách du lịch tiết kiệm, solo traveller và nhóm bạn trẻ.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'c342a323-88cb-41aa-8f81-d66ef59a8f11', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Khách sạn Bằng Giang', 'hotel',
  3, NULL, 'Phường Hợp Giang, TP. Cao Bằng, tỉnh Cao Bằng',
  ARRAY['wifi', 'điều hòa', 'nhà hàng', 'lễ tân 24h', 'bãi đỗ xe'], 'Khách sạn 3 sao nằm ngay trung tâm thành phố Cao Bằng, thuận tiện di chuyển đến các điểm tham quan. Phòng nghỉ sạch sẽ, đầy đủ tiện nghi cơ bản, nhà hàng phục vụ ẩm thực địa phương.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '304f8516-8683-40a7-b0fa-a9fed3cb49ac', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Khách sạn Phong Lan', 'hotel',
  2, NULL, 'Trung tâm TP. Cao Bằng, tỉnh Cao Bằng',
  ARRAY['wifi', 'điều hòa', 'lễ tân'], 'Khách sạn bình dân trung tâm thành phố Cao Bằng, giá cả phải chăng phù hợp cho khách du lịch tự túc và phượt thủ. Vị trí gần chợ và các tiện ích đô thị.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '96bcfd33-b97c-4e32-8bac-19bbd82f106a', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Homestay Bản Giốc View', 'homestay',
  None, NULL, 'Khu vực huyện Trùng Khánh, gần thác Bản Giốc, tỉnh Cao Bằng',
  ARRAY['wifi', 'bữa sáng', 'xe máy cho thuê', 'hướng dẫn địa phương'], 'Homestay do người dân địa phương vận hành gần thác Bản Giốc, mang lại trải nghiệm sống cùng gia đình người Tày-Nùng. Lý tưởng cho khách muốn khám phá văn hóa bản địa và đi thăm thác ngay trong ngày.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '61587651-3a29-48e8-8473-bc9106bfdec0', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Nhà nghỉ Hà Quảng', 'guesthouse',
  None, NULL, 'Thị trấn Hà Quảng, huyện Hà Quảng, tỉnh Cao Bằng',
  ARRAY['wifi', 'điều hòa', 'lễ tân'], 'Nhà nghỉ nhỏ tại thị trấn Hà Quảng, thuận tiện cho khách đến thăm hang Pác Bó và khu vực biên giới phía Bắc. Phù hợp cho khách muốn nghỉ lại trước khi di chuyển sớm ra điểm tham quan.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'ee624b99-4b2a-4901-8307-72635bdc97b2', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Khách sạn Kim Đồng', 'hotel',
  2, NULL, 'Trung tâm TP. Cao Bằng, tỉnh Cao Bằng',
  ARRAY['wifi', 'điều hòa', 'nhà hàng nhỏ', 'bãi đỗ xe'], 'Khách sạn tên gọi theo anh hùng dân tộc Kim Đồng — người liên lạc nhỏ tuổi của Việt Minh quê Cao Bằng. Vị trí trung tâm, phòng ốc gọn gàng, phù hợp khách thương mại và khách du lịch ngân sách thấp.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d2-7293-8074-579adc2abfa2', '44444444-4444-4444-4444-444444444444', 'Hoi An Coco Homestay', 'homestay',
  None, NULL, 'Khu vực Cẩm Châu, gần phố cổ Hội An',
  ARRAY['wifi', 'xe đạp miễn phí', 'bữa sáng', 'sân vườn'], 'Homestay gia đình phong cách vườn nhiệt đới, gần phố cổ, phù hợp khách muốn trải nghiệm sinh hoạt cùng người dân địa phương với mức giá tiết kiệm.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-72d5-a33a-2ab1d536ec9f', '44444444-4444-4444-4444-444444444444', 'Hoi An Backpacker Hostel', 'hostel',
  None, NULL, 'Khu phố cổ Hội An',
  ARRAY['wifi', 'phòng dorm & phòng riêng', 'tour desk', 'khu sinh hoạt chung'], 'Hostel năng động dành cho khách backpacker, gần trung tâm phố cổ, có khu vực chung để giao lưu với du khách quốc tế.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-716f-8954-42dcc494892e', '44444444-4444-4444-4444-444444444444', 'Little Hoi An Boutique Hotel', 'hotel',
  4, NULL, 'Khu vực gần phố cổ Hội An',
  ARRAY['hồ bơi', 'wifi', 'nhà hàng', 'đưa đón sân bay (phụ phí)'], 'Khách sạn boutique 4 sao theo phong cách kiến trúc Hội An truyền thống, gần phố cổ, phù hợp cặp đôi và gia đình muốn không gian yên tĩnh.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-7324-a1c3-66cffa63284c', '44444444-4444-4444-4444-444444444444', 'Anantara Hoi An Resort', 'resort',
  5, NULL, 'Ven sông Thu Bồn, gần phố cổ Hội An',
  ARRAY['hồ bơi', 'spa', 'nhà hàng cao cấp', 'thuyền đưa đón phố cổ'], 'Resort 5 sao nằm bên sông Thu Bồn, kiến trúc thuộc địa Pháp pha trộn văn hóa địa phương, có dịch vụ thuyền riêng đưa khách vào phố cổ.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-7e43-aa78-11a7c5e14ce2', '44444444-4444-4444-4444-444444444444', 'Four Seasons Resort The Nam Hai, Hoi An', 'resort',
  5, NULL, 'Bãi biển Hà My, giữa Đà Nẵng và Hội An',
  ARRAY['villa riêng hồ bơi', 'spa', 'bãi biển riêng', 'nhà hàng fine-dining'], 'Khu nghỉ dưỡng 5 sao đẳng cấp quốc tế với villa biệt lập có hồ bơi riêng, nằm trên bãi biển Hà My giữa Đà Nẵng và Hội An.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d2-7293-8074-579adc2abfa2', '44444444-4444-4444-4444-444444444444', 'Hoi An Coco Homestay', 'homestay',
  None, NULL, 'Khu vực Cẩm Châu, gần phố cổ Hội An',
  ARRAY['wifi', 'xe đạp miễn phí', 'bữa sáng', 'sân vườn'], 'Homestay gia đình phong cách vườn nhiệt đới, gần phố cổ, phù hợp khách muốn trải nghiệm sinh hoạt cùng người dân địa phương với mức giá tiết kiệm.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-72d5-a33a-2ab1d536ec9f', '44444444-4444-4444-4444-444444444444', 'Hoi An Backpacker Hostel', 'hostel',
  None, NULL, 'Khu phố cổ Hội An',
  ARRAY['wifi', 'phòng dorm & phòng riêng', 'tour desk', 'khu sinh hoạt chung'], 'Hostel năng động dành cho khách backpacker, gần trung tâm phố cổ, có khu vực chung để giao lưu với du khách quốc tế.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-716f-8954-42dcc494892e', '44444444-4444-4444-4444-444444444444', 'Little Hoi An Boutique Hotel', 'hotel',
  4, NULL, 'Khu vực gần phố cổ Hội An',
  ARRAY['hồ bơi', 'wifi', 'nhà hàng', 'đưa đón sân bay (phụ phí)'], 'Khách sạn boutique 4 sao theo phong cách kiến trúc Hội An truyền thống, gần phố cổ, phù hợp cặp đôi và gia đình muốn không gian yên tĩnh.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-7324-a1c3-66cffa63284c', '44444444-4444-4444-4444-444444444444', 'Anantara Hoi An Resort', 'resort',
  5, NULL, 'Ven sông Thu Bồn, gần phố cổ Hội An',
  ARRAY['hồ bơi', 'spa', 'nhà hàng cao cấp', 'thuyền đưa đón phố cổ'], 'Resort 5 sao nằm bên sông Thu Bồn, kiến trúc thuộc địa Pháp pha trộn văn hóa địa phương, có dịch vụ thuyền riêng đưa khách vào phố cổ.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eeecc-64d3-7e43-aa78-11a7c5e14ce2', '44444444-4444-4444-4444-444444444444', 'Four Seasons Resort The Nam Hai, Hoi An', 'resort',
  5, NULL, 'Bãi biển Hà My, giữa Đà Nẵng và Hội An',
  ARRAY['villa riêng hồ bơi', 'spa', 'bãi biển riêng', 'nhà hàng fine-dining'], 'Khu nghỉ dưỡng 5 sao đẳng cấp quốc tế với villa biệt lập có hồ bơi riêng, nằm trên bãi biển Hà My giữa Đà Nẵng và Hội An.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'a2fef6df-fd1f-430e-8d0b-6f0fca6df3c2', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Khách sạn Mường Thanh Holiday Điện Biên Phủ', 'hotel',
  4, NULL, 'Him Lam, TP. Điện Biên Phủ, tỉnh Điện Biên',
  ARRAY['wifi', 'hồ bơi', 'nhà hàng', 'spa', 'điều hòa', 'bãi đỗ xe', 'phòng họp'], 'Khách sạn 4 sao của tập đoàn Mường Thanh, một trong những cơ sở lưu trú cao cấp nhất tại Điện Biên Phủ. Phòng rộng rãi, tiện nghi đầy đủ, nhà hàng phục vụ ẩm thực Thái và Việt. Thuận tiện di chuyển đến các khu di tích.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '06f9dc23-18b5-4c4d-87a6-ed76cba6d365', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Khách sạn Him Lam', 'hotel',
  3, NULL, 'Trung tâm TP. Điện Biên Phủ, tỉnh Điện Biên',
  ARRAY['wifi', 'điều hòa', 'nhà hàng', 'lễ tân 24h', 'bãi đỗ xe'], 'Khách sạn 3 sao trung tâm thành phố, gần các khu di tích lịch sử. Tên đặt theo địa danh Him Lam — cứ điểm đầu tiên bị quân ta tấn công trong chiến dịch 1954. Phòng ốc sạch sẽ, phù hợp cho khách du lịch và đoàn thể.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '8b491ffd-b7db-4367-817d-113e3599848d', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Homestay Nhà Sàn Mường Thanh', 'homestay',
  None, NULL, 'Khu vực bản Thái quanh thung lũng Mường Thanh, tỉnh Điện Biên',
  ARRAY['wifi', 'bữa sáng', 'nhà sàn truyền thống', 'trải nghiệm văn hóa Thái'], 'Homestay trong nhà sàn gỗ truyền thống của gia đình người Thái trắng, nằm giữa cánh đồng lúa Mường Thanh. Trải nghiệm ngủ nhà sàn, ăn xôi nếp nương, tham gia múa xòe và nghe đàn tính. Lựa chọn độc đáo cho khách muốn kết hợp lịch sử và văn hóa bản địa.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '034b400e-8151-4d2e-a6a5-a6637362acce', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Nhà nghỉ Điện Biên', 'guesthouse',
  None, NULL, 'Trung tâm TP. Điện Biên Phủ, tỉnh Điện Biên',
  ARRAY['wifi', 'điều hòa', 'lễ tân'], 'Nhà nghỉ bình dân trung tâm thành phố, phù hợp cho phượt thủ và khách du lịch tiết kiệm. Giá cả phải chăng, vị trí thuận tiện đi bộ đến nhiều di tích lịch sử.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '53233acf-3c5b-4d67-bd00-6b02634a6c09', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Khách sạn Điện Biên Phủ', 'hotel',
  2, NULL, 'TP. Điện Biên Phủ, tỉnh Điện Biên',
  ARRAY['wifi', 'điều hòa', 'nhà hàng nhỏ'], 'Khách sạn 2 sao quen thuộc của khách nội địa, vị trí trung tâm, giá bình dân. Phù hợp đoàn thể đi tham quan di tích với ngân sách hạn chế.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '948c5212-bfa5-4ded-a3c5-fed87f3b92cb', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Melia Vinpearl Đồng Nai', 'resort',
  5, NULL, 'Khu đô thị Amata, Long Bình, TP. Biên Hòa, Đồng Nai',
  ARRAY['hồ bơi ngoài trời', 'spa', 'nhà hàng', 'phòng gym', 'wifi miễn phí', 'bãi đỗ xe', 'dịch vụ đưa đón'], 'Khu nghỉ dưỡng 5 sao cao cấp trong khuôn viên đô thị Amata, Biên Hòa. Thiết kế hiện đại với hồ bơi rộng lớn, spa đầy đủ dịch vụ và nhà hàng quốc tế. Phù hợp doanh nhân và gia đình muốn nghỉ dưỡng gần TP.HCM.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'b1ea1592-de8d-4aad-912e-f03d5cd496b1', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Merperle Crystal Palace Biên Hòa', 'hotel',
  4, NULL, 'Đường Phạm Văn Thuận, TP. Biên Hòa, Đồng Nai',
  ARRAY['hồ bơi', 'nhà hàng', 'wifi miễn phí', 'bãi đỗ xe', 'phòng hội nghị'], 'Khách sạn 4 sao trung tâm TP. Biên Hòa, dễ dàng di chuyển đến các điểm tham quan trong thành phố. Phòng rộng rãi, nhà hàng phục vụ ẩm thực Việt Nam và Châu Á. Lựa chọn tốt cho khách công vụ và du lịch ngắn ngày.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '7931e8fa-0f80-458f-90c3-53c582d75f0e', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Khách sạn Đồng Nai', 'hotel',
  3, NULL, 'Đường 30 Tháng 4, TP. Biên Hòa, Đồng Nai',
  ARRAY['nhà hàng', 'wifi miễn phí', 'bãi đỗ xe', 'máy lạnh'], 'Khách sạn 3 sao lâu đời tại trung tâm Biên Hòa, gần chợ Biên Hòa và các điểm ăn uống. Phòng sạch sẽ, dịch vụ cơ bản đầy đủ. Lựa chọn tầm trung quen thuộc cho khách trong nước.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '45851fb3-0ebb-488c-97d6-d33713a35829', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Nam Cát Tiên Ecolodge', 'resort',
  None, NULL, 'Trong khuôn viên Vườn Quốc gia Nam Cát Tiên, Huyện Tân Phú, Đồng Nai',
  ARRAY['bao gồm bữa ăn (tuỳ gói)', 'tour quan sát thú ban đêm', 'hướng dẫn viên sinh thái', 'wifi (hạn chế)'], 'Khu lưu trú sinh thái trong lòng Vườn Quốc gia Nam Cát Tiên — trải nghiệm độc nhất vô nhị khi thức dậy giữa tiếng chim hót và rừng nguyên sinh. Các bungalow/nhà gỗ nhỏ gọn, đơn giản nhưng hòa quyện với thiên nhiên. Buổi tối có tour quan sát thú hoang dã bằng đèn pin.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'feae31b5-397c-4af0-884c-6d24b20517ea', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Giang Điền Resort & Camping', 'resort',
  None, NULL, 'Khu du lịch Thác Giang Điền, Xã Giang Điền, Huyện Trảng Bom, Đồng Nai',
  ARRAY['chỗ cắm trại', 'khu BBQ', 'wifi (khu trung tâm)', 'nhà vệ sinh công cộng', 'khu tắm thác'], 'Khu lưu trú kết hợp nghỉ dưỡng và cắm trại ngay tại khu vực thác Giang Điền. Phù hợp nhóm bạn, gia đình muốn nghỉ qua đêm trong thiên nhiên gần TP.HCM. Có khu vực BBQ và nhiều hoạt động ngoài trời.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'b1d789b9-4335-4be6-a003-5e637954781b', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Sofitel Legend Metropole Hanoi', 'hotel',
  5, 6500000, '15 Phố Ngô Quyền, quận Hoàn Kiếm, Hà Nội',
  ARRAY['Hồ bơi', 'Spa', 'Nhà hàng Pháp', 'Gym', 'Wifi miễn phí'], 'Khách sạn lịch sử mang tính biểu tượng từ 1901, kiến trúc Pháp cổ điển, từng đón nhiều nguyên thủ và người nổi tiếng thế giới.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  'ca112e78-eaf7-4aa0-b57a-100e15232f48', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Lotte Hotel Hanoi', 'hotel',
  5, 3200000, '54 Liễu Giai, quận Ba Đình, Hà Nội',
  ARRAY['Hồ bơi trong nhà', 'Spa', 'Đài quan sát', 'Gym', 'Wifi miễn phí'], 'Khách sạn cao tầng hiện đại nằm trong tòa Lotte Center, có đài quan sát Skywalk view toàn cảnh Hà Nội.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '5d8bd421-54a1-4eb2-b7fc-d0d3f4f56187', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Hanoi La Siesta Hotel & Spa (Phố cổ)', 'hotel',
  4, 1800000, 'Phố Mã Mây, quận Hoàn Kiếm, Hà Nội',
  ARRAY['Spa', 'Nhà hàng tầng thượng', 'Wifi miễn phí', 'Đưa đón sân bay (phụ phí)'], 'Khách sạn boutique nằm giữa lòng phố cổ, gần Hồ Gươm và khu ăn đêm Tạ Hiện, phong cách Đông Dương.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '9ed8694d-5d22-48e8-bbb3-89af4d3b223c', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Hanoi Backpackers Hostel', 'hostel',
  None, 250000, 'Khu vực phố cổ, quận Hoàn Kiếm, Hà Nội',
  ARRAY['Phòng dorm có máy lạnh', 'Khu sinh hoạt chung', 'Wifi miễn phí', 'Tour ghép đoàn'], 'Hostel phổ biến với khách du lịch backpacker, không gian giao lưu sôi động, tổ chức tour/pub crawl.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '1a615d22-360e-49ea-b7a2-5f1feaf02945', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Hanoi Old Quarter Homestay', 'homestay',
  None, 450000, 'Gần phố Hàng Bạc, quận Hoàn Kiếm, Hà Nội',
  ARRAY['Bếp chung', 'Wifi miễn phí', 'Chủ nhà hỗ trợ tư vấn lịch trình'], 'Homestay nhỏ, ấm cúng, phù hợp khách muốn trải nghiệm gần gũi văn hóa địa phương ngay trong phố cổ.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eedf6-c8b1-77eb-a86a-785755b065b0', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Sheraton Nha Trang Hotel & Spa', 'hotel',
  5, NULL, '26-28 Trần Phú, TP. Nha Trang, Khánh Hòa',
  ARRAY['Hồ bơi vô cực', 'Spa', 'Nhà hàng', 'Phòng gym', 'Bãi đỗ xe', 'WiFi miễn phí', 'Bar rooftop'], 'Khách sạn 5 sao nằm ngay mặt tiền đường Trần Phú, view biển trực tiếp. Hồ bơi vô cực tầng cao nổi bật, spa đẳng cấp và nhà hàng hải sản cao cấp. Vị trí trung tâm, đi bộ đến biển và các nhà hàng dễ dàng.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eedf6-c8b1-7009-9869-70938ea22af8', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Vinpearl Resort & Spa Nha Trang Bay', 'resort',
  5, NULL, 'Đảo Hòn Tre, TP. Nha Trang, Khánh Hòa',
  ARRAY['Hồ bơi riêng', 'Bãi biển riêng', 'Spa', 'Golf', 'Nhà hàng đa ẩm thực', 'Vé cáp treo', 'WiFi'], 'Resort 5 sao trên đảo Hòn Tre, di chuyển bằng cáp treo hoặc tàu cao tốc. Bãi biển riêng yên tĩnh, cách xa khu du lịch đông đúc. Gói nghỉ dưỡng thường bao gồm vé vào Vinpearl Land — phù hợp cho gia đình.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eedf6-c8b1-702f-82f5-1b140cf1bbfb', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Novotel Nha Trang', 'hotel',
  4, NULL, '50 Trần Phú, TP. Nha Trang, Khánh Hòa',
  ARRAY['Hồ bơi ngoài trời', 'Nhà hàng', 'Bar', 'Phòng gym', 'WiFi miễn phí', 'Dịch vụ đưa đón sân bay'], 'Khách sạn 4 sao quốc tế nằm trên đường Trần Phú, ngay sát biển. Thiết kế hiện đại, phòng rộng rãi với nhiều phòng có ban công view biển. Dịch vụ chuẩn quốc tế, phù hợp du lịch công vụ và nghỉ dưỡng.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eedf6-c8b1-77e4-a590-c65f660518b2', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Sun River Nha Trang Hotel', 'hotel',
  3, NULL, 'Khu vực trung tâm TP. Nha Trang, Khánh Hòa',
  ARRAY['WiFi miễn phí', 'Điều hòa', 'Nhà hàng', 'Lễ tân 24/7'], 'Khách sạn 3 sao tầm trung nằm gần trung tâm, phù hợp cho khách du lịch tiết kiệm vẫn muốn vị trí thuận tiện. Phòng sạch sẽ, nhân viên thân thiện, gần các điểm ăn uống và chợ đêm.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eedf6-c8b1-78ae-b82c-2f09395f2ece', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'La Mer Homestay Nha Trang', 'homestay',
  None, NULL, 'Khu vực gần biển Nha Trang, Khánh Hòa',
  ARRAY['WiFi miễn phí', 'Bếp dùng chung', 'Sân thượng'], 'Homestay nhỏ gần biển phù hợp cho khách du lịch trẻ, nhóm bạn hoặc solo traveler muốn trải nghiệm không gian gần gũi, tiết kiệm chi phí. Chủ nhà am hiểu địa phương, sẵn sàng tư vấn điểm đến.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee06-3f91-768f-9249-b6d38342a711', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Caravelle Saigon', 'hotel',
  5, NULL, '19-23 Công trường Lam Sơn, Phường Bến Nghé, Quận 1, TP. HCM',
  ARRAY['hồ bơi', 'spa', 'nhà hàng', 'bar mái', 'phòng gym', 'wifi', 'dịch vụ đưa đón sân bay'], 'Caravelle Saigon là khách sạn 5 sao lịch sử ra đời năm 1959 tại trung tâm Quận 1, ngay cạnh Nhà hát Thành phố. Nổi tiếng với bar Saigon Saigon trên tầng 9 nhìn ra toàn cảnh thành phố — một trong những địa điểm uống thức uống với view đẹp nhất Sài Gòn.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee06-3f91-7b23-ac37-d628425203d1', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Hotel Nikko Saigon', 'hotel',
  5, NULL, '235 Nguyễn Văn Cừ, Phường Nguyễn Cư Trinh, Quận 1, TP. HCM',
  ARRAY['hồ bơi ngoài trời', 'spa', 'nhà hàng Nhật', 'phòng gym', 'wifi', 'trung tâm thương mại ngay dưới'], 'Hotel Nikko Saigon là khách sạn 5 sao phong cách Nhật Bản tọa lạc trên đường Nguyễn Văn Cừ, nổi tiếng với dịch vụ chăm sóc tỉ mỉ theo phong cách omotenashi. Phòng rộng rãi, nhà hàng đa dạng và vị trí gần các điểm mua sắm trung tâm.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee06-3f91-7d1f-bbed-db572f618040', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Rex Hotel Saigon', 'hotel',
  4, NULL, '141 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. HCM',
  ARRAY['hồ bơi mái', 'nhà hàng', 'bar', 'wifi', 'trung tâm tiệc cưới'], 'Rex Hotel là khách sạn 4 sao mang đậm dấu ấn lịch sử Sài Gòn từ thập niên 1960. Nằm trên phố đi bộ Nguyễn Huệ sầm uất, khách sạn có vườn thượng uyển ngoài trời và bar mái nổi tiếng. Là lựa chọn lý tưởng cho du khách muốn trải nghiệm không khí Sài Gòn cổ điển kết hợp tiện nghi hiện đại.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee06-3f91-71af-aaa9-76dff9405217', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Liberty Central Saigon Citypoint', 'hotel',
  4, NULL, '59-61 Pasteur, Phường Nguyễn Thái Bình, Quận 1, TP. HCM',
  ARRAY['hồ bơi', 'phòng gym', 'nhà hàng', 'bar', 'wifi'], 'Liberty Central Citypoint là khách sạn 4 sao tầm trung cao cấp tại Quận 1, được đánh giá tốt về tỷ lệ giá/chất lượng. Vị trí thuận tiện di chuyển bộ đến các điểm tham quan chính như Chợ Bến Thành, Nhà thờ Đức Bà. Phù hợp cho cả khách công tác lẫn du lịch.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();
INSERT INTO hotels (id, destination_id, name, type, stars, price_per_night, address, amenities, description, image_url, booking_url, is_active) VALUES (
  '019eee06-3f91-74d9-a826-c3474ca5b2c0', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Mango Backpackers Hostel', 'hostel',
  None, NULL, 'Khu Phạm Ngũ Lão, Quận 1, TP. HCM',
  ARRAY['wifi', 'bar', 'tour booking', 'máy lạnh', 'két sắt'], 'Nằm trong khu phố Tây Phạm Ngũ Lão sôi động, Mango Backpackers là lựa chọn phổ biến cho du khách trẻ và phượt thủ ngân sách thấp. Khu vực này tập trung nhiều hostel, nhà hàng quốc tế, quán bar và đại lý tour giá rẻ — lý tưởng để kết nối với các traveler khác.',
  NULL, NULL, TRUE
) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, address=EXCLUDED.address, amenities=EXCLUDED.amenities, updated_at=NOW();