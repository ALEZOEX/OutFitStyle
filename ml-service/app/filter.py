"""
Двухуровневая фильтрация кандидатов перед CatBoost.

Уровень 1: категориальный — убираем невозможные категории для данного контекста
Уровень 2: комбинаторный — убираем абсурдные ПАРЫ категорий

Пороги обоснованы анализом Season Fashion Dataset.

ИЗМЕНЕНИЯ (Март 2026):
- Переход на фильтрацию по категориям БД (upper, lower, footwear, outerwear, accessory)
- Убраны индонезийские subcategory (Kaos, Kemeja, Celana, etc.)
- Фильтр работает на уровне предметов из БД (Dict[str, List[Dict]])
"""

from dataclasses import dataclass
from itertools import product as cartesian_product
from typing import List, Optional, Set, Tuple, Dict, Any


# ═══════════════════════════════════════════
# ТЕМПЕРАТУРНЫЕ ПОРОГИ (°C)
# ═══════════════════════════════════════════

TEMP_FREEZING: float = 0.0       # Заморозки
TEMP_VERY_COLD: float = 5.0      # Очень холодно (ботинки обязательны)
TEMP_COLD: float = 10.0          # Холодно (куртка обязательна)
TEMP_COOL: float = 15.0          # Прохладно (outerwear рекомендована)
TEMP_MODERATE: float = 20.0      # Умеренно
TEMP_WARM: float = 25.0          # Тепло
TEMP_HOT: float = 30.0           # Жарко
TEMP_VERY_HOT: float = 35.0      # Очень жарко

# Пороги влажности (%)
HUMIDITY_HIGH: float = 85.0
HUMIDITY_LOW: float = 25.0

# Длительность (часы)
DURATION_LONG: float = 4.0


# ═══════════════════════════════════════════
# КОНТЕКСТ ПОГОДЫ
# ═══════════════════════════════════════════


@dataclass
class WeatherContext:
    """
    Контекст для фильтрации одежды.

    Attributes:
        temperature: Температура воздуха (°C)
        humidity: Влажность (%)
        weather_condition: Погода (Cerah, Mendung, Hujan, Berawan)
        location: Локация (Indoor, Outdoor)
        activity: Активность (Olahraga, Kerja, Jalan-jalan, Pesta)
        gender: Пол (Laki-laki, Perempuan)
        duration: Длительность активности (часы)
    """

    temperature: float
    humidity: float
    weather_condition: str
    location: str
    activity: str
    gender: str
    duration: float = 2.0


@dataclass
class UserPreferences:
    """
    Предпочтения пользователя для персонализации фильтрации.

    Attributes:
        style_preferences: Список предпочитаемых стилей (casual, sport, classic, etc.)
        budget_range: Диапазон бюджета (economy, medium, premium)
        favorite_brands: Список любимых брендов (Nike, Adidas, Zara, etc.)
    """
    style_preferences: Optional[List[str]] = None
    budget_range: Optional[str] = None
    favorite_brands: Optional[List[str]] = None


# ═══════════════════════════════════════════
# УРОВЕНЬ 1: КАТЕГОРИАЛЬНАЯ ФИЛЬТРАЦИЯ
# ═══════════════════════════════════════════


