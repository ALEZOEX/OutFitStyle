from contextlib import asynccontextmanager
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
from contracts.tz_rank_contract import TZRankRequest, TZRankResponse, TZRankedItem
from contracts.translation_contracts import TranslationRequest, TranslationResponse, BatchTranslationRequest, BatchTranslationResponse
from model.enhanced_predictor import EnhancedPredictor
from model.features_with_priorities import build_feature_frame


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    global predictor
    model_path = os.getenv("MODEL_PATH", "models/model.pkl")  # укажите путь к модели
    try:
        predictor = EnhancedPredictor(model_path)
        logging.info(f"ML model loaded successfully from {model_path}")
    except Exception as e:
        logging.error(f"Failed to load ML model: {e}")
        raise
    yield
    # Shutdown (если нужно что-то освобождать)


app = FastAPI(
    title="OutfitStyle ML Ranking Service",
    version="1.0.0",
    lifespan=lifespan
)

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
YANDEX_API_KEY = os.getenv("YANDEX_TRANSLATE_API_KEY")
YANDEX_FOLDER_ID = os.getenv("YANDEX_FOLDER_ID")

# Thread pool for translation requests
translation_executor = ThreadPoolExecutor(max_workers=10)



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


@app.post("/api/v1/rank", response_model=TZRankResponse)
async def rank_candidates_v1(request: TZRankRequest) -> TZRankResponse:
    start_time = time.time()

    if predictor is None:
        raise HTTPException(status_code=503, detail="ML model not available")

    # Map user prefs to legacy user_profile schema for your feature builder
    preferred_style = (request.user_preferences.preferred_styles[0] if request.user_preferences.preferred_styles else "casual")

    # temperature_sensitivity int -> label
    ts = request.user_preferences.temperature_sensitivity
    if ts <= -1:
        ts_label = "cold"
    elif ts >= 1:
        ts_label = "warm"
    else:
        ts_label = "normal"

    # Build items for feature builder
    items = []
    for c in request.candidates:
        f = c.features
        items.append({
            "id": c.id,
            "name": "",  # not used by model
            "category": c.category,
            "subcategory": c.subcategory,
            "gender": "unisex",
            "style": f.style,
            "usage": "daily",
            "season": "all",
            "base_colour": f.base_colour or "black",
            "formality_level": f.formality_level,
            "warmth_level": f.warmth_level,
            "min_temp": f.min_temp,
            "max_temp": f.max_temp,
            "materials": [],
            "fit": "regular",
            "pattern": f.pattern or "solid",
            "icon_emoji": "",
            "source": c.source,
            "is_owned": True if c.source == "user" else False,
            "source_priority": c.source_priority,
        })

    feature_df = build_feature_frame(
        weather_data={
            "temperature": request.context.temperature,
            "feels_like": request.context.feels_like,
            "humidity": request.context.humidity,
            "wind_speed": request.context.wind_speed,
            "weather": request.context.weather_code or "clear",
        },
        user_profile={
            "age_range": "25-35",
            "style_preference": preferred_style,
            "temperature_sensitivity": ts_label,
            "formality_preference": "business" if request.context.formality >= 4 else "casual",
            "gender": "unisex",
        },
        items=items
    )

    scores = predictor.predict(feature_df)

    # build rankings by category
    rankings: Dict[str, List[TZRankedItem]] = {}
    for i, score in enumerate(scores):
        cat = request.candidates[i].category
        rankings.setdefault(cat, []).append(TZRankedItem(
            id=request.candidates[i].id,
            score=float(score),
            confidence=float(min(1.0, max(0.0, score))),
            factors={"source_priority": request.candidates[i].source_priority}
        ))

    for cat in rankings:
        rankings[cat].sort(key=lambda x: x.score, reverse=True)

    # outfit_score = mean of top scores in main categories
    top_scores = []
    for cat in ["outerwear", "upper", "lower", "footwear", "accessory"]:
        if cat in rankings and len(rankings[cat]) > 0:
            top_scores.append(rankings[cat][0].score)
    outfit_score = float(sum(top_scores) / len(top_scores)) if top_scores else 0.0

    processing_time = int((time.time() - start_time) * 1000)

    return TZRankResponse(
        request_id=request.request_id,
        rankings=rankings,
        outfit_score=outfit_score,
        style_coherence=0.5,
        color_harmony=0.5,
        model_version=predictor.get_model_version(),
        processing_time_ms=processing_time,
    )


@app.get("/metrics")
async def get_metrics():
    """Placeholder for Prometheus metrics endpoint"""
    # В реальном приложении здесь должен быть код для интеграции с Prometheus
    return {"message": "Metrics endpoint"}


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", "8000"))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port,
        reload=True,
        log_level="info"
    )