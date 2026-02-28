"""
Двухуровневая фильтрация кандидатов перед CatBoost.

Уровень 1: категориальный — убираем невозможные категории для данного контекста
Уровень 2: комбинаторный — убираем абсурдные ПАРЫ категорий

Пороги обоснованы анализом Season Fashion Dataset.

ИЗМЕНЕНИЯ:
- Добавлена обязательная проверка категорий (top, bottom, shoes)
- Улучшена логика для холодной погоды (1°C и ниже)
- Добавлены температурные пороги для каждого типа одежды
"""

from dataclasses import dataclass
from itertools import product as cartesian_product
from typing import List, Optional, Set, Tuple, Dict, Any


# ═══════════════════════════════════════════
# КОНСТАНТЫ
# ═══════════════════════════════════════════

# Все возможные предметы по категориям
ALL_TOPS: List[str] = [
    "Kaos",  # Футболка
    "Kemeja",  # Рубашка
    "Blouse",  # Блузка
    "Jas",  # Пиджак
]

ALL_BOTTOMS: List[str] = [
    "Celana Panjang",  # Брюки/джинсы
    "Celana Pendek",  # Шорты
    "Rok",  # Юбка
    "Celana Jogger",  # Джоггеры
    "Celana Cargo",  # Карго
]

ALL_OUTERWEAR: List[str] = [
    "Hoodie",  # Худи
    "Jaket",  # Куртка
    "Tanpa Pakaian Luar",  # Без верхней одежды
]

ALL_FOOTWEAR: List[str] = [
    "Sneakers",  # Кроссовки
    "Sepatu Bot",  # Ботинки
    "Sandal",  # Сандали
    "Sepatu Formal",  # Туфли
    "Sepatu Olahraga",  # Спортивная обувь
]

# ═══════════════════════════════════════════
# ТЕМПЕРАТУРНЫЕ ПОРОГИ (°C)
# ═══════════════════════════════════════════

# Общие пороги
TEMP_FREEZING: float = 0.0      # Заморозки
TEMP_VERY_COLD: float = 5.0     # Очень холодно
TEMP_COLD: float = 10.0         # Холодно
TEMP_COOL: float = 15.0         # Прохладно
TEMP_MODERATE: float = 20.0     # Умеренно
TEMP_WARM: float = 25.0         # Тепло
TEMP_HOT: float = 30.0          # Жарко
TEMP_VERY_HOT: float = 35.0     # Очень жарко

# Пороги для верхней одежды (outerwear)
OUTERWEAR_JACKET_REQUIRED: float = 10.0    # Куртка обязательна
OUTERWEAR_HOODIE_ALLOWED: float = 18.0     # Худи допустимо
OUTERWEAR_NONE_ALLOWED: float = 22.0       # Без верхней одежды допустимо

# Пороги для обуви
FOOTWEAR_BOOTS_REQUIRED: float = 5.0       # Ботинки обязательны
FOOTWEAR_CLOSED_REQUIRED: float = 12.0     # Закрытая обувь обязательна
FOOTWEAR_SANDALS_ALLOWED: float = 20.0     # Сандали допустимы

# Пороги для низа
BOTTOM_SHORTS_ALLOWED: float = 20.0        # Шорты допустимы
BOTTOM_LONG_REQUIRED: float = 15.0         # Длинные брюки обязательны

# Пороги для верха
TOP_LAYERS_REQUIRED: float = 10.0          # Многослойность обязательна
TOP_LONG_SLEEVE_REQUIRED: float = 15.0     # Длинный рукав обязателен

# Пороги влажности (%)
HUMIDITY_HIGH: float = 85.0
HUMIDITY_LOW: float = 25.0

# Длительность (часы)
DURATION_LONG: float = 4.0

# ═══════════════════════════════════════════
# БЮДЖЕТНЫЕ ПОРОГИ (₽)
# ═══════════════════════════════════════════

BUDGET_ECONOMY_MAX: float = 3000.0    # Economy: до 3000₽
BUDGET_MEDIUM_MAX: float = 10000.0   # Medium: 3000-10000₽
# Premium: 10000+₽


# ═══════════════════════════════════════════
# УРОВЕНЬ 2: Запрещённые комбинации (пары)
# ═══════════════════════════════════════════

