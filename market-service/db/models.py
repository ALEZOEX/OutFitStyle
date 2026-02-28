"""
Модели базы данных для market-service.
"""
import uuid
from datetime import datetime
from decimal import Decimal
from enum import Enum
from typing import List, Optional

from sqlalchemy import (
    Column,
    String,
    Text,
    Numeric,
    Boolean,
    Integer,
    DateTime,
    ForeignKey,
    Enum as SQLEnum,
    Index,
)
from sqlalchemy.dialects.postgresql import UUID, ARRAY, JSONB
from sqlalchemy.orm import declarative_base, relationship

Base = declarative_base()


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


class Product(Base):
    """Товар в каталоге."""
    __tablename__ = "products"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    brand = Column(String(100), nullable=False)
    
    category = Column(SQLEnum(ProductCategory), nullable=False)
    subcategory = Column(String(100), nullable=True)
    
    price = Column(Numeric(10, 2), nullable=False)
    currency = Column(String(3), default="RUB")
    
    # Изображения
    image_urls = Column(ARRAY(String), default=[])
    
    # Размеры и цвета
    sizes = Column(ARRAY(String), default=[])  # XS, S, M, L, XL, XXL
    colors = Column(ARRAY(String), default=[])
    
    # Стили
    style_tags = Column(ARRAY(String), default=[])  # casual, sport, classic, etc.
    
    # Наличие
    in_stock = Column(Boolean, default=True)
    stock_count = Column(Integer, default=0)
    
    # Метаданные
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Индексы для производительности
    __table_args__ = (
        Index("ix_products_category", "category"),
        Index("ix_products_brand", "brand"),
        Index("ix_products_price", "price"),
        Index("ix_products_in_stock", "in_stock"),
        Index("ix_products_style_tags", "style_tags", postgresql_using="gin"),
    )
    
    def to_dict(self) -> dict:
        """Конвертация в словарь."""
        return {
            "id": str(self.id),
            "name": self.name,
            "description": self.description,
            "brand": self.brand,
            "category": self.category.value if self.category else None,
            "subcategory": self.subcategory,
            "price": float(self.price) if self.price else 0.0,
            "currency": self.currency,
            "image_urls": self.image_urls or [],
            "sizes": self.sizes or [],
            "colors": self.colors or [],
            "style_tags": self.style_tags or [],
            "in_stock": self.in_stock,
            "stock_count": self.stock_count,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class Order(Base):
    """Заказ пользователя."""
    __tablename__ = "orders"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Integer, nullable=False)  # ID из основного API
    
    status = Column(SQLEnum(OrderStatus), default=OrderStatus.PENDING, nullable=False)
    total_amount = Column(Numeric(10, 2), nullable=False)
    
    # Элементы заказа: [{product_id, size, color, quantity, price}, ...]
    items = Column(JSONB, nullable=False, default=[])
    
    # Адрес доставки
    shipping_address = Column(JSONB, nullable=True)
    
    # Метод оплаты
    payment_method = Column(String(50), nullable=True)
    
    # Метаданные
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Индексы
    __table_args__ = (
        Index("ix_orders_user_id", "user_id"),
        Index("ix_orders_status", "status"),
        Index("ix_orders_created_at", "created_at"),
    )
    
    def to_dict(self) -> dict:
        """Конвертация в словарь."""
        return {
            "id": str(self.id),
            "user_id": self.user_id,
            "status": self.status.value if self.status else None,
            "total_amount": float(self.total_amount) if self.total_amount else 0.0,
            "items": self.items or [],
            "shipping_address": self.shipping_address,
            "payment_method": self.payment_method,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }


class Cart(Base):
    """Корзина пользователя."""
    __tablename__ = "cart"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(Integer, unique=True, nullable=False)  # ID из основного API
    
    # Элементы корзины: [{product_id, size, color, quantity}, ...]
    items = Column(JSONB, nullable=False, default=[])
    
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Индексы
    __table_args__ = (
        Index("ix_cart_user_id", "user_id"),
    )
    
    def to_dict(self) -> dict:
        """Конвертация в словарь."""
        return {
            "id": str(self.id),
            "user_id": self.user_id,
            "items": self.items or [],
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
