"""
Test cho app/services/hallucination_guard.py — YÊU CẦU 3 (Hạn chế hallucination).

ĐÍNH CHÍNH (sau khi đọc kỹ .agent/rules/AGENT_RULES.md và .agent/ROADMAP.md):
file này KHÔNG phải là "bộ eval RULE-13" — RULE-13 trong AGENT_RULES.md quy
định cụ thể: sau khi T-010 và T-012 DONE, phải tạo bộ ≥20 câu hỏi cố định
phủ 4 loại intent, lưu tại `backend/tests/eval_questions.json` (đây cũng
chính là T-017, nằm ở Phase 3 — Enhancement trong ROADMAP.md, sau khi
Phase 1 và 2 xong). T-010/T-011/T-012 hiện vẫn ⬜ TODO, nên điều kiện kích
hoạt RULE-13 CHƯA tới — `eval_questions.json` chưa cần làm ngay.

File này là một việc khác, độc lập: unit test cho 2 lớp phòng thủ
hallucination_guard.py (filter threshold trước khi build prompt + grounding/
citation check sau khi sinh câu trả lời) — module này đã tồn tại và chạy
thật trong rag_pipeline.py ngay bây giờ, không phụ thuộc gì vào
knowledge-base/ hay các task T-00x. Có giá trị độc lập với RULE-13, nhưng
không thay thế được `eval_questions.json` mà RULE-13 yêu cầu khi đến lúc.

Hai lớp phòng thủ được test:
  Lớp 1 (trước khi build prompt):
    - filter_by_dynamic_threshold(): lọc hit có score thấp, có cơ chế hạ
      ngưỡng (fallback) khi KB mỏng để tránh "0 results".
    - annotate_fallback_sources(): đánh dấu is_approximate cho nguồn kém
      tin cậy (PostgreSQL FTS hoặc Qdrant score thấp).

  Lớp 2 (sau khi sinh câu trả lời):
    - run_hallucination_checks(): kiểm tra grounding (câu trả lời có bám
      vào context không) + citation (chỉ số [1][2]... có hợp lệ không).

Không cần DB/Qdrant/Gemini thật — toàn bộ là pure function, chạy nhanh,
phù hợp để chạy trong CI hoặc trước mỗi lần bảo vệ.

Chạy: pytest backend/tests/test_hallucination_guard.py -v
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.services.hallucination_guard import (  # noqa: E402
    PRIMARY_THRESHOLD,
    FALLBACK_THRESHOLD,
    APPROXIMATE_SCORE_CEILING,
    filter_by_dynamic_threshold,
    annotate_fallback_sources,
    run_hallucination_checks,
)


# ════════════════════════════════════════════════════════════════════════════
# Lớp 1a: filter_by_dynamic_threshold
# ════════════════════════════════════════════════════════════════════════════

class TestDynamicThreshold:
    def test_no_hits_returns_empty_with_primary_threshold(self):
        filtered, threshold = filter_by_dynamic_threshold([])
        assert filtered == []
        assert threshold == PRIMARY_THRESHOLD

    def test_high_quality_hit_uses_primary_threshold(self):
        """Có ít nhất 1 hit đạt PRIMARY_THRESHOLD → dùng ngưỡng cao,
        loại bỏ các hit yếu hơn ngưỡng cao đó."""
        hits = [
            {"text": "Đà Lạt mát mẻ quanh năm", "score": 0.60},
            {"text": "không liên quan lắm", "score": 0.35},
        ]
        filtered, threshold = filter_by_dynamic_threshold(hits)
        assert threshold == PRIMARY_THRESHOLD
        assert len(filtered) == 1
        assert filtered[0]["score"] == 0.60

    def test_low_quality_only_falls_back_to_lower_threshold(self):
        """Không có hit nào đạt ngưỡng cao, nhưng có hit ở mức thấp hơn
        FALLBACK_THRESHOLD → hạ ngưỡng để tránh 0 kết quả."""
        hits = [
            {"text": "gần đúng", "score": 0.32},
            {"text": "khá liên quan", "score": 0.38},
        ]
        filtered, threshold = filter_by_dynamic_threshold(hits)
        assert threshold == FALLBACK_THRESHOLD
        assert len(filtered) == 2

    def test_all_hits_below_fallback_threshold_excluded(self):
        hits = [{"text": "không liên quan", "score": 0.10}]
        filtered, threshold = filter_by_dynamic_threshold(hits)
        assert threshold == FALLBACK_THRESHOLD
        assert filtered == []

    def test_missing_score_key_defaults_to_zero(self):
        """Hit thiếu key 'score' phải được coi là 0, không raise lỗi."""
        hits = [{"text": "thiếu score"}]
        filtered, threshold = filter_by_dynamic_threshold(hits)
        assert filtered == []


# ════════════════════════════════════════════════════════════════════════════
# Lớp 1b: annotate_fallback_sources
# ════════════════════════════════════════════════════════════════════════════

class TestAnnotateFallbackSources:
    def test_postgres_fts_source_marked_approximate(self):
        results = [{"source": "postgres_fts", "score": 0.9, "text": "abc"}]
        annotated = annotate_fallback_sources(results)
        assert annotated[0]["is_approximate"] is True

    def test_low_score_qdrant_source_marked_approximate(self):
        results = [{"source": "qdrant", "score": APPROXIMATE_SCORE_CEILING - 0.01}]
        annotated = annotate_fallback_sources(results)
        assert annotated[0]["is_approximate"] is True

    def test_high_score_qdrant_source_not_approximate(self):
        results = [{"source": "qdrant", "score": APPROXIMATE_SCORE_CEILING + 0.1}]
        annotated = annotate_fallback_sources(results)
        assert annotated[0]["is_approximate"] is False

    def test_does_not_mutate_original_dicts(self):
        """annotate phải trả về dict mới, không sửa trực tiếp input
        (tránh side-effect khó debug ở pipeline gọi nhiều lần)."""
        original = {"source": "postgres_fts", "score": 0.9}
        annotate_fallback_sources([original])
        assert "is_approximate" not in original


# ════════════════════════════════════════════════════════════════════════════
# Lớp 2: run_hallucination_checks (grounding + citation)
# ════════════════════════════════════════════════════════════════════════════

class TestGroundingCheck:
    def test_answer_well_grounded_in_sources(self):
        sources = [
            {"text": "Đà Lạt có khí hậu mát mẻ quanh năm, nhiệt độ trung bình 18-23 độ C."}
        ]
        answer = "Đà Lạt có khí hậu mát mẻ quanh năm với nhiệt độ trung bình khoảng 18-23 độ C."
        report = run_hallucination_checks(answer, sources)
        assert report.grounding.is_grounded is True
        assert report.should_flag_for_review is False

    def test_answer_unrelated_to_sources_flagged(self):
        sources = [{"text": "Đà Lạt có khí hậu mát mẻ quanh năm."}]
        answer = "Bạn nên mang theo hộ chiếu và visa khi nhập cảnh Nhật Bản bằng tàu siêu tốc."
        report = run_hallucination_checks(answer, sources)
        assert report.grounding.is_grounded is False
        assert report.should_flag_for_review is True
        assert len(report.grounding.ungrounded_terms) > 0

    def test_no_sources_at_all_low_confidence(self):
        """Không có context nào (KB rỗng) mà vẫn có câu trả lời → confidence
        thấp mặc định, phải bị flag để admin review."""
        report = run_hallucination_checks("Một câu trả lời bất kỳ.", [])
        assert report.grounding.is_grounded is False
        assert report.grounding.confidence == 0.3
        assert report.should_flag_for_review is True

    def test_empty_answer_against_sources_is_trivially_grounded(self):
        """Câu trả lời rỗng (không có token nào) không có gì để đối chiếu
        sai — implementation coi là grounded mặc định, ghi lại để không
        bị hiểu nhầm là bug nếu ai đó đọc lại behaviour này."""
        sources = [{"text": "Một số thông tin."}]
        report = run_hallucination_checks("   ", sources)
        assert report.grounding.is_grounded is True
        assert report.grounding.confidence == 1.0


class TestCitationCheck:
    def test_no_citation_marks_are_valid_by_default(self):
        report = run_hallucination_checks(
            "Đà Lạt mát mẻ quanh năm.",
            [{"text": "Đà Lạt mát mẻ quanh năm."}],
        )
        assert report.citation.valid is True
        assert report.citation.invalid_indices == []

    def test_citation_within_range_is_valid(self):
        sources = [{"text": "nguồn 1"}, {"text": "nguồn 2"}]
        answer = "Theo [1] và [2], thông tin này đúng."
        report = run_hallucination_checks(answer, sources)
        assert report.citation.valid is True

    def test_citation_out_of_range_is_invalid_and_flagged(self):
        """Model trích dẫn [3] nhưng chỉ có 2 nguồn thật → rất có thể đang
        bịa nguồn, phải bị đánh dấu invalid và flag review."""
        sources = [{"text": "nguồn 1"}, {"text": "nguồn 2"}]
        answer = "Theo [3], thông tin này đúng."
        report = run_hallucination_checks(answer, sources)
        assert report.citation.valid is False
        assert report.citation.invalid_indices == [3]
        assert report.should_flag_for_review is True

    def test_citation_zero_index_is_invalid(self):
        """Citation 1-indexed theo _build_prompt, nên [0] phải coi là invalid."""
        sources = [{"text": "nguồn 1"}]
        report = run_hallucination_checks("Theo [0], ...", sources)
        assert report.citation.valid is False
        assert 0 in report.citation.invalid_indices

    def test_invalid_citation_caps_overall_confidence(self):
        """Dù grounding cao, citation sai vẫn phải kéo overall_confidence
        xuống tối đa 0.4 — đây là rule khẳng định trong code, test để khoá
        hành vi này không bị vô tình đổi khi refactor."""
        sources = [{"text": "Đà Lạt mát mẻ quanh năm suốt cả năm"}]
        answer = "Đà Lạt mát mẻ quanh năm suốt cả năm theo [5]."
        report = run_hallucination_checks(answer, sources)
        assert report.citation.valid is False
        assert report.overall_confidence <= 0.4


# ════════════════════════════════════════════════════════════════════════════
# Bộ "eval" tổng hợp — mô phỏng đo % câu trả lời bị flag trên 1 batch câu hỏi
# Dùng để có SỐ LIỆU cụ thể khi bảo vệ đồ án (RULE-13)
# ════════════════════════════════════════════════════════════════════════════

EVAL_CASES: list[tuple[str, list[dict], bool]] = [
    # (answer, sources, expected_should_flag)
    (
        "Phú Quốc có nhiều bãi biển đẹp như Bãi Sao, Bãi Dài.",
        [{"text": "Phú Quốc nổi tiếng với các bãi biển đẹp như Bãi Sao và Bãi Dài."}],
        False,
    ),
    (
        "Nên đến Sa Pa vào mùa lúa chín tháng 9-10 để ngắm ruộng bậc thang.",
        [{"text": "Sa Pa đẹp nhất vào mùa lúa chín, khoảng tháng 9 đến tháng 10."}],
        False,
    ),
    (
        "Để đi du lịch Hàn Quốc cần chuẩn bị visa và đặt vé máy bay Vietjet.",
        [{"text": "Đà Nẵng có cầu Rồng và bãi biển Mỹ Khê nổi tiếng."}],
        True,
    ),
    (
        "Khách sạn ở Đà Lạt theo [9] có giá rất rẻ.",
        [{"text": "Đà Lạt có nhiều khách sạn giá rẻ phù hợp sinh viên."}],
        True,
    ),
]


def test_eval_batch_flag_rate():
    """Chạy cả batch câu hỏi/câu trả lời mẫu, in ra tỉ lệ bị flag.

    Đây chính là "Bảng/số liệu minh chứng RAG giảm hallucination" mà
    CHECKLIST_TONG_THE.md mục 5 yêu cầu — assert khoá lại kỳ vọng cho từng
    case, đồng thời in tỉ lệ flag tổng để paste vào báo cáo khi cần.
    """
    flagged_count = 0
    for answer, sources, expected_flag in EVAL_CASES:
        report = run_hallucination_checks(answer, sources)
        assert report.should_flag_for_review == expected_flag, (
            f"Sai kỳ vọng cho answer={answer!r}"
        )
        if report.should_flag_for_review:
            flagged_count += 1

    flag_rate = flagged_count / len(EVAL_CASES)
    print(f"\n[EVAL] {flagged_count}/{len(EVAL_CASES)} câu trả lời bị flag review "
          f"({flag_rate:.0%}).")
    # Batch mẫu được thiết kế cố ý có 2/4 case xấu — khoá lại tỉ lệ kỳ vọng
    # để phát hiện ngay nếu logic guard bị thay đổi không cố ý.
    assert flag_rate == pytest.approx(0.5)


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
