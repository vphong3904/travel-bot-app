from datetime import datetime, timedelta
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import ChatLog, KnowledgeEntry, PopularQuery, User
from app.schemas import (
    ChatLogResponse,
    KBEntryCreate,
    KBEntryResponse,
    KBEntryUpdate,
    StatsResponse,
    UserResponse,
)
from app.services.rag_service import get_rag_service

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/stats", response_model=StatsResponse)
def get_stats(db: Session = Depends(get_db)):
    total_users = db.query(User).count()
    total_chats = db.query(ChatLog).count()
    total_kb = db.query(KnowledgeEntry).count()

    popular_questions = [
        {"query": q.query_text, "count": q.count, "intent": q.intent}
        for q in db.query(PopularQuery).order_by(PopularQuery.count.desc()).limit(10).all()
    ]

    popular_destinations = [
        {"destination": d.destination or "Không xác định", "count": d.count}
        for d in db.query(ChatLog.destination, func.count(ChatLog.id).label("count"))
        .filter(ChatLog.destination != "")
        .group_by(ChatLog.destination)
        .order_by(func.count(ChatLog.id).desc())
        .limit(10)
        .all()
    ]

    intent_distribution = [
        {"intent": i.intent or "unknown", "count": i.count}
        for i in db.query(ChatLog.intent, func.count(ChatLog.id).label("count"))
        .group_by(ChatLog.intent)
        .all()
    ]

    daily = []
    for day_offset in range(6, -1, -1):
        day = datetime.utcnow().date() - timedelta(days=day_offset)
        count = db.query(ChatLog).filter(func.date(ChatLog.created_at) == day).count()
        daily.append({"date": day.isoformat(), "count": count})

    return StatsResponse(
        total_users=total_users,
        total_chats=total_chats,
        total_kb_entries=total_kb,
        popular_questions=popular_questions,
        popular_destinations=popular_destinations,
        intent_distribution=intent_distribution,
        daily_chats=daily,
    )


@router.get("/users", response_model=list[UserResponse])
def list_users(db: Session = Depends(get_db)):
    return db.query(User).order_by(User.created_at.desc()).all()


@router.patch("/users/{user_id}/toggle")
def toggle_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy user")
    user.is_active = not user.is_active
    db.commit()
    return {"id": user.id, "is_active": user.is_active}


@router.get("/chat-logs", response_model=list[ChatLogResponse])
def list_chat_logs(
    limit: int = 50,
    intent: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(ChatLog).order_by(ChatLog.created_at.desc())
    if intent:
        query = query.filter(ChatLog.intent == intent)
    return query.limit(limit).all()


@router.get("/kb", response_model=list[KBEntryResponse])
def list_kb(category: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(KnowledgeEntry).order_by(KnowledgeEntry.updated_at.desc())
    if category:
        query = query.filter(KnowledgeEntry.category == category)
    return query.all()


@router.post("/kb", response_model=KBEntryResponse)
def create_kb(data: KBEntryCreate, db: Session = Depends(get_db)):
    entry = KnowledgeEntry(**data.model_dump())
    db.add(entry)
    db.commit()
    db.refresh(entry)
    _rebuild_rag(db)
    return entry


@router.put("/kb/{entry_id}", response_model=KBEntryResponse)
def update_kb(entry_id: int, data: KBEntryUpdate, db: Session = Depends(get_db)):
    entry = db.query(KnowledgeEntry).filter(KnowledgeEntry.id == entry_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Không tìm thấy entry")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(entry, key, value)
    entry.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(entry)
    _rebuild_rag(db)
    return entry


@router.delete("/kb/{entry_id}")
def delete_kb(entry_id: int, db: Session = Depends(get_db)):
    entry = db.query(KnowledgeEntry).filter(KnowledgeEntry.id == entry_id).first()
    if not entry:
        raise HTTPException(status_code=404, detail="Không tìm thấy entry")
    db.delete(entry)
    db.commit()
    _rebuild_rag(db)
    return {"ok": True}


def _rebuild_rag(db: Session):
    kb_entries = db.query(KnowledgeEntry).all()
    docs = [
        {
            "id": e.id,
            "title": e.title,
            "content": e.content,
            "category": e.category,
            "destination": e.destination,
            "tags": e.tags,
        }
        for e in kb_entries
    ]
    get_rag_service().initialize(docs)
