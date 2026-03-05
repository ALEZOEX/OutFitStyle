import uuid
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.responses import JSONResponse
from pydantic import ValidationError
from typing import Dict, Any, Optional, List, Tuple
from collections import Counter
import time
import logging
import os
import redis
import requests  # type: ignore[import-untyped]
import hashlib
from concurrent.futures import ThreadPoolExecutor, as_completed
import asyncio
import threading
from queue import Queue

from contracts.outfit_contract import OutfitsResponse, Outfit, OutfitItem
from model.adapters import normalize_item
from model.features_v2 import build_feature_frame_v2
from model.outfit_generator import generate_outfits

from contracts.rank_contract import MLRankRequest, MLRankResponse, RankedItem
from contracts.tz_rank_contract import TZRankRequest, TZRankResponse, TZRankedItem
from contracts.translation_contracts import (
    TranslationRequest,
    TranslationResponse,
    BatchTranslationRequest,
    BatchTranslationResponse,
)
from contracts.recommend_contract import (
    RecommendRequest,
    RecommendResponse,
    RecommendOutfit,
    RecommendOutfitItem,
    RecommendContext,
    UserPreferences,
    Item,
)
from model.enhanced_predictor import EnhancedPredictor
from model.features_with_priorities import build_feature_frame
from model.internal_schema import (
    InternalRequest,
    InternalItem,
    InternalContext,
    InternalWeatherData,
    InternalUserProfile,
    InternalSourceType,
)
from contracts.event_contract import ActionEvent, ActionEventResponse
from model.event_logger import log_rank_impression, log_outfits_impression, log_action

from app.filter import (
    WeatherContext,
    filter_categories,
    generate_combinations,
    get_stats,
    apply_preferences_filter,
    UserPreferences as FilterUserPreferences,
)


# ═══════════════════════════════════════════
# MARKET SERVICE CONFIGURATION
# ═══════════════════════════════════════════

MARKET_SERVICE_URL = os.getenv("MARKET_SERVICE_URL", "http://localhost:8001")

# Кэш для данных каталога (TTL 5 минут)
_catalog_cache: Dict[str, Any] = {}
_catalog_cache_timestamp: float = 0
_CATALOG_CACHE_TTL = 300  # секунд


def _get_catalog_data() -> Tuple[Dict[str, float], Dict[str, str], Dict[str, str]]:
    """
    Загружает данные о товарах из Market Service для фильтрации предпочтений.
    Возвращает кортеж: (item_prices, item_styles, item_brands)
    
    Данные кэшируются на 5 минут для снижения нагрузки на Market Service.
    """
    global _catalog_cache, _catalog_cache_timestamp
    
    current_time = time.time()
    
    # Проверка кэша
    if current_time - _catalog_cache_timestamp < _CATALOG_CACHE_TTL and _catalog_cache:
        return (
            _catalog_cache.get("prices", {}),
            _catalog_cache.get("styles", {}),
            _catalog_cache.get("brands", {}),
        )
    
    try:
        # Запрос к Market Service API
        response = requests.get(
            f"{MARKET_SERVICE_URL}/api/v1/products/catalog-data",
            timeout=5,
        )
        response.raise_for_status()
        data = response.json()
        
        # Кэширование данных
        _catalog_cache = {
            "prices": data.get("prices", {}),
            "styles": data.get("styles", {}),
            "brands": data.get("brands", {}),
        }
        _catalog_cache_timestamp = current_time
        
        logger.info(f"Catalog data loaded from Market Service: {len(data)} items")
        
    except requests.RequestException as e:
        logger.warning(f"Failed to load catalog data from Market Service: {e}")
        # Возвращаем пустые данные при ошибке
        _catalog_cache = {"prices": {}, "styles": {}, "brands": {}}
        _catalog_cache_timestamp = current_time
    
    return (
        _catalog_cache.get("prices", {}),
        _catalog_cache.get("styles", {}),
        _catalog_cache.get("brands", {}),
    )


# ═══════════════════════════════════════════
# GLOBAL VARIABLES WITH TYPE HINTS
# ═══════════════════════════════════════════

predictor: Optional["ThreadSafePredictor"] = None
prediction_pool: Optional[ThreadPoolExecutor] = None
redis_client: Optional[redis.Redis] = None


