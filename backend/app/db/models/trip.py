from sqlalchemy import Column, String, Text, Integer, TIMESTAMP, Date, Time, ForeignKey, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid
from app.db.database import Base


class TripPlan(Base):
    __tablename__ = "trip_plans"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"))
    destination_id = Column(UUID(as_uuid=True), ForeignKey("destinations.id", ondelete="SET NULL"), nullable=True)
    title = Column(String(300))
    budget = Column(Integer)
    start_date = Column(Date)
    end_date = Column(Date)
    travelers = Column(Integer, default=1)
    travel_type = Column(String(50))
    status = Column(String(20), default="draft")
    ai_generated = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP(timezone=True))
    updated_at = Column(TIMESTAMP(timezone=True))

    items = relationship("TripPlanItem", back_populates="trip", cascade="all, delete-orphan")


class TripPlanItem(Base):
    __tablename__ = "trip_plan_items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_plan_id = Column(UUID(as_uuid=True), ForeignKey("trip_plans.id", ondelete="CASCADE"))
    day_number = Column(Integer, nullable=False)
    order_in_day = Column(Integer, default=0)
    title = Column(String(200))
    description = Column(Text)
    location_id = Column(UUID(as_uuid=True), ForeignKey("locations.id", ondelete="SET NULL"), nullable=True)
    start_time = Column(Time)
    end_time = Column(Time)
    estimated_cost = Column(Integer)
    notes = Column(Text)

    trip = relationship("TripPlan", back_populates="items")
