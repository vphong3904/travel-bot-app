import re
from dataclasses import dataclass


@dataclass
class IntentResult:
    intent: str
    confidence: float
    entities: dict


INTENT_PATTERNS = {
    "itinerary": [
        r"lịch trình", r"kế hoạch", r"itinerary", r"\d+\s*ngày", r"ngày\s*\d+\s*đêm",
        r"đi\s+\w+\s+\d+\s*ngày", r"lên\s+plan", r"thu\s+xếp\s+chuyến",
    ],
    "service_search": [
        r"khách sạn", r"homestay", r"resort", r"chỗ\s+nghỉ", r"book\s+phòng",
        r"tour", r"vé\s+tham quan", r"vé\s+", r"đặt\s+tour", r"tra\s+cứu\s+dịch vụ",
    ],
    "destination_advice": [
        r"nên\s+đi\s+đâu", r"gợi\s+ý\s+điểm", r"tư\s+vấn\s+điểm", r"đi\s+đâu\s+cho",
        r"phù\s+hợp", r"theo\s+ngân\s+sách", r"theo\s+sở\s+thích", r"biển\s+hay\s+núi",
        r"recommend", r"gợi\s+ý\s+địa\s+điểm",
    ],
    "faq_info": [
        r"thời\s+tiết", r"mùa\s+du\s+lịch", r"ẩm\s+thực", r"món\s+ăn", r"đặc\s+sản",
        r"chi\s+phí", r"giá", r"ngân\s+sách", r"kinh\s+nghiệm", r"tips", r"lưu\s+ý",
        r"di\s+chuyển", r"phương\s+tiện", r"thông\s+tin", r"có\s+gì\s+ở",
    ],
}

DESTINATIONS = ["đà lạt", "phú quốc", "hà giang", "hội an", "nha trang", "sa pa", "sapa", "đà nẵng", "ninh bình", "vũng tàu"]
BUDGET_KEYWORDS = {"tiết kiệm": "low", "rẻ": "low", "bình dân": "low", "tầm trung": "mid", "trung bình": "mid", "cao cấp": "high", "luxury": "high", "sang": "high"}
PREFERENCE_KEYWORDS = {"biển": "biển", "núi": "núi", "nghỉ dưỡng": "nghỉ dưỡng", "khám phá": "khám phá", "phiêu lưu": "khám phá", "gia đình": "gia đình", "cặp đôi": "cặp đôi", "solo": "solo"}
GROUP_KEYWORDS = {"gia đình": "gia đình", "cặp đôi": "cặp đôi", "solo": "solo", "nhóm bạn": "nhóm bạn", "một mình": "solo"}


def classify_intent(message: str) -> IntentResult:
    text = message.lower().strip()
    scores = {intent: 0.0 for intent in INTENT_PATTERNS}

    for intent, patterns in INTENT_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, text):
                scores[intent] += 1.0

    if max(scores.values()) == 0:
        best_intent = "faq_info"
        confidence = 0.5
    else:
        best_intent = max(scores, key=scores.get)
        confidence = min(0.95, 0.5 + scores[best_intent] * 0.15)

    entities = _extract_entities(text)
    return IntentResult(intent=best_intent, confidence=confidence, entities=entities)


def _extract_entities(text: str) -> dict:
    entities: dict = {}

    for dest in DESTINATIONS:
        if dest in text:
            entities["destination"] = dest.title().replace("Sapa", "Sa Pa")
            break

    duration_match = re.search(r"(\d+)\s*ngày\s*(\d+)?\s*đêm?", text)
    if duration_match:
        days = duration_match.group(1)
        nights = duration_match.group(2) or str(int(days) - 1)
        entities["duration"] = f"{days} ngày {nights} đêm"

    for kw, level in BUDGET_KEYWORDS.items():
        if kw in text:
            entities["budget"] = level
            break

    for kw, pref in PREFERENCE_KEYWORDS.items():
        if kw in text:
            entities["preference"] = pref
            break

    for kw, group in GROUP_KEYWORDS.items():
        if kw in text:
            entities["group"] = group
            break

    if "khách sạn" in text or "homestay" in text or "resort" in text:
        entities["service_type"] = "hotel"
    elif "tour" in text:
        entities["service_type"] = "tour"
    elif "vé" in text:
        entities["service_type"] = "ticket"

    return entities
