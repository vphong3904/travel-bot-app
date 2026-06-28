"""
Service ghi/đọc 4 loại log đã chuyển từ PostgreSQL sang MongoDB:
  - search_history
  - user_behavior
  - chatbot_unanswered_questions
  - chatbot_flagged_responses

Tất cả document dùng `id` là string UUID4 (không dùng ObjectId của Mongo)
để giữ format giống id cũ (UUID) khi trả ra cho client / so sánh với
user_id, session_id... vốn là UUID bên Postgres.
"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone
from typing import Optional

from app.db.mongo import (
    get_mongo_db,
    COLLECTION_SEARCH_HISTORY,
    COLLECTION_USER_BEHAVIOR,
    COLLECTION_UNANSWERED_QUESTIONS,
    COLLECTION_FLAGGED_RESPONSES,
)
from app.utils import get_logger

logger = get_logger("log_service")


def _now() -> datetime:
    return datetime.now(timezone.utc)


def _new_id() -> str:
    return str(uuid.uuid4())


# ════════════════════════════════════════════════════════════════════════════
# SEARCH HISTORY
# ════════════════════════════════════════════════════════════════════════════

async def log_search(user_id: str, keyword: str, result_count: int) -> dict:
    """Ghi 1 lượt tìm kiếm. Tương đương INSERT INTO search_history cũ."""
    doc = {
        "id": _new_id(),
        "user_id": str(user_id),
        "keyword": keyword,
        "result_count": result_count,
        "created_at": _now(),
    }
    try:
        await get_mongo_db()[COLLECTION_SEARCH_HISTORY].insert_one(doc)
    except Exception as e:
        # Log là phụ, không nên làm fail cả request search chính
        logger.warning(f"[log_search] Không thể ghi search_history: {e}")
    return doc


async def get_search_history(user_id: str, skip: int = 0, limit: int = 20) -> list[dict]:
    cursor = (
        get_mongo_db()[COLLECTION_SEARCH_HISTORY]
        .find({"user_id": str(user_id)}, {"_id": 0})
        .sort("created_at", -1)
        .skip(skip)
        .limit(limit)
    )
    return await cursor.to_list(length=limit)


async def clear_search_history(user_id: str) -> int:
    result = await get_mongo_db()[COLLECTION_SEARCH_HISTORY].delete_many(
        {"user_id": str(user_id)}
    )
    return result.deleted_count


async def top_search_keywords(since: datetime, limit: int = 20) -> list[dict]:
    """Top keyword tìm nhiều nhất — tương đương GROUP BY keyword bên SQL."""
    pipeline = [
        {"$match": {"created_at": {"$gte": since}}},
        {"$group": {"_id": "$keyword", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}},
        {"$limit": limit},
    ]
    rows = await get_mongo_db()[COLLECTION_SEARCH_HISTORY].aggregate(pipeline).to_list(length=limit)
    return [{"keyword": r["_id"], "count": r["count"]} for r in rows]


# ════════════════════════════════════════════════════════════════════════════
# USER BEHAVIOR
# ════════════════════════════════════════════════════════════════════════════

VALID_EVENT_TYPES = {
    "view_destination",
    "view_hotel",
    "view_tour",
    "save_trip",
    "feedback_positive",
    "feedback_negative",
    "ask_chatbot",
}


async def log_behavior(
    user_id: str,
    event_type: str,
    entity_type: Optional[str] = None,
    entity_id: Optional[str] = None,
    session_id: Optional[str] = None,
) -> dict:
    """Ghi 1 event hành vi user. Tương đương INSERT INTO user_behavior cũ."""
    if event_type not in VALID_EVENT_TYPES:
        # giữ đúng tinh thần CHECK constraint cũ, nhưng không raise để không vỡ flow chính
        logger.warning(f"[log_behavior] event_type lạ: {event_type}")

    doc = {
        "id": _new_id(),
        "user_id": str(user_id),
        "event_type": event_type,
        "entity_type": entity_type,
        "entity_id": str(entity_id) if entity_id else None,
        "session_id": str(session_id) if session_id else None,
        "created_at": _now(),
    }
    try:
        await get_mongo_db()[COLLECTION_USER_BEHAVIOR].insert_one(doc)
    except Exception as e:
        logger.warning(f"[log_behavior] Không thể ghi user_behavior: {e}")
    return doc


async def top_viewed_destinations(since: datetime, limit: int = 20) -> list[dict]:
    """Điểm đến được xem nhiều nhất — tương đương GROUP BY entity_id bên SQL."""
    pipeline = [
        {
            "$match": {
                "entity_type": "destination",
                "event_type": "view_destination",
                "created_at": {"$gte": since},
            }
        },
        {"$group": {"_id": "$entity_id", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}},
        {"$limit": limit},
    ]
    rows = await get_mongo_db()[COLLECTION_USER_BEHAVIOR].aggregate(pipeline).to_list(length=limit)
    return [{"destination_id": r["_id"], "views": r["count"]} for r in rows]


# ════════════════════════════════════════════════════════════════════════════
# CHATBOT UNANSWERED QUESTIONS
# ════════════════════════════════════════════════════════════════════════════

VALID_UNANSWERED_REASONS = {"no_context", "wrong_answer", "out_of_scope", "low_confidence"}


async def log_unanswered_question(
    question: str,
    session_id: Optional[str] = None,
    reason: str = "no_context",
) -> dict:
    if reason not in VALID_UNANSWERED_REASONS:
        reason = "no_context"
    doc = {
        "id": _new_id(),
        "question": question,
        "session_id": str(session_id) if session_id else None,
        "reason": reason,
        "created_at": _now(),
        "is_resolved": False,
        "resolved_at": None,
        "resolved_by": None,
    }
    try:
        await get_mongo_db()[COLLECTION_UNANSWERED_QUESTIONS].insert_one(doc)
    except Exception as e:
        logger.warning(f"[log_unanswered_question] Không thể ghi log: {e}")
    return doc


async def list_unanswered_questions(
    is_resolved: Optional[bool] = None, skip: int = 0, limit: int = 50
) -> list[dict]:
    query = {} if is_resolved is None else {"is_resolved": is_resolved}
    cursor = (
        get_mongo_db()[COLLECTION_UNANSWERED_QUESTIONS]
        .find(query, {"_id": 0})
        .sort("created_at", -1)
        .skip(skip)
        .limit(limit)
    )
    return await cursor.to_list(length=limit)


async def resolve_unanswered_question(question_id: str, resolved_by: str) -> bool:
    result = await get_mongo_db()[COLLECTION_UNANSWERED_QUESTIONS].update_one(
        {"id": question_id},
        {"$set": {"is_resolved": True, "resolved_at": _now(), "resolved_by": resolved_by}},
    )
    return result.modified_count > 0


# ════════════════════════════════════════════════════════════════════════════
# CHATBOT FLAGGED RESPONSES (hallucination guard)
# ════════════════════════════════════════════════════════════════════════════

async def log_flagged_response(
    session_id: Optional[str],
    question: str,
    answer: str,
    is_grounded: bool,
    grounding_confidence: Optional[float],
    ungrounded_terms: list[str],
    citation_valid: bool,
    invalid_citation_indices: list[int],
    search_method: Optional[str],
    overall_confidence: Optional[float],
) -> dict:
    """Tương đương INSERT INTO chatbot_flagged_responses cũ (rag_pipeline.py)."""
    doc = {
        "id": _new_id(),
        "session_id": str(session_id) if session_id else None,
        "question": question,
        "answer": answer,
        "is_grounded": is_grounded,
        "grounding_confidence": grounding_confidence,
        "ungrounded_terms": ungrounded_terms or [],
        "citation_valid": citation_valid,
        "invalid_citation_indices": invalid_citation_indices or [],
        "search_method": search_method,
        "overall_confidence": overall_confidence,
        "is_reviewed": False,
        "reviewer_note": None,
        "created_at": _now(),
    }
    await get_mongo_db()[COLLECTION_FLAGGED_RESPONSES].insert_one(doc)
    return doc


async def list_flagged_responses(
    is_reviewed: Optional[bool] = None, skip: int = 0, limit: int = 50
) -> list[dict]:
    query = {} if is_reviewed is None else {"is_reviewed": is_reviewed}
    cursor = (
        get_mongo_db()[COLLECTION_FLAGGED_RESPONSES]
        .find(query, {"_id": 0})
        .sort("created_at", -1)
        .skip(skip)
        .limit(limit)
    )
    return await cursor.to_list(length=limit)


async def review_flagged_response(flagged_id: str, reviewer_note: Optional[str] = None) -> bool:
    result = await get_mongo_db()[COLLECTION_FLAGGED_RESPONSES].update_one(
        {"id": flagged_id},
        {"$set": {"is_reviewed": True, "reviewer_note": reviewer_note}},
    )
    return result.modified_count > 0
