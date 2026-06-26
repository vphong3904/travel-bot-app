"""
Route: POST /chat/guest/stream
Cho phép khách (chưa đăng nhập) hỏi AI tối đa N câu/ngày tính theo IP.
Không lưu session/history vào DB. Dùng RAG pipeline như user thường.
"""
import time
import asyncio
from collections import defaultdict
from datetime import date
from typing import AsyncGenerator

from fastapi import APIRouter, Request, HTTPException, status
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from app.core.config import settings
from app.core.sse import format_sse
from app.services.nlp_preprocessor import preprocess
from app.utils import get_logger

router = APIRouter(tags=["chat-guest"])
logger = get_logger("chat_guest")

# ── Cấu hình giới hạn ─────────────────────────────────────────────────────────
GUEST_DAILY_LIMIT: int = 3          # số câu tối đa mỗi khách/ngày
GUEST_MIN_INTERVAL: float = 2.0     # giây tối thiểu giữa 2 request liên tiếp (anti-spam)

# ── In-memory rate limiter (reset khi restart server) ─────────────────────────
# Cấu trúc: { ip: {"date": "2026-06-25", "count": 2, "last_ts": 1234567890.0} }
_guest_usage: dict[str, dict] = defaultdict(lambda: {"date": "", "count": 0, "last_ts": 0.0})
_lock = asyncio.Lock()


def _get_client_ip(request: Request) -> str:
    """Lấy IP thật, hỗ trợ reverse proxy qua X-Forwarded-For."""
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


async def _check_and_increment(ip: str) -> tuple[bool, int]:
    """
    Kiểm tra quota và tăng đếm nếu còn slot.
    Returns: (allowed, remaining_after)
    """
    today = date.today().isoformat()
    async with _lock:
        usage = _guest_usage[ip]

        # Reset nếu sang ngày mới
        if usage["date"] != today:
            usage["date"] = today
            usage["count"] = 0
            usage["last_ts"] = 0.0

        # Anti-spam: kiểm tra interval
        now = time.monotonic()
        if now - usage["last_ts"] < GUEST_MIN_INTERVAL:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Vui lòng chờ {GUEST_MIN_INTERVAL:.0f} giây giữa các câu hỏi.",
            )

        # Kiểm tra daily limit
        if usage["count"] >= GUEST_DAILY_LIMIT:
            remaining = 0
            return False, remaining

        # Tăng đếm
        usage["count"] += 1
        usage["last_ts"] = now
        remaining = GUEST_DAILY_LIMIT - usage["count"]
        return True, remaining


# ── Schema ─────────────────────────────────────────────────────────────────────

class GuestChatRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=500)


# ── RAG lazy singleton (tái dùng instance từ chat_messages nếu đã khởi tạo) ───

_rag = None

def _get_rag():
    global _rag
    if _rag is None:
        from app.services.rag_pipeline import RAGPipeline
        _rag = RAGPipeline()
    return _rag


# ── Route ──────────────────────────────────────────────────────────────────────

@router.post("/chat/guest/stream")
async def guest_stream(
    payload: GuestChatRequest,
    request: Request,
):
    """
    SSE stream cho khách chưa đăng nhập.
    - Giới hạn GUEST_DAILY_LIMIT câu/IP/ngày (reset lúc 00:00).
    - Không lưu session, không lưu history.
    - Trả về header X-Guest-Remaining để frontend cập nhật UI.
    """
    ip = _get_client_ip(request)
    allowed, remaining = await _check_and_increment(ip)

    if not allowed:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Bạn đã dùng hết {GUEST_DAILY_LIMIT} câu hỏi miễn phí hôm nay. Đăng nhập để hỏi không giới hạn!",
        )

    question = payload.content.strip()
    rag = _get_rag()

    # session_id giả cho NLP + logging (không lưu DB)
    guest_session_id = f"guest:{ip}:{date.today().isoformat()}"

    async def event_generator() -> AsyncGenerator[str, None]:
        t0 = time.monotonic()
        full_content: list[str] = []
        rag_meta: dict = {}

        yield format_sse({"type": "start", "remaining": remaining})

        try:
            async for chunk in rag.stream_query(
                question=question,
                history=[],           # khách không có history
                session_id=guest_session_id,
            ):
                if await request.is_disconnected():
                    logger.info(f"[GUEST-SSE] disconnect ip={ip}")
                    return

                if chunk.get("type") == "chunk":
                    full_content.append(chunk["content"])
                    yield format_sse({"type": "chunk", "content": chunk["content"]})
                elif chunk.get("type") == "meta":
                    rag_meta = chunk

        except Exception as exc:
            logger.error(f"[GUEST-SSE] error ip={ip}: {exc}")
            yield format_sse({"type": "error", "detail": str(exc)})
            return

        total_ms = int((time.monotonic() - t0) * 1000)
        logger.info(
            f"[GUEST-SSE:done] ip={ip} | chars={len(''.join(full_content))} "
            f"| {total_ms}ms | remaining={remaining}"
        )

        yield format_sse({
            "type": "done",
            "sources": rag_meta.get("sources", []),
            "remaining": remaining,          # frontend dùng để update counter
            "latency_ms": rag_meta.get("latency_ms"),
        })

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
            "Connection": "keep-alive",
            "Content-Type": "text/event-stream; charset=utf-8",
            "X-Guest-Remaining": str(remaining),
        },
    )


@router.get("/chat/guest/status")
async def guest_status(request: Request):
    """
    Trả về số câu hỏi còn lại cho IP hiện tại.
    Frontend gọi khi mở app để sync lại counter với server.
    """
    ip = _get_client_ip(request)
    today = date.today().isoformat()
    async with _lock:
        usage = _guest_usage[ip]
        if usage["date"] != today:
            count = 0
        else:
            count = usage["count"]
    remaining = max(0, GUEST_DAILY_LIMIT - count)
    return {
        "used": count,
        "limit": GUEST_DAILY_LIMIT,
        "remaining": remaining,
        "reset_at": "00:00 ngày hôm sau",
    }