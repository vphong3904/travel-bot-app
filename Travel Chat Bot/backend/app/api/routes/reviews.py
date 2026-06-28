"""
Routes: /travel/destinations/{destination_id}/reviews

POST   /travel/destinations/:id/reviews          → tạo review (auth required)
GET    /travel/destinations/:id/reviews          → list reviews (public)
GET    /travel/destinations/:id/reviews/me       → review của tôi (auth required)
DELETE /travel/destinations/:id/reviews/{rev_id} → xoá review của tôi (auth required)
"""

from uuid import UUID
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.api.deps import get_db, get_current_user, CurrentUser, DB
from app.db.models.travel import Review, Destination
from app.db.models.user import User
from app.db.schemas.travel import ReviewCreate, ReviewOut, ReviewWithUserOut

router = APIRouter(tags=["reviews"])


# ── Helper ────────────────────────────────────────────────────────────────────
async def _get_dest_or_404(db: AsyncSession, destination_id: UUID) -> Destination:
    result = await db.execute(
        select(Destination).where(
            Destination.id == destination_id,
            Destination.is_active.is_(True),
        )
    )
    dest = result.scalar_one_or_none()
    if not dest:
        raise HTTPException(status_code=404, detail="Destination not found")
    return dest


# ── Tạo review ────────────────────────────────────────────────────────────────
@router.post(
    "/destinations/{destination_id}/reviews",
    response_model=ReviewOut,
    status_code=status.HTTP_201_CREATED,
    summary="Viết review cho địa điểm",
)
async def create_review(
    destination_id: UUID,
    body: ReviewCreate,
    current_user: CurrentUser,
    db: DB,
):
    await _get_dest_or_404(db, destination_id)

    # Mỗi user chỉ được review 1 lần / destination
    existing = await db.execute(
        select(Review).where(
            Review.user_id == current_user.id,
            Review.destination_id == destination_id,
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Bạn đã đánh giá địa điểm này rồi",
        )

    review = Review(
        user_id=current_user.id,
        destination_id=destination_id,
        rating=body.rating,
        content=body.content,
    )
    db.add(review)
    await db.commit()
    await db.refresh(review)

    # DB trigger tự cập nhật rating_avg và review_count trên destinations
    return review


# ── Danh sách reviews (public) ────────────────────────────────────────────────
@router.get(
    "/destinations/{destination_id}/reviews",
    response_model=list[ReviewWithUserOut],
    summary="Xem danh sách đánh giá của một địa điểm",
)
async def list_reviews(
    destination_id: UUID,
    db: DB,
    skip: int = 0,
    limit: int = Query(20, le=100),
):
    await _get_dest_or_404(db, destination_id)

    stmt = (
        select(Review, User.username, User.avatar_url)
        .join(User, Review.user_id == User.id)
        .where(Review.destination_id == destination_id)
        .order_by(Review.created_at.desc())
        .offset(skip)
        .limit(limit)
    )
    rows = (await db.execute(stmt)).all()

    result = []
    for review, username, avatar_url in rows:
        out = ReviewWithUserOut.model_validate(review)
        out.username = username
        out.avatar_url = avatar_url
        result.append(out)
    return result


# ── Review của tôi cho một destination ───────────────────────────────────────
@router.get(
    "/destinations/{destination_id}/reviews/me",
    response_model=ReviewOut,
    summary="Xem review của bản thân (nếu có)",
)
async def get_my_review(
    destination_id: UUID,
    current_user: CurrentUser,
    db: DB,
):
    await _get_dest_or_404(db, destination_id)

    result = await db.execute(
        select(Review).where(
            Review.user_id == current_user.id,
            Review.destination_id == destination_id,
        )
    )
    review = result.scalar_one_or_none()
    if not review:
        raise HTTPException(status_code=404, detail="Bạn chưa đánh giá địa điểm này")
    return review


# ── Xoá review ────────────────────────────────────────────────────────────────
@router.delete(
    "/destinations/{destination_id}/reviews/{review_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Xoá đánh giá của bản thân",
)
async def delete_review(
    destination_id: UUID,
    review_id: UUID,
    current_user: CurrentUser,
    db: DB,
):
    result = await db.execute(
        select(Review).where(
            Review.id == review_id,
            Review.destination_id == destination_id,
        )
    )
    review = result.scalar_one_or_none()
    if not review:
        raise HTTPException(status_code=404, detail="Review không tìm thấy")
    if review.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Không có quyền xoá review này")

    await db.delete(review)
    await db.commit()
    # Cập nhật thống kê sau khi xoá — do trigger chỉ xử lý INSERT nên ta tự cập nhật
    await _recalculate_review_stats(db, destination_id)


# ── Helpers internal ──────────────────────────────────────────────────────────
async def _recalculate_review_stats(db: AsyncSession, destination_id: UUID):
    """Tái tính rating_avg và review_count sau khi xoá review."""
    row = await db.execute(
        select(
            func.count(Review.id).label("cnt"),
            func.coalesce(func.avg(Review.rating), 0).label("avg"),
        ).where(Review.destination_id == destination_id)
    )
    stats = row.one()

    dest = await db.get(Destination, destination_id)
    if dest:
        dest.review_count = stats.cnt
        dest.rating_avg = round(float(stats.avg), 1)
        await db.commit()
