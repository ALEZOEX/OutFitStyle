import logging
import os
from typing import Any, Dict, List, Literal, Optional

import pandas as pd
import psycopg2
import psycopg2.extras
import requests
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

from model.advanced_trainer import AdvancedOutfitRecommender
from model.enhanced_predictor import EnhancedOutfitPredictor

# --------------------------------------------------
# Логирование
# --------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# --------------------------------------------------
# FastAPI
# --------------------------------------------------
app = FastAPI(
    title="OutfitStyle ML Service",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --------------------------------------------------
# Модель
# --------------------------------------------------
recommender = AdvancedOutfitRecommender(model_type="gradient_boosting")
predictor = EnhancedOutfitPredictor(recommender)

# --------------------------------------------------
# Конфиг БД
# --------------------------------------------------
DB_CONFIG: Dict[str, Any] = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5432"),
    "user": os.getenv("DB_USER", "Admin"),
    "password": os.getenv("DB_PASSWORD", "password"),
    "database": os.getenv("DB_NAME", "outfitstyle"),
}

# URL marketplace‑сервиса внутри docker‑сети
MARKETPLACE_SERVICE_URL = os.getenv(
    "MARKETPLACE_SERVICE_URL", "http://marketplace-service:5000"
)


# --------------------------------------------------
# Вспомогательные функции работы с БД
# --------------------------------------------------
def get_db_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        logger.error(f"DB connection error: {e}")
        raise


