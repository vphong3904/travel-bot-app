from pathlib import Path
import re
import json

# seed_data.py
# ============================================================
#  Toàn bộ dữ liệu mẫu — load từ JSON files + KNOWLEDGE_BASE
#  + Destinations, Hotels, Tours, Tickets, Users
# ============================================================

# ------------------------------------------------------------------
# KNOWLEDGE ENTRIES — 24 tài liệu RAG (đúng theo JSX gốc)
# ------------------------------------------------------------------
KNOWLEDGE_ENTRIES = [
    {
        "title": "Thời tiết Đà Lạt theo mùa",
        "category": "weather",
        "destination": "Đà Lạt",
        "content": (
            "Đà Lạt có khí hậu mát mẻ quanh năm. "
            "Mùa khô (tháng 11-3): nắng đẹp, hoa dã quỳ nở rộ tháng 11-12. "
            "Mùa mưa (tháng 4-10): mưa chiều, sương mù dày buổi sáng. "
            "Nhiệt độ trung bình 15-25°C."
        ),
        "tags": "thời tiết,mùa du lịch,đà lạt",
    },
    {
        "title": "Chi phí du lịch Phú Quốc 3 ngày 2 đêm",
        "category": "budget",
        "destination": "Phú Quốc",
        "content": (
            "Ngân sách tiết kiệm: 3-5 triệu/người (homestay, ăn quán). "
            "Tầm trung: 6-10 triệu (khách sạn 3-4 sao, tour). "
            "Cao cấp: 12-20 triệu (resort 5 sao, VinWonders). "
            "Vé máy bay khứ hồi SGN-PQC: 1.5-3 triệu."
        ),
        "tags": "chi phí,ngân sách,phú quốc",
    },
    {
        "title": "Ẩm thực Hà Giang đặc sắc",
        "category": "cuisine",
        "destination": "Hà Giang",
        "content": (
            "Thắng cố - món ăn truyền thống người Mông. "
            "Bánh tam giác mạch - đặc sản mùa thu. "
            "Thịt trâu gác bếp - đặc sản cao nguyên. "
            "Rượu ngô - thức uống truyền thống dân tộc H'Mông."
        ),
        "tags": "ẩm thực,hà giang,đặc sản",
    },
    {
        "title": "Kinh nghiệm du lịch Hội An",
        "category": "tips",
        "destination": "Hội An",
        "content": (
            "Nên đi phố cổ buổi tối để ngắm đèn lồng lung linh. "
            "Thuê xe đạp khám phá làng gốm Thanh Hà. "
            "Mua vé tham quan phố cổ 120.000đ (5 điểm). "
            "Tránh mùa mưa bão tháng 9-12. "
            "Mặc trang phục kín đáo khi vào chùa."
        ),
        "tags": "kinh nghiệm,hội an,tips",
    },
    {
        "title": "Lịch trình Phú Quốc 3 ngày 2 đêm gia đình",
        "category": "itinerary",
        "destination": "Phú Quốc",
        "content": (
            "Ngày 1: Đáp sân bay Phú Quốc, nhận phòng, Grand World buổi chiều, chợ đêm Dinh Cậu tối. "
            "Ngày 2: Bãi Sao buổi sáng bơi lội, VinWonders cả ngày vui chơi. "
            "Ngày 3: Nhà tù Phú Quốc, mua quà lưu niệm, ra sân bay."
        ),
        "tags": "lịch trình,phú quốc,gia đình,3 ngày 2 đêm",
    },
    {
        "title": "Lịch trình Đà Lạt 2 ngày 1 đêm cặp đôi",
        "category": "itinerary",
        "destination": "Đà Lạt",
        "content": (
            "Ngày 1: Hồ Xuân Hương buổi sáng, Dinh Bảo Đại trưa, Thung lũng Tình Yêu chiều, chợ đêm Đà Lạt tối. "
            "Ngày 2: Langbiang sáng sớm chinh phục đỉnh núi, cafe view đẹp buổi trưa, mua bánh tráng nướng về."
        ),
        "tags": "lịch trình,đà lạt,cặp đôi,2 ngày 1 đêm",
    },
    {
        "title": "Phương tiện di chuyển Hà Giang",
        "category": "transport",
        "destination": "Hà Giang",
        "content": (
            "Từ Hà Nội: xe khách giường nằm 8-10 tiếng (250-350k). "
            "Thuê xe máy tại Hà Giang: 150-200k/ngày, nên chọn xe số. "
            "Tour xe ô tô 3 ngày: 2-3 triệu/người. "
            "Lưu ý: đèo dốc nguy hiểm, cần kinh nghiệm lái xe."
        ),
        "tags": "di chuyển,hà giang,xe máy,phương tiện",
    },
    {
        "title": "Điểm đến theo sở thích biển",
        "category": "recommendation",
        "destination": "",
        "content": (
            "Biển đẹp nổi tiếng: Phú Quốc, Nha Trang, Quy Nhơn, Phú Yên. "
            "Biển yên tĩnh ít người: Côn Đảo, Bình Ba, Lý Sơn. "
            "Biển gần TP.HCM: Vũng Tàu, Mũi Né, Bình Thuận. "
            "Mùa hè tháng 6-8 đẹp nhất cho biển miền Trung."
        ),
        "tags": "tư vấn,biển,sở thích",
    },
    {
        "title": "Điểm đến theo sở thích núi",
        "category": "recommendation",
        "destination": "",
        "content": (
            "Núi cao thử thách: Fansipan Sa Pa (3143m), Langbiang Đà Lạt. "
            "Trekking đẹp: Hà Giang, Pu Luong, Pù Mát. "
            "Ruộng bậc thang vàng: Mù Cang Chải tháng 9-10, Hoàng Su Phì tháng 8-9."
        ),
        "tags": "tư vấn,núi,sở thích,trekking",
    },
    {
        "title": "Điểm đến phù hợp ngân sách thấp",
        "category": "recommendation",
        "destination": "",
        "content": (
            "Ngân sách dưới 3 triệu: Đà Lạt, Ninh Bình, Vũng Tàu, Hà Giang tự túc. "
            "3-5 triệu: Hội An, Nha Trang, Sa Pa. "
            "Trên 5 triệu: Phú Quốc, combo Đà Nẵng-Hội An, Hạ Long du thuyền."
        ),
        "tags": "tư vấn,ngân sách,điểm đến,tiết kiệm",
    },
    {
        "title": "Visa và nhập cảnh Việt Nam",
        "category": "visa",
        "destination": "",
        "content": (
            "Công dân ASEAN được miễn visa 14-30 ngày tùy quốc gia. "
            "Châu Âu, Mỹ, Úc, Nhật cần xin e-visa trên evisa.xuatnhapcanh.gov.vn. "
            "Hộ chiếu cần còn hạn ít nhất 6 tháng. "
            "Khai báo hải quan điện tử khi nhập cảnh."
        ),
        "tags": "visa,nhập cảnh,hộ chiếu,e-visa,quốc tế",
    },
    {
        "title": "Thời tiết Đà Nẵng theo mùa",
        "category": "weather",
        "destination": "Đà Nẵng",
        "content": (
            "Mùa khô (tháng 2-8): nắng đẹp, thích hợp tắm biển và thăm Bà Nà Hills. "
            "Mùa mưa (tháng 9-12): mưa rào ngắn, giá dịch vụ thấp hơn. "
            "Nhiệt độ trung bình 25-33°C. Tháng 10 có nguy cơ bão."
        ),
        "tags": "đà nẵng,thời tiết,mùa khô,mùa mưa",
    },
    {
        "title": "Ẩm thực Phú Quốc nên thử",
        "category": "cuisine",
        "destination": "Phú Quốc",
        "content": (
            "Gỏi cá trích ăn kèm bánh tráng, nhum biển nướng mỡ hành, "
            "bún kèn đặc sản, bún quậy Kiến Xây. "
            "Hải sản tươi tại chợ Dương Đông và bãi Khem. "
            "Nước mắm Phú Quốc là đặc sản quốc tế nổi tiếng. "
            "Giá hải sản 150.000-500.000đ/kg."
        ),
        "tags": "phú quốc,ẩm thực,hải sản,đặc sản",
    },
    {
        "title": "Lưu ý khi trek Sa Pa",
        "category": "tips",
        "destination": "Sa Pa",
        "content": (
            "Mang giày chống trượt chuyên dụng, áo khoác dày vì nhiệt độ có thể xuống 5°C ban đêm. "
            "Thuê porter địa phương nếu mang hành lý nặng (200.000-300.000đ/ngày). "
            "Đặt homestay trước mùa cao điểm tháng 9-11 ít nhất 1 tháng. "
            "Cần mua vé cáp treo hoặc đăng ký leo Fansipan."
        ),
        "tags": "sa pa,trek,fansipan,lưu ý,leo núi",
    },
    {
        "title": "Phí tham quan phố cổ Hội An",
        "category": "pricing",
        "destination": "Hội An",
        "content": (
            "Vé tham quan phố cổ 120.000đ/người, sử dụng trong 24 giờ cho 5 điểm di tích tự chọn. "
            "Miễn phí vào phố đi bộ sau 21h hàng ngày. "
            "Phí đèn hoa đăng: 20.000-50.000đ/chiếc thả sông. "
            "Nên thuê xe đạp 30.000đ/ngày để di chuyển."
        ),
        "tags": "hội an,vé,phí,phố cổ,giá cả",
    },
    {
        "title": "Du thuyền Hạ Long chọn tàu nào?",
        "category": "tips",
        "destination": "Hạ Long",
        "content": (
            "Tàu 3-4 sao: 1.200.000-2.500.000đ/người cho 1 ngày. "
            "Tàu 5 sao luxury: 3.500.000-8.000.000đ cho 2 ngày 1 đêm. "
            "Nên chọn tàu có giấy phép của UBND Quảng Ninh để đảm bảo an toàn. "
            "Tàu nhỏ 20-30 khách trải nghiệm tốt hơn tàu lớn ồn ào."
        ),
        "tags": "hạ long,du thuyền,tàu,giá,kinh nghiệm",
    },
    {
        "title": "Di chuyển giữa các thành phố du lịch",
        "category": "transport",
        "destination": "",
        "content": (
            "Hà Nội - Đà Nẵng: bay 1h15 (1.500.000đ) hoặc tàu hỏa SE 16h (700.000đ). "
            "Đà Nẵng - Hội An: xe bus 30 phút giá 30.000đ. "
            "Nha Trang - Đà Lạt: xe limousine 3-4h giá 250.000đ. "
            "Đặt vé sớm dịp lễ 30/4, 2/9, Tết ít nhất 3 tháng."
        ),
        "tags": "di chuyển,xe bus,máy bay,tàu hỏa,liên tỉnh",
    },
    {
        "title": "Mùa lúa chín Sa Pa khi nào?",
        "category": "weather",
        "destination": "Sa Pa",
        "content": (
            "Ruộng bậc thang chuyển vàng đẹp nhất cuối tháng 9 đến đầu tháng 11 hàng năm. "
            "Mùa xuân tháng 3-5 ruộng nước phản chiếu bầu trời và mây xanh rất lãng mạn. "
            "Tránh đi tháng 7-8 vì mưa nhiều, sương mù che khuất toàn bộ view ruộng bậc thang."
        ),
        "tags": "sa pa,ruộng bậc thang,mùa lúa chín,thời tiết,mùa vàng",
    },
    {
        "title": "Đà Lạt - Thành phố ngàn hoa",
        "category": "destination_info",
        "destination": "Đà Lạt",
        "content": (
            "Thành phố Đà Lạt thuộc tỉnh Lâm Đồng, cao 1500m so với mực nước biển. "
            "Nổi tiếng với hoa hydrangea, mimosa, atiso. "
            "Kiến trúc Pháp cổ như Ga Đà Lạt, Dinh Bảo Đại. "
            "Chi phí 800.000-5.000.000đ/người. "
            "Điểm nổi bật: Hồ Xuân Hương, Thung lũng Tình Yêu, Langbiang, Chợ Đà Lạt."
        ),
        "tags": "đà lạt,thông tin,địa điểm,lâm đồng",
    },
    {
        "title": "Phú Quốc - Đảo ngọc Kiên Giang",
        "category": "destination_info",
        "destination": "Phú Quốc",
        "content": (
            "Phú Quốc là đảo lớn nhất Việt Nam thuộc tỉnh Kiên Giang. "
            "Bãi biển trong xanh, resort sang trọng, nước mắm nổi tiếng. "
            "Chi phí 1.500.000-15.000.000đ/người. "
            "Điểm nổi bật: Bãi Sao, Grand World, VinWonders, Chợ đêm Dinh Cậu, Nhà tù Phú Quốc."
        ),
        "tags": "phú quốc,thông tin,đảo,kiên giang",
    },
    {
        "title": "Hội An - Phố cổ UNESCO",
        "category": "destination_info",
        "destination": "Hội An",
        "content": (
            "Hội An được UNESCO công nhận Di sản văn hóa thế giới năm 1999. "
            "Phố cổ với đèn lồng lung linh, kiến trúc Nhật-Trung-Việt hòa quyện. "
            "Chi phí 600.000-4.000.000đ/người. Mùa đẹp nhất tháng 2-4. "
            "Nổi bật: chùa Cầu, phố đi bộ, hội quán Phúc Kiến, làng gốm Thanh Hà."
        ),
        "tags": "hội an,phố cổ,unesco,quảng nam",
    },
    {
        "title": "Hà Giang - Vùng địa đầu Tổ quốc",
        "category": "destination_info",
        "destination": "Hà Giang",
        "content": (
            "Hà Giang nằm cực Bắc Việt Nam, tiếp giáp Trung Quốc. "
            "Cao nguyên đá Đồng Văn là Công viên địa chất toàn cầu UNESCO. "
            "Chi phí 500.000-3.000.000đ/người. "
            "Đẹp nhất: tháng 9-11 hoa tam giác mạch. "
            "Điểm nổi bật: đèo Mã Pí Lèng, cột cờ Lũng Cú, phố cổ Đồng Văn."
        ),
        "tags": "hà giang,địa đầu,tổ quốc,cao nguyên đá",
    },
    {
        "title": "Khách sạn Đà Lạt gợi ý",
        "category": "hotel",
        "destination": "Đà Lạt",
        "content": (
            "Dalat Palace Heritage Hotel: 5 sao, 2.500.000đ/đêm, view hồ Xuân Hương đẹp nhất. "
            "Homestay The Kupid: 4.5 sao, 600.000đ/đêm, decor vintage Pháp. "
            "Ana Mandara Villas: villa biệt lập, 3.000.000đ/đêm. "
            "Khách sạn Mimosa: tầm trung 800.000đ/đêm."
        ),
        "tags": "khách sạn,homestay,đà lạt,nơi ở",
    },
    {
        "title": "Khách sạn Phú Quốc gợi ý",
        "category": "hotel",
        "destination": "Phú Quốc",
        "content": (
            "JW Marriott Phu Quoc: resort 5 sao, 8.500.000đ/đêm, bãi biển riêng. "
            "Premier Village Phu Quoc: biệt thự bãi biển 6.000.000đ/đêm. "
            "Homestay Mango Bay: 4.3 sao, 800.000đ/đêm, nguyên sinh tự nhiên. "
            "La Veranda Resort: 5 sao boutique 4.500.000đ/đêm."
        ),
        "tags": "khách sạn,resort,phú quốc,nơi ở",
    },
    # --- Bổ sung thêm để phong phú hơn ---
    {
        "title": "Ẩm thực Hội An đặc sắc",
        "category": "cuisine",
        "destination": "Hội An",
        "content": (
            "Cao lầu - món đặc sản chỉ có ở Hội An. "
            "Mì Quảng - sợi mì vàng với nước dùng đậm đà. "
            "Bánh mì Phượng - nổi tiếng thế giới. "
            "Cơm gà Hội An - thịt gà mềm, cơm vàng thơm. "
            "Bánh bao bánh vạc (White Rose) - đặc sản tinh tế. "
            "Giá ăn uống bình dân 30.000-80.000đ/món."
        ),
        "tags": "hội an,ẩm thực,đặc sản,cao lầu,mì quảng",
    },
    {
        "title": "Lịch trình Hà Nội 3 ngày 2 đêm",
        "category": "itinerary",
        "destination": "Hà Nội",
        "content": (
            "Ngày 1: Hồ Hoàn Kiếm, Đền Ngọc Sơn, phố cổ 36 phố phường, bia hơi Tạ Hiện tối. "
            "Ngày 2: Lăng Chủ tịch Hồ Chí Minh, Văn Miếu Quốc Tử Giám, bảo tàng Dân tộc học. "
            "Ngày 3: Chùa Hương hoặc làng cổ Đường Lâm, mua quà đặc sản về."
        ),
        "tags": "lịch trình,hà nội,3 ngày 2 đêm",
    },
    {
        "title": "Kinh nghiệm đi Sa Pa tự túc",
        "category": "tips",
        "destination": "Sa Pa",
        "content": (
            "Đặt homestay ở bản Cát Cát hoặc Tả Van để trải nghiệm văn hóa H'Mông. "
            "Thuê xe máy tại thị trấn 150-200k/ngày để chủ động. "
            "Trekking bản Lao Chải - Tả Van khoảng 10km, mất 4-5 tiếng. "
            "Mua đặc sản: rượu táo mèo, thổ cẩm, rau rừng, lê giòn. "
            "Mùa cao điểm tháng 9-11 cần đặt phòng trước 1-2 tháng."
        ),
        "tags": "sa pa,kinh nghiệm,tự túc,homestay,trekking",
    },
    {
        "title": "Chi phí du lịch Đà Lạt tiết kiệm",
        "category": "budget",
        "destination": "Đà Lạt",
        "content": (
            "Homestay tầm trung: 200.000-500.000đ/đêm. "
            "Xe máy thuê: 120.000-180.000đ/ngày. "
            "Ăn uống: bánh tráng nướng 15.000đ, phở 40.000đ, bò né 60.000đ. "
            "Vé tham quan: Thung lũng Tình Yêu 100.000đ, Langbiang 50.000đ. "
            "Tổng chi phí 2 ngày 1 đêm tiết kiệm: 1.200.000-2.000.000đ/người."
        ),
        "tags": "đà lạt,chi phí,tiết kiệm,ngân sách thấp",
    },
    {
        "title": "Bãi biển đẹp Nha Trang",
        "category": "destination_info",
        "destination": "Nha Trang",
        "content": (
            "Nha Trang có 6km bãi biển cong hình vịnh tuyệt đẹp. "
            "Lặn biển ngắm san hô tại Hòn Mun, Hòn Tằm. "
            "Vịnh Nha Trang được bình chọn 1 trong 29 vịnh đẹp nhất thế giới. "
            "Điểm tham quan: tháp Chàm Ponagar, chùa Long Sơn, Vinpearl Land. "
            "Mùa đẹp nhất: tháng 1-8, tránh mùa mưa tháng 9-12."
        ),
        "tags": "nha trang,biển,lặn biển,san hô",
    },
    {
        "title": "Kinh nghiệm mua sắm Đà Nẵng",
        "category": "tips",
        "destination": "Đà Nẵng",
        "content": (
            "Chợ Hàn - mua đặc sản, bánh tráng, mắm ruốc, hải sản khô. "
            "Vincom Đà Nẵng - trung tâm thương mại hiện đại. "
            "Phố Bạch Đằng - cà phê ven sông Hàn view đẹp. "
            "Đặc sản mang về: khô bò, mực khô, nước mắm Nam Ô, bánh tráng cuốn thịt heo. "
            "Giá cả bình dân hơn Hội An 20-30%."
        ),
        "tags": "đà nẵng,mua sắm,chợ,đặc sản,tips",
    },
    {
        "title": "Thời tiết Hà Nội theo mùa",
        "category": "weather",
        "destination": "Hà Nội",
        "content": (
            "Hà Nội mùa xuân (tháng 2-4): mát ẩm, hoa đào nở; "
            "mùa hè (tháng 5-8): nóng 30-38°C, mưa rào buổi chiều; "
            "mùa thu (tháng 9-11): dễ chịu, trời hanh; "
            "mùa đông (tháng 12-1): lạnh 12-18°C, cần áo ấm."
        ),
        "tags": "hà nội,thời tiết,mùa xuân,mùa hè,mùa thu,mùa đông",
    },
    {
        "title": "Ẩm thực Hà Nội nên thử",
        "category": "cuisine",
        "destination": "Hà Nội",
        "content": (
            "Phở bò Hà Nội, bún chả, bún thang, và bánh cuốn là những món must-try. "
            "Kem Tràng Tiền, trà đá vỉa hè, và cốm là đặc sản đường phố. "
            "Nên thử quán Phở Bát Đàn, Bún chả Hàng Mành, và Bánh cuốn Bà Hoành."
        ),
        "tags": "hà nội,ẩm thực,phở,bún chả,cốm",
    },
    {
        "title": "Hành trình Đà Nẵng - Hội An 4 ngày",
        "category": "itinerary",
        "destination": "Đà Nẵng",
        "content": (
            "Ngày 1: tham quan Cầu Rồng, công viên Châu Á, biển Mỹ Khê. "
            "Ngày 2: bay Bà Nà Hills, Golden Bridge, làng Pháp. "
            "Ngày 3: về Hội An, tham quan phố cổ, chùa Cầu, làng gốm Thanh Hà. "
            "Ngày 4: tắm biển An Bàng, chợ đêm Hội An, về Đà Nẵng hoặc tiếp tục hành trình."
        ),
        "tags": "lịch trình,đà nẵng,hội an,4 ngày",
    },
    {
        "title": "Mua sim và internet ở Việt Nam",
        "category": "tips",
        "destination": "",
        "content": (
            "Mua sim 4G/5G tại sân bay hoặc cửa hàng Viettel, Mobifone, Vinaphone. "
            "Giá sim du lịch 1-7 ngày từ 50.000đ đến 200.000đ. "
            "Nên đem theo giấy tờ tùy thân để đăng ký. "
            "Dùng ứng dụng eSIM nếu điện thoại hỗ trợ để tiết kiệm thời gian."
        ),
        "tags": "sim,4g,5g,internet,du lịch,viettel,mobifone",
    },
    {
        "title": "Đổi tiền và thanh toán tại Việt Nam",
        "category": "tips",
        "destination": "",
        "content": (
            "Đổi tiền USD hoặc EUR sang VND tại ngân hàng, tiệm vàng hoặc sân bay. "
            "Nên đổi ở ngân hàng lớn để có tỷ giá tốt và an toàn. "
            "Hầu hết nơi du lịch chấp nhận thẻ tín dụng, nhưng nên có tiền mặt cho taxi, quán nhỏ. "
            "Ứng dụng Momo, ZaloPay, ViettelPay được chấp nhận rộng rãi tại thành phố lớn."
        ),
        "tags": "đổi tiền,thanh toán,momo,zalo pay,viettelpay,tiền mặt",
    },
    {
        "title": "Thông tin du lịch Hạ Long",
        "category": "destination_info",
        "destination": "Hạ Long",
        "content": (
            "Hạ Long nằm ở Quảng Ninh, nổi tiếng vịnh biển và hang động đá vôi. "
            "Du thuyền 2 ngày 1 đêm trên vịnh là trải nghiệm phổ biến. "
            "Tham quan hang Sửng Sốt, đảo Titop, làng chài Cửa Vạn. "
            "Mùa đẹp nhất: tháng 3-7, tránh bão tháng 8-10."
        ),
        "tags": "hạ long,vịnh,hải phòng,du lịch,bãi biển",
    },
    {
        "title": "Chi phí du lịch Ninh Bình 2 ngày 1 đêm",
        "category": "budget",
        "destination": "Ninh Bình",
        "content": (
            "Ngân sách tiết kiệm: 700.000-1.200.000đ/người với homestay, xe đạp và ăn quán. "
            "Bao gồm vé Tam Cốc, Tràng An, chùa Bái Đính. "
            "Xe ôm, xe đạp thuê khoảng 100.000-150.000đ/ngày. "
            "Ăn uống địa phương khoảng 80.000-150.000đ/bữa."
        ),
        "tags": "ninh bình,chi phí,budget,tiết kiệm",
    },
    {
        "title": "Tuyến bay nội địa phổ biến",
        "category": "transport",
        "destination": "",
        "content": (
            "Hà Nội - Đà Nẵng: 1h15, giá 800.000-1.500.000đ. "
            "Hà Nội - Phú Quốc: 2h00, giá 1.200.000-2.500.000đ. "
            "TP.HCM - Đà Lạt: 1h10, giá 600.000-1.200.000đ. "
            "TP.HCM - Cần Thơ: 1h00, giá 500.000-900.000đ."
        ),
        "tags": "máy bay,nội địa,chặng bay,giá vé",
    },
    {
        "title": "Đà Nẵng di chuyển giữa thành phố",
        "category": "transport",
        "destination": "Đà Nẵng",
        "content": (
            "Xe bus công cộng và Grab là lựa chọn tiện lợi. "
            "Taxi từ sân bay vào trung tâm khoảng 300.000-400.000đ. "
            "Xe đạp và xe máy thuê là cách hay để khám phá phố cổ. "
            "Cầu Rồng, cầu Sông Hàn là điểm nổi bật nên đi buổi tối."
        ),
        "tags": "đà nẵng,di chuyển,grab,taxi,xe đạp",
    },
    {
        "title": "Du lịch Sài Gòn 2 ngày 1 đêm",
        "category": "itinerary",
        "destination": "Hồ Chí Minh",
        "content": (
            "Ngày 1: tham quan Nhà thờ Đức Bà, Bưu điện Trung tâm, chợ Bến Thành, ăn uống ở quận 1. "
            "Ngày 2: thăm Bảo tàng Chứng tích Chiến tranh, phố đi bộ Nguyễn Huệ, lên Landmark 81. "
            "Ăn uống: cơm tấm, hủ tiếu Nam Vang, bánh mì Huỳnh Hoa."
        ),
        "tags": "hồ chí minh,sài gòn,lịch trình,2 ngày 1 đêm",
    },
    {
        "title": "Ẩm thực Sài Gòn nên thử",
        "category": "cuisine",
        "destination": "Hồ Chí Minh",
        "content": (
            "Cơm tấm sườn, bánh mì, hủ tiếu, bún thịt nướng, và chè là những món không thể bỏ qua. "
            "Nên ăn khu Bùi Viện, quận 1, và các quán vỉa hè ở quận 4, quận 5. "
            "Đặc biệt: hủ tiếu nam vang, bún riêu, cuốn tôm thịt."
        ),
        "tags": "sài gòn,ẩm thực,hồ chí minh,ăn uống",
    },
    {
        "title": "Mẹo du lịch an toàn mùa mưa bão",
        "category": "tips",
        "destination": "",
        "content": (
            "Theo dõi dự báo thời tiết và hạn chế đi biển, đèo trong bão. "
            "Chuẩn bị áo mưa, giày chống trượt và sao lưu giấy tờ quan trọng. "
            "Chọn khách sạn có lối thoát hiểm rõ ràng và tránh vùng dễ ngập. "
            "Đặt tour và xe cộ linh hoạt để dễ hoãn, huỷ khi thời tiết xấu."
        ),
        "tags": "mưa bão,an toàn,du lịch,mẹo",
    },
]


