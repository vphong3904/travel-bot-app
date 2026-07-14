"""Unit test thuần logic cho Destination Advisor (tư vấn điểm đến trong chat).

Không cần DB/Gemini: phần detection + formatter là hàm thuần; phần handler
được test bằng cách monkeypatch các hàm truy vấn DB.
"""
import app.services.destination_advisor as adv
from app.services.destination_advisor import (
    AdvisoryQuery,
    _fmt_best_months,
    _fmt_vnd,
    _matched_tags,
    _per_day_range,
    detect_advisory,
    handle_advisory_turn,
)


# ══════════════════════════════════════════════════════════════════════════════
# DETECTION
# ══════════════════════════════════════════════════════════════════════════════

def test_feasibility_named_dest_with_budget():
    q = detect_advisory("tôi chỉ có 4 triệu muốn đi đà lạt được không")
    assert q is not None and q.mode == "feasibility"
    assert q.destination and "lạt" in q.destination.lower()
    assert q.budget == 4_000_000


def test_feasibility_named_dest_without_budget():
    q = detect_advisory("đà lạt có nên đi không")
    assert q is not None and q.mode == "feasibility"
    assert q.budget is None


def test_recommend_by_budget():
    q = detect_advisory("có 3 triệu thì đi đâu được")
    assert q is not None and q.mode == "recommend"
    assert q.budget == 3_000_000
    assert q.destination is None


def test_recommend_by_preference():
    q = detect_advisory("mình thích tắm biển thì nên đi đâu")
    assert q is not None and q.mode == "recommend"
    assert "biển" in q.preferences


def test_recommend_by_days():
    q = detect_advisory("cuối tuần rảnh 2 ngày đi đâu gần")
    assert q is not None and q.mode == "recommend"
    assert q.days == 2


def test_negative_info_question_about_named_dest():
    # "Đà Lạt có gì chơi" là câu hỏi thông tin → nhường RAG (None).
    assert detect_advisory("đà lạt có gì chơi") is None
    assert detect_advisory("đà lạt ăn gì ngon") is None


def test_negative_planner_trigger_yields_to_planner():
    # Có "lịch trình" → planner lo, advisor không bắt.
    assert detect_advisory("lên lịch trình đi đà lạt 3 ngày") is None


def test_negative_non_travel_budget():
    # Ngân sách nhưng không có bối cảnh du lịch → không bắt.
    assert detect_advisory("tôi có 4 triệu mua điện thoại nào") is None


# ══════════════════════════════════════════════════════════════════════════════
# FORMATTERS
# ══════════════════════════════════════════════════════════════════════════════

def test_fmt_vnd():
    assert _fmt_vnd(4_000_000) == "4 triệu"
    assert _fmt_vnd(4_500_000) == "4.5 triệu"
    assert _fmt_vnd(500_000) == "500k"
    assert _fmt_vnd(None) == "—"


def test_fmt_best_months_wrap_range():
    # [11,12,1,2,3] là dải liên tục bao vòng cuối năm.
    assert _fmt_best_months([11, 12, 1, 2, 3]) == "tháng 11 đến tháng 3"


def test_fmt_best_months_simple_range():
    assert _fmt_best_months([6, 7, 8]) == "tháng 6 đến tháng 8"


def test_fmt_best_months_single_and_empty():
    assert _fmt_best_months([9]) == "tháng 9"
    assert _fmt_best_months(None) is None
    assert _fmt_best_months([]) is None


def test_per_day_range_fallback_when_null():
    low, high = _per_day_range({"budget_low": None, "budget_high": None})
    assert low == adv.FALLBACK_PER_DAY_LOW and high == adv.FALLBACK_PER_DAY_HIGH


def test_matched_tags():
    blob = adv.strip_accents("biển xanh cát trắng bãi tắm đẹp")
    assert "biển" in _matched_tags(blob, ["biển", "núi"])
    assert "núi" not in _matched_tags(blob, ["biển", "núi"])


# ══════════════════════════════════════════════════════════════════════════════
# HANDLERS (monkeypatch DB access)
# ══════════════════════════════════════════════════════════════════════════════

_DA_LAT = {
    "id": "d1", "name": "Đà Lạt", "province": "Lâm Đồng", "region": "Tây Nguyên",
    "description": "cao nguyên mát mẻ, rừng thông, săn mây healing",
    "special": "thành phố ngàn hoa", "best_months": [11, 12, 1, 2, 3],
    "budget_low": 700_000, "budget_high": 1_400_000, "image_url": None,
    "rating_avg": 4.6, "favorite_count": 120, "review_count": 50,
}
_NHA_TRANG = {
    "id": "d2", "name": "Nha Trang", "province": "Khánh Hòa", "region": "Nam Trung Bộ",
    "description": "biển xanh cát trắng bãi tắm lặn biển san hô",
    "special": "vịnh đẹp", "best_months": [6, 7, 8],
    "budget_low": 900_000, "budget_high": 1_800_000, "image_url": None,
    "rating_avg": 4.4, "favorite_count": 90, "review_count": 40,
}


async def test_feasibility_reply_enough_days(monkeypatch):
    async def fake_resolve(db, name):
        return _DA_LAT

    monkeypatch.setattr(adv, "resolve_destination", fake_resolve)
    res = await handle_advisory_turn(None, "u1", "4 triệu đi đà lạt được không")
    assert res is not None
    assert res["intent"] == "ask_destination"
    assert "Đà Lạt" in res["reply"]
    assert "ngày" in res["reply"]
    assert res["suggestions"] and res["suggestions"][0]["name"] == "Đà Lạt"


async def test_feasibility_unknown_dest_yields_to_rag(monkeypatch):
    async def fake_resolve(db, name):
        return None

    monkeypatch.setattr(adv, "resolve_destination", fake_resolve)
    res = await handle_advisory_turn(None, "u1", "5 triệu đi nơi xyz được không")
    assert res is None  # không rõ điểm đến → nhường RAG


async def test_recommend_prefers_matching_preference(monkeypatch):
    async def fake_fetch(db):
        return [dict(_DA_LAT), dict(_NHA_TRANG)]

    monkeypatch.setattr(adv, "_fetch_active_destinations", fake_fetch)
    res = await handle_advisory_turn(None, "u1", "thích tắm biển thì đi đâu")
    assert res is not None
    # Nha Trang (biển) phải xuất hiện và đứng trước Đà Lạt trong text.
    assert "Nha Trang" in res["reply"]
    assert res["reply"].index("Nha Trang") < res["reply"].index("Đà Lạt")


async def test_recommend_budget_filter(monkeypatch):
    async def fake_fetch(db):
        return [dict(_DA_LAT), dict(_NHA_TRANG)]

    monkeypatch.setattr(adv, "_fetch_active_destinations", fake_fetch)
    # 2 triệu / 3 ngày / 1 người ≈ 667k/ngày < budget_low cả hai → vẫn trả gợi ý
    # (không rỗng), ưu tiên nơi rẻ hơn.
    res = await handle_advisory_turn(None, "u1", "có 2 triệu đi đâu du lịch")
    assert res is not None and res["suggestions"]
