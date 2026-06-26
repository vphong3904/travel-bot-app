"""
Hallucination Guard — YÊU CẦU 3.

Hai lớp phòng thủ:
  1. Trước khi sinh câu trả lời: filter_by_dynamic_threshold() lọc bớt kết quả
     Qdrant có score quá thấp (không đáng tin), và annotate_fallback_sources()
     đánh dấu rõ nguồn nào đến từ PostgreSQL FTS (chỉ "gần đúng" về từ khoá,
     không đảm bảo về ngữ nghĩa) để Gemini/Frontend thận trọng hơn.
  2. Sau khi sinh câu trả lời: run_hallucination_checks() kiểm tra:
     - Grounding: câu trả lời có "bám" vào context được cung cấp không
       (heuristic dựa trên token overlap — không cần thêm model/API call).
     - Citation: nếu câu trả lời có trích dẫn dạng [1], [2]... thì các chỉ số
       đó phải nằm trong phạm vi số lượng nguồn thực tế.
"""

from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass, field

# Ngưỡng động: ưu tiên cao hơn nếu có kết quả tốt, fallback thấp hơn nếu KB mỏng
PRIMARY_THRESHOLD = 0.45
FALLBACK_THRESHOLD = 0.30

# Dưới ngưỡng này, dù có trả về cũng luôn đánh dấu approximate
APPROXIMATE_SCORE_CEILING = 0.40

_STOPWORDS = {
    "có", "không", "là", "và", "hoặc", "của", "để", "cho", "với", "thì", "mà",
    "nên", "cần", "muốn", "hỏi", "biết", "thế", "nào", "này", "đó", "các",
    "một", "những", "rất", "cũng", "khi", "đã", "sẽ", "tôi", "mình", "bạn",
    "ở", "tại", "đi", "về", "the", "a", "an", "is", "are", "of", "to", "in",
}


def _tokenize(text: str) -> set[str]:
    text = unicodedata.normalize("NFC", text.lower())
    words = re.findall(r"[\wÀ-ỹ]+", text)
    return {w for w in words if len(w) > 1 and w not in _STOPWORDS}


# ── Lớp 1: lọc trước khi build prompt ───────────────────────────────────────

def filter_by_dynamic_threshold(hits: list[dict]) -> tuple[list[dict], float]:
    """
    Nếu có ít nhất 1 hit đạt PRIMARY_THRESHOLD → dùng ngưỡng cao (chất lượng tốt).
    Nếu không có hit nào đạt ngưỡng cao nhưng có hit ở mức thấp hơn → hạ ngưỡng
    xuống FALLBACK_THRESHOLD để tránh "0 results" (KB còn mỏng).
    """
    if not hits:
        return [], PRIMARY_THRESHOLD

    has_high_quality = any(h.get("score", 0) >= PRIMARY_THRESHOLD for h in hits)
    threshold = PRIMARY_THRESHOLD if has_high_quality else FALLBACK_THRESHOLD

    filtered = [h for h in hits if h.get("score", 0) >= threshold]
    return filtered, threshold


def annotate_fallback_sources(results: list[dict]) -> list[dict]:
    """Đánh dấu is_approximate=True cho nguồn từ PostgreSQL FTS hoặc Qdrant
    score thấp — Gemini/Frontend sẽ hiển thị/sử dụng thận trọng hơn."""
    annotated = []
    for r in results:
        r = dict(r)
        is_pg = r.get("source") == "postgres_fts"
        is_low_score = r.get("score", 1.0) < APPROXIMATE_SCORE_CEILING
        r["is_approximate"] = bool(is_pg or is_low_score)
        annotated.append(r)
    return annotated


# ── Lớp 2: kiểm tra sau khi sinh câu trả lời ────────────────────────────────

@dataclass
class GroundingResult:
    is_grounded: bool
    confidence: float
    ungrounded_terms: list[str] = field(default_factory=list)


@dataclass
class CitationResult:
    valid: bool
    invalid_indices: list[int] = field(default_factory=list)


@dataclass
class HallucinationReport:
    grounding: GroundingResult
    citation: CitationResult
    overall_confidence: float
    should_flag_for_review: bool


def _check_grounding(answer: str, sources: list[dict]) -> GroundingResult:
    if not sources:
        # Không có context mà vẫn trả lời dài/cụ thể → rủi ro cao, nhưng đây
        # là pipeline tạo từ câu hỏi out-of-context, không có cách verify thêm
        # ngoài cảnh báo confidence thấp.
        return GroundingResult(is_grounded=True, confidence=0.6, ungrounded_terms=[])

    context_tokens: set[str] = set()
    for s in sources:
        context_tokens |= _tokenize(s.get("text", ""))

    answer_tokens = _tokenize(answer)
    if not answer_tokens:
        return GroundingResult(is_grounded=True, confidence=1.0, ungrounded_terms=[])

    overlap = answer_tokens & context_tokens
    ratio = len(overlap) / len(answer_tokens)

    # ratio thấp không tự động nghĩa là hallucination (câu trả lời có thể paraphrase
    # hợp lý), nhưng dùng làm confidence heuristic nhẹ.
    confidence = min(1.0, 0.4 + ratio)
    is_grounded = ratio >= 0.15

    ungrounded_sample = list(answer_tokens - context_tokens)[:5]
    return GroundingResult(
        is_grounded=is_grounded,
        confidence=round(confidence, 3),
        ungrounded_terms=ungrounded_sample if not is_grounded else [],
    )


def _check_citations(answer: str, sources: list[dict]) -> CitationResult:
    """Câu trả lời có thể chứa trích dẫn dạng [1], [2]... khớp với index nguồn
    trong _build_prompt (1-indexed). Nếu chỉ số trích dẫn vượt quá số nguồn
    thực tế → coi là citation không hợp lệ (model có thể đang bịa nguồn)."""
    indices = [int(m) for m in re.findall(r"\[(\d+)\]", answer)]
    if not indices:
        return CitationResult(valid=True, invalid_indices=[])

    n_sources = len(sources)
    invalid = [i for i in indices if i < 1 or i > n_sources]
    return CitationResult(valid=len(invalid) == 0, invalid_indices=sorted(set(invalid)))


def run_hallucination_checks(answer: str, sources: list[dict]) -> HallucinationReport:
    grounding = _check_grounding(answer, sources)
    citation = _check_citations(answer, sources)

    overall_confidence = grounding.confidence
    if not citation.valid:
        overall_confidence = min(overall_confidence, 0.4)

    should_flag = (not grounding.is_grounded and bool(sources)) or (not citation.valid) or overall_confidence < 0.4

    return HallucinationReport(
        grounding=grounding,
        citation=citation,
        overall_confidence=round(overall_confidence, 3),
        should_flag_for_review=should_flag,
    )