def load_kb_entries_from_md(md_path: Path) -> list[dict]:
    text = md_path.read_text(encoding="utf-8")
    blocks = [block.strip() for block in text.split("\n---\n") if block.strip()]
    entries: list[dict] = []

    for block in blocks:
        lines = block.splitlines()
        if not lines:
            continue

        title_line = lines[0].strip()
        if title_line.startswith("### "):
            title = title_line[4:].strip()
        else:
            title = title_line

        metadata: dict[str, str] = {}
        content_lines: list[str] = []
        in_content = False

        for line in lines[1:]:
            if in_content:
                content_lines.append(line)
                continue

            stripped = line.strip()
            if stripped.startswith("category:"):
                metadata["category"] = stripped.split(":", 1)[1].strip()
            elif stripped.startswith("destination:"):
                metadata["destination"] = stripped.split(":", 1)[1].strip()
            elif stripped.startswith("tags:"):
                metadata["tags"] = stripped.split(":", 1)[1].strip()
            elif stripped == "content:":
                in_content = True

        content = "\n".join([line.strip() for line in content_lines if line.strip()])
        if not content:
            continue

        entries.append(
            {
                "title": title,
                "category": metadata.get("category", "destination_info"),
                "destination": metadata.get("destination", ""),
                "content": content,
                "tags": metadata.get("tags", ""),
            }
        )

    return entries


