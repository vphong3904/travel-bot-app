# 🚀 ADMIN QUICK START — Đọc cái này đầu tiên

## Tôi là agent mới, bắt đầu từ đâu?

### Bước 1 — Đọc rules
```
.agent/admin/rules/ADMIN_AGENT_RULES.md  ← đọc TOÀN BỘ
.agent/rules/AGENT_RULES.md              ← đọc phần RULE-02 (no hallucinate)
```

### Bước 2 — Xem progress
```
.agent/admin/ADMIN_ROADMAP.md  ← tìm task ⬜ TODO đầu tiên theo thứ tự Phase
```

### Bước 3 — Đọc task file
```
.agent/admin/tasks/TA-00X-tên-task.md
```

### Bước 4 — Xác nhận với user → làm

---

## Thứ tự tuyệt đối không được thay đổi

```
P0: TA-001 → TA-002 → TA-003 (parallel với 1+2) → TA-004
                                    ↓
P1: TA-005, TA-006, TA-007, TA-008 (parallel) → TA-009
                                    ↓
P2: TA-010 → TA-011 → TA-012     TA-013, TA-014 (parallel)
                                    ↓
P3: TA-015 → TA-016               TA-017, TA-018 (parallel)
                                    ↓
P4: TA-019, TA-022, TA-023 (parallel)
```

---

## File nào làm gì?

| File | Mục đích |
|---|---|
| `ADMIN_AGENT_RULES.md` | Rules bắt buộc — đọc trước khi code bất cứ thứ gì |
| `ADMIN_ROADMAP.md` | Progress tracker + dependency order |
| `TA-001-rbac-backend.md` | Chi tiết task RBAC (P0, BE) |
| `TA-002-audit-log-service.md` | Chi tiết task Audit Log (P0, BE) |
| `TA-003-frontend-skeleton.md` | Chi tiết task FE Skeleton (P0, FE) |
| `TA-004-auth-pages.md` | Chi tiết task Auth (P0, FE+BE) |
| `TA-008-knowledge-crud.md` | Chi tiết task KB CRUD (P1, FE+BE) — QUAN TRỌNG NHẤT |
| `TA-005-to-014-remaining.md` | Tasks P1 còn lại + toàn bộ P2 |
| `TA-015-to-023-p3-p4.md` | Toàn bộ P3 + P4 |

---

## Luồng Knowledge Entry CRUD (AR-08) — phải nhớ thuộc

```
Admin lưu entry
    ↓
UPDATE knowledge_entries (Postgres)
    ↓
INSERT embedding_jobs status="pending"  ← KHÔNG ĐƯỢC BỎ BƯỚC NÀY
    ↓
INSERT audit_logs (Mongo)               ← KHÔNG ĐƯỢC BỎ BƯỚC NÀY
    ↓
API response: { status: "pending", job_id }
    ↓
FE polling /embedding-jobs/{job_id} mỗi 3s
    ↓
Background worker embed → Qdrant
    ↓
UPDATE embedding_jobs status="done"
    ↓
FE badge: "Đã đồng bộ ✓"
```

---

## Khi không chắc về role nào được làm gì

Xem bảng **AR-09** trong `ADMIN_AGENT_RULES.md`.

Nguyên tắc nhanh:
- SUPER_ADMIN = làm tất cả
- ADMIN = làm tất cả trừ system_config write và role_change super_admin
- CONTENT_MANAGER = KB + Content + City Mapping + Intent Patterns (không động User/System)
- MODERATOR = Chat + Feedback (read-only phần còn lại)
