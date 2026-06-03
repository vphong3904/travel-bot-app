import logging
from typing import Optional

logger = logging.getLogger(__name__)


class RAGService:
    """Retrieval Augmented Generation using FAISS + sentence embeddings."""

    def __init__(self):
        self._index = None
        self._documents: list[dict] = []
        self._model = None
        self._initialized = False

    def initialize(self, documents: list[dict]):
        self._documents = documents
        if not documents:
            return

        try:
            import numpy as np
            from sentence_transformers import SentenceTransformer
            import faiss

            from app.config import settings

            self._model = SentenceTransformer(settings.embedding_model)
            texts = [f"{d['title']}. {d['content']} {d.get('tags', '')}" for d in documents]
            embeddings = self._model.encode(texts, show_progress_bar=False)
            embeddings = np.array(embeddings).astype("float32")

            dim = embeddings.shape[1]
            self._index = faiss.IndexFlatIP(dim)
            faiss.normalize_L2(embeddings)
            self._index.add(embeddings)
            self._initialized = True
            logger.info("RAG initialized with %d documents", len(documents))
        except Exception as e:
            logger.warning("FAISS/embeddings unavailable, using keyword fallback: %s", e)
            self._initialized = False

    def retrieve(self, query: str, top_k: int = 3) -> list[dict]:
        if not self._documents:
            return []

        if self._initialized and self._index is not None:
            return self._retrieve_faiss(query, top_k)
        return self._retrieve_keyword(query, top_k)

    def _retrieve_faiss(self, query: str, top_k: int) -> list[dict]:
        import faiss
        import numpy as np

        q_emb = self._model.encode([query]).astype("float32")
        faiss.normalize_L2(q_emb)
        scores, indices = self._index.search(q_emb, min(top_k, len(self._documents)))
        results = []
        for score, idx in zip(scores[0], indices[0]):
            if idx >= 0:
                doc = dict(self._documents[idx])
                doc["score"] = float(score)
                results.append(doc)
        return results

    def _retrieve_keyword(self, query: str, top_k: int) -> list[dict]:
        query_words = set(query.lower().split())
        scored = []
        for doc in self._documents:
            text = f"{doc['title']} {doc['content']} {doc.get('tags', '')} {doc.get('destination', '')}".lower()
            score = sum(1 for w in query_words if w in text and len(w) > 2)
            if doc.get("destination", "").lower() in query.lower():
                score += 3
            if score > 0:
                scored.append((score, doc))
        scored.sort(key=lambda x: x[0], reverse=True)
        return [dict(d) for _, d in scored[:top_k]]


_rag_instance: Optional[RAGService] = None


def get_rag_service() -> RAGService:
    global _rag_instance
    if _rag_instance is None:
        _rag_instance = RAGService()
    return _rag_instance
