# app/api/routes/admin.py
"""
Admin routes — /api/admin/*

Tất cả endpoints yêu cầu role admin.
Role matrix đơn giản hoá: role IN ('admin', 'super_admin', 'content_manager', 'moderator').
"""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone, timedelta
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, Request, UploadFile, File, status
from sqlalchemy import cast, func, select, update, delete, Date, case
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import DB, CurrentUser, ADMIN_ROLES, require_admin, require_role
from app.db.database import AsyncSessionLocal
from app.db.models.admin import EmbeddingJob, KnowledgeEntry
from app.db.models.media import ContentItem, ContentOption
from app.db.models.chat import ChatMessage, ChatSession
from app.db.models.travel import (
    Destination, Location, Tour, Ticket,
    Itinerary, ItineraryItem, IntentPattern, LocationAlias, City,
)
from app.db.models.user import User
from app.services.knowledge import KnowledgeService
from app.services.embedding_jobs import EmbeddingJobService
from app.utils import get_logger

logger = get_logger("admin")
router = APIRouter(tags=["admin"])

# ── Guard: mọi endpoint đều cần admin role ────────────────────────────────────

def _admin(user: CurrentUser) -> User:
    if user.role not in ADMIN_ROLES:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Admin access required")
    return user

AdminUser = CurrentUser  # re-use; guard applied per endpoint with Depends


# ══════════════════════════════════════════════════════════════════════════════
# DASHBOARD STATS
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/stats/overview")
async def stats_overview(
    period: str = Query("month", pattern="^(day|week|month|year)$"),
    db: DB = None,
    _: User = Depends(require_admin),
):
    """Dashboard tổng quan — trả về đúng cấu trúc DashboardOverview cho Flutter."""
    now = datetime.now(timezone.utc)
    delta = {"day": 1, "week": 7, "month": 30, "year": 365}[period]
    since = now - timedelta(days=delta)

    # ── KPI counts ────────────────────────────────────────────────────────────
    total_users = await db.scalar(
        select(func.count(User.id)).where(User.is_deleted == False)
    )
    new_users = await db.scalar(
        select(func.count(User.id)).where(
            User.created_at >= since, User.is_deleted == False
        )
    )
    total_sessions = await db.scalar(select(func.count(ChatSession.id)))

    # Chỉ đếm assistant messages để tính answered_rate
    total_messages = await db.scalar(select(func.count(ChatMessage.id)))
    assistant_messages = await db.scalar(
        select(func.count(ChatMessage.id)).where(ChatMessage.role == "assistant")
    )
    user_messages = await db.scalar(
        select(func.count(ChatMessage.id)).where(ChatMessage.role == "user")
    )

    # answered_rate = số assistant msg / số user msg (tối đa 1.0)
    answered_rate: float = 0.0
    if user_messages and user_messages > 0:
        answered_rate = min(1.0, (assistant_messages or 0) / user_messages)

    # Pending: session bị flag / messages không có câu trả lời (heuristic)
    pending_flagged = await db.scalar(
        select(func.count(ChatSession.id)).where(ChatSession.is_flagged == True)
    )
    # Unanswered = user messages có feedback âm hoặc chưa có feedback
    pending_unanswered = await db.scalar(
        select(func.count(ChatMessage.id)).where(
            ChatMessage.role == "user",
            ChatMessage.feedback == None,  # noqa: E711
            ChatMessage.created_at >= since,
        )
    )

    # ── Time-series: users_over_time ─────────────────────────────────────────
    users_ts_rows = await db.execute(
        select(
            cast(func.date_trunc("day", User.created_at), Date).label("date"),
            func.count(User.id).label("count"),
        )
        .where(User.created_at >= since, User.is_deleted == False)
        .group_by("date")
        .order_by("date")
    )
    users_over_time = [
        {"date": str(r.date), "count": int(r.count)}
        for r in users_ts_rows
    ]

    # ── Time-series: messages_over_time ──────────────────────────────────────
    messages_ts_rows = await db.execute(
        select(
            cast(func.date_trunc("day", ChatMessage.created_at), Date).label("date"),
            func.count(ChatMessage.id).label("count"),
        )
        .where(ChatMessage.created_at >= since)
        .group_by("date")
        .order_by("date")
    )
    messages_over_time = [
        {"date": str(r.date), "count": int(r.count)}
        for r in messages_ts_rows
    ]

    # ── Top destinations (by favorite_count + view_count) ────────────────────
    top_dest_rows = await db.execute(
        select(Destination.name, Destination.favorite_count, Destination.view_count)
        .where(Destination.is_active == True)
        .order_by((Destination.favorite_count + Destination.view_count).desc())
        .limit(10)
    )
    top_destinations = [
        {"destination": r.name, "count": int((r.favorite_count or 0) + (r.view_count or 0))}
        for r in top_dest_rows
    ]

    # ── Intent breakdown (từ ChatMessage.intent trong period) ─────────────────
    intent_rows = await db.execute(
        select(
            ChatMessage.intent.label("intent"),
            func.count(ChatMessage.id).label("count"),
        )
        .where(
            ChatMessage.intent != None,  # noqa: E711
            ChatMessage.created_at >= since,
        )
        .group_by(ChatMessage.intent)
        .order_by(func.count(ChatMessage.id).desc())
        .limit(10)
    )
    intent_breakdown = [
        {"intent": r.intent, "count": int(r.count)}
        for r in intent_rows
    ]

    return {
        "period": period,
        "kpi": {
            "total_users": total_users or 0,
            "new_users_this_period": new_users or 0,
            "total_chat_sessions": total_sessions or 0,
            "total_messages": total_messages or 0,
            "answered_rate": round(answered_rate, 4),
            "pending_unanswered": pending_unanswered or 0,
            "pending_flagged": pending_flagged or 0,
        },
        "users_over_time": users_over_time,
        "messages_over_time": messages_over_time,
        "top_destinations": top_destinations,
        "intent_breakdown": intent_breakdown,
    }


@router.get("/stats/feedback")
async def stats_feedback(
    period: str = Query("month", pattern="^(day|week|month|year)$"),
    db: DB = None,
    _: User = Depends(require_admin),
):
    """Thống kê feedback theo ngày trong period."""
    now = datetime.now(timezone.utc)
    delta = {"day": 1, "week": 7, "month": 30, "year": 365}[period]
    since = now - timedelta(days=delta)

    rows = await db.execute(
        select(
            func.date_trunc("day", ChatMessage.created_at).label("date"),
            func.sum(
                case((ChatMessage.feedback == 1, 1), else_=0)
            ).label("positive"),
            func.sum(
                case((ChatMessage.feedback == -1, 1), else_=0)
            ).label("negative"),
        )
        .where(ChatMessage.created_at >= since)
        .group_by("date")
        .order_by("date")
    )
    daily = [
        {
            "date": str(r.date)[:10],
            "positive": int(r.positive or 0),
            "negative": int(r.negative or 0),
        }
        for r in rows
    ]
    return {"daily": daily, "period": period}


@router.get("/stats/export")
async def stats_export(
    format: str = Query("excel"),
    report: str = Query("overview"),
    period: str = Query("month"),
    _: User = Depends(require_admin),
):
    """Export placeholder — trả về JSON. Thay bằng openpyxl nếu cần file thật."""
    return {"message": "Export feature coming soon", "format": format, "report": report}


# ══════════════════════════════════════════════════════════════════════════════
# USER MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/users")
async def list_users(
    q: Optional[str] = None,
    role: Optional[str] = None,
    is_active: Optional[bool] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, le=100),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(User).where(User.is_deleted == False)
    if q:
        stmt = stmt.where(
            User.email.ilike(f"%{q}%") | User.username.ilike(f"%{q}%")
        )
    if role:
        stmt = stmt.where(User.role == role)
    if is_active is not None:
        stmt = stmt.where(User.is_active == is_active)

    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows = await db.execute(stmt.offset((page - 1) * limit).limit(limit))
    users = rows.scalars().all()

    return {
        "total": total or 0,
        "page": page,
        "items": [_user_dict(u) for u in users],
    }


