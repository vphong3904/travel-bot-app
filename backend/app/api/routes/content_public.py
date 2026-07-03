# app/api/routes/content_public.py
"""
Public content API — /api/content/*  (KHÔNG auth)

Mobile đọc content admin đã publish. CHỈ trả status='published' & chưa xoá —
draft không bao giờ lộ. Ghi vẫn ở /admin/content/* (require_admin).
"""
from __future__ import annotations

from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from app.api.deps import DB
from app.api.routes.admin import CONTENT_TYPES
from app.db.models.media import ContentItem
from sqlalchemy import func, select

router = APIRouter(tags=["content"])


def _serialize_public(c: ContentItem) -> dict:
    data = dict(c.data or {})
    data.setdefault("name", c.name)
    if c.image_url:
        data["image_url"] = c.image_url
    return {
        "id": str(c.id),
        "image_url": c.image_url,
        "city_slug": c.city_slug,
        "data": data,
    }


@router.get("/{content_type}")
async def list_public_content(
    content_type: str,
    city_slug: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: DB = None,
):
    if content_type not in CONTENT_TYPES:
        raise HTTPException(400, f"Content type '{content_type}' không hợp lệ")
    stmt = select(ContentItem).where(
        ContentItem.content_type == content_type,
        ContentItem.status == "published",
        ContentItem.is_deleted == False,  # noqa: E712
    )
    if city_slug:
        stmt = stmt.where(ContentItem.city_slug == city_slug)

    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows = await db.execute(
        stmt.order_by(ContentItem.updated_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    return {
        "total": total or 0,
        "page": page,
        "items": [_serialize_public(c) for c in rows.scalars().all()],
    }


@router.get("/{content_type}/{item_id}")
async def get_public_content(content_type: str, item_id: str, db: DB = None):
    item = await db.get(ContentItem, item_id)
    if (
        not item
        or item.is_deleted
        or item.status != "published"
        or item.content_type != content_type
    ):
        raise HTTPException(404, "Không tìm thấy")
    return _serialize_public(item)
