"""
Gemini Optimizer — YÊU CẦU 5.

Gồm:
  - SYSTEM_INSTRUCTION: nguyên tắc chống hallucination tách riêng khỏi prompt
    biến đổi (truyền qua config.system_instruction, không lặp lại mỗi request).
  - FEW_SHOT_EXAMPLES: ví dụ trả lời tốt / trả lời khi thiếu context, chèn vào
    đầu phần `contents` (Gemini hiện chưa hỗ trợ few-shot examples là 1 field
    riêng như OpenAI, nên ghép trực tiếp vào prompt).
  - gemini_config(intent): system_instruction + max_output_tokens động theo
    intent (FAQ ngắn → ít token, itinerary dài → nhiều token hơn).
  - build_sliding_history(): nếu lịch sử hội thoại dài hơn CHAT_HISTORY_LIMIT,
    tóm tắt phần cũ bằng 1 lần gọi Gemini, giữ nguyên N tin nhắn gần nhất.
  - call_with_retry(): retry + exponential backoff cho lỗi tạm thời (timeout,
    503, rate limit).
  - StreamTimingTracker: đo TTFT (time-to-first-token) tách biệt với tổng thời
    gian generate.
"""

from __future__ import annotations

import asyncio
import time
from typing import Awaitable, Callable, Optional, TypeVar

from google.genai import types as genai_types

from app.core.config import settings
from app.utils import get_logger

logger = get_logger("gemini_optimizer")

T = TypeVar("T")

FRIENDLY_TIMEOUT_MESSAGE = (
    "Xin lỗi, hệ thống đang phản hồi chậm hơn bình thường. "
    "Bạn vui lòng thử lại câu hỏi sau ít phút nhé!"
)

SYSTEM_INSTRUCTION = """Bạn là PDTrip AI, chuyên gia tư vấn du lịch Việt Nam, trả lời bằng tiếng Việt tự nhiên, thân thiện và ngắn gọn.

NGUYÊN TẮC QUAN TRỌNG:
1. Ưu tiên dùng "Thông tin tham khảo" nếu có. KHÔNG bịa đặt giá cả cụ thể, địa chỉ, số điện thoại nếu không có trong đó.
2. Nếu câu hỏi mang tính gợi ý chung (ví dụ: "đi biển ở đâu?", "nên đi đâu hè này?", "điểm đến đẹp?") và không có Thông tin tham khảo, hãy CHỦ ĐỘNG gợi ý dựa trên kiến thức của bạn về du lịch Việt Nam, kèm lời mời hỏi thêm để tư vấn cụ thể hơn.
3. Chỉ nói "Tôi chưa có đủ thông tin" khi câu hỏi yêu cầu dữ liệu CỤ THỂ (giá phòng, lịch trình chi tiết, địa chỉ chính xác) mà không có trong Thông tin tham khảo.
4. Nếu nguồn được đánh dấu "[Nguồn gần đúng]", hãy diễn đạt thận trọng hơn (ví dụ: "theo thông tin tham khảo được...") vì độ tin cậy thấp hơn.
5. Khi trích dẫn, dùng số thứ tự nguồn trong dấu ngoặc vuông như [1], [2] khớp với phần "Thông tin tham khảo" — không tự đặt số nguồn không tồn tại.
6. Với câu hỏi lập lịch trình, nếu chưa biết số ngày/ngân sách/loại hình đi, hãy hỏi lại trước khi tư vấn chi tiết.
7. Sau câu trả lời chính, có thể gợi ý 2-3 câu hỏi liên quan người dùng có thể quan tâm, đặt trong khối:
<<<SUGGESTED_QUESTIONS>>>
- câu hỏi gợi ý 1
- câu hỏi gợi ý 2
<<<END_SUGGESTED>>>
"""

FEW_SHOT_EXAMPLES = """=== Ví dụ cách trả lời ===

Ví dụ 1 — đủ thông tin:
Người dùng: "Đi Đà Lạt tháng mấy đẹp?"
Trợ lý: "Đà Lạt đẹp nhất từ tháng 11 đến tháng 4 năm sau — mùa khô, trời trong, nắng ban ngày nhưng sáng tối vẫn se lạnh. Tháng 12 có Festival Hoa rất đặc sắc nhưng giá phòng tăng cao, nên đặt trước 2-3 tuần. [1]"

Ví dụ 2 — thiếu thông tin trong context:
Người dùng: "Khách sạn nào rẻ nhất ở Cà Mau?"
Trợ lý: "Tôi chưa có đủ thông tin chi tiết về khách sạn tại Cà Mau để tư vấn chính xác. Bạn có thể tham khảo Booking.com hoặc Agoda và lọc theo giá để tìm lựa chọn phù hợp nhé!"

=== Hết ví dụ ===
"""

