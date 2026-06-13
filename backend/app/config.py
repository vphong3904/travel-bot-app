from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "AI Travel Advisor Chatbot"
    database_url: str
    secret_key: str = "demo-secret-key-change-in-production"
    gemini_api_key: str = ""
    use_gemini: bool = False
    embedding_model: str = "VoVanPhuc/sup-SimCSE-VietNamese-phobert-base"
    cors_origins: list[str] = ["*"]

    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore"
    )
settings = Settings()
