"""
Сервис для учёта предпочтений пользователя при ранжировании рекомендаций.

ИЗМЕНЕНИЯ:
- Добавлен учёт style_preferences для boost score
- Добавлен учёт favorite_brands для boost score
- Добавлен учёт budget_range для фильтрации/penalty

Логика boost:
- style_preferences → boost 50% для соответствующих стилей
- favorite_brands → boost 30% для любимых брендов
- budget_range → penalty 50% для超出 бюджета вещей
"""

import logging
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass, field
from datetime import datetime

logger = logging.getLogger(__name__)


@dataclass
class UserPreferences:
    """Предпочтения пользователя для ранжирования"""
    style_preferences: Optional[List[str]] = None
    budget_range: Optional[str] = None
    favorite_brands: Optional[List[str]] = None


@dataclass
class RankedItem:
    """Элемент с оценкой"""
    id: int
    base_score: float
    adjusted_score: float = 0.0
    boost_factors: Dict[str, float] = field(default_factory=dict)
    item_data: Optional[Dict[str, Any]] = None

    def __post_init__(self):
        self.adjusted_score = self.base_score


@dataclass
class RankingResult:
    """Результат ранжирования"""
    items: List[RankedItem]
    applied_filters: List[str] = field(default_factory=list)
    processing_time_ms: float = 0.0


