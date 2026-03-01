"""
Конфигурация приложения market-service.
"""
import os
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Настройки приложения."""
    
    # Application
    APP_NAME: str = "OutfitStyle Market Service"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"
    
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8001
    
    # Database
    DATABASE_URL: str
    DATABASE_POOL_SIZE: int = 10
    DATABASE_MAX_OVERFLOW: int = 20
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379"
    REDIS_CACHE_TTL: int = 300  # 5 минут
    REDIS_CART_TTL: int = 86400  # 24 часа
    
    # ML Service Integration
    ML_SERVICE_URL: str = "http://localhost:8000"
    ML_SERVICE_TIMEOUT: int = 30
    
    # Main API Service Integration (для проверки пользователей)
    API_SERVICE_URL: str = "http://localhost:8080"
    API_SERVICE_TIMEOUT: int = 10

    # Scraper API Integration (для парсинга WB/Ozon)
    SCRAPER_API_URL: str = "http://scraper-api:8000"
    SCRAPER_TIMEOUT: int = 60

    # Payment Integration
    PAYMENT_ENABLED: bool = False
    YOOKASSA_SHOP_ID: Optional[str] = None
    YOOKASSA_SECRET_KEY: Optional[str] = None
    YOOKASSA_BASE_URL: str = "https://api.yookassa.ru/v3"
    
    # CORS
    CORS_ORIGINS: list[str] = ["*"]
    
    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 100
    
    # Pagination
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
