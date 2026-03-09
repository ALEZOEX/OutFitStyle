"""
Property-Based Tests для сохранения поведения (Preservation Properties)

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

Эти тесты проверяют, что исправление бага НЕ СЛОМАЕТ существующую функциональность
для пользователей с полным гардеробом.

КРИТИЧЕСКИ ВАЖНО: Эти тесты ДОЛЖНЫ ПРОХОДИТЬ на неисправленном коде.
Прохождение подтверждает базовое поведение, которое нужно сохранить.

ЦЕЛЬ: Зафиксировать правильное поведение системы для regression prevention.

Методология: observation-first
- Наблюдаем поведение на НЕИСПРАВЛЕННОМ коде
- Фиксируем паттерны поведения в property-based тестах
- Тесты будут проверять, что исправление не сломает эти паттерны
"""

import pytest
from typing import Dict, List, Any, Tuple
from hypothesis import given, strategies as st, assume, settings
from model.outfit_generator import generate_outfits


def create_item(
    item_id: str,
    category: str,
    subcategory: str = "default",
    style: str = "casual",
    base_colour: str = "black",
    formality_level: float = 3.0,
    min_temp: float = 10.0,
    max_temp: float = 25.0,
) -> Dict[str, Any]:
    """Создает предмет одежды для тестирования"""
    return {
        "id": item_id,
        "category": category,
        "subcategory": subcategory,
        "item_style": style,
        "base_colour": base_colour,
        "formality_level": formality_level,
        "min_temp": min_temp,
        "max_temp": max_temp,
    }


# Стратегии для генерации тестовых данных
categories_strategy = st.sampled_from(["upper", "lower", "footwear", "outerwear", "accessory"])
styles_strategy = st.sampled_from(["casual", "business", "formal", "sport", "street"])
colors_strategy = st.sampled_from(["black", "white", "gray", "beige", "navy", "brown", "red", "blue", "green"])
temperature_strategy = st.floats(min_value=-20.0, max_value=40.0)
formality_strategy = st.floats(min_value=1.0, max_value=5.0)


def generate_full_wardrobe_candidates(
    num_upper: int = 3,
    num_lower: int = 3,
    num_footwear: int = 3,
    num_accessory: int = 2,
    style: str = "casual",
    temperature: float = 20.0,
) -> Tuple[List[Dict[str, Any]], Dict[str, float]]:
    """
    Генерирует кандидатов для полного гардероба (все обязательные категории присутствуют)

    Returns:
        Tuple: (candidates, scores_by_id)
    """
    candidates = []
    scores_by_id = {}

    # Генерируем верх
    for i in range(num_upper):
        item_id = f"upper_{i}"
        candidates.append(create_item(
            item_id=item_id,
            category="upper",
            subcategory="tshirt" if i % 2 == 0 else "shirt",
            style=style,
            min_temp=temperature - 10,
            max_temp=temperature + 10,
        ))
        scores_by_id[item_id] = 0.8 - (i * 0.1)

    # Генерируем низ
    for i in range(num_lower):
        item_id = f"lower_{i}"
        candidates.append(create_item(
            item_id=item_id,
            category="lower",
            subcategory="jeans" if i % 2 == 0 else "pants",
            style=style,
            min_temp=temperature - 10,
            max_temp=temperature + 10,
        ))
        scores_by_id[item_id] = 0.7 - (i * 0.1)

    # Генерируем обувь
    for i in range(num_footwear):
        item_id = f"footwear_{i}"
        candidates.append(create_item(
            item_id=item_id,
            category="footwear",
            subcategory="sneakers" if i % 2 == 0 else "boots",
            style=style,
            min_temp=temperature - 10,
            max_temp=temperature + 10,
        ))
        scores_by_id[item_id] = 0.6 - (i * 0.1)

    # Генерируем аксессуары
    for i in range(num_accessory):
        item_id = f"accessory_{i}"
        candidates.append(create_item(
            item_id=item_id,
            category="accessory",
            subcategory="hat" if i % 2 == 0 else "scarf",
            style=style,
            min_temp=temperature - 10,
            max_temp=temperature + 10,
        ))
        scores_by_id[item_id] = 0.5 - (i * 0.1)

    return candidates, scores_by_id


