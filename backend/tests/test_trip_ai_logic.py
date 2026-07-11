"""Unit tests thuần logic cho Trip AI (TP-001/003) — không cần DB/Gemini."""
from datetime import date

from app.services.trip_planner_service import (
    detect_missing_slots,
    estimate_total_cost,
    questions_for,
    schedule_days,
)
from app.services.user_preference_service import (
    PREFERENCE_TAXONOMY,
    _finalize,
    keywords_for_tags,
    score_text,
    strip_accents,
)


# ── Slot filling (TR-03) ──────────────────────────────────────────────────────

def test_missing_required_slots():
    missing, _ = detect_missing_slots({}, skip_optional=True)
    assert "destination" in missing and "days" in missing
    assert questions_for(missing)  # có câu hỏi tiếng Việt tương ứng


def test_days_from_date_range():
    missing, slots = detect_missing_slots(
        {"destination": "Đà Lạt", "start_date": date(2026, 8, 1),
         "end_date": date(2026, 8, 3)},
        skip_optional=True,
    )
    assert missing == []
    assert slots["days"] == 3
    assert slots["travelers"] == 1          # default khi skip_optional
    assert slots["travel_type"] == "solo"


def test_optional_slots_asked_when_not_skipped():
    missing, _ = detect_missing_slots({"destination": "Huế", "days": 2})
    assert set(missing) == {"budget", "travelers", "travel_type", "preferences"}


def test_invalid_travel_type_falls_back():
    _, slots = detect_missing_slots(
        {"destination": "Huế", "days": 2, "travel_type": "abc"}, skip_optional=True
    )
    assert slots["travel_type"] == "solo"


# ── Sắp lịch (TR-01: chỉ dùng entity truyền vào, không lặp) ──────────────────

def _fake_sights(n):
    return [{"id": f"s{i}", "name": f"Điểm {i}", "type": "sightseeing",
             "description": "", "tips": None, "image_url": None, "address": None,
             "rating_avg": 5 - i * 0.1, "price_adult": 50000, "hours": None}
            for i in range(n)]


def _fake_eateries(n):
    return [{"id": f"r{i}", "name": f"Quán {i}", "type": "restaurant",
             "address": None, "price_range": "50k-100k", "rating": 4.5,
             "image_url": None, "specialties": "bánh căn"}
            for i in range(n)]


def _fake_hotel():
    return {"id": "h1", "name": "Hotel Test", "price_per_night": 500_000,
            "stars": 3, "rating": 4.2, "address": "123", "description": "",
            "image_url": None, "type": "hotel"}


def test_schedule_days_structure():
    days = schedule_days(3, _fake_sights(10), _fake_eateries(4), _fake_hotel())
    assert len(days) == 3
    # ngày 1 có nhận phòng
    assert days[0]["items"][0]["type"] == "hotel_checkin"
    # mỗi ngày có morning + lunch + afternoon + evening
    for d in days:
        slots = [it["time_slot"] for it in d["items"]]
        for expected in ("morning", "lunch", "afternoon", "evening"):
            assert expected in slots, f"Ngày {d['day_number']} thiếu {expected}"
    # location không lặp lại giữa các ngày
    loc_ids = [it["ref_id"] for d in days for it in d["items"] if it["type"] == "location"]
    assert len(loc_ids) == len(set(loc_ids))


def test_schedule_days_empty_db_uses_free_slots():
    """DB không có dữ liệu → item type=free có ghi chú, không bịa entity (TR-01)."""
    days = schedule_days(2, [], [], None)
    for d in days:
        for it in d["items"]:
            assert it["type"] == "free"
            assert it["ref_id"] is None
            assert it["notes"]


def test_estimate_total_cost():
    days = schedule_days(3, _fake_sights(6), _fake_eateries(3), _fake_hotel())
    total = estimate_total_cost(3, 2, _fake_hotel(), days)
    # hotel 2 đêm × 500k × 1 phòng = 1tr; vé + ăn > 0
    assert total > 1_000_000


