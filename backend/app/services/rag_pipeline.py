"""
RAG Pipeline — Retrieval-Augmented Generation cho PDTrip chatbot.

SDK: google-genai >= 2.0 (thay thế google-generativeai cũ)

Flow đầy đủ (đã tích hợp 8 hạng mục tối ưu):
  0. [NLP] Normalize / Intent Detection / Entity Extraction / Query Rewriting /
     Clarification Flow / Out-of-scope handling   (nlp_preprocessor.py — YÊU CẦU 2)
  1. [Cache] Kiểm tra exact-match + semantic cache trước khi làm bất cứ điều gì
     (cache_layer.py — YÊU CẦU 4)
  2. Embed câu hỏi bằng BGE-M3 (asyncio.to_thread), cache embedding
  3. [Hybrid Search] Chạy SONG SONG Qdrant (semantic) + PostgreSQL FTS (keyword),
     hợp nhất bằng Reciprocal Rank Fusion, sau đó re-rank bằng cross-encoder
     (hybrid_search.py — YÊU CẦU 7)
  4. [Retrieval Optimizer] Dynamic top-K theo intent (retrieval_optimizer.py — YÊU CẦU 6)
  5. [Hallucination Guard] Dynamic threshold lọc kết quả + đánh dấu nguồn fallback
     (hallucination_guard.py — YÊU CẦU 3)
  6. Build prompt với history + context (system instruction tách riêng)
  7. [Gemini Optimizer] system_instruction riêng, dynamic max_output_tokens,
     sliding summary cho history dài, retry/backoff, TTFT tracking
     (gemini_optimizer.py — YÊU CẦU 5)
  8. [Hallucination Guard] Grounding check + citation validation sau khi sinh câu trả lời
  9. [Cache] Lưu kết quả vào cache (FAQ/semantic) để câu hỏi sau trả lời tức thì
  10. [Evaluation Monitor] Ghi nhận latency/TTFT/cache-hit vào performance_monitor
     (evaluation_monitor.py — YÊU CẦU 8)

Knowledge Base mở rộng (destination/weather/cuisine/accommodation/transport/
festival/safety/FAQ) nằm ở initdb/02_knowledge_base_extended.sql — YÊU CẦU 1.

BUG FIXES (kế thừa từ trước):
  - Root cause "0 points": Qdrant collection chưa được embed data từ DB
    → Fix ở main.py: tự động run_pending() khi startup
  - score_threshold=0.3 (BGE-M3 cosine, tiếng Việt thường 0.3-0.7) làm baseline,
    dynamic threshold (0.45 ưu tiên / 0.30 fallback) áp dụng ở hallucination_guard
  - Thêm PostgreSQL FTS fallback → chatbot KHÔNG BAO GIỜ bị thiếu context
  - Anti-hallucination: prompt chặt hơn, yêu cầu trích dẫn nguồn
  - Memory: tăng history lên 10 tin nhắn (nay có thêm sliding summary khi dài hơn)
"""

from __future__ import annotations

import asyncio
import os
import time
import uuid
from typing import AsyncGenerator, Optional

from google import genai
from google.genai import types as genai_types
from qdrant_client import QdrantClient
from qdrant_client.http import models as qmodels
from sentence_transformers import SentenceTransformer

from app.core.config import settings
from app.services import cache_layer
from app.services import nlp_preprocessor as nlp
from app.services import hallucination_guard as guard
from app.services import gemini_optimizer as gopt
from app.services import retrieval_optimizer as ropt
from app.services import hybrid_search as hybrid
from app.services import structured_search
from app.services import quick_replies
from app.services import evaluation_monitor as evalmon
from app.utils import get_logger

logger = get_logger("rag_pipeline")

import re as _re

# [FAQ-direct] Ngưỡng cosine để trả thẳng đáp án FAQ (không gọi Gemini). Cao để
# tránh trả nhầm FAQ khác ý. Chỉnh qua RAG_FAQ_DIRECT.
_FAQ_DIRECT_THRESHOLD: float = float(os.getenv("RAG_FAQ_DIRECT", "0.68"))


def _clean_faq(text: str) -> str:
    """Tách phần đáp án từ nội dung faq dạng 'Q: ...\\nA: ...\\n## ...'."""
    if not text:
        return ""
    if "A:" in text:
        text = text.split("A:", 1)[1]
    # cắt phần heading markdown thừa (## ...) bị lẫn khi parse faq.md — kể cả khi
    # không đứng đầu dòng (parser đôi lúc nối liền).
    text = _re.split(r"#{2,}\s", text)[0]
    return text.strip()


# [OPT-2.3] Cross-encoder rerank (bge-reranker-v2-m3, 568M) tốn ~7s/query khi
# chạy cùng bge-m3 trên GPU 6GB (tranh VRAM) — phá vỡ mục tiêu <2s. RRF fusion
# (Qdrant semantic + PG keyword) đã cho thứ hạng tốt, structured DB lại đứng đầu
# sources, nên TẮT rerank mặc định. Bật lại qua RAG_RERANK=1 nếu có GPU mạnh.
_RERANK_ENABLED: bool = os.getenv("RAG_RERANK", "0") == "1"


# ── Lazy singletons ───────────────────────────────────────────────────────────

_embed_model: Optional[SentenceTransformer] = None
_qdrant: Optional[QdrantClient] = None
_genai_client: Optional[genai.Client] = None


def _detect_device() -> str:
    """
    [OPT-1.3] Tự nhận thiết bị: 'cuda' nếu có GPU NVIDIA + torch bản CUDA, ngược
    lại 'cpu'. An toàn khi torch là bản CPU-only hoặc không có driver — luôn
    fallback 'cpu', không bao giờ raise.
    """
    try:
        import torch
        if torch.cuda.is_available():
            return "cuda"
    except Exception as e:
        logger.warning(f"[Device] Không kiểm tra được CUDA, dùng CPU: {e}")
    return "cpu"


def _get_embed_model() -> SentenceTransformer:
    global _embed_model
    if _embed_model is None:
        device = _detect_device()
        logger.info(f"Loading embedding model: {settings.EMBEDDING_MODEL} | device={device}")
        t0 = time.monotonic()
        _embed_model = SentenceTransformer(settings.EMBEDDING_MODEL, device=device)
        # Warm-up: encode 1 câu để load weights lên RAM/GPU ngay (giảm cold-start)
        _embed_model.encode(["warm-up"], normalize_embeddings=True)
        logger.info(
            f"Embedding model loaded in {int((time.monotonic()-t0)*1000)}ms (device={device})"
        )
    return _embed_model


def _get_qdrant() -> QdrantClient:
    global _qdrant
    if _qdrant is None:
        _qdrant = QdrantClient(
            url=settings.QDRANT_URL,
            api_key= settings.QDRANT_API_KEY,
            timeout=10,
            prefer_grpc=False,
        )
        logger.info(f"Connected to Qdrant at {settings.QDRANT_URL}")
    return _qdrant


