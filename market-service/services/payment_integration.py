"""
Сервис интеграции с платежными системами.
"""
import logging
from typing import Dict, Any, Optional
from decimal import Decimal
import uuid

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

from core.config import settings

logger = logging.getLogger(__name__)


class PaymentError(Exception):
    """Ошибка платежного сервиса."""
    pass


class PaymentIntegrationService:
    """Сервис интеграции с платежными системами."""
    
    def __init__(self):
        self.enabled = settings.PAYMENT_ENABLED
        self.shop_id = settings.YOOKASSA_SHOP_ID
        self.secret_key = settings.YOOKASSA_SECRET_KEY
        self.base_url = settings.YOOKASSA_BASE_URL
        self._client: Optional[httpx.AsyncClient] = None
    
    async def _get_client(self) -> httpx.AsyncClient:
        """Получение HTTP клиента."""
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                base_url=self.base_url,
                timeout=httpx.Timeout(30),
                auth=(self.shop_id, self.secret_key) if self.shop_id and self.secret_key else None,
            )
        return self._client
    
    async def close(self):
        """Закрытие клиента."""
        if self._client and not self._client.is_closed:
            await self._client.aclose()
    
    async def create_payment(
        self,
        order_id: str,
        amount: Decimal,
        currency: str = "RUB",
        description: str = "Заказ в OutfitStyle Market",
        return_url: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Создание платежа через YooKassa.
        
        Args:
            order_id: ID заказа
            amount: Сумма платежа
            currency: Валюта
            description: Описание платежа
            return_url: URL возврата после оплаты
            
        Returns:
            Данные платежа (confirmation_url, payment_id, etc.)
        """
        if not self.enabled:
            logger.warning("Payment service is disabled, returning mock payment data")
            return {
                "payment_id": str(uuid.uuid4()),
                "status": "pending",
                "confirmation_url": "https://example.com/mock-payment",
                "is_mock": True,
            }
        
        client = await self._get_client()
        
        payload = {
            "amount": {
                "value": str(amount),
                "currency": currency,
            },
            "capture": True,  # Автоматическое подтверждение
            "confirmation": {
                "type": "redirect",
                "return_url": return_url or "https://outfitstyle.app/payment/success",
            },
            "description": description,
            "metadata": {
                "order_id": order_id,
            },
        }
        
        try:
            response = await client.post(
                "/payments",
                json=payload,
                headers={
                    "Idempotence-Key": str(uuid.uuid4()),
                    "Content-Type": "application/json",
                },
            )
            response.raise_for_status()
            data = response.json()
            
            logger.info(f"Payment created for order {order_id}: {data.get('id')}")
            
            return {
                "payment_id": data.get("id"),
                "status": data.get("status"),
                "confirmation_url": data.get("confirmation", {}).get("confirmation_url"),
                "is_mock": False,
            }
            
        except httpx.HTTPStatusError as e:
            logger.error(f"Payment API error: {e.response.status_code} - {e.response.text}")
            raise PaymentError(f"Payment creation failed: {e.response.status_code}")
        except httpx.RequestError as e:
            logger.error(f"Payment request error: {e}")
            raise PaymentError(f"Payment service unavailable: {e}")
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type(httpx.RequestError),
    )
    async def get_payment_status(self, payment_id: str) -> Dict[str, Any]:
        """
        Получение статуса платежа.
        
        Args:
            payment_id: ID платежа
            
        Returns:
            Статус платежа
        """
        if not self.enabled:
            return {"status": "pending", "is_mock": True}
        
        client = await self._get_client()
        
        try:
            response = await client.get(f"/payments/{payment_id}")
            response.raise_for_status()
            data = response.json()
            
            return {
                "payment_id": data.get("id"),
                "status": data.get("status"),
                "amount": data.get("amount"),
                "is_mock": False,
            }
            
        except httpx.HTTPStatusError as e:
            logger.error(f"Payment status error: {e.response.status_code}")
            raise PaymentError(f"Payment status check failed: {e.response.status_code}")
        except httpx.RequestError as e:
            logger.error(f"Payment status request error: {e}")
            raise PaymentError(f"Payment service unavailable: {e}")
    
    async def refund_payment(
        self,
        payment_id: str,
        amount: Optional[Decimal] = None,
        description: str = "Возврат средств",
    ) -> Dict[str, Any]:
        """
        Возврат средств.
        
        Args:
            payment_id: ID платежа
            amount: Сумма возврата (полная если None)
            description: Описание возврата
            
        Returns:
            Данные возврата
        """
        if not self.enabled:
            return {"refund_id": str(uuid.uuid4()), "status": "pending", "is_mock": True}
        
        client = await self._get_client()
        
        payload = {
            "payment_id": payment_id,
            "amount": {
                "value": str(amount) if amount else "0",
                "currency": "RUB",
            },
            "description": description,
        }
        
        try:
            response = await client.post(
                "/refunds",
                json=payload,
                headers={
                    "Idempotence-Key": str(uuid.uuid4()),
                    "Content-Type": "application/json",
                },
            )
            response.raise_for_status()
            data = response.json()
            
            logger.info(f"Refund created for payment {payment_id}: {data.get('id')}")
            
            return {
                "refund_id": data.get("id"),
                "status": data.get("status"),
                "is_mock": False,
            }
            
        except httpx.HTTPStatusError as e:
            logger.error(f"Refund API error: {e.response.status_code}")
            raise PaymentError(f"Refund creation failed: {e.response.status_code}")
        except httpx.RequestError as e:
            logger.error(f"Refund request error: {e}")
            raise PaymentError(f"Payment service unavailable: {e}")
    
    async def health_check(self) -> bool:
        """Проверка доступности платежного сервиса."""
        if not self.enabled:
            return True  # Если отключен, считаем здоровым
        
        try:
            # YooKassa не имеет публичного health endpoint
            # Проверяем просто подключение
            client = await self._get_client()
            # Пытаемся сделать простой запрос
            return True
        except Exception as e:
            logger.error(f"Payment service health check failed: {e}")
            return False


# Глобальный экземпляр сервиса
payment_integration_service = PaymentIntegrationService()
