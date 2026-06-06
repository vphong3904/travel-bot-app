from datetime import datetime, timedelta
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models import ChatLog, KnowledgeEntry, PopularQuery, User
from app.schemas import (
    ChatLogResponse, KBEntryCreate, KBEntryResponse,
    KBEntryUpdate, StatsResponse, UserResponse,
)
from app.services.rag_service import get_rag_service

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/stats", response_model=StatsResponse)
async def get_stats(db: AsyncSession = Depends(get_db)):
    total_users = (await db.execute(select(func.count(User.id)))).scalar()
    total_chats = (await db.execute(select(func.count(ChatLog.id)))).scalar()
    total_kb = (await db.execute(select(func.count(KnowledgeEntry.id)))).scalar()

    popular_questions_result = await db.execute(
        select(PopularQuery).order_by(PopularQuery.count.desc()).limit(10)
    )
    popular_questions = [
        {"query": q.query_text, "count": q.count, "intent": q.intent}
        for q in popular_questions_result.scalars().all()
    ]

    popular_dest_result = await db.execute(
        select(ChatLog.destination, func.count(ChatLog.id).label("count"))
        .filter(ChatLog.destination != "")
        .group_by(ChatLog.destination)
        .order_by(func.count(ChatLog.id).desc())
        .limit(10)
    )
    popular_destinations = [
        {"destination": d.destination or "Không xác định", "count": d.count}
        for d in popular_dest_result.all()
    ]

    intent_result = await db.execute(
        select(ChatLog.intent, func.count(ChatLog.id).label("count"))
        .group_by(ChatLog.intent)
    )
    intent_distribution = [
        {"intent": i.intent or "unknown", "count": i.count}
        for i in intent_result.all()
    ]

    daily = []
    for day_offset in range(6, -1, -1):
        day = datetime.utcnow().date() - timedelta(days=day_offset)
        count = (await db.execute(
            select(func.count(ChatLog.id)).filter(func.date(ChatLog.created_at) == day)
        )).scalar()
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
async def list_users(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).order_by(User.created_at.desc()))
    return result.scalars().all()


@router.patch("/users/{user_id}/toggle")
async def toggle_user(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy user")
    user.is_active = not user.is_active
    await db.commit()
    return {"id": user.id, "is_active": user.is_active}


@router.get("/chat-logs", response_model=list[ChatLogResponse])
async def list_chat_logs(
    limit: int = 50,
    intent: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
):
    q = select(ChatLog).order_by(ChatLog.created_at.desc()).limit(limit)
    if intent:
        q = q.where(ChatLog.intent == intent)
    result = await db.execute(q)
    return result.scalars().all()


@router.get("/kb", response_model=list[KBEntryResponse])
async def list_kb(category: Optional[str] = None, db: AsyncSession = Depends(get_db)):
    q = select(KnowledgeEntry).order_by(KnowledgeEntry.updated_at.desc())
    if category:
        q = q.where(KnowledgeEntry.category == category)
    result = await db.execute(q)
    return result.scalars().all()


@router.post("/kb", response_model=KBEntryResponse)
async def create_kb(data: KBEntryCreate, db: AsyncSession = Depends(get_db)):
    entry = KnowledgeEntry(**data.model_dump())
    db.add(entry)
    await db.commit()
    await db.refresh(entry)
    await _rebuild_rag(db)
    return entry


@router.put("/kb/{entry_id}", response_model=KBEntryResponse)
async def update_kb(entry_id: int, data: KBEntryUpdate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(KnowledgeEntry).where(KnowledgeEntry.id == entry_id))
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=404, detail="Không tìm thấy entry")
    for key, value in data.model_dump(exclude_unset=True).items():
        setattr(entry, key, value)
    entry.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(entry)
    await _rebuild_rag(db)
    return entry


@router.delete("/kb/{entry_id}")
async def delete_kb(entry_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(KnowledgeEntry).where(KnowledgeEntry.id == entry_id))
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=404, detail="Không tìm thấy entry")
    await db.delete(entry)
    await db.commit()
    await _rebuild_rag(db)
    return {"ok": True}


async def _rebuild_rag(db: AsyncSession):
    result = await db.execute(select(KnowledgeEntry))
    kb_entries = result.scalars().all()
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