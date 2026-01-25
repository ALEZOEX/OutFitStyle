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
    "street": 0.3,
    "classic": 0.5,
    "business": 0.7,
    "smart_casual": 0.6,
    "outdoor": 0.4,
}

_FORMALITY_MAP = {
    "casual": 0.2,
    "sport": 0.1,
    "street": 0.3,
    "classic": 0.5,
    "business": 0.7,
    "smart_casual": 0.6,
    "outdoor": 0.4,
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
    "all": 2,  # default to summer for all-season items
}

_CATEGORY_MAP = {
    "outerwear": 0,
    "upper": 1,
    "lower": 2,
    "footwear": 3,
    "accessory": 4,
}

_SUBCATEGORY_MAP = {
    "parka": 0,
    "puffer": 1,
    "coat": 2,
    "softshell": 3,
    "raincoat": 4,
    "tshirt": 5,
    "longsleeve": 6,
    "shirt": 7,
    "hoodie": 8,
    "sweater": 9,
    "thermal_top": 10,
    "shorts": 11,
    "jeans": 12,
    "pants": 13,
    "thermal_pants": 14,
    "skirt": 15,
    "sandals": 16,
    "sneakers": 17,
    "boots": 18,
    "winter_boots": 19,
    "loafers": 20,
    "hat": 21,
    "scarf": 22,
    "gloves": 23,
    "umbrella": 24,
    "bag": 25,
}

_USAGE_MAP = {
    "daily": 0,
    "work": 1,
    "formal": 2,
    "sport": 3,
    "outdoor": 4,
    "travel": 5,
    "party": 6,
}

_BASE_COLOUR_MAP = {
    "black": 0,
    "white": 1,
    "gray": 2,
    "navy": 3,
    "beige": 4,
    "brown": 5,
    "green": 6,
    "blue": 7,
    "red": 8,
    "pink": 9,
    "yellow": 10,
    "orange": 11,
    "purple": 12,
}

_FIT_MAP = {
    "slim": 0,
    "regular": 1,
    "relaxed": 2,
    "oversized": 3,
}

_PATTERN_MAP = {
    "solid": 0,
    "striped": 1,
    "checked": 2,
    "printed": 3,
    "camo": 4,
}

