from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.models import Destination, Hotel, KnowledgeEntry, Tour, Ticket
from app.services.intent_classifier import IntentResult
from app.services.rag_service import get_rag_service


async def generate_response(message: str, intent_result: IntentResult, db: AsyncSession) -> dict:
    intent = intent_result.intent
    entities = intent_result.entities

    rag = get_rag_service()
    context_docs = rag.retrieve(message, top_k=3)
    context_text = "\n".join(f"- {d['title']}: {d['content']}" for d in context_docs)

    if intent == "itinerary":
        return await _itinerary_response(message, entities, context_docs, db)
    if intent == "service_search":
        return await _service_response(message, entities, db)
    if intent == "destination_advice":
        return await _destination_advice_response(message, entities, context_docs, db)
    return await _faq_response(message, entities, context_docs, db, context_text)


async def _faq_response(message: str, entities: dict, context_docs: list, db: AsyncSession, context_text: str) -> dict:
    dest = entities.get("destination", "")
    if dest and not context_docs:
        result = await db.execute(select(Destination).where(Destination.name.ilike(f"%{dest}%")))
        dest_obj = result.scalar_one_or_none()
        if dest_obj:
            text = (
                f"📍 **{dest_obj.name}** ({dest_obj.region})\n\n"
                f"{dest_obj.description}\n\n"
                f"🌤️ **Thời tiết:** {dest_obj.weather}\n"
                f"📅 **Mùa du lịch lý tưởng:** {dest_obj.best_season}\n"
                f"🍜 **Ẩm thực:** {dest_obj.cuisine}\n"
                f"💰 **Chi phí tham khảo:** {dest_obj.budget_low:,} - {dest_obj.budget_high:,} VNĐ/người\n"
                f"⭐ **Điểm nổi bật:** {dest_obj.highlights}"
            )
            return {"text": text, "intent": "faq_info", "has_itinerary": False, "sources": [dest_obj.name]}

    if context_docs:
        main = context_docs[0]
        extra = ""
        if len(context_docs) > 1:
            extra = "\n\n📌 **Thông tin liên quan:**\n" + "\n".join(
                f"• {d['title']}" for d in context_docs[1:]
            )
        text = (
            f"🔍 *Dựa trên Knowledge Base (RAG):*\n\n"
            f"**{main['title']}**\n\n{main['content']}{extra}"
        )
        return {
            "text": text,
            "intent": "faq_info",
            "has_itinerary": False,
            "sources": [d["title"] for d in context_docs],
        }

    return {
        "text": "Xin lỗi, tôi chưa tìm thấy thông tin phù hợp trong Knowledge Base. "
                "Bạn có thể hỏi về địa điểm cụ thể như Đà Lạt, Phú Quốc, Hà Giang, Hội An...",
        "intent": "faq_info",
        "has_itinerary": False,
        "sources": [],
    }


async def _destination_advice_response(message: str, entities: dict, context_docs: list, db: AsyncSession) -> dict:
    budget = entities.get("budget")
    preference = entities.get("preference")

    q = select(Destination)
    if budget == "low":
        q = q.where(Destination.budget_low <= 3000000)
    elif budget == "high":
        q = q.where(Destination.budget_high >= 8000000)
    if preference:
        q = q.where(Destination.tags.ilike(f"%{preference}%"))
    q = q.limit(4)

    result = await db.execute(q)
    destinations = result.scalars().all()

    if not destinations:
        result = await db.execute(select(Destination).limit(4))
        destinations = result.scalars().all()

    lines = ["🎯 **Gợi ý điểm đến phù hợp với bạn:**\n"]
    for i, d in enumerate(destinations, 1):
        lines.append(
            f"**{i}. {d.name}** ({d.region})\n"
            f"   {d.description[:120]}...\n"
            f"   💰 {d.budget_low:,} - {d.budget_high:,} VNĐ | 📅 {d.best_season}\n"
        )

    if context_docs:
        lines.append(f"\n📚 *Tham khảo KB:* {context_docs[0]['title']}")

    return {
        "text": "\n".join(lines),
        "intent": "destination_advice",
        "has_itinerary": False,
        "destinations": [{"id": d.id, "name": d.name, "region": d.region, "image_url": d.image_url} for d in destinations],
        "sources": [d["title"] for d in context_docs],
    }


