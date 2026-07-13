"""
Routes: /chat/sessions/:id/messages  &  /chat/messages/:id/feedback
"""
import json
import re
import time
import asyncio
from uuid import UUID
from typing import AsyncGenerator

from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import StreamingResponse
from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db, get_current_user
from app.db.database import AsyncSessionLocal
from app.db.models.user import User
from app.db.models.chat import ChatSession, ChatMessage
from app.db.schemas.chat import ChatMessageOut, ChatMessageCreate, FeedbackUpdate
from app.core.sse import format_sse
from app.services import log_service, trip_chat_planner
from app.core.config import settings
from app.utils import get_logger
from app.utils.uuid_v7 import uuid_v7
from app.services.nlp_preprocessor import (
    preprocess,
    get_greeting_response,
    OUT_OF_SCOPE_RESPONSE,
)

router = APIRouter(tags=["chat-messages"])
logger = get_logger("chat_messages")

_rag = None


def get_rag():
    global _rag
    if _rag is None:
        from app.services.rag_pipeline import RAGPipeline
        _rag = RAGPipeline()
    return _rag


@router.get("/chat/sessions/{session_id}/messages", response_model=list[ChatMessageOut])
async def list_messages(
    session_id: UUID,
    skip: int = 0,
    limit: int = 50,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await _assert_session_owner(db, session_id, current_user.id)
    result = await db.execute(
        select(ChatMessage)
        .where(ChatMessage.session_id == str(session_id))
        .order_by(ChatMessage.created_at.asc())
        .offset(skip)
        .limit(limit)
    )
    return result.scalars().all()


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
):
    await _assert_session_owner(db, session_id, current_user.id)
    rag = get_rag()

    user_msg = ChatMessage(
        id=str(uuid_v7()),
        session_id=str(session_id),
        role="user",
        content=payload.content,
    )
    db.add(user_msg)
    await db.flush()

    # Đặt tên hội thoại theo câu hỏi đầu tiên (chỉ khi chưa có tiêu đề)
    await _maybe_set_session_title(db, session_id, payload.content)

    # ✅ Dùng CHAT_HISTORY_LIMIT từ config (mặc định 10)
    history = await _get_recent_history(db, session_id, limit=settings.CHAT_HISTORY_LIMIT)

    # ── Req 2: luồng lên lịch trình từng bước ngay trong chat ─────────────────
    planner = await trip_chat_planner.handle_planning_turn(
        db, str(current_user.id), history[:-1], payload.content
    )
    if planner is not None:
        assistant_msg = ChatMessage(
            id=str(uuid_v7()),
            session_id=str(session_id),
            role="assistant",
            content=planner["reply"],
            intent="plan_trip",
        )
        db.add(assistant_msg)
        if planner.get("itinerary"):
            await _save_last_itinerary(db, session_id, planner["itinerary"])
        await db.commit()
        await db.refresh(assistant_msg)
        await log_service.log_behavior(
            user_id=str(current_user.id),
            event_type="ask_chatbot",
            entity_type="chat_session",
            entity_id=str(session_id),
        )
        return assistant_msg

    nlp = preprocess(payload.content, history=history)

    t0 = time.monotonic()
    rag_result = await rag.query(
        question=nlp.rewritten_query,
        history=history,
        session_id=str(session_id),
    )
    total_ms = int((time.monotonic() - t0) * 1000)
    tok_per_sec = round(
        rag_result.get("completion_tokens", 0) / max(total_ms / 1000, 0.001), 1
    )
    logger.info(
        f"[CHAT] user={current_user.id} session={session_id} | "
        f"total={total_ms}ms | speed={tok_per_sec} tok/s | "
        f"sources={len(rag_result.get('sources', []))}"
    )
    
    assistant_msg = ChatMessage(
        id=str(uuid_v7()),
        session_id=str(session_id),
        role="assistant",
        content=rag_result["answer"],
        sources=rag_result.get("sources", []),
        intent=rag_result.get("intent"),
        prompt_tokens=rag_result.get("prompt_tokens", 0),
        completion_tokens=rag_result.get("completion_tokens", 0),
        latency_ms=rag_result.get("latency_ms"),
        confidence_score=rag_result.get("confidence_score"),
        search_method=rag_result.get("search_method"),
        search_ms=rag_result.get("search_ms"),
        llm_ms=rag_result.get("llm_ms"),
        cache_hit=rag_result.get("cache_hit"),
        chunk_count=rag_result.get("chunk_count"),
    )
    db.add(assistant_msg)
    await db.commit()
    await db.refresh(assistant_msg)
    # Ghi behavior log vào MongoDB
    await log_service.log_behavior(
        user_id=str(current_user.id),
        event_type="ask_chatbot",
        entity_type="chat_session",
        entity_id=str(session_id),
    )
    return assistant_msg


