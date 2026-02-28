"""
API routes для работы с товарами.
"""
import logging
from typing import List, Optional
from decimal import Decimal

from fastapi import APIRouter, Depends, HTTPException, Query, Request
from sqlalchemy import select, func, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import get_db_session
from db.models import Product, ProductCategory
from schemas.schemas import (
    ProductResponse,
    ProductListResponse,
    ProductCategory as ProductCategorySchema,
)
from services.redis_service import redis_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/products", tags=["Products"])


@router.get("", response_model=ProductListResponse)
async def get_products(
    request: Request,
    session: AsyncSession = Depends(get_db_session),
    category: Optional[ProductCategorySchema] = Query(None, description="Категория товара"),
    brand: Optional[str] = Query(None, description="Бренд"),
    min_price: Optional[Decimal] = Query(None, ge=0, description="Минимальная цена"),
    max_price: Optional[Decimal] = Query(None, ge=0, description="Максимальная цена"),
    style: Optional[str] = Query(None, description="Стиль"),
    in_stock: Optional[bool] = Query(None, description="Только в наличии"),
    page: int = Query(1, ge=1, description="Номер страницы"),
    page_size: int = Query(20, ge=1, le=100, description="Размер страницы"),
    search: Optional[str] = Query(None, description="Поиск по названию"),
):
    """
    Получение каталога товаров с фильтрацией и пагинацией.
    
    - **category**: Фильтрация по категории
    - **brand**: Фильтрация по бренду
    - **min_price/max_price**: Фильтрация по цене
    - **style**: Фильтрация по стилю
    - **in_stock**: Только товары в наличии
    - **search**: Поиск по названию товара
    """
    # Построение запроса
    query = select(Product)
    conditions = []
    
    if category:
        conditions.append(Product.category == ProductCategory(category.value))
    
    if brand:
        conditions.append(Product.brand.ilike(f"%{brand}%"))
    
    if min_price is not None:
        conditions.append(Product.price >= min_price)
    
    if max_price is not None:
        conditions.append(Product.price <= max_price)
    
    if style:
        # Поиск стиля в массиве style_tags
        conditions.append(Product.style_tags.contains([style]))
    
    if in_stock is not None:
        conditions.append(Product.in_stock == in_stock)
    
    if search:
        conditions.append(Product.name.ilike(f"%{search}%"))
    
    if conditions:
        query = query.where(and_(*conditions))
    
    # Получение общего количества
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await session.execute(count_query)
    total = total_result.scalar() or 0
    
    # Пагинация
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)
    
    # Выполнение запроса
    result = await session.execute(query)
    products = result.scalars().all()
    
    # Конвертация в ответ
    items = [ProductResponse.model_validate(p) for p in products]
    
    return ProductListResponse(
        items=items,
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size,
    )


@router.get("/categories", response_model=List[dict])
async def get_categories():
    """Получение списка категорий товаров."""
    return [
        {"value": cat.value, "label": cat.name.replace("_", " ").title()}
        for cat in ProductCategory
    ]


@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: str,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
):
    """
    Получение деталей товара по ID.
    """
    # Проверка кэша
    cached = await redis_service.get_cached_product(product_id)
    if cached:
        logger.debug(f"Cache hit for product {product_id}")
        return ProductResponse(**cached)
    
    # Поиск в БД
    query = select(Product).where(Product.id == product_id)
    result = await session.execute(query)
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    # Кэширование
    product_dict = product.to_dict()
    await redis_service.cache_product(product_id, product_dict)
    
    return ProductResponse(**product_dict)
