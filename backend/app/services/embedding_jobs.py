"""
EmbeddingJobService — Xử lý hàng đợi embedding cho Qdrant.

Worker flow:
  1. Lấy các job đang pending từ DB
  2. Load KnowledgeEntry tương ứng
  3. Chunk text → embed → upsert vào Qdrant
  4. Cập nhật job status (done / failed)

Được gọi:
  - Từ background task trong startup event
  - Hoặc gọi trực tiếp từ admin API sau khi tạo/sửa entry
"""

from __future__ import annotations

import asyncio
from datetime import datetime, timezone
from typing import Optional
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models.admin import EmbeddingJob, KnowledgeEntry
from app.utils import get_logger

logger = get_logger("embedding_jobs")

# Import lazy để tránh circular import và không load model khi import
def _get_rag():
    from app.services.rag_pipeline import RAGPipeline
    return RAGPipeline()


class EmbeddingJobService:
    """
    Async service xử lý embedding jobs.
    Dùng chung AsyncSession với request hoặc background task.
    """

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    # ── Query jobs ────────────────────────────────────────────────────────────

    async def get_pending(self, limit: int = 10) -> list[EmbeddingJob]:
        result = await self.db.execute(
            select(EmbeddingJob)
            .where(EmbeddingJob.status.in_(["pending", "processing"]))
            .order_by(EmbeddingJob.created_at.asc())
            .limit(limit)
        )
        return list(result.scalars().all())

    async def get_job(self, job_id: UUID) -> Optional[EmbeddingJob]:
        result = await self.db.execute(
            select(EmbeddingJob).where(EmbeddingJob.id == job_id)
        )
        return result.scalar_one_or_none()

    async def list(
        self,
        status: Optional[str] = None,
        skip: int = 0,
        limit: int = 50,
    ) -> list[EmbeddingJob]:
        stmt = select(EmbeddingJob)
        if status:
            stmt = stmt.where(EmbeddingJob.status == status)
        stmt = stmt.order_by(EmbeddingJob.created_at.desc()).offset(skip).limit(limit)
        result = await self.db.execute(stmt)
        return list(result.scalars().all())

    # ── Update status ─────────────────────────────────────────────────────────

    async def mark_processing(self, job: EmbeddingJob) -> None:
        job.status = "processing"
        job.updated_at = datetime.now(timezone.utc)
        await self.db.commit()

    async def mark_done(self, job: EmbeddingJob) -> None:
        job.status = "done"
        job.error = None
        job.updated_at = datetime.now(timezone.utc)
        await self.db.commit()

    async def mark_failed(self, job: EmbeddingJob, error: str) -> None:
        job.status = "failed"
        job.error = error[:500]  # tránh quá dài
        job.updated_at = datetime.now(timezone.utc)
        await self.db.commit()

    # ── Process single job ────────────────────────────────────────────────────

    async def process_job(self, job: EmbeddingJob) -> bool:
        """
        Xử lý một embedding job.
        Trả về True nếu thành công, False nếu thất bại.
        """
        await self.mark_processing(job)

        try:
            if job.entity_type != "knowledge_entry":
                raise ValueError(f"Unknown entity_type: {job.entity_type}")

            # Load knowledge entry
            result = await self.db.execute(
                select(KnowledgeEntry).where(
                    KnowledgeEntry.id == job.entity_id,
                    KnowledgeEntry.is_active == True,
                )
            )
            entry = result.scalar_one_or_none()

            if not entry:
                # Entry đã bị xoá hoặc inactive → bỏ qua
                logger.warning(f"[EmbedJob] Entry {job.entity_id} not found, skipping")
                await self.mark_done(job)
                return True

            rag = _get_rag()

            # Chunk text (entry dài sẽ được chia nhỏ)
            chunks = rag.chunk_text(entry.content)

            # Mỗi chunk là một vector riêng trong Qdrant
            # ID = "{entry_id}_{chunk_index}" để có thể xoá theo entry
            dest_id = str(entry.destination_id) if entry.destination_id else ""
            embed_entries = [
                {
                    "id": f"{entry.id}_{i}",
                    "text": chunk,
                    "title": entry.title,
                    "category": entry.category or "",
                    "destination_id": dest_id,
                }
                for i, chunk in enumerate(chunks)
            ]

            await rag.upsert_knowledge(embed_entries)
            await self.mark_done(job)

            logger.info(
                f"[EmbedJob] Done — entry={entry.id} chunks={len(chunks)}"
            )
            return True

        except Exception as exc:
            err_msg = str(exc)
            logger.error(f"[EmbedJob] Failed job={job.id}: {err_msg}")
            await self.mark_failed(job, err_msg)
            return False

    # ── Process batch (dùng trong background worker) ──────────────────────────

    async def run_pending(self, limit: int = 10) -> dict:
        """
        Xử lý tất cả pending jobs (tối đa `limit`).
        Trả về {"done": n, "failed": n}.
        """
        jobs = await self.get_pending(limit=limit)
        if not jobs:
            return {"done": 0, "failed": 0}

        logger.info(f"[EmbedJob] Processing {len(jobs)} pending jobs")
        done = failed = 0

        for job in jobs:
            ok = await self.process_job(job)
            if ok:
                done += 1
            else:
                failed += 1

        logger.info(f"[EmbedJob] Batch done — done={done} failed={failed}")
        return {"done": done, "failed": failed}
