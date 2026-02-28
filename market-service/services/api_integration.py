"""
Сервис интеграции с основным API для проверки пользователей.
"""
import logging
from typing import Optional, Dict, Any

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

from core.config import settings

logger = logging.getLogger(__name__)


class APIServiceError(Exception):
    """Ошибка API сервиса."""
    pass


class APIService:
    """Сервис интеграции с основным Go API."""
    
    def __init__(self):
        self.base_url = settings.API_SERVICE_URL
        self.timeout = settings.API_SERVICE_TIMEOUT
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
        wait=wait_exponential(multiplier=1, min=1, max=5),
        retry=retry_if_exception_type(httpx.RequestError),
    )
    async def verify_user(self, user_id: int, auth_token: Optional[str] = None) -> bool:
        """
        Проверка существования пользователя.
        
        Args:
            user_id: ID пользователя
            auth_token: Токен авторизации (опционально)
            
        Returns:
            True если пользователь существует
        """
        client = await self._get_client()
        
        headers = {}
        if auth_token:
            headers["Authorization"] = f"Bearer {auth_token}"
        
        try:
            response = await client.get(
                f"/api/v1/users/{user_id}",
                headers=headers,
            )
            
            if response.status_code == 200:
                return True
            elif response.status_code == 404:
                logger.warning(f"User {user_id} not found in API service")
                return False
            else:
                logger.warning(f"Unexpected status code for user {user_id}: {response.status_code}")
                return False
                
        except httpx.RequestError as e:
            logger.error(f"API service request error: {e}")
            # В случае недоступности API, разрешаем доступ (graceful degradation)
            logger.warning("API service unavailable, allowing access by default")
            return True
    
    async def get_user_profile(self, user_id: int) -> Optional[Dict[str, Any]]:
        """
        Получение профиля пользователя.
        
        Args:
            user_id: ID пользователя
            
        Returns:
            Профиль пользователя или None
        """
        client = await self._get_client()
        
        try:
            response = await client.get(f"/api/v1/users/{user_id}")
            
            if response.status_code == 200:
                return response.json()
            else:
                return None
                
        except httpx.RequestError as e:
            logger.error(f"API service request error: {e}")
            return None
    
    async def health_check(self) -> bool:
        """Проверка доступности API сервиса."""
        try:
            client = await self._get_client()
            response = await client.get("/health")
            return response.status_code == 200
        except Exception as e:
            logger.error(f"API service health check failed: {e}")
            return False


# Глобальный экземпляр сервиса
api_service = APIService()
