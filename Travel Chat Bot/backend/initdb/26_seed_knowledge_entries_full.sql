-- PDTrip – Seed: knowledge_entries (RAG) từ MD files + JSON summaries
-- Sau khi insert, embedding_jobs tự động được queue

INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '25a50d57-3cf5-5ac0-804b-ecbbdebc0f5c', 'Tổng quan du lịch Phú Quốc', 'destination', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Tổng quan Phú Quốc (An Giang):
Đảo ngọc lớn nhất Việt Nam với bãi biển trong xanh, hải sản tươi sống và các khu nghỉ dưỡng cao cấp.

Mùa đẹp nhất: Tháng 11–4 (mùa khô, biển êm)
Thời tiết: Nóng ẩm, 25–32°C, mùa mưa tháng 5–10 có bão nhẹ
Ẩm thực: Hải sản, nước mắm Phú Quốc, gỏi cá trích, nhum nướng mỡ hành
Ngân sách tham khảo: 3,000,000–8,000,000đ/người', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '9d2823ff-e11c-58d9-bd92-755616da60c3', 'Phú Quốc – Trải nghiệm nổi bật – Phú Quốc (An Giang)', 'safety', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## Trải nghiệm nổi bật – Phú Quốc (An Giang)

> Lưu ý: File này KHÔNG lặp lại số liệu chi tiết (giá, toạ độ, giờ mở cửa) đã có trong các file JSON. Hãy xem , , , , , , ,  để có thông tin đầy đủ.

---', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3545a418-da24-5ea4-bc91-652a7640439f', 'Phú Quốc – 🏖️ Bãi Sao', 'tip', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## 🏖️ Bãi Sao
Nhiều người gọi đây là "bãi biển đẹp nhất Phú Quốc" — cát trắng mịn như bột, nước trong xanh màu ngọc lam, chưa bị các khối khách sạn lớn bao vây. Đến sáng sớm trước 9h để có không gian và ánh sáng chụp ảnh đẹp nhất. *(Xem chi tiết: destinations.json)*', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '64ca5da4-2478-5fdf-bff6-eac2ac44df9c', 'Phú Quốc – 🐟 Làng chài Hàm Ninh', 'tip', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## 🐟 Làng chài Hàm Ninh
Không chỉ là nơi ăn hải sản, Hàm Ninh còn là một góc Phú Quốc đời thường còn giữ được hồn ngư dân truyền thống. Cầu gỗ dài ra biển, thuyền đánh cá rực rỡ, núi rừng xanh phía xa — khung cảnh rất khác khu resort sầm uất. *(Xem chi tiết: destinations.json)*', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd2d7fb61-a295-51ae-9aa3-d6f372190cef', 'Phú Quốc – 🌅 Dinh Cậu & Chợ đêm', 'activity', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## 🌅 Dinh Cậu & Chợ đêm
Mỏm đá nhô ra biển với ngôi miếu thờ cá Ông là điểm xem hoàng hôn "vàng" nhất đảo. Ngay bên cạnh là chợ đêm sôi động — hai trải nghiệm trong một buổi chiều tối hoàn hảo. *(Xem chi tiết: destinations.json)*', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b579556c-920a-574c-b1b4-8c0459044bcc', 'Phú Quốc – 🦁 Vinpearl Safari', 'tip', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## 🦁 Vinpearl Safari
Vườn thú bán hoang dã lớn nhất Đông Nam Á, phù hợp đặc biệt cho gia đình có trẻ em. Xe điện chạy giữa khu bảo tồn, thú hoang dã tự do — cảm giác khác hẳn sở thú thông thường. *(Xem chi tiết: destinations.json)*', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5d9feb15-1a4f-5f1e-be6f-c46c79970914', 'Phú Quốc – 🌿 Vườn Quốc gia Phú Quốc', 'tip', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## 🌿 Vườn Quốc gia Phú Quốc
Hơn 50% diện tích đảo là rừng nguyên sinh được bảo vệ. Trekking băng rừng, thăm suối và thác Tranh — dành cho ai muốn thoát khỏi bãi biển và resort. Cần hướng dẫn viên địa phương. *(Xem chi tiết: destinations.json)*

---', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6c11ff15-7f63-5b0b-957c-70ef1aa1f274', 'Phú Quốc – ⏱️ Lịch trình ngắn: 3N2Đ – Dành cho cặp đôi', 'activity', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## ⏱️ Lịch trình ngắn: 3N2Đ – Dành cho cặp đôi
Phù hợp khi có thời gian hạn chế, muốn trải nghiệm những điểm tinh túy nhất:

| Ngày | Chủ đề | Điểm nhấn |
|------|--------|-----------|
| Ngày 1 | Làng chài & hoàng hôn | Hàm Ninh → Dinh Cậu → Chợ đêm |
| Ngày 2 | Biển & đảo nhỏ | Tour 4 đảo cả ngày (lặn san hô, câu cá) |
| Ngày 3 | Bãi Sao & đặc sản | Tắm biển → Bún quậy → Mua quà về |

*(Xem lịch trình đầy đủ với giờ và địa điểm cụ thể: itineraries.json)*', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f0cf6bd0-f56f-5582-9b75-773c30b8fd64', 'Phú Quốc – ⏱️ Lịch trình dài: 5N4Đ – Dành cho gia đình', 'tip', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## ⏱️ Lịch trình dài: 5N4Đ – Dành cho gia đình
Đủ thời gian để khám phá cả thiên nhiên, văn hóa và giải trí:

| Ngày | Chủ đề | Điểm nhấn |
|------|--------|-----------|
| Ngày 1 | Đến nơi & nghỉ ngơi | Nhận phòng resort, tắm biển Bãi Trường |
| Ngày 2 | Thiên nhiên & bắc đảo | Vinpearl Safari → Bãi Dài hoang sơ |
| Ngày 3 | Biển & đêm sao | Tour 4 đảo → Câu mực đêm |
| Ngày 4 | Làng nghề & bãi đẹp | Nước mắm + rượu sim → Bãi Sao chiều |
| Ngày 5 | Mua sắm & về | Chợ Dương Đông → Bữa cuối → Sân bay |

*(Xem lịch trình đầy đủ với giờ và địa điểm cụ thể: itineraries.json)*

---', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b344b381-3f6f-57e4-8926-a2460b5e5aea', 'Phú Quốc – Tips thực tế', 'safety', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## Tips thực tế

Mùa nào nên đi?  
Tháng 11 đến tháng 4 là lý tưởng — biển êm, nhum theo mùa, lặn ngắm san hô rõ nhất. Tháng 12–2 đông và đắt nhất, đặt phòng sớm ít nhất 4–6 tuần.

Di chuyển trên đảo  
Thuê xe máy là linh hoạt nhất. Grab có nhưng coverage không đều khu xa đảo. Không có xe buýt công cộng hoàn chỉnh — xem chi tiết hơn trong .

Tắm biển an toàn  
Luôn quan sát cờ cảnh báo tắm biển. Mùa mưa (T5–10) sóng to và nguy hiểm ở một số bãi. Không bơi một mình ra xa bờ.

Mặc cả và giá cả  
Trả giá được ở chợ đêm và chợ truyền thống, đặc biệt đồ lưu niệm. Hỏi giá rõ hải sản tươi trước khi gọi để tránh tình trạng "chặt chém" ở một số điểm du lịch đông khách.

Kem chống nắng & nước  
Nắng Phú Quốc rất gắt, đặc biệt giữa trưa. Mang kem chống nắng SPF50+, uống đủ nước và tránh ra ngoài 11:00–14:00 nếu không cần thiết.

---', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8da52ff5-39d6-53d7-8686-a2bb583d2601', 'Phú Quốc – Bảng đặc sản nên thử', 'safety', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## Bảng đặc sản nên thử

| Đặc sản | Đặc trưng | Nơi tìm | Lưu ý |
|---------|-----------|---------|-------|
| Gỏi cá trích | Cá tươi trộn dừa nạo, rau thơm, chanh | Làng chài Hàm Ninh, quán ven biển | Đặc sản số 1 của Phú Quốc |
| Nhum nướng mỡ hành | Cầu gai biển, béo ngậy | Chợ đêm Dinh Cậu | Chỉ có tháng 11–4 |
| Nước mắm nhĩ Phú Quốc | Nguyên chất từ cá cơm ủ 12–18 tháng | Cơ sở Khải Hoàn, Thanh Hà | Đặc sản mua về làm quà |
| Bún quậy Phú Quốc | Sợi bún tươi to, nước lèo hải sản | Chợ sáng Dương Đông | Ăn sáng, hết trước 10h |
| Ghẹ rang muối / hấp bia | Ghẹ tươi sống, thịt chắc ngọt | Chợ đêm, làng chài | Hỏi giá theo kg trước |
| Rượu sim | Từ quả sim núi, vị ngọt nhẹ | Trang trại Ngọc Hiền, chợ đêm | Thử trước khi mua |

*(Xem mô tả đầy đủ từng món: foods.json)*', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '68e7ba9e-758d-5917-9c89-e79001744db3', 'FAQ Du lịch Phú Quốc (1)', 'faq', '019eee7d-cd94-744b-86d1-ca07059a9949',
  '## FAQ – Phú Quốc (An Giang)

> Lưu ý: File này KHÔNG chứa lại số liệu giá/rating đã có trong các file JSON cùng thư mục. Mọi thông tin giá/lịch trình chi tiết hãy xem các file tương ứng: , , , , , v.v.

---

## 1. Thời điểm

Q: Khi nào là thời điểm đẹp nhất để đến Phú Quốc?  
A: Mùa khô từ tháng 11 đến tháng 4 là lý tưởng nhất — biển êm, nắng đẹp, lặn ngắm san hô rõ nhất. Tháng 12–2 (Tết dương lịch và Tết Nguyên Đán) là mùa cao điểm, rất đông khách và giá tăng cao. Nên đặt sớm ít nhất 4–6 tuần nếu đi dịp này.

Q: Mùa mưa (tháng 5–10) có đi được không?  
A: Vẫn đi được, giá rẻ hơn đáng kể và ít khách hơn. Tuy nhiên mưa lớn và gió mạnh thường xuyên, biển có sóng to — tour đảo và lặn biển có thể bị hủy. Nếu chọn mùa mưa, nên mua bảo hiểm du lịch và giữ lịch trình linh hoạt.

Q: Tháng mấy có nhum (cầu gai) để ăn?  
A: Nhum theo mùa, thường xuất hiện từ tháng 11 đến tháng 4 — trùng với mùa khô biển êm. Đến mùa mưa nhum khan hiếm và chất lượng kém hơn.

---

## 2. Chi phí

Q: Đi Phú Quốc cần dự trù bao nhiêu tiền (không tính vé máy bay)?  
A: Phụ thuộc phân khúc lưu trú. Tham khảo khung ngân sách trong  và giá ước tính trong  — lưu ý đó là ước tính mùa thấp, mùa cao (T11–4) có thể cao hơn 30–80%.

Q: Phú Quốc có rẻ không so với Đà Nẵng hay Nha Trang?  
A: Trung bình Phú Quốc đắt hơn một chút vì chi phí vận chuyển đảo cao hơn. Khu resort 5 sao giá rất cao nhưng có nhiều lựa chọn bình dân (xem ). Ăn uống hải sản tươi tại chợ đêm và làng chài thường rẻ hơn nhà hàng khách sạn.

Q: Có mặc cả được ở chợ và chợ đêm không?  
A: Được — đặc biệt với đồ lưu niệm và mua số lượng nhiều. Hải sản tươi sống thường có giá niêm yết nhưng vẫn có thể thương lượng. Siêu thị và cửa hàng có niêm yết thì không mặc cả.

---

## 3. Di chuyển', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '2d9df0f8-c5eb-5be7-923c-9d69249b87f6', 'FAQ Du lịch Phú Quốc (2)', 'faq', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Q: Từ TP.HCM đi Phú Quốc bằng cách nào?  
A: Xem chi tiết trong . Nhanh nhất là bay thẳng (~55 phút). Tiết kiệm hơn là xe khách + phà nhưng mất 6–8 giờ. Mùa mưa nên ưu tiên đi máy bay vì phà dễ bị hủy do sóng to.

Q: Trên đảo di chuyển bằng gì?  
A: Thuê xe máy là phổ biến và linh hoạt nhất (xem ). Grab hoạt động nhưng coverage không đều ở khu xa. Đi tour là cách dễ nhất để đến các điểm xa không có xe cá nhân.

Q: Có xe buýt công cộng trên đảo không?  
A: Chưa có hệ thống xe buýt công cộng nội đảo hoàn chỉnh. Một số tuyến trung chuyển sân bay hoạt động theo giờ. Phương tiện chính là taxi, xe máy thuê và grab.

---

## 4. Lưu trú

Q: Nên ở khu nào trên đảo?  
A: Khu Bãi Trường (Long Beach) là trung tâm sôi động nhất, gần chợ đêm và nhà hàng — phù hợp nhóm bạn trẻ và gia đình. Khu Bãi Khem (phía nam) yên tĩnh hơn, nhiều resort 5 sao — phù hợp nghỉ dưỡng sang. Khu Vũng Bầu (phía bắc) hoang sơ, ít phát triển — phù hợp tìm sự tĩnh lặng.

Q: Có homestay hay hostel giá bình dân không?  
A: Có — xem  để biết các lựa chọn từ hostel dorm đến guesthouse, giá dao động từ thấp đến trung bình.

---

## 5. Ẩm thực

Q: Đặc sản nhất định phải thử khi đến Phú Quốc là gì?  
A: Xem danh sách đặc sản trong . Ba món không thể bỏ: gỏi cá trích, nhum nướng mỡ hành (theo mùa) và bún quậy Phú Quốc. Ngoài ra đừng quên thử nước mắm nhĩ ngay tại nguồn.

Q: Hải sản ở Phú Quốc có đắt không?  
A: Tùy nơi. Tại chợ đêm Dinh Cậu và làng chài Hàm Ninh giá thường hợp lý hơn nhiều so với nhà hàng trong resort. Nên hỏi giá trước khi chọn, đặc biệt hải sản tươi tính theo kg.', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd05c0861-bd89-5ac5-8d93-7917d84790ed', 'FAQ Du lịch Phú Quốc (3)', 'faq', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Q: Người ăn chay có nhiều lựa chọn không?  
A: Phú Quốc là điểm hải sản nên chọn lựa chay ít hơn. Có một số nhà hàng chay/thuần chay ở khu Dương Đông nhưng không phổ biến như đất liền. Khách ăn chay nên hỏi kỹ trước khi gọi món.

---

## 6. Câu hỏi ngoài phạm vi

Q: PDTrip AI có thể đặt vé máy bay / đặt phòng cho tôi không?  
A: Không — PDTrip AI là trợ lý tư vấn du lịch, không có chức năng đặt vé hay đặt phòng trực tiếp. Bạn có thể đặt trên Traveloka, Agoda, Booking.com hoặc trực tiếp tại website hãng.

Q: Tôi muốn biết giá phòng khách sạn hôm nay?  
A: PDTrip AI chỉ có giá ước tính tham khảo (xem ). Để có giá real-time, hãy kiểm tra trực tiếp trên Agoda, Booking.com hoặc Traveloka.

---

## 7. An toàn

Q: Phú Quốc có an toàn không?  
A: Nhìn chung an toàn cho khách du lịch. Các lưu ý chính: (1) Mùa mưa biển có sóng to, không bơi xa bờ — tuân thủ cờ cảnh báo tắm biển. (2) Đi xe máy phải đội mũ bảo hiểm và lái cẩn thận — đường đảo đôi chỗ hẹp và nhiều xe tải. (3) Tránh mua hải sản ở quán không quen, hỏi giá rõ trước khi gọi để tránh "chặt chém". (4) Mang theo kem chống nắng và uống đủ nước khi ra ngoài ban ngày.

Q: Có cần bảo hiểm du lịch không?  
A: Khuyến nghị có, đặc biệt nếu đi mùa mưa (rủi ro hủy tour, phà). Bảo hiểm du lịch cũng bảo vệ trường hợp tai nạn xe máy (phổ biến hơn đất liền do đường đảo), và chi phí y tế trên đảo thường cao hơn đất liền.

Q: Nên gọi số nào khi khẩn cấp?  
A: Cấp cứu y tế: 115 | Công an: 113 | Cứu hỏa: 114. Bệnh viện Đa khoa Phú Quốc nằm ở khu Dương Đông — đây là cơ sở y tế lớn nhất trên đảo.', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a2dfdda6-9b2c-596a-a3f6-165d4513b640', 'Ẩm thực đặc sản Phú Quốc', 'food', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Đặc sản ẩm thực Phú Quốc:
- Gỏi cá trích: Đặc sản nổi tiếng nhất Phú Quốc. Cá trích tươi lọc xương, trộn với dừa nạo, sả, rau thơm và nước cốt chanh. Ăn kèm bánh tráng và rau sống. Hương vị tươi mát, đặc trưng vùng biển.
  Địa điểm thưởng thức: Các quán ven biển khu Dương Đông, nhà hàng Hàm Ninh
  Giá tham khảo: 50.000–80.000đ/đĩa (ƯỚC TÍNH)
- Nhum nướng mỡ hành: Nhum biển (cầu gai) nướng mỡ hành, một trong những món hải sản đặc trưng nhất Phú Quốc. Thịt nhum màu cam, béo ngậy, ăn kèm bánh mì hoặc cơm. Chỉ có theo mùa (thường tháng 11–4).
  Địa điểm thưởng thức: Chợ đêm Dinh Cậu, làng chài Hàm Ninh
  Giá tham khảo: 150.000–250.000đ/con (ƯỚC TÍNH, tùy kích cỡ)
- Nước mắm Phú Quốc: Nước mắm nổi tiếng nhất Việt Nam, được làm từ cá cơm đảo ngâm ủ tối thiểu 12–18 tháng trong thùng gỗ. Màu nâu đỏ, thơm đặc trưng, đạm cao. Là đặc sản mua về làm quà số 1.
  Địa điểm thưởng thức: Làng nghề nước mắm Dương Đông, các cơ sở Khải Hoàn, Thanh Hà
  Giá tham khảo: 50.000–200.000đ/chai tùy loại (ƯỚC TÍNH)
- Ghẹ rang muối / hấp bia: Ghẹ biển Phú Quốc tươi sống, chế biến theo phong cách rang muối ớt hoặc hấp bia lá sả. Thịt ghẹ chắc, ngọt tự nhiên. Ăn tại chỗ ở chợ đêm hoặc nhà hàng ven biển.
  Địa điểm thưởng thức: Chợ đêm Dinh Cậu, nhà hàng khu Bãi Trường
  Giá tham khảo: 150.000–300.000đ/con (ƯỚC TÍNH, tùy trọng lượng)
- Bún quậy Phú Quốc: Món bún đặc sản địa phương ít ai biết, sợi bún tươi lớn hơn bún thường, chan nước lèo từ hải sản (ghẹ, mực, tôm), ăn kèm rau thơm và tôm tươi. Tên ''quậy'' do người ăn tự khuấy đều bát trước khi thưởng 
  Địa điểm thưởng thức: Các quán bún quậy ở khu Dương Đông, chợ sáng Phú Quốc
  Giá tham khảo: 40.000–70.000đ/tô (ƯỚC TÍNH)
- Rượu sim Phú Quốc: Rượu vang làm từ quả sim tươi trên núi Phú Quốc, màu tím đỏ, vị ngọt nhẹ, nồng độ thấp. Là đặc sản uống tại chỗ hoặc mua về làm quà. Cơ sở Tám Nhàn và Ngọc Hiền nổi tiếng nhất.
  Địa điểm thưởng thức: Trang trại rượu sim khu Dương Đông, các cửa hàng quà lưu niệm
  Giá tham khảo: 80.000–200.000đ/chai (ƯỚC TÍNH)', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '48c96a5c-0351-580e-be3e-74937b32f925', 'Cách di chuyển đến Phú Quốc', 'transport', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Di chuyển đến và trong Phú Quốc:

Cách đến:
- AIRPLANE từ TP.HCM (TSN), Hà Nội (NIO), Đà Nẵng, Cần Thơ và các TP lớn: ~55 phút từ TP.HCM; ~2h từ Hà Nội — 800.000–2.500.000đ/chiều (ƯỚC TÍNH, biến động mạnh theo mùa)
  Sân bay Phú Quốc quốc tế (PQC) cách trung tâm Dương Đông ~10km. Là cách di chuyển phổ biến nhất. Nên đặt sớm 2–4 tuần trong mùa cao điểm (Tết, hè).
- FERRY từ Rạch Giá (Kiên Giang) hoặc Hà Tiên: ~2h15 từ Rạch Giá; ~45 phút từ Hà Tiên (tàu cao tốc) — 200.000–350.000đ/người (ƯỚC TÍNH)
  Phà chạy nhiều chuyến/ngày, nhưng mùa mưa (tháng 6–10) sóng to có thể hủy chuyến. Nên kiểm tra trước khi đặt vé.
- BUS_COMBINED từ TP.HCM (xe khách đến Rạch Giá/Hà Tiên, sau đó đi phà): ~6–8 giờ tổng (xe + phà) — 300.000–500.000đ/người tổng (ƯỚC TÍNH)
  Lựa chọn tiết kiệm nhất cho khách từ TP.HCM. Nhiều hãng có combo xe + phà. Không phù hợp trẻ nhỏ hoặc người say tàu xe.
- PRIVATE_CAR từ TP.HCM hoặc Cần Thơ: ~4–5 giờ đến Hà Tiên + 45 phút phà — None
  Phù hợp nhóm đông (4–7 người) chia tiền. Linh hoạt dừng dọc đường tham quan.

Di chuyển trong thành phố:
- motorbike_rental: Cách di chuyển phổ biến và tiện nhất trên đảo. Nhiều điểm cho thuê ở Dương Đông và gần sân bay. Cần bằng lái A1 và đội mũ bảo hiểm.
- taxi: Có taxi Mai Linh và Sao Vàng hoạt động trên đảo. Giá thường cao hơn đất liền. Nên chốt giá trước với taxi không đồng hồ.
- grab: Grab có hoạt động tại Phú Quốc nhưng coverage không đều như TP.HCM. Khu Dương Đông và Bãi Trường dễ đặt hơn, khu xa đảo khó.
- xe_dien_golf: Xe điện golf carts có trong một số resort lớn (Vinpearl, JW Marriott) để di chuyển nội khu.', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3844008f-c07d-5360-aeae-f17e78a0ee89', 'Khách sạn & Lưu trú tại Phú Quốc', 'hotel', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Lưu trú tại Phú Quốc:
- InterContinental Phu Quoc Long Beach Resort (5★): Bãi Trường, TP. Phú Quốc, tỉnh An Giang
  Tiện ích: Hồ bơi vô cực ra biển, Spa, 5 nhà hàng & bar, Gym
- JW Marriott Phu Quoc Emerald Bay (5★): Khem Beach, TP. Phú Quốc, tỉnh An Giang
  Tiện ích: Bãi biển riêng Bãi Khem, Hồ bơi nhiều khu, Spa LaGrace, 6 nhà hàng
- Sunset Sanato Resort & Villas (4★): Bãi Khem, TP. Phú Quốc, tỉnh An Giang
  Tiện ích: Hồ bơi, Bãi biển riêng, Nhà hàng, Wifi miễn phí
  Giá: ƯỚC TÍNH mùa thấp — xác nhận tại Agoda/Traveloka
- Mango Bay Resort (3★): Vũng Bầu, TP. Phú Quốc, tỉnh An Giang
  Tiện ích: Hồ bơi, Nhà hàng hải sản, Wifi miễn phí, Bãi biển riêng nhỏ
  Giá: ƯỚC TÍNH mùa thấp — xác nhận tại Booking.com
- Phu Quoc Backpacker Hostel (None★): Đường 30 Tháng 4, khu Dương Đông, TP. Phú Quốc, tỉnh An Giang
  Tiện ích: Phòng dorm máy lạnh, Khu bếp chung, Wifi miễn phí, Cho thuê xe máy
  Giá: ƯỚC TÍNH giường dorm — xác nhận tại Booking.com/Hostelworld
- Cassia Cottage (3★): Bãi Trường, TP. Phú Quốc, tỉnh An Giang
  Tiện ích: Hồ bơi nhỏ, Nhà hàng, Wifi miễn phí, Sân vườn nhiệt đới
  Giá: ƯỚC TÍNH — xác nhận tại Agoda hoặc Traveloka', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '57acc15b-6189-5ae9-a06f-4539d04509a7', 'Tour & Trải nghiệm tại Phú Quốc', 'tour', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Tour & Trải nghiệm tại Phú Quốc:
- Tour câu cá & lặn ngắm san hô 4 đảo: 1 ngày (7:00–17:00) — 350,000đ/người
  Tour nổi tiếng nhất Phú Quốc, ghé 4 hòn đảo nhỏ: Hòn Thơm, Hòn Móng Tay, Hòn Gầm Ghì, Hòn Vú. Kết hợp lặn ngắm san hô, câu cá, ăn hải sản trên biển và tắm biển tại các điểm ghé.
- Tour khám phá Vườn Quốc gia & thác Tranh: Nửa ngày (buổi sáng, ~4 giờ) — liên hệ
  Trekking nhẹ vào rừng nguyên sinh Vườn Quốc gia Phú Quốc, thăm thác Tranh và suối tự nhiên. Hướng dẫn viên địa phương giới thiệu hệ sinh thái rừng nhiệt đới đặc trưng của đảo.
- Tour hoàng hôn & câu mực đêm trên biển: Buổi tối (~4 giờ, 17:30–21:30) — 300,000đ/người
  Lên thuyền ra biển xem hoàng hôn, sau đó câu mực đêm dưới ánh đèn cao áp. Hải sản câu được có thể nướng ngay trên thuyền. Trải nghiệm độc đáo không thể bỏ qua khi đến Phú Quốc.
- Tour làng nghề: nước mắm & rượu sim Phú Quốc: Nửa ngày (buổi sáng, ~3 giờ) — 200,000đ/người
  Tham quan nhà thùng nước mắm truyền thống (Khải Hoàn hoặc Thanh Hà), xem quy trình ủ cá cơm làm nước mắm nhĩ. Tiếp theo thăm trang trại rượu sim, thử rượu và mua đặc sản về.', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3aad7ed9-db17-58ad-86a7-f68664ae0c3d', 'Lễ hội & Sự kiện tại Phú Quốc', 'event', '019eee7d-cd94-744b-86d1-ca07059a9949',
  'Lễ hội & Sự kiện tại Phú Quốc:
- Lễ hội Nghinh Ông (Cúng Cá Voi): Tháng 4 (ngày 16–18 âm lịch hằng năm)
  Lễ hội truyền thống của ngư dân Phú Quốc, cúng tế cá Ông (cá voi) để cầu bình an và mùa đánh bắt bội thu. Có thuyền hoa diễu hành trên biển, múa lân và biểu diễn dân gian.
- Tết Nguyên Đán trên đảo Phú Quốc: Tháng 1 hoặc 2 (theo lịch âm)
  Dịp Tết tại Phú Quốc có không khí độc đáo: chợ hoa, pháo hoa đêm giao thừa trên biển, các đình chùa đông người cầu nguyện đầu năm. Cũng là mùa cao điểm du lịch nên cần đặt phòng sớm.
- Lễ hội Khai Thác Mùa Cá (Ngày mở biển): Tháng 10 âm lịch hằng năm (cuối mùa gió Nam)
  Lễ mở đầu mùa đánh bắt sau mùa mưa giông, ngư dân cúng biển, thả thuyền ra khơi lần đầu trong mùa mới. Khách du lịch có thể quan sát nghi lễ truyền thống độc đáo của ngư dân đảo.
- Phú Quốc International Music Festival: Cuối năm (tháng 12) — thường vào dịp Giáng sinh/Năm mới
  Lễ hội âm nhạc quốc tế thu hút DJ và nghệ sĩ quốc tế, được tổ chức không thường xuyên theo kế hoạch năm. Kết hợp âm nhạc, vui chơi trên biển và pháo hoa.', ARRAY['an-giang-phu-quoc', 'phú quốc', 'an giang', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'fcf63a35-dc75-50b6-b304-87b69a4729d0', 'Tổng quan du lịch Bắc Ninh', 'destination', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Tổng quan Bắc Ninh (Bắc Ninh):
Quê hương quan họ với chùa Dâu, chùa Bút Tháp và làng nghề gốm Phù Lãng, tranh Đông Hồ; sau sáp nhập còn có vùng đồi núi Bắc Giang với Tây Yên Tử, vườn vải thiều Lục Ngạn.

Mùa đẹp nhất: Tháng 9–11 hoặc Tháng 1–3 (mùa hội chùa, hát quan họ)
Thời tiết: 4 mùa rõ rệt, nóng ẩm mùa hè, lạnh khô mùa đông 10–18°C
Ẩm thực: Bánh phu thê Đình Bảng, nem Bùi, bánh tro, rượu làng Vân
Ngân sách tham khảo: ', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c7a4b347-8620-5e69-b508-7dd741a9a484', 'Bắc Ninh – 🌟 Kinh Nghiệm Du Lịch Bắc Ninh', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 🌟 Kinh Nghiệm Du Lịch Bắc Ninh

> Tips thực tế từ du khách kinh nghiệm và người am hiểu văn hóa Kinh Bắc. Thông tin giá và địa chỉ cụ thể: xem các file JSON cùng thư mục.

---', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c5d3a75b-6392-5097-a130-dcc4e45cb065', 'Bắc Ninh – 1. Chùa Dâu (Pháp Vân)', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 1. Chùa Dâu (Pháp Vân)
Loại: temple — Di tích Quốc gia đặc biệt
Khu vực: Huyện Thuận Thành (cụm di tích cổ nhất miền Bắc)
Giờ mở cửa: Khoảng 6:00–18:00 *(xác nhận trước khi đến)*
Tip: Đến lúc 6:30–7:30 để không khí thanh tịnh nhất và ánh sáng sáng sớm rất đẹp chụp tháp Hòa Phong. Kết hợp với Chùa Bút Tháp ngay cùng buổi vì chỉ cách 5km.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '403dd2af-15ad-5969-81da-05775973df4e', 'Bắc Ninh – 2. Chùa Bút Tháp', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 2. Chùa Bút Tháp
Loại: temple — Kiến trúc thế kỷ 17 nguyên vẹn nhất miền Bắc
Khu vực: Huyện Thuận Thành (cùng cụm với Chùa Dâu)
Giờ mở cửa: Khoảng 7:00–17:30 *(xác nhận trước khi đến)*
Tip: Tượng Quan Âm nghìn tay nghìn mắt và tháp Báo Nghiêm là hai điểm nhấn nghệ thuật đặc sắc. Nên mang theo tài liệu về triều Lê để hiểu sâu hơn ý nghĩa kiến trúc.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b6cf060f-14ae-5b6d-925f-607ff5fc7706', 'Bắc Ninh – 3. Đền Đô (Đền Lý Bát Đế)', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 3. Đền Đô (Đền Lý Bát Đế)
Loại: temple — Đền thờ 8 vua triều Lý
Khu vực: Làng Đình Bảng, thị xã Từ Sơn
Giờ mở cửa: Khoảng 7:00–17:00 *(xác nhận trước khi đến)*
Tip: Lễ hội Đền Đô (14–16 tháng 3 âm lịch) rất đông và đặc sắc, có rước kiệu và hát quan họ. Nếu không phải dịp lễ hội, buổi sáng đến rất vắng và yên tĩnh để chiêm ngưỡng kiến trúc. Mua bánh phu thê ngay tại làng Đình Bảng sau khi thăm đền.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '41b8bf0c-dbd3-5aea-8858-ea1c7d73db18', 'Bắc Ninh – 4. Làng tranh dân gian Đông Hồ', 'activity', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 4. Làng tranh dân gian Đông Hồ
Loại: attraction — Di sản văn hóa phi vật thể (UNESCO)
Khu vực: Xã Song Hồ, huyện Thuận Thành
Giờ mở cửa: Liên hệ nghệ nhân trước khi đến *(giờ linh hoạt)*
Tip: Chỉ còn rất ít gia đình giữ nghề. Gọi điện trước để hẹn giờ và đảm bảo có người tiếp đón. Xem trực tiếp quy trình in tranh thủ công từ mộc bản là trải nghiệm không thể có ở nơi nào khác. Mua tranh tại nhà nghệ nhân là cách ủng hộ bảo tồn di sản thiết thực nhất.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd827d24c-ad0c-51b2-a1d2-5925513a0ec5', 'Bắc Ninh – 5. Làng gốm Phù Lãng', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 5. Làng gốm Phù Lãng
Loại: attraction — Làng nghề trăm năm tuổi
Khu vực: Xã Phù Lãng, huyện Quế Võ
Giờ mở cửa: Cả ngày, nên đến 8:00–11:00 *(thợ gốm làm việc buổi sáng)*
Tip: Màu da lươn và đỏ gạch đặc trưng của gốm Phù Lãng khác hoàn toàn với gốm Bát Tràng — đây là lý do chính để ghé thăm. Nếu thích, có thể hỏi thợ cho tự tay nặn thử một tác phẩm nhỏ. Mang túi chắc để đựng đồ gốm khi mua về.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '06c7fd31-455b-5acb-9692-6d9bc52ff4cb', 'Bắc Ninh – 6. Đồi Lim – Cái nôi Hội Lim', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 6. Đồi Lim – Cái nôi Hội Lim
Loại: attraction — Lễ hội Quan họ lớn nhất tỉnh
Khu vực: Thị trấn Lim, huyện Tiên Du
Thời điểm tốt nhất: 12–13 tháng Giêng âm lịch (Hội Lim)
Tip: Ngoài mùa hội, Đồi Lim là một ngọn đồi bình thường. Hội Lim mới là dịp xem hát quan họ trên thuyền trên hồ — cảnh tượng đặc sắc chỉ có ở đây. Đến trước 8:00 sáng để có vị trí xem tốt; từ 9:00 trở đi rất đông.

---', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'da181295-c7e9-575d-9f01-44a6d1ca80d1', 'Bắc Ninh – 🎒 Lịch Trình Gợi Ý', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 🎒 Lịch Trình Gợi Ý

*(Chi tiết giờ giấc và địa điểm cụ thể: xem )*', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '437addfb-8f29-5135-9939-8a52f4cf8a3f', 'Bắc Ninh – Day Trip 1 Ngày từ Hà Nội — Văn hóa & Làng nghề', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## Day Trip 1 Ngày từ Hà Nội — Văn hóa & Làng nghề
> Chi tiết →  id: 

- Sáng: Khởi hành từ Hà Nội → Cụm chùa Thuận Thành (Chùa Dâu + Chùa Bút Tháp)
- Trưa: Ăn bún cá rô và đặc sản tại thành phố Bắc Ninh
- Chiều: Đền Đô + mua bánh phu thê Đình Bảng → Làng tranh Đông Hồ → Về Hà Nội trước 16:30', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b1ce3513-9711-5f27-abf6-6510b7340ab7', 'Bắc Ninh – 2 Ngày 1 Đêm — Văn hóa sâu + Làng nghề', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 2 Ngày 1 Đêm — Văn hóa sâu + Làng nghề
> Chi tiết →  id: 

- Ngày 1: Chùa Dâu → Chùa Bút Tháp → Nhận phòng → Đền Đô → Ăn tối phố cổ
- Ngày 2: Làng gốm Phù Lãng buổi sáng → Ăn trưa → Làng tranh Đông Hồ → Về Hà Nội

---', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '629581f6-4740-5838-86d0-ead4f62ec151', 'Bắc Ninh – 🚨 Kinh Nghiệm An Toàn', 'safety', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 🚨 Kinh Nghiệm An Toàn

- ⚠️ Giờ tan ca khu công nghiệp (16:30–18:30): Hàng nghìn công nhân Samsung, Canon, Foxconn ra cổng cùng lúc, đường vào/ra Bắc Ninh tắc nặng. Nếu đi day trip, hãy sắp xếp rời trước 16:00 hoặc chờ sau 19:00.
- ⚠️ Hội Lim rất đông: Đây là lễ hội lớn, thu hút hàng chục nghìn người. Cất ví và điện thoại trong balo đeo trước người. Trẻ em dễ lạc — nên cầm tay và mặc quần áo màu nổi bật.
- ⚠️ Đường tới làng nghề: Đường vào làng Phù Lãng và Đông Hồ nhỏ, dễ lạc nếu không có người dẫn. Tải bản đồ offline hoặc hỏi người dân khi bắt đầu đường làng.

---', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a94087ae-032d-517f-a524-60c9c28741ef', 'Bắc Ninh – 🚌 Di chuyển thông minh', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 🚌 Di chuyển thông minh
- Xe buýt 204 từ Bến xe Gia Lâm là cách rẻ nhất đến Bắc Ninh. Phù hợp nếu xuất phát từ phía Đông Hà Nội. *(Thông tin chi tiết: xem transport.json)*
- Thuê xe máy khi đến Bắc Ninh là lựa chọn linh hoạt nhất để khám phá làng nghề rải rác. *(Gợi ý phương tiện: xem transport.json)*', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '94410af2-9433-58f6-8414-d7add31cc64a', 'Bắc Ninh – 📅 Timing thông minh', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 📅 Timing thông minh
- Dịp Hội Lim (tháng 1 âm lịch): Là dịp xem quan họ thật sự nhất. Đặt xe từ Hà Nội từ vài ngày trước.
- Ngày thường, buổi sáng sớm: Chùa và di tích vắng, không khí thanh tịnh, ánh sáng đẹp nhất để chụp ảnh.
- Tránh trưa hè tháng 6–8: Ngoài trời rất nóng. Sắp xếp nghỉ trong nhà hàng hoặc quán từ 11:30–13:30.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '688707fd-cadb-5e89-91c6-e5725919fafa', 'Bắc Ninh – 🎶 Trải nghiệm Quan họ thật', 'activity', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 🎶 Trải nghiệm Quan họ thật
- Muốn nghe hát quan họ authentic (không phải biểu diễn thương mại), ghé thăm vào dịp Hội Lim hoặc liên hệ câu lạc bộ quan họ tại Làng Diềm (làng Quan họ gốc ở xã Hòa Long).
- Tránh các điểm "quan họ du lịch" tại trung tâm thành phố — chất lượng và trải nghiệm văn hóa không bằng.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '48b5317e-0b3e-57ef-ba55-93b93e779c31', 'Bắc Ninh – 📸 Chụp ảnh', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 📸 Chụp ảnh
- Chùa Bút Tháp: Ánh sáng đẹp nhất 7:30–9:00 sáng khi nắng chiếu qua cây đại thụ trong sân.
- Chùa Dâu: Chụp tháp Hòa Phong từ góc phía Nam, sáng sớm.
- Làng Đông Hồ: Màu sắc tranh rực rỡ nhất khi chụp trong nhà có ánh sáng tự nhiên.

---', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a316706a-8294-55d1-8c0c-26fc96dff151', 'Bắc Ninh – 🛒 Mua Sắm & Đặc Sản Mang Về', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

*(Địa chỉ và giá: xem  và )*

| Sản phẩm | Mua ở đâu tốt nhất | Ghi chú |
|---|---|---|
| Bánh phu thê Đình Bảng | Làng Đình Bảng, thị xã Từ Sơn | Mua buổi sáng khi bánh còn mới. Dùng trong 2–3 ngày |
| Tranh dân gian Đông Hồ | Trực tiếp từ gia đình nghệ nhân | Gọi điện trước. Tranh cuộn dễ mang về |
| Gốm Phù Lãng | Trực tiếp tại lò gốm | Rẻ hơn nhiều so với mua ở Hà Nội |
| Rượu làng Vân | Làng Vân (huyện Việt Yên) hoặc cửa hàng đặc sản | Xin xem nhãn mác để chọn rượu gốc |
| Nem Bùi | Chợ Bùi hoặc quán đặc sản Bắc Ninh | Ăn ngay, không để qua đêm nhiều |

---', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7ba573fc-c0a8-5c26-abc3-86c88e3b5a18', 'Bắc Ninh – 📞 Thông Tin Liên Hệ Hữu Ích', 'tip', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## 📞 Thông Tin Liên Hệ Hữu Ích

- Sở Du lịch tỉnh Bắc Ninh: bacninh.gov.vn
- Xe buýt Hà Nội–Bắc Ninh (tuyến 204): Bến xe Gia Lâm, tần suất ~20–30 phút/chuyến
- Cấp cứu: 115 | Cảnh sát: 113', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f3033920-2942-5470-abcc-182773afa5a6', 'FAQ Du lịch Bắc Ninh (1)', 'faq', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  '## ❓ FAQ Du Lịch Bắc Ninh

---

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm đẹp nhất để đến Bắc Ninh là khi nào?
A: Tháng 9–11 (thu mát, trời khô, ít mưa) và tháng 1–3 (mùa hội chùa, hát quan họ đầu xuân) là hai khoảng thời gian lý tưởng nhất. Đặc biệt dịp Hội Lim (12–13 tháng Giêng âm lịch) và Lễ hội Đền Đô (14–16 tháng 3 âm lịch) là thời điểm sôi động và đặc sắc nhất của Bắc Ninh. *(Chi tiết lễ hội: xem events.json)*

Q: Bắc Ninh có mấy mùa? Mùa mưa kéo dài bao lâu?
A: Bắc Ninh có 4 mùa rõ rệt như toàn bộ miền Bắc. Mùa hè (tháng 5–8) nóng ẩm, dễ có mưa rào buổi chiều. Mùa đông (tháng 12–2) lạnh khô. Mùa xuân và thu là khoảng thời gian dễ chịu nhất. Nếu đi vào tháng 6–8, nên mang áo mưa nhỏ.

Q: Đi Bắc Ninh mùa đông có lạnh quá không?
A: Mùa đông Bắc Ninh (tháng 12–2) lạnh và hanh khô, nhiệt độ có thể xuống 10–15°C vào đêm. Không quá khắc nghiệt nhưng cần mang áo khoác dày nếu đi đầu mùa đông. Ưu điểm: ít khách du lịch, các chùa và làng nghề yên tĩnh hơn.

---

## 💰 Chi phí & Ngân sách

Q: Chi phí đi Bắc Ninh 1–2 ngày hết bao nhiêu?
A: Bắc Ninh là điểm du lịch rất tiết kiệm, phù hợp làm day trip từ Hà Nội với chi phí thấp. Phần lớn chùa và di tích không thu phí vào cửa hoặc miễn phí. Chi phí chính là phương tiện đi lại, ăn uống và mua đặc sản làm quà. *(Thông tin khách sạn và tham quan: xem hotels.json và destinations.json)*

Q: Có cần đặt phòng trước không?
A: Bắc Ninh chỉ cách Hà Nội khoảng 30km nên phần lớn du khách đi về trong ngày, không cần đặt phòng. Nếu ở lại, nên đặt trước khi đi vào dịp Hội Lim hoặc lễ hội lớn — khách sạn trong tỉnh có thể hết phòng. *(Danh sách khách sạn: xem hotels.json)*', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e24cd03d-6cf2-54ab-a6fb-b6fe82427692', 'FAQ Du lịch Bắc Ninh (2)', 'faq', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Q: Phí vào cửa các chùa và di tích có đắt không?
A: Hầu hết chùa cổ tại Bắc Ninh (Chùa Dâu, Chùa Bút Tháp, Đền Đô) không thu phí vào cửa hoặc chỉ gợi ý công đức tự nguyện. Chúng tôi chưa có thông tin giá vé chính thức cập nhật — bạn có thể kiểm tra tại website Sở Du lịch Bắc Ninh hoặc hỏi trực tiếp khi đến.

---

## 🚗 Di chuyển

Q: Từ Hà Nội đến Bắc Ninh bằng phương tiện gì?
A: Có 3 lựa chọn phổ biến: (1) Xe buýt từ Bến xe Gia Lâm — rẻ nhất, khoảng 45–60 phút; (2) Taxi/Grab từ nội thành Hà Nội; (3) Tự lái xe máy theo đường Yên Viên. Không có tàu hỏa trực tiếp tới trung tâm tỉnh. *(Chi tiết tuyến, giá và nhà xe: xem transport.json)*

Q: Di chuyển trong Bắc Ninh bằng gì?
A: Grab và xe ôm là tiện nhất để di chuyển giữa các điểm tham quan trong nội thành. Thuê xe máy phù hợp nếu muốn tự khám phá các làng nghề rải rác như Đông Hồ, Phù Lãng. Xe đạp cũng ổn trong khu vực huyện Thuận Thành vì đường bằng phẳng. *(Chi tiết phương tiện và mẹo di chuyển: xem transport.json)*

Q: Bắc Ninh sau sáp nhập có đến được Tây Yên Tử không?
A: Có — sau sáp nhập 2025, khu vực Bắc Giang cũ (bao gồm Tây Yên Tử, Lục Ngạn) nay thuộc tỉnh Bắc Ninh. Từ thành phố Bắc Ninh cũ đến Tây Yên Tử khoảng 80–100km, nên dành ngày riêng và đi xe riêng. Không thể kết hợp trong cùng chuyến day trip từ Hà Nội.

---

## 🏨 Lưu trú

Q: Nên ở khu vực nào tại Bắc Ninh?
A: Hầu hết khách lưu trú ở trung tâm thành phố Bắc Ninh, thuận tiện di chuyển đến hầu hết điểm tham quan. Nếu muốn trải nghiệm văn hóa sâu hơn, có thể tìm homestay tại Làng Diềm (làng Quan họ gốc). *(Danh sách khách sạn và homestay: xem hotels.json)*', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '91eb1fc3-aecc-559c-b80e-4e444509fd05', 'FAQ Du lịch Bắc Ninh (3)', 'faq', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Q: Bắc Ninh có resort không?
A: Bắc Ninh chủ yếu đón khách công vụ và du lịch ngắn ngày nên ít resort, chủ yếu là khách sạn thương mại 2–4 sao. Nếu muốn resort sang trọng, Hà Nội hoặc Ninh Bình có nhiều lựa chọn hơn.

---

## 🍜 Ẩm thực

Q: Đặc sản nổi tiếng nhất của Bắc Ninh là gì?
A: Bánh phu thê Đình Bảng, nem Bùi, bún cá rô đồng và rượu làng Vân là những đặc sản không thể bỏ qua. Bánh phu thê mua tại làng Đình Bảng mới là chính gốc và ngon nhất. *(Mô tả chi tiết từng món: xem foods.json)*

Q: Có món chay không?
A: Bắc Ninh có nhiều chùa nên các quán cơm chay phục vụ khách hành hương khá phổ biến, đặc biệt vào ngày rằm, mùng 1 và dịp lễ hội. Bánh phu thê và bánh tro đều là món chay tự nhiên. Hỏi người dân địa phương để tìm quán cơm chay gần nhất.

---

## ❓ Câu hỏi ngoài phạm vi

Q: Có thể đặt vé tour Bắc Ninh qua hệ thống này không?
A: Hệ thống này cung cấp thông tin du lịch tham khảo, không hỗ trợ đặt tour trực tuyến. Để đặt tour, bạn có thể tham khảo Klook (klook.com/vi), Traveloka hoặc các công ty lữ hành địa phương tại Bắc Ninh.

Q: Thông tin về điểm du lịch ở Bắc Giang cũ (Tây Yên Tử, Lục Ngạn)?
A: Dữ liệu chi tiết về khu vực Bắc Giang cũ (nay thuộc tỉnh Bắc Ninh sau sáp nhập 2025) chưa được bổ sung đầy đủ vào hệ thống. Để có thông tin chính xác nhất về Tây Yên Tử và Lục Ngạn, bạn có thể tham khảo Vietnam Tourism tại vietnamtourism.gov.vn hoặc Cổng thông tin tỉnh Bắc Ninh tại bacninh.gov.vn.

---

## ⚠️ An toàn & Lưu ý

Q: Có lưu ý gì về an toàn khi đến Bắc Ninh?
A: Bắc Ninh là tỉnh khá an toàn, tỷ lệ tội phạm thấp. Khi đến Hội Lim và các lễ hội đông người, nên cất đồ đạc cẩn thận. Lưu ý giao thông đông đặc quanh khu công nghiệp (Samsung, Canon) vào giờ tan ca 17:00–18:30 — nên sắp xếp rời trước 16:30 hoặc sau 19:00.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'cd94f684-c4a8-54ae-a9c1-6e0c5866aec9', 'FAQ Du lịch Bắc Ninh (4)', 'faq', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Q: Cần chuẩn bị gì trước khi đến các chùa, đền?
A: Mặc trang phục kín đáo (vai và gối được che), không mang giày vào chánh điện (thường có dép để sẵn). Vào dịp lễ hội nên đặt phương tiện từ sớm vì đường ùn tắc. Mang theo nước uống và kem chống nắng khi đi tham quan ngoài trời vào mùa hè.

Q: Điện thoại có sóng không?
A: Toàn tỉnh Bắc Ninh có phủ sóng 4G tốt từ các nhà mạng lớn (Viettel, Mobifone, Vinaphone). Ngay cả tại các làng nghề xa trung tâm như Phù Lãng, Đông Hồ vẫn có sóng bình thường.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '2546a8ca-da61-5891-b6ce-2f1792ba59de', 'Ẩm thực đặc sản Bắc Ninh', 'food', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Đặc sản ẩm thực Bắc Ninh:
- Bánh phu thê Đình Bảng: Bánh vuông nhỏ làm từ bột gạo nếp hoặc bột sắn dây, nhân đậu xanh ngọt trộn dừa nạo, vỏ bánh trong mờ bọc trong lá dong xanh. Mềm dẻo, thơm nhẹ, ngọt thanh. Đặc sản nổi tiếng nhất Bắc Ninh và là quà b
  Địa điểm thưởng thức: [''Làng Đình Bảng, phường Đình Bảng, thị xã Từ Sơn (mua tại các hộ gia đình làng nghề)'', ''Khu vực gần Đền Đô (các quầy hàng lưu niệm)'']
- Nem Bùi: Nem cuốn truyền thống của Bắc Ninh làm từ thịt lợn giã nhuyễn, trộn bì, gia vị và lá đinh lăng, bọc trong lá chuối lên men chua nhẹ. Ăn kèm với tỏi, ớt và lá sung, lá ổi. Hương vị đặc trưng chua ngọt 
  Địa điểm thưởng thức: [''Chợ Bùi, thành phố Bắc Ninh'', ''Các quán đặc sản trên phố Ngô Gia Tự'']
- Bún cá rô Bắc Ninh: Món bún sáng đặc trưng của người Bắc Ninh, nước dùng từ cá rô đồng ngọt tự nhiên, ăn kèm bún tươi, rau sống và chả cá chiên vàng. Vị thanh đạm, nhẹ nhàng khác hẳn bún bò hay bún riêu miền Nam.
  Địa điểm thưởng thức: [''Các quán bún sáng quanh chợ trung tâm thành phố Bắc Ninh'', ''Phố Ngô Gia Tự và khu vực hồ Hoàn Kiếm Bắc Ninh'']
- Rượu làng Vân: Rượu gạo nếp cái hoa vàng được nấu thủ công tại làng Vân (nay thuộc huyện Việt Yên, Bắc Ninh sau sáp nhập). Nồng độ 40–50 độ, màu trong suốt, hương thơm đặc trưng của nếp cái. Từng là rượu tiến vua th
  Địa điểm thưởng thức: [''Làng Vân, huyện Việt Yên (mua trực tiếp tại làng)'', ''Các cửa hàng đặc sản tại thành phố Bắc Ninh'']
- Bánh tro Bắc Ninh: Bánh làm từ gạo nếp ngâm nước tro đốt từ củi tre, gói lá dong, luộc chín có màu vàng nâu trong suốt. Ăn kèm mật mía hoặc đường. Vị thanh nhẹ, không ngấy, mát lành. Thường xuất hiện vào dịp Tết Đoan Ng
  Địa điểm thưởng thức: [''Chợ trung tâm thành phố Bắc Ninh'', ''Các chợ làng quê trong tỉnh'']
- Xôi lúa (xôi ngô): Xôi nếp nấu cùng ngô non xay vỡ, hạt dền hoặc đậu, rắc dừa nạo và đường. Vị ngọt bùi đặc trưng, là món ăn sáng hoặc ăn vặt phổ biến của người Bắc Ninh.
  Địa điểm thưởng thức: [''Các xe đẩy gánh xôi sáng trước cổng chợ'', ''Khu phố ẩm thực trung tâm thành phố'']', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '4c9c11d0-6e76-540e-80e8-524f5dd064b2', 'Cách di chuyển đến Bắc Ninh', 'transport', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Di chuyển đến và trong Bắc Ninh:

Cách đến:
- BUS từ Hà Nội (Bến xe Gia Lâm): 45–60 phút — 15.000–20.000đ (tham khảo — xác nhận tại nhà xe)
  Tuyến 204 xuất phát từ Bến xe Gia Lâm, tần suất khoảng 20–30 phút/chuyến. Đây là phương tiện rẻ nhất và phổ biến nhất cho khách từ Hà Nội.
- BUS từ Hà Nội (Bến xe Mỹ Đình): 60–90 phút (tùy tắc đường) — None
  Có xe khách từ Bến xe Mỹ Đình đến Bắc Ninh. Phù hợp cho khách ở phía Tây Hà Nội. Xác nhận giờ và giá tại bến xe.
- CAR từ Hà Nội (nội thành): 30–60 phút (tùy điểm xuất phát và giờ đi) — 150.000–300.000đ (taxi/Grab — ước tính)
  Đi theo Quốc lộ 1A hoặc đường cao tốc Hà Nội–Bắc Ninh. Tắc đường vào giờ cao điểm và dịp cuối tuần lễ hội. Thuê xe tự lái hoặc có tài xế cũng là lựa chọn tiện.
- MOTORBIKE từ Hà Nội (nội thành): 40–60 phút — None
  Nhiều bạn trẻ và du khách tự lái xe máy từ Hà Nội. Đi theo đường Yên Viên qua cầu Đuống hoặc cầu Chui. Phù hợp thời tiết đẹp, không nên đi mùa mưa hay đêm muộn.

Di chuyển trong thành phố:
- grab: Grab hoạt động tại thành phố Bắc Ninh và các thị xã lớn. Tiện lợi nhất cho di chuyển giữa các điểm tham quan trong nội thành. Ít xe hơn Hà Nội nên đặt trước 5–10 phút.
- xe_om: Xe ôm truyền thống có ở bến xe, gần chợ và khu trung tâm. Thỏa thuận giá trước khi đi. Phù hợp cho quãng đường ngắn trong thị trấn.
- taxi: Taxi địa phương (Taxi Bắc Ninh, Taxi Mai Linh...) có mặt khắp thành phố. Nên bắt taxi có đồng hồ tính tiền hoặc thỏa thuận giá từ đầu.
- motorbike_rental: Thuê xe máy rất phù hợp để khám phá các làng nghề và di tích nằm rải rác (Đông Hồ, Phù Lãng, chùa Dâu, chùa Bút Tháp). Hỏi khách sạn để giới thiệu điểm thuê uy tín.', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '9e938029-d2f8-554d-ba39-e97571e4285d', 'Khách sạn & Lưu trú tại Bắc Ninh', 'hotel', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Lưu trú tại Bắc Ninh:
- Aria Hotel Bắc Ninh (3★): Khu vực trung tâm thành phố Bắc Ninh (xác nhận địa chỉ chính xác tại Google Maps)
  Tiện ích: wifi, điều hòa, bãi đỗ xe, nhà hàng
- TTC Hotel Bắc Ninh (4★): Khu vực trung tâm thành phố Bắc Ninh (xác nhận địa chỉ chính xác tại Google Maps)
  Tiện ích: wifi, hồ bơi, gym, nhà hàng
- Khách sạn Phương Đông (2★): Khu vực phố Ngô Gia Tự, thành phố Bắc Ninh (xác nhận số nhà tại Google Maps)
  Tiện ích: wifi, điều hòa, lễ tân, bãi đỗ xe
- Bắc Ninh Palace Hotel (3★): Khu vực đường Lý Thái Tổ, thành phố Bắc Ninh (xác nhận số nhà tại Google Maps)
  Tiện ích: wifi, điều hòa, nhà hàng, bãi đỗ xe
- Homestay Quan Họ Làng Diềm (None★): Làng Diềm (Viêm Xá), xã Hòa Long, thành phố Bắc Ninh
  Tiện ích: wifi, bữa sáng địa phương, trải nghiệm văn hóa quan họ', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'cdde2d71-d031-5389-b40b-95c86ff3be40', 'Tour & Trải nghiệm tại Bắc Ninh', 'tour', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Tour & Trải nghiệm tại Bắc Ninh:
- Tour Chùa Cổ Bắc Ninh – Cụm Thuận Thành: Nửa ngày (4–5 tiếng) — liên hệ
  Tour tham quan cụm di tích Phật giáo cổ nhất Việt Nam tại huyện Thuận Thành: Chùa Dâu (Pháp Vân) — ngôi chùa cổ nhất VN — và Chùa Bút Tháp với kiến trúc thế kỷ 17 nguyên vẹn. Hướng dẫn viên giải thích lịch sử Phật giáo Giao Chỉ và ý nghĩa các công tr
- Tour Làng Nghề Truyền Thống Bắc Ninh: Một ngày (6–7 tiếng) — liên hệ
  Tour trải nghiệm hai làng nghề đặc sắc nhất Bắc Ninh: Làng tranh dân gian Đông Hồ (xem và thử in tranh) và Làng gốm Phù Lãng (xem thợ làm gốm thủ công). Kết hợp ăn trưa đặc sản bánh phu thê và nem Bùi tại nhà hàng địa phương.
- Tour Văn Hóa Quan Họ & Đền Đô: Một ngày (6–8 tiếng) — liên hệ
  Tour văn hóa đặc sắc kết hợp thăm Đền Đô (đền thờ 8 vua triều Lý tại Từ Sơn), mua bánh phu thê Đình Bảng và thưởng thức chương trình hát quan họ dân gian. Tour được tổ chức đặc biệt vào dịp lễ hội Đền Đô (tháng 3 âm lịch) và Hội Lim (tháng 1 âm lịch)', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '94fd5cdf-048e-5713-bb3b-4a4d6a7dbc0f', 'Lễ hội & Sự kiện tại Bắc Ninh', 'event', '3d01b622-f917-44bb-9054-c5b6001c52ee',
  'Lễ hội & Sự kiện tại Bắc Ninh:
- Hội Lim – Lễ hội Quan họ Bắc Ninh: Ngày 12–13 tháng Giêng âm lịch (thường vào tháng 2 dương lịch)
  Lễ hội quan họ lớn và nổi tiếng nhất tỉnh Bắc Ninh, thu hút hàng chục nghìn du khách mỗi năm. Tổ chức hát quan họ trên thuyền tại hồ Lim, trên đồi và trong các đình làng xung quanh. Quan họ Bắc Ninh được UNESCO công nhận là Di sản văn hóa phi vật thể
- Lễ hội Đền Đô (Đền Lý Bát Đế): Ngày 14–16 tháng 3 âm lịch (thường vào tháng 4–5 dương lịch)
  Lễ hội tưởng nhớ 8 vị vua triều Lý — triều đại đặt kinh đô Thăng Long và xây dựng Văn Miếu. Lễ hội có rước kiệu trang trọng, tế lễ, hát quan họ và các trò diễn dân gian. Đây là một trong những lễ hội lịch sử quan trọng nhất của người Kinh Bắc.
- Lễ hội Chùa Dâu: Ngày mùng 8 tháng 4 âm lịch (thường vào tháng 5 dương lịch)
  Lễ hội thờ Tứ Pháp — bốn vị nữ thần bảo hộ nông nghiệp (Pháp Vân, Pháp Vũ, Pháp Lôi, Pháp Điện) tại ngôi chùa cổ nhất Việt Nam. Lễ hội gồm rước kiệu, tế lễ và các nghi lễ cầu mưa thuận gió hòa đặc trưng của nông nghiệp truyền thống. Di sản văn hóa ph
- Lễ hội Tây Yên Tử (khu vực Bắc Giang cũ): Mùng 10 tháng Giêng đến hết tháng 3 âm lịch
  Lễ hội hành hương về khu di tích Tây Yên Tử — sườn Tây của núi Yên Tử, nơi Phật hoàng Trần Nhân Tông đặt chân tu hành trên đường lên đỉnh. Dành cho người yêu leo núi tâm linh, kết hợp cảnh quan thiên nhiên rừng núi và các đền chùa cổ dọc đường lên đỉ', ARRAY['bac-ninh', 'bắc ninh', 'bắc ninh', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '37f5cd7b-48a2-5c71-8370-caaaab7dea0b', 'Tổng quan du lịch Cà Mau', 'destination', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Tổng quan Cà Mau (Cà Mau):
Điểm cực Nam đất nước với Mũi Cà Mau, rừng ngập mặn U Minh Hạ và hệ sinh thái đước bạt ngàn; sau sáp nhập còn có cánh đồng điện gió Bạc Liêu và nhà Công tử Bạc Liêu.

Mùa đẹp nhất: Tháng 12–4 (mùa khô)
Thời tiết: Nóng ẩm 25–34°C quanh năm, mùa mưa tháng 5–11
Ẩm thực: Cua Cà Mau, ba khía, cá thòi lòi, mắm ong rừng U Minh
Ngân sách tham khảo: ', ARRAY['ca-mau', 'cà mau', 'cà mau', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '80675fe7-1a81-5bf7-be7c-0a1a3d9aa74e', 'Cà Mau – 🌟 Kinh Nghiệm Du Lịch Cà Mau', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 🌟 Kinh Nghiệm Du Lịch Cà Mau

Cà Mau là tỉnh cực Nam của Tổ quốc — nơi đất nước "nở ra" theo đúng nghĩa đen khi đất bồi tiếp tục mở rộng ra biển mỗi năm. Sau sáp nhập năm 2025, tỉnh Cà Mau mới bao gồm cả vùng Bạc Liêu với điện gió và di sản đờn ca tài tử. Đây không phải điểm đến cho người thích tiện nghi sang trọng — mà là cho những ai muốn chạm vào thiên nhiên hoang sơ, ăn hải sản đúng nghĩa và đứng trước cột mốc thiêng liêng nhất Tổ quốc.

---', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6060f2d7-9ba3-5b7b-8e03-81da0d55cb14', 'Cà Mau – 1. Mũi Cà Mau — Cột mốc số 0', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 1. Mũi Cà Mau — Cột mốc số 0
Loại: Điểm cực Nam, di tích quốc gia
Khu vực: Xã Đất Mũi, huyện Ngọc Hiển — vào bằng đường thủy
Giờ mở cửa: Xác nhận trước khi đến *(xem destinations.json)*
Giá vé: Chưa có thông tin xác thực — *liên hệ Sở Du lịch Cà Mau để xác nhận*
Tip: Đặt chân lên đây không chỉ là "check-in" — đây là cảm giác đứng tại điểm tận cùng đất nước, nhìn ra nơi ba dòng biển gặp nhau. Đến sáng sớm để tránh nóng và chụp ảnh đẹp hơn. Đường vào dài nên mang dép kín và nước uống đủ.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f88c0962-d414-59db-b247-7c273def6d59', 'Cà Mau – 2. Vườn Quốc gia U Minh Hạ', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 2. Vườn Quốc gia U Minh Hạ
Loại: Rừng tràm, sinh thái
Khu vực: Huyện U Minh — ~40km từ TP. Cà Mau
Giờ mở cửa: Thường 7:00–17:00 *(xác nhận trước khi đến)*
Giá vé: Chưa có thông tin xác thực — *liên hệ Ban quản lý VQG U Minh Hạ*
Tip: Đừng chỉ đi đường bộ — thuê thuyền chèo là cách duy nhất để thực sự thấm được không khí rừng tràm trên đất than bùn. Mang theo ống nhòm để quan sát chim. Đi mùa khô để không lo cháy rừng.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c299361c-93bb-51a2-85c7-2d721c695c26', 'Cà Mau – 3. Rừng đước Năm Căn', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 3. Rừng đước Năm Căn
Loại: Rừng ngập mặn, hệ sinh thái
Khu vực: Huyện Năm Căn — ~80km từ TP. Cà Mau, đi thuyền
Giờ mở cửa: Mở cửa hằng ngày
Giá vé: Phí thuyền — *liên hệ tại bến Năm Căn để biết giá*
Tip: Bộ rễ đước cao ngang đầu người — nhìn từ thuyền rất ấn tượng. Chợ nổi Năm Căn họp sáng sớm là điểm thú vị để mua hải sản tươi sống với giá thực của người địa phương, không phải giá du lịch.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '70941e42-9045-52eb-8a29-421dd244404e', 'Cà Mau – 4. Đầm Thị Tường — Thiên đường của chim', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 4. Đầm Thị Tường — Thiên đường của chim
Loại: Đất ngập nước, quan sát chim
Khu vực: Huyện Cái Nước / Phú Tân
Giờ tốt nhất: Bình minh 5:00–7:00, mùa chim tháng 11–3
Giá: Phí thuyền — *liên hệ hướng dẫn viên địa phương*
Tip: Đây là khoảnh khắc khó quên: hàng nghìn con cò, vạc bay lên đồng loạt khi mặt trời mọc trên mặt đầm phẳng lặng. Không đến mùa chim thì cảnh quan vẫn đẹp nhưng sẽ kém ấn tượng hơn nhiều.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8c3840d6-4efd-5824-8579-ce1730cafeed', 'Cà Mau – 5. Nhà Công tử Bạc Liêu và Cánh đồng điện gió', 'activity', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 5. Nhà Công tử Bạc Liêu và Cánh đồng điện gió
Loại: Di tích kiến trúc + cảnh quan năng lượng sạch
Khu vực: TP. Bạc Liêu (nay thuộc tỉnh Cà Mau)
Giờ mở cửa nhà Công tử: Thường 7:00–17:00 *(xác nhận trước)*
Tip: Kết hợp hai điểm này trong một buổi chiều hiệu quả: tham quan nhà Công tử sáng, chiều ra bờ biển xem điện gió vào lúc hoàng hôn. Ánh sáng chiều tà chiếu vào các turbine trắng giữa biển xanh tạo ra khung cảnh siêu thực.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ebbf392d-6b40-5913-8643-0f576089f9f7', 'Cà Mau – 6. Hòn Đá Bạc', 'activity', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 6. Hòn Đá Bạc
Loại: Đảo đá, di tích đường Hồ Chí Minh trên biển
Khu vực: Ngoài khơi huyện Trần Văn Thời — đi thuyền từ bờ
Tip: Kết hợp được cả tham quan di tích lịch sử và khám phá thiên nhiên biển đảo. Ít đông đúc hơn các điểm khác nên phù hợp nếu muốn không gian thoáng.

---', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7d2176c5-15e8-554b-b849-9404c6e3d5ee', 'Cà Mau – 3 Ngày 2 Đêm — Gia đình khám phá cực Nam', 'activity', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 3 Ngày 2 Đêm — Gia đình khám phá cực Nam
> Chi tiết →  id: 

- Ngày 1: TP. Cà Mau — tham quan chợ đặc sản, bắt tàu vào Năm Căn, cơm tối cua biển
- Ngày 2: Đất Mũi — đặt chân lên cột mốc số 0, trưa hải sản Đất Mũi, chiều về TP.
- Ngày 3: Bạc Liêu — nhà Công tử, điện gió hoàng hôn, mua đặc sản về', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8d313e95-6b36-530a-9e8d-23707a6b2018', 'Cà Mau – 2 Ngày 1 Đêm — Phượt thủ sinh thái', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 2 Ngày 1 Đêm — Phượt thủ sinh thái
> Chi tiết →  id: 

- Ngày 1: Homestay rừng tràm U Minh — thuyền chèo khám phá VQG, thử mật ong tươi
- Ngày 2: Bình minh đầm Thị Tường — thuê thuyền ngắm chim bay, về mua đặc sản

---', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6dfc1f1a-0216-53d3-b90f-e43798ba8139', 'Cà Mau – 🚨 Kinh Nghiệm An Toàn', 'safety', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 🚨 Kinh Nghiệm An Toàn

- Đi thuyền: Luôn mặc áo phao trên tàu/thuyền, không ngồi trên mui trong khi chạy nhanh. Kiểm tra thời tiết biển trước khi đi Hòn Đá Bạc hoặc chuyến đường dài vào Đất Mũi.

- Rừng ngập mặn: Không tự ý vào rừng một mình nếu không quen địa hình — kênh rạch chằng chịt rất dễ lạc. Luôn đi cùng hướng dẫn viên hoặc người dân địa phương.

- Mùa khô rừng tràm: Tháng 3–4 là mùa khô nhất, rừng tràm U Minh dễ cháy — tuân thủ nghiêm túc quy định không đốt lửa, hút thuốc trong rừng.

- Nắng gắt: Cà Mau nằm ở vĩ độ thấp, nắng mạnh quanh năm — mặc đồ che nắng, đội mũ và thoa kem chống nắng khi ra ngoài, đặc biệt khi đi thuyền trên sông.

---', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '843e8003-2f32-5c6b-9fd1-9e0e47c1137f', 'Cà Mau – 📅 Lên kế hoạch', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 📅 Lên kế hoạch
- Đặt vé máy bay/xe khách và khách sạn trước ít nhất 2 tuần vào mùa cao điểm (lễ Tết, tháng 12–2).
- Lịch trình vào Đất Mũi phụ thuộc hoàn toàn vào thời tiết — có phương án dự phòng nếu biển động.
- Các tour sinh thái U Minh và đầm Thị Tường nên đặt trước vì số lượng thuyền có hạn.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ed342702-6f32-5616-8ad9-00cf14a6ab99', 'Cà Mau – 🚤 Di chuyển đường thủy', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 🚤 Di chuyển đường thủy
- Tàu cao tốc Năm Căn – Đất Mũi chạy theo lịch cố định — hỏi lịch trước để không bị lỡ chuyến.
- Thuê thuyền nhỏ khám phá rừng nên thỏa thuận giá rõ ràng trước khi lên thuyền.
- Mang túi chống nước cho máy ảnh và điện thoại khi đi thuyền.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '0c0bdab9-ee82-5782-a462-9498a32f7045', 'Cà Mau – 🦟 Sức khỏe', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 🦟 Sức khỏe
- Mang theo thuốc chống muỗi và xịt côn trùng — cần thiết khi vào rừng.
- Hải sản Cà Mau nên ăn chín — tránh gỏi sống tại các quán không rõ uy tín.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '92ec8983-2705-5996-ad37-27d2a6e8156d', 'Cà Mau – 📸 Chụp ảnh', 'tip', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 📸 Chụp ảnh
- Bình minh đầm Thị Tường (5:30–6:30 sáng, tháng 11–3): khung cảnh chim bay + bầu trời hồng.
- Hoàng hôn cánh đồng điện gió Bạc Liêu (17:30–18:30): ánh sáng vàng chiếu vào turbine trắng.
- Đường gỗ vào Mũi Cà Mau buổi sáng sớm trước 9:00: ánh sáng đẹp, ít người.

---', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '49bd78be-4c86-5948-bd8e-9d137896576f', 'Cà Mau – 🛒 Mua Sắm & Đặc Sản Mang Về', 'safety', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

| Đặc sản | Mô tả ngắn | Nơi mua tốt nhất |
|---|---|---|
| Tôm khô Cà Mau | Tôm sú/thẻ phơi khô, màu hồng tự nhiên, ngọt đậm | Cảng Sông Đốc, Chợ Cà Mau |
| Ba khía muối Rạch Gốc | Cua nhỏ muối mặn đặc trưng vùng Ngọc Hiển | Chợ Năm Căn, cơ sở đặc sản địa phương |
| Mật ong rừng U Minh | Mật hoa tràm, màu đậm, sánh, thơm đặc biệt | Vườn Quốc gia U Minh Hạ, Chợ Cà Mau |
| Cua biển tươi | Mang về được nếu đi xe/máy bay trong ngày | Chợ Năm Căn, Chợ Cà Mau |
| Bánh tét lá cẩm | Bánh tét màu tím truyền thống miền Tây | Chợ Bạc Liêu, cơ sở bánh truyền thống |
| Muối ớt Bạc Liêu | Muối pha ớt và các gia vị đặc trưng | Chợ Bạc Liêu |

> 💡 Tip mua sắm: Tôm khô và mật ong có thể mang lên máy bay trong hành lý ký gửi (đóng gói kín). Cua sống chỉ nên mua nếu về trong ngày hoặc có hộp giữ lạnh. Hàng đóng hộp tại Co.opmart Cà Mau an toàn nhất nếu mang đi xa.

*(Địa chỉ và giờ mở cửa chi tiết các điểm mua sắm: xem shopping.json)*', ARRAY['ca-mau', 'cà mau', 'cà mau', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'bb1fa8ba-8172-5cd5-8b6f-380907d08a6b', 'FAQ Du lịch Cà Mau (1)', 'faq', '23431b56-3e63-4368-949f-8df24ab3c539',
  '## ❓ FAQ Du Lịch Cà Mau

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm nào trong năm thích hợp nhất để đến Cà Mau?
A: Mùa khô từ tháng 12 đến tháng 4 là thời điểm lý tưởng nhất — trời nắng ráo, ít mưa, đường vào Đất Mũi và rừng đước dễ đi hơn. Tháng 12–2 (dịp Tết) khí hậu dễ chịu nhất. Nếu muốn xem chim ở Đầm Thị Tường, đến vào tháng 11–3 khi chim di cư về trú đông. (Nguồn: Vietnam Tourism / Sở Du lịch Cà Mau)

Q: Mùa mưa ở Cà Mau có đi được không?
A: Mùa mưa (tháng 5–11) vẫn đi được nhưng phức tạp hơn. Mưa thường xuất hiện buổi chiều, nước sông dâng cao làm một số tuyến đường thủy vào Đất Mũi khó khăn hơn. Lợi điểm là giá phòng và tour rẻ hơn, ít du khách hơn. Nếu đi mùa mưa, luôn mang áo mưa và theo dõi thời tiết hằng ngày.

Q: Cà Mau có bị ảnh hưởng bởi bão không?
A: Cà Mau ít bị bão trực tiếp hơn các tỉnh miền Trung, nhưng vùng biển Tây (Vịnh Thái Lan) có thể ảnh hưởng bởi áp thấp nhiệt đới vào tháng 9–11. Nếu có kế hoạch đi thuyền ra Hòn Đá Bạc hoặc vào Đất Mũi, kiểm tra dự báo thời tiết biển trước 1–2 ngày.

---

## 💰 Chi phí & Ngân sách

Q: Chi phí cho một chuyến đi Cà Mau khoảng bao nhiêu?
A: Hiện chúng tôi chưa có dữ liệu giá tổng hợp đã xác thực cho một chuyến đi Cà Mau. Để có ước tính thực tế, bạn có thể xem giá khách sạn trên Booking.com hoặc Agoda, giá vé máy bay trên Traveloka, và liên hệ công ty lữ hành địa phương để hỏi giá tour trọn gói. *(Xem thêm: hotels.json và tours.json)*

Q: Ăn uống tại Cà Mau có đắt không?
A: Cà Mau là điểm đến có chi phí ăn uống đa dạng. Ăn tại chợ và quán bình dân giá rất phải chăng. Cua biển — đặc sản số một — giá dao động theo mùa và thị trường hải sản. Để biết giá cụ thể, bạn có thể xem tại Foody.vn hoặc hỏi trực tiếp nhà hàng trước khi gọi món. *(Xem thêm: restaurants.json và foods.json)*

---

## 🚗 Di chuyển', ARRAY['ca-mau', 'cà mau', 'cà mau', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '064682da-070a-509b-9e23-8922d6d658ff', 'FAQ Du lịch Cà Mau (2)', 'faq', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Q: Từ TP. Hồ Chí Minh đến Cà Mau đi bằng phương tiện gì?
A: Có hai lựa chọn chính: bay thẳng (~1 giờ, nhiều hãng bay) hoặc xe khách giường nằm ban đêm (~7–9 giờ, xuất phát từ bến xe Miền Tây). Bay tiết kiệm thời gian nhất. Xe khách phù hợp nếu muốn tiết kiệm chi phí và trải nghiệm đường dài miền Tây. *(Xem thêm chi tiết: transport.json)*

Q: Từ Cà Mau vào Đất Mũi đi như thế nào?
A: Không có đường bộ đến tận Mũi Cà Mau — bắt buộc phải đi thuyền. Phổ biến nhất là tàu cao tốc từ bến Năm Căn đến Đất Mũi (~1,5 giờ). Một số tour đặt tàu từ TP. Cà Mau đi thẳng luôn. Đây chính là phần thú vị nhất của hành trình — ngắm rừng đước bạt ngàn hai bên sông. *(Xem thêm: transport.json)*

Q: Sân bay Cà Mau ở đâu, cách trung tâm bao xa?
A: Sân bay Cà Mau (mã IATA: CAH) nằm cách trung tâm TP. Cà Mau khoảng 2km — rất gần, có thể đi taxi hoặc Grab về khách sạn trong vài phút. Hiện có các tuyến bay từ Hà Nội và TP. Hồ Chí Minh.

---

## 🏨 Lưu trú

Q: Nên ở đâu khi đến Cà Mau?
A: Có hai khu vực chính để ở: trung tâm TP. Cà Mau (nhiều lựa chọn từ 2–4 sao, thuận tiện di chuyển) và gần điểm đến (nhà nghỉ Đất Mũi, homestay U Minh — trải nghiệm độc đáo hơn nhưng tiện nghi hạn chế). Nếu đây là lần đầu, ở trung tâm TP. rồi đi tour ngày là hợp lý nhất. *(Xem thêm: hotels.json)*

Q: Có nên ở homestay trong rừng U Minh không?
A: Rất đáng thử nếu bạn thích trải nghiệm thiên nhiên thực sự — ngủ trong nhà gỗ trên mặt nước, ăn cơm miền Tây, thức dậy nghe tiếng chim. Tuy nhiên tiện nghi khiêm tốn, sóng điện thoại yếu. Phù hợp cho phượt thủ và những ai muốn tách biệt hoàn toàn khỏi thành phố. *(Xem thêm: hotels.json)*

---

## 🍜 Ẩm thực', ARRAY['ca-mau', 'cà mau', 'cà mau', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '267fd93e-9511-58ec-8862-e23eed7d861f', 'FAQ Du lịch Cà Mau (3)', 'faq', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Q: Những món gì nhất định phải ăn ở Cà Mau?
A: Cua biển Cà Mau là đặc sản số một, nổi tiếng toàn quốc với thịt chắc và gạch béo. Tiếp theo là ba khía muối Rạch Gốc, cá thòi lòi nướng, tôm sú nướng muối ớt. Đừng quên mật ong rừng U Minh và thử bánh canh cua buổi sáng. *(Danh sách đầy đủ: foods.json)*

Q: Mua đặc sản Cà Mau ở đâu để mang về?
A: Chợ Cà Mau trung tâm là nơi bán đủ loại: tôm khô, ba khía đóng hộp, mật ong rừng. Cơ sở đặc sản tại cảng Sông Đốc bán tôm khô chất lượng tốt hơn và rẻ hơn. Nếu muốn an toàn vệ sinh thực phẩm, mua hàng đóng gói tại Co.opmart. *(Xem thêm: shopping.json)*

---

## ❓ Câu hỏi ngoài phạm vi

Q: Giá vé vào Vườn Quốc gia U Minh Hạ hiện tại là bao nhiêu?
A: Hiện chúng tôi chưa có thông tin giá vé cập nhật đã xác thực cho Vườn Quốc gia U Minh Hạ. Bạn có thể kiểm tra trực tiếp tại Ban quản lý Vườn Quốc gia U Minh Hạ, hoặc xem thông tin trên trang Klook (klook.com/vi) và Sở Du lịch Cà Mau (camau.gov.vn) trước khi đến.

Q: Có thể đặt tour Mũi Cà Mau online ở đâu?
A: Thông tin đặt tour online chi tiết hiện chưa có trong hệ thống của chúng tôi. Bạn có thể tìm trên Klook (klook.com/vi), Traveloka, hoặc liên hệ các công ty lữ hành lớn như Vietravel, Saigon Tourist để hỏi tour Cà Mau trọn gói.

---

## ⚠️ An toàn & Lưu ý

Q: Đi thuyền vào Đất Mũi có an toàn không?
A: Về cơ bản an toàn nếu đi vào mùa khô (tháng 12–4) và không có bão. Luôn mặc áo phao được cung cấp trên tàu. Không nên đi thuyền nhỏ tự thuê nếu chưa quen địa hình sông nước Cà Mau — nên đi cùng hướng dẫn viên địa phương hoặc qua tour được cấp phép.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ce58368e-02ea-5d7a-b73e-021371b8b55b', 'FAQ Du lịch Cà Mau (4)', 'faq', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Q: Cần lưu ý gì khi đi rừng U Minh?
A: Rừng U Minh có vắt, muỗi và côn trùng nhiều — cần mặc quần áo dài tay, xịt thuốc chống muỗi. Mùa khô (tháng 12–4) rừng tràm dễ cháy, không vứt rác và tuyệt đối không đốt lửa. Đi theo đường mòn được hướng dẫn, không tự ý vào sâu một mình.

Q: Có vấn đề gì về vệ sinh thực phẩm khi ăn hải sản Cà Mau không?
A: Hải sản tươi Cà Mau nói chung an toàn khi ăn tại nhà hàng và chợ uy tín. Tuy nhiên nên thận trọng với hải sản sống (gỏi, sashimi) tại các quán vỉa hè nhỏ không rõ nguồn gốc. Tôm khô và ba khía đóng hộp có hạn sử dụng — kiểm tra ngày in trên bao bì trước khi mua về.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c598aba3-c5a4-5a9b-a630-3e79dbdbc4b0', 'Ẩm thực đặc sản Cà Mau', 'food', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Đặc sản ẩm thực Cà Mau:
- Cua Cà Mau: Cua biển Cà Mau nổi tiếng khắp cả nước với thịt chắc, gạch béo và hương vị đậm đà nhờ nguồn nước mặn vùng ngập mặn. Có thể chế biến nhiều cách: hấp gừng, rang muối, nướng, nấu canh chua hoặc bún cua. 
  Địa điểm thưởng thức: [''Chợ Cà Mau'', ''Các nhà hàng hải sản TP. Cà Mau'', ''Bến Năm Căn'', ''Chợ cua Cà Mau'']
- Ba khía muối: Đặc sản nổi tiếng của vùng Rạch Gốc - Ngọc Hiển, Cà Mau. Ba khía là loài cua nhỏ sống ở bìa rừng đước, được ướp muối theo phương pháp truyền thống tạo nên món ăn mặn mà hương vị biển rừng. Ăn kèm cơm 
  Địa điểm thưởng thức: [''Chợ Cà Mau'', ''Chợ Năm Căn'', ''Các cơ sở đặc sản địa phương'', ''Huyện Ngọc Hiển'']
- Cá thòi lòi nướng: Cá thòi lòi là loài cá kỳ lạ có thể sống trên cạn và leo cây đước — đặc trưng chỉ có ở vùng rừng ngập mặn. Thịt cá săn chắc, nướng than với sả ớt hoặc kho tiêu có vị ngọt tự nhiên và thơm đặc biệt. Hi
  Địa điểm thưởng thức: [''Nhà hàng đặc sản Cà Mau'', ''Khu vực Năm Căn'', ''Đất Mũi'']
- Mật ong rừng U Minh: Mật ong khai thác từ đàn ong mật tự nhiên trong rừng tràm U Minh Hạ — có màu vàng đậm, độ sánh cao và hương thơm đặc trưng của hoa tràm. Nổi tiếng là một trong những loại mật ong ngon và sạch nhất Việ
  Địa điểm thưởng thức: [''Vườn Quốc gia U Minh Hạ'', ''Chợ Cà Mau'', ''Cơ sở đặc sản địa phương'']
- Bánh tét lá cẩm: Bánh tét đặc trưng miền Tây Nam Bộ nhưng phiên bản Cà Mau được gói bằng lá cẩm tạo màu tím đẹp mắt. Nhân bánh gồm đậu xanh và thịt heo. Thường được làm dịp Tết Nguyên Đán và bán quanh năm tại các chợ.
  Địa điểm thưởng thức: [''Chợ Cà Mau'', ''Chợ TP. Bạc Liêu'', ''Cơ sở làm bánh truyền thống'']
- Tôm khô Cà Mau: Tôm sú và tôm thẻ phơi khô theo phương pháp truyền thống — đặc sản nổi tiếng nhất Cà Mau sau cua biển. Màu đỏ hồng tự nhiên, vị ngọt đậm, dùng nấu canh chua, xào dưa kiệu hoặc ăn kèm cơm. Được bán nhi
  Địa điểm thưởng thức: [''Chợ Cà Mau'', ''Cảng cá Sông Đốc'', ''Năm Căn'']', ARRAY['ca-mau', 'cà mau', 'cà mau', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '67a75683-ed52-5664-8640-e2aaf65d1a13', 'Cách di chuyển đến Cà Mau', 'transport', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Di chuyển đến và trong Cà Mau:

Cách đến:
- AIRPLANE từ TP. Hồ Chí Minh (Tân Sơn Nhất): ~1 giờ bay — None
  Sân bay Cà Mau (CAH) cách trung tâm thành phố khoảng 2km. Đây là phương tiện nhanh nhất để vào Cà Mau. Nên đặt vé trước ít nhất 1–2 tuần vào mùa cao điểm.
- BUS từ TP. Hồ Chí Minh (bến xe Miền Tây): ~7–9 giờ — None
  Xe giường nằm chạy ban đêm phổ biến và tiết kiệm. Nhiều chuyến khởi hành 19:00–21:00 từ bến xe Miền Tây, đến Cà Mau lúc 4:00–6:00 sáng hôm sau.
- BUS từ Cần Thơ: ~3–4 giờ — None
  Tuyến phổ biến cho du khách transit qua Cần Thơ. Nhiều chuyến trong ngày.
- CAR từ TP. Hồ Chí Minh: ~5–6 giờ (cao tốc) — None
  Quốc lộ 1A và cao tốc Trung Lương–Mỹ Thuận–Cao Lãnh rút ngắn đáng kể thời gian. Qua phà Năm Căn nếu vào Đất Mũi.
- BOAT từ Năm Căn → Đất Mũi: ~1,5 giờ — None
  Đây là đoạn bắt buộc phải đi đường thủy để vào Đất Mũi — không có đường bộ đến tận cùng. Trải nghiệm thú vị qua rừng đước bạt ngàn.

Di chuyển trong thành phố:
- motorbike_rental: Phương tiện linh hoạt nhất để khám phá TP. Cà Mau và vùng ven. Thuê tại các cửa hàng gần trung tâm hoặc hỏi khách sạn giới thiệu. Cần bằng lái A1/A2.
- taxi: Taxi Mai Linh hoạt động tại TP. Cà Mau. Phù hợp cho di chuyển trong nội thành và ra sân bay.
- grab: Grab xe máy và Grab car hoạt động tại TP. Cà Mau. Không phủ sóng ở các huyện xa như Năm Căn, Ngọc Hiển.
- xe_om: Xe ôm truyền thống vẫn phổ biến ở các huyện xa. Thỏa thuận giá trước khi lên xe.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '927c1c6e-d989-515b-b759-ed563d4efdee', 'Khách sạn & Lưu trú tại Cà Mau', 'hotel', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Lưu trú tại Cà Mau:
- Mường Thanh Grand Cà Mau (4★): Khu trung tâm TP. Cà Mau, tỉnh Cà Mau
  Tiện ích: wifi, hồ bơi, nhà hàng, phòng gym
- Khách sạn Phương Nam Cà Mau (3★): Khu vực trung tâm TP. Cà Mau
  Tiện ích: wifi, nhà hàng, đỗ xe, điều hòa
- Nhà nghỉ Đất Mũi (None★): Xã Đất Mũi, huyện Ngọc Hiển, tỉnh Cà Mau
  Tiện ích: wifi, quạt/điều hòa, bữa sáng (một số phòng)
- Homestay Rừng Đước U Minh (None★): Khu vực U Minh Hạ, huyện U Minh, tỉnh Cà Mau
  Tiện ích: wifi, bữa ăn theo gói, thuyền tham quan rừng, võng
- Khách sạn Sông Đốc (2★): Thị trấn Sông Đốc, huyện Trần Văn Thời, tỉnh Cà Mau
  Tiện ích: wifi, điều hòa, đỗ xe', ARRAY['ca-mau', 'cà mau', 'cà mau', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'fd9b0b2b-3196-5959-b3e0-2b2243d1f947', 'Tour & Trải nghiệm tại Cà Mau', 'tour', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Tour & Trải nghiệm tại Cà Mau:
- Tour Mũi Cà Mau – Rừng đước Năm Căn: 2 ngày 1 đêm — liên hệ
  Tour đặc trưng nhất Cà Mau: xuất phát từ TP. Cà Mau, di chuyển bằng tàu cao tốc qua huyện Năm Căn ngắm rừng đước, dừng chợ nổi Năm Căn, tiếp tục vào Đất Mũi, đặt chân lên cột mốc quốc gia số 0 — điểm cực Nam Tổ quốc. Đêm nghỉ tại nhà nghỉ Đất Mũi hoặ
- Tour Khám phá Vườn Quốc gia U Minh Hạ: 1 ngày — liên hệ
  Hành trình vào lòng rừng tràm U Minh Hạ bằng thuyền chèo, khám phá hệ sinh thái đất than bùn độc đáo, quan sát chim và động vật hoang dã. Thăm cơ sở nuôi ong mật và thưởng thức mật ong tươi ngay tại rừng. Phù hợp cho người yêu thiên nhiên và eco-tour
- Tour Cà Mau – Bạc Liêu: Điện gió & Di tích: 1 ngày — liên hệ
  Tour kết hợp hai điểm du lịch của tỉnh Cà Mau sau sáp nhập: tham quan cánh đồng điện gió biển Bạc Liêu — cảnh quan kỳ vĩ turbine giữa biển, thăm nhà Công tử Bạc Liêu, khu lưu niệm Cao Văn Lầu, Khu du lịch sinh thái Hồ Nam — trong ngày từ TP. Cà Mau.
- Tour Đầm Thị Tường ngắm chim buổi sáng: Nửa ngày (4–6 tiếng) — liên hệ
  Khởi hành lúc 4:30–5:00 sáng để đến Đầm Thị Tường trước bình minh, thuê thuyền nhỏ tiến sâu vào đầm quan sát hàng nghìn con chim nước bay lên khi mặt trời mọc. Trải nghiệm đặc biệt chỉ có từ tháng 11 đến tháng 3 khi chim di cư về trú đông.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6bbb1809-ac3e-52b6-9586-b600e142b910', 'Lễ hội & Sự kiện tại Cà Mau', 'event', '23431b56-3e63-4368-949f-8df24ab3c539',
  'Lễ hội & Sự kiện tại Cà Mau:
- Lễ hội Nghinh Ông (Đua thuyền trên biển): Rằm tháng 2 âm lịch hằng năm
  Lễ hội truyền thống lớn nhất của ngư dân Cà Mau, cầu nguyện cho mùa đánh cá bình an và bội thu. Có nghi lễ rước sắc thần Nghinh Ông trên biển, đua thuyền truyền thống, biểu diễn văn nghệ và hội chợ. Hàng chục nghìn ngư dân và du khách tập hợp tại cản
- Lễ hội Ba khía Rạch Gốc: Tháng 10 âm lịch hằng năm
  Lễ hội thường niên đặc trưng của vùng Ngọc Hiển, gắn với mùa thu hoạch ba khía — đặc sản muối mặn nổi tiếng. Có thi muối ba khía, trình diễn nghề truyền thống và chợ bán đặc sản địa phương. Đây là cơ hội hiếm để thấy toàn bộ quy trình làm ba khía từ 
- Lễ hội Đờn ca tài tử Bạc Liêu: Tháng 11–12 hằng năm (lịch cụ thể thay đổi)
  Lễ hội tôn vinh đờn ca tài tử Nam Bộ — di sản văn hóa phi vật thể thế giới được UNESCO công nhận năm 2013. Bạc Liêu là cái nôi của đờn ca tài tử với nhạc sĩ Cao Văn Lầu và bài ''Dạ cổ hoài lang''. Có thi đấu đờn ca, triển lãm và biểu diễn đường phố.
- Ngày hội Văn hóa – Thể thao dân tộc Khmer Nam Bộ: Thường tổ chức vào tháng 11–12 (lịch thay đổi từng năm)
  Sự kiện định kỳ vinh danh văn hóa người Khmer vùng Tây Nam Bộ, có đua ghe ngo, múa Lâm Thôn, triển lãm trang phục và ẩm thực Khmer. Đây là dịp để hiểu sâu hơn về cộng đồng dân tộc thiểu số đang sinh sống lâu đời tại đồng bằng Cửu Long.', ARRAY['ca-mau', 'cà mau', 'cà mau', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5e6a63f6-bc13-5478-b511-fecb009bc5cc', 'Tổng quan du lịch Cần Thơ', 'destination', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Tổng quan Cần Thơ (Cần Thơ):
Thủ phủ miền Tây với chợ nổi Cái Răng, vườn trái cây và hệ thống kênh rạch sông nước; sau sáp nhập còn có chùa Dơi và lễ hội Óoc Om Bóc của Sóc Trăng, cùng vùng sông nước Hậu Giang với chợ nổi Ngã Bảy.

Mùa đẹp nhất: Tháng 12–4 (mùa khô) hoặc mùa nước nổi Tháng 9–11
Thời tiết: Nóng ẩm 25–34°C, mùa nước nổi tháng 9–11
Ẩm thực: Bánh xèo miền Tây, lẩu mắm, nem nướng Cái Răng, cá lóc nướng trui
Ngân sách tham khảo: ', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '1cfff33e-6f42-529b-9da6-e4fc8bab934b', 'Cần Thơ – 🌟 Kinh Nghiệm Du Lịch Cần Thơ', 'tip', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 🌟 Kinh Nghiệm Du Lịch Cần Thơ

> Tổng hợp tips từ du khách và người dân miền Tây sông nước.

---', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '85b5c5b3-56f6-5982-9929-8f5f07169570', 'Cần Thơ – 1. Chợ nổi Cái Răng', 'tip', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 1. Chợ nổi Cái Răng
Loại: market
Địa chỉ: Quận Cái Răng, cách trung tâm ~6km
Giờ mở cửa: 5:00–9:00 (đông nhất 5:30–7:00)
Tip: Chợ nổi lớn nhất miền Tây, nơi hàng trăm ghe chở đầy trái cây, rau củ giao thương trên sông. Dấu hiệu nhận biết: mỗi ghe cắm cây sào treo mặt hàng bán. Đặt tour xuồng máy từ tối hôm trước, xuất phát 5:00–5:30 để kịp lúc đông nhất. Mua trái cây thẳng trên ghe, hỏi giá trước.', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f3cf0827-df5b-53f7-b4df-58f3b9e71535', 'Cần Thơ – 2. Bến Ninh Kiều và phố đi bộ', 'activity', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 2. Bến Ninh Kiều và phố đi bộ
Loại: attraction
Địa chỉ: Bờ sông Cần Thơ, quận Ninh Kiều
Giờ mở cửa: 24/7 (nhộn nhịp nhất 18:00–22:00)
Tip: Phố đi bộ cuối tuần ven sông Ninh Kiều có biểu diễn đờn ca tài tử và đồ ăn vặt miền Tây. Ngồi cà phê nhìn sông lúc hoàng hôn là trải nghiệm tuyệt vời. Chợ đêm Ninh Kiều gần đó bán đủ món ngon giá rẻ.', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '2c33dc4d-117d-56c3-aa23-e851fa545890', 'Cần Thơ – 3. Nhà cổ Bình Thủy', 'activity', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 3. Nhà cổ Bình Thủy
Loại: museum
Địa chỉ: 144 Bùi Hữu Nghĩa, phường Bình Thủy
Giờ mở cửa: 8:00–17:00, thứ 2 nghỉ
Tip: Biệt thự Pháp 1870 còn nguyên vẹn, từng là bối cảnh phim "L''Amant" (Người Tình) của đạo diễn Jean-Jacques Annaud. Vé vào ~20.000đ. Nên kết hợp với tham quan chùa Ông Bình Thủy gần đó.', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f2283803-c8d5-52f9-adb7-010bea96f4a0', 'Cần Thơ – 4. Làng du lịch sinh thái Mỹ Khánh', 'activity', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 4. Làng du lịch sinh thái Mỹ Khánh
Loại: nature
Địa chỉ: Xã Mỹ Khánh, huyện Phong Điền, cách trung tâm 12km
Giờ mở cửa: 7:00–17:00
Tip: Vườn trái cây rộng lớn với xoài, sầu riêng, chôm chôm theo mùa. Đi xe đạp trong vườn và thưởng thức trái cây tươi tại chỗ là trải nghiệm đặc trưng miền Tây. Kết hợp đi xuồng kênh rạch xuyên vườn.', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c533c398-ae08-5367-aab3-33a24f190a11', 'Cần Thơ – 5. Chùa Ông (Quảng Triệu Hội Quán)', 'tip', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 5. Chùa Ông (Quảng Triệu Hội Quán)
Loại: temple
Địa chỉ: 32 Hai Bà Trưng, quận Ninh Kiều
Giờ mở cửa: 6:00–17:30
Tip: Ngôi chùa Hoa thế kỷ 19 với kiến trúc và trang trí độc đáo. Nổi tiếng với khói nhang và vòng nhang treo trên trần — không gian rất photogenic. Miễn phí vào cửa.

---', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '11201190-ed5c-5473-8ea0-ca279ba4023e', 'Cần Thơ – 🎒 Lịch Trình Gợi Ý', 'tip', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 🎒 Lịch Trình Gợi Ý

> Chi tiết giờ giấc và tham chiếu địa điểm: xem .', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a518b3fc-61ae-5977-9ba5-8ecd4620d24b', 'Cần Thơ – 2 Ngày 1 Đêm — Sông nước miền Tây', 'tip', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 2 Ngày 1 Đêm — Sông nước miền Tây
Xem đầy đủ tại  → id: 

Ngày 1: Xe từ TP.HCM → Bến Ninh Kiều → Nhà cổ Bình Thủy → Chợ đêm tối
Ngày 2: 5:00 dậy → Chợ nổi Cái Răng → Sáng → Vườn trái cây Mỹ Khánh → Ăn trưa → Về TP.HCM', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '910af241-735d-5741-b66a-506757c72b3d', 'Cần Thơ – 3 Ngày 2 Đêm — Khám phá miền Tây', 'tip', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 3 Ngày 2 Đêm — Khám phá miền Tây
Xem đầy đủ tại  → id: 

Ngày 1: TP.HCM → Cần Thơ → Ninh Kiều buổi chiều → Đờn ca tài tử tối
Ngày 2: Chợ nổi sáng sớm → Vườn trái cây → Đi thuyền kênh rạch → Lẩu mắm tối
Ngày 3: Chùa Ông → Chợ truyền thống → Về hoặc tiếp tục Cà Mau

---', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a381b3a1-bd87-52fe-84c2-300c77cd2b1d', 'Cần Thơ – 🚨 Kinh Nghiệm An Toàn', 'safety', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 🚨 Kinh Nghiệm An Toàn

- ⚠️ Áo phao trên thuyền: Bắt buộc với trẻ em, nên mặc với người lớn — kênh rạch miền Tây sâu và dòng chảy mạnh.
- ⚠️ Mua hàng trên chợ nổi: Hỏi giá rõ ràng trước khi mua, một số ghe báo giá cao cho khách Tây.
- ⚠️ Say nắng trên thuyền: Ngồi thuyền buổi sáng trời nắng sớm, cần đội mũ và bôi kem chống nắng.

---', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e24510cf-c96c-585f-b2a1-0c0f8e76736c', 'Cần Thơ – 💡 Tips Thực Tế', 'activity', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 💡 Tips Thực Tế

- 💰 Tiết kiệm: Ăn sáng hủ tiếu hoặc bánh mì tại các quán vỉa hè gần chợ Ninh Kiều chỉ 25.000–40.000đ, ngon hơn nhiều so với ăn tại khách sạn.
- 🛶 Chợ nổi Cái Răng: Dù nhiều người nói chợ nổi đang "thu hẹp" do đô thị hóa, chợ vẫn rất sôi động vào sáng sớm — cứ đến sớm trước 6:00 là có ảnh và trải nghiệm hay.
- 🎶 Đờn ca tài tử: Hỏi khách sạn hoặc trung tâm văn hóa về lịch biểu diễn — thường tổ chức tối thứ 6, thứ 7 tại bến Ninh Kiều hoặc các nhà hàng nổi tiếng.
- 🍽️ Ẩm thực: Bánh xèo miền Tây ăn kèm lá điều và rau sống mới đúng điệu — đừng nhầm với bánh xèo Đà Nẵng.

---', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '18e2a3de-ebb2-587b-9f70-314b125280cf', 'Cần Thơ – 🛒 Mua Sắm & Đặc Sản Mang Về', 'tip', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

| Sản phẩm | Mua ở đâu | Giá tham khảo |
|---|---|---|
| Mắm Cần Thơ (nhiều loại) | Chợ Cần Thơ, siêu thị | 80.000–200.000đ/hũ |
| Bánh tráng mè | Chợ truyền thống | 30.000–50.000đ/gói |
| Trái cây tươi | Chợ nổi, vườn Mỹ Khánh | Theo mùa |
| Rượu nếp Than | Siêu thị, cửa hàng đặc sản | 100.000–200.000đ/chai |
| Nem nướng Cái Răng (đóng gói) | Siêu thị Co.op Mart | 80.000–120.000đ |

---', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ca538d53-cfad-534b-a482-97bcff81f117', 'Cần Thơ – 📞 Thông Tin Liên Hệ Hữu Ích', 'activity', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## 📞 Thông Tin Liên Hệ Hữu Ích

- Trung tâm xúc tiến du lịch Cần Thơ: (0292) 3822 082
- Bến tàu Ninh Kiều (tour chợ nổi): Số 2 Hai Bà Trưng, quận Ninh Kiều
- Bệnh viện Đa khoa Trung ương Cần Thơ: 4 Châu Văn Liêm — (0292) 3820 071
- Grab Cần Thơ: Hoạt động tốt trong nội ô', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5a8eae1b-3276-5162-9b76-f3f11f7f8321', 'FAQ Du lịch Cần Thơ (1)', 'faq', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  '## ❓ FAQ Du Lịch Cần Thơ

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm đẹp nhất để đến Cần Thơ là khi nào?
A: Tháng 12–4 (mùa khô) là thời gian lý tưởng nhất — trời nắng, đường dễ đi, chợ nổi tấp nập. Tháng 9–11 (mùa nước nổi) cũng rất đặc sắc khi đồng bằng ngập nước, cá linh, bông điên điển nở vàng và đời sống sông nước hiện rõ nhất.

Q: Cần Thơ có bị lũ lụt không?
A: Mùa nước nổi (tháng 9–11) nước từ thượng nguồn Mekong đổ về làm ngập một số vùng trũng và đồng ruộng — đây là hiện tượng tự nhiên bình thường, không nguy hiểm với du khách ở khu đô thị. Thực ra đây là mùa có nhiều đặc sản nhất: cá linh kho mắm, lẩu bông điên điển.

---

## 💰 Chi phí & Ngân sách

Q: Chi phí đi Cần Thơ 2 ngày 1 đêm hết bao nhiêu?
A: Ước tính 1.000.000–2.500.000đ/người bao gồm đi về từ TP.HCM, lưu trú và ăn uống. Cần Thơ ăn uống rất rẻ — bữa ăn đầy đủ tại quán bình dân khoảng 50.000–100.000đ/người. Tour chợ nổi Cái Răng khoảng 150.000–300.000đ/người.

Q: Có cần đặt phòng trước không?
A: Nên đặt trước dịp lễ Tết và tháng 12–1 vì Cần Thơ là điểm dừng chân phổ biến của tour miền Tây. Ngoài cao điểm, khách sạn bình dân và trung cấp khá dễ đặt trong ngày.

---

## 🚗 Di chuyển

Q: Từ TP.HCM đến Cần Thơ bằng phương tiện gì?
A: Xe khách Phương Trang, Thuận Thảo đi từ bến xe Miền Tây (TP.HCM) đến Cần Thơ ~3,5 tiếng, giá 120.000–180.000đ — nhanh và tiện nhất. Tàu cao tốc từ Bạch Đằng TP.HCM (đi sáng sớm) cũng có nhưng ít lịch hơn. Ngoài ra có thể đặt xe riêng hoặc thuê xe tự lái.

Q: Di chuyển trong Cần Thơ bằng gì?
A: Grab và taxi là tiện nhất trong nội ô. Xe buýt công cộng có nhưng ít tuyến. Thuê xe máy 100.000–150.000đ/ngày để tự khám phá. Đặc biệt ở Cần Thơ nên thử đi xuồng ba lá (ghe) trên kênh rạch — đây chính là nét văn hóa đặc trưng.

---

## 🏨 Lưu trú', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '30756736-e452-58fc-9632-8bba15e6486b', 'FAQ Du lịch Cần Thơ (2)', 'faq', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Q: Nên ở khu vực nào tại Cần Thơ?
A: Khu trung tâm bờ sông Ninh Kiều là lý tưởng nhất — vừa đẹp, vừa tiện đi bộ đến bến tàu Cái Răng và phố ẩm thực Hai Bà Trưng. Xa hơn một chút, khu Bình Thủy (gần cầu Cần Thơ) yên tĩnh hơn với một số nhà hàng nổi tiếng.

Q: Các loại hình lưu trú phổ biến tại Cần Thơ?
A: Khách sạn boutique ven sông (Azerai La Residence, Mường Thanh Cần Thơ) cho trải nghiệm cao cấp; khách sạn 2–3 sao giá 400.000–800.000đ/đêm phong phú trong nội ô; homestay trên sông và nhà vườn miền Tây là trải nghiệm đặc trưng nhất.

---

## 🍜 Ẩm thực

Q: Đặc sản nổi tiếng nhất của Cần Thơ là gì?
A: Bánh xèo miền Tây (to hơn miền Trung, ăn kèm rau sống và nước mắm ngọt), lẩu mắm (ngọt ngào đặc trưng miền Tây), nem nướng Cái Răng, cá lóc nướng trui và hủ tiếu Nam Vang Cần Thơ là những món không thể bỏ qua.

Q: Nên ăn ở đâu tại Cần Thơ?
A: Đường Phan Đình Phùng và Hai Bà Trưng là hai con phố ẩm thực sôi động nhất. Chợ đêm Ninh Kiều ven sông mở đến 22:00 có nhiều đồ ăn vặt ngon. Nhà hàng Mekong và các quán ven sông Bình Thủy được nhiều du khách đánh giá cao.

---

## ⚠️ An toàn & Lưu ý

Q: Có lưu ý gì về an toàn khi đến Cần Thơ?
A: Cần Thơ khá an toàn. Khi đi xuồng/ghe trên sông cần mặc áo phao, đặc biệt cho trẻ em và người không biết bơi. Cẩn thận giữ đồ cá nhân ở chợ đông người. Không uống nước lạ trực tiếp từ kênh rạch.

Q: Cần chuẩn bị gì trước khi đến Cần Thơ?
A: Nếu muốn đi chợ nổi Cái Răng, cần dậy sớm 5:00–5:30 sáng — chợ họp từ tảng sáng và tan dần sau 8:00. Mang kem chống nắng vì ngồi thuyền trên sông nắng chiếu thẳng không có bóng che. Chuẩn bị tiền mặt nhỏ để mua hàng trên ghe.', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd0b13bcb-1096-5b82-b67d-07eea5e4b2ce', 'FAQ Du lịch Cần Thơ (3)', 'faq', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Q: Cần Thơ sau sáp nhập có gồm những tỉnh nào?
A: Có — tỉnh/thành Cần Thơ mới (từ 2025) được hợp nhất từ Cần Thơ, Sóc Trăng và Hậu Giang cũ. Khu Sóc Trăng cũ nổi tiếng với chùa Dơi, lễ hội Óoc Om Bóc; khu Hậu Giang cũ có chợ nổi Ngã Bảy. *(Lưu ý: dữ liệu chi tiết điểm đến/ẩm thực hai khu vực này chưa được bổ sung đầy đủ vào knowledge base — cần agent_task riêng cập nhật destinations.json/foods.json.)*', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a8721f87-6fdc-5ca5-929d-fcfb535e9190', 'Ẩm thực đặc sản Cần Thơ', 'food', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Đặc sản ẩm thực Cần Thơ:
- Bánh xèo miền Tây: Bánh xèo miền Tây to hơn và dày hơn bánh xèo miền Trung, nhân tôm thịt hoặc hải sản, ăn kèm rau sống (lá điều, lá lốt, giá...) và nước mắm chua ngọt pha loãng. Cách ăn đặc trưng là cuốn bánh vào lá đi
  Địa điểm thưởng thức: [''Quán bánh xèo Mười Xinh (Quận Ninh Kiều)'', ''Chợ đêm Ninh Kiều'', ''Các quán dọc đường Đề Thám'']
- Lẩu mắm miền Tây: Lẩu nấu từ mắm cá linh hoặc mắm sặc — đặc sản miền Tây Nam Bộ có vị ngọt ngào và thơm đặc trưng không nơi nào có được. Ăn cùng cá lóc, tôm, mực, thịt heo quay và nhiều loại rau đặc trưng như bông súng
  Địa điểm thưởng thức: [''Nhà hàng Mekong (khu Ninh Kiều)'', ''Các nhà hàng nổi trên sông Bình Thủy'', ''Chợ đêm Ninh Kiều'']
- Nem nướng Cái Răng: Nem nướng Cần Thơ nổi tiếng với thịt heo xay viên nướng than hoa, ăn cùng bánh tráng, bún, rau sống, chuối xanh, dưa leo và nước chấm từ mắm nêm. Cái Răng (quận cách trung tâm ~5km) là nơi được coi là
  Địa điểm thưởng thức: [''Các quán nem nướng khu Cái Răng'', ''Đường Phan Đình Phùng (Ninh Kiều)'']
- Cá lóc nướng trui: Cá lóc đồng (cá rô đồng) được nướng nguyên con bằng lửa rơm không cần ướp gia vị, khi chín lột da bỏ đi còn lại phần thịt trắng ngần thơm ngon. Ăn cuốn với bánh tráng, rau sống và mắm nêm — là món ăn 
  Địa điểm thưởng thức: [''Các nhà hàng sân vườn ven sông'', ''Khu ẩm thực Bình Thủy'']
- Hủ tiếu Nam Vang Cần Thơ: Hủ tiếu phong cách Campuchia (Nam Vang) được biến tấu theo khẩu vị miền Tây — nước dùng trong, ngọt từ xương heo và mực khô, ăn kèm thịt heo xay, tôm, lòng heo và nhiều rau giá. Cần Thơ có nhiều quán 
  Địa điểm thưởng thức: [''Hủ tiếu Nam Vang Mỹ Khánh (Phong Điền)'', ''Các quán sáng sớm ven kênh Ninh Kiều'']
- Bánh tráng nướng miền Tây: Bánh tráng (bánh đa) nướng trên lửa than, phết mỡ hành, trứng cút và các loại topping như tôm khô, nem chà bông. Món ăn vặt đường phố rất phổ biến ở Cần Thơ, đặc biệt tại các chợ đêm và bến Ninh Kiều.
  Địa điểm thưởng thức: [''Chợ đêm Ninh Kiều'', ''Vỉa hè đường Hai Bà Trưng'']
- Chè bưởi / chè đậu miền Tây: Các loại chè miền Tây phong phú: chè bưởi (múi bưởi ngâm siro cùng thạch dừa, nước cốt dừa), chè đậu xanh lá dứa, chè thập cẩm... Vị ngọt dịu, béo nhẹ từ nước cốt dừa là điểm đặc trưng của chè Nam Bộ.
  Địa điểm thưởng thức: [''Chợ đêm Ninh Kiều'', ''Các quán chè dọc đường Đề Thám'']', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f9b9af06-203f-53ae-853e-8ef2b045ea72', 'Cách di chuyển đến Cần Thơ', 'transport', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Di chuyển đến và trong Cần Thơ:

Cách đến:
- AIRPLANE từ Hà Nội (nội địa, quá cảnh TP.HCM hoặc bay thẳng): ~2 giờ bay + di chuyển từ sân bay (~30 phút về trung tâm) — None
  Sân bay Cần Thơ (VCA) nằm cách trung tâm khoảng 10km. Bay thẳng Hà Nội – Cần Thơ có sẵn. Từ sân bay về trung tâm bắt taxi hoặc Grab (~100.000–150.000đ). Xác nhận giá vé tại Traveloka hoặc Vexere.
- BUS từ TP.HCM (Bến xe Miền Tây): ~3,5–4 giờ — None
  Tuyến xe khách Sài Gòn – Cần Thơ chạy liên tục từ sáng đến tối. Phương Trang có xe giường nằm và ghế ngồi. Tiện nhất, giá rẻ nhất cho chuyến đi từ TP.HCM. Xác nhận giá tại Vexere.com.
- BOAT từ TP.HCM (Bến Bạch Đằng): ~3,5 giờ — None
  Tàu cao tốc xuất phát buổi sáng sớm, ngắm cảnh sông nước đặc sắc. Lịch tàu ít hơn xe khách. Xác nhận giá và lịch tàu tại Traveloka hoặc trực tiếp hãng trước khi đi.
- CAR từ TP.HCM (cao tốc TP.HCM – Cần Thơ): ~2,5–3 giờ (tùy giao thông) — None
  Đường cao tốc TP.HCM – Trung Lương – Mỹ Thuận – Cần Thơ đã thông tuyến hoàn chỉnh. Phí cầu đường khoảng 80.000–120.000đ/lượt (xác nhận mức phí thực tế). Thuê xe tự lái hoặc có tài xế từ Traveloka hoặc

Di chuyển trong thành phố:
- grab: Grab hoạt động tốt trong nội ô Cần Thơ. Tiện nhất cho di chuyển giữa các điểm tham quan trung tâm. Grab Boat cũng có tại một số bến.
- taxi: Taxi Mai Linh và Vinasun hoạt động tại Cần Thơ. Nên đặt qua app hoặc gọi tổng đài tránh taxi dù.
- motorbike_rental: Thuê xe máy khoảng 100.000–150.000đ/ngày (xác nhận giá tại các cửa hàng cho thuê gần bến Ninh Kiều). Cần bằng lái xe máy. Phù hợp để khám phá các khu ngoại ô như Phong Điền, Cái Răng.
- xe_om: Xe ôm truyền thống vẫn còn hoạt động, đặc biệt ở khu chợ và bến xe. Thỏa thuận giá trước khi đi.', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6a306843-47d7-5d78-b873-ee9d9d8fc763', 'Khách sạn & Lưu trú tại Cần Thơ', 'hotel', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Lưu trú tại Cần Thơ:
- Azerai La Residence Cần Thơ (5★): Đường Lê Lợi, Quận Ninh Kiều, TP. Cần Thơ
  Tiện ích: hồ bơi, spa, nhà hàng, bar
- Mường Thanh Luxury Cần Thơ (4★): Đường Ngô Quyền, Quận Ninh Kiều, TP. Cần Thơ
  Tiện ích: hồ bơi, phòng gym, nhà hàng, wifi miễn phí
- Khách sạn Ninh Kiều 2 (3★): Đường Hai Bà Trưng, Quận Ninh Kiều, TP. Cần Thơ
  Tiện ích: nhà hàng, wifi miễn phí, bãi đỗ xe, view sông
- Sông Xanh Riverside Homestay (None★): Huyện Phong Điền, TP. Cần Thơ (khu vực vườn trái cây)
  Tiện ích: wifi miễn phí, bữa sáng, cho thuê xe đạp, tour xuồng ba lá
- Kim Tho Hotel Cần Thơ (2★): Đường Châu Văn Liêm, Quận Ninh Kiều, TP. Cần Thơ
  Tiện ích: wifi miễn phí, máy lạnh, bãi đỗ xe', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8f78fec5-cd07-5313-8b8b-f7564471de31', 'Tour & Trải nghiệm tại Cần Thơ', 'tour', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Tour & Trải nghiệm tại Cần Thơ:
- Tour Chợ Nổi Cái Răng Sáng Sớm: 3–4 tiếng (xuất phát 5:00–5:30) — liên hệ
  Tour thuyền máy xuất phát sáng sớm từ bến Ninh Kiều, di chuyển khoảng 6km để đến chợ nổi Cái Răng — chợ nổi lớn nhất miền Tây. Tham quan cảnh mua bán trên sông, mua trái cây trực tiếp từ ghe và thưởng thức bữa sáng trên thuyền (hủ tiếu/bánh mì).
- Tour Kênh Rạch & Vườn Trái Cây Phong Điền: Nửa ngày (4–5 tiếng) hoặc cả ngày — liên hệ
  Khám phá hệ thống kênh rạch vùng ngoại ô Cần Thơ bằng xuồng ba lá hoặc thuyền nhỏ, ghé thăm vườn trái cây khu Phong Điền, hái và thưởng thức trái cây tươi tại chỗ, quan sát đời sống người dân ven kênh rạch miền Tây. Kết hợp bữa trưa đặc sản tại nhà v
- Tour Cần Thơ – Sóc Trăng 1 Ngày (Chùa Dơi & Lễ hội Khmer): Cả ngày (~10 tiếng) — liên hệ
  Tour kết hợp từ Cần Thơ đến Sóc Trăng (khoảng 60km) khám phá văn hóa Khmer Nam Bộ: Chùa Dơi (hàng chục nghìn con dơi quạ), chùa Kh''leang, bảo tàng Khmer, và tìm hiểu lễ hội Óoc Om Bóc đặc sắc của người Khmer. Khu Sóc Trăng cũ nay thuộc Cần Thơ sau sá
- Tour Chợ Nổi Ngã Bảy – Hậu Giang 1 Ngày: Cả ngày (~8 tiếng) — liên hệ
  Khám phá chợ nổi Ngã Bảy (Phụng Hiệp) — điểm giao thoa 7 con kênh, thuộc Hậu Giang cũ nay là Cần Thơ sau sáp nhập 2025. Tham quan làng nghề truyền thống, vườn cây ăn trái vùng Hậu Giang và thưởng thức đặc sản địa phương ít được biết đến hơn.', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f4c0b09f-0e6b-5009-a775-63cfb18ff6fa', 'Lễ hội & Sự kiện tại Cần Thơ', 'event', 'e1b4d4cb-8d60-4a03-8b98-bc54991eff17',
  'Lễ hội & Sự kiện tại Cần Thơ:
- Lễ hội Óoc Om Bóc – Đua ghe Ngo: Tháng 10 âm lịch (thường tháng 11 dương lịch), hằng năm
  Lễ hội lớn nhất của người Khmer Nam Bộ, gồm 2 phần: Lễ Cúng Trăng (dâng lễ vật cúng Mặt Trăng vào đêm rằm) và Hội đua ghe Ngo trên sông sáng hôm sau. Đua ghe Ngo là phần hấp dẫn nhất với hàng chục chiếc ghe dài 25–30m, mỗi ghe 40–60 tay chèo thi đấu 
- Lễ hội Du lịch Cần Thơ: Tháng 4 hằng năm (thường gần dịp 30/4)
  Lễ hội du lịch thường niên của TP. Cần Thơ với các hoạt động như: triển lãm ảnh sông nước miền Tây, biểu diễn đờn ca tài tử Nam Bộ, trình diễn nghề thủ công truyền thống, hội chợ ẩm thực đặc sản và các tour khám phá thành phố miễn phí hoặc giảm giá.
- Chợ phiên nổi Cái Răng cuối tuần: Thứ Bảy và Chủ Nhật hằng tuần
  Cuối tuần chợ nổi Cái Răng sôi động hơn ngày thường với nhiều ghe thuyền hơn và một số hoạt động đặc biệt dành cho du khách như: trình diễn nấu ăn trên ghe, đặc sản mùa vụ, và cơ hội giao lưu với tiểu thương. Nhiều du khách chọn cuối tuần để kết hợp 
- Mùa nước nổi miền Tây: Tháng 9 – 11 hằng năm
  Mùa nước từ thượng nguồn Mekong đổ về tạo nên cảnh sắc đặc trưng: đồng bằng mênh mông nước, cá linh theo nước đổ về, hoa điên điển nở vàng. Đây là mùa của những món đặc sản như cá linh kho mắm, bông điên điển nấu canh chua — trải nghiệm khó quên về v
- Tết Nguyên Đán tại Cần Thơ: Tháng 1 hoặc tháng 2 dương lịch (âm lịch: 28 tháng Chạp – 10 tháng Giêng)
  Tết tại Cần Thơ rất sôi động với chợ hoa Ninh Kiều bên sông, màn bắn pháo hoa đêm giao thừa tại bến Ninh Kiều, và không khí sum họp của người miền Tây. Lưu ý: nhiều nhà hàng và dịch vụ đóng cửa từ mùng 1–3, chợ nổi vắng hơn thường ngày trong 3 ngày T', ARRAY['can-tho', 'cần thơ', 'cần thơ', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '00be7740-6d13-5d12-b61e-7144feca74a8', 'Tổng quan du lịch Cao Bằng', 'destination', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Tổng quan Cao Bằng (Cao Bằng):
Vùng biên giới với thác Bản Giốc, hồ Thang Hen và hang Pác Bó gắn liền lịch sử cách mạng.

Mùa đẹp nhất: Tháng 8–10 (thác nhiều nước) hoặc Tháng 3–5
Thời tiết: Mát mẻ 15–28°C, lạnh về đêm mùa đông, có thể có sương giá
Ẩm thực: Bánh cuốn Cao Bằng, hạt dẻ Trùng Khánh, vịt quay 7 vị, miến lươn
Ngân sách tham khảo: ', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6bb27b0a-c558-5590-b3ac-74e68c0b8433', 'Cao Bằng – 1. Thác Bản Giốc', 'activity', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 1. Thác Bản Giốc
Loại: Thiên nhiên / Thác nước biên giới
Khu vực: Huyện Trùng Khánh, cách TP. Cao Bằng ~90km
Giờ mở cửa: Thường 7:00–17:00 *(xác nhận trước khi đến — có thể thay đổi theo mùa)*
Giá vé: *Liên hệ Sở Du lịch Cao Bằng hoặc hỏi khách sạn địa phương để có giá cập nhật nhất* *(xem thêm destinations.json)*
Tip: Đến trước 9:00 sáng để có ánh sáng đẹp và ít người nhất. Thuê bè mảng (khoảng 30 phút) để tiếp cận gần thác từ phía dưới — trải nghiệm rất khác biệt. Mùa tháng 8–10 thác nhiều nước nhất và hùng vĩ nhất.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '892a01e5-85a3-5d66-8f3e-e5fa2c829975', 'Cao Bằng – 2. Hang Pác Bó', 'tip', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 2. Hang Pác Bó
Loại: Di tích lịch sử quốc gia đặc biệt
Khu vực: Huyện Hà Quảng, cách TP. Cao Bằng ~60km
Giờ mở cửa: Thường 7:00–17:00 *(xác nhận trước khi đến)*
Giá vé: *Liên hệ Ban Quản lý Khu di tích Pác Bó để có giá và thông tin cập nhật* *(xem thêm destinations.json)*
Tip: Mang áo khoác mỏng vì trong hang khá mát và ẩm dù trời ngoài nắng. Đặt thuê hướng dẫn viên tại điểm để hiểu đầy đủ câu chuyện lịch sử — rất đáng tiền, đặc biệt nếu đi cùng trẻ em.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '9e4c9e39-0b5a-5e50-99c2-68530ca82632', 'Cao Bằng – 3. Hồ Thang Hen', 'activity', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 3. Hồ Thang Hen
Loại: Thiên nhiên / Cao nguyên đá vôi
Khu vực: Huyện Trà Lĩnh, cách TP. Cao Bằng ~50km
Giờ mở cửa: Tự do tham quan, không giới hạn giờ
Giá vé: Không có thông tin thu phí tại thời điểm viết *(xem thêm destinations.json)*
Tip: Buổi sáng sớm có sương mù ôm quanh mặt hồ — cảnh đẹp nhất cho nhiếp ảnh gia. Mùa mưa nước hồ xanh hơn và đầy hơn nhưng đường vào có thể trơn, hỏi thêm điều kiện đường tại địa phương.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3d160fb5-f7e0-5ccf-a10a-0e0e346fff5a', 'Cao Bằng – 4. Núi Mắt Thần (Hạ Lang)', 'activity', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 4. Núi Mắt Thần (Hạ Lang)
Loại: Địa hình đặc biệt / Nhiếp ảnh
Khu vực: Huyện Hạ Lang — cần hỏi thêm đường đi tại địa phương
Giờ mở cửa: Tự do, tham quan ban ngày
Giá vé: *Liên hệ UBND huyện Hạ Lang hoặc Sở Du lịch Cao Bằng* *(xem thêm destinations.json)*
Tip: Khung giờ ánh sáng đi qua lỗ đẹp nhất là 10:00–14:00. Cần leo bộ khoảng 30 phút đường dốc — mang giày bám tốt. Điểm này mới nổi, nên hỏi khách sạn hoặc cộng đồng phượt địa phương về đường đi cập nhật nhất.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3e59c3e2-53a2-5798-aa26-9a6cc4ae9ed1', 'Cao Bằng – 5. Khu Di tích Rừng Trần Hưng Đạo', 'activity', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 5. Khu Di tích Rừng Trần Hưng Đạo
Loại: Di tích lịch sử cách mạng
Khu vực: Huyện Nguyên Bình, tỉnh Cao Bằng
Giờ mở cửa: Thường 7:00–17:00 các ngày làm việc *(xác nhận trước khi đến)*
Giá vé: *Liên hệ Ban Quản lý hoặc Sở Văn hóa Cao Bằng* *(xem thêm destinations.json)*
Tip: Điểm tham quan phù hợp nhất cho đoàn thể, trường học, hoặc người muốn tìm hiểu sâu về lịch sử 22/12/1944. Kết hợp vào hành trình nếu có thêm ngày.

---', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '837d57e1-30fb-5d9c-bddd-d8bb5519206a', 'Cao Bằng – 3 Ngày 2 Đêm — Cặp Đôi / Bạn Bè', 'activity', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 3 Ngày 2 Đêm — Cặp Đôi / Bạn Bè
> Chi tiết →  id: 

- Ngày 1: Ăn sáng bánh cuốn tại chợ → Tham quan Chợ Cao Bằng → Thăm Hồ Thang Hen → Ăn tối vịt quay
- Ngày 2: Khởi hành sớm đến Bản Giốc → Thuê bè mảng ngắm thác → Ăn trưa cơm lam → Chợ phiên Trùng Khánh → Nghỉ đêm homestay Bản Giốc
- Ngày 3: Thăm Hang Pác Bó → Ăn bánh áp chao → Về TP. Cao Bằng và xuất phát', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'bbf4dbab-9ef7-5c50-ac48-24d4bac5c3f8', 'Cao Bằng – 2 Ngày 1 Đêm — Gia Đình Có Trẻ Em', 'tip', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 2 Ngày 1 Đêm — Gia Đình Có Trẻ Em
> Chi tiết →  id: 

- Ngày 1: Ăn sáng TP. Cao Bằng → Thác Bản Giốc (cưỡi bè mảng cho trẻ thú vị) → Ăn trưa khu Bản Giốc → Nghỉ tại khách sạn trung tâm
- Ngày 2: Hang Pác Bó (học lịch sử cùng con) → Mua đặc sản chợ Cao Bằng → Về

---', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3fc8bcb2-d276-5328-96d6-1d09f7535ec2', 'Cao Bằng – 🚨 Kinh Nghiệm An Toàn', 'safety', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 🚨 Kinh Nghiệm An Toàn

Đường đèo và mùa mưa: Đường từ TP. Cao Bằng đến Bản Giốc và Pác Bó có nhiều đoạn đèo dốc, quanh co. Mùa mưa (tháng 5–9) đường có thể trơn và sụt lún sau mưa lớn — luôn hỏi tình trạng đường tại khách sạn hoặc người dân địa phương trước khi xuất phát. Không lái xe ban đêm trên đèo.

Khu vực biên giới: Cao Bằng giáp Trung Quốc — một số khu vực sát biên có hạn chế ra vào. Không tự ý đi vào khu vực không có biển chỉ dẫn cho khách du lịch. Các điểm tham quan chính như Bản Giốc và Pác Bó là khu vực mở và an toàn.

Sóng điện thoại và bản đồ offline: Vùng sâu như Hồ Thang Hen hoặc khu rừng Nguyên Bình có sóng rất yếu. Tải bản đồ offline (Maps.me hoặc Google Maps offline) trước khi rời TP. Cao Bằng.

Mùa đông và sương giá: Tháng 12–2 nhiệt độ đêm có thể xuống dưới 5°C ở độ cao — mang áo ấm đủ lớp ngay cả khi ban ngày thấy ổn. Sương muối có thể xuất hiện, đường ẩm trơn hơn bình thường.

---', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd7581602-8d36-575e-bd4f-1ffa2063a602', 'Cao Bằng – 💡 Tips Thực Tế', 'tip', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 💡 Tips Thực Tế

🕐 Timing thăm thác:
Đến Bản Giốc trước 9:00 để có ánh sáng chụp ảnh đẹp nhất và tránh đám đông từ tour buổi sáng đến sau. Thác đẹp nhất tháng 8–9 nhưng đông khách nhất — cân nhắc đi sớm trong tuần thay vì cuối tuần.

🎒 Đồ cần mang:
Áo mưa (dù không có kế hoạch đến mùa mưa — thời tiết núi thay đổi nhanh). Giày đế bám (đường đến hang, đường đèo). Thuốc say xe nếu dễ bị ảnh hưởng — đèo Mã Phục và đèo Giàng khá quanh co. Tiền mặt đủ dùng cho 2–3 ngày.

📸 Điểm chụp ảnh đặc sắc:
Hồ Thang Hen đẹp nhất khi có sương mù sáng sớm. Thác Bản Giốc chụp đẹp từ bờ phía Việt Nam theo góc chụp ngang. Cánh đồng hoa cải vàng ở vùng nông thôn Cao Bằng rất đẹp tháng 3–4 — hỏi người dân địa phương điểm nào đang nở.

🛒 Mua đặc sản hiệu quả:
Hạt dẻ Trùng Khánh nên mua tại chợ Trùng Khánh hoặc chợ Cao Bằng trực tiếp — tươi hơn và rẻ hơn ở Hà Nội. Chọn loại có nhãn chỉ dẫn địa lý để chắc chắn mua đúng hàng Trùng Khánh. Mua miến dong đóng gói sẵn tiện mang về làm quà.

---', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'bb529fcf-495d-53a5-8579-2cb92f8413b4', 'Cao Bằng – 🛒 Mua Sắm & Đặc Sản Mang Về', 'tip', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

| Đặc sản | Nơi mua tốt nhất | Ghi chú |
|---|---|---|
| Hạt dẻ Trùng Khánh | Chợ Trùng Khánh, Chợ Cao Bằng | Mùa tươi: tháng 9–11. Có thể mua khô quanh năm |
| Miến dong Cao Bằng | Chợ Cao Bằng, cửa hàng đặc sản | Đóng gói sẵn tiện mang về |
| Mật ong rừng | Chợ Cao Bằng, cửa hàng đặc sản | Hỏi nguồn gốc và xem chứng nhận nếu có |
| Thổ cẩm Tày-Nùng | Làng nghề, chợ phiên | Mua tại làng nghề để ủng hộ nghệ nhân |
| Rượu ngô đặc sản | Chợ Cao Bằng, cửa hàng địa phương | Mang theo bình đựng để tránh vỡ |
| Lá mắc mật khô | Chợ Cao Bằng | Loại gia vị đặc trưng làm vịt quay và lợn quay |

*(Địa chỉ cụ thể và giờ mở cửa: xem shopping.json)*', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '214dc840-f983-5a56-a132-d8e9abb6d247', 'FAQ Du lịch Cao Bằng (1)', 'faq', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  '## ❓ FAQ Du Lịch Cao Bằng

---

## 🗓️ Thời điểm & Thời tiết

Q: Mùa nào đẹp nhất để đi Cao Bằng?
A: Cao Bằng đẹp ở hai mùa khác nhau. Tháng 8–10 là lúc thác Bản Giốc nhiều nước nhất — dòng thác hung hãn, trắng xóa, đây là thời điểm lý tưởng nếu bạn ưu tiên thác. Tháng 3–5 khí hậu mát mẻ, hoa cải vàng nở rộ trên các triền đồi, rất đẹp để chụp ảnh và đi bộ. Tháng 12–2 rất lạnh (có thể dưới 10°C ban đêm, có sương giá), phù hợp cho người thích thời tiết se se nhưng cần chuẩn bị quần áo ấm kỹ.
(Nguồn: Sở Du lịch Cao Bằng / vietnamtourism.gov.vn)

Q: Cao Bằng có mưa nhiều không? Cần chuẩn bị gì về thời tiết?
A: Mùa mưa tại Cao Bằng kéo dài từ tháng 5–9, tháng 7–8 mưa nhiều nhất. Đường đèo vào một số điểm như Hồ Thang Hen hay vùng sâu có thể trơn trượt sau mưa. Nếu đi mùa mưa, nên mang áo mưa và giày chống trơn, và hỏi thêm tình trạng đường tại khách sạn trước khi xuất phát. Mùa đông có sương mù dày trên đèo — nên lái xe chậm và cẩn thận.

---

## 💰 Chi phí & Ngân sách

Q: Chi phí đi Cao Bằng 2–3 ngày khoảng bao nhiêu?
A: Hiện chúng tôi chưa có số liệu chi phí đã xác minh cho hành trình Cao Bằng. Để ước tính, bạn có thể tham khảo giá phòng tại Booking.com hoặc Agoda (tìm "khách sạn Cao Bằng"), giá vé xe tại Traveloka (tuyến Hà Nội–Cao Bằng), và giá tour tại Klook (tìm "Cao Bằng"). Nhìn chung Cao Bằng là điểm đến giá cả phải chăng hơn so với Hà Nội hay Đà Nẵng — chi phí ăn uống và lưu trú tại địa phương khá hợp lý.

Q: Có cần đổi tiền mặt trước khi đến Cao Bằng không?
A: Nên mang tiền mặt khi đến Cao Bằng, đặc biệt nếu có kế hoạch đến các điểm xa như Bản Giốc hay Hà Quảng. ATM có ở trung tâm TP. Cao Bằng nhưng ít gặp ở vùng nông thôn. Các chợ phiên, homestay và quán ăn nhỏ thường chỉ nhận tiền mặt. Thẻ ngân hàng chủ yếu dùng được tại khách sạn lớn và siêu thị.

---

## 🚗 Di chuyển', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '97f47c7d-aa5d-5e92-96f8-aa3b09fe60eb', 'FAQ Du lịch Cao Bằng (2)', 'faq', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Q: Từ Hà Nội đến Cao Bằng đi bằng gì và mất bao lâu?
A: Cách phổ biến nhất là xe khách từ bến xe Mỹ Đình, mất khoảng 7–9 tiếng (có xe giường nằm ban đêm). Có thể tự lái xe hoặc thuê xe ô tô, theo Quốc lộ 3 qua Thái Nguyên–Bắc Kạn, khoảng 5–6 tiếng nếu đường thông. Không có đường sắt hoặc chuyến bay thẳng đến Cao Bằng. Phượt thủ hay đi xe máy từ Hà Nội theo đường đèo — rất đẹp nhưng cần kinh nghiệm lái đèo.
*(Xem thêm thông tin tuyến và nhà xe tại transport.json)*

Q: Đến Cao Bằng rồi di chuyển giữa các điểm bằng gì?
A: Thuê xe máy là cách linh hoạt và phổ biến nhất để khám phá các điểm xa như Bản Giốc (~90km từ TP), Pác Bó (~60km) hay Hồ Thang Hen (~50km). Gia đình hoặc nhóm đông nên thuê xe ô tô 4–7 chỗ có lái. Grab không phổ biến hoặc không hoạt động tại đây — không nên phụ thuộc vào ứng dụng gọi xe. Taxi địa phương có nhưng nên thỏa thuận giá trước cho các chuyến xa.

Q: Có thể đi Cao Bằng mà không thuê xe riêng không?
A: Được, nhưng sẽ giới hạn điểm tham quan. Nếu không muốn tự lái, tham gia tour trọn gói sẽ tiện hơn — xe và hướng dẫn viên được sắp xếp sẵn. Xe ôm và taxi địa phương có thể thuê chuyến đến các điểm, nhưng cần thỏa thuận giá rõ ràng trước.
*(Xem tours.json để biết các tour có xe đưa đón)*

---

## 🏨 Lưu trú

Q: Nên ở đâu tại Cao Bằng — trong thành phố hay gần thác Bản Giốc?
A: Phụ thuộc vào kế hoạch của bạn. Ở trung tâm TP. Cao Bằng tiện hơn về tiện ích, ATM, nhà hàng và dùng làm "điểm xuất phát" đi các nơi. Ở homestay gần Bản Giốc (khu Trùng Khánh) giúp bạn thăm thác ngay buổi sáng sớm khi ít người và ánh sáng đẹp nhất — lý tưởng nếu bạn đam mê chụp ảnh. Hành trình 2 ngày trở lên nên thử cả hai: 1 đêm homestay ở Trùng Khánh, 1 đêm TP. Cao Bằng.
*(Xem danh sách lưu trú tại hotels.json)*

---

## 🍜 Ẩm thực', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b8ad746a-4fde-591b-b977-7f5636b1c56a', 'FAQ Du lịch Cao Bằng (3)', 'faq', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Q: Cao Bằng có những đặc sản gì nhất định phải thử?
A: Bốn món không thể bỏ qua: bánh cuốn Cao Bằng (ăn sáng với nước dùng xương thay nước chấm), hạt dẻ Trùng Khánh (bùi và ngọt hơn hạt dẻ nơi khác, được bảo hộ chỉ dẫn địa lý), vịt quay 7 vị ướp mắc mật và thảo quả, và bánh áp chao (bánh chiên giòn nhân thịt vịt). Mua hạt dẻ tươi nếu đến mùa thu hoạch tháng 9–11.
*(Xem chi tiết tại foods.json và restaurants.json)*

---

## ❓ Câu hỏi ngoài phạm vi

Q: Giá vé vào thác Bản Giốc là bao nhiêu?
A: Hiện chúng tôi chưa có thông tin giá vé cập nhật và đã xác minh cho thác Bản Giốc. Giá vé và quy định thăm quan có thể thay đổi theo mùa. Bạn có thể kiểm tra tại trang Sở Du lịch Cao Bằng (caobang.gov.vn), hỏi trực tiếp tại ban quản lý khu thác khi đến, hoặc hỏi khách sạn/homestay địa phương để có thông tin mới nhất.

Q: Có thể sang Trung Quốc qua cửa khẩu ở Cao Bằng không?
A: Thông tin chi tiết về thủ tục và quy định cửa khẩu tại Cao Bằng nằm ngoài phạm vi knowledge base du lịch của chúng tôi. Để có thông tin chính xác, bạn nên liên hệ Cục Quản lý xuất nhập cảnh (xuatnhapcanh.gov.vn) hoặc đồn biên phòng khu vực trước khi có kế hoạch.

---

## ⚠️ An toàn & Lưu ý

Q: Đi Cao Bằng cần lưu ý an toàn gì?
A: Một số điểm cần chú ý: Đường đèo đến Bản Giốc và Pác Bó khá quanh co và dốc — không lái xe ban đêm, đặc biệt mùa mưa khi đường trơn. Khu vực gần biên giới Việt–Trung, không đi lạc vào khu vực hạn chế — hỏi hướng dẫn viên hoặc dân địa phương về phạm vi cho phép. Sóng điện thoại yếu ở nhiều vùng nông thôn — tải bản đồ offline trước. Mùa đông có sương giá ở độ cao — mang quần áo đủ ấm.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e4e5d128-10cc-5eec-bafd-fb7f8610a01e', 'FAQ Du lịch Cao Bằng (4)', 'faq', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Q: Có cần xin giấy phép đặc biệt để đến vùng biên giới Cao Bằng không?
A: Một số khu vực sát biên giới có thể yêu cầu giấy phép đặc biệt hoặc phải có hướng dẫn viên đi kèm. Tuy nhiên, các điểm du lịch chính như thác Bản Giốc và hang Pác Bó là khu vực mở, không cần giấy phép riêng. Nếu có kế hoạch đến vùng biên giới ngoài các điểm du lịch thông thường, nên hỏi Ban Quản lý Biên phòng địa phương hoặc Sở Du lịch Cao Bằng trước để đảm bảo đúng quy định.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '845c82cd-be59-5f65-bc57-8dfa85557230', 'Ẩm thực đặc sản Cao Bằng', 'food', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Đặc sản ẩm thực Cao Bằng:
- Bánh Cuốn Cao Bằng: Bánh cuốn Cao Bằng có lớp vỏ mỏng làm từ bột gạo tẻ địa phương, cuộn nhân thịt lợn băm xào mộc nhĩ và nấm hương. Điểm khác biệt so với bánh cuốn miền xuôi là nước chấm pha từ nước dùng thịt lợn hầm xư
  Địa điểm thưởng thức: [''Chợ Cao Bằng'', ''Các quán ăn sáng khu trung tâm TP. Cao Bằng'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn hoặc Google Maps
- Hạt Dẻ Trùng Khánh: Hạt dẻ trồng tại huyện Trùng Khánh — loại đặc sản nổi tiếng nhất Cao Bằng được bảo hộ chỉ dẫn địa lý. Hạt to, bùi, ngọt tự nhiên hơn hẳn hạt dẻ nơi khác. Thường nướng hoặc luộc ăn trực tiếp, hay làm t
  Địa điểm thưởng thức: [''Chợ Cao Bằng'', ''Chợ Trùng Khánh'', ''Các cửa hàng đặc sản TP. Cao Bằng'']
  Giá tham khảo: // TODO: xác nhận tại chợ địa phương — giá theo mùa
- Vịt Quay 7 Vị: Vịt quay đặc trưng của người Tày-Nùng Cao Bằng, ướp bảy loại gia vị bản địa gồm mắc mật, gừng, tỏi, sả, hồi, quế và thảo quả. Da giòn vàng óng, thịt thơm đậm đà hương núi rừng, khác hoàn toàn so với v
  Địa điểm thưởng thức: [''Các quán vịt quay ở TP. Cao Bằng'', ''Chợ Cao Bằng'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn hoặc Google Maps
- Miến Dong Cao Bằng: Miến làm từ tinh bột dong riềng trồng trên đất đồi Cao Bằng, sợi dai trong vắt, nấu không bị nhũn. Thường nấu với xương lợn, gà hoặc vịt, ăn cùng giò, chả và rau thơm địa phương. Là món chủ đạo của bữ
  Địa điểm thưởng thức: [''Chợ Cao Bằng'', ''Các quán bún phở khu trung tâm'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn
- Bánh Áp Chao: Bánh rán giòn đặc sản của người Nùng Cao Bằng, làm từ bột gạo trộn nhân thịt vịt hoặc thịt lợn và nấm hương, chiên ngập dầu cho đến khi vỏ ngoài giòn rụm vàng đẹp. Thường ăn kèm tương ớt và rau sống. 
  Địa điểm thưởng thức: [''Chợ Cao Bằng'', ''Khu chợ đêm TP. Cao Bằng'', ''Các hàng rong ven đường'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn hoặc Google Maps
- Lợn Quay Lá Mắc Mật: Lợn bản địa giống Lũng Pù được nuôi thả trên đồi, quay bằng củi và nhồi nhân lá mắc mật — loại lá rừng đặc trưng của vùng núi Đông Bắc. Da giòn tan, thịt mềm thơm mùi lá, khó tìm thấy ở nơi khác. Thườ
  Địa điểm thưởng thức: [''Nhà hàng và quán ăn TP. Cao Bằng'', ''Chợ phiên các huyện'']
  Giá tham khảo: // TODO: xác nhận tại Google Maps hoặc Foody.vn', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '63983568-02a6-5256-a882-df301b4aae2d', 'Cách di chuyển đến Cao Bằng', 'transport', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Di chuyển đến và trong Cao Bằng:

Cách đến:
- BUS từ Hà Nội (bến xe Mỹ Đình): Khoảng 7–9 tiếng — // TODO: xác nhận tại Traveloka hoặc nhà xe Hoàng Long, Kumho Samco
  Tuyến xe khách phổ biến nhất đi Cao Bằng. Có xe giường nằm chạy ban đêm. Đường đèo Mã Phục và đèo Giàng khá quanh co — người say xe nên uống thuốc trước.
- CAR từ Hà Nội: Khoảng 5–6 tiếng (tự lái theo Quốc lộ 3) — // TODO: tùy thuê xe tự lái hoặc thuê lái xe
  Đi theo Quốc lộ 3 qua Thái Nguyên, Bắc Kạn. Đoạn đèo vào Cao Bằng khá dốc và quanh co. Nên xuất phát sớm trước 6:00 để tránh tắc và còn sáng khi qua đèo.
- MOTORBIKE từ Hà Nội hoặc Lạng Sơn: Từ Hà Nội ~6–8 tiếng, từ Lạng Sơn ~3–4 tiếng — None
  Tuyến yêu thích của phượt thủ — phong cảnh đường đèo rất đẹp. Nên chuẩn bị xe tốt vì đường đèo dốc. Mùa đông có sương mù dày, cần cẩn thận.
- BUS từ Lạng Sơn: Khoảng 3–4 tiếng — // TODO: xác nhận tại bến xe Lạng Sơn
  Tuyến ngắn hơn từ Lạng Sơn, thuận tiện nếu kết hợp hành trình Đông Bắc.

Di chuyển trong thành phố:
- motorbike_rental: Phương tiện lý tưởng nhất để khám phá Cao Bằng. Đường đến thác Bản Giốc (~90km từ TP), hang Pác Bó (~60km) đều cần xe máy hoặc ô tô riêng. Thuê xe tại các khách sạn hoặc điểm cho thuê trên phố.
- taxi: Có taxi tại TP. Cao Bằng, nhưng ít phổ biến. Nên thỏa thuận giá trước cho các chuyến đi xa đến thác Bản Giốc hay Pác Bó.
- grab: Grab hoạt động hạn chế hoặc không có tại Cao Bằng — nên xác nhận trước khi đến và chuẩn bị phương án dự phòng.
- xe_om: Xe ôm truyền thống sẵn có tại bến xe và chợ TP. Cao Bằng. Hữu ích cho di chuyển ngắn trong thành phố.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ede80b02-5d1b-5303-8b0a-d09c0d433c8e', 'Khách sạn & Lưu trú tại Cao Bằng', 'hotel', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Lưu trú tại Cao Bằng:
- Khách sạn Bằng Giang (3★): Phường Hợp Giang, TP. Cao Bằng, tỉnh Cao Bằng
  Tiện ích: wifi, điều hòa, nhà hàng, lễ tân 24h
- Khách sạn Phong Lan (2★): Trung tâm TP. Cao Bằng, tỉnh Cao Bằng
  Tiện ích: wifi, điều hòa, lễ tân
- Homestay Bản Giốc View (None★): Khu vực huyện Trùng Khánh, gần thác Bản Giốc, tỉnh Cao Bằng
  Tiện ích: wifi, bữa sáng, xe máy cho thuê, hướng dẫn địa phương
- Nhà nghỉ Hà Quảng (None★): Thị trấn Hà Quảng, huyện Hà Quảng, tỉnh Cao Bằng
  Tiện ích: wifi, điều hòa, lễ tân
- Khách sạn Kim Đồng (2★): Trung tâm TP. Cao Bằng, tỉnh Cao Bằng
  Tiện ích: wifi, điều hòa, nhà hàng nhỏ, bãi đỗ xe', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '83e1b025-2e31-56c9-843c-16a0be6bce5a', 'Tour & Trải nghiệm tại Cao Bằng', 'tour', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Tour & Trải nghiệm tại Cao Bằng:
- Tour Thác Bản Giốc – Hang Pác Bó 2 Ngày 1 Đêm: 2 ngày 1 đêm — liên hệ
  Tour trọn gói ghép hai điểm nổi tiếng nhất Cao Bằng: thác Bản Giốc hùng vĩ và hang Pác Bó lịch sử. Ngày 1 di chuyển từ TP. Cao Bằng đến Trùng Khánh, thăm thác Bản Giốc và nghỉ đêm tại khu vực lân cận hoặc homestay. Ngày 2 thăm Pác Bó và về thành phố.
- Tour Khám Phá Cao Nguyên Đá Hồ Thang Hen: 1 ngày — liên hệ
  Tour 1 ngày khám phá hồ Thang Hen và các vùng cao nguyên đá vôi xung quanh huyện Trà Lĩnh. Tham quan quần thể 36 hồ liên thông, ngắm cảnh núi non đá vôi, tìm hiểu đời sống người Tày-Nùng địa phương. Phù hợp nhiếp ảnh gia và người yêu thiên nhiên.
- Hành Trình Về Nguồn – Lịch Sử Cách Mạng Cao Bằng: 1 ngày — liên hệ
  Tour chuyên đề lịch sử thăm hang Pác Bó, suối Lê-nin, núi Các Mác và Rừng Trần Hưng Đạo — cái nôi cách mạng Việt Nam. Phù hợp nhóm trường học, đoàn thể chính trị, hoặc khách quan tâm lịch sử. Có hướng dẫn viên am hiểu lịch sử địa phương.', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e670ee4d-0c2a-5843-892e-22bc14cba528', 'Lễ hội & Sự kiện tại Cao Bằng', 'event', 'aa20e516-ea38-4c41-9bd2-7de71095647e',
  'Lễ hội & Sự kiện tại Cao Bằng:
- Lễ Hội Lồng Tồng (Xuống Đồng): Tháng Giêng âm lịch (thường tháng 1–2 dương lịch)
  Lễ hội truyền thống lớn nhất của người Tày-Nùng Cao Bằng, cầu mùa màng bội thu đầu năm mới. Bao gồm lễ cúng thần nông tại ruộng, hội tung còn, hát lượn, đánh pháo đất và các trò chơi dân gian truyền thống. Đây là dịp để con cháu về thăm gia đình và c
- Lễ Hội Nàng Hai: Tháng 2–3 âm lịch (thường tháng 3–4 dương lịch)
  Lễ hội đón Nàng Trăng và cầu phúc của người Tày Cao Bằng, mang đậm bản sắc tín ngưỡng tâm linh dân gian. Có các nghi lễ đặc trưng: hát then, đàn tính, múa và dâng lễ vật cho Nàng Hai (người con gái Mặt Trăng) để cầu an, cầu mưa thuận gió hòa. Di sản 
- Kỷ Niệm Ngày Thành Lập Quân Đội Nhân Dân Việt Nam: 22 tháng 12 hằng năm
  Lễ kỷ niệm ngày 22/12/1944 — ngày thành lập Đội Việt Nam Tuyên truyền Giải phóng quân tại khu rừng Trần Hưng Đạo, Cao Bằng. Sự kiện được tổ chức hằng năm với các nghi lễ dâng hương, biểu diễn văn nghệ và triển lãm lịch sử, thu hút đoàn thể từ khắp cả', ARRAY['cao-bang', 'cao bằng', 'cao bằng', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a7c357fa-30cb-5995-89ab-a40f23267139', 'Tổng quan du lịch Hội An', 'destination', '44444444-4444-4444-4444-444444444444',
  'Tổng quan Hội An (Đà Nẵng):
Phố cổ di sản UNESCO với kiến trúc cổ kính, đèn lồng rực rỡ và ẩm thực đường phố nổi tiếng.

Mùa đẹp nhất: Tháng 2–4 (khô, mát, ít mưa)
Thời tiết: Nóng vào hè (28–35°C), mùa mưa bão tháng 9–12
Ẩm thực: Cao lầu, mì Quảng, cơm gà, bánh mì Phượng, bánh bao bánh vạc
Ngân sách tham khảo: 1,000,000–3,500,000đ/người', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a3a519b0-abcb-5091-9db1-5c0e5fe18d1d', 'Hội An – 🌟 Kinh Nghiệm Du Lịch Đà Nẵng – Hội An', 'activity', '44444444-4444-4444-4444-444444444444',
  '## 🌟 Kinh Nghiệm Du Lịch Đà Nẵng – Hội An

> Tổng hợp tips theo chủ đề: di sản lịch sử, tâm linh, thiên nhiên, biển và trải nghiệm mạo hiểm nhẹ. Số liệu giá/giờ/địa chỉ cụ thể xem tại các file JSON tương ứng cùng thư mục.

---', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '582dc78f-e39d-582e-b7a3-1e37301827d9', 'Hội An – 1. Phố cổ Hội An — Di sản & lịch sử', 'activity', '44444444-4444-4444-4444-444444444444',
  '## 1. Phố cổ Hội An — Di sản & lịch sử
*(thông tin đầy đủ: xem )*
Tip: Đêm 14 âm lịch hàng tháng, phố cổ tắt điện, chỉ còn đèn lồng — đây là thời điểm đặc biệt nhất để cảm nhận không khí cổ xưa, nên cố gắng xếp lịch trùng ngày này nếu muốn trải nghiệm trọn vẹn.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c153433f-47ca-5d88-af92-23931060c1aa', 'Hội An – 2. Chùa Cầu (Lai Viễn Kiều) — Tâm linh & lịch sử', 'tip', '44444444-4444-4444-4444-444444444444',
  '## 2. Chùa Cầu (Lai Viễn Kiều) — Tâm linh & lịch sử
*(thông tin đầy đủ: xem )*
Tip: Đến trước 8h sáng để chụp ảnh không đông người; góc đẹp nhất là từ bờ kênh đối diện, không phải đứng trên cầu.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a0d6c407-fcf1-5a77-934e-0f1d627fd17e', 'Hội An – 3. Bà Nà Hills & Cầu Vàng — Thách thức & thiên nhiên trên núi', 'tip', '44444444-4444-4444-4444-444444444444',
  '## 3. Bà Nà Hills & Cầu Vàng — Thách thức & thiên nhiên trên núi
*(thông tin đầy đủ: xem , tour tham khảo: )*
Tip: Trên núi lạnh hơn chân núi đáng kể, nhớ mang áo khoác nhẹ. Đi vào buổi sớm để tránh sương mù che mất view cầu và đông khách cuối tuần.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6e9d0257-8f9e-5b80-a4b1-aef8514d2258', 'Hội An – 4. Ngũ Hành Sơn — Tâm linh & hang động', 'tip', '44444444-4444-4444-4444-444444444444',
  '## 4. Ngũ Hành Sơn — Tâm linh & hang động
*(thông tin đầy đủ: xem )*
Tip: Kết hợp ghé làng đá Non Nước ngay dưới chân núi để mua đồ điêu khắc đá thủ công; nếu không muốn leo bộ nhiều, có dịch vụ thang máy lên núi.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '722b9dd0-bf12-54ae-b240-236697606a90', 'Hội An – 5. Bán đảo Sơn Trà & Chùa Linh Ứng — Thiên nhiên & tâm linh', 'tip', '44444444-4444-4444-4444-444444444444',
  '## 5. Bán đảo Sơn Trà & Chùa Linh Ứng — Thiên nhiên & tâm linh
*(thông tin đầy đủ: xem )*
Tip: Đi sáng sớm để có cơ hội quan sát voọc chà vá chân nâu quý hiếm trước khi nắng lên và xe cộ qua lại đông hơn.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '229358cd-16db-593c-97db-d54f013516b9', 'Hội An – 6. Rừng dừa Bảy Mẫu (Cẩm Thanh) — Trải nghiệm thuyền thúng', 'activity', '44444444-4444-4444-4444-444444444444',
  '## 6. Rừng dừa Bảy Mẫu (Cẩm Thanh) — Trải nghiệm thuyền thúng
*(thông tin đầy đủ: xem , tour tham khảo: )*
Tip: Đặt thuyền thúng qua homestay hoặc tour có giá rõ ràng trước khi đi để tránh bị nâng giá tại chỗ; phần lớn hành trình không có bóng râm nên cần mang mũ.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '27bdb2b8-49cb-56d3-b19a-614d890c3e69', 'Hội An – 7. Biển Mỹ Khê — Biển', 'tip', '44444444-4444-4444-4444-444444444444',
  '## 7. Biển Mỹ Khê — Biển
*(thông tin đầy đủ: xem )*
Tip: Tắm biển sáng sớm (trước 7h) khi biển yên tĩnh nhất và nắng chưa gắt; buổi tối dọc đường ven biển có nhiều quán hải sản phù hợp ăn tối.

---', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '2c74d24c-0ed3-52ce-9fea-611c81b856c3', 'Hội An – 🎒 Lịch Trình Gợi Ý', 'tip', '44444444-4444-4444-4444-444444444444',
  '## 🎒 Lịch Trình Gợi Ý

> Chi tiết giờ giấc và tham chiếu địa điểm đầy đủ: xem .', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '0124523b-b3ae-5186-b92f-e3d5340118f3', 'Hội An – 2 Ngày 1 Đêm — Cặp đôi, di sản & đèn lồng', 'activity', '44444444-4444-4444-4444-444444444444',
  '## 2 Ngày 1 Đêm — Cặp đôi, di sản & đèn lồng
Xem đầy đủ tại  → id: 

- Ngày 1: Nhận phòng resort ven sông → dạo phố cổ và Chùa Cầu buổi tối → ăn tối phong cách nhà cổ
- Ngày 2: Tham quan Chùa Cầu sáng sớm → ăn trưa cao lầu/bánh mì Phượng → ra sân bay', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '568bfcb4-f888-563f-97b9-59ce5d2b90b7', 'Hội An – 3 Ngày 2 Đêm — Gia đình, thiên nhiên & trải nghiệm', 'activity', '44444444-4444-4444-4444-444444444444',
  '## 3 Ngày 2 Đêm — Gia đình, thiên nhiên & trải nghiệm
Xem đầy đủ tại  → id: 

- Ngày 1: Nhận phòng khu vực biển Mỹ Khê → tắm biển buổi chiều
- Ngày 2: Tour Bà Nà Hills cả ngày, đi cáp treo và tham quan Cầu Vàng
- Ngày 3: Thuyền thúng rừng dừa Cẩm Thanh → ăn trưa chợ Hội An → mua sắm đèn lồng

---', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '61cb0f85-7294-5c26-a93b-fc02f36e8165', 'Hội An – 🚨 Kinh Nghiệm An Toàn', 'safety', '44444444-4444-4444-4444-444444444444',
  '## 🚨 Kinh Nghiệm An Toàn

- ⚠️ Nắng nóng mùa hè: Tháng 6–8 nắng gắt giữa trưa, đặc biệt khi đi bộ nhiều trong phố cổ hoặc leo Ngũ Hành Sơn — nên mang nước, đội mũ và nghỉ trong bóng mát thường xuyên.
- ⚠️ Mùa mưa bão: Tháng 10–12 có nguy cơ ngập lụt tại phố cổ Hội An và ảnh hưởng lịch trình lên Bà Nà Hills (sương mù, cáp treo có thể tạm dừng vì gió lớn) — nên theo dõi dự báo thời tiết sát ngày đi.
- ⚠️ Chênh lệch nhiệt độ trên núi: Bà Nà Hills lạnh hơn chân núi đáng kể, cần mang áo ấm để tránh cảm lạnh.
- ⚠️ Xe cộ trong phố cổ về đêm: Đường nhỏ, đông xe đạp và xe điện vào buổi tối — đi chậm, chú ý người đi bộ.

---', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3cd3f90f-acef-5afc-94bb-ba4f6acc5f52', 'Hội An – 💡 Tips Thực Tế', 'activity', '44444444-4444-4444-4444-444444444444',
  '## 💡 Tips Thực Tế

- 💰 Tiết kiệm: Ăn tại khu ẩm thực chợ Hội An hoặc các quán bình dân trong hẻm phố cổ thường rẻ hơn nhà hàng mặt phố — chi tiết địa điểm xem .
- 🏮 Trải nghiệm đặc biệt: Ưu tiên xếp lịch trùng đêm 14 âm lịch để xem phố cổ không dùng điện, chỉ chiếu sáng bằng đèn lồng — xem .
- 📸 Góc chụp ảnh: Chùa Cầu buổi sáng sớm trước 8h; đèn lồng phố cổ buổi tối nhìn từ tầng 2 các nhà cổ.
- 🎨 Mua đồ thủ công: Đèn lồng và áo dài may đo là quà lưu niệm đặc trưng nhất — danh sách nơi mua và mặt hàng xem .
- 🚲 Linh hoạt di chuyển: Thuê xe đạp trong phố cổ và xe máy cho quãng đường xa hơn (Sơn Trà, Bà Nà) — chi tiết phương tiện xem .

---', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '77347c91-08e0-5125-8acf-693cee324960', 'Hội An – 🛒 Mua Sắm & Đặc Sản Mang Về', 'tip', '44444444-4444-4444-4444-444444444444',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

| Đặc sản / Sản phẩm | Mua ở đâu (xem chi tiết) |
|---|---|
| Đèn lồng Hội An |  — Chợ Hội An, phố đèn lồng Trần Phú |
| Áo dài, veston may đo |  — Làng nghề may đo Hội An |
| Cao lầu, mì Quảng, cơm gà, bánh mì Phượng |  |
| Bánh bao bánh vạc (White Rose) |  |
| Hải sản khô, đặc sản chợ Đà Nẵng |  — Chợ Cồn Đà Nẵng |

*(Giá tham khảo và giờ mở cửa cụ thể: xem  và  — một số trường hiện đang  do chưa có nguồn xác thực, sẽ bổ sung khi có dữ liệu Foody/Google Maps đáng tin cậy.)*', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '14a02ce5-0912-598e-8eaf-4a5fb559151d', 'FAQ Du lịch Hội An (1)', 'faq', '44444444-4444-4444-4444-444444444444',
  '## ❓ FAQ Du Lịch Đà Nẵng – Hội An

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm đẹp nhất để đến Đà Nẵng – Hội An là khi nào?
A: Tháng 2–4 là lý tưởng nhất — khô ráo, mát mẻ, ít mưa, phù hợp đi bộ tham quan phố cổ. Tháng 6–8 nóng và là mùa biển đẹp nhất. Tháng 10–12 là mùa mưa bão, cần theo dõi dự báo thời tiết trước khi đi. (Nguồn: Vietnam Tourism / Sở Du lịch Đà Nẵng)

Q: Hội An có hay bị ngập lụt không?
A: Hội An nằm gần hạ lưu sông Thu Bồn nên ngập lụt thường xảy ra vào tháng 10–11 khi có mưa lớn. Nếu đi vào giai đoạn này, nên theo dõi tin tức địa phương và chuẩn bị phương án thay thế.

---

## 💰 Chi phí & Ngân sách

Q: Đi Đà Nẵng – Hội An cần chuẩn bị ngân sách thế nào?
A: Hiện chúng tôi chưa có mức ngân sách tổng hợp đã xác minh cho khu vực này *(xem city.json — budget hiện để null vì chưa có nguồn)*. Mức chi phí thực tế phụ thuộc loại hình lưu trú bạn chọn — xem chi tiết phân khúc tại  và các tour tham khảo tại .

Q: Vé máy bay và giá phòng có biến động nhiều theo mùa không?
A: Có — giá tăng mạnh vào mùa cao điểm (tháng 6–8 và các kỳ lễ Tết, 30/4–1/5). Bạn nên kiểm tra giá hiện tại trên Traveloka, Klook hoặc Booking.com vì hệ thống của chúng tôi hiện chưa có dữ liệu giá đã xác minh *(xem hotels.json, price_per_night = null)*.

---

## 🚗 Di chuyển

Q: Từ Hà Nội hoặc TP.HCM đến Đà Nẵng – Hội An bằng gì?
A: Phổ biến nhất là bay đến sân bay quốc tế Đà Nẵng, sau đó di chuyển về Hội An. Cũng có thể đi tàu hỏa tuyến Bắc–Nam dừng tại ga Đà Nẵng. Chi tiết các tuyến và hãng vận chuyển xem tại  (mục ).', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'db37b7e7-e183-51c2-9601-ea71f578c140', 'FAQ Du lịch Hội An (2)', 'faq', '44444444-4444-4444-4444-444444444444',
  'Q: Di chuyển trong khu vực Đà Nẵng – Hội An bằng gì là hợp lý nhất?
A: Xe đạp là phương tiện đặc trưng và phù hợp nhất trong phố cổ Hội An vì đường nhỏ và một số đoạn cấm xe cơ giới. Giữa Đà Nẵng và Hội An nên dùng Grab hoặc thuê xe máy. Xem đầy đủ các phương tiện tại  (mục ).

---

## 🏨 Lưu trú

Q: Nên chọn loại hình lưu trú nào tại Hội An?
A: Khu vực này có đầy đủ phân khúc từ homestay, hostel giá rẻ đến boutique hotel và resort 5 sao ven sông/biển — xem danh sách chi tiết và mô tả từng nơi tại . Nên ở gần phố cổ nếu muốn đi bộ thuận tiện, hoặc chọn resort ven biển/sông nếu ưu tiên không gian yên tĩnh.

Q: Có cần đặt phòng trước không?
A: Nên đặt trước, đặc biệt vào mùa cao điểm (tháng 2–5 và tháng 6–8) vì Hội An đón rất đông khách quốc tế và các resort ven biển thường kín phòng sớm.

---

## 🍜 Ẩm thực

Q: Đặc sản nổi tiếng nhất của Đà Nẵng – Hội An là gì?
A: Cao lầu, mì Quảng, cơm gà Hội An, bánh mì Phượng và bánh bao bánh vạc là những món tiêu biểu nhất. Mô tả chi tiết từng món xem tại .

Q: Nên ăn ở khu vực nào?
A: Khu phố cổ Hội An tập trung nhiều quán ăn truyền thống và quán bánh mì nổi tiếng; khu vực ven biển Mỹ Khê (Đà Nẵng) phù hợp ăn hải sản tươi buổi tối. Danh sách địa điểm cụ thể theo khu vực xem tại .

---

## ❓ Câu hỏi ngoài phạm vi

Q: Giá vé vào Bà Nà Hills hoặc Ngũ Hành Sơn là bao nhiêu?
A: Hiện chúng tôi chưa có thông tin giá vé cập nhật và xác thực cho các địa điểm này *(xem destinations.json, entry_fee = null)*. Bạn có thể kiểm tra trực tiếp tại Klook (klook.com/vi), Traveloka, hoặc website chính thức của điểm đến trước khi đi.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b910a7ea-168b-5e54-bf2a-eec47f08ed18', 'FAQ Du lịch Hội An (3)', 'faq', '44444444-4444-4444-4444-444444444444',
  'Q: Có thể tư vấn lịch trình đi Huế hoặc Quảng Ngãi kết hợp không?
A: Thông tin chi tiết về các tỉnh/thành khác hiện chưa thuộc phạm vi knowledge base của Đà Nẵng – Hội An. Bạn có thể tham khảo Vietnam Tourism tại vietnamtourism.gov.vn hoặc Sở Du lịch của tỉnh tương ứng.

---

## ⚠️ An toàn & Lưu ý

Q: Có lưu ý gì về an toàn khi đến Đà Nẵng – Hội An?
A: Mùa hè (tháng 6–8) nắng gắt giữa trưa, dễ say nắng khi đi bộ nhiều trong phố cổ — nên mang nước và che nắng. Mùa mưa bão (tháng 10–12) cần theo dõi dự báo thời tiết, đặc biệt nếu di chuyển lên Bà Nà Hills hoặc ra biển.

Q: Cần chuẩn bị gì trước khi đến?
A: Giày đi bộ thoải mái (phố cổ có nhiều đoạn lát đá không đều), kem chống nắng, và áo ấm nhẹ nếu lên Bà Nà Hills vì nhiệt độ trên núi thấp hơn nhiều so với chân núi *(xem destinations.json)*.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd298b959-4aa0-57aa-945c-d8b4a81a4d61', 'Ẩm thực đặc sản Hội An', 'food', '44444444-4444-4444-4444-444444444444',
  'Đặc sản ẩm thực Hội An:
- Cao lầu: Món mì đặc trưng chỉ có tại Hội An, sợi mì dày và giòn hơn các loại mì khác vì được nhúng nước từ giếng Bá Lễ và tro củi tràm, ăn kèm thịt heo xá xíu, tóp mỡ và rau sống.
  Địa điểm thưởng thức: [''Quán trong hẻm khu phố cổ Hội An (xem restaurants.json)'']
- Mì Quảng: Sợi mì gạo vàng nghệ ăn với rất ít nước dùng (khác phở/bún), kèm tôm, thịt heo, trứng cút, đậu phộng rang và bánh tráng nướng bẻ vụn rắc lên trên.
  Địa điểm thưởng thức: [''Các quán ăn tại Đà Nẵng và Hội An (xem restaurants.json)'']
- Cơm gà Hội An: Cơm nấu với nước luộc gà và nghệ cho màu vàng đặc trưng, ăn cùng thịt gà xé hoặc gà luộc chặt miếng, rau răm, hành phi và nước mắm gừng.
  Địa điểm thưởng thức: [''Khu vực phố cổ Hội An (xem restaurants.json)'']
- Bánh mì Phượng: Bánh mì kẹp thịt phong cách Hội An nổi tiếng toàn thế giới sau khi được đầu bếp Anthony Bourdain ca ngợi trong show truyền hình, nhân đầy đặn với pate, thịt nguội, rau và sốt đặc trưng.
  Địa điểm thưởng thức: [''Quán Bánh mì Phượng, khu phố cổ Hội An (xem restaurants.json)'']
- Bánh bao bánh vạc (White Rose): Hai loại bánh hấp làm từ bột gạo mỏng trong suốt, nhân tôm hoặc thịt băm, tạo hình như bông hồng trắng nhỏ, chỉ làm được ngon đúng vị bởi vài gia đình gốc Hội An.
  Địa điểm thưởng thức: [''Một số tiệm gia truyền trong khu phố cổ Hội An (xem restaurants.json)'']
- Bê thui Cầu Mống: Thịt bê thui nguyên con da vàng giòn, thái mỏng cuộn với rau sống, chuối chát, khế và bánh tráng, chấm mắm nêm — món đặc sản gắn liền với vùng Cầu Mống, Quảng Nam (cũ).
  Địa điểm thưởng thức: [''Khu vực ngoại ô Đà Nẵng/Hội An (xem restaurants.json)'']
- Mít trộn: Món gỏi làm từ mít non luộc trộn cùng tôm, da heo, đậu phộng rang và rau thơm, rưới nước mắm chua ngọt, thường ăn kèm bánh tráng nướng — món vặt đặc trưng đường phố Đà Nẵng.
  Địa điểm thưởng thức: [''Các quán ăn vặt tại Đà Nẵng (xem restaurants.json)'']', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7572a9f2-9f74-5ce1-a083-634df57fba20', 'Cách di chuyển đến Hội An', 'transport', '44444444-4444-4444-4444-444444444444',
  'Di chuyển đến và trong Hội An:

Cách đến:
- AIRPLANE từ Hà Nội: ~1,5 giờ bay đến sân bay quốc tế Đà Nẵng (DAD) — None
  Sân bay Đà Nẵng cách phố cổ Hội An ~30km, đi taxi/Grab khoảng 40–50 phút.
- AIRPLANE từ TP. Hồ Chí Minh: ~1 giờ bay đến sân bay quốc tế Đà Nẵng (DAD) — None
  Tần suất chuyến bay nhiều, đặc biệt cao điểm hè và lễ — nên đặt trước.
- TRAIN từ Hà Nội / TP. Hồ Chí Minh: Tàu Bắc–Nam dừng tại ga Đà Nẵng, thời gian tùy điểm xuất phát (khoảng 14–20 giờ) — None
  Phù hợp khách muốn ngắm cảnh dọc đường, đặc biệt đoạn đèo Hải Vân; mất nhiều thời gian hơn máy bay.
- BUS từ Huế: ~2,5–3 giờ bằng xe khách hoặc xe limousine — None
  Tuyến phổ biến cho khách kết hợp tham quan Huế, đi qua đèo Hải Vân với cảnh biển đẹp.

Di chuyển trong thành phố:
- grab: Phổ biến tại Đà Nẵng, ít xe hơn ở khu phố cổ Hội An do hạn chế xe cơ giới vào một số giờ.
- bicycle: Phương tiện đặc trưng nhất tại phố cổ Hội An — nhỏ gọn, phù hợp đường hẹp cấm ô tô.
- motorbike_rental: Linh hoạt nhất để di chuyển giữa Đà Nẵng và Hội An hoặc lên bán đảo Sơn Trà; cần có giấy phép lái xe hợp lệ.
- walking: Khu phố cổ Hội An nhỏ, đi bộ là cách tốt nhất để khám phá chi tiết kiến trúc cổ.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '867833f7-e293-5c13-95cf-3a6dfc3a82e6', 'Khách sạn & Lưu trú tại Hội An', 'hotel', '44444444-4444-4444-4444-444444444444',
  'Lưu trú tại Hội An:
- Hoi An Coco Homestay (None★): Khu vực Cẩm Châu, gần phố cổ Hội An
  Tiện ích: wifi, xe đạp miễn phí, bữa sáng, sân vườn
- Hoi An Backpacker Hostel (None★): Khu phố cổ Hội An
  Tiện ích: wifi, phòng dorm & phòng riêng, tour desk, khu sinh hoạt chung
- Little Hoi An Boutique Hotel (4★): Khu vực gần phố cổ Hội An
  Tiện ích: hồ bơi, wifi, nhà hàng, đưa đón sân bay (phụ phí)
- Anantara Hoi An Resort (5★): Ven sông Thu Bồn, gần phố cổ Hội An
  Tiện ích: hồ bơi, spa, nhà hàng cao cấp, thuyền đưa đón phố cổ
- Four Seasons Resort The Nam Hai, Hoi An (5★): Bãi biển Hà My, giữa Đà Nẵng và Hội An
  Tiện ích: villa riêng hồ bơi, spa, bãi biển riêng, nhà hàng fine-dining', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'cfc0f47d-1432-5358-8e58-f2866f1de896', 'Tour & Trải nghiệm tại Hội An', 'tour', '44444444-4444-4444-4444-444444444444',
  'Tour & Trải nghiệm tại Hội An:
- Tour Bà Nà Hills & Cầu Vàng 1 ngày: 1 ngày — liên hệ
  Tour khám phá khu nghỉ dưỡng núi Bà Nà Hills bằng cáp treo, tham quan Cầu Vàng, làng Pháp và vườn hoa, kết thúc trong ngày.
- Tour thuyền thúng rừng dừa Cẩm Thanh & làng rau Trà Quế: Nửa ngày — liên hệ
  Trải nghiệm ngồi thuyền thúng len lỏi rừng dừa nước Cẩm Thanh, sau đó tham gia hái rau và học nấu ăn tại làng rau Trà Quế truyền thống.
- Tour Ngũ Hành Sơn & Bán đảo Sơn Trà: 1 ngày — liên hệ
  Kết hợp tham quan quần thể núi đá Ngũ Hành Sơn, làng đá Non Nước và bán đảo Sơn Trà với chùa Linh Ứng, ngắm voọc chà vá chân nâu.
- Tour đêm thuyền hoa đăng sông Hoài: ~2 giờ buổi tối — liên hệ
  Đi thuyền dọc sông Hoài giữa lòng phố cổ Hội An, thả hoa đăng và ngắm đèn lồng phản chiếu trên mặt nước về đêm.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ec8d8b31-ee38-57fd-a157-8fee00dab004', 'Lễ hội & Sự kiện tại Hội An', 'event', '44444444-4444-4444-4444-444444444444',
  'Lễ hội & Sự kiện tại Hội An:
- Đêm phố cổ không dùng điện (Đêm rằm Hội An): Đêm 14 âm lịch hàng tháng
  Mỗi tháng một lần vào đêm 14 âm lịch, khu phố cổ tắt điện, chỉ chiếu sáng bằng đèn lồng truyền thống, tạo không khí huyền ảo đặc trưng chỉ có ở Hội An.
- Lễ hội Pháo hoa Quốc tế Đà Nẵng (DIFF): Thường tổ chức vào tháng 6 hàng năm — xác nhận lịch chính thức trước khi đến
  Cuộc thi trình diễn pháo hoa quốc tế quy tụ các đội thi từ nhiều quốc gia, một trong những sự kiện du lịch lớn nhất của Đà Nẵng, thu hút đông đảo du khách trong và ngoài nước.
- Lễ hội Quán Thế Âm Ngũ Hành Sơn: Thường tổ chức tháng 2–3 âm lịch hàng năm — xác nhận lịch chính thức trước khi đến
  Lễ hội Phật giáo lớn gắn với tín ngưỡng thờ Quán Thế Âm tại Ngũ Hành Sơn, gồm phần lễ trang nghiêm và phần hội với các hoạt động văn hóa dân gian.
- Lễ hội Cầu Bông làng rau Trà Quế: Thường tổ chức đầu năm âm lịch — xác nhận lịch chính thức trước khi đến
  Lễ hội cầu mong mùa màng tốt tươi của người dân làng rau Trà Quế, gồm nghi lễ cúng tổ nghề và các hoạt động hội làng truyền thống.', ARRAY['da-nang-hoi-an', 'hội an', 'đà nẵng', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7c43f4b0-70e4-583f-bf43-44a960b3f534', 'Tổng quan du lịch Buôn Ma Thuột', 'destination', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Tổng quan Buôn Ma Thuột (Đắk Lắk):
Thủ phủ cà phê Tây Nguyên với hồ Lắk, thác Dray Nur và voi nhà Bản Đôn; sau sáp nhập còn có vùng biển Phú Yên với Gành Đá Đĩa, Mũi Điện.

Mùa đẹp nhất: Tháng 11–4 (mùa khô)
Thời tiết: Mát mẻ 18–30°C mùa khô, mùa mưa tháng 5–10
Ẩm thực: Cà phê Buôn Ma Thuột, bún đỏ, gà nướng Bản Đôn, cơm lam
Ngân sách tham khảo: ', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'cb7179a0-451f-5dd8-8484-ec5d1b174a7d', 'Buôn Ma Thuột – 🌟 Kinh Nghiệm Du Lịch Buôn Ma Thuột (Đắk Lắk)', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 🌟 Kinh Nghiệm Du Lịch Buôn Ma Thuột (Đắk Lắk)

> Tổng hợp tips thực tế từ nguồn du lịch đáng tin cậy. Địa chỉ, giá vé, giờ mở cửa chi tiết — xem các file JSON tương ứng trong cùng thư mục.

---', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a6bda8ac-1e28-599f-82c2-96c12b60a18d', 'Buôn Ma Thuột – 1. Thác Dray Nur', 'safety', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 1. Thác Dray Nur
Loại: Thiên nhiên — thác nước
*(Xem địa chỉ, tọa độ, giờ mở cửa và giá vé tại )*
Tip: Mùa mưa (tháng 6–10) thác đổ mạnh, hùng vĩ nhưng đường trơn hơn; mùa khô (tháng 2–5) nước chia nhiều nhánh nhỏ, dễ chụp ảnh và an toàn hơn để tắm suối. Có thể kết hợp tham quan thác Dray Sáp liền kề qua cầu treo trong cùng buổi.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a202b0ce-07ec-5eec-a710-9ab3c90d3770', 'Buôn Ma Thuột – 2. Hồ Lắk', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 2. Hồ Lắk
Loại: Thiên nhiên — hồ nước ngọt
*(Xem địa chỉ, tọa độ tại )*
Tip: Đây là điểm xa trung tâm thành phố nhất trong các địa điểm chính (khoảng 56km), nên bố trí nguyên một buổi hoặc nghỉ đêm gần khu vực này để không phải di chuyển gấp gáp trong ngày.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '94a12f70-66d6-5028-b67e-4e13af986164', 'Buôn Ma Thuột – 3. Khu du lịch Buôn Đôn', 'activity', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 3. Khu du lịch Buôn Đôn
Loại: Văn hóa — lịch sử
*(Xem địa chỉ, tọa độ tại )*
Tip: Các hoạt động cưỡi voi truyền thống đang dần chuyển sang hình thức du lịch thân thiện với voi (quan sát, cho ăn) theo xu hướng bảo vệ động vật — nên hỏi rõ hình thức trải nghiệm cụ thể với đơn vị tổ chức trước khi đặt để tránh hiểu nhầm.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f825da33-bb96-5938-86d6-0735b7a881c1', 'Buôn Ma Thuột – 4. Vườn quốc gia Yok Đôn', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 4. Vườn quốc gia Yok Đôn
Loại: Thiên nhiên — rừng khộp
*(Xem địa chỉ, giá vé tham khảo tại )*
Tip: Khu rừng rất rộng và một số khu vực không có sóng điện thoại — nên đi cùng hướng dẫn viên/kiểm lâm, mặc trang phục dài tay và mang giày phù hợp đi bộ đường rừng.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5d22b9c6-f94f-5b67-a60c-1bc99b858380', 'Buôn Ma Thuột – 5. Bảo tàng Thế giới Cà phê', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 5. Bảo tàng Thế giới Cà phê
Loại: Văn hóa — bảo tàng
*(Xem địa chỉ, giờ mở cửa, giá vé tham khảo tại )*
Tip: Nên đến vào buổi sáng hoặc đầu giờ chiều để có ánh sáng tự nhiên đẹp khi chụp ảnh khu kiến trúc 5 mái nhà cong và thư viện ánh sáng; ăn nhẹ trước khi vào vì khuôn viên khá rộng, đi bộ nhiều.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '32205095-f5ec-58f1-a8f6-58a7e4cf926d', 'Buôn Ma Thuột – 6. Buôn Ako Dhong (Buôn Cô Thôn)', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 6. Buôn Ako Dhong (Buôn Cô Thôn)
Loại: Văn hóa — buôn làng Ê Đê
*(Xem địa chỉ tại )*
Tip: Đây là buôn làng hiếm hoi nằm ngay trong lòng thành phố, thuận tiện ghé qua trong nửa buổi mà không cần đi xa. Nên giữ ý tứ, xin phép trước khi chụp ảnh người dân hoặc vào nhà dài.

---', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd75893fa-163a-50aa-80c8-18521ec4d13e', 'Buôn Ma Thuột – 🎒 Lịch Trình Gợi Ý', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 🎒 Lịch Trình Gợi Ý

> Chi tiết giờ giấc từng buổi → xem . Ở đây chỉ tóm tắt định hướng chung.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '49f576d6-0735-513c-9f3c-427815c742c7', 'Buôn Ma Thuột – 2 Ngày 1 Đêm — Cặp đôi, cà phê & thiên nhiên', 'activity', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 2 Ngày 1 Đêm — Cặp đôi, cà phê & thiên nhiên
Xem lịch trình đầy đủ tại  → id: 

Định hướng:
- Ngày 1: Nhận phòng, ăn trưa đặc sản Tây Nguyên, tham quan Bảo tàng Thế giới Cà phê, dạo chợ đêm khu Ngã Sáu
- Ngày 2: Tham quan Buôn Ako Dhong, mua đặc sản cà phê làm quà, trả phòng và kết thúc chuyến đi', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '852a3ca5-7b36-5e66-a3a0-933295527e53', 'Buôn Ma Thuột – 3 Ngày 2 Đêm — Gia đình/nhóm bạn, thiên nhiên & văn hóa', 'activity', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 3 Ngày 2 Đêm — Gia đình/nhóm bạn, thiên nhiên & văn hóa
Xem lịch trình đầy đủ tại  → id: 

Định hướng:
- Ngày 1: Nhận phòng trung tâm thành phố, tham quan và tắm suối tại thác Dray Nur
- Ngày 2: Khám phá văn hóa voi tại Buôn Đôn, trekking nhẹ ở Vườn quốc gia Yok Đôn, nghỉ đêm tại khu vực Buôn Đôn
- Ngày 3: Quay về trung tâm, mua sắm đặc sản tại chợ trung tâm, kết thúc chuyến đi

---', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7c12d5e4-de41-5419-9f35-adfcc6ded585', 'Buôn Ma Thuột – 🚨 Kinh Nghiệm An Toàn', 'safety', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 🚨 Kinh Nghiệm An Toàn

- ⚠️ Tắm thác đúng khu vực cho phép: Tại thác Dray Nur và các thác khác, chỉ nên tắm ở khu vực được khoanh vùng an toàn, tránh đá trơn gần dòng chảy mạnh — đặc biệt nguy hiểm hơn vào mùa mưa khi nước dâng cao và chảy xiết.
- ⚠️ Trekking trong rừng nên có người dẫn đường: Vườn quốc gia Yok Đôn rộng hơn 115.000ha và một số khu vực không có sóng điện thoại, dễ lạc nếu tự đi mà không có hướng dẫn viên hoặc bản đồ rõ ràng.
- ⚠️ Đường vào các điểm xa trung tâm có thể trơn trượt vào mùa mưa: Nếu thuê xe máy tự đi tới thác Dray Nur, Buôn Đôn hay hồ Lắk, nên kiểm tra thời tiết và tình trạng đường trước khi xuất phát.

---', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd69f398c-fe44-5785-829e-60ad0df43bc6', 'Buôn Ma Thuột – 💡 Tips Thực Tế', 'safety', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 💡 Tips Thực Tế

- 💰 Tiết kiệm: Đặt vé máy bay và phòng trước 1–2 tháng nếu đi đúng dịp Lễ hội Cà phê Buôn Ma Thuột (tháng 3, 2 năm/lần) vì đây là giai đoạn cao điểm nhất của cả tỉnh.
- 📸 Chụp ảnh đẹp: Buổi sáng sớm là thời điểm lý tưởng để chụp ảnh tại Bảo tàng Thế giới Cà phê và các buôn làng vì ánh sáng dịu, ít người qua lại.
- 🕐 Thời điểm lý tưởng: Mùa khô (tháng 11–4) thuận tiện nhất để di chuyển và tham quan đa số điểm; nếu muốn ngắm hoa cà phê nở, nên đi vào khoảng tháng 2–3.
- 🍽️ Ẩm thực: Món bún đỏ ở Buôn Ma Thuột chủ yếu bán vào buổi chiều–khuya, không phải buổi sáng như nhiều nơi khác — nên lưu ý thời điểm trước khi đi tìm quán.

---', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '78ecd8e8-e142-5c34-b9c1-9dd442d76dea', 'Buôn Ma Thuột – 🛒 Mua Sắm & Đặc Sản Mang Về', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

| Sản phẩm | Mua ở đâu | Ghi chú |
|---|---|---|
| Cà phê Buôn Ma Thuột | Chợ trung tâm, Làng Cà phê Trung Nguyên *(xem )* | Nên hỏi giá vài sạp trước khi mua tại chợ vì giá có thể khác nhau |
| Bò một nắng, muối kiến vàng | Chợ trung tâm Buôn Ma Thuột | Phù hợp mua làm quà, bảo quản được lâu |
| Mật ong rừng, tiêu rừng, măng le khô | Chợ trung tâm, các cửa hàng đặc sản | Nên chọn nơi uy tín để đảm bảo chất lượng |
| Cà phê đóng gói sẵn làm quà | Cửa hàng Quà Tây Nguyên *(xem )* | Tiện mang theo máy bay vì đã đóng gói sẵn |

> Giá tham khảo: kiểm tra Traveloka Shop, Klook hoặc hỏi trực tiếp tại điểm bán — xem thêm  và  để biết chi tiết từng món/nơi mua.

---', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'efe8edf6-4ffb-5390-9f3f-f3e2fd10357a', 'Buôn Ma Thuột – 📞 Thông Tin Hữu Ích', 'tip', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## 📞 Thông Tin Hữu Ích

- Đường dây hỗ trợ du lịch: Tra số cụ thể tại vietnamtourism.gov.vn hoặc daklak.gov.vn
- Ứng dụng hữu ích: Grab/Xanh SM/Be (di chuyển), Google Maps (điều hướng), Foody (tìm quán ăn)', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f4cc172d-a8e0-5788-b645-c3f781c55494', 'FAQ Du lịch Buôn Ma Thuột (1)', 'faq', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  '## ❓ FAQ Du Lịch Buôn Ma Thuột (Đắk Lắk)

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm đẹp nhất để đến Buôn Ma Thuột là khi nào?
A: Mùa khô từ khoảng tháng 11 đến tháng 4 là thời điểm lý tưởng nhất — trời ráo, ít mưa, thuận tiện cho việc di chuyển và tham quan các thác nước, vườn quốc gia. Nếu muốn ngắm hoa cà phê nở trắng đồi, nên đi vào khoảng tháng 2–3; còn nếu thích thác nước đổ mạnh, hùng vĩ hơn thì mùa mưa (tháng 6–10) lại phù hợp hơn, dù việc di chuyển có thể bất tiện hơn đôi chút.

Q: Buôn Ma Thuột có khí hậu như thế nào, có cần lo bão lũ không?
A: Buôn Ma Thuột nằm trên cao nguyên ở độ cao trung bình khoảng 500m nên khí hậu mát mẻ hơn nhiều vùng khác, nhiệt độ trung bình khoảng 22–25°C quanh năm. Khu vực này ít bị ảnh hưởng trực tiếp bởi bão so với vùng duyên hải, nhưng mùa mưa (tháng 5–11) có thể khiến một số đường vào các điểm xa trung tâm (thác, vườn quốc gia) trơn trượt hơn — nên kiểm tra thời tiết trước khi đi nếu chọn đi vào giai đoạn này.

---

## 💰 Chi phí & Ngân sách

Q: Chi phí đi Buôn Ma Thuột vài ngày tốn khoảng bao nhiêu?
A: Hiện chúng tôi chưa có đủ dữ liệu giá đã xác minh để đưa ra mức tổng chi phí cụ thể cho một chuyến đi. Vé máy bay, giá phòng và giá tour có thể tham khảo chi tiết tại ,  và  trong hệ thống — các mục này sẽ được cập nhật khi có nguồn giá đáng tin cậy. Để có con số sát thực tế nhất tại thời điểm đi, bạn nên kiểm tra trực tiếp trên Traveloka hoặc Booking.com.

Q: Có cần đặt phòng/tour trước không?
A: Nếu đi đúng dịp Lễ hội Cà phê Buôn Ma Thuột (tổ chức 2 năm/lần, thường vào tháng 3) thì nên đặt phòng và vé máy bay trước ít nhất 1–2 tháng vì đây là giai đoạn cao điểm của cả tỉnh. Các thời điểm khác trong năm, đặt trước khoảng 1–2 tuần là đủ thoải mái, trừ dịp lễ Tết.

---

## 🚗 Di chuyển', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'fd6b25b9-c172-552f-a4e0-6c4010ff1cd0', 'FAQ Du lịch Buôn Ma Thuột (2)', 'faq', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Q: Từ TP.HCM hoặc Hà Nội đến Buôn Ma Thuột bằng phương tiện gì?
A: Máy bay là lựa chọn nhanh nhất, khoảng 1 giờ từ TP.HCM và khoảng 1 giờ 45 phút từ Hà Nội, do Vietnam Airlines và Vietjet Air khai thác (chi tiết giá xem ). Nếu muốn đi xe khách từ TP.HCM, hành trình mất khoảng 8–9 giờ đường bộ; đường sắt không có ga trực tiếp tại Buôn Ma Thuột nên phương án này ít phổ biến hơn.

Q: Di chuyển trong Buôn Ma Thuột bằng gì?
A: Trong nội thành, taxi và xe công nghệ (Grab, Xanh SM, Be) là lựa chọn tiện lợi nhất. Để đi các điểm xa trung tâm như thác Dray Nur, Buôn Đôn hay Vườn quốc gia Yok Đôn (cách 25–40km), nhiều du khách chọn thuê xe máy hoặc đặt tour ghép có xe đưa đón — xem chi tiết các phương tiện tại .

---

## 🏨 Lưu trú

Q: Nên ở khu vực nào tại Buôn Ma Thuột?
A: Trung tâm thành phố (gần khu vực Ngã Sáu, đường Nguyễn Tất Thành) là lựa chọn thuận tiện nhất để di chuyển đến các điểm tham quan nội thành như Bảo tàng Thế giới Cà phê, chợ trung tâm và các quán ăn. Nếu muốn trải nghiệm gần gũi văn hóa bản địa hơn, có thể chọn nghỉ tại khu vực Buôn Đôn hoặc hồ Lắk, nhưng sẽ cách trung tâm thành phố khá xa.

Q: Các loại hình lưu trú phổ biến tại Buôn Ma Thuột là gì?
A: Buôn Ma Thuột có đầy đủ phân khúc từ homestay mang đậm bản sắc Tây Nguyên tại Buôn Đôn, khách sạn 2–4 sao trong trung tâm thành phố, đến khách sạn 5 sao tiêu chuẩn quốc tế. Danh sách cụ thể cùng loại phòng và tiện ích xem tại .

---

## 🍜 Ẩm thực

Q: Đặc sản nổi tiếng nhất của Buôn Ma Thuột là gì?
A: Cà phê Buôn Ma Thuột là biểu tượng không thể thiếu, bên cạnh đó bún đỏ (món ăn sáng/chiều "quốc dân" của người dân), gà nướng Bản Đôn ăn kèm cơm lam, và bò một nắng là những món được nhắc đến nhiều nhất. Danh sách đầy đủ các món đặc sản và nơi ăn xem tại .', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'fd3893ec-14b0-5752-b86e-d34046312539', 'FAQ Du lịch Buôn Ma Thuột (3)', 'faq', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Q: Nên ăn ở đâu tại Buôn Ma Thuột?
A: Khu vực trung tâm thành phố quanh Ngã Sáu tập trung nhiều quán ăn đường phố và chợ đêm, thuận tiện để khám phá nhiều món trong một khu vực. Nếu muốn thưởng thức món gà nướng, cơm lam đúng chất Tây Nguyên, có thể ra hẳn khu du lịch Bản Đôn hoặc các quán chuyên ẩm thực dân tộc trong thành phố — danh sách cụ thể xem .

---

## ❓ Câu hỏi ngoài phạm vi

Q: Giá vé vào Vườn quốc gia Yok Đôn hoặc các điểm tham quan cụ thể hiện nay là bao nhiêu?
A: Hiện chúng tôi chưa có đầy đủ thông tin giá vé đã xác minh từ ≥2 nguồn khớp nhau cho tất cả các điểm tham quan. Bạn có thể kiểm tra giá tham khảo (nếu có) tại , hoặc xem trực tiếp tại Klook (klook.com/vi), Traveloka, hoặc liên hệ điểm đến trước khi đi để có giá chính xác nhất.

Q: Lễ hội Cồng chiêng Tây Nguyên năm nay tổ chức ở đâu, ngày nào cụ thể?
A: Lễ hội Cồng chiêng Tây Nguyên không có thời gian và địa điểm tổ chức cố định hằng năm — nó gắn với các nghi lễ truyền thống tại từng buôn làng (mừng lúa mới, cúng bến nước, cưới hỏi...) hơn là một sự kiện du lịch có lịch trình công bố sẵn. Để biết chương trình cụ thể trong năm, bạn nên tham khảo Sở Văn hóa, Thể thao và Du lịch tỉnh Đắk Lắk hoặc cổng thông tin daklak.gov.vn gần thời điểm dự định đi.

---

## ⚠️ An toàn & Lưu ý

Q: Có lưu ý gì về an toàn khi đến Buôn Ma Thuột?
A: Khi tham quan các thác nước như Dray Nur, nên tuân thủ khu vực được phép tắm và tránh các khu vực đá trơn gần dòng chảy mạnh, đặc biệt vào mùa mưa khi nước dâng cao và chảy xiết hơn. Nếu trekking trong Vườn quốc gia Yok Đôn, nên đi cùng hướng dẫn viên/kiểm lâm vì khu rừng rộng và một số khu vực không có sóng điện thoại.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b9b5a805-f2af-5b50-a8ca-78e54ba0a64a', 'FAQ Du lịch Buôn Ma Thuột (4)', 'faq', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Q: Cần chuẩn bị gì trước khi đến Buôn Ma Thuột?
A: Nên mang giày thể thao hoặc giày leo núi nếu có kế hoạch trekking hoặc tham quan thác, vì nhiều điểm yêu cầu đi bộ khá nhiều trên địa hình không bằng phẳng. Nếu đi vào mùa mưa (tháng 5–11), nên mang theo áo mưa hoặc áo khoác nhẹ vì các cơn mưa cao nguyên có thể đến bất ngờ vào buổi chiều.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'cf496410-1bbf-509c-b51c-fcb4145490c4', 'Ẩm thực đặc sản Buôn Ma Thuột', 'food', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Đặc sản ẩm thực Buôn Ma Thuột:
- Cao lầu: Món mì đặc trưng chỉ có tại Hội An, sợi mì dày và giòn hơn các loại mì khác vì được nhúng nước từ giếng Bá Lễ và tro củi tràm, ăn kèm thịt heo xá xíu, tóp mỡ và rau sống.
  Địa điểm thưởng thức: [''Quán trong hẻm khu phố cổ Hội An (xem restaurants.json)'']
- Mì Quảng: Sợi mì gạo vàng nghệ ăn với rất ít nước dùng (khác phở/bún), kèm tôm, thịt heo, trứng cút, đậu phộng rang và bánh tráng nướng bẻ vụn rắc lên trên.
  Địa điểm thưởng thức: [''Các quán ăn tại Đà Nẵng và Hội An (xem restaurants.json)'']
- Cơm gà Hội An: Cơm nấu với nước luộc gà và nghệ cho màu vàng đặc trưng, ăn cùng thịt gà xé hoặc gà luộc chặt miếng, rau răm, hành phi và nước mắm gừng.
  Địa điểm thưởng thức: [''Khu vực phố cổ Hội An (xem restaurants.json)'']
- Bánh mì Phượng: Bánh mì kẹp thịt phong cách Hội An nổi tiếng toàn thế giới sau khi được đầu bếp Anthony Bourdain ca ngợi trong show truyền hình, nhân đầy đặn với pate, thịt nguội, rau và sốt đặc trưng.
  Địa điểm thưởng thức: [''Quán Bánh mì Phượng, khu phố cổ Hội An (xem restaurants.json)'']
- Bánh bao bánh vạc (White Rose): Hai loại bánh hấp làm từ bột gạo mỏng trong suốt, nhân tôm hoặc thịt băm, tạo hình như bông hồng trắng nhỏ, chỉ làm được ngon đúng vị bởi vài gia đình gốc Hội An.
  Địa điểm thưởng thức: [''Một số tiệm gia truyền trong khu phố cổ Hội An (xem restaurants.json)'']
- Bê thui Cầu Mống: Thịt bê thui nguyên con da vàng giòn, thái mỏng cuộn với rau sống, chuối chát, khế và bánh tráng, chấm mắm nêm — món đặc sản gắn liền với vùng Cầu Mống, Quảng Nam (cũ).
  Địa điểm thưởng thức: [''Khu vực ngoại ô Đà Nẵng/Hội An (xem restaurants.json)'']
- Mít trộn: Món gỏi làm từ mít non luộc trộn cùng tôm, da heo, đậu phộng rang và rau thơm, rưới nước mắm chua ngọt, thường ăn kèm bánh tráng nướng — món vặt đặc trưng đường phố Đà Nẵng.
  Địa điểm thưởng thức: [''Các quán ăn vặt tại Đà Nẵng (xem restaurants.json)'']', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f78e7002-ec98-50a9-bea6-f6f324eaf6b0', 'Cách di chuyển đến Buôn Ma Thuột', 'transport', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Di chuyển đến và trong Buôn Ma Thuột:

Cách đến:
- AIRPLANE từ TP. Hồ Chí Minh: Khoảng 1 giờ — Khoảng 580.000–1.000.000đ/chiều (Vietjet/Traveloka, 06/2026 — biến động theo thời điểm đặt)
  Sân bay Buôn Ma Thuột (BMV) cách trung tâm thành phố khoảng 8km, mất khoảng 15–20 phút di chuyển vào trung tâm.
- AIRPLANE từ Hà Nội: Khoảng 1 giờ 45 phút — Khoảng 599.000–900.000đ/chiều (Vietjet, 06/2026 — biến động theo thời điểm đặt)
  Khai thác khoảng 3 chuyến/ngày từ sân bay Nội Bài — xác nhận lịch bay thực tế trước khi đặt vì có thể thay đổi theo mùa.
- AIRPLANE từ Đà Nẵng: Khoảng 55 phút – 1 giờ 10 phút — None
  Chuyến bay thẳng hiện chỉ khai thác khoảng 1–2 chuyến/ngày vào một số ngày trong tuần — xác nhận lịch bay cụ thể trước khi đặt.
- BUS từ TP. Hồ Chí Minh: Khoảng 8–9 giờ (đường bộ ~350km) — Khoảng 300.000–400.000đ/chiều (theo Vexere & VnExpress, 06/2026 — biến động theo nhà xe và thời điểm)
  Nhiều xe khởi hành buổi tối để sáng hôm sau có mặt tại Buôn Ma Thuột, phù hợp tiết kiệm thời gian ban ngày.

Di chuyển trong thành phố:
- taxi: Các hãng taxi phổ biến: Mai Linh, Quyết Tiến, Tây Nguyên, Ban Mê Xanh, Đắk Lắk Taxi.
- grab: Xe công nghệ (Grab, Xanh SM, Be, GoJek) ngày càng phổ biến tại Buôn Ma Thuột, đặt qua app tiện lợi với giá cước minh bạch.
- xe_om: Phù hợp di chuyển nhanh quãng đường ngắn trong nội thành, nên thỏa thuận giá trước khi đi nếu không qua app.
- motorbike_rental: Thuê xe máy là lựa chọn linh hoạt để di chuyển tới các điểm xa trung tâm như thác Dray Nur, Buôn Đôn, Yok Đôn — nên hỏi thuê tại các khách sạn hoặc cửa hàng cho thuê xe ở trung tâm thành phố.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ad263e06-a468-5497-a758-ac99fef289dc', 'Khách sạn & Lưu trú tại Buôn Ma Thuột', 'hotel', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Lưu trú tại Buôn Ma Thuột:
- Hoi An Coco Homestay (None★): Khu vực Cẩm Châu, gần phố cổ Hội An
  Tiện ích: wifi, xe đạp miễn phí, bữa sáng, sân vườn
- Hoi An Backpacker Hostel (None★): Khu phố cổ Hội An
  Tiện ích: wifi, phòng dorm & phòng riêng, tour desk, khu sinh hoạt chung
- Little Hoi An Boutique Hotel (4★): Khu vực gần phố cổ Hội An
  Tiện ích: hồ bơi, wifi, nhà hàng, đưa đón sân bay (phụ phí)
- Anantara Hoi An Resort (5★): Ven sông Thu Bồn, gần phố cổ Hội An
  Tiện ích: hồ bơi, spa, nhà hàng cao cấp, thuyền đưa đón phố cổ
- Four Seasons Resort The Nam Hai, Hoi An (5★): Bãi biển Hà My, giữa Đà Nẵng và Hội An
  Tiện ích: villa riêng hồ bơi, spa, bãi biển riêng, nhà hàng fine-dining', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7761ced5-927f-50c5-98ce-7042caf1353d', 'Tour & Trải nghiệm tại Buôn Ma Thuột', 'tour', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Tour & Trải nghiệm tại Buôn Ma Thuột:
- Tour khám phá thác Dray Nur & Vườn quốc gia Yok Đôn: 1 ngày — liên hệ
  Tour ngày kết hợp tham quan cụm thác Dray Nur hùng vĩ và trải nghiệm sinh thái tại Vườn quốc gia Yok Đôn — phù hợp cho người yêu thiên nhiên và muốn vận động nhẹ (đi bộ, tắm suối).
- Tour văn hóa Buôn Đôn — Sông Sêrêpôk & làng voi: 1 ngày — liên hệ
  Tour tìm hiểu văn hóa, lịch sử nghề thuần dưỡng voi tại Buôn Đôn, đi qua cầu treo bắc qua sông Sêrêpôk, tham quan mộ vua săn voi và trải nghiệm các hoạt động du lịch thân thiện với voi.
- Tour Hồ Lắk & buôn làng M''nông: 1 ngày (có thể nghỉ đêm tại khu vực hồ) — liên hệ
  Trải nghiệm ngồi thuyền độc mộc trên hồ Lắk, tham quan buôn Jun – buôn Lê của người M''nông, xem trình diễn cồng chiêng, đàn đá, đàn T''rưng và tìm hiểu đời sống nhà dài truyền thống.
- Tour văn hóa cà phê — Làng Cà phê Trung Nguyên & Bảo tàng Thế giới Cà phê: Nửa ngày — liên hệ
  Tour khám phá văn hóa cà phê Buôn Ma Thuột tại Làng Cà phê Trung Nguyên và Bảo tàng Thế giới Cà phê, gồm trải nghiệm thưởng thức nhiều loại cà phê và tìm hiểu hành trình hạt cà phê từ khắp thế giới qua không gian trưng bày tương tác.', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e953870e-0dc1-5c70-85a8-0103610ccfb8', 'Lễ hội & Sự kiện tại Buôn Ma Thuột', 'event', '9193ad16-91b7-43cd-86bf-e208fcdc43f1',
  'Lễ hội & Sự kiện tại Buôn Ma Thuột:
- Lễ hội Cà phê Buôn Ma Thuột: Định kỳ 2 năm/lần, thường vào đầu/giữa tháng 3 (lần gần nhất: 9–13/3/2025)
  Lễ hội cấp quốc gia lớn nhất của tỉnh Đắk Lắk, được Thủ tướng Chính phủ công nhận, tổ chức định kỳ 2 năm/lần nhằm tôn vinh người trồng và kinh doanh cà phê, quảng bá thương hiệu ''Buôn Ma Thuột — Điểm đến của cà phê thế giới''. Gồm hội chợ triển lãm cà
- Hội Voi Buôn Đôn: Thường gắn liền với chuỗi hoạt động Lễ hội Cà phê Buôn Ma Thuột (tháng 3, năm tổ chức lễ hội cà phê) — xác nhận lịch cụ thể từng năm
  Sự kiện văn hóa gắn với truyền thống thuần dưỡng voi của người Ê Đê, M''nông tại Buôn Đôn, thường được tổ chức như một phần hành trình du lịch trong khuôn khổ Lễ hội Cà phê Buôn Ma Thuột.
- Hội đua thuyền độc mộc huyện Lắk: Thường tổ chức gắn với chuỗi hoạt động Lễ hội Cà phê Buôn Ma Thuột — xác nhận lịch cụ thể từng năm
  Hoạt động đua thuyền độc mộc truyền thống của người M''nông trên hồ Lắk, là một trong các hành trình du lịch trải nghiệm văn hóa được tổ chức trong khuôn khổ các lễ hội lớn của tỉnh.
- Lễ hội Cồng chiêng Tây Nguyên: Không có thời gian tổ chức cố định, thường diễn ra vào khoảng tháng 11 đến tháng 1 (cuối năm theo âm lịch), tại các buôn làng
  Không gian Văn hóa Cồng chiêng Tây Nguyên đã được UNESCO công nhận là Di sản văn hóa phi vật thể đại diện của nhân loại. Tiếng cồng chiêng được xem là ngôn ngữ giao tiếp giữa con người với thần linh (Yang), xuất hiện trong các nghi lễ quan trọng như ', ARRAY['dak-lak-buon-ma-thuot', 'buôn ma thuột', 'đắk lắk', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f816816d-6862-5db8-9b66-7a698421f4fc', 'Tổng quan du lịch Điện Biên Phủ', 'destination', '01c26442-a471-48e6-b6f1-dc3036aa718e',
  'Tổng quan Điện Biên Phủ (Điện Biên):
Vùng đất lịch sử với chiến thắng Điện Biên Phủ 1954, đồi A1, hầm Đờ Cát và cánh đồng Mường Thanh.

Mùa đẹp nhất: Tháng 10–4 (khô, mát)
Thời tiết: Mát mẻ 15–28°C, mùa mưa tháng 5–9
Ẩm thực: Xôi nếp nương, gà bản, cá suối nướng, rượu Mường Ảng
Ngân sách tham khảo: ', ARRAY['dien-bien-dien-bien-phu', 'điện biên phủ', 'điện biên', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7009643e-9eb3-551f-8b42-6d2975f0c534', 'Ẩm thực đặc sản Điện Biên Phủ', 'food', '01c26442-a471-48e6-b6f1-dc3036aa718e',
  'Đặc sản ẩm thực Điện Biên Phủ:
- Xôi Nếp Nương: Xôi nấu từ giống nếp nương đặc sản vùng cao Điện Biên — hạt dài, trắng trong, thơm dịu tự nhiên. Được đồ trong chõ gỗ truyền thống của người Thái, xôi dẻo mà không dính tay, vị ngọt thanh. Thường ăn c
  Địa điểm thưởng thức: [''Chợ Điện Biên Phủ'', ''Nhà hàng ẩm thực Thái trong thành phố'', ''Homestay nhà sàn'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn hoặc Google Maps
- Gà Bản Nướng: Gà ta nuôi thả vườn của đồng bào dân tộc Thái, thịt chắc săn và đậm vị hơn gà công nghiệp. Ướp gia vị bản địa gồm mắc khén (hạt tiêu rừng Tây Bắc), gừng, sả, tỏi, ớt rừng rồi nướng trên than củi. Mùi 
  Địa điểm thưởng thức: [''Nhà hàng ẩm thực Thái TP. Điện Biên Phủ'', ''Homestay bản Thái'', ''Chợ đêm'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn
- Cá Suối Nướng Mắc Khén: Cá bắt từ các suối núi sạch quanh Điện Biên — thường là cá chép suối, cá trầm hoặc cá niếc. Nhồi nhân sả, gừng, mắc khén vào bụng cá rồi kẹp tre nướng trên bếp than. Thịt cá ngọt, thơm mùi gia vị rừng
  Địa điểm thưởng thức: [''Nhà hàng ẩm thực Thái'', ''Bản văn hóa Thái'', ''Quán ăn ven suối'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn hoặc Google Maps
- Rượu Cần Điện Biên: Rượu ủ từ gạo nếp nương và các loại lá cây rừng trong chum đất, uống chung qua cần trúc dài. Nồng độ cồn thấp, vị ngọt thanh, đậm hương thảo mộc rừng núi. Uống rượu cần là nghi thức quan trọng trong v
  Địa điểm thưởng thức: [''Homestay nhà sàn'', ''Bản văn hóa Thái'', ''Lễ hội địa phương'']
  Giá tham khảo: // TODO: xác nhận tại cơ sở địa phương
- Pa Pỉnh Tộp (Cá Gập Nướng): Đặc sản cá nướng độc đáo của người Thái — cá được mổ dọc sống lưng, gập đôi, kẹp nhân gồm sả, gừng, mắc khén, lá chanh và ớt rồi nướng trên lửa than. Cách gấp đặc biệt giúp gia vị ngấm sâu vào từng th
  Địa điểm thưởng thức: [''Nhà hàng ẩm thực Thái TP. Điện Biên Phủ'', ''Homestay bản Thái'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn
- Nậm Pịa: Canh đặc sản người Thái làm từ lòng dê hoặc lòng bò nấu với mắc khén, sả, gừng và đặc biệt là dịch tiêu hóa (pịa) — nghe lạ nhưng tạo ra vị đắng nhẹ độc đáo rất cuốn. Dành cho người dạn thử đặc sản ''t
  Địa điểm thưởng thức: [''Nhà hàng ẩm thực Thái'', ''Chợ địa phương'']
  Giá tham khảo: // TODO: xác nhận tại Foody.vn', ARRAY['dien-bien-dien-bien-phu', 'điện biên phủ', 'điện biên', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b4d14aaa-5bf2-53ae-a1d6-10ed455ce4e5', 'Cách di chuyển đến Điện Biên Phủ', 'transport', '01c26442-a471-48e6-b6f1-dc3036aa718e',
  'Di chuyển đến và trong Điện Biên Phủ:

Cách đến:
- FLIGHT từ Hà Nội (Nội Bài): Khoảng 55–65 phút — // TODO: xác nhận tại Vietnam Airlines hoặc Traveloka — giá thay đổi theo mùa
  Tuyến bay nhanh nhất và thuận tiện nhất. Sân bay Điện Biên Phủ cách trung tâm thành phố khoảng 2km. Lưu ý: tải trọng hành lý có thể bị giới hạn hơn do loại máy bay nhỏ (ATR72). Đặt vé sớm vào mùa cao 
- BUS từ Hà Nội (bến xe Mỹ Đình): Khoảng 10–12 tiếng — // TODO: xác nhận tại Traveloka hoặc nhà xe địa phương
  Có xe giường nằm chạy ban đêm từ Mỹ Đình — xuất phát tối, đến sáng sớm. Đường đèo qua Sơn La và Tuần Giáo khá quanh co — người say xe cần uống thuốc. Thích hợp khách ít thời gian hoặc muốn tiết kiệm c
- CAR từ Hà Nội: Khoảng 7–9 tiếng (tự lái theo QL6) — // TODO: tùy thuê xe hoặc tự lái
  Đi theo Quốc lộ 6 qua Hòa Bình, Sơn La, Tuần Giáo. Phong cảnh rất đẹp nhưng đường đèo dài và mệt — nên có 2 người thay nhau lái. Xuất phát trước 5:00 sáng để đến trước tối.
- MOTORBIKE từ Hà Nội hoặc Sơn La: Từ Hà Nội ~2 ngày (qua đêm Sơn La), từ Sơn La ~4–5 tiếng — None
  Hành trình phượt đèo huyền thoại qua đèo Pha Đin — một trong tứ đại đỉnh đèo Tây Bắc. Chỉ phù hợp người có kinh nghiệm lái đèo. Đường đèo Pha Đin dài ~32km với nhiều khúc cua tay áo.

Di chuyển trong thành phố:
- motorbike_rental: Lý tưởng để khám phá cánh đồng Mường Thanh và các bản Thái quanh thành phố. Các di tích lịch sử tập trung khá gần nhau trong bán kính ~5km — có thể đi xe máy dễ dàng. Thuê tại khách sạn hoặc các điểm 
- taxi: Taxi có sẵn tại TP. Điện Biên Phủ. Thỏa thuận giá trước cho các chuyến dài ra ngoài thành phố. Có thể đặt taxi trọn ngày để đi các di tích — hỏi khách sạn để giới thiệu lái xe tin cậy.
- xe_om: Xe ôm có tại bến xe và trung tâm thành phố. Hữu ích cho di chuyển ngắn trong thành phố. Thỏa thuận giá rõ ràng trước khi đi.
- grab: Grab hoạt động hạn chế hoặc không có tại Điện Biên Phủ — không nên phụ thuộc vào ứng dụng gọi xe. Chuẩn bị số điện thoại taxi địa phương.', ARRAY['dien-bien-dien-bien-phu', 'điện biên phủ', 'điện biên', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ad697fca-3004-516c-bfd6-a9c84ae9ebfe', 'Khách sạn & Lưu trú tại Điện Biên Phủ', 'hotel', '01c26442-a471-48e6-b6f1-dc3036aa718e',
  'Lưu trú tại Điện Biên Phủ:
- Khách sạn Mường Thanh Holiday Điện Biên Phủ (4★): Him Lam, TP. Điện Biên Phủ, tỉnh Điện Biên
  Tiện ích: wifi, hồ bơi, nhà hàng, spa
- Khách sạn Him Lam (3★): Trung tâm TP. Điện Biên Phủ, tỉnh Điện Biên
  Tiện ích: wifi, điều hòa, nhà hàng, lễ tân 24h
- Homestay Nhà Sàn Mường Thanh (None★): Khu vực bản Thái quanh thung lũng Mường Thanh, tỉnh Điện Biên
  Tiện ích: wifi, bữa sáng, nhà sàn truyền thống, trải nghiệm văn hóa Thái
- Nhà nghỉ Điện Biên (None★): Trung tâm TP. Điện Biên Phủ, tỉnh Điện Biên
  Tiện ích: wifi, điều hòa, lễ tân
- Khách sạn Điện Biên Phủ (2★): TP. Điện Biên Phủ, tỉnh Điện Biên
  Tiện ích: wifi, điều hòa, nhà hàng nhỏ', ARRAY['dien-bien-dien-bien-phu', 'điện biên phủ', 'điện biên', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '9daffe58-d790-506c-a957-b5aeb881a112', 'Tour & Trải nghiệm tại Điện Biên Phủ', 'tour', '01c26442-a471-48e6-b6f1-dc3036aa718e',
  'Tour & Trải nghiệm tại Điện Biên Phủ:
- Tour Di Tích Lịch Sử Điện Biên Phủ Trọn Gói 1 Ngày: 1 ngày — liên hệ
  Tour 1 ngày thăm toàn bộ cụm di tích lịch sử Điện Biên Phủ: Bảo tàng Chiến thắng, Đồi A1, Hầm Đờ Cát, Nghĩa trang Liệt sĩ A1, Đồi D1 (Dominique 2) và Him Lam. Hướng dẫn viên am hiểu lịch sử sẽ kể lại diễn biến 56 ngày đêm chiến dịch tại từng địa điểm
- Tour Văn Hóa Bản Thái & Cánh Đồng Mường Thanh: 1 ngày — liên hệ
  Tour 1 ngày kết hợp khám phá văn hóa bản địa: thăm bản người Thái trắng, trải nghiệm múa xòe và rượu cần, tham quan cánh đồng Mường Thanh vào mùa lúa, tìm hiểu nghề dệt thổ cẩm Thái và thưởng thức bữa trưa ẩm thực bản Thái truyền thống tại nhà sàn.
- Hành Trình Điện Biên – Sơn La 3 Ngày 2 Đêm: 3 ngày 2 đêm — liên hệ
  Hành trình mở rộng kết hợp Điện Biên Phủ và Sơn La trong 3 ngày: di tích lịch sử Điện Biên (ngày 1–2), cánh đồng Mường Thanh và bản Thái (ngày 2 chiều), di chuyển qua đèo Pha Đin về Sơn La và thăm Nhà tù Sơn La (ngày 3). Tour đường dài phù hợp nhóm m', ARRAY['dien-bien-dien-bien-phu', 'điện biên phủ', 'điện biên', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8d52e69f-816c-5bc2-b1d0-23b68e14751d', 'Tổng quan du lịch Đồng Nai', 'destination', '0a193ffa-e0a2-401c-8e6f-f54630558a65',
  'Tổng quan Đồng Nai (Đồng Nai):
Vườn quốc gia Nam Cát Tiên với hệ sinh thái rừng nguyên sinh và thác Giang Điền gần TP.HCM; sau sáp nhập còn có vùng biên giới Bình Phước với vườn quốc gia Bù Gia Mập, thác Đứng Gió.

Mùa đẹp nhất: Tháng 12–4 (mùa khô, dễ trekking)
Thời tiết: Nóng ẩm 25–34°C, mùa mưa tháng 5–11
Ẩm thực: Gỏi cá Biên Hòa, bưởi Tân Triều, dế chiên, lẩu cá kèo
Ngân sách tham khảo: ', ARRAY['dong-nai', 'đồng nai', 'đồng nai', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '57cd1d22-d0b2-50d9-b754-8fffcd2c0223', 'Ẩm thực đặc sản Đồng Nai', 'food', '0a193ffa-e0a2-401c-8e6f-f54630558a65',
  'Đặc sản ẩm thực Đồng Nai:
- Gỏi cá Biên Hòa: Đặc sản nổi tiếng nhất Biên Hòa — cá lóc hoặc cá trắm thái lát mỏng ướp gia vị chua ngọt, ăn kèm với bánh tráng, rau sống, bún và nước mắm pha đặc trưng. Khác với gỏi cá miền Trung (ăn sống), gỏi cá B
  Địa điểm thưởng thức: [''Các quán đặc sản dọc đường Nguyễn Ái Quốc, Biên Hòa'', ''Nhà hàng ven sông Đồng Nai'']
- Bưởi Tân Triều: Giống bưởi đặc sản nổi tiếng nhất Đồng Nai, có hai loại: bưởi da xanh (vỏ xanh, múi hồng ngọt) và bưởi đường lá cam (vỏ vàng, múi trắng ngọt dịu). Bưởi Tân Triều được trồng tại xã Tân Bình, Vĩnh Cửu —
  Địa điểm thưởng thức: [''Vườn bưởi Tân Triều (hái trực tiếp)'', ''Chợ Biên Hòa'', ''Các cửa hàng đặc sản'']
- Dế chiên giòn: Món ăn đặc trưng của vùng Đông Nam Bộ, dế được nuôi hoặc bắt tự nhiên, làm sạch rồi chiên giòn với tỏi ớt. Có thể ăn kèm với muối chanh hoặc tương ớt. Mặc dù lạ miệng nhưng là trải nghiệm ẩm thực khôn
  Địa điểm thưởng thức: [''Các quán ăn địa phương khu Biên Hòa'', ''Chợ đêm Biên Hòa'', ''Khu ẩm thực gần bến xe'']
- Bánh canh Trảng Bom: Bánh canh bột gạo sợi to, nước dùng từ xương heo ninh lâu trong vắt và ngọt tự nhiên, ăn kèm chả cua hoặc tôm. Huyện Trảng Bom nổi tiếng với phiên bản bánh canh đặc trưng địa phương, nhiều quán lâu đờ
  Địa điểm thưởng thức: [''Các quán bánh canh sáng dọc QL1A, Trảng Bom'', ''Chợ Trảng Bom'']
- Lẩu cá lăng sông Đồng Nai: Cá lăng — loài cá nước ngọt sống tự nhiên trên sông Đồng Nai — thịt trắng dai ngọt, ít xương. Nấu lẩu chua cay với me, cà chua, thơm (dứa) và rau nhúng phong phú. Là đặc sản sông nước đặc trưng của cá
  Địa điểm thưởng thức: [''Nhà hàng ven sông Đồng Nai, Biên Hòa'', ''Khu ẩm thực ven hồ Trị An'']
- Nem Bình Xuyên: Nem chua lên men đặc sản của huyện Bình Xuyên (tên cũ), nay là khu vực Long Thành, Nhơn Trạch — được làm từ thịt heo tươi giã mịn, bọc lá vông hoặc lá chuối, lên men tự nhiên. Nem Đồng Nai có vị chua 
  Địa điểm thưởng thức: [''Chợ Biên Hòa'', ''Cửa hàng đặc sản Đồng Nai'', ''Các quán ăn khu vực Long Thành'']
- Cơm tấm Biên Hòa: Cơm tấm phong cách Biên Hòa có thêm đặc điểm riêng so với cơm tấm Sài Gòn: sườn nướng dày hơn, bì heo giòn hơn và mỡ hành thơm đặc trưng. Nhiều quán cơm tấm nổi tiếng lâu đời ở Biên Hòa phục vụ từ sán
  Địa điểm thưởng thức: [''Các quán cơm tấm dọc đường Nguyễn Văn Trị'', ''Khu ẩm thực trung tâm Biên Hòa'']', ARRAY['dong-nai', 'đồng nai', 'đồng nai', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8ad99d63-6c3d-55c4-a296-ee0f8572c81f', 'Cách di chuyển đến Đồng Nai', 'transport', '0a193ffa-e0a2-401c-8e6f-f54630558a65',
  'Di chuyển đến và trong Đồng Nai:

Cách đến:
- BUS từ TP.HCM (Bến xe Miền Đông / Bến xe An Sương): ~1–1,5 giờ đến Biên Hòa — None
  Tuyến TP.HCM – Biên Hòa chạy liên tục và thường xuyên, là tuyến đường phổ biến nhất. Ngoài ra có xe khách đi các huyện xa hơn như Tân Phú (gần Nam Cát Tiên). Xác nhận giá tại Vexere.com.
- TRAIN từ TP.HCM (Ga Sài Gòn): ~1 giờ đến Ga Biên Hòa — None
  Tàu lửa TP.HCM – Biên Hòa là tuyến tàu ngắn tiện lợi, giá rẻ. Ga Biên Hòa nằm trung tâm thành phố. Đặt vé tại dsvn.vn hoặc ứng dụng VR.
- CAR từ TP.HCM (đường cao tốc TP.HCM – Long Thành – Dầu Giây): ~45 phút đến Biên Hòa, ~2,5–3 giờ đến Nam Cát Tiên — None
  Cao tốc TP.HCM – Long Thành – Dầu Giây kết nối nhanh. Từ ngã tư Dầu Giây đi thêm ~1,5 giờ lên Nam Cát Tiên theo đường tỉnh. Phí cao tốc xác nhận tại trạm thu phí.
- BUS từ Hà Nội (xe khách giường nằm qua đêm): ~30 giờ (qua đêm) — None
  Tuyến Hà Nội – Biên Hòa qua đêm. Thực tế hầu hết du khách từ miền Bắc sẽ bay vào TP.HCM rồi đi tiếp. Xác nhận lịch tại Vexere.com.

Di chuyển trong thành phố:
- grab: Grab hoạt động đầy đủ tại TP. Biên Hòa và các thị trấn lớn. Tiện nhất cho di chuyển nội ô. Không có sẵn tại Nam Cát Tiên — cần thuê xe riêng.
- taxi: Taxi Mai Linh và Vinasun hoạt động tại Biên Hòa. Gọi qua app hoặc tổng đài. Không có ở các huyện xa như Tân Phú.
- motorbike_rental: Thuê xe máy tại Biên Hòa và gần các khu du lịch. Phù hợp tham quan Vĩnh Cửu, Trảng Bom, Long Thành. Không nên đi xe máy lên Nam Cát Tiên vì đường dài và có thể nguy hiểm ban đêm.
- car_rental: Thuê xe 4–7 chỗ có tài xế là phương án tốt nhất cho nhóm đi Nam Cát Tiên hoặc vùng Bình Phước cũ (Bù Gia Mập). Đặt qua Traveloka hoặc các hãng địa phương tại Biên Hòa.', ARRAY['dong-nai', 'đồng nai', 'đồng nai', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7f44a8a5-43a0-5c88-bcba-415014268b95', 'Khách sạn & Lưu trú tại Đồng Nai', 'hotel', '0a193ffa-e0a2-401c-8e6f-f54630558a65',
  'Lưu trú tại Đồng Nai:
- Melia Vinpearl Đồng Nai (5★): Khu đô thị Amata, Long Bình, TP. Biên Hòa, Đồng Nai
  Tiện ích: hồ bơi ngoài trời, spa, nhà hàng, phòng gym
- Merperle Crystal Palace Biên Hòa (4★): Đường Phạm Văn Thuận, TP. Biên Hòa, Đồng Nai
  Tiện ích: hồ bơi, nhà hàng, wifi miễn phí, bãi đỗ xe
- Khách sạn Đồng Nai (3★): Đường 30 Tháng 4, TP. Biên Hòa, Đồng Nai
  Tiện ích: nhà hàng, wifi miễn phí, bãi đỗ xe, máy lạnh
- Nam Cát Tiên Ecolodge (None★): Trong khuôn viên Vườn Quốc gia Nam Cát Tiên, Huyện Tân Phú, Đồng Nai
  Tiện ích: bao gồm bữa ăn (tuỳ gói), tour quan sát thú ban đêm, hướng dẫn viên sinh thái, wifi (hạn chế)
- Giang Điền Resort & Camping (None★): Khu du lịch Thác Giang Điền, Xã Giang Điền, Huyện Trảng Bom, Đồng Nai
  Tiện ích: chỗ cắm trại, khu BBQ, wifi (khu trung tâm), nhà vệ sinh công cộng', ARRAY['dong-nai', 'đồng nai', 'đồng nai', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f292134c-a550-5522-949c-05ee7f055fd8', 'Tour & Trải nghiệm tại Đồng Nai', 'tour', '0a193ffa-e0a2-401c-8e6f-f54630558a65',
  'Tour & Trải nghiệm tại Đồng Nai:
- Tour Trekking Nam Cát Tiên 2 Ngày 1 Đêm: 2 ngày 1 đêm — liên hệ
  Gói lưu trú và trekking trong Vườn Quốc gia Nam Cát Tiên: ngày 1 đi bộ rừng quan sát chim thú, tắm suối Đatanla nhỏ, chiều thăm Bàu Sấu; tối quan sát thú ban đêm bằng đèn pin. Ngày 2 thăm Đảo Tiên và về. Lưu trú tại ecolodge trong vườn.
- Tour Thác Giang Điền Ngày (từ TP.HCM): 1 ngày (~8 tiếng) — liên hệ
  Tour ngày từ TP.HCM đến khu du lịch Thác Giang Điền — gồm: tắm thác, chèo kayak, cáp treo tham quan, leo núi nhẹ và picnic. Về TP.HCM buổi tối. Phù hợp gia đình và nhóm bạn muốn dã ngoại cuối tuần gần thành phố.
- Tour Vườn Bưởi Tân Triều & Văn miếu Trấn Biên: Nửa ngày (4–5 tiếng) — liên hệ
  Tour khám phá văn hóa và đặc sản nổi tiếng của Đồng Nai: tham quan Văn miếu Trấn Biên — công trình văn hóa lớn nhất Nam Bộ — và vườn bưởi Tân Triều trứ danh. Hái bưởi tươi, thử đặc sản địa phương và mua quà về. Phù hợp cả gia đình và nhóm nhỏ.
- Tour Câu Cá & Cắm Trại Hồ Trị An: 1 ngày hoặc 2 ngày 1 đêm — liên hệ
  Trải nghiệm câu cá trên hồ Trị An — hồ nhân tạo khổng lồ bao quanh rừng. Gói bao gồm thuyền câu, dụng cụ câu, hướng dẫn viên địa phương và có thể nấu ăn bằng cá câu được ngay trên thuyền hoặc bờ hồ. Gói cắm trại qua đêm có lửa trại và BBQ.', ARRAY['dong-nai', 'đồng nai', 'đồng nai', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'dd252583-69fd-5f22-a63b-0c089cf12fae', 'Lễ hội & Sự kiện tại Đồng Nai', 'event', '0a193ffa-e0a2-401c-8e6f-f54630558a65',
  'Lễ hội & Sự kiện tại Đồng Nai:
- Lễ hội Sayangva (Cúng thần Lúa) của người Chơro: Tháng 3–4 âm lịch hằng năm (thường tháng 4–5 dương lịch)
  Lễ hội truyền thống quan trọng nhất của người Chơro — dân tộc bản địa của vùng Đông Nam Bộ sinh sống lâu đời tại Đồng Nai. Lễ cúng thần Lúa (Yang Va) gồm nghi thức dâng lễ vật, hát múa truyền thống, chơi cồng chiêng và ăn uống cộng đồng. Là dịp hiếm 
- Lễ hội trái cây Đồng Nai: Tháng 6–7 hằng năm (mùa trái cây chính)
  Lễ hội tôn vinh các loại trái cây đặc sản Đồng Nai như bưởi Tân Triều, sầu riêng Cẩm Mỹ, chôm chôm Long Khánh, măng cụt... Có các hoạt động: trưng bày giống trái cây, thi bình trái cây, ẩm thực từ trái cây và chợ nông sản giá gốc tại vườn.
- Tết Chôl Chnăm Thmây (Tết Khmer): Tháng 4 dương lịch (khoảng 13–16/4 hằng năm)
  Tết Năm Mới của người Khmer Nam Bộ — lễ hội lớn nhất trong năm của cộng đồng Khmer tại Bình Phước cũ, nay thuộc Đồng Nai sau sáp nhập 2025. Các nghi lễ tại chùa, múa Lâm Thol truyền thống, thả đèn nước và bữa tiệc cộng đồng kéo dài 3 ngày.
- Giỗ Tổ Hùng Vương tại Văn miếu Trấn Biên: Mùng 10 tháng 3 âm lịch hằng năm
  Lễ Giỗ Tổ Hùng Vương tổ chức trọng thể tại Văn miếu Trấn Biên — ngôi văn miếu lớn nhất Nam Bộ. Nghi lễ dâng hương trang nghiêm, biểu diễn múa hát truyền thống và các hoạt động văn hóa giáo dục. Thu hút đông đảo người dân và học sinh toàn tỉnh về dự.
- Mùa trekking Nam Cát Tiên (mùa khô): Tháng 12 – tháng 4 hằng năm
  Mùa khô là thời điểm lý tưởng nhất để trekking và quan sát thú ở Nam Cát Tiên: đường mòn khô ráo, động vật tập trung ra bàu uống nước dễ quan sát hơn, ít muỗi và côn trùng hơn mùa mưa. Ban quản lý VQG thường tổ chức thêm các tour đặc biệt và chương t', ARRAY['dong-nai', 'đồng nai', 'đồng nai', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e639ebc4-2397-554f-8b4d-dd358eb900a8', 'Tổng quan du lịch Đồng Tháp', 'destination', '019eee23-1730-7352-8c9a-09c5b0bed755',
  'Tổng quan Đồng Tháp (Đồng Tháp):
Tỉnh sông nước miệt vườn sau sáp nhập Đồng Tháp và Tiền Giang, nổi tiếng với Đồng Tháp Mười, vườn quốc gia Tràm Chim, làng hoa Sa Đéc và các cù lao trái cây dọc sông Tiền (Tiền Giang cũ) như Cù lao Thới Sơn, chợ nổi Cái Bè.

Mùa đẹp nhất: Tháng 12–4 (mùa khô); tháng 9–11 mùa nước nổi Đồng Tháp Mười đặc trưng
Thời tiết: Nóng ẩm 25–34°C quanh năm, mùa nước nổi tháng 9–11, mùa mưa tháng 5–11
Ẩm thực: Hủ tiếu Sa Đéc, cá lóc nướng trui, bông điên điển, chuột đồng, kẹo dừa và mắm còng (Tiền Giang cũ)
Ngân sách tham khảo: ', ARRAY['dong-thap', 'đồng tháp', 'đồng tháp', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'bb5ab936-d088-576f-8812-6a390f10ccef', 'Tổng quan du lịch Pleiku', 'destination', '019eeda8-d830-762e-8f70-18a66f56fa5c',
  'Tổng quan Pleiku (Gia Lai):
Cao nguyên núi lửa với Biển Hồ T''Nưng, đồi chè và văn hóa cồng chiêng Tây Nguyên; sau sáp nhập còn có vùng biển Bình Định với Quy Nhơn, Eo Gió, Kỳ Co.

Mùa đẹp nhất: Tháng 11–4 (mùa khô, trời mát, ít mưa)
Thời tiết: Mát mẻ quanh năm 18–28°C nhờ độ cao, mùa mưa tháng 5–10
Ẩm thực: Phở khô Gia Lai (phở hai tô), cơm lam gà nướng, măng le, cà phê Tây Nguyên
Ngân sách tham khảo: ', ARRAY['gia-lai-pleiku', 'pleiku', 'gia lai', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8350ccc9-5ded-5ac6-b0de-4a686c55bba4', 'Tổng quan du lịch Hà Nội', 'destination', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  'Tổng quan Hà Nội (Hà Nội):
Thủ đô ngàn năm văn hiến với 36 phố phường cổ, Hồ Gươm, Văn Miếu - Quốc Tử Giám, kiến trúc Pháp thuộc địa và ẩm thực đường phố phong phú bậc nhất Việt Nam.

Mùa đẹp nhất: Tháng 9–11 (thu vàng) và tháng 3–4 (hoa sưa, hoa ban)
Thời tiết: 4 mùa rõ rệt, 15–38°C, mùa đông lạnh ẩm 10–18°C (tháng 12–2), mùa hè nóng ẩm
Ẩm thực: Phở Hà Nội, bún chả, chả cá Lã Vọng, bánh cuốn, bún ốc, cà phê trứng, xôi xéo
Ngân sách tham khảo: 1,000,000–3,000,000đ/người', ARRAY['ha-noi', 'hà nội', 'hà nội', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3dc7974f-4343-540c-a172-4174d84a066f', 'Hà Nội – 🌟 Kinh Nghiệm Du Lịch Hà Nội', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 🌟 Kinh Nghiệm Du Lịch Hà Nội

> Tổng hợp tips từ kiến thức phổ biến về các địa danh nổi tiếng, dễ xác minh của Hà Nội.

---', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b6fb553c-3240-5959-80f6-9cb6e0eda6ed', 'Hà Nội – 1. Hồ Hoàn Kiếm (Hồ Gươm)', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 1. Hồ Hoàn Kiếm (Hồ Gươm)
Loại: attraction
Địa chỉ: Phố Đinh Tiên Hoàng, quận Hoàn Kiếm, Hà Nội
Giờ mở cửa: 24/7 (không gian công cộng)
Tip: Đi dạo sáng sớm 6:00–7:00 hoặc tối cuối tuần khi quanh hồ trở thành phố đi bộ.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '27d7dc62-c6ef-5a1c-89aa-622b1a783cbd', 'Hà Nội – 2. Văn Miếu - Quốc Tử Giám', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 2. Văn Miếu - Quốc Tử Giám
Loại: temple
Địa chỉ: 58 Phố Quốc Tử Giám, quận Đống Đa, Hà Nội
Giờ mở cửa: 8:00–17:00
Tip: Không chạm vào đầu rùa đá để bảo tồn di tích; nên đi cùng hướng dẫn viên để hiểu rõ lịch sử.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd63da4f2-4d01-5f06-9016-e96bedbd2219', 'Hà Nội – 3. Lăng Chủ tịch Hồ Chí Minh', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 3. Lăng Chủ tịch Hồ Chí Minh
Loại: attraction
Địa chỉ: số 8 phố Hùng Vương, quận Ba Đình, Hà Nội
Giờ mở cửa: Sáng Thứ 3–5, Thứ 7, CN; đóng Thứ 2 & Thứ 6
Tip: Trang phục lịch sự, đến sớm vì có kiểm tra an ninh và thường đông.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '9f792556-5f7d-5bf1-8b0b-6a84983411ed', 'Hà Nội – 4. Hoàng thành Thăng Long', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 4. Hoàng thành Thăng Long
Loại: museum
Địa chỉ: 19C Hoàng Diệu, quận Ba Đình, Hà Nội
Giờ mở cửa: 8:00–17:00, đóng Thứ 2
Tip: Di sản UNESCO, nên thuê audio guide để hiểu các lớp di tích khảo cổ qua nhiều triều đại.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd1e62e55-7bf1-5dcf-a7da-dcf3a9cc1024', 'Hà Nội – 5. Phố cổ Hà Nội & phố ăn đêm Tạ Hiện', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 5. Phố cổ Hà Nội & phố ăn đêm Tạ Hiện
Loại: attraction
Địa chỉ: Khu Hàng Bạc, Hàng Gai, Tạ Hiện, quận Hoàn Kiếm
Giờ mở cửa: Cả ngày, sôi động nhất buổi tối
Tip: Tạ Hiện về đêm đông đúc, cẩn thận giữ đồ cá nhân khi ngồi vỉa hè.

---', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '4e42c533-06b2-5f0f-b9a8-37e6bf640212', 'Hà Nội – 🎒 Lịch Trình Gợi Ý', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 🎒 Lịch Trình Gợi Ý

> Lịch trình đầy đủ (giờ giấc, chi phí từng mục, tham chiếu địa điểm cụ thể) đã được cấu trúc hóa
> trong  — xem chi tiết tại đó để tránh lệch dữ liệu giữa 2 file.
// solo, cặp đôi, gia đình, bạn bè', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a5a0bc4f-1cef-595c-a77b-5f4769a7c163', 'Hà Nội – 2 Ngày 1 Đêm — Cặp đôi', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 2 Ngày 1 Đêm — Cặp đôi
Xem đầy đủ tại  → id: 

Ngày 1: Lăng Bác – Chùa Một Cột → Bún chả Hương Liên → Văn Miếu → Phố cổ/Tạ Hiện buổi tối
Ngày 2: Hồ Gươm sáng sớm → Cà phê trứng → Hồ Tây thư thái buổi chiều', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'efc47ac5-66cb-5868-8507-d58a361e98ba', 'Hà Nội – 3 Ngày 2 Đêm — Gia đình', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 3 Ngày 2 Đêm — Gia đình
Xem đầy đủ tại  → id: 

Ngày 1: Nhận phòng → Bảo tàng Dân tộc học → Ăn tối phở
Ngày 2: Hoàng thành Thăng Long → Hồ Gươm chiều, cho trẻ chơi phố đi bộ
Ngày 3: Mua quà chợ Đồng Xuân → Ra sân bay/ga tàu

---', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8bb71a7a-091a-5d9d-b582-d45097c6a9b1', 'Hà Nội – 🚨 Kinh Nghiệm An Toàn', 'safety', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 🚨 Kinh Nghiệm An Toàn

- ⚠️ Móc túi/giật đồ ở nơi đông người: Khu chợ Đồng Xuân, phố đi bộ cuối tuần — nên đeo túi
  trước người, không để điện thoại hớ hênh.
- ⚠️ Chốt giá trước khi đi xe không qua app: Xe ôm/taxi truyền thống ở khu du lịch đông khách
  đôi khi báo giá cao hơn bình thường nếu không thỏa thuận trước.
- ⚠️ Giao thông đông xe máy: Qua đường nên đi chậm, dứt khoát, quan sát kỹ — đặc biệt với
  khách lần đầu đến Việt Nam chưa quen giao thông xe máy đông đúc.

---', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd71dbe7b-30f5-5393-bc48-f07841a75f5e', 'Hà Nội – 💡 Tips Thực Tế', 'tip', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## 💡 Tips Thực Tế

- 💰 Tiết kiệm: Ăn ở quán ăn đường phố/phố cổ thường rẻ và ngon hơn nhà hàng lớn; đi bộ/Grab
  thay taxi truyền thống nếu muốn tiết kiệm và tránh bị "chặt chém".
- 🧥 Mùa đông (T12–2): Hà Nội có thể lạnh hơn dự kiến với khách miền Nam, nên mang áo khoác.
- 🕐 Giờ giấc: Một số di tích (Lăng Bác, Hoàng thành Thăng Long) có ngày đóng cửa cố định
  (Thứ 2 và/hoặc Thứ 6) — kiểm tra lịch trước khi lên kế hoạch để tránh đến nơi mà không vào được.
- 🛍️ Trả giá khi mua sắm: Ở chợ truyền thống (Đồng Xuân, phố Hàng Gai) nên trả giá, khác với
  trung tâm thương mại có giá niêm yết cố định.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '1d894ffd-7b19-5793-8201-4c762d96f5de', 'FAQ Du lịch Hà Nội (1)', 'faq', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  '## ❓ FAQ Du Lịch Hà Nội

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm đẹp nhất để đến Hà Nội là khi nào?
A: Tháng 9–11 (mùa thu, mát mẻ, trời trong) và tháng 3–4 (mùa xuân, hoa sưa, hoa ban) là hai khoảng
thời gian đẹp nhất. Tránh tháng 6–8 vì nóng ẩm gay gắt.

Q: Hà Nội có mấy mùa? Mùa mưa kéo dài bao lâu?
A: Hà Nội có 4 mùa rõ rệt. Mùa hè (tháng 5–8) nóng ẩm 28–37°C kèm mưa rào; mùa đông (tháng 12–2)
lạnh khô 10–18°C, đôi khi có rét đậm.

---

## 💰 Chi phí & Ngân sách

Q: Chi phí đi Hà Nội 2 ngày 1 đêm hết bao nhiêu?
A: Theo lịch trình mẫu ( — ), ước tính khoảng 1.500.000–
3.000.000đ/người bao gồm di chuyển, ăn uống, vé tham quan — chưa gồm khách sạn. Đây là số ước
tính, có thể thay đổi theo thực tế.

Q: Có cần đặt phòng trước không?
A: Nên đặt trước, đặc biệt vào mùa cao điểm (lễ Tết, mùa thu) hoặc nếu muốn ở khu phố cổ gần Hồ
Gươm vì khu này thường kín phòng sớm.

---

## 🚗 Di chuyển

Q: Từ TP.HCM / các tỉnh khác đến Hà Nội bằng phương tiện gì?
A: Phổ biến nhất là máy bay (~2 giờ từ TP.HCM, sân bay Nội Bài). Ngoài ra có thể đi tàu hoặc xe
khách đường dài tùy điểm xuất phát — xem chi tiết trong .

Q: Di chuyển trong Hà Nội bằng gì?
A: Grab/taxi phổ biến nhất và tiện cho người mới đến; khu phố cổ và quanh Hồ Gươm rất phù hợp đi
bộ; xe buýt công cộng rẻ nhưng cần biết tuyến trước.

---

## 🏨 Lưu trú

Q: Nên ở khu vực nào tại Hà Nội?
A: Khu phố cổ (quận Hoàn Kiếm, quanh Hồ Gươm) tiện di chuyển bộ đến hầu hết điểm tham quan trung
tâm và sôi động về đêm. Khu Ba Đình/Tây Hồ yên tĩnh hơn, phù hợp nếu muốn nghỉ ngơi thoải mái.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f634bbdd-41b3-56cf-b1e7-cb3191a3438e', 'FAQ Du lịch Hà Nội (2)', 'faq', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  'Q: Các loại hình lưu trú phổ biến tại Hà Nội?
A: Từ khách sạn 5 sao (Sofitel Legend Metropole, Lotte Hotel), khách sạn boutique phố cổ, đến
hostel/homestay giá rẻ cho khách backpacker — xem chi tiết và mức giá ước tính trong .

---

## 🍜 Ẩm thực

Q: Đặc sản nổi tiếng nhất của Hà Nội là gì?
A: Phở, bún chả, chả cá Lã Vọng, cà phê trứng là những món đặc trưng nhất — chi tiết quán gợi ý
trong  và .

Q: Nên ăn ở đâu tại Hà Nội?
A: Khu phố cổ tập trung nhiều quán ăn lâu đời (Phở Thìn Lò Đúc, Bún Chả Hương Liên, Chả Cá Lã
Vọng); phố Tạ Hiện sôi động về đêm với đồ ăn vặt và bia hơi.

---

## ⚠️ An toàn & Lưu ý

Q: Có lưu ý gì về an toàn khi đến Hà Nội?
A: Cẩn thận móc túi/giật đồ ở khu vực đông người (chợ, phố đi bộ cuối tuần); chốt giá trước khi đi
xe ôm/taxi không qua app; giao thông đông và nhiều xe máy nên cẩn trọng khi qua đường.

Q: Cần chuẩn bị gì trước khi đến Hà Nội?
A: Mang giày thoải mái vì sẽ đi bộ nhiều ở phố cổ; chuẩn bị áo khoác nếu đi mùa đông (tháng 12–2)
vì có thể lạnh hơn dự kiến với khách từ miền Nam.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6c24a2e5-ecde-50f3-945f-a8a5c3e4a801', 'Ẩm thực đặc sản Hà Nội', 'food', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  'Đặc sản ẩm thực Hà Nội:
- Phở Hà Nội: Món nước với bánh phở, nước dùng ninh xương trong nhiều giờ, ăn cùng thịt bò hoặc gà.
  Địa điểm thưởng thức: [''Phở Thìn Lò Đúc'', ''Phở Bát Đàn'', ''Phở Gia Truyền'']
  Giá tham khảo: 35.000–60.000đ
- Bún chả: Chả thịt nướng than ăn cùng bún, nước mắm chua ngọt và rau sống.
  Địa điểm thưởng thức: [''Bún Chả Hương Liên'', ''Bún chả Đắc Kim'']
  Giá tham khảo: 40.000–80.000đ
- Chả cá Lã Vọng: Cá lăng/cá quả nướng trên than, ăn kèm bún, thì là, lạc rang, mắm tôm.
  Địa điểm thưởng thức: [''Chả Cá Lã Vọng'']
  Giá tham khảo: 100.000–200.000đ
- Cà phê trứng: Cà phê đánh cùng lòng đỏ trứng và sữa tạo lớp kem béo phía trên.
  Địa điểm thưởng thức: [''Cà phê Giảng'', ''Cà phê Đinh'']
  Giá tham khảo: 25.000–40.000đ
- Bánh cuốn Thanh Trì: Bánh bột gạo tráng mỏng, nhân thịt mộc nhĩ, ăn cùng nước mắm và chả lụa.
  Địa điểm thưởng thức: [''Bánh cuốn Bà Hoành'', ''Khu Thanh Trì'']
  Giá tham khảo: 30.000–50.000đ
- Nem chua rán: Nem chua chiên giòn, ăn kèm tương ớt/mù tạt, món ăn vặt phổ biến phố cổ về đêm.
  Địa điểm thưởng thức: [''Phố Tạ Hiện'', ''Hàng đêm các quán nhậu vỉa hè'']
  Giá tham khảo: 20.000–40.000đ', ARRAY['ha-noi', 'hà nội', 'hà nội', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7a1ea27e-5b52-560c-acfb-8e93bb27e4a2', 'Cách di chuyển đến Hà Nội', 'transport', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  'Di chuyển đến và trong Hà Nội:

Cách đến:
- AIRPLANE từ TP.HCM, Đà Nẵng, các tỉnh trong nước: ~2 giờ (từ TP.HCM) — 1.000.000–2.500.000đ (khứ hồi, ước tính)
  Sân bay quốc tế Nội Bài (HAN), cách trung tâm ~30km.
- TRAIN từ Các tỉnh phía Bắc, Bắc Trung Bộ: Tùy tuyến (vd Hà Nội–Lào Cai ~8 giờ) — 150.000–800.000đ tùy tuyến/loại ghế (ước tính)
  Ga Hà Nội (ga Hàng Cỏ) là đầu mối chính.
- BUS từ Các tỉnh thành trên cả nước: Tùy khoảng cách — 100.000–500.000đ (ước tính)
  Các bến chính: Mỹ Đình, Giáp Bát, Nước Ngầm.

Di chuyển trong thành phố:
- grab: Phổ biến nhất, đặt qua app.
- taxi: Taxi truyền thống (Mai Linh, G7...) hoặc gọi qua app.
- xe_om: Nên chốt giá trước khi đi nếu không qua app.
- bus: Mạng lưới xe buýt công cộng rộng, giá rẻ nhưng cần biết tuyến.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '9b6fdab6-b3e0-5e4d-9937-675faf36be5c', 'Khách sạn & Lưu trú tại Hà Nội', 'hotel', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  'Lưu trú tại Hà Nội:
- Sofitel Legend Metropole Hanoi (5★): 15 Phố Ngô Quyền, quận Hoàn Kiếm, Hà Nội
  Tiện ích: Hồ bơi, Spa, Nhà hàng Pháp, Gym
- Lotte Hotel Hanoi (5★): 54 Liễu Giai, quận Ba Đình, Hà Nội
  Tiện ích: Hồ bơi trong nhà, Spa, Đài quan sát, Gym
- Hanoi La Siesta Hotel & Spa (Phố cổ) (4★): Phố Mã Mây, quận Hoàn Kiếm, Hà Nội
  Tiện ích: Spa, Nhà hàng tầng thượng, Wifi miễn phí, Đưa đón sân bay (phụ phí)
- Hanoi Backpackers Hostel (None★): Khu vực phố cổ, quận Hoàn Kiếm, Hà Nội
  Tiện ích: Phòng dorm có máy lạnh, Khu sinh hoạt chung, Wifi miễn phí, Tour ghép đoàn
- Hanoi Old Quarter Homestay (None★): Gần phố Hàng Bạc, quận Hoàn Kiếm, Hà Nội
  Tiện ích: Bếp chung, Wifi miễn phí, Chủ nhà hỗ trợ tư vấn lịch trình', ARRAY['ha-noi', 'hà nội', 'hà nội', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6b7919c5-a9b5-586b-922a-d9c630defa38', 'Tour & Trải nghiệm tại Hà Nội', 'tour', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  'Tour & Trải nghiệm tại Hà Nội:
- Tour phố cổ Hà Nội bằng xích lô + ẩm thực đêm: Nửa ngày (buổi tối, ~3 giờ) — 450,000đ/người
  Tham quan phố cổ bằng xích lô, dừng chân tại các điểm ăn vặt nổi tiếng (cà phê trứng, nem chua rán, bún chả).
- Tour ngày: Hoàng thành Thăng Long + Văn Miếu + Lăng Bác: 1 ngày — 600,000đ/người
  Khám phá các di tích lịch sử trung tâm Hà Nội cùng hướng dẫn viên thuyết minh.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '4d0c35d6-cfb9-546d-81d8-22b8845e4e0f', 'Lễ hội & Sự kiện tại Hà Nội', 'event', '019eed69-50b1-7455-bdfa-2e98ab743e96',
  'Lễ hội & Sự kiện tại Hà Nội:
- Tết Nguyên Đán tại Hà Nội: Tháng 1 hoặc 2 (theo lịch âm)
  Lễ hội lớn nhất trong năm, phố cổ trang trí rực rỡ, chợ hoa Hàng Lược nhộn nhịp những ngày cận Tết.
- Lễ hội Gò Đống Đa: Mùng 5 Tết (lịch âm)
  Lễ hội tưởng nhớ chiến thắng Ngọc Hồi - Đống Đa của vua Quang Trung, có múa rồng, tái hiện lịch sử.
- Trung Thu phố cổ Hà Nội: Tháng 8 (rằm tháng 8 âm lịch)
  Phố Hàng Mã rực rỡ đèn lồng, mặt nạ, đồ chơi Trung Thu truyền thống, đông đúc về tối.', ARRAY['ha-noi', 'hà nội', 'hà nội', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3fb3cf3e-2f95-59ee-8259-b1fa75c20ee1', 'Tổng quan du lịch Thiên Cầm', 'destination', '019eed69-50b3-774a-83ca-b8e9b4965dcb',
  'Tổng quan Thiên Cầm (Hà Tĩnh):
Bãi biển Thiên Cầm ẩn mình dưới chân núi với nước biển xanh trong, cát vàng mịn, bãi đá san hô tự nhiên, không khí yên bình và hải sản tươi ngon ít bị thương mại hóa.

Mùa đẹp nhất: Tháng 4–8 (nắng đẹp, ít gió)
Thời tiết: Nóng 28–36°C mùa hè, gió Lào khô tháng 6–7, mưa bão tháng 8–10
Ẩm thực: Cá rô sông La, hàu Thiên Cầm, mực ống nướng, bún bò Hà Tĩnh, cháo hàu, cam bù Hương Khê
Ngân sách tham khảo: 600,000–1,800,000đ/người', ARRAY['ha-tinh-thien-cam', 'thiên cầm', 'hà tĩnh', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ddaa5697-2b91-537f-8b3c-936aafb95ffb', 'Tổng quan du lịch Cát Bà', 'destination', '019eed69-50b3-7d7e-876d-39fc6f6a1674',
  'Tổng quan Cát Bà (Hải Phòng):
Đảo lớn nhất vịnh Hạ Long với vườn quốc gia nguyên sinh, bãi biển Cát Cò trong xanh, làng chài bè cá nổi và cửa ngõ khám phá quần thể Hạ Long - Bái Tử Long hùng vĩ.

Mùa đẹp nhất: Tháng 4–9 (biển đẹp, tắm được)
Thời tiết: Ấm nóng 20–32°C, mùa hè đẹp, mưa bão tháng 7–9, đông lạnh sương mù
Ẩm thực: Cá hấp gừng Cát Bà, hải sản tươi sống, sam biển rang muối, cua biển hấp bia, bề bề nướng
Ngân sách tham khảo: 1,500,000–4,000,000đ/người', ARRAY['hai-phong-cat-ba', 'cát bà', 'hải phòng', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '9ff3212d-e376-531a-a922-9880f094c626', 'Tổng quan du lịch Huế', 'destination', '019eed69-50b3-73da-a651-2515b15db7c2',
  'Tổng quan Huế (Huế):
Cố đô triều Nguyễn với Hoàng thành Huế — Di sản Văn hóa Thế giới UNESCO, hệ thống lăng tẩm, chùa chiền, ẩm thực cung đình tinh tế và dòng sông Hương thơ mộng.

Mùa đẹp nhất: Tháng 1–4 và tháng 8–9 (tránh mùa mưa tháng 10–12)
Thời tiết: Nhiệt đới gió mùa, 20–35°C, mưa nhiều tháng 10–12, nóng nhất tháng 6–8
Ẩm thực: Bún bò Huế, cơm hến, bánh khoái, nem lụi, bánh bèo, chè Huế đa dạng, bánh ướt thịt nướng
Ngân sách tham khảo: 1,200,000–3,500,000đ/người', ARRAY['hue', 'huế', 'huế', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b5c01151-8cf9-5c3a-9533-212e92aeb1e3', 'Tổng quan du lịch Hưng Yên', 'destination', '019eed69-50b3-7d56-b86a-8abd90d35197',
  'Tổng quan Hưng Yên (Hưng Yên):
Xứ nhãn lồng nổi tiếng với phố Hiến — một trong tứ đại đô thị cổ Việt Nam, hệ thống đền chùa cổ kính và đặc sản nhãn lồng Hưng Yên ngọt thơm bậc nhất cả nước.

Mùa đẹp nhất: Tháng 7–8 (mùa nhãn chín) và tháng 9–11 (khí hậu mát)
Thời tiết: 4 mùa rõ rệt, 17–36°C, nóng ẩm mùa hè, lạnh khô mùa đông
Ẩm thực: Nhãn lồng Hưng Yên, bánh cuốn chả, tương bần, cá kho làng Vũ Dương, bánh gai, con don
Ngân sách tham khảo: 500,000–1,500,000đ/người', ARRAY['hung-yen', 'hưng yên', 'hưng yên', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '2fb168be-aef7-5f70-bb05-0dfaa82e84e6', 'Tổng quan du lịch Nha Trang', 'destination', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Tổng quan Nha Trang (Khánh Hòa):
Thành phố biển sầm uất với 6km bãi biển cát trắng trải dài, hải sản phong phú, đảo san hô đa dạng và khu nghỉ dưỡng quốc tế — thủ đô biển đảo của Việt Nam.

Mùa đẹp nhất: Tháng 1–8 (nắng đẹp, biển lặng)
Thời tiết: Nắng nóng 25–34°C, mùa mưa tháng 9–12 có bão, biển động
Ẩm thực: Bún cá Nha Trang, nem nướng Ninh Hòa, hải sản tươi sống, bánh căn, yến sào Khánh Hòa
Ngân sách tham khảo: 2,000,000–6,000,000đ/người', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '83ddd2db-d864-56d6-9d90-82ccfaad4300', 'Nha Trang – 🌟 Kinh Nghiệm Du Lịch Nha Trang', 'tip', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 🌟 Kinh Nghiệm Du Lịch Nha Trang

Nha Trang — "thủ đô biển đảo" của Việt Nam — hấp dẫn bởi sự kết hợp hiếm có: bãi biển cát trắng dài 6km ngay trung tâm thành phố, hệ san hô đa dạng, văn hóa Chăm Pa nghìn năm và ẩm thực hải sản phong phú. Đây không chỉ là điểm đến nghỉ dưỡng mà còn là cửa ngõ khám phá vùng biển Khánh Hòa rộng lớn sau khi sáp nhập với Ninh Thuận.

---', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a6977cec-0865-5cff-b39d-3051f8af5e24', 'Nha Trang – 1. Bãi Biển Nha Trang', 'tip', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 1. Bãi Biển Nha Trang
Loại: beach  
Khu vực: Dọc đường Trần Phú, trung tâm thành phố  
Giờ mở cửa: 24/7 — khu công cộng  
Giá vé: Miễn phí  
Tip: Xuống biển lúc 5:30–6:30 sáng để chụp ảnh bình minh và bơi khi biển yên tĩnh nhất. Buổi chiều từ 16:00 nước trong hơn và nắng dịu. Tránh giờ trưa 11:00–14:00 vì nắng gắt, tia UV cao.

*(Tọa độ, địa chỉ chi tiết: xem destinations.json)*', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5fb4c471-d861-5f3b-9166-e92f7091e7d7', 'Nha Trang – 2. Tháp Bà Ponagar', 'activity', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 2. Tháp Bà Ponagar
Loại: Đền thờ Chăm Pa — di tích quốc gia  
Khu vực: Phường Vĩnh Phước, bờ sông Cái, cách trung tâm ~2km về phía Bắc  
Giờ mở cửa: Thường 6:00–18:00 *(xác nhận trước khi đến)*  
Giá vé: ~30.000đ/người *(xác nhận tại điểm đến — có thể thay đổi)*  
Tip: Đến đây trước khi đi tour đảo — lịch trình sáng sớm rất hợp. Mặc quần dài hoặc váy kín khi vào khu thờ tự. Nếu đến đúng lễ hội Tháp Bà (tháng 3 âm lịch) sẽ được chứng kiến nghi lễ tắm tượng và múa Chăm — trải nghiệm độc đáo khó tìm ở nơi khác.

*(Chi tiết vị trí và lịch sử: xem destinations.json)*', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5f180321-6709-587e-9f95-b08788521cc2', 'Nha Trang – 3. Vinpearl Land Nha Trang', 'safety', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 3. Vinpearl Land Nha Trang
Loại: Khu vui chơi giải trí — đảo Hòn Tre  
Khu vực: Đảo Hòn Tre (di chuyển bằng cáp treo hoặc tàu cao tốc từ cảng Vinpearl)  
Giờ mở cửa: Thường 8:00–21:00 *(xác nhận tại vinpearl.com)*  
Giá vé: Cần kiểm tra tại vinpearl.com — giá thay đổi theo gói combo và mùa  
Tip: Không nên mua vé lẻ từng dịch vụ — gói combo tất cả luôn rẻ hơn đáng kể. Đặt online trước qua Klook hoặc vinpearl.com thường được giảm giá so với mua tại cổng. Đến trước 9:00 để tránh hàng chờ cáp treo.

*(Chi tiết địa chỉ và lưu ý: xem destinations.json)*', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e6796b77-373a-5447-84c5-0be93d0fb390', 'Nha Trang – 4. I-Resort — Tắm Bùn Khoáng Thiên Nhiên', 'tip', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 4. I-Resort — Tắm Bùn Khoáng Thiên Nhiên
Loại: Khu nghỉ dưỡng khoáng nóng  
Khu vực: Phường Vĩnh Ngọc, phía Bắc thành phố  
Giờ mở cửa: Thường 7:00–19:00 *(xác nhận tại i-resort.vn)*  
Giá vé: Theo gói dịch vụ — xem tại i-resort.vn  
Tip: Tắm bùn khoáng hiệu quả nhất khi ở trong bùn 15–20 phút rồi tắm lại bằng nước ngọt. Gói combo bùn + ngâm suối khoáng + buffet trưa là phổ biến nhất và tiết kiệm nhất. Cuối tuần và dịp lễ cần đặt trước vì số bể bùn có giới hạn.', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e9cd523d-7e6a-5a15-9525-a3ecdf1b340a', 'Nha Trang – 5. Hòn Mun — San Hô Quốc Gia', 'activity', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 5. Hòn Mun — San Hô Quốc Gia
Loại: Khu bảo tồn biển  
Khu vực: Đảo Hòn Mun — tham quan qua tour đảo 4 hòn  
Giờ mở cửa: Theo lịch tour (thường 8:00–16:00)  
Giá vé: *(xem tours.json — bao gồm trong giá tour đảo)*  
Tip: Đây là vùng bảo tồn biển — không bẻ san hô, không chạm vào sinh vật biển. Mang kem chống nắng thân thiện với san hô (không chứa oxybenzone). Lặn snorkel gần bề mặt là đủ để ngắm san hô — không cần bằng lặn.

---', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7cab28ac-3b38-5c7a-bcee-a7f8a58d6683', 'Nha Trang – 3 Ngày 2 Đêm — Cặp Đôi Biển Đảo', 'activity', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 3 Ngày 2 Đêm — Cặp Đôi Biển Đảo
> Chi tiết →  id: 

- Ngày 1: Đến — nhận phòng — tắm biển chiều — hải sản Phạm Văn Đồng tối
- Ngày 2: Tour 4 Đảo cả ngày (snorkel Hòn Mun, tham quan đảo) — chợ đêm tối
- Ngày 3: Tháp Bà Ponagar sáng sớm — tắm bùn I-Resort — mua đặc sản Chợ Đầm', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c38ae2e2-7d1b-5684-83ea-898876133128', 'Nha Trang – 2 Ngày 1 Đêm — Cuối Tuần Nhóm Bạn', 'tip', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 2 Ngày 1 Đêm — Cuối Tuần Nhóm Bạn
> Chi tiết →  id: 

- Ngày 1: Tour 4 Đảo sáng — tắm biển chiều — ăn hải sản và chợ đêm tối
- Ngày 2: Bún cá sáng Chợ Đầm — Tháp Bà Ponagar — mua quà rồi về

---', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'da555bb6-f896-544d-b0b4-971dde4876bb', 'Nha Trang – 🚨 Kinh Nghiệm An Toàn', 'safety', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 🚨 Kinh Nghiệm An Toàn

Biển và đảo:
- Không bơi ra xa khi biển động — tháng 9–12 có dòng chảy ngầm nguy hiểm.
- Luôn mặc áo phao khi trên tàu ra đảo, kể cả khi trời lặng.
- Không uống rượu bia trước khi xuống nước lặn hoặc bơi.
- Nếu cảm thấy mệt hoặc bị say sóng — báo ngay hướng dẫn viên tour.

Mua hải sản và dịch vụ:
- Hỏi giá và thống nhất rõ trước khi gọi hải sản tính theo cân — một số quán tính giá cao cho khách không hỏi trước.
- Đặt tour đảo qua công ty lữ hành có giấy phép hoặc nền tảng uy tín như Klook — tránh mua tour từ người lạ tiếp cận trên phố hoặc bến cảng.
- Tour đảo bị hủy do thời tiết là quyền của công ty tour — nên có kế hoạch dự phòng nếu đi trong mùa mưa.

---', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8e5ece2d-fa88-56bd-b43b-1cb823c2799f', 'Nha Trang – 💡 Tips Thực Tế', 'activity', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 💡 Tips Thực Tế

Thời điểm và thời tiết:
- Tháng 1–4 là "mùa vàng" ít đông, biển đẹp, giá hợp lý — lý tưởng cho người không thích đám đông.
- Tháng 6–8 đông và nóng nhất nhưng biển lặng nhất — tốt nhất cho tour đảo.
- Luôn kiểm tra dự báo thời tiết sát ngày nếu đi vào tháng 9–11.

Di chuyển và logistics:
- Sân bay Cam Ranh cách trung tâm 30km — tính thêm thời gian di chuyển vào lịch trình.
- Grab hoạt động tốt trong thành phố. Ra ngoại ô hoặc đến Cam Ranh nên dùng taxi hãng có đồng hồ.
- Thuê xe máy phù hợp nếu muốn tự do — nhớ mang theo bằng lái và kiểm tra kỹ xe trước khi thuê.

Ăn uống:
- Chợ Đầm là nơi người địa phương ăn sáng — rẻ, ngon, không "du lịch" — cố đến trước 8:00.
- Khu Phạm Văn Đồng nhiều nhà hàng cạnh tranh — so sánh giá 2–3 quán trước khi vào.
- Yến sào mua tại cửa hàng chính thức Công ty Yến Sào Khánh Hòa để đảm bảo chính hãng.

Mua sắm và quà:
- Hải sản khô (tôm khô, mực khô) mua ở đường Nguyễn Thiện Thuật hoặc Chợ Đầm — yêu cầu đóng gói chân không nếu mang lên máy bay.
- Nước mắm Nha Trang là đặc sản tốt — chọn loại có độ đạm cao (từ 40°N trở lên) và thương hiệu địa phương.

---', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '46b98382-43c9-5840-9296-a74fdcfd347b', 'Nha Trang – 🛒 Mua Sắm & Đặc Sản Mang Về', 'safety', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

| Đặc sản | Nơi mua tốt nhất | Lưu ý |
|---|---|---|
| Yến sào Khánh Hòa | Cửa hàng chính thức Công ty Yến Sào Khánh Hòa | Chỉ mua nơi có tem kiểm định, tránh hàng giả |
| Tôm khô, mực khô | Đường Nguyễn Thiện Thuật, Chợ Đầm | Yêu cầu đóng gói chân không khi mang máy bay |
| Nước mắm Nha Trang | Chợ Đầm, các cửa hàng đặc sản | Chọn độ đạm ≥40°N, đóng chai kỹ |
| Rong biển, hải sản khô | Chợ Đầm, đường Nguyễn Thiện Thuật | Mua nhiều được giảm giá — trả giá bình thường |
| Đồ lưu niệm biển (vỏ sò, tượng Chăm) | Chợ đêm Nha Trang | Mặc cả 20–30% so với giá chào |

*(Danh sách địa điểm mua sắm đầy đủ và giờ mở cửa: xem shopping.json)*', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '17e7c1f1-dcd1-5025-b037-488e23f399f5', 'FAQ Du lịch Nha Trang (1)', 'faq', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  '## ❓ FAQ Du Lịch Nha Trang

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm nào đẹp nhất để đi Nha Trang?
A: Mùa đẹp nhất là từ tháng 1 đến tháng 8, khi trời nắng ráo, biển lặng và trong xanh.
Tháng 6–8 là cao điểm hè, đông khách nhất nhưng thời tiết rất tốt để tắm biển và đi tour đảo.
Tháng 1–4 ít đông hơn, giá dễ chịu hơn, khí hậu mát mẻ — phù hợp nếu không thích đám đông.
*(Nguồn: Vietnam Tourism / Sở Du lịch Khánh Hòa)*

Q: Tháng 9–12 có nên đi Nha Trang không?
A: Đây là mùa mưa và bão tại Nha Trang — biển thường động, nhiều tour đảo bị hủy hoặc hoãn.
Nếu chuyến đi không thể thay đổi, nên kiểm tra dự báo thời tiết sát ngày và chuẩn bị kế hoạch dự phòng.
Đặc biệt tháng 10–11 có khả năng bão cao — xác nhận lại tại weather.gov.vn hoặc nchmf.gov.vn trước khi đi.

Q: Nha Trang có thể đi du lịch vào mùa đông (Tết) không?
A: Có — Nha Trang là điểm đến lý tưởng dịp Tết Nguyên Đán vì miền Trung có nắng ấm khi miền Bắc rét lạnh.
Tuy nhiên đây là thời điểm đông khách nhất trong năm — khách sạn và tour đảo cần đặt trước ít nhất 1–2 tháng.
Giá phòng và vé máy bay thường tăng đáng kể trong dịp Tết.

## 💰 Chi phí & Ngân sách

Q: Đi Nha Trang 3 ngày 2 đêm tốn khoảng bao nhiêu tiền?
A: Phụ thuộc nhiều vào loại hình lưu trú và cách di chuyển đến Nha Trang. Theo ước tính chung:
- Budget (tiết kiệm): ~1,5–2,5 triệu/người (hostel/homestay, ăn chợ, đi xe máy thuê)
- Tầm trung: ~2,5–4 triệu/người (khách sạn 3 sao, ăn nhà hàng bình dân, tour đảo)
- Cao cấp: 5 triệu+/người (resort 4–5 sao, hải sản cao cấp, dịch vụ riêng)
*(Chưa bao gồm vé máy bay/tàu/xe từ nơi khởi hành)*
Chi tiết giá các dịch vụ cụ thể: *(xem hotels.json và tours.json)*', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e5cd0949-6d04-50fa-a1f9-fa5825bad1c4', 'FAQ Du lịch Nha Trang (2)', 'faq', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Q: Giá hải sản tươi sống ở Nha Trang có đắt không?
A: Nha Trang có lợi thế là thành phố biển nên hải sản tươi và đa dạng hơn TP.HCM hay Hà Nội.
Tuy nhiên giá hải sản tính theo cân và thay đổi theo loài và mùa — nên hỏi giá cụ thể từng con trước khi đồng ý.
Khu vực Phạm Văn Đồng có nhiều lựa chọn, cạnh tranh giá. Tránh nhà hàng view biển đẹp nhưng giá thường cao hơn 30–50%.

## 🚗 Di chuyển

Q: Từ TP. Hồ Chí Minh đi Nha Trang bằng phương tiện gì?
A: Có 3 lựa chọn chính:
- Máy bay: ~1 giờ 10 phút — nhanh nhất, nhiều chuyến/ngày từ Vietnam Airlines, Vietjet, Bamboo.
- Tàu hỏa: ~6–8 giờ — phong cảnh đẹp, có ghế nằm điều hòa, đặt tại dsvn.vn.
- Xe khách giường nằm: ~10–12 giờ (ban đêm) — tiết kiệm nhất, nhiều hãng uy tín như Phương Trang.
*(Giá vé cụ thể: xem transport.json — cần xác nhận tại Traveloka hoặc website hãng vì thay đổi theo mùa)*

Q: Sân bay Cam Ranh cách trung tâm Nha Trang bao xa?
A: Khoảng 30km, mất khoảng 30–45 phút tùy phương tiện và giờ cao điểm.
Các lựa chọn từ sân bay vào trung tâm: xe bus sân bay (rẻ nhất, ~50.000–60.000đ, xác nhận giá tại nhà xe), taxi Mai Linh/Vinasun, hoặc Grab (thuận tiện nhất, đặt qua app).
Một số khách sạn có dịch vụ đưa đón sân bay — hỏi trước khi đặt phòng.

Q: Đi lại trong Nha Trang bằng gì thuận tiện nhất?
A: Grab (GrabCar và GrabBike) là lựa chọn thuận tiện nhất cho hầu hết du khách — có sẵn app, không cần thỏa thuận giá.
Thuê xe máy (~100.000–180.000đ/ngày — xác nhận tại cửa hàng thuê) phù hợp nếu muốn tự do khám phá ngoại ô và các làng chài.
*(Chi tiết các phương tiện và giá ước tính: xem transport.json)*

## 🏨 Lưu trú', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '69577704-70ce-5abd-85f8-cdf66ad7ab0c', 'FAQ Du lịch Nha Trang (3)', 'faq', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Q: Nên ở khu vực nào tại Nha Trang?
A: Đường Trần Phú (sát biển) là khu vực đắc địa nhất — đi bộ ra biển ngay, gần nhà hàng và điểm vui chơi nhưng giá phòng cao hơn.
Khu vực trung tâm (gần Chợ Đầm, đường Nguyễn Thiện Thuật) — giá bình dân hơn, đi Grab đến biển ~5 phút, nhiều quán ăn địa phương.
Bãi Dài / Cam Ranh — phù hợp resort cao cấp muốn yên tĩnh, nhưng xa trung tâm thành phố.
*(Danh sách khách sạn theo từng phân khúc: xem hotels.json)*

## 🍜 Ẩm thực

Q: Không thể bỏ qua món gì khi đến Nha Trang?
A: 3 món nhất định phải thử:
1. Bún cá Nha Trang — nước dùng cá trong vắt, thanh ngọt, ăn kèm chả cá chiên. Phổ biến nhất bữa sáng tại Chợ Đầm.
2. Nem nướng Ninh Hòa — đặc sản nướng cuốn bánh đa, chấm mắm ngọt.
3. Yến sào Khánh Hòa — nếu muốn mang quà về, đây là đặc sản cao cấp số 1 vùng.
Ngoài ra đừng bỏ qua hải sản tươi sống và bánh căn ăn vặt buổi chiều.
*(Chi tiết và nơi ăn: xem foods.json và restaurants.json)*

## ⚠️ An toàn & Lưu ý

Q: Đi tour đảo Nha Trang có an toàn không? Cần lưu ý gì?
A: Tour đảo nhìn chung an toàn nếu chọn công ty tour có phép hoạt động.
Một số lưu ý thực tế:
- Tránh đi tour đảo vào tháng 9–12 khi biển động — nhiều tour bị hủy hoặc chất lượng kém.
- Không uống rượu bia trước khi xuống nước lặn.
- Mặc áo phao khi trên tàu — bắt buộc theo quy định.
- Đặt tour qua đại lý uy tín hoặc Klook thay vì mua từ người lạ trên phố.
- Bảo vệ đồ điện tử và tài sản giá trị khi ra đảo.

Q: Có cần cẩn thận gì về an ninh, mất cắp không?
A: Nha Trang là thành phố du lịch khá an toàn nhưng cần chú ý:
- Giữ túi ở mặt trước hoặc ba lô chống cướp khi đi xe máy, đặc biệt ở khu đông khách.
- Tránh để điện thoại và ví lộ ra khi ngồi ở quán vỉa hè.
- Khu vực chợ đêm đông đúc — cẩn thận móc túi.
- Không để đồ trên bãi biển khi xuống nước một mình.

## ❓ Câu hỏi ngoài phạm vi', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '6b69c575-36bd-5869-af7e-6e66da865879', 'FAQ Du lịch Nha Trang (4)', 'faq', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Q: Giá vé vào Viện Hải dương học Nha Trang là bao nhiêu?
A: Hiện chưa có thông tin giá vé cập nhật cho địa điểm này trong hệ thống.
Bạn có thể kiểm tra tại trang web chính thức của Viện Hải dương học Nha Trang, Google Maps, hoặc liên hệ trực tiếp trước khi đến để có giá chính xác nhất.

Q: Tôi muốn thuê du thuyền riêng ra đảo, chi phí thế nào?
A: Thông tin thuê du thuyền riêng (private charter) hiện chưa có trong hệ thống.
Để có báo giá chính xác, bạn có thể liên hệ trực tiếp các công ty lữ hành biển tại Nha Trang, hoặc tìm kiếm trên Klook (klook.com/vi) và Traveloka với từ khóa "thuê thuyền Nha Trang" hoặc "private boat Nha Trang".', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5dec4a77-3512-5b80-a2e2-9d1ad3d735f5', 'Ẩm thực đặc sản Nha Trang', 'food', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Đặc sản ẩm thực Nha Trang:
- Bún cá Nha Trang: Món bún đặc trưng của Nha Trang với nước dùng từ cá tươi nấu trong vắt, thanh ngọt. Thường ăn kèm chả cá chiên giòn, rau sống và mắm ruốc. Khác bún bò Huế ở chỗ nước dùng nhẹ hơn, hương vị biển đặc tr
  Địa điểm thưởng thức: [''Chợ Đầm Nha Trang'', ''Các quán bún cá khu vực trung tâm thành phố'']
  Giá tham khảo: Tầm 30.000–60.000đ/tô (ước tính — xác nhận tại quán)
- Nem nướng Ninh Hòa: Nem nướng làm từ thịt heo xay trộn gia vị, nướng trên than hồng, cuốn cùng bánh đa, rau sống và chấm nước mắm tỏi ớt ngọt. Ninh Hòa (huyện thuộc Khánh Hòa) là nơi khai sinh món này và được công nhận l
  Địa điểm thưởng thức: [''Các quán nem nướng khu trung tâm Nha Trang'', ''Thị trấn Ninh Hòa nếu đi xa hơn'']
  Giá tham khảo: Tầm 50.000–100.000đ/phần (ước tính — xác nhận tại quán)
- Yến sào Khánh Hòa: Tổ yến (tổ chim yến) được khai thác từ các đảo đá ven biển Khánh Hòa — vùng yến sào nổi tiếng nhất Việt Nam. Chế biến thành chè yến, súp yến, nước yến đóng chai. Được coi là thực phẩm bổ dưỡng cao cấp
  Địa điểm thưởng thức: [''Các cửa hàng yến sào Khánh Hòa chính thức'', ''Nhà hàng cao cấp tại Nha Trang'']
  Giá tham khảo: Cao — phụ thuộc loại yến và hình thức chế biến (xác nhận tại cửa hàng)
- Bánh căn: Bánh làm từ bột gạo đổ vào khuôn đất nung nhỏ, nướng trên bếp than, thường kèm trứng cút hoặc hải sản. Ăn kèm nước chấm cá hoặc mắm nêm. Món ăn vặt quen thuộc của người dân Nha Trang, đặc biệt phổ biế
  Địa điểm thưởng thức: [''Chợ đêm Nha Trang'', ''Các xe bánh căn vỉa hè khu trung tâm'']
  Giá tham khảo: Bình dân — tầm 20.000–40.000đ/phần (ước tính)
- Hải sản tươi sống: Nha Trang là thiên đường hải sản với tôm hùm, ghẹ, mực, cá mú, hào, sò điệp tươi sống từ các làng chài và đảo gần bờ. Chế biến đa dạng: hấp, nướng, xào tỏi, lẩu. Giá cả cạnh tranh hơn các thành phố lớ
  Địa điểm thưởng thức: [''Khu hải sản đường Phạm Văn Đồng'', ''Nhà hàng dọc bờ biển'', ''Chợ Đầm'']
  Giá tham khảo: Dao động rộng theo loại hải sản — nên hỏi giá trước khi gọi
- Bò né Nha Trang: Bít tết bò áp chảo nóng hổi ăn kèm trứng ốp la, bánh mì giòn và nước sốt pate. Phong trào bò né phổ biến khắp Việt Nam nhưng Nha Trang có phiên bản riêng với nhiều quán ngon, giá bình dân.
  Địa điểm thưởng thức: [''Các quán bò né khu trung tâm thành phố'', ''Chợ đêm Nha Trang'']
  Giá tham khảo: Tầm 50.000–90.000đ/phần (ước tính — xác nhận tại quán)
- Chè Nha Trang: Các loại chè đặc trưng miền Trung: chè thập cẩm, chè đậu xanh, chè bắp, chè yến. Đặc biệt có chè yến sào — đặc sản Khánh Hòa. Ăn kèm đá bào mát lạnh, phù hợp thời tiết nóng ở Nha Trang.
  Địa điểm thưởng thức: [''Các quán chè khu trung tâm'', ''Chợ đêm Nha Trang'']
  Giá tham khảo: Tầm 15.000–50.000đ/ly (ước tính — xác nhận tại quán)', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '4afc55d4-ae09-5473-9595-f23218adf4de', 'Cách di chuyển đến Nha Trang', 'transport', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Di chuyển đến và trong Nha Trang:

Cách đến:
- AIRPLANE từ Hà Nội (Nội Bài): 2 giờ 10 phút — Xác nhận tại Traveloka hoặc Vietnam Airlines — dao động theo thời điểm đặt
  Sân bay Cam Ranh cách trung tâm Nha Trang khoảng 30km. Có xe bus và taxi ra trung tâm.
- AIRPLANE từ TP. Hồ Chí Minh (Tân Sơn Nhất): 1 giờ 10 phút — Xác nhận tại Traveloka — thường có vé giá rẻ trên các chặng ngắn
  Chặng ngắn, nhiều chuyến mỗi ngày. Thuận tiện nhất từ TP.HCM.
- TRAIN từ Hà Nội: Khoảng 24–27 giờ — Xác nhận tại dsvn.vn hoặc 12go.asia — có ghế nằm điều hòa
  Chặng dài nhưng phong cảnh đẹp qua duyên hải miền Trung. Đặt vé trước tại dsvn.vn.
- TRAIN từ TP. Hồ Chí Minh: Khoảng 6–8 giờ — Xác nhận tại dsvn.vn
  Phương án tốt nếu không muốn bay. Ga Nha Trang nằm gần trung tâm thành phố.
- BUS từ TP. Hồ Chí Minh: 10–12 giờ — Xác nhận tại nhà xe hoặc Vexere.com
  Xe limousine giường nằm chạy ban đêm, tiết kiệm một đêm khách sạn. Đặt trước qua Vexere.com.

Di chuyển trong thành phố:
- grab: Phương tiện thuận tiện nhất cho khách du lịch. Trả tiền qua app hoặc tiền mặt.
- taxi: Chọn hãng taxi có đồng hồ (Mai Linh, Vinasun). Tránh taxi dù không rõ nguồn gốc.
- xe_om: Phổ biến ở các khu vực chưa có Grab. Thỏa thuận giá trước khi đi.
- motorbike_rental: Phù hợp cho người có bằng lái và quen đường. Tự do khám phá ngoại ô và các làng chài. Kiểm tra kỹ xe trước khi thuê.', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ecccaf21-7e24-5b42-b2e4-b94946509b49', 'Khách sạn & Lưu trú tại Nha Trang', 'hotel', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Lưu trú tại Nha Trang:
- Sheraton Nha Trang Hotel & Spa (5★): 26-28 Trần Phú, TP. Nha Trang, Khánh Hòa
  Tiện ích: Hồ bơi vô cực, Spa, Nhà hàng, Phòng gym
- Vinpearl Resort & Spa Nha Trang Bay (5★): Đảo Hòn Tre, TP. Nha Trang, Khánh Hòa
  Tiện ích: Hồ bơi riêng, Bãi biển riêng, Spa, Golf
- Novotel Nha Trang (4★): 50 Trần Phú, TP. Nha Trang, Khánh Hòa
  Tiện ích: Hồ bơi ngoài trời, Nhà hàng, Bar, Phòng gym
- Sun River Nha Trang Hotel (3★): Khu vực trung tâm TP. Nha Trang, Khánh Hòa
  Tiện ích: WiFi miễn phí, Điều hòa, Nhà hàng, Lễ tân 24/7
- La Mer Homestay Nha Trang (None★): Khu vực gần biển Nha Trang, Khánh Hòa
  Tiện ích: WiFi miễn phí, Bếp dùng chung, Sân thượng', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b5ec5312-deed-50b3-a684-9d60dce522be', 'Tour & Trải nghiệm tại Nha Trang', 'tour', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Tour & Trải nghiệm tại Nha Trang:
- Tour 4 Đảo Nha Trang (Snorkeling & Lặn ngắm san hô): 1 ngày (khoảng 8:00–17:00) — liên hệ
  Tour tàu tham quan 4 đảo: Hòn Mun (lặn ngắm san hô), Hòn Miễu, Hòn Tằm và Hòn Một. Bao gồm thiết bị lặn snorkel, bữa trưa hải sản trên thuyền, thời gian tự do bơi lội. Một số tour có option lặn scuba thêm phí.
- Tour Bình Ba — Đảo Tôm Hùm: 2 ngày 1 đêm — liên hệ
  Tour khám phá đảo Bình Ba (Cam Ranh), nổi tiếng với tôm hùm tươi sống giá tốt và bãi biển hoang sơ. Chương trình bao gồm tàu ra đảo, lưu trú nhà dân hoặc resort nhỏ, ăn hải sản đảo, bơi lội tự do.
- Tour Tắm Bùn I-Resort Nha Trang: Nửa ngày (khoảng 4–5 giờ) — liên hệ
  Trải nghiệm tắm bùn khoáng thiên nhiên tại I-Resort — địa điểm tắm bùn nổi tiếng nhất Nha Trang. Bùn khoáng từ nguồn tự nhiên, nhiều gói: tắm bùn đôi, gia đình, cá nhân. Kết hợp ngâm suối khoáng nóng và hồ bơi.
- Tour Lặn Scuba Hòn Mun (Diving): 1 ngày — liên hệ
  Lặn scuba khám phá vùng biển Hòn Mun — khu bảo tồn biển quốc gia với san hô đa dạng và cá nhiều màu sắc. Có chương trình dành cho người chưa có chứng chỉ (fun dive kèm hướng dẫn viên) và cho người có chứng chỉ PADI.', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b756f54b-4dde-53bd-8cd0-1daefe636b08', 'Lễ hội & Sự kiện tại Nha Trang', 'event', '019eed69-50b3-743c-b2d0-2107e58ca38d',
  'Lễ hội & Sự kiện tại Nha Trang:
- Lễ hội Tháp Bà Ponagar (Vía Bà): Tháng 3 âm lịch (thường tháng 4–5 dương lịch), 3 ngày
  Lễ hội truyền thống lớn nhất của người Chăm và người Kinh ở Khánh Hòa, thờ nữ thần Ponagar — thánh mẫu bảo hộ vùng đất. Nghi lễ tắm tượng, dâng hương, biểu diễn múa Chăm truyền thống thu hút hàng vạn người. Được Bộ Văn hóa công nhận là di sản văn hóa
- Festival Biển Nha Trang: Thường tổ chức tháng 6–7, cách năm (năm chẵn hoặc theo kế hoạch tỉnh)
  Sự kiện du lịch - văn hóa lớn của tỉnh Khánh Hòa với các hoạt động: biểu diễn nghệ thuật, đua thuyền, lễ hội ẩm thực biển, trình diễn ánh sáng trên bờ biển. Thu hút hàng trăm nghìn du khách trong và ngoài nước.
- Giải Marathon Quốc tế Nha Trang: Thường tháng 5–6 hàng năm — xác nhận lịch chính xác tại website giải
  Giải chạy marathon quốc tế với cung đường đẹp dọc bờ biển Nha Trang, thu hút vận động viên trong nước và quốc tế. Các cự ly: 5km, 10km, 21km (Half Marathon), 42km (Full Marathon).
- Lễ hội Ăn Tết Nguyên Đán tại Nha Trang: Tháng 1–2 (âm lịch) hàng năm
  Nha Trang tổ chức nhiều hoạt động đón Tết: chợ hoa Tết, màn pháo hoa đêm Giao Thừa trên biển, các chương trình văn nghệ. Đây cũng là thời điểm đông khách nhất — nên đặt phòng trước vài tháng.', ARRAY['khanh-hoa-nha-trang', 'nha trang', 'khánh hòa', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'bc02b3e6-85a5-5673-9eb7-e22849bf9d47', 'Tổng quan du lịch Lai Châu', 'destination', '019eed69-50b3-7c74-b810-8e00d38b1805',
  'Tổng quan Lai Châu (Lai Châu):
Tỉnh vùng cao biên giới phía Tây Bắc với đỉnh Pu Si Lung cao thứ 2 Việt Nam, thác Tác Tình hùng vĩ, ruộng bậc thang Bản Bo và văn hóa dân tộc Thái, Mảng, Hà Nhì nguyên bản.

Mùa đẹp nhất: Tháng 9–10 (ruộng bậc thang vàng) và tháng 3–5 (hoa ban trắng)
Thời tiết: Mát lạnh 12–28°C, sương mù buổi sáng, mưa nhiều tháng 6–8, lạnh tháng 12–2
Ẩm thực: Cá bống vùi tro Lai Châu, pa pính tộp (cá nướng), thịt trâu gác bếp, rượu sán lùng, nậm pịa
Ngân sách tham khảo: 1,500,000–4,000,000đ/người', ARRAY['lai-chau', 'lai châu', 'lai châu', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8d09b5c2-af1a-501e-9544-401e99eeff7d', 'Tổng quan du lịch Đà Lạt', 'destination', '019eed69-50b3-7d37-b71a-93a9a778c50c',
  'Tổng quan Đà Lạt (Lâm Đồng):
Thành phố ngàn hoa trên cao nguyên Lâm Viên 1.500m, nổi tiếng với khí hậu mát mẻ quanh năm, đồi chè xanh mướt, thác nước hùng vĩ và kiến trúc Pháp cổ kính.

Mùa đẹp nhất: Tháng 11–4 (mùa khô, ít mưa)
Thời tiết: Mát mẻ 15–24°C, mùa mưa tháng 5–10, sương mù buổi sáng
Ẩm thực: Bánh tráng nướng, lẩu gà lá é, sữa đậu nành nóng, dâu tây, atiso, rượu vang Đà Lạt
Ngân sách tham khảo: 1,500,000–4,000,000đ/người', ARRAY['lam-dong-da-lat', 'đà lạt', 'lâm đồng', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'db66eccf-1554-5c0b-806e-6ae926a46bf2', 'Tổng quan du lịch Mũi Né', 'destination', '019eed69-50b3-7691-995a-bbe5f3404ea8',
  'Tổng quan Mũi Né (Lâm Đồng):
Làng chài ven biển nổi tiếng với đồi cát bay kỳ ảo, bãi biển kite surfing quốc tế, suối Tiên đa màu sắc và hải sản tươi ngon — thiên đường thể thao biển Đông Nam Á.

Mùa đẹp nhất: Tháng 11–4 (gió mạnh — mùa kite surfing, nắng đẹp)
Thời tiết: Nóng nắng 25–35°C, ít mưa nhất cả nước, gió mạnh tháng 11–4 (lý tưởng kite surf)
Ẩm thực: Hải sản Mũi Né, bánh canh chả cá Phan Thiết, nước mắm Phan Thiết, thanh long Bình Thuận, cơm chiên hải sản
Ngân sách tham khảo: 1,500,000–4,000,000đ/người', ARRAY['lam-dong-mui-ne', 'mũi né', 'lâm đồng', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'cd4cf0b8-6cfb-535b-ae78-b5a858b23d7f', 'Tổng quan du lịch Lạng Sơn', 'destination', '019eed69-50b3-7232-b155-10c17a514c3c',
  'Tổng quan Lạng Sơn (Lạng Sơn):
Tỉnh biên giới phía Bắc với ải Chi Lăng lịch sử, chợ Đông Kinh nhộn nhịp hàng Trung Quốc, động Tam Thanh kỳ ảo, núi Mẫu Sơn có tuyết và văn hóa Tày - Nùng đặc sắc.

Mùa đẹp nhất: Tháng 9–11 và tháng 12–1 (tuyết Mẫu Sơn, hiếm)
Thời tiết: 4 mùa rõ rệt, 10–32°C, lạnh tháng 12–2, núi Mẫu Sơn có thể có băng tuyết
Ẩm thực: Vịt quay Lạng Sơn, bánh cuốn trứng, khâu nhục, lợn quay, phở chua Lạng Sơn, hồng quân, na Chi Lăng
Ngân sách tham khảo: 800,000–2,500,000đ/người', ARRAY['lang-son', 'lạng sơn', 'lạng sơn', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'abe389bd-76a5-5dd7-a812-1932d809e2c5', 'Tổng quan du lịch Sa Pa', 'destination', '019eed69-50b3-7b08-84a7-341ade2c0908',
  'Tổng quan Sa Pa (Lào Cai):
Thị trấn sương mù trên độ cao 1.500m với ruộng bậc thang kỳ vĩ, đỉnh Fansipan 3.143m — nóc nhà Đông Dương, cùng văn hóa H''Mông, Dao Đỏ và các bản làng dân tộc đặc sắc.

Mùa đẹp nhất: Tháng 9–10 (ruộng bậc thang vàng) hoặc tháng 3–5 (hoa đào, hoa mận)
Thời tiết: Mát lạnh 10–22°C, sương mù quanh năm, tuyết rơi dịp Tết âm lịch (hiếm), mưa nhiều tháng 6–8
Ẩm thực: Cá hồi Sa Pa, thịt lợn cắp nách nướng, rau cải mèo xào tỏi, rượu ngô H''Mông, thắng cố, xôi nếp nương
Ngân sách tham khảo: 2,000,000–6,000,000đ/người', ARRAY['lao-cai-sa-pa', 'sa pa', 'lào cai', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '05eda676-c3c2-55fb-8351-30a0f4129df9', 'Tổng quan du lịch Cửa Lò', 'destination', '019eed69-50b3-75f8-b421-0622df9db573',
  'Tổng quan Cửa Lò (Nghệ An):
Thị xã biển xứ Nghệ với bãi biển Cửa Lò dài 10km sóng nhỏ, nước trong xanh, hải sản phong phú và không khí bình dân gần gũi — điểm tắm biển phổ biến nhất miền Bắc Trung Bộ.

Mùa đẹp nhất: Tháng 4–8 (mùa hè, biển đẹp nhất)
Thời tiết: Nóng ẩm 30–38°C mùa hè, gió Lào khô nóng tháng 6–7, mưa bão tháng 9–10
Ẩm thực: Mực khô Cửa Lò, cá thu nướng, hàu sữa, bún bò Vinh, cháo lươn Nghệ An, kẹo cu đơ
Ngân sách tham khảo: 700,000–2,000,000đ/người', ARRAY['nghe-an-cua-lo', 'cửa lò', 'nghệ an', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5a21b47b-93d6-525d-b7ac-727e067d669d', 'Tổng quan du lịch Ninh Bình', 'destination', '019eed69-50b3-7f4e-886e-b5d04063fc02',
  'Tổng quan Ninh Bình (Ninh Bình):
Vùng đất được mệnh danh ''Hạ Long trên cạn'' với quần thể Tràng An — Di sản Thế giới kép UNESCO, cố đô Hoa Lư, chùa Bái Đính lớn nhất Đông Nam Á và đồng lúa Tam Cốc thơ mộng.

Mùa đẹp nhất: Tháng 10–4 (tránh mưa, lúa vàng tháng 10–11)
Thời tiết: 4 mùa rõ rệt, 15–35°C, mưa nhiều tháng 5–9, lạnh tháng 12–2
Ẩm thực: Cơm cháy Ninh Bình, thịt dê núi Ninh Bình, rượu Kim Sơn, cá rô Tổng Trường, miến lươn
Ngân sách tham khảo: 800,000–2,500,000đ/người', ARRAY['ninh-binh', 'ninh bình', 'ninh bình', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '78fc3dfd-6d11-51e3-9829-cd339509f407', 'Tổng quan du lịch Phú Thọ', 'destination', '019eed69-50b3-7a97-8133-dab596aaf763',
  'Tổng quan Phú Thọ (Phú Thọ):
Đất Tổ Hùng Vương linh thiêng với Đền Hùng — nơi thờ các Vua Hùng dựng nước, rừng quốc gia Xuân Sơn, suối khoáng Thanh Thủy và văn hóa đâm trống đồng của người Mường.

Mùa đẹp nhất: Tháng 2–4 (lễ hội Giỗ Tổ) và tháng 9–11 (mát mẻ)
Thời tiết: 4 mùa rõ rệt, 15–36°C, mưa nhiều tháng 5–8, lạnh tháng 12–2
Ẩm thực: Thịt chua Thanh Sơn, bánh sắn Phú Thọ, cá anh vũ sông Đà, rượu cần Mường, chè kho, cơm lam
Ngân sách tham khảo: 600,000–1,800,000đ/người', ARRAY['phu-tho', 'phú thọ', 'phú thọ', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '8560b6ff-a826-5d8a-8c45-29111513f7c2', 'Tổng quan du lịch Đảo Lý Sơn', 'destination', '019eeda8-d830-7d4c-9ef2-6de207ce2bdb',
  'Tổng quan Đảo Lý Sơn (Quảng Ngãi):
Đảo núi lửa với cánh đồng hành tỏi, vách đá bazan và biển trong xanh ngoài khơi Quảng Ngãi; sau sáp nhập còn có vùng cao nguyên Kon Tum với núi Ngọc Linh, nhà thờ gỗ Kon Tum và văn hóa cồng chiêng Tây Nguyên.

Mùa đẹp nhất: Tháng 4–8 (biển êm, thuận lợi ra đảo)
Thời tiết: Nóng ẩm 25–34°C, mùa mưa bão tháng 9–12 — tàu ra đảo có thể tạm ngưng
Ẩm thực: Gỏi tỏi Lý Sơn, don Quảng Ngãi, hải sản tươi, hành tỏi đặc sản
Ngân sách tham khảo: ', ARRAY['quang-ngai-ly-son', 'đảo lý sơn', 'quảng ngãi', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '4a00d87a-e700-516d-baa0-f7fd35e1532e', 'Tổng quan du lịch Vịnh Hạ Long', 'destination', '019eed69-50b3-7f32-bd6d-13f617e17937',
  'Tổng quan Vịnh Hạ Long (Quảng Ninh):
Di sản Thiên nhiên Thế giới UNESCO với hơn 1.969 hòn đảo đá vôi, hang động kỳ ảo, làng chài nổi và vịnh biển xanh ngọc bích — biểu tượng du lịch Việt Nam.

Mùa đẹp nhất: Tháng 10–4 (biển lặng, ít mưa)
Thời tiết: Ấm 20–30°C, mùa hè nóng ẩm có mưa bão (tháng 6–9), đông lạnh có sương mù đẹp
Ẩm thực: Hải sản Hạ Long, sá sùng nướng, chả mực Hạ Long, bề bề rang me, ngán xào tỏi
Ngân sách tham khảo: 2,500,000–8,000,000đ/người', ARRAY['quang-ninh-ha-long', 'vịnh hạ long', 'quảng ninh', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e75076eb-5719-5f46-9476-abc8586fff75', 'Tổng quan du lịch Quảng Trị', 'destination', '019eed69-50b3-79f6-9a6e-66856703829f',
  'Tổng quan Quảng Trị (Quảng Trị):
Vùng đất lịch sử bi hùng với Thành Cổ Quảng Trị, Nghĩa trang Trường Sơn, sông Bến Hải - cầu Hiền Lương chia đôi đất nước và động Phong Nha - Kẻ Bàng Di sản UNESCO.

Mùa đẹp nhất: Tháng 2–8 (tránh mưa lũ tháng 9–11)
Thời tiết: Nhiệt đới gió mùa, 18–36°C, mưa lũ nặng tháng 9–11, nóng khô gió Lào tháng 5–7
Ẩm thực: Cháo vạt giường Quảng Trị, bún bò Quảng Trị, bánh ướt thịt heo, tré bò, mắm ruốc, bánh nậm
Ngân sách tham khảo: 800,000–2,500,000đ/người', ARRAY['quang-tri', 'quảng trị', 'quảng trị', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '898c6a99-7386-5821-be1d-13987d379713', 'Tổng quan du lịch Mộc Châu', 'destination', '019eed69-50b3-7c76-b437-284592040a13',
  'Tổng quan Mộc Châu (Sơn La):
Cao nguyên Mộc Châu 1.000m xanh mát với đồi chè bát ngát, vườn mận nở trắng tháng 2, đàn bò sữa thư thái, thung lũng Mai Châu thơ mộng và văn hóa Thái trắng nguyên bản.

Mùa đẹp nhất: Tháng 1–3 (hoa mận, đào) và tháng 9–11 (mùa vàng lúa, hoa cải)
Thời tiết: Mát mẻ 15–25°C quanh năm, lạnh tháng 12–1 có sương muối, mưa tháng 6–8
Ẩm thực: Sữa tươi Mộc Châu, lợn cắp nách nướng, thịt trâu gác bếp, rượu táo mèo, cá suối nướng, mận Mộc Châu
Ngân sách tham khảo: 1,200,000–3,500,000đ/người', ARRAY['son-la-moc-chau', 'mộc châu', 'sơn la', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '11b5b9e3-57f1-592c-bafe-43cacbd5ccc6', 'Tổng quan du lịch Núi Bà Đen', 'destination', '019eeda8-d830-7a83-8b89-527da5de9455',
  'Tổng quan Núi Bà Đen (Tây Ninh):
Ngọn núi cao nhất Nam Bộ với hệ thống cáp treo, tượng Phật Bà và Tòa Thánh Cao Đài nổi tiếng; sau sáp nhập còn có vùng Đồng Tháp Mười thuộc Long An với khu du lịch sinh thái Làng nổi Tân Lập.

Mùa đẹp nhất: Tháng 11–4 (mùa khô, trời quang, dễ ngắm cảnh từ cáp treo)
Thời tiết: Nóng 25–35°C, mùa mưa tháng 5–10
Ẩm thực: Bánh tráng phơi sương Trảng Bàng, muối tôm Tây Ninh, ốc núi
Ngân sách tham khảo: ', ARRAY['tay-ninh-nui-ba-den', 'núi bà đen', 'tây ninh', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '827c44a2-9e11-556a-9471-07063af62a0e', 'Tổng quan du lịch Thái Nguyên', 'destination', '019eed69-50b3-7b51-bde0-322dacd2b8b3',
  'Tổng quan Thái Nguyên (Thái Nguyên):
Thủ phủ chè Việt Nam với đồi chè Tân Cương xanh mướt nổi tiếng, hồ Núi Cốc thơ mộng, ATK Định Hóa — căn cứ địa cách mạng kháng chiến và văn hóa dân tộc Tày đặc sắc.

Mùa đẹp nhất: Tháng 9–11 và tháng 3–5 (thu hoạch chè, khí hậu mát)
Thời tiết: 4 mùa rõ rệt, 16–34°C, mưa nhiều tháng 6–8, sương mù đồi chè buổi sáng
Ẩm thực: Chè Tân Cương, gà đồi Thái Nguyên, cá nướng Pa Tẩu, bánh chưng gù Bắc Kạn, trám om xôi
Ngân sách tham khảo: 700,000–2,000,000đ/người', ARRAY['thai-nguyen', 'thái nguyên', 'thái nguyên', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3ce5044c-1758-5c56-8e74-1e509d7bff19', 'Tổng quan du lịch Sầm Sơn', 'destination', '019eed69-50b3-7e43-9532-5f1a51149596',
  'Tổng quan Sầm Sơn (Thanh Hóa):
Thành phố biển nổi tiếng xứ Thanh với bãi biển dài 9km cát mịn, đền Độc Cước linh thiêng trên mỏm đá, sóng lớn phù hợp lướt sóng và hải sản tươi ngon giá bình dân.

Mùa đẹp nhất: Tháng 4–8 (mùa tắm biển sầm uất)
Thời tiết: Nóng 28–36°C mùa hè, gió biển mát, mùa đông lạnh hanh, bão tháng 9–10
Ẩm thực: Nem chua Thanh Hóa, bánh cuốn Phủ Lý, cháo lươn, ghẹ rang muối, canh chua hải sản, ốc hút
Ngân sách tham khảo: 800,000–2,500,000đ/người', ARRAY['thanh-hoa-sam-son', 'sầm sơn', 'thanh hóa', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c0823c89-35a1-5e56-9f6e-1e6e94aa23fa', 'Tổng quan du lịch TP. Hồ Chí Minh', 'destination', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Tổng quan TP. Hồ Chí Minh (TP. Hồ Chí Minh):
Đô thị lớn nhất Việt Nam, trung tâm kinh tế năng động, kết hợp di tích lịch sử, ẩm thực đường phố, các khu công nghiệp Bình Dương và biển Vũng Tàu sau sáp nhập.

Mùa đẹp nhất: Tháng 12–4 (mùa khô, ít mưa)
Thời tiết: Nóng ẩm 25–35°C quanh năm, mùa mưa tháng 5–11
Ẩm thực: Cơm tấm, hủ tiếu, bánh mì Sài Gòn, lẩu mắm, ốc Vũng Tàu
Ngân sách tham khảo: ', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '57485070-2439-5ba4-b8f0-8f749b2f117e', 'TP. Hồ Chí Minh – 1. Dinh Độc Lập', 'tip', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 1. Dinh Độc Lập
Loại: Công trình lịch sử — attraction
Khu vực: Trung tâm Quận 1, gần công viên Tao Đàn
Giờ mở cửa: Thường 7:30–11:00 và 13:00–16:00 *(xác nhận trước khi đến — đóng cửa khi có sự kiện)*
Giá vé: *Xem destinations.json — chưa xác minh*
Tip: Nhiều khách chỉ chụp ảnh bên ngoài rồi bỏ qua nội thất — đây là sai lầm lớn. Khu hầm ngầm tầng B1, B2, B3 với máy phát điện, máy đánh mã và trung tâm chỉ huy mới là linh hồn của toà nhà. Thuê hướng dẫn viên tại chỗ (~60–90 phút) để hiểu đầy đủ câu chuyện lịch sử.', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'dd2175e9-8b4b-5cbe-b19e-c77205d38d20', 'TP. Hồ Chí Minh – 2. Bảo tàng Chứng tích Chiến tranh', 'tip', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 2. Bảo tàng Chứng tích Chiến tranh
Loại: Bảo tàng — museum
Khu vực: Quận 3, gần khu trung tâm
Giờ mở cửa: Thường 7:30–18:00 hàng ngày *(xác nhận tại Google Maps trước khi đến)*
Giá vé: *Xem destinations.json — chưa xác minh*
Tip: Không phải điểm cho trẻ nhỏ dưới 8–10 tuổi — nội dung ảnh chiến tranh rất trực quan. Người lớn nên dành 2–3 tiếng trọn vẹn, không vội. Tầng 3 có phòng ảnh của nhà báo quốc tế ghi lại cuộc chiến — ấn tượng nhất trong toàn bộ bảo tàng.', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '0c5a2cb9-3a8f-51bc-ba85-c2ff9cc23942', 'TP. Hồ Chí Minh – 3. Chùa Ngọc Hoàng (Phước Hải Tự)', 'tip', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 3. Chùa Ngọc Hoàng (Phước Hải Tự)
Loại: Đền chùa — temple
Khu vực: Phường Đa Kao, Quận 1 — gần khu trung tâm
Giờ mở cửa: Thường 7:00–18:00 *(xác nhận trước khi đến)*
Giá vé: Miễn phí
Tip: Được cựu Tổng thống Obama ghé thăm năm 2016 — chùa rất nổi tiếng nhưng vẫn giữ được không khí tâm linh thật sự. Đến vào sáng sớm cuối tuần để thấy người dân địa phương thờ cúng — khác hẳn cảm giác điểm du lịch đông đúc. Ao rùa trong sân là điểm check-in yêu thích.', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '3a0b348e-563e-508f-8de8-08607312db1b', 'TP. Hồ Chí Minh – 4. Chợ Bến Thành', 'tip', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 4. Chợ Bến Thành
Loại: Chợ truyền thống — market
Khu vực: Công trường Quách Thị Trang, trung tâm Quận 1
Giờ mở cửa: Thường 6:00–18:00 *(khu đêm đến ~23:00)*
Giá vé: Miễn phí vào cửa
Tip: Đừng chỉ mua đồ lưu niệm — khu ẩm thực bên trong chợ phục vụ nhiều món ngon đặc trưng Nam Bộ và là nơi ăn uống giá phải chăng ngay trung tâm thành phố. Buổi sáng trước 9:00 là thời điểm yên tĩnh nhất để quan sát chợ thật sự (không phải chợ du lịch).', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'a189b3f0-1918-5ed2-967e-dcb033ed2b41', 'TP. Hồ Chí Minh – 5. Địa đạo Củ Chi', 'activity', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 5. Địa đạo Củ Chi
Loại: Di tích lịch sử — attraction
Khu vực: Huyện Củ Chi — cách trung tâm ~70km (khoảng 1.5–2 tiếng đi xe)
Giờ mở cửa: Thường 7:00–17:00 *(xác nhận trước khi đến)*
Giá vé: *Xem destinations.json — chưa xác minh*
Tip: Đi theo tour có hướng dẫn viên (xem tours.json) để hiểu đầy đủ ngữ cảnh lịch sử — tự đi không có hướng dẫn sẽ thiếu nhiều thông tin. Mặc quần áo tối màu, thoải mái vì hầm ẩm và bẩn. Thử khoai mì (sắn) luộc — thức ăn của du kích năm xưa — được phục vụ tại điểm tham quan.', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '24f738a4-fb77-5db7-9a60-4152dd910ab4', 'TP. Hồ Chí Minh – 6. Làng Du lịch Bình Quới', 'activity', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 6. Làng Du lịch Bình Quới
Loại: Khu sinh thái sông nước — nature
Khu vực: Bình Thạnh — cách trung tâm ~8km theo sông Sài Gòn
Giờ mở cửa: Thường 7:00–22:00 *(xác nhận trước khi đến)*
Giá vé: *Xem destinations.json — liên hệ điểm đến để có giá cập nhật*
Tip: Lý tưởng cho gia đình có trẻ nhỏ hoặc nhóm muốn thoát khỏi ồn ào đô thị mà không cần ra khỏi thành phố. Đặt bàn ăn trước cuối tuần — rất đông vào thứ 7, CN. Buổi chiều ngồi uống nước nhìn ra sông Sài Gòn là trải nghiệm yên bình hiếm có ở một đô thị 10 triệu dân.

---', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '5d976c69-4c6c-5192-909e-50f992c911ab', 'TP. Hồ Chí Minh – 2 Ngày 1 Đêm — Khám Phá Lần Đầu', 'tip', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 2 Ngày 1 Đêm — Khám Phá Lần Đầu
> Chi tiết đầy đủ →  id: 

- Ngày 1: Ăn sáng phở Hòa Pasteur → Dinh Độc Lập (sáng) → Cơm tấm trưa → Bảo tàng Chứng tích Chiến tranh (chiều) → Nhà thờ Đức Bà + phố đi bộ Nguyễn Huệ → Tối ăn Nhà Hàng Ngon
- Ngày 2: Chợ Bến Thành (sáng) → Chùa Ngọc Hoàng → Trưa Cục Gạch Quán → Phố Đồng Khởi + Vincom → Tối phố Bùi Viện', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ae966517-848f-5432-9877-fa53cf1e80f7', 'TP. Hồ Chí Minh – 3 Ngày 2 Đêm — Gia Đình & Trẻ Em', 'tip', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 3 Ngày 2 Đêm — Gia Đình & Trẻ Em
> Chi tiết đầy đủ →  id: 

- Ngày 1: Trung tâm Quận 1 — Dinh Độc Lập, chợ Bến Thành, phố đi bộ Nguyễn Huệ
- Ngày 2: Làng Bình Quới sáng + chiều nghỉ ngơi hồ bơi khách sạn
- Ngày 3: Tour Địa Đạo Củ Chi nửa ngày → Chiều mua quà Vincom Center

---', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '42ed66b9-ea71-5bdb-930e-4c8e0d556909', 'TP. Hồ Chí Minh – 🚨 Kinh Nghiệm An Toàn', 'safety', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 🚨 Kinh Nghiệm An Toàn

Cảnh giác giật đồ: Giật túi từ xe máy là vấn đề thực tế tại TP. HCM, đặc biệt ở khu đông khách như Bến Thành, Phạm Ngũ Lão, và bất kỳ đâu sát mép đường. Không cầm điện thoại lên khi đứng sát lề đường. Đeo túi trước ngực hoặc kẹp cánh tay khi đi bộ vỉa hè đông.

Qua đường: Không có đèn tín hiệu tại nhiều giao lộ nhỏ — quy tắc là đi chậm, đều, không giật lùi hay chạy đột ngột. Nhìn và bước ra từ từ — xe máy đã quen tránh người. Lần đầu nên đi cùng người địa phương để học cách qua đường Sài Gòn.

Taxi và Grab: Chỉ dùng Grab app, hoặc taxi Vinasun (số xe bắt đầu bằng 51A-xxx) / Mai Linh (màu xanh lá). Taxi không thương hiệu đón tại sân bay hoặc chợ có thể tính giá cao gấp 3–5 lần.

Thức ăn đường phố: Nhìn chung an toàn khi ăn ở quán đông khách, thức ăn chín tới. Tránh đá lạnh nơi không rõ nguồn nước nếu dạ dày nhạy cảm. Nước đóng chai hoặc trà nóng là lựa chọn an toàn hơn.

---', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'd9f10715-beef-5268-b079-1a33639ad737', 'TP. Hồ Chí Minh – 💡 Tips Thực Tế', 'tip', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 💡 Tips Thực Tế

⏰ Timing thông minh:
- Đến Dinh Độc Lập và các bảo tàng ngay lúc mở cửa (7:30–8:00) để tránh đoàn khách lớn
- Phở Hòa Pasteur và nhiều quán ngon chỉ mở buổi sáng đến ~11:00 — đừng ngủ nướng
- Phố đi bộ Nguyễn Huệ đẹp nhất vào buổi tối cuối tuần — dạo bộ từ 19:00–21:00
- Tránh kẹt xe: 7:00–8:30 và 16:30–18:30 là giờ cao điểm kinh hoàng

📱 Apps cần thiết:
- Grab: di chuyển toàn thành phố
- Google Maps: điều hướng và tra giờ mở cửa (thường cập nhật)
- Foody: tìm quán ăn ngon theo khu vực

🌧️ Mùa mưa:
- Mang theo áo mưa gọn nhẹ (poncho) — mưa chiều thường đến bất ngờ
- Cơn mưa Sài Gòn thường tạnh trong vòng 30–60 phút — có thể đợi trong quán cà phê
- Khách sạn khu trung tâm Quận 1 thường không bị ngập — nhưng một số con phố nhỏ có thể ngập sau mưa lớn

💬 Ngôn ngữ:
- Ở khu Quận 1, Phạm Ngũ Lão: nhiều người biết tiếng Anh cơ bản
- Google Translate với camera (dịch menu ảnh) rất hữu ích tại quán bình dân
- Một vài từ tiếng Việt được đánh giá cao: "cảm ơn" (cảm ơn), "ngon quá" (ngon lắm), "tính tiền" (xin hóa đơn)

---', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b1e6c222-0158-52b5-88fe-eaf0a7649882', 'TP. Hồ Chí Minh – 🛒 Mua Sắm & Đặc Sản Mang Về', 'safety', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## 🛒 Mua Sắm & Đặc Sản Mang Về

| Đặc sản | Mô tả | Nơi mua tốt nhất |
|---|---|---|
| Cà phê Việt Nam | Cà phê robusta rang xay đặc trưng, pha phin hoặc cà phê sữa đá | Siêu thị Vincom, Co.opmart; cửa hàng cà phê khu Quận 1 |
| Bánh tráng & gia vị Nam Bộ | Bánh tráng mè, gia vị mắm, nước mắm Phú Quốc | Chợ Bến Thành, siêu thị |
| Áo dài lụa | Trang phục truyền thống Việt Nam, đặt may hoặc mua sẵn | Phố Đồng Khởi, Lê Lợi (Quận 1) |
| Đồ thủ công mỹ nghệ | Tranh sơn mài, đồ gỗ chạm khắc, lụa thêu | Phố Đồng Khởi, chợ Bến Thành |
| Hạt điều rang muối | Đặc sản miền Nam, giá tốt hơn ở siêu thị so với sân bay | Siêu thị Vincom, Co.opmart |
| Kẹo dừa Bến Tre | Đặc sản miền Tây Nam Bộ, nhiều loại hương vị | Chợ Bến Thành, siêu thị |

Lưu ý mua sắm: Siêu thị trong Vincom Center và Co.opmart có đặc sản đóng gói sạch, có hóa đơn — an toàn và tiện hơn khi mang qua kiểm tra hải quan. Giá ở siêu thị thường niêm yết, không cần mặc cả — nhưng cũng cao hơn chợ một chút. Khu chợ Bến Thành có nhiều lựa chọn hơn nhưng cần mặc cả. *(Xem shopping.json để biết đầy đủ địa điểm mua sắm.)*', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'kinh nghiệm', 'tip'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'c88b4cad-34b8-5d5e-bc46-fad254875f0e', 'FAQ Du lịch TP. Hồ Chí Minh (1)', 'faq', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  '## ❓ FAQ Du Lịch TP. Hồ Chí Minh (Sài Gòn)

---

## 🗓️ Thời điểm & Thời tiết

Q: Thời điểm nào trong năm đẹp nhất để đến TP. HCM?
A: Mùa khô từ tháng 11 đến tháng 4 năm sau là thời điểm lý tưởng nhất. Trời nắng, ít mưa, dễ đi lại và tham quan ngoài trời. Tháng 12–1 khí hậu dễ chịu nhất, mát mẻ hơn so với các tháng còn lại.
Nếu đến tháng 5–10 (mùa mưa), cần chuẩn bị áo mưa — mưa thường đến nhanh và tạnh nhanh vào buổi chiều, không kéo dài cả ngày. Vẫn du lịch được, chỉ cần linh hoạt lịch trình.
(Nguồn: vietnamtourism.gov.vn)

Q: Thời tiết TP. HCM như thế nào? Có lạnh không?
A: TP. HCM có khí hậu nhiệt đới, nóng và ẩm quanh năm. Không có mùa đông — nhiệt độ hiếm khi xuống dưới 20°C. Du khách từ miền Bắc hay nước ngoài vùng ôn đới thường thấy khá nóng.
Mang theo quần áo thoáng mát, kem chống nắng và nước uống khi đi ra ngoài. Buổi trưa 11:00–14:00 là nóng nhất — nên lên kế hoạch tham quan điểm trong nhà hoặc nghỉ giữa trưa.

---

## 💰 Chi phí & Ngân sách

Q: Chi phí một ngày ở TP. HCM khoảng bao nhiêu?
A: Chi phí phụ thuộc rất nhiều vào phong cách đi của bạn. Du khách ngân sách tiết kiệm có thể chi tiêu ít hơn nhiều so với khách muốn ở khách sạn 4–5 sao.
Để có ước tính cụ thể theo loại khách sạn và phong cách ăn uống, hãy tham khảo *(xem hotels.json và restaurants.json)* để so sánh các phân khúc. Giá vé tham quan các điểm chính như Dinh Độc Lập, Bảo tàng Chứng tích Chiến tranh tham khảo *(xem destinations.json)*.

Q: Có cần đổi ngoại tệ trước khi đến không?
A: Không cần đổi trước — TP. HCM có rất nhiều điểm đổi tiền tại sân bay Tân Sơn Nhất, các ngân hàng và điểm đổi tiền uy tín ở Quận 1. ATM phủ sóng rộng rãi, chấp nhận thẻ Visa/Mastercard.
Lưu ý: một số điểm đổi tiền vỉa hè có thể cộng thêm phí ẩn — ưu tiên đổi tại ngân hàng hoặc quầy đổi tiền có giấy phép. Nhiều nhà hàng và khách sạn lớn chấp nhận thẻ tín dụng, nhưng chợ và quán bình dân chỉ nhận tiền mặt.

---

## 🚗 Di chuyển', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '7fe3830e-8764-5f3f-9334-c97680939f77', 'FAQ Du lịch TP. Hồ Chí Minh (2)', 'faq', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Q: Từ sân bay Tân Sơn Nhất về trung tâm đi như thế nào?
A: Có 3 cách chính: Grab (tiện, giá rõ ràng qua app — khoảng 15–25 phút về Quận 1 tùy kẹt xe), taxi Vinasun hoặc Mai Linh (yêu cầu bật đồng hồ), hoặc xe buýt tuyến số 109 giá rẻ hơn nhưng mất nhiều thời gian hơn.
Tránh taxi dù không tên tuổi đón tại lối ra sân bay — có thể bị tính giá cao.

Q: Đi lại trong thành phố dễ không? Có cần thuê xe không?
A: Grab (xe ôm và ô tô) là lựa chọn tiện nhất cho khách du lịch — giá minh bạch, không cần mặc cả, phủ sóng toàn thành phố. Không cần thuê xe riêng trừ khi đi theo nhóm đông.
Taxi Vinasun và Mai Linh cũng uy tín. Xe buýt công cộng rẻ hơn nhưng lịch trình phức tạp, không phù hợp cho người mới đến. *(Xem transport.json để biết đầy đủ phương tiện và lưu ý.)*

Q: Từ TP. HCM đi Đà Lạt hoặc miền Tây thì đi như thế nào?
A: Đi Đà Lạt: xe limousine Phương Trang (FUTA) hoặc Thành Bưởi từ bến xe Miền Đông, khoảng 7–8 tiếng. Cũng có thể bay từ Tân Sơn Nhất.
Đi miền Tây (Cần Thơ, Mỹ Tho...): xe khách từ bến xe Miền Tây hoặc đặt tour ngày từ TP. HCM. *(Xem transport.json và tours.json để biết thêm tuyến đường và nhà xe.)*

---

## 🏨 Lưu trú

Q: Nên ở khu nào tại TP. HCM cho thuận tiện?
A: Quận 1 là lựa chọn tốt nhất cho lần đầu đến — gần nhất tất cả điểm tham quan chính, nhiều loại khách sạn từ hostel đến 5 sao, đi bộ hoặc Grab đến mọi nơi dễ dàng. Đặc biệt khu Phạm Ngũ Lão phù hợp du khách trẻ, ngân sách.
Quận 3 yên tĩnh hơn, gần các bảo tàng và nhà hàng ngon. Bình Thạnh và Thủ Đức thích hợp nếu bạn có việc ở khu đó nhưng xa trung tâm hơn.
*(Xem hotels.json để biết các lựa chọn lưu trú theo phân khúc.)*

---

## 🍜 Ẩm thực', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'e1dd6e95-9a9c-5569-bab9-5e48fedb4616', 'FAQ Du lịch TP. Hồ Chí Minh (3)', 'faq', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Q: Buổi sáng ở TP. HCM nên ăn gì?
A: Sáng Sài Gòn phong phú — cơm tấm sườn (ăn cơm từ sáng là đặc trưng miền Nam), phở bò tái, hủ tiếu Nam Vang, hoặc bánh mì. Người Sài Gòn ăn sáng rất sớm — nhiều quán từ 6:00.
Phở Hòa Pasteur chỉ mở buổi sáng (đến ~11:00) và tối khuya — nếu muốn thử nên lên kế hoạch trước. *(Xem foods.json và restaurants.json để biết các món và địa điểm cụ thể.)*

Q: Có ăn chay được dễ ở TP. HCM không?
A: Có — TP. HCM có văn hóa ăn chay rất phát triển, đặc biệt vào ngày mùng 1 và ngày 15 âm lịch. Nhiều quán chay tập trung ở Quận 3, Quận 5 (Chợ Lớn) và các khu chùa.
Nếu ăn chay trường, tìm quán có biển "Cơm Chay" hoặc "Quán Chay" — rất phổ biến và giá bình dân.

---

## ❓ Câu hỏi ngoài phạm vi

Q: Giá vé vào Dinh Độc Lập hoặc Bảo tàng Chứng tích Chiến tranh là bao nhiêu?
A: Hiện chúng tôi chưa có thông tin giá vé cập nhật đã xác minh cho các điểm này. Giá có thể thay đổi theo thời gian.
Bạn có thể kiểm tra tại Klook (klook.com/vi), trang chính thức của điểm tham quan, hoặc hỏi trực tiếp tại quầy vé khi đến. Sở Du lịch TP. HCM (tourism.hochiminhcity.gov.vn) cũng có thông tin cập nhật.

Q: Có thể đi từ TP. HCM ra Hà Nội bằng xe máy không?
A: Câu hỏi này nằm ngoài phạm vi thông tin du lịch TP. HCM của chúng tôi. Hành trình xuyên Việt bằng xe máy là một chủ đề riêng với nhiều lưu ý về giấy phép, bảo hiểm và tuyến đường.
Bạn có thể tham khảo các cộng đồng phượt như diễn đàn Phượt.vn hoặc nhóm Facebook "Phượt Việt Nam" để có thông tin thực tế từ người có kinh nghiệm.

---

## ⚠️ An toàn & Lưu ý', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'f7a21a8a-69da-5e3f-b212-315a01ae97af', 'FAQ Du lịch TP. Hồ Chí Minh (4)', 'faq', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Q: TP. HCM có an toàn cho khách du lịch không?
A: Nhìn chung TP. HCM khá an toàn cho du khách. Tuy nhiên cần lưu ý một số điều thực tế:
Giật túi xách là vấn đề phổ biến — đặc biệt khi đi xe máy qua, cầm điện thoại hoặc ví trên vỉa hè. Nên đeo túi chéo trước người, không dùng điện thoại khi đứng sát lề đường.
Khu Phạm Ngũ Lão và chợ Bến Thành đông khách du lịch — cảnh giác với kẻ móc túi trong đám đông. Không để đồ vật ở bàn ngoài quán cà phê vỉa hè mà không trông.

Q: Giao thông TP. HCM có nguy hiểm không? Đi bộ qua đường như thế nào?
A: Giao thông Sài Gòn đông đúc và có vẻ hỗn loạn với người mới đến — nhưng có quy tắc ngầm. Khi qua đường không có đèn tín hiệu: đi chậm, đều và dứt khoát — xe máy sẽ tự tránh. Không đứng chờ hay chạy đột ngột.
Tránh qua đường vào giờ cao điểm (7:00–8:30 và 16:30–18:30) khi giao thông đặc biệt đông. Đi cùng người địa phương lần đầu nếu chưa quen.', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'faq', 'hỏi đáp'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '34246bf2-03dc-51d8-b81d-b3bf4ace8e7a', 'Ẩm thực đặc sản TP. Hồ Chí Minh', 'food', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Đặc sản ẩm thực TP. Hồ Chí Minh:
- Hủ Tiếu Nam Vang: Hủ tiếu Nam Vang là món ăn đặc trưng của người Hoa-Khmer gốc Nam Vang (Phnom Penh) định cư tại Sài Gòn. Nước dùng trong ngọt từ xương heo hầm lâu, sợi hủ tiếu dai mềm, ăn kèm thịt heo, tôm, lòng heo v
  Địa điểm thưởng thức: [''Chợ Bến Thành'', ''khu Quận 5 (Cholon)'', ''các quán hủ tiếu xe vỉa hè toàn thành phố'']
  Giá tham khảo: Khoảng 40.000–80.000đ/tô — xác nhận tại Foody.vn
- Bánh Mì Sài Gòn: Bánh mì Sài Gòn là biểu tượng ẩm thực đường phố của thành phố, được CNN và nhiều tạp chí quốc tế vinh danh. Ổ bánh mì giòn vỏ mềm ruột, nhân đa dạng: thịt nguội, pate, chả, trứng, dưa leo, hành ngò và
  Địa điểm thưởng thức: [''Bánh Mì Huỳnh Hoa (Lê Thị Riêng, Quận 1)'', ''các xe bánh mì vỉa hè toàn thành phố'']
  Giá tham khảo: Khoảng 20.000–50.000đ/ổ — xác nhận tại Foody.vn
- Cơm Tấm: Cơm tấm (cơm gạo tấm) là món ăn quốc dân của người Sài Gòn, ăn từ sáng đến tối. Cơm tấm thật sự dùng gạo nát/gạo bể, có hương vị đặc biệt. Thường ăn kèm sườn nướng, bì, chả trứng hấp, mỡ hành và nước 
  Địa điểm thưởng thức: [''Cơm Tấm Thuận Kiều (Quận 11)'', ''các quán cơm tấm vỉa hè toàn thành phố'', ''khu Quận 3, Quận 1'']
  Giá tham khảo: Khoảng 40.000–100.000đ/phần — xác nhận tại Foody.vn
- Bún Bò Huế kiểu Sài Gòn: Bún bò Huế du nhập vào Sài Gòn được biến tấu theo khẩu vị địa phương — ít cay hơn, nước dùng ngọt hơn. Sợi bún tròn to, nước dùng đỏ sóng sánh từ sả, mắm ruốc và ớt, ăn kèm bò, chả heo, giò heo và rau
  Địa điểm thưởng thức: [''khu Quận 3'', ''khu Bình Thạnh'', ''các quán bún bò vỉa hè'']
  Giá tham khảo: Khoảng 50.000–100.000đ/tô — xác nhận tại Foody.vn
- Chè Sài Gòn: Chè Sài Gòn (hay chè Nam Bộ) nổi tiếng với hương vị ngọt béo đặc trưng từ nước cốt dừa. Có hàng chục loại: chè đậu đỏ, chè bưởi, chè thập cẩm, chè chuối, sâm bổ lượng... Các xe chè vỉa hè và tiệm chè 
  Địa điểm thưởng thức: [''phố chè Võ Văn Tần (Quận 3)'', ''khu Cholon Quận 5'', ''các xe chè vỉa hè'']
  Giá tham khảo: Khoảng 20.000–50.000đ/ly — xác nhận tại Foody.vn
- Gỏi Cuốn: Gỏi cuốn (chả giò tươi) là món khai vị nhẹ nhàng của ẩm thực Nam Bộ, được du khách quốc tế yêu thích. Bánh tráng ướt cuốn với tôm, thịt luộc, bún, rau sống và chấm với nước mắm hoặc tương hoisin pha đ
  Địa điểm thưởng thức: [''Nhà Hàng Ngon (Pasteur, Quận 1)'', ''các nhà hàng ẩm thực Nam Bộ'', ''chợ ẩm thực đêm'']
  Giá tham khảo: Khoảng 30.000–70.000đ/đĩa (4–6 cuốn) — xác nhận tại Foody.vn', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'ẩm thực', 'đặc sản', 'món ăn'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '2461efff-6666-56e1-817b-627823c1a0a3', 'Cách di chuyển đến TP. Hồ Chí Minh', 'transport', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Di chuyển đến và trong TP. Hồ Chí Minh:

Cách đến:
- AIRPLANE từ Hà Nội (Nội Bài): Khoảng 2 tiếng — None
  Sân bay Tân Sơn Nhất (SGN) cách trung tâm Quận 1 khoảng 7–10km. Có taxi, Grab và xe buýt sân bay về trung tâm.
- AIRPLANE từ Đà Nẵng: Khoảng 1 tiếng 20 phút — None
  Bay thẳng, tần suất nhiều chuyến mỗi ngày.
- TRAIN từ Hà Nội (ga Hà Nội): Khoảng 30–33 tiếng (tàu SE) — None
  Có nhiều loại ghế: ngồi cứng, ngồi mềm, nằm cứng, nằm mềm điều hòa. Tàu SE3/SE4 nhanh nhất. Ga Sài Gòn tại Quận 3.
- BUS từ Cần Thơ: Khoảng 3–4 tiếng — None
  Xe limousine và xe ghế ngồi đều có. Bến xe Miền Tây là điểm đến chính khi từ miền Tây về TPHCM.
- BUS từ Đà Lạt (Lâm Đồng): Khoảng 7–8 tiếng — None
  Có xe giường nằm và xe limousine. Bến xe Miền Đông là điểm đến khi từ miền Trung, Tây Nguyên.

Di chuyển trong thành phố:
- grab: Grab xe máy (GrabBike) và Grab ô tô (GrabCar) là lựa chọn phổ biến và an toàn nhất cho khách du lịch. Giá minh bạch, không cần mặc cả. Phủ sóng toàn thành phố.
- taxi: Hãng taxi uy tín: Vinasun (logo xanh lá), Mai Linh (logo xanh dương). Tránh taxi không thương hiệu hoặc không đồng hồ tính tiền. Luôn yêu cầu bật đồng hồ.
- xe_om: Xe ôm truyền thống còn phổ biến ở các chợ, bến xe. Cần mặc cả và thỏa thuận giá trước. Xe ôm công nghệ (Grab/Be) an toàn và thuận tiện hơn.
- bus: Mạng lưới xe buýt phủ rộng nhưng giờ giấc không ổn định và khó tra cứu cho người lạ. Phù hợp cho người có thời gian và muốn tiết kiệm tối đa. Tra cứu tuyến tại buyttphcm.com.vn.', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'di chuyển', 'phương tiện', 'giao thông'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '09b86e32-3309-5e07-bd9c-4267951cc482', 'Khách sạn & Lưu trú tại TP. Hồ Chí Minh', 'hotel', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Lưu trú tại TP. Hồ Chí Minh:
- Caravelle Saigon (5★): 19-23 Công trường Lam Sơn, Phường Bến Nghé, Quận 1, TP. HCM
  Tiện ích: hồ bơi, spa, nhà hàng, bar mái
- Hotel Nikko Saigon (5★): 235 Nguyễn Văn Cừ, Phường Nguyễn Cư Trinh, Quận 1, TP. HCM
  Tiện ích: hồ bơi ngoài trời, spa, nhà hàng Nhật, phòng gym
- Rex Hotel Saigon (4★): 141 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. HCM
  Tiện ích: hồ bơi mái, nhà hàng, bar, wifi
- Liberty Central Saigon Citypoint (4★): 59-61 Pasteur, Phường Nguyễn Thái Bình, Quận 1, TP. HCM
  Tiện ích: hồ bơi, phòng gym, nhà hàng, bar
- Mango Backpackers Hostel (None★): Khu Phạm Ngũ Lão, Quận 1, TP. HCM
  Tiện ích: wifi, bar, tour booking, máy lạnh', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'khách sạn', 'lưu trú', 'phòng'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '372af9d7-9e17-510e-855c-c8633bc5fe53', 'Tour & Trải nghiệm tại TP. Hồ Chí Minh', 'tour', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Tour & Trải nghiệm tại TP. Hồ Chí Minh:
- Tour Địa Đạo Củ Chi Nửa Ngày: Nửa ngày (khoảng 4–5 tiếng) — liên hệ
  Tour khám phá hệ thống địa đạo lịch sử Củ Chi — di tích quốc gia đặc biệt cách trung tâm ~70km. Hướng dẫn viên giải thích lịch sử kháng chiến, tham quan bẫy địa đạo, thử chui qua đường hầm được mở rộng, xem biểu diễn vũ khí thủ công và thưởng thức kh
- Tour Đồng Bằng Sông Cửu Long 1 Ngày: 1 ngày (khoảng 9–10 tiếng) — liên hệ
  Day trip từ TP. HCM xuống miền Tây sông nước, thường đến Mỹ Tho (Tiền Giang) hoặc Bến Tre. Đi thuyền nhỏ len lỏi các kênh rạch, thăm làng nghề làm kẹo dừa, nghe đờn ca tài tử, ăn trưa miệt vườn với cá tai tượng chiên xù và rau vườn. Trải nghiệm đời s
- Tour Khám Phá Sài Gòn Cổ — Walking & Food Tour: Nửa ngày (khoảng 3–4 tiếng) — liên hệ
  Tour đi bộ khám phá kiến trúc và ẩm thực Sài Gòn xưa, thường xuất phát từ Chợ Bến Thành qua Nhà thờ Đức Bà, Bưu điện Thành phố, phố ẩm thực Phạm Ngũ Lão và khu Chợ Lớn người Hoa. Dọc đường thử nhiều món ăn đường phố như bánh mì, gỏi cuốn, hủ tiếu và ', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'tour', 'trải nghiệm', 'tham quan'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'ad57fc0e-b66f-56b5-822d-4ccedce00498', 'Lễ hội & Sự kiện tại TP. Hồ Chí Minh', 'event', '019eeda8-d830-72fe-8479-3d24a2698ee8',
  'Lễ hội & Sự kiện tại TP. Hồ Chí Minh:
- Tết Nguyên Đán Sài Gòn: Tháng 1 hoặc tháng 2 hàng năm (theo âm lịch, thường 29 tháng Chạp đến mùng 7 Tết)
  Tết Nguyên Đán là lễ hội lớn nhất năm tại TP. HCM. Đường hoa Nguyễn Huệ trưng bày hàng triệu hoa tươi và tác phẩm nghệ thuật suốt 1 tuần trước và sau giao thừa. Pháo hoa bắn tại nhiều điểm trên sông Sài Gòn đêm giao thừa. Chợ hoa Bình Điền và chợ hoa
- Lễ Giỗ Tổ Hùng Vương & Ngày Giải Phóng 30/4: 10 tháng 3 âm lịch (Giỗ Tổ) và 30/4–1/5 hàng năm
  Ngày 30/4 (Giải Phóng Miền Nam) là dịp lễ đặc biệt tại TP. HCM với diễu binh, bắn pháo hoa và các hoạt động văn hóa tại Dinh Độc Lập — địa điểm gắn liền với sự kiện lịch sử 1975. Đây là kỳ nghỉ lễ 4–5 ngày, thành phố rất đông người đổ về tham quan.
- Lễ Hội Áo Dài TP. HCM: Tháng 3 hàng năm (thường tuần đầu tháng 3)
  Lễ Hội Áo Dài là sự kiện văn hóa thường niên do Sở Du lịch TP. HCM tổ chức, tôn vinh trang phục truyền thống Việt Nam. Sự kiện gồm các buổi trình diễn áo dài trên phố đi bộ, triển lãm, workshop may áo dài, và diễu hành tập thể. Du khách được khuyến k
- Lễ Hội Đền Hùng & Carnival Phố Đi Bộ Nguyễn Huệ: Các dịp cuối tuần định kỳ và lễ lớn trong năm
  Phố đi bộ Nguyễn Huệ (mở cửa cuối tuần từ 19:00–24:00 thứ 6, 7, CN và dịp lễ) thường xuyên tổ chức các sự kiện văn hóa, âm nhạc đường phố, triển lãm nghệ thuật và carnival. Đây là không gian sinh hoạt cộng đồng sôi động nhất Sài Gòn — lý tưởng để hòa', ARRAY['tp-ho-chi-minh', 'tp. hồ chí minh', 'tp. hồ chí minh', 'lễ hội', 'sự kiện', 'festival'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  '843e03a8-6553-5c52-b3db-8e22b2cf60e1', 'Tổng quan du lịch Hà Giang', 'destination', '019eed69-50b3-70c8-8345-0c9df484cb9d',
  'Tổng quan Hà Giang (Tuyên Quang):
Vùng đất cực Bắc hùng vĩ với cung đường đèo Mã Pí Lèng ''Đường Hạnh Phúc'', cao nguyên đá Đồng Văn UNESCO, ruộng bậc thang và văn hóa đa dân tộc H''Mông, Dao, Lô Lô đặc sắc.

Mùa đẹp nhất: Tháng 9–11 (hoa tam giác mạch) hoặc tháng 3–5 (hoa đào)
Thời tiết: Lạnh về đêm 10–25°C, sương mù dày đặc sáng sớm, rét đậm tháng 12–2
Ẩm thực: Thắng cố ngựa, mèn mén, rượu ngô Bắc Hà, cháo ấu tẩu, thịt trâu khô, mật ong bạc hà
Ngân sách tham khảo: 1,500,000–5,000,000đ/người', ARRAY['tuyen-quang-ha-giang', 'hà giang', 'tuyên quang', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();
INSERT INTO knowledge_entries (id, title, category, destination_id, content, tags, source, is_active) VALUES (
  'b2979d8e-caa4-5224-b74a-fbb822f9fae4', 'Tổng quan du lịch TP. Vĩnh Long', 'destination', '019eeda8-d830-700b-a117-253a6c24a6f8',
  'Tổng quan TP. Vĩnh Long (Vĩnh Long):
Miền sông nước miệt vườn với cù lao An Bình, chợ nổi và làng nghề gốm đỏ ven sông Cổ Chiên; sau sáp nhập còn có xứ dừa Bến Tre và vùng văn hóa Khmer Trà Vinh với hệ thống chùa Khmer cổ.

Mùa đẹp nhất: Tháng 12–4 (mùa khô, thuận tiện tham quan vườn và sông nước)
Thời tiết: Nóng ẩm 25–34°C, mùa nước nổi tháng 9–11 (vùng lân cận)
Ẩm thực: Cá tai tượng chiên xù, bánh xèo miền Tây, trái cây miệt vườn, bưởi Năm Roi
Ngân sách tham khảo: ', ARRAY['vinh-long', 'tp. vĩnh long', 'vĩnh long', 'tổng quan', 'mùa du lịch', 'thời tiết'], 'kb_import', TRUE
) ON CONFLICT (id) DO UPDATE SET content=EXCLUDED.content, tags=EXCLUDED.tags, updated_at=NOW();

-- Queue embedding jobs cho tất cả entries vừa import
INSERT INTO embedding_jobs (entity_type, entity_id, status, created_at, updated_at)
SELECT 'knowledge_entry', id, 'pending', NOW(), NOW()
FROM knowledge_entries
WHERE source = 'kb_import'
  AND id NOT IN (SELECT entity_id FROM embedding_jobs WHERE entity_type='knowledge_entry')
ON CONFLICT DO NOTHING;