def load_user_profile(user_id: int) -> Dict[str, Any]:
    """
    Загружаем профиль пользователя из user_profiles.
    Используем поля, которые нужны ML‑модели.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute(
            """
            SELECT
                gender,
                age_range,
                style_preference,
                temperature_sensitivity,
                preferred_categories,
                formality_preference
            FROM user_profiles
            WHERE user_id = %s
            """,
            (user_id,),
        )
        result = cursor.fetchone()
        cursor.close()
        conn.close()

        if result:
            profile = dict(result)
            profile.setdefault("formality_preference", "informal")
            return profile

        logger.warning(f"Profile not found for user {user_id}, using defaults")
        return {
            "age_range": "25-35",
            "style_preference": "casual",
            "temperature_sensitivity": "normal",
            "formality_preference": "informal",
        }
    except Exception as e:
        logger.error(f"Error loading user profile: {e}", exc_info=True)
        return {
            "age_range": "25-35",
            "style_preference": "casual",
            "temperature_sensitivity": "normal",
            "formality_preference": "informal",
        }


def get_candidate_items(user_id: int,
                        weather: Dict[str, Any],
                        profile: Dict[str, Any],
                        limit_per_cat: int = 300) -> List[Dict[str, Any]]:
    """
    Возвращает список candidate-вещей с приоритетом:
    1) гардероб (wardrobe),
    2) реальные новые (catalog/marketplace),
    3) kaggle_seed.
    """
    conn = get_db_connection()
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

    feels_like = float(weather.get("feels_like") or weather.get("temperature") or 20.0)
    style_pref = profile.get("style_preference", "casual")
    gender = profile.get("gender", None)

    required_categories = ["upper", "lower", "footwear", "accessory"]

    candidates: List[Dict[str, Any]] = []

    # 1. Wardrobe (личные вещи пользователя)
    cursor.execute(
        """
        SELECT ci.*, w.user_id as owner_user_id
        FROM clothing_items ci
        JOIN wardrobe_items w ON w.clothing_item_id = ci.id
        WHERE w.user_id = %s
          AND ci.category = ANY(%s)
          AND (ci.min_temp IS NULL OR ci.min_temp <= %s + 5)
          AND (ci.max_temp IS NULL OR ci.max_temp >= %s - 5)
        """,
        (user_id, required_categories, feels_like, feels_like),
    )
    wardrobe_items = [dict(r) for r in cursor.fetchall()]
    for it in wardrobe_items:
        it.setdefault("source", "wardrobe")
        it.setdefault("is_owned", True)
    candidates.extend(wardrobe_items)

    # Посчитаем покрытие по категориям
    coverage = {cat: 0 for cat in required_categories}
    for it in wardrobe_items:
        cat = it.get("category")
        if cat in coverage:
            coverage[cat] += 1

    # 2. Catalog/marketplace для недостающих категорий
    missing_cats = [c for c, cnt in coverage.items() if cnt == 0]
    if missing_cats:
        cursor.execute(
            """
            SELECT ci.*, ci.owner_user_id
            FROM clothing_items ci
            WHERE ci.source IN ('catalog', 'marketplace')
              AND ci.category = ANY(%s)
              AND (ci.min_temp IS NULL OR ci.min_temp <= %s + 5)
              AND (ci.max_temp IS NULL OR ci.max_temp >= %s - 5)
            ORDER BY RANDOM()
            LIMIT %s
            """,
            (missing_cats, feels_like, feels_like, len(missing_cats) * limit_per_cat),
        )
        new_items = [dict(r) for r in cursor.fetchall()]
        for it in new_items:
            it.setdefault("source", "catalog")
            it.setdefault("is_owned", False)
        candidates.extend(new_items)

    # 3. Kaggle_seed для тех категорий, где всё равно пусто
    coverage2 = {cat: 0 for cat in required_categories}
    for it in candidates:
        cat = it.get("category")
        if cat in coverage2:
            coverage2[cat] += 1
    still_missing = [c for c, cnt in coverage2.items() if cnt == 0]

    if still_missing:
        cursor.execute(
            """
            SELECT ci.*, ci.owner_user_id
            FROM clothing_items ci
            WHERE ci.source = 'kaggle_seed'
              AND ci.category = ANY(%s)
              AND (ci.min_temp IS NULL OR ci.min_temp <= %s + 10)
              AND (ci.max_temp IS NULL OR ci.max_temp >= %s - 10)
            ORDER BY RANDOM()
            LIMIT %s
            """,
            (still_missing, feels_like, feels_like, len(still_missing) * limit_per_cat),
        )
        k_items = [dict(r) for r in cursor.fetchall()]
        for it in k_items:
            it.setdefault("source", "kaggle_seed")
            it.setdefault("is_owned", False)
        candidates.extend(k_items)

    cursor.close()
    conn.close()

    # Ограничиваем общее кол-во кандидатов, чтобы не убивать модель
    MAX_TOTAL = 1000
    if len(candidates) > MAX_TOTAL:
        import random
        random.shuffle(candidates)
        candidates = candidates[:MAX_TOTAL]

    logger.info(f"Total candidate items: {len(candidates)}")
    return candidates


def load_clothing_items(
    weather_data: Dict[str, Any],
    user_profile: Dict[str, Any],
) -> List[Dict[str, Any]]:
    """
    Fallback: загружаем одежду напрямую из clothing_items по диапазону температур и стилю.
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        temperature = float(weather_data.get("temperature", 20.0))
        style_pref = user_profile.get("style_preference", "casual")

        cursor.execute(
            """
            SELECT
                id,
                name,
                category,
                subcategory,
                min_temp,
                max_temp,
                weather_conditions,
                style,
                warmth_level,
                formality_level,
                icon_emoji
            FROM clothing_items
            WHERE
                (min_temp IS NULL OR min_temp <= %s + 10)
                AND (max_temp IS NULL OR max_temp >= %s - 10)
            ORDER BY
                CASE WHEN style = %s THEN 1 ELSE 2 END,
                ABS(COALESCE((min_temp + max_temp) / 2, %s) - %s)
            LIMIT 50
            """,
            (temperature, temperature, style_pref, temperature, temperature),
        )

        items = cursor.fetchall()
        cursor.close()
        conn.close()

        logger.info(f"Loaded {len(items)} clothing items from DB (fallback)")

        normalized: List[Dict[str, Any]] = []
        for item in items:
            d = dict(item)
            if d.get("min_temp") is not None:
                d["min_temp"] = float(d["min_temp"])
            if d.get("max_temp") is not None:
                d["max_temp"] = float(d["max_temp"])
            normalized.append(d)

        return normalized

    except Exception as e:
        logger.error(f"Error loading clothing items: {e}", exc_info=True)
        return []


