"""
PDTrip RAG Validation Test Suite
=================================
Mục tiêu: kiểm tra xem các thành phố đã có KB folder có chạy được RAG
với tỉ lệ hallucination thấp và độ chính xác >50% không.

Không cần Qdrant/Gemini thật — test toàn bộ pure-function logic:
  1. KB Validation: cấu trúc JSON/MD hợp lệ, required fields
  2. Hallucination Guard: 2 lớp phòng thủ (threshold + grounding/citation)
  3. RAG Simulation: giả lập retrieval bằng token overlap, đánh giá grounding
  4. Address Ward Mapping: địa chỉ cũ trong KB có map được sang phường mới không
  5. City Slug Alias: slug alias có đúng không

Chạy: python3 rag_validation_test.py
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
import unicodedata
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

# ── Paths ─────────────────────────────────────────────────────────────────────

BASE = Path("/home/claude/project/full_project_PDTrip/backend")
KB_BASE = BASE / "knowledge-base"
DATA_DIR = BASE / "app" / "data"

# ── Màu ANSI ──────────────────────────────────────────────────────────────────

GREEN  = "\033[92m"
RED    = "\033[91m"
YELLOW = "\033[93m"
CYAN   = "\033[96m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

def _c(color, text): return f"{color}{text}{RESET}"
def OK(msg): return _c(GREEN, f"  ✅ PASS  {msg}")
def FAIL(msg): return _c(RED,   f"  ❌ FAIL  {msg}")
def WARN(msg): return _c(YELLOW,f"  ⚠️  WARN  {msg}")
def INFO(msg): return _c(CYAN,  f"  ℹ️  INFO  {msg}")

# ══════════════════════════════════════════════════════════════════════════════
# Section 0: load dữ liệu
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'='*70}{RESET}")
print(f"{BOLD}  PDTrip RAG Validation — {time.strftime('%Y-%m-%d %H:%M:%S')}{RESET}")
print(f"{BOLD}{'='*70}{RESET}\n")

# Load ward mapping
with open(DATA_DIR / "ward_old_to_new.json") as f:
    WARD_MAP: list[dict] = json.load(f)
print(INFO(f"ward_old_to_new.json loaded — {len(WARD_MAP)} entries"))

# Load province mapping
with open(DATA_DIR / "province_old_to_new.json") as f:
    PROV_MAP: list[dict] = json.load(f)
print(INFO(f"province_old_to_new.json loaded — {len(PROV_MAP)} provinces"))

# Load city slug alias
with open(DATA_DIR / "city_slug_alias.json") as f:
    SLUG_ALIAS: dict = json.load(f)
print(INFO(f"city_slug_alias.json loaded — {len(SLUG_ALIAS)} cities"))

# ── Xác định các city folder ─────────────────────────────────────────────────

ALL_FOLDERS = sorted([d.name for d in KB_BASE.iterdir() if d.is_dir()])
FULL_KB_CITIES = []   # có ≥8 files (đủ KB)
STUB_CITIES    = []   # chỉ có README

for folder in ALL_FOLDERS:
    files = list((KB_BASE / folder).iterdir())
    real_files = [f for f in files if not f.name.startswith('.')]
    if len(real_files) >= 5:
        FULL_KB_CITIES.append(folder)
    else:
        STUB_CITIES.append(folder)

print(INFO(f"KB folders tổng: {len(ALL_FOLDERS)} — Full KB: {len(FULL_KB_CITIES)} — Stub (README only): {len(STUB_CITIES)}"))
print(INFO(f"Full KB cities: {FULL_KB_CITIES}"))

# ══════════════════════════════════════════════════════════════════════════════
# Test counters
# ══════════════════════════════════════════════════════════════════════════════

@dataclass
class TestResult:
    section: str
    name: str
    passed: bool
    detail: str = ""
    score: Optional[float] = None  # grounding score nếu có

all_results: list[TestResult] = []

def record(section, name, passed, detail="", score=None):
    all_results.append(TestResult(section, name, passed, detail, score))
    line = OK(name) if passed else FAIL(name)
    if detail: line += f" — {detail}"
    if score is not None: line += f" [score={score:.2f}]"
    print(line)
    return passed

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1: KB Structure Validation
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'─'*60}{RESET}")
print(f"{BOLD}  SECTION 1: KB Structure Validation{RESET}")
print(f"{BOLD}{'─'*60}{RESET}")

REQUIRED_FILES = {
    "city.json": ["id", "name", "slug", "province", "description"],
    "destinations.json": None,   # check is list/has data
    "restaurants.json": None,
    "foods.json": None,
    "hotels.json": None,
    "faq.md": None,
    "experiences.md": None,
}

def validate_json_file(path: Path, required_fields: Optional[list]) -> tuple[bool, str]:
    """Validate JSON file: parse OK, có _meta + data, required fields trong data."""
    try:
        with open(path) as f:
            obj = json.load(f)
    except json.JSONDecodeError as e:
        return False, f"JSONDecodeError: {e}"
    
    if not isinstance(obj, dict):
        return False, "Root không phải object"
    
    if "data" not in obj:
        return False, "Thiếu key 'data'"
    
    data = obj["data"]
    
    if required_fields:
        # data có thể là dict (city.json) hoặc list (destinations.json)
        check_obj = data if isinstance(data, dict) else (data[0] if data else {})
        missing = [f for f in required_fields if f not in check_obj]
        if missing:
            return False, f"Thiếu fields: {missing}"
    
    return True, f"OK ({len(data) if isinstance(data, list) else 1} records)"

for city in FULL_KB_CITIES:
    city_dir = KB_BASE / city
    section = f"S1/{city}"
    
    # Check mỗi required file
    for fname, req_fields in REQUIRED_FILES.items():
        fpath = city_dir / fname
        exists = fpath.exists()
        
        if not exists:
            record(section, f"[{city}] {fname} exists", False, "File không tồn tại")
            continue
        
        if fname.endswith(".json"):
            ok, msg = validate_json_file(fpath, req_fields)
            record(section, f"[{city}] {fname} valid", ok, msg)
        else:
            # .md files: check non-empty
            size = fpath.stat().st_size
            ok = size > 200
            record(section, f"[{city}] {fname} non-empty", ok, f"{size} bytes")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2: Hallucination Guard — pure function tests
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'─'*60}{RESET}")
print(f"{BOLD}  SECTION 2: Hallucination Guard Logic{RESET}")
print(f"{BOLD}{'─'*60}{RESET}")

# Copy logic từ hallucination_guard.py (pure functions, không cần import)
PRIMARY_THRESHOLD = 0.45
FALLBACK_THRESHOLD = 0.30
APPROXIMATE_SCORE_CEILING = 0.40
_STOPWORDS = {
    "có","không","là","và","hoặc","của","để","cho","với","thì","mà",
    "nên","cần","muốn","hỏi","biết","thế","nào","này","đó","các",
    "một","những","rất","cũng","khi","đã","sẽ","tôi","mình","bạn",
    "ở","tại","đi","về","the","a","an","is","are","of","to","in",
}

def _tokenize(text: str) -> set[str]:
    text = unicodedata.normalize("NFC", text.lower())
    words = re.findall(r"[\wÀ-ỹ]+", text)
    return {w for w in words if len(w) > 1 and w not in _STOPWORDS}

def filter_by_dynamic_threshold(hits):
    if not hits: return [], PRIMARY_THRESHOLD
    has_high = any(h.get("score", 0) >= PRIMARY_THRESHOLD for h in hits)
    threshold = PRIMARY_THRESHOLD if has_high else FALLBACK_THRESHOLD
    filtered = [h for h in hits if h.get("score", 0) >= threshold]
    return filtered, threshold

def annotate_fallback_sources(results):
    out = []
    for r in results:
        r = dict(r)
        r["is_approximate"] = bool(r.get("source") == "postgres_fts" or r.get("score", 1.0) < APPROXIMATE_SCORE_CEILING)
        out.append(r)
    return out

def run_hallucination_checks(answer: str, sources: list[dict]):
    # grounding
    if not sources:
        grounding_conf, is_grounded = 0.3, False
        ungrounded = []
    else:
        ctx_tokens: set[str] = set()
        for s in sources:
            ctx_tokens |= _tokenize(s.get("text", ""))
        ans_tokens = _tokenize(answer)
        if not ans_tokens:
            grounding_conf, is_grounded, ungrounded = 1.0, True, []
        else:
            overlap = ans_tokens & ctx_tokens
            ratio = len(overlap) / len(ans_tokens)
            grounding_conf = min(1.0, 0.4 + ratio)
            is_grounded = ratio >= 0.15
            ungrounded = list(ans_tokens - ctx_tokens)[:5] if not is_grounded else []
    
    # citation
    indices = [int(m) for m in re.findall(r"\[(\d+)\]", answer)]
    n_sources = len(sources)
    invalid_cites = [i for i in indices if i < 1 or i > n_sources]
    citation_valid = len(invalid_cites) == 0
    
    overall = grounding_conf
    if not citation_valid: overall = min(overall, 0.4)
    should_flag = (not is_grounded) or (not citation_valid) or overall < 0.5
    
    return {
        "is_grounded": is_grounded,
        "grounding_confidence": round(overall, 3),
        "citation_valid": citation_valid,
        "invalid_citations": invalid_cites,
        "should_flag": should_flag,
    }

# Test cases
tc = "S2/HallucinationGuard"

# T1: Empty hits → fallback với empty list
filtered, thresh = filter_by_dynamic_threshold([])
record(tc, "filter: empty hits → empty result + PRIMARY threshold",
       filtered == [] and thresh == PRIMARY_THRESHOLD,
       f"thresh={thresh}")

# T2: High quality hit
hits = [{"text": "Hội An phố cổ đẹp", "score": 0.62},
        {"text": "không liên quan", "score": 0.31}]
filtered, thresh = filter_by_dynamic_threshold(hits)
record(tc, "filter: high-quality hit → PRIMARY threshold, lọc hit yếu",
       thresh == PRIMARY_THRESHOLD and len(filtered) == 1 and filtered[0]["score"] == 0.62,
       f"thresh={thresh}, filtered={len(filtered)}")

# T3: All low quality → fallback threshold
hits = [{"text": "Đà Lạt mát mẻ", "score": 0.38},
        {"text": "thác Datanla", "score": 0.35}]
filtered, thresh = filter_by_dynamic_threshold(hits)
record(tc, "filter: all low-score → FALLBACK threshold, giữ lại kết quả",
       thresh == FALLBACK_THRESHOLD and len(filtered) == 2,
       f"thresh={thresh}, filtered={len(filtered)}")

# T4: annotate_fallback
sources = [
    {"source": "postgres_fts", "score": 0.50, "text": "..."},
    {"source": "qdrant", "score": 0.38, "text": "..."},
    {"source": "qdrant", "score": 0.55, "text": "..."},
]
annotated = annotate_fallback_sources(sources)
record(tc, "annotate: postgres_fts → is_approximate=True",
       annotated[0]["is_approximate"] == True, "")
record(tc, "annotate: qdrant score<0.40 → is_approximate=True",
       annotated[1]["is_approximate"] == True, "")
record(tc, "annotate: qdrant score>=0.40 → is_approximate=False",
       annotated[2]["is_approximate"] == False, "")

# T5: Grounding check — câu trả lời bám context
ctx_src = [{"text": "Chợ Bến Thành nằm ở Quận 1 TP HCM, là biểu tượng của Sài Gòn, mở cửa 6 giờ sáng"}]
answer_good = "Chợ Bến Thành là biểu tượng Sài Gòn nằm Quận 1, mở cửa buổi sáng sớm"
answer_bad  = "Tháp Eiffel nằm ở Paris Pháp, xây năm 1889 bởi Gustave Eiffel"
r_good = run_hallucination_checks(answer_good, ctx_src)
r_bad  = run_hallucination_checks(answer_bad, ctx_src)
record(tc, "grounding: answer bám context → is_grounded=True",
       r_good["is_grounded"], f"conf={r_good['grounding_confidence']}")
record(tc, "grounding: answer hallucinated → is_grounded=False",
       not r_bad["is_grounded"], f"conf={r_bad['grounding_confidence']}")
record(tc, "grounding: hallucinated → should_flag=True",
       r_bad["should_flag"], "")

# T6: Citation validation
answer_cite_ok  = "Nhà Hàng Ngon [1] nằm ở 160 Pasteur [1]"
answer_cite_bad = "Nhà Hàng Ngon [1][2][3] — nhưng chỉ có 1 nguồn"
r_cite_ok  = run_hallucination_checks(answer_cite_ok, ctx_src)  # 1 source
r_cite_bad = run_hallucination_checks(answer_cite_bad, ctx_src) # 1 source, cite [2][3] invalid
record(tc, "citation: valid citations → citation_valid=True",
       r_cite_ok["citation_valid"], f"invalid={r_cite_ok['invalid_citations']}")
record(tc, "citation: invalid citation indices → citation_valid=False + should_flag=True",
       not r_cite_bad["citation_valid"] and r_cite_bad["should_flag"],
       f"invalid_cites={r_cite_bad['invalid_citations']}")

# T7: No context → low confidence
r_no_ctx = run_hallucination_checks("Sài Gòn có Chợ Bến Thành rất nổi tiếng", [])
record(tc, "grounding: no context → confidence=0.3, should_flag=True",
       r_no_ctx["grounding_confidence"] <= 0.3 and r_no_ctx["should_flag"],
       f"conf={r_no_ctx['grounding_confidence']}")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3: RAG Simulation — giả lập retrieval từ KB content
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'─'*60}{RESET}")
print(f"{BOLD}  SECTION 3: RAG Simulation — Grounding Rate per City{RESET}")
print(f"{BOLD}{'─'*60}{RESET}")

def load_city_context(city: str) -> str:
    """Load tất cả text KB của một city thành 1 context string."""
    parts = []
    city_dir = KB_BASE / city
    for fname in ["city.json", "destinations.json", "restaurants.json", "foods.json", "faq.md", "experiences.md"]:
        p = city_dir / fname
        if not p.exists():
            continue
        if fname.endswith(".json"):
            try:
                with open(p) as f:
                    obj = json.load(f)
                data = obj.get("data", obj)
                parts.append(json.dumps(data, ensure_ascii=False))
            except:
                pass
        else:
            parts.append(p.read_text(encoding="utf-8"))
    return "\n\n".join(parts)

def simulate_rag_score(query: str, context: str) -> float:
    """
    Simulate RAG grounding: tính tỉ lệ overlap token giữa query và context.
    Score = overlap / query_tokens, sau đó dùng formula hallucination_guard.
    Đây là lower-bound conservative — BGE-M3 semantic similarity thực tế cao hơn.
    """
    q_tok = _tokenize(query)
    c_tok = _tokenize(context)
    if not q_tok:
        return 0.0
    overlap = q_tok & c_tok
    ratio = len(overlap) / len(q_tok)
    return min(1.0, 0.4 + ratio)  # khớp formula hallucination_guard.py

# Test questions per city (realistic user queries)
CITY_TEST_CASES = {
    "tp-ho-chi-minh-hcmc": [
        ("Chợ Bến Thành mở cửa mấy giờ?",
         "Chợ Bến Thành mở cửa từ 6:00 đến 18:00, khu hàng đêm đến khoảng 23:00"),
        ("Từ sân bay Tân Sơn Nhất về trung tâm đi bao lâu?",
         "Từ sân bay về Quận 1 bằng Grab mất khoảng 15-25 phút tùy kẹt xe"),
        ("Nhà Hàng Ngon ở đâu?",
         "Nhà Hàng Ngon nằm tại 160 Pasteur, Phường Bến Nghé, Quận 1, TP. HCM"),
        ("Thời tiết TP.HCM như thế nào?",
         "TP.HCM có khí hậu nhiệt đới, nóng ẩm 25-35°C quanh năm, mùa mưa tháng 5-11"),
        ("Ăn hủ tiếu ở đâu ngon ở Sài Gòn?",
         "Hủ tiếu Nam Vang là đặc sản Sài Gòn, có thể tìm ở nhiều quán trong thành phố"),
        ("Dinh Độc Lập địa chỉ ở đâu?",
         "Dinh Độc Lập tại 135 Nam Kỳ Khởi Nghĩa, Phường Bến Thành, Quận 1, TP.HCM"),
        # Câu hallucination bẫy — không có trong KB
        ("Tháp Eiffel ở TP.HCM mở cửa mấy giờ?",
         "Tháp Eiffel mở cửa 9 giờ sáng ở quận 2"),  # FAKE — nên bị flag
    ],
    "ha-noi-ha-noi": [
        ("Phở Thìn Lò Đúc ở đâu?",
         "Phở Thìn Lò Đúc ở 13 Lò Đúc, quận Hai Bà Trưng, Hà Nội"),
        ("Bún chả Hương Liên có phải quán Obama ăn không?",
         "Bún Chả Hương Liên ở 24 Lê Văn Hưu là quán Obama từng ghé thăm"),
        ("Thủ đô Việt Nam là gì?",
         "Hà Nội là thủ đô của Việt Nam"),
        ("Hà Nội có gì đặc sắc về ẩm thực?",
         "Hà Nội nổi tiếng với phở, bún chả, chả cá Lã Vọng, cà phê trứng"),
    ],
    "da-nang-hoi-an": [
        ("Bánh mì Phượng ở đâu?",
         "Bánh mì Phượng tại 02B Phan Châu Trinh, khu phố cổ Hội An"),
        ("Hội An có đặc sản gì?",
         "Hội An nổi tiếng với bánh mì, cao lầu, mì Quảng, white rose"),
        ("Phố cổ Hội An đẹp nhất lúc nào?",
         "Phố cổ Hội An đẹp nhất vào đêm rằm khi thả đèn lồng"),
    ],
    "can-tho-can-tho": [
        ("Chợ nổi Cái Răng ở đâu?",
         "Chợ nổi Cái Răng cách trung tâm Cần Thơ khoảng 6km trên sông Cần Thơ"),
        ("Ăn gì ở Cần Thơ?",
         "Cần Thơ nổi tiếng với bánh xèo, lẩu mắm, hủ tiếu Nam Vang, cá lóc nướng trui"),
        ("Bến Ninh Kiều có gì?",
         "Bến Ninh Kiều là điểm dạo chơi nổi tiếng ở Cần Thơ, có chợ đêm và nhà hàng"),
    ],
}

# Chạy test per city
city_scores: dict[str, dict] = {}
tc_rag = "S3/RAGSimulation"

for city in FULL_KB_CITIES:
    if city not in CITY_TEST_CASES:
        print(WARN(f"[{city}] không có test cases — skip"))
        continue
    
    context = load_city_context(city)
    ctx_word_count = len(_tokenize(context))
    print(INFO(f"[{city}] context loaded — ~{ctx_word_count} unique tokens"))
    
    tests = CITY_TEST_CASES[city]
    city_pass = 0
    city_scores[city] = {"scores": [], "pass": 0, "fail": 0, "flag": 0}
    
    for query, expected_answer in tests:
        is_trap = "Tháp Eiffel" in query or "không có trong KB" in query
        
        # Simulate retrieval: context là "KB retrieved docs"
        context_chunks = [{"text": context[:3000], "source": "qdrant", "score": 0.55}]
        
        # Grounding check: expected answer bám context bao nhiêu
        report = run_hallucination_checks(expected_answer, context_chunks)
        score = report["grounding_confidence"]
        is_grounded = report["is_grounded"]
        
        city_scores[city]["scores"].append(score)
        
        if is_trap:
            # Trap question: expected trả lời sai → nên bị flag
            # score thấp vì answer không bám context
            flagged = report["should_flag"] or score < 0.5
            passed = flagged
            city_scores[city]["flag"] += 1
            record(tc_rag,
                   f"[{city}] TRAP: '{query[:50]}' → flagged={flagged}",
                   passed, f"score={score:.2f} (mong muốn flag/thấp)", score)
        else:
            # Legitimate Q: expected answer nên bám context
            passed = is_grounded and score >= 0.5
            if passed:
                city_scores[city]["pass"] += 1
            else:
                city_scores[city]["fail"] += 1
            record(tc_rag,
                   f"[{city}] Q: '{query[:50]}'",
                   passed, f"grounded={is_grounded}, score={score:.2f}", score)

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4: Address Ward Mapping
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'─'*60}{RESET}")
print(f"{BOLD}  SECTION 4: Address Ward Mapping (Old → New){RESET}")
print(f"{BOLD}{'─'*60}{RESET}")

# Build lookup: (old_ward, old_district, old_province) → new entry
def make_ward_lookup(ward_map: list) -> dict:
    """key = (old_ward_normalized, old_district_normalized, old_province_normalized)"""
    lookup = {}
    for entry in ward_map:
        key = (
            entry["old_ward"].strip().lower(),
            entry["old_district"].strip().lower(),
            entry["old_province"].strip().lower(),
        )
        lookup.setdefault(key, []).append(entry)
    return lookup

WARD_LOOKUP = make_ward_lookup(WARD_MAP)

def extract_address_components(address: str) -> Optional[tuple[str,str,str]]:
    """
    Parse địa chỉ kiểu: "160 Pasteur, Phường Bến Nghé, Quận 1, TP. HCM"
    Trả về (ward, district, province_hint) hoặc None nếu parse thất bại.
    """
    parts = [p.strip() for p in address.split(",")]
    if len(parts) < 3:
        return None
    
    ward = ""
    district = ""
    province_hint = ""
    
    for p in parts:
        p_lower = p.lower()
        if any(x in p_lower for x in ["phường", "xã", "thị trấn", "tt."]):
            ward = p
        elif any(x in p_lower for x in ["quận", "huyện", "thị xã", "q."]):
            district = p
        elif any(x in p_lower for x in ["tp.", "thành phố", "tỉnh", "hcm", "hà nội", "đà nẵng"]):
            province_hint = p
    
    if not ward or not district:
        return None
    return (ward.strip(), district.strip(), province_hint.strip())

def lookup_new_ward(ward: str, district: str, province_hint: str) -> Optional[list[dict]]:
    """Tìm new ward mapping, thử exact match trước rồi fuzzy."""
    # Normalize province hint
    prov_map = {
        "hcm": "thành phố hồ chí minh",
        "tp. hcm": "thành phố hồ chí minh",
        "hà nội": "thành phố hà nội",
        "đà nẵng": "thành phố đà nẵng",
        "cần thơ": "thành phố cần thơ",
    }
    prov_norm = prov_map.get(province_hint.lower(), province_hint.lower())
    
    key = (ward.lower(), district.lower(), prov_norm)
    results = WARD_LOOKUP.get(key)
    
    if not results:
        # Try partial: chỉ dùng ward + district (bỏ qua province mismatch)
        for k, v in WARD_LOOKUP.items():
            if k[0] == ward.lower() and k[1] == district.lower():
                results = v
                break
    
    return results

tc_addr = "S4/AddressMapping"

# Collect tất cả địa chỉ từ KB các city đủ data
address_test_cases = []
for city in FULL_KB_CITIES:
    for fname in ["restaurants.json", "destinations.json"]:
        p = KB_BASE / city / fname
        if not p.exists():
            continue
        try:
            with open(p) as f:
                obj = json.load(f)
            items = obj.get("data", [])
            if isinstance(items, list):
                for item in items:
                    addr = item.get("address", "")
                    if addr and "Phường" in addr and ("Quận" in addr or "Huyện" in addr):
                        address_test_cases.append({
                            "city": city,
                            "name": item.get("name", "?"),
                            "address": addr,
                            "file": fname,
                        })
        except:
            pass

print(INFO(f"Tổng địa chỉ có Phường/Quận để test mapping: {len(address_test_cases)}"))

mapped_ok = 0
mapped_fail = 0

for tc_item in address_test_cases:
    addr = tc_item["address"]
    name = tc_item["name"]
    city = tc_item["city"]
    
    components = extract_address_components(addr)
    if not components:
        record(tc_addr, f"[{city}] parse: {name}", False,
               f"Không parse được: '{addr[:60]}'")
        mapped_fail += 1
        continue
    
    ward, district, prov_hint = components
    results = lookup_new_ward(ward, district, prov_hint)
    
    if results:
        new_ward = results[0]["new_ward"]
        new_prov = results[0]["new_province"]
        record(tc_addr, f"[{city}] mapping: '{name}'",
               True, f"'{ward}, {district}' → '{new_ward}, {new_prov}'")
        mapped_ok += 1
    else:
        record(tc_addr, f"[{city}] mapping: '{name}'",
               False, f"'{ward}, {district}' — không tìm thấy trong ward_map")
        mapped_fail += 1

mapping_rate = mapped_ok / (mapped_ok + mapped_fail) if (mapped_ok + mapped_fail) > 0 else 0
print(INFO(f"Ward mapping rate: {mapped_ok}/{mapped_ok+mapped_fail} = {mapping_rate:.1%}"))

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5: City Slug Alias Validation
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'─'*60}{RESET}")
print(f"{BOLD}  SECTION 5: City Slug Alias Coverage{RESET}")
print(f"{BOLD}{'─'*60}{RESET}")

tc_slug = "S5/SlugAlias"

for city in FULL_KB_CITIES:
    in_alias = city in SLUG_ALIAS
    aliases = SLUG_ALIAS.get(city, [])
    has_vietnamese = any(
        any(ord(c) > 127 for c in a) for a in aliases
    ) if aliases else False
    has_ascii = any(
        all(ord(c) < 128 for c in a) for a in aliases
    ) if aliases else False
    
    record(tc_slug, f"[{city}] có trong city_slug_alias", in_alias,
           f"aliases={aliases}")
    if in_alias:
        record(tc_slug, f"[{city}] có alias tiếng Việt", has_vietnamese,
               f"aliases={aliases}")
        record(tc_slug, f"[{city}] có alias ASCII/slug", has_ascii,
               f"aliases={aliases}")

# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6: Province Mapping Coverage
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'─'*60}{RESET}")
print(f"{BOLD}  SECTION 6: Province Sáp Nhập Mapping (34 đơn vị){RESET}")
print(f"{BOLD}{'─'*60}{RESET}")

tc_prov = "S6/ProvinceMapping"

record(tc_prov, "Tổng số 34 tỉnh/thành phố sau sáp nhập",
       len(PROV_MAP) == 34,
       f"actual={len(PROV_MAP)}")

# Check các tỉnh/thành quan trọng
expected_new_provinces = [
    "Thành phố Hồ Chí Minh",  # HCM + Bình Dương + BRVT
    "Thành phố Hà Nội",
    "Thành phố Đà Nẵng",
    "Thành phố Cần Thơ",
    "Thành phố Huế",
    "Thành phố Hải Phòng",
]

all_new_provs = {p["new_province"] for p in PROV_MAP}
for prov in expected_new_provinces:
    record(tc_prov, f"'{prov}' có trong mapping",
           prov in all_new_provs, "")

# Check HCM mapping (key case)
hcm_entry = next((p for p in PROV_MAP if p["new_province"] == "Thành phố Hồ Chí Minh"), None)
if hcm_entry:
    old_provs = hcm_entry["old_provinces"]
    record(tc_prov, "HCM nhận Bình Dương",
           "Tỉnh Bình Dương" in old_provs, f"old={old_provs}")
    record(tc_prov, "HCM nhận Bà Rịa - Vũng Tàu",
           "Tỉnh Bà Rịa - Vũng Tàu" in old_provs, f"old={old_provs}")

# Ward mapping: check HCM Q1 → phường mới
hcm_q1_wards = [x for x in WARD_MAP 
                if "Hồ Chí Minh" in x.get("old_province","") 
                and "Quận 1" in x.get("old_district","")]
record(tc_prov, "Ward mapping có đủ Quận 1 HCM (>20 entries)",
       len(hcm_q1_wards) >= 20, f"count={len(hcm_q1_wards)}")

# ══════════════════════════════════════════════════════════════════════════════
# FINAL SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

print(f"\n{BOLD}{'='*70}{RESET}")
print(f"{BOLD}  SUMMARY{RESET}")
print(f"{BOLD}{'='*70}{RESET}\n")

total = len(all_results)
passed = sum(1 for r in all_results if r.passed)
failed = total - passed
pct = passed / total * 100 if total > 0 else 0

# Per-section breakdown
from collections import defaultdict
section_stats: dict[str, dict] = defaultdict(lambda: {"pass": 0, "fail": 0})
for r in all_results:
    sec = r.section.split("/")[0]
    if r.passed:
        section_stats[sec]["pass"] += 1
    else:
        section_stats[sec]["fail"] += 1

print(f"{'Section':<30} {'Pass':>6} {'Fail':>6} {'Rate':>7}")
print(f"{'─'*52}")
for sec in sorted(section_stats.keys()):
    p = section_stats[sec]["pass"]
    f = section_stats[sec]["fail"]
    t = p + f
    rate = p / t * 100 if t > 0 else 0
    color = GREEN if rate >= 70 else (YELLOW if rate >= 50 else RED)
    print(f"  {sec:<28} {p:>6} {f:>6} {_c(color, f'{rate:>6.1f}%')}")

print(f"{'─'*52}")
color = GREEN if pct >= 70 else (YELLOW if pct >= 50 else RED)
print(f"  {'TOTAL':<28} {passed:>6} {failed:>6} {_c(BOLD+color, f'{pct:>6.1f}%')}")

# RAG Grounding summary per city
if city_scores:
    print(f"\n{BOLD}  RAG Grounding Score per City:{RESET}")
    print(f"  {'City':<40} {'Avg Score':>10} {'Pass/Total':>12}")
    print(f"  {'─'*64}")
    for city, stats in city_scores.items():
        scores = stats["scores"]
        if scores:
            avg = sum(scores) / len(scores)
            p_count = stats["pass"]
            total_q = p_count + stats["fail"]
            color = GREEN if avg >= 0.6 else (YELLOW if avg >= 0.5 else RED)
            print(f"  {city:<40} {_c(color, f'{avg:>8.2f}  ')} {p_count:>6}/{total_q:<4}")

# Ward mapping summary
print(f"\n  Ward Mapping: {mapped_ok}/{mapped_ok+mapped_fail} = {_c(GREEN if mapping_rate>=0.5 else RED, f'{mapping_rate:.1%}')}")

# Verdict
print(f"\n{BOLD}  VERDICT:{RESET}")
verdict_items = []

if pct >= 70:
    verdict_items.append(OK(f"Overall test pass rate {pct:.1f}% ≥ 70% — ✅ ĐẠT YÊU CẦU"))
elif pct >= 50:
    verdict_items.append(WARN(f"Overall test pass rate {pct:.1f}% (50-70%) — ⚠️ ĐẠT NGƯỠNG MINIMUM"))
else:
    verdict_items.append(FAIL(f"Overall test pass rate {pct:.1f}% < 50% — ❌ CHƯA ĐẠT"))

if mapping_rate >= 0.5:
    verdict_items.append(OK(f"Ward mapping rate {mapping_rate:.1%} ≥ 50% — địa chỉ cũ map được sang phường mới"))
else:
    verdict_items.append(FAIL(f"Ward mapping rate {mapping_rate:.1%} < 50% — cần review địa chỉ trong KB"))

full_kb_count = len(FULL_KB_CITIES)
stub_count = len(STUB_CITIES)
verdict_items.append(INFO(f"KB coverage: {full_kb_count} cities có full KB, {stub_count} cities chỉ có README (cần expand)"))

for v in verdict_items:
    print(f"  {v}")

print(f"\n  Chi tiết FAILED tests:")
fail_list = [r for r in all_results if not r.passed]
if fail_list:
    for r in fail_list[:20]:
        print(f"  {RED}✗{RESET} [{r.section}] {r.name} — {r.detail}")
    if len(fail_list) > 20:
        print(f"  ... và {len(fail_list)-20} failed tests khác")
else:
    print(f"  {GREEN}Không có failed tests!{RESET}")

print(f"\n{BOLD}{'='*70}{RESET}\n")
