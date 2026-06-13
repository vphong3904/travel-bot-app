# import_kb_to_db.py
# ============================================================
#  Convert KNOWLEDGE_ENTRIES thành record trong DB
# ============================================================

from app.models import Destination, Hotel, Tour
from app.seed_data import KNOWLEDGE_ENTRIES
from sqlalchemy.ext.asyncio import AsyncSession

async def import_kb_to_db(db: AsyncSession):
    for entry in KNOWLEDGE_ENTRIES:
        cat = entry.get("category", "")
        dest = entry.get("destination", "")
        title = entry.get("title", "")
        content = entry.get("content", "")
        tags = entry.get("tags", "")

        # Destination info
        if cat in ["destination_info", "weather", "budget", "cuisine", "tips"]:
            db.add(Destination(
                name=dest or title,
                region="",
                description=content,
                budget_low=0,
                budget_high=0,
                tags=tags,
                best_season="",
                image_url=""
            ))

        # Hotels
        elif cat == "hotel":
            db.add(Hotel(
                name=title,
                destination=dest,
                type="",
                price_per_night=0,
                rating=0,
                amenities=tags
            ))

        # Tours / Itinerary
        elif cat == "itinerary":
            db.add(Tour(
                name=title,
                destination=dest,
                duration="",
                price=0,
                description=content,
                includes=tags
            ))

        # Transport → có thể lưu vào Tour hoặc Destination tuỳ bạn
        elif cat == "transport":
            db.add(Tour(
                name=title,
                destination=dest,
                duration="",
                price=0,
                description=content,
                includes=tags
            ))

    await db.commit()
    print("✅ Import KB vào DB thành công!")
