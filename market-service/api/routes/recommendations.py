"""
API routes для рекомендаций товаров.
"""
import logging
import os
from typing import List, Optional, Dict, Any

from fastapi import APIRouter, Depends, HTTPException, Request, Header, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import get_db_session
from db.models import Product, ProductCategory
from schemas.schemas import (
    RecommendationResponse,
    RecommendationProduct,
    ProductResponse,
)
from services.ml_integration import ml_integration_service
from services.redis_service import redis_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/recommendations", tags=["Recommendations"])


async def get_user_id(x_user_id: int = Header(..., alias="X-User-Id")) -> int:
    """Получение ID пользователя из заголовка."""
    return x_user_id


@router.get("", response_model=RecommendationResponse)
async def get_recommendations(
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=50, description="Количество рекомендаций"),
    temperature: Optional[float] = Query(None, description="Температура (для погоды)"),
    humidity: Optional[float] = Query(None, description="Влажность"),
    weather_condition: Optional[str] = Query(None, description="Погодные условия"),
    style: Optional[str] = Query(None, description="Предпочитаемый стиль"),
):
    """
    Получение персональных рекомендаций товаров.
    
    Требуется заголовок: X-User-Id
    
    **Параметры:**
    - **limit**: Количество рекомендаций (1-50)
    - **temperature**: Температура воздуха (опционально)
    - **humidity**: Влажность (опционально)
    - **weather_condition**: Погодные условия (clear, rain, snow, etc.)
    - **style**: Предпочитаемый стиль (casual, sport, classic, etc.)
    
    **Логика работы:**
    1. Запрос к ML-service для получения рекомендаций по категориям
    2. Поиск товаров в каталоге по рекомендованным категориям
    3. Возврат товаров с ценами и наличием
    """
    # Проверка кэша рекомендаций
    cache_key = f"recommendations:user:{user_id}:temp:{temperature}:style:{style}:limit:{limit}"
    cached = await redis_service.get_cached(cache_key)
    if cached:
        logger.debug(f"Cache hit for recommendations user {user_id}")
        return RecommendationResponse(**cached)
    
    # Подготовка данных для ML сервиса
    weather_data = {
        "temperature": temperature or 20.0,
        "humidity": humidity or 50.0,
        "weather": weather_condition or "clear",
    }
    
    user_preferences = {
        "style_preferences": [style] if style else ["casual"],
        "activity": "daily",
    }
    
    # Получение рекомендаций от ML сервиса
    try:
        ml_categories = await ml_integration_service.get_recommendations(
            user_id=user_id,
            weather_data=weather_data,
            user_preferences=user_preferences,
            limit=limit,
        )
        # Версия модели конфигурируется через env переменную ML_MODEL_VERSION
        model_version = os.getenv("ML_MODEL_VERSION", "ml-v1.0")
    except Exception as e:
        logger.error(f"ML service error, using fallback: {e}")
        # Fallback: просто возвращаем популярные товары
        ml_categories = [
            {"category": "top", "style": style or "casual", "score": 0.5},
            {"category": "bottom", "style": style or "casual", "score": 0.5},
            {"category": "shoes", "style": style or "casual", "score": 0.5},
        ]
        model_version = "fallback"
    
    # Поиск товаров по рекомендованным категориям
    recommendations = []
    seen_products = set()
    
    for cat_info in ml_categories:
        if len(recommendations) >= limit:
            break
        
        category = cat_info.get("category")
        style_tag = cat_info.get("style")
        score = cat_info.get("score", 0.5)
        
        if not category:
            continue
        
        # Поиск товаров в категории
        query = select(Product).where(
            Product.category == ProductCategory(category),
            Product.in_stock == True,
        )
        
        # Фильтрация по стилю если указан
        if style_tag:
            query = query.where(Product.style_tags.contains([style_tag]))
        
        # Ограничение количества товаров на категорию
        query = query.limit(5)
        
        result = await session.execute(query)
        products = result.scalars().all()
        
        for product in products:
            if str(product.id) in seen_products:
                continue
            
            seen_products.add(str(product.id))
            
            recommendations.append(RecommendationProduct(
                product=ProductResponse.model_validate(product),
                score=score,
                reason=f"Рекомендуем для {weather_condition or 'текущей погоды'}",
            ))
            
            if len(recommendations) >= limit:
                break
    
    # Если рекомендаций мало, добавляем популярные товары
    if len(recommendations) < limit:
        remaining = limit - len(recommendations)
        
        # Получаем товары, которые еще не добавлены
        query = select(Product).where(
            Product.in_stock == True,
            Product.id.notin_(seen_products),
        )
        query = query.limit(remaining)
        
        result = await session.execute(query)
        products = result.scalars().all()
        
        for product in products:
            recommendations.append(RecommendationProduct(
                product=ProductResponse.model_validate(product),
                score=0.3,  # Базовый скор для популярных товаров
                reason="Популярный товар",
            ))
    
    response = RecommendationResponse(
        recommendations=recommendations[:limit],
        model_version=model_version,
    )
    
    # Кэширование
    await redis_service.set_cached(
        cache_key,
        response.model_dump(),
        ttl=300,  # 5 минут
    )
    
    return response


@router.get("/similar/{product_id}", response_model=List[ProductResponse])
async def get_similar_products(
    product_id: str,
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
    limit: int = Query(5, ge=1, le=20, description="Количество похожих товаров"),
):
    """
    Получение похожих товаров.
    
    Требуется заголовок: X-User-Id
    
    **Логика:**
    - Товары той же категории
    - Похожий стиль
    - Похожая цена
    """
    # Получение исходного товара
    query = select(Product).where(Product.id == product_id)
    result = await session.execute(query)
    product = result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    # Поиск похожих товаров
    conditions = [
        Product.id != product_id,
        Product.category == product.category,
        Product.in_stock == True,
    ]
    
    # Похожие по стилю
    if product.style_tags:
        # Ищем товары с хотя бы одним общим стилем
        style_conditions = []
        for tag in product.style_tags:
            style_conditions.append(Product.style_tags.contains([tag]))
        if style_conditions:
            conditions.append(style_conditions[0])  # Упрощенно
    
    # Похожая цена (+/- 30%)
    min_price = float(product.price) * 0.7
    max_price = float(product.price) * 1.3
    conditions.append(Product.price >= min_price)
    conditions.append(Product.price <= max_price)
    
    query = select(Product).where(*conditions).limit(limit)
    result = await session.execute(query)
    similar_products = result.scalars().all()
    
    return [ProductResponse.model_validate(p) for p in similar_products]