_SOURCE_MAP = {
    "synthetic": 0,  # lowest priority
    "partner": 1,
    "manual": 2,
    "user": 3,       # highest priority (wardrobe items)
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
    formality_pref = (user_profile.get("formality_preference") or "casual").lower()

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


def _get_int(item: Dict[str, Any], key: str, default: int) -> int:
    raw = item.get(key, default)
    try:
        return int(raw)
    except (TypeError, ValueError):
        logger.debug(
            "Cannot parse %s=%r for item %s, using default=%s",
            key,
            raw,
            item.get("name"),
            default,
        )
        return int(default)


def _get_warmth_level(item: Dict[str, Any], default: float = 5.0) -> float:
    return _get_float(item, "warmth_level", default)


def _get_formality_level(item: Dict[str, Any], default: float = 3.0) -> float:
    raw = item.get("formality_level", default)
    try:
        return float(raw)
    except (TypeError, ValueError):
        if isinstance(raw, str):
            label = raw.strip().lower()
            mapped = _FORMALITY_MAP.get(label)
            if mapped is not None:
                # приводим к шкале 1..5, если модель на этом тренировалась
                return mapped * 5.0
        return float(default)


def _get_category_idx(category: str) -> int:
    return _CATEGORY_MAP.get((category or "upper").lower(), 1)


def _get_subcategory_idx(subcategory: str) -> int:
    return _SUBCATEGORY_MAP.get((subcategory or "tshirt").lower(), 5)


def _get_source_priority(item: Dict[str, Any], default: int = 0) -> int:
    """Возвращает приоритет источника (0-3), где 3 - highest priority (user/wardrobe items)."""
    source = item.get("source", "synthetic")
    return _SOURCE_MAP.get(source, 0)


def _get_materials_vector(materials: List[str], all_materials: set) -> List[int]:
    """Преобразует список материалов в one-hot вектор."""
    if not materials:
        materials = []
    materials_lower = [m.lower() for m in materials]
    return [1 if material in materials_lower else 0 for material in all_materials]


# =========================
#  ITEM FEATURES
# =========================

def prepare_item_features(item: Dict[str, Any]) -> Dict[str, Any]:
    """Подготавливает признаки предмета одежды."""
    category = item.get("category", "upper")
    subcategory = item.get("subcategory", "tshirt")

    # Извлекаем source и is_owned
    source = item.get("source", "synthetic")
    is_owned = bool(item.get("is_owned", False))

    # One-hot кодирование для source
    is_synthetic = 1 if source == "synthetic" else 0
    is_user = 1 if source == "user" else 0
    is_partner = 1 if source == "partner" else 0
    is_manual = 1 if source == "manual" else 0

    # One-hot кодирование категории
    is_outerwear = 1 if category == "outerwear" else 0
    is_upper = 1 if category == "upper" else 0
    is_lower = 1 if category == "lower" else 0
    is_footwear = 1 if category == "footwear" else 0
    is_accessory = 1 if category == "accessory" else 0

    # One-hot кодирование стиля
    is_casual = 1 if item.get("style") == "casual" else 0
    is_sport = 1 if item.get("style") == "sport" else 0
    is_street = 1 if item.get("style") == "street" else 0
    is_classic = 1 if item.get("style") == "classic" else 0
    is_business = 1 if item.get("style") == "business" else 0
    is_smart_casual = 1 if item.get("style") == "smart_casual" else 0
    is_outdoor = 1 if item.get("style") == "outdoor" else 0

    # One-hot кодирование сезона
    is_winter = 1 if item.get("season") == "winter" else 0
    is_spring = 1 if item.get("season") == "spring" else 0
    is_summer = 1 if item.get("season") == "summer" else 0
    is_autumn = 1 if item.get("season") == "autumn" else 0
    is_all_season = 1 if item.get("season") == "all" else 0

    # One-hot кодирование основного цвета
    base_colour = item.get("base_colour", "black")
    is_black = 1 if base_colour == "black" else 0
    is_white = 1 if base_colour == "white" else 0
    is_gray = 1 if base_colour == "gray" else 0
    is_navy = 1 if base_colour == "navy" else 0
    is_beige = 1 if base_colour == "beige" else 0
    is_brown = 1 if base_colour == "brown" else 0
    is_green = 1 if base_colour == "green" else 0
    is_blue = 1 if base_colour == "blue" else 0
    is_red = 1 if base_colour == "red" else 0
    is_pink = 1 if base_colour == "pink" else 0
    is_yellow = 1 if base_colour == "yellow" else 0
    is_orange = 1 if base_colour == "orange" else 0
    is_purple = 1 if base_colour == "purple" else 0

    # One-hot кодирование фасона
    fit = item.get("fit", "regular")
    is_slim = 1 if fit == "slim" else 0
    is_regular = 1 if fit == "regular" else 0
    is_relaxed = 1 if fit == "relaxed" else 0
    is_oversized = 1 if fit == "oversized" else 0

    # One-hot кодирование рисунка
    pattern = item.get("pattern", "solid")
    is_solid = 1 if pattern == "solid" else 0
    is_striped = 1 if pattern == "striped" else 0
    is_checked = 1 if pattern == "checked" else 0
    is_printed = 1 if pattern == "printed" else 0
    is_camo = 1 if pattern == "camo" else 0

    # Приоритет источника (для финального скоринга)
    source_priority = _get_source_priority(item)

    return {
        "item_name": item.get("name", ""),
        "category": category,
        "category_idx": _get_category_idx(category),
        "subcategory": subcategory,
        "subcategory_idx": _get_subcategory_idx(subcategory),
        "min_temp": _get_float(item, "min_temp", 0.0),
        "max_temp": _get_float(item, "max_temp", 30.0),
        "warmth_level": _get_warmth_level(item, default=5.0),
        "formality_level": _get_formality_level(item, default=3.0),
        "item_style": (item.get("style") or "casual").lower(),
        # Новые признаки для источника и принадлежности
        "is_synthetic": is_synthetic,
        "is_user": is_user,
        "is_partner": is_partner,
        "is_manual": is_manual,
        "is_owned": 1 if is_owned else 0,
        "source": source,  # для возможности визуализации/анализа
        "source_priority": source_priority,  # приоритет источника для финального скоринга
        # One-hot кодирование различных атрибутов
        "is_outerwear": is_outerwear,
        "is_upper": is_upper,
        "is_lower": is_lower,
        "is_footwear": is_footwear,
        "is_accessory": is_accessory,
        "is_casual": is_casual,
        "is_sport": is_sport,
        "is_street": is_street,
        "is_classic": is_classic,
        "is_business": is_business,
        "is_smart_casual": is_smart_casual,
        "is_outdoor": is_outdoor,
        "is_winter": is_winter,
        "is_spring": is_spring,
        "is_summer": is_summer,
        "is_autumn": is_autumn,
        "is_all_season": is_all_season,
        "is_black": is_black,
        "is_white": is_white,
        "is_gray": is_gray,
        "is_navy": is_navy,
        "is_beige": is_beige,
        "is_brown": is_brown,
        "is_green": is_green,
        "is_blue": is_blue,
        "is_red": is_red,
        "is_pink": is_pink,
        "is_yellow": is_yellow,
        "is_orange": is_orange,
        "is_purple": is_purple,
        "is_slim": is_slim,
        "is_regular": is_regular,
        "is_relaxed": is_relaxed,
        "is_oversized": is_oversized,
        "is_solid": is_solid,
        "is_striped": is_striped,
        "is_checked": is_checked,
        "is_printed": is_printed,
        "is_camo": is_camo,
        # Признаки материалов (пока не используем вектор материалов для упрощения)
        "material_count": len(item.get("materials", [])),
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