def filter_categories(
    context: WeatherContext,
    items_by_category: Dict[str, List[Dict[str, Any]]],
) -> Dict[str, List[Dict[str, Any]]]:
    """
    Фильтрует предметы по категориям на основе погоды.

    Работает на уровне категорий БД:
    - upper: всегда обязательна
    - lower: всегда обязателен
    - footwear: всегда обязательна
    - outerwear: зависит от температуры
    - accessory: всегда опционально

    Args:
        context: погода
        items_by_category: {"upper": [...], "lower": [...], ...}
            Каждый предмет: {"id": "uuid", "category": "upper", "subcategory": "tshirt", ...}

    Returns:
        Отфильтрованные предметы по категориям
    """
    result: Dict[str, List[Dict[str, Any]]] = {}
    t = context.temperature
    location = context.location
    weather = context.weather_condition
    activity = context.activity
    humidity = context.humidity

    # upper — всегда обязательна
    if "upper" in items_by_category:
        result["upper"] = list(items_by_category["upper"])

    # lower — всегда обязателен
    if "lower" in items_by_category:
        result["lower"] = list(items_by_category["lower"])

    # footwear — всегда обязательна
    if "footwear" in items_by_category:
        result["footwear"] = list(items_by_category["footwear"])

    # outerwear — зависит от температуры
    if "outerwear" in items_by_category:
        if t < TEMP_COLD:
            # Холодно (< 10°C) — outerwear обязательна
            result["outerwear"] = list(items_by_category["outerwear"])
        elif t < TEMP_COOL:
            # Прохладно (10-15°C) — outerwear рекомендована
            result["outerwear"] = list(items_by_category["outerwear"])
        elif t < TEMP_MODERATE:
            # Умеренно (15-20°C) — outerwear опционально
            result["outerwear"] = list(items_by_category["outerwear"])
        else:
            # Тепло (> 20°C) — outerwear не нужна
            result["outerwear"] = []

    # accessory — всегда опционально (оставляем как есть)
    if "accessory" in items_by_category:
        result["accessory"] = list(items_by_category["accessory"])

    # ── Дополнительная фильтрация по погоде ──
    if location == "Outdoor":
        # Дождь — убираем открытую обувь
        if weather == "Hujan" and "footwear" in result:
            result["footwear"] = [
                item for item in result["footwear"]
                if item.get("subcategory", "").lower() not in ["sandal", "sandals"]
            ]

        # Очень холодно (< 5°C) — только закрытая обувь
        if t < TEMP_VERY_COLD and "footwear" in result:
            result["footwear"] = [
                item for item in result["footwear"]
                if item.get("subcategory", "").lower() not in ["sandal", "sandals"]
            ]

    # ── Фильтрация по активности ──
    if activity == "Olahraga":
        # Спорт — убираем формальную одежду
        if "upper" in result:
            result["upper"] = [
                item for item in result["upper"]
                if item.get("subcategory", "").lower() not in ["blazer", "suit"]
            ]
        if "footwear" in result:
            result["footwear"] = [
                item for item in result["footwear"]
                if item.get("subcategory", "").lower() not in ["formal_shoes", "boots"]
            ]

    elif activity == "Kerja":
        # Работа — формальный стиль
        if "footwear" in result:
            result["footwear"] = [
                item for item in result["footwear"]
                if item.get("subcategory", "").lower() not in ["sandal", "sport_shoes"]
            ]

    return result


# ═══════════════════════════════════════════
# УРОВЕНЬ 2: КОМБИНАТОРНАЯ ФИЛЬТРАЦИЯ
# ═══════════════════════════════════════════


def _check_style_conflict(
    top_item: Dict[str, Any],
    bottom_item: Dict[str, Any],
    outerwear_item: Optional[Dict[str, Any]],
    footwear_item: Dict[str, Any],
    context: WeatherContext,
) -> bool:
    """
    Проверяет комбинацию на стилевые конфликты.

    Возвращает True если комбинация ДОПУСТИМА.

    Args:
        top_item: предмет верхней одежды
        bottom_item: предмет нижней одежды
        outerwear_item: предмет верхней одежды (может быть None)
        footwear_item: обувь
        context: контекст погоды

    Returns:
        True если комбинация допустима
    """
    t = context.temperature
    location = context.location

    top_sub = top_item.get("subcategory", "").lower()
    bottom_sub = bottom_item.get("subcategory", "").lower()
    footwear_sub = footwear_item.get("subcategory", "").lower()
    outerwear_sub = outerwear_item.get("subcategory", "").lower() if outerwear_item else ""

    # Стилевые конфликты — формальный верх + неформальный низ
    formal_tops = ["blazer", "suit", "formal_shirt"]
    casual_bottoms = ["shorts", "joggers", "cargo"]

    if top_sub in formal_tops and bottom_sub in casual_bottoms:
        return False

    # Формальная обувь + шорты
    formal_footwear = ["formal_shoes", "oxford", "loafer"]
    if footwear_sub in formal_footwear and bottom_sub in ["shorts"]:
        return False

    # Ботинки + шорты (стилистически спорно)
    if footwear_sub in ["boots", "ankle_boots"] and bottom_sub in ["shorts"]:
        return False

    # ── Температурные конфликты ──
    if location == "Outdoor":
        # Холодно (< 10°C) — без outerwear нельзя
        if t < TEMP_COLD and outerwear_item is None:
            return False

        # Очень холодно (< 5°C) — только теплая обувь
        if t < TEMP_VERY_COLD and footwear_sub in ["sandal", "slipper"]:
            return False

        # Жарко (> 28°C) — куртка не нужна
        if t > 28 and outerwear_item is not None:
            if outerwear_sub in ["jacket", "coat", "parka"]:
                return False

    return True