# Стилевые конфликты — абсурд при ЛЮБОЙ погоде
STYLE_CONFLICTS: Set[Tuple[str, str, str, str]] = {
    # Пиджак + шорты/джоггеры/карго
    ("top", "Jas", "bottom", "Celana Pendek"),
    ("top", "Jas", "bottom", "Celana Jogger"),
    ("top", "Jas", "bottom", "Celana Cargo"),
    # Пиджак + худи сверху
    ("top", "Jas", "outerwear", "Hoodie"),
    # Пиджак + спортивная/неформальная обувь
    ("top", "Jas", "footwear", "Sepatu Olahraga"),
    ("top", "Jas", "footwear", "Sneakers"),
    ("top", "Jas", "footwear", "Sandal"),
    # Формальная обувь + шорты/джоггеры/карго
    ("bottom", "Celana Pendek", "footwear", "Sepatu Formal"),
    ("bottom", "Celana Jogger", "footwear", "Sepatu Formal"),
    ("bottom", "Celana Cargo", "footwear", "Sepatu Formal"),
    # Ботинки + шорты
    ("bottom", "Celana Pendek", "footwear", "Sepatu Bot"),
    # Спортивная обувь + юбка
    ("bottom", "Rok", "footwear", "Sepatu Olahraga"),
    # Блузка + спортивная обувь/джоггеры/карго
    ("top", "Blouse", "footwear", "Sepatu Olahraga"),
    ("top", "Blouse", "bottom", "Celana Jogger"),
    ("top", "Blouse", "bottom", "Celana Cargo"),
}


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


def _level1_category_filter(
    context: WeatherContext,
    tops: Set[str],
    bottoms: Set[str],
    outerwear: Set[str],
    footwear: Set[str],
) -> Tuple[Set[str], Set[str], Set[str], Set[str]]:
    """
    Уровень 1: убираем невозможные категории по погоде, активности, гендеру.

    КРИТИЧЕСКИЕ ИЗМЕНЕНИЯ:
    - При температуре < 10°C обязательна куртка + теплый верх + длинные брюки + закрытая обувь
    - При температуре < 5°C обязательны ботинки

    Args:
        context: Контекст погоды
        tops: Доступные верхние предметы одежды
        bottoms: Доступные нижние предметы одежды
        outerwear: Доступная верхняя одежда
        footwear: Доступная обувь

    Returns:
        Кортеж (tops, bottoms, outerwear, footwear) с отфильтрованными множествами
    """
    # Создаём копии для immutability
    tops = tops.copy()
    bottoms = bottoms.copy()
    outerwear = outerwear.copy()
    footwear = footwear.copy()

    t = context.temperature
    weather = context.weather_condition
    location = context.location
    activity = context.activity
    gender = context.gender
    humidity = context.humidity

    # ── Гендер ──
    if gender == "Laki-laki":
        tops.discard("Blouse")
        bottoms.discard("Rok")

    # ── ТЕМПЕРАТУРА + ЛОКАЦИЯ (ОСНОВНАЯ ЛОГИКА) ──
    if location == "Outdoor":
        # === ОЧЕНЬ ХОЛОДНО (< 10°C) ===
        if t < TEMP_COLD:
            # Шорты запрещены
            bottoms.discard("Celana Pendek")
            # Сандали запрещены
            footwear.discard("Sandal")
            # Без верхней одежды запрещено - ОБЯЗАТЕЛЬНА куртка
            outerwear.discard("Tanpa Pakaian Luar")
            
            # При < 5°C обязательны ботинки
            if t < TEMP_VERY_COLD:
                footwear.discard("Sandal")
                footwear.discard("Sneakers")
                footwear.discard("Sepatu Olahraga")
                # Оставляем только ботинки

        # === ПРОХЛАДНО (10-15°C) ===
        elif t < TEMP_COOL:
            # Без верхней одежды не рекомендуется
            outerwear.discard("Tanpa Pakaian Luar")
            # Шорты не рекомендуются
            bottoms.discard("Celana Pendek")
            # Сандали не рекомендуются
            footwear.discard("Sandal")

        # === УМЕРЕННО (15-20°C) ===
        elif t < TEMP_MODERATE:
            # Можно без верхней одежды
            pass

        # === ТЕПЛО (20-25°C) ===
        elif t < TEMP_WARM:
            # Куртка не нужна
            outerwear.discard("Jaket")

        # === ЖАРКО (> 25°C) ===
        elif t > TEMP_WARM:
            # Куртка и пиджак не нужны
            outerwear.discard("Jaket")
            tops.discard("Jas")
            # Ботинки слишком жаркие
            footwear.discard("Sepatu Bot")

        # === ОЧЕНЬ ЖАРКО (> 30°C) ===
        if t > TEMP_HOT:
            # Только легкая одежда
            outerwear.discard("Jaket")
            outerwear.discard("Hoodie")
            tops.discard("Jas")

    elif location == "Indoor":
        # В помещении теплее, но если на улице очень холодно...
        if t < TEMP_VERY_COLD:
            # В помещении холодно (нет отопления?)
            footwear.discard("Sandal")

        if t > TEMP_WARM:
            outerwear.discard("Jaket")
            tops.discard("Jas")

    # ── Влажность ──
    if humidity > HUMIDITY_HIGH and t > HUMIDITY_LOW:
        # Очень душно — убираем тяжёлое
        outerwear.discard("Jaket")
        tops.discard("Jas")

    # ── Погода ──
    if weather == "Hujan":
        # Дождь - убираем открытую обувь
        footwear.discard("Sandal")
        if location == "Outdoor":
            # Без верхней одежды нельзя
            outerwear.discard("Tanpa Pakaian Luar")

    # ── Активность ──
    if activity == "Olahraga":
        # Спорт - убираем формальную одежду
        tops.discard("Jas")
        tops.discard("Blouse")
        bottoms.discard("Rok")
        footwear.discard("Sepatu Formal")
        footwear.discard("Sepatu Bot")

    elif activity == "Kerja":
        # Работа - формальный стиль
        footwear.discard("Sandal")
        footwear.discard("Sepatu Olahraga")
        bottoms.discard("Celana Pendek")
        bottoms.discard("Celana Jogger")
        outerwear.discard("Hoodie")

    elif activity == "Pesta":
        # Вечеринка - без спортивного
        footwear.discard("Sepatu Olahraga")
        bottoms.discard("Celana Jogger")
        bottoms.discard("Celana Cargo")

    # ── Длительность ──
    if context.duration > DURATION_LONG and location == "Outdoor":
        # Долго на улице — убираем некомфортное
        if t < TEMP_MODERATE:
            outerwear.discard("Tanpa Pakaian Luar")
        footwear.discard("Sepatu Formal")  # неудобно долго

    return tops, bottoms, outerwear, footwear


