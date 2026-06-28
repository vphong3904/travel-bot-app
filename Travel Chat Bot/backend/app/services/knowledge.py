"""
KnowledgeService — CRUD async cho KnowledgeEntry + trigger embedding.

Tất cả method đều dùng AsyncSession để khớp với FastAPI async stack.
Service này được gọi từ admin routes và embedding job worker.
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
from typing import Optional
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.admin import KnowledgeEntry, EmbeddingJob
from app.utils import get_logger

logger = get_logger("knowledge")


class KnowledgeService:
    """
    Đóng gói logic CRUD cho KnowledgeEntry.
    Mỗi lần tạo / cập nhật content sẽ tạo EmbeddingJob tương ứng.
    """

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ── Create ────────────────────────────────────────────────────────────────

    async def create(
        self,
        title: str,
        category: str,
        content: str,
        destination_id: Optional[UUID] = None,
        tags: Optional[list[str]] = None,
        source: Optional[str] = None,
    ) -> KnowledgeEntry:
        now = datetime.now(timezone.utc)
        entry = KnowledgeEntry(
            title=title,
            category=category,
            content=content,
            destination_id=destination_id,
            tags=tags or [],
            source=source,
            is_active=True,
            created_at=now,
            updated_at=now,
        )
        self.db.add(entry)
        await self.db.flush()  # lấy entry.id trước khi tạo job

        job = EmbeddingJob(
            entity_type="knowledge_entry",
            entity_id=entry.id,
            status="pending",
            created_at=now,
            updated_at=now,
        )
        self.db.add(job)
        await self.db.commit()
        await self.db.refresh(entry)

        logger.info(f"Created knowledge entry {entry.id} — '{title}'")
        return entry

    # ── Read ──────────────────────────────────────────────────────────────────

    async def get(self, entry_id: UUID) -> Optional[KnowledgeEntry]:
        result = await self.db.execute(
            select(KnowledgeEntry).where(KnowledgeEntry.id == entry_id)
        )
        return result.scalar_one_or_none()

    async def list(
        self,
        category: Optional[str] = None,
        destination_id: Optional[UUID] = None,
        is_active: bool = True,
        skip: int = 0,
        limit: int = 50,
    ) -> list[KnowledgeEntry]:
        stmt = select(KnowledgeEntry).where(KnowledgeEntry.is_active == is_active)
        if category:
            stmt = stmt.where(KnowledgeEntry.category == category)
        if destination_id:
            stmt = stmt.where(KnowledgeEntry.destination_id == destination_id)
        stmt = stmt.order_by(KnowledgeEntry.created_at.desc()).offset(skip).limit(limit)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    # ── Update ────────────────────────────────────────────────────────────────

    async def update(
        self,
        entry_id: UUID,
        **kwargs,
    ) -> Optional[KnowledgeEntry]:
        entry = await self.get(entry_id)
        if not entry:
            return None

        content_changed = "content" in kwargs and kwargs["content"] != entry.content

        for key, value in kwargs.items():
            setattr(entry, key, value)
        entry.updated_at = datetime.now(timezone.utc)

        # Nếu content thay đổi → tạo re-embed job
        if content_changed:
            job = EmbeddingJob(
                entity_type="knowledge_entry",
                entity_id=entry.id,
                status="pending",
                created_at=datetime.now(timezone.utc),
                updated_at=datetime.now(timezone.utc),
            )
            self.db.add(job)

        await self.db.commit()
        await self.db.refresh(entry)
        logger.info(f"Updated knowledge entry {entry_id}")
        return entry

    # ── Soft delete ───────────────────────────────────────────────────────────

    async def soft_delete(self, entry_id: UUID) -> bool:
        entry = await self.get(entry_id)
        if not entry:
            return False
        entry.is_active = False
        entry.updated_at = datetime.now(timezone.utc)
        await self.db.commit()
        logger.info(f"Soft-deleted knowledge entry {entry_id}")
        return True
