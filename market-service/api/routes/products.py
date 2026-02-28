"""
API routes для работы с товарами.
"""
import logging
import uuid
from typing import List, Optional
from decimal import Decimal
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, Request
from sqlalchemy import select, func, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from core.config import settings
from db.database import get_db_session
from db.models import Product, ProductCategory
from schemas.schemas import (
    ProductResponse,
    ProductListResponse,
    ProductCategory as ProductCategorySchema,
    ProductImportRequest,
    ProductImportResponse,
)
from services.redis_service import redis_service
from services.product_scraper import (
    get_scraper_service,
    ProductScraperService,
    ProductImportLimiter,
    ProductScraperError,
)

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


@router.post("/import", response_model=ProductImportResponse)
async def import_product_from_url(
    url_request: ProductImportRequest,
    request: Request,
    session: AsyncSession = Depends(get_db_session),
    scraper: ProductScraperService = Depends(get_scraper_service),
):
    """
    Импортировать товар по ссылке на WB/Ozon.
    
    Поддерживаемые маркетплейсы:
    - Wildberries: https://www.wildberries.ru/catalog/... или wb/12345678
    - Ozon: https://www.ozon.ru/product/... или oz/12345678
    
    Лимит импортов: 10 в день на пользователя.
    
    Требуется заголовок: X-User-Id
    """
    request_id = request.headers.get("X-Request-Id", "unknown")
    
    # Получение user_id из заголовка
    user_id_str = request.headers.get("X-User-Id")
    if not user_id_str:
        raise HTTPException(
            status_code=400,
            detail="Требуется заголовок X-User-Id"
        )
    
    try:
        user_id = int(user_id_str)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Некорректный формат X-User-Id"
        )
    
    # Проверка лимита импорта
    limiter = ProductImportLimiter(redis_service)
    allowed, remaining = await limiter.check_limit(user_id)
    
    if not allowed:
        logger.warning(f"Import limit exceeded for user {user_id}")
        raise HTTPException(
            status_code=429,
            detail={
                "code": "IMPORT_LIMIT_EXCEEDED",
                "message": f"Превышен лимит импорта товаров ({settings.PRODUCT_IMPORT_LIMIT_PER_DAY} в день)",
                "remaining": 0,
            }
        )
    
    try:
        # Распарсить товар
        logger.info(f"Importing product from URL: {url_request.url} for user {user_id}")
        product_data = await scraper.parse_product_url(url_request.url)
        
        # Валидация данных
        if not product_data.get('name'):
            raise ProductScraperError("Не удалось получить название товара")
        
        # Сохранение в базу данных
        from db.models import ProductCategory as ProductCategoryModel
        
        # Определяем категорию
        category_str = product_data.get('category', 'top')
        try:
            category = ProductCategoryModel(category_str)
        except ValueError:
            category = ProductCategoryModel.TOP
        
        # Создаем товар
        new_product = Product(
            id=uuid.uuid4(),
            name=product_data['name'],
            description=product_data.get('description'),
            brand=product_data.get('brand', 'Unknown'),
            category=category,
            price=Decimal(str(product_data.get('price', 0))),
            currency='RUB',
            image_urls=product_data.get('image_urls', []),
            in_stock=product_data.get('in_stock', True),
            stock_count=0,  # Для импортированных товаров
            sizes=[],
            colors=[],
            style_tags=[],
        )
        
        session.add(new_product)
        await session.commit()
        await session.refresh(new_product)
        
        # Увеличиваем счетчик импорта
        await limiter.increment_import(user_id)
        remaining = max(0, remaining - 1)
        
        # Инвалидация кэша категорий (опционально)
        # await redis_service.delete_cached("products:categories")
        
        logger.info(f"Successfully imported product {new_product.id} for user {user_id}")
        
        # Конвертация в response
        product_response = ProductResponse.model_validate(new_product)
        
        return ProductImportResponse(
            status="success",
            product=product_response,
            message=f"Товар из {product_data['source']} успешно импортирован",
            remaining_imports=remaining,
        )
        
    except ProductScraperError as e:
        logger.error(f"Product scraper error for user {user_id}: {e}")
        # Возвращаем ошибку как успешный ответ со status=error
        return ProductImportResponse(
            status="error",
            product=None,
            message=str(e),
            remaining_imports=remaining,
        )
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error importing product for user {user_id}: {e}", exc_info=True)
        return ProductImportResponse(
            status="error",
            product=None,
            message=f"Ошибка импорта товара: {str(e)}",
            remaining_imports=remaining,
        )