def fetch_clothing_items_from_marketplace(
    user_id: int,
    weather_data: Dict[str, Any],
    user_profile: Dict[str, Any],
    limit: int = 50,
    source: str = "wardrobe",
) -> List[Dict[str, Any]]:
    """
    Запрашивает вещи у marketplace‑сервиса.

    source = "wardrobe"    -> вещи гардероба пользователя (clothing_items.user_id = user_id)
    source = "catalog"     -> общий каталог (user_id IS NULL).
    """
    try:
        url = f"{MARKETPLACE_SERVICE_URL}/api/marketplace/items-for-ml"
        payload = {
            "user_id": user_id,
            "source": source,
            "weather": weather_data,
            "user_profile": {
                "style_preference": user_profile.get("style_preference", "casual"),
            },
            "limit": limit,
        }

        resp = requests.post(url, json=payload, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        items = data.get("items", [])
        logger.info(
            f"Loaded {len(items)} clothing items from marketplace "
            f"(source={source}, user_id={user_id})"
        )
        return items

    except Exception as e:
        logger.error(f"Error fetching items from marketplace: {e}", exc_info=True)
        return []


# --------------------------------------------------
# Pydantic‑модели
# --------------------------------------------------
class WeatherData(BaseModel):
    temperature: float
    weather: str
    location: str
    feels_like: Optional[float] = None
    humidity: Optional[float] = None
    wind_speed: Optional[float] = None
    min_temp: Optional[float] = None
    max_temp: Optional[float] = None
    will_rain: Optional[bool] = None
    will_snow: Optional[bool] = None


class RecommendRequest(BaseModel):
    user_id: int = Field(..., ge=1)
    weather: WeatherData
    source: Literal["wardrobe", "catalog", "mixed"] = "mixed"
    min_confidence: float = Field(0.5, ge=0.0, le=1.0)


class RecommendResponse(BaseModel):
    recommendation_id: int
    user_id: int
    weather: WeatherData
    outfit_score: float
    ml_powered: bool
    algorithm: str
    recommendations: List[Dict[str, Any]]


class TrainRequest(BaseModel):
    optimize_hyperparameters: bool = False


# --------------------------------------------------
# Handlers
# --------------------------------------------------
@app.get("/health")
def health() -> Dict[str, Any]:
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.close()
        conn.close()
        db_status = "connected"
    except Exception:
        db_status = "disconnected"

    return {
        "status": "ok",
        "service": "Advanced ML Service",
        "model_trained": getattr(recommender, "is_trained", False),
        "database": db_status,
    }


@app.post("/api/ml/recommend", response_model=RecommendResponse)
def recommend(req: RecommendRequest) -> RecommendResponse:
    try:
        user_id = req.user_id
        weather_data = req.weather.dict()
        source = (req.source or "mixed").lower()
        min_confidence = req.min_confidence

        logger.info(
            "Recommendation request",
            extra={
                "user_id": user_id,
                "temp": weather_data.get("temperature"),
                "source": source,
            },
        )

        # 1. Профиль пользователя
        user_profile = load_user_profile(user_id)
        logger.info(f"Loaded user profile: {user_profile}")

        available_items: List[Dict[str, Any]] = []
        used_kaggle_dataset = False

        # 2. Получаем кандидатов через Retrieval из БД
        available_items = get_candidate_items(user_id, weather_data, user_profile)

        # 3. Если нет подходящих вещей ни в гардеробе, ни в каталоге, ни в kaggle_seed –
        #    используем fallback к обычным вещам из clothing_items
        if not available_items:
            logger.warning(
                "No items from retrieval. Falling back to DB clothing_items"
            )
            available_items = load_clothing_items(weather_data, user_profile)

        # 4. Если даже fallback пуст – возвращаем пустой ответ (safety net)
        if not available_items:
            logger.warning(
                "No suitable clothing items found anywhere. "
                "Returning empty outfit recommendation."
            )

            return RecommendResponse(
                recommendation_id=-1,
                user_id=user_id,
                weather=req.weather,
                recommendations=[],
                outfit_score=0.0,
                ml_powered=False,
                algorithm="no_items_fallback",
            )

        logger.info(f"Loaded {len(available_items)} candidate items for recommendation")

        # 5. Есть вещи – строим образ через ML
        adjusted_min_confidence = min(0.3, float(min_confidence))

        outfit = predictor.build_outfit(
            weather_data,
            user_profile,
            available_items,
            min_confidence=adjusted_min_confidence,
        )

        outfit_items = outfit.get("items", [])
        outfit_score = float(outfit.get("outfit_score", 0.0))
        ml_powered = bool(outfit.get("ml_powered", True))
        algorithm = outfit.get("algorithm", "advanced_recommender")

        # Если использовали kaggle_seed – помечаем алгоритм
        if used_kaggle_dataset:
            algorithm = f"{algorithm}_kaggle_dataset"

        recommendation_id = -1

        return RecommendResponse(
            recommendation_id=recommendation_id,
            user_id=user_id,
            weather=req.weather,
            recommendations=outfit_items,
            outfit_score=outfit_score,
            ml_powered=ml_powered,
            algorithm=algorithm,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in recommend endpoint: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/ml/train")
def train_model(req: TrainRequest) -> Dict[str, Any]:
    try:
        optimize = bool(req.optimize_hyperparameters)

        conn = get_db_connection()
        query = """
        SELECT
            r.temperature,
            r.weather,
            NULL::DOUBLE PRECISION    AS humidity,
            NULL::DOUBLE PRECISION    AS wind_speed,
            up.gender,
            up.age_range,
            up.style_preference,
            up.temperature_sensitivity,
            ci.category,
            ci.style,
            ci.warmth_level,
            ci.formality_level,
            ri.ml_score               AS ml_score,
            1                         AS is_liked
        FROM recommendations r
        JOIN user_profiles up
            ON r.user_id = up.user_id
        JOIN recommendation_items ri
            ON r.id = ri.recommendation_id
        JOIN clothing_items ci
            ON ri.clothing_item_id = ci.id
        WHERE r.created_at >= NOW() - INTERVAL '30 days'
        ORDER BY r.created_at DESC
        LIMIT 10000
        """
        df = pd.read_sql(query, conn)
        conn.close()

        if len(df) < 50:
            raise HTTPException(status_code=400, detail="Not enough training data")

        metrics = recommender.train(df, optimize_hyperparameters=optimize)
        os.makedirs("models", exist_ok=True)
        recommender.save("models/advanced_recommender.pkl")

        return {"status": "success", "metrics": metrics}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Training error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

# --------------------------------------------------
# Внутренний fallback-датасет больше не нужен (styles.csv из Kaggle)
# --------------------------------------------------
# Удаляем старую функцию load_internal_dataset_items и глобальную переменную INTERNAL_DATASET_ITEMS
# Теперь датасет Kaggle загружен в базу данных как source='kaggle_seed'

# --------------------------------------------------
# Стартовая загрузка модели
# --------------------------------------------------
@app.on_event("startup")
def load_model_on_startup() -> None:
    global recommender, predictor

    model_paths = [
        "models/kaggle_trained_recommender.pkl",
        "models/advanced_recommender.pkl",
    ]

    os.makedirs("models", exist_ok=True)

    model_loaded = False
    for model_path in model_paths:
        if os.path.exists(model_path):
            try:
                recommender.load(model_path)
                predictor = EnhancedOutfitPredictor(recommender)
                logger.info(f"Loaded trained ML model from {model_path}")
                model_loaded = True
                break
            except ModuleNotFoundError as e:
                logger.warning(
                    f"Model {model_path} incompatible with current sklearn: {e}"
                )
                try:
                    os.remove(model_path)
                    logger.info(f"Removed incompatible model: {model_path}")
                except Exception as del_err:
                    logger.warning(f"Could not delete {model_path}: {del_err}")
            except Exception as e:
                logger.warning(f"Failed to load {model_path}: {e}")

    if not model_loaded:
        logger.warning(
            "No trained model found - using rule-based recommendations. "
            "Train a new model via POST /api/ml/train"
        )


if __name__ == "__main__":
    import uvicorn

    logger.info("Starting Advanced ML Service on port 5000")
    uvicorn.run("main:app", host="0.0.0.0", port=5000, reload=True)