"""
Property-Based Test для бага неполных рекомендаций outfit

**Validates: Requirements 1.1, 1.2, 1.3**

Этот тест проверяет Bug Condition: система должна возвращать полные комплекты
одежды даже когда в пользовательском гардеробе отсутствуют обязательные категории.

КРИТИЧЕСКИ ВАЖНО: Этот тест ДОЛЖЕН ПРОВАЛИТЬСЯ на неисправленном коде.
Провал подтверждает существование бага.

НЕ ПЫТАЙТЕСЬ исправить тест или код, когда он провалится!

ЦЕЛЬ: Выявить контрпримеры, демонстрирующие существование бага.
"""

import pytest
from typing import Dict, List, Any
from model.outfit_generator import generate_outfits


def create_sample_item(
    item_id: str,
    category: str,
    subcategory: str = "default",
    style: str = "casual",
    base_colour: str = "black",
    formality_level: float = 3.0,
    min_temp: float = 10.0,
    max_temp: float = 25.0,
) -> Dict[str, Any]:
    """Создает образец предмета одежды для тестирования"""
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


class TestIncompleteOutfitBugCondition:
    """
    Property 1: Bug Condition - Неполный комплект при отсутствии категорий в гардеробе

    Тестирует, что система возвращает полные комплекты одежды (upper, lower, footwear)
    даже когда в пользовательском гардеробе отсутствуют некоторые обязательные категории.

    Ожидаемое поведение (Expected Behavior Properties из design.md):
    - Результат должен содержать все обязательные категории (upper, lower, footwear)
    - Для отсутствующих в гардеробе категорий должны использоваться предметы из базового каталога

    ОЖИДАЕМЫЙ РЕЗУЛЬТАТ: Тест ПРОВАЛИТСЯ (это правильно - доказывает существование бага)
    """

    def test_missing_lower_and_footwear_categories(self):
        """
        Тест 1: Пользователь с гардеробом, содержащим только верх и аксессуары
        (отсутствуют низ и обувь)

        Bug Condition 1.1, 1.2: Система оставляет низ и обувь как "Не выбрано"
        Expected Behavior 2.1, 2.2: Система должна подобрать низ и обувь из базового каталога
        """
        # Arrange: Создаем кандидатов только с верхом и аксессуарами
        candidates = [
            create_sample_item("upper_1", "upper", "tshirt"),
            create_sample_item("upper_2", "upper", "shirt"),
            create_sample_item("accessory_1", "accessory", "hat"),
        ]

        scores_by_id = {
            "upper_1": 0.8,
            "upper_2": 0.7,
            "accessory_1": 0.6,
        }

        temperature = 20.0
        user_style = "casual"

        # Act: Генерируем outfit
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=1,
        )

        # Assert: Проверяем, что система вернула полный комплект
        # ОЖИДАЕТСЯ ПРОВАЛ: текущая реализация вернет пустой список
        assert len(outfits) > 0, (
            "Bug detected: система не вернула outfit при отсутствии категорий 'lower' и 'footwear'. "
            "Ожидается использование базового каталога как fallback."
        )

        # Проверяем наличие всех обязательных категорий
        outfit = outfits[0]
        assert "upper" in outfit.items, "Отсутствует обязательная категория 'upper'"
        assert "lower" in outfit.items, "Отсутствует обязательная категория 'lower' (должна быть из базового каталога)"
        assert "footwear" in outfit.items, "Отсутствует обязательная категория 'footwear' (должна быть из базового каталога)"

    def test_missing_footwear_category(self):
        """
        Тест 2: Пользователь с гардеробом, содержащим верх и низ (отсутствует обувь)

        Bug Condition 1.2: Система оставляет обувь как "Не выбрано"
        Expected Behavior 2.2: Система должна подобрать обувь из базового каталога
        """
        # Arrange: Создаем кандидатов с верхом и низом, но без обуви
        candidates = [
            create_sample_item("upper_1", "upper", "tshirt"),
            create_sample_item("lower_1", "lower", "jeans"),
            create_sample_item("lower_2", "lower", "pants"),
        ]

        scores_by_id = {
            "upper_1": 0.8,
            "lower_1": 0.7,
            "lower_2": 0.6,
        }

        temperature = 20.0
        user_style = "casual"

        # Act: Генерируем outfit
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=1,
        )

        # Assert: Проверяем, что система вернула полный комплект
        # ОЖИДАЕТСЯ ПРОВАЛ: текущая реализация вернет пустой список
        assert len(outfits) > 0, (
            "Bug detected: система не вернула outfit при отсутствии категории 'footwear'. "
            "Ожидается использование базового каталога как fallback."
        )

        # Проверяем наличие всех обязательных категорий
        outfit = outfits[0]
        assert "upper" in outfit.items, "Отсутствует обязательная категория 'upper'"
        assert "lower" in outfit.items, "Отсутствует обязательная категория 'lower'"
        assert "footwear" in outfit.items, "Отсутствует обязательная категория 'footwear' (должна быть из базового каталога)"

    def test_empty_wardrobe(self):
        """
        Тест 3: Пользователь с пустым гардеробом (отсутствуют все категории)

        Bug Condition 1.3: Система возвращает неполный комплект одежды
        Expected Behavior 2.3, 2.4: Система должна использовать двухуровневую логику поиска
        и вернуть полный комплект из базового каталога
        """
        # Arrange: Пустой список кандидатов
        candidates = []
        scores_by_id = {}
        temperature = 20.0
        user_style = "casual"

        # Act: Генерируем outfit
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=1,
        )

        # Assert: Проверяем, что система вернула полный комплект
        # ОЖИДАЕТСЯ ПРОВАЛ: текущая реализация вернет пустой список
        assert len(outfits) > 0, (
            "Bug detected: система не вернула outfit при пустом гардеробе. "
            "Ожидается использование базового каталога как fallback."
        )

        # Проверяем наличие всех обязательных категорий
        outfit = outfits[0]
        assert "upper" in outfit.items, "Отсутствует обязательная категория 'upper' (должна быть из базового каталога)"
        assert "lower" in outfit.items, "Отсутствует обязательная категория 'lower' (должна быть из базового каталога)"
        assert "footwear" in outfit.items, "Отсутствует обязательная категория 'footwear' (должна быть из базового каталога)"

    def test_missing_lower_category(self):
        """
        Тест 4: Пользователь с гардеробом, содержащим только верх (отсутствуют низ и обувь)

        Bug Condition 1.1, 1.2: Система оставляет низ и обувь как "Не выбрано"
        Expected Behavior 2.1, 2.2: Система должна подобрать низ и обувь из базового каталога
        """
        # Arrange: Создаем кандидатов только с верхом
        candidates = [
            create_sample_item("upper_1", "upper", "tshirt"),
            create_sample_item("upper_2", "upper", "shirt"),
            create_sample_item("upper_3", "upper", "sweater"),
        ]

        scores_by_id = {
            "upper_1": 0.8,
            "upper_2": 0.7,
            "upper_3": 0.6,
        }

        temperature = 20.0
        user_style = "casual"

        # Act: Генерируем outfit
        outfits = generate_outfits(
            candidates=candidates,
            scores_by_id=scores_by_id,
            temperature=temperature,
            user_style=user_style,
            k=1,
        )

        # Assert: Проверяем, что система вернула полный комплект
        # ОЖИДАЕТСЯ ПРОВАЛ: текущая реализация вернет пустой список
        assert len(outfits) > 0, (
            "Bug detected: система не вернула outfit при отсутствии категорий 'lower' и 'footwear'. "
            "Ожидается использование базового каталога как fallback."
        )

        # Проверяем наличие всех обязательных категорий
        outfit = outfits[0]
        assert "upper" in outfit.items, "Отсутствует обязательная категория 'upper'"
        assert "lower" in outfit.items, "Отсутствует обязательная категория 'lower' (должна быть из базового каталога)"
        assert "footwear" in outfit.items, "Отсутствует обязательная категория 'footwear' (должна быть из базового каталога)"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
