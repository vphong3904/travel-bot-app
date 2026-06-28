---
name: admin-web-agent
description: >-
  Quy trình xây dựng PDTrip AI Web Admin (Frontend React/Vite + mở rộng Backend
  FastAPI). Kích hoạt khi user nhắc tới: "admin", "web admin", "trang quản trị",
  bất kỳ mã task "TA-001".."TA-023", RBAC / phân quyền 4 role, audit log,
  knowledge base CRUD cho admin, dashboard admin, user management, chat
  management, RAG monitoring, city/intent mapping, content/feedback/media
  management, system config, export Excel, session management. Skill này nạp rules
  bắt buộc (ADMIN_AGENT_RULES) và roadmap rồi dẫn agent thực thi đúng thứ tự task.
---

# Admin Web Agent — PDTrip AI

Skill này điều phối việc xây dựng **Web Admin** cho dự án PDTrip AI. Toàn bộ
"não bộ" của agent nằm trong thư mục `.agent/admin/` của project. Skill KHÔNG
chứa lại nội dung đó — nó chỉ ra đúng file cần đọc và bắt buộc tuân theo quy trình.

## Khi nào dùng skill này

Dùng khi user muốn làm bất cứ việc gì liên quan tới **trang quản trị (admin)** của
PDTrip AI: phân quyền (RBAC), audit log, dashboard, quản lý user/chat/knowledge/
content/feedback/media, RAG monitoring, city–intent mapping, system config, export,
session management — hoặc khi user gọi tên một task `TA-0xx`.

> Phân biệt với agent Knowledge Base: các task `T-0xx` (một chữ T) thuộc agent
> Knowledge Base ở `.agent/` — KHÔNG dùng skill này. Skill này chỉ cho `TA-0xx`
> (Admin) trong `.agent/admin/`.

## Bước bắt buộc mỗi khi bắt đầu (theo AR-01)

1. Đọc TOÀN BỘ `.agent/admin/rules/ADMIN_AGENT_RULES.md` (AR-01 → AR-15).
2. Đọc `.agent/admin/context/CODEBASE_CONTEXT.md` để biết route/model/service đã
   tồn tại — **không tạo trùng**.
3. Đọc `.agent/admin/ADMIN_ROADMAP.md`, tìm task `⬜ TODO` / `🔄 IN_PROGRESS`
   đầu tiên theo đúng thứ tự Phase.
4. Đọc file task chi tiết trong `.agent/admin/tasks/TA-0xx-*.md`.
5. Nếu task liên quan Knowledge Base, đọc thêm `.agent/rules/AGENT_RULES.md`
   phần RULE-02 (no hallucinate).
6. **Xác nhận scope với user → rồi mới code.**

## Quy tắc không được vi phạm (tóm tắt — chi tiết trong rules)

- **Thứ tự task cố định** (AR-01): không nhảy task; dependency chưa DONE → báo
  `BLOCKED` theo AR-15, không tự đoán dữ liệu thiếu.
- **Tách FE/BE** (AR-02): task `[FE+BE]` làm Backend trước, chốt API contract,
  rồi mới Frontend.
- **Không sửa cấu trúc file đang chạy production** (AR-03): `auth.py`,
  `core/security.py`, `db/database.py` — chỉ thêm/mở rộng, đọc trước khi sửa.
- **Mọi route mới** (AR-04): có `Depends(require_role([...]))` đúng ma trận AR-09,
  có `response_model`, docstring, và `log_audit()` cho mọi mutating action (AR-06).
- **Migration bằng Alembic** (AR-07): 1 migration = 1 thay đổi logic; không
  ALTER TABLE thủ công, không DROP cột cũ.
- **Knowledge Entry CRUD** (AR-08): UPDATE Postgres -> INSERT embedding_jobs
  (pending) -> INSERT audit_logs -> trả `job_id`; FE polling 3s. Không bỏ bước.
- **Không over-engineer** (AR-11): polling thay vì WebSocket, local disk thay vì
  S3, Recharts cho biểu đồ, focus happy path + auth test.
- **Checklist DONE** (AR-10): xong checklist BE/FE mới đánh dấu task DONE và cập
  nhật status trong `ADMIN_ROADMAP.md` + file task.

## Thứ tự thực thi (từ ADMIN_ROADMAP)

```
P0: TA-001 -> TA-002 -> TA-003 (song song 1+2) -> TA-004
P1: TA-005, TA-006, TA-007, TA-008 (song song) -> TA-009
P2: TA-010 -> TA-011 -> TA-012 ; TA-013, TA-014 (song song)
P3: TA-015 -> TA-016 ; TA-017, TA-018 (song song)
P4: TA-019, TA-022, TA-023 (song song)
```

Task đầu tiên cần làm: **TA-001 — RBAC 4 Role (Backend)**.

## Tài liệu nguồn (đọc trực tiếp, đừng nhớ từ skill)

| File | Mục đích |
|---|---|
| `.agent/admin/ADMIN_QUICK_START.md` | Điểm bắt đầu nhanh |
| `.agent/admin/rules/ADMIN_AGENT_RULES.md` | Rules bắt buộc AR-01 -> AR-15 |
| `.agent/admin/ADMIN_ROADMAP.md` | Tracker + thứ tự dependency |
| `.agent/admin/context/CODEBASE_CONTEXT.md` | Hiện trạng backend đã có |
| `.agent/admin/tasks/TA-0xx-*.md` | Spec chi tiết từng task |
