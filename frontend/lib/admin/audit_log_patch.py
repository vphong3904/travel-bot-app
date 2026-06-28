# backend/app/api/routes/auth.py
# Patch: thêm audit log sau login thành công (TA-004 — BE checklist)
#
# Tìm đoạn login endpoint hiện tại và thêm vào sau khi tạo TokenResponse:

# ----- PATCH BEGIN -----
# Vị trí: sau dòng "return TokenResponse(...)"
# Bọc return trong try/finally hoặc thêm background task:

from fastapi import BackgroundTasks
from app.services.audit_log import log_audit  # service từ TA-002

# Trong hàm login():
async def _do_audit_log(user, request, mongo_db):
    """Chạy audit log async — không block response."""
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
        pass  # log fail KHÔNG được ảnh hưởng login flow


# Cách tích hợp vào endpoint (dùng BackgroundTasks để không delay response):
#
# @router.post("/login", response_model=TokenResponse)
# async def login(
#     form: LoginForm,
#     request: Request,
#     background_tasks: BackgroundTasks,
#     db: AsyncSession = Depends(get_db),
#     mongo_db = Depends(get_mongo_db),
# ):
#     user = await authenticate_user(db, form.email, form.password)
#     if not user:
#         raise HTTPException(status_code=401, detail="Email hoặc mật khẩu không đúng")
#
#     access_token = create_access_token({"sub": str(user.id)})
#     response = TokenResponse(
#         access_token=access_token,
#         token_type="bearer",
#         user=UserSchema.from_orm(user),
#     )
#
#     # ← THÊM VÀO ĐÂY (TA-004)
#     background_tasks.add_task(_do_audit_log, user, request, mongo_db)
#
#     return response
# ----- PATCH END -----