KB_DIR = Path(__file__).parent / "kb"
KB_MD_FILE = Path(__file__).parent / "kb_data.md"
KB_MARKDOWN_ENTRIES: list[dict] = []
if KB_DIR.exists():
    for md_file in sorted(KB_DIR.glob("*.md")):
        KB_MARKDOWN_ENTRIES.extend(load_kb_entries_from_md(md_file))

if KB_MD_FILE.exists():
    KB_MARKDOWN_ENTRIES.extend(load_kb_entries_from_md(KB_MD_FILE))

if KB_MARKDOWN_ENTRIES:
    KNOWLEDGE_ENTRIES += KB_MARKDOWN_ENTRIES

# ------------------------------------------------------------------
# DESTINATIONS — 8 điểm đến chính
# ------------------------------------------------------------------
DESTINATIONS = [
    {
        "name": "Đà Lạt",
        "region": "Lâm Đồng",
        "description": (
            "Thành phố cao nguyên mát mẻ nằm ở độ cao 1500m, nổi tiếng với hoa, "
            "thông xanh và kiến trúc Pháp cổ. Điểm lý tưởng cho cặp đôi và gia đình."
        ),
        "highlights": "Hồ Xuân Hương, Thung lũng Tình Yêu, Langbiang, Dinh Bảo Đại, Chợ Đà Lạt, Ga Đà Lạt",
        "best_season": "Tháng 11-3 (mùa khô, hoa nở rộ)",
        "weather": "Mát mẻ quanh năm 15-25°C, mùa mưa tháng 4-10",
        "cuisine": "Bánh tráng nướng, bơ, dâu tây, hồng sấy, cơm lam, rượu vang",
        "budget_low": 800000,
        "budget_high": 5000000,
        "tags": "núi,hoa,mát mẻ,cặp đôi,gia đình",
        "image_url": "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800",
    },
    {
        "name": "Phú Quốc",
        "region": "Kiên Giang",
        "description": (
            "Đảo ngọc lớn nhất Việt Nam với bãi biển trong xanh, resort sang trọng "
            "và nước mắm nổi tiếng thế giới. Thiên đường nghỉ dưỡng hàng đầu."
        ),
        "highlights": "Bãi Sao, Grand World, VinWonders, Chợ đêm Dinh Cậu, Nhà tù Phú Quốc, Vinpearl Safari",
        "best_season": "Tháng 11-4 (mùa khô, biển đẹp)",
        "weather": "Nhiệt đới 27-33°C, mùa mưa tháng 5-10",
        "cuisine": "Gỏi cá trích, nhum biển, bún kèn, bún quậy, nước mắm Phú Quốc",
        "budget_low": 1500000,
        "budget_high": 15000000,
        "tags": "biển,resort,gia đình,sang trọng,đảo",
        "image_url": "https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?w=800",
    },
    {
        "name": "Hội An",
        "region": "Quảng Nam",
        "description": (
            "Phố cổ UNESCO với đèn lồng lung linh, kiến trúc giao thoa Nhật-Trung-Việt "
            "và ẩm thực phong phú. Điểm đến văn hóa hàng đầu Việt Nam."
        ),
        "highlights": "Chùa Cầu, phố đi bộ, hội quán Phúc Kiến, làng gốm Thanh Hà, biển An Bàng",
        "best_season": "Tháng 2-4 (ít mưa, mát mẻ)",
        "weather": "Nhiệt đới 25-35°C, mùa mưa tháng 9-12",
        "cuisine": "Cao lầu, mì Quảng, bánh mì Phượng, cơm gà, White Rose",
        "budget_low": 600000,
        "budget_high": 4000000,
        "tags": "văn hóa,ẩm thực,phố cổ,unesco,lịch sử",
        "image_url": "https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?w=800",
    },
    {
        "name": "Hà Giang",
        "region": "Hà Giang",
        "description": (
            "Vùng địa đầu Tổ quốc với cao nguyên đá hùng vĩ, ruộng bậc thang mùa vàng "
            "và văn hóa các dân tộc thiểu số độc đáo. Thiên đường của dân phượt."
        ),
        "highlights": "Đèo Mã Pí Lèng, cột cờ Lũng Cú, phố cổ Đồng Văn, cao nguyên đá Đồng Văn",
        "best_season": "Tháng 9-11 (hoa tam giác mạch, ruộng bậc thang vàng)",
        "weather": "Mát mẻ 15-25°C, mùa đông lạnh, sương mù dày",
        "cuisine": "Thắng cố, bánh tam giác mạch, thịt trâu gác bếp, rượu ngô",
        "budget_low": 500000,
        "budget_high": 3000000,
        "tags": "núi,khám phá,trek,phượt,dân tộc",
        "image_url": "https://images.unsplash.com/photo-1606814893907-4b55d46d1ed0?w=800",
    },
    {
        "name": "Sa Pa",
        "region": "Lào Cai",
        "description": (
            "Thị trấn mù sương nơi có Fansipan - nóc nhà Đông Dương, ruộng bậc thang "
            "kỳ vĩ và văn hóa người H'Mông, Dao đỏ đặc sắc."
        ),
        "highlights": "Fansipan 3143m, ruộng bậc thang Mù Cang Chải, bản Cát Cát, chợ phiên Sa Pa",
        "best_season": "Tháng 9-11 (lúa chín vàng), tháng 3-5 (mùa xuân)",
        "weather": "Mát 10-22°C mùa hè, lạnh 2-10°C mùa đông",
        "cuisine": "Cá hồi Sa Pa, thịt lợn cắp nách, rượu táo mèo, bánh ngô nướng",
        "budget_low": 1000000,
        "budget_high": 5000000,
        "tags": "núi,ruộng bậc thang,trekking,fansipan,văn hóa",
        "image_url": "https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800",
    },
    {
        "name": "Đà Nẵng",
        "region": "Đà Nẵng",
        "description": (
            "Thành phố biển hiện đại với cầu Rồng nổi tiếng, bãi biển Mỹ Khê xếp hạng "
            "đẹp nhất châu Á và cổng vào Bà Nà Hills huyền bí."
        ),
        "highlights": "Cầu Rồng, Bà Nà Hills, biển Mỹ Khê, Ngũ Hành Sơn, Bán đảo Sơn Trà",
        "best_season": "Tháng 2-8 (nắng đẹp, biển lặng)",
        "weather": "Nhiệt đới 25-33°C, mùa mưa tháng 9-12",
        "cuisine": "Mì Quảng, bún chả cá, bánh xèo, hải sản tươi, bánh tráng cuốn thịt heo",
        "budget_low": 1000000,
        "budget_high": 8000000,
        "tags": "biển,đô thị,cầu rồng,hiện đại,ẩm thực",
        "image_url": "https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=800",
    },
    {
        "name": "Hạ Long",
        "region": "Quảng Ninh",
        "description": (
            "Di sản thiên nhiên thế giới UNESCO với hàng nghìn đảo đá vôi hùng vĩ, "
            "hang động kỳ bí và trải nghiệm du thuyền đêm độc đáo."
        ),
        "highlights": "Hang Sửng Sốt, Hang Đầu Gỗ, Vịnh Lan Hạ, đảo Tuần Châu, chợ nổi",
        "best_season": "Tháng 10-4 (thời tiết mát, ít mưa)",
        "weather": "Nhiệt đới 18-28°C, mùa hè oi bức, đông lạnh",
        "cuisine": "Hải sản tươi sống, sam biển, sứa, ngán, bánh cuốn Hạ Long",
        "budget_low": 2000000,
        "budget_high": 10000000,
        "tags": "vịnh,du thuyền,unesco,hang động,thiên nhiên",
        "image_url": "https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=800",
    },
    {
        "name": "Nha Trang",
        "region": "Khánh Hòa",
        "description": (
            "Thành phố biển sôi động với vịnh biển trong vắt, lặn ngắm san hô "
            "và hệ thống đảo đẹp. Trung tâm du lịch biển miền Trung."
        ),
        "highlights": "Vịnh Nha Trang, Hòn Mun, tháp Chàm Ponagar, Vinpearl Land, chùa Long Sơn",
        "best_season": "Tháng 1-8 (biển lặng, nắng đẹp)",
        "weather": "Nhiệt đới 26-32°C, mùa mưa tháng 9-12",
        "cuisine": "Bún cá, bánh canh chả cá, nem nướng, hải sản, yến sào",
        "budget_low": 1000000,
        "budget_high": 6000000,
        "tags": "biển,lặn biển,san hô,đảo,resort",
        "image_url": "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=800",
    },
]