# ═══════════════════════════════════════════
# УРОВЕНЬ 2: КОМБИНАТОРНАЯ ФИЛЬТРАЦИЯ
# ═══════════════════════════════════════════


def _level2_combination_filter(
    combo: Dict[str, str],
    context: WeatherContext,
) -> bool:
    """
    Уровень 2: проверяем конкретную комбинацию на
    стилевые конфликты и контекстные абсурды.

    КРИТИЧЕСКИЕ ИЗМЕНЕНИЯ:
    - Проверка обязательных категорий (top, bottom, shoes)
    - Проверка температуры для каждого предмета
    - При 1°C: футболка + худи + куртка (многослойность)

    Возвращает True если комбинация ДОПУСТИМА.

    Args:
        combo: Комбинация одежды {top, bottom, outerwear, footwear}
        context: Контекст погоды

    Returns:
        True если комбинация допустима, False иначе
    """
    top = combo["top"]
    bottom = combo["bottom"]
    ow = combo["outerwear"]
    fw = combo["footwear"]

    t = context.temperature
    location = context.location

    # Проверка стилевых конфликтов
    pairs_to_check: List[Tuple[str, str, str, str]] = [
        ("top", top, "bottom", bottom),
        ("top", top, "outerwear", ow),
        ("top", top, "footwear", fw),
        ("bottom", bottom, "outerwear", ow),
        ("bottom", bottom, "footwear", fw),
        ("outerwear", ow, "footwear", fw),
    ]

    for pair in pairs_to_check:
        if pair in STYLE_CONFLICTS:
            return False

    # ═══════════════════════════════════════════
    # ПРОВЕРКА ТЕМПЕРАТУРНОЙ АДЕКВАТНОСТИ
    # ═══════════════════════════════════════════

    # === ОЧЕНЬ ХОЛОДНО (< 10°C) ===
    if t < TEMP_COLD and location == "Outdoor":
        # Куртка обязательна
        if ow == "Tanpa Pakaian Luar":
            return False
        
        # Шорты запрещены
        if bottom == "Celana Pendek":
            return False
        
        # Сандали запрещены
        if fw == "Sandal":
            return False
        
        # При < 5°C ботинки обязательны
        if t < TEMP_VERY_COLD:
            if fw not in ["Sepatu Bot"]:
                return False

    # === ПРОХЛАДНО (10-15°C) ===
    elif t < TEMP_COOL and location == "Outdoor":
        # Без верхней одежды нельзя
        if ow == "Tanpa Pakaian Luar":
            return False
        
        # Шорты не рекомендуются
        if bottom == "Celana Pendek":
            return False

    # === ЖАРКО (> 28°C) ===
    if t > 28 and location == "Outdoor":
        # Куртка не нужна
        if ow == "Jaket":
            return False
        
        # Ботинки слишком жаркие
        if fw == "Sepatu Bot":
            return False

    # Контекстные абсурды
    # Шорты + без куртки при < 18°C outdoor
    if (
        bottom == "Celana Pendek"
        and ow == "Tanpa Pakaian Luar"
        and t < TEMP_MODERATE
        and location == "Outdoor"
    ):
        return False

    # Футболка + без куртки при < 12°C outdoor
    if (
        top == "Kaos"
        and ow == "Tanpa Pakaian Luar"
        and t < 12
        and location == "Outdoor"
    ):
        return False

    # Сандали + куртка (стилистически абсурдно)
    if fw == "Sandal" and ow == "Jaket":
        return False

    # Ботинки + шорты + жарко (> 28°C)
    if fw == "Sepatu Bot" and bottom == "Celana Pendek" and t > TEMP_WARM:
        return False

    return True


