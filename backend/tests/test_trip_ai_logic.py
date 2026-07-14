"""Unit tests thuần logic cho Trip AI (TP-001/003) — không cần DB/Gemini."""
from datetime import date

from app.services.trip_planner_service import (
    _validate_ai_schedule,
    ai_select_schedule,
    detect_missing_slots,
    estimate_total_cost,
    normalize_group_size,
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


# ── Quy mô nhóm (không nhân chi phí tự do theo đầu người) ────────────────────

def test_normalize_group_size_solo_couple_fixed():
    assert normalize_group_size("solo", 5) == ("solo", 1)       # solo luôn 1
    assert normalize_group_size("couple", 10) == ("couple", 2)  # couple luôn 2


def test_normalize_group_size_family_clamped_3_to_7():
    assert normalize_group_size("family", None) == ("family", 4)   # mặc định
    assert normalize_group_size("family", 5) == ("family", 5)      # trong khoảng giữ nguyên
    assert normalize_group_size("group", 20) == ("group", 7)       # ép trần 7
    assert normalize_group_size("group", 1) == ("group", 3)        # ép sàn 3


def test_normalize_group_size_infers_type_from_travelers():
    assert normalize_group_size("", 1) == ("solo", 1)
    assert normalize_group_size("", 2) == ("couple", 2)
    assert normalize_group_size("", 15) == ("group", 7)
    assert normalize_group_size("", None) == ("solo", 1)


# ── AI schedule selection (hybrid) — fallback rule-based khi LLM lỗi ─────────

async def test_ai_select_schedule_falls_back_when_gemini_unavailable(monkeypatch):
    # Mock _get_genai_client lỗi (giả lập Gemini down/hết quota) -> None,
    # build_plan tự fallback về schedule_days rule-based. Không bao giờ crash.
    # (Mock thay vì dựa vào thiếu GEMINI_API_KEY vì máy dev có thể đã cấu hình
    # key thật trong .env — gọi thật sẽ chậm/tốn quota trong unit test.)
    from app.services import rag_pipeline

    def _boom():
        raise RuntimeError("gemini unavailable (mocked)")

    monkeypatch.setattr(rag_pipeline, "_get_genai_client", _boom)
    result = await ai_select_schedule(
        days_count=3,
        sights=_fake_sights(6),
        eateries=_fake_eateries(3),
        hotel=_fake_hotel(),
        travelers=2,
        budget=5_000_000,
        preferences=["biển"],
        destination_name="Đà Lạt",
    )
    assert result is None


def test_validate_ai_schedule_rejects_repeat_when_enough_candidates():
    sights = _fake_sights(6)
    hotel = _fake_hotel()
    days = schedule_days(3, sights, [], hotel)
    # Ép lặp lại 1 sight dù có đủ 6 sight cho 3 ngày (2 sight/ngày = 6 slot)
    loc_items = [it for d in days for it in d["items"] if it["type"] == "location"]
    loc_items[-1]["ref_id"] = loc_items[0]["ref_id"]
    assert _validate_ai_schedule(days, 3, sights, []) is False


def test_validate_ai_schedule_allows_repeat_when_not_enough_candidates():
    sights = _fake_sights(2)  # ít hơn nhu cầu 3 ngày -> cho phép lặp/free
    hotel = _fake_hotel()
    days = schedule_days(3, sights, [], hotel)
    assert _validate_ai_schedule(days, 3, sights, []) is True


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


def test_chat_post_plan_edit_continues_planning():
    # Sau khi plan xong (reply gắn PLAN_DONE_MARKER), câu SỬA (đổi ngày/người/
    # nơi/ngân sách) vẫn ở luồng lên lịch dù không gõ lại "lên lịch trình".
    history = [
        {"role": "user", "content": "lên lịch trình đà nẵng 3 ngày cho 2 người"},
        {"role": "assistant", "content": f"{tcp.PLAN_DONE_MARKER} Mình đã lên **Đà Nẵng 3 ngày**..."},
    ]
    assert tcp.is_planning_turn(history, "cho 5 ngày đi")     # đổi ngày
    assert tcp.is_planning_turn(history, "qua đà lạt đi")     # đổi nơi
    assert tcp.is_planning_turn(history, "2 người thôi")      # đổi số người


def test_chat_post_plan_unrelated_question_exits_to_rag():
    # Sau khi plan xong, câu HỎI khác (không phải sửa) → thoát về RAG.
    history = [
        {"role": "user", "content": "lên lịch trình đà nẵng 3 ngày"},
        {"role": "assistant", "content": f"{tcp.PLAN_DONE_MARKER} Mình đã lên **Đà Nẵng 3 ngày**..."},
    ]
    assert not tcp.is_planning_turn(history, "đà nẵng có món gì ngon không")
    assert not tcp.is_planning_turn(history, "cảm ơn nhé")


def test_chat_item_swap_request_detected():
    # "đổi khách sạn khác" = đổi riêng 1 mục → không re-plan (hướng bấm nút Đổi).
    assert tcp._is_item_swap_request("đổi khách sạn khác đi")
    assert tcp._is_item_swap_request("thay quán ăn khác được không")
    # nhưng đổi kèm tham số chuyến thì KHÔNG phải item-swap (để re-plan xử lý):
    assert not tcp._is_item_swap_request("đổi qua đà lạt")
    assert not tcp._is_item_swap_request("đổi thành 5 ngày")


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


def test_chat_collect_slots_ignores_pre_trigger_messages():
    # Bug đã sửa: số liệu từ câu hỏi KHÁC trước đó (không phải lượt lên lịch)
    # rò rỉ vào plan. Ở đây "1 ngày" + "500k" nằm trong câu hỏi KHÁCH SẠN, và
    # "4 người" trong câu vu vơ — đều TRƯỚC câu trigger "lên lịch trình". Slot
    # chỉ được lấy từ câu trigger trở đi → days/budget/travelers KHÔNG bị nhiễm.
    history = [
        {"role": "user", "content": "khách sạn nào ở hội an 1 ngày 500k không?"},
        {"role": "assistant", "content": "(rag) vài khách sạn..."},
        {"role": "user", "content": "đi 4 người có phòng lớn không"},
        {"role": "assistant", "content": "(rag) có..."},
    ]
    slots = tcp.collect_slots(history, "lên lịch trình đi hội an")
    assert slots["destination"] == "Hội An"
    assert slots.get("days") is None          # KHÔNG lấy "1 ngày" từ câu khách sạn
    assert slots.get("budget") is None        # KHÔNG lấy "500k"
    assert slots.get("travelers") is None     # KHÔNG lấy "4 người"


def test_chat_collect_slots_within_planning_flow_accumulates():
    # Trong CÙNG lượt lên lịch (sau trigger), câu trả lời ngắn vẫn được gộp.
    history = [
        {"role": "user", "content": "lên lịch trình đi đà nẵng"},
        {"role": "assistant", "content": f"{tcp.PLANNER_MARKER} Đà Nẵng mấy ngày?"},
        {"role": "user", "content": "3 ngày"},
        {"role": "assistant", "content": f"{tcp.PLANNER_MARKER} Đi mấy người?"},
    ]
    slots = tcp.collect_slots(history, "gia đình 4 người thích biển")
    assert slots["destination"] == "Đà Nẵng"
    assert slots["days"] == 3
    assert slots["travelers"] == 4
    assert slots["travel_type"] == "family"
    assert "biển" in slots["preferences"]


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


def test_chat_itinerary_payload_ai_plan_has_image_hotel_alternatives():
    # Bug đã sửa: ai_plan trước đây thiếu destination_image/hotel/alternatives
    # nên FE không render được ảnh/đổi lựa chọn khi plan đến từ chat (chỉ
    # AiPlannerScreen có, vì gọi thẳng build_plan → thiếu đồng bộ giữa 2 nơi).
    plan = {
        "title": "Đà Lạt 2 ngày", "destination_id": "d1", "destination_name": "Đà Lạt",
        "destination_image": "https://example.com/dalat.jpg",
        "days_count": 2, "travelers": 2, "travel_type": "couple", "budget": 5_000_000,
        "estimated_cost": 4_800_000, "start_date": None, "end_date": None, "summary": None,
        "budget_warning": None,
        "hotel": {"id": "h1", "name": "KS Test", "price_per_night": 500_000,
                   "stars": 3, "image_url": "https://example.com/hotel.jpg"},
        "days": [{"day_number": 1, "items": [
            {"time_slot": "morning", "title": "Điểm A", "type": "location"}]}],
        "alternatives": {"hotels": [{"id": "h2", "name": "KS Khác"}],
                          "restaurants": [], "locations": []},
    }
    payload = tcp._to_itinerary_payload(plan)
    ai_plan = payload["ai_plan"]
    assert ai_plan["destination_image"] == "https://example.com/dalat.jpg"
    assert ai_plan["hotel"]["image_url"] == "https://example.com/hotel.jpg"
    assert ai_plan["alternatives"]["hotels"][0]["name"] == "KS Khác"


def test_chat_itinerary_payload_is_json_serializable_with_decimal_and_date():
    # Bug đã sửa (gây "network error" giữa stream): giá lấy từ DB là cột NUMERIC
    # → Decimal, và start_date/end_date có thể là date. Payload chat đi thẳng qua
    # json.dumps thô (format_sse + lưu cột JSON chat_sessions.last_itinerary),
    # KHÔNG qua FastAPI jsonable_encoder → Decimal/date làm json.dumps raise
    # TypeError, backend crash giữa chừng SSE, client thấy "network error".
    import json
    from datetime import date
    from decimal import Decimal

    plan = {
        "title": "Hội An 3 ngày", "destination_id": "d1", "destination_name": "Hội An",
        "destination_image": None,
        "days_count": 3, "travelers": 4, "travel_type": "family",
        "budget": 4_600_000, "estimated_cost": Decimal("4550000"),
        "start_date": date(2026, 7, 14), "end_date": date(2026, 7, 16),
        "summary": None, "budget_warning": None,
        "hotel": {"id": "h1", "name": "KS Test",
                   "price_per_night": Decimal("850000.00"), "rating": Decimal("4.5"),
                   "stars": 3},
        "days": [{"day_number": 1, "items": [
            {"time_slot": "morning", "title": "Phố cổ", "type": "location",
             "estimated_cost": Decimal("120000")}]}],
        "alternatives": {
            "hotels": [{"id": "h2", "name": "KS Khác",
                         "price_per_night": Decimal("650000"), "rating": Decimal("4.1")}],
            "restaurants": [], "locations": [],
        },
    }
    payload = tcp._to_itinerary_payload(plan)
    # Không được raise — đây chính là chỗ trước đây vỡ:
    dumped = json.dumps(payload, ensure_ascii=False)
    assert dumped
    # Decimal nguyên → int, giữ giá trị:
    assert payload["ai_plan"]["estimated_cost"] == 4_550_000
    assert payload["ai_plan"]["hotel"]["price_per_night"] == 850_000
    assert payload["ai_plan"]["hotel"]["rating"] == 4.5
    # date → ISO string:
    assert payload["ai_plan"]["start_date"] == "2026-07-14"
    assert payload["ai_plan"]["days"][0]["items"][0]["estimated_cost"] == 120_000
