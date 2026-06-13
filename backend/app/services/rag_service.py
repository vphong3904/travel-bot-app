# app/services/rag_service.py
# ============================================================
#  RAG Service — Hybrid (TF-IDF + PhoBERT Dense Embedding)
#  Tối ưu cho tiếng Việt: semantic + keyword matching
# ============================================================

from __future__ import annotations

import math
import re
import unicodedata
from collections import Counter, defaultdict
from typing import Optional
import httpx
import numpy as np

try:
    from sentence_transformers import SentenceTransformer
    HAVE_SENTENCE_TRANSFORMERS = True
except ImportError:
    HAVE_SENTENCE_TRANSFORMERS = False

try:
    from pyvi import ViTokenizer
    HAVE_PYVI = True
except ImportError:
    HAVE_PYVI = False

from app.config import settings

# ── Gemini ────────────────────────────────────────────────────────────────────
GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1/models/"
    "gemini-1.5-flash:generateContent"
)

# ── Normalize tiếng Việt (giữ nguyên từ gốc, chỉ bỏ dấu khi compare) ─────────
_VI_MAP = str.maketrans({
    "à": "a", "á": "a", "ạ": "a", "ả": "a", "ã": "a",
    "â": "a", "ầ": "a", "ấ": "a", "ậ": "a", "ẩ": "a", "ẫ": "a",
    "ă": "a", "ằ": "a", "ắ": "a", "ặ": "a", "ẳ": "a", "ẵ": "a",
    "è": "e", "é": "e", "ẹ": "e", "ẻ": "e", "ẽ": "e",
    "ê": "e", "ề": "e", "ế": "e", "ệ": "e", "ể": "e", "ễ": "e",
    "ì": "i", "í": "i", "ị": "i", "ỉ": "i", "ĩ": "i",
    "ò": "o", "ó": "o", "ọ": "o", "ỏ": "o", "õ": "o",
    "ô": "o", "ồ": "o", "ố": "o", "ộ": "o", "ổ": "o", "ỗ": "o",
    "ơ": "o", "ờ": "o", "ớ": "o", "ợ": "o", "ở": "o", "ỡ": "o",
    "ù": "u", "ú": "u", "ụ": "u", "ủ": "u", "ũ": "u",
    "ư": "u", "ừ": "u", "ứ": "u", "ự": "u", "ử": "u", "ữ": "u",
    "ỳ": "y", "ý": "y", "ỵ": "y", "ỷ": "y", "ỹ": "y",
    "đ": "d",
})

# Stopwords tiếng Việt đầy đủ hơn — KHÔNG bao gồm từ mang nghĩa địa danh/đặc sản
STOPWORDS = {
    "toi", "thich", "di", "o", "dau", "la", "co", "voi",
    "va", "cho", "vao", "nhung", "neu", "hay", "rat",
    "duoc", "xin", "chao", "the", "cung", "khong", "biet",
    "gi", "nao", "nhu", "khi", "de", "tu", "tren", "duoi",
    "mot", "hai", "ba", "bon", "nam", "sau", "bay", "tam",
    "minh", "ban", "tui", "ho", "chung", "cac", "nhieu",
    "it", "qua", "len", "xuong", "vao", "ra", "vay", "thi",
    "ma", "roi", "se", "da", "dang", "bi", "duoc", "chua",
}


def _normalize(text: str) -> str:
    """Lowercase + bỏ dấu tiếng Việt."""
    text = unicodedata.normalize("NFD", text.lower())
    text = "".join(ch for ch in text if unicodedata.category(ch) != "Mn")
    return unicodedata.normalize("NFC", text).translate(_VI_MAP)


def _tokenize_unigrams(text: str) -> list[str]:
    """Tách unigram, lọc stopword và ký tự ngắn."""
    source = ViTokenizer.tokenize(text) if HAVE_PYVI else text
    norm = _normalize(source)
    raw_tokens = re.split(r"[\s/,;:!?.()\[\]\"']+", norm)
    tokens: list[str] = []
    for token in raw_tokens:
        token = re.sub(r"[^\w_]", "", token).strip("_")
        if len(token) >= 2 and token not in STOPWORDS:
            tokens.append(token)
    return tokens


