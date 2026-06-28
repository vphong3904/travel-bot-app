# TA-012 · AI/RAG Monitoring Dashboard
> **Phase:** P2  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-011 DONE  |  **Estimated:** 4–5 giờ

## Backend — 4 Endpoints

```python
GET /admin/rag-monitoring/overview?from=&to=
# Returns:
# avg_confidence_score (float)
# avg_search_ms, avg_llm_ms
# cache_hit_rate: { exact: %, semantic: %, miss: % }
# search_method_breakdown: { qdrant: %, fts: %, hybrid: %, no_results: % }
# hallucination_rate: % (flagged_responses / total_messages)
# avg_chunk_count (float)
# confidence_over_time: [{date, avg_score}]

GET /admin/rag-monitoring/latency
# latency_by_hour: [{hour, avg_search_ms, avg_llm_ms}]

GET /admin/rag-monitoring/errors
# errors từ Mongo error_logs (nếu chưa có collection → để empty list)

GET /admin/rag-monitoring/cache
# cache_trend: [{date, hit_count, miss_count}]
```

**Lưu ý:** Chỉ query từ rows có `confidence_score IS NOT NULL` (data chỉ có từ sau TA-011).

## Frontend — 4 Tabs

**Tab 1 — Overview:** 4 KPI cards (confidence, cache rate, hallucination rate, avg latency) + confidence trend line chart

**Tab 2 — Latency:** Line chart search_ms vs llm_ms theo giờ

**Tab 3 — Retrieval:** Pie chart search method breakdown + confidence score histogram (bar chart phân phối 0-0.2, 0.2-0.4, ..., 0.8-1.0)

**Tab 4 — Errors:** Bảng đơn giản, có thể empty nếu chưa có data

## Checklist DONE
- [ ] Chỉ query rows có metrics (không lẫn data cũ NULL)
- [ ] Confidence KPI card màu theo ngưỡng (green >0.7, yellow 0.5-0.7, red <0.5)
- [ ] Tất cả charts null-safe (không crash khi data rỗng)
- [ ] Date range picker filter tất cả charts

```
completed_at:
```
