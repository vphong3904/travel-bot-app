# ⚡ Kế hoạch tối ưu Chatbot PDTrip AI

> Mục tiêu tổng: **phản hồi nhanh (TTFT < 2s)**, embedding không nghẽn khi tải nặng,
> phân loại ý + truy vấn DB nhanh gọn, chặn hallucination, tối ưu tiếng Việt,
> và knowledge base **chỉ còn trong DB + Qdrant** (bỏ JSON/MD).
>
> Liên quan: `.agent/ROADMAP_V2.md` (Phase 5 CB-1→CB-5), `docs/CHATBOT_DEVELOPMENT.md`,
> rule `.agent/rules/AGENT_RULES_SQL_MIGRATION.md` (đặc biệt MIG-07: chỉ bật
> `KNOWLEDGE_SOURCE=db` sau khi eval pass).
>
> Skill điều phối: `.claude/skills/chatbot-optimizer/SKILL.md`.

---

## ✅ Tiến độ (cập nhật 2026-06-29)

| Task | Trạng thái | Ghi chú |
|---|---|---|
| OPT-2.1 No-context guard | ✅ DONE | sources rỗng → `MISSING_KNOWLEDGE_RESPONSE`, không gọi Gemini (cả `query` + `stream_query`) |
| OPT-1.1 Throttle worker | ✅ DONE | `_embedding_worker_loop` batch=4, nghỉ 1s/batch — không nghẽn query |
| OPT-4.1 Continuous embed | ✅ DONE | cùng loop, poll 5s khi idle → admin thêm entry tự embed |
| OPT-2.3 Bỏ rerank intent nhẹ | ✅ DONE | `_NO_RERANK_INTENTS={ask_faq}`, truyền theo intent |
| OPT-3.1 Intent đọc từ DB | ✅ DONE | `intent_loader.load_intent_patterns_from_db` (merge file+DB), gọi lúc startup |
| OPT-3.2 Sửa intent tiếng Việt | ✅ DONE | strip địa danh ("Nẵng"≠"nắng") + accent-sensitive {nắng,mưa,nóng,lạnh,bão} (fix "bão"≠"bao") + bỏ "du lịch" chung chung + thêm keyword ask_activity & out_of_scope tài chính. **Intent eval offline: 12/12 = 1.0** (baseline 0.75) |
| OPT-3.3 Endpoint reload | ✅ DONE | `POST /admin/intent-patterns/reload` + SQL `36_update_intent_patterns.sql` |
| OPT-1.2/1.3 Bật CUDA auto | ✅ DONE | `_detect_device()` cuda↔cpu tự động cho bge-m3 + cross-encoder. torch 2.11.0+cu128 chạy trên RTX 3060 (driver 546.30 OK nhờ minor-ver compat). **Embed GPU 31ms/câu** (CPU 200-2000ms). Restart backend để áp |
| ~~Đo latency~~ (phát hiện) | ✅ | "2s/req" trong eval là **artifact `localhost`→IPv6 trên Windows**, không phải chatbot. Đã đổi eval sang `127.0.0.1`. Thực tế: cache-hit 2-28ms, short-circuit ~3ms, RAG cold ~2-3s (CPU) |
| OPT-2.2 Structured grounding | ✅ DONE | `structured_search.py`: fetch hotels/tours/tickets/transport/shopping/locations/events/itineraries theo intent+địa danh, đưa vào sources cho Gemini. Resolve destination theo **location** (đáng tin hơn city_slug). + intent **ask_shopping** mới. Test Đà Lạt: mọi nhóm 12-17 nguồn DB, **không miss**. Fallback degradation nhóm theo loại |
| ⚠️ BLOCKER môi trường | — | **Gemini API key 429 RESOURCE_EXHAUSTED** (hết quota free tier hôm nay). Code đúng; cần key mới (AIza... từ aistudio.google.com/apikey) hoặc chờ reset để test câu trả lời composed + đề xuất |
| OPT-2.4 Pre-warm cache | ⬜ TODO | |
| OPT-4.3/4.4 Cutover db + eval | ⬜ TODO | sau khi đo `--baseline`/`--compare` |

---

## 0. Hiện trạng & điểm nghẽn (đo từ code thật)