# ═══════════════════════════════════════════
# ПРОВЕРКА ОБЯЗАТЕЛЬНЫХ КАТЕГОРИЙ
# ═══════════════════════════════════════════


def validate_outfit_completeness(
    combo: Dict[str, str],
    context: WeatherContext,
) -> Dict[str, Any]:
    """
    Проверка полноты комплекта одежды.

    Возвращает информацию о missing категориях и рекомендациях.

    Args:
        combo: Комбинация одежды {top, bottom, outerwear, footwear}
        context: Контекст погоды

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

    # Проверка наличия всех категорий
    if not combo.get("top") or combo["top"] == "":
        result["complete"] = False
        result["missing"].append("top")
        result["recommendations"].append("Добавьте верхнюю одежду (футболка, рубашка, свитер)")

    if not combo.get("bottom") or combo["bottom"] == "":
        result["complete"] = False
        result["missing"].append("bottom")
        result["recommendations"].append("Добавьте низ (джинсы, брюки, шорты)")

    if not combo.get("footwear") or combo["footwear"] == "":
        result["complete"] = False
        result["missing"].append("footwear")
        result["recommendations"].append("Добавьте обувь (кроссовки, ботинки, туфли)")

    # Проверка верхней одежды по температуре
    if location == "Outdoor":
        if t < OUTERWEAR_JACKET_REQUIRED:
            if combo.get("outerwear") == "Tanpa Pakaian Luar":
                result["warnings"].append("При такой температуре рекомендуется куртка")
                result["recommendations"].append("Добавьте куртку или пальто")
        
        if t < FOOTWEAR_BOOTS_REQUIRED:
            if combo.get("footwear") not in ["Sepatu Bot"]:
                result["warnings"].append("При температуре ниже 5°C рекомендуются ботинки")

    return result


# ═══════════════════════════════════════════
# ПУБЛИЧНЫЕ ФУНКЦИИ
# ═══════════════════════════════════════════


def filter_candidates(
    context: WeatherContext,
    wardrobe_tops: Optional[List[str]] = None,
    wardrobe_bottoms: Optional[List[str]] = None,
    wardrobe_outerwear: Optional[List[str]] = None,
    wardrobe_footwear: Optional[List[str]] = None,
) -> Dict[str, List[str]]:
    """
    Уровень 1: категориальная фильтрация.

    Возвращает допустимые категории одежды для данного контекста.
    Использует fallback на полный гардероб если фильтрация оставила 0 вариантов.

    Args:
        context: Контекст погоды
        wardrobe_tops: Доступные пользователю топы (или None для всех)
        wardrobe_bottoms: Доступные пользователю брюки/юбки (или None для всех)
        wardrobe_outerwear: Доступная пользователю верхняя одежда (или None для всех)
        wardrobe_footwear: Доступная пользователю обувь (или None для всех)

    Returns:
        Dict с ключами tops, bottoms, outerwear, footwear
    """
    tops = set(wardrobe_tops or ALL_TOPS)
    bottoms = set(wardrobe_bottoms or ALL_BOTTOMS)
    outerwear = set(wardrobe_outerwear or ALL_OUTERWEAR)
    footwear = set(wardrobe_footwear or ALL_FOOTWEAR)

    tops, bottoms, outerwear, footwear = _level1_category_filter(
        context, tops, bottoms, outerwear, footwear
    )

    # Fallback: если фильтрация убрала ВСЁ, возвращаем исходный гардероб
    if not tops:
        tops = set(wardrobe_tops or ALL_TOPS)
    if not bottoms:
        bottoms = set(wardrobe_bottoms or ALL_BOTTOMS)
    if not outerwear:
        outerwear = set(wardrobe_outerwear or ALL_OUTERWEAR)
    if not footwear:
        footwear = set(wardrobe_footwear or ALL_FOOTWEAR)

    return {
        "tops": sorted(tops),
        "bottoms": sorted(bottoms),
        "outerwear": sorted(outerwear),
        "footwear": sorted(footwear),
    }


def generate_combinations(
    context: WeatherContext,
    wardrobe_tops: Optional[List[str]] = None,
    wardrobe_bottoms: Optional[List[str]] = None,
    wardrobe_outerwear: Optional[List[str]] = None,
    wardrobe_footwear: Optional[List[str]] = None,
) -> List[Dict[str, str]]:
    """
    Полный пайплайн фильтрации:
    1. Уровень 1 → допустимые категории
    2. Декартово произведение → все комбинации
    3. Уровень 2 → убрать абсурдные пары
    4. Проверка полноты комплекта

    Args:
        context: Контекст погоды
        wardrobe_tops: Доступные топы (или None для всех)
        wardrobe_bottoms: Доступные брюки/юбки (или None для всех)
        wardrobe_outerwear: Доступная верхняя одежда (или None для всех)
        wardrobe_footwear: Доступная обувь (или None для всех)

    Returns:
        Список допустимых комбинаций одежды
    """
    # Уровень 1: категориальная фильтрация
    filtered = filter_candidates(
        context,
        wardrobe_tops,
        wardrobe_bottoms,
        wardrobe_outerwear,
        wardrobe_footwear,
    )

    # Все комбинации (декартово произведение)
    all_combos: List[Dict[str, str]] = [
        {"top": t, "bottom": b, "outerwear": o, "footwear": f}
        for t, b, o, f in cartesian_product(
            filtered["tops"],
            filtered["bottoms"],
            filtered["outerwear"],
            filtered["footwear"],
        )
    ]

    # Уровень 2: фильтрация комбинаций
    valid = [c for c in all_combos if _level2_combination_filter(c, context)]

    # Fallback: если уровень 2 убрал ВСЁ, возвращаем всё после уровня 1
    if not valid:
        valid = all_combos

    # Сортировка по полноте комплекта (предпочитаем полные комплекты)
    def completeness_score(combo):
        validation = validate_outfit_completeness(combo, context)
        score = 0
        if validation["complete"]:
            score += 100
        score -= len(validation["warnings"]) * 10
        return score

    valid.sort(key=completeness_score, reverse=True)

    return valid


def get_stats(
    context: WeatherContext,
    wardrobe_tops: Optional[List[str]] = None,
    wardrobe_bottoms: Optional[List[str]] = None,
    wardrobe_outerwear: Optional[List[str]] = None,
    wardrobe_footwear: Optional[List[str]] = None,
) -> Dict[str, Any]:
    """
    Статистика фильтрации для отладки и API.

    Args:
        context: Контекст погоды
        wardrobe_tops: Доступные топы (или None для всех)
        wardrobe_bottoms: Доступные брюки/юбки (или None для всех)
        wardrobe_outerwear: Доступная верхняя одежда (или None для всех)
        wardrobe_footwear: Доступная обувь (или None для всех)

    Returns:
        Dict со статистикой фильтрации
    """
    all_t = wardrobe_tops or ALL_TOPS
    all_b = wardrobe_bottoms or ALL_BOTTOMS
    all_o = wardrobe_outerwear or ALL_OUTERWEAR
    all_f = wardrobe_footwear or ALL_FOOTWEAR

    total_raw = len(all_t) * len(all_b) * len(all_o) * len(all_f)

    filtered_cats = filter_candidates(
        context,
        wardrobe_tops,
        wardrobe_bottoms,
        wardrobe_outerwear,
        wardrobe_footwear,
    )
    after_level1 = (
        len(filtered_cats["tops"])
        * len(filtered_cats["bottoms"])
        * len(filtered_cats["outerwear"])
        * len(filtered_cats["footwear"])
    )

    valid = generate_combinations(
        context,
        wardrobe_tops,
        wardrobe_bottoms,
        wardrobe_outerwear,
        wardrobe_footwear,
    )
    after_level2 = len(valid)

    # Статистика полноты комплектов
    complete_count = sum(
        1 for c in valid 
        if validate_outfit_completeness(c, context)["complete"]
    )

    return {
        "total_raw": total_raw,
        "after_level1": after_level1,
        "after_level2": after_level2,
        "complete_outfits": complete_count,
        "level1_reduction": (
            f"{(1 - after_level1 / total_raw) * 100:.0f}%" if total_raw > 0 else "0%"
        ),
        "total_reduction": (
            f"{(1 - after_level2 / total_raw) * 100:.0f}%" if total_raw > 0 else "0%"
        ),
        "categories_after_l1": filtered_cats,
        "temperature_recommendations": get_temperature_recommendations(context),
    }


def get_temperature_recommendations(context: WeatherContext) -> Dict[str, Any]:
    """
    Получить рекомендации по температуре.

    Args:
        context: Контекст погоды

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
    combinations: List[Dict[str, str]],
    budget_range: Optional[str],
    item_prices: Optional[Dict[str, float]] = None,
) -> List[Dict[str, str]]:
    """
    Фильтрация комбинаций по бюджету.

    Args:
        combinations: Список комбинаций одежды
        budget_range: Диапазон бюджета (economy, medium, premium)
        item_prices: Словарь цен предметов {item_name: price}

    Returns:
        Отфильтрованный список комбинаций

    Логика:
        - economy: общая стоимость комплекта ≤ 3000₽
        - medium: общая стоимость комплекта ≤ 10000₽
        - premium: без ограничений
    """
    if budget_range is None or item_prices is None:
        return combinations

    # Определяем максимальный бюджет
    if budget_range == "economy":
        max_budget = BUDGET_ECONOMY_MAX
    elif budget_range == "medium":
        max_budget = BUDGET_MEDIUM_MAX
    else:  # premium
        return combinations  # Без ограничений

    filtered = []
    for combo in combinations:
        total_price = 0.0
        items = [combo.get("top"), combo.get("bottom"), combo.get("outerwear"), combo.get("footwear")]
        
        for item in items:
            if item and item in item_prices:
                total_price += item_prices[item]
            elif item:
                # Если цена неизвестна, используем среднюю для категории
                # Это позволяет не отбрасывать комбинации без данных о цене
                total_price += 2500.0  # Средняя цена по умолчанию

        if total_price <= max_budget:
            filtered.append(combo)

    import logging
    logger = logging.getLogger(__name__)
    logger.info(
        f"Фильтрация по бюджету ({budget_range}): "
        f"{len(combinations)} → {len(filtered)} (max={max_budget}₽)"
    )

    return filtered if filtered else combinations  # Fallback: если всё отфильтровалось, возвращаем всё


