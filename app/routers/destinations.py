from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Destination, Hotel, Ticket, Tour
from app.schemas import DestinationResponse, HotelResponse, TicketResponse, TourResponse

router = APIRouter(prefix="/destinations", tags=["Destinations"])


@router.get("", response_model=list[DestinationResponse])
def list_destinations(
    tag: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Destination)
    if tag:
        query = query.filter(Destination.tags.ilike(f"%{tag}%"))
    if search:
        query = query.filter(
            Destination.name.ilike(f"%{search}%") | Destination.description.ilike(f"%{search}%")
        )
    return query.all()


@router.get("/{dest_id}", response_model=DestinationResponse)
def get_destination(dest_id: int, db: Session = Depends(get_db)):
    dest = db.query(Destination).filter(Destination.id == dest_id).first()
    if not dest:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Không tìm thấy địa điểm")
    return dest


services_router = APIRouter(prefix="/services", tags=["Services"])


@services_router.get("/hotels", response_model=list[HotelResponse])
def list_hotels(destination: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Hotel)
    if destination:
        query = query.filter(Hotel.destination.ilike(f"%{destination}%"))
    return query.all()


@services_router.get("/tours", response_model=list[TourResponse])
def list_tours(destination: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Tour)
    if destination:
        query = query.filter(Tour.destination.ilike(f"%{destination}%"))
    return query.all()


@services_router.get("/tickets", response_model=list[TicketResponse])
def list_tickets(destination: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Ticket)
    if destination:
        query = query.filter(Ticket.destination.ilike(f"%{destination}%"))
    return query.all()


@services_router.get("/search")
def search_services(
    q: str = Query(""),
    type: Optional[str] = None,
    destination: Optional[str] = None,
    db: Session = Depends(get_db),
):
    results = {"hotels": [], "tours": [], "tickets": []}
    if type in (None, "hotel"):
        hq = db.query(Hotel)
        if destination:
            hq = hq.filter(Hotel.destination.ilike(f"%{destination}%"))
        if q:
            hq = hq.filter(Hotel.name.ilike(f"%{q}%"))
        results["hotels"] = [HotelResponse.model_validate(h) for h in hq.limit(10).all()]
    if type in (None, "tour"):
        tq = db.query(Tour)
        if destination:
            tq = tq.filter(Tour.destination.ilike(f"%{destination}%"))
        if q:
            tq = tq.filter(Tour.name.ilike(f"%{q}%"))
        results["tours"] = [TourResponse.model_validate(t) for t in tq.limit(10).all()]
    if type in (None, "ticket"):
        tkq = db.query(Ticket)
        if destination:
            tkq = tkq.filter(Ticket.destination.ilike(f"%{destination}%"))
        if q:
            tkq = tkq.filter(Ticket.name.ilike(f"%{q}%"))
        results["tickets"] = [TicketResponse.model_validate(t) for t in tkq.limit(10).all()]
    return results
