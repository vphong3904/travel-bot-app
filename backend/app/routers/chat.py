from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.init_db import log_chat
from app.schemas import ChatRequest, ChatResponse
from app.services.chat_service import generate_response
from app.services.intent_classifier import classify_intent

router = APIRouter(prefix="/chat", tags=["Chat"])


@router.post("", response_model=ChatResponse)
def chat(request: ChatRequest, db: Session = Depends(get_db)):
    intent_result = classify_intent(request.message)
    result = generate_response(request.message, intent_result, db)

    log_chat(
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