def _get_genai_client() -> genai.Client:
    global _genai_client
    if _genai_client is None:
        if not settings.GEMINI_API_KEY:
            raise RuntimeError("GEMINI_API_KEY chưa được cấu hình trong .env")
        _genai_client = genai.Client(api_key=settings.GEMINI_API_KEY)
        logger.info(f"Initialized google-genai Client (model: {settings.GEMINI_MODEL})")
    return _genai_client


# ── Sync helpers ─────────────────────────────────────────────────────────────

def _embed_sync(text: str) -> list[float]:
    model = _get_embed_model()
    vec = model.encode(text, normalize_embeddings=True)
    return vec.tolist()


def _ensure_collection_sync() -> None:
    client = _get_qdrant()
    existing = [c.name for c in client.get_collections().collections]
    
    # Fix: mỗi collection check riêng
    for col_name in [settings.QDRANT_COLLECTION, settings.QDRANT_COLLECTION_KB_FILES]:
        if col_name not in existing:
            client.create_collection(
                collection_name=col_name,
                vectors_config=qmodels.VectorParams(
                    size=settings.EMBEDDING_DIM,
                    distance=qmodels.Distance.COSINE,
                ),
                quantization_config=ropt.get_quantization_config("scalar"),
                hnsw_config=ropt.get_hnsw_config("small"),
                optimizers_config=qmodels.OptimizersConfigDiff(
                    indexing_threshold=0,
                ),
            )
            logger.info(f"[Qdrant] Auto-created collection '{col_name}'")
        else:
            logger.info(f"[Qdrant] Collection '{col_name}' already exists")

    # [FAQ-direct] Payload index để lọc category/destination_id (bắt buộc, nếu
    # không Qdrant trả 400 khi filter). Idempotent — gọi lại không sao.
    for field in ("category", "destination_id"):
        try:
            client.create_payload_index(
                collection_name=settings.QDRANT_COLLECTION,
                field_name=field,
                field_schema="keyword",
            )
        except Exception:
            pass  # đã tồn tại hoặc không cần


def _city_filter(destination_id: Optional[str]):
    """
    [P0 anti cross-city] Lọc KB theo đúng thành phố: chỉ nhận entry của
    destination_id ĐÓ hoặc entry CHUNG (destination_id rỗng) — loại KB tỉnh khác.
    Trả None nếu không có destination_id (không lọc).
    """
    if not destination_id:
        return None
    return qmodels.Filter(should=[
        qmodels.FieldCondition(key="destination_id", match=qmodels.MatchValue(value=str(destination_id))),
        qmodels.FieldCondition(key="destination_id", match=qmodels.MatchValue(value="")),
    ])


def _search_qdrant_sync(
    query_vec: list[float], top_k: int, destination_id: Optional[str] = None
) -> list[dict]:
    """
    Search Qdrant với auto-create collection nếu chưa tồn tại.
    score_threshold=settings.RAG_SCORE_THRESHOLD là ngưỡng baseline (thấp, để
    tránh "0 results"); dynamic threshold thực sự được áp dụng sau ở
    hallucination_guard.filter_by_dynamic_threshold().

    [P0] destination_id != None → chỉ trả KB của đúng thành phố + KB chung
    (tránh nhiễm chéo: câu Đà Lạt trả nguồn Cao Bằng/Buôn Ma Thuột).

    [YÊU CẦU 6] HNSW search params (ef) được áp dụng để cân bằng tốc độ/recall.
    """
    if top_k <= 0:
        return []

    client = _get_qdrant()

    try:
        results = client.query_points(
            collection_name=settings.QDRANT_COLLECTION,
            query=query_vec,
            limit=top_k,
            with_payload=True,
            score_threshold=settings.RAG_SCORE_THRESHOLD,
            search_params=ropt.get_search_params(),
            query_filter=_city_filter(destination_id),
        ).points
    except Exception as e:
        err = str(e)
        if "doesn't exist" in err or "Not found" in err or "404" in err:
            logger.warning(f"[Qdrant] Collection not found, auto-creating... ({err})")
            _ensure_collection_sync()
            return []
        raise

    hits = [
        {
            "id": str(r.id),
            "score": round(r.score, 4),
            "text": r.payload.get("text", "") if r.payload else "",
            "title": r.payload.get("title", "") if r.payload else "",
            "category": r.payload.get("category", "") if r.payload else "",
            "source": "qdrant",
        }
        for r in results
    ]

    logger.debug(
        f"[Qdrant] query → {len(hits)} hits "
        f"(threshold={settings.RAG_SCORE_THRESHOLD}, top_k={top_k})"
    )
    if hits:
        scores = [h["score"] for h in hits]
        logger.debug(f"[Qdrant] scores: min={min(scores):.3f} max={max(scores):.3f}")
    else:
        logger.warning(
            "[Qdrant] 0 points returned — sẽ fallback sang PostgreSQL FTS. "
            "Kiểm tra: (1) đã embed data chưa (POST /debug/qdrant/reindex), "
            "(2) RAG_SCORE_THRESHOLD không quá cao, "
            "(3) EMBEDDING_DIM khớp với collection."
        )

    return hits


# ── T-012: Search KB-files collection (KNOWLEDGE_SOURCE=files|hybrid) ────────

def _search_qdrant_kb_sync(query_vec: list[float], top_k: int) -> list[dict]:
    """
    Search Qdrant collection KB files (import từ T-011).
    Dùng khi KNOWLEDGE_SOURCE=files.
    """
    if top_k <= 0:
        return []

    client = _get_qdrant()
    kb_collection = settings.QDRANT_COLLECTION_KB_FILES

    try:
        results = client.query_points(
            collection_name=kb_collection,
            query=query_vec,
            limit=top_k,
            with_payload=True,
            score_threshold=settings.RAG_SCORE_THRESHOLD,
            search_params=ropt.get_search_params(),
        ).points
    except Exception as e:
        err_msg = str(e)
        logger.error(f"[Qdrant-KB] Search lỗi: {type(e).__name__}: {err_msg}")
        if "doesn't exist" in err_msg or "Not found" in err_msg or "404" in err_msg:
            logger.warning(
                f"[Qdrant-KB] Collection '{kb_collection}' chưa có data. "
                f"Chạy: python backend/scripts/import_knowledge_base.py"
            )
        return []

    hits = [
        {
            "id": str(r.id),
            "score": round(r.score, 4),
            "text": r.payload.get("text", "") if r.payload else "",
            "title": r.payload.get("item_name", r.payload.get("title", "")) if r.payload else "",
            "category": r.payload.get("category", "") if r.payload else "",
            "city": r.payload.get("city", "") if r.payload else "",
            "source_file": r.payload.get("source_file", "") if r.payload else "",
            "source": "qdrant_kb",
        }
        for r in results
    ]

    logger.debug(f"[Qdrant-KB] query → {len(hits)} hits (collection={kb_collection})")
    return hits


