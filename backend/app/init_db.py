import bcrypt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.database import Base, SessionLocal, engine
from app.models import (
    ChatLog, Destination, Hotel, KnowledgeEntry,
    PopularQuery, Ticket, Tour, User
)

from app.seed_data import DESTINATIONS, HOTELS, KNOWLEDGE_ENTRIES, TICKETS, TOURS, USERS
from app.services.rag_service import get_rag_service
# chạy trong backend/, với venv đã activate
from app import models  # noqa: import để đăng ký model

def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def init_db():
    """
    Sync — chỉ chạy 1 lần lúc startup, dùng SessionLocal trực tiếp.
    Tạo bảng, seed dữ liệu từ seed_data + KB, khởi tạo RAG index.
    """
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # Seed nếu DB trống
        if db.query(Destination).count() == 0:
            # Destinations
            for d in DESTINATIONS:
                db.add(Destination(**d))

            # Knowledge Entries (KB)
            for kb in KNOWLEDGE_ENTRIES:
                db.add(KnowledgeEntry(**kb))

                # Đồng bộ KB sang Destination/Hotel/Tour nếu phù hợp
                cat = kb.get("category", "")
                dest = kb.get("destination", "")
                if cat == "destination_info":
                    db.add(Destination(
                        name=dest or kb["title"],
                        region="",
                        description=kb["content"],
                        budget_low=0,
                        budget_high=0,
                        tags=kb["tags"],
                        best_season="",
                        image_url=""
                    ))
                elif cat == "hotel":
                    db.add(Hotel(
                        name=kb["title"],
                        destination=dest,
                        type="",
                        price_per_night=0,
                        rating=0,
                        amenities=kb["tags"]
                    ))
                elif cat in ["itinerary", "transport"]:
                    db.add(Tour(
                        name=kb["title"],
                        destination=dest,
                        duration="",
                        price=0,
                        description=kb["content"],
                        includes=kb["tags"]
                    ))

            # Hotels
            for h in HOTELS:
                db.add(Hotel(**h))

            # Tours
            for t in TOURS:
                db.add(Tour(**t))

            # Tickets
            for tk in TICKETS:
                db.add(Ticket(**tk))

            # Users
            for u in USERS:
                db.add(User(
                    name=u["name"],
                    email=u["email"],
                    password_hash=hash_password(u["password"]),
                    role=u["role"],
                ))

            db.commit()

        # Đồng bộ KB mới nếu backend đã seed trước đó
        existing_kb_titles = {e.title for e in db.query(KnowledgeEntry).all()}
        added_new_kb = False
        for kb in KNOWLEDGE_ENTRIES:
            if kb["title"] in existing_kb_titles:
                continue
            db.add(KnowledgeEntry(**kb))
            added_new_kb = True

            cat = kb.get("category", "")
            dest = kb.get("destination", "")
            if cat == "destination_info":
                db.add(Destination(
                    name=dest or kb["title"],
                    region="",
                    description=kb["content"],
                    budget_low=0,
                    budget_high=0,
                    tags=kb["tags"],
                    best_season="",
                    image_url=""
                ))
            elif cat == "hotel":
                db.add(Hotel(
                    name=kb["title"],
                    destination=dest,
                    type="",
                    price_per_night=0,
                    rating=0,
                    amenities=kb["tags"]
                ))
            elif cat in ["itinerary", "transport"]:
                db.add(Tour(
                    name=kb["title"],
                    destination=dest,
                    duration="",
                    price=0,
                    description=kb["content"],
                    includes=kb["tags"]
                ))

        if added_new_kb:
            db.commit()

        # Khởi tạo RAG index từ KnowledgeEntry
        kb_entries = db.query(KnowledgeEntry).all()
        docs = [
            {
                "id": e.id,
                "title": e.title,
                "content": e.content,
                "category": e.category,
                "destination": e.destination,
                "tags": e.tags,
            }
            for e in kb_entries
        ]
        get_rag_service().initialize(docs)
    finally:
        db.close()


async def log_chat(
    db,
    user_id: int,
    user_name: str,
    message: str,
    response: str,
    intent: str,
    destination: str,
    session_id: int | None = None,   # ← THÊM tham số này
):
    from app.models import ChatLog, PopularQuery
    from sqlalchemy.future import select
 
    log = ChatLog(
        session_id=session_id,        # ← lưu session_id
        user_id=user_id,
        user_name=user_name,
        message=message,
        response=response,
        intent=intent or "",
        destination=destination or "",
    )
    db.add(log)
 
    # Cập nhật popular queries (giữ nguyên logic cũ)
    result = await db.execute(
        select(PopularQuery).where(PopularQuery.query_text == message[:300])
    )
    existing = result.scalar_one_or_none()
    if existing:
        existing.count += 1
    else:
        db.add(PopularQuery(query_text=message[:300], intent=intent or "", count=1))
 
    await db.commit()
