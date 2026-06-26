-- ============================================================
-- PDTrip – Seed FULL: destinations từ knowledge-base (35 cities)
-- ============================================================

INSERT INTO categories (id, name, slug, icon, description) VALUES
  ('c1111111-1111-1111-1111-111111111111','Biển & Đảo','beach','beach_access','Điểm đến ven biển, hải đảo'),
  ('c2222222-2222-2222-2222-222222222222','Núi & Cao nguyên','mountain','terrain','Trekking, leo núi, khí hậu mát mẻ'),
  ('c3333333-3333-3333-3333-333333333333','Nghỉ dưỡng','resort','spa','Resort, spa, thư giãn cao cấp'),
  ('c4444444-4444-4444-4444-444444444444','Phiêu lưu','adventure','hiking','Cắm trại, motor, kayak, leo núi'),
  ('c5555555-5555-5555-5555-555555555555','Ẩm thực','food','restaurant','Khám phá đặc sản địa phương'),
  ('c6666666-6666-6666-6666-666666666666','Văn hóa & Lịch sử','culture','museum','Di sản, đền chùa, bảo tàng'),
  ('c7777777-7777-7777-7777-777777777777','Thiên nhiên','nature','forest','Rừng, thác, hang động'),
  ('c8888888-8888-8888-8888-888888888888','Chụp ảnh','photography','camera','Phong cảnh đẹp, check-in'),
  ('c9999999-9999-9999-9999-999999999999','Gia đình','family','family_restroom','Phù hợp cả gia đình'),
  ('caaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','Cao cấp','luxury','diamond','Trải nghiệm sang trọng 5 sao')
