import json
from typing import AsyncGenerator
from fastapi.responses import StreamingResponse


def format_sse(data: dict | str, event: str = "message") -> str:
    """Format một SSE event. Alias: sse_event."""
    payload = data if isinstance(data, str) else json.dumps(data, ensure_ascii=False)
    return f"event: {event}\ndata: {payload}\n\n"


# Alias tương thích ngược
sse_event = format_sse


def sse_done() -> str:
    return "event: done\ndata: [DONE]\n\n"


def sse_error(msg: str) -> str:
    return format_sse({"error": msg}, event="error")


async def stream_response(generator: AsyncGenerator) -> StreamingResponse:
    return StreamingResponse(
        generator,
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
            "Connection": "keep-alive",
        },
    )