async def _service_response(message: str, entities: dict, db: AsyncSession) -> dict:
    dest = entities.get("destination", "")
    service_type = entities.get("service_type", "hotel")

    if service_type == "tour":
        q = select(Tour)
        if dest:
            q = q.where(Tour.destination.ilike(f"%{dest}%"))
        result = await db.execute(q.limit(5))
        results = result.scalars().all()
        if not results:
            return {"text": "Không tìm thấy tour phù hợp. Thử hỏi tour Phú Quốc hoặc Hà Giang.", "intent": "service_search", "has_itinerary": False, "services": []}
        lines = ["🚌 **Tour du lịch gợi ý:**\n"]
        for t in results:
            lines.append(f"• **{t.name}** ({t.destination}) - {t.duration}\n  💰 {t.price:,} VNĐ | {t.description}")
        return {"text": "\n".join(lines), "intent": "service_search", "has_itinerary": False, "services": [{"type": "tour", "name": t.name, "price": t.price} for t in results]}

    if service_type == "ticket":
        q = select(Ticket)
        if dest:
            q = q.where(Ticket.destination.ilike(f"%{dest}%"))
        result = await db.execute(q.limit(5))
        results = result.scalars().all()
        lines = ["🎫 **Vé tham quan:**\n"]
        for t in results:
            price_str = "Miễn phí" if t.price == 0 else f"{t.price:,} VNĐ"
            lines.append(f"• **{t.name}** ({t.destination}) - {price_str}\n  {t.description}")
        return {"text": "\n".join(lines), "intent": "service_search", "has_itinerary": False, "services": [{"type": "ticket", "name": t.name, "price": t.price} for t in results]}

    # default: hotel
    q = select(Hotel)
    if dest:
        q = q.where(Hotel.destination.ilike(f"%{dest}%"))
    result = await db.execute(q.limit(5))
    results = result.scalars().all()
    if not results:
        result = await db.execute(select(Hotel).limit(5))
        results = result.scalars().all()
    lines = ["🏨 **Khách sạn & Homestay gợi ý:**\n"]
    for h in results:
        lines.append(f"• **{h.name}** ({h.type}) - {h.destination}\n  ⭐ {h.rating} | 💰 {h.price_per_night:,} VNĐ/đêm\n  📍 {h.address}")
    return {"text": "\n".join(lines), "intent": "service_search", "has_itinerary": False, "services": [{"type": "hotel", "name": h.name, "price": h.price_per_night} for h in results]}


async def _itinerary_response(message: str, entities: dict, context_docs: list, db: AsyncSession) -> dict:
    dest_name = entities.get("destination", "Phú Quốc")
    duration = entities.get("duration", "3 ngày 2 đêm")
    group = entities.get("group", "gia đình")

    result = await db.execute(
        select(Destination).where(Destination.name.ilike(f"%{dest_name.split()[0]}%"))
    )
    dest_obj = result.scalar_one_or_none()
    dest_display = dest_obj.name if dest_obj else dest_name.title()

    itinerary_doc = next((d for d in context_docs if d.get("category") == "itinerary"), None)
    plan_content = itinerary_doc["content"] if itinerary_doc else _default_itinerary(dest_display, duration, group)

    budget_note = ""
    if dest_obj:
        budget_note = f"\n\n💡 **Chi phí dự kiến:** {dest_obj.budget_low:,} - {dest_obj.budget_high:,} VNĐ/người"

    text = (
        f"✨ **Lịch trình {dest_display} - {duration}** (Nhóm: {group})\n\n"
        f"*Truy xuất từ Knowledge Base qua RAG*\n\n"
        f"{plan_content}{budget_note}\n\n"
        f"Nhấn **Xem Lịch Trình Chi Tiết** để xem bản đầy đủ!"
    )

    days = _parse_itinerary_days(plan_content, dest_display, duration, group)

    return {
        "text": text,
        "intent": "itinerary",
        "has_itinerary": True,
        "itinerary": {
            "destination": dest_display,
            "duration": duration,
            "group": group,
            "days": days,
            "budget_low": dest_obj.budget_low if dest_obj else 3000000,
            "budget_high": dest_obj.budget_high if dest_obj else 8000000,
        },
        "sources": [d["title"] for d in context_docs],
    }


# ── Helpers thuần Python, không dùng db → giữ sync ───────────────────────────

def _default_itinerary(dest: str, duration: str, group: str) -> str:
    return (
        f"Ngày 1: Di chuyển đến {dest}, check-in, khám phá khu vực trung tâm.\n"
        f"Ngày 2: Tham quan các điểm nổi bật, trải nghiệm ẩm thực địa phương.\n"
        f"Ngày 3: Mua sắm quà lưu niệm, trả phòng, về."
    )


def _parse_itinerary_days(content: str, dest: str, duration: str, group: str) -> list:
    import re

    days = []
    parts = re.split(r"Ngày\s*(\d+)[:\.]?", content)
    if len(parts) > 2:
        for i in range(1, len(parts), 2):
            day_num = parts[i]
            day_content = parts[i + 1].strip() if i + 1 < len(parts) else ""
            activities = [a.strip() for a in re.split(r"[-•]\s*", day_content) if a.strip()]
            days.append({"day": int(day_num), "title": f"Ngày {day_num}", "activities": activities})
    else:
        days = [
            {"day": 1, "title": "Ngày 1: Khởi hành", "activities": [f"Di chuyển đến {dest}", "Check-in & nghỉ ngơi"]},
            {"day": 2, "title": "Ngày 2: Khám phá", "activities": ["Tham quan điểm nổi bật", "Ẩm thực địa phương"]},
            {"day": 3, "title": "Ngày 3: Kết thúc", "activities": ["Mua quà lưu niệm", "Trả phòng & về"]},
        ]
    return days