from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, Float, Integer, String, Text

from app.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(120), nullable=False)
    email = Column(String(120), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(20), default="user")  # user | admin
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class KnowledgeEntry(Base):
    __tablename__ = "knowledge_entries"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), nullable=False)
    category = Column(String(50), nullable=False)
    destination = Column(String(100), default="")
    content = Column(Text, nullable=False)
    tags = Column(String(300), default="")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class Destination(Base):
    __tablename__ = "destinations"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    region = Column(String(100), default="")
    description = Column(Text, nullable=False)
    highlights = Column(Text, default="")
    best_season = Column(String(100), default="")
    weather = Column(String(200), default="")
    cuisine = Column(Text, default="")
    budget_low = Column(Integer, default=2000000)
    budget_high = Column(Integer, default=8000000)
    tags = Column(String(200), default="")
    image_url = Column(String(500), default="")


class Hotel(Base):
    __tablename__ = "hotels"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    destination = Column(String(100), nullable=False)
    type = Column(String(50), default="hotel")
    price_per_night = Column(Integer, default=0)
    rating = Column(Float, default=4.0)
    address = Column(String(300), default="")
    amenities = Column(String(300), default="")


class Tour(Base):
    __tablename__ = "tours"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    destination = Column(String(100), nullable=False)
    duration = Column(String(50), default="1 ngày")
    price = Column(Integer, default=0)
    description = Column(Text, default="")
    includes = Column(Text, default="")


class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(200), nullable=False)
    destination = Column(String(100), nullable=False)
    price = Column(Integer, default=0)
    description = Column(Text, default="")


class ChatLog(Base):
    __tablename__ = "chat_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, default=0)
    user_name = Column(String(120), default="Khách")
    message = Column(Text, nullable=False)
    response = Column(Text, nullable=False)
    intent = Column(String(50), default="")
    destination = Column(String(100), default="")
    created_at = Column(DateTime, default=datetime.utcnow)


class PopularQuery(Base):
    __tablename__ = "popular_queries"

    id = Column(Integer, primary_key=True, index=True)
    query_text = Column(String(300), nullable=False)
    count = Column(Integer, default=1)
    intent = Column(String(50), default="")
