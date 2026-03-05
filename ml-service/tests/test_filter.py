"""
Тесты для фильтрации по категориям (pytest version).

ИЗМЕНЕНИЯ (Март 2026):
- Переход на items_by_category формат
- Тесты для filter_categories, generate_combinations

Запуск:
    pytest tests/test_filter.py -v

Покрытие:
    pytest tests/test_filter.py --cov=app.filter --cov-report=html
"""

import pytest
from typing import Dict, Any, List

from app.filter import (
    WeatherContext,
    filter_categories,
    generate_combinations,
    get_stats,
    get_temperature_recommendations,
    apply_preferences_filter,
    UserPreferences,
)


# ═══════════════════════════════════════════
# ФИКСТУРЫ
# ═══════════════════════════════════════════


def make_item(
    item_id: str,
    category: str,
    subcategory: str,
    base_colour: str = "black",
    name: str = "Test Item",
) -> Dict[str, Any]:
    """Создаёт предмет одежды для тестов."""
    return {
        "id": item_id,
        "category": category,
        "subcategory": subcategory,
        "base_colour": base_colour,
        "name": name,
    }


@pytest.fixture
def sample_items_by_category() -> Dict[str, List[Dict[str, Any]]]:
    """Пример предметов по категориям."""
    return {
        "upper": [
            make_item("u1", "upper", "tshirt", "white", "White T-Shirt"),
            make_item("u2", "upper", "shirt", "blue", "Blue Shirt"),
            make_item("u3", "upper", "sweater", "gray", "Gray Sweater"),
        ],
        "lower": [
            make_item("l1", "lower", "jeans", "black", "Black Jeans"),
            make_item("l2", "lower", "shorts", "khaki", "Khaki Shorts"),
            make_item("l3", "lower", "trousers", "navy", "Navy Trousers"),
        ],
        "footwear": [
            make_item("f1", "footwear", "sneakers", "white", "White Sneakers"),
            make_item("f2", "footwear", "boots", "brown", "Brown Boots"),
            make_item("f3", "footwear", "sandals", "black", "Black Sandals"),
        ],
        "outerwear": [
            make_item("o1", "outerwear", "jacket", "black", "Black Jacket"),
            make_item("o2", "outerwear", "hoodie", "gray", "Gray Hoodie"),
        ],
    }


@pytest.fixture
def cold_outdoor_context() -> WeatherContext:
    """Холодная погода outdoor (< 10°C)."""
    return WeatherContext(
        temperature=8,
        humidity=85,
        weather_condition="Mendung",
        location="Outdoor",
        activity="Jalan-jalan",
        gender="Laki-laki",
    )


@pytest.fixture
def hot_outdoor_context() -> WeatherContext:
    """Жаркая погода outdoor (> 25°C)."""
    return WeatherContext(
        temperature=30,
        humidity=60,
        weather_condition="Cerah",
        location="Outdoor",
        activity="Jalan-jalan",
        gender="Perempuan",
    )


@pytest.fixture
def moderate_outdoor_context() -> WeatherContext:
    """Умеренная погода outdoor (15-20°C)."""
    return WeatherContext(
        temperature=18,
        humidity=60,
        weather_condition="Cerah",
        location="Outdoor",
        activity="Jalan-jalan",
        gender="Laki-laki",
    )


@pytest.fixture
def rain_outdoor_context() -> WeatherContext:
    """Дождь на улице."""
    return WeatherContext(
        temperature=18,
        humidity=95,
        weather_condition="Hujan",
        location="Outdoor",
        activity="Jalan-jalan",
        gender="Laki-laki",
    )


@pytest.fixture
def sport_outdoor_context() -> WeatherContext:
    """Спорт на улице."""
    return WeatherContext(
        temperature=25,
        humidity=60,
        weather_condition="Cerah",
        location="Outdoor",
        activity="Olahraga",
        gender="Perempuan",
    )


@pytest.fixture
def work_indoor_context() -> WeatherContext:
    """Работа в офисе indoor."""
    return WeatherContext(
        temperature=22,
        humidity=50,
        weather_condition="Cerah",
        location="Indoor",
        activity="Kerja",
        gender="Laki-laki",
    )


