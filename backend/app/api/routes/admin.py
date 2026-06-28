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
from app.utils.uuid_v7 import uuid_v7
from typing import Optional
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select, func, desc, text
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user, require_admin, require_role
from app.db.models.user import User, UserRole
from app.db.mongo import get_mongo_db, COLLECTION_AUDIT_LOGS
from app.db.models.chat import ChatSession, ChatMessage
from app.db.models.admin import KnowledgeEntry, EmbeddingJob
from app.services import log_service
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
    UserRoleUpdate,
    AuditLogOut,
    AuditLogListOut,
    ChatLogOut,
)
from app.services.audit_service import log_audit

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

    # Top keywords — đọc từ MongoDB (search_history đã chuyển sang Mongo)
    top_keywords = await log_service.top_search_keywords(since=since, limit=limit)

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
        top_keywords=top_keywords,
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

    # user_behavior đã chuyển sang MongoDB
    top = await log_service.top_viewed_destinations(since=since, limit=limit)

    return StatsDestinationsOut(
        period_days=days,
        top_destinations=top,
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


@router.patch("/users/{user_id}/role", response_model=UserAdminOut)
async def update_user_role(
    user_id: UUID,
    body: UserRoleUpdate,
    db: AsyncSession = Depends(get_db),
    mongo_db=Depends(get_mongo_db),
    current_user: User = Depends(require_role([UserRole.SUPER_ADMIN])),
):
    """Chỉ Super Admin được đổi role người dùng."""
    result = await db.execute(
        select(User).where(User.id == user_id, User.is_deleted.is_(False))
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User không tồn tại")

    before_role = user.role
    user.role = body.role
    await db.commit()
    await db.refresh(user)

    await log_audit(
        mongo_db=mongo_db,
        actor=current_user,
        action="role_change",
        resource_type="user",
        resource_id=str(user_id),
        before_value={"role": before_role},
        after_value={"role": body.role},
    )

    return user


# ════════════════════════════════════════════════════════════
# AUDIT LOGS
# ════════════════════════════════════════════════════════════

@router.get("/audit-logs", response_model=AuditLogListOut)
async def get_audit_logs(
    actor_id: Optional[str] = Query(None),
    action: Optional[str] = Query(None),
    resource_type: Optional[str] = Query(None),
    from_date: Optional[datetime] = Query(None),
    to_date: Optional[datetime] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.SUPER_ADMIN])),
    mongo_db=Depends(get_mongo_db),
):
    """Xem audit log — chỉ ADMIN và SUPER_ADMIN."""
    query: dict = {}
    if actor_id:
        query["actor_id"] = actor_id
    if action:
        query["action"] = action
    if resource_type:
        query["resource_type"] = resource_type
    if from_date or to_date:
        query["created_at"] = {}
        if from_date:
            query["created_at"]["$gte"] = from_date
        if to_date:
            query["created_at"]["$lte"] = to_date

    total = await mongo_db[COLLECTION_AUDIT_LOGS].count_documents(query)
    skip = (page - 1) * page_size
    cursor = (
        mongo_db[COLLECTION_AUDIT_LOGS]
        .find(query, {"_id": 0})
        .sort("created_at", -1)
        .skip(skip)
        .limit(page_size)
    )
    items = await cursor.to_list(length=page_size)

    return AuditLogListOut(items=items, total=total, page=page, page_size=page_size)


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


@router.post("/embedding-jobs/run")
async def run_embedding_jobs(
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """
    Xử lý các embedding job đang pending — embed nội dung KnowledgeEntry
    và upsert vào Qdrant.

    Gọi route này sau khi tạo/sửa KnowledgeEntry để dữ liệu thực sự có
    trong Qdrant (POST /admin/knowledge chỉ tạo job "pending", không
    tự embed).
    """
    from app.services.embedding_jobs import EmbeddingJobService

    service = EmbeddingJobService(db)
    result = await service.run_pending(limit=limit)
    return result


# ── Helper ────────────────────────────────────────────────────────────────────
async def _get_knowledge_or_404(db: AsyncSession, entry_id: UUID) -> KnowledgeEntry:
    result = await db.execute(
        select(KnowledgeEntry).where(KnowledgeEntry.id == entry_id)
    )
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=404, detail="Knowledge entry not found")
    return entry

