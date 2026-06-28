# app/api/routes/admin.py
"""
Admin routes — /api/admin/*

Tất cả endpoints yêu cầu role admin.
Role matrix đơn giản hoá: role IN ('admin', 'super_admin', 'content_manager', 'moderator').
"""

from __future__ import annotations

import json
from datetime import datetime, timezone, timedelta
from typing import Any, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, Request, UploadFile, File, status
from sqlalchemy import func, select, update, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import DB, CurrentUser, ADMIN_ROLES, require_admin, require_role
from app.db.database import AsyncSessionLocal
from app.db.models.admin import EmbeddingJob, KnowledgeEntry
from app.db.models.chat import ChatMessage, ChatSession
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
    """Dashboard tổng quan: users, sessions, messages, feedback."""
    now = datetime.now(timezone.utc)
    delta = {"day": 1, "week": 7, "month": 30, "year": 365}[period]
    since = now - timedelta(days=delta)

    total_users = await db.scalar(select(func.count(User.id)).where(User.is_deleted == False))
    new_users = await db.scalar(
        select(func.count(User.id)).where(User.created_at >= since, User.is_deleted == False)
    )
    total_sessions = await db.scalar(select(func.count(ChatSession.id)))
    total_messages = await db.scalar(select(func.count(ChatMessage.id)))
    positive_fb = await db.scalar(
        select(func.count(ChatMessage.id)).where(ChatMessage.feedback == 1)
    )
    negative_fb = await db.scalar(
        select(func.count(ChatMessage.id)).where(ChatMessage.feedback == -1)
    )

    return {
        "total_users": total_users or 0,
        "new_users": new_users or 0,
        "total_sessions": total_sessions or 0,
        "total_messages": total_messages or 0,
        "positive_feedback": positive_fb or 0,
        "negative_feedback": negative_fb or 0,
        "period": period,
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
                func.case((ChatMessage.feedback == 1, 1), else_=0)
            ).label("positive"),
            func.sum(
                func.case((ChatMessage.feedback == -1, 1), else_=0)
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
                "category": e.category,
                "tags": e.tags or [],
                "is_active": e.is_active,
                "qdrant_id": e.qdrant_id,
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

    avg_latency = await db.scalar(
        select(func.avg(ChatMessage.latency_ms)).where(
            ChatMessage.created_at >= since, ChatMessage.latency_ms.isnot(None)
        )
    )
    avg_confidence = await db.scalar(
        select(func.avg(ChatMessage.confidence_score)).where(
            ChatMessage.created_at >= since, ChatMessage.confidence_score.isnot(None)
        )
    )
    total_queries = await db.scalar(
        select(func.count(ChatMessage.id)).where(
            ChatMessage.role == "assistant", ChatMessage.created_at >= since
        )
    )

    return {
        "period": period,
        "avg_latency_ms": round(float(avg_latency or 0), 1),
        "avg_confidence": round(float(avg_confidence or 0), 3),
        "total_queries": total_queries or 0,
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
    return [
        {
            "date": str(r.date)[:10],
            "avg_ms": round(float(r.avg_ms or 0), 1),
            "p95_ms": round(float(r.p95_ms or 0), 1),
        }
        for r in rows
    ]


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
    return [
        {
            "id": m.id,
            "content": m.content[:200],
            "confidence_score": m.confidence_score,
            "intent": m.intent,
            "created_at": str(m.created_at),
        }
        for m in messages
    ]


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
    _: User = Depends(require_admin),
):
    import os
    kb_path = "knowledge-base"
    if not os.path.isdir(kb_path):
        return []
    return sorted(
        d for d in os.listdir(kb_path)
        if os.path.isdir(os.path.join(kb_path, d))
    )


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
    result = []
    all_kws: list[str] = []
    for intent, kws in INTENT_PATTERNS.items():
        all_kws.extend(kws)

    for intent, kws in INTENT_PATTERNS.items():
        keyword_list = [
            {
                "keyword": kw,
                "is_collision": sum(1 for _, v in INTENT_PATTERNS.items() if kw in v) > 1,
            }
            for kw in kws
        ]
        result.append({"intent": intent, "keywords": keyword_list})
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

# Map content_type → table name (đơn giản hoá, dùng knowledge_entries làm demo)
CONTENT_TYPES = {
    "destinations", "hotels", "tours", "foods", "restaurants",
    "shopping", "itineraries", "events", "transport", "faq", "experiences",
}


@router.get("/content/{content_type}")
async def list_content(
    content_type: str,
    city_slug: Optional[str] = None,
    status: Optional[str] = None,
    page: int = Query(1, ge=1),
    db: DB = None,
    _: User = Depends(require_admin),
):
    if content_type not in CONTENT_TYPES:
        raise HTTPException(400, f"Content type '{content_type}' không hợp lệ")

    # Trả dữ liệu từ knowledge_entries với category = content_type
    stmt = select(KnowledgeEntry).where(KnowledgeEntry.category == content_type)
    if city_slug:
        stmt = stmt.where(KnowledgeEntry.tags.any(city_slug))

    total = await db.scalar(select(func.count()).select_from(stmt.subquery()))
    rows = await db.execute(
        stmt.order_by(KnowledgeEntry.created_at.desc()).offset((page - 1) * 20).limit(20)
    )
    entries = rows.scalars().all()

    return {
        "total": total or 0,
        "page": page,
        "items": [
            {
                "id": e.id,
                "status": "published" if e.is_active else "draft",
                "created_at": str(e.created_at),
                "updated_at": str(e.updated_at),
                "is_deleted": False,
                "data": {
                    "name": e.title,
                    "city_slug": city_slug or "",
                    "content": e.content[:100],
                },
            }
            for e in entries
        ],
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
    svc = KnowledgeService(db)
    entry = await svc.create(
        title=body.get("name", "Untitled"),
        category=content_type,
        content=str(body),
        tags=[city_slug] if city_slug else [],
    )
    return {"id": entry.id, "status": "pending"}


@router.patch("/content/{content_type}/{item_id}")
async def update_content(
    content_type: str,
    item_id: str,
    body: dict,
    db: DB = None,
    _: User = Depends(require_admin),
):
    svc = KnowledgeService(db)
    entry = await svc.update(entry_id=item_id, title=body.get("name"))
    return {"id": entry.id}


@router.delete("/content/{content_type}/{item_id}")
async def delete_content(
    content_type: str,
    item_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    svc = KnowledgeService(db)
    await svc.delete(item_id)
    return {"ok": True}


@router.patch("/content/{content_type}/{item_id}/publish")
async def publish_content(
    content_type: str,
    item_id: str,
    db: DB = None,
    _: User = Depends(require_admin),
):
    await db.execute(
        update(KnowledgeEntry).where(KnowledgeEntry.id == item_id).values(is_active=True)
    )
    await db.commit()
    return {"ok": True}


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
# MEDIA (placeholder — file storage cần S3/local disk setup)
# ══════════════════════════════════════════════════════════════════════════════

_media_store: list[dict] = []  # in-memory, thay bằng DB/S3 thật


@router.get("/media")
async def list_media(
    tag: Optional[str] = None,
    page: int = Query(1, ge=1),
    _: User = Depends(require_admin),
):
    items = _media_store
    if tag:
        items = [m for m in items if tag in m.get("tags", [])]
    start = (page - 1) * 20
    return {
        "total": len(items),
        "page": page,
        "items": items[start: start + 20],
    }


@router.post("/media/upload", status_code=201)
async def upload_media(
    file: UploadFile = File(...),
    _: User = Depends(require_admin),
):
    import os, uuid as _uuid
    upload_dir = "uploads"
    os.makedirs(upload_dir, exist_ok=True)
    ext = os.path.splitext(file.filename or "file")[1]
    filename = f"{_uuid.uuid4()}{ext}"
    path = os.path.join(upload_dir, filename)
    content = await file.read()
    with open(path, "wb") as f:
        f.write(content)

    record = {
        "id": str(_uuid.uuid4()),
        "filename": filename,
        "original_name": file.filename,
        "mime_type": file.content_type,
        "size": len(content),
        "tags": [],
        "created_at": datetime.now(timezone.utc).isoformat(),
    }
    _media_store.append(record)
    return record


@router.delete("/media/{media_id}")
async def delete_media(
    media_id: str,
    _: User = Depends(require_admin),
):
    global _media_store
    _media_store = [m for m in _media_store if m["id"] != media_id]
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
    return [
        {
            "id": m.id,
            "content": m.content[:300],
            "confidence_score": m.confidence_score,
            "intent": m.intent,
            "created_at": str(m.created_at),
        }
        for m in messages
    ]


@router.post("/unanswered-questions/{question_id}/promote-to-kb")
async def promote_to_kb(
    question_id: str,
    body: dict,
    db: DB = None,
    _: User = Depends(require_admin),
):
    svc = KnowledgeService(db)
    entry = await svc.create(
        title=body.get("title", "Promoted Question"),
        category=body.get("category", "faq"),
        content=body.get("content", ""),
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
