# Kế hoạch hoàn thiện App Mobile — PDTrip AI

> Tài liệu lập kế hoạch dựa trên rà soát mã nguồn thực tế (`backend/app/...` và `frontend/lib/...`).
> Mục tiêu: hoàn thiện 4 mảng theo yêu cầu — **Chatbot** (ưu tiên cao nhất), **Service screen**, **Settings**, **Home** — kèm task backend/frontend cụ thể, tiêu chí nghiệm thu và thứ tự ưu tiên.

---

## 0. Hiện trạng tổng quan (đã rà soát)

**Backend (FastAPI) khá hoàn chỉnh:**

- RAG pipeline (`services/rag_pipeline.py`) đầy đủ: NLP preprocessing → cache (exact + semantic) → hybrid search (Qdrant + Postgres FTS + RRF + re-rank) → Gemini → hallucination guard → đánh giá latency/TTFT.
- NLP/intent (`services/nlp_preprocessor.py`) đã có: normalize tiếng Việt, intent detection rule-based có trọng số theo số từ keyword, entity extraction (location/month/duration), query rewriting, clarification flow, **short-circuit greeting / out-of-scope / clarification** (đây chính là "fast response" cho chào hỏi / tạm biệt / ngoài phạm vi đã có sẵn).
- CRUD đầy đủ cho `travel` (destinations, hotels, tours, tickets, events, transport, shopping), `favorites`, `reviews`, `trips` (TripPlan + items), `chat sessions/messages` (kèm SSE stream + feedback).

**Frontend (Flutter) — phần lớn UI có nhưng còn gap:**

- `chatbot_screen.dart`: stream chat ổn, guest quota 3 câu/ngày, quick prompts. **Nhưng**: hiển thị "Độ tin cậy" đang **hardcode 0.95** (`confidence: m.promptTokens > 0 ? 0.95 : 0`), intent của message stream không được surface về (event `done` thiếu `intent`/`confidence`), và **itinerary có cấu trúc chưa được backend sinh ra** → `TripDetailsScreen` đang render dữ liệu placeholder mặc định.
- `home_screen.dart`: đã có rating, view count, favorite count, filter theo category/region/budget/month. **Thiếu**: đề xuất cá nhân hóa theo sở thích/lịch sử user.
- `destination_detail_screen.dart`: rating + comment (review) + favorite + views + favorite_count **đã wired đầy đủ** với API.
- `services_screen.dart`: có search + tab (Tất cả/Khách sạn/Tour). **Thiếu**: favorites theo danh mục, danh mục chuyến đi đã lưu, lịch sử chat, luồng multi-select → gửi cho chatbot.
- `intent_setup_screen.dart`: đã có form (điểm đi/đến, thời gian, ngân sách, nhóm, sở thích) sinh prompt gửi chatbot — **nhưng đứng rời, chưa gắn vào Service screen**, và kết quả không lưu thành "chuyến đi".
- `settings_screen.dart`: các toggle (dark mode, ngôn ngữ, thông báo, xóa lịch sử/yêu thích) **chỉ setState giả lập**, chưa persist, chưa đổi theme/locale thật, chưa gọi API.
- `profile_screen.dart`: stats "Chuyến đi" và "Đánh giá" đang để `–` (chưa wired); danh mục "Chuyến đi đã lưu" chưa có màn hình.

---

## 1. CHATBOT — Ưu tiên CAO NHẤT

Mục tiêu: chuẩn theo luồng + intent score cao + tỉ lệ chính xác cao + **fast response** khi có sẵn dữ liệu (khách sạn / kinh nghiệm / FAQ / chào hỏi / tạm biệt / ngoài phạm vi).

### 1.1. Nâng độ chính xác Intent & surface score thật ra mobile

**Backend (`nlp_preprocessor.py`, `chat_messages.py`, `rag_pipeline.py`):**

