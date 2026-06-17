"""
Routes: /chat/sessions/:id/messages  &  /chat/messages/:id/feedback
Gửi tin nhắn → RAG → AI trả lời (normal + SSE stream)
"""
import json
import asyncio
from uuid import UUID
from typing import AsyncGenerator

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import StreamingResponse
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.db.models.user import User
from app.db.models.chat import ChatSession, ChatMessage
from app.db.schemas.chat import (
    ChatMessageOut,
    ChatMessageCreate,
    FeedbackUpdate,
)
from app.core.sse import format_sse

router = APIRouter(tags=["chat-messages"])

# Singleton RAG pipeline — lazy init để tránh load model khi import
_rag = None


def get_rag():
    global _rag
    if _rag is None:
        from app.services.rag_pipeline import RAGPipeline
        _rag = RAGPipeline()
    return _rag


# ── List messages ─────────────────────────────────────────────────────────────
@router.get(
    "/chat/sessions/{session_id}/messages",
    response_model=list[ChatMessageOut],
)
async def list_messages(
    session_id: UUID,
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Lịch sử hội thoại trong session (cũ → mới)."""
    await _assert_session_owner(db, session_id, current_user.id)

    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.asc())
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()


# ── Send message (non-stream) ──────────────────────────────────────────────────
@router.post(
    "/chat/sessions/{session_id}/messages",
    response_model=ChatMessageOut,
    status_code=status.HTTP_201_CREATED,
)
async def send_message(
    session_id: UUID,
    payload: ChatMessageCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
    rag = Depends(get_rag),
):
    """Gửi tin nhắn user → RAG pipeline → trả về message AI."""
    await _assert_session_owner(db, session_id, current_user.id)

    # 1. Lưu user message
    user_msg = ChatMessage(
        session_id=session_id,
        role="user",
        content=payload.content,
    )
    db.add(user_msg)
    await db.flush()

    # 2. Lấy lịch sử hội thoại gần đây (context window)
    history = await _get_recent_history(db, session_id, limit=10)

    # 3. Gọi RAG pipeline
    rag_result = await rag.query(
        question=payload.content,
        history=history,
        session_id=str(session_id),
    )

    # 4. Lưu assistant message
    assistant_msg = ChatMessage(
        session_id=session_id,
        role="assistant",
        content=rag_result["answer"],
        sources=rag_result.get("sources", []),
        intent=rag_result.get("intent"),
        prompt_tokens=rag_result.get("prompt_tokens", 0),
        completion_tokens=rag_result.get("completion_tokens", 0),
        latency_ms=rag_result.get("latency_ms"),
    )
    db.add(assistant_msg)
    await db.commit()
    await db.refresh(assistant_msg)
    return assistant_msg


# ── Send message (SSE stream) ──────────────────────────────────────────────────
@router.post("/chat/sessions/{session_id}/messages/stream")
async def stream_message(
    session_id: UUID,
    payload: ChatMessageCreate,
    request: Request,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
    rag = Depends(get_rag),
):
    """
    SSE streaming: mỗi chunk text AI trả về 1 event.
    Format: data: {"type":"chunk","content":"..."}
    Kết thúc:  data: {"type":"done","message_id":"...","sources":[...]}
    """
    await _assert_session_owner(db, session_id, current_user.id)

    # Lưu user message
    user_msg = ChatMessage(
        session_id=session_id,
        role="user",
        content=payload.content,
    )
    db.add(user_msg)
    await db.commit()

    history = await _get_recent_history(db, session_id, limit=10)

    async def event_generator() -> AsyncGenerator[str, None]:
        full_content = []
        rag_meta: dict = {}

        try:
            async for chunk in rag.stream_query(
                question=payload.content,
                history=history,
                session_id=str(session_id),
            ):
                if chunk.get("type") == "chunk":
                    full_content.append(chunk["content"])
                    yield format_sse({"type": "chunk", "content": chunk["content"]})
                elif chunk.get("type") == "meta":
                    rag_meta = chunk

                # Kiểm tra client đã disconnect chưa
                if await request.is_disconnected():
                    break

        except Exception as exc:
            yield format_sse({"type": "error", "detail": str(exc)})
            return

        # Lưu assistant message sau khi stream xong
        answer = "".join(full_content)
        assistant_msg = ChatMessage(
            session_id=session_id,
            role="assistant",
            content=answer,
            sources=rag_meta.get("sources", []),
            intent=rag_meta.get("intent"),
            prompt_tokens=rag_meta.get("prompt_tokens", 0),
            completion_tokens=rag_meta.get("completion_tokens", 0),
            latency_ms=rag_meta.get("latency_ms"),
        )
        db.add(assistant_msg)
        await db.commit()
        await db.refresh(assistant_msg)

        yield format_sse({
            "type": "done",
            "message_id": str(assistant_msg.id),
            "sources": rag_meta.get("sources", []),
        })

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )


# ── Feedback (thumbs up/down) ─────────────────────────────────────────────────
@router.patch("/chat/messages/{message_id}/feedback", response_model=ChatMessageOut)
async def update_feedback(
    message_id: UUID,
    payload: FeedbackUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Cập nhật feedback 👍 (+1) / 👎 (-1) cho message của AI."""
    result = await db.execute(
        select(ChatMessage)
        .join(ChatSession, ChatSession.id == ChatMessage.session_id)
        .where(
            ChatMessage.id == message_id,
            ChatMessage.role == "assistant",
            ChatSession.user_id == current_user.id,
        )
    )
    msg = result.scalar_one_or_none()
    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")

    msg.feedback = payload.feedback
    await db.commit()
    await db.refresh(msg)
    return msg


# ── Helpers ───────────────────────────────────────────────────────────────────
async def _assert_session_owner(
    db: AsyncSession, session_id: UUID, user_id: UUID
) -> None:
    result = await db.execute(
        select(ChatSession.id).where(
            ChatSession.id == session_id,
            ChatSession.user_id == user_id,
            ChatSession.is_deleted.is_(False),
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Session not found")


async def _get_recent_history(
    db: AsyncSession, session_id: UUID, limit: int = 10
) -> list[dict]:
    """Lấy N tin nhắn gần nhất để làm context cho LLM."""
    result = await db.execute(
        select(ChatMessage.role, ChatMessage.content)
        .where(ChatMessage.session_id == session_id)
        .order_by(ChatMessage.created_at.desc())
        .limit(limit)
    )
    rows = result.all()
    # Đảo ngược lại để cũ → mới
    return [{"role": r.role, "content": r.content} for r in reversed(rows)]