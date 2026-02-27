"""
Двухуровневая фильтрация кандидатов перед CatBoost.

Уровень 1: категориальный — убираем невозможные
           категории для данного контекста
Уровень 2: комбинаторный — убираем абсурдные
           ПАРЫ категорий

Пороги обоснованы анализом Season Fashion Dataset.
"""

from dataclasses import dataclass
from itertools import product as cartesian_product
from typing import List, Optional, Set, Tuple, Dict, Any


# ═══════════════════════════════════════════
# КОНСТАНТЫ
# ═══════════════════════════════════════════

ALL_TOPS: List[str] = ["Kaos", "Kemeja", "Blouse", "Jas"]
ALL_BOTTOMS: List[str] = [
    "Celana Panjang",
    "Celana Pendek",
    "Rok",
    "Celana Jogger",
    "Celana Cargo",
]
ALL_OUTERWEAR: List[str] = ["Hoodie", "Jaket", "Tanpa Pakaian Luar"]
ALL_FOOTWEAR: List[str] = [
    "Sneakers",
    "Sepatu Bot",
    "Sandal",
    "Sepatu Formal",
    "Sepatu Olahraga",
]

# Пороги температуры (°C)
TEMP_COLD: float = 15.0
TEMP_COOL: float = 12.0
TEMP_VERY_COLD: float = 10.0
TEMP_HOT: float = 33.0
TEMP_WARM: float = 28.0
TEMP_MODERATE: float = 18.0

# Пороги влажности (%)
HUMIDITY_HIGH: float = 85.0
HUMIDITY_HOT: float = 25.0

# Длительность (часы)
DURATION_LONG: float = 4.0


# ═══════════════════════════════════════════
# УРОВЕНЬ 2: Запрещённые комбинации (пары)
# ═══════════════════════════════════════════

# Стилевые конфликты — абсурд при ЛЮБОЙ погоде
# Формат: (категория1, значение1, категория2, значение2)
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

    ВАЖНО: Функция НЕ мутирует входные множества, а работает с копиями.

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

    # ── Температура + локация ──
    if location == "Outdoor":
        if t < TEMP_COLD:
            bottoms.discard("Celana Pendek")
            footwear.discard("Sandal")

        if t < TEMP_COOL:
            outerwear.discard("Tanpa Pakaian Luar")
            bottoms.discard("Rok")  # юбка в холод outdoor

        if t < TEMP_VERY_COLD:
            # Совсем холодно — только тёплая обувь
            footwear.discard("Sneakers")
            footwear.discard("Sepatu Olahraga")

        if t > TEMP_HOT:
            outerwear.discard("Jaket")
            tops.discard("Jas")
            footwear.discard("Sepatu Bot")

        if t > TEMP_WARM:
            # Тепло — ботинки нелогичны
            footwear.discard("Sepatu Bot")

    elif location == "Indoor":
        if t < TEMP_VERY_COLD:
            # В помещении холодно (нет отопления?)
            footwear.discard("Sandal")

        if t > TEMP_WARM:
            outerwear.discard("Jaket")
            tops.discard("Jas")

    # ── Влажность ──
    if humidity > HUMIDITY_HIGH and t > HUMIDITY_HOT:
        # Очень душно — убираем тяжёлое
        outerwear.discard("Jaket")
        tops.discard("Jas")

    # ── Погода ──
    if weather == "Hujan":
        footwear.discard("Sandal")
        if location == "Outdoor":
            outerwear.discard("Tanpa Pakaian Luar")

    # ── Активность ──
    if activity == "Olahraga":
        tops.discard("Jas")
        tops.discard("Blouse")
        bottoms.discard("Rok")
        footwear.discard("Sepatu Formal")
        footwear.discard("Sepatu Bot")

    elif activity == "Kerja":
        footwear.discard("Sandal")
        footwear.discard("Sepatu Olahraga")
        bottoms.discard("Celana Pendek")
        bottoms.discard("Celana Jogger")
        outerwear.discard("Hoodie")

    elif activity == "Pesta":  # Вечеринка/мероприятие
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

    # Контекстные абсурды (зависят от погоды)
    t = context.temperature

    # Шорты + без куртки при < 18°C outdoor
    if (
        bottom == "Celana Pendek"
        and ow == "Tanpa Pakaian Luar"
        and t < TEMP_MODERATE
        and context.location == "Outdoor"
    ):
        return False

    # Футболка + без куртки при < 12°C outdoor
    if (
        top == "Kaos"
        and ow == "Tanpa Pakaian Luar"
        and t < TEMP_COOL
        and context.location == "Outdoor"
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
        return all_combos

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

    return {
        "total_raw": total_raw,
        "after_level1": after_level1,
        "after_level2": after_level2,
        "level1_reduction": (
            f"{(1 - after_level1 / total_raw) * 100:.0f}%" if total_raw > 0 else "0%"
        ),
        "total_reduction": (
            f"{(1 - after_level2 / total_raw) * 100:.0f}%" if total_raw > 0 else "0%"
        ),
        "categories_after_l1": filtered_cats,
    }
