"""
NLP Preprocessor — Tiền xử lý ngôn ngữ tự nhiên tiếng Việt cho PDTrip chatbot.

[YÊU CẦU 2] Hiểu ngôn ngữ tự nhiên:
- Normalize tiếng Việt (có dấu / không dấu)
- Spell correction cho địa danh phổ biến
- Intent Detection (greeting, destination, weather, accommodation, out_of_scope...)
- Entity Extraction (địa danh, thời gian/tháng)
- Query Rewriting (mở rộng câu hỏi ngắn thành đầy đủ)
- Clarification Flow (hỏi lại khi câu quá ngắn/mơ hồ)
- Context Follow-up (hiểu câu hỏi tiếp theo dựa trên lịch sử)
- Out-of-Scope + Missing Knowledge handling
"""

from __future__ import annotations

import json
import re
import unicodedata
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

from app.utils import get_logger

logger = get_logger("nlp_preprocessor")

# ── Bảng ánh xạ tỉnh/thành CŨ -> slug knowledge-base MỚI ────────────────────
# Sinh tự động bởi scripts/build_admin_mapping.py (xem backend/app/data/).
# Dùng để nhận diện khi người dùng hỏi bằng tên tỉnh/thành cũ trước sáp nhập
# 01/07/2025 (vd "Vũng Tàu", "Bình Dương", "Hà Giang"...) và route đúng vào
# folder knowledge-base hiện tại (vd "tp-ho-chi-minh", "tuyen-quang-ha-giang").
_CITY_SLUG_ALIAS_PATH = Path(__file__).resolve().parent.parent / "data" / "city_slug_alias.json"


