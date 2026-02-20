"""
Сервис для управления рейтингом рекомендаций и фильтрации вещей.

Интегрируется с Go backend для:
- Получения оценок пользователей
- Фильтрации вещей с низким рейтингом (< -5)
- Отправки событий о негативных оценках для переобучения модели
"""

import logging
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from datetime import datetime
import json

logger = logging.getLogger(__name__)


@dataclass
class RatingEvent:
    """Событие оценки рекомендации"""
    user_id: str
    recommendation_id: str
    rating: int  # 1-5
    quality_score: int  # -10 до +10
    outfit_items: List[int]
    feedback: Optional[str] = None
    thermal_feedback: Optional[str] = None
    timestamp: datetime = None

    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.utcnow()


class RatingService:
    """
    Сервис для обработки рейтингов и фильтрации вещей.
    
    Основные функции:
    1. Фильтрация вещей с низким рейтингом (< -5)
    2. Обработка негативных оценок для переобучения
    3. Агрегация статистики по вещам
    """

    def __init__(self, redis_client=None, threshold: float = -5.0):
        """
        Инициализация сервиса.
        
        Args:
            redis_client: Redis клиент для кэширования (опционально)
            threshold: Порог quality_score для фильтрации (по умолчанию -5)
        """
        self.redis_client = redis_client
        self.threshold = threshold
        self._low_quality_cache: Dict[str, List[int]] = {}
        self._rating_stats: Dict[str, Dict[str, Any]] = {}

    def filter_low_rated_items(
        self,
        user_id: str,
        items: List[Dict[str, Any]],
        low_rated_item_ids: List[int],
    ) -> List[Dict[str, Any]]:
        """
        Исключить вещи с рейтингом < -5 из списка кандидатов.
        
        Args:
            user_id: ID пользователя
            items: Список вещей-кандидатов
            low_rated_item_ids: ID вещей с низким рейтингом
            
        Returns:
            Отфильтрованный список вещей
        """
        if not low_rated_item_ids:
            return items

        filtered_items = [
            item for item in items
            if item.get('id') not in low_rated_item_ids
        ]

        logger.info(
            f"Фильтрация вещей для пользователя {user_id}: "
            f"{len(items)} -> {len(filtered_items)} (исключено {len(items) - len(filtered_items)})"
        )

        return filtered_items

    def on_negative_rating(
        self,
        user_id: str,
        outfit_items: List[int],
        rating: int,
        quality_score: int,
    ) -> bool:
        """
        Обработать негативную оценку (< -5).
        
        При плохой оценке помечает вещи как "не подходящие" для пользователя.
        
        Args:
            user_id: ID пользователя
            outfit_items: ID вещей в наряде
            rating: Оценка 1-5
            quality_score: Конвертированная оценка -10..+10
            
        Returns:
            True если требуется переобучение модели
        """
        if quality_score >= self.threshold:
            return False

        logger.info(
            f"Негативная оценка от пользователя {user_id}: "
            f"rating={rating}, quality_score={quality_score}, "
            f"items={outfit_items}"
        )

        # Кэшируем вещи с низким рейтингом
        if user_id not in self._low_quality_cache:
            self._low_quality_cache[user_id] = []

        for item_id in outfit_items:
            if item_id not in self._low_quality_cache[user_id]:
                self._low_quality_cache[user_id].append(item_id)

        # Требуется переобучение если оценка очень низкая
        needs_retrain = quality_score <= -7
        if needs_retrain:
            logger.warning(
                f"Требуется переобучение для пользователя {user_id}: "
                f"quality_score={quality_score}"
            )

        return needs_retrain

    def update_rating_stats(
        self,
        user_id: str,
        recommendation_id: str,
        outfit_items: List[int],
        quality_score: int,
    ):
        """
        Обновить статистику оценок для вещей.
        
        Args:
            user_id: ID пользователя
            recommendation_id: ID рекомендации
            outfit_items: ID вещей в наряде
            quality_score: Оценка качества -10..+10
        """
        for item_id in outfit_items:
            item_key = f"{user_id}:{item_id}"

            if item_key not in self._rating_stats:
                self._rating_stats[item_key] = {
                    'user_id': user_id,
                    'item_id': item_id,
                    'total_ratings': 0,
                    'total_score': 0,
                    'avg_score': 0.0,
                    'last_rated': None,
                }

            stats = self._rating_stats[item_key]
            stats['total_ratings'] += 1
            stats['total_score'] += quality_score
            stats['avg_score'] = stats['total_score'] / stats['total_ratings']
            stats['last_rated'] = datetime.utcnow().isoformat()

        logger.debug(
            f"Обновлена статистика для {len(outfit_items)} вещей пользователя {user_id}"
        )

    def get_user_low_rated_items(self, user_id: str) -> List[int]:
        """
        Получить ID вещей с низким рейтингом для пользователя.
        
        Args:
            user_id: ID пользователя
            
        Returns:
            Список ID вещей с rating < threshold
        """
        return self._low_quality_cache.get(user_id, [])

    def get_item_avg_score(
        self,
        user_id: str,
        item_id: int,
    ) -> Optional[float]:
        """
        Получить средний score для вещи.
        
        Args:
            user_id: ID пользователя
            item_id: ID вещи
            
        Returns:
            Средний score или None если нет оценок
        """
        item_key = f"{user_id}:{item_id}"
        stats = self._rating_stats.get(item_key)
        return stats['avg_score'] if stats else None

    def clear_user_cache(self, user_id: str):
        """
        Очистить кэш для пользователя.
        
        Используется при переобучении модели.
        """
        if user_id in self._low_quality_cache:
            del self._low_quality_cache[user_id]

        items_to_remove = [
            key for key in self._rating_stats
            if key.startswith(f"{user_id}:")
        ]
        for key in items_to_remove:
            del self._rating_stats[key]

        logger.info(f"Очищен кэш для пользователя {user_id}")

    def retrain_model(
        self,
        user_id: str,
        negative_items: List[int],
    ) -> Dict[str, Any]:
        """
        Инициировать переобучение модели для пользователя.
        
        Args:
            user_id: ID пользователя
            negative_items: ID вещей с негативными оценками
            
        Returns:
            Информация о переобучении
        """
        logger.info(
            f"Инициация переобучения для пользователя {user_id}: "
            f"{len(negative_items)} негативных вещей"
        )

        # В реальной реализации здесь будет вызов ML пайплайна
        # Пока просто логируем
        return {
            'user_id': user_id,
            'negative_items_count': len(negative_items),
            'status': 'pending',
            'timestamp': datetime.utcnow().isoformat(),
        }

    def process_rating_event(self, event: RatingEvent) -> Dict[str, Any]:
        """
        Обработать событие оценки.
        
        Комплексная обработка:
        1. Обновление статистики
        2. Фильтрация при негативной оценке
        3. Решение о переобучении
        
        Args:
            event: Событие оценки
            
        Returns:
            Результат обработки
        """
        # Обновляем статистику
        self.update_rating_stats(
            user_id=event.user_id,
            recommendation_id=event.recommendation_id,
            outfit_items=event.outfit_items,
            quality_score=event.quality_score,
        )

        # Обрабатываем негативную оценку
        needs_retrain = self.on_negative_rating(
            user_id=event.user_id,
            outfit_items=event.outfit_items,
            rating=event.rating,
            quality_score=event.quality_score,
        )

        result = {
            'processed': True,
            'user_id': event.user_id,
            'quality_score': event.quality_score,
            'low_rated_items': self.get_user_low_rated_items(event.user_id),
            'needs_retrain': needs_retrain,
        }

        if needs_retrain:
            result['retrain_info'] = self.retrain_model(
                user_id=event.user_id,
                negative_items=event.outfit_items,
            )

        return result


# Глобальный инстанс для использования в приложении
rating_service = RatingService()


def filter_low_rated_items(
    user_id: str,
    items: List[Dict[str, Any]],
    low_rated_item_ids: List[int],
) -> List[Dict[str, Any]]:
    """
    Утилита для фильтрации вещей с низким рейтингом.
    
    Args:
        user_id: ID пользователя
        items: Список вещей-кандидатов
        low_rated_item_ids: ID вещей с низким рейтингом
        
    Returns:
        Отфильтрованный список вещей
    """
    return rating_service.filter_low_rated_items(
        user_id=user_id,
        items=items,
        low_rated_item_ids=low_rated_item_ids,
    )


def on_negative_rating(
    user_id: str,
    outfit_items: List[int],
    rating: int,
    quality_score: int,
) -> bool:
    """
    Утилита для обработки негативной оценки.
    
    Args:
        user_id: ID пользователя
        outfit_items: ID вещей в наряде
        rating: Оценка 1-5
        quality_score: Конвертированная оценка -10..+10
        
    Returns:
        True если требуется переобучение
    """
    return rating_service.on_negative_rating(
        user_id=user_id,
        outfit_items=outfit_items,
        rating=rating,
        quality_score=quality_score,
    )