def _search_qdrant_hybrid_mode(
    query_vec: list[float], top_k: int, destination_id: Optional[str] = None
) -> list[dict]:
    """
    T-012 hybrid mode: query SONG SONG cả 2 collections, dedupe theo title+city,
    ưu tiên nguồn kb_files khi conflict (đã qua validate T-010).
    """
    import concurrent.futures

    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as ex:
        fut_db = ex.submit(_search_qdrant_sync, query_vec, top_k, destination_id)
        fut_kb = ex.submit(_search_qdrant_kb_sync, query_vec, top_k)
        db_hits = fut_db.result()
        kb_hits = fut_kb.result()

    for h in db_hits:
        h["knowledge_source"] = "db"
    for h in kb_hits:
        h["knowledge_source"] = "files"

    # Dedupe: kb_files ưu tiên (thắng khi conflict)
    seen: dict[str, dict] = {}
    conflicts = 0
    for h in kb_hits:
        key = f"{h.get('city','')}::{h.get('title','')}"
        seen[key] = h
    for h in db_hits:
        key = f"{h.get('city','')}::{h.get('title','')}"
        if key in seen:
            conflicts += 1
        else:
            seen[key] = h

    if conflicts:
        logger.info(f"[Hybrid] {conflicts} conflicts — kb_files wins. db={len(db_hits)} kb={len(kb_hits)}")

    merged = sorted(seen.values(), key=lambda x: x.get("score", 0), reverse=True)[:top_k]
    return merged


def _route_qdrant_search(
    query_vec: list[float], top_k: int, destination_id: Optional[str] = None
) -> list[dict]:
    """
    T-012: Router — đọc KNOWLEDGE_SOURCE từ settings và dispatch đúng hàm search.
      db     → collection cũ (EmbeddingJob pipeline) — mặc định, an toàn
      files  → collection KB files (T-011)
      hybrid → cả hai, dedupe, kb_files ưu tiên
    [P0] destination_id được luồn vào nhánh 'db' để lọc KB đúng thành phố.
    """
    source = getattr(settings, "KNOWLEDGE_SOURCE", "db").lower()
    if source == "files":
        return _search_qdrant_kb_sync(query_vec, top_k)
    elif source == "hybrid":
        return _search_qdrant_hybrid_mode(query_vec, top_k, destination_id)
    else:  # "db" hoặc bất kỳ giá trị không hợp lệ → fallback về db
        if source not in ("db", "files", "hybrid"):
            logger.warning(f"[RAG] KNOWLEDGE_SOURCE='{source}' không hợp lệ, dùng 'db'")
        return _search_qdrant_sync(query_vec, top_k, destination_id)


def _upsert_qdrant_sync(entries: list[dict]) -> int:
    """
    Embed + upsert danh sách knowledge entries vào Qdrant.
    Point ID dùng UUID5 deterministic từ (entry_id, chunk_index).
    """
    client = _get_qdrant()
    model = _get_embed_model()

    texts = [e["text"] for e in entries]
    vectors = model.encode(
        texts,
        normalize_embeddings=True,
        batch_size=64,
        show_progress_bar=False,
    ).tolist()

    points = []
    for e, vec in zip(entries, vectors):
        point_uuid = str(uuid.uuid5(uuid.NAMESPACE_OID, e["id"]))
        points.append(
            qmodels.PointStruct(
                id=point_uuid,
                vector=vec,
                payload={
                    "text": e["text"],
                    "title": e.get("title", ""),
                    "category": e.get("category", ""),
                    "source_id": e["id"],
                    # [FAQ-direct] cho phép lọc theo thành phố khi trả FAQ trực tiếp
                    "destination_id": e.get("destination_id", ""),
                },
            )
        )

    client.upsert(
        collection_name=settings.QDRANT_COLLECTION,
        points=points,
        wait=True,
    )
    logger.info(f"[Qdrant] Upserted {len(points)} points into '{settings.QDRANT_COLLECTION}'")
    return len(points)


def _faq_direct_sync(query_vec: list[float], destination_id: str) -> Optional[str]:
    """
    [FAQ-direct] Tìm FAQ khớp nhất cho ĐÚNG thành phố (lọc category=faq +
    destination_id). Trả đáp án đã làm sạch nếu cosine ≥ ngưỡng, ngược lại None.
    Lọc theo destination_id để tránh trả FAQ của tỉnh khác.
    """
    if not destination_id:
        return None
    client = _get_qdrant()
    try:
        res = client.query_points(
            collection_name=settings.QDRANT_COLLECTION,
            query=query_vec,
            limit=1,
            with_payload=True,
            score_threshold=_FAQ_DIRECT_THRESHOLD,
            query_filter=qmodels.Filter(must=[
                qmodels.FieldCondition(key="category", match=qmodels.MatchValue(value="faq")),
                qmodels.FieldCondition(key="destination_id", match=qmodels.MatchValue(value=destination_id)),
            ]),
        ).points
    except Exception as e:
        logger.warning(f"[FAQ-direct] search lỗi: {e}")
        return None
    if not res:
        return None
    answer = _clean_faq(res[0].payload.get("text", "") if res[0].payload else "")
    if answer:
        logger.info(f"[FAQ-direct] hit score={res[0].score:.3f} dest={destination_id[:8]}")
    return answer or None


def _delete_qdrant_sync(entry_id: str) -> None:
    """Xoá tất cả chunk của một entry."""
    client = _get_qdrant()
    client.delete(
        collection_name=settings.QDRANT_COLLECTION,
        points_selector=qmodels.FilterSelector(
            filter=qmodels.Filter(
                must=[
                    qmodels.FieldCondition(
                        key="source_id",
                        match=qmodels.MatchText(text=entry_id),
                    )
                ]
            )
        ),
        wait=True,
    )


def _build_prompt(
    question: str,
    context_chunks: list[dict],
    history: list[dict],
    summary_text: Optional[str] = None,
) -> str:
    """
    Xây dựng phần `contents` gửi tới Gemini — KHÔNG còn chứa nguyên tắc
    chống hallucination (đã chuyển sang `gemini_optimizer.SYSTEM_INSTRUCTION`,
    truyền qua `config.system_instruction` — YÊU CẦU 5.1). Hàm này chỉ build
    phần biến đổi theo từng request: context, lịch sử, câu hỏi.

    [YÊU CẦU 3] Context chunks đến từ PostgreSQL FTS fallback được đánh dấu rõ
    "[Nguồn gần đúng]" để Gemini thận trọng hơn khi dùng.
    """
    context_text = ""
    if context_chunks:
        lines = []
        for i, c in enumerate(context_chunks):
            src_tag = f"[{i + 1}]"
            title = f" ({c['title']})" if c.get("title") else ""
            cat = f" [{c.get('category', '')}]" if c.get("category") else ""
            approx_tag = " [Nguồn gần đúng]" if c.get("is_approximate") else ""
            lines.append(f"{src_tag}{title}{cat}{approx_tag}\n{c['text']}")
        context_text = "\n\n".join(lines)

    history_text = ""
    if history:
        lines = []
        for msg in history[-10:]:
            role = "Người dùng" if msg["role"] == "user" else "Trợ lý"
            lines.append(f"{role}: {msg['content']}")
        history_text = "\n".join(lines)

    prompt = gopt.FEW_SHOT_EXAMPLES + "\n"

    if summary_text:
        prompt += f"=== Tóm tắt hội thoại trước đó ===\n{summary_text}\n\n"

    if context_text:
        prompt += f"=== Thông tin tham khảo ===\n{context_text}\n\n"
    else:
        prompt += (
            "=== Thông tin tham khảo ===\n"
            "[Không tìm thấy thông tin liên quan trong knowledge base]\n\n"
        )

    if history_text:
        prompt += f"=== Lịch sử hội thoại gần đây ===\n{history_text}\n\n"

    prompt += f"=== Câu hỏi ===\n{question}\n\n=== Câu trả lời ==="
    return prompt


