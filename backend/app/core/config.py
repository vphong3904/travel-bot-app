from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )
    # App
    APP_NAME: str = "PDTrip AI"
    DEBUG: bool = False

    # Database
    DATABASE_URL: str
    DATABASE_POOL_SIZE: int = 10
    DATABASE_MAX_OVERFLOW: int = 20

    # MongoDB (log lưu trữ: search_history, user_behavior, chatbot quality control)
    MONGODB_URL: str
    MONGODB_DB_NAME: str

    # JWT
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 days
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    # Qdrant
    QDRANT_URL: str
    # Qdrant Cloud: set QDRANT_API_KEY trong .env — để trống khi chạy Docker local
    QDRANT_API_KEY: str
    QDRANT_COLLECTION: str
    # T-011/T-012: collection riêng cho knowledge-base/ files, tách khỏi collection cũ
    QDRANT_COLLECTION_KB_FILES: str
    # T-012: nguồn dữ liệu RAG — "db" (cũ, mặc định) | "files" (T-011) | "hybrid" (cả hai)
    KNOWLEDGE_SOURCE: str

    # Gemini
    GEMINI_API_KEY: str
    GEMINI_MODEL: str

    # Embedding
    EMBEDDING_MODEL: str
    EMBEDDING_DIM: int

    # RAG
    RAG_TOP_K: int = 5
    # ✅ FIX: Hạ từ 0.5 xuống 0.3 — BGE-M3 cosine similarity thường cho score 0.3-0.7
    # với dữ liệu tiếng Việt, 0.5 quá cao gây 0 results
    RAG_SCORE_THRESHOLD: float = 0.3

    # Chat memory
    CHAT_HISTORY_LIMIT: int = 10   # ✅ số tin nhắn nhớ trong context

    # Google OAuth
    GOOGLE_CLIENT_ID: str

    # SMTP (Email OTP)
    SMTP_HOST:     str
    SMTP_PORT:     int
    SMTP_USER:     str
    SMTP_PASSWORD: str
    SMTP_FROM:     str 
    SMTP_USE_TLS:  bool


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = Settings()