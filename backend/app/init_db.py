import bcrypt
from sqlalchemy.orm import Session

from app.database import Base, SessionLocal, engine
from app.models import ChatLog, Destination, Hotel, KnowledgeEntry, PopularQuery, Ticket, Tour, User
from app.seed_data import DESTINATIONS, HOTELS, KNOWLEDGE_ENTRIES, TICKETS, TOURS, USERS
from app.services.rag_service import get_rag_service


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def init_db():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if db.query(Destination).count() == 0:
            for d in DESTINATIONS:
                db.add(Destination(**d))
            for kb in KNOWLEDGE_ENTRIES:
                db.add(KnowledgeEntry(**kb))
            for h in HOTELS:
                db.add(Hotel(**h))
            for t in TOURS:
                db.add(Tour(**t))
            for tk in TICKETS:
                db.add(Ticket(**tk))
            for u in USERS:
                db.add(User(
                    name=u["name"],
                    email=u["email"],
                    password_hash=hash_password(u["password"]),
                    role=u["role"],
                ))
            db.commit()

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
        rag = get_rag_service()
        rag.initialize(docs)
    finally:
        db.close()


def log_chat(db: Session, user_id: int, user_name: str, message: str, response: str, intent: str, destination: str = ""):
    db.add(ChatLog(
        user_id=user_id,
        user_name=user_name,
        message=message,
        response=response,
        intent=intent,
        destination=destination,
    ))

    existing = db.query(PopularQuery).filter(PopularQuery.query_text == message[:300]).first()
    if existing:
        existing.count += 1
    else:
        db.add(PopularQuery(query_text=message[:300], intent=intent))
    db.commit()