1. **Tăng độ chính xác intent** (giữ rule-based, thêm lớp tin cậy):
   - Bổ sung keyword còn thiếu cho các intent dễ nhầm (đặc biệt `find_hotel`, `ask_food`, `plan_trip`, `find_tour`) vào `data/intent_patterns.json`.
   - Thêm cơ chế **tie-break theo entity**: nếu có `entities['duration_days']` hoặc cụm "lịch trình/mấy ngày" → ưu tiên `plan_trip`; có `location`+`month` → `ask_weather`.
   - (Tùy chọn nâng cao) Thêm **fallback phân loại bằng Gemini** khi `confidence < 0.5`: gọi 1 lượt phân loại intent rẻ tiền (max_output_tokens nhỏ) để quyết định nhãn cuối — chỉ chạy khi rule-based mơ hồ để không tăng chi phí.
2. **Đưa intent + confidence ra event stream**: trong `chat_messages.stream_message`, event `done` hiện chỉ trả `sources/latency/tps`. Bổ sung `intent`, `confidence_score`, `suggested_questions` vào payload `done` (đã có sẵn trong `rag_meta`).

**Frontend (`chatbot_screen.dart`, `chat_api_service.dart`, `chat_message.dart`):**

3. Đọc `intent` + `confidence_score` thật từ event `done`/`meta`, **bỏ hardcode 0.95**. Hiển thị badge intent + thanh độ tin cậy thật (vd màu xanh ≥0.7, vàng 0.4–0.7, đỏ <0.4).
4. Hiển thị **suggested_questions** (backend đã parse `<<<SUGGESTED_QUESTIONS>>>`) thành chip bấm nhanh dưới câu trả lời.

**Nghiệm thu:** bộ test 30–50 câu tiếng Việt (có/không dấu) cho ra intent đúng ≥90%; badge intent + % tin cậy hiển thị đúng theo dữ liệu backend (không còn 0.95 cố định).

### 1.2. Fast response từ dữ liệu có sẵn (khách sạn / kinh nghiệm / FAQ / chào / tạm biệt / ngoài phạm vi)

Hiện đã có short-circuit cho **greeting / out_of_scope / clarification** (trả lời tức thì, không cần LLM). Cần mở rộng "fast path" cho dữ liệu structured có sẵn:

**Backend (`rag_pipeline.py` + service mới `fast_response.py`):**

1. **FAQ fast-path**: nếu intent `ask_faq` hoặc câu khớp một FAQ đã chuẩn hóa (đổi tiền, sim, wifi, múi giờ...) → trả thẳng từ bảng FAQ/cache, không gọi Gemini.
2. **Khách sạn / dịch vụ fast-path**: khi intent `find_hotel`/`find_tour` **và** có `entities['location']`/`city_slug` rõ ràng → truy vấn thẳng Postgres (`Hotel`/`Tour` theo destination) và format danh sách top N (tên, giá, rating) trả về ngay, kèm gợi ý "Bạn muốn mình lên lịch trình kèm khách sạn này không?". Chỉ rơi xuống full RAG khi không có dữ liệu structured.
3. **Kinh nghiệm/experiences fast-path**: tận dụng cache câu trả lời KB-grounded sẵn có (cache_layer) — đã có; bổ sung seed sẵn các câu kinh nghiệm phổ biến vào cache khi khởi động.
4. Đảm bảo mọi fast-path đều trả đúng format SSE `chunk` + `meta` để frontend không phải đổi logic.

**Nghiệm thu:** câu "khách sạn Đà Lạt giá rẻ" trả danh sách khách sạn thật < 800ms (không chờ Gemini); chào/tạm biệt/ngoài phạm vi < 300ms; FAQ trả tức thì.

### 1.3. Sinh lịch trình CÓ CẤU TRÚC theo ý định + sở thích + nhóm + budget + điểm đến

Đây là gap lớn: backend hiện chỉ trả markdown, `TripDetailsScreen` đang hiển thị placeholder.

**Backend (`rag_pipeline.py` + `services/itinerary_builder.py` mới + route trips):**

