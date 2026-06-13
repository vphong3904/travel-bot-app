import json
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.auth import CurrentUser, check_and_consume_ai_quota, get_optional_user
from app.database import get_db
from app.init_db import log_chat
from app.models import ChatLog, ChatSession
from app.schemas import (
    ChatRequest,
    ChatResponse,
    ChatSessionDetailResponse,
    ChatSessionResponse,
)
from app.services.chat_service import generate_response, generate_response_streaming
from app.services.intent_classifier import classify_intent

router = APIRouter(prefix="/chat", tags=["Chat"])


def _format_sse(event: str, data: dict) -> str:
    payload = json.dumps(data, ensure_ascii=False)
    return f"event: {event}\ndata: {payload}\n\n"


def _auto_title(message: str, max_len: int = 60) -> str:
    """Tao tieu de session tu tin nhan dau tien."""
    title = message.strip().replace("\n", " ")
    return title[:max_len] + ("..." if len(title) > max_len else "")


async def _resolve_identity(
    request: ChatRequest, user: Optional[CurrentUser]
) -> tuple[int, str]:
    """Xac dinh user_id/user_name thuc su dung cho session & log.

    - Neu co JWT hop le: luon dung id/ten tu token (khong tin client gui len),
      tranh truong hop user A gia mao user_id cua user B.
    - Neu khong co token (Guest): dung user_id=0 co dinh, bo qua moi
      user_id khac 0 ma client gui len.
    """
    if user:
        return user.id, user.name
    return 0, request.user_name or "Khach"


async def _get_or_create_session(
    db: AsyncSession,
    user_id: int,
    user_name: str,
    session_id: int | None,
    first_message: str,
) -> int:
    """Tra ve session_id hop le (tao moi neu can). Kiem tra session phai
    thuoc ve chinh user_id dang request (chong truy cap cheo session)."""
    if session_id:
        result = await db.execute(
            select(ChatSession).where(ChatSession.id == session_id)
        )
        session = result.scalar_one_or_none()
        if session is None:
            raise HTTPException(status_code=404, detail="Khong tim thay session")
        if session.user_id != user_id:
            raise HTTPException(
                status_code=403, detail="Ban khong co quyen truy cap session nay"
            )
        return session_id

    session = ChatSession(
        user_id=user_id,
        user_name=user_name,
        title=_auto_title(first_message),
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return session.id


# -- JSON endpoint (khong streaming) -----------------------------------------
@router.post("/json", response_model=ChatResponse)
async def chat_json(
    request: ChatRequest,
    db: AsyncSession = Depends(get_db),
    user: Optional[CurrentUser] = Depends(get_optional_user),
):
    uid, uname = await _resolve_identity(request, user)
    await check_and_consume_ai_quota(user, db)
    intent_result = classify_intent(request.message)
    result = await generate_response(request.message, intent_result, db)

    sid = await _get_or_create_session(
        db, uid, uname, request.session_id, request.message
    )

    await log_chat(
        db=db,
        user_id=uid,
        user_name=uname,
        message=request.message,
        response=result["text"],
        intent=result["intent"],
        destination=result.get("itinerary", {}).get("destination", "") if result.get("itinerary") else "",
        session_id=sid,
    )

    return ChatResponse(
        text=result["text"],
        intent=result["intent"],
        confidence=intent_result.confidence,
        has_itinerary=result.get("has_itinerary", False),
        itinerary=result.get("itinerary"),
        destinations=result.get("destinations"),
        services=result.get("services"),
        sources=result.get("sources", []),
        session_id=sid,
    )


# -- SSE streaming endpoint ----------------------------------------------------
@router.post("")
async def chat(
    request: ChatRequest,
    db: AsyncSession = Depends(get_db),
    user: Optional[CurrentUser] = Depends(get_optional_user),
):
    uid, uname = await _resolve_identity(request, user)
    await check_and_consume_ai_quota(user, db)
    intent_result = classify_intent(request.message)

    sid = await _get_or_create_session(
        db, uid, uname, request.session_id, request.message
    )

    async def event_generator():
        full_response_text = ""

        yield _format_sse("session", {"session_id": sid})

        try:
            async for event in generate_response_streaming(request.message, intent_result, db):
                if event["type"] == "metadata":
                    yield _format_sse("metadata", {
                        "intent": event["intent"],
                        "confidence": event["confidence"],
                        "sources": event["sources"],
                        "has_itinerary": event["has_itinerary"],
                        "itinerary": event["itinerary"],
                        "destinations": event["destinations"],
                        "services": event["services"],
                    })

                elif event["type"] == "chunk":
                    chunk_text = event["text"]
                    full_response_text += chunk_text
                    yield _format_sse("chunk", {"text": chunk_text})

                elif event["type"] == "done":
                    await log_chat(
                        db=db,
                        user_id=uid,
                        user_name=uname,
                        message=request.message,
                        response=full_response_text,
                        intent=intent_result.intent,
                        destination="",
                        session_id=sid,
                    )
                    yield _format_sse("done", {"status": "success"})

        except Exception as exc:
            yield _format_sse("error", {
                "type": "error",
                "text": f"Da xay ra loi: {str(exc)[:200]}",
            })

    return StreamingResponse(event_generator(), media_type="text/event-stream")


# -- Lich su chat session (yeu cau dang nhap) ---------------------------------
@router.get("/sessions", response_model=list[ChatSessionResponse])
async def list_sessions(
    db: AsyncSession = Depends(get_db),
    user: Optional[CurrentUser] = Depends(get_optional_user),
):
    """Tra ve danh sach session cua user hien tai (moi nhat truoc).
    Guest (chua dang nhap) khong co lich su luu tren server -> tra ve []."""
    if user is None:
        return []
    result = await db.execute(
        select(ChatSession)
        .where(ChatSession.user_id == user.id)
        .order_by(ChatSession.updated_at.desc())
    )
    return result.scalars().all()


@router.get("/sessions/{session_id}", response_model=ChatSessionDetailResponse)
async def get_session(
    session_id: int,
    db: AsyncSession = Depends(get_db),
    user: Optional[CurrentUser] = Depends(get_optional_user),
):
    if user is None:
        raise HTTPException(status_code=401, detail="Yeu cau dang nhap")

    result = await db.execute(select(ChatSession).where(ChatSession.id == session_id))
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="Khong tim thay session")
    if session.user_id != user.id and user.role != "admin":
        raise HTTPException(status_code=403, detail="Ban khong co quyen truy cap session nay")

    msgs_result = await db.execute(
        select(ChatLog)
        .where(ChatLog.session_id == session_id)
        .order_by(ChatLog.created_at.asc())
    )
    messages = msgs_result.scalars().all()

    data = ChatSessionResponse.model_validate(session).model_dump()
    data["messages"] = messages
    return ChatSessionDetailResponse(**data)


@router.delete("/sessions/{session_id}")
async def delete_session(
    session_id: int,
    db: AsyncSession = Depends(get_db),
    user: Optional[CurrentUser] = Depends(get_optional_user),
):
    if user is None:
        raise HTTPException(status_code=401, detail="Yeu cau dang nhap")

    result = await db.execute(select(ChatSession).where(ChatSession.id == session_id))
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=404, detail="Khong tim thay session")
    if session.user_id != user.id and user.role != "admin":
        raise HTTPException(status_code=403, detail="Ban khong co quyen xoa session nay")

    await db.execute(
        ChatLog.__table__.delete().where(ChatLog.session_id == session_id)
    )
    await db.delete(session)
    await db.commit()
    return {"ok": True}
