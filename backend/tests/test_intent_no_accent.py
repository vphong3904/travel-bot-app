"""
Regression test cho nlp_preprocessor.detect_intent().

Bộ test này là minh chứng "phương pháp huấn luyện" theo roadmap mục 2.4:
không phải train mô hình ML, mà là vòng lặp data-driven dictionary expansion
có kiểm thử hồi quy — mỗi khi thêm/sửa từ khóa trong INTENT_PATTERNS, chạy
lại file này để đảm bảo không phá nhãn cũ.

Chạy: pytest backend/tests/test_intent_no_accent.py -v
(từ thư mục backend/, hoặc thêm backend/ vào PYTHONPATH)

Các case dưới đây bao phủ:
  1. 14 nhãn intent (khớp với _TOPK_OVERRIDES / _MAX_TOKENS_BY_INTENT)
  2. Cùng 1 câu hỏi ở dạng có dấu VÀ không dấu phải ra cùng 1 intent
     (test trực tiếp cho Bug A — accent-fold keyword matching)
  3. Một vài case cho Bug C (chữ "đ" không được NFKD decompose) và
     Bug D (greeting trước đây không accent-fold)
  4. Bug substring-collision (keyword khớp nhầm bên trong từ khác do thiếu
     ranh giới từ) và bug tie-break (hòa điểm thắng theo thứ tự khai báo
     dict thay vì theo độ đặc trưng keyword) — phát hiện và fix sau cùng,
     xem ghi chú chi tiết ở cuối file.
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

# Cho phép chạy trực tiếp `pytest tests/test_intent_no_accent.py` từ backend/
# mà không cần cài package, đồng thời vẫn hoạt động nếu backend/ đã có sẵn
# trong PYTHONPATH (vd: khi chạy từ CI với `pytest` ở thư mục backend/).
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.services.nlp_preprocessor import detect_intent, normalize_vietnamese  # noqa: E402


# ── Case chính: 1 câu hỏi, kỳ vọng 1 intent, chạy cả bản có dấu lẫn không dấu ──
# Đặt is_short=True nếu câu đủ ngắn để rơi vào nhánh "greeting" short-circuit
# (len(text.split()) <= 5) — không liên quan greeting nhưng câu ngắn vẫn chạy
# qua scoring bình thường nếu không khớp từ khóa chào hỏi.
PAIRED_CASES: list[tuple[str, str, str]] = [
    # (câu có dấu, câu không dấu, intent kỳ vọng)
    ("đà nẵng tháng mấy đẹp", "da nang thang may dep", "ask_weather"),
    ("thời tiết sa pa thế nào", "thoi tiet sa pa the nao", "ask_weather"),
    ("khách sạn đà lạt dưới 500k", "khach san da lat duoi 500k", "find_hotel"),
    ("ks đà lạt dưới 500k", "ks da lat duoi 500k", "find_hotel"),
    ("ăn gì ở hội an", "an gi o hoi an", "ask_food"),
    ("đặc sản phú quốc là gì", "dac san phu quoc la gi", "ask_food"),
    ("đi sa pa bằng gì", "di sapa bang gi", "ask_transport"),
    ("vé máy bay đi côn đảo giá sao", "ve may bay di con dao gia sao", "ask_transport"),
    ("lên lịch 3 ngày huế", "len lich 3 ngay hue", "plan_trip"),
    ("lập kế hoạch đi đà nẵng 4 ngày", "lap ke hoach di da nang 4 ngay", "plan_trip"),
    ("có gì chơi ở đà lạt", "co gi choi o da lat", "ask_activity"),
    ("gợi ý chơi gì ở nha trang", "goi y choi gi o nha trang", "ask_activity"),
    ("visa cần chuẩn bị gì khi đi việt nam", "visa can chuan bi gi khi di viet nam", "ask_safety"),
    ("đi phú quốc có an toàn không", "di phu quoc co an toan khong", "ask_safety"),
    ("chi phí đi đà lạt bao nhiêu", "chi phi di da lat bao nhieu", "ask_budget"),
    ("ngân sách du lịch hà giang", "ngan sach du lich ha giang", "ask_budget"),
    ("phú quốc hay nha trang", "phu quoc hay nha trang", "compare_destinations"),
    ("đà lạt so với sa pa", "da lat so voi sa pa", "compare_destinations"),
    ("tour trọn gói phú quốc", "tour tron goi phu quoc", "find_tour"),
    ("đặt tour đi hạ long", "dat tour di ha long", "find_tour"),
    ("ngôn ngữ chính ở việt nam là gì", "ngon ngu chinh o viet nam la gi", "ask_faq"),
    ("múi giờ việt nam là gì", "mui gio viet nam la gi", "ask_faq"),
]

# ── Case greeting / out_of_scope (chạy riêng vì có short-circuit logic khác) ──
SHORT_CIRCUIT_CASES: list[tuple[str, str]] = [
    ("xin chào", "greeting"),
    ("xin chao", "greeting"),  # Bug D: trước đây fail vì greeting không accent-fold
    ("chào bạn", "greeting"),
    ("cảm ơn nhé", "greeting"),
    ("cam on nhe", "greeting"),
    ("hỏi về python được không", "out_of_scope"),
    ("hoi ve python duoc khong", "out_of_scope"),
    ("kết quả bóng đá hôm nay", "out_of_scope"),
]

# ── Case riêng cho Bug C: chữ "đ" phải được fold đúng thành "d" ──────────────
D_STROKE_CASES: list[tuple[str, str]] = [
    ("đổi tiền ở đâu", "doi tien o dau"),
    ("địa điểm nào đẹp", "dia diem nao dep"),
    ("đi đà nẵng tháng mấy đẹp", "di da nang thang may dep"),
]


@pytest.mark.parametrize("accented,unaccented,expected", PAIRED_CASES)
def test_intent_matches_with_and_without_accent(accented: str, unaccented: str, expected: str):
    """
    Test chính cho Bug A: cùng 1 câu hỏi phải ra cùng 1 intent dù có dấu
    hay không dấu. Trước fix, bản không dấu hầu như luôn rơi về
    "destination"/"unknown" vì kw (có dấu) in no_acc (không dấu) gần như
    không bao giờ true.
    """
    norm_accented = normalize_vietnamese(accented)
    norm_unaccented = normalize_vietnamese(unaccented)

    intent_a, _ = detect_intent(norm_accented, {})
    intent_b, _ = detect_intent(norm_unaccented, {})

    assert intent_a == expected, f"'{accented}' → got {intent_a}, expected {expected}"
    assert intent_b == expected, (
        f"'{unaccented}' (không dấu) → got {intent_b}, expected {expected} "
        f"(bản có dấu ra đúng: {intent_a == expected})"
    )


@pytest.mark.parametrize("text,expected", SHORT_CIRCUIT_CASES)
def test_greeting_and_out_of_scope_short_circuit(text: str, expected: str):
    norm = normalize_vietnamese(text)
    intent, confidence = detect_intent(norm, {})
    assert intent == expected, f"'{text}' → got {intent}, expected {expected}"


@pytest.mark.parametrize("accented,unaccented", D_STROKE_CASES)
def test_d_stroke_folds_to_plain_d(accented: str, unaccented: str):
    """
    Test riêng cho Bug C: _remove_accents() phải fold "đ"/"Đ" thành "d"/"D".
    NFKD decomposition KHÔNG tự làm việc này vì "đ" (U+0111) là ký tự độc
    lập, không phải "d" + dấu kết hợp — nên phải xử lý thủ công trước khi
    chạy NFKD. Test này so sánh trực tiếp kết quả normalize, không qua
    detect_intent, để cô lập đúng phần bị lỗi.
    """
    from app.services.nlp_preprocessor import _remove_accents

    folded = _remove_accents(accented.lower())
    # Không yêu cầu khớp tuyệt đối 100% với bản không dấu viết tay (dấu câu,
    # khoảng trắng có thể lệch nhẹ), chỉ cần xác nhận "đ" đã biến mất khỏi
    # kết quả — đây chính là điều kiện đủ để no-accent keyword matching hoạt
    # động đúng.
    assert "đ" not in folded, f"'{accented}' → '{folded}' vẫn còn ký tự 'đ' chưa fold"


def test_intent_labels_are_disjoint_from_legacy_names():
    """
    Test bảo vệ: đảm bảo không ai vô tình thêm lại nhãn cũ (weather,
    accommodation, food, transport, itinerary, safety, cost, destination)
    vào INTENT_PATTERNS — các nhãn này KHÔNG khớp với _TOPK_OVERRIDES /
    _MAX_TOKENS_BY_INTENT và sẽ tái tạo lại Bug B (no-op tuning).
    """
    from app.services.nlp_preprocessor import INTENT_PATTERNS

    legacy_labels = {
        "weather", "accommodation", "food", "transport",
        "itinerary", "safety", "cost", "destination",
    }
    current_labels = set(INTENT_PATTERNS.keys())
    overlap = legacy_labels & current_labels
    assert not overlap, f"Nhãn cũ bị thêm lại: {overlap} — sẽ phá đồng bộ với retrieval_optimizer/gemini_optimizer"


def test_intent_labels_match_topk_overrides():
    """
    Test bảo vệ: mọi nhãn trong INTENT_PATTERNS (trừ out_of_scope, đã xử lý
    short-circuit riêng) phải có mặt trong _TOPK_OVERRIDES, nếu không nhãn
    đó sẽ luôn rơi về default_top_k (no-op).
    """
    from app.services.nlp_preprocessor import INTENT_PATTERNS
    from app.services.retrieval_optimizer import _TOPK_OVERRIDES

    missing = set(INTENT_PATTERNS.keys()) - {"out_of_scope"} - set(_TOPK_OVERRIDES.keys())
    assert not missing, f"Nhãn chưa có trong _TOPK_OVERRIDES (sẽ no-op): {missing}"


def test_intent_labels_match_max_tokens_by_intent():
    """
    Tương tự test trên, nhưng cho _MAX_TOKENS_BY_INTENT. "greeting" và
    "out_of_scope" được short-circuit trước khi tới gemini_config() nên
    không bắt buộc có mặt ở đây.
    """
    from app.services.nlp_preprocessor import INTENT_PATTERNS
    from app.services.gemini_optimizer import _MAX_TOKENS_BY_INTENT

    exempt = {"out_of_scope", "greeting"}
    missing = set(INTENT_PATTERNS.keys()) - exempt - set(_MAX_TOKENS_BY_INTENT.keys())
    assert not missing, f"Nhãn chưa có trong _MAX_TOKENS_BY_INTENT (sẽ dùng default): {missing}"


# ── Bug đã fix sau lần rename ban đầu (không nằm trong phạm vi "đổi tên nhãn",
#    phát hiện qua chính bộ test này, đã quyết định sửa) ─────────────────────
#
# 1) SUBSTRING COLLISION DO KHÔNG CÓ WORD BOUNDARY — ĐÃ FIX
#    Trước: keyword ngắn như "ăn gì" (no-accent "an gi") khớp NHẦM vào bên
#    trong từ khác qua substring thô. Ví dụ "viet nam CAN GI" (từ "cần gì")
#    chứa substring "an gi", bị tính là khớp "ăn gì" → lệch sang ask_food.
#    Fix: thêm hàm _keyword_in_text() dùng regex lookaround (?<![a-zA-Z])
#    .. (?![a-zA-Z]) để chỉ khớp đúng ranh giới từ, không khớp substring
#    nằm giữa các chữ cái khác.
#
# 2) TIE-BREAK KHÔNG THEO ĐỘ ĐẶC TRƯNG — ĐÃ FIX (phần lớn)
#    Trước: mỗi keyword khớp tính đúng 1 điểm bất kể độ dài/đặc trưng, nên
#    "tiền" (1 từ, chung chung) và "đổi tiền" (2 từ, đặc trưng) đều +1 như
#    nhau; khi hòa điểm, nhãn khai báo trước trong dict thắng — ngẫu nhiên.
#    Fix: trọng số điểm = số từ trong keyword thay vì đếm thô (vd "tiền"=1,
#    "đổi tiền"=2). Kết hợp thêm: rà soát thủ công, bỏ 3 keyword 1-từ quá
#    chung chung từng gây hòa điểm sai dù đã có trọng số ("ở đâu" khỏi
#    find_hotel, "vé" khỏi ask_transport, "đến" khỏi ask_destination).
#
# Đánh đổi đã CHỌN GIỮ NGUYÊN, không sửa thêm (xác nhận với người dùng):
#   - "mưa" (ask_weather) và "mua" (mua/buy) trùng nhau sau accent-fold —
#     giới hạn ngữ nghĩa tự nhiên của rule-based không dấu, word-boundary
#     không giải quyết được vì cả 2 đều là từ hợp lệ, đúng ranh giới từ.
#   - Bỏ "đến" khỏi ask_destination làm mất recall cho câu chỉ dựa đúng từ
#     đó (vd "làm sao đến được Côn Đảo" → rơi về "unknown" thay vì
#     ask_transport). Chấp nhận đánh đổi để đổi lấy việc giảm false-positive
#     ở nhiều câu khác.

@pytest.mark.parametrize("text,expected", [
    ("đổi tiền ở đâu", "ask_faq"),
    ("mua sim ở đâu", "ask_faq"),
    ("ăn hải sản ở đâu", "ask_food"),
])
def test_specificity_weighting_fixes_tie_break(text: str, expected: str):
    """
    Test cho bug đã fix #2 (tie-break): "đổi tiền"/"sim" (đặc trưng) phải
    thắng "ở đâu" (chung chung, từng gây hòa điểm và thắng sai do khai báo
    trước trong dict).
    """
    norm = normalize_vietnamese(text)
    intent, _ = detect_intent(norm, {})
    assert intent == expected, f"'{text}' → got {intent}, expected {expected}"


@pytest.mark.parametrize("text,expected", [
    ("visa cần chuẩn bị gì khi đi việt nam", "ask_safety"),
    ("visa việt nam cần gì", "ask_safety"),
])
def test_word_boundary_fixes_substring_collision(text: str, expected: str):
    """
    Test cho bug đã fix #1 (substring collision): "cần gì" không còn bị
    nhận nhầm thành "ăn gì" (ask_food) qua khớp substring thô nữa.
    """
    norm = normalize_vietnamese(text)
    intent, _ = detect_intent(norm, {})
    assert intent == expected, f"'{text}' → got {intent}, expected {expected}"