def _tokenize_with_bigrams(text: str) -> list[str]:
    """
    Trả về unigrams + bigrams.
    Bigram giúp bắt từ ghép tiếng Việt: "am thuc", "lich trinh", "khach san"...
    """
    unigrams = _tokenize_unigrams(text)
    bigrams = [f"{unigrams[i]}_{unigrams[i+1]}" for i in range(len(unigrams) - 1)]
    return unigrams + bigrams


# ── Chunking theo ngữ nghĩa (paragraph-aware) ─────────────────────────────────

def _chunk_by_paragraph(text: str, max_chars: int = 400, overlap_sentences: int = 1) -> list[str]:
    """
    Chunk theo đoạn văn:
    1. Ưu tiên tách theo dấu xuống dòng (paragraph break)
    2. Nếu đoạn quá dài, tách tiếp theo câu
    3. Thêm overlap 1 câu giữa các chunk để tránh mất ngữ cảnh
    """
    # Tách theo paragraph (2+ newlines hoặc bullet points)
    paragraphs = re.split(r"\n{2,}|(?<=[.!?])\s*\n", text.strip())
    paragraphs = [p.strip() for p in paragraphs if p.strip()]

    chunks: list[str] = []
    for para in paragraphs:
        if len(para) <= max_chars:
            chunks.append(para)
        else:
            # Tách câu trong đoạn dài
            sentences = re.split(r"(?<=[.!?;])\s+", para)
            sentences = [s.strip() for s in sentences if s.strip()]

            current: list[str] = []
            current_len = 0
            tail: list[str] = []  # overlap sentences

            for sent in sentences:
                sent_len = len(sent)
                if current_len + sent_len > max_chars and current:
                    chunk_text = " ".join(current)
                    chunks.append(chunk_text)
                    # overlap: carry over last N sentences
                    tail = current[-overlap_sentences:] if overlap_sentences else []
                    current = tail + [sent]
                    current_len = sum(len(s) for s in current)
                else:
                    current.append(sent)
                    current_len += sent_len + 1

            if current:
                chunks.append(" ".join(current))

    return chunks if chunks else [text.strip()]


# ── Hybrid Index (TF-IDF + Dense Embedding) ──────────────────────────────────

