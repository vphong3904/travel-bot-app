-- PDTrip – Seed: Transport

INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'e80f9ecb-5e74-5caa-a746-284a28130940', '019eee7d-cd94-744b-86d1-ca07059a9949', 'airplane', 'TP.HCM (TSN), Hà Nội (NIO), Đà Nẵng, Cần Thơ và các TP lớn',
  '~55 phút từ TP.HCM; ~2h từ Hà Nội', '800.000–2.500.000đ/chiều (ƯỚC TÍNH, biến động mạnh theo mùa)',
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'], 'Sân bay Phú Quốc quốc tế (PQC) cách trung tâm Dương Đông ~10km. Là cách di chuyển phổ biến nhất. Nên đặt sớm 2–4 tuần trong mùa cao điểm (Tết, hè).', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '5606c362-052b-59c9-b36f-9acbd732bffc', '019eee7d-cd94-744b-86d1-ca07059a9949', 'ferry', 'Rạch Giá (Kiên Giang) hoặc Hà Tiên',
  '~2h15 từ Rạch Giá; ~45 phút từ Hà Tiên (tàu cao tốc)', '200.000–350.000đ/người (ƯỚC TÍNH)',
  ARRAY['Superdong', 'Phú Quốc Express', 'Tàu Ngọc Thành'], 'Phà chạy nhiều chuyến/ngày, nhưng mùa mưa (tháng 6–10) sóng to có thể hủy chuyến. Nên kiểm tra trước khi đặt vé.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '449b5c51-f37b-586f-8108-5f2d9f63a25e', '019eee7d-cd94-744b-86d1-ca07059a9949', 'bus_combined', 'TP.HCM (xe khách đến Rạch Giá/Hà Tiên, sau đó đi phà)',
  '~6–8 giờ tổng (xe + phà)', '300.000–500.000đ/người tổng (ƯỚC TÍNH)',
  ARRAY['Xe khách Phương Trang (Futa)', 'Kumho Samco'], 'Lựa chọn tiết kiệm nhất cho khách từ TP.HCM. Nhiều hãng có combo xe + phà. Không phù hợp trẻ nhỏ hoặc người say tàu xe.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'd1adeb36-023b-5fb4-ba19-dda54ab0724c', '019eee7d-cd94-744b-86d1-ca07059a9949', 'private_car', 'TP.HCM hoặc Cần Thơ',
  '~4–5 giờ đến Hà Tiên + 45 phút phà', NULL,
  ARRAY['Dịch vụ thuê xe tư nhân'], 'Phù hợp nhóm đông (4–7 người) chia tiền. Linh hoạt dừng dọc đường tham quan.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'cada8fe9-9730-57c0-a97f-52f5a54d4c41', '019eee7d-cd94-744b-86d1-ca07059a9949', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Cách di chuyển phổ biến và tiện nhất trên đảo. Nhiều điểm cho thuê ở Dương Đông và gần sân bay. Cần bằng lái A1 và đội mũ bảo hiểm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'f43e8cee-38e4-5164-83ee-2b10425f8e0e', '019eee7d-cd94-744b-86d1-ca07059a9949', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Có taxi Mai Linh và Sao Vàng hoạt động trên đảo. Giá thường cao hơn đất liền. Nên chốt giá trước với taxi không đồng hồ.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '9f50ee9c-ee90-5094-bd4f-240c20e1e3ca', '019eee7d-cd94-744b-86d1-ca07059a9949', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab có hoạt động tại Phú Quốc nhưng coverage không đều như TP.HCM. Khu Dương Đông và Bãi Trường dễ đặt hơn, khu xa đảo khó.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '0b4a0d69-a7f4-5a02-9c10-ce88cf108356', '019eee7d-cd94-744b-86d1-ca07059a9949', 'xe_dien_golf', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe điện golf carts có trong một số resort lớn (Vinpearl, JW Marriott) để di chuyển nội khu.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'a0d35f24-2dae-5312-a460-f3750b34d18e', '019eee7d-cd94-744b-86d1-ca07059a9949', 'bicycle', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phù hợp tham quan khu trung tâm Dương Đông và bãi biển gần. Không phù hợp cho các tuyến xa (Bãi Dài, Vườn Quốc gia) vì đường xa và nắng nóng.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '0f6b6354-fb8d-59db-b3c8-34ad3cacc7dd', '019eee7d-cd94-744b-86d1-ca07059a9949', 'bus_noi_dao', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Hiện tại Phú Quốc chưa có hệ thống xe buýt công cộng nội đảo hoàn chỉnh. Một số tuyến trung chuyển sân bay có hoạt động theo giờ.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '28fbf841-0a60-594b-b34d-4f77ed1fb7a1', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'bus', 'Hà Nội (Bến xe Gia Lâm)',
  '45–60 phút', '15.000–20.000đ (tham khảo — xác nhận tại nhà xe)',
  ARRAY['Xe buýt tuyến 204 (Transerco)', 'Xe buýt tuyến 203'], 'Tuyến 204 xuất phát từ Bến xe Gia Lâm, tần suất khoảng 20–30 phút/chuyến. Đây là phương tiện rẻ nhất và phổ biến nhất cho khách từ Hà Nội.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'cd45e6d3-32be-54ba-971b-563d4e8ad800', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'bus', 'Hà Nội (Bến xe Mỹ Đình)',
  '60–90 phút (tùy tắc đường)', NULL,
  ARRAY['Các hãng xe khách liên tỉnh'], 'Có xe khách từ Bến xe Mỹ Đình đến Bắc Ninh. Phù hợp cho khách ở phía Tây Hà Nội. Xác nhận giờ và giá tại bến xe.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'ee9b81b8-2ae5-5ac8-b6b1-632979908389', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'car', 'Hà Nội (nội thành)',
  '30–60 phút (tùy điểm xuất phát và giờ đi)', '150.000–300.000đ (taxi/Grab — ước tính)',
  ARRAY['Grab', 'Be', 'Taxi truyền thống'], 'Đi theo Quốc lộ 1A hoặc đường cao tốc Hà Nội–Bắc Ninh. Tắc đường vào giờ cao điểm và dịp cuối tuần lễ hội. Thuê xe tự lái hoặc có tài xế cũng là lựa chọn tiện.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '4e1293c9-2f3b-54f5-8a16-d7a19f0ecdc8', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'motorbike', 'Hà Nội (nội thành)',
  '40–60 phút', NULL,
  ARRAY[]::TEXT[], 'Nhiều bạn trẻ và du khách tự lái xe máy từ Hà Nội. Đi theo đường Yên Viên qua cầu Đuống hoặc cầu Chui. Phù hợp thời tiết đẹp, không nên đi mùa mưa hay đêm muộn.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'e1f8b74b-82ac-5228-b1c8-5b3c5d992972', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab hoạt động tại thành phố Bắc Ninh và các thị xã lớn. Tiện lợi nhất cho di chuyển giữa các điểm tham quan trong nội thành. Ít xe hơn Hà Nội nên đặt trước 5–10 phút.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '7e3cc692-a056-5bda-bad4-5dc0dd7cf749', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe ôm truyền thống có ở bến xe, gần chợ và khu trung tâm. Thỏa thuận giá trước khi đi. Phù hợp cho quãng đường ngắn trong thị trấn.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '321abcc6-8e63-5715-abfc-61b8e1efef6a', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Taxi địa phương (Taxi Bắc Ninh, Taxi Mai Linh...) có mặt khắp thành phố. Nên bắt taxi có đồng hồ tính tiền hoặc thỏa thuận giá từ đầu.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '829f5773-b7ab-5d30-bdce-ceb1d5ab14ea', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe máy rất phù hợp để khám phá các làng nghề và di tích nằm rải rác (Đông Hồ, Phù Lãng, chùa Dâu, chùa Bút Tháp). Hỏi khách sạn để giới thiệu điểm thuê uy tín.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'c4ee5c0d-f4bb-5dc8-92b1-6b4aae29c138', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'bicycle', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Đạp xe phù hợp trong khu vực huyện Thuận Thành (cụm chùa Dâu–Bút Tháp) vì đường làng bằng phẳng, ít xe. Hỏi thuê tại các homestay hoặc nhà nghỉ địa phương.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '99a8bb8d-c89a-51da-b0fd-b3ab68f07b7d', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'bus', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Có xe buýt nội tỉnh kết nối các huyện trong Bắc Ninh, nhưng tần suất thấp và không thuận tiện cho du khách. Chỉ dùng khi không có lựa chọn khác.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'f554056e-d31b-5a4a-ac6e-3ff31951f32b', '23431b56-3e63-4368-949f-8df24ab3c539', 'airplane', 'TP. Hồ Chí Minh (Tân Sơn Nhất)',
  '~1 giờ bay', NULL,
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'], 'Sân bay Cà Mau (CAH) cách trung tâm thành phố khoảng 2km. Đây là phương tiện nhanh nhất để vào Cà Mau. Nên đặt vé trước ít nhất 1–2 tuần vào mùa cao điểm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'f953d9b6-8c99-57ad-bbda-2c9175bbfdcb', '23431b56-3e63-4368-949f-8df24ab3c539', 'bus', 'TP. Hồ Chí Minh (bến xe Miền Tây)',
  '~7–9 giờ', NULL,
  ARRAY['Phương Trang (FUTA)', 'Kumho Samco', 'Hạnh Café'], 'Xe giường nằm chạy ban đêm phổ biến và tiết kiệm. Nhiều chuyến khởi hành 19:00–21:00 từ bến xe Miền Tây, đến Cà Mau lúc 4:00–6:00 sáng hôm sau.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '7c2348ca-71bf-5317-ba11-3f93e6b87c8e', '23431b56-3e63-4368-949f-8df24ab3c539', 'bus', 'Cần Thơ',
  '~3–4 giờ', NULL,
  ARRAY['Phương Trang', 'xe khách địa phương'], 'Tuyến phổ biến cho du khách transit qua Cần Thơ. Nhiều chuyến trong ngày.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'e65756a1-10ea-5a9e-b6d5-f6dc7023e13e', '23431b56-3e63-4368-949f-8df24ab3c539', 'car', 'TP. Hồ Chí Minh',
  '~5–6 giờ (cao tốc)', NULL,
  ARRAY['Tự lái', 'Dịch vụ xe thuê'], 'Quốc lộ 1A và cao tốc Trung Lương–Mỹ Thuận–Cao Lãnh rút ngắn đáng kể thời gian. Qua phà Năm Căn nếu vào Đất Mũi.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '1145f31a-2e81-522f-bde1-186b6edb4116', '23431b56-3e63-4368-949f-8df24ab3c539', 'boat', 'Năm Căn → Đất Mũi',
  '~1,5 giờ', NULL,
  ARRAY['Tàu cao tốc Năm Căn', 'Tàu địa phương'], 'Đây là đoạn bắt buộc phải đi đường thủy để vào Đất Mũi — không có đường bộ đến tận cùng. Trải nghiệm thú vị qua rừng đước bạt ngàn.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '694a37e5-90ed-5964-a3a3-b7a16a6d923d', '23431b56-3e63-4368-949f-8df24ab3c539', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phương tiện linh hoạt nhất để khám phá TP. Cà Mau và vùng ven. Thuê tại các cửa hàng gần trung tâm hoặc hỏi khách sạn giới thiệu. Cần bằng lái A1/A2.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'c5dafa8d-d8b3-5361-99a2-75a9496e0b6e', '23431b56-3e63-4368-949f-8df24ab3c539', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Taxi Mai Linh hoạt động tại TP. Cà Mau. Phù hợp cho di chuyển trong nội thành và ra sân bay.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '1dd8f639-dc66-5d86-a01e-8079c6fe7262', '23431b56-3e63-4368-949f-8df24ab3c539', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab xe máy và Grab car hoạt động tại TP. Cà Mau. Không phủ sóng ở các huyện xa như Năm Căn, Ngọc Hiển.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'a4e8055a-22b0-5643-9c2b-096afdf7ab06', '23431b56-3e63-4368-949f-8df24ab3c539', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe ôm truyền thống vẫn phổ biến ở các huyện xa. Thỏa thuận giá trước khi lên xe.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '46fed980-34d2-5602-b123-64ac60acfec6', '23431b56-3e63-4368-949f-8df24ab3c539', 'bus', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe buýt nội đô hạn chế. Chủ yếu tuyến TP. Cà Mau – Năm Căn và một số tuyến liên huyện. Không phủ các điểm du lịch chính.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '842707f9-620e-5cc0-ac68-54e3ad252ecd', '23431b56-3e63-4368-949f-8df24ab3c539', 'bicycle', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Một số homestay và khách sạn cho thuê xe đạp để dạo quanh khu trung tâm hoặc rừng U Minh (địa hình bằng phẳng).', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '799243d1-735f-5f1e-af40-50aa8f5cb43a', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'airplane', 'Hà Nội (nội địa, quá cảnh TP.HCM hoặc bay thẳng)',
  '~2 giờ bay + di chuyển từ sân bay (~30 phút về trung tâm)', NULL,
  ARRAY['Vietnam Airlines', 'VietJet Air', 'Bamboo Airways'], 'Sân bay Cần Thơ (VCA) nằm cách trung tâm khoảng 10km. Bay thẳng Hà Nội – Cần Thơ có sẵn. Từ sân bay về trung tâm bắt taxi hoặc Grab (~100.000–150.000đ). Xác nhận giá vé tại Traveloka hoặc Vexere.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '5cc18318-db4b-51e7-ac8a-d77f9f7531fb', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'bus', 'TP.HCM (Bến xe Miền Tây)',
  '~3,5–4 giờ', NULL,
  ARRAY['Phương Trang (FUTA)', 'Thuận Thảo', 'Hoàng Long'], 'Tuyến xe khách Sài Gòn – Cần Thơ chạy liên tục từ sáng đến tối. Phương Trang có xe giường nằm và ghế ngồi. Tiện nhất, giá rẻ nhất cho chuyến đi từ TP.HCM. Xác nhận giá tại Vexere.com.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'e18cfb2d-92b1-5934-a76e-3284dc6cbcb1', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'boat', 'TP.HCM (Bến Bạch Đằng)',
  '~3,5 giờ', NULL,
  ARRAY['Công ty TNHH Greenlines DP', 'Tàu cao tốc Cần Thơ Express'], 'Tàu cao tốc xuất phát buổi sáng sớm, ngắm cảnh sông nước đặc sắc. Lịch tàu ít hơn xe khách. Xác nhận giá và lịch tàu tại Traveloka hoặc trực tiếp hãng trước khi đi.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'fc321150-3448-5b33-91ea-103b48ad3ef5', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'car', 'TP.HCM (cao tốc TP.HCM – Cần Thơ)',
  '~2,5–3 giờ (tùy giao thông)', NULL,
  ARRAY['Tự lái', 'Thuê xe 4 chỗ có tài xế'], 'Đường cao tốc TP.HCM – Trung Lương – Mỹ Thuận – Cần Thơ đã thông tuyến hoàn chỉnh. Phí cầu đường khoảng 80.000–120.000đ/lượt (xác nhận mức phí thực tế). Thuê xe tự lái hoặc có tài xế từ Traveloka hoặc các hãng địa phương.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '9619a679-2976-51f9-a4b4-29bfb4380dde', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab hoạt động tốt trong nội ô Cần Thơ. Tiện nhất cho di chuyển giữa các điểm tham quan trung tâm. Grab Boat cũng có tại một số bến.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '7fcb6c97-e8b2-5872-84bc-834ab2fb8337', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Taxi Mai Linh và Vinasun hoạt động tại Cần Thơ. Nên đặt qua app hoặc gọi tổng đài tránh taxi dù.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'b124129d-b256-57b2-8c4a-625a3fb313d5', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe máy khoảng 100.000–150.000đ/ngày (xác nhận giá tại các cửa hàng cho thuê gần bến Ninh Kiều). Cần bằng lái xe máy. Phù hợp để khám phá các khu ngoại ô như Phong Điền, Cái Răng.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'fe06e7c1-e77e-59fd-ae78-7467fe1e29ab', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe ôm truyền thống vẫn còn hoạt động, đặc biệt ở khu chợ và bến xe. Thỏa thuận giá trước khi đi.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '71c7adea-1099-5548-a2f6-0b535ac2dd21', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'bicycle', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Một số khách sạn và homestay cho thuê xe đạp miễn phí hoặc giá thấp. Phù hợp để khám phá khu vực vườn trái cây Phong Điền và các làng ven kênh. Không thích hợp cho khoảng cách dài trong nội ô.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '61602a3d-b4c9-5f8d-af49-79a8e99ffa48', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'boat', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xuồng ba lá và thuyền máy là phương tiện đặc trưng của Cần Thơ. Đặt tour thuyền từ bến Ninh Kiều để đi chợ nổi Cái Răng, kênh rạch. Giá tour từ bến khoảng 150.000–300.000đ/người (xác nhận tại bến Ninh Kiều).', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '3e45b6de-afb6-5e94-91c9-e9ee8d922cf2', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'bus', 'Hà Nội (bến xe Mỹ Đình)',
  'Khoảng 7–9 tiếng', '// TODO: xác nhận tại Traveloka hoặc nhà xe Hoàng Long, Kumho Samco',
  ARRAY['Hoàng Long', 'Kumho Samco', 'các nhà xe địa phương'], 'Tuyến xe khách phổ biến nhất đi Cao Bằng. Có xe giường nằm chạy ban đêm. Đường đèo Mã Phục và đèo Giàng khá quanh co — người say xe nên uống thuốc trước.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'bdfe71f4-2a01-5c3d-8a3d-4392d06651d1', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'car', 'Hà Nội',
  'Khoảng 5–6 tiếng (tự lái theo Quốc lộ 3)', '// TODO: tùy thuê xe tự lái hoặc thuê lái xe',
  ARRAY['Tự lái', 'Thuê xe có lái tại Hà Nội'], 'Đi theo Quốc lộ 3 qua Thái Nguyên, Bắc Kạn. Đoạn đèo vào Cao Bằng khá dốc và quanh co. Nên xuất phát sớm trước 6:00 để tránh tắc và còn sáng khi qua đèo.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'd3891f60-26e1-5084-b0d6-cfebfc8d8239', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'motorbike', 'Hà Nội hoặc Lạng Sơn',
  'Từ Hà Nội ~6–8 tiếng, từ Lạng Sơn ~3–4 tiếng', NULL,
  ARRAY['Tự đi xe cá nhân', 'Phượt đoàn'], 'Tuyến yêu thích của phượt thủ — phong cảnh đường đèo rất đẹp. Nên chuẩn bị xe tốt vì đường đèo dốc. Mùa đông có sương mù dày, cần cẩn thận.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '2d1dfd20-48e7-5f4b-9db6-c8e20fad4c86', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'bus', 'Lạng Sơn',
  'Khoảng 3–4 tiếng', '// TODO: xác nhận tại bến xe Lạng Sơn',
  ARRAY['Xe khách địa phương Lạng Sơn–Cao Bằng'], 'Tuyến ngắn hơn từ Lạng Sơn, thuận tiện nếu kết hợp hành trình Đông Bắc.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'f1cb23ff-07fb-55b4-ae0d-622cdd639f27', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phương tiện lý tưởng nhất để khám phá Cao Bằng. Đường đến thác Bản Giốc (~90km từ TP), hang Pác Bó (~60km) đều cần xe máy hoặc ô tô riêng. Thuê xe tại các khách sạn hoặc điểm cho thuê trên phố.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '7ba71f34-17f0-5ab5-865b-255d2ed95ee0', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Có taxi tại TP. Cao Bằng, nhưng ít phổ biến. Nên thỏa thuận giá trước cho các chuyến đi xa đến thác Bản Giốc hay Pác Bó.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'bb3e0415-2de2-54a9-b0a6-b3a16276d068', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab hoạt động hạn chế hoặc không có tại Cao Bằng — nên xác nhận trước khi đến và chuẩn bị phương án dự phòng.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '9535e384-0134-5ad5-b04d-010e158e9ab1', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe ôm truyền thống sẵn có tại bến xe và chợ TP. Cao Bằng. Hữu ích cho di chuyển ngắn trong thành phố.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'cef19f25-2593-5dde-9f32-49d3f6182033', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'car', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe ô tô 4 chỗ hoặc 7 chỗ có lái là lựa chọn tốt cho gia đình hoặc nhóm đông muốn đi Bản Giốc và Pác Bó trong 2 ngày. Có thể đặt qua khách sạn.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'ac6d97d7-2f11-5ee7-9248-c13f662b141b', '44444444-4444-4444-4444-444444444444', 'airplane', 'Hà Nội',
  '~1,5 giờ bay đến sân bay quốc tế Đà Nẵng (DAD)', NULL,
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'], 'Sân bay Đà Nẵng cách phố cổ Hội An ~30km, đi taxi/Grab khoảng 40–50 phút.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '34013709-be4a-576f-9a0e-f0e00b978d46', '44444444-4444-4444-4444-444444444444', 'airplane', 'TP. Hồ Chí Minh',
  '~1 giờ bay đến sân bay quốc tế Đà Nẵng (DAD)', NULL,
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways', 'Vietravel Airlines'], 'Tần suất chuyến bay nhiều, đặc biệt cao điểm hè và lễ — nên đặt trước.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '6a3c1f19-66e0-5597-9608-b12d4be7509f', '44444444-4444-4444-4444-444444444444', 'train', 'Hà Nội / TP. Hồ Chí Minh',
  'Tàu Bắc–Nam dừng tại ga Đà Nẵng, thời gian tùy điểm xuất phát (khoảng 14–20 giờ)', NULL,
  ARRAY['Đường sắt Việt Nam (Vietnam Railways)'], 'Phù hợp khách muốn ngắm cảnh dọc đường, đặc biệt đoạn đèo Hải Vân; mất nhiều thời gian hơn máy bay.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '8e869d75-0a33-5295-bf8a-6b61e35c532d', '44444444-4444-4444-4444-444444444444', 'bus', 'Huế',
  '~2,5–3 giờ bằng xe khách hoặc xe limousine', NULL,
  ARRAY['Các hãng xe limousine tuyến Huế–Đà Nẵng–Hội An'], 'Tuyến phổ biến cho khách kết hợp tham quan Huế, đi qua đèo Hải Vân với cảnh biển đẹp.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'b5189917-80f7-5c45-b4d8-0dd1e5420703', '44444444-4444-4444-4444-444444444444', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phổ biến tại Đà Nẵng, ít xe hơn ở khu phố cổ Hội An do hạn chế xe cơ giới vào một số giờ.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '4b23a7a6-a3af-5704-bed1-b79e431c8859', '44444444-4444-4444-4444-444444444444', 'bicycle', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phương tiện đặc trưng nhất tại phố cổ Hội An — nhỏ gọn, phù hợp đường hẹp cấm ô tô.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'ec295536-4111-541e-9585-e3eeb2f09f8f', '44444444-4444-4444-4444-444444444444', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Linh hoạt nhất để di chuyển giữa Đà Nẵng và Hội An hoặc lên bán đảo Sơn Trà; cần có giấy phép lái xe hợp lệ.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '5a4b18ec-e5c3-5f56-93ab-25bd9b031d5e', '44444444-4444-4444-4444-444444444444', 'walking', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Khu phố cổ Hội An nhỏ, đi bộ là cách tốt nhất để khám phá chi tiết kiến trúc cổ.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'd6f9e39b-86e1-5b50-a531-76dd03c2cbf6', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'airplane', 'TP. Hồ Chí Minh',
  'Khoảng 1 giờ', 'Khoảng 580.000–1.000.000đ/chiều (Vietjet/Traveloka, 06/2026 — biến động theo thời điểm đặt)',
  ARRAY['Vietnam Airlines', 'Vietjet Air'], 'Sân bay Buôn Ma Thuột (BMV) cách trung tâm thành phố khoảng 8km, mất khoảng 15–20 phút di chuyển vào trung tâm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'e8a144a1-567e-54b9-990b-1babc0d8f762', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'airplane', 'Hà Nội',
  'Khoảng 1 giờ 45 phút', 'Khoảng 599.000–900.000đ/chiều (Vietjet, 06/2026 — biến động theo thời điểm đặt)',
  ARRAY['Vietnam Airlines', 'Vietjet Air'], 'Khai thác khoảng 3 chuyến/ngày từ sân bay Nội Bài — xác nhận lịch bay thực tế trước khi đặt vì có thể thay đổi theo mùa.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '03ba70dc-73c4-5d53-a276-626b35070be1', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'airplane', 'Đà Nẵng',
  'Khoảng 55 phút – 1 giờ 10 phút', NULL,
  ARRAY['Vietnam Airlines'], 'Chuyến bay thẳng hiện chỉ khai thác khoảng 1–2 chuyến/ngày vào một số ngày trong tuần — xác nhận lịch bay cụ thể trước khi đặt.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '1838dc55-3a0c-5821-b4f3-3527872d4135', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'bus', 'TP. Hồ Chí Minh',
  'Khoảng 8–9 giờ (đường bộ ~350km)', 'Khoảng 300.000–400.000đ/chiều (theo Vexere & VnExpress, 06/2026 — biến động theo nhà xe và thời điểm)',
  ARRAY['Các hãng xe khách như Kumho Samco và nhiều nhà xe tuyến TP.HCM – Buôn Ma Thuột'], 'Nhiều xe khởi hành buổi tối để sáng hôm sau có mặt tại Buôn Ma Thuột, phù hợp tiết kiệm thời gian ban ngày.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '6480909a-825d-5d67-a99b-557b7a7ccdaa', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Các hãng taxi phổ biến: Mai Linh, Quyết Tiến, Tây Nguyên, Ban Mê Xanh, Đắk Lắk Taxi.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '7ecf7583-5f14-5cc0-9fe2-9c91631f8b15', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe công nghệ (Grab, Xanh SM, Be, GoJek) ngày càng phổ biến tại Buôn Ma Thuột, đặt qua app tiện lợi với giá cước minh bạch.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '290a859a-5c4f-5b4a-9bad-18f6ea7453ce', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phù hợp di chuyển nhanh quãng đường ngắn trong nội thành, nên thỏa thuận giá trước khi đi nếu không qua app.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '645933b4-063d-50eb-909f-ef1b5b9e16fa', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe máy là lựa chọn linh hoạt để di chuyển tới các điểm xa trung tâm như thác Dray Nur, Buôn Đôn, Yok Đôn — nên hỏi thuê tại các khách sạn hoặc cửa hàng cho thuê xe ở trung tâm thành phố.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'd686d423-b32d-5be9-bf8c-dba295d7bb92', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'bus', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Có một số tuyến xe buýt nội tỉnh (ví dụ tuyến số 13 đi hướng Krông Nô để tới khu vực thác Dray Nur), nhưng mạng lưới xe buýt chưa phát triển rộng — phù hợp cho người có nhiều thời gian và muốn tiết kiệm chi phí.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '196f83e1-6197-5fd6-8087-0e364461a6ef', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'flight', 'Hà Nội (Nội Bài)',
  'Khoảng 55–65 phút', '// TODO: xác nhận tại Vietnam Airlines hoặc Traveloka — giá thay đổi theo mùa',
  ARRAY['Vietnam Airlines'], 'Tuyến bay nhanh nhất và thuận tiện nhất. Sân bay Điện Biên Phủ cách trung tâm thành phố khoảng 2km. Lưu ý: tải trọng hành lý có thể bị giới hạn hơn do loại máy bay nhỏ (ATR72). Đặt vé sớm vào mùa cao điểm (tháng 4–5, dịp 7/5).', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '6e4d4915-9ff6-5566-ac49-a6aca9ff3c07', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'bus', 'Hà Nội (bến xe Mỹ Đình)',
  'Khoảng 10–12 tiếng', '// TODO: xác nhận tại Traveloka hoặc nhà xe địa phương',
  ARRAY['Điện Biên Express', 'các nhà xe địa phương'], 'Có xe giường nằm chạy ban đêm từ Mỹ Đình — xuất phát tối, đến sáng sớm. Đường đèo qua Sơn La và Tuần Giáo khá quanh co — người say xe cần uống thuốc. Thích hợp khách ít thời gian hoặc muốn tiết kiệm chi phí.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'a026f683-d0fe-5d58-8428-d95650e62187', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'car', 'Hà Nội',
  'Khoảng 7–9 tiếng (tự lái theo QL6)', '// TODO: tùy thuê xe hoặc tự lái',
  ARRAY['Tự lái', 'Thuê xe có lái tại Hà Nội'], 'Đi theo Quốc lộ 6 qua Hòa Bình, Sơn La, Tuần Giáo. Phong cảnh rất đẹp nhưng đường đèo dài và mệt — nên có 2 người thay nhau lái. Xuất phát trước 5:00 sáng để đến trước tối.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '1ecb1be1-db49-5978-81a3-78f3c0dc1a56', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'motorbike', 'Hà Nội hoặc Sơn La',
  'Từ Hà Nội ~2 ngày (qua đêm Sơn La), từ Sơn La ~4–5 tiếng', NULL,
  ARRAY['Tự đi xe cá nhân', 'Phượt đoàn'], 'Hành trình phượt đèo huyền thoại qua đèo Pha Đin — một trong tứ đại đỉnh đèo Tây Bắc. Chỉ phù hợp người có kinh nghiệm lái đèo. Đường đèo Pha Đin dài ~32km với nhiều khúc cua tay áo.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'c1955872-3307-5a2a-b00b-12740f267219', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Lý tưởng để khám phá cánh đồng Mường Thanh và các bản Thái quanh thành phố. Các di tích lịch sử tập trung khá gần nhau trong bán kính ~5km — có thể đi xe máy dễ dàng. Thuê tại khách sạn hoặc các điểm cho thuê trên phố.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'ead2233e-6a08-51ce-8255-a7dda7ed6f3f', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Taxi có sẵn tại TP. Điện Biên Phủ. Thỏa thuận giá trước cho các chuyến dài ra ngoài thành phố. Có thể đặt taxi trọn ngày để đi các di tích — hỏi khách sạn để giới thiệu lái xe tin cậy.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '2a270517-5ed3-5f7b-a4c1-8cc705c82c86', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe ôm có tại bến xe và trung tâm thành phố. Hữu ích cho di chuyển ngắn trong thành phố. Thỏa thuận giá rõ ràng trước khi đi.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'a00f6f99-407a-5d65-9827-2746cf1d20da', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab hoạt động hạn chế hoặc không có tại Điện Biên Phủ — không nên phụ thuộc vào ứng dụng gọi xe. Chuẩn bị số điện thoại taxi địa phương.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '266c9761-91f9-5bf0-9f77-ef17caaf68c8', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'car', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe 4–7 chỗ có lái phù hợp gia đình hoặc nhóm muốn đi tất cả các di tích trong 1 ngày và kết hợp thăm bản Thái ngoại ô. Đặt qua khách sạn hoặc công ty lữ hành địa phương.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '62146853-c68d-5787-8232-b20fecd66a82', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'bus', 'TP.HCM (Bến xe Miền Đông / Bến xe An Sương)',
  '~1–1,5 giờ đến Biên Hòa', NULL,
  ARRAY['Phương Trang (FUTA)', 'Thành Bưởi', 'xe buýt liên tỉnh'], 'Tuyến TP.HCM – Biên Hòa chạy liên tục và thường xuyên, là tuyến đường phổ biến nhất. Ngoài ra có xe khách đi các huyện xa hơn như Tân Phú (gần Nam Cát Tiên). Xác nhận giá tại Vexere.com.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '2c68c745-a148-5adc-a270-64f2414b8335', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'train', 'TP.HCM (Ga Sài Gòn)',
  '~1 giờ đến Ga Biên Hòa', NULL,
  ARRAY['VR (Đường sắt Việt Nam)'], 'Tàu lửa TP.HCM – Biên Hòa là tuyến tàu ngắn tiện lợi, giá rẻ. Ga Biên Hòa nằm trung tâm thành phố. Đặt vé tại dsvn.vn hoặc ứng dụng VR.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '5e8f8e5e-8003-5b4d-bed1-e676ef97a46a', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'car', 'TP.HCM (đường cao tốc TP.HCM – Long Thành – Dầu Giây)',
  '~45 phút đến Biên Hòa, ~2,5–3 giờ đến Nam Cát Tiên', NULL,
  ARRAY['Tự lái', 'Grab Car', 'xe thuê có tài xế'], 'Cao tốc TP.HCM – Long Thành – Dầu Giây kết nối nhanh. Từ ngã tư Dầu Giây đi thêm ~1,5 giờ lên Nam Cát Tiên theo đường tỉnh. Phí cao tốc xác nhận tại trạm thu phí.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '60782f68-3a21-5fdf-a6d0-e4399d21bd17', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'bus', 'Hà Nội (xe khách giường nằm qua đêm)',
  '~30 giờ (qua đêm)', NULL,
  ARRAY['Phương Trang', 'Hoàng Long', 'các hãng giường nằm'], 'Tuyến Hà Nội – Biên Hòa qua đêm. Thực tế hầu hết du khách từ miền Bắc sẽ bay vào TP.HCM rồi đi tiếp. Xác nhận lịch tại Vexere.com.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'a6435420-f41c-58de-852c-6cf6af75fdf1', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab hoạt động đầy đủ tại TP. Biên Hòa và các thị trấn lớn. Tiện nhất cho di chuyển nội ô. Không có sẵn tại Nam Cát Tiên — cần thuê xe riêng.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '90cf4420-4716-5497-bea9-5088282c55ec', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Taxi Mai Linh và Vinasun hoạt động tại Biên Hòa. Gọi qua app hoặc tổng đài. Không có ở các huyện xa như Tân Phú.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '325092bc-dc5e-572e-909d-68067820bc18', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe máy tại Biên Hòa và gần các khu du lịch. Phù hợp tham quan Vĩnh Cửu, Trảng Bom, Long Thành. Không nên đi xe máy lên Nam Cát Tiên vì đường dài và có thể nguy hiểm ban đêm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'e77c8d8d-62ac-5bc4-977d-7f38a825fbe5', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'car_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe 4–7 chỗ có tài xế là phương án tốt nhất cho nhóm đi Nam Cát Tiên hoặc vùng Bình Phước cũ (Bù Gia Mập). Đặt qua Traveloka hoặc các hãng địa phương tại Biên Hòa.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '17ab7bd2-35a2-5606-a8de-d1b0a9d18982', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe ôm truyền thống vẫn phổ biến ở các chợ, bến xe. Thỏa thuận giá trước. Ở khu vực nông thôn xa đôi khi là lựa chọn duy nhất.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '81af2c72-52ab-5713-8f09-81e7d705e0d1', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'boat', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuyền câu cá và du thuyền trên hồ Trị An — thuê tại các điểm ven hồ khu vực Vĩnh Cửu. Không có dịch vụ phà/tàu định kỳ.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'c71b81c2-9ddb-5c4f-ac36-17d101388fe7', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'airplane', 'TP.HCM, Đà Nẵng, các tỉnh trong nước',
  '~2 giờ (từ TP.HCM)', '1.000.000–2.500.000đ (khứ hồi, ước tính)',
  ARRAY['Vietnam Airlines', 'Vietjet', 'Bamboo Airways'], 'Sân bay quốc tế Nội Bài (HAN), cách trung tâm ~30km.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '08f77192-3508-5ae1-bae2-8fa265e88a9e', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'train', 'Các tỉnh phía Bắc, Bắc Trung Bộ',
  'Tùy tuyến (vd Hà Nội–Lào Cai ~8 giờ)', '150.000–800.000đ tùy tuyến/loại ghế (ước tính)',
  ARRAY['Đường sắt Việt Nam'], 'Ga Hà Nội (ga Hàng Cỏ) là đầu mối chính.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '9acf760a-a233-5b7b-bf72-ffd0d9e98bd0', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'bus', 'Các tỉnh thành trên cả nước',
  'Tùy khoảng cách', '100.000–500.000đ (ước tính)',
  ARRAY['Nhà xe Hoàng Long', 'Nhà xe limousine các tuyến'], 'Các bến chính: Mỹ Đình, Giáp Bát, Nước Ngầm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'aad63bfc-fb35-5210-ba31-1c5b4a0c131c', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phổ biến nhất, đặt qua app.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '46cde30e-3a1c-514b-9973-e746c192bcef', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Taxi truyền thống (Mai Linh, G7...) hoặc gọi qua app.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'd7454f76-2d73-5cce-973a-0ea7884fdf9c', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Nên chốt giá trước khi đi nếu không qua app.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'b2de406b-f770-5604-830d-8ce49ac1b1f9', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'bus', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Mạng lưới xe buýt công cộng rộng, giá rẻ nhưng cần biết tuyến.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '7de594df-d051-57cc-ade8-ed21c13678ef', '019eed69-50b1-7455-bdfa-2e98ab743e96', 'walking', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Khu phố cổ và quanh Hồ Gươm rất phù hợp đi bộ khám phá.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'ad9e3737-50ce-5d2e-9efd-5f6dac4cd176', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'airplane', 'Hà Nội (Nội Bài)',
  '2 giờ 10 phút', 'Xác nhận tại Traveloka hoặc Vietnam Airlines — dao động theo thời điểm đặt',
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'], 'Sân bay Cam Ranh cách trung tâm Nha Trang khoảng 30km. Có xe bus và taxi ra trung tâm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '3e2aad14-f528-5660-afda-8c8e9fe7a3a8', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'airplane', 'TP. Hồ Chí Minh (Tân Sơn Nhất)',
  '1 giờ 10 phút', 'Xác nhận tại Traveloka — thường có vé giá rẻ trên các chặng ngắn',
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'], 'Chặng ngắn, nhiều chuyến mỗi ngày. Thuận tiện nhất từ TP.HCM.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '37d85e1e-35f2-5c10-9091-d7a3dfe39af3', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'train', 'Hà Nội',
  'Khoảng 24–27 giờ', 'Xác nhận tại dsvn.vn hoặc 12go.asia — có ghế nằm điều hòa',
  ARRAY['Đường sắt Việt Nam (VNR)'], 'Chặng dài nhưng phong cảnh đẹp qua duyên hải miền Trung. Đặt vé trước tại dsvn.vn.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '561e9666-10f4-5ce7-9894-fbafedccff8f', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'train', 'TP. Hồ Chí Minh',
  'Khoảng 6–8 giờ', 'Xác nhận tại dsvn.vn',
  ARRAY['Đường sắt Việt Nam (VNR)'], 'Phương án tốt nếu không muốn bay. Ga Nha Trang nằm gần trung tâm thành phố.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '4774f7ae-cf18-5adb-87a1-0ddd8e8a7eb5', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'bus', 'TP. Hồ Chí Minh',
  '10–12 giờ', 'Xác nhận tại nhà xe hoặc Vexere.com',
  ARRAY['Phương Trang (FUTA)', 'Thành Bưởi', 'Hoàng Long'], 'Xe limousine giường nằm chạy ban đêm, tiết kiệm một đêm khách sạn. Đặt trước qua Vexere.com.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '632585fe-c5c3-53f8-922e-36a20c3fa19b', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'bus', 'Đà Nẵng',
  '7–8 giờ', 'Xác nhận tại Vexere.com hoặc nhà xe trực tiếp',
  ARRAY['Phương Trang (FUTA)', 'các nhà xe địa phương'], 'Tuyến duyên hải, qua nhiều thành phố ven biển.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '4ddcb61c-1c7a-5f7d-8552-7300cd515fde', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phương tiện thuận tiện nhất cho khách du lịch. Trả tiền qua app hoặc tiền mặt.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '4b24b1b9-2b22-5467-9565-c67a036ba495', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Chọn hãng taxi có đồng hồ (Mai Linh, Vinasun). Tránh taxi dù không rõ nguồn gốc.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '58431c65-ecc8-5205-90ab-209c37ba6b2f', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phổ biến ở các khu vực chưa có Grab. Thỏa thuận giá trước khi đi.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '0104d5bd-8414-5dab-9385-5785dbedf915', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phù hợp cho người có bằng lái và quen đường. Tự do khám phá ngoại ô và các làng chài. Kiểm tra kỹ xe trước khi thuê.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'ee881759-4b20-5d12-9af7-e5945cd44607', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'bicycle', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Phù hợp đi dọc đường Trần Phú ven biển sáng sớm hoặc chiều mát. Không khuyến khích giờ cao điểm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '0d872eaf-071f-5419-bba2-eaa9cb7c9678', '019eed69-50b3-743c-b2d0-2107e58ca38d', 'bus', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe buýt nội thành chạy các tuyến chính. Thời gian không ổn định, phù hợp người không vội.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'b42b4826-8a92-57eb-b4c1-044564e5a335', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'airplane', 'Hà Nội (Nội Bài)',
  'Khoảng 2 tiếng', NULL,
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways', 'Vietravel Airlines'], 'Sân bay Tân Sơn Nhất (SGN) cách trung tâm Quận 1 khoảng 7–10km. Có taxi, Grab và xe buýt sân bay về trung tâm.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '856210a6-debe-51b4-8c7e-b24ba2f3675b', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'airplane', 'Đà Nẵng',
  'Khoảng 1 tiếng 20 phút', NULL,
  ARRAY['Vietnam Airlines', 'Vietjet Air', 'Bamboo Airways'], 'Bay thẳng, tần suất nhiều chuyến mỗi ngày.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'a1e55685-09e4-5470-a3ae-2a1c2d20bded', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'train', 'Hà Nội (ga Hà Nội)',
  'Khoảng 30–33 tiếng (tàu SE)', NULL,
  ARRAY['Đường sắt Việt Nam (DSVN)'], 'Có nhiều loại ghế: ngồi cứng, ngồi mềm, nằm cứng, nằm mềm điều hòa. Tàu SE3/SE4 nhanh nhất. Ga Sài Gòn tại Quận 3.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'c7567757-ac69-5170-8f25-ebf8900afbce', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'bus', 'Cần Thơ',
  'Khoảng 3–4 tiếng', NULL,
  ARRAY['Phương Trang (FUTA)', 'Kumho Samco', 'Thành Bưởi'], 'Xe limousine và xe ghế ngồi đều có. Bến xe Miền Tây là điểm đến chính khi từ miền Tây về TPHCM.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '41d0a216-475a-527c-a999-57eee4a33461', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'bus', 'Đà Lạt (Lâm Đồng)',
  'Khoảng 7–8 tiếng', NULL,
  ARRAY['Phương Trang (FUTA)', 'Thành Bưởi', 'Kumho Samco'], 'Có xe giường nằm và xe limousine. Bến xe Miền Đông là điểm đến khi từ miền Trung, Tây Nguyên.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '15174dd9-f913-5d92-a8a9-22ac942623a3', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'grab', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Grab xe máy (GrabBike) và Grab ô tô (GrabCar) là lựa chọn phổ biến và an toàn nhất cho khách du lịch. Giá minh bạch, không cần mặc cả. Phủ sóng toàn thành phố.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '2aec8dba-10a9-57af-83aa-02bdfc2826ea', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'taxi', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Hãng taxi uy tín: Vinasun (logo xanh lá), Mai Linh (logo xanh dương). Tránh taxi không thương hiệu hoặc không đồng hồ tính tiền. Luôn yêu cầu bật đồng hồ.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'f65063cc-cad0-5f8c-95db-26d3f08afc00', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'xe_om', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe ôm truyền thống còn phổ biến ở các chợ, bến xe. Cần mặc cả và thỏa thuận giá trước. Xe ôm công nghệ (Grab/Be) an toàn và thuận tiện hơn.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '6e66a755-f286-5900-8e69-2a25f9dbb526', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'bus', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Mạng lưới xe buýt phủ rộng nhưng giờ giấc không ổn định và khó tra cứu cho người lạ. Phù hợp cho người có thời gian và muốn tiết kiệm tối đa. Tra cứu tuyến tại buyttphcm.com.vn.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  'f29d52d6-6901-568f-a690-42d902558d8a', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'motorbike_rental', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Thuê xe máy phổ biến với phượt thủ có kinh nghiệm. Khu Phạm Ngũ Lão (Quận 1) có nhiều shop cho thuê. Cần bằng lái xe máy hợp lệ. Giao thông TPHCM đông đúc và phức tạp — không khuyến khích người chưa quen.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();
INSERT INTO transport_options (id, destination_id, type, from_location, duration, price_range, providers, notes, is_active) VALUES (
  '87bbadb5-c4b9-5da5-8ca9-9ef46a8b6965', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'bicycle', '',
  NULL, NULL,
  ARRAY[]::TEXT[], 'Xe đạp điện và xe đạp chia sẻ đang mở rộng tại TPHCM. Thích hợp khám phá các khu vực trong Quận 1-3. Không phù hợp giờ cao điểm do giao thông đông.', TRUE
) ON CONFLICT (id) DO UPDATE SET notes=EXCLUDED.notes, updated_at=NOW();