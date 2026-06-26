# 🗄️ Nguồn dữ liệu cho Knowledge Base

> **Lưu ý quan trọng:** File SQL seed (`backend/initdb/*.sql`) là dữ liệu do AI sinh tự động
> và **không đáng tin cậy** — không dùng làm nguồn dữ liệu cho knowledge-base/.
> Nguồn duy nhất hợp lệ là dữ liệu thật từ app mobile và các nguồn ngoài được liệt kê dưới đây.

---

## Nguồn dữ liệu hợp lệ (theo thứ tự ưu tiên)

### Nhóm 1 — Nguồn chính phủ & cơ quan nhà nước
| Nguồn | URL | Dùng cho |
|---|---|---|
| Cổng thông tin điện tử Chính phủ | chinhphu.vn | Thông tin hành chính, tỉnh thành |
| Vietnam Tourism (Tổng cục Du lịch) | vietnamtourism.gov.vn | Điểm đến chính thức, lễ hội |
| Sở Du lịch từng tỉnh | (domain tỉnh) | Thông tin địa phương chính xác nhất |
| Cục Di sản Văn hóa | dsvh.gov.vn | Di tích, di sản |

### Nhóm 2 — Nền tảng du lịch lớn (giá thực tế)
| Nguồn | URL | Dùng cho |
|---|---|---|
| Traveloka | traveloka.com/vi-vn | Giá vé, khách sạn, tour |
| Klook Việt Nam | klook.com/vi | Giá vé tham quan, hoạt động |
| Booking.com | booking.com | Giá phòng khách sạn |
| Agoda | agoda.com/vi-vn | Giá phòng khách sạn |
| Vietravel | vietravel.com | Tour nội địa |
| VNTRIP | vntrip.vn | Khách sạn, tour trong nước |

### Nhóm 3 — Đánh giá & cộng đồng (tips, không dùng cho giá)
| Nguồn | URL | Dùng cho |
|---|---|---|
| TripAdvisor | tripadvisor.com.vn | Tips thực tế, đánh giá địa điểm |
| Google Maps | maps.google.com | Giờ mở cửa (xác nhận chéo) |
| Foody | foody.vn | Quán ăn, món ngon |

---

## Mapping file output → loại nguồn cần tìm

| Output File | Nội dung cần | Tìm ở |
|---|---|---|
| `city.json` | Tổng quan tỉnh/thành, khí hậu, ngân sách | vietnamtourism.gov.vn, Sở Du lịch tỉnh |
| `destinations.json` | Danh sách địa điểm, giờ mở cửa, giá vé | Google Maps, Klook, website chính thức |
| `hotels.json` | Danh sách khách sạn, giá, loại | Booking.com, Agoda, Traveloka |
| `restaurants.json` | Quán ăn, địa chỉ, giá | Foody, Google Maps |
| `foods.json` | Đặc sản, mô tả, nơi ăn chung | vietnamtourism.gov.vn, Sở Du lịch |
| `transport.json` | Cách di chuyển, giá, nhà xe | Traveloka, 12go.asia, website nhà xe |
| `tours.json` | Tour, giá, bao gồm gì | Klook, Traveloka, Vietravel |
| `tickets.json` | Giá vé vào cửa | Klook, website chính thức điểm đến |
| `events.json` | Lễ hội, sự kiện, ngày | Sở Du lịch tỉnh, vietnamtourism.gov.vn |
| `shopping.json` | Nơi mua sắm, mặt hàng, giờ | Google Maps, Foody |
| `faq.md` | Câu hỏi thực tế | Tổng hợp từ tất cả nguồn trên |
| `experiences.md` | Tips hành vi, timing, cảnh báo | TripAdvisor, cộng đồng du lịch |

---

## Quy tắc xác minh

- **Giá** → bắt buộc ≥ 2 nguồn Nhóm 2 khớp → ghi kèm `(nguồn: X & Y, tháng MM/YYYY)`
- **Giờ mở cửa** → Google Maps + website chính thức. 1 nguồn → thêm `— xác nhận trước khi đến`
- **Thông tin mâu thuẫn** → ghi cả hai, `status: partial`, ghi vào `_conflicts`
- **Không tìm thấy** → dùng mô tả chung hoặc `null` — tuyệt đối không bịa số cụ thể

> Xem thêm: RULE-02, RULE-18, RULE-19 trong `.agent/rules/AGENT_RULES.md`
