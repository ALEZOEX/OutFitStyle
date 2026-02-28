"""
Pydantic схемы для API запросов и ответов.
"""
import uuid
from datetime import datetime
from decimal import Decimal
from enum import Enum
from typing import List, Optional, Dict, Any

from pydantic import BaseModel, Field, field_validator


# ═══════════════════════════════════════════
# ENUMS
# ═══════════════════════════════════════════

class ProductCategory(str, Enum):
    """Категории товаров."""
    TOP = "top"
    BOTTOM = "bottom"
    SHOES = "shoes"
    ACCESSORIES = "accessories"
    OUTERWEAR = "outerwear"
    HEADWEAR = "headwear"


class OrderStatus(str, Enum):
    """Статусы заказа."""
    PENDING = "pending"
    PAID = "paid"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"


# ═══════════════════════════════════════════
# PRODUCT SCHEMAS
# ═══════════════════════════════════════════

class ProductBase(BaseModel):
    """Базовая схема товара."""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    brand: str = Field(..., min_length=1, max_length=100)
    category: ProductCategory
    subcategory: Optional[str] = Field(None, max_length=100)
    price: Decimal = Field(..., ge=0)
    currency: str = Field(default="RUB", min_length=3, max_length=3)
    image_urls: List[str] = Field(default_factory=list)
    sizes: List[str] = Field(default_factory=list)
    colors: List[str] = Field(default_factory=list)
    style_tags: List[str] = Field(default_factory=list)
    in_stock: bool = True
    stock_count: int = Field(default=0, ge=0)


class ProductCreate(ProductBase):
    """Схема для создания товара."""
    pass


class ProductUpdate(BaseModel):
    """Схема для обновления товара."""
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    brand: Optional[str] = Field(None, min_length=1, max_length=100)
    category: Optional[ProductCategory] = None
    subcategory: Optional[str] = None
    price: Optional[Decimal] = Field(None, ge=0)
    currency: Optional[str] = None
    image_urls: Optional[List[str]] = None
    sizes: Optional[List[str]] = None
    colors: Optional[List[str]] = None
    style_tags: Optional[List[str]] = None
    in_stock: Optional[bool] = None
    stock_count: Optional[int] = Field(None, ge=0)


class ProductResponse(ProductBase):
    """Схема ответа товара."""
    id: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class ProductListResponse(BaseModel):
    """Схема ответа списка товаров с пагинацией."""
    items: List[ProductResponse]
    total: int
    page: int
    page_size: int
    total_pages: int


# ═══════════════════════════════════════════
# CART SCHEMAS
# ═══════════════════════════════════════════

class CartItemBase(BaseModel):
    """Базовая схема элемента корзины."""
    product_id: str
    size: Optional[str] = None
    color: Optional[str] = None
    quantity: int = Field(default=1, ge=1, le=100)


class CartItemCreate(CartItemBase):
    """Схема для добавления элемента в корзину."""
    pass


class CartItemUpdate(BaseModel):
    """Схема для обновления элемента корзины."""
    quantity: int = Field(..., ge=1, le=100)


class CartItemResponse(BaseModel):
    """Схема ответа элемента корзины."""
    product_id: str
    size: Optional[str]
    color: Optional[str]
    quantity: int
    price: Decimal
    product_name: Optional[str] = None
    product_image: Optional[str] = None


class CartResponse(BaseModel):
    """Схема ответа корзины."""
    id: str
    user_id: int
    items: List[CartItemResponse]
    total_amount: Decimal
    updated_at: datetime


# ═══════════════════════════════════════════
# ORDER SCHEMAS
# ═══════════════════════════════════════════

class OrderItemBase(BaseModel):
    """Базовая схема элемента заказа."""
    product_id: str
    size: Optional[str] = None
    color: Optional[str] = None
    quantity: int = Field(..., ge=1)
    price: Decimal


class OrderCreate(BaseModel):
    """Схема для создания заказа."""
    shipping_address: Dict[str, Any] = Field(..., description="Адрес доставки")
    payment_method: str = Field(..., description="Метод оплаты")


class OrderResponse(BaseModel):
    """Схема ответа заказа."""
    id: str
    user_id: int
    status: OrderStatus
    total_amount: Decimal
    items: List[OrderItemBase]
    shipping_address: Optional[Dict[str, Any]]
    payment_method: Optional[str]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class OrderListResponse(BaseModel):
    """Схема ответа списка заказов."""
    items: List[OrderResponse]
    total: int


# ═══════════════════════════════════════════
# RECOMMENDATION SCHEMAS
# ═══════════════════════════════════════════

class RecommendationRequest(BaseModel):
    """Запрос рекомендаций."""
    user_id: int
    limit: int = Field(default=10, ge=1, le=50)
    context: Optional[Dict[str, Any]] = None  # Погода, предпочтения


class RecommendationProduct(BaseModel):
    """Товар рекомендации."""
    product: ProductResponse
    score: float
    reason: Optional[str] = None


class RecommendationResponse(BaseModel):
    """Ответ рекомендаций."""
    recommendations: List[RecommendationProduct]
    model_version: Optional[str] = None


# ═══════════════════════════════════════════
# PRODUCT IMPORT SCHEMAS
# ═══════════════════════════════════════════

class ProductImportRequest(BaseModel):
    """Запрос на импорт товара по URL."""
    url: str = Field(..., min_length=1, max_length=2048, description="URL товара на WB/Ozon")


class ProductImportResponse(BaseModel):
    """Ответ импорта товара."""
    status: str = Field(..., description="status: success/error")
    product: Optional[ProductResponse] = None
    message: str = Field(..., description="Сообщение о результате")
    remaining_imports: Optional[int] = Field(None, description="Оставшееся количество импортов на сегодня")


# ═══════════════════════════════════════════
# ERROR SCHEMAS
# ═══════════════════════════════════════════

class ErrorResponse(BaseModel):
    """Схема ошибки."""
    code: str
    message: str
    details: Optional[Dict[str, Any]] = None
    request_id: Optional[str] = None


class HealthResponse(BaseModel):
    """Ответ проверки здоровья."""
    status: str
    service: str
    version: str
    database: str
    redis: str
    ml_service: str