def _load_city_slug_alias() -> dict[str, list[str]]:
    try:
        with _CITY_SLUG_ALIAS_PATH.open(encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        logger.warning(
            "Không tìm thấy %s — chạy `python scripts/build_admin_mapping.py` để sinh file này. "
            "Tạm thời bỏ qua alias địa chỉ cũ/mới.",
            _CITY_SLUG_ALIAS_PATH,
        )
        return {}


CITY_SLUG_ALIAS: dict[str, list[str]] = _load_city_slug_alias()

_CITY_SLUG_DISPLAY_PATH = Path(__file__).resolve().parent.parent / "data" / "city_slug_display_name.json"


def _load_city_slug_display_name() -> dict[str, str]:
    try:
        with _CITY_SLUG_DISPLAY_PATH.open(encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return {}


CITY_SLUG_TO_DISPLAY_NAME: dict[str, str] = _load_city_slug_display_name()

# ── Bảng ánh xạ PHƯỜNG/XÃ cũ -> slug knowledge-base MỚI ─────────────────────
# Sinh tự động bởi scripts/build_admin_mapping.py. Cho phép nhận diện khi
# người dùng gõ tên phường/xã cũ cụ thể (vd "phường Trúc Bạch", "xã Vĩnh
# Thịnh") chứ không chỉ tên tỉnh/thành cũ. Vì tên phường/xã có thể trùng
# giữa nhiều tỉnh (vd "Phường 1"), mỗi key trỏ tới 1 LIST ứng viên kèm
# old_district/old_province — xem resolve_ward_slug() để biết cách disambiguate.
_WARD_ALIAS_INDEX_PATH = Path(__file__).resolve().parent.parent / "data" / "ward_alias_index.json"


def _load_ward_alias_index() -> dict[str, list[dict]]:
    try:
        with _WARD_ALIAS_INDEX_PATH.open(encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        logger.warning(
            "Không tìm thấy %s — chạy `python scripts/build_admin_mapping.py` để sinh file này. "
            "Tạm thời bỏ qua nhận diện tên phường/xã cũ.",
            _WARD_ALIAS_INDEX_PATH,
        )
        return {}


WARD_ALIAS_INDEX: dict[str, list[dict]] = _load_ward_alias_index()

_WARD_PREFIX_RE = re.compile(r"^(phường|xã|thị trấn|đặc khu)\s+", flags=re.IGNORECASE)


def _ward_lookup_key(name: str) -> str:
    name = _WARD_PREFIX_RE.sub("", name.strip())
    return _remove_accents(name).lower().replace(" ", "")

# Bảng tra ngược: tên cũ (không dấu, lowercase) -> slug, để lookup O(1).
_OLD_NAME_TO_SLUG: dict[str, str] = {}
for _slug, _names in CITY_SLUG_ALIAS.items():
    for _name in _names:
        _OLD_NAME_TO_SLUG[_name.lower()] = _slug

# ── Bảng địa danh: không dấu → có dấu ───────────────────────────────────────
LOCATION_MAP: dict[str, str] = {
    # Tỉnh/thành
    "da lat": "Đà Lạt", "dalat": "Đà Lạt", "da lac": "Đà Lạt", "da lak": "Đà Lạt",
    "phu quoc": "Phú Quốc", "phuquoc": "Phú Quốc",
    "hoi an": "Hội An", "hoian": "Hội An",
    "ha noi": "Hà Nội", "hanoi": "Hà Nội",
    "sai gon": "Sài Gòn", "saigon": "Sài Gòn",
    "ho chi minh": "TP.HCM", "hcm": "TP.HCM", "tphcm": "TP.HCM",
    "nha trang": "Nha Trang", "nhatrang": "Nha Trang",
    "sa pa": "Sa Pa", "sapa": "Sa Pa",
    "ha long": "Hạ Long", "halong": "Hạ Long",
    "hue": "Huế", "hue city": "Huế",
    "da nang": "Đà Nẵng", "danang": "Đà Nẵng",
    "ha giang": "Hà Giang", "hagiang": "Hà Giang",
    "ninh binh": "Ninh Bình", "ninhbinh": "Ninh Bình",
    "mui ne": "Mũi Né", "muine": "Mũi Né",
    "can tho": "Cần Thơ", "cantho": "Cần Thơ",
    "vung tau": "Vũng Tàu", "vungtau": "Vũng Tàu",
    "quy nhon": "Quy Nhơn", "quynhon": "Quy Nhơn",
    "con dao": "Côn Đảo", "condao": "Côn Đảo",
    "phan thiet": "Phan Thiết", "phanthiet": "Phan Thiết",
    "lai chau": "Lai Châu", "laichau": "Lai Châu",
    "dien bien": "Điện Biên", "dienbienphu": "Điện Biên Phủ",
    "moc chau": "Mộc Châu", "mocchau": "Mộc Châu",
    "cat ba": "Cát Bà", "catba": "Cát Bà",
    "phu yen": "Phú Yên", "phuyen": "Phú Yên",
    "binh dinh": "Bình Định", "binhdinh": "Bình Định",
    "tay ninh": "Tây Ninh", "tayninh": "Tây Ninh",
    "an giang": "An Giang", "angiang": "An Giang",
    "ca mau": "Cà Mau", "camau": "Cà Mau",
    "kien giang": "Kiên Giang", "kiengiang": "Kiên Giang",
    "lam dong": "Lâm Đồng", "lamdong": "Lâm Đồng",
    "thanh hoa": "Thanh Hóa", "thanhhoa": "Thanh Hóa",
    "nghe an": "Nghệ An", "nghean": "Nghệ An",
    "ha tinh": "Hà Tĩnh", "hatinh": "Hà Tĩnh",
    "quang nam": "Quảng Nam", "quangnam": "Quảng Nam",
    "quang binh": "Quảng Bình", "quangbinh": "Quảng Bình",
    # Cities có trong KB nhưng thiếu trong LOCATION_MAP (fix intent=unknown)
    "bac ninh": "Bắc Ninh", "bacninh": "Bắc Ninh", "bắc ninh": "Bắc Ninh",
    "cao bang": "Cao Bằng", "caobang": "Cao Bằng", "cao bằng": "Cao Bằng",
    "buon ma thuot": "Buôn Ma Thuột", "buonmathuot": "Buôn Ma Thuột",
    "bmt": "Buôn Ma Thuột", "buon me thuot": "Buôn Ma Thuột",
    "dong nai": "Đồng Nai", "dongnai": "Đồng Nai", "bien hoa": "Biên Hòa",
    "ha long": "Hạ Long", "vinh ha long": "Vịnh Hạ Long",  # đã có 'ha long' nhưng thêm alias
    # Các tỉnh KB đã có nhưng bổ sung alias gõ tắt
    "tphcm": "TP.HCM", "tp hcm": "TP.HCM", "sai gon": "Sài Gòn",
    "dien bien phu": "Điện Biên Phủ", "dbp": "Điện Biên Phủ",
    # Địa danh nổi tiếng
    "fansipan": "Fansipan", "fan si pan": "Fansipan",
    "ma pi leng": "Mã Pí Lèng", "mapi leng": "Mã Pí Lèng",
    "trang an": "Tràng An", "trang_an": "Tràng An",
    "bai dinh": "Bái Đính", "baidinh": "Bái Đính",
    "tam coc": "Tam Cốc", "tamcoc": "Tam Cốc",
    "chau doc": "Châu Đốc", "chaudoc": "Châu Đốc",
}

# ── Spell correction cho lỗi gõ phổ biến ────────────────────────────────────
SPELL_FIX: dict[str, str] = {
    "đa lạc": "Đà Lạt", "đà lạc": "Đà Lạt", "da lạt": "Đà Lạt",
    "phú quốt": "Phú Quốc", "phú kuoc": "Phú Quốc",
    "hội ahn": "Hội An", "hội anh": "Hội An",
    "nha trand": "Nha Trang", "nha trag": "Nha Trang",
    "hạ lòng": "Hạ Long", "vịnh halong": "Vịnh Hạ Long",
}

# ── Tháng mapping ─────────────────────────────────────────────────────────────
MONTH_MAP: dict[str, int] = {
    "tháng 1": 1, "tháng một": 1, "tháng giêng": 1,
    "tháng 2": 2, "tháng hai": 2, "tháng chạp": 12,
    "tháng 3": 3, "tháng ba": 3,
    "tháng 4": 4, "tháng tư": 4,
    "tháng 5": 5, "tháng năm": 5,
    "tháng 6": 6, "tháng sáu": 6,
    "tháng 7": 7, "tháng bảy": 7,
    "tháng 8": 8, "tháng tám": 8,
    "tháng 9": 9, "tháng chín": 9,
    "tháng 10": 10, "tháng mười": 10,
    "tháng 11": 11, "tháng mười một": 11,
    "tháng 12": 12, "tháng mười hai": 12,
}

# ── Intent keywords ───────────────────────────────────────────────────────────
# Nhãn khớp 1-1 với _TOPK_OVERRIDES (retrieval_optimizer.py) và
# _MAX_TOKENS_BY_INTENT (gemini_optimizer.py) — đây là điều kiện bắt buộc để
# 2 hệ thống tuning đó hoạt động thay vì luôn rơi về giá trị mặc định.
# Lưu ý: "ask_best_time" được gộp vào "ask_weather" (nội dung trả lời giống
# nhau, tách riêng không đổi hành vi retrieval) nên không xuất hiện ở đây dù
# có mặt trong 2 dict trên — _TOPK_OVERRIDES/_MAX_TOKENS_BY_INTENT vẫn giữ key
# "ask_best_time" phòng khi cần dùng từ nơi khác (vd: phân loại bằng Gemini).
INTENT_PATTERNS: dict[str, list[str]] = {
    "greeting": [
        "xin chào", "hello", "hi ", "chào bạn", "hey", "chào buổi",
        "good morning", "good evening", "alo", "ơi chatbot",
        "chào", "hi", "cảm ơn", "cám ơn", "thanks", "tạm biệt", "bye",
    ],
    "ask_weather": [
        "thời tiết", "nhiệt độ", "nắng", "mưa", "lạnh", "nóng",
        "khí hậu", "mùa mưa", "mùa khô", "mùa du lịch", "mùa nào",
        "thời điểm", "tháng mấy", "mùa nào đẹp", "nên đi tháng",
        "có tuyết", "bão", "khi nào đi", "thời điểm nào", "đi lúc nào",
    ],
    "find_hotel": [
        "khách sạn", "homestay", "resort", "hostel", "nhà nghỉ", "ks",
        "ngủ đâu", "ngủ ở đâu", "lưu trú", "đặt phòng", "booking",
        "giá phòng", "phòng", "villa", "bungalow",
    ],
    "ask_food": [
        "ăn gì", "đặc sản", "ẩm thực", "món ngon", "nhà hàng",
        "quán ăn", "hải sản", "ăn uống", "bún", "phở", "bánh",
        "đồ ăn",
    ],
    "ask_transport": [
        "di chuyển", "đi lại", "máy bay", "tàu hỏa", "xe khách",
        "vé xe", "vé tàu", "grab", "taxi", "xe máy", "thuê xe", "bus",
        "cách đi", "đường đi", "km", "giờ đi", "bằng gì",
    ],
    "plan_trip": [
        "lịch trình", "kế hoạch", "lên lịch", "hành trình",
        "đi mấy ngày", "lập kế hoạch", "tự túc mấy ngày",
    ],
    "ask_activity": [
        "có gì chơi", "có gì hay", "nên đi đâu", "địa điểm nào",
        "gợi ý chơi gì", "tham quan", "check in", "trải nghiệm",
    ],
    "ask_safety": [
        "an toàn", "nguy hiểm", "lừa đảo", "bệnh viện", "cấp cứu",
        "visa", "hộ chiếu", "bảo hiểm", "cẩn thận", "lưu ý",
    ],
    "ask_budget": [
        "giá", "chi phí", "bao nhiêu tiền", "tiền", "đắt", "rẻ",
        "ngân sách", "budget", "phí", "vé vào",
    ],
    "ask_destination": [
        "du lịch", "địa điểm", "nơi nào", "đi đâu",
        "thăm quan", "khám phá", "điểm đến", "cảnh đẹp",
    ],
    "find_tour": [
        "tour", "tour trọn gói", "đặt tour", "tour ghép", "công ty du lịch",
    ],
    "compare_destinations": [
        "hay là", "hay đi", "nên chọn", "so với", "khác gì nhau", "hơn", "hay",
    ],
    "ask_faq": [
        "đổi tiền", "sim", "wifi", "ngôn ngữ", "múi giờ", "tiền tệ",
    ],
    "out_of_scope": [
        "code", "lập trình", "python", "javascript", "git",
        "hacking", "crypto", "bitcoin", "chứng khoán",
        "toán học", "công thức", "giải phương trình",
        "thể thao", "bóng đá", "game", "anime",
        "chính trị", "bầu cử", "chiến tranh",
    ],
}

# ── Từ khóa khi câu hỏi quá ngắn/mơ hồ → hỏi lại ───────────────────────────
CLARIFICATION_OPTIONS: dict[str, list[str]] = {
    "destination_generic": [
        "🌤 Thời tiết & mùa du lịch",
        "🗺 Địa điểm tham quan",
        "🏨 Khách sạn & lưu trú",
        "🍜 Ẩm thực đặc sản",
        "🚗 Di chuyển & vận tải",
        "📅 Gợi ý lịch trình",
    ],
}


# ── Data classes ──────────────────────────────────────────────────────────────

@dataclass
class NLPResult:
    """Kết quả tiền xử lý NLP."""
    original_query: str
    normalized_query: str           # Sau normalize + spell fix
    rewritten_query: str            # Sau query rewriting (đầy đủ hơn)
    intent: str                     # greeting | ask_weather | find_hotel | ask_food | ask_transport |
                                     # plan_trip | ask_activity | ask_safety | ask_budget | ask_destination |
                                     # find_tour | compare_destinations | ask_faq | out_of_scope | unknown
    entities: dict                  # {"location": "Đà Lạt", "month": 12, ...}
    needs_clarification: bool       # True nếu cần hỏi lại
    clarification_message: str      # Câu hỏi lại cho user
    clarification_options: list[str]  # Các lựa chọn gợi ý
    is_out_of_scope: bool           # True nếu ngoài nghiệp vụ du lịch
    is_greeting: bool               # True nếu chào hỏi thuần túy
    confidence: float               # 0.0 - 1.0


# ── Utility functions ─────────────────────────────────────────────────────────

def _remove_accents(text: str) -> str:
    """
    Bỏ dấu tiếng Việt.

    Lưu ý quan trọng: chữ "đ"/"Đ" (U+0111 / U+0110) KHÔNG phải là "d" + dấu
    kết hợp (combining mark) trong Unicode — nó là một ký tự độc lập, nên
    NFKD decomposition không tách được nó thành "d". Nếu không xử lý riêng,
    mọi từ chứa "đ" (đi, đến, đẹp, địa điểm, đổi tiền, Đà Nẵng...) sẽ KHÔNG
    được bỏ dấu đúng — "đổi" sẽ ra "đoi" thay vì "doi", khiến no-accent
    matching thất bại cho rất nhiều từ khóa du lịch phổ biến.
    """
    text = text.replace("đ", "d").replace("Đ", "D")
    nfkd = unicodedata.normalize("NFKD", text)
    return "".join(c for c in nfkd if not unicodedata.combining(c))


_KEYWORD_PATTERN_CACHE: dict[str, re.Pattern] = {}


def _keyword_in_text(keyword: str, text: str) -> bool:
    """
    Kiểm tra `keyword` có xuất hiện trong `text` theo RANH GIỚI TỪ, không
    phải substring thô.

    Lý do cần hàm này: keyword ngắn như "ăn gì" (bỏ dấu: "an gi") trước đây
    dùng `kw in text` — phép so khớp substring thô — nên khớp NHẦM vào bên
    trong các từ khác. Ví dụ "việt nam CẦN GÌ" (bỏ dấu: "viet nam CAN GI")
    chứa substring "an gi" ở giữa "can gi", bị tính là khớp "ăn gì" dù câu
    không liên quan ẩm thực, kéo intent lệch sang ask_food.

    Dùng (?<![a-zA-Z]) / (?![a-zA-Z]) thay vì \\b chuẩn vì keyword có thể
    chứa khoảng trắng ở giữa (vd "ăn gì", "đổi tiền") — \\b của Python chỉ
    xét ranh giới ở 2 đầu chuỗi pattern, không xét khoảng trắng bên trong,
    nên vẫn cho kết quả đúng trong trường hợp này, nhưng viết tường minh
    bằng lookaround để rõ ý đồ và tránh phụ thuộc hành vi ngầm của \\b với
    khoảng trắng/dấu câu.

    Kết quả pattern được cache theo keyword vì cùng 1 keyword được gọi lại
    rất nhiều lần (mỗi câu hỏi x mỗi intent x mỗi keyword).
    """
    pattern = _KEYWORD_PATTERN_CACHE.get(keyword)
    if pattern is None:
        pattern = re.compile(r"(?<![a-zA-Z])" + re.escape(keyword) + r"(?![a-zA-Z])")
        _KEYWORD_PATTERN_CACHE[keyword] = pattern
    return pattern.search(text) is not None


# Bản không dấu của INTENT_PATTERNS, tính sẵn 1 lần khi import module.
# Dùng để so khớp keyword với câu hỏi không dấu (vd: "thoi tiet da nang
# thang may dep") — _remove_accents áp cho cả 2 phía (keyword lẫn câu hỏi)
# thay vì chỉ 1 phía như code cũ (xem detect_intent()).
INTENT_PATTERNS_NO_ACCENT: dict[str, list[str]] = {
    intent: [_remove_accents(kw) for kw in keywords]
    for intent, keywords in INTENT_PATTERNS.items()
}


def normalize_vietnamese(text: str) -> str:
    """
    Normalize tiếng Việt:
    - Không dấu → có dấu cho địa danh
    - Lowercase + strip
    - Map spell corrections
    """
    # Spell fix trước (uppercase-sensitive)
    lower = text.strip().lower()
    for wrong, correct in SPELL_FIX.items():
        lower = lower.replace(wrong.lower(), correct)

    # Map địa danh không dấu → có dấu
    no_accent_lower = _remove_accents(lower)
    for no_accent_key, correct_name in LOCATION_MAP.items():
        # Thay trong cả phiên bản không dấu
        if no_accent_key in no_accent_lower:
            # Tìm vị trí trong text gốc và thay thế
            pattern = re.compile(re.escape(no_accent_key), re.IGNORECASE)
            # Chỉ thay nếu đó là từ nguyên bản không dấu (tránh false positive)
            no_acc_text = _remove_accents(lower)
            if pattern.search(no_acc_text):
                # Rebuild: đưa correct_name vào
                lower = pattern.sub(correct_name, _remove_accents(lower))
                # Cũng cần update no_accent_lower
                no_accent_lower = _remove_accents(lower)

    return lower.strip()


def resolve_ward_slug(text: str) -> Optional[dict]:
    """
    Tìm xem trong `text` có chứa tên PHƯỜNG/XÃ cũ (trước sáp nhập 01/07/2025)
    nào không, và map sang city_slug knowledge-base tương ứng.

    Vì nhiều phường/xã trùng tên giữa các tỉnh (vd "Phường 1"), nếu 1 tên
    match nhiều ứng viên thì cố gắng disambiguate bằng tên quận/huyện cũ
    (old_district) cũng xuất hiện trong text; nếu vẫn không phân biệt được
    thì bỏ qua (trả None) để tránh route sai.

    Trả về dict {"slug", "old_ward", "old_district", "old_province",
    "new_ward", "new_province"} hoặc None nếu không match được rõ ràng.
    """
    if not text or not WARD_ALIAS_INDEX:
        return None
    no_accent = _remove_accents(text).lower()

    best_match: Optional[dict] = None
    best_len = 0
    for ward_key, candidates in WARD_ALIAS_INDEX.items():
        if not ward_key or ward_key not in no_accent.replace(" ", ""):
            continue
        if len(candidates) == 1:
            chosen = candidates[0]
        else:
            # Nhiều tỉnh có phường/xã trùng tên -> thử khớp thêm old_district
            district_matches = [
                c for c in candidates
                if _ward_lookup_key(c["old_district"]) and
                _ward_lookup_key(c["old_district"]) in no_accent.replace(" ", "")
            ]
            if len(district_matches) == 1:
                chosen = district_matches[0]
            else:
                continue  # vẫn mơ hồ -> bỏ qua, không đoán bừa
        # Ưu tiên match dài nhất (tránh match nhầm tên ngắn là substring của tên dài hơn)
        if len(ward_key) > best_len:
            best_len = len(ward_key)
            best_match = chosen

    return best_match


def resolve_city_slug(location_text: str) -> tuple[Optional[str], bool]:
    """
    Map một tên địa danh (mới hoặc CŨ trước sáp nhập 01/07/2025) sang
    city_slug hiện dùng trong knowledge-base.

    Trả về (slug, is_legacy_name):
        - slug: vd "tp-ho-chi-minh", hoặc None nếu không khớp alias nào.
        - is_legacy_name: True nếu match được là do dùng tên tỉnh/thành CŨ
          (vd "Vũng Tàu", "Bình Dương") — agent có thể dùng cờ này để chêm
          một câu giải thích ngắn về sáp nhập hành chính trong câu trả lời.
    """
    if not location_text:
        return None, False
    no_accent = _remove_accents(location_text).lower().replace(" ", "")
    lower = location_text.lower()

    slug = _OLD_NAME_TO_SLUG.get(lower) or _OLD_NAME_TO_SLUG.get(no_accent)
    if slug:
        return slug, True

    # Thử match theo substring (vd "đi vũng tàu chơi gì" chứa "vũng tàu")
    for old_name_lower, mapped_slug in _OLD_NAME_TO_SLUG.items():
        if old_name_lower and (old_name_lower in lower or old_name_lower in no_accent):
            return mapped_slug, True

    return None, False


def extract_entities(text: str) -> dict:
    """
    Trích xuất entities từ text:
    - location: địa danh
    - month: số tháng (1-12)
    - duration: số ngày
    """
    entities: dict = {}
    lower = text.lower()
    no_acc = _remove_accents(lower)

    # Extract location
    for no_accent_key, correct_name in LOCATION_MAP.items():
        if no_accent_key in no_acc:
            entities["location"] = correct_name
            break
    # Nếu không tìm được từ LOCATION_MAP, thử tìm tên có dấu trực tiếp
    if "location" not in entities:
        for no_accent_key, correct_name in LOCATION_MAP.items():
            if correct_name.lower() in lower:
                entities["location"] = correct_name
                break

    # [Sáp nhập 01/07/2025] Map location -> city_slug knowledge-base hiện tại,
    # đồng thời đánh dấu nếu người dùng đang dùng tên tỉnh/thành CŨ
    # (vd "Vũng Tàu" -> slug "tp-ho-chi-minh", is_legacy_name=True).
    # Thử khớp cấp PHƯỜNG/XÃ cũ trước (cụ thể hơn, vd "phường Trúc Bạch"),
    # nếu không có thì fallback về khớp cấp tỉnh/thành cũ.
    ward_match = resolve_ward_slug(text)
    if ward_match:
        entities["city_slug"] = ward_match["slug"]
        entities["is_legacy_location_name"] = True
        entities["legacy_ward"] = ward_match["old_ward"]
        entities["legacy_ward_new_name"] = ward_match["new_ward"]
        if "location" not in entities:
            entities["location"] = ward_match["old_ward"]
    else:
        location_for_lookup = entities.get("location") or text
        city_slug, is_legacy_name = resolve_city_slug(location_for_lookup)
        if city_slug:
            entities["city_slug"] = city_slug
            entities["is_legacy_location_name"] = is_legacy_name

    # Extract month
    for month_str, month_num in MONTH_MAP.items():
        if month_str in lower:
            entities["month"] = month_num
            break
    # Pattern: "tháng X" với số
    month_match = re.search(r"tháng\s+(\d{1,2})", lower)
    if month_match and "month" not in entities:
        m = int(month_match.group(1))
        if 1 <= m <= 12:
            entities["month"] = m

    # Extract duration (X ngày)
    duration_match = re.search(r"(\d+)\s*ngày", lower)
    if duration_match:
        entities["duration_days"] = int(duration_match.group(1))

    return entities


def detect_intent(text: str, entities: dict) -> tuple[str, float]:
    """
    Phát hiện intent từ text và entities.
    Trả về (intent_label, confidence_score).
    """
    lower = text.lower()
    no_acc = _remove_accents(lower)

    # Check out_of_scope trước
    oos_score = sum(1 for kw in INTENT_PATTERNS_NO_ACCENT["out_of_scope"] if _keyword_in_text(kw, no_acc))
    if oos_score >= 1:
        return "out_of_scope", 0.9

    # Check greeting (accent-fold cả 2 phía, cùng cách làm với out_of_scope ở trên —
    # bug gốc: check này chỉ so trên `lower`, nên "xin chao" không dấu sẽ không khớp
    # "xin chào" có dấu trong INTENT_PATTERNS, rơi xuống "unknown" dù rõ ràng là chào hỏi)
    greeting_score = sum(
        1 for kw, kw_na in zip(INTENT_PATTERNS["greeting"], INTENT_PATTERNS_NO_ACCENT["greeting"])
        if _keyword_in_text(kw, lower) or _keyword_in_text(kw_na, no_acc)
    )
    # Câu rất ngắn + chào → greeting
    if greeting_score >= 1 and len(text.split()) <= 5:
        return "greeting", 0.95

    # Score từng intent — TRỌNG SỐ theo số từ trong keyword, không đếm thô.
    #
    # Bug đã sửa: trước đây mỗi keyword khớp được tính đúng 1 điểm bất kể độ
    # đặc trưng — "tiền" (1 từ, rất chung chung, xuất hiện trong vô số câu)
    # và "đổi tiền" (2 từ, rất đặc trưng cho ask_faq) đều được +1 như nhau.
    # Khi 2 intent hòa điểm, max() chọn nhãn nào KHAI BÁO TRƯỚC trong dict —
    # ngẫu nhiên về mặt ngữ nghĩa, không phản ánh nhãn nào phù hợp hơn.
    #
    # Cách sửa: trọng số keyword = số từ trong keyword đó (vd "tiền"=1,
    # "đổi tiền"=2, "tour trọn gói"=3). Keyword nhiều từ hơn đặc trưng hơn
    # nên cộng điểm cao hơn, giúp "đổi tiền" thắng "tiền" một cách có căn cứ
    # thay vì thắng/thua ngẫu nhiên theo thứ tự khai báo. Đây vẫn là cách
    # tính đơn giản, dễ giải thích (không cần TF-IDF/ML) — đúng tinh thần
    # rule-based của hệ thống, chỉ thêm 1 lớp trọng số tối thiểu.
    scores: dict[str, float] = {}
    for intent, keywords in INTENT_PATTERNS.items():
        if intent in ("out_of_scope", "greeting"):
            continue
        kw_no_acc_list = INTENT_PATTERNS_NO_ACCENT[intent]
        # So khớp CẢ bản có dấu (trên lower) LẪN bản không dấu (trên no_acc),
        # đúng cặp keyword <-> keyword_no_accent (zip giữ nguyên thứ tự khai
        # báo ở trên), không lệch như code cũ (kw in no_acc so chuỗi có dấu
        # với chuỗi không dấu, gần như không bao giờ match).
        # Dùng _keyword_in_text() (ranh giới từ) thay vì `in` thô — chặn
        # substring collision kiểu "an gi" khớp nhầm vào trong "can gi".
        score = sum(
            len(kw.split()) for kw, kw_na in zip(keywords, kw_no_acc_list)
            if _keyword_in_text(kw, lower) or _keyword_in_text(kw_na, no_acc)
        )
        if score > 0:
            scores[intent] = score

    if not scores:
        # Có location entity nhưng không rõ intent
        if "location" in entities:
            return "ask_destination", 0.5
        return "unknown", 0.3

    best_intent = max(scores, key=lambda k: scores[k])
    max_score = scores[best_intent]
    # max_score giờ là tổng trọng số (số từ), không còn là số lượt khớp thô,
    # nên hệ số nhân giảm từ 0.15 xuống 0.1 để confidence không tăng quá
    # nhanh khi 1 keyword nhiều từ (vd "tour trọn gói" = 3 điểm) đã đẩy
    # confidence gần kịch trần chỉ với 1 lần khớp duy nhất.
    confidence = min(0.95, 0.5 + max_score * 0.1)
    return best_intent, confidence


def rewrite_query(original: str, entities: dict, intent: str, history: list[dict]) -> str:
    """
    Query Rewriting: mở rộng câu hỏi ngắn thành đầy đủ.
    Tận dụng context từ history để bổ sung ngữ cảnh thiếu.
    """
    location = entities.get("location", "")
    month = entities.get("month")
    lower = original.lower().strip()

    # Lấy location từ history nếu câu hiện tại không có
    if not location and history:
        for msg in reversed(history[-6:]):
            prev_entities = extract_entities(msg.get("content", ""))
            if prev_entities.get("location"):
                location = prev_entities["location"]
                break

    # Lấy month từ history nếu câu hiện tại không có
    if not month and history:
        for msg in reversed(history[-4:]):
            prev_entities = extract_entities(msg.get("content", ""))
            if prev_entities.get("month"):
                month = prev_entities["month"]
                break

    # --- Patterns viết lại ---

    # "có lạnh không?" → "Có lạnh không ở [location] vào tháng [month]?"
    if re.search(r"^(có )?(lạnh|nóng|mưa|nắng|tuyết)\s*(không|ko|k)?[?]?$", lower):
        loc_part = f" ở {location}" if location else ""
        month_part = f" vào tháng {month}" if month else ""
        return f"Thời tiết{loc_part}{month_part} như thế nào? Có {lower.rstrip('?không ko k').strip()} không?"

    # "ổn ko?" / "đi tháng X ổn ko" → thêm context location
    if re.search(r"(ổn|ok|oke|được)\s*(ko|không|k)?[?]?$", lower):
        loc_part = f" {location}" if location else ""
        month_part = f" tháng {month}" if month else ""
        return f"Đi du lịch{loc_part}{month_part} có phù hợp không? Thời tiết và điều kiện du lịch như thế nào?"

    # Câu 1 từ là địa danh
    stripped = lower.strip("?.,!")
    if location and stripped in (_remove_accents(location.lower()), location.lower()):
        return f"Thông tin tổng quan về {location}: địa điểm tham quan, thời tiết, ẩm thực và lưu trú"

    # "thời tiết tháng X" không có location → thêm location từ context
    if intent == "ask_weather" and month and not location:
        return f"Thời tiết và điều kiện du lịch tháng {month} như thế nào?"

    # "thời tiết [location] tháng X" đã đủ → giữ nguyên
    if location and month and intent == "ask_weather":
        return f"Thời tiết {location} tháng {month} như thế nào? Có phù hợp để du lịch không?"

    # Câu hỏi với location nhưng thiếu intent rõ ràng
    if location and intent in ("ask_destination", "unknown") and len(lower.split()) <= 4:
        return f"Thông tin du lịch {location}: địa điểm tham quan, thời tiết, ẩm thực, lưu trú và di chuyển"

    # Không cần rewrite
    return original


def should_clarify(text: str, entities: dict, intent: str) -> tuple[bool, str, list[str]]:
    """
    Kiểm tra xem có cần hỏi lại người dùng không.
    Trả về (needs_clarification, message, options).
    """
    lower = text.strip().lower()
    word_count = len(lower.split())

    # Câu 1 từ là địa danh → hỏi muốn biết gì
    if word_count <= 2 and entities.get("location") and intent in ("ask_destination", "unknown"):
        location = entities["location"]
        return (
            True,
            f"Bạn muốn tìm hiểu gì về **{location}**?",
            CLARIFICATION_OPTIONS["destination_generic"],
        )

    # Câu cực ngắn không có context gì
    if word_count == 1 and intent == "unknown":
        return (
            True,
            "Bạn muốn hỏi về chủ đề du lịch nào?",
            [
                "🗺 Địa điểm du lịch Việt Nam",
                "🌤 Thời tiết & thời điểm đi",
                "🏨 Khách sạn & lưu trú",
                "🍜 Ẩm thực đặc sản",
                "💰 Chi phí & ngân sách",
                "📋 Lịch trình gợi ý",
            ],
        )

    return False, "", []


# ── Main preprocessor ─────────────────────────────────────────────────────────

def preprocess(
    question: str,
    history: list[dict] | None = None,
) -> NLPResult:
    """
    Tiền xử lý đầy đủ một câu hỏi trước khi vào RAG pipeline.

    Args:
        question: Câu hỏi gốc từ người dùng
        history: Lịch sử hội thoại [{"role": "user"/"assistant", "content": "..."}]

    Returns:
        NLPResult với đầy đủ thông tin đã xử lý
    """
    if history is None:
        history = []

    original = question.strip()

    # 1. Normalize
    normalized = normalize_vietnamese(original)

    # 2. Extract entities
    entities = extract_entities(normalized)

    # 3. Intent detection
    intent, confidence = detect_intent(normalized, entities)

    # 4. Classify special cases
    is_greeting = intent == "greeting"
    is_out_of_scope = intent == "out_of_scope"

    # 5. Clarification check (chỉ khi không phải greeting/out_of_scope)
    needs_clarification = False
    clarification_message = ""
    clarification_options: list[str] = []
    if not is_greeting and not is_out_of_scope:
        needs_clarification, clarification_message, clarification_options = should_clarify(
            normalized, entities, intent
        )

    # 6. Query rewriting (chỉ khi không cần clarification)
    if needs_clarification:
        rewritten = normalized  # Không rewrite nếu cần hỏi lại
    else:
        rewritten = rewrite_query(normalized, entities, intent, history)

    # 7. [Sáp nhập 01/07/2025] Nếu người dùng dùng tên tỉnh/thành CŨ
    # (vd "Vũng Tàu", "Bình Dương", "Hà Giang"...), chêm thêm tên tỉnh/thành
    # MỚI vào rewritten_query để semantic search khớp đúng nội dung trong
    # knowledge-base (đã được tổ chức theo slug/tên mới, vd "tp-ho-chi-minh").
    # Không sửa lại original/normalized_query — chỉ enrich bản dùng để
    # embedding + retrieval.
    if not needs_clarification and entities.get("is_legacy_location_name") and entities.get("city_slug"):
        new_city_name = CITY_SLUG_TO_DISPLAY_NAME.get(entities["city_slug"])
        if new_city_name and new_city_name.lower() not in rewritten.lower():
            rewritten = f"{rewritten} (thuộc {new_city_name} sau sáp nhập hành chính 2025)"

    result = NLPResult(
        original_query=original,
        normalized_query=normalized,
        rewritten_query=rewritten,
        intent=intent,
        entities=entities,
        needs_clarification=needs_clarification,
        clarification_message=clarification_message,
        clarification_options=clarification_options,
        is_out_of_scope=is_out_of_scope,
        is_greeting=is_greeting,
        confidence=confidence,
    )

    logger.debug(
        f"[NLP] '{original[:50]}' → intent={intent}({confidence:.2f}) "
        f"entities={entities} rewritten='{rewritten[:60]}' "
        f"clarify={needs_clarification}"
    )

    return result


# ── Greeting + Out-of-scope responses ────────────────────────────────────────

GREETING_RESPONSES = [
    "Xin chào! Tôi là trợ lý du lịch PDTrip 🌏 Tôi có thể giúp bạn lên kế hoạch du lịch Việt Nam — thời tiết, địa điểm, ẩm thực, lưu trú và di chuyển. Bạn muốn khám phá điểm đến nào?",
    "Chào bạn! Tôi là chatbot du lịch PDTrip, sẵn sàng tư vấn du lịch Việt Nam cho bạn 🗺 Bạn đang có ý định đi đâu?",
    "Hello! Tôi là trợ lý du lịch của PDTrip 👋 Hãy hỏi tôi về bất kỳ điểm đến nào ở Việt Nam — thời tiết, khách sạn, ẩm thực hay lịch trình!",
]

OUT_OF_SCOPE_RESPONSE = (
    "Tôi là chatbot hỗ trợ du lịch PDTrip, chuyên tư vấn du lịch Việt Nam. "
    "Câu hỏi này nằm ngoài phạm vi tư vấn của tôi 🙏\n\n"
    "Bạn có thể hỏi tôi về:\n"
    "- 🗺 Địa điểm du lịch\n"
    "- 🌤 Thời tiết & mùa du lịch\n"
    "- 🏨 Khách sạn & lưu trú\n"
    "- 🍜 Ẩm thực đặc sản\n"
    "- 🚗 Di chuyển & vận tải\n"
    "- 📅 Lịch trình tham quan"
)

MISSING_KNOWLEDGE_RESPONSE = (
    "Hiện tôi chưa có dữ liệu đáng tin cậy về nội dung này trong knowledge base. "
    "Bạn có thể liên hệ tư vấn viên PDTrip để được hỗ trợ chi tiết hơn 📞"
)


def get_greeting_response(index: int = 0) -> str:
    return GREETING_RESPONSES[index % len(GREETING_RESPONSES)]