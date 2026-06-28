# TA-011 · Persist RAG Metrics trong rag_pipeline.py
> **Phase:** P2  |  **Nhãn:** [BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-010 DONE  |  **Estimated:** 2–3 giờ

## Mục tiêu
`rag_pipeline.py` đã tính metrics — chỉ cần lưu vào DB. KHÔNG sửa logic RAG.

## Làm gì

### 1 — Đọc rag_pipeline.py trước

```bash
cat backend/app/services/rag_pipeline.py | grep -n "confidence\|latency\|cache\|search_method\|chunk"
```

Xác định chỗ nào đang tính: `confidence_score`, `search_method`, `search_ms`, `llm_ms`, `cache_hit`, `chunk_count`.

### 2 — Thêm assignment khi INSERT ChatMessage

Tìm chỗ tạo `ChatMessage(...)` trong pipeline, thêm 6 field:

```python
chat_msg = ChatMessage(
    # ... fields hiện có ...
    confidence_score = confidence_score,   # None nếu chưa tính được
    search_method    = search_method,      # "qdrant"|"postgres_fts"|"hybrid"|"no_results"
    search_ms        = search_ms,
    llm_ms           = llm_ms,
    cache_hit        = cache_hit,          # "exact"|"semantic"|None
    chunk_count      = chunk_count,
)
```

> ⚠️ Nếu giá trị chưa accessible tại điểm đó → gán `None`. KHÔNG tạo biến mới hay sửa logic.

## Checklist DONE
- [ ] Đã đọc rag_pipeline.py và xác định vị trí gán
- [ ] 6 field được lưu vào DB sau mỗi chat
- [ ] Test: gửi 1 câu hỏi → xem row trong chat_messages → có giá trị
- [ ] Không có exception mới trong log

```
completed_at:
notes:
```
