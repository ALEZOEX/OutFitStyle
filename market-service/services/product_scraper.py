"""
Сервис парсинга товаров с маркетплейсов (Wildberries, Ozon) через pyRustScraperApi.
"""
import logging
import re
import json
from typing import Optional, Dict, Any, List
from datetime import datetime, timedelta

from bs4 import BeautifulSoup

from core.config import settings

logger = logging.getLogger(__name__)


class ProductScraperError(Exception):
    """Ошибка парсинга товара."""
    pass


class ProductScraperService:
    """
    Сервис для парсинга товаров с маркетплейсов.
    
    Поддерживаемые маркетплейсы:
    - Wildberries (https://www.wildberries.ru/catalog/...)
    - Ozon (https://www.ozon.ru/product/...)
    - Короткие ссылки: wb/12345678, oz/12345678
    """

    def __init__(self, api_token: Optional[str] = None):
        """
        Инициализация сервиса парсинга.
        
        Args:
            api_token: Токен для pyRustScraperApi (опционально для бесплатного доступа)
        """
        self.api_token = api_token or settings.PYRUSTSCRAPERAPI_TOKEN
        self.timeout = settings.PYRUSTSCRAPERAPI_TIMEOUT
        self._client = None
    
    def _get_client(self):
        """Ленивая инициализация клиента pyRustScraperApi."""
        if self._client is None:
            try:
                from pyRustScraperApi import Client
                from pyRustScraperApi.models import Order
                
                self._client = Client(api_token=self.api_token)
                self._Order = Order
                logger.info("pyRustScraperApi client initialized")
            except ImportError as e:
                logger.error(f"pyRustScraperApi not installed: {e}")
                raise ProductScraperError(
                    "Сервис парсинга недоступен. Установите pyRustScraperApi: pip install pyRustScraperApi"
                )
        return self._client
    
    def _detect_marketplace(self, url: str) -> str:
        """
        Определение маркетплейса по URL.
        
        Args:
            url: URL товара
            
        Returns:
            Название маркетплейса: 'wildberries', 'ozon'
            
        Raises:
            ProductScraperError: Если маркетплейс не поддерживается
        """
        url_lower = url.lower().strip()
        
        # Wildberries
        if 'wildberries.ru' in url_lower or url_lower.startswith('wb/'):
            return 'wildberries'
        
        # Ozon
        if 'ozon.ru' in url_lower or url_lower.startswith('oz/'):
            return 'ozon'
        
        raise ProductScraperError(
            f"Неподдерживаемый маркетплейс. URL: {url}. "
            f"Поддерживаются: wildberries.ru, ozon.ru"
        )
    
    def _normalize_url(self, url: str, marketplace: str) -> str:
        """
        Нормализация URL (преобразование коротких ссылок в полные).
        
        Args:
            url: Исходный URL
            marketplace: Название маркетплейса
            
        Returns:
            Полный URL
        """
        if marketplace == 'wildberries' and url.startswith('wb/'):
            product_id = url[3:].strip()
            return f"https://www.wildberries.ru/catalog/{product_id}/detail.aspx"
        
        if marketplace == 'ozon' and url.startswith('oz/'):
            product_id = url[3:].strip()
            return f"https://www.ozon.ru/product/{product_id}"
        
        return url
    
    def _detect_category(self, parsed_data: Dict[str, Any]) -> str:
        """
        Определение категории товара на основе названия и описания.
        
        Args:
            parsed_data: Распарсенные данные товара
            
        Returns:
            Категория: 'top', 'bottom', 'shoes', 'accessories', 'outerwear', 'headwear'
        """
        name = (parsed_data.get('name') or '').lower()
        description = (parsed_data.get('description') or '').lower()
        category_from_api = (parsed_data.get('category') or '').lower()
        
        text = f"{name} {description} {category_from_api}"
        
        # Верхняя одежда
        outerwear_keywords = ['пальто', 'куртка', 'пуховик', 'плащ', 'ветровка', 'кепка', 'жилет', 'шуба', 'дубленка']
        if any(kw in text for kw in outerwear_keywords):
            return 'outerwear'
        
        # Обувь
        shoes_keywords = ['ботинки', 'кроссовки', 'туфли', 'сапоги', 'ботильоны', 'сандалии', 'шлепанцы', 'тапки', 'угги']
        if any(kw in text for kw in shoes_keywords):
            return 'shoes'
        
        # Головные уборы
        headwear_keywords = ['шапка', 'кепка', 'шляпа', 'панама', 'бандана', 'повязка', 'шарф']
        if any(kw in text for kw in headwear_keywords):
            return 'headwear'
        
        # Аксессуары
        accessories_keywords = ['сумка', 'ремень', 'перчатки', 'очки', 'украшение', 'кошелек', 'портмоне', 'зонт']
        if any(kw in text for kw in accessories_keywords):
            return 'accessories'
        
        # Низ (брюки, юбки, шорты)
        bottom_keywords = ['брюки', 'джинсы', 'юбка', 'шорты', 'легинсы', 'колготки', 'штаны']
        if any(kw in text for kw in bottom_keywords):
            return 'bottom'
        
        # Верх (футболки, рубашки, свитера) - по умолчанию
        return 'top'
    
    def _parse_result(self, result: Any, marketplace: str) -> Dict[str, Any]:
        """
        Преобразование результата парсинга в Product dict.
        
        Args:
            result: Результат от pyRustScraperApi
            marketplace: Название маркетплейса
            
        Returns:
            Словарь с данными товара
        """
        # Извлекаем данные из результата
        # Структура зависит от версии pyRustScraperApi
        try:
            # Пробуем получить атрибуты как объекты или словари
            name = getattr(result, 'name', None) or getattr(result, 'title', None) or 'Товар'
            brand = getattr(result, 'brand', None) or getattr(result, 'manufacturer', None) or 'Unknown'
            price = getattr(result, 'price', None)
            
            # Цена может быть строкой или числом
            if isinstance(price, str):
                # Удаляем валюту и пробелы: "1 234 ₽" -> 1234
                price_str = re.sub(r'[^\d,.]', '', price.replace(',', '.'))
                try:
                    price = float(price_str) if price_str else 0.0
                except ValueError:
                    price = 0.0
            elif price is None:
                price = 0.0
            
            # Изображения
            images = getattr(result, 'images', None) or getattr(result, 'image_urls', None) or []
            if isinstance(images, str):
                images = [images]
            
            # Наличие
            in_stock = getattr(result, 'in_stock', None) or getattr(result, 'available', True)
            
            # URL
            url = getattr(result, 'url', None) or getattr(result, 'product_url', None) or ''
            
            # Описание
            description = getattr(result, 'description', None) or getattr(result, 'details', None) or ''
            
        except Exception as e:
            logger.error(f"Error parsing result: {e}")
            raise ProductScraperError(f"Ошибка обработки результата парсинга: {e}")
        
        product_data = {
            'name': str(name),
            'brand': str(brand),
            'price': float(price),
            'category': self._detect_category({
                'name': name,
                'description': description,
                'category': '',
            }),
            'image_urls': list(images) if images else [],
            'source_url': str(url),
            'source': marketplace,
            'in_stock': bool(in_stock),
            'description': str(description) if description else None,
        }
        
        return product_data
    
    async def parse_product_url(self, url: str) -> Dict[str, Any]:
        """
        Распарсить товар по ссылке.
        
        Args:
            url: URL товара на маркетплейсе
            
        Returns:
            Словарь с данными товара:
            - name: Название товара
            - brand: Бренд
            - price: Цена
            - category: Категория (top/bottom/shoes/accessories/outerwear/headwear)
            - image_urls: Список URL изображений
            - source_url: Исходный URL
            - source: Маркетплейс (wildberries/ozon)
            - in_stock: Наличие
            - description: Описание
            
        Raises:
            ProductScraperError: Ошибка парсинга
        """
        # Валидация URL
        if not url or not isinstance(url, str):
            raise ProductScraperError("Некорректный URL")
        
        url = url.strip()
        
        # Определение маркетплейса
        marketplace = self._detect_marketplace(url)
        
        # Нормализация URL
        full_url = self._normalize_url(url, marketplace)
        
        logger.info(f"Parsing product from {marketplace}: {full_url}")
        
        try:
            # Отправка заказа на парсинг через pyRustScraperApi
            client = self._get_client()
            
            # Создаем заказ
            order = self._Order([full_url])
            order_hash = client.send_order(order)
            
            # Получаем результат (с ожиданием)
            result = client.get_result(order_hash)
            
            # Преобразуем в Product dict
            product_data = self._parse_result(result, marketplace)
            product_data['source_url'] = full_url
            
            logger.info(f"Successfully parsed product: {product_data['name']}")
            return product_data
            
        except ProductScraperError:
            raise
        except Exception as e:
            logger.error(f"Error parsing product URL {url}: {e}", exc_info=True)
            raise ProductScraperError(f"Ошибка парсинга товара: {e}")


