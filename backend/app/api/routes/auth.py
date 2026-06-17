from datetime import datetime, timezone
from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select, update

from app.api.deps import CurrentUser, DB
from app.core.security import (
    hash_password, verify_password,
    create_access_token, create_refresh_token, hash_token,
)
from app.db.models.user import User, RefreshToken
from app.db.schemas.auth import (
    RegisterRequest, LoginRequest, TokenResponse,
    RefreshRequest, UserResponse, UpdateProfileRequest,
)

router = APIRouter(tags=["auth"])


@router.post("/register", response_model=UserResponse, status_code=201)
async def register(body: RegisterRequest, db: DB):
    # Check duplicate
    dup = await db.execute(
        select(User).where((User.email == body.email) | (User.username == body.username))
    )
    if dup.scalar_one_or_none():
        raise HTTPException(400, "Email hoặc username đã tồn tại")

    now = datetime.now(timezone.utc)
    user = User(
        username=body.username,
        email=body.email,
        password_hash=hash_password(body.password),
        full_name=body.full_name,
        created_at=now,
        updated_at=now,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest, db: DB):
    result = await db.execute(select(User).where(User.email == body.email, User.is_deleted == False))
    user = result.scalar_one_or_none()
    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Sai email hoặc mật khẩu")

    access = create_access_token(str(user.id), {"role": user.role})
    raw_refresh, expires_at = create_refresh_token(str(user.id))

    db.add(RefreshToken(
        user_id=user.id,
        token_hash=hash_token(raw_refresh),
        expires_at=expires_at,
    ))
    await db.commit()
    return TokenResponse(access_token=access, refresh_token=raw_refresh)


@router.post("/refresh", response_model=TokenResponse)
async def refresh(body: RefreshRequest, db: DB):
    token_hash = hash_token(body.refresh_token)
    result = await db.execute(
        select(RefreshToken).where(
            RefreshToken.token_hash == token_hash,
            RefreshToken.revoked == False,
            RefreshToken.expires_at > datetime.now(timezone.utc),
        )
    )
    rt = result.scalar_one_or_none()
    if not rt:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Refresh token không hợp lệ")

    user_result = await db.execute(select(User).where(User.id == rt.user_id))
    user = user_result.scalar_one()

    # Rotate token
    rt.revoked = True
    access = create_access_token(str(user.id), {"role": user.role})
    raw_refresh, expires_at = create_refresh_token(str(user.id))
    db.add(RefreshToken(user_id=user.id, token_hash=hash_token(raw_refresh), expires_at=expires_at))
    await db.commit()
    return TokenResponse(access_token=access, refresh_token=raw_refresh)


@router.post("/logout", status_code=204)
async def logout(body: RefreshRequest, db: DB):
    token_hash = hash_token(body.refresh_token)
    await db.execute(
        update(RefreshToken)
        .where(RefreshToken.token_hash == token_hash)
        .values(revoked=True)
    )
    await db.commit()


@router.get("/me", response_model=UserResponse)
async def me(current_user: CurrentUser):
    return current_user


@router.patch("/me", response_model=UserResponse)
async def update_me(body: UpdateProfileRequest, current_user: CurrentUser, db: DB):
    if body.full_name is not None:
        current_user.full_name = body.full_name
    if body.avatar_url is not None:
        current_user.avatar_url = body.avatar_url
    await db.commit()
    await db.refresh(current_user)
    return current_user