def validate_outfit_completeness(
    combo: Dict[str, Optional[Dict[str, Any]]],
    context: WeatherContext,
) -> Dict[str, Any]:
    """
    Проверка полноты комплекта одежды.

    Args:
        combo: комбинация предметов {"upper": {...}, "lower": {...}, ...}
        context: контекст погоды

    Returns:
        Dict с информацией о полноте комплекта
    """
    result = {
        "complete": True,
        "missing": [],
        "warnings": [],
        "recommendations": [],
    }

    t = context.temperature
    location = context.location

    # Проверка наличия обязательных категорий
    if not combo.get("upper"):
        result["complete"] = False
        result["missing"].append("upper")
        result["recommendations"].append("Добавьте верхнюю одежду")

    if not combo.get("lower"):
        result["complete"] = False
        result["missing"].append("lower")
        result["recommendations"].append("Добавьте нижнюю одежду")

    if not combo.get("footwear"):
        result["complete"] = False
        result["missing"].append("footwear")
        result["recommendations"].append("Добавьте обувь")

    # Проверка outerwear по температуре
    if location == "Outdoor":
        if t < TEMP_COLD and not combo.get("outerwear"):
            result["warnings"].append("При такой температуре рекомендуется верхняя одежда")
            result["recommendations"].append("Добавьте куртку или пальто")

    return result


# ═══════════════════════════════════════════
# ГЕНЕРАЦИЯ КОМБИНАЦИЙ
# ═══════════════════════════════════════════


def generate_combinations(
    filtered_items: Dict[str, List[Dict[str, Any]]],
    context: WeatherContext,
) -> List[Dict[str, Optional[Dict[str, Any]]]]:
    """
    Генерирует все допустимые комбинации из отфильтрованных предметов.

    Args:
        filtered_items: отфильтрованные предметы по категориям
        context: контекст погоды

    Returns:
        Список комбинаций, каждая: {"upper": {...}, "lower": {...}, "footwear": {...}, "outerwear": {...}}
    """
    # Получаем предметы по категориям
    uppers = filtered_items.get("upper", [])
    lowers = filtered_items.get("lower", [])
    footwears = filtered_items.get("footwear", [])
    outerwears = filtered_items.get("outerwear", [])

    # Если outerwear пуст, добавляем None как опцию
    if not outerwears:
        outerwears_to_use: List[Optional[Dict[str, Any]]] = [None]
    else:
        outerwears_to_use = list(outerwears)

    combinations: List[Dict[str, Optional[Dict[str, Any]]]] = []

    # Декартово произведение
    for upper in uppers:
        for lower in lowers:
            for footwear in footwears:
                for outerwear in outerwears_to_use:
                    combo = {
                        "upper": upper,
                        "lower": lower,
                        "footwear": footwear,
                        "outerwear": outerwear,
                    }

                    # Уровень 2: проверка стилевых конфликтов
                    if _check_style_conflict(upper, lower, outerwear, footwear, context):
                        combinations.append(combo)

    # Fallback: если все отфильтровалось, возвращаем хотя бы что-то
    if not combinations and uppers and lowers and footwears:
        for upper in uppers:
            for lower in lowers:
                for footwear in footwears:
                    combinations.append({
                        "upper": upper,
                        "lower": lower,
                        "footwear": footwear,
                        "outerwear": None,
                    })

    return combinations


# ═══════════════════════════════════════════
# ПУБЛИЧНЫЕ ФУНКЦИИ
# ═══════════════════════════════════════════