# ════════════════════════════════════════════════════════════
# DEBUG / DIAGNOSTICS (admin only)
# ════════════════════════════════════════════════════════════

@router.get("/qdrant-debug")
async def qdrant_debug(
    _: User = Depends(require_admin),
):
    """
    ✅ Debug: kiểm tra Qdrant collection status, số points, sample data.
    Dùng để chẩn đoán khi RAG trả về 0 results.
    """
    from app.services.rag_pipeline import RAGPipeline
    rag = RAGPipeline()
    return await rag.debug_collection()


@router.post("/knowledge/{entry_id}/embed-now")
async def embed_knowledge_now(
    entry_id: UUID,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_admin),
):
    """
    ✅ Trigger embedding ngay lập tức cho 1 entry cụ thể.
    Không cần đợi background job worker.
    """
    from app.services.embedding_jobs import EmbeddingJobService
    from app.db.models.admin import EmbeddingJob
    from datetime import datetime, timezone

    entry = await _get_knowledge_or_404(db, entry_id)

    # Tạo job mới và process ngay
    job = EmbeddingJob(
        entity_type="knowledge_entry",
        entity_id=str(entry.id),
        status="pending",
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
    )
    db.add(job)
    await db.commit()
    await db.refresh(job)

    service = EmbeddingJobService(db)
    success = await service.process_job(job)

    return {
        "entry_id": str(entry_id),
        "job_id": str(job.id),
        "success": success,
        "error": job.error,
    }

# ════════════════════════════════════════════════════════════
# UNANSWERED QUESTIONS  (MongoDB)
# ════════════════════════════════════════════════════════════

@router.get("/unanswered-questions")
async def list_unanswered_questions(
    is_resolved: Optional[bool] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    _: User = Depends(require_admin),
):
    """
    Danh sách câu hỏi chatbot không trả lời được — đọc từ MongoDB.
    Dùng is_resolved=false để lọc câu cần xử lý.
    """
    return await log_service.list_unanswered_questions(is_resolved, skip, limit)


@router.patch("/unanswered-questions/{question_id}/resolve")
async def resolve_unanswered_question(
    question_id: str,
    resolved_by: str = Query(..., description="Username / email người duyệt"),
    _: User = Depends(require_admin),
):
    """Đánh dấu câu hỏi unanswered đã được xử lý."""
    updated = await log_service.resolve_unanswered_question(question_id, resolved_by)
    if not updated:
        raise HTTPException(status_code=404, detail="Question not found")
    return {"status": "resolved", "question_id": question_id, "resolved_by": resolved_by}


# ════════════════════════════════════════════════════════════
# FLAGGED RESPONSES  (MongoDB — hallucination guard)
# ════════════════════════════════════════════════════════════

@router.get("/flagged-responses")
async def list_flagged_responses(
    is_reviewed: Optional[bool] = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    _: User = Depends(require_admin),
):
    """
    Danh sách phản hồi bị hallucination guard đánh dấu — đọc từ MongoDB.
    Dùng is_reviewed=false để lọc những câu cần admin review thủ công.
    """
    return await log_service.list_flagged_responses(is_reviewed, skip, limit)


@router.patch("/flagged-responses/{flagged_id}/review")
async def review_flagged_response(
    flagged_id: str,
    reviewer_note: Optional[str] = None,
    _: User = Depends(require_admin),
):
    """Đánh dấu flagged response đã được review, kèm ghi chú của admin."""
    updated = await log_service.review_flagged_response(flagged_id, reviewer_note)
    if not updated:
        raise HTTPException(status_code=404, detail="Flagged response not found")
    return {"status": "reviewed", "flagged_id": flagged_id}