def adapt_ml_request_to_internal(external_request: MLRankRequest) -> InternalRequest:
    """
    Адаптер: преобразует MLRankRequest во внутреннюю схему InternalRequest
    """
    # Преобразование кандидатов
    internal_candidates = []
    for item in external_request.candidates:
        # Преобразование полей warmth->warmth_level и formality->formality_level
        internal_item = InternalItem(
            id=item.id,
            name=item.name,
            category=item.category,
            subcategory=item.subcategory,
            gender=item.gender,
            style=item.style,
            usage=item.usage,
            season=item.season,
            base_colour=item.base_colour,
            formality_level=item.formality,  # Преобразование
            warmth_level=item.warmth,  # Преобразование
            min_temp=item.min_temp,
            max_temp=item.max_temp,
            materials=item.materials,
            fit=item.fit,
            pattern=item.pattern,
            icon_emoji=item.icon_emoji,
            source=InternalSourceType(item.source.value),
            is_owned=item.is_owned,
            created_at=item.created_at,
            source_priority=item.source_priority,
        )
        internal_candidates.append(internal_item)

    # Преобразование контекста
    internal_context = InternalContext(
        weather=InternalWeatherData(
            temperature=external_request.context.weather.temperature,
            feels_like=external_request.context.weather.feels_like,
            humidity=external_request.context.weather.humidity,
            wind_speed=external_request.context.weather.wind_speed,
            weather=external_request.context.weather.weather,
        ),
        user_profile=InternalUserProfile(
            age_range=external_request.context.user_profile.age_range,
            style_preference=external_request.context.user_profile.style_preference,
            temperature_sensitivity=external_request.context.user_profile.temperature_sensitivity,
            formality_preference=external_request.context.user_profile.formality_preference,
            gender=external_request.context.user_profile.gender,
        ),
        preferences=external_request.context.preferences,
        location=external_request.context.location,
    )

    return InternalRequest(context=internal_context, candidates=internal_candidates)


# ═══════════════════════════════════════════
# THREAD POOL & PREDICTOR
# ═══════════════════════════════════════════