# Max output tokens theo intent: trả lời ngắn (FAQ) ít token, lịch trình dài cần nhiều hơn
_MAX_TOKENS_BY_INTENT: dict[str, int] = {
    "smalltalk": 256,
    "ask_faq": 512,
    "faq": 512,
    "ask_weather": 512,
    "ask_best_time": 512,
    "ask_transport": 640,
    "ask_food": 640,
    "ask_safety": 640,
    "ask_activity": 640,
    "ask_budget": 768,
    "ask_destination": 768,
    "find_hotel": 768,
    "find_tour": 768,
    "compare_destinations": 1024,
    "plan_trip": 2048,
    "itinerary_planner": 2048,
}
_DEFAULT_MAX_TOKENS = 1024


def _thinking_off():
    """
    Tắt 'thinking' cho các model Gemini 2.5 (mặc định bật → chậm + tốn token,
    không cần cho chatbot RAG ngắn gọn). Trả None nếu SDK không hỗ trợ
    ThinkingConfig (model cũ 2.0) — khi đó bỏ qua, không lỗi.
    """
    try:
        return genai_types.ThinkingConfig(thinking_budget=0)
    except Exception:
        return None


def gemini_config(intent: Optional[str] = None) -> genai_types.GenerateContentConfig:
    max_tokens = _MAX_TOKENS_BY_INTENT.get(intent or "", _DEFAULT_MAX_TOKENS)
    kwargs = dict(
        system_instruction=SYSTEM_INSTRUCTION,
        temperature=0.4,
        top_p=0.9,
        max_output_tokens=max_tokens,
    )
    tc = _thinking_off()
    if tc is not None:
        kwargs["thinking_config"] = tc
    return genai_types.GenerateContentConfig(**kwargs)


# ── Sliding history summary ─────────────────────────────────────────────────

async def build_sliding_history(
    history: list[dict],
    client,
    model: str,
    keep_recent: Optional[int] = None,
) -> tuple[list[dict], Optional[str]]:
    """
    Nếu lịch sử dài hơn settings.CHAT_HISTORY_LIMIT, tóm tắt phần cũ bằng 1
    lần gọi Gemini (rẻ, nhanh) và chỉ giữ `keep_recent` tin nhắn gần nhất
    nguyên văn. Nếu lịch sử ngắn, trả về nguyên vẹn, summary_text=None.
    """
    limit = keep_recent or settings.CHAT_HISTORY_LIMIT
    if len(history) <= limit:
        return history, None

    older = history[: len(history) - limit]
    recent = history[-limit:]

    convo_text = "\n".join(
        f"{'Người dùng' if m['role'] == 'user' else 'Trợ lý'}: {m['content']}"
        for m in older
    )
    summary_prompt = (
        "Tóm tắt ngắn gọn (3-5 câu) nội dung chính của đoạn hội thoại sau, "
        "chỉ giữ thông tin quan trọng cho việc tư vấn du lịch tiếp theo "
        "(điểm đến đã hỏi, sở thích, ngân sách, ngày đi nếu có):\n\n" + convo_text
    )

    try:
        response = await client.aio.models.generate_content(
            model=model,
            contents=summary_prompt,
            config=genai_types.GenerateContentConfig(
                temperature=0.2, max_output_tokens=300
            ),
        )
        summary_text = (response.text or "").strip()
        return recent, summary_text or None
    except Exception as e:
        logger.warning(f"[Gemini Optimizer] Sliding summary thất bại, dùng history thô: {e}")
        # Nếu summary fail, vẫn cắt history để tránh prompt quá dài
        return recent, None


# ── Retry với exponential backoff ──────────────────────────────────────────

_RETRYABLE_ERROR_HINTS = ("timeout", "503", "deadline", "unavailable", "429", "rate limit")


def _is_retryable(exc: Exception) -> bool:
    msg = str(exc).lower()
    return any(hint in msg for hint in _RETRYABLE_ERROR_HINTS)


async def call_with_retry(
    fn: Callable[[], Awaitable[T]],
    max_retries: int = 3,
    base_delay: float = 1.0,
) -> T:
    last_exc: Optional[Exception] = None
    for attempt in range(max_retries + 1):
        try:
            return await fn()
        except Exception as e:
            last_exc = e
            if attempt >= max_retries or not _is_retryable(e):
                raise
            delay = base_delay * (2 ** attempt)
            logger.warning(
                f"[Gemini Optimizer] Lỗi tạm thời (attempt {attempt + 1}/{max_retries}): {e} "
                f"— retry sau {delay:.1f}s"
            )
            await asyncio.sleep(delay)
    raise last_exc  # type: ignore[misc]


# ── TTFT tracking ────────────────────────────────────────────────────────────

class StreamTimingTracker:
    """Theo dõi time-to-first-token (TTFT) tách biệt với tổng thời gian generate."""

    def __init__(self, t_start: float) -> None:
        self.t_start = t_start
        self.ttft_ms: Optional[int] = None

    def mark_first_token(self) -> None:
        if self.ttft_ms is None:
            self.ttft_ms = int((time.monotonic() - self.t_start) * 1000)

    def generation_ms(self, t_end: float) -> int:
        return int((t_end - self.t_start) * 1000)