@router.get("/users/{user_id}")
async def get_user(
    user_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    u = await _get_or_404(db, User, user_id)

    sessions_count = await db.scalar(
        select(func.count(ChatSession.id)).where(
            ChatSession.user_id == user_id, ChatSession.is_deleted == False
        )
    )
    messages_count = await db.scalar(
        select(func.count(ChatMessage.id)).join(
            ChatSession, ChatMessage.session_id == ChatSession.id
        ).where(ChatSession.user_id == user_id)
    )

    recent_sessions_rows = await db.execute(
        select(ChatSession)
        .where(ChatSession.user_id == user_id, ChatSession.is_deleted == False)
        .order_by(ChatSession.updated_at.desc())
        .limit(5)
    )
    recent_sessions = [
        {
            "id": s.id,
            "title": s.title,
            "total_messages": s.total_messages,
            "updated_at": str(s.updated_at),
        }
        for s in recent_sessions_rows.scalars()
    ]

    return {
        **_user_dict(u),
        "total_chat_sessions": sessions_count or 0,
        "total_messages": messages_count or 0,
        "recent_sessions": recent_sessions,
    }


@router.patch("/users/{user_id}")
async def update_user(
    user_id: str,
    body: dict,
    db: DB = None,
    actor: User = Depends(require_admin),
):
    u = await _get_or_404(db, User, user_id)
    if "is_active" in body:
        u.is_active = bool(body["is_active"])
    if "role" in body:
        if actor.role not in ("admin", "super_admin"):
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Chỉ admin mới đổi được role")
        u.role = body["role"]
    u.updated_at = datetime.now(timezone.utc)
    await db.commit()
    return _user_dict(u)


@router.patch("/users/{user_id}/role")
async def change_role(
    user_id: str,
    body: dict,
    db: DB = None,
    actor: User = Depends(require_role(["admin", "super_admin"])),
):
    u = await _get_or_404(db, User, user_id)
    u.role = body.get("role", u.role)
    u.updated_at = datetime.now(timezone.utc)
    await db.commit()
    return _user_dict(u)


# ══════════════════════════════════════════════════════════════════════════════
# CHAT SESSIONS (admin view)
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/chat-sessions")
async def list_chat_sessions(
    user_id: Optional[str] = None,
    is_flagged: Optional[bool] = None,
    q: Optional[str] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, le=100),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(ChatSession).where(ChatSession.is_deleted == False)
    if user_id:
        stmt = stmt.where(ChatSession.user_id == user_id)
    if is_flagged is not None:
        stmt = stmt.where(ChatSession.is_flagged == is_flagged)
    if q:
        stmt = stmt.where(ChatSession.title.ilike(f"%{q}%"))

    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows = await db.execute(
        stmt.order_by(ChatSession.updated_at.desc()).offset((page - 1) * limit).limit(limit)
    )
    sessions = rows.scalars().all()

    return {
        "total": total or 0,
        "page": page,
        "items": [
            {
                "id": s.id,
                "user_id": s.user_id,
                "title": s.title,
                "total_messages": s.total_messages,
                "is_flagged": s.is_flagged,
                "created_at": str(s.created_at),
                "updated_at": str(s.updated_at),
            }
            for s in sessions
        ],
    }


@router.get("/chat-sessions/{session_id}/messages")
async def get_session_messages(
    session_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    rows = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at)
    )
    messages = rows.scalars().all()
    return [
        {
            "id": m.id,
            "role": m.role,
            "content": m.content,
            "intent": m.intent,
            "feedback": m.feedback,
            "latency_ms": m.latency_ms,
            "created_at": str(m.created_at),
        }
        for m in messages
    ]