| Thành phần | File | Chi phí | Vấn đề |
|---|---|---|---|
| Embedding query (bge-m3) | [rag_pipeline.py:73](../backend/app/services/rag_pipeline.py) `_get_embed_model`, `_embed_sync` | 0.3–2s CPU, **6–8s khi tải nặng** | 1 instance `SentenceTransformer` dùng chung cho **cả worker nền lẫn query** → tranh CPU |
| Worker embedding nền | [main.py:38](../backend/app/main.py) `_run_pending_embedding_jobs` | chạy 544 job tuần tự lúc startup | block CPU embedding → query của user xếp hàng sau |
| Cross-encoder rerank | [hybrid_search.py:73](../backend/app/services/hybrid_search.py) `_get_reranker`, `_rerank_sync` | +0.1–0.5s/query CPU | chạy cho **mọi** intent kể cả FAQ/greeting |
| Gemini call | [rag_pipeline.py:911](../backend/app/services/rag_pipeline.py) `generate_content_stream` | TTFT 0.5–1.5s | vẫn gọi **ngay cả khi sources rỗng** → chậm + dễ bịa |
| Intent + alias | [nlp_preprocessor.py:344](../backend/app/services/nlp_preprocessor.py) | nhanh (regex) ✓ | nhưng đọc `intent_patterns.json` / `city_slug_alias.json` từ **file**, chưa đọc bảng DB đã migrate (T-026) |
| Cache 3 lớp | [cache_layer.py](../backend/app/services/cache_layer.py) | tốt ✓ | in-memory, mất khi restart; chưa pre-warm câu hỏi phổ biến |

**Kết luận:** nghẽn chính = (a) embedding CPU tranh chấp giữa worker nền và query;
(b) rerank chạy thừa; (c) gọi LLM cả khi không có ngữ cảnh.

---

## 1. Ngân sách độ trễ mục tiêu (TTFT — time to first token)

```
NLP preprocess (rule-based)        ~  5 ms
Cache lookup (exact + semantic)    ~  2 ms
Embedding query (ONNX int8)        < 300 ms   (hiện 500–2000ms, nghẽn tới 8s)
Hybrid search (Qdrant ∥ PG-FTS)    ~ 250 ms
Rerank (chỉ intent cần)            < 150 ms   (FAQ/greeting: bỏ qua)
Gemini TTFT (stream)               ~ 800 ms
──────────────────────────────────────────
TỔNG TTFT mục tiêu                 ≈ 1.5 s  (đệm tới 2s)
```

3 đường tắt **< 500ms, không gọi LLM**:
- **Cache hit** (exact/semantic) → trả ngay.
- **Greeting / out-of-scope / clarification** → câu mẫu (đã có short-circuit).
- **Structured fast-path** (find_hotel / ask_budget / find_tour / ticket có `city_slug`) → query thẳng Postgres, render template.
- **No-context guard** → khi sources rỗng/yếu, trả câu chặn hallucination thay vì gọi Gemini.

---

## 2. Bốn workstream

### WS-1 — Tốc độ embedding (yêu cầu #2: bge-m3 chậm khi tải nặng)

| Task | Việc | File | Tiêu chí xong |
|---|---|---|---|
| **OPT-1.1** | Tách worker nền khỏi đường request: chạy worker theo **vòng lặp throttle** (batch nhỏ + `asyncio.sleep`) thay vì nuốt hết CPU lúc startup | [main.py](../backend/app/main.py), [embedding_jobs.py](../backend/app/services/embedding_jobs.py) | query lúc đang embed nền không vượt 2s |
| **OPT-1.2** | **✅ CHỐT: chạy GPU (CUDA)** trên RTX 3060 — `SentenceTransformer(..., device="cuda")` + `.half()` (fp16). **Không cần ONNX, không cần re-embed** (cùng weights, vector ≈ y hệt CPU) | `rag_pipeline.py` `_get_embed_model`/`_embed_sync` | embed query < 100ms p50 |
| **OPT-1.2b** | Cross-encoder rerank cũng lên GPU: `CrossEncoder("BAAI/bge-reranker-v2-m3", device="cuda")` (fp16). Nếu 6GB VRAM căng → giữ reranker CPU hoặc chỉ rerank intent cần (OPT-2.3) | [hybrid_search.py:73](../backend/app/services/hybrid_search.py) `_get_reranker` | rerank < 80ms; không OOM |
| **OPT-1.3** | Guard CUDA: `torch.cuda.is_available()` → fallback CPU nếu driver/torch-CUDA thiếu (log rõ device đang dùng). Yêu cầu cài **torch bản CUDA** (cu121) | rag_pipeline.py, hybrid_search.py | log "[Embed] device=cuda" khi có GPU |
| **OPT-1.4** | Giữ **warm singleton** + warm-up lúc startup (đã có) — đảm bảo không reload model giữa request | rag_pipeline.py | log "model loaded" chỉ 1 lần |

