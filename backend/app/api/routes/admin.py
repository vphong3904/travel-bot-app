"""
Routes: /admin/*
Chỉ admin role mới được truy cập.

Knowledge Base:
  GET    /admin/knowledge          → Danh sách
  POST   /admin/knowledge          → Thêm mới (trigger embedding job)
  PATCH  /admin/knowledge/:id      → Sửa (trigger re-embed)
  DEL    /admin/knowledge/:id      → Xoá (soft delete)

Stats:
  GET /admin/stats/questions        → Câu hỏi phổ biến
  GET /admin/stats/destinations     → Điểm đến được quan tâm
  GET /admin/stats/chatbot          → Thống kê chatbot
  GET /admin/stats/users            → Thống kê users

Management:
  GET   /admin/users                → Danh sách users
  PATCH /admin/users/:id            → Cập nhật user (role, is_active)
  GET   /admin/chat-logs            → Log hội thoại
  GET   /admin/embedding-jobs       → Danh sách embedding jobs
"""
from uuid import UUID
from typing import Optional
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func, desc, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user, require_admin
from app.db.models.user import User
from app.db.models.chat import ChatSession, ChatMessage
from app.db.models.admin import KnowledgeEntry, EmbeddingJob, SearchHistory, UserBehavior
from app.db.schemas.admin import (
    KnowledgeEntryCreate,
    KnowledgeEntryUpdate,
    KnowledgeEntryOut,
    EmbeddingJobOut,
    StatsQuestionsOut,
    StatsDestinationsOut,
    StatsChatbotOut,
    StatsUsersOut,
    UserAdminOut,
    UserAdminUpdate,
    ChatLogOut,
)

router = APIRouter(tags=["admin"])


# ════════════════════════════════════════════════════════════
# KNOWLEDGE BASE
# ════════════════════════════════════════════════════════════