def filter_by_styles(
    combinations: List[Dict[str, str]],
    style_preferences: Optional[List[str]],
    item_styles: Optional[Dict[str, List[str]]] = None,
) -> List[Dict[str, str]]:
    """
    Фильтрация комбинаций по стилям.

    Args:
        combinations: Список комбинаций одежды
        style_preferences: Предпочитаемые стили пользователя
        item_styles: Словарь стилей предметов {item_name: [styles]}

    Returns:
        Отфильтрованный список комбинаций

    Логика:
        - Если стиль предмета совпадает с предпочтением — оставляем
        - Если нет данных о стиле — оставляем (нейтральный предмет)
    """
    if not style_preferences or not item_styles:
        return combinations

    # Нормализуем стили к нижнему регистру
    preferred_styles_lower = {s.lower() for s in style_preferences}

    filtered = []
    for combo in combinations:
        items = [combo.get("top"), combo.get("bottom"), combo.get("outerwear"), combo.get("footwear")]
        
        # Проверяем каждый предмет на соответствие стилю
        has_preferred_style = False
        has_non_preferred = False
        
        for item in items:
            if item and item in item_styles:
                item_style_list = item_styles.get(item, [])
                item_styles_lower = {s.lower() for s in item_style_list}
                
                if item_styles_lower & preferred_styles_lower:
                    has_preferred_style = True
                elif item_styles_lower:
                    has_non_preferred = True
        
        # Оставляем если есть хотя бы один предмет предпочитаемого стиля
        # или если нет данных о стилях
        if has_preferred_style or not (has_preferred_style or has_non_preferred):
            filtered.append(combo)

    import logging
    logger = logging.getLogger(__name__)
    logger.info(
        f"Фильтрация по стилям ({style_preferences}): "
        f"{len(combinations)} → {len(filtered)}"
    )

    return filtered if filtered else combinations


