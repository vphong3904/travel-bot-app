from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.init_db import log_chat
from app.schemas import ChatRequest, ChatResponse
from app.services.chat_service import generate_response
from app.services.intent_classifier import classify_intent

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("", response_model=ChatResponse)
async def chat(request: ChatRequest, db: AsyncSession = Depends(get_db)):
    intent_result = classify_intent(request.message)  # sync → giữ nguyên nếu không dùng db
    result = await generate_response(request.message, intent_result, db)  # cần sửa thành async nếu nó query db

    await log_chat(  # cần sửa thành async nếu nó query db
        db=db,
        user_id=request.user_id,
        user_name=request.user_name,
        message=request.message,
        response=result["text"],
        intent=result["intent"],
        destination=result.get("itinerary", {}).get("destination", "") if result.get("itinerary") else "",
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
    )