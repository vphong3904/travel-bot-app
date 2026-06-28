"""
Test cho app/services/hybrid_search.py — YÊU CẦU 7 (Hybrid Search).

Test các phần pure-logic không cần Qdrant/PostgreSQL/model thật:
  - _dedup_key(): khoá khử trùng giữa 2 nhánh search
  - _reciprocal_rank_fusion(): hợp nhất rank Qdrant + PostgreSQL FTS
  - hybrid_search(): luồng tổng (dùng use_reranking=False để không phải
    tải cross-encoder thật — cross-encoder có fallback an toàn riêng,
    không cần test lại model bên thứ ba ở đây)

Chạy: pytest backend/tests/test_hybrid_search.py -v
"""

from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.services.hybrid_search import (  # noqa: E402
    _dedup_key,
    _reciprocal_rank_fusion,
    hybrid_search,
)


# ════════════════════════════════════════════════════════════════════════════
# _dedup_key
# ════════════════════════════════════════════════════════════════════════════

class TestDedupKey:
    def test_uses_title_when_present(self):
        item = {"title": "Đà Lạt Mộng Mơ", "text": "..."}
        assert _dedup_key(item) == "title::đà lạt mộng mơ"

    def test_title_is_case_and_whitespace_insensitive(self):
        a = {"title": "  Đà Lạt  "}
        b = {"title": "đà lạt"}
        assert _dedup_key(a) == _dedup_key(b)

    def test_falls_back_to_text_prefix_when_no_title(self):
        item = {"text": "Một đoạn mô tả dài về Phú Quốc..."}
        key = _dedup_key(item)
        assert key.startswith("text::")
        assert "phú quốc" in key.lower() or "phu quoc" in key.lower() or "một đoạn" in key

    def test_empty_item_does_not_raise(self):
        # Không có title, không có text — vẫn phải trả về key hợp lệ, không crash
        key = _dedup_key({})
        assert key == "text::"


# ════════════════════════════════════════════════════════════════════════════
# _reciprocal_rank_fusion
# ════════════════════════════════════════════════════════════════════════════

class TestReciprocalRankFusion:
    def test_item_found_in_both_branches_ranks_higher(self):
        """Item xuất hiện ở cả 2 nhánh phải có rrf_score cao hơn item chỉ
        xuất hiện ở 1 nhánh, vì điểm RRF được cộng dồn."""
        qdrant = [{"title": "Đà Lạt"}, {"title": "Phú Quốc"}]
        pg = [{"title": "Đà Lạt"}]
        fused = _reciprocal_rank_fusion(qdrant, pg)

        da_lat = next(it for it in fused if it["title"] == "Đà Lạt")
        phu_quoc = next(it for it in fused if it["title"] == "Phú Quốc")
        assert da_lat["rrf_score"] > phu_quoc["rrf_score"]

    def test_item_in_both_branches_marked_found_in_both(self):
        qdrant = [{"title": "Đà Lạt"}]
        pg = [{"title": "Đà Lạt"}]
        fused = _reciprocal_rank_fusion(qdrant, pg)
        assert fused[0].get("found_in_both") is True

    def test_item_only_in_one_branch_not_marked(self):
        qdrant = [{"title": "Đà Lạt"}]
        pg: list[dict] = []
        fused = _reciprocal_rank_fusion(qdrant, pg)
        assert fused[0].get("found_in_both") is None

    def test_higher_rank_in_either_branch_scores_higher(self):
        """Rank 0 (đầu danh sách) phải có điểm RRF cao hơn rank thấp hơn,
        vì công thức 1/(k+rank+1) giảm dần theo rank."""
        qdrant = [{"title": "A"}, {"title": "B"}, {"title": "C"}]
        fused = _reciprocal_rank_fusion(qdrant, [])
        scores = [it["rrf_score"] for it in fused]
        assert scores == sorted(scores, reverse=True)

    def test_empty_inputs_return_empty(self):
        assert _reciprocal_rank_fusion([], []) == []

    def test_result_sorted_descending_by_score(self):
        qdrant = [{"title": "A"}, {"title": "B"}]
        pg = [{"title": "B"}, {"title": "C"}, {"title": "A"}]
        fused = _reciprocal_rank_fusion(qdrant, pg)
        scores = [it["rrf_score"] for it in fused]
        assert scores == sorted(scores, reverse=True)


# ════════════════════════════════════════════════════════════════════════════
# hybrid_search() — luồng tổng, không dùng reranker thật
# ════════════════════════════════════════════════════════════════════════════

class TestHybridSearchFlow:
    @pytest.mark.asyncio
    async def test_method_is_hybrid_when_both_branches_have_results(self):
        async def qdrant_fn():
            return [{"title": "Đà Lạt", "text": "..."}]

        async def pg_fn():
            return [{"title": "Phú Quốc", "text": "..."}]

        results, meta = await hybrid_search(
            "câu hỏi mẫu", qdrant_fn, pg_fn, use_reranking=False
        )
        assert meta["method"] == "hybrid"
        assert meta["qdrant_count"] == 1
        assert meta["pg_count"] == 1
        assert len(results) == 2

    @pytest.mark.asyncio
    async def test_method_is_qdrant_only_when_pg_empty(self):
        async def qdrant_fn():
            return [{"title": "Đà Lạt", "text": "..."}]

        async def pg_fn():
            return []

        results, meta = await hybrid_search(
            "câu hỏi mẫu", qdrant_fn, pg_fn, use_reranking=False
        )
        assert meta["method"] == "qdrant_only"
        assert len(results) == 1

    @pytest.mark.asyncio
    async def test_method_is_postgres_only_when_qdrant_empty(self):
        async def qdrant_fn():
            return []

        async def pg_fn():
            return [{"title": "Phú Quốc", "text": "..."}]

        results, meta = await hybrid_search(
            "câu hỏi mẫu", qdrant_fn, pg_fn, use_reranking=False
        )
        assert meta["method"] == "postgres_only"

    @pytest.mark.asyncio
    async def test_method_is_none_when_both_empty(self):
        async def qdrant_fn():
            return []

        async def pg_fn():
            return []

        results, meta = await hybrid_search(
            "câu hỏi mẫu", qdrant_fn, pg_fn, use_reranking=False
        )
        assert meta["method"] == "none"
        assert results == []
        # Đảm bảo pipeline không cần chạy RRF/rerank khi không có gì để xử lý
        assert meta["qdrant_count"] == 0
        assert meta["pg_count"] == 0

    @pytest.mark.asyncio
    async def test_respects_final_top_k_limit(self):
        async def qdrant_fn():
            return [{"title": f"Đ{i}", "text": "..."} for i in range(10)]

        async def pg_fn():
            return []

        results, _ = await hybrid_search(
            "câu hỏi mẫu", qdrant_fn, pg_fn, final_top_k=3, use_reranking=False
        )
        assert len(results) == 3

    @pytest.mark.asyncio
    async def test_no_reranking_flag_reflected_in_meta(self):
        async def qdrant_fn():
            return [{"title": "Đà Lạt", "text": "..."}]

        async def pg_fn():
            return []

        _, meta = await hybrid_search(
            "câu hỏi mẫu", qdrant_fn, pg_fn, use_reranking=False
        )
        assert meta["reranked"] is False


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-v"]))
