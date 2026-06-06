from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "AI Travel Advisor Chatbot"
    database_url: str
    secret_key: str = "demo-secret-key-change-in-production"
    gemini_api_key: str
    embedding_model: str = "paraphrase-multilingual-MiniLM-L12-v2"
    cors_origins: list[str] = ["*"]

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore"
    )
settings = Settings()