def get_stats(
    context: WeatherContext,
    items_by_category: Dict[str, List[Dict[str, Any]]],
) -> Dict[str, Any]:
    """
    Статистика фильтрации для отладки и API.

    Args:
        context: контекст погоды
        items_by_category: предметы по категориям

    Returns:
        Dict со статистикой фильтрации
    """
    # Считаем исходное количество
    total_raw = sum(len(items) for items in items_by_category.values())

    # Фильтрация
    filtered = filter_categories(context, items_by_category)
    after_filter = sum(len(items) for items in filtered.values())

    # Генерация комбинаций
    combinations = generate_combinations(filtered, context)

    # Статистика полноты
    complete_count = sum(
        1 for c in combinations
        if validate_outfit_completeness(c, context)["complete"]
    )

    return {
        "total_items": total_raw,
        "after_category_filter": after_filter,
        "total_combinations": len(combinations),
        "complete_outfits": complete_count,
        "categories": {cat: len(items) for cat, items in filtered.items()},
    }


def get_temperature_recommendations(context: WeatherContext) -> Dict[str, Any]:
    """
    Получить рекомендации по температуре.

    Args:
        context: контекст погоды

    Returns:
        Dict с рекомендациями
    """
    t = context.temperature
    location = context.location

    recommendations = []
    required_items = []

    if location == "Outdoor":
        if t < TEMP_VERY_COLD:
            recommendations.append("Очень холодно! Оденьтесь максимально тепло.")
            required_items.extend(["куртка", "теплые брюки", "ботинки", "шапка", "шарф"])
        elif t < TEMP_COLD:
            recommendations.append("Холодно. Необходима теплая одежда.")
            required_items.extend(["куртка или пальто", "длинные брюки", "закрытая обувь"])
        elif t < TEMP_COOL:
            recommendations.append("Прохладно. Рекомендуется многослойность.")
            required_items.extend(["худи/свитер", "длинные брюки", "закрытая обувь"])
        elif t < TEMP_MODERATE:
            recommendations.append("Умеренная погода. Комфортная одежда.")
        elif t < TEMP_WARM:
            recommendations.append("Тепло. Можно одеться легче.")
        elif t < TEMP_HOT:
            recommendations.append("Жарко. Легкая одежда из дышащих материалов.")
        else:
            recommendations.append("Очень жарко! Минимум одежды, светлые тона.")

    return {
        "temperature": t,
        "comfort_level": _get_comfort_level(t),
        "recommendations": recommendations,
        "required_items": required_items,
    }


def _get_comfort_level(temp: float) -> str:
    """Определить уровень комфорта по температуре."""
    if temp < TEMP_VERY_COLD:
        return "very_cold"
    elif temp < TEMP_COLD:
        return "cold"
    elif temp < TEMP_COOL:
        return "cool"
    elif temp < TEMP_MODERATE:
        return "moderate"
    elif temp < TEMP_WARM:
        return "warm"
    elif temp < TEMP_HOT:
        return "hot"
    else:
        return "very_hot"


# ═══════════════════════════════════════════
# ФИЛЬТРАЦИЯ ПО ПРЕДПОЧТЕНИЯМ ПОЛЬЗОВАТЕЛЯ
# ═══════════════════════════════════════════


def filter_by_budget(
    combinations: List[Dict[str, Optional[Dict[str, Any]]]],
    budget_range: Optional[str],
    item_prices: Optional[Dict[str, float]] = None,
) -> List[Dict[str, Optional[Dict[str, Any]]]]:
    """
    Фильтрация комбинаций по бюджету.

    Args:
        combinations: список комбинаций одежды
        budget_range: диапазон бюджета (economy, medium, premium)
        item_prices: словарь цен предметов {item_id: price}

    Returns:
        Отфильтрованный список комбинаций
    """
    if budget_range is None or item_prices is None:
        return combinations

    # Определяем максимальный бюджет
    budget_limits = {
        "economy": 3000.0,
        "medium": 10000.0,
        "premium": float("inf"),
    }
    max_budget = budget_limits.get(budget_range.lower(), float("inf"))

    filtered = []
    for combo in combinations:
        total_price = 0.0
        items = [combo.get("upper"), combo.get("lower"), combo.get("outerwear"), combo.get("footwear")]

        for item in items:
            if item:
                item_id = item.get("id")
                if item_id and item_id in item_prices:
                    total_price += item_prices[item_id]
                else:
                    # Средняя цена если неизвестна
                    total_price += 2500.0

        if total_price <= max_budget:
            filtered.append(combo)

    return filtered if filtered else combinations  # Fallback