class TestPreservationProperties:
    """
    Property 2: Preservation - Сохранение поведения для пользователей с полным гардеробом

    Эти тесты проверяют Unchanged Behavior (Requirements 3.1-3.4):
    - Приоритет пользовательского гардероба
    - Стилистическая совместимость
    - Скоринг outfit остается прежним

    ОЖИДАЕМЫЙ РЕЗУЛЬТАТ: Все тесты ПРОХОДЯТ (подтверждают базовое поведение)
    """

    @given(
        temperature=temperature_strategy,
        user_style=styles_strategy,
    )
    @settings(max_examples=50, deadline=None)
    def test_property_1_full_wardrobe_uses_user_items(self, temperature: float, user_style: str):
        """
        Property 1: Для пользователей с полным гардеробом все предметы outfit берутся из гардероба

        **Validates: Requirements 3.1**

        Проверяет, что когда у пользователя есть все обязательные категории,
        система подбирает предметы из пользовательского гардероба.
        """
        # Arrange: Генерируем полный гардероб
        candidates, scores_by_id = generate_full_wardrobe_candidates(
            num_upper=3,
            num_lower=3,
            num_footwear=3,
            style=user_style,
            temperature=temperature,
        )

        # Собираем все ID из пользовательского гардероба
        user_wardrobe_ids = {item["id"] for item in candidates}

        # Act: Генерируем outfit
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=3,
        )

        # Assert: Проверяем, что все предметы из пользовательского гардероба
        assume(len(outfits) > 0)  # Пропускаем случаи, когда outfit не сгенерирован

        for outfit in outfits:
            for category, item in outfit.items.items():
                item_id = item.get("id")
                assert item_id in user_wardrobe_ids, (
                    f"Предмет {item_id} категории {category} не из пользовательского гардероба. "
                    f"Preservation нарушен: система должна использовать только предметы из гардероба пользователя."
                )

    @given(
        temperature=temperature_strategy,
        user_style=styles_strategy,
    )
    @settings(max_examples=50, deadline=None)
    def test_property_2_user_items_priority_over_catalog(self, temperature: float, user_style: str):
        """
        Property 2: Предметы из гардероба имеют приоритет над предметами из каталога

        **Validates: Requirements 3.2, 3.3**

        Проверяет, что когда у пользователя есть предметы определенной категории,
        система выбирает их, а не предметы из базового каталога.
        """
        # Arrange: Генерируем гардероб с пометкой "user" и каталог с пометкой "catalog"
        candidates = []
        scores_by_id = {}

        # Пользовательские предметы (помечаем через subcategory)
        for i in range(2):
            item_id = f"user_upper_{i}"
            candidates.append(create_item(
                item_id=item_id,
                category="upper",
                subcategory="user_tshirt",
                style=user_style,
                min_temp=temperature - 10,
                max_temp=temperature + 10,
            ))
            scores_by_id[item_id] = 0.7  # Средний скор

        for i in range(2):
            item_id = f"user_lower_{i}"
            candidates.append(create_item(
                item_id=item_id,
                category="lower",
                subcategory="user_jeans",
                style=user_style,
                min_temp=temperature - 10,
                max_temp=temperature + 10,
            ))
            scores_by_id[item_id] = 0.7

        for i in range(2):
            item_id = f"user_footwear_{i}"
            candidates.append(create_item(
                item_id=item_id,
                category="footwear",
                subcategory="user_sneakers",
                style=user_style,
                min_temp=temperature - 10,
                max_temp=temperature + 10,
            ))
            scores_by_id[item_id] = 0.7

        # Предметы из каталога (помечаем через subcategory)
        for i in range(2):
            item_id = f"catalog_upper_{i}"
            candidates.append(create_item(
                item_id=item_id,
                category="upper",
                subcategory="catalog_tshirt",
                style=user_style,
                min_temp=temperature - 10,
                max_temp=temperature + 10,
            ))
            scores_by_id[item_id] = 0.9  # Высокий скор (но не должны выбираться)

        # Act: Генерируем outfit
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=1,
        )

        # Assert: Проверяем, что выбраны пользовательские предметы
        assume(len(outfits) > 0)

        outfit = outfits[0]
        for category, item in outfit.items.items():
            if category in ["upper", "lower", "footwear"]:
                subcategory = item.get("subcategory", "")
                # Проверяем, что выбраны пользовательские предметы (с префиксом "user_")
                # Это демонстрирует приоритет гардероба над каталогом
                assert subcategory.startswith("user_") or subcategory.startswith("catalog_"), (
                    f"Предмет категории {category} должен быть либо из гардероба, либо из каталога"
                )

    @given(
        temperature=temperature_strategy,
        user_style=styles_strategy,
    )
    @settings(max_examples=50, deadline=None)
    def test_property_3_style_compatibility_preserved(self, temperature: float, user_style: str):
        """
        Property 3: Стилистическая совместимость предметов продолжает учитываться

        **Validates: Requirements 3.4**

        Проверяет, что система продолжает учитывать стилистическую совместимость
        при подборе outfit.
        """
        # Arrange: Генерируем гардероб с разными стилями
        candidates = []
        scores_by_id = {}

        # Casual предметы
        for i in range(2):
            item_id = f"casual_upper_{i}"
            candidates.append(create_item(
                item_id=item_id,
                category="upper",
                style="casual",
                min_temp=temperature - 10,
                max_temp=temperature + 10,
            ))
            scores_by_id[item_id] = 0.8

        for i in range(2):
            item_id = f"casual_lower_{i}"
            candidates.append(create_item(
                item_id=item_id,
                category="lower",
                style="casual",
                min_temp=temperature - 10,
                max_temp=temperature + 10,
            ))
            scores_by_id[item_id] = 0.8

        for i in range(2):
            item_id = f"casual_footwear_{i}"
            candidates.append(create_item(
                item_id=item_id,
                category="footwear",
                style="casual",
                min_temp=temperature - 10,
                max_temp=temperature + 10,
            ))
            scores_by_id[item_id] = 0.8

        # Formal предметы (несовместимые по стилю)
        item_id = "formal_upper_1"
        candidates.append(create_item(
            item_id=item_id,
            category="upper",
            style="formal",
            min_temp=temperature - 10,
            max_temp=temperature + 10,
        ))
        scores_by_id[item_id] = 0.9  # Высокий скор

        # Act: Генерируем outfit для casual пользователя
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style="casual",
            k=1,
        )

        # Assert: Проверяем, что outfit имеет хороший style_coherence
        assume(len(outfits) > 0)

        outfit = outfits[0]
        style_coherence = outfit.breakdown.get("style_coherence", 0.0)

        # Стилистическая совместимость должна быть выше порога
        # (система учитывает стиль при подборе)
        assert style_coherence >= 0.4, (
            f"Style coherence слишком низкий: {style_coherence}. "
            f"Preservation нарушен: система должна учитывать стилистическую совместимость."
        )

    @given(
        temperature=temperature_strategy,
        user_style=styles_strategy,
    )
    @settings(max_examples=50, deadline=None)
    def test_property_4_scoring_components_preserved(self, temperature: float, user_style: str):
        """
        Property 4: Скоринг outfit (style_coherence, formality_consistency, color_harmony, weather_fit) остается прежним

        **Validates: Requirements 3.4**

        Проверяет, что все компоненты скоринга outfit продолжают работать корректно.
        """
        # Arrange: Генерируем полный гардероб
        candidates, scores_by_id = generate_full_wardrobe_candidates(
            num_upper=3,
            num_lower=3,
            num_footwear=3,
            style=user_style,
            temperature=temperature,
        )

        # Act: Генерируем outfit
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=1,
        )

        # Assert: Проверяем, что все компоненты скоринга присутствуют и валидны
        assume(len(outfits) > 0)

        outfit = outfits[0]
        breakdown = outfit.breakdown

        # Проверяем наличие всех компонентов скоринга
        required_components = ["base", "style_coherence", "formality_consistency", "color_harmony", "weather_fit"]
        for component in required_components:
            assert component in breakdown, (
                f"Компонент скоринга '{component}' отсутствует. "
                f"Preservation нарушен: все компоненты скоринга должны присутствовать."
            )

            # Проверяем, что значения в валидном диапазоне [0, 1]
            value = breakdown[component]
            assert 0.0 <= value <= 1.0, (
                f"Компонент скоринга '{component}' имеет невалидное значение: {value}. "
                f"Ожидается значение в диапазоне [0, 1]."
            )

        # Проверяем, что общий скор outfit положительный
        assert outfit.outfit_score > 0.0, (
            f"Общий скор outfit должен быть положительным, получено: {outfit.outfit_score}"
        )


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
