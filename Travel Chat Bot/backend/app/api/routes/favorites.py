"""
Routes: /travel/favorites  (yêu thích của user đang đăng nhập)

POST   /travel/favorites/{destination_id}        → toggle yêu thích
GET    /travel/favorites                         → danh sách yêu thích của tôi
GET    /travel/favorites/{destination_id}/status → kiểm tra đã yêu thích chưa
DELETE /travel/favorites/{destination_id}        → bỏ yêu thích
"""

from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.api.deps import CurrentUser, DB
from app.db.models.travel import UserFavorite, Destination
from app.db.schemas.travel import FavoriteStatusOut, FavoriteDestinationOut

router = APIRouter(tags=["favorites"])


# ── Toggle yêu thích ─────────────────────────────────────────────────────────
@router.post(
    "/favorites/{destination_id}",
    response_model=FavoriteStatusOut,
    summary="Toggle yêu thích địa điểm (thêm nếu chưa có, xoá nếu đã có)",
)
async def toggle_favorite(
    destination_id: UUID,
    current_user: CurrentUser,
    db: DB,
):
    # Kiểm tra destination tồn tại
    dest = await db.get(Destination, destination_id)
    if not dest or not dest.is_active:
        raise HTTPException(status_code=404, detail="Destination not found")

    existing = await db.execute(
        select(UserFavorite).where(
            UserFavorite.user_id == current_user.id,
            UserFavorite.destination_id == destination_id,
        )
    )
    fav = existing.scalar_one_or_none()

    if fav:
        # Đã yêu thích → bỏ yêu thích
        await db.delete(fav)
        await db.commit()
        # DB trigger tự giảm favorite_count
        return FavoriteStatusOut(destination_id=destination_id, is_favorited=False)
    else:
        # Chưa yêu thích → thêm
        new_fav = UserFavorite(
            user_id=current_user.id,
            destination_id=destination_id,
        )
        db.add(new_fav)
        await db.commit()
        # DB trigger tự tăng favorite_count
        return FavoriteStatusOut(destination_id=destination_id, is_favorited=True)


# ── Danh sách yêu thích của tôi ──────────────────────────────────────────────
@router.get(
    "/favorites",
    response_model=list[FavoriteDestinationOut],
    summary="Lấy danh sách địa điểm yêu thích của tôi",
)
async def list_my_favorites(
    current_user: CurrentUser,
    db: DB,
    skip: int = 0,
    limit: int = Query(20, le=100),
):
    stmt = (
        select(UserFavorite)
        .options(
            selectinload(UserFavorite.destination).selectinload(Destination.categories)
        )
        .where(UserFavorite.user_id == current_user.id)
        .order_by(UserFavorite.created_at.desc())
        .offset(skip)
        .limit(limit)
    )
    result = await db.execute(stmt)
    favs = result.scalars().all()
    return favs


# ── Kiểm tra trạng thái yêu thích ───────────────────────────────────────────
@router.get(
    "/favorites/{destination_id}/status",
    response_model=FavoriteStatusOut,
    summary="Kiểm tra xem đã yêu thích địa điểm này chưa",
)
async def check_favorite_status(
    destination_id: UUID,
    current_user: CurrentUser,
    db: DB,
):
    result = await db.execute(
        select(UserFavorite).where(
            UserFavorite.user_id == current_user.id,
            UserFavorite.destination_id == destination_id,
        )
    )
    is_favorited = result.scalar_one_or_none() is not None
    return FavoriteStatusOut(destination_id=destination_id, is_favorited=is_favorited)


# ── Bỏ yêu thích (explicit DELETE) ───────────────────────────────────────────
@router.delete(
    "/favorites/{destination_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Bỏ yêu thích địa điểm",
)
async def remove_favorite(
    destination_id: UUID,
    current_user: CurrentUser,
    db: DB,
):
    result = await db.execute(
        select(UserFavorite).where(
            UserFavorite.user_id == current_user.id,
            UserFavorite.destination_id == destination_id,
        )
    )
    fav = result.scalar_one_or_none()
    if not fav:
        raise HTTPException(status_code=404, detail="Chưa yêu thích địa điểm này")

    await db.delete(fav)
    await db.commit()
    # DB trigger tự giảm favorite_count