# ------------------------------------------------------------------
# HOTELS — Khách sạn mẫu
# ------------------------------------------------------------------
HOTELS = [
    # Đà Lạt
    {
        "name": "Dalat Palace Heritage Hotel",
        "destination": "Đà Lạt",
        "type": "5 sao",
        "price_per_night": 2500000,
        "rating": 4.8,
        "address": "12 Trần Phú, Đà Lạt, Lâm Đồng",
        "amenities": "Hồ bơi, spa, nhà hàng, view hồ Xuân Hương, wifi miễn phí",
    },
    {
        "name": "Homestay The Kupid",
        "destination": "Đà Lạt",
        "type": "Homestay",
        "price_per_night": 600000,
        "rating": 4.5,
        "address": "Khu Hòa Bình, Đà Lạt",
        "amenities": "Decor vintage Pháp, breakfast, wifi, bãi đậu xe",
    },
    {
        "name": "Ana Mandara Villas",
        "destination": "Đà Lạt",
        "type": "Villa",
        "price_per_night": 3000000,
        "rating": 4.9,
        "address": "Le Lai, Đà Lạt",
        "amenities": "Villa biệt lập, sân vườn riêng, spa, nhà hàng fine dining",
    },
    {
        "name": "Khách sạn Mimosa",
        "destination": "Đà Lạt",
        "type": "3 sao",
        "price_per_night": 800000,
        "rating": 4.2,
        "address": "170 Phan Đình Phùng, Đà Lạt",
        "amenities": "Nhà hàng, wifi, lễ tân 24/7, bãi đậu xe",
    },
    # Phú Quốc
    {
        "name": "JW Marriott Phu Quoc Emerald Bay",
        "destination": "Phú Quốc",
        "type": "5 sao",
        "price_per_night": 8500000,
        "rating": 4.9,
        "address": "Khu Bãi Khem, An Thới, Phú Quốc",
        "amenities": "Bãi biển riêng, 7 hồ bơi, spa đẳng cấp, 12 nhà hàng, golf",
    },
    {
        "name": "Premier Village Phu Quoc Resort",
        "destination": "Phú Quốc",
        "type": "5 sao",
        "price_per_night": 6000000,
        "rating": 4.8,
        "address": "Mũi Ông Đội, An Thới, Phú Quốc",
        "amenities": "Biệt thự bãi biển riêng, hồ bơi vô cực, spa, nhà hàng hải sản",
    },
    {
        "name": "Mango Bay Resort",
        "destination": "Phú Quốc",
        "type": "Eco Resort",
        "price_per_night": 800000,
        "rating": 4.3,
        "address": "Ông Lang, Phú Quốc",
        "amenities": "Bãi biển nguyên sinh, kayak miễn phí, nhà hàng hữu cơ",
    },
    # Hội An
    {
        "name": "Four Seasons Resort The Nam Hai",
        "destination": "Hội An",
        "type": "5 sao",
        "price_per_night": 12000000,
        "rating": 4.9,
        "address": "Điện Bàn, Quảng Nam",
        "amenities": "3 hồ bơi, spa, bãi biển riêng, butler service",
    },
    {
        "name": "Anantara Hội An Resort",
        "destination": "Hội An",
        "type": "5 sao",
        "price_per_night": 4500000,
        "rating": 4.7,
        "address": "1 Phạm Hồng Thái, Hội An",
        "amenities": "Bên sông Thu Bồn, hồ bơi, spa, cooking class",
    },
    {
        "name": "Cát Bà Sunrise Resort",
        "destination": "Hạ Long",
        "type": "4 sao",
        "price_per_night": 1800000,
        "rating": 4.4,
        "address": "Cát Bà, Hải Phòng",
        "amenities": "View biển, hồ bơi, nhà hàng hải sản, tổ chức tour",
    },
]