> **Encoder = GPU CUDA (RTX 3060 laptop)** — chốt 2026-06-29. Vì giữ nguyên weights bge-m3
> nên vector tương thích, **KHÔNG phải re-embed** Qdrant. Lưu ý VRAM 6GB: bge-m3 (~2.3GB) +
> bge-reranker (~2.3GB) → dùng `.half()` (fp16) cho cả hai; nếu vẫn căng thì để reranker ở CPU.
> Điều kiện tiên quyết: `pip install torch --index-url https://download.pytorch.org/whl/cu121`
> (kiểm tra `python -c "import torch; print(torch.cuda.is_available())"` → `True`).

### WS-2 — Đường phản hồi nhanh & chặn hallucination (yêu cầu #1, #3)

| Task | Việc | File | Tiêu chí xong |
|---|---|---|---|
| **OPT-2.1** | **No-context guard**: sau `_get_sources`, nếu rỗng hoặc max score < ngưỡng → trả `MISSING_KNOWLEDGE_RESPONSE`, **không gọi Gemini** | [rag_pipeline.py:701](../backend/app/services/rag_pipeline.py) (cả `query` lẫn `stream_query`) | câu ngoài KB trả < 500ms, không bịa |
| **OPT-2.2** | **Structured fast-path**: intent ∈ {find_hotel, ask_budget, find_tour, ticket} + có `city_slug` → query bảng `hotels`/`tours`/`tickets` → template, bỏ LLM | service mới `fast_answer.py` + hook trong `query`/`stream_query` | các intent này trả < 800ms |
| **OPT-2.3** | **Bỏ rerank cho intent nhẹ** (greeting đã short-circuit; FAQ/ask_faq, structured) — truyền `use_reranking=False` theo intent | [rag_pipeline.py:632](../backend/app/services/rag_pipeline.py), [hybrid_search.py:112](../backend/app/services/hybrid_search.py) | rerank chỉ chạy cho intent cần độ chính xác cao |
| **OPT-2.4** | **Pre-warm cache** câu hỏi phổ biến lúc startup (top intent × top city) | main.py + cache_layer | cache hit-rate tăng, p50 giảm |

### WS-3 — Tối ưu tiếng Việt + intent đọc từ DB (yêu cầu #3, #4)

| Task | Việc | File | Tiêu chí xong |
|---|---|---|---|
| **OPT-3.1** | nlp_preprocessor đọc `intent_patterns` + `locations_alias` từ **bảng DB** (T-026), fallback file nếu DB trống | [nlp_preprocessor.py:344](../backend/app/services/nlp_preprocessor.py) | sửa intent ở Admin → chatbot nhận ngay (reload) |
| **OPT-3.2** | Sửa nhầm intent tiếng Việt: "biển … có gì đặc biệt" → `ask_activity` (không phải `ask_weather`); ưu tiên keyword đặc trưng | bảng `intent_patterns` / nlp_preprocessor | eval `intent_accuracy` ≥ baseline |
| **OPT-3.3** | Endpoint `POST /admin/intent-patterns/reload` gọi `reload_intent_patterns()` sau khi sửa | [admin.py](../backend/app/api/routes/admin.py) | không cần restart server |

### WS-4 — KB chỉ trong DB + embed tức thời (yêu cầu #4)