class ThreadSafePredictor:
    """
    Thread-safe wrapper for the predictor to handle concurrent requests
    """

    def __init__(self, model_path: str):
        self._lock = threading.RLock()
        self._predictor = EnhancedPredictor(model_path)

    def get_model_version(self) -> str:
        with self._lock:
            return self._predictor.get_model_version()

    def predict(self, feature_df: Any) -> List[float]:
        """
        Выполняет предсказание в потокобезопасном режиме.

        Args:
            feature_df: DataFrame с признаками

        Returns:
            Список оценок для каждого элемента
        """
        with self._lock:
            result = self._predictor.predict(feature_df)
            return result if isinstance(result, list) else list(result)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Управление жизненным циклом приложения:
    - Загрузка ML модели при старте
    - Инициализация пула потоков
    - Корректное завершение при shutdown
    """
    global predictor, prediction_pool

    # Инициализация пула потоков для предсказаний
    prediction_pool = ThreadPoolExecutor(
        max_workers=int(os.getenv("PREDICTION_WORKERS", "4"))
    )

    model_path = os.getenv("MODEL_PATH", "models/model.pkl")

    # Проверяем существование модели
    if not os.path.exists(model_path):
        logging.warning(f"ML model not found at {model_path}. Running without model.")
        predictor = None
    else:
        try:
            predictor = ThreadSafePredictor(model_path)
            logging.info(f"ML model loaded successfully from {model_path}")
        except Exception as e:
            logging.error(f"Failed to load ML model: {e}")
            predictor = None

    yield

    # Shutdown: корректное завершение пула потоков
    if prediction_pool is not None:
        prediction_pool.shutdown(wait=True)
        logging.info("Prediction pool shutdown complete")


app = FastAPI(
    title="OutfitStyle ML Ranking Service", version="1.0.0", lifespan=lifespan
)

# ═══════════════════════════════════════════
# LOGGING & CONFIG
# ═══════════════════════════════════════════

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

TRANSLATION_CACHE_TTL = int(
    os.getenv("TRANSLATION_CACHE_TTL", "86400")
)  # 24 hours in seconds

# Lazy Redis initialization for translation caching
_redis_initialized = False


def _init_redis_client() -> Optional[redis.Redis]:
    """
    Инициализирует Redis клиент для кэширования переводов.
    Вызывается лениво при первом обращении.
    """
    global redis_client, _redis_initialized

    if _redis_initialized:
        return redis_client

    try:
        redis_host = os.getenv(
            "REDIS_HOST", os.getenv("TRANSLATION_REDIS_HOST", "redis")
        )
        redis_port = int(
            os.getenv("REDIS_PORT", os.getenv("TRANSLATION_REDIS_PORT", "6379"))
        )
        redis_password = os.getenv("REDIS_PASSWORD", "")

        if redis_password:
            redis_client = redis.Redis(
                host=redis_host,
                port=redis_port,
                password=redis_password,
                decode_responses=True,
                socket_connect_timeout=5,
            )
        else:
            redis_client = redis.Redis(
                host=redis_host,
                port=redis_port,
                decode_responses=True,
                socket_connect_timeout=5,
            )

        redis_client.ping()
        logger.info(
            f"Connected to Redis at {redis_host}:{redis_port} for translation caching"
        )
    except Exception as e:
        logger.warning(f"Could not connect to Redis for translation caching: {e}")
        redis_client = None

    _redis_initialized = True
    return redis_client


# Yandex Translate API configuration
YANDEX_TRANSLATE_API_URL = os.getenv(
    "YANDEX_TRANSLATE_API_URL",
    "https://translate.api.cloud.yandex.net/translate/v2/translate",
)
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
async def rank_candidates(
    request: MLRankRequest, http_request: Request, response: Response
) -> MLRankResponse:
    """
    Rank clothing candidates based on context and ML model.

    Args:
        request: MLRankRequest containing context and candidates to rank

    Returns:
        MLRankResponse with ranked candidates and model version
    """
    start_time = time.time()

    # Генерация/получение request_id
    request_id = http_request.headers.get("X-Request-Id") or str(uuid.uuid4())
    response.headers["X-Request-Id"] = request_id
    user_id = http_request.headers.get(
        "X-User-Id", "anonymous"
    )  # если у вас есть такой заголовок

    try:
        if len(request.candidates) == 0:
            return MLRankResponse(
                ranked=[],
                model_version=predictor.get_model_version() if predictor else "unknown",
                processing_time_ms=0.0,
            )

        if len(request.candidates) > 250:
            raise HTTPException(
                status_code=422,
                detail=f"Too many candidates: {len(request.candidates)}, maximum allowed: 250",
            )

        # Проверка, что модель загружена
        if predictor is None:
            raise HTTPException(status_code=503, detail="ML model not available")

        # Подготовка признаков для модели (v2)
        items = [normalize_item(item.dict()) for item in request.candidates]

        feature_df = build_feature_frame_v2(
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
            items=items,
        )

        # Выполняем предсказание в пуле потоков для избежания блокировки
        loop = asyncio.get_event_loop()
        scores = await loop.run_in_executor(
            prediction_pool, predictor.predict, feature_df
        )

        # Сопоставление оценок с кандидатами (используем оригинальные id из внешнего запроса)
        ranked_items = []
        for i, score in enumerate(scores):
            ranked_items.append(
                RankedItem(id=request.candidates[i].id, score=float(score))
            )

        # Сортировка по оценке (от максимальной к минимальной)
        ranked_items.sort(key=lambda x: x.score, reverse=True)

        processing_time = (time.time() - start_time) * 1000  # в миллисекундах

        # Логирование импрессии
        context_for_log = {
            "weather": {
                "temperature": request.context.weather.temperature,
                "feels_like": request.context.weather.feels_like,
                "humidity": request.context.weather.humidity,
                "wind_speed": request.context.weather.wind_speed,
                "weather": request.context.weather.weather,
            },
            "user_profile": {
                "age_range": request.context.user_profile.age_range,
                "style_preference": request.context.user_profile.style_preference,
                "temperature_sensitivity": request.context.user_profile.temperature_sensitivity,
                "formality_preference": request.context.user_profile.formality_preference,
                "gender": request.context.user_profile.gender,
            },
        }

        candidates_for_log = [
            {
                "id": c.id,
                "category": c.category,
                "subcategory": c.subcategory,
                "source": str(c.source),
                "source_priority": c.source_priority,
            }
            for c in request.candidates
        ]

        ranked_for_log = [
            {"id": ri.id, "score": ri.score, "position": idx}
            for idx, ri in enumerate(ranked_items, start=1)
        ]

        log_rank_impression(
            request_id=request_id,
            user_id=user_id,
            api="api/rank",
            model_version=predictor.get_model_version(),
            context=context_for_log,
            candidates=candidates_for_log,
            ranked=ranked_for_log,
        )

        return MLRankResponse(
            ranked=ranked_items,
            model_version=predictor.get_model_version(),
            processing_time_ms=processing_time,
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
            error=str(e),
        )


@app.post("/api/recommend", response_model=RecommendResponse)
async def recommend_outfits(
    request: RecommendRequest,
    http_request: Request,
    response: Response,
) -> RecommendResponse:
    """
    Полный пайплайн: фильтрация → генерация комбинаций → скоринг → Top-K.

    В отличие от /api/rank, этот endpoint:
    1. Принимает предметы по категориям (items_by_category)
    2. Фильтрует категории по погоде (filter_categories)
    3. Генерирует комбинации из отфильтрованных предметов
    4. Скорит комбинации через CatBoost
    5. Возвращает Top-K рекомендаций
    6. Применяет предпочтения пользователя (стили, бренды, бюджет)

    Args:
        request: RecommendRequest с контекстом и items_by_category
        http_request: FastAPI request для заголовков
        response: FastAPI response для заголовков

    Returns:
        RecommendResponse с рекомендациями и статистикой
    """
    start_time = time.time()

    # Генерация/получение request_id
    request_id = http_request.headers.get("X-Request-Id") or str(uuid.uuid4())
    response.headers["X-Request-Id"] = request_id
    user_id = http_request.headers.get("X-User-Id", "anonymous")

    try:
        # Проверка, что модель загружена
        if predictor is None:
            raise HTTPException(status_code=503, detail="ML model not available")

        # 1. Создаём контекст для фильтрации
        filter_context = WeatherContext(
            temperature=request.context.temperature,
            humidity=request.context.humidity,
            weather_condition=request.context.weather_condition,
            location=request.context.location,
            activity=request.context.activity,
            gender=request.context.gender,
            duration=request.context.duration,
        )

        # 2. Конвертируем Pydantic Item в dict для filter.py
        items_by_category_dict: Dict[str, List[Dict[str, Any]]] = {}
        for category, items in request.items_by_category.items():
            items_by_category_dict[category] = [item.model_dump() for item in items]

        # 3. Статистика до фильтрации
        stats_before = get_stats(filter_context, items_by_category_dict)

        # 4. Фильтрация по категориям (Уровень 1)
        filtered_items = filter_categories(filter_context, items_by_category_dict)

        # 5. Статистика после фильтрации
        stats_after = get_stats(filter_context, filtered_items)

        # 6. Генерация комбинаций (Уровень 2 — стилевые конфликты)
        candidates = generate_combinations(filtered_items, filter_context)

        if not candidates:
            logger.warning(
                f"No valid combinations for user {user_id}: "
                f"{stats_before['total_items']} items → 0 combinations"
            )
            return RecommendResponse(
                outfits=[],
                total_combinations=0,
                filtered_from=stats_before["total_items"],
                context=request.context.model_dump(),
                model_version=predictor.get_model_version() if predictor else "unknown",
                processing_time_ms=0.0,
            )

        # 7. Применяем предпочтения пользователя (если указаны)
        if request.user_preferences:
            filter_prefs = FilterUserPreferences(
                style_preferences=request.user_preferences.style_preferences,
                budget_range=request.user_preferences.budget_range,
                favorite_brands=request.user_preferences.favorite_brands,
            )

            # Загружаем данные о товарах из Market Service для фильтрации
            item_prices, item_styles, item_brands = _get_catalog_data()

            # Конвертируем item_prices/item_styles/item_brands по ID
            # item_prices: {item_id: price}, item_styles: {item_id: [styles]}, item_brands: {item_id: brand}
            candidates = apply_preferences_filter(
                combinations=candidates,
                preferences=filter_prefs,
                item_prices=item_prices,
                item_styles=item_styles,
                item_brands=item_brands,
            )

            logger.info(
                f"[recommend] preferences applied for user {user_id}: "
                f"styles={request.user_preferences.style_preferences}, "
                f"budget={request.user_preferences.budget_range}, "
                f"brands={request.user_preferences.favorite_brands}"
            )

        # 8. Построение feature frame для CatBoost
        # build_feature_frame_v2 ожидает items с полями category/subcategory
        feature_df = build_feature_frame_v2(
            weather_data={
                "temperature": request.context.temperature,
                "feels_like": request.context.temperature,  # нет данных
                "humidity": request.context.humidity,
                "wind_speed": 0.0,  # нет данных
                "weather": request.context.weather_condition,
            },
            user_profile={
                "age_range": "adult",
                "style_preference": (
                    request.user_preferences.style_preferences[0]
                    if request.user_preferences and request.user_preferences.style_preferences
                    else "casual"
                ),
                "temperature_sensitivity": "normal",
                "formality_preference": "normal",
                "gender": request.context.gender,
            },
            items=[
                {
                    "category": "outfit",
                    "subcategory": "full_look",
                    "item_name": _combo_to_name(combo),
                }
                for combo in candidates
            ],
        )

        # 9. Предсказание CatBoost в пуле потоков (неблокирующе)
        loop = asyncio.get_event_loop()
        scores = await loop.run_in_executor(
            prediction_pool, predictor.predict, feature_df
        )

        # 10. Ранжирование по убыванию score
        scored: List[Tuple[Dict[str, Any], float]] = list(zip(candidates, scores))
        scored.sort(key=lambda x: x[1], reverse=True)

        # 11. Формирование результата (Top-K с diversification)
        result_outfits: List[RecommendOutfit] = []
        prev_subcategories: List[str] = []  # последние 2 subcategory для diversification

        for combo, score in scored:
            if len(result_outfits) >= request.top_k:
                break

            # Diversification: не более 2 одинаковых subcategory подряд
            upper_sub = combo["upper"].get("subcategory", "")
            if len(prev_subcategories) >= 2 and prev_subcategories[-1] == upper_sub and prev_subcategories[-2] == upper_sub:
                continue

            result_outfits.append(
                RecommendOutfit(
                    upper=RecommendOutfitItem(
                        id=combo["upper"]["id"],
                        category=combo["upper"]["category"],
                        subcategory=combo["upper"]["subcategory"],
                        name=combo["upper"]["name"],
                        base_colour=combo["upper"]["base_colour"],
                    ),
                    lower=RecommendOutfitItem(
                        id=combo["lower"]["id"],
                        category=combo["lower"]["category"],
                        subcategory=combo["lower"]["subcategory"],
                        name=combo["lower"]["name"],
                        base_colour=combo["lower"]["base_colour"],
                    ),
                    footwear=RecommendOutfitItem(
                        id=combo["footwear"]["id"],
                        category=combo["footwear"]["category"],
                        subcategory=combo["footwear"]["subcategory"],
                        name=combo["footwear"]["name"],
                        base_colour=combo["footwear"]["base_colour"],
                    ),
                    outerwear=(
                        RecommendOutfitItem(
                            id=combo["outerwear"]["id"],
                            category=combo["outerwear"]["category"],
                            subcategory=combo["outerwear"]["subcategory"],
                            name=combo["outerwear"]["name"],
                            base_colour=combo["outerwear"]["base_colour"],
                        )
                        if combo.get("outerwear")
                        else None
                    ),
                    score=round(float(score), 4),
                )
            )
            prev_subcategories.append(upper_sub)
            if len(prev_subcategories) > 2:
                prev_subcategories.pop(0)

        processing_time = (time.time() - start_time) * 1000

        # 12. Логирование с метриками
        logger.info(
            f"[recommend] request_id={request_id} user={user_id} "
            f"{stats_before['total_items']} items → {stats_after['total_items']} after filter → "
            f"{len(candidates)} combinations → Top-{len(result_outfits)} returned, "
            f"processing_time={processing_time:.2f}ms"
        )

        return RecommendResponse(
            outfits=result_outfits,
            total_combinations=len(candidates),
            filtered_from=stats_before["total_items"],
            context=request.context.model_dump(),
            model_version=predictor.get_model_version() if predictor else "unknown",
            processing_time_ms=processing_time,
        )

    except ValidationError as ve:
        logger.error(f"[recommend] Validation error: {ve}")
        raise HTTPException(status_code=422, detail=f"Validation error: {str(ve)}")
    except Exception as e:
        logger.exception(f"[recommend] Unexpected error: {e}")
        processing_time = (time.time() - start_time) * 1000
        return RecommendResponse(
            outfits=[],
            total_combinations=0,
            filtered_from=0,
            context=request.context.model_dump(),
            model_version=predictor.get_model_version() if predictor else "unknown",
            processing_time_ms=processing_time,
            error=str(e),
        )


def _combo_to_name(combo: Dict[str, Any]) -> str:
    """Создаёт читаемое название комбинации для ML модели."""
    parts = []
    if combo.get("upper"):
        parts.append(combo["upper"].get("subcategory", "upper"))
    if combo.get("lower"):
        parts.append(combo["lower"].get("subcategory", "lower"))
    if combo.get("outerwear"):
        parts.append(combo["outerwear"].get("subcategory", "outerwear"))
    if combo.get("footwear"):
        parts.append(combo["footwear"].get("subcategory", "footwear"))
    return "+".join(parts) if parts else "outfit"


@app.post("/api/v1/rank", response_model=TZRankResponse)
async def rank_candidates_v1(
    request: TZRankRequest, http_request: Request, response: Response
) -> TZRankResponse:
    start_time = time.time()

    # Генерация/получение request_id
    request_id = request.request_id
    response.headers["X-Request-Id"] = request_id
    user_id = getattr(request, "user_id", None) or http_request.headers.get(
        "X-User-Id", "anonymous"
    )

    if predictor is None:
        raise HTTPException(status_code=503, detail="ML model not available")

    # Map user prefs to legacy user_profile schema for your feature builder
    preferred_style = (
        request.user_preferences.preferred_styles[0]
        if request.user_preferences.preferred_styles
        else "casual"
    )

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
        items.append(
            {
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
            }
        )

    feature_df = build_feature_frame_v2(
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
            "formality_preference": "business"
            if request.context.formality >= 4
            else "casual",
            "gender": "unisex",
        },
        items=items,
    )

    # Выполняем предсказание в пуле потоков для избежания блокировки
    loop = asyncio.get_event_loop()
    scores = await loop.run_in_executor(prediction_pool, predictor.predict, feature_df)

    # build rankings by category
    rankings: Dict[str, List[TZRankedItem]] = {}
    for i, score in enumerate(scores):
        cat = request.candidates[i].category
        rankings.setdefault(cat, []).append(
            TZRankedItem(
                id=request.candidates[i].id,
                score=float(score),
                confidence=float(min(1.0, max(0.0, score))),
                factors={"source_priority": request.candidates[i].source_priority},
            )
        )

    for cat in rankings:
        rankings[cat].sort(key=lambda x: x.score, reverse=True)

    # outfit_score = mean of top scores in main categories
    top_scores = []
    for cat in ["outerwear", "upper", "lower", "footwear", "accessory"]:
        if cat in rankings and len(rankings[cat]) > 0:
            top_scores.append(rankings[cat][0].score)
    outfit_score = float(sum(top_scores) / len(top_scores)) if top_scores else 0.0

    processing_time = int((time.time() - start_time) * 1000)

    # Логирование импрессии
    context_for_log = {
        "temperature": request.context.temperature,
        "feels_like": request.context.feels_like,
        "humidity": request.context.humidity,
        "wind_speed": request.context.wind_speed,
        "weather_code": request.context.weather_code,
        "occasion": getattr(request.context, "occasion", None),
        "formality": getattr(request.context, "formality", None),
    }

    candidates_for_log = [
        {
            "id": c.id,
            "category": c.category,
            "subcategory": c.subcategory,
            "source": c.source,
            "source_priority": c.source_priority,
        }
        for c in request.candidates
    ]

    flat_ranked = []
    for cat, items_list in rankings.items():
        for pos, it in enumerate(items_list, start=1):
            flat_ranked.append(
                {"id": it.id, "score": it.score, "position": pos, "category": cat}
            )

    log_rank_impression(
        request_id=request_id,
        user_id=user_id,
        api="api/v1/rank",
        model_version=predictor.get_model_version(),
        context=context_for_log,
        candidates=candidates_for_log,
        ranked=flat_ranked,
    )

    return TZRankResponse(
        request_id=request.request_id,
        rankings=rankings,
        outfit_score=outfit_score,
        style_coherence=0.5,
        color_harmony=0.5,
        model_version=predictor.get_model_version(),
        processing_time_ms=processing_time,
    )


@app.post("/api/outfits", response_model=OutfitsResponse)
async def outfits(
    request: MLRankRequest, http_request: Request, response: Response
) -> OutfitsResponse:
    start = time.time()

    # Генерация/получение request_id
    request_id = http_request.headers.get("X-Request-Id") or str(uuid.uuid4())
    response.headers["X-Request-Id"] = request_id
    user_id = http_request.headers.get("X-User-Id", "anonymous")

    try:
        if predictor is None:
            raise HTTPException(status_code=503, detail="ML model not available")

        if len(request.candidates) == 0:
            return OutfitsResponse(
                outfits=[],
                model_version=predictor.get_model_version(),
                processing_time_ms=0.0,
            )

        if len(request.candidates) > 250:
            raise HTTPException(status_code=422, detail="Too many candidates, max 250")

        items = [normalize_item(item.dict()) for item in request.candidates]

        feature_df = build_feature_frame_v2(
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
            items=items,
        )

        # Выполняем предсказание в пуле потоков для избежания блокировки
        loop = asyncio.get_event_loop()
        scores = await loop.run_in_executor(
            prediction_pool, predictor.predict, feature_df
        )

        scores_by_id = {items[i]["id"]: float(scores[i]) for i in range(len(items))}

        temperature = float(request.context.weather.temperature)
        user_style = str(request.context.user_profile.style_preference).lower()

        outfits_list = generate_outfits(
            candidates=items,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=5,
            topn_per_category=20,
            beam_size=60,
        )

        resp = []
        for o in outfits_list:
            resp_items = {
                cat: OutfitItem(
                    id=it["id"], score=float(scores_by_id.get(it["id"], 0.0))
                )
                for cat, it in o.items.items()
            }
            resp.append(
                Outfit(
                    outfit_score=float(o.outfit_score),
                    breakdown=o.breakdown,
                    items=resp_items,
                )
            )

        # Логирование импрессии outfits
        context_for_log = {
            "weather": {
                "temperature": request.context.weather.temperature,
                "feels_like": request.context.weather.feels_like,
                "humidity": request.context.weather.humidity,
                "wind_speed": request.context.weather.wind_speed,
                "weather": request.context.weather.weather,
            },
            "user_profile": {
                "style_preference": request.context.user_profile.style_preference,
                "formality_preference": request.context.user_profile.formality_preference,
            },
        }

        # outfit_id можно сделать детерминированным: "upper=1|lower=2|footwear=3"
        outfits_for_log = []
        for pos, o in enumerate(resp, start=1):
            items_map = {cat: str(item.id) for cat, item in o.items.items()}
            outfit_id = "|".join(
                [f"{k}={items_map[k]}" for k in sorted(items_map.keys())]
            )
            outfits_for_log.append(
                {
                    "outfit_id": outfit_id,
                    "outfit_score": o.outfit_score,
                    "position": pos,
                    "items": items_map,
                    "breakdown": o.breakdown,
                }
            )

        log_outfits_impression(
            request_id=request_id,
            user_id=user_id,
            api="api/outfits",
            model_version=predictor.get_model_version(),
            context=context_for_log,
            outfits=outfits_for_log,
        )

        ms = (time.time() - start) * 1000
        return OutfitsResponse(
            outfits=resp,
            model_version=predictor.get_model_version(),
            processing_time_ms=ms,
        )

    except Exception as e:
        ms = (time.time() - start) * 1000
        return OutfitsResponse(
            outfits=[],
            model_version=predictor.get_model_version() if predictor else "unknown",
            processing_time_ms=ms,
            error=str(e),
        )


@app.post("/api/action", response_model=ActionEventResponse)
async def action_event(ev: ActionEvent) -> ActionEventResponse:
    # сюда должен стучаться backend, когда пользователь кликнул/выбрал вещь или outfit
    log_action(
        request_id=ev.request_id,
        user_id=ev.user_id,
        action_type=ev.action_type,
        entity_type=ev.entity_type,
        entity_id=ev.entity_id,
        meta=ev.meta,
    )
    return ActionEventResponse(ok=True)


@app.get("/metrics")
async def get_metrics():
    """Placeholder for Prometheus metrics endpoint"""
    # В реальном приложении здесь должен быть код для интеграции с Prometheus
    return {"message": "Metrics endpoint"}


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8000"))
    uvicorn.run("main:app", host="0.0.0.0", port=port, reload=True, log_level="info")
