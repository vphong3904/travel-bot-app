"""
Destination Advisor — tư vấn ĐIỂM ĐẾN trong chat (theo ngân sách / số ngày /
sở thích). Bổ sung cho cụm Trip AI (.agent/trip-ai), khác `trip_chat_planner`:

  - `trip_chat_planner`  → LÊN LỊCH TRÌNH chi tiết (chọn khách sạn/quán/điểm,
    sắp lịch từng ngày). Kích hoạt bằng "lịch trình / lên kế hoạch...".
  - `destination_advisor` → TƯ VẤN "NÊN ĐI ĐÂU" trước khi có lịch trình:
      • "4 triệu đi Đà Lạt được không?"   → feasibility (đủ tiền không, mấy ngày)
      • "có 3 triệu đi đâu?" / "thích biển đi đâu?" → recommend (gợi ý điểm đến)

Nguyên tắc (kế thừa TRIP_AI_RULES):
  TR-01: chỉ nêu điểm đến / khoảng giá / mùa là dữ liệu THẬT trong bảng
         `destinations` (budget_low/high, best_months, rating_avg...). Không bịa
         tên điểm đến, không bịa con số ngoài DB. Chi phí là ƯỚC TÍNH, ghi rõ.
  TR-02: hoàn toàn rule-based, không phụ thuộc Gemini.
  TR-06: intercept TRƯỚC RAG, SAU planner; không đụng response cache; trả None
         khi không chắc → nhường RAG (không hijack "Đà Lạt có gì chơi").
  TR-07: nội dung tiếng Việt, đối tượng người Việt nội địa.

Một lượt hỏi–đáp, kèm CTA nối sang planner khi user muốn lịch trình.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Optional

from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.nlp_preprocessor import extract_entities
from app.services.trip_chat_planner import (
    _extract_budget,
    _extract_travel_type,
    _extract_travelers,
    has_trigger,
)
from app.services.trip_planner_service import (
    normalize_group_size,
    resolve_destination,
)
from app.services.user_preference_service import (
    PREFERENCE_TAXONOMY,
    score_text,
    strip_accents,
)
from app.utils import get_logger

logger = get_logger("destination_advisor")

# Số ngày mặc định để quy ngân sách TỔNG → ngân sách/ngày khi user không nêu.
DEFAULT_DAYS = 3
# Khoảng chi phí/người/ngày dùng khi destinations.budget_low/high = NULL
# (nhiều điểm đến chưa seed budget). Mức trung bình nội địa VN, ước tính.
FALLBACK_PER_DAY_LOW = 600_000
FALLBACK_PER_DAY_HIGH = 1_300_000
# Trần hợp lý cho chi phí/người/ngày hiển thị — chặn outlier do KB seed lệch
# đơn vị (xem _per_day_range). Median thực tế trong DB ~600k/965k.
PLAUSIBLE_PER_DAY_LOW_CAP = 1_500_000
PLAUSIBLE_PER_DAY_HIGH_CAP = 2_500_000

# Câu hỏi CHỌN điểm đến (không dấu) — "nên đi ĐÂU" chứ không phải "ở X có gì".
_CHOICE_PHRASES = (
    "di dau", "noi nao", "cho nao", "diem den nao", "dia diem nao", "tinh nao",
    "thanh pho nao", "nen di dau", "di choi o dau", "du lich o dau", "o dau dep",
    "dau dep", "dau vui", "goi y diem den", "goi y noi", "goi y cho di",
    "goi y dia diem", "nen du lich o", "di dau choi", "di dau bay gio",
    "di dau ngau nhien", "dau gan", "cho nao gan",
)
# Câu hỏi TÍNH KHẢ THI (không dấu) — "X có được không / đủ không / có nên".
_FEASIBILITY_PHRASES = (
    "duoc khong", "co duoc khong", "di duoc khong", "co nen", "nen di khong",
    "du khong", "co du khong", "co du", "hop ly khong", "on khong", "co on",
    "lieu co", "co kip", "co qua it", "du tien khong", "bao nhieu tien",
    "het bao nhieu", "co dat khong", "co mac khong",
)
# Từ khoá bối cảnh du lịch — để "X triệu" không kích hoạt khi không nói du lịch.
_TRAVEL_HINTS = (
    "du lich", "di choi", "di dau", "dia diem", "diem den", "nghi duong",
    "phuot", "di bien", "di nui", "chuyen di", "di nghi", "di phuot", "di choi",
)
# Bug thật gặp khi user test: "Khách sạn nào tốt ở Đà Lạt giá dưới 1 triệu/đêm?"
# có tên điểm đến + số tiền → bị advisor nuốt thành feasibility ("với 1 triệu đi
# Đà Lạt..."), trong khi đây là câu TRA CỨU DỊCH VỤ (tìm khách sạn/tour/vé) phải
# nhường cho RAG/structured_search (đã có find_hotel/find_tour xử lý đúng theo
# giá/đêm). Chặn SỚM trước mọi logic khác — có tên dịch vụ là nhường ngay,
# không quan tâm có ngân sách/điểm đến hay không.
_SERVICE_LOOKUP_HINTS = (
    "khach san", "resort", "homestay", "nha nghi", "tour", "ve tham quan",
    "ve vao", "gia ve", "/dem", "moi dem", "quan an", "nha hang",
    "an o dau", "quan nao",
)


@dataclass
class AdvisoryQuery:
    mode: str  # "feasibility" | "recommend"
    destination: Optional[str] = None
    budget: Optional[int] = None
    days: Optional[int] = None
    travelers: Optional[int] = None
    travel_type: Optional[str] = None
    preferences: list[str] = field(default_factory=list)


# ══════════════════════════════════════════════════════════════════════════════
# DETECTION (TR-06 — chỉ bắt câu tư vấn điểm đến, nhường RAG khi không chắc)
# ══════════════════════════════════════════════════════════════════════════════

def detect_advisory(message: str) -> Optional[AdvisoryQuery]:
    """Trả về AdvisoryQuery nếu câu là tư vấn điểm đến, else None (→ RAG).

    Ưu tiên nhường planner khi có trigger "lịch trình". Không hijack câu hỏi
    thông tin về MỘT điểm đến đã nêu tên ("Đà Lạt có gì chơi") — chỉ bắt khi
    có tín hiệu ngân sách / tính khả thi / hỏi chọn nơi rõ ràng.
    """
    if not message or has_trigger(message):
        return None

    low = strip_accents(message.lower())
    if any(h in low for h in _SERVICE_LOOKUP_HINTS):
        return None
    ent = extract_entities(message)
    dest = ent.get("location")
    budget = _extract_budget(message)
    days = ent.get("duration_days")
    travelers = _extract_travelers(message)
    ttype = _extract_travel_type(message)
    prefs = list(score_text(message).keys())

    has_feasibility = any(p in low for p in _FEASIBILITY_PHRASES)
    has_choice = any(p in low for p in _CHOICE_PHRASES)
    has_travel_ctx = any(h in low for h in _TRAVEL_HINTS)

    # Có nêu tên điểm đến cụ thể → chỉ tư vấn khi hỏi khả thi/ngân sách,
    # còn "Đà Lạt có gì chơi / ăn gì" để RAG trả (kiến thức KB).
    if dest:
        if budget or has_feasibility:
            return AdvisoryQuery(
                "feasibility", dest, budget, days, travelers, ttype, prefs
            )
        return None

    # Không nêu điểm đến → gợi ý CHỌN nơi khi:
    #  - hỏi "đi đâu / nơi nào..." (has_choice), HOẶC
    #  - nêu ngân sách/sở thích kèm bối cảnh du lịch.
    if has_choice or (budget and has_travel_ctx) or (prefs and has_travel_ctx):
        return AdvisoryQuery(
            "recommend", None, budget, days, travelers, ttype, prefs
        )
    return None


# ══════════════════════════════════════════════════════════════════════════════
# HELPERS
# ══════════════════════════════════════════════════════════════════════════════

_MONTH_NAMES = {
    1: "tháng 1", 2: "tháng 2", 3: "tháng 3", 4: "tháng 4", 5: "tháng 5",
    6: "tháng 6", 7: "tháng 7", 8: "tháng 8", 9: "tháng 9", 10: "tháng 10",
    11: "tháng 11", 12: "tháng 12",
}


def _fmt_vnd(v: Optional[int]) -> str:
    if not v:
        return "—"
    if v >= 1_000_000:
        n = v / 1_000_000
        return (f"{n:.1f}".rstrip("0").rstrip(".")) + " triệu"
    if v >= 1_000:
        return f"{int(round(v / 1_000))}k"
    return str(int(v))


def _fmt_best_months(months: Optional[list[int]]) -> Optional[str]:
    """[11,12,1,2,3] → 'tháng 11 đến tháng 3'; rời rạc → liệt kê."""
    if not months:
        return None
    ms = sorted({int(m) for m in months if 1 <= int(m) <= 12})
    if not ms:
        return None
    if len(ms) == 1:
        return _MONTH_NAMES[ms[0]]
    # Nhận diện dải liên tục có bao vòng cuối năm (vd 11,12,1,2,3)
    full = list(range(1, 13))
    rotations = [full[i:] + full[:i] for i in range(12)]
    for rot in rotations:
        idx = [rot.index(m) for m in ms]
        if max(idx) - min(idx) == len(ms) - 1:  # liên tục trong 1 vòng xoay
            start, end = rot[min(idx)], rot[max(idx)]
            return f"{_MONTH_NAMES[start]} đến {_MONTH_NAMES[end]}"
    return ", ".join(_MONTH_NAMES[m] for m in ms)


def _per_day_range(dest: dict) -> tuple[int, int]:
    """Khoảng chi phí/người/ngày của điểm đến (dùng fallback khi DB trống).

    Bug thật gặp khi user test: `destinations.budget_low/budget_high` seed
    KHÔNG đồng nhất đơn vị giữa các tỉnh — đa số 400k–1.2tr/ngày (median
    600k/965k) nhưng vài tỉnh (Phú Quốc, Nha Trang, Sa Pa, Mũi Né...) lưu
    2–8 triệu/ngày, khiến câu trả lời nghe vô lý ("2 triệu–6 triệu/người/ngày"
    cho Nha Trang). Kẹp về trần hợp lý cho tới khi dữ liệu KB được rà soát lại
    (không sửa DB ở đây — chỉ chặn hiển thị sai lệch)."""
    low = dest.get("budget_low") or FALLBACK_PER_DAY_LOW
    high = dest.get("budget_high") or FALLBACK_PER_DAY_HIGH
    if high < low:
        low, high = high, low
    low = min(int(low), PLAUSIBLE_PER_DAY_LOW_CAP)
    high = min(int(high), PLAUSIBLE_PER_DAY_HIGH_CAP)
    if high < low:
        high = low
    return low, high


def _matched_tags(blob_na: str, prefs: list[str]) -> list[str]:
    """Tag sở thích thực sự khớp mô tả điểm đến.

    Dùng chính `score_text` (giữ ranh giới từ bằng space đầu/cuối của keyword
    trong taxonomy) — KHÔNG tự strip keyword, tránh khớp nhầm (vd keyword
    "hon " của "hòn đảo" nếu bỏ space sẽ dính vào "t-hon-g" = thông)."""
    hits = score_text(blob_na)
    return [t for t in prefs if t in hits]


# ══════════════════════════════════════════════════════════════════════════════
# FEASIBILITY — "X triệu đi <điểm đến> được không?"
# ══════════════════════════════════════════════════════════════════════════════

async def _handle_feasibility(db: AsyncSession, q: AdvisoryQuery) -> Optional[dict]:
    dest = await resolve_destination(db, q.destination or "")
    if not dest:
        return None  # không rõ điểm đến → nhường RAG

    name = dest["name"]
    low, high = _per_day_range(dest)
    mid = (low + high) // 2
    ttype, travelers = normalize_group_size(q.travel_type or "", q.travelers)
    best_months = _fmt_best_months(dest.get("best_months"))

    lines: list[str] = []

    if q.budget:
        per_day_group = mid * travelers
        max_days = q.budget // max(per_day_group, 1)
        who = "một mình" if travelers == 1 else f"{travelers} người"

        if max_days >= 1:
            nights = max(max_days - 1, 0)
            verdict = (
                "khá dư dả" if max_days >= (q.days or DEFAULT_DAYS) + 1
                else "vừa đủ" if max_days >= (q.days or DEFAULT_DAYS)
                else "hơi eo hẹp"
            )
            lines.append(
                f"Với **{_fmt_vnd(q.budget)}** đi **{name}** ({who}), ngân sách "
                f"**{verdict}** — đủ cho khoảng **{max_days} ngày"
                + (f" {nights} đêm" if nights else "") + "**."
            )
            if q.days and q.days > max_days:
                lines.append(
                    f"Bạn muốn đi **{q.days} ngày** thì hơi thiếu — nên rút còn "
                    f"{max_days} ngày, chọn khách sạn/quán bình dân, hoặc tăng ngân sách."
                )
        else:
            lines.append(
                f"Với **{_fmt_vnd(q.budget)}** đi **{name}** ({who}) thì khá chật vật "
                f"cho một chuyến trọn vẹn — chi phí ăn ở tại đây khoảng "
                f"**{_fmt_vnd(low)}–{_fmt_vnd(high)}/người/ngày**. Cân nhắc đi ngắn "
                f"1 ngày, ghép nhóm chia phòng, hoặc chọn điểm đến gần hơn."
            )
        lines.append(
            f"_Ước tính chi phí tại điểm đến: **{_fmt_vnd(low)}–{_fmt_vnd(high)}"
            f"/người/ngày** (lưu trú + ăn uống + tham quan + đi lại nội vùng). "
            f"Chưa gồm vé máy bay/xe khách từ nơi bạn ở._"
        )
    else:
        # Có "được không/có nên" nhưng chưa nêu ngân sách → tổng quan chi phí.
        lines.append(
            f"**{name}** hoàn toàn đáng đi! Chi phí ăn ở tại đây khoảng "
            f"**{_fmt_vnd(low)}–{_fmt_vnd(high)}/người/ngày** (chưa gồm vé xe/máy bay "
            f"tới nơi)."
        )
        est3 = mid * travelers * DEFAULT_DAYS
        who = "một mình" if travelers == 1 else f"{travelers} người"
        lines.append(
            f"Chuyến **{DEFAULT_DAYS} ngày** đi {who} thường tốn khoảng "
            f"**~{_fmt_vnd(est3)}**. Bạn cho mình biết ngân sách để mình tư vấn kỹ hơn nhé."
        )

    if best_months:
        lines.append(f"🗓️ **Thời điểm đẹp:** {best_months}.")

    lines.append(f"👉 Muốn mình **lên lịch trình chi tiết** cho {name} không?")

    return {
        "reply": "\n\n".join(lines),
        "intent": "ask_destination",
        "suggestions": [_dest_card(dest)],
    }


# ══════════════════════════════════════════════════════════════════════════════
# RECOMMEND — "có X triệu / thích biển... đi đâu?"
# ══════════════════════════════════════════════════════════════════════════════

async def _fetch_active_destinations(db: AsyncSession) -> list[dict]:
    rows = (
        await db.execute(
            text(
                """
                SELECT id::text AS id, name, province, region, description,
                       special, best_months, budget_low, budget_high, image_url,
                       COALESCE(rating_avg, 0)     AS rating_avg,
                       COALESCE(favorite_count, 0) AS favorite_count,
                       COALESCE(review_count, 0)   AS review_count
                FROM destinations
                WHERE is_active IS NOT FALSE
                """
            )
        )
    ).mappings().all()
    return [dict(r) for r in rows]


async def _handle_recommend(
    db: AsyncSession, q: AdvisoryQuery, profile_tags: list[str]
) -> Optional[dict]:
    dests = await _fetch_active_destinations(db)
    if not dests:
        return None

    prefs = q.preferences or profile_tags or []
    per_day_cap: Optional[int] = None
    if q.budget:
        days = q.days or DEFAULT_DAYS
        _, travelers = normalize_group_size(q.travel_type or "", q.travelers)
        per_day_cap = int(q.budget / max(days, 1) / max(travelers, 1))

    scored: list[tuple[float, dict, list[str]]] = []
    for d in dests:
        blob_na = strip_accents(
            " ".join(
                str(d.get(k) or "")
                for k in ("name", "description", "special", "region", "province")
            )
        )
        matched = _matched_tags(blob_na, prefs)
        score = 3.0 * len(matched)
        score += float(d["rating_avg"] or 0) * 0.6
        score += min(int(d["favorite_count"] or 0), 200) / 200 * 0.8
        # Ưu tiên khớp ngân sách; phạt nhẹ nếu vượt hẳn (giữ nếu DB trống budget).
        if per_day_cap and d.get("budget_low"):
            if int(d["budget_low"]) <= per_day_cap:
                score += 1.5
            else:
                score -= 2.5
        scored.append((score, d, matched))

    scored.sort(key=lambda x: x[0], reverse=True)
    top = scored[:5]
    if per_day_cap:
        # Giữ những nơi khớp ngân sách (hoặc chưa có dữ liệu budget) lên đầu.
        in_budget = [
            t for t in scored
            if not t[1].get("budget_low")
            or int(t[1]["budget_low"]) <= per_day_cap
        ]
        if in_budget:
            top = in_budget[:5]

    if not top:
        return None

    # ── Dựng câu trả lời ─────────────────────────────────────────────────────
    intro_bits = []
    if q.budget:
        intro_bits.append(f"ngân sách **{_fmt_vnd(q.budget)}**")
    if q.days:
        intro_bits.append(f"**{q.days} ngày**")
    if prefs:
        labels = [
            PREFERENCE_TAXONOMY[t]["label"] for t in prefs if t in PREFERENCE_TAXONOMY
        ]
        if labels:
            intro_bits.append("sở thích **" + ", ".join(labels[:3]) + "**")

    if intro_bits:
        intro = "Dựa trên " + ", ".join(intro_bits) + ", mình gợi ý vài nơi:"
    else:
        intro = "Một vài điểm đến bạn có thể cân nhắc:"

    lines = [intro, ""]
    for score, d, matched in top:
        low, high = _per_day_range(d)
        reason_bits = []
        if matched:
            labels = [PREFERENCE_TAXONOMY[t]["label"] for t in matched]
            reason_bits.append("hợp gu " + "/".join(labels[:2]))
        if d.get("budget_low"):
            reason_bits.append(f"~{_fmt_vnd(low)}–{_fmt_vnd(high)}/ngày")
        if float(d["rating_avg"] or 0) >= 4:
            reason_bits.append(f"đánh giá {float(d['rating_avg']):.1f}★")
        months = _fmt_best_months(d.get("best_months"))
        if months:
            reason_bits.append(f"đẹp {months}")
        where = d.get("province") or d.get("region") or ""
        head = f"**{d['name']}**" + (f" ({where})" if where else "")
        tail = (" — " + "; ".join(reason_bits)) if reason_bits else ""
        lines.append(f"• {head}{tail}")

    days_txt = f" {q.days} ngày" if q.days else ""
    lines.append("")
    lines.append(
        f"👉 Chốt được nơi nào thì nói mình **lên lịch trình chi tiết**{days_txt} nhé!"
    )

    return {
        "reply": "\n".join(lines),
        "intent": "ask_destination",
        "suggestions": [_dest_card(d) for _, d, _ in top],
    }


def _dest_card(d: dict) -> dict:
    """Payload gọn cho FE (Phase 2: render card bấm vào chi tiết)."""
    return {
        "id": d.get("id"),
        "name": d.get("name"),
        "province": d.get("province"),
        "region": d.get("region"),
        "image_url": d.get("image_url"),
        "rating_avg": float(d["rating_avg"]) if d.get("rating_avg") is not None else 0.0,
    }


# ══════════════════════════════════════════════════════════════════════════════
# ENTRY POINT — gọi ở chat_messages.py (SAU planner, TRƯỚC RAG)
# ══════════════════════════════════════════════════════════════════════════════

async def handle_advisory_turn(
    db: AsyncSession, user_id: Optional[str], message: str
) -> Optional[dict]:
    """None → không phải câu tư vấn điểm đến (nhường RAG). Dict → đã trả lời."""
    q = detect_advisory(message)
    if q is None:
        return None

    try:
        if q.mode == "feasibility":
            return await _handle_feasibility(db, q)

        # recommend — lấy sở thích từ profile khi user không nêu
        profile_tags: list[str] = []
        if not q.preferences and user_id:
            try:
                from app.services.user_preference_service import get_profile

                profile = await get_profile(db, user_id)
                profile_tags = [p["tag"] for p in profile]
            except Exception as e:  # profile lỗi → gợi ý theo phổ biến
                logger.warning(f"[advisor] không lấy được profile: {e}")
        return await _handle_recommend(db, q, profile_tags)
    except Exception as e:
        logger.warning(f"[advisor] lỗi xử lý, nhường RAG: {e}")
        return None
