# app/services/intent_classifier.py
# ============================================================
#  Intent Classifier — phát hiện ý định từ câu hỏi tiếng Việt
# ============================================================

from __future__ import annotations
from dataclasses import dataclass
import re


@dataclass
class IntentResult:
    intent: str
    confidence: float
    destination: str = ""
    extra: dict = None

    def __post_init__(self):
        if self.extra is None:
            self.extra = {}


# Danh sách điểm đến được nhận diện
KNOWN_DESTINATIONS = [
    "đà lạt", "dalat", "da lat",
    "phú quốc", "phu quoc",
    "hội an", "hoi an",
    "hà giang", "ha giang",
    "sa pa", "sapa",
    "đà nẵng", "da nang",
    "hạ long", "ha long",
    "nha trang",
    "hà nội", "ha noi",
    "hồ chí minh", "sài gòn", "saigon", "tphcm",
    "huế", "hue",
    "ninh bình", "ninh binh",
    "quy nhơn", "quy nhon",
    "phú yên", "phu yen",
    "côn đảo", "con dao",
    "vũng tàu", "vung tau",
    "mũi né", "mui ne",
    "bến tre", "ben tre",
    "mù cang chải", "mu cang chai",
]

# Ánh xạ intent → danh sách keyword
INTENT_PATTERNS: dict[str, list[str]] = {
    "weather": [
        "thời tiết", "khí hậu", "mưa", "nắng", "mùa", "lạnh", "nóng",
        "tháng mấy", "khi nào đẹp", "mùa du lịch", "mùa mưa", "mùa khô",
        "nhiệt độ", "sương mù", "lúa chín",
    ],
    "budget": [
        "chi phí", "bao nhiêu tiền", "ngân sách", "giá cả", "tốn bao nhiêu",
        "hết bao nhiêu", "tiết kiệm", "rẻ", "giá tour", "giá vé", "chi tiêu", "tiền",
    ],
    "cuisine": [
        "ăn gì", "ẩm thực", "món ngon", "đặc sản", "quán ăn", "nhà hàng",
        "đồ ăn", "hải sản", "thức uống", "bánh", "phở", "bún",
    ],
    "itinerary": [
        "lịch trình", "hành trình", "ngày mấy", "mấy ngày", "kế hoạch",
        "đi những đâu", "gợi ý đi", "tour mấy ngày", "2 ngày", "3 ngày",
        "4 ngày", "1 tuần",
    ],
    "hotel": [
        "khách sạn", "homestay", "resort", "nơi ở", "chỗ ở", "nhà nghỉ",
        "villa", "glamping", "đặt phòng", "phòng",
    ],
    "transport": [
        "di chuyển", "phương tiện", "xe máy", "ô tô", "máy bay", "tàu hỏa",
        "xe khách", "cách đi", "đường đi", "vé", "giá vé", "vé tham quan", "ticket", "bus", "grab",
    ],
    "tips": [
        "kinh nghiệm", "lưu ý", "tips", "cần biết", "nên", "không nên",
        "chú ý", "lời khuyên", "bí quyết", "chuẩn bị",
    ],
    "recommendation": [
        "gợi ý", "đề xuất", "nên đi đâu", "điểm đến", "địa điểm nào",
        "nơi nào đẹp", "chỗ nào hay", "muốn đi", "thích biển", "thích núi",
        "đi biển", "đi chơi", "đi đâu", "du lịch biển", "du lịch núi",
    ],
    "visa": [
        "visa", "hộ chiếu", "nhập cảnh", "e-visa", "xuất cảnh", "thị thực",
        "giấy tờ", "passport",
    ],
    "greeting": [
        "xin chào", "hello", "hi", "chào", "alo", "hey",
    ],
}

# intent_classifier.py

# Định nghĩa mapping một lần
_MAP = str.maketrans({
    "à": "a", "á": "a", "ạ": "a", "ả": "a", "ã": "a",
    "â": "a", "ầ": "a", "ấ": "a", "ậ": "a", "ẩ": "a", "ẫ": "a",
    "ă": "a", "ằ": "a", "ắ": "a", "ặ": "a", "ẳ": "a", "ẵ": "a",
    "è": "e", "é": "e", "ẹ": "e", "ẻ": "e", "ẽ": "e",
    "ê": "e", "ề": "e", "ế": "e", "ệ": "e", "ể": "e", "ễ": "e",
    "ì": "i", "í": "i", "ị": "i", "ỉ": "i", "ĩ": "i",
    "ò": "o", "ó": "o", "ọ": "o", "ỏ": "o", "õ": "o",
    "ô": "o", "ồ": "o", "ố": "o", "ộ": "o", "ổ": "o", "ỗ": "o",
    "ơ": "o", "ờ": "o", "ớ": "o", "ợ": "o", "ở": "o", "ỡ": "o",
    "ù": "u", "ú": "u", "ụ": "u", "ủ": "u", "ũ": "u",
    "ư": "u", "ừ": "u", "ứ": "u", "ự": "u", "ử": "u", "ữ": "u",
    "ỳ": "y", "ý": "y", "ỵ": "y", "ỷ": "y", "ỹ": "y",
    "đ": "d"
})

def _normalize(text: str) -> str:
    text = text.lower().strip()
    return text.translate(_MAP)


def _detect_destination(text_lower: str) -> str:
    """Trả về tên điểm đến (viết hoa chuẩn) nếu tìm thấy trong câu."""
    CANONICAL = {
        "da lat": "Đà Lạt", "dalat": "Đà Lạt",
        "phu quoc": "Phú Quốc",
        "hoi an": "Hội An",
        "ha giang": "Hà Giang",
        "sapa": "Sa Pa", "sa pa": "Sa Pa",
        "da nang": "Đà Nẵng",
        "ha long": "Hạ Long",
        "nha trang": "Nha Trang",
        "ha noi": "Hà Nội",
        "saigon": "TP. Hồ Chí Minh", "sai gon": "TP. Hồ Chí Minh",
        "hue": "Huế",
        "ninh binh": "Ninh Bình",
        "quy nhon": "Quy Nhơn",
        "phu yen": "Phú Yên",
        "con dao": "Côn Đảo",
        "vung tau": "Vũng Tàu",
        "mui ne": "Mũi Né",
        "ben tre": "Bến Tre",
    }
    norm = _normalize(text_lower)
    for key, canonical in CANONICAL.items():
        if key in norm:
            return canonical
    return ""


def classify_intent(message: str) -> IntentResult:
    """
    Phân loại ý định từ câu hỏi tiếng Việt.
    Trả về IntentResult với intent, confidence, destination.
    """
    lower = message.lower()
    norm = _normalize(lower)
    destination = _detect_destination(lower)

    scores: dict[str, int] = {}
    for intent, keywords in INTENT_PATTERNS.items():
        score = 0
        for kw in keywords:
            kw_norm = _normalize(kw)
            if kw_norm in norm:
                score += 2 if len(kw) > 6 else 1
        if score > 0:
            scores[intent] = score

    if not scores:
        return IntentResult(
            intent="general",
            confidence=0.5,
            destination=destination,
        )

    best_intent = max(scores, key=lambda k: scores[k])
    total = sum(scores.values())
    confidence = round(min(scores[best_intent] / max(total, 1), 1.0), 2)

    return IntentResult(
        intent=best_intent,
        confidence=confidence,
        destination=destination,
    )