# ------------------------------------------------------------------
# TOURS — Tour mẫu
# ------------------------------------------------------------------
TOURS = [
    {
        "name": "Tour Đà Lạt 3 ngày 2 đêm",
        "destination": "Đà Lạt",
        "duration": "3 ngày 2 đêm",
        "price": 2500000,
        "description": (
            "Khám phá Đà Lạt toàn diện: hồ Xuân Hương, Thung lũng Tình Yêu, "
            "Langbiang, vườn hoa, chợ đêm và các làng hoa."
        ),
        "includes": "Xe đưa đón, khách sạn 3 sao, ăn sáng, vé tham quan, hướng dẫn viên",
    },
    {
        "name": "Tour Phú Quốc 4 ngày 3 đêm",
        "destination": "Phú Quốc",
        "duration": "4 ngày 3 đêm",
        "price": 5900000,
        "description": (
            "Trọn gói Phú Quốc: khách sạn 4 sao, tour biển đảo, "
            "VinWonders, Grand World và khám phá ẩm thực đảo ngọc."
        ),
        "includes": "Vé máy bay khứ hồi, khách sạn 4 sao, ăn sáng, vé VinWonders, tour đảo",
    },
    {
        "name": "Tour Hội An - Đà Nẵng 4 ngày 3 đêm",
        "destination": "Hội An",
        "duration": "4 ngày 3 đêm",
        "price": 4200000,
        "description": (
            "Combo hoàn hảo Đà Nẵng - Hội An: thăm phố cổ, Bà Nà Hills, "
            "cầu Rồng và trải nghiệm ẩm thực đặc sắc miền Trung."
        ),
        "includes": "Vé máy bay, khách sạn, ăn sáng, vé Bà Nà Hills, hướng dẫn viên",
    },
    {
        "name": "Tour Hà Giang Loop 4 ngày 3 đêm",
        "destination": "Hà Giang",
        "duration": "4 ngày 3 đêm",
        "price": 3800000,
        "description": (
            "Chinh phục Hà Giang: đèo Mã Pí Lèng, cột cờ Lũng Cú, "
            "phố cổ Đồng Văn và trải nghiệm văn hóa H'Mông."
        ),
        "includes": "Xe ô tô, homestay, ăn đủ 3 bữa, hướng dẫn viên bản địa",
    },
    {
        "name": "Tour du thuyền Hạ Long 2 ngày 1 đêm",
        "destination": "Hạ Long",
        "duration": "2 ngày 1 đêm",
        "price": 3500000,
        "description": (
            "Ngủ đêm trên du thuyền 4 sao, khám phá hang Sửng Sốt, "
            "chèo kayak, câu mực và tận hưởng ẩm thực hải sản tươi sống."
        ),
        "includes": "Xe từ Hà Nội, du thuyền 4 sao, ăn đủ bữa, vé tham quan, kayak",
    },
    {
        "name": "Tour Sa Pa trekking 3 ngày 2 đêm",
        "destination": "Sa Pa",
        "duration": "3 ngày 2 đêm",
        "price": 3200000,
        "description": (
            "Trekking bản làng, leo Fansipan, khám phá ruộng bậc thang "
            "và giao lưu văn hóa H'Mông, Dao đỏ."
        ),
        "includes": "Tàu hỏa/xe từ Hà Nội, homestay, hướng dẫn viên người bản địa, ăn sáng",
    },
]

