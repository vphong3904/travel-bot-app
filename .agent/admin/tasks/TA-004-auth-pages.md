# TA-004 · Auth Pages — Login / Forgot Password / Reset Password
> **Phase:** P0 — Nền tảng  
> **Nhãn:** [FE+BE]  
> **Status:** ⬜ TODO  
> **Priority:** 🔴 CRITICAL  
> **Dependency:** TA-001 DONE, TA-002 DONE, TA-003 DONE  
> **Estimated:** 2–3 giờ  
> **Thứ tự trong task:** BE schema confirm → FE implement

---

## Mục tiêu

Kết nối Frontend Admin với auth backend đã có sẵn. Backend auth hoạt động đầy đủ — task này chủ yếu là **FE** để gọi các endpoint đó, lưu token đúng cách, và handle refresh token tự động.

---

## Phần BE — Xác nhận API Contract (không viết mới)

Đọc `backend/app/api/routes/auth.py` và xác nhận các endpoint sau hoạt động đúng:

| Endpoint | Method | Request | Response |
|---|---|---|---|
| `/auth/login` | POST | `{email, password}` | `{access_token, token_type, user: {...}}` |
| `/auth/refresh` | POST | cookie `refresh_token` | `{access_token}` |
| `/auth/logout` | POST | Bearer token | `{message}` |
| `/auth/forgot-password` | POST | `{email}` | `{message}` |
| `/auth/reset-password` | POST | `{token, new_password}` | `{message}` |

**Nếu response `login` chưa trả về `user` object** (chỉ trả token), thêm vào `TokenResponse` schema:

```python
# backend/app/db/schemas/auth.py — mở rộng
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    # Thêm user info để FE không cần gọi thêm /me
    user: UserPublicResponse  # schema UserPublicResponse đã có
```

**Đảm bảo** refresh token được set vào httpOnly cookie trong response login:
```python
# Trong route login — kiểm tra xem đã có chưa
response.set_cookie(
    key="refresh_token",
    value=refresh_token_str,
    httponly=True,
    secure=True,      # chỉ HTTPS trong production
    samesite="lax",
    max_age=60 * 60 * 24 * 30,  # 30 ngày
)
```

---

## Phần FE — API functions

**File:** `src/api/admin/auth.ts`

```typescript
import { api } from "@/lib/api";

export interface LoginPayload {
  email: string;
  password: string;
}

export interface AuthUser {
  id: string;
  email: string;
  full_name: string;
  role: "super_admin" | "admin" | "content_manager" | "moderator" | "user";
}

export interface LoginResponse {
  access_token: string;
  token_type: string;
  user: AuthUser;
}

export const authApi = {
  login: (data: LoginPayload) =>
    api.post<LoginResponse>("/auth/login", data),

  logout: () =>
    api.post("/auth/logout"),

  forgotPassword: (email: string) =>
    api.post("/auth/forgot-password", { email }),

  resetPassword: (token: string, new_password: string) =>
    api.post("/auth/reset-password", { token, new_password }),
};
```

---

## Phần FE — LoginPage

```typescript
// src/pages/auth/LoginPage.tsx

const loginSchema = z.object({
  email: z.string().email("Email không hợp lệ"),
  password: z.string().min(1, "Vui lòng nhập mật khẩu"),
});

export function LoginPage() {
  const navigate = useNavigate();
  const { setAuth } = useAuthStore();
  
  const form = useForm<z.infer<typeof loginSchema>>({
    resolver: zodResolver(loginSchema),
  });

  const mutation = useMutation({
    mutationFn: authApi.login,
    onSuccess: (res) => {
      setAuth(res.data.access_token, res.data.user);
      navigate("/");
    },
    onError: (err: AxiosError<{ detail: string }>) => {
      toast.error(err.response?.data?.detail || "Đăng nhập thất bại");
    },
  });

  // UI: Logo PDTrip + form card + link quên mật khẩu
  // Không cần layout sidebar — trang này standalone
}
```

**UI yêu cầu:**
- Logo/tên hệ thống ở trên
- Card trung tâm: email input + password input (có toggle show/hide)
- Button "Đăng nhập" với loading state
- Link "Quên mật khẩu?" → /forgot-password
- Error message hiển thị dưới form (không dùng toast cho login error — user cần đọc rõ)

---

## Phần FE — ForgotPasswordPage + ResetPasswordPage

**ForgotPasswordPage:**
- Input email + button "Gửi link đặt lại"
- Sau submit: hiển thị "Kiểm tra email của bạn" (không cần popup)
- Link quay lại đăng nhập

**ResetPasswordPage:**
- Đọc `?token=xxx` từ URL params
- Input mật khẩu mới + xác nhận mật khẩu
- Zod validation: min 8 ký tự, phải khớp nhau
- Sau success: redirect /login với toast "Đặt lại mật khẩu thành công"

---

## Phần FE — useAuth hook

```typescript
// src/hooks/admin/useAuth.ts
import { useMutation } from "@tanstack/react-query";
import { useNavigate } from "react-router-dom";
import { useAuthStore } from "@/store/authStore";
import { authApi } from "@/api/admin/auth";

export function useLogout() {
  const { clearAuth } = useAuthStore();
  const navigate = useNavigate();
  
  return useMutation({
    mutationFn: authApi.logout,
    onSettled: () => {
      clearAuth();
      navigate("/login");
    },
  });
}
```

---

## Audit Log cho Login

Trong `backend/app/api/routes/auth.py`, sau khi login thành công, thêm:

```python
# Ghi audit log login (không bắt lỗi log — không được để log fail chặn login)
try:
    await log_audit(
        mongo_db=mongo_db,
        actor=user,
        action="login",
        resource_type="user",
        resource_id=str(user.id),
        request=request,
    )
except Exception:
    pass  # Log fail không được ảnh hưởng login flow
```

---

## Checklist DONE

**BE:**
- [ ] `GET /auth/login` response có `user` object với `role`
- [ ] Refresh token được set httpOnly cookie khi login
- [ ] Audit log ghi `action="login"` sau mỗi login thành công

**FE:**
- [ ] Login page: email/password form + error handling
- [ ] Zustand store lưu access token + user sau login
- [ ] Auto-refresh: khi token hết hạn, axios tự gọi /auth/refresh và retry
- [ ] Logout: clear store + xóa cookie
- [ ] Forgot password: gửi email, show confirmation
- [ ] Reset password: validate token URL, set mật khẩu mới
- [ ] ProtectedRoute redirect về /login khi store rỗng
- [ ] Không lưu access token vào localStorage

---

## Ghi chú khi DONE

```
completed_at:
notes:
```