1. Khi intent `plan_trip`: yêu cầu Gemini trả về **JSON có cấu trúc** (qua `response_mime_type=application/json` hoặc marker block) gồm: `destination`, `duration`, `group`, `budget_low/high`, `days[]` (mỗi ngày: `title`, `activities[]`), và `hotels[]` gợi ý lấy từ DB theo budget/điểm đến.
2. Ghép dữ liệu thật từ `Hotel`/`Tour`/`Destination` (theo `city_slug`, budget, sở thích) vào itinerary để số liệu khớp DB, không bịa.
3. Trả `itinerary` JSON này trong `meta` của stream.

**Frontend (`chatbot_screen.dart`, `itinerary_card.dart`, `trip_details_screen.dart`, `trip` service mới):**

4. Parse `itinerary` thật từ meta → render `ItineraryCard` + `TripDetailsScreen` bằng dữ liệu thật (bỏ `_defaultDays`).
5. Nút **"Lưu chuyến đi"** → gọi `POST /trips` + `POST /trips/:id/items` (backend đã có sẵn) để lưu thành "danh mục chuyến đi".

**Nghiệm thu:** từ prompt của `IntentSetupScreen` (đích/thời gian/nhóm/budget/sở thích), chatbot trả lịch trình từng ngày + khách sạn thật từ DB; bấm "Lưu" tạo được TripPlan xem lại trong Profile/Service.

### 1.4. Cache câu hỏi & sửa lịch trình theo ý user (multi-turn trên kế hoạch)

Yêu cầu: "lưu cache câu đó và sửa lại theo ý user, trả lời vấn đề liên quan đến kế hoạch đã đưa ra".

**Backend (`chat_messages.py` đã có history; bổ sung context kế hoạch):**

1. Lưu itinerary JSON gần nhất vào **session context** (cột mới `last_itinerary` trên `chat_sessions`, hoặc message metadata). Khi user nhắn tiếp ("đổi ngày 2 sang đi biển", "giảm budget", "đổi khách sạn khác") → đưa itinerary trước đó vào prompt như context để Gemini **chỉnh sửa** thay vì tạo mới.
2. Tận dụng `build_sliding_history` đã có để giữ ngữ cảnh dài.

**Frontend:** giữ itinerary hiện tại trong state phiên chat, hiển thị "đang chỉnh sửa kế hoạch #..." để user biết bot đang thao tác trên kế hoạch nào.

**Nghiệm thu:** sau khi có kế hoạch, user gõ "đổi ngày 2 thành tắm biển" → bot trả kế hoạch đã chỉnh đúng ngày 2, giữ nguyên các ngày khác.

---

## 2. SERVICE SCREEN — Thiết kế mở rộng

Mục tiêu: mở rộng search; favorites xem lại theo từng danh mục; lưu lịch sử chat + danh mục chuyến đi; search theo lựa chọn của user; sau khi chọn xong các mục → đề xuất gửi tin nhắn cho chatbot để lên kế hoạch.

**Đề xuất cấu trúc lại Service screen thành các khu (tabs hoặc sections):**

1. **Tìm kiếm dịch vụ (đã có)**: giữ search + tab Tất cả/Khách sạn/Tour; **bổ sung filter** (giá, sao khách sạn, rating, khu vực) tận dụng query param có sẵn của `/travel/destinations` và `/hotels` (`stars`, `price_max`, `sort_by`).
2. **Yêu thích theo danh mục**: màn "Yêu thích của tôi" nhóm theo category (dùng `GET /travel/favorites` + `destination.categories`), cho lọc theo từng danh mục. (Backend đã trả categories trong favorite.)
3. **Danh mục chuyến đi đã lưu**: list TripPlan (`GET /trips`), mở chi tiết (`GET /trips/:id`), sửa/xóa (`PATCH`/`DELETE` đã có). Cho lọc/search theo tên/điểm đến/trạng thái.
4. **Lịch sử chat**: nhúng/điều hướng tới `ChatHistoryScreen` (đã có) ngay trong Service để truy cập nhanh.
5. **Luồng "Thiết kế chuyến đi với AI"** (gộp `IntentSetupScreen` vào Service):
   - User chọn: điểm đến (search), thời gian, ngân sách, nhóm, **loại tour**, sở thích.
   - Sau khi chọn xong → nút **"Gửi cho AI lên kế hoạch"** sinh prompt đầy đủ và mở `ChatBotScreen(initialMessage: ...)` → chatbot trả lịch trình + khách sạn đầy đủ (mục 1.3).