class HybridIndex:
    """
    Hybrid retrieval kết hợp:
    1. TF-IDF (keyword matching - fast, 100% keyword)
    2. Dense embedding PhoBERT (semantic, hiểu tiếng Việt tốt)
    Blend: 0.4 * tfidf_score + 0.6 * dense_score
    """

    def __init__(self):
        self._docs: list[dict] = []
        self._doc_tokens: list[list[str]] = []
        self._idf: dict[str, float] = {}
        self._doc_tfidf: list[dict[str, float]] = []
        
        # Dense embedding
        self._embed_model = None
        self._doc_embeddings = None
        self._use_dense = HAVE_SENTENCE_TRANSFORMERS
        
        if self._use_dense:
            try:
                self._embed_model = SentenceTransformer(settings.embedding_model)
            except Exception as e:
                print(f"Warning: Không load embedding model: {e}, fallback to TF-IDF only")
                self._use_dense = False

    def build(self, docs: list[dict]) -> None:
        self._docs = docs

        # ── TF-IDF part ──────────────────────────────────────────────────────
        self._doc_tokens = []
        for doc in docs:
            field_text = " ".join([
                " ".join([doc.get("title", "")] * 3),
                " ".join([doc.get("tags", "")] * 2),
                " ".join([doc.get("destination", "")] * 2),
                doc.get("content", ""),
            ])
            self._doc_tokens.append(_tokenize_with_bigrams(field_text))

        N = len(docs)
        df: dict[str, int] = defaultdict(int)
        for tokens in self._doc_tokens:
            for t in set(tokens):
                df[t] += 1

        self._idf = {
            term: math.log((N + 1) / (freq + 1)) + 1.0
            for term, freq in df.items()
        }

        self._doc_tfidf = []
        for tokens in self._doc_tokens:
            tf = Counter(tokens)
            total = max(len(tokens), 1)
            vec = {
                term: (count / total) * self._idf.get(term, 0.0)
                for term, count in tf.items()
            }
            self._doc_tfidf.append(vec)

        # ── Dense Embedding part ─────────────────────────────────────────────
        if self._use_dense and self._embed_model:
            try:
                doc_texts = [
                    doc.get("title", "") + " " + doc.get("content", "")
                    for doc in docs
                ]
                self._doc_embeddings = self._embed_model.encode(
                    doc_texts, convert_to_numpy=True, normalize_embeddings=True
                )
            except Exception as e:
                print(f"Warning: Dense embedding failed: {e}")
                self._use_dense = False

    def query_vec(self, query: str) -> dict[str, float]:
        """TF-IDF vector của query"""
        tokens = _tokenize_with_bigrams(query)
        tf = Counter(tokens)
        total = max(len(tokens), 1)
        return {
            term: (count / total) * self._idf.get(term, 0.0)
            for term, count in tf.items()
            if term in self._idf
        }

    def cosine(self, vec_a: dict[str, float], vec_b: dict[str, float]) -> float:
        if not vec_a or not vec_b:
            return 0.0
        dot = sum(vec_a.get(t, 0.0) * v for t, v in vec_b.items())
        norm_a = math.sqrt(sum(v * v for v in vec_a.values()))
        norm_b = math.sqrt(sum(v * v for v in vec_b.values()))
        if norm_a == 0 or norm_b == 0:
            return 0.0
        return dot / (norm_a * norm_b)

    def tfidf_score(self, query: str) -> list[tuple[int, float]]:
        """Return [(doc_idx, score)] from TF-IDF"""
        q_vec = self.query_vec(query)
        scores = []
        for idx, doc_vec in enumerate(self._doc_tfidf):
            score = self.cosine(q_vec, doc_vec)
            scores.append((idx, score))
        return scores

    def dense_score(self, query: str) -> list[tuple[int, float]]:
        """Return [(doc_idx, score)] from dense embedding"""
        if not self._use_dense or self._doc_embeddings is None:
            return [(i, 0.0) for i in range(len(self._docs))]

        try:
            query_emb = self._embed_model.encode(
                [query], convert_to_numpy=True, normalize_embeddings=True
            )[0]
            # Cosine similarity (already normalized)
            scores = np.dot(self._doc_embeddings, query_emb).tolist()
            return [(idx, score) for idx, score in enumerate(scores)]
        except Exception:
            return [(i, 0.0) for i in range(len(self._docs))]

    def hybrid_score(self, query: str, alpha: float = 0.4) -> list[tuple[int, float]]:
        """
        Blend TF-IDF + Dense scores
        alpha=0.4: 40% TF-IDF, 60% Dense
        """
        tfidf_scores = self.tfidf_score(query)
        dense_scores = self.dense_score(query)

        # Normalize to [0, 1]
        tfidf_vals = [s for _, s in tfidf_scores]
        dense_vals = [
            max((s + 1.0) / 2.0, 0.0) if self._use_dense else 0.0
            for _, s in dense_scores
        ]

        tfidf_max = max(tfidf_vals) if tfidf_vals else 1.0
        dense_max = max(dense_vals) if dense_vals else 1.0

        tfidf_norm = {
            idx: s / tfidf_max if tfidf_max > 0 else 0.0
            for idx, s in tfidf_scores
        }
        dense_norm = {
            idx: s / dense_max if dense_max > 0 else 0.0
            for (idx, _), s in zip(dense_scores, dense_vals)
        }

        # Blend
        blended = [
            (idx, alpha * tfidf_norm.get(idx, 0.0) + (1 - alpha) * dense_norm.get(idx, 0.0))
            for idx in range(len(self._docs))
        ]
        return blended


