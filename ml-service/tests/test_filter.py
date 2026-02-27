"""
Тесты для двухуровневой фильтрации (pytest version).

Запуск:
    pytest tests/test_filter.py -v

Покрытие:
    pytest tests/test_filter.py --cov=app.filter --cov-report=html
"""

import pytest
from typing import List, Dict, Any

from app.filter import (
    WeatherContext,
    filter_candidates,
    generate_combinations,
    get_stats,
    _level2_combination_filter,
    ALL_TOPS,
    ALL_BOTTOMS,
    ALL_OUTERWEAR,
    ALL_FOOTWEAR,
)


# ═══════════════════════════════════════════
# ФИКСТУРЫ
# ═══════════════════════════════════════════


@pytest.fixture
def cold_outdoor_context() -> WeatherContext:
    """Холодная погода outdoor (< 12°C)"""
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
    """Жаркая погода outdoor (> 33°C)"""
    return WeatherContext(
        temperature=35,
        humidity=60,
        weather_condition="Cerah",
        location="Outdoor",
        activity="Jalan-jalan",
        gender="Perempuan",
    )


@pytest.fixture
def work_indoor_context() -> WeatherContext:
    """Работа в офисе indoor"""
    return WeatherContext(
        temperature=22,
        humidity=50,
        weather_condition="Cerah",
        location="Indoor",
        activity="Kerja",
        gender="Laki-laki",
    )


@pytest.fixture
def sport_outdoor_context() -> WeatherContext:
    """Спорт на улице"""
    return WeatherContext(
        temperature=25,
        humidity=60,
        weather_condition="Cerah",
        location="Outdoor",
        activity="Olahraga",
        gender="Perempuan",
    )


@pytest.fixture
def rain_outdoor_context() -> WeatherContext:
    """Дождь на улице"""
    return WeatherContext(
        temperature=18,
        humidity=95,
        weather_condition="Hujan",
        location="Outdoor",
        activity="Jalan-jalan",
        gender="Laki-laki",
    )


# ═══════════════════════════════════════════
# УРОВЕНЬ 1: КАТЕГОРИАЛЬНЫЕ ТЕСТЫ
# ═══════════════════════════════════════════