**Backend:** chủ yếu đã đủ; chỉ cần đảm bảo filter param được expose và (tùy chọn) thêm endpoint search hotels/tours toàn cục (hiện chỉ theo destination).

**Nghiệm thu:** Service screen có 4 khu truy cập được; chọn tiêu chí → 1 chạm gửi sang chatbot và nhận kế hoạch; xem lại favorites theo danh mục và danh sách chuyến đi đã lưu.

---

## 3. SETTINGS — Hoàn thiện đầy đủ chức năng

Hiện các toggle chỉ giả lập. Cần làm thật + persist + có thể mở rộng.

**Frontend (`settings_screen.dart`, `app_state.dart`, `app_theme.dart`):**

1. **Dark mode thật**: lưu `ThemeMode` vào `AppState` + `SharedPreferences`; `MaterialApp.themeMode` đọc từ AppState; bổ sung dark theme trong `app_theme.dart`.
2. **Ngôn ngữ thật**: tích hợp `flutter_localizations` + ARB (vi/en), lưu locale; tối thiểu áp cho các chuỗi chính.
3. **Thông báo**: lưu trạng thái; nếu có push (FCM) thì subscribe/unsubscribe, nếu chưa thì lưu preference + ẩn tính năng chưa hỗ trợ.
4. **Xóa lịch sử tìm kiếm**: xóa khỏi `SharedPreferences` (lịch sử search local).
5. **Xóa tất cả yêu thích**: gọi API thật — lặp `DELETE /travel/favorites/{id}` cho từng favorite (hoặc thêm endpoint xóa hàng loạt ở backend).
6. **Persist mọi setting** qua `SharedPreferences`; đọc lại khi khởi động.
7. (Mở rộng) Đổi mật khẩu, quản lý tài khoản, đơn vị tiền tệ, kích thước chữ.

**Backend (tùy chọn):** thêm `DELETE /travel/favorites` (xóa tất cả) để mục 5 gọn hơn.

**Nghiệm thu:** bật dark mode → toàn app đổi theme và giữ sau khi mở lại; đổi ngôn ngữ áp dụng thật; "xóa tất cả yêu thích" thực sự rỗng danh sách trên server.

---

## 4. HOME — Hoàn thiện rating / comment / favorite / views / đề xuất

Phần lớn đã có (rating, view count, favorite count hiển thị trên card; comment/review/favorite đầy đủ ở Detail). Cần bổ sung lớp **đề xuất cá nhân hóa** và đồng bộ số liệu.

**Frontend (`home_screen.dart`, `destination_card.dart`):**

1. **Đề xuất theo sở thích (cá nhân hóa)**: thêm section "Gợi ý cho bạn" dựa trên:
   - Favorites của user (`GET /travel/favorites`) → lấy categories phổ biến → gợi ý destinations cùng category.
   - (Nếu có) behavior log MongoDB (`view_destination`, `save_trip`) để xếp hạng.
2. **Filter mở rộng trên Home**: cho phép kết hợp nhiều tiêu chí (category + region + budget + month) thay vì rời rạc; nút "Bộ lọc" mở bottom sheet.
3. **Đồng bộ comment/rating ở card**: hiển thị thêm `reviewCount` (rating đã có) nếu cần; đảm bảo favorite toggle trên card cập nhật `favoriteCount` lạc quan.
4. **Profile stats**: wire "Chuyến đi" (`GET /trips` count) và "Đánh giá" (đếm review của user) thay cho `–`.

**Backend (tùy chọn):** thêm endpoint `GET /travel/recommendations` trả gợi ý theo user (dựa favorites/behavior) để Home gọi 1 lần thay vì ghép phía client.

**Nghiệm thu:** Home có section "Gợi ý cho bạn" thay đổi theo favorites của user; bộ lọc kết hợp hoạt động; profile hiển thị số chuyến đi & đánh giá thật.

