# CHATBOT DEVELOPMENT — PDTrip AI

> Tài liệu phát triển **riêng cho Chatbot** (RAG + NLP). Tách khỏi kế hoạch mobile tổng để đội AI tập trung.
> Phạm vi: kiến trúc hiện tại → cải tiến intent → fast response → lịch trình có cấu trúc → multi-turn sửa kế hoạch → đo lường & giám sát.
> Liên quan: `KE_HOACH_HOAN_THIEN_MOBILE.md` (mục 1), `MIGRATION_JSON_MD_TO_SQL.md` (nguồn dữ liệu KB).

---

## A. Kiến trúc chatbot hiện tại (đã rà soát code)

Luồng trong `services/rag_pipeline.py` (`RAGPipeline.query` / `stream_query`):

```
Câu hỏi (tiếng Việt)
 → [NLP] nlp_preprocessor.preprocess(): normalize → entity → intent → rewrite
        → short-circuit: greeting / out_of_scope / clarification  (FAST, không gọi LLM)
 → [Cache] exact-match → semantic cache (cache_layer)
 → [Embed] BGE-M3 (asyncio.to_thread) + cache embedding
 → [Hybrid Search] Qdrant (semantic) ∥ Postgres FTS (keyword) → RRF → cross-encoder re-rank
 → [Retrieval Optimizer] top-K động theo intent
 → [Hallucination Guard] dynamic threshold lọc nguồn
 → [Gemini] system_instruction riêng + max_output_tokens động + sliding summary + retry
 → [Hallucination Guard] grounding + citation check
 → [Cache] lưu câu trả lời KB-grounded
 → [Eval] ghi latency / TTFT / cache-hit
```

**Điểm mạnh đã có:** intent rule-based có trọng số theo số từ keyword (`detect_intent`), short-circuit chào hỏi/ngoài phạm vi/clarification (đây là "fast response" cơ bản), cache 2 lớp, hybrid search + re-rank, hallucination guard, fallback Postgres FTS để **không bao giờ thiếu context**, fallback khi Gemini lỗi.

**Gap cần làm (theo yêu cầu):**

1. Intent score thật **không được surface ra mobile** — `chatbot_screen.dart` hardcode `confidence: 0.95`; event `done` của stream thiếu `intent`/`confidence`/`suggested_questions`.
2. Chưa có **fast response từ dữ liệu structured** (khách sạn, kinh nghiệm, FAQ) — mọi câu (trừ chào/oos/clarify) đều đi full RAG + Gemini.
3. Chưa sinh **lịch trình có cấu trúc** — backend chỉ trả markdown, nên `TripDetailsScreen` hiển thị `_defaultDays` placeholder.
4. Chưa có **multi-turn sửa kế hoạch** (cache kế hoạch + chỉnh theo ý user).
5. Chưa có **bộ eval cố định** đo độ chính xác intent + retrieval (RULE-13 yêu cầu nhưng chưa làm).

---

## B. Hạng mục phát triển

### CB-1 · Intent chính xác cao + đưa score thật ra mobile

**Mục tiêu:** intent đúng ≥90% trên bộ test; mobile hiển thị intent + % tin cậy THẬT.

Backend:
- `data/intent_patterns.json`: bổ sung keyword cho intent dễ nhầm (`find_hotel`, `ask_food`, `plan_trip`, `find_tour`, `ask_budget`).
- `nlp_preprocessor.detect_intent`: thêm **tie-break theo entity** — có `duration_days`/cụm "mấy ngày/lịch trình" → ưu tiên `plan_trip`; có `location`+`month` → `ask_weather`; có `location`+từ giá → `ask_budget`.
- (Nâng cao, tùy chọn) **fallback phân loại bằng Gemini** chỉ khi `confidence < 0.5`: 1 lượt gọi rẻ (max_output_tokens nhỏ, JSON `{intent}`), tránh tăng chi phí cho đa số câu rõ ràng.
- `chat_messages.stream_message`: thêm `intent`, `confidence_score`, `suggested_questions` vào payload event `done` (đã có trong `rag_meta`).

Frontend:
- `models/chat_message.dart` + `chat_api_service.dart`: map `intent` + `confidence` thật.
- `chatbot_screen.dart`: **bỏ hardcode 0.95**; render badge intent (đã có `intentIcon/intentLabel`) + thanh tin cậy (xanh ≥0.7 / vàng 0.4–0.7 / đỏ <0.4).
- Render `suggested_questions` thành chip bấm nhanh (backend đã parse marker `<<<SUGGESTED_QUESTIONS>>>`).

**Nghiệm thu:** chạy `backend/tests/eval_questions.json` ≥90% intent đúng; UI không còn 0.95 cố định; chip gợi ý hiển thị và bấm được.

---

### CB-2 · Fast response từ dữ liệu có sẵn

**Mục tiêu:** câu có dữ liệu structured trả < 800ms (không chờ Gemini); chào/tạm biệt/oos < 300ms (đã có); FAQ tức thì.

Tạo `services/fast_response.py`, gọi NGAY sau bước NLP (trước hybrid search) trong `rag_pipeline`:

| Trường hợp | Điều kiện | Hành động |
|---|---|---|
| Chào / tạm biệt | `is_greeting` | (đã có) trả mẫu greeting |
| Ngoài phạm vi | `is_out_of_scope` | (đã có) trả `OUT_OF_SCOPE_RESPONSE` |
| FAQ phổ biến | intent `ask_faq` + khớp FAQ chuẩn hóa | trả thẳng từ bảng FAQ (knowledge_entries category='faq') / cache, không gọi Gemini |
| Khách sạn | intent `find_hotel` + có `city_slug`/`location` | query Postgres `Hotel` theo destination → format top-N (tên, giá, rating) + gợi ý "lên lịch trình kèm KS này?" |
| Tour | intent `find_tour` + có `location` | tương tự với `Tour` |
| Kinh nghiệm/tips | câu khớp cache KB-grounded | trả từ cache (đã có cache layer) |

