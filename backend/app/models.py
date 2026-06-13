# models.py
from sqlalchemy import (
    Column, Integer, String, Text, Boolean,
    Float, DateTime, func
)
from app.database import Base

class User(Base):
    __tablename__ = "users"
    id            = Column(Integer, primary_key=True, index=True)
    name          = Column(String(120), nullable=False)
    email         = Column(String(120), nullable=False, unique=True, index=True)
    password_hash = Column(String(255), nullable=False)
    role          = Column(String(20), default="user")
    is_active     = Column(Boolean, default=True)
    created_at    = Column(DateTime, server_default=func.now())

class Destination(Base):
    __tablename__ = "destinations"
    id          = Column(Integer, primary_key=True, index=True)
    name        = Column(String(100), nullable=False)
    region      = Column(String(100))
    description = Column(Text, nullable=False)
    highlights  = Column(Text)
    best_season = Column(String(100))
    weather     = Column(String(200))
    cuisine     = Column(Text)
    budget_low  = Column(Integer)
    budget_high = Column(Integer)
    tags        = Column(String(200))
    image_url   = Column(String(500))

class Hotel(Base):
    __tablename__ = "hotels"
    id             = Column(Integer, primary_key=True, index=True)
    name           = Column(String(200), nullable=False)
    destination    = Column(String(100), nullable=False)
    type           = Column(String(50))
    price_per_night= Column(Integer)
    rating         = Column(Float)
    address        = Column(String(300))
    amenities      = Column(String(300))

class Tour(Base):
    __tablename__ = "tours"
    id          = Column(Integer, primary_key=True, index=True)
    name        = Column(String(200), nullable=False)
    destination = Column(String(100), nullable=False)
    duration    = Column(String(50))
    price       = Column(Integer)
    description = Column(Text)
    includes    = Column(Text)

class Ticket(Base):
    __tablename__ = "tickets"
    id          = Column(Integer, primary_key=True, index=True)
    name        = Column(String(200), nullable=False)
    destination = Column(String(100), nullable=False)
    price       = Column(Integer)
    description = Column(Text)

class KnowledgeEntry(Base):
    __tablename__ = "knowledge_entries"
    id          = Column(Integer, primary_key=True, index=True)
    title       = Column(String(200), nullable=False)
    category    = Column(String(50), nullable=False)
    destination = Column(String(100))
    content     = Column(Text, nullable=False)
    tags        = Column(String(300))
    created_at  = Column(DateTime, server_default=func.now())
    updated_at  = Column(DateTime, server_default=func.now(), onupdate=func.now())

class ChatLog(Base):
    __tablename__ = "chat_logs"
    id          = Column(Integer, primary_key=True, index=True)
    session_id  = Column(Integer, nullable=True, index=True)
    user_id     = Column(Integer)
    user_name   = Column(String(120))
    message     = Column(Text, nullable=False)
    response    = Column(Text, nullable=False)
    intent      = Column(String(50))
    destination = Column(String(100))
    created_at  = Column(DateTime, server_default=func.now())

class PopularQuery(Base):
    __tablename__ = "popular_queries"
    id         = Column(Integer, primary_key=True, index=True)
    query_text = Column(String(300), nullable=False)
    count      = Column(Integer, default=1)
    intent     = Column(String(50))

class ChatSession(Base):
    """Một cuộc hội thoại (session) gồm nhiều tin nhắn."""
    __tablename__ = "chat_sessions"
 
    id          = Column(Integer, primary_key=True, index=True)
    user_id     = Column(Integer, nullable=False, index=True)
    user_name   = Column(String(120), nullable=False, default="Khách")
    title       = Column(String(300), nullable=True)   # auto-generated từ tin nhắn đầu
    summary     = Column(Text, nullable=True)          # tóm tắt ngắn (optional)
    created_at  = Column(DateTime, server_default=func.now())
    updated_at  = Column(DateTime, server_default=func.now(), onupdate=func.now())

class AiUsage(Base):
    """Đếm số lượt chat AI theo user/ngày, dùng cho rate limiting (FREE = 20/ngày)."""
    __tablename__ = "ai_usage"

    id      = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    date    = Column(String(10), nullable=False, index=True)  # 'YYYY-MM-DD' (UTC)
    count   = Column(Integer, default=0)