# ------------------------------------------------------------------
# TICKETS — Vé tham quan mẫu
# ------------------------------------------------------------------
TICKETS = [
    {
        "name": "Vé tham quan phố cổ Hội An",
        "destination": "Hội An",
        "price": 120000,
        "description": "Vé tham quan 5 điểm di tích tự chọn trong khu phố cổ, có giá trị 24 giờ",
    },
    {
        "name": "Vé cáp treo Fansipan Sa Pa",
        "destination": "Sa Pa",
        "price": 750000,
        "description": "Vé cáp treo khứ hồi lên đỉnh Fansipan 3143m, bao gồm tàu hỏa leo núi",
    },
    {
        "name": "Vé VinWonders Phú Quốc",
        "destination": "Phú Quốc",
        "price": 900000,
        "description": "Vé vào cổng VinWonders, bao gồm tất cả trò chơi và khu vui chơi trong ngày",
    },
    {
        "name": "Vé cáp treo Bà Nà Hills Đà Nẵng",
        "destination": "Đà Nẵng",
        "price": 850000,
        "description": "Vé cáp treo + tất cả trò chơi trong khu Bà Nà Hills, người lớn",
    },
    {
        "name": "Vé tham quan Vịnh Hạ Long",
        "destination": "Hạ Long",
        "price": 250000,
        "description": "Phí tham quan vịnh Hạ Long + bảo hiểm du lịch theo quy định",
    },
    {
        "name": "Vé Vinpearl Land Nha Trang",
        "destination": "Nha Trang",
        "price": 800000,
        "description": "Vé cáp treo + vào cổng Vinpearl Land, bao gồm tất cả trò chơi trong ngày",
    },
    {
        "name": "Vé Grand World Phú Quốc",
        "destination": "Phú Quốc",
        "price": 0,
        "description": "Miễn phí vào cổng Grand World, chỉ tính phí các show diễn và trò chơi riêng lẻ",
    },
    {
        "name": "Vé Thung lũng Tình Yêu Đà Lạt",
        "destination": "Đà Lạt",
        "price": 100000,
        "description": "Vé tham quan Thung lũng Tình Yêu, bao gồm đi thuyền trên hồ",
    },
]

# ------------------------------------------------------------------
# USERS mẫu — dùng để seed tài khoản test
# ------------------------------------------------------------------
USERS = [
    {
        "name": "Admin VietTravel",
        "email": "admin@viettravel.ai",
        "password": "admin@123",
        "role": "admin",
    },
    {
        "name": "Nguyễn Văn Test",
        "email": "test@viettravel.ai",
        "password": "test@123",
        "role": "user",
    },
]