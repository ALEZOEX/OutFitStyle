"""
Сервис для работы с Redis (кэширование, корзина).
"""
import json
import logging
from typing import Optional, Dict, Any, List

import redis.asyncio as redis
from tenacity import retry, stop_after_attempt, wait_exponential

from core.config import settings

logger = logging.getLogger(__name__)


class RedisService:
    """Сервис для работы с Redis."""
    
    def __init__(self):
        self.redis_url = settings.REDIS_URL
        self.cache_ttl = settings.REDIS_CACHE_TTL
        self.cart_ttl = settings.REDIS_CART_TTL
        self._client: Optional[redis.Redis] = None
    
    async def connect(self):
        """Подключение к Redis."""
        try:
            self._client = redis.from_url(
                self.redis_url,
                encoding="utf-8",
                decode_responses=True,
            )
            await self._client.ping()
            logger.info(f"Connected to Redis at {self.redis_url}")
        except Exception as e:
            logger.error(f"Failed to connect to Redis: {e}")
            self._client = None
    
    async def disconnect(self):
        """Отключение от Redis."""
        if self._client:
            await self._client.close()
    
    async def _get_client(self) -> redis.Redis:
        """Получение Redis клиента."""
        if self._client is None:
            await self.connect()
        return self._client
    
    # ═══════════════════════════════════════════
    # CACHE OPERATIONS
    # ═══════════════════════════════════════════
    
    async def get_cached(self, key: str) -> Optional[Any]:
        """Получение данных из кэша."""
        try:
            client = await self._get_client()
            if client is None:
                return None
            
            data = await client.get(key)
            if data:
                return json.loads(data)
            return None
        except Exception as e:
            logger.error(f"Redis get_cached error for key {key}: {e}")
            return None
    
    async def set_cached(
        self,
        key: str,
        value: Any,
        ttl: Optional[int] = None,
    ):
        """Сохранение данных в кэш."""
        try:
            client = await self._get_client()
            if client is None:
                return
            
            await client.setex(
                key,
                ttl or self.cache_ttl,
                json.dumps(value, ensure_ascii=False, default=str),
            )
        except Exception as e:
            logger.error(f"Redis set_cached error for key {key}: {e}")
    
    async def delete_cached(self, key: str):
        """Удаление данных из кэша."""
        try:
            client = await self._get_client()
            if client is None:
                return
            await client.delete(key)
        except Exception as e:
            logger.error(f"Redis delete_cached error for key {key}: {e}")
    
    # ═══════════════════════════════════════════
    # CART OPERATIONS
    # ═══════════════════════════════════════════
    
    def _cart_key(self, user_id: int) -> str:
        """Генерация ключа корзины."""
        return f"cart:user:{user_id}"
    
    async def get_cart(self, user_id: int) -> Optional[Dict[str, Any]]:
        """Получение корзины пользователя."""
        key = self._cart_key(user_id)
        return await self.get_cached(key)
    
    async def set_cart(self, user_id: int, cart_data: Dict[str, Any]):
        """Сохранение корзины пользователя."""
        key = self._cart_key(user_id)
        await self.set_cached(key, cart_data, ttl=self.cart_ttl)
    
    async def delete_cart(self, user_id: int):
        """Удаление корзины пользователя."""
        key = self._cart_key(user_id)
        await self.delete_cached(key)
    
    async def add_to_cart(
        self,
        user_id: int,
        product_id: str,
        size: Optional[str],
        color: Optional[str],
        quantity: int,
    ) -> Dict[str, Any]:
        """Добавление товара в корзину."""
        cart = await self.get_cart(user_id) or {"items": []}
        
        # Проверяем, есть ли уже такой товар с такими параметрами
        existing_item = None
        for item in cart["items"]:
            if (
                item["product_id"] == product_id
                and item.get("size") == size
                and item.get("color") == color
            ):
                existing_item = item
                break
        
        if existing_item:
            existing_item["quantity"] += quantity
        else:
            cart["items"].append({
                "product_id": product_id,
                "size": size,
                "color": color,
                "quantity": quantity,
            })
        
        await self.set_cart(user_id, cart)
        return cart
    
    async def update_cart_item(
        self,
        user_id: int,
        product_id: str,
        size: Optional[str],
        color: Optional[str],
        quantity: int,
    ) -> Dict[str, Any]:
        """Обновление количества товара в корзине."""
        cart = await self.get_cart(user_id) or {"items": []}
        
        for item in cart["items"]:
            if (
                item["product_id"] == product_id
                and item.get("size") == size
                and item.get("color") == color
            ):
                item["quantity"] = quantity
                break
        
        await self.set_cart(user_id, cart)
        return cart
    
    async def remove_from_cart(
        self,
        user_id: int,
        product_id: str,
        size: Optional[str] = None,
        color: Optional[str] = None,
    ) -> Dict[str, Any]:
        """Удаление товара из корзины."""
        cart = await self.get_cart(user_id) or {"items": []}
        
        new_items = []
        for item in cart["items"]:
            # Если size и color не указаны, удаляем все товары с этим product_id
            if size is None and color is None:
                if item["product_id"] != product_id:
                    new_items.append(item)
            else:
                # Удаляем только конкретный вариант
                if not (
                    item["product_id"] == product_id
                    and item.get("size") == size
                    and item.get("color") == color
                ):
                    new_items.append(item)
        
        cart["items"] = new_items
        await self.set_cart(user_id, cart)
        return cart
    
    async def clear_cart(self, user_id: int):
        """Очистка корзины."""
        await self.set_cart(user_id, {"items": []})
    
    # ═══════════════════════════════════════════
    # PRODUCT CACHE
    # ═══════════════════════════════════════════
    
    def _product_key(self, product_id: str) -> str:
        """Генерация ключа товара."""
        return f"product:{product_id}"
    
    async def cache_product(self, product_id: str, product_data: Dict[str, Any]):
        """Кэширование товара."""
        key = self._product_key(product_id)
        await self.set_cached(key, product_data, ttl=self.cache_ttl)
    
    async def get_cached_product(self, product_id: str) -> Optional[Dict[str, Any]]:
        """Получение кэшированного товара."""
        key = self._product_key(product_id)
        return await self.get_cached(key)
    
    async def invalidate_product_cache(self, product_id: str):
        """Инвалидация кэша товара."""
        key = self._product_key(product_id)
        await self.delete_cached(key)
    
    # ═══════════════════════════════════════════
    # HEALTH CHECK
    # ═══════════════════════════════════════════
    
    async def health_check(self) -> bool:
        """Проверка подключения к Redis."""
        try:
            client = await self._get_client()
            if client is None:
                return False
            await client.ping()
            return True
        except Exception as e:
            logger.error(f"Redis health check failed: {e}")
            return False


# Глобальный экземпляр сервиса
redis_service = RedisService()
