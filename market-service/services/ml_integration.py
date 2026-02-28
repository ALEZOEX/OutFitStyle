"""
Сервис интеграции с ML-service для рекомендаций.
"""
import logging
from typing import List, Dict, Any, Optional

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

from core.config import settings

logger = logging.getLogger(__name__)


class MLServiceError(Exception):
    """Ошибка ML сервиса."""
    pass


class MLIntegrationService:
    """Сервис интеграции с ML-service."""
    
    def __init__(self):
        self.base_url = settings.ML_SERVICE_URL
        self.timeout = settings.ML_SERVICE_TIMEOUT
        self._client: Optional[httpx.AsyncClient] = None
    
    async def _get_client(self) -> httpx.AsyncClient:
        """Получение HTTP клиента."""
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                base_url=self.base_url,
                timeout=httpx.Timeout(self.timeout),
            )
        return self._client
    
    async def close(self):
        """Закрытие клиента."""
        if self._client and not self._client.is_closed:
            await self._client.aclose()
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type(httpx.RequestError),
    )
    async def get_recommendations(
        self,
        user_id: int,
        weather_data: Dict[str, Any],
        user_preferences: Dict[str, Any],
        limit: int = 10,
    ) -> List[Dict[str, Any]]:
        """
        Получение рекомендаций от ML сервиса.
        
        Args:
            user_id: ID пользователя
            weather_data: Данные о погоде
            user_preferences: Предпочтения пользователя
            limit: Количество рекомендаций
            
        Returns:
            Список рекомендаций (категории товаров)
        """
        client = await self._get_client()
        
        # Формируем запрос к ML сервису
        # Используем endpoint /api/recommend для получения рекомендаций по комбинациям
        # или создаем свой формат запроса
        
        request_payload = {
            "user_id": user_id,
            "context": {
                "temperature": weather_data.get("temperature", 20),
                "humidity": weather_data.get("humidity", 50),
                "weather_condition": weather_data.get("weather", "clear"),
                "activity": user_preferences.get("activity", "daily"),
            },
            "user_preferences": {
                "style_preferences": user_preferences.get("style_preferences", ["casual"]),
                "budget_range": user_preferences.get("budget_range"),
                "favorite_brands": user_preferences.get("favorite_brands", []),
            },
            "top_k": limit,
        }
        
        try:
            response = await client.post(
                "/api/recommend",
                json=request_payload,
                headers={"X-User-Id": str(user_id)},
            )
            response.raise_for_status()
            data = response.json()
            
            # ML сервис возвращает outfit рекомендации
            # Преобразуем их в категории для поиска товаров
            outfits = data.get("outfits", [])
            
            # Извлекаем категории из рекомендаций
            categories = []
            for outfit in outfits[:limit]:
                # outfit содержит top, bottom, outerwear, footwear
                for item_type in ["top", "bottom", "outerwear", "footwear"]:
                    if item_type in outfit:
                        categories.append({
                            "category": self._map_category(item_type),
                            "style": outfit.get("style", "casual"),
                            "score": outfit.get("score", 0.5),
                        })
            
            logger.info(
                f"ML recommendations for user {user_id}: {len(categories)} categories"
            )
            return categories
            
        except httpx.HTTPStatusError as e:
            logger.error(f"ML service HTTP error: {e.response.status_code} - {e.response.text}")
            raise MLServiceError(f"ML service error: {e.response.status_code}")
        except httpx.RequestError as e:
            logger.error(f"ML service request error: {e}")
            raise MLServiceError(f"ML service unavailable: {e}")
    
    def _map_category(self, ml_category: str) -> str:
        """Маппинг категорий ML сервиса на категории маркета."""
        mapping = {
            "top": "top",
            "bottom": "bottom",
            "outerwear": "outerwear",
            "footwear": "shoes",
            "headwear": "headwear",
            "accessory": "accessories",
        }
        return mapping.get(ml_category, "accessories")
    
    async def health_check(self) -> bool:
        """Проверка доступности ML сервиса."""
        try:
            client = await self._get_client()
            response = await client.get("/health")
            return response.status_code == 200
        except Exception as e:
            logger.error(f"ML service health check failed: {e}")
            return False


# Глобальный экземпляр сервиса
ml_integration_service = MLIntegrationService()