@router.post("/chat/sessions/{session_id}/messages/stream")
async def stream_message(
    session_id: UUID,
    payload: ChatMessageCreate,
    request: Request,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    await _assert_session_owner(db, session_id, current_user.id)

    user_msg = ChatMessage(
        id=str(uuid_v7()),
        session_id=str(session_id),
        role="user",
        content=payload.content,
    )
    db.add(user_msg)
    # Đặt tên hội thoại theo câu hỏi đầu tiên (chỉ khi chưa có tiêu đề)
    await _maybe_set_session_title(db, session_id, payload.content)
    await db.commit()

    # ✅ Dùng CHAT_HISTORY_LIMIT từ config
    history = await _get_recent_history(
        db,
        session_id,
        limit=settings.CHAT_HISTORY_LIMIT
    )
    session_id_str = str(session_id)
    question = payload.content
    user_id_str = str(current_user.id)
    rag = get_rag()

    # ── Req 2: phát hiện luồng lên lịch trình trước khi gọi RAG ───────────────
    planner = await trip_chat_planner.handle_planning_turn(
        db, user_id_str, history[:-1], question
    )

    async def event_generator() -> AsyncGenerator[str, None]:
        full_content: list[str] = []
        rag_meta: dict = {}
        t0 = time.monotonic()

        # ✅ Gửi event "start" ngay lập tức để frontend biết stream đã sẵn sàng
        yield format_sse({"type": "start"})

        # Luồng lên lịch: stream text trợ lý + đính kèm itinerary, KHÔNG gọi RAG.
        if planner is not None:
            reply = planner["reply"]
            for piece in _chunk_text(reply):
                if await request.is_disconnected():
                    return
                yield format_sse({"type": "chunk", "content": piece})
            async with AsyncSessionLocal() as db_new:
                assistant_msg = ChatMessage(
                    id=str(uuid_v7()),
                    session_id=session_id_str,
                    role="assistant",
                    content=reply,
                    intent="plan_trip",
                )
                db_new.add(assistant_msg)
                if planner.get("itinerary"):
                    await _save_last_itinerary(db_new, session_id, planner["itinerary"])
                await db_new.commit()
                await db_new.refresh(assistant_msg)
            yield format_sse({
                "type": "done",
                "message_id": assistant_msg.id,
                "intent": "plan_trip",
                "sources": [],
                "suggested_questions": [],
                "itinerary": planner.get("itinerary"),
            })
            return

        try:
            async for chunk in rag.stream_query(
                question=question,
                history=history,
                session_id=session_id_str,
            ):
                if await request.is_disconnected():
                    logger.warning(
                        f"[SSE] Client disconnected: session={session_id_str}"
                    )
                    return

                if chunk.get("type") == "chunk":
                    full_content.append(chunk["content"])
                    yield format_sse({"type": "chunk", "content": chunk["content"]})
                elif chunk.get("type") == "meta":
                    rag_meta = chunk

        except Exception as exc:
            logger.error(f"[SSE] Stream error session={session_id_str}: {exc}")
            yield format_sse({"type": "error", "detail": str(exc)})
            return

        answer = "".join(full_content)
        stream_ms = int((time.monotonic() - t0) * 1000)
        tok_per_sec = rag_meta.get("tokens_per_second", 0)

        logger.info(
            f"[SSE:done] user={user_id_str} session={session_id_str} | "
            f"chars={len(answer)} | total_stream={stream_ms}ms | speed={tok_per_sec} tok/s"
        )

        async with AsyncSessionLocal() as db_new:
            assistant_msg = ChatMessage(
                id=str(uuid_v7()),
                session_id=session_id_str,
                role="assistant",
                content=answer,
                sources=rag_meta.get("sources", []),
                intent=rag_meta.get("intent"),
                suggested_questions=rag_meta.get("suggested_questions", []),
                prompt_tokens=rag_meta.get("prompt_tokens", 0),
                completion_tokens=rag_meta.get("completion_tokens", 0),
                latency_ms=rag_meta.get("latency_ms"),
                confidence_score=rag_meta.get("confidence_score"),
                search_method=rag_meta.get("search_method"),
                search_ms=rag_meta.get("search_ms"),
                llm_ms=rag_meta.get("llm_ms"),
                cache_hit=rag_meta.get("cache_hit"),
                chunk_count=rag_meta.get("chunk_count"),
            )
            db_new.add(assistant_msg)
            await db_new.commit()
            await db_new.refresh(assistant_msg)

            yield format_sse({
                "type": "done",
                "message_id": assistant_msg.id,
                "sources": rag_meta.get("sources", []),
                "latency_ms": rag_meta.get("latency_ms"),
                "tokens_per_second": tok_per_sec,
                # [P0] surface intent + độ tin cậy + câu gợi ý ra mobile
                "intent": rag_meta.get("intent"),
                "confidence_score": rag_meta.get("confidence_score"),
                "suggested_questions": rag_meta.get("suggested_questions", []),
                # [P1] lịch trình có cấu trúc (plan_trip)
                "itinerary": rag_meta.get("itinerary"),
            })

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
            "Connection": "keep-alive",
            # ✅ Content-Type tường minh cho SSE
            "Content-Type": "text/event-stream; charset=utf-8",
        },
    )


