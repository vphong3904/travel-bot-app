from sqlalchemy.orm import Session

from app.models import Destination, Hotel, KnowledgeEntry, Tour, Ticket
from app.services.intent_classifier import IntentResult
from app.services.rag_service import get_rag_service


def generate_response(message: str, intent_result: IntentResult, db: Session) -> dict:
    intent = intent_result.intent
    entities = intent_result.entities

    rag = get_rag_service()
    context_docs = rag.retrieve(message, top_k=3)
    context_text = "\n".join(f"- {d['title']}: {d['content']}" for d in context_docs)

    if intent == "itinerary":
        return _itinerary_response(message, entities, context_docs, db)
    if intent == "service_search":
        return _service_response(message, entities, db)
    if intent == "destination_advice":
        return _destination_advice_response(message, entities, context_docs, db)
    return _faq_response(message, entities, context_docs, db, context_text)


def _faq_response(message: str, entities: dict, context_docs: list, db: Session, context_text: str) -> dict:
    dest = entities.get("destination", "")
    if dest and not context_docs:
        dest_obj = db.query(Destination).filter(Destination.name.ilike(f"%{dest}%")).first()
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


def _destination_advice_response(message: str, entities: dict, context_docs: list, db: Session) -> dict:
    query = db.query(Destination)
    budget = entities.get("budget")
    preference = entities.get("preference")

    if budget == "low":
        query = query.filter(Destination.budget_low <= 3000000)
    elif budget == "high":
        query = query.filter(Destination.budget_high >= 8000000)

    if preference:
        query = query.filter(Destination.tags.ilike(f"%{preference}%"))

    destinations = query.limit(4).all()
    if not destinations:
        destinations = db.query(Destination).limit(4).all()

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


def _service_response(message: str, entities: dict, db: Session) -> dict:
    dest = entities.get("destination", "")
    service_type = entities.get("service_type", "hotel")

    if service_type == "tour":
        items = db.query(Tour)
        if dest:
            items = items.filter(Tour.destination.ilike(f"%{dest}%"))
        results = items.limit(5).all()
        if not results:
            return {"text": "Không tìm thấy tour phù hợp. Thử hỏi tour Phú Quốc hoặc Hà Giang.", "intent": "service_search", "has_itinerary": False, "services": []}
        lines = ["🚌 **Tour du lịch gợi ý:**\n"]
        for t in results:
            lines.append(f"• **{t.name}** ({t.destination}) - {t.duration}\n  💰 {t.price:,} VNĐ | {t.description}")
        return {"text": "\n".join(lines), "intent": "service_search", "has_itinerary": False, "services": [{"type": "tour", "name": t.name, "price": t.price} for t in results]}

    if service_type == "ticket":
        items = db.query(Ticket)
        if dest:
            items = items.filter(Ticket.destination.ilike(f"%{dest}%"))
        results = items.limit(5).all()
        lines = ["🎫 **Vé tham quan:**\n"]
        for t in results:
            price_str = "Miễn phí" if t.price == 0 else f"{t.price:,} VNĐ"
            lines.append(f"• **{t.name}** ({t.destination}) - {price_str}\n  {t.description}")
        return {"text": "\n".join(lines), "intent": "service_search", "has_itinerary": False, "services": [{"type": "ticket", "name": t.name, "price": t.price} for t in results]}

    items = db.query(Hotel)
    if dest:
        items = items.filter(Hotel.destination.ilike(f"%{dest}%"))
    results = items.limit(5).all()
    if not results:
        results = db.query(Hotel).limit(5).all()
    lines = ["🏨 **Khách sạn & Homestay gợi ý:**\n"]
    for h in results:
        lines.append(f"• **{h.name}** ({h.type}) - {h.destination}\n  ⭐ {h.rating} | 💰 {h.price_per_night:,} VNĐ/đêm\n  📍 {h.address}")
    return {"text": "\n".join(lines), "intent": "service_search", "has_itinerary": False, "services": [{"type": "hotel", "name": h.name, "price": h.price_per_night} for h in results]}


def _itinerary_response(message: str, entities: dict, context_docs: list, db: Session) -> dict:
    dest_name = entities.get("destination", "Phú Quốc")
    duration = entities.get("duration", "3 ngày 2 đêm")
    group = entities.get("group", "gia đình")

    dest_obj = db.query(Destination).filter(Destination.name.ilike(f"%{dest_name.split()[0]}%")).first()
    dest_display = dest_obj.name if dest_obj else dest_name.title()

    itinerary_doc = next((d for d in context_docs if d.get("category") == "itinerary"), None)
    if itinerary_doc:
        plan_content = itinerary_doc["content"]
    else:
        plan_content = _default_itinerary(dest_display, duration, group)

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