| Task | Việc | File | Tiêu chí xong |
|---|---|---|---|
| **OPT-4.1** | **Continuous embed worker**: vòng lặp nền poll `embedding_jobs` mỗi ~5s (throttle theo OPT-1.1) → thêm entry ở Admin tự vào Qdrant trong vài giây | main.py lifespan + embedding_jobs `run_pending` | tạo entry qua Admin → Qdrant có vector < 10s, không cần bấm tay |
| **OPT-4.2** | Đảm bảo CRUD Admin → DB → `embedding_jobs(pending)` (đã có ở [knowledge.py:35](../backend/app/services/knowledge.py)); thêm trigger SQL [34_migration_embedding_trigger.sql](../backend/initdb/34_migration_embedding_trigger.sql) đã tạo | knowledge.py, admin.py | mọi đường tạo/sửa đều sinh job |
| **OPT-4.3** | **Cutover `KNOWLEDGE_SOURCE=db`** (T-030) sau eval pass; archive `backend/knowledge-base/` | [.env](../backend/.env) | RAG đọc 100% từ DB/Qdrant, không còn JSON/MD |
| **OPT-4.4** | Eval hồi quy `--compare` xác nhận không tụt > 5% trước & sau cutover (T-031) | [eval_kb_retrieval.py](../backend/scripts/eval_kb_retrieval.py) | `[PASS]` |

---

## 3. Thứ tự thực thi đề xuất

```
WS-3 (OPT-3.1→3.3) ─┐  intent đúng + đọc DB  (rẻ, mở khóa eval đẹp)
WS-2 (OPT-2.1→2.4) ─┼─ đường nhanh + no-context guard  (đòn bẩy <2s lớn nhất)
WS-1 (OPT-1.1)     ─┘  throttle worker  (sửa nghẽn 6-8s ngay, ít rủi ro)
        │
        ▼
WS-1 (OPT-1.2→1.4) ── đổi encoder ONNX + re-embed  (cần chốt phương án encoder)
        │
        ▼
WS-4 (OPT-4.1→4.2) ── continuous worker + verify CRUD→embed
        │
        ▼
WS-4 (OPT-4.4 eval --baseline) → (OPT-4.3 cutover db) → (OPT-4.4 eval --compare)
```

Nguyên tắc: **sửa nghẽn rẻ trước** (throttle worker, no-context guard) → đo lại →
mới đụng vào encoder (rủi ro tương thích vector) → cuối cùng mới cutover DB.

---

## 4. Cách đo (bắt buộc trước/sau mỗi WS)

```bash
cd backend
set PYTHONIOENCODING=utf-8

# Baseline (chạy 1 lần trước khi tối ưu)
python scripts/eval_kb_retrieval.py --baseline

# Sau mỗi thay đổi: so sánh không hồi quy + xem latency
python scripts/eval_kb_retrieval.py --compare
```

Quan sát trong [eval_kb_retrieval.py](../backend/scripts/eval_kb_retrieval.py):
`intent_accuracy`, `sources_present`, `avg_latency_ms`. Bổ sung log RAG đã có
(`embed=…ms search=…ms llm=…ms total=…ms` tại [rag_pipeline.py:748](../backend/app/services/rag_pipeline.py))
để bóc tách thành phần chậm.

**Định nghĩa "đạt":**
- TTFT p50 < 2s cho câu RAG thường; < 800ms cho structured/cached.
- Câu ngoài KB → câu chặn hallucination, không bịa, < 500ms.
- Tạo entry ở Admin → Qdrant có vector tự động < 10s.
- `KNOWLEDGE_SOURCE=db`, không còn đọc JSON/MD.

---

## 5. Ràng buộc / không được vi phạm

- **MIG-07**: không đặt `KNOWLEDGE_SOURCE=db` trước khi eval `--compare` PASS.
- **Tương thích vector**: nếu đổi encoder (OPT-1.2) → **phải re-embed toàn bộ** (OPT-1.3),
  không trộn vector 2 encoder khác nhau trong cùng collection.
- **Không over-engineer**: worker dùng vòng lặp asyncio + throttle, **không** thêm Redis/Celery/
  process riêng cho quy mô đồ án (cache in-memory + polling là đủ).
- **Không bịa dữ liệu**: no-context guard luôn ưu tiên câu "chưa có dữ liệu" hơn là để LLM tự chế.
