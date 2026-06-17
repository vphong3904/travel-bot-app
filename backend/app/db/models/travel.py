from sqlalchemy import Column, String, Text, Integer, TIMESTAMP, Boolean, ForeignKey, DECIMAL, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from sqlalchemy.orm import relationship
import uuid
from app.db.database import Base

class Destination(Base):
    __tablename__ = "destinations"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(200), nullable=False)
    province = Column(String(100))
    region = Column(String(50))
    description = Column(Text)
    best_season = Column(String(200))
    weather = Column(Text)
    cuisine = Column(Text)
    budget_low = Column(Integer)
    budget_high = Column(Integer)
    image_url = Column(Text)
    special = Column(Text)

    # ranking / social stats
    rating_avg = Column(DECIMAL(2, 1), default=0)
    review_count = Column(Integer, default=0)
    favorite_count = Column(Integer, default=0)
    view_count = Column(Integer, default=0)

    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))

    categories = relationship(
        "Category",
        secondary="destination_categories",
        back_populates="destinations",
    )
    reviews = relationship("Review", back_populates="destination", cascade="all, delete-orphan")
    favorites = relationship("UserFavorite", back_populates="destination", cascade="all, delete-orphan")


class Review(Base):
    __tablename__ = "reviews"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"), nullable=False)
    rating = Column(Integer, nullable=False)   # 1-5
    content = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True))

    destination = relationship("Destination", back_populates="reviews")
    user = relationship("User")


class UserFavorite(Base):
    __tablename__ = "user_favorites"

    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"), primary_key=True)
    created_at = Column(TIMESTAMP(timezone=True))

    destination = relationship("Destination", back_populates="favorites")
    user = relationship("User")

class Location(Base):
    __tablename__ = "locations"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"))
    name = Column(String(200), nullable=False)
    type = Column(String(50))
    address = Column(Text)
    lat = Column(DECIMAL(10,7))
    lng = Column(DECIMAL(10,7))
    hours = Column(String(200))
    description = Column(Text)
    tips = Column(Text)
    image_url = Column(Text)
    rating_avg = Column(DECIMAL(3,2), default=0)
    review_count = Column(Integer, default=0)
    verified = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))

class Hotel(Base):
    __tablename__ = "hotels"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"))
    name = Column(String(200), nullable=False)
    type = Column(String(50))
    stars = Column(Integer)
    price_per_night = Column(Integer)
    address = Column(Text)
    amenities = Column(ARRAY(Text))
    description = Column(Text)
    image_url = Column(Text)
    rating = Column(DECIMAL(3,2), default=0)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))

class Tour(Base):
    __tablename__ = "tours"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"))
    name = Column(String(200), nullable=False)
    duration = Column(String(50))
    price = Column(Integer)
    group_size = Column(String(50))
    description = Column(Text)
    includes = Column(ARRAY(Text))
    excludes = Column(ARRAY(Text))
    image_url = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))

class Ticket(Base):
    __tablename__ = "tickets"
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"))
    location_id = Column(UUID(as_uuid=True), ForeignKey("locations.id", ondelete="SET NULL"))
    name = Column(String(200), nullable=False)
    price_adult = Column(Integer)
    price_child = Column(Integer)
    description = Column(Text)
    hours = Column(String(200))
    created_at = Column(TIMESTAMP(timezone=True))


class TransportOption(Base):
    __tablename__ = "transport_options"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"))
    type = Column(String(50))        # xe máy, taxi, xe buýt, tàu hỏa...
    is_local = Column(Boolean, default=True)  # True=nội đô, False=đến địa điểm
    price_info = Column(Text)
    duration = Column(String(100))
    provider = Column(String(200))
    notes = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True))


class DestinationEvent(Base):
    __tablename__ = "destination_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"))
    name = Column(String(200), nullable=False)
    event_date = Column(String(100))
    location_text = Column(Text)
    cost = Column(String(100))
    description = Column(Text)
    created_at = Column(TIMESTAMP(timezone=True))


class Category(Base):
    __tablename__ = "categories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(100), nullable=False, unique=True)
    slug = Column(String(100), nullable=False, unique=True)
    icon = Column(String(100))
    description = Column(Text)
    is_active = Column(Boolean, default=True)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))

    destinations = relationship(
        "Destination",
        secondary="destination_categories",
        back_populates="categories",
    )


class DestinationCategory(Base):
    __tablename__ = "destination_categories"

    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"), primary_key=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id", ondelete="CASCADE"), primary_key=True)
    created_at = Column(TIMESTAMP(timezone=True))


class ShoppingPlace(Base):
    __tablename__ = "shopping_places"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="CASCADE"))
    name = Column(String(200), nullable=False)
    type = Column(String(50))
    items = Column(ARRAY(Text))
    address = Column(Text)
    opening_hours = Column(String(200))
    price_range = Column(String(100))
    created_at = Column(TIMESTAMP(timezone=True))