# ── Gemini config ─────────────────────────────────────────────────────────────

def _parse_answer_and_suggestions(raw: str) -> tuple[str, list[str]]:
    """Tách phần câu trả lời chính và suggested_questions từ output Gemini."""
    marker_start = "<<<SUGGESTED_QUESTIONS>>>"
    marker_end = "<<<END_SUGGESTED>>>"
    suggested: list[str] = []

    if marker_start in raw and marker_end in raw:
        answer_part = raw[:raw.index(marker_start)].strip()
        block = raw[raw.index(marker_start) + len(marker_start):raw.index(marker_end)]
        for line in block.splitlines():
            line = line.strip().lstrip("-").strip()
            if line:
                suggested.append(line)
    else:
        answer_part = raw.strip()

    return answer_part, suggested


# Lưu ý: _gemini_config() cũ đã được thay bằng gopt.gemini_config(intent)
# — xem app/services/gemini_optimizer.py (YÊU CẦU 5: system_instruction tách
# riêng + dynamic max_output_tokens theo intent).

# fallback answer khi Gemini không available (tạm thời quá tải, timeout, lỗi mạng)
def _build_rag_fallback_answer(sources: list[dict], question: str) -> str:
    """
    Fallback khi Gemini không available: tổng hợp câu trả lời thô từ Qdrant sources.
    Trả về thông tin có sẵn thay vì báo lỗi.
    """
    if not sources:
        return (
            "Xin lỗi, trợ lý AI đang tạm bận. "
            "Mình chưa tìm được thông tin phù hợp cho câu hỏi này — "
            "bạn thử hỏi lại cụ thể hơn (kèm tên địa danh) nhé!"
        )

    # [OPT-2.2] Khi LLM lỗi/hết quota: vẫn trả lời HỮU ÍCH bằng dữ liệu thật từ DB,
    # nhóm theo loại cho dễ đọc thay vì dump thô. Đây là "graceful degradation".
    _CAT_LABEL = {
        "hotel": "🏨 Khách sạn", "tour": "🧳 Tour", "transport": "🚗 Di chuyển",
        "shopping": "🛍 Mua sắm", "attraction": "📍 Điểm đến", "event": "🎉 Sự kiện",
        "ticket": "🎟 Vé/giá", "itinerary": "🗺 Lịch trình",
        "food": "🍜 Ẩm thực", "faq": "ℹ️ Hỏi đáp", "tip": "💡 Kinh nghiệm",
    }
    grouped: dict[str, list[str]] = {}
    seen = set()
    for src in sources[:10]:
        text = (src.get("text") or "").strip()
        if not text or text in seen:
            continue
        seen.add(text)
        cat = (src.get("category") or "").strip()
        grouped.setdefault(cat, []).append(text[:300] + ("…" if len(text) > 300 else ""))

    lines = ["Dưới đây là thông tin từ cơ sở dữ liệu PDTrip cho câu hỏi của bạn:\n"]
    for cat, items in grouped.items():
        label = _CAT_LABEL.get(cat, "•")
        lines.append(f"**{label}**")
        for it in items[:6]:
            lines.append(f"- {it}")
        lines.append("")
    lines.append("_(Tư vấn AI chi tiết hơn sẽ sẵn sàng ngay khi hệ thống bớt tải.)_")
    return "\n".join(lines)

# ── RAGPipeline ───────────────────────────────────────────────────────────────

