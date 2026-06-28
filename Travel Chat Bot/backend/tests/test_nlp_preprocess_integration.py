"""
Test cho app/services/nlp_preprocessor.preprocess() — luồng NLP tổng hợp.

File test_intent_no_accent.py hiện có chỉ test detect_intent() đơn lẻ.
File này bổ sung test cho preprocess() — hàm tổng hợp thật sự được
chat_messages.py gọi (xem app/api/routes/chat_messages.py: `nlp =
preprocess(payload.content, history=history)`), bao phủ:

  - Luồng greeting / out-of-scope short-circuit
  - Luồng cần hỏi lại (clarification) khi câu hỏi quá mơ hồ
  - Query rewriting có dùng lịch sử hội thoại (multi-turn context)
  - extract_entities() cho location/month/duration

Đây là phần CHECKLIST_TONG_THE.md mục 4 nói "khá mỏng để chứng minh độ
tin cậy khi bảo vệ" — bổ sung thêm 1 lớp test ở mức tích hợp giữa các hàm
trong cùng module, không chỉ unit test riêng detect_intent.

Chạy: pytest backend/tests/test_nlp_preprocess_integration.py -v
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.services.nlp_preprocessor import (  # noqa: E402
    preprocess,
    extract_entities,
    GREETING_RESPONSES,
    OUT_OF_SCOPE_RESPONSE,
)


# ════════════════════════════════════════════════════════════════════════════
# extract_entities
# ════════════════════════════════════════════════════════════════════════════

class TestExtractEntities:
    def test_extracts_known_location(self):
        entities = extract_entities("thời tiết đà lạt thế nào")
        assert entities.get("location") == "Đà Lạt"

    def test_extracts_location_no_accent(self):
        entities = extract_entities("thoi tiet da lat the nao")
        assert entities.get("location") == "Đà Lạt"

    def test_extracts_month_as_number_word(self):
        entities = extract_entities("đi đà lạt tháng 12 có lạnh không")
        assert entities.get("month") == 12

    def test_extracts_duration_days(self):
        entities = extract_entities("lên kế hoạch 3 ngày ở đà lạt")
        assert entities.get("duration_days") == 3

    def test_no_entities_for_unrelated_text(self):
        entities = extract_entities("xin chào bạn khoẻ không")
        assert "location" not in entities
        assert "month" not in entities


# ════════════════════════════════════════════════════════════════════════════
# preprocess() — short-circuit greeting / out-of-scope
# ════════════════════════════════════════════════════════════════════════════

class TestPreprocessShortCircuit:
    def test_pure_greeting_marked_as_greeting(self):
        result = preprocess("xin chào")
        assert result.is_greeting is True
        assert result.is_out_of_scope is False
        # is_greeting=True nghĩa là chat_messages.py sẽ dùng
        # get_greeting_response() — không gọi rag.query() tốn phí Gemini.
        assert result.intent == "greeting"

    def test_known_out_of_scope_keyword_detected(self):
        """is_out_of_scope dựa trên whitelist từ khoá cụ thể trong
        INTENT_PATTERNS["out_of_scope"] (rule-based, không phải NLP hiểu
        nghĩa) — "giải phương trình" là 1 trong các cụm khoá đó, nên câu
        hỏi chứa cụm này phải được short-circuit, tránh tốn 1 lần gọi
        Gemini cho câu hỏi chắc chắn ngoài phạm vi du lịch."""
        result = preprocess("giải phương trình bậc hai giúp tôi")
        assert result.is_out_of_scope is True

    def test_unknown_unrelated_question_not_auto_flagged_out_of_scope(self):
        """LƯU Ý quan trọng: out_of_scope CHỈ kích hoạt khi khớp đúng 1 từ
        khoá trong whitelist — hệ thống KHÔNG tự suy luận một câu là "ngoài
        phạm vi du lịch" bằng ngữ nghĩa. Câu hỏi lạ không khớp khoá nào sẽ
        rơi vào "unknown", không phải "out_of_scope". Test này khoá lại
        đúng hành vi thật, tránh hiểu lầm rằng hệ thống "hiểu" mọi câu hỏi
        ngoài đề tài khi đọc lại code sau này."""
        result = preprocess("con mèo của tôi tên là Mít")
        assert result.is_out_of_scope is False
        assert result.intent == "unknown"

    def test_greeting_response_pool_is_nonempty(self):
        """Đảm bảo luôn có ít nhất 1 câu chào để get_greeting_response()
        không bao giờ index lỗi (hash(session_id) % 3 trong rag_pipeline.py
        giả định GREETING_RESPONSES có ít nhất vài phần tử)."""
        assert len(GREETING_RESPONSES) >= 1

    def test_out_of_scope_response_mentions_scope(self):
        assert "du lịch" in OUT_OF_SCOPE_RESPONSE.lower()


# ════════════════════════════════════════════════════════════════════════════
# preprocess() — clarification flow
# ════════════════════════════════════════════════════════════════════════════

class TestPreprocessClarification:
    def test_location_only_question_asks_for_clarification(self):
        """Người dùng chỉ gõ tên địa danh (không rõ muốn hỏi gì) phải được
        hỏi lại, không nên đoán bừa và gọi RAG ngay — tránh trả lời lệch."""
        result = preprocess("đà lạt")
        assert result.needs_clarification is True
        assert "Đà Lạt" in result.clarification_message
        assert len(result.clarification_options) > 0

    def test_clarification_skips_query_rewriting(self):
        """Khi cần hỏi lại, rewritten_query phải giữ nguyên normalized_query
        (không rewrite) — đúng theo logic preprocess() bước 6."""
        result = preprocess("đà lạt")
        assert result.rewritten_query == result.normalized_query

    def test_full_question_does_not_need_clarification(self):
        result = preprocess("thời tiết đà lạt tháng 12 thế nào")
        assert result.needs_clarification is False


# ════════════════════════════════════════════════════════════════════════════
# preprocess() — query rewriting có dùng lịch sử (multi-turn)
# ════════════════════════════════════════════════════════════════════════════

class TestPreprocessMultiTurnRewriting:
    def test_followup_question_inherits_location_from_history(self):
        """Đây là case quan trọng nhất của multi-turn: user hỏi về Đà Lạt
        ở câu trước, câu sau chỉ hỏi "có lạnh không?" (không nhắc lại địa
        danh) — rewritten_query phải tự thêm "Đà Lạt" vào, nếu không RAG
        sẽ tìm kiếm mơ hồ và rất dễ trả lời sai/lạc đề."""
        history = [
            {"role": "user", "content": "đà lạt"},
            {"role": "assistant", "content": "Đà Lạt là thành phố cao nguyên..."},
        ]
        result = preprocess("có lạnh không?", history=history)
        assert "đà lạt" in result.rewritten_query.lower() or "Đà Lạt" in result.rewritten_query

    def test_followup_inherits_month_from_history(self):
        history = [
            {"role": "user", "content": "đi đà lạt tháng 12 thì sao"},
            {"role": "assistant", "content": "Tháng 12 ở Đà Lạt khá lạnh..."},
        ]
        result = preprocess("có lạnh không?", history=history)
        assert "12" in result.rewritten_query

    def test_no_history_does_not_crash_on_followup(self):
        """Câu hỏi cụt lủn nhưng KHÔNG có history (vd: tin nhắn đầu tiên
        của session) không được crash — chỉ đơn giản không có location/month
        để điền vào, rewritten_query vẫn phải là string hợp lệ."""
        result = preprocess("có lạnh không?")
        assert isinstance(result.rewritten_query, str)
        assert len(result.rewritten_query) > 0


# ════════════════════════════════════════════════════════════════════════════
# preprocess() — kết quả luôn có shape đầy đủ (an toàn cho route gọi .attr)
# ════════════════════════════════════════════════════════════════════════════

class TestPreprocessResultShape:
    @pytest.mark.parametrize(
        "question",
        [
            "xin chào",
            "đà lạt",
            "thời tiết sa pa tháng 1",
            "giải phương trình bậc hai giúp tôi",
            "",
            "   ",
        ],
    )
    def test_result_always_has_required_attributes(self, question):
        """Bất kể input gì (kể cả rỗng/toàn khoảng trắng), preprocess()
        không được raise exception và phải trả về NLPResult có đủ field mà
        chat_messages.py truy cập (.rewritten_query, .intent, .is_greeting,
        .is_out_of_scope, .needs_clarification, .clarification_message,
        .clarification_options)."""
        result = preprocess(question)
        assert isinstance(result.rewritten_query, str)
        assert isinstance(result.intent, str)
        assert isinstance(result.is_greeting, bool)
        assert isinstance(result.is_out_of_scope, bool)
        assert isinstance(result.needs_clarification, bool)
        assert isinstance(result.clarification_message, str)
        assert isinstance(result.clarification_options, list)
        assert isinstance(result.confidence, float)
        assert 0.0 <= result.confidence <= 1.0


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
