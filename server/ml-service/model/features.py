import logging
from typing import Dict, Any, List

import pandas as pd

logger = logging.getLogger(__name__)

# =========================
#  MAPPINGS
# =========================

_WEATHER_MAP = {
    "ясно": "clear",
    "облачно": "clouds",
    "дождь": "rain",
    "морось": "drizzle",
    "снег": "snow",
    "туман": "mist",
    "гроза": "thunderstorm",
}

_STYLE_MAP = {
    "casual": 0.2,
    "sport": 0.1,
    "smart": 0.6,
    "business": 0.7,
    "formal": 0.8,
}

_FORMALITY_MAP = {
    "casual": 0.2,
    "smart": 0.6,
    "business": 0.7,
    "formal": 0.8,
}

_TEMP_SENS_MAP = {
    "cold": -1.0,
    "normal": 0.0,
    "warm": 1.0,
}

_SEASON_MAP = {
    "winter": 0,
    "spring": 1,
    "summer": 2,
    "autumn": 3,
}

_CATEGORY_MAP = {
    "outerwear": 0,
    "upper": 1,
    "lower": 2,
    "footwear": 3,
    "accessories": 4,
}


# =========================
#  WEATHER FEATURES
# =========================

def prepare_weather_features(weather_data: Dict[str, Any]) -> Dict[str, Any]:
    """Подготавливает погодные признаки в числовом виде."""
    weather_condition = (weather_data.get("weather") or "Ясно").lower()
    weather_condition = _WEATHER_MAP.get(weather_condition, weather_condition)

    temp = float(weather_data.get("temperature", 20.0))

    if temp < 0:
        season = "winter"
    elif temp < 15:
        season = "spring"
    elif temp < 25:
        season = "summer"
    else:
        season = "autumn"

    return {
        "temperature": temp,
        "feels_like": float(
            weather_data.get("feels_like", weather_data.get("temperature", 20.0))
        ),
        "humidity": float(weather_data.get("humidity", 50.0)),
        "wind_speed": float(weather_data.get("wind_speed", 0.0)),
        "weather_condition": weather_condition,
        "season": season,
        "season_idx": _SEASON_MAP.get(season, 2),
    }


# =========================
#  USER FEATURES
# =========================

def prepare_user_features(user_profile: Dict[str, Any]) -> Dict[str, Any]:
    """Подготавливает признаки пользователя (частично числовые)."""
    style = (user_profile.get("style_preference") or "casual").lower()
    temp_sens = (user_profile.get("temperature_sensitivity") or "normal").lower()
    formality_pref = (user_profile.get("formality_preference") or "informal").lower()

    return {
        "age_range": user_profile.get("age_range", "25-35"),
        "style_preference": style,
        "style_pref_score": _STYLE_MAP.get(style, 0.2),
        "temperature_sensitivity": temp_sens,
        "temp_sens_score": _TEMP_SENS_MAP.get(temp_sens, 0.0),
        "formality_preference": formality_pref,
    }


# =========================
#  ITEM HELPERS
# =========================

def _get_float(item: Dict[str, Any], key: str, default: float) -> float:
    raw = item.get(key, default)
    try:
        return float(raw)
    except (TypeError, ValueError):
        logger.debug(
            "Cannot parse %s=%r for item %s, using default=%s",
            key,
            raw,
            item.get("name"),
            default,
        )
        return float(default)


def _get_warmth_level(item: Dict[str, Any], default: float = 5.0) -> float:
    return _get_float(item, "warmth_level", default)


def _get_formality_level(item: Dict[str, Any], default: float = 5.0) -> float:
    raw = item.get("formality_level", default)
    try:
        return float(raw)
    except (TypeError, ValueError):
        if isinstance(raw, str):
            label = raw.strip().lower()
            mapped = _FORMALITY_MAP.get(label)
            if mapped is not None:
                # приводим к шкале 0..10, если модель на этом тренировалась
                return mapped * 10.0
        return float(default)


def _get_category_idx(category: str) -> int:
    return _CATEGORY_MAP.get((category or "upper").lower(), 1)


# =========================
#  ITEM FEATURES
# =========================

def prepare_item_features(item: Dict[str, Any]) -> Dict[str, Any]:
    """Подготавливает признаки предмета одежды."""
    category = item.get("category", "upper")

    # Извлекаем source и is_owned
    source = item.get("source", "catalog")
    is_owned = bool(item.get("is_owned", False))

    # One-hot кодирование для source
    is_wardrobe = 1 if source == "wardrobe" else 0
    is_catalog = 1 if source == "catalog" else 0
    is_kaggle_seed = 1 if source == "kaggle_seed" else 0

    return {
        "item_name": item.get("name", ""),
        "category": category,
        "category_idx": _get_category_idx(category),
        "min_temp": _get_float(item, "min_temp", 0.0),
        "max_temp": _get_float(item, "max_temp", 30.0),
        "warmth_level": _get_warmth_level(item, default=5.0),
        "formality_level": _get_formality_level(item, default=5.0),
        "item_style": (item.get("style") or "casual").lower(),
        # Новые признаки для источника и принадлежности
        "is_wardrobe": is_wardrobe,
        "is_catalog": is_catalog,
        "is_kaggle_seed": is_kaggle_seed,
        "is_owned": 1 if is_owned else 0,
        "source": source,  # для возможности визуализации/анализа
    }


# =========================
#  HIGH-LEVEL BUILDERS
# =========================

def build_feature_rows(
    weather_data: Dict[str, Any],
    user_profile: Dict[str, Any],
    items: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    """Собирает список dict'ов фичей для каждого item."""
    rows: List[Dict[str, Any]] = []

    base_weather = prepare_weather_features(weather_data)
    base_user = prepare_user_features(user_profile)

    for item in items:
        row = {
            **base_weather,
            **base_user,
            **prepare_item_features(item),
        }
        rows.append(row)

    return rows


def build_feature_frame(
    weather_data: Dict[str, Any],
    user_profile: Dict[str, Any],
    items: List[Dict[str, Any]],
) -> pd.DataFrame:
    """Готовит pandas DataFrame для подачи в модель."""
    rows = build_feature_rows(weather_data, user_profile, items)
    if not rows:
        return pd.DataFrame()
    df = pd.DataFrame(rows)
    return df