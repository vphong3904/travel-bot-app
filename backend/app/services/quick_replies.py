"""
quick_replies.py — Trả lời TỨC THÌ cho câu hỏi quen thuộc/meta, KHÔNG gọi Gemini
và không cần embedding. Tiết kiệm quota + phản hồi <50ms.

Dùng cho:
  - Câu hỏi về chính bot ("bạn là ai", "giúp được gì", "dùng thế nào").
  - Cảm ơn / xã giao ngắn.
  - Vài câu FAQ chung rất phổ biến không phụ thuộc thành phố (sim, đổi tiền, an toàn).

Khớp theo cụm từ KHÔNG DẤU (robust với gõ thiếu dấu). Mỗi rule: nếu BẤT KỲ
trigger nào là substring của câu hỏi (đã bỏ dấu) → trả answer.

Câu hỏi du lịch theo thành phố (điểm đến/khách sạn/ăn uống...) KHÔNG nằm ở đây —
chúng đi qua RAG (structured + KB) để trả dữ liệu thật.
"""

from __future__ import annotations

from typing import Optional

from app.services.nlp_preprocessor import _remove_accents


def _norm(text: str) -> str:
    return _remove_accents(text or "").lower().strip()


# (triggers không dấu, câu trả lời). Thứ tự = độ ưu tiên.
_RULES: list[tuple[list[str], str]] = [
    (
        ["ban la ai", "ban ten gi", "ban la chatbot", "gioi thieu ban than",
         "ban la gi", "may la ai"],
        "Mình là **PDTrip AI** — trợ lý du lịch Việt Nam. Mình giúp bạn tìm điểm "
        "tham quan, khách sạn, ẩm thực, mua sắm, tour, cách di chuyển và gợi ý lịch "
        "trình cho 63 tỉnh/thành. Bạn muốn khám phá nơi nào?",
    ),
    (
        ["lam duoc gi", "giup duoc gi", "giup gi duoc", "chuc nang", "ho tro gi",
         "ban biet gi", "dung the nao", "dung nhu the nao", "huong dan su dung",
         "co the lam gi"],
        "Mình có thể giúp bạn:\n"
        "- Điểm tham quan & trải nghiệm\n"
        "- Khách sạn / lưu trú\n"
        "- Ẩm thực & nhà hàng\n"
        "- Mua sắm, chợ, đặc sản\n"
        "- Tour & cách di chuyển\n"
        "- Gợi ý lịch trình theo sở thích\n\n"
        "Cứ hỏi kiểu “Đà Lạt có gì chơi?”, “khách sạn cặp đôi ở Đà Lạt”, "
        "“ăn gì ở Huế?” nhé!",
    ),
    (
        ["cam on", "cam ban", "thanks", "thank you", "tks", "cam o n", "thén kiu", "thank u", "ok thanks", "ok thank you", "ok ban"],
        "Không có gì, chúc bạn có chuyến đi thật vui! Cần gì cứ hỏi mình nhé.",
    ),
    (
        ["ban co that khong", "ban co phai nguoi that", "ban la nguoi hay may"],
        "Mình là trợ lý AI của PDTrip — không phải người thật, nhưng luôn sẵn sàng "
        "tư vấn du lịch cho bạn!",
    ),
    (
        ["alo","lo","chao xin","xin chao", "hello", "hi", "chao ban", "chao", "xin chao ban", "xin chao pdtrip", "chao pdtrip", "chao pdtrip ai", "chao pdtrip assistant", "chao pdtrip bot", "chao pdtrip chatbot"],
        "Xin chào bạn. Mình là trợ lý AI của PDTrip — Mình có thể giúp bạn tìm điểm "
        "tham quan, khách sạn, ẩm thực, mua sắm, tour, cách di chuyển và lên kế hoạch gợi ý lịch "
        "trình cho 63 tỉnh/thành. Bạn muốn đi đâu hay khám phá nơi nào nói cho mình biết nhé?",
    ),
]


def match(question: str) -> Optional[str]:
    """Trả câu trả lời mẫu nếu câu hỏi khớp 1 rule quen thuộc; None nếu không."""
    if not question:
        return None
    q = _norm(question)
    # tránh nuốt nhầm câu dài có ý hỏi du lịch (vd "... giúp tôi tìm khách sạn")
    if len(q.split()) > 12:
        return None
    for triggers, answer in _RULES:
        if any(t in q for t in triggers):
            return answer
    return None