---

## 5. Thứ tự ưu tiên đề xuất (roadmap)

| Giai đoạn | Hạng mục | Lý do |
|---|---|---|
| **P0 (tuần 1)** | 1.1 + 1.2 — intent score thật ra mobile + fast response khách sạn/FAQ/chào/tạm biệt | Đúng trọng tâm yêu cầu, tác động lớn, rủi ro thấp (backend đã sẵn nền) |
| **P1 (tuần 1–2)** | 1.3 + 1.4 — lịch trình có cấu trúc + lưu chuyến đi + sửa theo ý user | Mở khóa luồng chính "chọn → gửi AI → kế hoạch" |
| **P2 (tuần 2)** | 2 — Service screen mở rộng (favorites theo danh mục, danh mục chuyến đi, gộp Intent Setup) | Phụ thuộc 1.3 (cần lưu trip) |
| **P3 (tuần 3)** | 4 — Home đề xuất cá nhân hóa + filter + profile stats | Nâng trải nghiệm, độc lập |
| **P4 (tuần 3)** | 3 — Settings thật (dark mode, ngôn ngữ, persist, xóa favorites) | Polish, ít rủi ro |

---

## 6. Rủi ro & lưu ý kỹ thuật

- **JSON itinerary từ Gemini** có thể không ổn định — cần validate + fallback về markdown khi parse lỗi (đừng để app crash).
- **Fast-path khách sạn** phải kiểm tra dữ liệu DB thực sự có cho điểm đến đó trước khi short-circuit, tránh trả rỗng.
- **Dark mode / l10n** chạm nhiều widget — làm sớm theme tokens trong `app_theme.dart` để đỡ sửa rải rác.
- **Đồng bộ favorite_count/rating** dựa trên DB trigger (đã có) — phía client chỉ cập nhật lạc quan rồi refetch.
- Viết **unit test backend** cho intent (bộ câu mẫu) và **integration test** cho fast-path; test widget cho chatbot render intent/confidence/itinerary.

---

## 7. Tổng hợp thay đổi theo file (cheat-sheet)

**Backend:**
- `data/intent_patterns.json` — bổ sung keyword.
- `services/nlp_preprocessor.py` — tie-break intent theo entity, (tùy chọn) fallback Gemini.
- `services/rag_pipeline.py` — fast-path FAQ/hotel, sinh itinerary JSON, đưa context kế hoạch vào prompt.
- `services/fast_response.py` (mới), `services/itinerary_builder.py` (mới).
- `api/routes/chat_messages.py` — thêm `intent/confidence/suggested_questions/itinerary` vào event `done`; lưu `last_itinerary` cho session.
- `api/routes/favorites.py` — (tùy chọn) `DELETE /travel/favorites` xóa tất cả.
- `api/routes/travel.py` — (tùy chọn) endpoint recommendations / search hotels-tours toàn cục.

**Frontend:**
- `screens/chat/chatbot_screen.dart` — bỏ hardcode confidence, render intent thật + suggested questions + itinerary thật + nút Lưu chuyến đi.
- `models/chat_message.dart`, `services/chat_api_service.dart` — map intent/confidence/itinerary.
- `screens/trip_detail/trip_details_screen.dart`, `widgets/itinerary_card.dart` — render dữ liệu thật.
- `screens/services/services_screen.dart` — 4 khu + filter + gộp Intent Setup; `screens/chat/intent_setup_screen.dart` — gắn vào Service + lưu trip.
- `screens/profile/settings_screen.dart` + `providers/app_state.dart` + `theme/app_theme.dart` — settings thật + dark mode + l10n.
- `screens/home/home_screen.dart` — section "Gợi ý cho bạn" + filter tổng hợp; `screens/profile/profile_screen.dart` — wire stats + màn "Chuyến đi đã lưu".
- (mới) `services/trip_api_service.dart` — gọi `/trips`.

---

*Tài liệu này là bản kế hoạch; bước tiếp theo có thể bắt đầu hiện thực hóa theo từng giai đoạn P0→P4.*
