# Task T-012 — Update RAG Pipeline đọc từ file

| Trường | Giá trị |
|---|---|
| **Task ID** | T-012 |
| **Status** | ⬜ TODO |
| **Priority** | 🟡 MEDIUM |
| **Depends on** | T-011 DONE |
| **Estimated** | ~3 giờ |

---

## 🎯 Mục tiêu

Cập nhật pipeline truy xuất (`app/services/rag_pipeline.py`, `app/services/knowledge.py`) để hỗ trợ cả 2 nguồn dữ liệu mà **không phá vỡ** hệ thống production hiện tại:

1. **PostgreSQL → Qdrant (cũ)** — nguồn từ bảng `KnowledgeEntry` qua `EmbeddingJob`. Giữ nguyên 100%, đây là fallback an toàn.
2. **`knowledge-base/*.json|.md` → Qdrant collection riêng (mới)** — nguồn từ T-011. Ưu tiên cao hơn vì có cấu trúc rõ và validate kỹ hơn (RULE-02, RULE-07).

## 📖 Approach

Thêm flag `KNOWLEDGE_SOURCE = "files" | "db" | "hybrid"` vào `.env` (mặc định `db` để không phá hệ thống đang chạy):

| Mode | Hành vi |
|---|---|
| `db` | Giữ nguyên hành vi hiện tại — chỉ query collection cũ (từ `embedding_jobs`) |
| `files` | Chỉ query collection mới (từ `knowledge-base/`, tạo ở T-011) |
| `hybrid` | Query **cả 2 collection song song**, gắn nhãn `source: "db" \| "files"` vào mỗi kết quả, sau đó re-rank/dedupe theo `(city, item_name)` trước khi đưa vào prompt — **không** đơn giản nối 2 list lại, vì sẽ gây trùng lặp context và tăng rủi ro mâu thuẫn dữ liệu giữa 2 nguồn (vi phạm RULE-06 — ưu tiên nguồn).

## ⚠️ Lưu ý quan trọng

- Không xoá hoặc tắt code path cũ (`db` mode) — đây là cơ chế rollback nếu `knowledge-base/` có lỗi dữ liệu phát hiện sau khi demo.
- Nếu 2 nguồn trả về thông tin mâu thuẫn nhau (vd: giá vé khác nhau) ở mode `hybrid` → log cảnh báo + ưu tiên nguồn `files` (đã qua validate T-010), nhưng phải log rõ entry nào bị ghi đè để dễ truy vết khi báo cáo đồ án.
- Cần có cách đo so sánh: chạy cùng 1 bộ câu hỏi test qua cả 3 mode, log lại độ chính xác / độ liên quan để làm minh chứng cải tiến khi bảo vệ đồ án (xem RULE-13 trong `AGENT_RULES.md`).

## ✅ Checklist

- [ ] `.env` có key `KNOWLEDGE_SOURCE`, mặc định `db`
- [ ] `rag_pipeline.py` đọc flag và switch/merge source đúng theo 3 mode trên
- [ ] Mode `hybrid` có dedupe + log conflict, không nối thô 2 list
- [ ] Unit test cho cả 3 mode (`backend/tests/`)
- [ ] Không break các API endpoint hiện có (chat, search, admin)
- [ ] README cập nhật hướng dẫn bật/tắt `KNOWLEDGE_SOURCE`
- [ ] Có bảng so sánh kết quả (trước/sau) cho ít nhất 10 câu hỏi mẫu, lưu lại làm minh chứng

---

### Partial note
```
Đã xong:
Còn lại:
```
