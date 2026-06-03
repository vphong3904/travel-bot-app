from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "AI Travel Advisor Chatbot"
    database_url: str = "sqlite:///./travel_chatbot.db"
    secret_key: str = "demo-secret-key-change-in-production"
    openai_api_key: str = ""
    embedding_model: str = "paraphrase-multilingual-MiniLM-L12-v2"
    cors_origins: list[str] = ["*"]

    class Config:
        env_file = ".env"


settings = Settings()
