"""
quick_replies.py — Trả lời TỨC THÌ cho câu hỏi quen thuộc/meta, KHÔNG gọi Gemini
và không cần embedding. Tiết kiệm quota + phản hồi <50ms.

Dùng cho:
  - Câu hỏi về chính bot ("bạn là ai", "giúp được gì", "dùng thế nào").
  - Cảm ơn / xã giao ngắn.
  - Vài câu FAQ chung rất phổ biến không phụ thuộc thành phố (sim, đổi tiền, an toàn).

Khớp theo cụm từ KHÔNG DẤU (robust với gõ thiếu dấu), theo RANH GIỚI TỪ (dùng
lại `_keyword_in_text` của nlp_preprocessor) — KHÔNG phải substring thô. Bug đã
sửa: khớp substring thô khiến trigger "hi" lọt vào giữa chữ "n**hi**ều" (câu
"Giá khách sạn đó bao **nhiêu**" bị nhận nhầm là lời chào, không lên LLM, mất
context). Mỗi rule còn có `max_words` riêng — rule càng "nhạy cảm" (dễ trùng
với từ tiếng Việt khác, vd "chào" trùng "cháo") càng cần câu NGẮN mới cho khớp,
để câu hỏi du lịch thật (dài hơn, có thực thể) luôn rơi xuống RAG/LLM.

Câu hỏi du lịch theo thành phố (điểm đến/khách sạn/ăn uống...) KHÔNG nằm ở đây —
chúng đi qua RAG (structured + KB) để trả dữ liệu thật.
"""

from __future__ import annotations

from typing import Optional

from app.services.nlp_preprocessor import _keyword_in_text, _remove_accents


def _norm(text: str) -> str:
    return _remove_accents(text or "").lower().strip()


# (triggers không dấu, câu trả lời, max_words). Thứ tự = độ ưu tiên.
# max_words giới hạn số từ TỐI ĐA của cả câu để rule này được phép khớp.
_RULES: list[tuple[list[str], str, int]] = [
    (
        ["ban la ai", "ban ten gi", "ban la chatbot", "gioi thieu ban than",
         "ban la gi", "may la ai"],
        "Mình là **PDTrip AI** — trợ lý du lịch Việt Nam. Mình giúp bạn tìm điểm "
        "tham quan, khách sạn, ẩm thực, mua sắm, tour, cách di chuyển và gợi ý lịch "
        "trình cho 63 tỉnh/thành. Bạn muốn khám phá nơi nào?",
        12,
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
        12,
    ),
    (
        ["cam on", "cam ban", "thanks", "thank you", "tks", "cam o n", "thén kiu", "thank u", "ok thanks", "ok thank you", "ok ban"],
        "Không có gì, chúc bạn có chuyến đi thật vui! Cần gì cứ hỏi mình nhé.",
        12,
    ),
    (
        ["ban co that khong", "ban co phai nguoi that", "ban la nguoi hay may"],
        "Mình là trợ lý AI của PDTrip — không phải người thật, nhưng luôn sẵn sàng "
        "tư vấn du lịch cho bạn!",
        12,
    ),
    (
        # Bỏ trigger 2 ký tự "hi"/"lo" — dù đã có ranh giới từ, chúng vẫn là
        # TỪ THẬT trong tiếng Việt không dấu ("hi" trong "hi vọng", "lo" trong
        # "lo lắng"/"lò nướng") nên vẫn khớp nhầm câu không liên quan chào hỏi.
        # "chao" cũng trùng với "cháo" (món ăn) khi bỏ dấu — giới hạn max_words
        # thấp để câu hỏi về món cháo (thường dài hơn) không bị nuốt.
        ["alo", "chao xin", "xin chao", "hello", "chao ban", "chao",
         "xin chao ban", "xin chao pdtrip", "chao pdtrip", "chao pdtrip ai",
         "chao pdtrip assistant", "chao pdtrip bot", "chao pdtrip chatbot"],
        "Xin chào bạn. Mình là trợ lý AI của PDTrip — Mình có thể giúp bạn tìm điểm "
        "tham quan, khách sạn, ẩm thực, mua sắm, tour, cách di chuyển và lên kế hoạch gợi ý lịch "
        "trình cho 63 tỉnh/thành. Bạn muốn đi đâu hay khám phá nơi nào nói cho mình biết nhé?",
        4,
    ),
]


def match(question: str) -> Optional[str]:
    """Trả câu trả lời mẫu nếu câu hỏi khớp 1 rule quen thuộc; None nếu không."""
    if not question:
        return None
    q = _norm(question)
    word_count = len(q.split())
    # tránh nuốt nhầm câu dài có ý hỏi du lịch (vd "... giúp tôi tìm khách sạn")
    if word_count > 12:
        return None
    for triggers, answer, max_words in _RULES:
        if word_count > max_words:
            continue
        if any(_keyword_in_text(t, q) for t in triggers):
            return answer
    return None
