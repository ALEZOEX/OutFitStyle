from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import ValidationError
from typing import Dict, Any, Optional
import time
import logging
import os
import redis
import requests
import hashlib
from concurrent.futures import ThreadPoolExecutor

from contracts.rank_contract import MLRankRequest, MLRankResponse, RankedItem
from contracts.translation_contracts import TranslationRequest, TranslationResponse, BatchTranslationRequest, BatchTranslationResponse
from model.enhanced_predictor import EnhancedPredictor
from model.features_with_priorities import build_feature_frame


app = FastAPI(title="OutfitStyle ML Ranking Service", version="1.0.0")

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Глобальный инстанс модели
predictor = None

# Initialize Redis client for translation caching
redis_client = None
TRANSLATION_CACHE_TTL = 86400  # 24 hours in seconds
try:
    redis_host = os.getenv("REDIS_HOST", "redis")
    redis_port = int(os.getenv("REDIS_PORT", 6379))
    redis_client = redis.Redis(host=redis_host, port=redis_port, decode_responses=True, socket_connect_timeout=5)
    redis_client.ping()  # Test connection
    logger.info(f"Connected to Redis at {redis_host}:{redis_port} for translation caching")
except Exception as e:
    logger.warning(f"Could not connect to Redis for translation caching: {e}")
    redis_client = None

# Yandex Translate API configuration
YANDEX_TRANSLATE_API_URL = "https://translate.api.cloud.yandex.net/translate/v2/translate"
YANDEX_API_KEY = os.getenv("YANDEX_TRANSLATE_API_KEY", "aje36hbuc3e2ntrh5e21")  # Default fallback key
YANDEX_FOLDER_ID = os.getenv("YANDEX_FOLDER_ID", "b1ghje4lg8jt69h4tsck")  # Default folder ID

# Thread pool for translation requests
translation_executor = ThreadPoolExecutor(max_workers=10)

@app.on_event("startup")
def startup_event():
    global predictor
    model_path = os.getenv("MODEL_PATH", "models/model.pkl")  # укажите путь к модели
    try:
        predictor = EnhancedPredictor(model_path)
        logger.info(f"ML model loaded successfully from {model_path}")
    except Exception as e:
        logger.error(f"Failed to load ML model: {e}")
        raise


@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": predictor is not None}


@app.get("/ready")
async def readiness_check():
    if predictor is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "ready"}


@app.post("/api/rank", response_model=MLRankResponse)
async def rank_candidates(request: MLRankRequest) -> MLRankResponse:
    """
    Rank clothing candidates based on context and ML model.
    
    Args:
        request: MLRankRequest containing context and candidates to rank
        
    Returns:
        MLRankResponse with ranked candidates and model version
    """
    start_time = time.time()
    
    try:
        if len(request.candidates) == 0:
            return MLRankResponse(
                ranked=[],
                model_version=predictor.get_model_version() if predictor else "unknown",
                processing_time_ms=0.0
            )
        
        if len(request.candidates) > 250:
            raise HTTPException(
                status_code=422, 
                detail=f"Too many candidates: {len(request.candidates)}, maximum allowed: 250"
            )
        
        # Проверка, что модель загружена
        if predictor is None:
            raise HTTPException(status_code=503, detail="ML model not available")
        
        # Подготовка признаков для модели
        feature_df = build_feature_frame(
            weather_data={
                "temperature": request.context.weather.temperature,
                "feels_like": request.context.weather.feels_like,
                "humidity": request.context.weather.humidity,
                "wind_speed": request.context.weather.wind_speed,
                "weather": request.context.weather.weather,
            },
            user_profile={
                "age_range": request.context.user_profile.age_range,
                "style_preference": request.context.user_profile.style_preference,
                "temperature_sensitivity": request.context.user_profile.temperature_sensitivity,
                "formality_preference": request.context.user_profile.formality_preference,
                "gender": request.context.user_profile.gender,
            },
            items=[item.dict() for item in request.candidates]
        )
        
        # Получение предсказаний от модели
        scores = predictor.predict(feature_df)
        
        # Сопоставление оценок с кандидатами
        ranked_items = []
        for i, score in enumerate(scores):
            ranked_items.append(RankedItem(
                id=request.candidates[i].id,
                score=float(score)
            ))
        
        # Сортировка по оценке (от максимальной к минимальной)
        ranked_items.sort(key=lambda x: x.score, reverse=True)
        
        processing_time = (time.time() - start_time) * 1000  # в миллисекундах
        
        return MLRankResponse(
            ranked=ranked_items,
            model_version=predictor.get_model_version(),
            processing_time_ms=processing_time
        )
    
    except ValidationError as ve:
        logger.error(f"Validation error: {ve}")
        raise HTTPException(status_code=422, detail=f"Validation error: {str(ve)}")
    except Exception as e:
        logger.error(f"Error during ranking: {e}")
        processing_time = (time.time() - start_time) * 1000
        return MLRankResponse(
            ranked=[],
            model_version=predictor.get_model_version() if predictor else "unknown",
            processing_time_ms=processing_time,
            error=str(e)
        )


@app.get("/metrics")
async def get_metrics():
    """Placeholder for Prometheus metrics endpoint"""
    # В реальном приложении здесь должен быть код для интеграции с Prometheus
    return {"message": "Metrics endpoint"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=5000,
        reload=True,
        log_level="info"
    )