@router.patch("/chat/messages/{message_id}/feedback", response_model=ChatMessageOut)
async def update_feedback(
    message_id: UUID,
    payload: FeedbackUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    result = await db.execute(
        select(ChatMessage)
        .join(ChatSession, ChatSession.id == ChatMessage.session_id)
        .where(
            ChatMessage.id == str(message_id),
            ChatMessage.role == "assistant",
            ChatSession.user_id == str(current_user.id),
        )
    )
    msg = result.scalar_one_or_none()
    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")
    msg.feedback          = payload.feedback
    msg.feedback_reason   = payload.reason
    msg.feedback_category = payload.category
    await db.commit()
    await db.refresh(msg)
    event_type = "feedback_positive" if payload.feedback == 1 else "feedback_negative"
    await log_service.log_behavior(
        user_id=str(current_user.id),
        event_type=event_type,
        entity_type="chat_message",
        entity_id=str(message_id),
        metadata={"reason": payload.reason, "category": payload.category},
    )
    return msg


def _make_session_title(content: str, max_len: int = 80) -> str:
    """Tạo tiêu đề hội thoại từ câu hỏi đầu tiên của người dùng."""
    title = " ".join((content or "").split()).strip()
    if len(title) > max_len:
        title = title[:max_len].rstrip() + "…"
    return title or "Hội thoại mới"


async def _maybe_set_session_title(
    db: AsyncSession, session_id: UUID, content: str
) -> None:
    """Đặt tiêu đề = câu hỏi đầu tiên, chỉ khi session chưa có tiêu đề."""
    await db.execute(
        update(ChatSession)
        .where(
            ChatSession.id == str(session_id),
            (ChatSession.title.is_(None)) | (ChatSession.title == ""),
        )
        .values(title=_make_session_title(content))
    )


async def _assert_session_owner(db: AsyncSession, session_id: UUID, user_id: str) -> None:
    result = await db.execute(
        select(ChatSession.id).where(
            ChatSession.id == str(session_id),
            ChatSession.user_id == str(user_id),
            ChatSession.is_deleted.is_(False),
        )
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Session not found")


def _chunk_text(text: str, size: int = 24):
    """
    Cắt text thành mẩu nhỏ để stream cho có cảm giác gõ dần (planner reply).

    Bug đã sửa: bản cũ dùng `text.split(" ")` rồi nối lại bằng `" " + w` —
    khoảng trắng ở RANH GIỚI GIỮA 2 CHUNK bị mất (chunk trước không có khoảng
    trắng cuối, chunk sau không có khoảng trắng đầu), nên khi frontend nối
    các chunk SSE lại bằng cách ghép chuỗi thô, 2 từ ở đúng ranh giới đó bị
    dính liền (vd "Ăn trưa" + "tự do" → "Ăn trưatự do"). Cùng lỗi khiến
    "**Ngày 2:**" dính vào chữ trước nếu "\n" rơi đúng ranh giới chunk.

    Dùng `re.split(r"(\s+)", text)` (giữ khoảng trắng — kể cả "\n" — làm token
    riêng nhờ capturing group) rồi gộp token vào buffer thay vì tách theo từ:
    nối lại toàn bộ token luôn tái tạo ĐÚNG NGUYÊN VĂN gốc, bất kể điểm cắt
    rơi ở đâu.
    """
    tokens = re.split(r"(\s+)", text)
    buf = ""
    for tok in tokens:
        buf += tok
        if len(buf) >= size:
            yield buf
            buf = ""
    if buf:
        yield buf


async def _save_last_itinerary(db: AsyncSession, session_id: UUID, itinerary: dict) -> None:
    """Lưu lịch trình mới nhất vào chat_sessions.last_itinerary để không mất khi
    user quay lại xem/lưu sau (Req 2)."""
    await db.execute(
        update(ChatSession)
        .where(ChatSession.id == str(session_id))
        .values(last_itinerary=itinerary)
    )


async def _get_recent_history(
    db: AsyncSession, session_id: UUID, limit: int = 10
) -> list[dict]:
    """
    ✅ Lấy tối đa `limit` tin nhắn gần nhất (mặc định 10 từ config).
    Trả về theo thứ tự cũ → mới để Gemini đọc ngữ cảnh đúng chiều.
    """
    result = await db.execute(
        select(ChatMessage.role, ChatMessage.content)
        .where(ChatMessage.session_id == str(session_id))
        .order_by(ChatMessage.created_at.desc())
        .limit(limit)
    )
    rows = result.all()
    return [{"role": r.role, "content": r.content} for r in reversed(rows)]
