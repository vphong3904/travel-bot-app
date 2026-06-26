"""
Seed dữ liệu mẫu cho 2 collection MongoDB: search_history, user_behavior.
Tương đương phần seed search_history/user_behavior cũ trong
initdb/17_seed_memory_analytics.sql (đã xoá khỏi Postgres).

Cách chạy (sau khi `docker-compose up -d mongo`):
    cd backend
    pip install motor --break-system-packages   # nếu chưa có
    python mongo_seed_logs.py

User ID lấy từ initdb/10_seed_auth.sql (UUID cố định, không random).
"""
import asyncio
import uuid
from datetime import datetime, timezone

from motor.motor_asyncio import AsyncIOMotorClient

MONGODB_URL = "mongodb://localhost:27017"
MONGODB_DB_NAME = "pdtrip_ai_logs"

# username -> user_id (khớp initdb/10_seed_auth.sql)
USERS = {
    "tranlan": "22222222-2222-2222-2222-222222222222",
    "minhhieu": "33333333-3333-3333-3333-333333333333",
    "ngochuong": "44444444-4444-4444-4444-444444444444",
    "quangkhai": "55555555-5555-5555-5555-555555555555",
    "thuylinh": "66666666-6666-6666-6666-666666666666",
}

SESSION_HOI_AN = "c0000000-0000-0000-0000-000000000001"
SESSION_PHU_QUOC = "c0000000-0000-0000-0000-000000000002"
SESSION_SAPA = "c0000000-0000-0000-0000-000000000003"


def _doc(**kwargs) -> dict:
    base = {"id": str(uuid.uuid4()), "created_at": datetime.now(timezone.utc)}
    base.update(kwargs)
    return base


SEARCH_HISTORY_SEED = [
    _doc(user_id=USERS["tranlan"], keyword="lịch trình hội an 3 ngày 2 đêm",
         intent="plan_trip", result_count=5, session_id=SESSION_HOI_AN),
    _doc(user_id=USERS["tranlan"], keyword="resort hội an giá rẻ",
         intent="find_hotel", result_count=3, session_id=SESSION_HOI_AN),
    _doc(user_id=USERS["minhhieu"], keyword="phú quốc hay côn đảo",
         intent="ask_destination", result_count=2, session_id=SESSION_PHU_QUOC),
    _doc(user_id=USERS["minhhieu"], keyword="tour phú quốc trọn gói",
         intent="find_tour", result_count=4, session_id=SESSION_PHU_QUOC),
    _doc(user_id=USERS["ngochuong"], keyword="chi phí du lịch sa pa",
         intent="ask_faq", result_count=1, session_id=SESSION_SAPA),
    _doc(user_id=USERS["quangkhai"], keyword="ninh bình tam cốc hay tràng an",
         intent="ask_faq", result_count=2, session_id=None),
    _doc(user_id=USERS["thuylinh"], keyword="mũi né lướt ván diều an toàn",
         intent="ask_faq", result_count=1, session_id=None),
    _doc(user_id=USERS["quangkhai"], keyword="nha trang 3 ngày 2 đêm bao nhiêu tiền",
         intent="ask_faq", result_count=1, session_id=None),
]

USER_BEHAVIOR_SEED = [
    _doc(user_id=USERS["tranlan"], event_type="view_destination", entity_type="destination",
         entity_id="44444444-4444-4444-4444-444444444444", session_id=SESSION_HOI_AN),
    _doc(user_id=USERS["tranlan"], event_type="ask_chatbot", entity_type=None,
         entity_id=None, session_id=SESSION_HOI_AN),
    _doc(user_id=USERS["tranlan"], event_type="save_trip", entity_type="trip_plan",
         entity_id="b0000000-0000-0000-0000-000000000001", session_id=None),
    _doc(user_id=USERS["minhhieu"], event_type="view_destination", entity_type="destination",
         entity_id="22222222-2222-2222-2222-222222222222", session_id=SESSION_PHU_QUOC),
    _doc(user_id=USERS["minhhieu"], event_type="ask_chatbot", entity_type=None,
         entity_id=None, session_id=SESSION_PHU_QUOC),
    _doc(user_id=USERS["minhhieu"], event_type="feedback_positive", entity_type="chat_message",
         entity_id=None, session_id=None),
    _doc(user_id=USERS["ngochuong"], event_type="view_destination", entity_type="destination",
         entity_id="aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", session_id=None),
    _doc(user_id=USERS["ngochuong"], event_type="save_trip", entity_type="trip_plan",
         entity_id="b0000000-0000-0000-0000-000000000003", session_id=None),
    _doc(user_id=USERS["quangkhai"], event_type="view_tour", entity_type="tour",
         entity_id=None, session_id=None),
    _doc(user_id=USERS["thuylinh"], event_type="view_destination", entity_type="destination",
         entity_id="99999999-9999-9999-9999-999999999999", session_id=None),
    _doc(user_id=USERS["thuylinh"], event_type="view_hotel", entity_type="hotel",
         entity_id=None, session_id=None),
]


async def main() -> None:
    client = AsyncIOMotorClient(MONGODB_URL)
    db = client[MONGODB_DB_NAME]

    await db["search_history"].delete_many({})
    await db["user_behavior"].delete_many({})

    if SEARCH_HISTORY_SEED:
        await db["search_history"].insert_many(SEARCH_HISTORY_SEED)
    if USER_BEHAVIOR_SEED:
        await db["user_behavior"].insert_many(USER_BEHAVIOR_SEED)

    print(f"Đã seed {len(SEARCH_HISTORY_SEED)} search_history "
          f"+ {len(USER_BEHAVIOR_SEED)} user_behavior vào MongoDB ({MONGODB_DB_NAME}).")
    client.close()


if __name__ == "__main__":
    asyncio.run(main())