@router.get("/knowledge", response_model=list[KnowledgeEntryOut])
async def list_knowledge(
    category: Optional[str] = None,
    destination_id: Optional[UUID] = None,
    is_active: bool = True,
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    stmt = select(KnowledgeEntry).where(KnowledgeEntry.is_active == is_active)
    if category:
        stmt = stmt.where(KnowledgeEntry.category == category)
    if destination_id:
        stmt = stmt.where(KnowledgeEntry.destination_id == destination_id)
    stmt = stmt.order_by(KnowledgeEntry.created_at.desc()).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


@router.post("/knowledge", response_model=KnowledgeEntryOut, status_code=status.HTTP_201_CREATED)
async def create_knowledge(
    payload: KnowledgeEntryCreate,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    entry = KnowledgeEntry(**payload.model_dump())
    db.add(entry)
    await db.flush()  # get entry.id before commit

    # Tạo embedding job
    job = EmbeddingJob(entity_type="knowledge_entry", entity_id=entry.id)
    db.add(job)
    await db.commit()
    await db.refresh(entry)
    return entry


@router.patch("/knowledge/{entry_id}", response_model=KnowledgeEntryOut)
async def update_knowledge(
    entry_id: UUID,
    payload: KnowledgeEntryUpdate,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    entry = await _get_knowledge_or_404(db, entry_id)
    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(entry, field, value)

    # Nếu content thay đổi → re-embed
    if "content" in payload.model_dump(exclude_unset=True):
        job = EmbeddingJob(entity_type="knowledge_entry", entity_id=entry.id)
        db.add(job)

    await db.commit()
    await db.refresh(entry)
    return entry


@router.delete("/knowledge/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_knowledge(
    entry_id: UUID,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    entry = await _get_knowledge_or_404(db, entry_id)
    entry.is_active = False  # soft delete
    await db.commit()


# ════════════════════════════════════════════════════════════
# STATS
# ════════════════════════════════════════════════════════════

@router.get("/stats/questions", response_model=StatsQuestionsOut)
async def stats_questions(
    days: int = Query(30, description="Số ngày gần đây"),
    limit: int = Query(20, le=100),
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """Top câu hỏi / keyword được tìm nhiều nhất."""
    since = datetime.now(timezone.utc) - timedelta(days=days)

    # Top keywords
    kw_result = await db.execute(
        select(
            SearchHistory.keyword,
            func.count(SearchHistory.id).label("count"),
        )
        .where(SearchHistory.created_at >= since)
        .group_by(SearchHistory.keyword)
        .order_by(desc("count"))
        .limit(limit)
    )

    # Top intents from chat messages
    intent_result = await db.execute(
        select(
            ChatMessage.intent,
            func.count(ChatMessage.id).label("count"),
        )
        .where(
            ChatMessage.role == "user",
            ChatMessage.created_at >= since,
            ChatMessage.intent.isnot(None),
        )
        .group_by(ChatMessage.intent)
        .order_by(desc("count"))
        .limit(limit)
    )

    return StatsQuestionsOut(
        period_days=days,
        top_keywords=[{"keyword": r.keyword, "count": r.count} for r in kw_result.all()],
        top_intents=[{"intent": r.intent, "count": r.count} for r in intent_result.all()],
    )


@router.get("/stats/destinations", response_model=StatsDestinationsOut)
async def stats_destinations(
    days: int = 30,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """Điểm đến được xem / hỏi nhiều nhất."""
    since = datetime.now(timezone.utc) - timedelta(days=days)

    result = await db.execute(
        select(
            UserBehavior.entity_id,
            func.count(UserBehavior.id).label("count"),
        )
        .where(
            UserBehavior.entity_type == "destination",
            UserBehavior.event_type == "view_destination",
            UserBehavior.created_at >= since,
        )
        .group_by(UserBehavior.entity_id)
        .order_by(desc("count"))
        .limit(limit)
    )

    return StatsDestinationsOut(
        period_days=days,
        top_destinations=[
            {"destination_id": str(r.entity_id), "views": r.count}
            for r in result.all()
        ],
    )


@router.get("/stats/chatbot", response_model=StatsChatbotOut)
async def stats_chatbot(
    days: int = 30,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """Thống kê chatbot: tổng tin nhắn, feedback, latency trung bình."""
    since = datetime.now(timezone.utc) - timedelta(days=days)

    msg_result = await db.execute(
        select(
            func.count(ChatMessage.id).label("total"),
            func.avg(ChatMessage.latency_ms).label("avg_latency"),
            func.sum(ChatMessage.prompt_tokens + ChatMessage.completion_tokens).label("total_tokens"),
        ).where(
            ChatMessage.role == "assistant",
            ChatMessage.created_at >= since,
        )
    )
    row = msg_result.one()

    feedback_result = await db.execute(
        select(
            ChatMessage.feedback,
            func.count(ChatMessage.id).label("count"),
        )
        .where(
            ChatMessage.feedback.isnot(None),
            ChatMessage.created_at >= since,
        )
        .group_by(ChatMessage.feedback)
    )
    feedback_rows = feedback_result.all()
    thumbs_up = next((r.count for r in feedback_rows if r.feedback == 1), 0)
    thumbs_down = next((r.count for r in feedback_rows if r.feedback == -1), 0)

    return StatsChatbotOut(
        period_days=days,
        total_messages=row.total or 0,
        avg_latency_ms=round(row.avg_latency or 0, 1),
        total_tokens=row.total_tokens or 0,
        thumbs_up=thumbs_up,
        thumbs_down=thumbs_down,
    )


@router.get("/stats/users", response_model=StatsUsersOut)
async def stats_users(
    days: int = 30,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """Thống kê user: tổng, mới, active."""
    since = datetime.now(timezone.utc) - timedelta(days=days)

    total_result = await db.execute(
        select(func.count(User.id)).where(User.is_deleted.is_(False))
    )
    new_result = await db.execute(
        select(func.count(User.id)).where(
            User.created_at >= since,
            User.is_deleted.is_(False),
        )
    )
    # Active = có chat session trong kỳ
    active_result = await db.execute(
        select(func.count(func.distinct(ChatSession.user_id))).where(
            ChatSession.created_at >= since
        )
    )

    return StatsUsersOut(
        period_days=days,
        total_users=total_result.scalar() or 0,
        new_users=new_result.scalar() or 0,
        active_users=active_result.scalar() or 0,
    )


# ════════════════════════════════════════════════════════════
# USER MANAGEMENT
# ════════════════════════════════════════════════════════════

@router.get("/users", response_model=list[UserAdminOut])
async def list_users(
    role: Optional[str] = None,
    is_active: Optional[bool] = None,
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    stmt = select(User).where(User.is_deleted.is_(False))
    if role:
        stmt = stmt.where(User.role == role)
    if is_active is not None:
        stmt = stmt.where(User.is_active == is_active)
    stmt = stmt.order_by(User.created_at.desc()).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


@router.patch("/users/{user_id}", response_model=UserAdminOut)
async def update_user(
    user_id: UUID,
    payload: UserAdminUpdate,
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(require_admin),
):
    result = await db.execute(
        select(User).where(User.id == user_id, User.is_deleted.is_(False))
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(user, field, value)
    await db.commit()
    await db.refresh(user)
    return user


# ════════════════════════════════════════════════════════════
# CHAT LOGS
# ════════════════════════════════════════════════════════════

@router.get("/chat-logs", response_model=list[ChatLogOut])
async def get_chat_logs(
    user_id: Optional[UUID] = None,
    session_id: Optional[UUID] = None,
    role: Optional[str] = Query(None, pattern="^(user|assistant)$"),
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    stmt = select(ChatMessage).join(ChatSession)
    if user_id:
        stmt = stmt.where(ChatSession.user_id == user_id)
    if session_id:
        stmt = stmt.where(ChatMessage.session_id == session_id)
    if role:
        stmt = stmt.where(ChatMessage.role == role)
    stmt = stmt.order_by(ChatMessage.created_at.desc()).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


# ════════════════════════════════════════════════════════════
# EMBEDDING JOBS
# ════════════════════════════════════════════════════════════

@router.get("/embedding-jobs", response_model=list[EmbeddingJobOut])
async def get_embedding_jobs(
    job_status: Optional[str] = Query(None, alias="status"),
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    stmt = select(EmbeddingJob)
    if job_status:
        stmt = stmt.where(EmbeddingJob.status == job_status)
    stmt = stmt.order_by(EmbeddingJob.created_at.desc()).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()


# ── Helper ────────────────────────────────────────────────────────────────────
async def _get_knowledge_or_404(db: AsyncSession, entry_id: UUID) -> KnowledgeEntry:
    result = await db.execute(
        select(KnowledgeEntry).where(KnowledgeEntry.id == entry_id)
    )
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=404, detail="Knowledge entry not found")
    return entry