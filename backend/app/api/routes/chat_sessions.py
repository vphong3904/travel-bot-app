"""
Routes: /chat/sessions
CRUD cho chat sessions + pin/unpin + soft delete
"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, update, delete, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.db.models.user import User
from app.db.models.chat import ChatSession, ChatMessage
from app.db.schemas.chat import (
    ChatSessionCreate,
    ChatSessionUpdate,
    ChatSessionOut,
    ChatSessionListOut,
)

router = APIRouter(tags=["chat-sessions"])


# ── List sessions ─────────────────────────────────────────────────────────────
@router.get("/", response_model=list[ChatSessionListOut])
async def list_sessions(
    pinned_only: bool = False,
    skip: int = 0,
    limit: int = 30,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Lấy danh sách session (pinned trước, sau đó mới nhất)."""
    stmt = (
        select(ChatSession)
        .where(
            ChatSession.user_id == current_user.id,
            ChatSession.is_deleted.is_(False),
        )
    )
    if pinned_only:
        stmt = stmt.where(ChatSession.pinned.is_(True))

    stmt = stmt.order_by(
        ChatSession.pinned.desc(),
        ChatSession.updated_at.desc(),
    ).offset(skip).limit(limit)

    result = await db.execute(stmt)
    sessions = result.scalars().all()
    return sessions


# ── Create session ────────────────────────────────────────────────────────────
@router.post("/", response_model=ChatSessionOut, status_code=status.HTTP_201_CREATED)
async def create_session(
    payload: ChatSessionCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = ChatSession(
        user_id=current_user.id,
        title=payload.title,
        model_name=payload.model_name or "gemini-1.5-flash",
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return session


# ── Get session detail ────────────────────────────────────────────────────────
@router.get("/{session_id}", response_model=ChatSessionOut)
async def get_session(
    session_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = await _get_session_or_404(db, session_id, current_user.id)
    return session


# ── Update session (title / pin) ──────────────────────────────────────────────
@router.patch("/{session_id}", response_model=ChatSessionOut)
async def update_session(
    session_id: UUID,
    payload: ChatSessionUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = await _get_session_or_404(db, session_id, current_user.id)

    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(session, field, value)

    await db.commit()
    await db.refresh(session)
    return session


# ── Soft delete session ───────────────────────────────────────────────────────
@router.delete("/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(
    session_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = await _get_session_or_404(db, session_id, current_user.id)
    session.is_deleted = True
    await db.commit()


# ── Helper ────────────────────────────────────────────────────────────────────
async def _get_session_or_404(
    db: AsyncSession, session_id: UUID, user_id: UUID
) -> ChatSession:
    result = await db.execute(
        select(ChatSession).where(
            ChatSession.id == session_id,
            ChatSession.user_id == user_id,
            ChatSession.is_deleted.is_(False),
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session