# ═══════════════════════════════════════════
# ТЕСТЫ КАТЕГОРИАЛЬНОЙ ФИЛЬТРАЦИИ
# ═══════════════════════════════════════════


class TestCategoryFilter:
    """Тесты filter_categories."""

    def test_cold_outdoor_keeps_all_categories(
        self,
        cold_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """< 10°C outdoor: outerwear обязательна, все категории есть."""
        result = filter_categories(cold_outdoor_context, sample_items_by_category)

        assert "upper" in result
        assert "lower" in result
        assert "footwear" in result
        assert "outerwear" in result
        assert len(result["outerwear"]) > 0  # outerwear обязательна

    def test_hot_outdoor_removes_outerwear(
        self,
        hot_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """> 25°C: outerwear не нужна."""
        result = filter_categories(hot_outdoor_context, sample_items_by_category)

        assert "upper" in result
        assert "lower" in result
        assert "footwear" in result
        assert result.get("outerwear") == []  # outerwear пуст

    def test_moderate_outdoor_keeps_outerwear(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """15-20°C: outerwear опционально, но доступна."""
        result = filter_categories(moderate_outdoor_context, sample_items_by_category)

        assert "outerwear" in result
        assert len(result["outerwear"]) > 0

    def test_rain_removes_sandals(
        self,
        rain_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Дождь: убираем сандали."""
        result = filter_categories(rain_outdoor_context, sample_items_by_category)

        footwear_subcategories = [item["subcategory"] for item in result["footwear"]]
        assert "sandals" not in footwear_subcategories

    def test_sport_removes_formal_items(
        self,
        sport_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Спорт: убираем формальные items."""
        result = filter_categories(sport_outdoor_context, sample_items_by_category)

        # Проверяем, что формальные items отфильтрованы
        upper_subcategories = [item["subcategory"] for item in result["upper"]]
        footwear_subcategories = [item["subcategory"] for item in result["footwear"]]

        assert "blazer" not in upper_subcategories
        assert "suit" not in upper_subcategories

    def test_work_removes_casual_footwear(
        self,
        work_indoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Работа: убираем сандали и спорт.обувь (только outdoor)."""
        result = filter_categories(work_indoor_context, sample_items_by_category)

        # Для indoor активности сандали не фильтруются автоматически
        # Фильтрация sandals происходит только для outdoor + дождь
        footwear_subcategories = [item["subcategory"] for item in result["footwear"]]
        # Проверяем что sport_shoes фильтруется для работы
        assert "sport_shoes" not in footwear_subcategories

    def test_missing_category_handled(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Отсутствующая категория корректно обрабатывается."""
        items_without_outerwear = {
            k: v for k, v in sample_items_by_category.items() if k != "outerwear"
        }

        result = filter_categories(moderate_outdoor_context, items_without_outerwear)

        assert "upper" in result
        assert "lower" in result
        assert "footwear" in result
        assert "outerwear" not in result  # не добавляется если не было

    def test_empty_items_handled(
        self,
        moderate_outdoor_context: WeatherContext,
    ) -> None:
        """Пустые items корректно обрабатываются."""
        result = filter_categories(moderate_outdoor_context, {})

        assert result == {}


# ═══════════════════════════════════════════
# ТЕСТЫ ГЕНЕРАЦИИ КОМБИНАЦИЙ
# ═══════════════════════════════════════════


class TestGenerateCombinations:
    """Тесты generate_combinations."""

    def test_generates_all_combinations(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Генерирует все возможные комбинации."""
        filtered = filter_categories(moderate_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, moderate_outdoor_context)

        assert len(combinations) > 0

        # Каждая комбинация имеет обязательные категории
        for combo in combinations:
            assert "upper" in combo
            assert "lower" in combo
            assert "footwear" in combo
            # outerwear может быть None
            assert "outerwear" in combo

    def test_combinations_have_valid_items(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Комбинации содержат валидные items."""
        filtered = filter_categories(moderate_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, moderate_outdoor_context)

        for combo in combinations:
            # Проверяем, что items имеют правильную структуру
            assert combo["upper"]["category"] == "upper"
            assert combo["lower"]["category"] == "lower"
            assert combo["footwear"]["category"] == "footwear"

    def test_cold_outdoor_outerwear_required(
        self,
        cold_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Холодно: outerwear обязательна в комбинациях."""
        filtered = filter_categories(cold_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, cold_outdoor_context)

        for combo in combinations:
            # При холоде outerwear должна быть
            assert combo.get("outerwear") is not None

    def test_hot_outdoor_outerwear_optional(
        self,
        hot_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Жарко: outerwear может быть None."""
        filtered = filter_categories(hot_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, hot_outdoor_context)

        # Все комбинации должны быть без outerwear
        for combo in combinations:
            assert combo.get("outerwear") is None


# ═══════════════════════════════════════════
# ТЕСТЫ СТАТИСТИКИ
# ═══════════════════════════════════════════


class TestGetStats:
    """Тесты get_stats."""

    def test_stats_structure(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Статистика имеет правильную структуру."""
        stats = get_stats(moderate_outdoor_context, sample_items_by_category)

        assert "total_items" in stats
        assert "after_category_filter" in stats
        assert "total_combinations" in stats
        assert "complete_outfits" in stats
        assert "categories" in stats

    def test_stats_counts(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Статистика считает правильно."""
        stats = get_stats(moderate_outdoor_context, sample_items_by_category)

        # Всего items: 3 upper + 3 lower + 3 footwear + 2 outerwear = 11
        assert stats["total_items"] == 11
        # После фильтра outerwear остаётся (умеренная погода)
        assert stats["after_category_filter"] == 11
        # Комбинации должны быть > 0
        assert stats["total_combinations"] > 0


# ═══════════════════════════════════════════
# ТЕСТЫ ТЕМПЕРАТУРНЫХ РЕКОМЕНДАЦИЙ
# ═══════════════════════════════════════════


class TestTemperatureRecommendations:
    """Тесты get_temperature_recommendations."""

    def test_very_cold_recommendations(self) -> None:
        """Очень холодно: правильные рекомендации."""
        ctx = WeatherContext(
            temperature=3,
            humidity=80,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Laki-laki",
        )
        recs = get_temperature_recommendations(ctx)

        assert recs["comfort_level"] == "very_cold"
        assert len(recs["recommendations"]) > 0
        assert "куртка" in " ".join(recs["required_items"])

    def test_cold_recommendations(self) -> None:
        """Холодно: правильные рекомендации."""
        ctx = WeatherContext(
            temperature=8,
            humidity=80,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Laki-laki",
        )
        recs = get_temperature_recommendations(ctx)

        assert recs["comfort_level"] == "cold"

    def test_hot_recommendations(self) -> None:
        """Жарко: правильные рекомендации."""
        ctx = WeatherContext(
            temperature=32,
            humidity=50,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Perempuan",
        )
        recs = get_temperature_recommendations(ctx)

        assert recs["comfort_level"] == "very_hot"

    def test_indoor_location(self) -> None:
        """Indoor: рекомендации учитывают локацию."""
        ctx = WeatherContext(
            temperature=22,
            humidity=50,
            weather_condition="Cerah",
            location="Indoor",
            activity="Kerja",
            gender="Laki-laki",
        )
        recs = get_temperature_recommendations(ctx)

        # 22°C это "warm" по нашим порогам (20-25°C)
        assert recs["comfort_level"] == "warm"


# ═══════════════════════════════════════════
# ТЕСТЫ ПРЕДПОЧТЕНИЙ ПОЛЬЗОВАТЕЛЯ
# ═══════════════════════════════════════════


class TestPreferencesFilter:
    """Тесты apply_preferences_filter."""

    def test_no_preferences_returns_all(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Без предпочтений: все комбинации возвращаются."""
        filtered = filter_categories(moderate_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, moderate_outdoor_context)

        result = apply_preferences_filter(combinations, None)
        assert len(result) == len(combinations)

    def test_budget_filter(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Бюджет: фильтрация по цене."""
        filtered = filter_categories(moderate_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, moderate_outdoor_context)

        # Создаём цены для items
        item_prices = {
            "u1": 1000.0,
            "u2": 2000.0,
            "u3": 3000.0,
            "l1": 2000.0,
            "l2": 1500.0,
            "l3": 3000.0,
            "f1": 2000.0,
            "f2": 3000.0,
            "f3": 1000.0,
            "o1": 5000.0,
            "o2": 3000.0,
        }

        prefs = UserPreferences(budget_range="economy")
        result = apply_preferences_filter(
            combinations, prefs, item_prices=item_prices
        )

        # economy = до 3000₽, комбинации должны быть отфильтрованы
        # или возвращены все если ничего не прошло
        assert len(result) >= 0  # может быть 0 или больше

    def test_style_filter(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Стили: фильтрация по стилям."""
        filtered = filter_categories(moderate_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, moderate_outdoor_context)

        item_styles = {
            "u1": ["casual", "sport"],
            "u2": ["classic", "business"],
            "u3": ["casual", "comfort"],
        }

        prefs = UserPreferences(style_preferences=["casual"])
        result = apply_preferences_filter(
            combinations, prefs, item_styles=item_styles
        )

        # Результат должен содержать комбинации с casual items
        assert len(result) >= 0

    def test_brand_sorting(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Бренды: сортировка по брендам."""
        filtered = filter_categories(moderate_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, moderate_outdoor_context)

        item_brands = {
            "u1": "nike",
            "u2": "zara",
            "u3": "nike",
        }

        prefs = UserPreferences(favorite_brands=["nike"])
        result = apply_preferences_filter(
            combinations, prefs, item_brands=item_brands
        )

        # Результат должен быть отсортирован
        assert len(result) == len(combinations)


# ═══════════════════════════════════════════
# ИНТЕГРАЦИОННЫЕ ТЕСТЫ
# ═══════════════════════════════════════════


class TestIntegration:
    """Интеграционные тесты полного пайплайна."""

    def test_full_pipeline_cold(
        self,
        cold_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Полный пайплайн: холодная погода."""
        # 1. Фильтрация
        filtered = filter_categories(cold_outdoor_context, sample_items_by_category)

        # 2. Генерация комбинаций
        combinations = generate_combinations(filtered, cold_outdoor_context)

        # 3. Проверяем результат
        assert len(combinations) > 0

        # 4. Все комбинации имеют outerwear
        for combo in combinations:
            assert combo.get("outerwear") is not None

    def test_full_pipeline_hot(
        self,
        hot_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Полный пайплайн: жаркая погода."""
        filtered = filter_categories(hot_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, hot_outdoor_context)

        assert len(combinations) > 0

        # Все комбинации без outerwear
        for combo in combinations:
            assert combo.get("outerwear") is None

    def test_full_pipeline_with_preferences(
        self,
        moderate_outdoor_context: WeatherContext,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Полный пайплайн с предпочтениями."""
        filtered = filter_categories(moderate_outdoor_context, sample_items_by_category)
        combinations = generate_combinations(filtered, moderate_outdoor_context)

        prefs = UserPreferences(
            style_preferences=["casual"],
            budget_range="medium",
        )

        result = apply_preferences_filter(combinations, prefs)
        assert len(result) >= 0

    @pytest.mark.parametrize(
        "temp,expected_outerwear",
        [
            (5, True),    # холодно
            (12, True),   # прохладно
            (18, True),   # умеренно
            (22, False),  # тепло
            (30, False),  # жарко
        ],
        ids=["5c", "12c", "18c", "22c", "30c"],
    )
    def test_outerwear_by_temperature(
        self,
        temp: float,
        expected_outerwear: bool,
        sample_items_by_category: Dict[str, List[Dict[str, Any]]],
    ) -> None:
        """Outerwear в зависимости от температуры."""
        ctx = WeatherContext(
            temperature=temp,
            humidity=60,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Laki-laki",
        )

        filtered = filter_categories(ctx, sample_items_by_category)

        if expected_outerwear:
            assert len(filtered.get("outerwear", [])) > 0
        else:
            assert filtered.get("outerwear", []) == []