class ProductImportLimiter:
    """
    Лимитер импорта товаров для пользователей.
    Использует Redis для подсчета импортов за день.
    """
    
    def __init__(self, redis_service):
        """
        Инициализация лимитера.
        
        Args:
            redis_service: Сервис Redis
        """
        self.redis = redis_service
        self.limit = settings.PRODUCT_IMPORT_LIMIT_PER_DAY
    
    def _get_key(self, user_id: int) -> str:
        """Генерация ключа Redis для пользователя."""
        today = datetime.utcnow().strftime('%Y-%m-%d')
        return f"product_import:user:{user_id}:date:{today}"
    
    async def check_limit(self, user_id: int) -> tuple[bool, int]:
        """
        Проверка лимита импорта для пользователя.
        
        Args:
            user_id: ID пользователя
            
        Returns:
            (allowed, remaining): 
            - allowed: True если импорт разрешен
            - remaining: Оставшееся количество импортов
        """
        key = self._get_key(user_id)
        
        try:
            # Получаем текущее количество импортов
            client = await self.redis._get_client()
            if client is None:
                # Если Redis недоступен, разрешаем импорт
                logger.warning("Redis unavailable for import limit check, allowing import")
                return True, self.limit
            
            current_count = await client.get(key)
            current_count = int(current_count) if current_count else 0
            
            remaining = max(0, self.limit - current_count)
            allowed = remaining > 0
            
            logger.debug(f"User {user_id} import limit: {current_count}/{self.limit}, remaining: {remaining}")
            return allowed, remaining
            
        except Exception as e:
            logger.error(f"Error checking import limit for user {user_id}: {e}")
            # В случае ошибки разрешаем импорт (graceful degradation)
            return True, self.limit
    
    async def increment_import(self, user_id: int):
        """
        Увеличение счетчика импортов пользователя.
        
        Args:
            user_id: ID пользователя
        """
        key = self._get_key(user_id)
        
        try:
            client = await self.redis._get_client()
            if client is None:
                return
            
            # Увеличиваем счетчик и устанавливаем TTL до конца дня
            now = datetime.utcnow()
            tomorrow = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
            ttl = int((tomorrow - now).total_seconds())
            
            await client.incr(key)
            await client.expire(key, ttl)
            
            logger.debug(f"Incremented import count for user {user_id}")
            
        except Exception as e:
            logger.error(f"Error incrementing import count for user {user_id}: {e}")
            # Игнорируем ошибку, чтобы не блокировать импорт


# Глобальные экземпляры
product_scraper_service = ProductScraperService()


def get_scraper_service() -> ProductScraperService:
    """Dependency injection для ProductScraperService."""
    return product_scraper_service