def filter_by_styles(
    combinations: List[Dict[str, Optional[Dict[str, Any]]]],
    style_preferences: Optional[List[str]],
    item_styles: Optional[Dict[str, List[str]]] = None,
) -> List[Dict[str, Optional[Dict[str, Any]]]]:
    """
    Фильтрация комбинаций по стилям.

    Args:
        combinations: список комбинаций
        style_preferences: предпочитаемые стили
        item_styles: стили предметов {item_id: [styles]}

    Returns:
        Отфильтрованный список комбинаций
    """
    if not style_preferences or not item_styles:
        return combinations

    preferred_styles_lower = {s.lower() for s in style_preferences}

    filtered = []
    for combo in combinations:
        items = [combo.get("upper"), combo.get("lower"), combo.get("outerwear"), combo.get("footwear")]
        has_preferred_style = False

        for item in items:
            if item:
                item_id = item.get("id")
                if item_id and item_id in item_styles:
                    item_style_list = item_styles.get(item_id, [])
                    item_styles_lower = {s.lower() for s in item_style_list}
                    if item_styles_lower & preferred_styles_lower:
                        has_preferred_style = True
                        break

        # Оставляем если есть предпочитаемый стиль или нет данных
        if has_preferred_style or not item_styles:
            filtered.append(combo)

    return filtered if filtered else combinations


def filter_by_brands(
    combinations: List[Dict[str, Optional[Dict[str, Any]]]],
    favorite_brands: Optional[List[str]],
    item_brands: Optional[Dict[str, str]] = None,
) -> List[Dict[str, Optional[Dict[str, Any]]]]:
    """
    Сортировка комбинаций по брендам.

    Args:
        combinations: список комбинаций
        favorite_brands: любимые бренды
        item_brands: бренды предметов {item_id: brand}

    Returns:
        Отсортированный список комбинаций
    """
    if not favorite_brands or not item_brands:
        return combinations

    favorite_brands_lower = {b.lower() for b in favorite_brands}

    def brand_score(combo: Dict[str, Optional[Dict[str, Any]]]) -> int:
        items = [combo.get("upper"), combo.get("lower"), combo.get("outerwear"), combo.get("footwear")]
        score = 0
        for item in items:
            if item:
                item_id = item.get("id")
                if item_id and item_id in item_brands:
                    brand = item_brands.get(item_id, "").lower()
                    if brand in favorite_brands_lower:
                        score += 1
        return score

    return sorted(combinations, key=brand_score, reverse=True)


def apply_preferences_filter(
    combinations: List[Dict[str, Optional[Dict[str, Any]]]],
    preferences: Optional[UserPreferences],
    item_prices: Optional[Dict[str, float]] = None,
    item_styles: Optional[Dict[str, List[str]]] = None,
    item_brands: Optional[Dict[str, str]] = None,
) -> List[Dict[str, Optional[Dict[str, Any]]]]:
    """
    Комплексная фильтрация по предпочтениям пользователя.

    Применяет фильтры в порядке:
    1. Бюджет (жёсткий фильтр)
    2. Стили (мягкий фильтр)
    3. Бренды (сортировка)

    Args:
        combinations: список комбинаций
        preferences: предпочтения пользователя
        item_prices: цены предметов
        item_styles: стили предметов
        item_brands: бренды предметов

    Returns:
        Отфильтрованный и отсортированный список
    """
    if not preferences:
        return combinations

    result = combinations

    # 1. Бюджет
    if preferences.budget_range:
        result = filter_by_budget(result, preferences.budget_range, item_prices)

    # 2. Стили
    if preferences.style_preferences:
        result = filter_by_styles(result, preferences.style_preferences, item_styles)

    # 3. Бренды (сортировка)
    if preferences.favorite_brands:
        result = filter_by_brands(result, preferences.favorite_brands, item_brands)

    return result