# ── Preference scoring (TP-003) ───────────────────────────────────────────────

def test_strip_accents():
    assert strip_accents("Đà Lạt ngắm mây") == "da lat ngam may"


def test_score_text_matches_beach_and_healing():
    scores = score_text("tôi muốn đi biển chill healing ngắm mây ngắm hoa", weight=3.0)
    assert scores.get("biển")
    assert scores.get("healing")
    assert scores.get("thiên_nhiên")


def test_finalize_top3_normalized():
    profile = _finalize({"biển": 9.0, "healing": 6.0, "núi": 3.0, "mua_sắm": 0.1})
    assert [p["tag"] for p in profile] == ["biển", "healing", "núi"]
    assert profile[0]["score"] == 1.0
    assert all(0 < p["score"] <= 1 for p in profile)


def test_keywords_for_tags_only_known_tags():
    kws = keywords_for_tags(["biển", "tag_không_tồn_tại"])
    assert kws and all(isinstance(k, str) for k in kws)


def test_taxonomy_keywords_are_accent_free_lowercase():
    for tag, cfg in PREFERENCE_TAXONOMY.items():
        for kw in cfg["keywords"]:
            assert kw == strip_accents(kw), f"{tag}: keyword '{kw}' chưa bỏ dấu"


# ── Chat planner (Req 2) ──────────────────────────────────────────────────────

from app.services import trip_chat_planner as tcp  # noqa: E402


def test_chat_trigger_detection():
    assert tcp.is_planning_turn([], "giúp tôi lên lịch trình đà lạt")
    assert not tcp.is_planning_turn([], "thời tiết đà lạt hôm nay thế nào")


def test_chat_continues_after_planner_question():
    # câu hỏi trợ lý gắn marker → lượt sau vẫn ở chế độ lên lịch dù không có trigger
    history = [
        {"role": "user", "content": "lên lịch trình"},
        {"role": "assistant", "content": f"{tcp.PLANNER_MARKER} Bạn muốn đi đâu?"},
    ]
    assert tcp.is_planning_turn(history, "đà lạt")


def test_chat_budget_extractors():
    assert tcp._extract_budget("ngân sách 5 triệu") == 5_000_000
    assert tcp._extract_budget("tầm 500k") == 500_000
    assert tcp._extract_budget("khoảng 3.000.000") == 3_000_000
    assert tcp._extract_budget("không rõ") is None


def test_chat_travelers_and_type():
    assert tcp._extract_travelers("đi 4 người") == 4
    assert tcp._extract_travel_type("đi gia đình") == "family"
    assert tcp._extract_travel_type("cặp đôi tụi mình") == "couple"


def test_chat_collect_slots_cumulative():
    history = [{"role": "user", "content": "lên lịch trình đà lạt 3 ngày"}]
    slots = tcp.collect_slots(history, "đi 2 người thích biển chill")
    assert slots["destination"] == "Đà Lạt"
    assert slots["days"] == 3
    assert slots["travelers"] == 2
    assert "biển" in slots["preferences"] and "healing" in slots["preferences"]


def test_chat_itinerary_payload_has_ai_plan():
    plan = {
        "title": "Đà Lạt 2 ngày", "destination_id": "d1", "destination_name": "Đà Lạt",
        "days_count": 2, "travelers": 2, "travel_type": "couple", "budget": None,
        "estimated_cost": 1_500_000, "start_date": None, "end_date": None, "summary": None,
        "hotel": {"id": "h1", "name": "KS Test", "price_per_night": 500_000, "stars": 3},
        "days": [{"day_number": 1, "items": [
            {"time_slot": "morning", "title": "Điểm A", "type": "location"}]}],
    }
    payload = tcp._to_itinerary_payload(plan)
    assert payload["destination"] == "Đà Lạt"
    assert payload["ai_plan"]["days_count"] == 2
    assert payload["days"][0]["activities"][0].startswith("Sáng:")
