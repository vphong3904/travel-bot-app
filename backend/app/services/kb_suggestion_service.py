"""
KB Suggestion Service — TP-005 (.agent/trip-ai).

AI (Gemini) soạn DRAFT knowledge-base entry từ câu hỏi user mà chatbot chưa
trả lời được. Chỉ trả draft cho admin duyệt/sửa — KHÔNG tự ghi
knowledge_entries (lưu vẫn qua promote-to-kb cũ).
"""
from __future__ import annotations

import asyncio
import json
import re
from typing import Optional

from app.utils import get_logger

logger = get_logger("kb_suggestion")

VALID_CATEGORIES = ("faq", "destination", "food", "tips")

_PROMPT_TEMPLATE = """Bạn là biên tập viên knowledge base cho chatbot du lịch Việt Nam (khách nội địa, tiếng Việt).
Chatbot đã KHÔNG trả lời được câu hỏi sau của người dùng:

"{question}"
{context_block}
Hãy soạn 1 bài knowledge base để lần sau chatbot trả lời được. Trả về DUY NHẤT một JSON object (không markdown, không giải thích) theo format:
{{"title": "tiêu đề ngắn gọn ≤80 ký tự",
  "category": "faq" | "destination" | "food" | "tips",
  "content": "nội dung markdown tiếng Việt, 100-250 từ, cấu trúc rõ ràng",
  "confidence": "high" | "low"}}

Quy tắc:
- KHÔNG bịa số liệu cụ thể (giá phòng chính xác, số điện thoại, địa chỉ số nhà). Giá cả chỉ nêu khoảng ước lượng kèm chữ "khoảng/tham khảo".
- Nếu câu hỏi cần dữ liệu thời gian thực hoặc bạn không chắc thông tin → vẫn soạn phần khái quát đúng, đặt "confidence": "low" để admin kiểm chứng kỹ.
- Không viết nội dung visa / đổi ngoại tệ / hướng tới khách nước ngoài.
- Câu hỏi của user có thể chỉ là 1 phản hồi ngắn tiếp nối hội thoại trước (vd "uk", "ừ", "ok", "dc", "đồng ý", "oke") để xác nhận/đồng ý với đề xuất trước đó — KHÔNG phải câu hỏi độc lập mới. Dựa vào NGỮ CẢNH TRƯỚC ĐÓ (nếu có) để hiểu đúng chủ đề đang bàn, TUYỆT ĐỐI không suy diễn từ viết tắt tiếng Việt thành từ tiếng Anh không liên quan (ví dụ "uk" ở đây nghĩa là "ừ", không phải "United Kingdom"/nước Anh).
- Nếu câu hỏi chỉ là phản hồi ngắn và KHÔNG có ngữ cảnh trước đó để hiểu ý, đặt "confidence": "low" và ghi rõ trong content rằng cần thêm ngữ cảnh, không tự bịa chủ đề.
"""


def _extract_json(raw: str) -> Optional[dict]:
    """Gemini đôi khi bọc ```json ... ``` hoặc thêm text — bóc JSON an toàn."""
    s = (raw or "").strip()
    s = re.sub(r"^```(?:json)?\s*|\s*```$", "", s, flags=re.MULTILINE).strip()
    try:
        return json.loads(s)
    except json.JSONDecodeError:
        m = re.search(r"\{.*\}", s, flags=re.DOTALL)
        if m:
            try:
                return json.loads(m.group(0))
            except json.JSONDecodeError:
                return None
    return None


async def suggest_kb_draft(question: str, context: str | None = None) -> dict:
    """
    Gọi Gemini soạn draft KB. `context` = câu trả lời/tin nhắn NGAY TRƯỚC câu
    hỏi trong cùng session — giúp Gemini hiểu đúng các phản hồi ngắn kiểu
    "uk"/"ừ" (đồng ý tiếp nối) thay vì suy diễn sai (vd "uk" → United Kingdom).
    Raise RuntimeError khi Gemini lỗi/không cấu hình (route chuyển thành
    HTTPException 502).
    """
    from google.genai import types as genai_types

    from app.core.config import settings
    from app.services.gemini_optimizer import _thinking_off, call_with_retry
    from app.services.rag_pipeline import _get_genai_client

    client = _get_genai_client()

    config_kwargs = dict(
        temperature=0.3,
        max_output_tokens=1024,
        response_mime_type="application/json",
    )
    thinking_config = _thinking_off()
    if thinking_config is not None:
        config_kwargs["thinking_config"] = thinking_config

    context_block = ""
    if context:
        context_block = (
            f'\nNgữ cảnh: tin nhắn NGAY TRƯỚC câu hỏi trên trong cùng hội '
            f'thoại là:\n"{context.strip()[:500]}"\n'
        )

    async def _call():
        return await asyncio.wait_for(
            client.aio.models.generate_content(
                model=settings.GEMINI_MODEL,
                contents=_PROMPT_TEMPLATE.format(
                    question=question.strip()[:500],
                    context_block=context_block,
                ),
                config=genai_types.GenerateContentConfig(**config_kwargs),
            ),
            timeout=25,
        )

    try:
        response = await call_with_retry(_call, max_retries=1)
    except Exception as e:
        logger.error(f"[suggest_kb_draft] Gemini lỗi: {e}")
        raise RuntimeError(f"Gemini không phản hồi: {e}") from e

    draft = _extract_json(response.text or "")
    if not draft or not draft.get("title") or not draft.get("content"):
        logger.error(f"[suggest_kb_draft] Output không parse được: {response.text!r:.300}")
        raise RuntimeError("AI trả về format không hợp lệ, vui lòng thử lại")

    if draft.get("category") not in VALID_CATEGORIES:
        draft["category"] = "faq"
    if draft.get("confidence") not in ("high", "low"):
        draft["confidence"] = "low"
    draft["title"] = str(draft["title"])[:80]
    return draft
