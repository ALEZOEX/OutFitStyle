"""
API routes для работы с товарами.
"""
import logging
from typing import List, Optional, Dict, Any
from decimal import Decimal
from datetime import datetime
import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, Request
from pydantic import BaseModel, Field
from sqlalchemy import select, func, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import get_db_session
from db.models import Product, ProductCategory
from schemas.schemas import (
    ProductResponse,
    ProductListResponse,
    ProductCategory as ProductCategorySchema,
    ProductCreate,
)
from services.redis_service import redis_service
from services.product_scraper import ProductScraper, get_scraper_service, ScraperError

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/products", tags=["Products"])


# ═══════════════════════════════════════════
# ДОПОЛНИТЕЛЬНЫЕ СХЕМЫ
# ═══════════════════════════════════════════

class ProductImportRequest(BaseModel):
    """Запрос на импорт товара по ссылке."""
    url: str = Field(..., description="Ссылка на товар (WB или Ozon)")
    marketplace: str = Field(default="auto", description="Маркетплейс: auto, wb, ozon")


class ProductImportResponse(BaseModel):
    """Ответ импорта товара."""
    status: str
    product: Optional[Dict[str, Any]] = None
    message: Optional[str] = None


# ═══════════════════════════════════════════
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# ═══════════════════════════════════════════

def detect_category(product_data: dict) -> ProductCategory:
    """
    Определить категорию товара из данных парсинга.
    
    Args:
        product_data: Данные товара от парсера
        
    Returns:
        ProductCategory
    """
    # Попытаться определить по названию/категории из парсера
    name = (product_data.get("name") or "").lower()
    category_from_parser = (product_data.get("category") or "").lower()
    
    # Маппинг категорий
    category_mapping = {
        "top": ["футболка", "рубашка", "блузка", "топ", "лонгслив", "водолазка", "поло", "майк", "кофта", "свитер", "джемпер", "худи", "свитшот"],
        "bottom": ["джинсы", "брюки", "штаны", "шорты", "юбка", "леггинсы"],
        "shoes": ["ботинки", "туфли", "кроссовки", "кеды", "сапоги", "ботильоны", "сандалии", "шлепанцы"],
        "accessories": ["сумка", "ремень", "шарф", "перчатки", "шапка", "носки", "колготки", "украшение"],
        "outerwear": ["куртка", "пальто", "плащ", "пуховик", "ветровка", "жилет", "кейп"],
        "headwear": ["шапка", "кепка", "шляпа", "панама", "бейсболка"],
    }
    
    # Проверка по категории от парсера
    for category, keywords in category_mapping.items():
        if any(kw in category_from_parser for kw in keywords):
            return ProductCategory(category)
    
    # Проверка по названию
    for category, keywords in category_mapping.items():
        if any(kw in name for kw in keywords):
            return ProductCategory(category)
    
    # По умолчанию
    return ProductCategory.TOP


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
    scraper: ProductScraper = Depends(get_scraper_service),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Импортировать товар по ссылке на WB/Ozon.
    
    Распарсить товар с маркетплейса и сохранить в каталог.
    
    **Поддерживаемые маркетплейсы:**
    - Wildberries (wildberries.ru, wb.ru)
    - Ozon (ozon.ru)
    
    **Пример запроса:**
    ```json
    {
      "url": "https://www.wildberries.ru/catalog/12345678/detail.aspx",
      "marketplace": "auto"
    }
    ```
    """
    logger.info(f"Импорт товара по ссылке: {url_request.url}")
    
    try:
        # Распарсить товар через Scraper API
        product_data = await scraper.parse_url(
            url=url_request.url,
            marketplace=url_request.marketplace
        )
        
        if not product_data:
            return ProductImportResponse(
                status="error",
                product=None,
                message="Не удалось распарсить товар"
            )
        
        # Извлечь данные
        name = product_data.get("name") or product_data.get("title") or "Без названия"
        brand = product_data.get("brand") or product_data.get("vendor") or "Unknown"
        
        # Цена (может быть строкой или числом)
        price_raw = product_data.get("price") or product_data.get("current_price") or 0
        if isinstance(price_raw, str):
            # Очистить от символов валюты и пробелов
            price_raw = price_raw.replace("₽", "").replace("₽", "").replace(" ", "").strip()
            try:
                price = Decimal(price_raw)
            except:
                price = Decimal(0)
        else:
            price = Decimal(str(price_raw))
        
        # Категория
        category = detect_category(product_data)
        
        # Изображения
        image_urls = product_data.get("images") or product_data.get("image_urls") or []
        if isinstance(image_urls, str):
            image_urls = [image_urls]
        
        # Источник
        marketplace = product_data.get("marketplace", "unknown")
        if marketplace == "unknown":
            if "wildberries" in url_request.url.lower() or "wb.ru" in url_request.url.lower():
                marketplace = "wildberries"
            elif "ozon" in url_request.url.lower():
                marketplace = "ozon"
        
        # Создать товар
        product = Product(
            id=uuid.uuid4(),
            name=name,
            description=product_data.get("description") or product_data.get("description_full"),
            brand=brand,
            category=category,
            subcategory=product_data.get("subcategory"),
            price=price,
            currency="RUB",
            image_urls=image_urls,
            sizes=product_data.get("sizes") or [],
            colors=product_data.get("colors") or [],
            style_tags=[],
            in_stock=product_data.get("in_stock", True),
            stock_count=product_data.get("stock_count") or 0,
        )
        
        # Сохранить в БД
        session.add(product)
        await session.commit()
        await session.refresh(product)
        
        logger.info(f"Товар импортирован: {product.id} - {name}")
        
        return ProductImportResponse(
            status="success",
            product=product.to_dict(),
            message=f"Товар из {marketplace} успешно импортирован"
        )
    
    except ScraperError as e:
        logger.error(f"Ошибка парсинга: {e}")
        return ProductImportResponse(
            status="error",
            product=None,
            message=f"Ошибка парсинга: {str(e)}"
        )
    except Exception as e:
        logger.exception(f"Ошибка импорта товара: {e}")
        return ProductImportResponse(
            status="error",
            product=None,
            message=f"Ошибка импорта: {str(e)}"
        )