# ── Category / Intent mapping ─────────────────────────────────────────────────

# intent → các category KB được phép retrieve
INTENT_TO_CATEGORIES: dict[str, set[str]] = {
    "weather":        {"destination_info", "tips"},
    "budget":         {"recommendation", "destination_info", "tips"},
    "cuisine":        {"destination_info", "tips", "recommendation"},
    "itinerary":      {"itinerary", "destination_info", "recommendation"},
    "hotel":          {"destination_info", "tips"},
    "transport":      {"destination_info", "tips"},
    "tips":           {"tips", "destination_info"},
    "recommendation": {"recommendation", "destination_info", "itinerary"},
    "visa":           {"tips", "destination_info"},
    "general":        set(),  # empty = không lọc
}

# Keyword → category để boost score
KEYWORD_CATEGORY_BOOST: list[tuple[str, str, float]] = [
    ("thoi tiet",   "destination_info", 0.3),
    ("khi hau",     "destination_info", 0.3),
    ("an gi",       "destination_info", 0.35),
    ("am thuc",     "destination_info", 0.35),
    ("dac san",     "destination_info", 0.35),
    ("khach san",   "destination_info", 0.3),
    ("homestay",    "destination_info", 0.3),
    ("resort",      "destination_info", 0.3),
    ("lich trinh",  "itinerary",        0.4),
    ("hanh trinh",  "itinerary",        0.4),
    ("chi phi",     "recommendation",   0.3),
    ("ngan sach",   "recommendation",   0.3),
    ("di chuyen",   "destination_info", 0.25),
    ("phuong tien", "destination_info", 0.25),
    ("kinh nghiem", "tips",             0.3),
    ("luu y",       "tips",             0.3),
    ("nen di dau",  "recommendation",   0.4),
    ("dia diem",    "recommendation",   0.35),
    ("goi y",       "recommendation",   0.35),
]


# ── RAG Service ───────────────────────────────────────────────────────────────