@router.delete("/chat-sessions/{session_id}")
async def delete_chat_session(
    session_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    await db.execute(
        update(ChatSession)
        .where(ChatSession.id == session_id)
        .values(is_deleted=True)
    )
    await db.commit()
    return {"ok": True}


# ══════════════════════════════════════════════════════════════════════════════
# KNOWLEDGE BASE
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/knowledge")
async def list_knowledge(
    q: Optional[str] = None,
    category: Optional[str] = None,
    is_active: Optional[bool] = None,
    page: int = Query(1, ge=1),
    limit: int = Query(20, le=100),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(KnowledgeEntry)
    if q:
        stmt = stmt.where(
            KnowledgeEntry.title.ilike(f"%{q}%") | KnowledgeEntry.content.ilike(f"%{q}%")
        )
    if category:
        stmt = stmt.where(KnowledgeEntry.category == category)
    if is_active is not None:
        stmt = stmt.where(KnowledgeEntry.is_active == is_active)

    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows = await db.execute(
        stmt.order_by(KnowledgeEntry.created_at.desc()).offset((page - 1) * limit).limit(limit)
    )
    entries = rows.scalars().all()

    return {
        "total": total or 0,
        "page": page,
        "items": [
            {
                "id": e.id,
                "title": e.title,
                "content": e.content or "",
                "category": e.category,
                "tags": e.tags or [],
                "is_active": e.is_active,
                "qdrant_id": e.qdrant_id,
                "embedding_status": "done" if e.qdrant_id else "not_embedded",
                "source": e.source,
                "created_at": str(e.created_at),
                "updated_at": str(e.updated_at),
            }
            for e in entries
        ],
    }


@router.post("/knowledge", status_code=201)
async def create_knowledge(
    body: dict,
    db: DB = None,
    _: User = Depends(require_admin),
):
    svc = KnowledgeService(db)
    entry = await svc.create(
        title=body["title"],
        category=body["category"],
        content=body["content"],
        tags=body.get("tags", []),
        source=body.get("source"),
    )
    return {"id": entry.id, "title": entry.title, "status": "pending"}


@router.patch("/knowledge/{entry_id}")
async def update_knowledge(
    entry_id: str,
    body: dict,
    db: DB = None,
    _: User = Depends(require_admin),
):
    svc = KnowledgeService(db)
    entry = await svc.update(
        entry_id=entry_id,
        title=body.get("title"),
        content=body.get("content"),
        tags=body.get("tags"),
        is_active=body.get("is_active"),
    )
    return {"id": entry.id, "title": entry.title, "status": "pending"}


@router.delete("/knowledge/{entry_id}")
async def delete_knowledge(
    entry_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    svc = KnowledgeService(db)
    await svc.delete(entry_id)
    return {"ok": True}


# ══════════════════════════════════════════════════════════════════════════════
# EMBEDDING JOBS
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/embedding-jobs/{job_id}")
async def get_embedding_job(
    job_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    result = await db.execute(
        select(EmbeddingJob).where(EmbeddingJob.id == job_id)
    )
    job = result.scalar_one_or_none()
    if not job:
        raise HTTPException(404, "Job not found")
    return {
        "id": job.id,
        "entity_type": job.entity_type,
        "entity_id": job.entity_id,
        "status": job.status,
        "error": job.error,
        "created_at": str(job.created_at),
        "updated_at": str(job.updated_at),
    }


@router.post("/embedding-jobs/run")
async def run_embedding_jobs(
    limit: int = Query(50, le=500),
    db: DB = None,
    _: User = Depends(require_admin),
):
    svc = EmbeddingJobService(db)
    result = await svc.run_pending(limit=limit)
    return result


# ══════════════════════════════════════════════════════════════════════════════
# KB HEALTH CHECK
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/kb-health")
async def kb_health(
    db: DB = None,
    _: User = Depends(require_admin),
):
    total_entries = await db.scalar(select(func.count(KnowledgeEntry.id)).where(KnowledgeEntry.is_active == True))
    pending_jobs = await db.scalar(
        select(func.count(EmbeddingJob.id)).where(EmbeddingJob.status == "pending")
    )
    failed_jobs = await db.scalar(
        select(func.count(EmbeddingJob.id)).where(EmbeddingJob.status == "failed")
    )
    done_jobs = await db.scalar(
        select(func.count(EmbeddingJob.id)).where(EmbeddingJob.status == "done")
    )

    try:
        from app.services.rag_pipeline import RAGPipeline
        qdrant_info = await RAGPipeline().debug_collection()
    except Exception as e:
        qdrant_info = {"error": str(e)}

    return {
        "postgres": {
            "total_active_entries": total_entries or 0,
            "pending_embedding_jobs": pending_jobs or 0,
            "failed_embedding_jobs": failed_jobs or 0,
            "done_embedding_jobs": done_jobs or 0,
        },
        "qdrant": qdrant_info,
    }


# ══════════════════════════════════════════════════════════════════════════════
# RAG MONITORING
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/rag-monitoring/overview")
async def rag_overview(
    period: str = Query("week"),
    db: DB = None,
    _: User = Depends(require_admin),
):
    delta = {"day": 1, "week": 7, "month": 30}.get(period, 7)
    since = datetime.now(timezone.utc) - timedelta(days=delta)

    avg_confidence = await db.scalar(
        select(func.avg(ChatMessage.confidence_score)).where(
            ChatMessage.created_at >= since, ChatMessage.confidence_score.isnot(None)
        )
    )
    avg_search_ms = await db.scalar(
        select(func.avg(ChatMessage.search_ms)).where(
            ChatMessage.created_at >= since, ChatMessage.search_ms.isnot(None)
        )
    )
    avg_llm_ms = await db.scalar(
        select(func.avg(ChatMessage.llm_ms)).where(
            ChatMessage.created_at >= since, ChatMessage.llm_ms.isnot(None)
        )
    )
    avg_chunk_count = await db.scalar(
        select(func.avg(ChatMessage.chunk_count)).where(
            ChatMessage.created_at >= since, ChatMessage.chunk_count.isnot(None)
        )
    )

    # hallucination_rate = tỉ lệ messages có confidence < 0.3
    total_assistant = await db.scalar(
        select(func.count(ChatMessage.id)).where(
            ChatMessage.role == "assistant",
            ChatMessage.created_at >= since,
            ChatMessage.confidence_score.isnot(None),
        )
    ) or 0
    low_confidence = await db.scalar(
        select(func.count(ChatMessage.id)).where(
            ChatMessage.role == "assistant",
            ChatMessage.created_at >= since,
            ChatMessage.confidence_score < 0.3,
        )
    ) or 0
    hallucination_rate = (low_confidence / total_assistant) if total_assistant > 0 else 0.0

    # cache_hit_rate breakdown
    cache_rows = await db.execute(
        select(ChatMessage.cache_hit, func.count(ChatMessage.id).label("cnt"))
        .where(ChatMessage.created_at >= since, ChatMessage.cache_hit.isnot(None))
        .group_by(ChatMessage.cache_hit)
    )
    total_cache = 0
    cache_counts: dict = {}
    for r in cache_rows:
        cache_counts[r.cache_hit] = r.cnt
        total_cache += r.cnt
    cache_hit_rate = {
        k: round(v / total_cache, 3) if total_cache > 0 else 0.0
        for k, v in cache_counts.items()
    }

    # search_method breakdown
    method_rows = await db.execute(
        select(ChatMessage.search_method, func.count(ChatMessage.id).label("cnt"))
        .where(ChatMessage.created_at >= since, ChatMessage.search_method.isnot(None))
        .group_by(ChatMessage.search_method)
    )
    total_methods = 0
    method_counts: dict = {}
    for r in method_rows:
        method_counts[r.search_method] = r.cnt
        total_methods += r.cnt
    search_method_breakdown = {
        k: round(v / total_methods, 3) if total_methods > 0 else 0.0
        for k, v in method_counts.items()
    }

    # confidence_over_time
    conf_rows = await db.execute(
        select(
            cast(func.date_trunc("day", ChatMessage.created_at), Date).label("date"),
            func.avg(ChatMessage.confidence_score).label("avg_score"),
        )
        .where(ChatMessage.created_at >= since, ChatMessage.confidence_score.isnot(None))
        .group_by("date")
        .order_by("date")
    )
    confidence_over_time = [
        {"date": str(r.date), "avg_score": round(float(r.avg_score or 0), 3)}
        for r in conf_rows
    ]

    return {
        "period": period,
        "avg_confidence_score": round(float(avg_confidence or 0), 3),
        "avg_search_ms": round(float(avg_search_ms or 0), 1),
        "avg_llm_ms": round(float(avg_llm_ms or 0), 1),
        "avg_chunk_count": round(float(avg_chunk_count or 0), 1),
        "hallucination_rate": round(hallucination_rate, 3),
        "cache_hit_rate": cache_hit_rate,
        "search_method_breakdown": search_method_breakdown,
        "confidence_over_time": confidence_over_time,
    }


@router.get("/rag-monitoring/latency")
async def rag_latency(
    period: str = Query("week"),
    db: DB = None,
    _: User = Depends(require_admin),
):
    delta = {"day": 1, "week": 7, "month": 30}.get(period, 7)
    since = datetime.now(timezone.utc) - timedelta(days=delta)

    rows = await db.execute(
        select(
            func.date_trunc("day", ChatMessage.created_at).label("date"),
            func.avg(ChatMessage.latency_ms).label("avg_ms"),
            func.percentile_cont(0.95).within_group(ChatMessage.latency_ms).label("p95_ms"),
        )
        .where(ChatMessage.created_at >= since, ChatMessage.latency_ms.isnot(None))
        .group_by("date")
        .order_by("date")
    )
    return {
        "items": [
            {
                "date": str(r.date)[:10],
                "avg_ms": round(float(r.avg_ms or 0), 1),
                "p95_ms": round(float(r.p95_ms or 0), 1),
            }
            for r in rows
        ]
    }


@router.get("/rag-monitoring/errors")
async def rag_errors(
    period: str = Query("week"),
    db: DB = None,
    _: User = Depends(require_admin),
):
    delta = {"day": 1, "week": 7, "month": 30}.get(period, 7)
    since = datetime.now(timezone.utc) - timedelta(days=delta)

    rows = await db.execute(
        select(ChatMessage)
        .where(
            ChatMessage.created_at >= since,
            ChatMessage.role == "assistant",
            ChatMessage.confidence_score < 0.3,
        )
        .order_by(ChatMessage.created_at.desc())
        .limit(50)
    )
    messages = rows.scalars().all()
    return {
        "items": [
            {
                "id": m.id,
                "content": m.content[:200],
                "confidence_score": m.confidence_score,
                "intent": m.intent,
                "created_at": str(m.created_at),
            }
            for m in messages
        ]
    }


# ══════════════════════════════════════════════════════════════════════════════
# CITY MAPPINGS
# ══════════════════════════════════════════════════════════════════════════════

# Simple in-memory city mappings (can be moved to DB later)
_city_overrides: dict[str, str] = {}


@router.get("/city-mappings/validate")
async def validate_city_mappings(
    _: User = Depends(require_admin),
):
    """Trả danh sách province names và mapping hiện tại."""
    from app.services.nlp_preprocessor import INTENT_PATTERNS
    import os

    kb_path = "knowledge-base"
    existing_folders = set()
    if os.path.isdir(kb_path):
        existing_folders = {
            d for d in os.listdir(kb_path)
            if os.path.isdir(os.path.join(kb_path, d))
        }

    # Lấy danh sách provinces từ DB
    return [
        {
            "old_province": slug,
            "mapped_slug": _city_overrides.get(slug, slug),
            "folder_exists": _city_overrides.get(slug, slug) in existing_folders,
            "suggestion": None,
        }
        for slug in list(existing_folders)[:50]
    ]


@router.get("/city-mappings/valid-slugs")
async def valid_slugs(
    db: DB = None,
    _: User = Depends(require_admin),
):
    """Trả danh sách city slug từ bảng destinations."""
    from app.db.models.travel import Destination
    rows = await db.execute(
        select(Destination.slug)
        .where(Destination.slug.isnot(None), Destination.is_active == True)
        .order_by(Destination.slug)
    )
    slugs = [r[0] for r in rows if r[0]]
    return slugs or []


@router.patch("/city-mappings/{old_province}")
async def update_city_mapping(
    old_province: str,
    body: dict,
    _: User = Depends(require_admin),
):
    _city_overrides[old_province] = body["new_slug"]
    return {"ok": True, "old_province": old_province, "new_slug": body["new_slug"]}


# ══════════════════════════════════════════════════════════════════════════════
# INTENT PATTERNS
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/intent-patterns")
async def list_intent_patterns(
    _: User = Depends(require_admin),
):
    from app.services.nlp_preprocessor import INTENT_PATTERNS
    result: dict = {}
    for intent, kws in INTENT_PATTERNS.items():
        keyword_list = [
            {
                "keyword": kw,
                "is_collision": sum(1 for _, v in INTENT_PATTERNS.items() if kw in v) > 1,
            }
            for kw in kws
        ]
        result[intent] = {"keywords": keyword_list, "collision_warnings": []}
    return result


@router.post("/intent-patterns/{intent}/keywords", status_code=201)
async def add_keyword(
    intent: str,
    body: dict,
    _: User = Depends(require_admin),
):
    from app.services.nlp_preprocessor import INTENT_PATTERNS, reload_intent_patterns
    kw = body.get("keyword", "").strip().lower()
    if not kw:
        raise HTTPException(400, "keyword không được trống")
    if intent not in INTENT_PATTERNS:
        raise HTTPException(404, f"Intent '{intent}' không tồn tại")
    if kw not in INTENT_PATTERNS[intent]:
        INTENT_PATTERNS[intent].append(kw)
        _save_intent_patterns(INTENT_PATTERNS)
        reload_intent_patterns()
    return {"ok": True}


@router.delete("/intent-patterns/{intent}/keywords/{keyword}")
async def delete_keyword(
    intent: str,
    keyword: str,
    _: User = Depends(require_admin),
):
    from app.services.nlp_preprocessor import INTENT_PATTERNS, reload_intent_patterns
    if intent not in INTENT_PATTERNS:
        raise HTTPException(404, f"Intent '{intent}' không tồn tại")
    if keyword in INTENT_PATTERNS[intent]:
        INTENT_PATTERNS[intent].remove(keyword)
        _save_intent_patterns(INTENT_PATTERNS)
        reload_intent_patterns()
    return {"ok": True}


@router.post("/intent-patterns/test")
async def test_intent(body: dict):
    from app.services.nlp_preprocessor import detect_intent, extract_entities
    text = body.get("text", "")
    entities = extract_entities(text)
    intent, confidence = detect_intent(text, entities)
    return {"intent": intent, "confidence": confidence, "matched_keywords": []}


@router.post("/intent-patterns/reload")
async def reload_intent_patterns_db(
    db: DB,
    _: User = Depends(require_admin),
):
    """
    [OPT-3.1/3.3] Nạp lại intent patterns từ bảng DB `intent_patterns` vào runtime
    chatbot — không cần restart server. Gọi sau khi sửa pattern qua Admin.
    """
    from app.services.intent_loader import load_intent_patterns_from_db
    total = await load_intent_patterns_from_db(db)
    return {"ok": True, "applied_keywords": total}


def _save_intent_patterns(patterns: dict) -> None:
    """Lưu patterns về file JSON."""
    import os
    path = os.path.join(os.path.dirname(__file__), "..", "..", "..", "app", "data", "intent_patterns.json")
    path = os.path.normpath(path)
    try:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(patterns, f, ensure_ascii=False, indent=2)
    except Exception as e:
        logger.warning(f"Không thể lưu intent_patterns.json: {e}")


# ══════════════════════════════════════════════════════════════════════════════
# CONTENT MANAGEMENT (generic CRUD)
# ══════════════════════════════════════════════════════════════════════════════

# content_type hợp lệ. faq & experiences KHÔNG ở đây — chúng là knowledge entries
# (quản lý qua /admin/knowledge). Content lưu ở bảng content_items (JSONB).
CONTENT_TYPES: set[str] = {
    "destinations", "hotels", "tours", "foods", "restaurants",
    "shopping", "itineraries", "events", "transport",
}


def _serialize_content(c: ContentItem) -> dict:
    """Chuẩn hoá 1 ContentItem cho FE (ContentItem.fromJson)."""
    data = dict(c.data or {})
    data.setdefault("name", c.name)
    if c.image_url:
        data["image_url"] = c.image_url
    return {
        "id": str(c.id),
        "status": c.status,
        "is_deleted": c.is_deleted,
        "image_url": c.image_url,
        "created_at": str(c.created_at),
        "updated_at": str(c.updated_at),
        "data": data,
    }


def _extract_content_fields(body: dict) -> tuple[str, str | None, dict]:
    """Tách name / image_url ra khỏi phần data động."""
    data = {k: v for k, v in body.items() if k not in ("city_slug",)}
    name = (data.get("name") or "Untitled").strip() or "Untitled"
    image_url = data.get("image_url") or None
    return name, image_url, data


@router.get("/content/{content_type}")
async def list_content(
    content_type: str,
    city_slug: Optional[str] = None,       # optional — không còn "cổng bắt buộc chọn city"
    status: Optional[str] = None,
    search: Optional[str] = None,
    sort: str = Query("newest"),           # newest | oldest | name
    date_from: Optional[str] = None,       # YYYY-MM-DD
    date_to: Optional[str] = None,         # YYYY-MM-DD
    field: Optional[str] = None,           # key trong data để lọc
    value: Optional[str] = None,           # giá trị khớp (ilike)
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: DB = None,
    _: User = Depends(require_admin),
):
    if content_type not in CONTENT_TYPES:
        raise HTTPException(400, f"Content type '{content_type}' không hợp lệ")

    stmt = select(ContentItem).where(
        ContentItem.content_type == content_type,
        ContentItem.is_deleted == False,  # noqa: E712
    )
    if city_slug:
        stmt = stmt.where(ContentItem.city_slug == city_slug)
    if status:
        stmt = stmt.where(ContentItem.status == status)
    if search:
        stmt = stmt.where(ContentItem.name.ilike(f"%{search}%"))
    if date_from:
        stmt = stmt.where(cast(ContentItem.created_at, Date) >= date_from)
    if date_to:
        stmt = stmt.where(cast(ContentItem.created_at, Date) <= date_to)
    if field and value:
        stmt = stmt.where(ContentItem.data[field].astext.ilike(f"%{value}%"))

    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    order = {
        "oldest": ContentItem.created_at.asc(),
        "name": ContentItem.name.asc(),
    }.get(sort, ContentItem.created_at.desc())
    rows = await db.execute(
        stmt.order_by(order).offset((page - 1) * page_size).limit(page_size)
    )
    items = rows.scalars().all()
    return {
        "total": total or 0,
        "page": page,
        "items": [_serialize_content(c) for c in items],
    }


@router.post("/content/{content_type}", status_code=201)
async def create_content(
    content_type: str,
    body: dict,
    city_slug: Optional[str] = None,
    db: DB = None,
    _: User = Depends(require_admin),
):
    if content_type not in CONTENT_TYPES:
        raise HTTPException(400, "Content type không hợp lệ")
    name, image_url, data = _extract_content_fields(body)
    item = ContentItem(
        content_type=content_type,
        city_slug=city_slug or body.get("city_slug"),
        name=name,
        data=data,
        image_url=image_url,
        status="draft",
    )
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return _serialize_content(item)


@router.patch("/content/{content_type}/{item_id}")
async def update_content(
    content_type: str,
    item_id: str,
    body: dict,
    db: DB = None,
    _: User = Depends(require_admin),
):
    item = await db.get(ContentItem, item_id)
    if not item or item.is_deleted:
        raise HTTPException(404, "Không tìm thấy mục")
    name, image_url, data = _extract_content_fields(body)
    item.name = name
    item.data = data
    item.image_url = image_url
    item.updated_at = datetime.now(timezone.utc)
    await db.commit()
    await db.refresh(item)
    return _serialize_content(item)


@router.delete("/content/{content_type}/{item_id}")
async def delete_content(
    content_type: str,
    item_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    item = await db.get(ContentItem, item_id)
    if item:
        item.is_deleted = True
        item.updated_at = datetime.now(timezone.utc)
        await db.commit()
    return {"ok": True}


@router.patch("/content/{content_type}/{item_id}/publish")
async def publish_content(
    content_type: str,
    item_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    await db.execute(
        update(ContentItem)
        .where(ContentItem.id == item_id)
        .values(status="published", updated_at=datetime.now(timezone.utc))
    )
    await db.commit()
    return {"ok": True}


# ── Cities (master list cho dropdown/filter content) ──────────────────────────

@router.get("/cities")
async def list_cities(
    q: Optional[str] = None,
    db: DB = None,
    _: User = Depends(require_admin),
):
    """
    Danh sách city (mức điểm đến) cho dropdown filter. Search KHÔNG phân biệt dấu
    (unaccent) theo tên điểm đến, tên tỉnh mới (34), hoặc alias tỉnh cũ (63) —
    gõ "da lat" ra Đà Lạt, "kien giang" ra Phú Quốc.
    """
    stmt = select(City).where(City.is_active == True)  # noqa: E712
    if q:
        like = f"%{q}%"
        stmt = stmt.where(
            func.unaccent(City.name).ilike(func.unaccent(like))
            | func.unaccent(func.coalesce(City.province, "")).ilike(func.unaccent(like))
            | func.unaccent(func.array_to_string(City.old_aliases, " ")).ilike(
                func.unaccent(like))
        )
    rows = await db.execute(stmt.order_by(City.province, City.name))
    return [
        {"id": str(c.id), "slug": c.slug, "name": c.name,
         "province": c.province, "region": c.region}
        for c in rows.scalars().all()
    ]


# ── Content options (taxonomy: "loại" theo content_type + field) ──────────────

def _serialize_option(o: ContentOption) -> dict:
    return {
        "id": str(o.id), "content_type": o.content_type, "field": o.field,
        "code": o.code, "label": o.label, "sort_order": o.sort_order,
        "is_active": o.is_active,
    }


@router.get("/content-options")
async def list_content_options(
    content_type: Optional[str] = None,
    field: Optional[str] = None,
    db: DB = None,
    _: User = Depends(require_admin),
):
    """Danh sách options. Form lọc theo content_type+field (và is_active phía FE);
    màn quản lý lấy tất cả."""
    stmt = select(ContentOption)
    if content_type:
        stmt = stmt.where(ContentOption.content_type == content_type)
    if field:
        stmt = stmt.where(ContentOption.field == field)
    rows = await db.execute(
        stmt.order_by(ContentOption.content_type, ContentOption.field,
                      ContentOption.sort_order, ContentOption.label)
    )
    return [_serialize_option(o) for o in rows.scalars().all()]


@router.post("/content-options", status_code=201)
async def create_content_option(
    body: dict, db: DB = None, _: User = Depends(require_admin),
):
    for f in ("content_type", "field", "code", "label"):
        if not body.get(f):
            raise HTTPException(422, f"Thiếu '{f}'")
    obj = ContentOption(
        content_type=body["content_type"], field=body["field"],
        code=body["code"].strip(), label=body["label"].strip(),
        sort_order=body.get("sort_order", 0),
    )
    db.add(obj)
    await db.commit()
    await db.refresh(obj)
    return _serialize_option(obj)


@router.patch("/content-options/{opt_id}")
async def update_content_option(
    opt_id: str, body: dict, db: DB = None, _: User = Depends(require_admin),
):
    obj = await _get_or_404(db, ContentOption, opt_id)
    for f in ("content_type", "field", "code", "label", "sort_order", "is_active"):
        if f in body:
            setattr(obj, f, body[f])
    await db.commit()
    return _serialize_option(obj)


@router.delete("/content-options/{opt_id}", status_code=204)
async def delete_content_option(
    opt_id: str, db: DB = None, _: User = Depends(require_admin),
):
    obj = await _get_or_404(db, ContentOption, opt_id)
    await db.delete(obj)
    await db.commit()


# ══════════════════════════════════════════════════════════════════════════════
# CHATBOT TEST (admin thử chatbot ngay trong panel — không lưu DB, không giới hạn)
# ══════════════════════════════════════════════════════════════════════════════

_admin_rag = None


def _clean_bot_answer(text: str) -> str:
    """Bỏ markdown ** và trích dẫn [1] khỏi câu trả lời chatbot cho gọn."""
    text = text or ""
    text = re.sub(r"\s*\[\d+\]", "", text)      # bỏ [1], [2]... (kèm space trước)
    text = text.replace("**", "")               # bỏ in đậm markdown
    text = re.sub(r"(?m)^\s*\*\s+", "• ", text)  # bullet '*   ' → '• '
    return text.strip()


def _get_admin_rag():
    global _admin_rag
    if _admin_rag is None:
        from app.services.rag_pipeline import RAGPipeline
        _admin_rag = RAGPipeline()
    return _admin_rag


@router.post("/chatbot/test")
async def chatbot_test(
    body: dict,
    _: User = Depends(require_admin),
):
    """
    Chạy RAG cho 1 câu hỏi để admin test chatbot. KHÔNG lưu session/history vào DB,
    không giới hạn. `history` (tùy chọn) = [{"role","content"}, ...] cho ngữ cảnh.
    """
    question = (body.get("content") or "").strip()
    if not question:
        raise HTTPException(422, "content không được trống")
    history = body.get("history") or []
    rag = _get_admin_rag()
    result = await rag.query(
        question=question,
        history=history,
        session_id="admin-test",
    )
    return {
        "answer": _clean_bot_answer(result.get("answer", "")),
        "intent": result.get("intent"),
        "confidence_score": result.get("confidence_score"),
        "sources": result.get("sources", []),
        "latency_ms": result.get("latency_ms"),
        "search_method": result.get("search_method"),
    }


# ══════════════════════════════════════════════════════════════════════════════
# FEEDBACK MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/feedback")
async def list_feedback(
    type: Optional[str] = None,
    category: Optional[str] = None,
    intent: Optional[str] = None,
    page: int = Query(1, ge=1),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(ChatMessage).where(ChatMessage.feedback.isnot(None))
    if type == "positive":
        stmt = stmt.where(ChatMessage.feedback == 1)
    elif type == "negative":
        stmt = stmt.where(ChatMessage.feedback == -1)
    if intent:
        stmt = stmt.where(ChatMessage.intent == intent)

    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows = await db.execute(
        stmt.order_by(ChatMessage.created_at.desc()).offset((page - 1) * 20).limit(20)
    )
    messages = rows.scalars().all()

    return {
        "total": total or 0,
        "page": page,
        "items": [
            {
                "message_id": m.id,
                "session_id": m.session_id,
                "content_preview": m.content[:150],
                "feedback_type": "positive" if m.feedback == 1 else "negative",
                "category": None,
                "reason": None,
                "intent": m.intent,
                "resolved": False,
                "created_at": str(m.created_at),
            }
            for m in messages
        ],
    }


@router.patch("/feedback/{message_id}/resolve")
async def resolve_feedback(
    message_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    # feedback_resolved column được thêm ở migration 28
    try:
        await db.execute(
            update(ChatMessage)
            .where(ChatMessage.id == message_id)
            .values(feedback_resolved=True)
        )
        await db.commit()
    except Exception:
        # Column chưa tồn tại nếu migration chưa chạy
        pass
    return {"ok": True}


# ══════════════════════════════════════════════════════════════════════════════
# MEDIA — trình quản lý ảnh dạng CMS (thư mục + ảnh, lưu DB + local disk)
# ══════════════════════════════════════════════════════════════════════════════
#
# - media_folders: cây thư mục (root / folder con) — TA-018 + yêu cầu CMS.
# - media_files:  ảnh, gắn folder_id, soft delete. File lưu static/uploads,
#                 mount /uploads ở main.py. URL = /uploads/<filename>.
# - Upload: multi-select nhiều ảnh 1 lần, Pillow resize ≤1920 → WebP (best-effort).
# Role: đọc = mọi admin role; tạo/sửa/xoá = admin/super_admin/content_manager.

import os as _os

_UPLOAD_DIR = _os.path.join("static", "uploads")
_ALLOWED_EXT = {"jpg", "jpeg", "png", "webp"}
_MAX_UPLOAD_BYTES = 8 * 1024 * 1024  # giới hạn input (sau resize WebP còn nhỏ hơn)

_media_writer = require_role(["admin", "super_admin", "content_manager"])


def _process_image(content: bytes, ext: str) -> tuple[bytes, str, Optional[str], Optional[int], Optional[int]]:
    """Resize ≤1920px + convert WebP nếu có Pillow. Lỗi/không có Pillow → giữ nguyên."""
    try:
        import io
        from PIL import Image

        img = Image.open(io.BytesIO(content))
        if img.mode not in ("RGB", "RGBA", "L"):
            img = img.convert("RGBA")
        w, h = img.size
        max_side = 1920
        if max(w, h) > max_side:
            ratio = max_side / float(max(w, h))
            img = img.resize((max(1, int(w * ratio)), max(1, int(h * ratio))))
        buf = io.BytesIO()
        img.save(buf, format="WEBP", quality=82, method=4)
        out = buf.getvalue()
        return out, "webp", "image/webp", img.size[0], img.size[1]
    except Exception:
        return content, ext, None, None, None


def _folder_uuid(value: Optional[str]) -> Optional[UUID]:
    if not value or str(value).lower() in ("", "null", "none", "root"):
        return None
    try:
        return UUID(str(value))
    except (ValueError, TypeError):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "folder_id không hợp lệ")


# ── Folders ───────────────────────────────────────────────────────────────────

@router.get("/media/folders")
async def list_media_folders(db: DB = None, _: User = Depends(require_admin)):
    """Trả về toàn bộ thư mục (phẳng) kèm số ảnh + thời điểm thêm ảnh gần nhất.

    FE tự dựng cây từ parent_id và sắp xếp thư mục theo last_added để hiển thị
    thư mục vừa thêm ảnh gần nhất lên trước.
    """
    from app.db.models.media import MediaFolder, MediaFile

    folders = (await db.execute(
        select(MediaFolder).order_by(MediaFolder.created_at.asc())
    )).scalars().all()

    # Đếm ảnh + last_added theo folder (1 query gom nhóm)
    stats = (await db.execute(
        select(
            MediaFile.folder_id,
            func.count(MediaFile.id),
            func.max(MediaFile.created_at),
        )
        .where(MediaFile.is_deleted == False)
        .group_by(MediaFile.folder_id)
    )).all()
    by_folder = {str(fid): (cnt, last) for fid, cnt, last in stats if fid is not None}

    return [
        {
            "id": str(f.id),
            "name": f.name,
            "parent_id": str(f.parent_id) if f.parent_id else None,
            "image_count": by_folder.get(str(f.id), (0, None))[0],
            "last_added": (by_folder.get(str(f.id), (0, None))[1].isoformat()
                           if by_folder.get(str(f.id), (0, None))[1] else None),
            "created_at": f.created_at.isoformat() if f.created_at else None,
        }
        for f in folders
    ]


@router.post("/media/folders", status_code=201)
async def create_media_folder(
    body: dict, db: DB = None, actor: User = Depends(_media_writer),
):
    from app.db.models.media import MediaFolder

    name = (body.get("name") or "").strip()
    if not name:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Tên thư mục không được trống")
    parent_id = _folder_uuid(body.get("parent_id"))

    if parent_id is not None:
        parent = (await db.execute(
            select(MediaFolder).where(MediaFolder.id == parent_id)
        )).scalar_one_or_none()
        if not parent:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Thư mục cha không tồn tại")

    folder = MediaFolder(name=name, parent_id=parent_id, created_by=actor.id)
    db.add(folder)
    try:
        await db.commit()
    except Exception:
        await db.rollback()
        raise HTTPException(status.HTTP_409_CONFLICT, "Đã có thư mục trùng tên trong thư mục này")
    await db.refresh(folder)
    return {
        "id": str(folder.id),
        "name": folder.name,
        "parent_id": str(folder.parent_id) if folder.parent_id else None,
        "image_count": 0,
        "last_added": None,
        "created_at": folder.created_at.isoformat() if folder.created_at else None,
    }


@router.patch("/media/folders/{folder_id}")
async def rename_media_folder(
    folder_id: str, body: dict, db: DB = None, _: User = Depends(_media_writer),
):
    from app.db.models.media import MediaFolder

    name = (body.get("name") or "").strip()
    if not name:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Tên thư mục không được trống")
    folder = (await db.execute(
        select(MediaFolder).where(MediaFolder.id == _folder_uuid(folder_id))
    )).scalar_one_or_none()
    if not folder:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Thư mục không tồn tại")
    folder.name = name
    try:
        await db.commit()
    except Exception:
        await db.rollback()
        raise HTTPException(status.HTTP_409_CONFLICT, "Đã có thư mục trùng tên trong thư mục này")
    return {"id": folder_id, "name": name}


@router.delete("/media/folders/{folder_id}")
async def delete_media_folder(
    folder_id: str, db: DB = None, _: User = Depends(_media_writer),
):
    """Xoá thư mục (cascade thư mục con); ảnh bên trong gỡ folder_id (giữ ảnh)."""
    from app.db.models.media import MediaFolder

    fid = _folder_uuid(folder_id)
    folder = (await db.execute(
        select(MediaFolder).where(MediaFolder.id == fid)
    )).scalar_one_or_none()
    if not folder:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Thư mục không tồn tại")
    await db.delete(folder)
    await db.commit()
    return {"ok": True}


# ── Files ─────────────────────────────────────────────────────────────────────

@router.get("/media")
async def list_media(
    folder_id: Optional[str] = None,
    tag: Optional[str] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(24, ge=1, le=100),
    db: DB = None,
    _: User = Depends(require_admin),
):
    from app.db.models.media import MediaFile

    stmt = select(MediaFile).where(MediaFile.is_deleted == False)
    if folder_id is not None:
        stmt = stmt.where(MediaFile.folder_id == _folder_uuid(folder_id))
    if tag:
        stmt = stmt.where(MediaFile.tags.any(tag))

    total = (await db.execute(
        select(func.count()).select_from(stmt.subquery())
    )).scalar() or 0

    rows = (await db.execute(
        stmt.order_by(MediaFile.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )).scalars().all()

    return {
        "total": total,
        "page": page,
        "items": [
            {
                "id": str(m.id),
                "filename": m.filename,
                "original_name": m.original_name,
                "file_path": m.file_path,
                "file_size": m.file_size,
                "mime_type": m.mime_type,
                "width": m.width,
                "height": m.height,
                "tags": list(m.tags or []),
                "folder_id": str(m.folder_id) if m.folder_id else None,
                "created_at": m.created_at.isoformat() if m.created_at else None,
            }
            for m in rows
        ],
    }


@router.post("/media/upload", status_code=201)
async def upload_media(
    files: list[UploadFile] = File(...),
    folder_id: Optional[str] = Query(None),
    db: DB = None,
    actor: User = Depends(_media_writer),
):
    """Upload nhiều ảnh 1 lần vào thư mục đang mở (folder_id)."""
    from app.db.models.media import MediaFile, MediaFolder
    import uuid as _uuid

    fid = _folder_uuid(folder_id)
    if fid is not None:
        exists = (await db.execute(
            select(MediaFolder.id).where(MediaFolder.id == fid)
        )).scalar_one_or_none()
        if not exists:
            raise HTTPException(status.HTTP_404_NOT_FOUND, "Thư mục không tồn tại")

    _os.makedirs(_UPLOAD_DIR, exist_ok=True)
    saved = []
    for file in files:
        ext = (_os.path.splitext(file.filename or "")[1].lstrip(".") or "jpg").lower()
        if ext not in _ALLOWED_EXT:
            raise HTTPException(status.HTTP_400_BAD_REQUEST,
                                f"Định dạng không hỗ trợ: {file.filename} (chỉ jpg/png/webp)")
        content = await file.read()
        if len(content) > _MAX_UPLOAD_BYTES:
            raise HTTPException(status.HTTP_400_BAD_REQUEST,
                                f"Ảnh quá lớn (>8MB): {file.filename}")

        out, out_ext, mime, width, height = _process_image(content, ext)
        filename = f"{_uuid.uuid4()}.{out_ext}"
        with open(_os.path.join(_UPLOAD_DIR, filename), "wb") as f:
            f.write(out)

        record = MediaFile(
            filename=filename,
            original_name=file.filename,
            file_path=f"/uploads/{filename}",
            file_size=len(out),
            mime_type=mime or file.content_type,
            width=width,
            height=height,
            tags=[],
            folder_id=fid,
            uploaded_by=actor.id,
        )
        db.add(record)
        saved.append(record)

    await db.commit()
    for r in saved:
        await db.refresh(r)
    return [
        {
            "id": str(r.id),
            "filename": r.filename,
            "original_name": r.original_name,
            "file_path": r.file_path,
            "file_size": r.file_size,
            "mime_type": r.mime_type,
            "width": r.width,
            "height": r.height,
            "tags": [],
            "folder_id": str(r.folder_id) if r.folder_id else None,
            "created_at": r.created_at.isoformat() if r.created_at else None,
        }
        for r in saved
    ]


@router.delete("/media/{media_id}")
async def delete_media(
    media_id: str, db: DB = None, _: User = Depends(_media_writer),
):
    from app.db.models.media import MediaFile

    try:
        mid = UUID(media_id)
    except (ValueError, TypeError):
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "media_id không hợp lệ")
    await db.execute(
        update(MediaFile).where(MediaFile.id == mid).values(is_deleted=True)
    )
    await db.commit()
    return {"ok": True}


# ══════════════════════════════════════════════════════════════════════════════
# UNANSWERED QUESTIONS
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/unanswered-questions")
async def list_unanswered(
    db: DB = None,
    _: User = Depends(require_admin),
):
    rows = await db.execute(
        select(ChatMessage)
        .where(
            ChatMessage.role == "assistant",
            ChatMessage.confidence_score < 0.3,
        )
        .order_by(ChatMessage.created_at.desc())
        .limit(50)
    )
    messages = rows.scalars().all()
    # FE (unanswered_list) mong {items:[...]} với field `question` + `is_promoted`.
    return {
        "total": len(messages),
        "items": [
            {
                "id": m.id,
                "question": (m.content or "")[:300],
                "confidence_score": m.confidence_score,
                "intent": m.intent,
                "is_promoted": False,
                "created_at": str(m.created_at),
            }
            for m in messages
        ],
    }


@router.post("/unanswered-questions/{question_id}/promote-to-kb")
async def promote_to_kb(
    question_id: str,
    body: dict | None = None,
    db: DB = None,
    _: User = Depends(require_admin),
):
    # FE có thể gọi không kèm body → tự lấy title/content từ chính message.
    body = body or {}
    title = body.get("title")
    content = body.get("content")
    if not title or not content:
        msg = await db.get(ChatMessage, question_id)
        text = (msg.content if msg else "") or ""
        title = title or (text[:80] or "Câu hỏi chưa trả lời")
        content = content or text
    svc = KnowledgeService(db)
    entry = await svc.create(
        title=title,
        category=body.get("category", "faq"),
        content=content or title,
    )
    return {"id": entry.id, "status": "pending"}


# ══════════════════════════════════════════════════════════════════════════════
# SYSTEM CONFIG
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/system-config")
async def get_system_config(
    db: DB = None,
    _: User = Depends(require_admin),
):
    try:
        from sqlalchemy import text
        rows = await db.execute(text("SELECT key, value, description, updated_at FROM system_configs"))
        return [
            {
                "key": r.key,
                "value": r.value,
                "description": r.description,
                "updated_at": str(r.updated_at) if r.updated_at else None,
            }
            for r in rows
        ]
    except Exception:
        return []


@router.patch("/system-config/{key}")
async def update_system_config(
    key: str,
    body: dict,
    db: DB = None,
    actor: User = Depends(require_role(["admin", "super_admin"])),
):
    from sqlalchemy import text
    value = body.get("value")
    await db.execute(
        text(
            "UPDATE system_configs SET value = :value, updated_by = :uid, updated_at = NOW() "
            "WHERE key = :key"
        ),
        {"value": json.dumps(value), "uid": actor.id, "key": key},
    )
    await db.commit()
    return {"ok": True, "key": key, "value": value}


# ══════════════════════════════════════════════════════════════════════════════
# SESSION MANAGEMENT
# ══════════════════════════════════════════════════════════════════════════════

@router.get("/sessions")
async def list_sessions(
    user_id: Optional[str] = None,
    db: DB = None,
    _: User = Depends(require_admin),
):
    from app.db.models.user import RefreshToken
    stmt = select(RefreshToken).where(
        RefreshToken.revoked == False,
        RefreshToken.expires_at > datetime.now(timezone.utc),
    )
    if user_id:
        stmt = stmt.where(RefreshToken.user_id == user_id)
    rows = await db.execute(stmt.order_by(RefreshToken.created_at.desc()).limit(50))
    tokens = rows.scalars().all()
    return [
        {
            "id": t.id,
            "user_id": t.user_id,
            "ip_address": None,
            "user_agent": None,
            "created_at": str(t.created_at),
            "expires_at": str(t.expires_at),
        }
        for t in tokens
    ]


@router.delete("/sessions/{session_id}")
async def revoke_session(
    session_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    from app.db.models.user import RefreshToken
    await db.execute(
        update(RefreshToken).where(RefreshToken.id == session_id).values(revoked=True)
    )
    await db.commit()
    return {"ok": True}


# ══════════════════════════════════════════════════════════════════════════════
# HELPERS
# ══════════════════════════════════════════════════════════════════════════════

async def _get_or_404(db: AsyncSession, model, id: str):
    result = await db.execute(select(model).where(model.id == id))
    obj = result.scalar_one_or_none()
    if not obj:
        raise HTTPException(404, f"{model.__name__} không tồn tại")
    return obj


def _user_dict(u: User) -> dict:
    return {
        "id": u.id,
        "username": u.username,
        "email": u.email,
        "full_name": u.full_name,
        "avatar_url": u.avatar_url,
        "role": u.role,
        "is_active": u.is_active,
        "auth_provider": u.auth_provider,
        "created_at": str(u.created_at),
        "updated_at": str(u.updated_at),
    }


# ══════════════════════════════════════════════════════════════════════════════
# STRUCTURED CONTENT CRUD (T-028)
# CRUD cho các bảng: locations, tours, itineraries, intent_patterns, locations_alias
# ══════════════════════════════════════════════════════════════════════════════

# ── Locations (attractions) ───────────────────────────────────────────────

@router.get("/locations")
async def list_locations(
    destination_id: Optional[str] = None,
    page: int = Query(1, ge=1),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(Location)
    if destination_id:
        stmt = stmt.where(Location.destination_id == destination_id)
    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows  = await db.execute(stmt.order_by(Location.created_at.desc()).offset((page - 1) * 20).limit(20))
    items = rows.scalars().all()
    return {
        "total": total or 0, "page": page,
        "items": [{"id": str(i.id), "name": i.name, "type": i.type,
                   "verified": i.verified, "data_source": i.data_source} for i in items],
    }


@router.post("/locations", status_code=201)
async def create_location(body: dict, db: DB = None, _: User = Depends(require_admin)):
    import uuid as _uuid
    obj = Location(
        id=_uuid.uuid4(),
        destination_id=body.get("destination_id"),
        name=body["name"],
        type=body.get("type"),
        address=body.get("address"),
        hours=body.get("hours"),
        description=body.get("description"),
        tips=body.get("tips"),
        image_url=body.get("image_url"),
        data_source=body.get("data_source"),
    )
    db.add(obj)
    await db.commit()
    await db.refresh(obj)
    return {"id": str(obj.id)}


@router.patch("/locations/{loc_id}")
async def update_location(loc_id: str, body: dict, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, Location, loc_id)
    for field in ("name", "type", "address", "hours", "description", "tips", "image_url", "data_source", "verified"):
        if field in body:
            setattr(obj, field, body[field])
    await db.commit()
    return {"id": str(obj.id)}


@router.delete("/locations/{loc_id}", status_code=204)
async def delete_location(loc_id: str, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, Location, loc_id)
    await db.delete(obj)
    await db.commit()


# ── Tours ─────────────────────────────────────────────────────────────────

@router.get("/tours")
async def list_tours(
    destination_id: Optional[str] = None,
    page: int = Query(1, ge=1),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(Tour)
    if destination_id:
        stmt = stmt.where(Tour.destination_id == destination_id)
    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows  = await db.execute(stmt.order_by(Tour.created_at.desc()).offset((page - 1) * 20).limit(20))
    items = rows.scalars().all()
    return {
        "total": total or 0, "page": page,
        "items": [{"id": str(i.id), "name": i.name, "duration": i.duration,
                   "price": i.price, "verified": i.verified} for i in items],
    }


@router.post("/tours", status_code=201)
async def create_tour(body: dict, db: DB = None, _: User = Depends(require_admin)):
    import uuid as _uuid
    obj = Tour(
        id=_uuid.uuid4(),
        destination_id=body["destination_id"],
        name=body["name"],
        duration=body.get("duration"),
        price=body.get("price"),
        group_size=body.get("group_size"),
        description=body.get("description"),
        includes=body.get("includes", []),
        excludes=body.get("excludes", []),
        data_source=body.get("data_source"),
    )
    db.add(obj)
    await db.commit()
    await db.refresh(obj)
    return {"id": str(obj.id)}


@router.patch("/tours/{tour_id}")
async def update_tour(tour_id: str, body: dict, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, Tour, tour_id)
    for field in ("name", "duration", "price", "group_size", "description", "includes", "excludes", "data_source", "verified"):
        if field in body:
            setattr(obj, field, body[field])
    await db.commit()
    return {"id": str(obj.id)}


@router.delete("/tours/{tour_id}", status_code=204)
async def delete_tour(tour_id: str, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, Tour, tour_id)
    await db.delete(obj)
    await db.commit()


# ── Itineraries ────────────────────────────────────────────────────────────

@router.get("/itineraries")
async def list_itineraries(
    city_slug: Optional[str] = None,
    page: int = Query(1, ge=1),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(Itinerary)
    if city_slug:
        stmt = stmt.where(Itinerary.city_slug == city_slug)
    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows  = await db.execute(stmt.order_by(Itinerary.created_at.desc()).offset((page - 1) * 20).limit(20))
    items = rows.scalars().all()
    return {
        "total": total or 0, "page": page,
        "items": [{"id": str(i.id), "title": i.title, "city_slug": i.city_slug,
                   "duration_days": i.duration_days, "is_active": i.is_active} for i in items],
    }


@router.get("/itineraries/{itin_id}")
async def get_itinerary(itin_id: str, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, Itinerary, itin_id)
    result = await db.execute(
        select(ItineraryItem).where(ItineraryItem.itinerary_id == itin_id).order_by(
            ItineraryItem.day_no, ItineraryItem.order_no
        )
    )
    sub_items = result.scalars().all()
    return {
        "id": str(obj.id), "title": obj.title, "city_slug": obj.city_slug,
        "duration_days": obj.duration_days, "group_type": obj.group_type,
        "is_active": obj.is_active, "data_source": obj.data_source,
        "days": [{"day_no": i.day_no, "order_no": i.order_no, "time_slot": i.time_slot,
                  "title": i.title, "ref_type": i.ref_type} for i in sub_items],
    }


@router.patch("/itineraries/{itin_id}")
async def update_itinerary(itin_id: str, body: dict, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, Itinerary, itin_id)
    for field in ("title", "duration_days", "group_type", "budget_low", "budget_high", "is_active", "data_source", "verified"):
        if field in body:
            setattr(obj, field, body[field])
    await db.commit()
    return {"id": str(obj.id)}


@router.delete("/itineraries/{itin_id}", status_code=204)
async def delete_itinerary(itin_id: str, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, Itinerary, itin_id)
    await db.delete(obj)
    await db.commit()


# ── Intent patterns (DB) ─────────────────────────────────────────────────

@router.get("/intent-patterns-db")
async def list_intent_patterns_db(
    intent: Optional[str] = None,
    page: int = Query(1, ge=1),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(IntentPattern).where(IntentPattern.is_active == True)  # noqa: E712
    if intent:
        stmt = stmt.where(IntentPattern.intent == intent)
    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows  = await db.execute(stmt.order_by(IntentPattern.intent, IntentPattern.keyword).offset((page - 1) * 50).limit(50))
    items = rows.scalars().all()
    return {
        "total": total or 0, "page": page,
        "items": [{"id": str(i.id), "intent": i.intent, "keyword": i.keyword,
                   "weight": i.weight, "is_active": i.is_active} for i in items],
    }


@router.post("/intent-patterns-db", status_code=201)
async def create_intent_pattern_db(body: dict, db: DB = None, _: User = Depends(require_admin)):
    import uuid as _uuid
    obj = IntentPattern(id=_uuid.uuid4(), intent=body["intent"], keyword=body["keyword"].strip().lower(), weight=body.get("weight", 1))
    db.add(obj)
    await db.commit()
    return {"id": str(obj.id)}


@router.patch("/intent-patterns-db/{pat_id}")
async def update_intent_pattern_db(pat_id: str, body: dict, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, IntentPattern, pat_id)
    for field in ("keyword", "weight", "is_active"):
        if field in body:
            setattr(obj, field, body[field])
    await db.commit()
    return {"id": str(obj.id)}


@router.delete("/intent-patterns-db/{pat_id}", status_code=204)
async def delete_intent_pattern_db(pat_id: str, db: DB = None, _: User = Depends(require_admin)):
    obj = await _get_or_404(db, IntentPattern, pat_id)
    await db.delete(obj)
    await db.commit()


# ── Locations alias ───────────────────────────────────────────────────────

@router.get("/locations-alias")
async def list_locations_alias(
    level: Optional[str] = None,
    page: int = Query(1, ge=1),
    db: DB = None,
    _: User = Depends(require_admin),
):
    stmt = select(LocationAlias).where(LocationAlias.is_active == True)  # noqa: E712
    if level:
        stmt = stmt.where(LocationAlias.level == level)
    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows  = await db.execute(stmt.order_by(LocationAlias.new_slug).offset((page - 1) * 50).limit(50))
    items = rows.scalars().all()
    return {
        "total": total or 0, "page": page,
        "items": [{"id": str(i.id), "old_name": i.old_name,
                   "new_slug": i.new_slug, "level": i.level} for i in items],
    }