class RAGPipeline:
    """
    Async RAG pipeline dùng cho FastAPI.

    - Embedding / Qdrant: asyncio.to_thread (sync libs)
    - PostgreSQL FTS: async SQLAlchemy fallback khi Qdrant trống
    - Gemini: client.aio.models.* (async native)
    """

    # ── Private helpers ───────────────────────────────────────────────────────

    async def _embed(self, text: str) -> tuple[list[float], int]:
        t0 = time.monotonic()
        vec = await asyncio.to_thread(_embed_sync, text)
        ms = int((time.monotonic() - t0) * 1000)
        return vec, ms

    async def _resolve_destination_id(
        self, location: Optional[str], city_slug: Optional[str]
    ) -> Optional[str]:
        """[P0] destination_id (str) nếu resolve được thành phố từ entities; None nếu không."""
        if not location and not city_slug:
            return None
        try:
            from app.db.database import AsyncSessionLocal
            from app.services.structured_search import resolve_destination
            async with AsyncSessionLocal() as db:
                did, _ = await resolve_destination(db, location, city_slug)
            return str(did) if did else None
        except Exception as e:
            logger.warning(f"[RAG] resolve destination_id lỗi: {e}")
            return None

    async def _faq_direct(
        self, query_vec: list[float], location: Optional[str], city_slug: Optional[str]
    ) -> Optional[str]:
        """[FAQ-direct] Trả đáp án FAQ của đúng thành phố nếu khớp cao — không gọi LLM."""
        if not location and not city_slug:
            return None
        try:
            from app.db.database import AsyncSessionLocal
            from app.services.structured_search import resolve_destination
            async with AsyncSessionLocal() as db:
                did, _ = await resolve_destination(db, location, city_slug)
            if not did:
                return None
            return await asyncio.to_thread(_faq_direct_sync, query_vec, str(did))
        except Exception as e:
            logger.warning(f"[FAQ-direct] lỗi: {e}")
            return None

    async def _embed_cached(self, text: str) -> tuple[list[float], int, bool]:
        """
        [YÊU CẦU 4] Embedding cache: tránh encode lại câu hỏi trùng/tương tự.
        Trả về (vector, ms, was_cache_hit).
        """
        t0 = time.monotonic()
        cached = await cache_layer.get_cached_embedding(text)
        if cached is not None:
            ms = int((time.monotonic() - t0) * 1000)
            return cached, ms, True

        vec, embed_ms = await self._embed(text)
        await cache_layer.set_cached_embedding(text, vec)
        return vec, embed_ms, False

    async def _search(
        self, query_vec: list[float], top_k: int, destination_id: Optional[str] = None
    ) -> tuple[list[dict], int]:
        # T-012: dùng _route_qdrant_search thay vì gọi thẳng _search_qdrant_sync
        # Router đọc KNOWLEDGE_SOURCE=db|files|hybrid từ settings
        # [P0] destination_id để lọc KB đúng thành phố (tránh nhiễm chéo).
        t0 = time.monotonic()
        hits = await asyncio.to_thread(
            _route_qdrant_search, query_vec, top_k, destination_id
        )
        ms = int((time.monotonic() - t0) * 1000)
        ropt.search_metrics.record(ms)
        return hits, ms

    async def _search_postgres_fallback(
        self, question: str, top_k: Optional[int] = None, destination_id: Optional[str] = None
    ) -> list[dict]:
        """
        ✅ FIX: PostgreSQL Full-Text Search — dùng cả làm fallback (Qdrant=0)
        VÀ làm 1 nhánh của Hybrid Search (chạy song song với Qdrant — YÊU CẦU 7).

        Đảm bảo chatbot LUÔN CÓ CONTEXT ngay cả khi:
        - Qdrant chưa được embed (vừa khởi động)
        - score_threshold quá cao
        - Vector không match tốt với câu hỏi ngắn

        Dùng pg_trgm trigram similarity + FTS để tìm kiếm tiếng Việt.
        """
        limit = top_k if top_k is not None else settings.RAG_TOP_K
        if limit <= 0:
            return []
        try:
            from app.db.database import AsyncSessionLocal
            from sqlalchemy import text

            # Build query terms từ câu hỏi (loại stop words)
            stop_words = {"có", "không", "là", "và", "hoặc", "của", "để", "cho", "với",
                          "tôi", "mình", "bạn", "ở", "tại", "đi", "về", "thì", "mà",
                          "nên", "cần", "muốn", "hỏi", "cho", "biết", "thế", "nào"}
            words = [w for w in question.lower().split() if w not in stop_words and len(w) > 1]
            search_query = " | ".join(words[:8]) if words else question

            # [P0 anti cross-city] Lọc đúng thành phố + entry chung (destination_id NULL).
            params = {"q": question, "limit": limit}
            city_clause = ""
            if destination_id:
                city_clause = "AND (destination_id = CAST(:did AS uuid) OR destination_id IS NULL)"
                params["did"] = destination_id

            async with AsyncSessionLocal() as db:
                result = await db.execute(
                    text(f"""
                        SELECT title, category, content,
                               similarity(title || ' ' || content, :q) AS score
                        FROM knowledge_entries
                        WHERE is_active = TRUE
                          {city_clause}
                          AND (
                            to_tsvector('simple', title || ' ' || content)
                            @@ plainto_tsquery('simple', :q)
                            OR similarity(title || ' ' || content, :q) > 0.1
                          )
                        ORDER BY score DESC
                        LIMIT :limit
                    """),
                    params
                )
                rows = result.fetchall()

            if rows:
                logger.info(f"[PG FTS] Found {len(rows)} results for: {question[:50]}")
            else:
                logger.warning(f"[PG FTS] 0 results found for: {question[:50]}")

            return [
                {
                    "id": f"pg_{i}_{abs(hash(row.title)) % 100000}",
                    "score": round(float(row.score), 4) if row.score else 0.1,
                    "text": row.content,
                    "title": row.title,
                    "category": row.category,
                    "source": "postgres_fts",
                }
                for i, row in enumerate(rows)
            ]
        except Exception as e:
            logger.error(f"[PG FTS] Error: {e}")
            return []

    async def _get_sources(
        self, question: str, query_vec: list[float], intent: Optional[str] = None,
        entities: Optional[dict] = None,
    ) -> tuple[list[dict], int, str]:
        """
        [YÊU CẦU 7] Hybrid Search thực sự: chạy SONG SONG Qdrant (semantic) +
        PostgreSQL FTS (keyword), hợp nhất bằng Reciprocal Rank Fusion,
        sau đó re-rank bằng cross-encoder để lấy top-K cuối cùng.

        [OPT-2.2] Ngoài knowledge_entries, lấy thêm dữ liệu CÓ CẤU TRÚC từ Postgres
        (hotels/tours/tickets/transport/shopping/locations/events/itineraries) theo
        intent + địa danh, đưa lên đầu sources để Gemini grounding + đề xuất.

        [YÊU CẦU 6] top_k động theo intent (FAQ=3, itinerary=8...).
        [YÊU CẦU 3] Dynamic threshold áp dụng sau khi có kết quả Qdrant.

        Trả về (sources, search_ms, search_method).
        """
        final_top_k = ropt.get_dynamic_top_k(intent, default_top_k=settings.RAG_TOP_K)
        if final_top_k == 0:
            return [], 0, "skipped"

        rrf_pool_k = max(final_top_k * 3, 15)

        # [OPT-2.3] Rerank tắt mặc định (xem _RERANK_ENABLED) — quá chậm trên GPU 6GB.
        use_reranking = _RERANK_ENABLED

        # [P0 anti cross-city] Resolve thành phố từ entities để lọc KB đúng tỉnh.
        ent0 = entities or {}
        destination_id = await self._resolve_destination_id(
            ent0.get("location"), ent0.get("city_slug")
        )

        async def qdrant_branch():
            hits, _ms = await self._search(query_vec, rrf_pool_k, destination_id)
            filtered, _threshold = guard.filter_by_dynamic_threshold(hits)
            return filtered

        async def pg_branch():
            return await self._search_postgres_fallback(question, rrf_pool_k, destination_id)

        t0 = time.monotonic()
        final_results, meta = await hybrid.hybrid_search(
            question=question,
            qdrant_search_fn=qdrant_branch,
            postgres_search_fn=pg_branch,
            rrf_top_k=rrf_pool_k,
            final_top_k=final_top_k,
            use_reranking=use_reranking,
        )
        search_ms = int((time.monotonic() - t0) * 1000)

        # [YÊU CẦU 3] Đánh dấu rõ nguồn PostgreSQL FTS là "gần đúng"
        final_results = guard.annotate_fallback_sources(final_results)

        # [OPT-2.2] Bổ sung dữ liệu có cấu trúc (DB) theo intent + địa danh. Đưa
        # LÊN ĐẦU vì là dữ liệu thật, đầy đủ (giá, sao, địa chỉ...) — Gemini ưu
        # tiên dùng để trả lời chính xác + đề xuất theo sở thích.
        ent = entities or {}
        structured = await structured_search.fetch_structured_sources(
            intent=intent,
            location=ent.get("location"),
            city_slug=ent.get("city_slug"),
        )
        if structured:
            final_results = structured + final_results

        # search_method phản ánh nguồn đã dùng
        if not final_results:
            search_method = "no_results"
        elif structured:
            search_method = "db_structured+" + (meta["method"] if meta else "kb")
        else:
            search_method = meta["method"]

        return final_results, search_ms, search_method

    # ── Public: non-stream ────────────────────────────────────────────────────

    async def query(
        self,
        question: str,
        history: list[dict],
        session_id: str,
    ) -> dict:
        t0 = time.monotonic()

        # [Quick reply] Câu quen thuộc/meta (bạn là ai, giúp được gì, cảm ơn...) →
        # trả mẫu tức thì, KHÔNG embedding, KHÔNG Gemini.
        quick = quick_replies.match(question)
        if quick:
            return self._short_circuit_response(quick, t0, intent="quick_reply")

        # [YÊU CẦU 2] NLP preprocessing: normalize, intent, entities, rewriting,
        # clarification flow, out-of-scope / greeting short-circuit.
        nlp_result = nlp.preprocess(question, history)

        if nlp_result.is_greeting:
            return self._short_circuit_response(
                nlp.get_greeting_response(hash(session_id) % 3), t0, intent="greeting"
            )

        if nlp_result.is_out_of_scope:
            return self._short_circuit_response(
                nlp.OUT_OF_SCOPE_RESPONSE, t0, intent="out_of_scope"
            )

        if nlp_result.needs_clarification:
            options_text = "\n".join(f"- {opt}" for opt in nlp_result.clarification_options)
            answer = f"{nlp_result.clarification_message}\n\n{options_text}"
            return self._short_circuit_response(answer, t0, intent="clarification")

        effective_question = nlp_result.rewritten_query
        intent = nlp_result.intent

        # [Anti-hallucination theo nhóm] Nếu user hỏi đúng 1 nhóm (khách sạn/tour/
        # mua sắm/di chuyển/ẩm thực) cho 1 thành phố mà thành phố đó KHÔNG có dữ
        # liệu nhóm đó → trả câu "chưa có dữ liệu" + gợi ý nhóm có data, KHÔNG gọi
        # LLM (tránh bịa từ vài entry faq lạc).
        gap_msg = await structured_search.category_gap_message(
            intent, nlp_result.entities.get("location"), nlp_result.entities.get("city_slug")
        )
        if gap_msg:
            return self._short_circuit_response(gap_msg, t0, intent=intent)

        # [YÊU CẦU 4] Cache: thử exact-match trước, rồi semantic cache
        cached_response = await cache_layer.get_cached_response(effective_question)
        if cached_response:
            evalmon.performance_monitor.record_cache_lookup(hit=True)
            cached_response = dict(cached_response)
            cached_response["latency_ms"] = int((time.monotonic() - t0) * 1000)
            cached_response["cache_hit"] = "exact"
            return cached_response

        query_vec, embed_ms, embed_cache_hit = await self._embed_cached(effective_question)

        if not embed_cache_hit:
            semantic_hit = await cache_layer.find_semantic_cache_match(query_vec)
            if semantic_hit:
                evalmon.performance_monitor.record_cache_lookup(hit=True)
                semantic_hit = dict(semantic_hit)
                semantic_hit["latency_ms"] = int((time.monotonic() - t0) * 1000)
                semantic_hit["cache_hit"] = "semantic"
                return semantic_hit

        evalmon.performance_monitor.record_cache_lookup(hit=False)

        # [FAQ-direct] Nếu câu hỏi khớp cao 1 FAQ của đúng thành phố → trả thẳng
        # đáp án FAQ, KHÔNG gọi Gemini (tiết kiệm quota, <1s).
        faq_ans = await self._faq_direct(
            query_vec, nlp_result.entities.get("location"), nlp_result.entities.get("city_slug")
        )
        if faq_ans:
            return self._short_circuit_response(faq_ans, t0, intent=intent)

        sources, search_ms, search_method = await self._get_sources(
            effective_question, query_vec, intent, entities=nlp_result.entities
        )

        # [OPT-2.1] No-context guard: KB không có nguồn liên quan → trả câu mẫu
        # "chưa có dữ liệu" thay vì gọi Gemini (nhanh < 500ms + chặn hallucination).
        if not sources:
            logger.info(
                f"[RAG] session={session_id} | intent={intent} | "
                f"NO sources ({search_method}) → missing-knowledge guard (bỏ qua LLM)"
            )
            return self._short_circuit_response(
                nlp.MISSING_KNOWLEDGE_RESPONSE, t0, intent=intent
            )

        # [P1] plan_trip → dựng lịch trình có cấu trúc từ DB (đính kèm vào kết quả)
        itinerary_data = None
        if intent == "plan_trip":
            itinerary_data = await structured_search.build_itinerary(
                nlp_result.entities.get("location"),
                nlp_result.entities.get("city_slug"),
                nlp_result.entities,
            )

        # [YÊU CẦU 5] Sliding summary nếu history dài
        client = _get_genai_client()
        recent_history, summary_text = await gopt.build_sliding_history(
            history, client, settings.GEMINI_MODEL
        )

        prompt = _build_prompt(effective_question, sources, recent_history, summary_text)

        t_llm = time.monotonic()

        async def _call():
            return await client.aio.models.generate_content(
                model=settings.GEMINI_MODEL,
                contents=prompt,
                config=gopt.gemini_config(intent),
            )

        try:
            response = await gopt.call_with_retry(_call)
        except Exception as e:
            logger.error(f"[RAG] Gemini call thất bại sau retry: {e}")
            fallback_answer = _build_rag_fallback_answer(sources, effective_question)
            return self._short_circuit_response(
                fallback_answer, t0, intent=intent, is_error=True
            )

        llm_ms = int((time.monotonic() - t_llm) * 1000)

        answer_raw = response.text or ""
        answer, suggested_questions = _parse_answer_and_suggestions(answer_raw)
        usage = response.usage_metadata
        prompt_tokens = (usage.prompt_token_count or 0) if usage else 0
        completion_tokens = (usage.candidates_token_count or 0) if usage else 0

        # [YÊU CẦU 3] Grounding check + citation validation (lớp phòng thủ thứ 2)
        hallu_report = guard.run_hallucination_checks(answer, sources)

        latency_ms = int((time.monotonic() - t0) * 1000)
        tok_per_sec = round(completion_tokens / (llm_ms / 1000), 1) if llm_ms > 0 else 0

        evalmon.performance_monitor.record_latency(latency_ms)

        logger.info(
            f"[RAG] session={session_id} | intent={intent} | sources={len(sources)} ({search_method}) | "
            f"embed={embed_ms}ms search={search_ms}ms llm={llm_ms}ms total={latency_ms}ms | "
            f"tokens=({prompt_tokens}+{completion_tokens}) | speed={tok_per_sec} tok/s | "
            f"hallucination_check confidence={hallu_report.overall_confidence} "
            f"flagged={hallu_report.should_flag_for_review}"
        )

        if hallu_report.should_flag_for_review:
            await self._log_flagged_response(
                session_id, question, answer, hallu_report, search_method
            )

        result = {
            "answer": answer,
            "sources": sources,
            "suggested_questions": suggested_questions,
            "intent": intent,
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "latency_ms": latency_ms,
            "hallucination_confidence": hallu_report.overall_confidence,
            "confidence_score": hallu_report.overall_confidence,
            "search_method": search_method,
            "search_ms": search_ms,
            "llm_ms": llm_ms,
            "cache_hit": None,
            "itinerary": itinerary_data,
        }

        # [YÊU CẦU 4] Lưu cache (chỉ cache câu trả lời đáng tin cậy, KB-grounded)
        if not hallu_report.should_flag_for_review and sources:
            category = sources[0].get("category", "default") if sources else "default"
            await cache_layer.set_cached_response(
                effective_question, result, category=category, embedding=query_vec
            )

        return result

    def _short_circuit_response(
        self, answer: str, t0: float, intent: str, is_error: bool = False
    ) -> dict:
        """Trả lời nhanh cho greeting/out-of-scope/clarification/lỗi — không cần RAG đầy đủ."""
        latency_ms = int((time.monotonic() - t0) * 1000)
        evalmon.performance_monitor.record_latency(latency_ms)
        return {
            "answer": answer,
            "sources": [],
            "suggested_questions": [],
            "intent": intent,
            "prompt_tokens": 0,
            "completion_tokens": 0,
            "latency_ms": latency_ms,
            "hallucination_confidence": 1.0 if not is_error else 0.0,
            "confidence_score": 1.0 if not is_error else 0.0,
            "search_method": "no_results",
            "search_ms": None,
            "llm_ms": None,
            "cache_hit": None,
            "chunk_count": None,
        }

    async def _log_flagged_response(
        self,
        session_id: str,
        question: str,
        answer: str,
        report,
        search_method: str,
    ) -> None:
        """[YÊU CẦU 3 + 8] Ghi log câu trả lời bị flag vào MongoDB để giám sát định kỳ."""
        try:
            from app.services import log_service

            await log_service.log_flagged_response(
                session_id=session_id,
                question=question,
                answer=answer,
                is_grounded=report.grounding.is_grounded,
                grounding_confidence=report.grounding.confidence,
                ungrounded_terms=report.grounding.ungrounded_terms,
                citation_valid=report.citation.valid,
                invalid_citation_indices=report.citation.invalid_indices,
                search_method=search_method,
                overall_confidence=report.overall_confidence,
            )
        except Exception as e:
            logger.warning(f"[Hallucination Guard] Không thể ghi log flagged response: {e}")

    # ── Public: SSE stream ────────────────────────────────────────────────────

    async def stream_query(
        self,
        question: str,
        history: list[dict],
        session_id: str,
    ) -> AsyncGenerator[dict, None]:
        t0 = time.monotonic()

        # [Quick reply] (bản stream) — câu quen thuộc/meta → trả mẫu tức thì.
        quick = quick_replies.match(question)
        if quick:
            async for ev in self._short_circuit_stream(quick, t0, "quick_reply"):
                yield ev
            return

        # [YÊU CẦU 2] NLP preprocessing — short-circuit cho greeting/out-of-scope/clarification
        nlp_result = nlp.preprocess(question, history)

        if nlp_result.is_greeting:
            async for ev in self._short_circuit_stream(
                nlp.get_greeting_response(hash(session_id) % 3), t0, "greeting"
            ):
                yield ev
            return

        if nlp_result.is_out_of_scope:
            async for ev in self._short_circuit_stream(
                nlp.OUT_OF_SCOPE_RESPONSE, t0, "out_of_scope"
            ):
                yield ev
            return

        if nlp_result.needs_clarification:
            options_text = "\n".join(f"- {opt}" for opt in nlp_result.clarification_options)
            answer = f"{nlp_result.clarification_message}\n\n{options_text}"
            async for ev in self._short_circuit_stream(answer, t0, "clarification"):
                yield ev
            return

        effective_question = nlp_result.rewritten_query
        intent = nlp_result.intent

        # [Anti-hallucination theo nhóm] (bản stream) — xem chú thích ở query().
        gap_msg = await structured_search.category_gap_message(
            intent, nlp_result.entities.get("location"), nlp_result.entities.get("city_slug")
        )
        if gap_msg:
            async for ev in self._short_circuit_stream(gap_msg, t0, intent):
                yield ev
            return

        # [YÊU CẦU 4] Cache check — nếu hit, "giả lập" stream bằng cách trả nguyên answer
        cached_response = await cache_layer.get_cached_response(effective_question)
        if cached_response:
            evalmon.performance_monitor.record_cache_lookup(hit=True)
            async for ev in self._stream_from_cache(cached_response, t0):
                yield ev
            return

        query_vec, embed_ms, embed_cache_hit = await self._embed_cached(effective_question)

        if not embed_cache_hit:
            semantic_hit = await cache_layer.find_semantic_cache_match(query_vec)
            if semantic_hit:
                evalmon.performance_monitor.record_cache_lookup(hit=True)
                async for ev in self._stream_from_cache(semantic_hit, t0):
                    yield ev
                return

        evalmon.performance_monitor.record_cache_lookup(hit=False)

        # [FAQ-direct] (bản stream) — khớp cao FAQ đúng thành phố → trả thẳng, bỏ Gemini.
        faq_ans = await self._faq_direct(
            query_vec, nlp_result.entities.get("location"), nlp_result.entities.get("city_slug")
        )
        if faq_ans:
            async for ev in self._short_circuit_stream(faq_ans, t0, intent):
                yield ev
            return

        sources, search_ms, search_method = await self._get_sources(
            effective_question, query_vec, intent, entities=nlp_result.entities
        )

        # [OPT-2.1] No-context guard (bản stream): không nguồn → câu mẫu, bỏ qua LLM.
        if not sources:
            logger.info(
                f"[RAG:stream] session={session_id} | intent={intent} | "
                f"NO sources ({search_method}) → missing-knowledge guard (bỏ qua LLM)"
            )
            async for ev in self._short_circuit_stream(
                nlp.MISSING_KNOWLEDGE_RESPONSE, t0, intent
            ):
                yield ev
            return

        # [P1] plan_trip → lịch trình có cấu trúc từ DB, đính kèm meta
        itinerary_data = None
        if intent == "plan_trip":
            itinerary_data = await structured_search.build_itinerary(
                nlp_result.entities.get("location"),
                nlp_result.entities.get("city_slug"),
                nlp_result.entities,
            )

        client = _get_genai_client()
        recent_history, summary_text = await gopt.build_sliding_history(
            history, client, settings.GEMINI_MODEL
        )
        prompt = _build_prompt(effective_question, sources, recent_history, summary_text)

        full_text_parts: list[str] = []
        prompt_tokens = 0
        completion_tokens = 0
        chunk_count = 0
        t_llm = time.monotonic()
        # [YÊU CẦU 5] TTFT monitoring riêng biệt với generation time
        timing = gopt.StreamTimingTracker(t_start=t_llm)

        try:
            async for chunk in await client.aio.models.generate_content_stream(
                model=settings.GEMINI_MODEL,
                contents=prompt,
                config=gopt.gemini_config(intent),
            ):
                text = chunk.text

                if text:
                    timing.mark_first_token()
                    chunk_count += 1
                    full_text_parts.append(text)

                    yield {
                        "type": "chunk",
                        "content": text,
                    }

                usage = chunk.usage_metadata
                if usage:
                    prompt_tokens = usage.prompt_token_count or 0
                    completion_tokens = usage.candidates_token_count or 0
        except Exception as e:
            logger.error(f"[RAG:stream] Gemini stream lỗi: {e}")
            fallback_answer = _build_rag_fallback_answer(sources, effective_question)
            yield {"type": "chunk", "content": fallback_answer}
            yield {
                "type": "meta",
                "sources": sources,
                "suggested_questions": [],
                "intent": intent,
                "prompt_tokens": 0,
                "completion_tokens": 0,
                "latency_ms": int((time.monotonic() - t0) * 1000),
                "tokens_per_second": 0,
            }
            return

        # Parse answer chính + suggested_questions sau khi stream xong
        full_raw = "".join(full_text_parts)
        answer, suggested_questions = _parse_answer_and_suggestions(full_raw)

        t_end = time.monotonic()
        llm_ms = int((t_end - t_llm) * 1000)
        latency_ms = int((t_end - t0) * 1000)
        tok_per_sec = round(completion_tokens / (llm_ms / 1000), 1) if llm_ms > 0 else 0

        # [YÊU CẦU 3] Grounding + citation check sau khi sinh xong
        hallu_report = guard.run_hallucination_checks(answer, sources)

        evalmon.performance_monitor.record_latency(latency_ms)
        if timing.ttft_ms is not None:
            evalmon.performance_monitor.record_ttft(timing.ttft_ms)

        logger.info(
            f"[RAG:stream] session={session_id} | intent={intent} | sources={len(sources)} ({search_method}) | "
            f"embed={embed_ms}ms search={search_ms}ms ttft={timing.ttft_ms}ms "
            f"generation={timing.generation_ms(t_end)}ms total={latency_ms}ms | "
            f"tokens=({prompt_tokens}+{completion_tokens}) chunks={chunk_count} | "
            f"speed={tok_per_sec} tok/s | hallucination confidence={hallu_report.overall_confidence}"
        )

        if hallu_report.should_flag_for_review:
            await self._log_flagged_response(
                session_id, question, answer, hallu_report, search_method
            )

        meta_payload = {
            "type": "meta",
            "sources": sources,
            "suggested_questions": suggested_questions,
            "intent": intent,
            "prompt_tokens": prompt_tokens,
            "completion_tokens": completion_tokens,
            "latency_ms": latency_ms,
            "tokens_per_second": tok_per_sec,
            "ttft_ms": timing.ttft_ms,
            "hallucination_confidence": hallu_report.overall_confidence,
            "confidence_score": hallu_report.overall_confidence,
            "search_method": search_method,
            "search_ms": search_ms,
            "llm_ms": llm_ms,
            "cache_hit": None,
            "chunk_count": chunk_count,
            "itinerary": itinerary_data,
        }

        # [YÊU CẦU 4] Cache câu trả lời nếu đáng tin cậy
        if not hallu_report.should_flag_for_review and sources:
            category = sources[0].get("category", "default") if sources else "default"
            cacheable = {
                "answer": answer,
                "sources": sources,
                "suggested_questions": suggested_questions,
                "intent": intent,
                "prompt_tokens": prompt_tokens,
                "completion_tokens": completion_tokens,
                "hallucination_confidence": hallu_report.overall_confidence,
            }
            await cache_layer.set_cached_response(
                effective_question, cacheable, category=category, embedding=query_vec
            )

        yield meta_payload

    async def _short_circuit_stream(
        self, answer: str, t0: float, intent: str
    ) -> AsyncGenerator[dict, None]:
        """Stream giả lập (1 chunk duy nhất) cho greeting/out-of-scope/clarification."""
        yield {"type": "chunk", "content": answer}
        latency_ms = int((time.monotonic() - t0) * 1000)
        evalmon.performance_monitor.record_latency(latency_ms)
        yield {
            "type": "meta",
            "sources": [],
            "suggested_questions": [],
            "intent": intent,
            "prompt_tokens": 0,
            "completion_tokens": 0,
            "latency_ms": latency_ms,
            "tokens_per_second": 0,
        }

    async def _stream_from_cache(
        self, cached: dict, t0: float
    ) -> AsyncGenerator[dict, None]:
        """Trả lời tức thì từ cache, vẫn theo format SSE chunk + meta để frontend không cần đổi logic."""
        answer = cached.get("answer", "")
        yield {"type": "chunk", "content": answer}
        latency_ms = int((time.monotonic() - t0) * 1000)
        yield {
            "type": "meta",
            "sources": cached.get("sources", []),
            "suggested_questions": cached.get("suggested_questions", []),
            "intent": cached.get("intent"),
            "prompt_tokens": cached.get("prompt_tokens", 0),
            "completion_tokens": cached.get("completion_tokens", 0),
            "latency_ms": latency_ms,
            "tokens_per_second": 0,
            "cache_hit": True,
        }

    # ── Quản lý vector store ──────────────────────────────────────────────────

    async def upsert_knowledge(self, entries: list[dict]) -> int:
        count = await asyncio.to_thread(_upsert_qdrant_sync, entries)
        logger.info(f"[RAG] Upserted {count} chunks vào Qdrant")
        # [YÊU CẦU 4] Invalidate cache liên quan category này khi KB cập nhật
        categories = {e.get("category", "default") for e in entries}
        for cat in categories:
            await cache_layer.invalidate_category(cat)
        return count

    async def delete_knowledge(self, entry_id: str, category: Optional[str] = None) -> None:
        await asyncio.to_thread(_delete_qdrant_sync, entry_id)
        logger.info(f"[RAG] Deleted entry {entry_id} khỏi Qdrant")
        # [YÊU CẦU 4] Invalidate cache tự động khi xoá knowledge
        if category:
            await cache_layer.invalidate_category(category)
        else:
            await cache_layer.invalidate_all()

    @staticmethod
    def chunk_text(text: str, chunk_size: int = 200) -> list[str]:
        """Chia văn bản thành các chunk theo số từ."""
        words = text.split()
        return [
            " ".join(words[i: i + chunk_size])
            for i in range(0, len(words), chunk_size)
        ]

    async def ensure_collection(self) -> None:
        """Tạo Qdrant collection nếu chưa tồn tại."""
        def _create():
            _ensure_collection_sync()
            try:
                client = _get_qdrant()
                source = getattr(settings, "KNOWLEDGE_SOURCE", "db").lower()
                col = settings.QDRANT_COLLECTION_KB_FILES if source in ("files", "hybrid") else settings.QDRANT_COLLECTION
                info = client.get_collection(col)
                logger.info(
                    f"[Qdrant] Collection ready — points={info.points_count}"
                )
            except Exception:
                pass

        await asyncio.to_thread(_create)

    async def debug_collection(self) -> dict:
        """Endpoint debug: kiểm tra collection status + sample points."""
        def _debug():
            client = _get_qdrant()
            source = getattr(settings, "KNOWLEDGE_SOURCE", "db").lower()
            col = settings.QDRANT_COLLECTION_KB_FILES if source in ("files", "hybrid") else settings.QDRANT_COLLECTION
            info = client.get_collection(col)
            sample = client.scroll(
                collection_name=col,
                limit=3,
                with_payload=True,
                with_vectors=False,
            )[0]
            return {
                "collection": col,
                "points_count": info.points_count,
                "vectors_count": getattr(info, "vectors_count", None) or getattr(info, "points_count", 0),
                "embedding_dim": settings.EMBEDDING_DIM,
                "score_threshold": settings.RAG_SCORE_THRESHOLD,
                "sample_points": [
                    {
                        "id": str(p.id),
                        "payload_keys": list(p.payload.keys() if p.payload else []),
                        "title": p.payload.get("title", "") if p.payload else "",
                    }
                    for p in sample
                ],
            }
        return await asyncio.to_thread(_debug)