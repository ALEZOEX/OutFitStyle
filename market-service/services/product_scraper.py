"""
Сервис парсинга товаров с маркетплейсов (WB/Ozon).
Интеграция с Scraper API (WildSearch Crawler).
"""
import logging
from typing import Optional, Dict, Any

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

from core.config import settings

logger = logging.getLogger(__name__)


class ScraperError(Exception):
    """Ошибка парсинга товара."""
    pass


class ProductScraper:
    """Сервис парсинга товаров через Scraper API."""

    def __init__(self, scraper_api_url: Optional[str] = None):
        """
        Инициализация скрепера.
        
        Args:
            scraper_api_url: URL Scraper API сервиса
        """
        self.scraper_api_url = scraper_api_url or settings.SCRAPER_API_URL
        self.timeout = httpx.Timeout(60.0)  # 60 секунд на парсинг
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        """Получение HTTP клиента."""
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                base_url=self.scraper_api_url,
                timeout=self.timeout,
            )
        return self._client

    async def close(self):
        """Закрытие клиента."""
        if self._client and not self._client.is_closed:
            await self._client.aclose()

    @retry(
        stop=stop_after_attempt(2),
        wait=wait_exponential(multiplier=1, min=1, max=3),
        retry=retry_if_exception_type(httpx.RequestError),
    )
    async def parse_url(self, url: str, marketplace: str = "auto") -> Optional[Dict[str, Any]]:
        """
        Распарсить товар по ссылке.
        
        Args:
            url: Ссылка на товар (WB или Ozon)
            marketplace: Маркетплейс (auto, wb, ozon)
            
        Returns:
            Данные товара или None
            
        Raises:
            ScraperError: При ошибке парсинга
        """
        client = await self._get_client()
        
        logger.info(f"Парсинг товара: url={url}, marketplace={marketplace}")
        
        try:
            response = await client.post(
                "/api/v1/scraper/parse",
                json={
                    "url": url,
                    "marketplace": marketplace
                },
            )
            
            if response.status_code != 200:
                raise ScraperError(f"HTTP {response.status_code}: {response.text}")
            
            data = response.json()
            
            if data.get("status") != "success":
                error_msg = data.get("error", "Неизвестная ошибка парсинга")
                logger.error(f"Ошибка парсинга: {error_msg}")
                raise ScraperError(error_msg)
            
            product = data.get("product")
            
            if not product:
                raise ScraperError("Пустой результат парсинга")
            
            logger.info(f"Успешный парсинг: {product.get('name', 'Unknown')}")
            
            return product
        
        except httpx.TimeoutException:
            logger.error("Таймаут парсинга (60 сек)")
            raise ScraperError("Таймаут парсинга (60 сек)")
        except httpx.RequestError as e:
            logger.error(f"Ошибка соединения с Scraper API: {e}")
            raise ScraperError(f"Ошибка соединения: {str(e)}")
        except ScraperError:
            raise
        except Exception as e:
            logger.exception(f"Неожиданная ошибка парсинга: {e}")
            raise ScraperError(f"Ошибка парсинга: {str(e)}")

    async def health_check(self) -> bool:
        """Проверка доступности Scraper API."""
        try:
            client = await self._get_client()
            response = await client.get("/health")
            return response.status_code == 200
        except Exception as e:
            logger.error(f"Scraper API health check failed: {e}")
            return False


# Глобальный экземпляр сервиса
product_scraper = ProductScraper()


# Dependency для FastAPI
async def get_scraper_service() -> ProductScraper:
    """Получить экземпляр сервиса парсинга."""
    return product_scraper