class RAGService:
    """Singleton RAG service với Hybrid (TF-IDF + Dense Embedding cho tiếng Việt)."""

    _instance: Optional["RAGService"] = None

    def __init__(self):
        self._raw_docs: list[dict] = []
        self._chunks: list[dict] = []
        self._index = HybridIndex()
        self._ready = False

    @classmethod
    def get_instance(cls) -> "RAGService":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    # ── Build index ──────────────────────────────────────────────────────────

    def initialize(self, docs: list[dict]) -> None:
        """
        Gọi 1 lần khi startup với toàn bộ knowledge_entries.
        Thực hiện chunking + build Hybrid index (TF-IDF + Dense Embedding).
        """
        self._raw_docs = docs
        chunked: list[dict] = []

        for doc in docs:
            content = doc.get("content", "").strip()
            if not content:
                continue

            chunks = _chunk_by_paragraph(content, max_chars=400, overlap_sentences=1)

            for idx, chunk_text in enumerate(chunks, start=1):
                chunked.append({
                    **doc,
                    "content":      chunk_text,
                    "chunk_index":  idx,
                    "chunk_total":  len(chunks),
                    "is_chunked":   len(chunks) > 1,
                })

        self._chunks = chunked
        self._index.build(self._chunks)
        self._ready = True

    # ── Retrieve ─────────────────────────────────────────────────────────────

    def retrieve(
        self,
        query: str,
        top_k: int = 10,
        intent: str = "",
        destination: str = "",
        min_score: float = 0.03,
    ) -> list[dict]:
        """
        Bước 1: Hybrid search (TF-IDF + Dense embedding) + keyword/destination boost.
        min_score loại bỏ kết quả rác hoàn toàn không liên quan.
        """
        if not self._ready or not self._chunks:
            return []

        q_norm = _normalize(query)
        
        # Hybrid score: 40% TF-IDF, 60% Dense embedding
        hybrid_scores = self._index.hybrid_score(query, alpha=0.4)
        hybrid_dict = dict(hybrid_scores)  # {doc_idx: hybrid_score}

        allowed_cats = INTENT_TO_CATEGORIES.get(intent, set())
        dest_norm    = _normalize(destination) if destination else ""

        scored: list[dict] = []
        for doc_idx, doc in enumerate(self._chunks):
            cat = doc.get("category", "")

            # Lọc category theo intent (nếu có quy định)
            if allowed_cats and cat not in allowed_cats:
                continue

            # Base score from hybrid retrieval
            score = hybrid_dict.get(doc_idx, 0.0)

            # ── Boost theo destination ────────────────────────────────────────
            doc_dest = _normalize(doc.get("destination") or "")
            if dest_norm:
                if dest_norm == doc_dest or dest_norm in doc_dest:
                    score += 0.45  # khớp chính xác destination
                elif doc_dest and doc_dest in dest_norm:
                    score += 0.2   # partial match

            # Boost nếu tên điểm đến xuất hiện trong query
            if doc_dest and doc_dest in q_norm:
                score += 0.35

            # ── Boost theo keyword–category mapping ───────────────────────────
            for kw, target_cat, boost in KEYWORD_CATEGORY_BOOST:
                if kw in q_norm and cat == target_cat:
                    score += boost
                    break

            # ── Boost title match (exact term trong query) ────────────────────
            query_tokens = set(_tokenize_unigrams(query))
            title_tokens = set(_tokenize_unigrams(doc.get("title", "")))
            title_overlap = len(query_tokens & title_tokens)
            if title_overlap:
                score += title_overlap * 0.08

            # ── Bỏ qua nếu score quá thấp (rác hoàn toàn) ───────────────────
            if score < min_score:
                continue

            scored.append({**doc, "_score": round(score, 5)})

        scored.sort(key=lambda x: x["_score"], reverse=True)
        return scored[:top_k]

    # ── Rerank ───────────────────────────────────────────────────────────────

    def rerank(self, candidates: list[dict], query: str, destination: str = "") -> list[dict]:
        """
        Bước 2: Rerank đa tiêu chí:
          - Query term coverage (bao nhiêu % query terms có trong doc)
          - Exact phrase match bonus
          - Destination consistency (phạt doc sai địa danh)
          - Chunk position penalty (chunk sau ít quan trọng hơn)
          - Length normalization (tránh thiên vị chunk dài/ngắn)
        """
        if not candidates:
            return []

        query_tokens = set(_tokenize_unigrams(query))
        q_norm       = _normalize(query)
        dest_norm    = _normalize(destination) if destination else ""

        reranked: list[dict] = []
        for doc in candidates:
            base    = doc["_score"]
            bonuses = 0.0

            # 1) Query term coverage
            content_norm   = _normalize(doc.get("content", "") + " " + doc.get("title", ""))
            content_tokens = set(_tokenize_unigrams(content_norm))
            if query_tokens:
                coverage = len(query_tokens & content_tokens) / len(query_tokens)
                bonuses += coverage * 0.2

            # 2) Exact phrase bonus
            query_phrases = re.findall(r"[\w\u00C0-\u024F]{4,}", q_norm)
            phrase_hits = sum(1 for ph in query_phrases if ph in content_norm)
            bonuses += phrase_hits * 0.06

            # 3) Destination consistency — phạt doc có destination KHÁC với yêu cầu
            doc_dest = _normalize(doc.get("destination") or "")
            if dest_norm and doc_dest and doc_dest != dest_norm and doc_dest not in dest_norm:
                bonuses -= 0.25  # phạt doc địa danh sai

            # 4) Chunk position — chunk đầu thường chứa thông tin tổng quan hơn
            chunk_idx   = doc.get("chunk_index", 1)
            chunk_total = doc.get("chunk_total", 1)
            if chunk_total > 1:
                position_penalty = (chunk_idx - 1) / chunk_total * 0.05
                bonuses -= position_penalty

            # 5) Content length normalization (quá ngắn → ít thông tin)
            content_len = len(doc.get("content", ""))
            if content_len < 50:
                bonuses -= 0.1

            final = base + bonuses
            reranked.append({**doc, "_final_score": round(final, 5)})

        reranked.sort(key=lambda x: x["_final_score"], reverse=True)
        return reranked

    # ── Dedup và filter ──────────────────────────────────────────────────────

    def _deduplicate(self, docs: list[dict]) -> list[dict]:
        """
        Loại bỏ các chunk từ cùng 1 doc gốc nếu đã có chunk khác đại diện.
        Ưu tiên giữ chunk có score cao nhất từ mỗi doc gốc.
        Cho phép tối đa 2 chunk/doc để tránh mất thông tin từ doc dài.
        """
        doc_count: dict[int, int] = defaultdict(int)
        result: list[dict] = []
        for doc in docs:
            doc_id = doc.get("id", id(doc))
            if doc_count[doc_id] < 2:
                result.append(doc)
                doc_count[doc_id] += 1
        return result

    # ── Build context ────────────────────────────────────────────────────────

    def build_context(self, docs: list[dict], top: int = 5) -> str:
        """
        Tạo context string gửi lên LLM.
        Format rõ ràng để LLM dễ parse: tiêu đề + category + địa danh + nội dung.
        """
        lines: list[str] = []
        for i, doc in enumerate(docs[:top], 1):
            dest_part  = f" | 📍 {doc['destination']}" if doc.get("destination") else ""
            cat_part   = doc.get("category", "")
            chunk_part = (
                f" [phần {doc['chunk_index']}/{doc['chunk_total']}]"
                if doc.get("is_chunked")
                else ""
            )
            header  = f"[Tài liệu {i}] {doc['title']}{chunk_part} ({cat_part}{dest_part})"
            content = doc["content"].strip()
            lines.append(f"{header}\n{content}")

        return "\n\n---\n\n".join(lines)

    # ── Public API ───────────────────────────────────────────────────────────

    def search(
        self,
        query: str,
        intent: str = "",
        destination: str = "",
        top_context: int = 5,
    ) -> tuple[list[dict], str]:
        """
        Full pipeline: retrieve → rerank → dedup → build context.
        Trả về (top_docs, context_string).
        """
        retrieved = self.retrieve(
            query,
            top_k=15,
            intent=intent,
            destination=destination,
            min_score=0.03,
        )
        reranked  = self.rerank(retrieved, query, destination=destination)
        deduped   = self._deduplicate(reranked)
        top_docs  = deduped[:top_context]
        context   = self.build_context(top_docs, top=top_context)
        return top_docs, context

    # ── Debug trace ─────────────────────────────────────────────────────────

    def get_pipeline_trace(self, query: str, intent: str = "", destination: str = "") -> dict:
        step1 = self.retrieve(query, top_k=15, intent=intent, destination=destination)
        step2 = self.rerank(step1, query, destination=destination)
        step3 = self._deduplicate(step2)[:5]
        return {
            "query":            query,
            "intent":           intent,
            "destination":      destination,
            "step1_retrieved":  len(step1),
            "step1_top5": [
                {"title": d["title"], "score": d["_score"], "cat": d["category"], "dest": d.get("destination", "")}
                for d in step1[:5]
            ],
            "step2_reranked_top5": [
                {"title": d["title"], "tfidf": d["_score"], "final": d["_final_score"], "cat": d["category"]}
                for d in step2[:5]
            ],
            "step3_context_docs": [
                {"title": d["title"], "final_score": d["_final_score"], "chars": len(d.get("content", ""))}
                for d in step3
            ],
        }