class TestLevel1CategoryFilter:
    """Тесты категориальной фильтрации (Уровень 1)"""

    def test_cold_outdoor_removes_shorts_sandals(
        self, cold_outdoor_context: WeatherContext
    ) -> None:
        """< 15°C outdoor: нет шорт, сандалей"""
        result = filter_candidates(cold_outdoor_context)

        assert "Celana Pendek" not in result["bottoms"]
        assert "Sandal" not in result["footwear"]
        assert "Tanpa Pakaian Luar" not in result["outerwear"]
        # Kaos остаётся (может быть под курткой)
        assert "Kaos" in result["tops"]

    def test_very_cold_outdoor_only_warm_footwear(
        self, cold_outdoor_context: WeatherContext
    ) -> None:
        """< 10°C outdoor: только тёплая обувь"""
        result = filter_candidates(cold_outdoor_context)

        assert "Sneakers" not in result["footwear"]
        assert "Sepatu Olahraga" not in result["footwear"]
        assert "Sepatu Bot" in result["footwear"]
        assert "Rok" not in result["bottoms"]

    def test_hot_outdoor_removes_jacket_blazer_boots(
        self, hot_outdoor_context: WeatherContext
    ) -> None:
        """> 33°C: нет куртки, пиджака, ботинок"""
        result = filter_candidates(hot_outdoor_context)

        assert "Jaket" not in result["outerwear"]
        assert "Jas" not in result["tops"]
        assert "Sepatu Bot" not in result["footwear"]
        assert "Sandal" in result["footwear"]
        assert "Celana Pendek" in result["bottoms"]

    def test_rain_outdoor_removes_sandals_no_jacket(
        self, rain_outdoor_context: WeatherContext
    ) -> None:
        """Дождь outdoor: нет сандалей, нужна куртка"""
        result = filter_candidates(rain_outdoor_context)

        assert "Sandal" not in result["footwear"]
        assert "Tanpa Pakaian Luar" not in result["outerwear"]

    def test_sport_removes_formal_items(
        self, sport_outdoor_context: WeatherContext
    ) -> None:
        """Спорт: нет пиджака, блузки, юбки, формальной обуви"""
        result = filter_candidates(sport_outdoor_context)

        assert "Jas" not in result["tops"]
        assert "Blouse" not in result["tops"]
        assert "Rok" not in result["bottoms"]
        assert "Sepatu Formal" not in result["footwear"]
        assert "Sepatu Bot" not in result["footwear"]
        assert "Kaos" in result["tops"]

    def test_work_removes_casual_items(
        self, work_indoor_context: WeatherContext
    ) -> None:
        """Работа: нет сандалей, шорт, джоггеров, спорт.обуви, худи"""
        result = filter_candidates(work_indoor_context)

        assert "Sandal" not in result["footwear"]
        assert "Sepatu Olahraga" not in result["footwear"]
        assert "Celana Pendek" not in result["bottoms"]
        assert "Celana Jogger" not in result["bottoms"]
        assert "Hoodie" not in result["outerwear"]
        assert "Kemeja" in result["tops"]

    def test_gender_male_removes_blouse_skirt(
        self, work_indoor_context: WeatherContext
    ) -> None:
        """Мужчина: нет юбки и блузки"""
        # Меняем контекст на мужской
        male_context = WeatherContext(
            temperature=25,
            humidity=60,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Laki-laki",
        )
        result = filter_candidates(male_context)

        assert "Rok" not in result["bottoms"]
        assert "Blouse" not in result["tops"]

    def test_gender_female_keeps_blouse_skirt(
        self, work_indoor_context: WeatherContext
    ) -> None:
        """Женщина: юбка и блузка доступны"""
        female_context = WeatherContext(
            temperature=25,
            humidity=60,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Perempuan",
        )
        result = filter_candidates(female_context)

        assert "Rok" in result["bottoms"]
        assert "Blouse" in result["tops"]

    def test_fallback_never_empty(self, cold_outdoor_context: WeatherContext) -> None:
        """Fallback гарантирует непустой результат"""
        # Пустой гардероб → fallback на ALL_*
        result = filter_candidates(
            cold_outdoor_context,
            wardrobe_tops=[],
            wardrobe_bottoms=[],
            wardrobe_outerwear=[],
            wardrobe_footwear=[],
        )

        assert len(result["tops"]) > 0
        assert len(result["bottoms"]) > 0
        assert len(result["outerwear"]) > 0
        assert len(result["footwear"]) > 0


# ═══════════════════════════════════════════
# УРОВЕНЬ 2: КОМБИНАТОРНЫЕ ТЕСТЫ
# ═══════════════════════════════════════════