class PreferenceRankService:
    """
    Сервис для применения предпочтений пользователя к оценкам ML модели.

    Основные функции:
    1. Boost score для предпочитаемых стилей (+50%)
    2. Boost score для любимых брендов (+30%)
    3. Penalty для超出 бюджета вещей (-50%)
    4. Логирование применённых фильтров
    """

    # Коэффициенты boost/penalty
    STYLE_BOOST_MULTIPLIER = 1.5      # +50% для предпочитаемых стилей
    BRAND_BOOST_MULTIPLIER = 1.3      # +30% для любимых брендов
    BUDGET_PENALTY_MULTIPLIER = 0.5   # -50% для超出 бюджета вещей

    # Пороги бюджета
    BUDGET_ECONOMY_MAX = 3000.0
    BUDGET_MEDIUM_MAX = 10000.0

    def __init__(self):
        self._stats: Dict[str, Dict[str, Any]] = {}

    def apply_preferences(
        self,
        items: List[Dict[str, Any]],
        preferences: UserPreferences,
        scores: List[float],
    ) -> List[RankedItem]:
        """
        Применить предпочтения пользователя к оценкам предметов.

        Args:
            items: Список предметов с метаданными (style, brand, price)
            preferences: Предпочтения пользователя
            scores: Базовые оценки от ML модели

        Returns:
            Список предметов с применёнными boost/penalty
        """
        if len(items) != len(scores):
            raise ValueError(
                f"Несоответствие длин: items={len(items)}, scores={len(scores)}"
            )

        ranked_items = []
        for i, (item, base_score) in enumerate(zip(items, scores)):
            ranked_item = RankedItem(
                id=item.get("id", i),
                base_score=base_score,
                item_data=item,
            )

            # Применяем boost/penalty
            adjusted_score = self._calculate_adjusted_score(
                ranked_item=ranked_item,
                preferences=preferences,
            )

            ranked_item.adjusted_score = adjusted_score
            ranked_items.append(ranked_item)

        # Сортировка по adjusted_score (убывание)
        ranked_items.sort(key=lambda x: x.adjusted_score, reverse=True)

        logger.info(
            f"Применены предпочтения: {len(ranked_items)} предметов, "
            f"style_boost={bool(preferences.style_preferences)}, "
            f"brand_boost={bool(preferences.favorite_brands)}, "
            f"budget_filter={preferences.budget_range}"
        )

        return ranked_items

    def _calculate_adjusted_score(
        self,
        ranked_item: RankedItem,
        preferences: UserPreferences,
    ) -> float:
        """
        Рассчитать скорректированную оценку с учётом предпочтений.

        Args:
            ranked_item: Предмет с базовой оценкой
            preferences: Предпочтения пользователя

        Returns:
            Скорректированная оценка
        """
        score = ranked_item.base_score
        item = ranked_item.item_data or {}
        boost_factors = {}

        # 1. Boost для предпочитаемых стилей
        if preferences.style_preferences:
            style_boost = self._apply_style_boost(
                score=score,
                item_style=item.get("style", ""),
                preferred_styles=preferences.style_preferences,
            )
            if style_boost != 1.0:
                boost_factors["style"] = style_boost
                score *= style_boost

        # 2. Boost для любимых брендов
        if preferences.favorite_brands:
            brand_boost = self._apply_brand_boost(
                score=score,
                item_brand=item.get("brand", ""),
                favorite_brands=preferences.favorite_brands,
            )
            if brand_boost != 1.0:
                boost_factors["brand"] = brand_boost
                score *= brand_boost

        # 3. Penalty для超出 бюджета вещей
        if preferences.budget_range:
            budget_penalty = self._apply_budget_penalty(
                score=score,
                item_price=item.get("price", 0),
                budget_range=preferences.budget_range,
            )
            if budget_penalty != 1.0:
                boost_factors["budget"] = budget_penalty
                score *= budget_penalty

        ranked_item.boost_factors = boost_factors
        return score

    def _apply_style_boost(
        self,
        score: float,
        item_style: str,
        preferred_styles: List[str],
    ) -> float:
        """
        Применить boost для предпочитаемых стилей.

        Args:
            score: Текущая оценка
            item_style: Стиль предмета
            preferred_styles: Предпочитаемые стили пользователя

        Returns:
            Множитель boost (1.0 если нет boost)
        """
        if not item_style:
            return 1.0

        item_style_lower = item_style.lower()
        preferred_styles_lower = {s.lower() for s in preferred_styles}

        if item_style_lower in preferred_styles_lower:
            logger.debug(f"Style boost: {item_style} in {preferred_styles}")
            return self.STYLE_BOOST_MULTIPLIER

        return 1.0

    def _apply_brand_boost(
        self,
        score: float,
        item_brand: str,
        favorite_brands: List[str],
    ) -> float:
        """
        Применить boost для любимых брендов.

        Args:
            score: Текущая оценка
            item_brand: Бренд предмета
            favorite_brands: Любимые бренды пользователя

        Returns:
            Множитель boost (1.0 если нет boost)
        """
        if not item_brand:
            return 1.0

        item_brand_lower = item_brand.lower()
        favorite_brands_lower = {b.lower() for b in favorite_brands}

        if item_brand_lower in favorite_brands_lower:
            logger.debug(f"Brand boost: {item_brand} in {favorite_brands}")
            return self.BRAND_BOOST_MULTIPLIER

        return 1.0

    def _apply_budget_penalty(
        self,
        score: float,
        item_price: float,
        budget_range: str,
    ) -> float:
        """
        Применить penalty для超出 бюджета вещей.

        Args:
            score: Текущая оценка
            item_price: Цена предмета
            budget_range: Диапазон бюджета пользователя

        Returns:
            Множитель penalty (1.0 если нет penalty)
        """
        if item_price is None or item_price <= 0:
            return 1.0

        # Определяем максимальный бюджет
        max_budget = self._get_budget_limit(budget_range)
        if max_budget is None:
            return 1.0

        if item_price > max_budget:
            logger.debug(
                f"Budget penalty: price={item_price} > max={max_budget} "
                f"({budget_range})"
            )
            return self.BUDGET_PENALTY_MULTIPLIER

        return 1.0

    def _get_budget_limit(self, budget_range: str) -> Optional[float]:
        """
        Получить лимит бюджета по диапазону.

        Args:
            budget_range: Диапазон бюджета (economy, medium, premium)

        Returns:
            Лимит бюджета или None для premium
        """
        budget_limits = {
            "economy": self.BUDGET_ECONOMY_MAX,
            "medium": self.BUDGET_MEDIUM_MAX,
            "premium": None,  # Без ограничений
        }
        return budget_limits.get(budget_range.lower())

    def rank_with_preferences(
        self,
        items: List[Dict[str, Any]],
        scores: List[float],
        preferences: Optional[UserPreferences] = None,
    ) -> RankingResult:
        """
        Полный пайплайн ранжирования с учётом предпочтений.

        Args:
            items: Список предметов с метаданными
            scores: Базовые оценки от ML модели
            preferences: Предпочтения пользователя (опционально)

        Returns:
            Результат ранжирования
        """
        start_time = datetime.utcnow()
        applied_filters = []

        if not preferences:
            # Без предпочтений — просто сортировка по score
            ranked_items = [
                RankedItem(id=item.get("id", i), base_score=score, adjusted_score=score)
                for i, (item, score) in enumerate(zip(items, scores))
            ]
            ranked_items.sort(key=lambda x: x.adjusted_score, reverse=True)
        else:
            # С предпочтениями
            ranked_items = self.apply_preferences(items, preferences, scores)

            # Собираем статистику применённых фильтров
            if preferences.style_preferences:
                applied_filters.append(f"style:{preferences.style_preferences}")
            if preferences.favorite_brands:
                applied_filters.append(f"brands:{preferences.favorite_brands}")
            if preferences.budget_range:
                applied_filters.append(f"budget:{preferences.budget_range}")

        processing_time = (datetime.utcnow() - start_time).total_seconds() * 1000

        return RankingResult(
            items=ranked_items,
            applied_filters=applied_filters,
            processing_time_ms=processing_time,
        )

    def get_stats(self) -> Dict[str, Any]:
        """
        Получить статистику ранжирования.

        Returns:
            Статистика по применённым boost/penalty
        """
        return self._stats.copy()


# Глобальный инстанс для использования в приложении
preference_rank_service = PreferenceRankService()


def rank_with_preferences(
    items: List[Dict[str, Any]],
    scores: List[float],
    preferences: Optional[UserPreferences] = None,
) -> RankingResult:
    """
    Утилита для ранжирования с учётом предпочтений.

    Args:
        items: Список предметов с метаданными
        scores: Базовые оценки от ML модели
        preferences: Предпочтения пользователя

    Returns:
        Результат ранжирования
    """
    return preference_rank_service.rank_with_preferences(
        items=items,
        scores=scores,
        preferences=preferences,
    )
