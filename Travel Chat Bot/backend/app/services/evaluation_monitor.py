"""
Evaluation Monitor — YÊU CẦU 8.

performance_monitor: singleton in-memory ghi nhận các chỉ số vận hành của RAG
pipeline (latency tổng, TTFT, cache hit-rate) để có cơ sở đánh giá/báo cáo,
không cần thêm hạ tầng (Prometheus/Grafana) cho quy mô đồ án.

Có thể mở rộng sau (P1 roadmap) để định kỳ flush các số liệu này vào DB/
log file phục vụ phân tích feedback loop.
"""

from __future__ import annotations

import statistics
import threading
import time
from collections import deque


class _PerformanceMonitor:
    def __init__(self, maxlen: int = 1000) -> None:
        self._lock = threading.Lock()
        self._latencies: deque[int] = deque(maxlen=maxlen)
        self._ttfts: deque[int] = deque(maxlen=maxlen)
        self._cache_hits = 0
        self._cache_misses = 0
        self._started_at = time.time()

    def record_latency(self, ms: int) -> None:
        with self._lock:
            self._latencies.append(ms)

    def record_ttft(self, ms: int) -> None:
        with self._lock:
            self._ttfts.append(ms)

    def record_cache_lookup(self, hit: bool) -> None:
        with self._lock:
            if hit:
                self._cache_hits += 1
            else:
                self._cache_misses += 1

    def _percentile(self, data: list[int], pct: float) -> int:
        if not data:
            return 0
        s = sorted(data)
        idx = max(0, min(len(s) - 1, int(len(s) * pct) - 1))
        return s[idx]

    def summary(self) -> dict:
        with self._lock:
            latencies = list(self._latencies)
            ttfts = list(self._ttfts)
            total_lookups = self._cache_hits + self._cache_misses
            cache_hit_rate = (
                round(self._cache_hits / total_lookups, 4) if total_lookups else 0.0
            )
            return {
                "uptime_seconds": int(time.time() - self._started_at),
                "request_count": len(latencies),
                "latency_avg_ms": round(statistics.mean(latencies), 1) if latencies else 0,
                "latency_p95_ms": self._percentile(latencies, 0.95),
                "latency_max_ms": max(latencies) if latencies else 0,
                "ttft_avg_ms": round(statistics.mean(ttfts), 1) if ttfts else 0,
                "ttft_p95_ms": self._percentile(ttfts, 0.95),
                "cache_hit_rate": cache_hit_rate,
                "cache_hits": self._cache_hits,
                "cache_misses": self._cache_misses,
            }


performance_monitor = _PerformanceMonitor()