class TestLevel2CombinationFilter:
    """Тесты комбинаторной фильтрации (Уровень 2)"""

    @staticmethod
    def _default_context(
        temperature: float = 22,
        location: str = "Outdoor",
    ) -> WeatherContext:
        return WeatherContext(
            temperature=temperature,
            humidity=60,
            weather_condition="Cerah",
            location=location,
            activity="Jalan-jalan",
            gender="Laki-laki",
        )

    def test_jas_shorts_blocked(self) -> None:
        """Пиджак + шорты = абсурд"""
        combo: Dict[str, str] = {
            "top": "Jas",
            "bottom": "Celana Pendek",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sneakers",
        }
        assert not _level2_combination_filter(combo, self._default_context())

    def test_jas_joggers_blocked(self) -> None:
        """Пиджак + джоггеры = абсурд"""
        combo: Dict[str, str] = {
            "top": "Jas",
            "bottom": "Celana Jogger",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sepatu Formal",
        }
        assert not _level2_combination_filter(combo, self._default_context())

    def test_jas_hoodie_blocked(self) -> None:
        """Пиджак + худи сверху = абсурд"""
        combo: Dict[str, str] = {
            "top": "Jas",
            "bottom": "Celana Panjang",
            "outerwear": "Hoodie",
            "footwear": "Sepatu Formal",
        }
        assert not _level2_combination_filter(combo, self._default_context())

    def test_jas_sneakers_blocked(self) -> None:
        """Пиджак + кроссовки = абсурд"""
        combo: Dict[str, str] = {
            "top": "Jas",
            "bottom": "Celana Panjang",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sneakers",
        }
        assert not _level2_combination_filter(combo, self._default_context())

    def test_formal_shoes_shorts_blocked(self) -> None:
        """Формальная обувь + шорты = абсурд"""
        combo: Dict[str, str] = {
            "top": "Kaos",
            "bottom": "Celana Pendek",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sepatu Formal",
        }
        assert not _level2_combination_filter(combo, self._default_context())

    def test_boots_shorts_blocked(self) -> None:
        """Ботинки + шорты = абсурд"""
        combo: Dict[str, str] = {
            "top": "Kaos",
            "bottom": "Celana Pendek",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sepatu Bot",
        }
        assert not _level2_combination_filter(combo, self._default_context())

    def test_blouse_joggers_blocked(self) -> None:
        """Блузка + джоггеры = абсурд"""
        combo: Dict[str, str] = {
            "top": "Blouse",
            "bottom": "Celana Jogger",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sneakers",
        }
        context = WeatherContext(
            temperature=22,
            humidity=60,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Perempuan",
        )
        assert not _level2_combination_filter(combo, context)

    def test_sandal_jacket_blocked(self) -> None:
        """Сандали + куртка = стилистически абсурд"""
        combo: Dict[str, str] = {
            "top": "Kaos",
            "bottom": "Celana Panjang",
            "outerwear": "Jaket",
            "footwear": "Sandal",
        }
        assert not _level2_combination_filter(combo, self._default_context())

    def test_tshirt_no_jacket_cold_blocked(self) -> None:
        """Футболка без куртки при < 12°C outdoor"""
        combo: Dict[str, str] = {
            "top": "Kaos",
            "bottom": "Celana Panjang",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sepatu Bot",
        }
        assert not _level2_combination_filter(
            combo, self._default_context(temperature=10)
        )

    def test_shorts_no_jacket_cool_blocked(self) -> None:
        """Шорты без куртки при < 18°C outdoor"""
        combo: Dict[str, str] = {
            "top": "Kemeja",
            "bottom": "Celana Pendek",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sneakers",
        }
        assert not _level2_combination_filter(
            combo, self._default_context(temperature=16)
        )

    def test_valid_combo_passes(self) -> None:
        """Нормальная комбинация проходит"""
        combo: Dict[str, str] = {
            "top": "Kemeja",
            "bottom": "Celana Panjang",
            "outerwear": "Jaket",
            "footwear": "Sepatu Bot",
        }
        assert _level2_combination_filter(
            combo, self._default_context(temperature=12)
        )

    def test_casual_warm_valid(self) -> None:
        """Casual при тёплой погоде — ок"""
        combo: Dict[str, str] = {
            "top": "Kaos",
            "bottom": "Celana Pendek",
            "outerwear": "Tanpa Pakaian Luar",
            "footwear": "Sandal",
        }
        assert _level2_combination_filter(
            combo, self._default_context(temperature=30)
        )

    def test_tshirt_jacket_cold_valid(self) -> None:
        """Футболка ПОД курткой при холоде — ок"""
        combo: Dict[str, str] = {
            "top": "Kaos",
            "bottom": "Celana Panjang",
            "outerwear": "Jaket",
            "footwear": "Sepatu Bot",
        }
        assert _level2_combination_filter(
            combo, self._default_context(temperature=10)
        )


# ═══════════════════════════════════════════
# ИНТЕГРАЦИОННЫЕ ТЕСТЫ
# ═══════════════════════════════════════════