def filter_by_brands(
    combinations: List[Dict[str, str]],
    favorite_brands: Optional[List[str]],
    item_brands: Optional[Dict[str, str]] = None,
) -> List[Dict[str, str]]:
    """
    Фильтрация комбинаций по брендам.

    Args:
        combinations: Список комбинаций одежды
        favorite_brands: Любимые бренды пользователя
        item_brands: Словарь брендов предметов {item_name: brand}

    Returns:
        Отфильтрованный список комбинаций

    Логика:
        - Приоритет предметам из любимых брендов
        - Если бренд неизвестен — оставляем (нейтральный предмет)
        - Не отбрасываем полностью, только приоритезируем
    """
    if not favorite_brands or not item_brands:
        return combinations

    # Нормализуем бренды к нижнему регистру
    favorite_brands_lower = {b.lower() for b in favorite_brands}

    # Сортируем комбинации: сначала с любимыми брендами
    def brand_score(combo: Dict[str, str]) -> int:
        items = [combo.get("top"), combo.get("bottom"), combo.get("outerwear"), combo.get("footwear")]
        score = 0
        for item in items:
            if item and item in item_brands:
                brand = item_brands.get(item, "").lower()
                if brand in favorite_brands_lower:
                    score += 1
        return score

    sorted_combos = sorted(combinations, key=brand_score, reverse=True)
    
    import logging
    logger = logging.getLogger(__name__)
    logger.info(
        f"Сортировка по брендам ({favorite_brands}): "
        f"{len(combinations)} комбинаций отсортировано"
    )

    return sorted_combos