# ── Gemini API ────────────────────────────────────────────────────────────────

# System prompt STRICT: chỉ dùng KB, không hallucinate
SYSTEM_PROMPT = """\
Bạn là trợ lý tư vấn du lịch Việt Nam của VietTravel AI.
Nhiệm vụ: Trả lời câu hỏi của người dùng DỰA TRÊN VÀ CHỈ DỰA TRÊN các tài liệu Knowledge Base bên dưới.

KNOWLEDGE BASE:
{context}

=== QUY TẮC BẮT BUỘC ===
1. CHỈ sử dụng thông tin có trong Knowledge Base trên. KHÔNG thêm thông tin từ bên ngoài.
2. Nếu Knowledge Base KHÔNG có thông tin về điều người dùng hỏi → nói rõ: "Tôi chưa có thông tin về [chủ đề] này trong cơ sở dữ liệu."
3. Trả lời ĐÚNG CHỦ ĐỀ câu hỏi. Không mở rộng sang chủ đề khác không được hỏi.
4. Nếu câu hỏi hỏi về địa điểm A → chỉ trả lời về địa điểm A, không nói về địa điểm B, C.
5. Trả lời bằng tiếng Việt, thân thiện, dùng emoji phù hợp.
6. Cuối câu trả lời, hỏi người dùng có cần thêm thông tin gì không.
=========================\
"""