class TestIntegration:
    """Интеграционные тесты полного пайплайна"""

    def test_reduction_cold_rain(self) -> None:
        """Холодный дождь — сильное сокращение"""
        ctx = WeatherContext(
            temperature=10,
            humidity=90,
            weather_condition="Hujan",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Laki-laki",
        )
        stats = get_stats(ctx)

        assert stats["after_level2"] < stats["after_level1"]
        assert stats["after_level2"] < stats["total_raw"]
        assert stats["after_level2"] > 0

    def test_reduction_hot_clear(self) -> None:
        """Жаркая ясная погода"""
        ctx = WeatherContext(
            temperature=35,
            humidity=50,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Perempuan",
        )
        stats = get_stats(ctx)

        assert stats["after_level2"] > 0

    def test_reduction_work_indoor(self) -> None:
        """Работа indoor"""
        ctx = WeatherContext(
            temperature=22,
            humidity=50,
            weather_condition="Cerah",
            location="Indoor",
            activity="Kerja",
            gender="Laki-laki",
        )
        stats = get_stats(ctx)

        assert stats["after_level2"] > 0

    def test_reduction_sport(self) -> None:
        """Спорт outdoor"""
        ctx = WeatherContext(
            temperature=25,
            humidity=60,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Olahraga",
            gender="Laki-laki",
        )
        stats = get_stats(ctx)

        assert stats["after_level2"] > 0

    @pytest.mark.parametrize(
        "ctx",
        [
            WeatherContext(8, 100, "Hujan", "Outdoor", "Olahraga", "Laki-laki"),
            WeatherContext(40, 30, "Cerah", "Indoor", "Kerja", "Perempuan"),
            WeatherContext(15, 50, "Berawan", "Outdoor", "Jalan-jalan", "Laki-laki"),
            WeatherContext(22, 70, "Mendung", "Indoor", "Pesta", "Perempuan"),
            WeatherContext(8, 95, "Hujan", "Outdoor", "Kerja", "Laki-laki", duration=8),
            WeatherContext(38, 40, "Cerah", "Outdoor", "Olahraga", "Perempuan"),
        ],
        ids=["extreme_cold_rain", "extreme_hot", "cool_cloudy", "party_indoor", "long_cold_rain", "hot_sport"],
    )
    def test_no_empty_any_context(self, ctx: WeatherContext) -> None:
        """Ни при каком контексте не пустой результат"""
        combos = generate_combinations(ctx)
        assert len(combos) > 0, f"Empty for context: {ctx}"

    def test_cold_rain_all_combos_make_sense(self) -> None:
        """Spot-check: все комбинации для холодного дождя должны содержать куртку"""
        ctx = WeatherContext(
            temperature=10,
            humidity=90,
            weather_condition="Hujan",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Laki-laki",
        )
        combos = generate_combinations(ctx)

        for c in combos:
            # При 10°C дождь outdoor — не должно быть "без куртки"
            assert c["outerwear"] != "Tanpa Pakaian Luar"
            # Не должно быть сандалей
            assert c["footwear"] != "Sandal"
            # Не должно быть шорт
            assert c["bottom"] != "Celana Pendek"


# ═══════════════════════════════════════════
# ТЕСТЫ НА IMMUTABILITY
# ═══════════════════════════════════════════


class TestImmutability:
    """Тесты на отсутствие мутации входных данных"""

    def test_filter_does_not_mutate_input_sets(self) -> None:
        """filter_candidates не мутирует входные множества"""
        ctx = WeatherContext(
            temperature=25,
            humidity=60,
            weather_condition="Cerah",
            location="Outdoor",
            activity="Jalan-jalan",
            gender="Laki-laki",
        )

        original_tops = {"Kaos", "Kemeja", "Blouse", "Jas"}
        original_bottoms = {"Celana Panjang", "Celana Pendek", "Rok"}
        original_outerwear = {"Hoodie", "Jaket", "Tanpa Pakaian Luar"}
        original_footwear = {"Sneakers", "Sandal", "Sepatu Bot"}

        tops_copy = original_tops.copy()
        bottoms_copy = original_bottoms.copy()
        outerwear_copy = original_outerwear.copy()
        footwear_copy = original_footwear.copy()

        filter_candidates(
            ctx,
            list(original_tops),
            list(original_bottoms),
            list(original_outerwear),
            list(original_footwear),
        )

        # Проверяем, что оригиналы не изменились
        assert original_tops == tops_copy
        assert original_bottoms == bottoms_copy
        assert original_outerwear == outerwear_copy
        assert original_footwear == footwear_copy
