"""
Retrieval Optimizer — YÊU CẦU 6.

Chịu trách nhiệm:
  - Cấu hình Qdrant (quantization + HNSW) phù hợp quy mô KB nhỏ-vừa
    (vài trăm tới vài chục nghìn điểm), tối ưu RAM trên máy 16GB / 6GB VRAM.
  - search_params dùng khi query (cân bằng tốc độ/recall qua `ef`).
  - Dynamic top-K theo intent: FAQ/smalltalk cần ít chunk, itinerary/so sánh
    cần nhiều chunk hơn để tổng hợp.
  - search_metrics: ghi nhận latency các lần search Qdrant để theo dõi.
"""

from __future__ import annotations

import statistics
import threading
from collections import deque
from typing import Optional

from qdrant_client.http import models as qmodels

# ── Dynamic top-K theo intent ──────────────────────────────────────────────

# Intent cần ít context (câu trả lời ngắn, tập trung)
_LOW_TOPK_INTENTS = {
    "smalltalk", "greeting", "out_of_scope", "ask_faq", "faq",
}

# Intent cần nhiều context (phải tổng hợp nhiều nguồn)
_HIGH_TOPK_INTENTS = {
    "plan_trip", "itinerary_planner", "compare_destinations",
}

_TOPK_OVERRIDES: dict[str, int] = {
    "smalltalk": 0,
    "greeting": 0,
    "out_of_scope": 0,
    "ask_faq": 3,
    "faq": 3,
    "ask_weather": 4,
    "ask_best_time": 4,
    "ask_budget": 5,
    "ask_transport": 4,
    "ask_food": 4,
    "ask_safety": 4,
    "ask_activity": 4,
    # Bug đã sửa: "ask_shopping" có trong INTENT_PATTERNS nhưng thiếu ở đây
    # → luôn rơi về default_top_k (no-op), không được tuning riêng.
    "ask_shopping": 4,
    "find_hotel": 5,
    "find_tour": 5,
    "find_ticket": 4,
    "ask_destination": 5,
    "plan_trip": 8,
    "itinerary_planner": 8,
    "compare_destinations": 8,
}


def get_dynamic_top_k(intent: Optional[str], default_top_k: int = 5) -> int:
    """Trả về số lượng chunk cần lấy, tuỳ theo intent câu hỏi."""
    if not intent:
        return default_top_k
    return _TOPK_OVERRIDES.get(intent, default_top_k)


# ── Qdrant tuning ───────────────────────────────────────────────────────────

def get_quantization_config(kind: str = "scalar") -> Optional[qmodels.ScalarQuantization]:
    """
    Scalar Quantization (int8) — giảm ~4x RAM cho vector, tốc độ tăng,
    độ chính xác giảm không đáng kể (phù hợp KB vài trăm-vài chục nghìn entries).
    """
    if kind != "scalar":
        return None
    return qmodels.ScalarQuantization(
        scalar=qmodels.ScalarQuantizationConfig(
            type=qmodels.ScalarType.INT8,
            quantile=0.99,
            always_ram=True,
        )
    )


def get_hnsw_config(size: str = "small") -> qmodels.HnswConfigDiff:
    """
    HNSW config tuỳ quy mô KB. Với KB nhỏ (vài trăm-vài nghìn điểm), m thấp
    và ef_construct vừa phải vẫn cho recall tốt mà build nhanh.
    """
    presets = {
        "small": qmodels.HnswConfigDiff(m=16, ef_construct=100, full_scan_threshold=10000),
        "medium": qmodels.HnswConfigDiff(m=24, ef_construct=200, full_scan_threshold=20000),
        "large": qmodels.HnswConfigDiff(m=32, ef_construct=400, full_scan_threshold=50000),
    }
    return presets.get(size, presets["small"])


def get_search_params(ef: int = 128) -> qmodels.SearchParams:
    """Search-time `ef` — cao hơn ef_construct một chút để tăng recall khi query."""
    return qmodels.SearchParams(hnsw_ef=ef, exact=False)


# ── Search metrics (đơn giản, in-memory) ───────────────────────────────────

class _SearchMetrics:
    """Ghi nhận latency các lần search Qdrant để debug/monitor."""

    def __init__(self, maxlen: int = 500) -> None:
        self._lock = threading.Lock()
        self._latencies: deque[int] = deque(maxlen=maxlen)

    def record(self, ms: int) -> None:
        with self._lock:
            self._latencies.append(ms)

    def summary(self) -> dict:
        with self._lock:
            data = list(self._latencies)
        if not data:
            return {"count": 0, "avg_ms": 0, "p95_ms": 0, "max_ms": 0}
        sorted_data = sorted(data)
        p95_idx = max(0, int(len(sorted_data) * 0.95) - 1)
        return {
            "count": len(data),
            "avg_ms": round(statistics.mean(data), 1),
            "p95_ms": sorted_data[p95_idx],
            "max_ms": max(data),
        }


search_metrics = _SearchMetrics()