async def ask_gemini(query: str, context: str) -> str:
    """Call Gemini API với full response (dùng cho JSON endpoint)."""
    api_key = settings.gemini_api_key
    if not api_key:
        raise RuntimeError("Không có GEMINI_API_KEY.")

    system = SYSTEM_PROMPT.format(context=context)
    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [{"text": f"{system}\n\nCâu hỏi: {query}"}],
            }
        ],
        "generationConfig": {
            "temperature": 0.3,   # giảm xuống để bám sát KB hơn
            "maxOutputTokens": 1024,
            "topP": 0.8,
        },
    }

    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.post(
            GEMINI_URL,
            params={"key": api_key},
            json=payload,
            headers={"Content-Type": "application/json"},
        )

    if not resp.is_success:
        raise RuntimeError(f"Gemini lỗi {resp.status_code}: {resp.text[:300]}")

    data = resp.json()
    return (
        data.get("candidates", [{}])[0]
        .get("content", {})
        .get("parts", [{}])[0]
        .get("text", "Không có phản hồi từ Gemini.")
    )


async def ask_gemini_streaming(query: str, context: str):
    """
    Call Gemini API với Server-Sent Events streaming.
    Yield từng chunk response khi nhận được từ Gemini.
    """
    api_key = settings.gemini_api_key
    if not api_key:
        raise RuntimeError("Không có GEMINI_API_KEY.")

    system = SYSTEM_PROMPT.format(context=context)
    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [{"text": f"{system}\n\nCâu hỏi: {query}"}],
            }
        ],
        "generationConfig": {
            "temperature": 0.3,
            "maxOutputTokens": 1024,
            "topP": 0.8,
        },
    }

    # Gemini streaming API endpoint
    stream_url = (
        "https://generativelanguage.googleapis.com/v1/models/"
        "gemini-1.5-flash:streamGenerateContent"
    )

    async with httpx.AsyncClient(timeout=60) as client:
        async with client.stream(
            "POST",
            stream_url,
            params={"key": api_key},
            json=payload,
            headers={"Content-Type": "application/json"},
        ) as resp:
            if not resp.is_success:
                raise RuntimeError(f"Gemini lỗi {resp.status_code}")

            # Parse streaming response line by line
            async for line in resp.aiter_lines():
                if not line.strip():
                    continue

                # Mỗi dòng là JSON response
                try:
                    import json
                    chunk_data = json.loads(line)
                    # Extract text từ chunk
                    text = (
                        chunk_data
                        .get("candidates", [{}])[0]
                        .get("content", {})
                        .get("parts", [{}])[0]
                        .get("text", "")
                    )
                    if text:
                        yield text
                except Exception:
                    # Skip malformed chunks
                    continue


# ── Singleton getter ──────────────────────────────────────────────────────────

def get_rag_service() -> RAGService:
    return RAGService.get_instance()