Quy tắc: **chỉ short-circuit khi DB thật có dữ liệu**; nếu rỗng → rơi xuống full RAG. Mọi fast-path trả đúng format SSE `chunk` + `meta` (để frontend không đổi logic).

**Nghiệm thu:** "khách sạn Đà Lạt giá rẻ" trả danh sách KS thật < 800ms; FAQ "đổi tiền ở đâu" trả tức thì; đo bằng log latency.

---

### CB-3 · Sinh lịch trình CÓ CẤU TRÚC (intent `plan_trip`)

**Mục tiêu:** từ ý định + sở thích + nhóm + budget + điểm đến → JSON lịch trình từng ngày + khách sạn thật từ DB.

> ⚠️ Phụ thuộc dữ liệu: cần `itineraries` + `hotels`/`tours` trong SQL — xem `MIGRATION_JSON_MD_TO_SQL.md` (T-022, T-025).

Backend (`services/itinerary_builder.py` mới + `rag_pipeline`):
- Khi intent `plan_trip`: yêu cầu Gemini trả **JSON** (`response_mime_type=application/json` hoặc marker block) gồm:
  ```json
  {
    "destination": "...", "duration": "3 ngày 2 đêm", "group": "gia đình",
    "budget_low": 4000000, "budget_high": 10000000,
    "days": [{"day":1,"title":"...","activities":["..."]}],
    "hotels": [{"id":"...","name":"...","price":...,"rating":...}]
  }
  ```
- **Ghép dữ liệu thật** từ `Hotel`/`Tour`/`Destination`/`itineraries` (theo `city_slug`, budget, sở thích) — không để Gemini bịa số (tuân RULE-02).
- Validate JSON; nếu parse lỗi → fallback markdown (không crash).
- Trả `itinerary` trong `meta` của stream.

Frontend:
- `chatbot_screen.dart`: parse `itinerary` thật từ meta → `ItineraryCard`.
- `trip_details_screen.dart` + `itinerary_card.dart`: render dữ liệu thật (bỏ `_defaultDays`).
- Nút **"Lưu chuyến đi"** → `POST /trips` + `/trips/:id/items` (backend đã có).

**Nghiệm thu:** prompt từ `IntentSetupScreen` → trả lịch trình từng ngày + KS thật; bấm "Lưu" tạo TripPlan xem lại được.

---

### CB-4 · Multi-turn — cache & sửa kế hoạch theo ý user

**Mục tiêu:** sau khi có kế hoạch, user nhắn "đổi ngày 2 sang biển" / "giảm budget" / "đổi khách sạn" → bot **chỉnh sửa** kế hoạch cũ, không tạo mới.

Backend:
- Lưu itinerary JSON gần nhất vào **session context**: thêm cột `last_itinerary JSONB` trên `chat_sessions` (hoặc dùng `conversation_memory`).
- Khi câu mới liên quan kế hoạch (intent `plan_trip` + có itinerary trước) → đưa itinerary cũ vào prompt như context để Gemini chỉnh.
- Tận dụng `gemini_optimizer.build_sliding_history` (đã có) giữ ngữ cảnh dài.

Frontend: giữ itinerary hiện tại trong state phiên chat; hiển thị "Đang chỉnh kế hoạch ...".

**Nghiệm thu:** "đổi ngày 2 thành tắm biển" → ngày 2 đổi đúng, các ngày khác giữ nguyên.

---

### CB-5 · Đo lường & giám sát (RULE-13)

- Tạo `backend/tests/eval_questions.json` ≥30 câu, phủ 5 intent (FAQ / điểm đến / lịch trình / khách sạn / out-of-scope), có nhãn intent kỳ vọng + có/không dấu.
- Script `backend/tests/eval_intent.py`: chạy `preprocess()` trên bộ câu → in confusion matrix + accuracy.
- (Có sẵn) `evaluation_monitor.performance_monitor` ghi latency/TTFT/cache-hit → thêm endpoint admin để xem (đã có RAG monitoring TA-012).

**Nghiệm thu:** report accuracy in ra số; chạy lại sau mỗi thay đổi intent để chống hồi quy.

---

## C. Thứ tự ưu tiên chatbot

| Bước | Hạng mục | Phụ thuộc |
|---|---|---|
| 1 | CB-1 (intent score ra mobile) + CB-5 (eval) | — |
| 2 | CB-2 (fast response) | CB-1 |
| 3 | CB-3 (lịch trình cấu trúc) | Migration T-022/T-025 |
| 4 | CB-4 (multi-turn sửa kế hoạch) | CB-3 |

---

## D. Thay đổi theo file (cheat-sheet)

**Backend:** `data/intent_patterns.json`, `services/nlp_preprocessor.py`, `services/rag_pipeline.py`, `services/fast_response.py` (mới), `services/itinerary_builder.py` (mới), `api/routes/chat_messages.py`, migration cột `chat_sessions.last_itinerary`, `tests/eval_questions.json` + `tests/eval_intent.py`.

**Frontend:** `models/chat_message.dart`, `services/chat_api_service.dart`, `screens/chat/chatbot_screen.dart`, `widgets/itinerary_card.dart`, `screens/trip_detail/trip_details_screen.dart`, `services/trip_api_service.dart` (mới).
