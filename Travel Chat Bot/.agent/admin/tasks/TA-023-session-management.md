# TA-023 · Session Management (List/Revoke Refresh Tokens)
> **Phase:** P4  |  **Nhãn:** [FE+BE]  |  **Status:** ⬜ TODO  
> **Dependency:** TA-006 DONE  |  **Estimated:** 2 giờ

## Backend

Tái sử dụng model `RefreshToken` (đã có).

```python
GET    /admin/sessions?user_id=   # list refresh tokens active (revoked=False, expires_at > now)
DELETE /admin/sessions/{id}       # revoke: set revoked=True, audit log
```

## Frontend

Thêm **tab "Phiên đăng nhập"** vào `UserDetailDrawer` (TA-006) — tab thứ 3.

```
| Thông tin | Lịch sử chat | Phiên đăng nhập |

Bảng:
IP Address | User Agent | Ngày tạo | Hết hạn | Action
127.0.0.1  | Chrome/...  | 01/01/26 | 31/01/26 | [Thu hồi]
```

Nút "Thu hồi" → confirm dialog → DELETE → toast "Đã thu hồi phiên đăng nhập".

## Checklist DONE
- [ ] List active sessions (không show revoked)
- [ ] Revoke hoạt động + audit log
- [ ] Tab trong UserDetailDrawer

```
completed_at:
```
