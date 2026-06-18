# Services are imported lazily to avoid requiring ML deps at startup
# Use: from app.services.rag_pipeline import RAGPipeline

__all__ = ["RAGPipeline", "KnowledgeService", "EmbeddingJobService"]


def __getattr__(name):
    if name == "RAGPipeline":
        from .rag_pipeline import RAGPipeline
        return RAGPipeline
    if name == "KnowledgeService":
        from .knowledge import KnowledgeService
        return KnowledgeService
    if name == "EmbeddingJobService":
        from .embedding_jobs import EmbeddingJobService
        return EmbeddingJobService
    raise AttributeError(f"module 'app.services' has no attribute {name!r}")
