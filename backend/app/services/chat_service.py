# app/services/chat_service.py
# ============================================================
#  Chat Service — orchestrate Intent → RAG → Gemini → Response
# ============================================================

from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.models import Destination, Hotel, Tour
from app.services.intent_classifier import IntentResult
from app.services.rag_service import ask_gemini, ask_gemini_streaming, get_rag_service
from app.config import settings


# ── Hàm trợ giúp lấy dữ liệu DB ──────────────────────────────────────────────

async def _get_destinations(db: AsyncSession, keyword: str = "") -> list[dict]:
    stmt = select(Destination)
    if keyword:
        stmt = stmt.where(Destination.name.ilike(f"%{keyword}%"))
    result = await db.execute(stmt.limit(6))
    rows = result.scalars().all()
    return [
        {
            "id": r.id,
            "name": r.name,
            "region": r.region,
            "description": r.description,
            "budget_low": r.budget_low,
            "budget_high": r.budget_high,
            "tags": r.tags,
            "best_season": r.best_season,
            "image_url": r.image_url,
        }
        for r in rows
    ]


async def _get_hotels(db: AsyncSession, destination: str = "") -> list[dict]:
    stmt = select(Hotel)
    if destination:
        stmt = stmt.where(Hotel.destination.ilike(f"%{destination}%"))
    result = await db.execute(stmt.limit(4))
    rows = result.scalars().all()
    return [
        {
            "id": r.id,
            "name": r.name,
            "destination": r.destination,
            "type": r.type,
            "price_per_night": r.price_per_night,
            "rating": r.rating,
            "amenities": r.amenities,
        }
        for r in rows
    ]


async def _get_tours(db: AsyncSession, destination: str = "") -> list[dict]:
    stmt = select(Tour)
    if destination:
        stmt = stmt.where(Tour.destination.ilike(f"%{destination}%"))
    result = await db.execute(stmt.limit(4))
    rows = result.scalars().all()
    return [
        {
            "id": r.id,
            "name": r.name,
            "destination": r.destination,
            "duration": r.duration,
            "price": r.price,
            "description": r.description,
            "includes": r.includes,
        }
        for r in rows
    ]


# ── Lịch trình đơn giản (fallback khi KB không đủ dữ liệu) ───────────────────

def _build_simple_itinerary(destination: str, days: int = 3) -> dict:
    return {
        "destination": destination,
        "days": days,
        "note": f"Lịch trình {days} ngày {days-1} đêm tại {destination} — xem chi tiết trong câu trả lời AI.",
    }


def _kb_fallback_text(top_docs: list[dict]) -> str:
    if not top_docs:
        return "Mình chưa có thông tin phù hợp cho câu hỏi này, bạn thử hỏi khác nhé 😊"

    best_doc = top_docs[0]  # chỉ lấy doc ưu tiên nhất
    return f"🌍 {best_doc['title']}: {best_doc['content']}"

# ── Hàm chính ─────────────────────────────────────────────────────────────────

async def generate_response(
    message: str,
    intent_result: IntentResult,
    db: AsyncSession,
) -> dict:
    """
    Orchestrate toàn bộ pipeline:
      1. RAG: retrieve + rerank → context
      2. Gemini: context + query → answer
      3. Tuỳ intent: gắn thêm destinations / services / itinerary
    Trả về dict khớp với ChatResponse schema.
    """
    rag = get_rag_service()
    intent = intent_result.intent
    dest = intent_result.destination  # có thể rỗng

    if intent_result.confidence < 0.35:
        intent = "general"

    # ── Bước 1: RAG ──────────────────────────────────────────────────────────
    top_docs, context = rag.search(message, intent=intent, destination=dest)
    sources = [d["title"] for d in top_docs]

    # ── Bước 2: Gọi Gemini hoặc dùng KB trực tiếp ──────────────────────────────
    if not settings.use_gemini:
        ai_text = _kb_fallback_text(top_docs)
    else:
        try:
            ai_text = await ask_gemini(message, context)
        except Exception:
            ai_text = _kb_fallback_text(top_docs)



    # ── Bước 3: Tuỳ intent gắn thêm dữ liệu ─────────────────────────────────
    result: dict = {
        "text": ai_text,
        "intent": intent,
        "sources": sources,
        "has_itinerary": False,
        "itinerary": None,
        "destinations": None,
        "services": None,
    }

    if intent == "recommendation":
        result["destinations"] = await _get_destinations(db, keyword=dest)

    elif intent == "hotel":
        hotels = await _get_hotels(db, destination=dest)
        result["services"] = hotels

    elif intent == "itinerary":
        # Lấy tour liên quan + tạo itinerary summary
        tours = await _get_tours(db, destination=dest)
        result["services"] = tours
        if dest:
            result["has_itinerary"] = True
            result["itinerary"] = _build_simple_itinerary(dest)
        else:
            result["text"] = (
                "Bạn vui lòng cho mình biết điểm đến cụ thể, ví dụ: 'Lên lịch trình Phú Quốc 3 ngày 2 đêm'."
            )

    elif intent == "transport":
        # Gắn destinations để frontend gợi ý
        result["destinations"] = await _get_destinations(db, keyword=dest)

    elif intent == "budget":
        hotels = await _get_hotels(db, destination=dest)
        tours = await _get_tours(db, destination=dest)
        result["services"] = hotels + tours

    return result


async def generate_response_streaming(
    message: str,
    intent_result: IntentResult,
    db: AsyncSession,
):
    """
    Streaming version của generate_response.
    Yield events: {"type": "metadata", ...} sau đó {"type": "chunk", "text": "..."}
    """
    rag = get_rag_service()
    intent = intent_result.intent
    dest = intent_result.destination

    if intent_result.confidence < 0.35:
        intent = "general"

    # ── RAG retrieve + rerank ────────────────────────────────────────────────
    top_docs, context = rag.search(message, intent=intent, destination=dest)
    sources = [d["title"] for d in top_docs]

    # ── Chuẩn bị metadata ────────────────────────────────────────────────────
    destinations = None
    services = None
    has_itinerary = False
    itinerary = None

    if intent == "recommendation":
        destinations = await _get_destinations(db, keyword=dest)
    elif intent == "hotel":
        services = await _get_hotels(db, destination=dest)
    elif intent == "itinerary":
        services = await _get_tours(db, destination=dest)
        if dest:
            has_itinerary = True
            itinerary = _build_simple_itinerary(dest)
    elif intent == "transport":
        destinations = await _get_destinations(db, keyword=dest)
    elif intent == "budget":
        hotels = await _get_hotels(db, destination=dest)
        tours = await _get_tours(db, destination=dest)
        services = (hotels or []) + (tours or [])

    # ── Yield metadata trước ─────────────────────────────────────────────────
    yield {
        "type": "metadata",
        "intent": intent,
        "confidence": intent_result.confidence,
        "sources": sources,
        "has_itinerary": has_itinerary,
        "itinerary": itinerary,
        "destinations": destinations,
        "services": services,
    }

    # ── Stream LLM response ──────────────────────────────────────────────────
    if not settings.use_gemini:
        full_text = _kb_fallback_text(top_docs)
        yield {"type": "chunk", "text": full_text}
    else:
        try:
            async for chunk in ask_gemini_streaming(message, context):
                yield {"type": "chunk", "text": chunk}
        except Exception:
            fallback_text = _kb_fallback_text(top_docs)
            yield {"type": "chunk", "text": fallback_text}

    # ── Signal end of stream ────────────────────────────────────────────────
    yield {"type": "done"}