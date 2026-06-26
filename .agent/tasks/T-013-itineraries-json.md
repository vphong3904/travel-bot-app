# Task T-013 — Tạo `itineraries.json` cho 34 tỉnh/thành

| Trường | Giá trị |
|---|---|
| **Task ID** | T-013 |
| **Status** | ⬜ TODO |
| **Priority** | 🔴 HIGH — đây là chức năng cốt lõi #3 của đề bài ("Gợi ý lịch trình") |
| **Depends on** | T-002 (destinations), T-003 (hotels), T-004 (restaurants), T-008 (experiences — tham khảo lịch trình văn xuôi đã có) |
| **Estimated** | ~90 phút |

---

## 🎯 Vì sao task này quan trọng (đọc trước khi làm)

Đề bài yêu cầu chatbot **"Gợi ý lịch trình (itinerary)"** như một trong 3 chức năng AI cốt lõi
(ngang hàng với "Hỏi đáp thông tin" và "Tư vấn điểm đến"), không phải tính năng phụ.

Hiện tại (`rag_pipeline.py`), intent `itinerary` chỉ tăng `top_k` khi retrieve rồi để LLM tự
ghép lịch trình từ các mẩu dữ liệu rời rạc (destinations, hotels, foods...) — nghĩa là chatbot
đang **tự bịa lịch trình theo giờ giấc, thứ tự, khoảng cách di chuyển** mỗi lần trả lời khác nhau,
đây chính là dạng hallucination nguy hiểm nhất vì user sẽ làm theo lịch trình sai (vd: xếp 2 điểm
cách nhau 40km vào cùng 1 buổi sáng).

`itineraries.json` cung cấp các lịch trình **đã được con người/agent kiểm chứng trước**, để RAG
retrieve nguyên khối thay vì để LLM generate từ đầu — giảm hallucination đúng như RULE-02 và đúng
yêu cầu kỹ thuật "Hạn chế trả lời sai" trong đề bài.

## 📂 Output

```
knowledge-base/{city-slug}/itineraries.json   (×10)
```

## 📖 Nguồn dữ liệu

1. `knowledge-base/{city}/destinations.json` (đã tạo ở T-002) — để lấy `location_ref.id`
2. `knowledge-base/{city}/hotels.json` (T-003), `restaurants.json` (T-004), `tours.json` (T-005)
3. `knowledge_entries` WHERE `category = 'tip'` — gợi ý lịch trình có sẵn trong SQL (nếu có)
4. Phần "🎒 Lịch Trình Gợi Ý" đã viết tay trong `experiences.md` (T-008) — chuyển thành dữ liệu có cấu trúc

## 🔢 Các bước thực hiện

1. Đọc `.agent/schemas/SCHEMAS.md` → section `itineraries.json`
2. Với mỗi thành phố:
   a. Mở `destinations.json`, `hotels.json`, `restaurants.json`, `tours.json` đã có — lập danh sách `id` khả dụng
   b. Thiết kế tối thiểu 2 lịch trình khác nhau (khác `audience` hoặc `duration_days`) — tham khảo gợi ý loại hình ở T-008:
      - Đà Lạt: 2N1Đ cặp đôi + 3N2Đ gia đình
      - Phú Quốc: 3N2Đ nghỉ dưỡng + 4N3Đ gia đình
      - Hà Giang: 3N2Đ + 4N3Đ phượt loop
      - Hội An: 2N1Đ phố cổ + 1N1Đ day trip
      - Sa Pa: 2N1Đ + 3N2Đ trekking
      - Hạ Long: 2N1Đ du thuyền + 3N2Đ kết hợp Cát Bà (nếu data cho phép)
      - Huế: 2N1Đ văn hoá + 1N1Đ day trip
      - Nha Trang: 3N2Đ biển đảo + 2N1Đ cuối tuần
      - Mũi Né: 2N1Đ lướt ván + 1N1Đ day trip
      - Ninh Bình: 1N1Đ day trip + 2N1Đ kết hợp Tam Cốc + Tràng An
   c. Với mỗi `day` → mỗi `block` (sáng/trưa/chiều/tối): chọn 1 địa điểm/quán ăn/khách sạn **đã có UUID** trong file JSON tương ứng, điền `location_ref`
   d. Nếu thiếu data nguồn cho 1 buổi nào đó → để `location_ref.id = null` và ghi chú chung chung, KHÔNG tự đặt tên địa điểm mới
   e. Tính `total_estimated_cost` bằng tổng `estimated_cost` các block (ước lượng hợp lý dựa trên `price_range`/`budget` đã có)
3. Validate chéo: mọi `location_ref.id` khác null phải tồn tại trong file JSON nguồn cùng thành phố (xem T-010)
4. Cập nhật phần "🎒 Lịch Trình Gợi Ý" trong `experiences.md` để **trỏ về** `itineraries.json` (theo `id`) thay vì lặp lại nội dung

## ✅ Checklist hoàn thành

- [ ] 10 files `itineraries.json` được tạo
- [ ] Mỗi file có tối thiểu 2 lịch trình, khác `audience` hoặc `duration_days`
- [ ] Mọi `location_ref.id` (khác null) khớp UUID có thật trong `destinations.json`/`hotels.json`/`restaurants.json`/`tours.json` cùng thành phố
- [ ] Không có 2 block liên tiếp trong cùng ngày ở 2 khu vực cách xa nhau bất hợp lý (kiểm tra bằng `coordinates` nếu có)
- [ ] `total_estimated_cost` được tính cộng dồn, không bịa số tròn
- [ ] `experiences.md` của thành phố đó được cập nhật để tham chiếu `itineraries.json` thay vì duplicate nội dung
- [ ] File thiếu data nguồn ghi rõ `status: partial` + `missing_fields`

---

### Partial note (điền khi bị gián đoạn)

```
Đã xong: (liệt kê slug)
Còn lại: (liệt kê slug)
```
