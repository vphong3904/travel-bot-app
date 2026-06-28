"""
Kết nối MongoDB (qua Motor – async driver) dùng để lưu các loại "log":
  - search_history            : lịch sử tìm kiếm của user
  - user_behavior              : event log hành vi (view, click, save...)
  - chatbot_unanswered_questions : câu hỏi bot trả lời kém / out-of-scope
  - chatbot_flagged_responses  : câu trả lời nghi hallucination cần review

Trước đây 4 loại dữ liệu này nằm trong PostgreSQL nhưng về bản chất là
event-log append-only, không cần JOIN/ACID phức tạp với các bảng nghiệp vụ
khác → chuyển sang MongoDB để dễ scale & đổi schema sau này.

Cách dùng:
    from app.db.mongo import get_mongo_db
    db = get_mongo_db()
    await db[COLLECTION_SEARCH_HISTORY].insert_one({...})

Lifecycle (connect/close) được gọi từ app/main.py (lifespan).
"""
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase

from app.core.config import settings
from app.utils import get_logger

logger = get_logger("mongo")

# ── Tên collection (đặt tên giống bảng SQL cũ để dễ tra cứu / migrate) ────────
COLLECTION_SEARCH_HISTORY = "search_history"
COLLECTION_USER_BEHAVIOR = "user_behavior"
COLLECTION_UNANSWERED_QUESTIONS = "chatbot_unanswered_questions"
COLLECTION_FLAGGED_RESPONSES = "chatbot_flagged_responses"
COLLECTION_AUDIT_LOGS = "admin_audit_logs"

_client: AsyncIOMotorClient | None = None
_db: AsyncIOMotorDatabase | None = None


async def connect_mongo() -> None:
    """Mở connection pool tới MongoDB. Gọi 1 lần khi app startup."""
    global _client, _db
    if _client is not None:
        return
    try:
        _client = AsyncIOMotorClient(
            settings.MONGODB_URL,
            serverSelectionTimeoutMS=5000,
        )
        _db = _client[settings.MONGODB_DB_NAME]
        # ping để chắc chắn connect được, fail-fast nếu sai config
        await _client.admin.command("ping")
        await _ensure_indexes(_db)
        logger.info(f"[Mongo] Kết nối thành công tới '{settings.MONGODB_DB_NAME}'")
    except Exception as e:
        logger.warning(
            f"[Mongo] Không thể kết nối MongoDB ({settings.MONGODB_URL}): {e}. "
            "Các tính năng log (search_history, user_behavior, flagged_responses, "
            "unanswered_questions) sẽ không hoạt động cho tới khi MongoDB sẵn sàng."
        )
        # Không raise — Mongo chỉ phục vụ logging, không nên làm sập cả app
        # nếu service Mongo tạm thời chưa lên (khác với Postgres/Qdrant là core data).


async def close_mongo() -> None:
    """Đóng connection khi app shutdown."""
    global _client, _db
    if _client is not None:
        _client.close()
        _client = None
        _db = None
        logger.info("[Mongo] Đã đóng kết nối")


def get_mongo_db() -> AsyncIOMotorDatabase:
    """
    Lấy database handle hiện tại. Dùng trong service/route sau khi đã connect_mongo().
    Raise RuntimeError rõ ràng nếu chưa connect, để dễ debug hơn là AttributeError mù mờ.
    """
    if _db is None:
        raise RuntimeError(
            "MongoDB chưa được kết nối. Đảm bảo connect_mongo() đã chạy ở lifespan startup "
            "và MONGODB_URL trong .env trỏ đúng tới instance Mongo đang chạy."
        )
    return _db


async def _ensure_indexes(db: AsyncIOMotorDatabase) -> None:
    """Tạo index tương đương các CREATE INDEX của bảng SQL cũ."""
    await db[COLLECTION_SEARCH_HISTORY].create_index("user_id")
    await db[COLLECTION_SEARCH_HISTORY].create_index("created_at")
    await db[COLLECTION_SEARCH_HISTORY].create_index("keyword")

    await db[COLLECTION_USER_BEHAVIOR].create_index("user_id")
    await db[COLLECTION_USER_BEHAVIOR].create_index("event_type")
    await db[COLLECTION_USER_BEHAVIOR].create_index([("entity_type", 1), ("entity_id", 1)])
    await db[COLLECTION_USER_BEHAVIOR].create_index("created_at")

    await db[COLLECTION_UNANSWERED_QUESTIONS].create_index("reason")
    await db[COLLECTION_UNANSWERED_QUESTIONS].create_index("is_resolved")
    await db[COLLECTION_UNANSWERED_QUESTIONS].create_index("created_at")

    await db[COLLECTION_FLAGGED_RESPONSES].create_index("session_id")
    await db[COLLECTION_FLAGGED_RESPONSES].create_index("is_reviewed")
    await db[COLLECTION_FLAGGED_RESPONSES].create_index("created_at")

    await db[COLLECTION_AUDIT_LOGS].create_index("actor_id")
    await db[COLLECTION_AUDIT_LOGS].create_index([("created_at", -1)])
    await db[COLLECTION_AUDIT_LOGS].create_index("resource_type")
    await db[COLLECTION_AUDIT_LOGS].create_index("action")
    await db[COLLECTION_AUDIT_LOGS].create_index([("actor_id", 1), ("created_at", -1)])