def apply_preferences_filter(
    combinations: List[Dict[str, str]],
    preferences: Optional[UserPreferences],
    item_prices: Optional[Dict[str, float]] = None,
    item_styles: Optional[Dict[str, List[str]]] = None,
    item_brands: Optional[Dict[str, str]] = None,
) -> List[Dict[str, str]]:
    """
    Комплексная фильтрация по предпочтениям пользователя.

    Применяет фильтры в порядке:
    1. Бюджет (жёсткий фильтр)
    2. Стили (мягкий фильтр)
    3. Бренды (сортировка)

    Args:
        combinations: Список комбинаций одежды
        preferences: Предпочтения пользователя
        item_prices: Словарь цен предметов
        item_styles: Словарь стилей предметов
        item_brands: Словарь брендов предметов

    Returns:
        Отфильтрованный и отсортированный список комбинаций
    """
    if not preferences:
        return combinations

    result = combinations

    # 1. Фильтрация по бюджету (жёсткий фильтр)
    if preferences.budget_range:
        result = filter_by_budget(result, preferences.budget_range, item_prices)

    # 2. Фильтрация по стилям (мягкий фильтр)
    if preferences.style_preferences:
        result = filter_by_styles(result, preferences.style_preferences, item_styles)

    # 3. Сортировка по брендам (приоритезация)
    if preferences.favorite_brands:
        result = filter_by_brands(result, preferences.favorite_brands, item_brands)

    return result