ON CONFLICT (id) DO NOTHING;

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eee7d-cd94-744b-86d1-ca07059a9949', 'Phú Quốc', 'an-giang-phu-quoc', 'An Giang',
  'Đồng bằng sông Cửu Long', 'Đảo ngọc lớn nhất Việt Nam với bãi biển trong xanh, hải sản tươi sống và các khu nghỉ dưỡng cao cấp.', 'Đảo ngọc với biển xanh và resort cao cấp',
  'Tháng 11–4 (mùa khô, biển êm)', ARRAY[11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng ẩm, 25–32°C, mùa mưa tháng 5–10 có bão nhẹ', 'Hải sản, nước mắm Phú Quốc, gỏi cá trích, nhum nướng mỡ hành',
  3000000, 8000000, 'https://cdn.pdtrip.vn/destinations/phuquoc.jpg',
  4.7, 150,
  0, 6000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Bắc Ninh', 'bac-ninh', 'Bắc Ninh',
  'Đồng bằng sông Hồng', 'Quê hương quan họ với chùa Dâu, chùa Bút Tháp và làng nghề gốm Phù Lãng, tranh Đông Hồ; sau sáp nhập còn có vùng đồi núi Bắc Giang với Tây Yên Tử, vườn vải thiều Lục Ngạn.', 'Cái nôi của dân ca Quan họ và hệ thống chùa cổ, làng nghề truyền thống',
  'Tháng 9–11 hoặc Tháng 1–3 (mùa hội chùa, hát quan họ)', ARRAY[9, 10, 11, 1, 2, 3]::SMALLINT[],
  '4 mùa rõ rệt, nóng ẩm mùa hè, lạnh khô mùa đông 10–18°C', 'Bánh phu thê Đình Bảng, nem Bùi, bánh tro, rượu làng Vân',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '23431b56-3e63-4368-949f-8df24ab3c539', 'Cà Mau', 'ca-mau', 'Cà Mau',
  'Đồng bằng sông Cửu Long', 'Điểm cực Nam đất nước với Mũi Cà Mau, rừng ngập mặn U Minh Hạ và hệ sinh thái đước bạt ngàn; sau sáp nhập còn có cánh đồng điện gió Bạc Liêu và nhà Công tử Bạc Liêu.', 'Mũi Cà Mau — điểm cực Nam Tổ quốc, nơi ''đất biết nở, rừng biết đi và biển biết sinh sôi''',
  'Tháng 12–4 (mùa khô)', ARRAY[12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng ẩm 25–34°C quanh năm, mùa mưa tháng 5–11', 'Cua Cà Mau, ba khía, cá thòi lòi, mắm ong rừng U Minh',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Cần Thơ', 'can-tho', 'Cần Thơ',
  'Đồng bằng sông Cửu Long', 'Thủ phủ miền Tây với chợ nổi Cái Răng, vườn trái cây và hệ thống kênh rạch sông nước; sau sáp nhập còn có chùa Dơi và lễ hội Óoc Om Bóc của Sóc Trăng, cùng vùng sông nước Hậu Giang với chợ nổi Ngã Bảy.', 'Chợ nổi Cái Răng — nét văn hóa sông nước đặc trưng miền Tây Nam Bộ',
  'Tháng 12–4 (mùa khô) hoặc mùa nước nổi Tháng 9–11', ARRAY[12, 1, 2, 3, 4, 9, 10, 11]::SMALLINT[],
  'Nóng ẩm 25–34°C, mùa nước nổi tháng 9–11', 'Bánh xèo miền Tây, lẩu mắm, nem nướng Cái Răng, cá lóc nướng trui',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Cao Bằng', 'cao-bang', 'Cao Bằng',
  'Trung du và miền núi phía Bắc', 'Vùng biên giới với thác Bản Giốc, hồ Thang Hen và hang Pác Bó gắn liền lịch sử cách mạng.', 'Thác Bản Giốc hùng vĩ và hồ Thang Hen xanh ngọc giữa núi đá vôi',
  'Tháng 8–10 (thác nhiều nước) hoặc Tháng 3–5', ARRAY[8, 9, 10, 3, 4, 5]::SMALLINT[],
  'Mát mẻ 15–28°C, lạnh về đêm mùa đông, có thể có sương giá', 'Bánh cuốn Cao Bằng, hạt dẻ Trùng Khánh, vịt quay 7 vị, miến lươn',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '44444444-4444-4444-4444-444444444444', 'Hội An', 'da-nang-hoi-an', 'Đà Nẵng',
  'Bắc Trung Bộ', 'Phố cổ di sản UNESCO với kiến trúc cổ kính, đèn lồng rực rỡ và ẩm thực đường phố nổi tiếng.', 'Phố cổ di sản UNESCO và lễ hội đèn lồng rực rỡ',
  'Tháng 2–4 (khô, mát, ít mưa)', ARRAY[2, 3, 4]::SMALLINT[],
  'Nóng vào hè (28–35°C), mùa mưa bão tháng 9–12', 'Cao lầu, mì Quảng, cơm gà, bánh mì Phượng, bánh bao bánh vạc',
  1000000, 3500000, 'https://cdn.pdtrip.vn/destinations/hoian.jpg',
  4.6, 110,
  0, 5500, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Buôn Ma Thuột', 'dak-lak-buon-ma-thuot', 'Đắk Lắk',
  'Duyên hải Nam Trung Bộ và Tây Nguyên', 'Thủ phủ cà phê Tây Nguyên với hồ Lắk, thác Dray Nur và voi nhà Bản Đôn; sau sáp nhập còn có vùng biển Phú Yên với Gành Đá Đĩa, Mũi Điện.', 'Thủ phủ cà phê Việt Nam, gắn liền văn hóa cưỡi voi và cồng chiêng',
  'Tháng 11–4 (mùa khô)', ARRAY[11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Mát mẻ 18–30°C mùa khô, mùa mưa tháng 5–10', 'Cà phê Buôn Ma Thuột, bún đỏ, gà nướng Bản Đôn, cơm lam',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Điện Biên Phủ', 'dien-bien-dien-bien-phu', 'Điện Biên',
  'Trung du và miền núi phía Bắc', 'Vùng đất lịch sử với chiến thắng Điện Biên Phủ 1954, đồi A1, hầm Đờ Cát và cánh đồng Mường Thanh.', 'Di tích lịch sử chiến thắng Điện Biên Phủ và cánh đồng Mường Thanh rộng lớn',
  'Tháng 10–4 (khô, mát)', ARRAY[10, 11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Mát mẻ 15–28°C, mùa mưa tháng 5–9', 'Xôi nếp nương, gà bản, cá suối nướng, rượu Mường Ảng',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Đồng Nai', 'dong-nai', 'Đồng Nai',
  'Đông Nam Bộ', 'Vườn quốc gia Nam Cát Tiên với hệ sinh thái rừng nguyên sinh và thác Giang Điền gần TP.HCM; sau sáp nhập còn có vùng biên giới Bình Phước với vườn quốc gia Bù Gia Mập, thác Đứng Gió.', 'Vườn quốc gia Nam Cát Tiên — khu dự trữ sinh quyển thế giới',
  'Tháng 12–4 (mùa khô, dễ trekking)', ARRAY[12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng ẩm 25–34°C, mùa mưa tháng 5–11', 'Gỏi cá Biên Hòa, bưởi Tân Triều, dế chiên, lẩu cá kèo',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eee23-1730-7352-8c9a-09c5b0bed755', 'Đồng Tháp', 'dong-thap', 'Đồng Tháp',
  'Đồng bằng sông Cửu Long', 'Tỉnh sông nước miệt vườn sau sáp nhập Đồng Tháp và Tiền Giang, nổi tiếng với Đồng Tháp Mười, vườn quốc gia Tràm Chim, làng hoa Sa Đéc và các cù lao trái cây dọc sông Tiền (Tiền Giang cũ) như Cù lao Thới Sơn, chợ nổi Cái Bè.', 'Vườn quốc gia Tràm Chim — khu Ramsar đất ngập nước, sếu đầu đỏ; Làng hoa Sa Đéc; Cù lao Thới Sơn (Tiền Giang cũ) — du lịch sinh thái miệt vườn',
  'Tháng 12–4 (mùa khô); tháng 9–11 mùa nước nổi Đồng Tháp Mười đặc trưng', ARRAY[12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng ẩm 25–34°C quanh năm, mùa nước nổi tháng 9–11, mùa mưa tháng 5–11', 'Hủ tiếu Sa Đéc, cá lóc nướng trui, bông điên điển, chuột đồng, kẹo dừa và mắm còng (Tiền Giang cũ)',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eeda8-d830-762e-8f70-18a66f56fa5c', 'Pleiku', 'gia-lai-pleiku', 'Gia Lai',
  'Tây Nguyên', 'Cao nguyên núi lửa với Biển Hồ T''Nưng, đồi chè và văn hóa cồng chiêng Tây Nguyên; sau sáp nhập còn có vùng biển Bình Định với Quy Nhơn, Eo Gió, Kỳ Co.', 'Biển Hồ T''Nưng — miệng núi lửa cổ được mệnh danh "mắt ngọc Tây Nguyên"',
  'Tháng 11–4 (mùa khô, trời mát, ít mưa)', ARRAY[11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Mát mẻ quanh năm 18–28°C nhờ độ cao, mùa mưa tháng 5–10', 'Phở khô Gia Lai (phở hai tô), cơm lam gà nướng, măng le, cà phê Tây Nguyên',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b1-7455-bdfa-2e98ab743e96', 'Hà Nội', 'ha-noi', 'Hà Nội',
  'Đồng bằng sông Hồng', 'Thủ đô ngàn năm văn hiến với 36 phố phường cổ, Hồ Gươm, Văn Miếu - Quốc Tử Giám, kiến trúc Pháp thuộc địa và ẩm thực đường phố phong phú bậc nhất Việt Nam.', 'Phố cổ Hà Nội 36 phường, Hồ Gươm Tháp Rùa, Văn Miếu UNESCO, phở Hà Nội, bún chả Obama',
  'Tháng 9–11 (thu vàng) và tháng 3–4 (hoa sưa, hoa ban)', ARRAY[9, 10, 11, 3, 4]::SMALLINT[],
  '4 mùa rõ rệt, 15–38°C, mùa đông lạnh ẩm 10–18°C (tháng 12–2), mùa hè nóng ẩm', 'Phở Hà Nội, bún chả, chả cá Lã Vọng, bánh cuốn, bún ốc, cà phê trứng, xôi xéo',
  1000000, 3000000, 'https://cdn.pdtrip.vn/destinations/hanoi.jpg',
  4.8, 5200,
  0, 180000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-774a-83ca-b8e9b4965dcb', 'Thiên Cầm', 'ha-tinh-thien-cam', 'Hà Tĩnh',
  'Bắc Trung Bộ', 'Bãi biển Thiên Cầm ẩn mình dưới chân núi với nước biển xanh trong, cát vàng mịn, bãi đá san hô tự nhiên, không khí yên bình và hải sản tươi ngon ít bị thương mại hóa.', 'Bãi biển yên bình ít đông đúc, núi Nam Giới, hang động ven biển, hải sản tươi nguyên bản',
  'Tháng 4–8 (nắng đẹp, ít gió)', ARRAY[4, 5, 6, 7, 8]::SMALLINT[],
  'Nóng 28–36°C mùa hè, gió Lào khô tháng 6–7, mưa bão tháng 8–10', 'Cá rô sông La, hàu Thiên Cầm, mực ống nướng, bún bò Hà Tĩnh, cháo hàu, cam bù Hương Khê',
  600000, 1800000, 'https://cdn.pdtrip.vn/destinations/thiencam.jpg',
  4.2, 480,
  0, 18000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7d7e-876d-39fc6f6a1674', 'Cát Bà', 'hai-phong-cat-ba', 'Hải Phòng',
  'Đồng bằng sông Hồng', 'Đảo lớn nhất vịnh Hạ Long với vườn quốc gia nguyên sinh, bãi biển Cát Cò trong xanh, làng chài bè cá nổi và cửa ngõ khám phá quần thể Hạ Long - Bái Tử Long hùng vĩ.', 'Vườn quốc gia Cát Bà, bãi Cát Cò 1-2-3, khỉ đầu vàng Cát Bà đặc hữu, kayak trong hang động',
  'Tháng 4–9 (biển đẹp, tắm được)', ARRAY[4, 5, 6, 7, 8, 9]::SMALLINT[],
  'Ấm nóng 20–32°C, mùa hè đẹp, mưa bão tháng 7–9, đông lạnh sương mù', 'Cá hấp gừng Cát Bà, hải sản tươi sống, sam biển rang muối, cua biển hấp bia, bề bề nướng',
  1500000, 4000000, 'https://cdn.pdtrip.vn/destinations/catba.jpg',
  4.6, 2100,
  0, 72000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-73da-a651-2515b15db7c2', 'Huế', 'hue', 'Huế',
  'Bắc Trung Bộ', 'Cố đô triều Nguyễn với Hoàng thành Huế — Di sản Văn hóa Thế giới UNESCO, hệ thống lăng tẩm, chùa chiền, ẩm thực cung đình tinh tế và dòng sông Hương thơ mộng.', 'Hoàng thành Huế UNESCO, lăng Tự Đức, chùa Thiên Mụ, Festival Huế 2 năm/lần, ẩm thực cung đình',
  'Tháng 1–4 và tháng 8–9 (tránh mùa mưa tháng 10–12)', ARRAY[1, 2, 3, 4, 8, 9]::SMALLINT[],
  'Nhiệt đới gió mùa, 20–35°C, mưa nhiều tháng 10–12, nóng nhất tháng 6–8', 'Bún bò Huế, cơm hến, bánh khoái, nem lụi, bánh bèo, chè Huế đa dạng, bánh ướt thịt nướng',
  1200000, 3500000, 'https://cdn.pdtrip.vn/destinations/hue.jpg',
  4.7, 3500,
  0, 110000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7d56-b86a-8abd90d35197', 'Hưng Yên', 'hung-yen', 'Hưng Yên',
  'Đồng bằng sông Hồng', 'Xứ nhãn lồng nổi tiếng với phố Hiến — một trong tứ đại đô thị cổ Việt Nam, hệ thống đền chùa cổ kính và đặc sản nhãn lồng Hưng Yên ngọt thơm bậc nhất cả nước.', 'Nhãn lồng Hưng Yên đặc sản nổi tiếng, phố Hiến cổ, đền Mây, chùa Chuông, Văn Miếu Xích Đằng',
  'Tháng 7–8 (mùa nhãn chín) và tháng 9–11 (khí hậu mát)', ARRAY[7, 8, 9, 10, 11]::SMALLINT[],
  '4 mùa rõ rệt, 17–36°C, nóng ẩm mùa hè, lạnh khô mùa đông', 'Nhãn lồng Hưng Yên, bánh cuốn chả, tương bần, cá kho làng Vũ Dương, bánh gai, con don',
  500000, 1500000, 'https://cdn.pdtrip.vn/destinations/hungyen.jpg',
  4.2, 620,
  0, 22000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-743c-b2d0-2107e58ca38d', 'Nha Trang', 'khanh-hoa-nha-trang', 'Khánh Hòa',
  'Duyên hải Nam Trung Bộ và Tây Nguyên', 'Thành phố biển sầm uất với 6km bãi biển cát trắng trải dài, hải sản phong phú, đảo san hô đa dạng và khu nghỉ dưỡng quốc tế — thủ đô biển đảo của Việt Nam.', 'Vinpearl Land, lặn ngắm san hô 4 đảo, tháp Chăm Ponagar, suối khoáng bùn I-Resort',
  'Tháng 1–8 (nắng đẹp, biển lặng)', ARRAY[1, 2, 3, 4, 5, 6, 7, 8]::SMALLINT[],
  'Nắng nóng 25–34°C, mùa mưa tháng 9–12 có bão, biển động', 'Bún cá Nha Trang, nem nướng Ninh Hòa, hải sản tươi sống, bánh căn, yến sào Khánh Hòa',
  2000000, 6000000, 'https://cdn.pdtrip.vn/destinations/nhatrang.jpg',
  4.6, 3800,
  0, 130000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7c74-b810-8e00d38b1805', 'Lai Châu', 'lai-chau', 'Lai Châu',
  'Trung du và miền núi phía Bắc', 'Tỉnh vùng cao biên giới phía Tây Bắc với đỉnh Pu Si Lung cao thứ 2 Việt Nam, thác Tác Tình hùng vĩ, ruộng bậc thang Bản Bo và văn hóa dân tộc Thái, Mảng, Hà Nhì nguyên bản.', 'Đỉnh Pu Si Lung 3.076m cao thứ 2 VN, thác Tác Tình, ruộng bậc thang Bản Bo, chợ phiên dân tộc',
  'Tháng 9–10 (ruộng bậc thang vàng) và tháng 3–5 (hoa ban trắng)', ARRAY[9, 10, 3, 4, 5]::SMALLINT[],
  'Mát lạnh 12–28°C, sương mù buổi sáng, mưa nhiều tháng 6–8, lạnh tháng 12–2', 'Cá bống vùi tro Lai Châu, pa pính tộp (cá nướng), thịt trâu gác bếp, rượu sán lùng, nậm pịa',
  1500000, 4000000, 'https://cdn.pdtrip.vn/destinations/laichau.jpg',
  4.4, 680,
  0, 28000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7d37-b71a-93a9a778c50c', 'Đà Lạt', 'lam-dong-da-lat', 'Lâm Đồng',
  'Duyên hải Nam Trung Bộ và Tây Nguyên', 'Thành phố ngàn hoa trên cao nguyên Lâm Viên 1.500m, nổi tiếng với khí hậu mát mẻ quanh năm, đồi chè xanh mướt, thác nước hùng vĩ và kiến trúc Pháp cổ kính.', 'Khí hậu 15–24°C quanh năm, Festival Hoa tháng 12, đồi chè Cầu Đất, hồ Xuân Hương',
  'Tháng 11–4 (mùa khô, ít mưa)', ARRAY[11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Mát mẻ 15–24°C, mùa mưa tháng 5–10, sương mù buổi sáng', 'Bánh tráng nướng, lẩu gà lá é, sữa đậu nành nóng, dâu tây, atiso, rượu vang Đà Lạt',
  1500000, 4000000, 'https://cdn.pdtrip.vn/destinations/dalat.jpg',
  4.7, 2840,
  0, 95000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7691-995a-bbe5f3404ea8', 'Mũi Né', 'lam-dong-mui-ne', 'Lâm Đồng',
  'Duyên hải Nam Trung Bộ và Tây Nguyên', 'Làng chài ven biển nổi tiếng với đồi cát bay kỳ ảo, bãi biển kite surfing quốc tế, suối Tiên đa màu sắc và hải sản tươi ngon — thiên đường thể thao biển Đông Nam Á.', 'Đồi cát vàng/đỏ kỳ ảo, kite surfing nổi tiếng thế giới, bình minh trên biển, suối Tiên cổ tích',
  'Tháng 11–4 (gió mạnh — mùa kite surfing, nắng đẹp)', ARRAY[11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng nắng 25–35°C, ít mưa nhất cả nước, gió mạnh tháng 11–4 (lý tưởng kite surf)', 'Hải sản Mũi Né, bánh canh chả cá Phan Thiết, nước mắm Phan Thiết, thanh long Bình Thuận, cơm chiên hải sản',
  1500000, 4000000, 'https://cdn.pdtrip.vn/destinations/muine.jpg',
  4.5, 2100,
  0, 75000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7232-b155-10c17a514c3c', 'Lạng Sơn', 'lang-son', 'Lạng Sơn',
  'Trung du và miền núi phía Bắc', 'Tỉnh biên giới phía Bắc với ải Chi Lăng lịch sử, chợ Đông Kinh nhộn nhịp hàng Trung Quốc, động Tam Thanh kỳ ảo, núi Mẫu Sơn có tuyết và văn hóa Tày - Nùng đặc sắc.', 'Núi Mẫu Sơn có tuyết, động Tam Thanh - Nhị Thanh, chợ Đông Kinh hàng biên mậu, ải Chi Lăng',
  'Tháng 9–11 và tháng 12–1 (tuyết Mẫu Sơn, hiếm)', ARRAY[9, 10, 11, 12, 1]::SMALLINT[],
  '4 mùa rõ rệt, 10–32°C, lạnh tháng 12–2, núi Mẫu Sơn có thể có băng tuyết', 'Vịt quay Lạng Sơn, bánh cuốn trứng, khâu nhục, lợn quay, phở chua Lạng Sơn, hồng quân, na Chi Lăng',
  800000, 2500000, 'https://cdn.pdtrip.vn/destinations/langson.jpg',
  4.3, 920,
  0, 35000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7b08-84a7-341ade2c0908', 'Sa Pa', 'lao-cai-sa-pa', 'Lào Cai',
  'Trung du và miền núi phía Bắc', 'Thị trấn sương mù trên độ cao 1.500m với ruộng bậc thang kỳ vĩ, đỉnh Fansipan 3.143m — nóc nhà Đông Dương, cùng văn hóa H''Mông, Dao Đỏ và các bản làng dân tộc đặc sắc.', 'Fansipan nóc nhà Đông Dương, ruộng bậc thang Mù Cang Chải tháng 9–10, chợ phiên Bắc Hà',
  'Tháng 9–10 (ruộng bậc thang vàng) hoặc tháng 3–5 (hoa đào, hoa mận)', ARRAY[9, 10, 3, 4, 5]::SMALLINT[],
  'Mát lạnh 10–22°C, sương mù quanh năm, tuyết rơi dịp Tết âm lịch (hiếm), mưa nhiều tháng 6–8', 'Cá hồi Sa Pa, thịt lợn cắp nách nướng, rau cải mèo xào tỏi, rượu ngô H''Mông, thắng cố, xôi nếp nương',
  2000000, 6000000, 'https://cdn.pdtrip.vn/destinations/sapa.jpg',
  4.7, 3100,
  0, 102000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-75f8-b421-0622df9db573', 'Cửa Lò', 'nghe-an-cua-lo', 'Nghệ An',
  'Bắc Trung Bộ', 'Thị xã biển xứ Nghệ với bãi biển Cửa Lò dài 10km sóng nhỏ, nước trong xanh, hải sản phong phú và không khí bình dân gần gũi — điểm tắm biển phổ biến nhất miền Bắc Trung Bộ.', 'Bãi biển 10km sóng êm lý tưởng cho gia đình, hải sản Cửa Lò nổi tiếng, gần quê Bác Hồ',
  'Tháng 4–8 (mùa hè, biển đẹp nhất)', ARRAY[4, 5, 6, 7, 8]::SMALLINT[],
  'Nóng ẩm 30–38°C mùa hè, gió Lào khô nóng tháng 6–7, mưa bão tháng 9–10', 'Mực khô Cửa Lò, cá thu nướng, hàu sữa, bún bò Vinh, cháo lươn Nghệ An, kẹo cu đơ',
  700000, 2000000, 'https://cdn.pdtrip.vn/destinations/cualo.jpg',
  4.1, 980,
  0, 32000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7f4e-886e-b5d04063fc02', 'Ninh Bình', 'ninh-binh', 'Ninh Bình',
  'Đồng bằng sông Hồng', 'Vùng đất được mệnh danh ''Hạ Long trên cạn'' với quần thể Tràng An — Di sản Thế giới kép UNESCO, cố đô Hoa Lư, chùa Bái Đính lớn nhất Đông Nam Á và đồng lúa Tam Cốc thơ mộng.', 'Tràng An Di sản UNESCO kép, Bái Đính lớn nhất ĐNA, cố đô Hoa Lư, đồng lúa Tam Cốc, đầm Vân Long',
  'Tháng 10–4 (tránh mưa, lúa vàng tháng 10–11)', ARRAY[10, 11, 12, 1, 2, 3, 4]::SMALLINT[],
  '4 mùa rõ rệt, 15–35°C, mưa nhiều tháng 5–9, lạnh tháng 12–2', 'Cơm cháy Ninh Bình, thịt dê núi Ninh Bình, rượu Kim Sơn, cá rô Tổng Trường, miến lươn',
  800000, 2500000, 'https://cdn.pdtrip.vn/destinations/ninhbinh.jpg',
  4.7, 3200,
  0, 98000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7a97-8133-dab596aaf763', 'Phú Thọ', 'phu-tho', 'Phú Thọ',
  'Trung du và miền núi phía Bắc', 'Đất Tổ Hùng Vương linh thiêng với Đền Hùng — nơi thờ các Vua Hùng dựng nước, rừng quốc gia Xuân Sơn, suối khoáng Thanh Thủy và văn hóa đâm trống đồng của người Mường.', 'Đền Hùng di tích quốc gia đặc biệt, Giỗ Tổ Hùng Vương 10/3 âm lịch, vườn quốc gia Xuân Sơn',
  'Tháng 2–4 (lễ hội Giỗ Tổ) và tháng 9–11 (mát mẻ)', ARRAY[2, 3, 4, 9, 10, 11]::SMALLINT[],
  '4 mùa rõ rệt, 15–36°C, mưa nhiều tháng 5–8, lạnh tháng 12–2', 'Thịt chua Thanh Sơn, bánh sắn Phú Thọ, cá anh vũ sông Đà, rượu cần Mường, chè kho, cơm lam',
  600000, 1800000, 'https://cdn.pdtrip.vn/destinations/phutho.jpg',
  4.4, 1100,
  0, 38000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eeda8-d830-7d4c-9ef2-6de207ce2bdb', 'Đảo Lý Sơn', 'quang-ngai-ly-son', 'Quảng Ngãi',
  'Nam Trung Bộ', 'Đảo núi lửa với cánh đồng hành tỏi, vách đá bazan và biển trong xanh ngoài khơi Quảng Ngãi; sau sáp nhập còn có vùng cao nguyên Kon Tum với núi Ngọc Linh, nhà thờ gỗ Kon Tum và văn hóa cồng chiêng Tây Nguyên.', 'Đảo Bé — vịnh nước trong, di tích Hải đội Hoàng Sa Bắc Hải',
  'Tháng 4–8 (biển êm, thuận lợi ra đảo)', ARRAY[4, 5, 6, 7, 8]::SMALLINT[],
  'Nóng ẩm 25–34°C, mùa mưa bão tháng 9–12 — tàu ra đảo có thể tạm ngưng', 'Gỏi tỏi Lý Sơn, don Quảng Ngãi, hải sản tươi, hành tỏi đặc sản',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7f32-bd6d-13f617e17937', 'Vịnh Hạ Long', 'quang-ninh-ha-long', 'Quảng Ninh',
  'Đồng bằng sông Hồng', 'Di sản Thiên nhiên Thế giới UNESCO với hơn 1.969 hòn đảo đá vôi, hang động kỳ ảo, làng chài nổi và vịnh biển xanh ngọc bích — biểu tượng du lịch Việt Nam.', 'Di sản UNESCO 2 lần công nhận, hang Sửng Sốt, đảo Titop, du thuyền nghỉ đêm trên vịnh',
  'Tháng 10–4 (biển lặng, ít mưa)', ARRAY[10, 11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Ấm 20–30°C, mùa hè nóng ẩm có mưa bão (tháng 6–9), đông lạnh có sương mù đẹp', 'Hải sản Hạ Long, sá sùng nướng, chả mực Hạ Long, bề bề rang me, ngán xào tỏi',
  2500000, 8000000, 'https://cdn.pdtrip.vn/destinations/halong.jpg',
  4.8, 4200,
  0, 145000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-79f6-9a6e-66856703829f', 'Quảng Trị', 'quang-tri', 'Quảng Trị',
  'Bắc Trung Bộ', 'Vùng đất lịch sử bi hùng với Thành Cổ Quảng Trị, Nghĩa trang Trường Sơn, sông Bến Hải - cầu Hiền Lương chia đôi đất nước và động Phong Nha - Kẻ Bàng Di sản UNESCO.', 'Thành Cổ Quảng Trị, cầu Hiền Lương - sông Bến Hải, Nghĩa trang Trường Sơn, động Phong Nha - Kẻ Bàng',
  'Tháng 2–8 (tránh mưa lũ tháng 9–11)', ARRAY[2, 3, 4, 5, 6, 7, 8]::SMALLINT[],
  'Nhiệt đới gió mùa, 18–36°C, mưa lũ nặng tháng 9–11, nóng khô gió Lào tháng 5–7', 'Cháo vạt giường Quảng Trị, bún bò Quảng Trị, bánh ướt thịt heo, tré bò, mắm ruốc, bánh nậm',
  800000, 2500000, 'https://cdn.pdtrip.vn/destinations/quangtri.jpg',
  4.4, 890,
  0, 32000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7c76-b437-284592040a13', 'Mộc Châu', 'son-la-moc-chau', 'Sơn La',
  'Trung du và miền núi phía Bắc', 'Cao nguyên Mộc Châu 1.000m xanh mát với đồi chè bát ngát, vườn mận nở trắng tháng 2, đàn bò sữa thư thái, thung lũng Mai Châu thơ mộng và văn hóa Thái trắng nguyên bản.', 'Hoa mận tháng 2 trắng xóa, đồi chè xanh mát, trại bò sữa, thung lũng Mai Châu, dù lượn Mộc Châu',
  'Tháng 1–3 (hoa mận, đào) và tháng 9–11 (mùa vàng lúa, hoa cải)', ARRAY[1, 2, 3, 9, 10, 11]::SMALLINT[],
  'Mát mẻ 15–25°C quanh năm, lạnh tháng 12–1 có sương muối, mưa tháng 6–8', 'Sữa tươi Mộc Châu, lợn cắp nách nướng, thịt trâu gác bếp, rượu táo mèo, cá suối nướng, mận Mộc Châu',
  1200000, 3500000, 'https://cdn.pdtrip.vn/destinations/mocchau.jpg',
  4.6, 1850,
  0, 68000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eeda8-d830-7a83-8b89-527da5de9455', 'Núi Bà Đen', 'tay-ninh-nui-ba-den', 'Tây Ninh',
  'Đông Nam Bộ', 'Ngọn núi cao nhất Nam Bộ với hệ thống cáp treo, tượng Phật Bà và Tòa Thánh Cao Đài nổi tiếng; sau sáp nhập còn có vùng Đồng Tháp Mười thuộc Long An với khu du lịch sinh thái Làng nổi Tân Lập.', 'Tượng Phật Bà Tây Bổ Đà Sơn trên đỉnh núi — một trong những tượng Phật cao nhất châu Á',
  'Tháng 11–4 (mùa khô, trời quang, dễ ngắm cảnh từ cáp treo)', ARRAY[11, 12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng 25–35°C, mùa mưa tháng 5–10', 'Bánh tráng phơi sương Trảng Bàng, muối tôm Tây Ninh, ốc núi',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7b51-bde0-322dacd2b8b3', 'Thái Nguyên', 'thai-nguyen', 'Thái Nguyên',
  'Trung du và miền núi phía Bắc', 'Thủ phủ chè Việt Nam với đồi chè Tân Cương xanh mướt nổi tiếng, hồ Núi Cốc thơ mộng, ATK Định Hóa — căn cứ địa cách mạng kháng chiến và văn hóa dân tộc Tày đặc sắc.', 'Chè Tân Cương thương hiệu quốc gia, hồ Núi Cốc, ATK Định Hóa lịch sử, bảo tàng Văn hóa các dân tộc',
  'Tháng 9–11 và tháng 3–5 (thu hoạch chè, khí hậu mát)', ARRAY[9, 10, 11, 3, 4, 5]::SMALLINT[],
  '4 mùa rõ rệt, 16–34°C, mưa nhiều tháng 6–8, sương mù đồi chè buổi sáng', 'Chè Tân Cương, gà đồi Thái Nguyên, cá nướng Pa Tẩu, bánh chưng gù Bắc Kạn, trám om xôi',
  700000, 2000000, 'https://cdn.pdtrip.vn/destinations/thainguyen.jpg',
  4.3, 760,
  0, 29000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-7e43-9532-5f1a51149596', 'Sầm Sơn', 'thanh-hoa-sam-son', 'Thanh Hóa',
  'Bắc Trung Bộ', 'Thành phố biển nổi tiếng xứ Thanh với bãi biển dài 9km cát mịn, đền Độc Cước linh thiêng trên mỏm đá, sóng lớn phù hợp lướt sóng và hải sản tươi ngon giá bình dân.', 'Bãi biển dài 9km sóng lớn, đền Độc Cước trên mỏm đá, lễ hội cầu ngư, hải sản giá rẻ',
  'Tháng 4–8 (mùa tắm biển sầm uất)', ARRAY[4, 5, 6, 7, 8]::SMALLINT[],
  'Nóng 28–36°C mùa hè, gió biển mát, mùa đông lạnh hanh, bão tháng 9–10', 'Nem chua Thanh Hóa, bánh cuốn Phủ Lý, cháo lươn, ghẹ rang muối, canh chua hải sản, ốc hút',
  800000, 2500000, 'https://cdn.pdtrip.vn/destinations/samson.jpg',
  4.2, 1200,
  0, 42000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eeda8-d830-72fe-8479-3d24a2698ee8', 'TP. Hồ Chí Minh', 'tp-ho-chi-minh', 'TP. Hồ Chí Minh',
  'Đông Nam Bộ', 'Đô thị lớn nhất Việt Nam, trung tâm kinh tế năng động, kết hợp di tích lịch sử, ẩm thực đường phố, các khu công nghiệp Bình Dương và biển Vũng Tàu sau sáp nhập.', 'Chợ Bến Thành, Dinh Độc Lập, Nhà thờ Đức Bà — biểu tượng trung tâm thành phố',
  'Tháng 12–4 (mùa khô, ít mưa)', ARRAY[12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng ẩm 25–35°C quanh năm, mùa mưa tháng 5–11', 'Cơm tấm, hủ tiếu, bánh mì Sài Gòn, lẩu mắm, ốc Vũng Tàu',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eed69-50b3-70c8-8345-0c9df484cb9d', 'Hà Giang', 'tuyen-quang-ha-giang', 'Tuyên Quang',
  'Trung du và miền núi phía Bắc', 'Vùng đất cực Bắc hùng vĩ với cung đường đèo Mã Pí Lèng ''Đường Hạnh Phúc'', cao nguyên đá Đồng Văn UNESCO, ruộng bậc thang và văn hóa đa dân tộc H''Mông, Dao, Lô Lô đặc sắc.', 'Hà Giang Loop huyền thoại, đèo Mã Pí Lèng, hoa tam giác mạch tháng 10–11, cột cờ Lũng Cú cực Bắc',
  'Tháng 9–11 (hoa tam giác mạch) hoặc tháng 3–5 (hoa đào)', ARRAY[9, 10, 11, 3, 4, 5]::SMALLINT[],
  'Lạnh về đêm 10–25°C, sương mù dày đặc sáng sớm, rét đậm tháng 12–2', 'Thắng cố ngựa, mèn mén, rượu ngô Bắc Hà, cháo ấu tẩu, thịt trâu khô, mật ong bạc hà',
  1500000, 5000000, 'https://cdn.pdtrip.vn/destinations/hagiang.jpg',
  4.7, 1820,
  0, 78000, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();

INSERT INTO destinations (id, name, slug, province, region, description, special,
    best_season, best_months, weather, cuisine, budget_low, budget_high, image_url,
    rating_avg, review_count, favorite_count, view_count, is_active) VALUES (
  '019eeda8-d830-700b-a117-253a6c24a6f8', 'TP. Vĩnh Long', 'vinh-long', 'Vĩnh Long',
  'Đồng bằng sông Cửu Long', 'Miền sông nước miệt vườn với cù lao An Bình, chợ nổi và làng nghề gốm đỏ ven sông Cổ Chiên; sau sáp nhập còn có xứ dừa Bến Tre và vùng văn hóa Khmer Trà Vinh với hệ thống chùa Khmer cổ.', 'Cù lao An Bình — vườn cây ăn trái, du lịch homestay miệt vườn',
  'Tháng 12–4 (mùa khô, thuận tiện tham quan vườn và sông nước)', ARRAY[12, 1, 2, 3, 4]::SMALLINT[],
  'Nóng ẩm 25–34°C, mùa nước nổi tháng 9–11 (vùng lân cận)', 'Cá tai tượng chiên xù, bánh xèo miền Tây, trái cây miệt vườn, bưởi Năm Roi',
  NULL, NULL, NULL,
  0, 0,
  0, 0, TRUE
) ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name, province=EXCLUDED.province, region=EXCLUDED.region,
  description=EXCLUDED.description, special=EXCLUDED.special,
  best_season=EXCLUDED.best_season, weather=EXCLUDED.weather,
  cuisine=EXCLUDED.cuisine, budget_low=EXCLUDED.budget_low,
  budget_high=EXCLUDED.budget_high, updated_at=NOW();


-- destination_categories
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eee7d-cd94-744b-86d1-ca07059a9949','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eee7d-cd94-744b-86d1-ca07059a9949','c3333333-3333-3333-3333-333333333333') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eee7d-cd94-744b-86d1-ca07059a9949','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eee7d-cd94-744b-86d1-ca07059a9949','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eee7d-cd94-744b-86d1-ca07059a9949','caaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('3d01b622-f917-44bb-9054-c5b6001c52ee','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('3d01b622-f917-44bb-9054-c5b6001c52ee','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('23431b56-3e63-4368-949f-8df24ab3c539','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('23431b56-3e63-4368-949f-8df24ab3c539','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('23431b56-3e63-4368-949f-8df24ab3c539','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('e1b4d4cb-8d60-4a03-8b98-bc54991eff17','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('e1b4d4cb-8d60-4a03-8b98-bc54991eff17','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('e1b4d4cb-8d60-4a03-8b98-bc54991eff17','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('e1b4d4cb-8d60-4a03-8b98-bc54991eff17','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('aa20e516-ea38-4c41-9bd2-7de71095647e','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('aa20e516-ea38-4c41-9bd2-7de71095647e','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('aa20e516-ea38-4c41-9bd2-7de71095647e','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('44444444-4444-4444-4444-444444444444','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('44444444-4444-4444-4444-444444444444','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('44444444-4444-4444-4444-444444444444','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('44444444-4444-4444-4444-444444444444','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('9193ad16-91b7-43cd-86bf-e208fcdc43f1','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('9193ad16-91b7-43cd-86bf-e208fcdc43f1','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('9193ad16-91b7-43cd-86bf-e208fcdc43f1','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('9193ad16-91b7-43cd-86bf-e208fcdc43f1','c2222222-2222-2222-2222-222222222222') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('01c26442-a471-48e6-b6f1-dc3036aa718e','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('01c26442-a471-48e6-b6f1-dc3036aa718e','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('0a193ffa-e0a2-401c-8e6f-f54630558a65','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('0a193ffa-e0a2-401c-8e6f-f54630558a65','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eee23-1730-7352-8c9a-09c5b0bed755','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eee23-1730-7352-8c9a-09c5b0bed755','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-762e-8f70-18a66f56fa5c','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-762e-8f70-18a66f56fa5c','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b1-7455-bdfa-2e98ab743e96','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b1-7455-bdfa-2e98ab743e96','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-774a-83ca-b8e9b4965dcb','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-774a-83ca-b8e9b4965dcb','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-774a-83ca-b8e9b4965dcb','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d7e-876d-39fc6f6a1674','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d7e-876d-39fc6f6a1674','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d7e-876d-39fc6f6a1674','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d7e-876d-39fc6f6a1674','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-73da-a651-2515b15db7c2','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-73da-a651-2515b15db7c2','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-73da-a651-2515b15db7c2','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d56-b86a-8abd90d35197','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d56-b86a-8abd90d35197','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d56-b86a-8abd90d35197','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-743c-b2d0-2107e58ca38d','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-743c-b2d0-2107e58ca38d','c3333333-3333-3333-3333-333333333333') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-743c-b2d0-2107e58ca38d','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-743c-b2d0-2107e58ca38d','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c74-b810-8e00d38b1805','c2222222-2222-2222-2222-222222222222') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c74-b810-8e00d38b1805','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c74-b810-8e00d38b1805','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c74-b810-8e00d38b1805','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d37-b71a-93a9a778c50c','c2222222-2222-2222-2222-222222222222') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d37-b71a-93a9a778c50c','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d37-b71a-93a9a778c50c','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d37-b71a-93a9a778c50c','c3333333-3333-3333-3333-333333333333') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7d37-b71a-93a9a778c50c','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7691-995a-bbe5f3404ea8','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7691-995a-bbe5f3404ea8','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7691-995a-bbe5f3404ea8','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7691-995a-bbe5f3404ea8','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7691-995a-bbe5f3404ea8','c3333333-3333-3333-3333-333333333333') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7232-b155-10c17a514c3c','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7232-b155-10c17a514c3c','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7232-b155-10c17a514c3c','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b08-84a7-341ade2c0908','c2222222-2222-2222-2222-222222222222') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b08-84a7-341ade2c0908','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b08-84a7-341ade2c0908','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b08-84a7-341ade2c0908','c3333333-3333-3333-3333-333333333333') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-75f8-b421-0622df9db573','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-75f8-b421-0622df9db573','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-75f8-b421-0622df9db573','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7f4e-886e-b5d04063fc02','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7f4e-886e-b5d04063fc02','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7f4e-886e-b5d04063fc02','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7f4e-886e-b5d04063fc02','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7a97-8133-dab596aaf763','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7a97-8133-dab596aaf763','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7a97-8133-dab596aaf763','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-7d4c-9ef2-6de207ce2bdb','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-7d4c-9ef2-6de207ce2bdb','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7f32-bd6d-13f617e17937','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7f32-bd6d-13f617e17937','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7f32-bd6d-13f617e17937','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-79f6-9a6e-66856703829f','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-79f6-9a6e-66856703829f','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c76-b437-284592040a13','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c76-b437-284592040a13','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c76-b437-284592040a13','c3333333-3333-3333-3333-333333333333') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c76-b437-284592040a13','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7c76-b437-284592040a13','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-7a83-8b89-527da5de9455','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-7a83-8b89-527da5de9455','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b51-bde0-322dacd2b8b3','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b51-bde0-322dacd2b8b3','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b51-bde0-322dacd2b8b3','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7b51-bde0-322dacd2b8b3','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7e43-9532-5f1a51149596','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7e43-9532-5f1a51149596','c9999999-9999-9999-9999-999999999999') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-7e43-9532-5f1a51149596','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-72fe-8479-3d24a2698ee8','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-72fe-8479-3d24a2698ee8','c5555555-5555-5555-5555-555555555555') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-72fe-8479-3d24a2698ee8','c1111111-1111-1111-1111-111111111111') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-70c8-8345-0c9df484cb9d','c2222222-2222-2222-2222-222222222222') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-70c8-8345-0c9df484cb9d','c4444444-4444-4444-4444-444444444444') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-70c8-8345-0c9df484cb9d','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-70c8-8345-0c9df484cb9d','c8888888-8888-8888-8888-888888888888') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eed69-50b3-70c8-8345-0c9df484cb9d','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-700b-a117-253a6c24a6f8','c7777777-7777-7777-7777-777777777777') ON CONFLICT DO NOTHING;
INSERT INTO destination_categories(destination_id, category_id) VALUES ('019eeda8-d830-700b-a117-253a6c24a6f8','c6666666-6666-6666-6666-666666666666') ON CONFLICT DO NOTHING;

-- locations (sub-destinations)
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee71-616d-7317-b456-896589eaa20c', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Bãi Sao', 'beach',
  'Xã Dương Tơ, TP. Phú Quốc, tỉnh An Giang', 10.0311, 103.9777, 'Một trong những bãi biển đẹp nhất Phú Quốc với cát trắng mịn, nước biển trong xanh màu ngọc lam. Nổi tiếng là bãi biển lý tưởng để tắm và chụp ảnh, ít khách sạn lớn bao vây nên không khí còn tự nhiên.',
  'Mở 24/7 (bãi công cộng)', 'Miễn phí (bãi biển công cộng)', 'Đến trước 9:00 hoặc sau 16:00 để tránh nắng gắt và đông người. Có thể thuê ghế nằm và ô tại các quán dọc bãi.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee71-616d-7dc2-81e1-0521e1d2b287', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Vinpearl Safari Phú Quốc', 'attraction',
  'Đường Vòng Quanh Đảo, xã Gành Dầu, TP. Phú Quốc, tỉnh An Giang', 10.38, 103.8383, 'Vườn thú bán hoang dã lớn nhất Đông Nam Á tại Phú Quốc, có hơn 3.000 động vật quý hiếm. Du khách di chuyển bằng xe điện qua khu bảo tồn, xem sư tử, tê giác, hà mã trong môi trường bán tự nhiên.',
  '8:00–17:00 hằng ngày', '// TODO: xác nhận tại vinpearl.com hoặc Klook — giá vé theo mùa có thể thay đổi', 'Nên đặt vé online trước để có giá tốt hơn. Đi vào buổi sáng khi động vật còn hoạt động nhiều.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee71-616d-7457-b092-16c665bc6447', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Làng chài Hàm Ninh', 'attraction',
  'Xã Hàm Ninh, TP. Phú Quốc, tỉnh An Giang', 10.1738, 104.0545, 'Làng chài truyền thống lâu đời nhất Phú Quốc, nơi ngư dân bán hải sản tươi sống trực tiếp. Có cầu gỗ dài ra biển, là điểm chụp ảnh đẹp với khung cảnh thuyền đánh cá và núi rừng phía xa.',
  'Mở cả ngày (chợ hải sản sầm uất nhất buổi sáng 6:00–10:00)', 'Miễn phí', 'Đến sáng sớm để thấy cảnh đánh cá và mua ghẹ, tôm hùm tươi với giá gốc. Có thể ăn tại các quán hải sản ngay cầu cảng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee71-616e-7f4e-ac72-07dffaf4bc21', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Vườn Quốc gia Phú Quốc', 'nature',
  'Xã Gành Dầu – Bãi Thơm, TP. Phú Quốc, tỉnh An Giang', 10.32, 103.9, 'Vùng rừng nguyên sinh được UNESCO công nhận, chiếm hơn 50% diện tích đảo Phú Quốc. Có nhiều loài động thực vật quý hiếm, hệ thống suối và thác nước, tuyến trek băng rừng nguyên sinh.',
  '7:00–17:00 hằng ngày', '// TODO: xác nhận tại Ban quản lý Vườn Quốc gia Phú Quốc', 'Cần thuê hướng dẫn viên địa phương khi vào sâu rừng. Mang theo nước, thuốc chống muỗi và giày đế bằng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee71-616e-74a8-a5f9-8edfe71161eb', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Chợ Đêm Phú Quốc (Dinh Cậu Night Market)', 'market',
  'Đường Bạch Đằng, khu Dinh Cậu, TP. Phú Quốc, tỉnh An Giang', 10.2154, 103.9586, 'Chợ đêm sôi động nhất Phú Quốc nằm ngay mặt biển khu Dinh Cậu. Hàng chục quầy hải sản tươi, mực nướng, bạch tuộc, bắp nướng… Là nơi lý tưởng để thưởng thức ẩm thực và mua đồ lưu niệm.',
  '17:00–23:00 hằng ngày', 'Miễn phí vào chợ', 'Nên trả giá khi mua đồ lưu niệm. Hải sản tươi rẻ hơn nhiều so với nhà hàng khách sạn. Đông nhất lúc 19:00–21:00.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee71-616e-7cf5-bbc6-a2d20b16ae09', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Dinh Cậu (Dinh Cô)', 'temple',
  'Đường Bạch Đằng, TP. Phú Quốc, tỉnh An Giang', 10.2165, 103.958, 'Ngôi miếu thờ cá Ông (cá voi) nhỏ xinh nằm trên mỏm đá nhô ra biển. Đây là điểm linh thiêng với ngư dân địa phương và là điểm ngắm hoàng hôn tuyệt đẹp nhất Phú Quốc.',
  '6:00–18:00 hằng ngày', 'Miễn phí', 'Đến trước 18:00 để ngắm hoàng hôn từ mỏm đá. Kết hợp với chợ đêm ở sát bên.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee71-616e-7461-ba4b-6695feaa9e55', '019eee7d-cd94-744b-86d1-ca07059a9949', 'Bãi Dài (Kem Beach)', 'beach',
  'Xã Gành Dầu, TP. Phú Quốc, tỉnh An Giang', 10.35, 103.85, 'Bãi biển hoang sơ dài hơn 15km ở phía bắc đảo, cát trắng mịn, ít người hơn khu nam đảo. Hiện có khu Vinpearl Bãi Dài nhưng vẫn còn nhiều đoạn bãi công cộng tự nhiên.',
  'Mở 24/7', 'Miễn phí (khu công cộng)', 'Cần xe máy hoặc taxi để đến (khoảng 25km từ trung tâm). Mang đồ ăn và nước vì khu vực hạn chế dịch vụ ăn uống.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee91-da98-77e3-88cf-5a4eaa3b0000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Chùa Dâu (Pháp Vân)', 'temple',
  'Xã Thanh Khương, huyện Thuận Thành, tỉnh Bắc Ninh', None, None, 'Ngôi chùa cổ nhất Việt Nam, được xây dựng từ thế kỷ 2–3 SCN, là trung tâm Phật giáo đầu tiên của người Việt. Chùa thờ Tứ Pháp — bốn vị thần bảo hộ nông nghiệp. Tháp Hòa Phong 3 tầng là biểu tượng nổi bật nhất còn lại. Di tích Quốc gia đặc biệt.',
  '6:00–18:00 hàng ngày (xác nhận trước khi đến)', NULL, 'Đến buổi sáng sớm 6:30–8:00 để không khí thanh tịnh, ánh sáng đẹp chụp tháp Hòa Phong. Kết hợp tham quan cùng chùa Bút Tháp (cách 5km) trong cùng buổi.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee91-da99-73ab-ed08-723eeaab0000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Chùa Bút Tháp (Ninh Phúc Tự)', 'temple',
  'Thôn Bút Tháp, xã Đình Tổ, huyện Thuận Thành, tỉnh Bắc Ninh', None, None, 'Ngôi chùa thế kỷ 17 còn giữ nguyên kiến trúc gốc hoàn chỉnh nhất miền Bắc. Nổi tiếng với tòa tháp Báo Nghiêm 11 tầng bằng đá và tượng Quan Âm nghìn tay nghìn mắt (Phật Bà Thiên Thủ Thiên Nhãn) cao 3,7m — kiệt tác điêu khắc thời Lê. Di tích Quốc gia đặc biệt.',
  '7:00–17:30 hàng ngày (xác nhận trước khi đến)', NULL, 'Ánh sáng đẹp nhất để chụp ảnh vào 7:30–9:00 sáng khi nắng chiếu qua các cây đại cổ thụ. Trang phục kín đáo khi vào chánh điện.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee91-da9a-7187-0b60-85f0d79c0000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Đền Đô (Đền Lý Bát Đế)', 'temple',
  'Làng Đình Bảng, phường Đình Bảng, thị xã Từ Sơn, tỉnh Bắc Ninh', None, None, 'Đền thờ 8 vị vua triều Lý — triều đại đặt kinh đô Thăng Long và xây Văn Miếu. Đây là công trình lớn và trang nghiêm nhất trong hệ thống đền vua miền Bắc, được trùng tu quy mô vào thế kỷ 21. Lễ hội Đền Đô tổ chức vào ngày 14–16 tháng 3 âm lịch hàng năm.',
  '7:00–17:00 hàng ngày (xác nhận trước khi đến)', NULL, 'Làng Đình Bảng là nơi tốt nhất để mua bánh phu thê chính gốc — mua ngay tại các hộ gia đình sau khi thăm đền.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee91-da9b-7328-b2d5-0ed4fc216000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Làng tranh dân gian Đông Hồ', 'attraction',
  'Xã Song Hồ, huyện Thuận Thành, tỉnh Bắc Ninh', None, None, 'Làng nghề làm tranh dân gian lâu đời nhất Việt Nam, nơi sản xuất tranh khắc gỗ với màu sắc từ nguyên liệu tự nhiên. Hiện chỉ còn một số gia đình nghệ nhân gìn giữ nghề. Tranh Đông Hồ được UNESCO ghi nhận là Di sản văn hóa phi vật thể cần bảo vệ khẩn cấp.',
  '7:00–17:00 (tại các gia đình nghệ nhân — liên hệ trước)', NULL, 'Hỏi thăm nhà nghệ nhân Nguyễn Đăng Chế để xem quy trình làm tranh thực tế và mua tranh authentic. Đặt lịch trước qua điện thoại để đảm bảo có người tiếp.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee91-da9c-739c-3d40-4492fb350000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Làng gốm Phù Lãng', 'attraction',
  'Xã Phù Lãng, huyện Quế Võ, tỉnh Bắc Ninh', None, None, 'Làng gốm truyền thống hàng trăm năm tuổi nổi tiếng với sản phẩm màu da lươn và đỏ gạch đặc trưng, khác biệt hoàn toàn với gốm Bát Tràng. Gốm Phù Lãng được nung bằng than và có độ bóng tự nhiên độc đáo. Là điểm đến lý tưởng để tìm hiểu làng nghề thủ công miền Bắc.',
  'Hoạt động cả ngày (làng nghề — thích hợp ghé thăm sáng sớm)', NULL, 'Mua gốm trực tiếp tại lò rẻ hơn nhiều so với ngoài chợ. Đến buổi sáng để xem thợ làm gốm — buổi chiều nhiều lò đã tắt.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee91-da9d-726b-055c-bbf36add1000', '3d01b622-f917-44bb-9054-c5b6001c52ee', 'Đồi Lim – Hội Lim', 'attraction',
  'Thị trấn Lim, huyện Tiên Du, tỉnh Bắc Ninh', None, None, 'Đồi Lim là trung tâm của Hội Lim — lễ hội quan họ lớn nhất và nổi tiếng nhất Bắc Ninh, được tổ chức vào ngày 12–13 tháng Giêng âm lịch. Đây là nơi diễn ra các buổi hát quan họ trên thuyền, trên đồi và trong đình làng. Quan họ Bắc Ninh đã được UNESCO công nhận là Di sản văn hóa phi vật thể đại diện của nhân loại năm 2009.',
  'Cả ngày (địa điểm mở). Hội Lim: 12–13 tháng Giêng âm lịch hàng năm.', NULL, 'Đến sớm trước 8:00 sáng để xem hát quan họ trên thuyền tại hồ — đây là cảnh đẹp nhất của Hội Lim. Đường ùn tắc nặng từ 9:00 trở đi.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'a5b646aa-0a77-4573-9828-6fc926cfa907', '23431b56-3e63-4368-949f-8df24ab3c539', 'Mũi Cà Mau', 'nature',
  'Xã Đất Mũi, huyện Ngọc Hiển, tỉnh Cà Mau', 8.5833, 104.7167, 'Điểm cực Nam của đất nước Việt Nam, nơi hội tụ ba dòng chảy Biển Đông, Vịnh Thái Lan và biển Tây. Có cột mốc quốc gia số 0, biểu tượng thiêng liêng chủ quyền Tổ quốc. Xung quanh là rừng ngập mặn bạt ngàn và bãi bồi đất mới không ngừng mở rộng ra biển.',
  'Mở cửa hằng ngày — xác nhận giờ cụ thể trước khi đến', NULL, 'Nên đi thuyền từ bến Đầm Dơi hoặc Năm Căn để vào Đất Mũi — đường thủy là trải nghiệm đặc trưng. Đi sáng sớm để tránh nắng và chụp ảnh đẹp hơn.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '764d5012-c64e-4f97-8e66-42f24bfe03cd', '23431b56-3e63-4368-949f-8df24ab3c539', 'Vườn Quốc gia U Minh Hạ', 'nature',
  'Huyện U Minh và huyện Trần Văn Thời, tỉnh Cà Mau', 9.45, 105.05, 'Vườn quốc gia với hệ sinh thái rừng tràm trên đất than bùn độc đáo, một trong hai vùng đất ngập nước quan trọng nhất Nam Bộ (cùng với U Minh Thượng). Nơi sinh sống của nhiều loài chim, rắn, rùa và ong mật. Nổi tiếng với mật ong rừng U Minh chất lượng cao.',
  'Thường 7:00–17:00 — xác nhận trước khi đến', NULL, 'Thuê thuyền chèo để khám phá lòng rừng — không ồn ào, dễ quan sát chim và động vật. Mùa khô (tháng 12–4) cảnh quan đẹp nhất. Mang theo áo khoác chống vắt.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '25cb52e2-9647-41ae-84f6-98bb9b2d2e2f', '23431b56-3e63-4368-949f-8df24ab3c539', 'Hòn Đá Bạc', 'attraction',
  'Xã Khánh Bình Tây, huyện Trần Văn Thời, tỉnh Cà Mau', 9.62, 104.8, 'Quần thể đảo đá nhỏ nằm ngoài khơi bờ biển Tây Cà Mau, có di tích lịch sử đường Hồ Chí Minh trên biển. Cảnh quan thiên nhiên hoang sơ với hang động, bãi đá và rừng cây nhiệt đới. Là điểm kết hợp tham quan di tích và nghỉ dưỡng biển.',
  'Mở cửa hằng ngày — xác nhận giờ cụ thể trước khi đến', NULL, 'Đi thuyền từ cầu cảng Khánh Bình Tây. Mang theo đủ nước và thức ăn vì cơ sở dịch vụ còn hạn chế trên đảo.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'e2511569-ca3c-4292-a9e0-20e11a724d92', '23431b56-3e63-4368-949f-8df24ab3c539', 'Đầm Thị Tường', 'nature',
  'Huyện Cái Nước và huyện Phú Tân, tỉnh Cà Mau', 9.1, 105.02, 'Đầm nước ngọt lớn giữa vùng rừng ngập mặn, là nơi sinh sống của hàng trăm loài chim nước di cư. Đặc biệt nổi tiếng vào mùa chim về (tháng 11–3) với hàng nghìn con cò, vạc, sếu tụ về. Mặt đầm phẳng lặng phản chiếu trời xanh tạo nên cảnh quan thơ mộng.',
  'Mở cửa hằng ngày — tốt nhất đi sáng sớm 5:00–8:00', NULL, 'Thuê thuyền và xuất phát lúc bình minh để xem chim bay lên — thời điểm đẹp và ấn tượng nhất. Mang theo ống nhòm nếu có.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '5edb3bdb-f39b-440b-97b3-1e1b0b1d3929', '23431b56-3e63-4368-949f-8df24ab3c539', 'Cánh đồng điện gió Bạc Liêu', 'attraction',
  'Khu vực biển Bạc Liêu (nay thuộc tỉnh Cà Mau sau sáp nhập), tỉnh Cà Mau', 9.25, 105.72, 'Một trong những trang trại điện gió lớn nhất Việt Nam với hàng chục turbine khổng lồ mọc giữa biển. Cảnh quan kỳ vĩ và hiện đại, đặc biệt đẹp khi hoàng hôn. Trở thành điểm check-in nổi tiếng và biểu tượng phát triển năng lượng sạch của vùng đất cực Nam.',
  'Tham quan tự do từ bờ — xác nhận giờ tour chính thức trước khi đến', NULL, 'Thuê xe máy để chạy dọc đường bờ biển chiều tối — ánh sáng hoàng hôn chiếu vào các turbine tạo ra khung cảnh ảo diệu. Kết hợp ghé nhà Công tử Bạc Liêu gần đó.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'cbe319df-91fc-4391-add2-9f5fd83b202c', '23431b56-3e63-4368-949f-8df24ab3c539', 'Nhà Công tử Bạc Liêu', 'museum',
  'Số 13 đường Điện Biên Phủ, TP. Bạc Liêu (nay thuộc tỉnh Cà Mau)', 9.2937, 105.7273, 'Dinh thự cổ xây năm 1919 của gia đình Hội đồng Trạch — gia đình địa chủ giàu nhất Nam Kỳ đầu thế kỷ 20. Kiến trúc Pháp lai Á Đông, hiện được phục dựng thành bảo tàng lưu giữ chứng tích về cuộc sống xa hoa của công tử Bạc Liêu — nhân vật dân gian nổi tiếng miền Nam.',
  'Thường 7:00–17:00 các ngày — xác nhận trước khi đến', NULL, 'Kết hợp tham quan với Khu lưu niệm Cao Văn Lầu và đờn ca tài tử để hiểu sâu hơn về văn hóa Bạc Liêu.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '226241c8-03a6-4020-be42-b31ab31854db', '23431b56-3e63-4368-949f-8df24ab3c539', 'Rừng đước Năm Căn', 'nature',
  'Huyện Năm Căn, tỉnh Cà Mau', 8.95, 105.02, 'Vùng rừng đước ngập mặn đặc trưng nhất Đồng bằng sông Cửu Long, với những cây đước cao vút ken dày trên mặt nước. Hệ sinh thái phong phú: cua, cá, tôm sú nuôi trong rừng. Chợ Năm Căn nằm ngay trên sông cũng là điểm tham quan độc đáo với cảnh sinh hoạt trên thuyền.',
  'Mở cửa hằng ngày — xác nhận giờ tham quan', NULL, 'Mua hải sản tươi sống ngay tại chợ nổi Năm Căn — giá rẻ và tươi hơn nhiều so với trung tâm thành phố. Đi thuyền qua kênh rạch để thấy rõ bộ rễ đước ấn tượng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '252f436c-63fd-4ad9-a7e9-7fd4a0bedd8a', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chợ nổi Cái Răng', 'market',
  'Quận Cái Răng, TP. Cần Thơ', 10.0131, 105.762, 'Chợ nổi lớn nhất miền Tây Nam Bộ, nơi hàng trăm ghe thuyền chở đầy trái cây, rau củ trao đổi ngay trên sông. Đặc trưng nhận biết là mỗi ghe cắm cây sào treo mặt hàng đang bán (gọi là ''bẹo hàng''). Là điểm tham quan không thể bỏ qua khi đến Cần Thơ.',
  'Họp từ khoảng 5:00–9:00, đông nhất 5:30–7:00 — xác nhận trước khi đến', NULL, 'Xuất phát từ bến Ninh Kiều khoảng 5:00–5:30 để kịp thấy chợ đông nhất. Đặt tour xuồng máy từ tối hôm trước. Mang tiền mặt nhỏ để mua trái cây trực tiếp trên ghe.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '1e116ed4-60b5-4070-9261-6e0d550bc4ae', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Bến Ninh Kiều', 'attraction',
  'Đường Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ', 10.0317, 105.7889, 'Bến tàu và khu phố đi bộ ven sông Cần Thơ — trung tâm sinh hoạt văn hóa, ẩm thực của thành phố. Cuối tuần có phố đi bộ với biểu diễn đờn ca tài tử Nam Bộ, chợ đêm và nhiều gian hàng đặc sản miền Tây.',
  'Mở cửa 24/7, sôi động nhất 18:00–22:00', 'Miễn phí', 'Đến vào buổi tối cuối tuần để xem đờn ca tài tử và thưởng thức chợ đêm. Từ đây có thể đặt tour thuyền đi chợ nổi Cái Răng sáng sớm hôm sau.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'd50e0997-fbe0-4f53-a040-5bfa2a3d550a', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Nhà cổ Bình Thủy', 'museum',
  '144 Bùi Hữu Nghĩa, Phường Bình Thủy, Quận Bình Thủy, TP. Cần Thơ', 10.0556, 105.7608, 'Biệt thự phong cách Pháp xây năm 1870, còn được gọi là Villa Dương Chí Diệu, từng là bối cảnh phim ''L''Amant'' (Người Tình) của đạo diễn Jean-Jacques Annaud (1992). Kết hợp kiến trúc Pháp và nghệ thuật trang trí Á Đông với đồ cổ, tranh ảnh và không gian vườn xanh mát.',
  '8:00–17:00, nghỉ thứ Hai — xác nhận trước khi đến', NULL, 'Nên đến buổi sáng khi còn mát. Hỏi người canh gác để nghe câu chuyện về lịch sử ngôi nhà. Kết hợp tham quan chùa Ông Bình Thủy gần đó.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'ef17c097-3639-4f5f-a447-8e260ab4b14c', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Làng du lịch sinh thái Mỹ Khánh', 'nature',
  'Xã Mỹ Khánh, Huyện Phong Điền, TP. Cần Thơ (cách trung tâm ~12km)', 9.9965, 105.7167, 'Khu du lịch sinh thái vườn trái cây rộng lớn với các loại đặc sản miền Tây như xoài, sầu riêng, chôm chôm, mít... theo mùa. Du khách có thể đi xe đạp trong vườn, thả lưới bắt cá, đi xuồng ba lá qua kênh rạch và thưởng thức trái cây tươi ngay tại chỗ.',
  '7:00–17:00 — xác nhận trước khi đến', NULL, 'Đến mùa sầu riêng (tháng 5–7) hoặc xoài (tháng 3–5) để có trái cây ngon nhất. Nên đặt trước để chắc chắn có chỗ ăn trưa.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '43d0b17e-66f1-41aa-b7a3-d7b7f7284f67', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chùa Ông (Quảng Triệu Hội Quán)', 'temple',
  '32 Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ', 10.031, 105.787, 'Ngôi chùa Hoa (người Hoa Quảng Đông) xây dựng từ thế kỷ 19, thờ Quan Công và các vị thần. Nổi tiếng với kiến trúc mái cong nhiều lớp, đồ gốm sứ trang trí tinh xảo và những vòng nhang khổng lồ treo lơ lửng trên trần tạo không gian huyền bí, rất thu hút khách chụp ảnh.',
  '6:00–17:30 — xác nhận trước khi đến', 'Miễn phí', 'Miễn phí vào cửa. Buổi sáng sớm không gian yên tĩnh và khói nhang đẹp nhất. Nằm gần bến Ninh Kiều nên dễ kết hợp.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '0b99a3b6-877c-4726-840b-9def6f3fb60f', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chợ nổi Ngã Bảy (Phụng Hiệp)', 'market',
  'Thị xã Ngã Bảy, TP. Cần Thơ (tỉnh Hậu Giang cũ, sau sáp nhập thuộc Cần Thơ)', 9.8289, 105.9793, 'Chợ nổi độc đáo ở ngã ba 7 con kênh gặp nhau, từng là một trong những chợ nổi sầm uất nhất miền Tây. Sau khi sáp nhập tỉnh 2025, Ngã Bảy thuộc địa phận Cần Thơ. Chợ hiện có quy mô nhỏ hơn Cái Răng nhưng còn giữ được nét chân thực.',
  '5:00–9:00 — xác nhận trước khi đến', 'Miễn phí', 'Ít khách du lịch hơn Cái Răng — trải nghiệm chân thực hơn. Cách trung tâm Cần Thơ khoảng 50km, nên kết hợp tour 1 ngày.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '6378e32d-e2da-4210-be3e-3d4f8529389d', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17', 'Chùa Dơi (Mã Tộc)', 'temple',
  'Phường 3, TP. Sóc Trăng (thuộc Cần Thơ sau sáp nhập)', 9.5982, 105.9715, 'Ngôi chùa Khmer hơn 400 năm tuổi của người Khmer Nam Bộ, nổi tiếng với đàn dơi quạ hàng chục nghìn con sinh sống trên cây cổ thụ trong khuôn viên. Chùa có kiến trúc Khmer tinh xảo với mái đầu rồng đặc trưng. Thuộc địa phận Sóc Trăng cũ, nay thuộc Cần Thơ sau sáp nhập 2025.',
  '7:00–17:00 — xác nhận trước khi đến', 'Miễn phí', 'Đến chiều tà để xem đàn dơi bay ra kiếm ăn — cảnh tượng ấn tượng. Ăn mặc lịch sự vì đây là nơi thờ tự linh thiêng của cộng đồng Khmer.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '0c7364d8-7f0e-4ab7-8fd1-806515fd6d17', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Thác Bản Giốc', 'nature',
  'Xã Đàm Thủy, huyện Trùng Khánh, tỉnh Cao Bằng', 22.9028, 106.7072, 'Thác nước lớn thứ tư thế giới trên ranh giới Việt–Trung, với ba tầng thác hùng vĩ rộng hàng trăm mét. Mùa nước lũ tháng 8–10 thác chảy mạnh nhất, tạo ra bức màn nước trắng xóa vô cùng ngoạn mục. Đây là biểu tượng thiên nhiên nổi tiếng nhất của Cao Bằng.',
  'Thường 7:00–17:00 — xác nhận trước khi đến', '// TODO: xác nhận tại caobang.gov.vn hoặc Klook — giá vé có thể thay đổi theo mùa', 'Đến vào mùa mưa (tháng 8–10) để thác nhiều nước nhất. Có thể thuê bè mảng để ngắm thác gần hơn từ phía dưới. Mang giày đế chống trơn vì đường xuống ẩm và trơn.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '1d406b9b-3a6c-42f2-98a6-4dde7ffe6371', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Hang Pác Bó', 'attraction',
  'Xã Trường Hà, huyện Hà Quảng, tỉnh Cao Bằng', 22.9361, 106.2956, 'Di tích lịch sử quốc gia đặc biệt nơi Chủ tịch Hồ Chí Minh sống và làm việc từ năm 1941 sau khi về nước. Khu di tích bao gồm hang Pác Bó, suối Lê-nin, núi Các Mác và nhà làm việc của Bác. Là điểm hành hương quan trọng đối với du khách muốn tìm hiểu lịch sử cách mạng Việt Nam.',
  '7:00–17:00 hằng ngày — xác nhận trước khi đến', '// TODO: xác nhận tại Ban Quản lý Khu di tích Pác Bó hoặc caobang.gov.vn', 'Nên đến buổi sáng sớm trước 9:00 để tránh đông người, đặc biệt vào các dịp lễ. Mang theo áo dài tay vì bên trong hang khá mát và ẩm.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '521c2b59-d487-446a-8c72-f222893e1484', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Hồ Thang Hen', 'nature',
  'Xã Quốc Toản, huyện Trà Lĩnh, tỉnh Cao Bằng', 22.8167, 106.6167, 'Quần thể 36 hồ nước liên thông nằm trên cao nguyên đá vôi, xanh ngọc bích giữa khung cảnh núi non hùng vĩ. Vào mùa khô các hồ nhỏ hơn, mùa mưa nước dâng lên tràn bờ rất đẹp. Được ví như ''vịnh Hạ Long trên cạn'' của Cao Bằng.',
  'Mở cửa tự do, không có giờ cố định', NULL, 'Thời điểm đẹp nhất để chụp ảnh là sáng sớm khi có sương mù bao phủ mặt hồ. Đường vào có thể khó đi vào mùa mưa, nên hỏi thêm tình trạng đường tại địa phương.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '3b336ae8-b707-400c-a1bb-2ceff029cd64', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Núi Mắt Thần (Thiên Đường)', 'mountain',
  'Huyện Hạ Lang, tỉnh Cao Bằng', 22.6833, 106.7333, 'Ngọn núi đá vôi có một lỗ hổng tự nhiên hình tròn gần đỉnh, ánh sáng mặt trời chiếu qua tạo nên hiện tượng ''mắt thần'' ấn tượng. Điểm tham quan mới nổi của Cao Bằng, thu hút đông đảo nhiếp ảnh gia và phượt thủ.',
  'Tự do tham quan ban ngày', '// TODO: xác nhận tại UBND huyện Hạ Lang hoặc Sở Du lịch Cao Bằng', 'Ánh sáng qua lỗ tốt nhất vào khoảng 10:00–14:00. Cần leo bộ khoảng 30 phút, đường dốc — mang giày leo núi.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '815d0d7e-e6de-4116-bf43-7ecda4b9d09e', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Chợ Cao Bằng', 'market',
  'Phường Hợp Giang, TP. Cao Bằng, tỉnh Cao Bằng', 22.6668, 106.2614, 'Chợ trung tâm thành phố Cao Bằng, nơi tập trung sản vật địa phương như hạt dẻ Trùng Khánh, miến dong, thịt lợn đen, rau rừng và các loại thổ cẩm của đồng bào dân tộc Tày, Nùng. Chợ phiên họp định kỳ có nhiều người dân tộc xuống núi bán hàng.',
  '5:00–18:00 hằng ngày', NULL, 'Đến sáng sớm trước 8:00 để mua hạt dẻ tươi và thực phẩm tươi nhất. Mặc cả nhẹ nhàng và lịch sự.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '122caad4-1582-4031-8787-0c59b317f7f3', 'aa20e516-ea38-4c41-9bd2-7de71095647e', 'Khu Di tích Lịch sử Quốc gia Đặc biệt Rừng Trần Hưng Đạo', 'attraction',
  'Xã Tam Kim, huyện Nguyên Bình, tỉnh Cao Bằng', 22.5167, 105.95, 'Khu rừng thiêng liêng nơi Đội Việt Nam Tuyên truyền Giải phóng quân — tiền thân của Quân đội Nhân dân Việt Nam — được thành lập ngày 22/12/1944. Đây là địa chỉ đỏ quan trọng của lịch sử cách mạng, có nhà trưng bày và các khu tái hiện.',
  '7:00–17:00 các ngày trong tuần — xác nhận trước khi đến', '// TODO: xác nhận tại Ban Quản lý Di tích hoặc Sở Văn hóa Cao Bằng', 'Kết hợp chuyến thăm với hang Pác Bó để hiểu toàn cảnh lịch sử cách mạng Cao Bằng. Nên có hướng dẫn viên địa phương để hiểu sâu hơn.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7f2b-a944-c1c953ef1d9e', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Thác Dray Nur', 'nature',
  'Thôn Buôn Kuốp, xã Ea Na (giáp ranh Đắk Lắk – Đắk Nông)', 12.5667, 108.0167, 'Ngọn thác lớn nhất trên hệ thống sông Sêrêpôk, còn gọi là ''thác Vợ'' (Dray Nur tiếng Ê Đê), cao khoảng 30m và dài hơn 250m, tạo thành bức tường nước trắng xóa nối liền hai tỉnh Đắk Lắk và Đắk Nông qua một cây cầu treo. Phía sau màn nước có hang đá tự nhiên, là nơi sinh sống của một đàn dơi lớn thường bay ra vào buổi chiều.',
  '6:00–18:00 hằng ngày — xác nhận trước khi đến', NULL, 'Đẹp nhất vào mùa mưa (tháng 6–10) khi nước đổ mạnh, nhưng mùa khô (tháng 2–5) lại an toàn hơn để tắm suối và dễ chụp ảnh hơn vì nước chia thành nhiều nhánh nhỏ. Nên kết hợp tham quan luôn thác Dray Sáp liền kề qua cầu treo.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-75e1-9af4-406063c4dabd', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Hồ Lắk', 'nature',
  'Thị trấn Liên Sơn, huyện Lắk, tỉnh Đắk Lắk', 12.4333, 108.2, 'Hồ nước ngọt tự nhiên lớn thứ hai Việt Nam (chỉ sau hồ Ba Bể), bao quanh bởi rừng thông, núi đồi và các buôn làng người M''nông như buôn Jun, buôn Lê. Du khách có thể ngồi thuyền độc mộc ngắm hoàng hôn, tham quan nhà dài truyền thống và nghe trình diễn cồng chiêng, đàn đá, đàn T''rưng.',
  'Cả ngày — xác nhận giờ hoạt động dịch vụ thuyền trước khi đến', NULL, 'Kết hợp tham quan Buôn Jun – Buôn Lê ngay cạnh hồ để tìm hiểu văn hóa M''nông. Hồ cách trung tâm Buôn Ma Thuột khá xa (khoảng 56km) nên cần bố trí cả ngày hoặc nghỉ đêm tại khu vực này.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7f0b-aaea-66ade05b139c', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Khu du lịch Buôn Đôn', 'attraction',
  'Xã Krông Na, huyện Buôn Đôn, tỉnh Đắk Lắk', 12.95, 107.8333, 'Vùng đất gắn liền với nghề săn bắt và thuần dưỡng voi rừng nổi tiếng của người Ê Đê, M''nông, nằm bên dòng sông Sêrêpôk. Du khách có thể tham quan cầu treo bắc qua sông, mộ vua săn voi Khunjunop, nhà dài cổ và tìm hiểu đời sống văn hóa bản địa.',
  '7:00–17:00 — xác nhận trước khi đến', NULL, 'Các hoạt động cưỡi voi truyền thống đang dần được thay thế bằng các hình thức du lịch thân thiện với voi (xem voi, cho voi ăn) theo xu hướng bảo vệ động vật — nên hỏi trực tiếp đơn vị tổ chức về hình thức trải nghiệm trước khi đặt tour.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7439-92ba-060ea5aa057d', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Vườn quốc gia Yok Đôn', 'nature',
  'Xã Krông Na, huyện Buôn Đôn, tỉnh Đắk Lắk', 13.0167, 107.6833, 'Khu rừng đặc dụng lớn nhất Việt Nam, diện tích hơn 115.000ha, là nơi duy nhất tại Việt Nam còn bảo tồn hệ sinh thái rừng khộp (rừng thưa rụng lá theo mùa). Du khách có thể trekking xuyên rừng, chèo thuyền trên sông Sêrêpôk, cắm trại qua đêm tại trạm kiểm lâm và quan sát động vật hoang dã như voi, bò tót.',
  '7:00–17:00 — xác nhận trước khi đến', 'Khoảng 60.000đ/người lớn (Nam Thiên Travel, 06/2026 — có thể thay đổi, nên xác nhận lại tại quầy vé)', 'Phù hợp cho người yêu trekking và khám phá sinh thái hoang dã — nên mang giày leo núi, áo dài tay và thuê hướng dẫn viên kiểm lâm vì rừng rộng và một số khu vực không có sóng điện thoại.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-737a-a66b-b552346011e1', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Nhà đày Buôn Ma Thuột', 'attraction',
  '18 Tán Thuật, thành phố Buôn Ma Thuột, tỉnh Đắk Lắk', 12.6803, 108.0408, 'Di tích lịch sử quốc gia đặc biệt do thực dân Pháp xây dựng năm 1930 để giam giữ các chiến sĩ cách mạng Việt Nam. Hiện được bảo tồn nguyên trạng với hệ thống xà lim, cùm sắt và nhiều hiện vật lịch sử, giúp du khách hiểu thêm về một giai đoạn đấu tranh của dân tộc tại Tây Nguyên.',
  '7:30–17:00 (thứ Hai – thứ Sáu) — xác nhận trước khi đến vì có thể đóng cửa cuối tuần', NULL, 'Phù hợp cho du khách yêu thích tìm hiểu lịch sử; nên dành khoảng 45–60 phút để tham quan đầy đủ các khu trưng bày.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7083-a193-d75897a81e30', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Bảo tàng Thế giới Cà phê', 'museum',
  'Đường Nguyễn Đình Chiểu, phường Tân Lợi, thành phố Buôn Ma Thuột (khu đô thị Thành phố Cà phê)', 12.6964, 108.0508, 'Tổ hợp văn hóa rộng khoảng 45ha do Tập đoàn Trung Nguyên Legend xây dựng, khai trương tháng 11/2018, lấy cảm hứng kiến trúc từ nhà dài truyền thống của người Ê Đê. Trưng bày hơn 10.000 hiện vật liên quan đến văn hóa cà phê từ nhiều quốc gia trên thế giới, kết hợp không gian triển lãm tương tác đa giác quan và khu vực thưởng thức cà phê.',
  '7:00–18:00 hằng ngày (giờ đóng cửa bán vé có thể sớm hơn giờ đóng cửa tham quan) — xác nhận trước khi đến vì giờ mở cửa được báo cáo có chênh lệch nhẹ giữa các nguồn', 'Khoảng 70.000–75.000đ/người lớn, 40.000đ/trẻ em (Traveloka & KKday, 06/2026 — giá có thể đã bao gồm 1 ly cà phê, nên xác nhận lại khi mua vé)', 'Nên đến vào buổi sáng hoặc đầu giờ chiều để có ánh sáng tự nhiên đẹp cho việc chụp ảnh tại khu kiến trúc 5 mái nhà cong và thư viện ánh sáng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7cfc-b46b-658eca9794ac', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Buôn Ako Dhong (Buôn Cô Thôn)', 'attraction',
  'Phường Tân Lợi, thành phố Buôn Ma Thuột (cách trung tâm khoảng 2–3km về phía Bắc)', 12.6917, 108.0444, 'Được gọi là ''buôn trong phố'' vì nằm ngay trong lòng thành phố Buôn Ma Thuột, là nơi cư ngụ của đồng bào Ê Đê còn lưu giữ kiến trúc nhà dài truyền thống, nghề dệt thổ cẩm và văn hóa cồng chiêng. ''Ako'' trong tiếng Ê Đê nghĩa là đầu nguồn, ''Dhong'' là lũng — phản ánh vị trí buôn nằm ở đầu một con suối nhỏ.',
  'Cả ngày — nên tham quan ban ngày để gặp được người dân sinh hoạt', NULL, 'Có thể kết hợp ghé thăm các quán cà phê sân vườn trong buôn để vừa thưởng thức cà phê vừa quan sát kiến trúc nhà dài; nên giữ ý tứ và xin phép trước khi chụp ảnh người dân hoặc vào nhà dài.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7ade-bd84-975cde5f84d0', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Thác Thủy Tiên', 'nature',
  'Huyện Krông Năng, tỉnh Đắk Lắk', 12.9333, 108.3833, 'Còn gọi là thác Ba Tầng, dòng thác chia thành ba tầng nước đổ qua rừng nguyên sinh, tầng thấp nhất tạo thành hồ nước có thể tắm được. Vào mùa khô thác chảy hiền hòa như suối tóc, mùa mưa thì nước đổ mạnh và hoang dại hơn. Ít được khai thác du lịch đại trà nên còn giữ được nét hoang sơ.',
  '6:00–18:00 — xác nhận trước khi đến vì đường vào còn ít được khai thác dịch vụ', NULL, 'Đường vào thác khá xa trung tâm và chưa thuận tiện, phù hợp với người thích khám phá/trekking hơn là đi nghỉ dưỡng; nên đi cùng nhóm hoặc người địa phương rành đường.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7f2b-a944-c1c953ef1d9e', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Thác Dray Nur', 'nature',
  'Thôn Buôn Kuốp, xã Ea Na (giáp ranh Đắk Lắk – Đắk Nông)', 12.5667, 108.0167, 'Ngọn thác lớn nhất trên hệ thống sông Sêrêpôk, còn gọi là ''thác Vợ'' (Dray Nur tiếng Ê Đê), cao khoảng 30m và dài hơn 250m, tạo thành bức tường nước trắng xóa nối liền hai tỉnh Đắk Lắk và Đắk Nông qua một cây cầu treo. Phía sau màn nước có hang đá tự nhiên, là nơi sinh sống của một đàn dơi lớn thường bay ra vào buổi chiều.',
  '6:00–18:00 hằng ngày — xác nhận trước khi đến', NULL, 'Đẹp nhất vào mùa mưa (tháng 6–10) khi nước đổ mạnh, nhưng mùa khô (tháng 2–5) lại an toàn hơn để tắm suối và dễ chụp ảnh hơn vì nước chia thành nhiều nhánh nhỏ. Nên kết hợp tham quan luôn thác Dray Sáp liền kề qua cầu treo.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-75e1-9af4-406063c4dabd', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Hồ Lắk', 'nature',
  'Thị trấn Liên Sơn, huyện Lắk, tỉnh Đắk Lắk', 12.4333, 108.2, 'Hồ nước ngọt tự nhiên lớn thứ hai Việt Nam (chỉ sau hồ Ba Bể), bao quanh bởi rừng thông, núi đồi và các buôn làng người M''nông như buôn Jun, buôn Lê. Du khách có thể ngồi thuyền độc mộc ngắm hoàng hôn, tham quan nhà dài truyền thống và nghe trình diễn cồng chiêng, đàn đá, đàn T''rưng.',
  'Cả ngày — xác nhận giờ hoạt động dịch vụ thuyền trước khi đến', NULL, 'Kết hợp tham quan Buôn Jun – Buôn Lê ngay cạnh hồ để tìm hiểu văn hóa M''nông. Hồ cách trung tâm Buôn Ma Thuột khá xa (khoảng 56km) nên cần bố trí cả ngày hoặc nghỉ đêm tại khu vực này.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7f0b-aaea-66ade05b139c', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Khu du lịch Buôn Đôn', 'attraction',
  'Xã Krông Na, huyện Buôn Đôn, tỉnh Đắk Lắk', 12.95, 107.8333, 'Vùng đất gắn liền với nghề săn bắt và thuần dưỡng voi rừng nổi tiếng của người Ê Đê, M''nông, nằm bên dòng sông Sêrêpôk. Du khách có thể tham quan cầu treo bắc qua sông, mộ vua săn voi Khunjunop, nhà dài cổ và tìm hiểu đời sống văn hóa bản địa.',
  '7:00–17:00 — xác nhận trước khi đến', NULL, 'Các hoạt động cưỡi voi truyền thống đang dần được thay thế bằng các hình thức du lịch thân thiện với voi (xem voi, cho voi ăn) theo xu hướng bảo vệ động vật — nên hỏi trực tiếp đơn vị tổ chức về hình thức trải nghiệm trước khi đặt tour.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7439-92ba-060ea5aa057d', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Vườn quốc gia Yok Đôn', 'nature',
  'Xã Krông Na, huyện Buôn Đôn, tỉnh Đắk Lắk', 13.0167, 107.6833, 'Khu rừng đặc dụng lớn nhất Việt Nam, diện tích hơn 115.000ha, là nơi duy nhất tại Việt Nam còn bảo tồn hệ sinh thái rừng khộp (rừng thưa rụng lá theo mùa). Du khách có thể trekking xuyên rừng, chèo thuyền trên sông Sêrêpôk, cắm trại qua đêm tại trạm kiểm lâm và quan sát động vật hoang dã như voi, bò tót.',
  '7:00–17:00 — xác nhận trước khi đến', 'Khoảng 60.000đ/người lớn (Nam Thiên Travel, 06/2026 — có thể thay đổi, nên xác nhận lại tại quầy vé)', 'Phù hợp cho người yêu trekking và khám phá sinh thái hoang dã — nên mang giày leo núi, áo dài tay và thuê hướng dẫn viên kiểm lâm vì rừng rộng và một số khu vực không có sóng điện thoại.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-737a-a66b-b552346011e1', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Nhà đày Buôn Ma Thuột', 'attraction',
  '18 Tán Thuật, thành phố Buôn Ma Thuột, tỉnh Đắk Lắk', 12.6803, 108.0408, 'Di tích lịch sử quốc gia đặc biệt do thực dân Pháp xây dựng năm 1930 để giam giữ các chiến sĩ cách mạng Việt Nam. Hiện được bảo tồn nguyên trạng với hệ thống xà lim, cùm sắt và nhiều hiện vật lịch sử, giúp du khách hiểu thêm về một giai đoạn đấu tranh của dân tộc tại Tây Nguyên.',
  '7:30–17:00 (thứ Hai – thứ Sáu) — xác nhận trước khi đến vì có thể đóng cửa cuối tuần', NULL, 'Phù hợp cho du khách yêu thích tìm hiểu lịch sử; nên dành khoảng 45–60 phút để tham quan đầy đủ các khu trưng bày.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7083-a193-d75897a81e30', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Bảo tàng Thế giới Cà phê', 'museum',
  'Đường Nguyễn Đình Chiểu, phường Tân Lợi, thành phố Buôn Ma Thuột (khu đô thị Thành phố Cà phê)', 12.6964, 108.0508, 'Tổ hợp văn hóa rộng khoảng 45ha do Tập đoàn Trung Nguyên Legend xây dựng, khai trương tháng 11/2018, lấy cảm hứng kiến trúc từ nhà dài truyền thống của người Ê Đê. Trưng bày hơn 10.000 hiện vật liên quan đến văn hóa cà phê từ nhiều quốc gia trên thế giới, kết hợp không gian triển lãm tương tác đa giác quan và khu vực thưởng thức cà phê.',
  '7:00–18:00 hằng ngày (giờ đóng cửa bán vé có thể sớm hơn giờ đóng cửa tham quan) — xác nhận trước khi đến vì giờ mở cửa được báo cáo có chênh lệch nhẹ giữa các nguồn', 'Khoảng 70.000–75.000đ/người lớn, 40.000đ/trẻ em (Traveloka & KKday, 06/2026 — giá có thể đã bao gồm 1 ly cà phê, nên xác nhận lại khi mua vé)', 'Nên đến vào buổi sáng hoặc đầu giờ chiều để có ánh sáng tự nhiên đẹp cho việc chụp ảnh tại khu kiến trúc 5 mái nhà cong và thư viện ánh sáng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7cfc-b46b-658eca9794ac', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Buôn Ako Dhong (Buôn Cô Thôn)', 'attraction',
  'Phường Tân Lợi, thành phố Buôn Ma Thuột (cách trung tâm khoảng 2–3km về phía Bắc)', 12.6917, 108.0444, 'Được gọi là ''buôn trong phố'' vì nằm ngay trong lòng thành phố Buôn Ma Thuột, là nơi cư ngụ của đồng bào Ê Đê còn lưu giữ kiến trúc nhà dài truyền thống, nghề dệt thổ cẩm và văn hóa cồng chiêng. ''Ako'' trong tiếng Ê Đê nghĩa là đầu nguồn, ''Dhong'' là lũng — phản ánh vị trí buôn nằm ở đầu một con suối nhỏ.',
  'Cả ngày — nên tham quan ban ngày để gặp được người dân sinh hoạt', NULL, 'Có thể kết hợp ghé thăm các quán cà phê sân vườn trong buôn để vừa thưởng thức cà phê vừa quan sát kiến trúc nhà dài; nên giữ ý tứ và xin phép trước khi chụp ảnh người dân hoặc vào nhà dài.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eeef1-4b2d-7ade-bd84-975cde5f84d0', '9193ad16-91b7-43cd-86bf-e208fcdc43f1', 'Thác Thủy Tiên', 'nature',
  'Huyện Krông Năng, tỉnh Đắk Lắk', 12.9333, 108.3833, 'Còn gọi là thác Ba Tầng, dòng thác chia thành ba tầng nước đổ qua rừng nguyên sinh, tầng thấp nhất tạo thành hồ nước có thể tắm được. Vào mùa khô thác chảy hiền hòa như suối tóc, mùa mưa thì nước đổ mạnh và hoang dại hơn. Ít được khai thác du lịch đại trà nên còn giữ được nét hoang sơ.',
  '6:00–18:00 — xác nhận trước khi đến vì đường vào còn ít được khai thác dịch vụ', NULL, 'Đường vào thác khá xa trung tâm và chưa thuận tiện, phù hợp với người thích khám phá/trekking hơn là đi nghỉ dưỡng; nên đi cùng nhóm hoặc người địa phương rành đường.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '3b6f6068-4cd8-4210-86bd-1396606cc9d9', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Đồi A1 (Eliane 2)', 'attraction',
  'Đường Hoàng Văn Thái, TP. Điện Biên Phủ, tỉnh Điện Biên', 21.3833, 103.0197, 'Cứ điểm quan trọng nhất trong chiến dịch Điện Biên Phủ 1954, nơi diễn ra trận đánh ác liệt nhất trong 56 ngày đêm. Trên đồi vẫn còn hố bom khổng lồ do quân ta đặt mìn phá vỡ hầm ngầm của Pháp, xác xe tăng và các công sự bê tông. Đây là di tích được bảo tồn nguyên vẹn nhất trong quần thể Điện Biên Phủ.',
  '7:00–17:00 hằng ngày — xác nhận trước khi đến', '// TODO: xác nhận tại Ban Quản lý Khu Di tích Điện Biên Phủ hoặc dienbien.gov.vn', 'Đến buổi sáng sớm để tránh nắng — đồi trống, ít bóng cây. Mang theo nước uống. Nên đi cùng hướng dẫn viên để hiểu đầy đủ ý nghĩa lịch sử từng vị trí trên đồi.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'b47a26c4-96cf-41cb-b9a1-1d12fe484df2', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Hầm Chỉ Huy Đờ Cát (De Castries)', 'museum',
  'Đường 7/5, TP. Điện Biên Phủ, tỉnh Điện Biên', 21.3892, 103.0169, 'Hầm chỉ huy ngầm của Tướng Christian de Castries, nơi ông đầu hàng Đại tướng Võ Nguyên Giáp ngày 7/5/1954, kết thúc chiến dịch Điện Biên Phủ lịch sử. Hầm được tái dựng nguyên trạng với bàn ghế, bản đồ tác chiến và các hiện vật thời kỳ đó. Là điểm tham quan biểu tượng nhất của quần thể di tích.',
  '7:00–17:00 hằng ngày — xác nhận trước khi đến', '// TODO: xác nhận tại Ban Quản lý Khu Di tích Điện Biên Phủ', 'Kết hợp với Đồi A1 và Nghĩa trang Độc Lập thành hành trình nửa ngày. Có thuyết minh viên tại chỗ, nên đặt trước nếu đi nhóm.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'cd06475e-b556-468f-b1b4-dd3cb6dfddcb', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Bảo tàng Chiến thắng Điện Biên Phủ', 'museum',
  'Đường Võ Nguyên Giáp, TP. Điện Biên Phủ, tỉnh Điện Biên', 21.3868, 103.0155, 'Bảo tàng quốc gia lưu giữ hơn 1.000 hiện vật gốc về chiến dịch Điện Biên Phủ: vũ khí, quân trang, bản đồ tác chiến, hình ảnh và tài liệu lịch sử. Có sa bàn lớn mô phỏng toàn bộ trận địa và màn hình trình chiếu tóm tắt diễn biến chiến dịch. Nơi bắt đầu lý tưởng để hiểu tổng thể trước khi thăm các di tích ngoài trời.',
  '7:30–11:30 và 13:30–17:00 (trừ thứ 2) — xác nhận trước khi đến', '// TODO: xác nhận tại Bảo tàng hoặc dienbien.gov.vn', 'Vào bảo tàng trước, xem sa bàn để hiểu toàn cảnh, rồi mới ra các di tích ngoài trời — trải nghiệm sẽ sâu hơn nhiều. Cho phép chụp ảnh trong hầu hết khu vực.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'ecd579da-8755-4957-b0d2-99c244215f0b', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Nghĩa trang Liệt sĩ Điện Biên Phủ (A1)', 'attraction',
  'Đường Hoàng Văn Thái, TP. Điện Biên Phủ, tỉnh Điện Biên', 21.3841, 103.0189, 'Nghĩa trang liệt sĩ ngay dưới chân Đồi A1, nơi an nghỉ của hơn 640 chiến sĩ hy sinh trong trận Điện Biên Phủ. Không gian trang nghiêm với hàng ngàn ngôi mộ trắng xếp đều, có tượng đài trung tâm và khu tưởng niệm. Là điểm dừng chân mang ý nghĩa tinh thần sâu sắc với mọi du khách.',
  'Mở cửa tự do', NULL, 'Ăn mặc lịch sự, giữ yên lặng và thái độ trang trọng. Nên ghé thăm vào buổi chiều mát để cảm nhận không gian linh thiêng hơn.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '16acc5b0-579b-463b-b378-892173540c27', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Cánh Đồng Mường Thanh', 'nature',
  'Thành phố Điện Biên Phủ và vùng lân cận, tỉnh Điện Biên', 21.4, 103.0, 'Thung lũng lòng chảo lớn nhất Tây Bắc, rộng hơn 150km², bao quanh bởi núi non trùng điệp. Nơi đây từng là chiến trường lịch sử, nay là vùng đất nông nghiệp trù phú của người Thái với những cánh đồng lúa xanh mướt trải dài. Đẹp nhất vào mùa lúa chín tháng 9–10 hay mùa cấy tháng 5–6.',
  'Tự do tham quan', NULL, 'Thuê xe máy để chạy một vòng quanh cánh đồng lúc bình minh hoặc hoàng hôn — ánh sáng và cảnh sắc rất đẹp. Mùa lúa chín tháng 9–10 màu vàng óng rất ấn tượng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '9d4d130e-1504-455c-a9c7-1cae949a2117', '01c26442-a471-48e6-b6f1-dc3036aa718e', 'Bản Văn Khoa (Làng Văn Hóa Thái)', 'attraction',
  'Xã Thanh Minh, TP. Điện Biên Phủ, tỉnh Điện Biên', 21.37, 102.99, 'Bản người Thái trắng còn giữ nguyên nếp nhà sàn truyền thống, trang phục và phong tục sinh hoạt. Du khách có thể trải nghiệm ở lại nhà sàn, tham gia múa xòe Thái, thưởng thức rượu cần và ẩm thực bản địa. Là điểm văn hóa bổ sung hoàn hảo bên cạnh tuyến di tích lịch sử.',
  'Tự do, nên hỏi trước chủ bản', NULL, 'Nên liên hệ trước qua khách sạn hoặc tour địa phương để được đón tiếp. Ăn mặc kín đáo và tôn trọng phong tục khi vào nhà sàn.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'fa97b50a-dfc8-4b19-9a47-26cd1ec72328', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Vườn Quốc gia Nam Cát Tiên', 'nature',
  'Huyện Tân Phú, Đồng Nai (phần lớn nằm ở huyện Tân Phú và Vĩnh Cửu)', 11.4312, 107.4307, 'Một trong những vườn quốc gia lớn nhất và đa dạng sinh học nhất Việt Nam, được UNESCO công nhận là Khu dự trữ sinh quyển thế giới. Diện tích hơn 71.000 ha với hệ sinh thái rừng nguyên sinh, nơi sinh sống của bò tót, tê giác một sừng Java (đã tuyệt chủng tại đây từ 2011), và hàng trăm loài chim quý. Điểm highlight: Bàu Sấu (đầm nước ngọt) và Đảo Tiên.',
  'Mở cửa 24/7 (khu lưu trú và tour cần đặt trước) — xác nhận tại ban quản lý', NULL, 'Mùa khô (tháng 12–4) dễ quan sát thú hơn vì nước cạn, thú tập trung ra bàu uống nước. Đặt tour nội bộ trong vườn từ Trung tâm Du lịch Sinh thái Nam Cát Tiên trước ít nhất 1 tuần vào mùa cao điểm. Mang thuốc chống côn trùng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'afac5543-1a2f-463c-a0fe-f8db98554ba0', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Thác Giang Điền', 'nature',
  'Xã Giang Điền, Huyện Trảng Bom, Đồng Nai (cách TP.HCM ~60km)', 10.9982, 107.0521, 'Thác nước tự nhiên đẹp nằm trong khu du lịch sinh thái rộng lớn với nhiều hoạt động như: chèo thuyền kayak, cáp treo qua thác, leo núi, camping qua đêm và picnic. Là điểm dã ngoại cuối tuần rất phổ biến của người TP.HCM và Biên Hòa.',
  '7:00–17:30 — xác nhận tại Google Maps trước khi đến', NULL, 'Đặt vé trước dịp lễ vì rất đông. Nên đến sáng sớm để tránh nắng. Mang đồ bơi và thay quần áo nếu muốn tắm thác.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'ab320f1c-e746-4b02-8f17-c984b5a7d923', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Vườn Bưởi Tân Triều', 'nature',
  'Xã Tân Bình, Huyện Vĩnh Cửu, Đồng Nai (cách Biên Hòa ~10km)', 10.982, 106.987, 'Vùng trồng bưởi truyền thống lâu đời nhất Đồng Nai, nơi bưởi Tân Triều được coi là đặc sản nổi tiếng nhất tỉnh. Du khách có thể tham quan vườn, hái bưởi trực tiếp (mùa chính tháng 11–2) và mua về làm quà. Ngoài bưởi còn có măng cụt, sầu riêng theo mùa.',
  'Thường 7:00–17:00, liên hệ vườn trước khi đến', NULL, 'Mùa bưởi chín nhất: tháng 11–tháng 2 (dịp Tết). Gọi điện đặt trước để có người hướng dẫn trong vườn. Kết hợp với tham quan Văn miếu Trấn Biên gần đó.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '233a9c9c-def9-4764-aafa-a3cc0f6693fd', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Văn miếu Trấn Biên', 'museum',
  'Phường Bửu Long, TP. Biên Hòa, Đồng Nai', 10.975, 106.932, 'Văn miếu lớn nhất Nam Bộ, được xây dựng lại năm 1998 trên nền văn miếu cổ từ thế kỷ 18 (1715). Kiến trúc đặc sắc theo phong cách Việt – Hoa cổ điển, thờ Khổng Tử và các danh nhân văn hóa Việt Nam. Không gian yên tĩnh, khuôn viên đẹp với hồ nước và cây cổ thụ.',
  '7:30–11:30 và 13:30–17:00, nghỉ thứ Hai — xác nhận trước khi đến', 'Miễn phí', 'Miễn phí vào cửa. Nên đọc về lịch sử trước để hiểu hơn về ý nghĩa văn hóa. Phù hợp kết hợp với thăm vườn bưởi Tân Triều cùng buổi.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '7f494247-d77c-4e62-8f4b-58971fa20e56', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Hồ Trị An', 'nature',
  'Huyện Vĩnh Cửu, Đồng Nai (lòng hồ tiếp giáp rừng Nam Cát Tiên)', 11.137, 107.108, 'Một trong những hồ nhân tạo lớn nhất Việt Nam (323 km²), được tạo ra từ đập thủy điện Trị An trên sông Đồng Nai. Hồ bao quanh bởi rừng nguyên sinh, là thiên đường cho du thuyền, câu cá, ngắm bình minh/hoàng hôn trên mặt hồ mênh mông và cắm trại ven bờ.',
  'Mở cửa hằng ngày — xác nhận giờ tour thuyền tại địa phương', NULL, 'Đặt tour thuyền câu cá hoặc du thuyền qua đêm tại các điểm cho thuê ven hồ. Mang áo ấm nếu cắm trại vì đêm trên hồ se lạnh. Kết hợp với Nam Cát Tiên trong cùng chuyến đi.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'dd308d2e-5a99-4d57-8b8b-487692c1727c', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Vườn Quốc gia Bù Gia Mập', 'nature',
  'Huyện Bù Gia Mập, Bình Phước (nay thuộc Đồng Nai sau sáp nhập 2025)', 12.168, 107.195, 'Vườn quốc gia giáp biên giới Campuchia, nằm ở phần tỉnh Bình Phước cũ (nay thuộc Đồng Nai sau sáp nhập Nghị quyết 202/2025). Diện tích ~26.000 ha với rừng nhiệt đới còn nguyên sinh, nơi sinh sống của voi, bò tót, voọc chà vá chân đen. Ít khách du lịch hơn Nam Cát Tiên nên trải nghiệm hoang dã hơn.',
  'Mở cửa hằng ngày, cần đăng ký tham quan với ban quản lý', NULL, 'Cần liên hệ ban quản lý trước để đăng ký tour. Mang đủ đồ cắm trại và lương thực vì xa trung tâm. Phù hợp nhóm ưa mạo hiểm.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'a0c9f410-8b57-4c59-a191-0165f2d31169', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Thác Đứng (Voi) — Bình Phước', 'nature',
  'Huyện Bù Đốp, Bình Phước (nay thuộc Đồng Nai sau sáp nhập 2025)', 11.921, 106.845, 'Thác nước hùng vĩ ở vùng biên giới Bình Phước cũ, nay thuộc Đồng Nai sau sáp nhập 2025. Thác cao khoảng 20m đổ xuống vực đá tạo cảnh quan hoang sơ đặc biệt, ít được biết đến nên còn giữ được nét hoang dã. Khu vực xung quanh là rừng già và đất nông nghiệp của đồng bào dân tộc thiểu số.',
  'Thường 7:00–17:00 — xác nhận tại địa phương', NULL, 'Đường vào còn khó đi, nên đi xe gầm cao hoặc thuê xe địa phương. Mang thức ăn và nước uống riêng. Nên đi nhóm.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '75741fd1-337b-4e8c-8bc9-6120f0ad4790', '0a193ffa-e0a2-401c-8e6f-f54630558a65', 'Phố cổ Biên Hòa & Chùa Ông', 'attraction',
  'Phường Hiệp Hòa, TP. Biên Hòa, Đồng Nai', 10.9458, 106.8196, 'Khu phố cổ người Hoa tại cù lao Phố (Hiệp Hòa) — một trong những đô thị cổ nhất miền Nam, từng là trung tâm thương mại sầm uất thế kỷ 17–18. Chùa Ông (Thất Phủ Cổ Miếu) xây năm 1684 là một trong những ngôi chùa Hoa cổ nhất Nam Bộ. Nơi đây gắn với lịch sử người Minh Hương khai phá đất phương Nam.',
  'Chùa Ông: 6:00–18:00 hằng ngày', 'Miễn phí', 'Miễn phí vào cửa chùa. Nên đến buổi sáng sớm khi khói nhang đẹp. Kết hợp tản bộ tham quan kiến trúc nhà cổ người Hoa trên đảo.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '35bfc90b-c189-49cc-ad2b-2dd42d1b3d95', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Hồ Hoàn Kiếm (Hồ Gươm)', 'attraction',
  'Phố Đinh Tiên Hoàng, phường Hàng Trống, quận Hoàn Kiếm, Hà Nội', 21.0285, 105.8524, 'Hồ nước tự nhiên trung tâm Hà Nội, gắn truyền thuyết vua Lê Lợi trả gươm thần. Có Tháp Rùa giữa hồ và cầu Thê Húc dẫn vào đền Ngọc Sơn.',
  'Mở 24/7 (không gian công cộng); Đền Ngọc Sơn ~7:00–18:00', 'Miễn phí khu hồ; vé Đền Ngọc Sơn ước ~30.000đ (cần xác nhận tại cổng)', 'Đi dạo sáng sớm 6:00–7:00 hoặc tối cuối tuần khi quanh hồ thành phố đi bộ.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '58e365aa-5c8c-4488-92c5-f60d0b67299c', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Văn Miếu - Quốc Tử Giám', 'temple',
  '58 Phố Quốc Tử Giám, phường Quốc Tử Giám, quận Đống Đa, Hà Nội', 21.0292, 105.8355, 'Trường đại học đầu tiên của Việt Nam (thành lập 1070), thờ Khổng Tử, nổi tiếng với 82 bia tiến sĩ đặt trên lưng rùa đá.',
  '8:00–17:00 hằng ngày', '~30.000đ/người lớn (ước tính, cần xác nhận giá hiện hành)', 'Học sinh/sinh viên thường đến đây cầu may trước kỳ thi, chạm vào đầu rùa đá là điều cấm (bảo tồn di tích).', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '9b8f897a-a1cf-4938-ad0b-11faf6ad72ce', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Lăng Chủ tịch Hồ Chí Minh', 'attraction',
  'số 8 phố Hùng Vương, phường Điện Biên, quận Ba Đình, Hà Nội', 21.0368, 105.8342, 'Nơi lưu giữ và bảo quản thi hài Chủ tịch Hồ Chí Minh, kiến trúc đá hoa cương trang nghiêm, nằm trong quần thể Quảng trường Ba Đình.',
  'Sáng 7:30–10:30 (Thứ 3–Thứ 5, Thứ 7, Chủ Nhật); đóng cửa Thứ 2 & Thứ 6', 'Miễn phí', 'Trang phục lịch sự, không nói to, không chụp ảnh trong lăng; nên đến sớm vì thường đông và có kiểm tra an ninh.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '08d46bfc-2dea-444c-8636-820cb4dddf1a', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Chùa Một Cột (Diên Hựu tự)', 'temple',
  'Trong khuôn viên gần Quảng trường Ba Đình, quận Ba Đình, Hà Nội', 21.0365, 105.8332, 'Ngôi chùa nhỏ độc đáo dựng trên một cột đá giữa hồ sen, được xây dựng lại nhiều lần qua các thời kỳ, mang tính biểu tượng kiến trúc Phật giáo Việt Nam.',
  '~8:00–17:00', 'Miễn phí hoặc vé rất nhỏ tùy thời điểm (cần xác nhận)', 'Nên kết hợp ghé cùng buổi với Lăng Bác và Bảo tàng Hồ Chí Minh vì nằm sát nhau.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'a0484c7d-a78d-4420-a854-c6fde7787aa2', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Hoàng thành Thăng Long', 'museum',
  '19C Hoàng Diệu, phường Điện Biên, quận Ba Đình, Hà Nội', 21.0352, 105.8398, 'Di sản Văn hóa Thế giới UNESCO, di tích khảo cổ và kiến trúc cung đình qua nhiều triều đại từ thời Lý đến Nguyễn.',
  '8:00–17:00, đóng Thứ 2', '~30.000đ/người lớn (ước tính, cần xác nhận)', 'Nên thuê hướng dẫn viên hoặc audio guide để hiểu rõ các lớp di tích khảo cổ.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'd1663179-86bf-47a3-9e0c-2c0ce0f770f3', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Phố cổ Hà Nội (khu 36 phố phường)', 'attraction',
  'Khu vực quanh các phố Hàng Bạc, Hàng Gai, Hàng Mã, Tạ Hiện, quận Hoàn Kiếm', 21.0333, 105.85, 'Khu phố cổ buôn bán lâu đời, mỗi phố gắn với một nghề truyền thống (Hàng Bạc - bạc, Hàng Mã - đồ giấy...), nổi tiếng với phố đi bộ và phố ăn đêm Tạ Hiện.',
  'Cả ngày, sôi động nhất buổi tối', 'Miễn phí (khu vực công cộng)', 'Tạ Hiện về đêm là khu ''bia hơi'' sôi động nhất, nên đi cùng nhóm và cẩn thận giữ đồ cá nhân chỗ đông người.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  'ac29a763-f18c-4fa6-9498-a167efd3c9a1', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Hồ Tây', 'nature',
  'Quận Tây Hồ, Hà Nội', 21.057, 105.82, 'Hồ nước ngọt lớn nhất Hà Nội, xung quanh có nhiều quán cà phê view hồ, chùa Trấn Quốc, phủ Tây Hồ và là nơi đạp xe/đi dạo phổ biến.',
  'Mở 24/7', 'Miễn phí', 'Nên đi vào chiều hoàng hôn để ngắm cảnh đẹp nhất, có thể thuê xe đạp đôi quanh hồ.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '03f31742-c2a7-48ae-927d-b4c71489bda7', '0f2136b0-e9c2-4ff1-a86d-ac0cc63ff9c6', 'Bảo tàng Dân tộc học Việt Nam', 'museum',
  'Đường Nguyễn Văn Huyên, phường Quan Hoa, quận Cầu Giấy, Hà Nội', 21.0392, 105.7997, 'Trưng bày văn hóa, đời sống của 54 dân tộc Việt Nam, có cả khu ngoài trời tái hiện nhà sàn, nhà rông các vùng miền.',
  '8:30–17:30, đóng Thứ 2', '~40.000đ/người lớn (ước tính, cần xác nhận)', 'Phù hợp đi cùng gia đình có trẻ nhỏ, nên dành ít nhất 2–3 giờ để xem hết cả khu trong nhà và ngoài trời.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-788d-9915-e65782ad4e85', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Chợ Bến Thành', 'market',
  'Công trường Quách Thị Trang, Phường Bến Thành, Quận 1, TP. HCM', 10.7722, 106.6983, 'Chợ Bến Thành là biểu tượng du lịch nổi tiếng nhất của Sài Gòn, được xây dựng từ năm 1914. Nơi đây quy tụ hàng ngàn gian hàng bán thực phẩm, quần áo, đồ thủ công mỹ nghệ, đặc sản địa phương và đồ lưu niệm. Ngoài mua sắm, chợ còn là nơi thưởng thức ẩm thực đường phố ngay tại chỗ.',
  'Thường 6:00–18:00 (khu hàng đêm đến ~23:00) — xác nhận trước khi đến', 'Miễn phí vào cửa', 'Đến sớm buổi sáng để tránh đông đúc. Mặc cả là văn hóa ở đây — bắt đầu với 50–60% giá chào. Khu ẩm thực bên trong chợ phục vụ nhiều món đặc sản giá hợp lý.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-77e4-a3c7-48acf0b9c31a', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Dinh Độc Lập', 'attraction',
  '135 Nam Kỳ Khởi Nghĩa, Phường Bến Thành, Quận 1, TP. HCM', 10.7769, 106.6957, 'Dinh Độc Lập (hay còn gọi là Dinh Thống Nhất) là công trình kiến trúc lịch sử mang ý nghĩa trọng đại — nơi chứng kiến sự kiện thống nhất đất nước năm 1975. Tòa nhà được thiết kế bởi kiến trúc sư Ngô Viết Thụ theo phong cách hiện đại kết hợp truyền thống Á Đông, với hầm ngầm và hệ thống thông tin liên lạc thời chiến được bảo tồn nguyên vẹn.',
  '7:30–11:00 và 13:00–16:00 (đóng cửa khi có sự kiện nhà nước) — xác nhận trước khi đến', NULL, 'Nên thuê hướng dẫn viên tại chỗ để hiểu rõ hơn về lịch sử các phòng. Khu hầm ngầm là điểm hấp dẫn nhất — đừng bỏ qua. Quần áo lịch sự được khuyến khích.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-7da8-9742-5d6f0abd16f5', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Nhà thờ Đức Bà', 'attraction',
  '01 Công xã Paris, Phường Bến Nghé, Quận 1, TP. HCM', 10.7797, 106.699, 'Nhà thờ Đức Bà Sài Gòn là công trình kiến trúc Gothic đặc sắc do người Pháp xây dựng từ năm 1863–1880, nằm ngay trung tâm Quận 1. Tháp chuông cao 57m là một trong những biểu tượng của thành phố. Phía trước nhà thờ là quảng trường Paris với tượng Đức Mẹ hòa bình nổi tiếng.',
  'Thường mở cửa hàng ngày — giờ cụ thể liên hệ nhà thờ để xác nhận', 'Miễn phí (khu vực ngoài)', 'Không vào trong khi đang có lễ. Góc chụp ảnh đẹp nhất từ đầu đường Đồng Khởi hướng về phía nhà thờ, đặc biệt lúc chiều tà. Kết hợp tham quan cùng Bưu điện Thành phố ngay bên cạnh.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-7357-927f-0bb11a498d86', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Bảo tàng Chứng tích Chiến tranh', 'museum',
  '28 Võ Văn Tần, Phường Võ Thị Sáu, Quận 3, TP. HCM', 10.7796, 106.6924, 'Một trong những bảo tàng được ghé thăm nhiều nhất Việt Nam, lưu giữ tư liệu và hiện vật về cuộc kháng chiến chống Mỹ. Bảo tàng gồm nhiều phòng trưng bày ảnh lịch sử, vũ khí, máy bay và xe tăng ngoài trời, cùng khu tái hiện nhà tù Côn Đảo. Nội dung có tính chân thực cao, phù hợp người lớn và thanh thiếu niên.',
  '7:30–18:00 hàng ngày (kể cả cuối tuần và lễ) — xác nhận trước khi đến', NULL, 'Nên dành ít nhất 2–3 tiếng. Mang theo nước uống vì bảo tàng khá rộng. Không phù hợp với trẻ nhỏ dưới 8 tuổi do nội dung mang tính lịch sử nặng nề.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-72fa-984b-77095ef88e7d', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Chùa Ngọc Hoàng', 'temple',
  '73 Mai Thị Lựu, Phường Đa Kao, Quận 1, TP. HCM', 10.7867, 106.6979, 'Chùa Ngọc Hoàng (Phước Hải Tự) là ngôi chùa Đạo giáo xây dựng từ năm 1909, nổi tiếng với không gian linh thiêng và hương khói nghi ngút. Nơi đây được cựu Tổng thống Obama ghé thăm năm 2016, khiến chùa càng trở nên nổi tiếng quốc tế. Kiến trúc điêu khắc tinh xảo và ao rùa trong sân tạo nên cảnh quan độc đáo.',
  '7:00–18:00 hàng ngày — xác nhận trước khi đến', 'Miễn phí', 'Đến vào sáng sớm hoặc cuối tuần để thấy không khí thờ phụng nhộn nhịp. Trang phục kín đáo, lịch sự. Không chụp ảnh thẳng vào mặt người đang thờ cúng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-79cf-a456-1ee9d8b2bfc8', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Làng Du lịch Bình Quới', 'nature',
  '1147 Bình Quới, Phường 28, Bình Thạnh, TP. HCM', 10.8292, 106.7266, 'Làng Du lịch Bình Quới là khu nghỉ dưỡng sinh thái nằm ven sông Sài Gòn, cách trung tâm thành phố khoảng 8km. Nơi đây có nhà hàng truyền thống, các trò chơi dân gian, biểu diễn văn nghệ và không gian xanh mát bên sông — lý tưởng để thoát khỏi nhịp sống đô thị.',
  '7:00–22:00 hàng ngày — xác nhận trước khi đến', NULL, 'Đặt bàn trước nếu đi vào cuối tuần, đặc biệt cho nhóm đông. Phù hợp cho gia đình có trẻ nhỏ. Dịch vụ chèo thuyền trên sông là trải nghiệm đáng thử.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-7f60-a2f0-f82d3a3e029e', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Địa đạo Củ Chi', 'attraction',
  'Khu di tích lịch sử địa đạo Củ Chi, huyện Củ Chi, TP. HCM (cách trung tâm ~70km)', 11.0646, 106.4998, 'Hệ thống địa đạo Củ Chi là mạng lưới đường hầm dài hơn 200km được đào bởi người dân và du kích trong thời kỳ kháng chiến. Di tích lịch sử quốc gia đặc biệt này cho phép du khách trải nghiệm chui qua đường hầm được mở rộng cho người nước ngoài, xem biểu diễn vũ khí thủ công và tìm hiểu cuộc sống trong lòng đất.',
  '7:00–17:00 hàng ngày — xác nhận trước khi đến', NULL, 'Nên đi theo tour có hướng dẫn viên để hiểu đầy đủ lịch sử. Mặc quần áo thoải mái, kín (hầm bẩn và chật). Bẫy địa đạo trưng bày là hiện vật thật — quan sát cẩn thận khi đi cùng trẻ em.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-788d-9915-e65782ad4e85', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Chợ Bến Thành', 'market',
  'Công trường Quách Thị Trang, Phường Bến Thành, Quận 1, TP. HCM', 10.7722, 106.6983, 'Chợ Bến Thành là biểu tượng du lịch nổi tiếng nhất của Sài Gòn, được xây dựng từ năm 1914. Nơi đây quy tụ hàng ngàn gian hàng bán thực phẩm, quần áo, đồ thủ công mỹ nghệ, đặc sản địa phương và đồ lưu niệm. Ngoài mua sắm, chợ còn là nơi thưởng thức ẩm thực đường phố ngay tại chỗ.',
  'Thường 6:00–18:00 (khu hàng đêm đến ~23:00) — xác nhận trước khi đến', 'Miễn phí vào cửa', 'Đến sớm buổi sáng để tránh đông đúc. Mặc cả là văn hóa ở đây — bắt đầu với 50–60% giá chào. Khu ẩm thực bên trong chợ phục vụ nhiều món đặc sản giá hợp lý.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-77e4-a3c7-48acf0b9c31a', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Dinh Độc Lập', 'attraction',
  '135 Nam Kỳ Khởi Nghĩa, Phường Bến Thành, Quận 1, TP. HCM', 10.7769, 106.6957, 'Dinh Độc Lập (hay còn gọi là Dinh Thống Nhất) là công trình kiến trúc lịch sử mang ý nghĩa trọng đại — nơi chứng kiến sự kiện thống nhất đất nước năm 1975. Tòa nhà được thiết kế bởi kiến trúc sư Ngô Viết Thụ theo phong cách hiện đại kết hợp truyền thống Á Đông, với hầm ngầm và hệ thống thông tin liên lạc thời chiến được bảo tồn nguyên vẹn.',
  '7:30–11:00 và 13:00–16:00 (đóng cửa khi có sự kiện nhà nước) — xác nhận trước khi đến', NULL, 'Nên thuê hướng dẫn viên tại chỗ để hiểu rõ hơn về lịch sử các phòng. Khu hầm ngầm là điểm hấp dẫn nhất — đừng bỏ qua. Quần áo lịch sự được khuyến khích.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-7da8-9742-5d6f0abd16f5', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Nhà thờ Đức Bà', 'attraction',
  '01 Công xã Paris, Phường Bến Nghé, Quận 1, TP. HCM', 10.7797, 106.699, 'Nhà thờ Đức Bà Sài Gòn là công trình kiến trúc Gothic đặc sắc do người Pháp xây dựng từ năm 1863–1880, nằm ngay trung tâm Quận 1. Tháp chuông cao 57m là một trong những biểu tượng của thành phố. Phía trước nhà thờ là quảng trường Paris với tượng Đức Mẹ hòa bình nổi tiếng.',
  'Thường mở cửa hàng ngày — giờ cụ thể liên hệ nhà thờ để xác nhận', 'Miễn phí (khu vực ngoài)', 'Không vào trong khi đang có lễ. Góc chụp ảnh đẹp nhất từ đầu đường Đồng Khởi hướng về phía nhà thờ, đặc biệt lúc chiều tà. Kết hợp tham quan cùng Bưu điện Thành phố ngay bên cạnh.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-7357-927f-0bb11a498d86', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Bảo tàng Chứng tích Chiến tranh', 'museum',
  '28 Võ Văn Tần, Phường Võ Thị Sáu, Quận 3, TP. HCM', 10.7796, 106.6924, 'Một trong những bảo tàng được ghé thăm nhiều nhất Việt Nam, lưu giữ tư liệu và hiện vật về cuộc kháng chiến chống Mỹ. Bảo tàng gồm nhiều phòng trưng bày ảnh lịch sử, vũ khí, máy bay và xe tăng ngoài trời, cùng khu tái hiện nhà tù Côn Đảo. Nội dung có tính chân thực cao, phù hợp người lớn và thanh thiếu niên.',
  '7:30–18:00 hàng ngày (kể cả cuối tuần và lễ) — xác nhận trước khi đến', NULL, 'Nên dành ít nhất 2–3 tiếng. Mang theo nước uống vì bảo tàng khá rộng. Không phù hợp với trẻ nhỏ dưới 8 tuổi do nội dung mang tính lịch sử nặng nề.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-72fa-984b-77095ef88e7d', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Chùa Ngọc Hoàng', 'temple',
  '73 Mai Thị Lựu, Phường Đa Kao, Quận 1, TP. HCM', 10.7867, 106.6979, 'Chùa Ngọc Hoàng (Phước Hải Tự) là ngôi chùa Đạo giáo xây dựng từ năm 1909, nổi tiếng với không gian linh thiêng và hương khói nghi ngút. Nơi đây được cựu Tổng thống Obama ghé thăm năm 2016, khiến chùa càng trở nên nổi tiếng quốc tế. Kiến trúc điêu khắc tinh xảo và ao rùa trong sân tạo nên cảnh quan độc đáo.',
  '7:00–18:00 hàng ngày — xác nhận trước khi đến', 'Miễn phí', 'Đến vào sáng sớm hoặc cuối tuần để thấy không khí thờ phụng nhộn nhịp. Trang phục kín đáo, lịch sự. Không chụp ảnh thẳng vào mặt người đang thờ cúng.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-79cf-a456-1ee9d8b2bfc8', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Làng Du lịch Bình Quới', 'nature',
  '1147 Bình Quới, Phường 28, Bình Thạnh, TP. HCM', 10.8292, 106.7266, 'Làng Du lịch Bình Quới là khu nghỉ dưỡng sinh thái nằm ven sông Sài Gòn, cách trung tâm thành phố khoảng 8km. Nơi đây có nhà hàng truyền thống, các trò chơi dân gian, biểu diễn văn nghệ và không gian xanh mát bên sông — lý tưởng để thoát khỏi nhịp sống đô thị.',
  '7:00–22:00 hàng ngày — xác nhận trước khi đến', NULL, 'Đặt bàn trước nếu đi vào cuối tuần, đặc biệt cho nhóm đông. Phù hợp cho gia đình có trẻ nhỏ. Dịch vụ chèo thuyền trên sông là trải nghiệm đáng thử.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();
INSERT INTO locations (id, destination_id, name, type, address, lat, lng, description, opening_hours, entry_fee, tips, is_active) VALUES (
  '019eee06-3f91-7f60-a2f0-f82d3a3e029e', '019eeda8-d830-72fe-8479-3d24a2698ee8', 'Địa đạo Củ Chi', 'attraction',
  'Khu di tích lịch sử địa đạo Củ Chi, huyện Củ Chi, TP. HCM (cách trung tâm ~70km)', 11.0646, 106.4998, 'Hệ thống địa đạo Củ Chi là mạng lưới đường hầm dài hơn 200km được đào bởi người dân và du kích trong thời kỳ kháng chiến. Di tích lịch sử quốc gia đặc biệt này cho phép du khách trải nghiệm chui qua đường hầm được mở rộng cho người nước ngoài, xem biểu diễn vũ khí thủ công và tìm hiểu cuộc sống trong lòng đất.',
  '7:00–17:00 hàng ngày — xác nhận trước khi đến', NULL, 'Nên đi theo tour có hướng dẫn viên để hiểu đầy đủ lịch sử. Mặc quần áo thoải mái, kín (hầm bẩn và chật). Bẫy địa đạo trưng bày là hiện vật thật — quan sát cẩn thận khi đi cùng trẻ em.', TRUE
) ON CONFLICT (id) DO UPDATE SET description=EXCLUDED.description, tips=EXCLUDED.tips, updated_at=NOW();