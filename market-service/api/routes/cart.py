"""
API routes для работы с корзиной.
"""
import logging
from typing import List
from decimal import Decimal
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Request, Header
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import get_db_session
from db.models import Product, Cart as CartModel
from schemas.schemas import (
    CartResponse,
    CartItemResponse,
    CartItemCreate,
    CartItemUpdate,
)
from services.redis_service import redis_service
from services.api_integration import api_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/cart", tags=["Cart"])


async def get_user_id(x_user_id: int = Header(..., alias="X-User-Id")) -> int:
    """Получение ID пользователя из заголовка."""
    return x_user_id


@router.get("", response_model=CartResponse)
async def get_cart(
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Получение корзины пользователя.
    
    Требуется заголовок: X-User-Id
    """
    # Проверка корзины в Redis
    cart_data = await redis_service.get_cart(user_id)
    
    if not cart_data or not cart_data.get("items"):
        # Пустая корзина
        return CartResponse(
            id="",
            user_id=user_id,
            items=[],
            total_amount=Decimal("0"),
            updated_at=datetime.utcnow(),
        )
    
    # Получение деталей товаров
    items_with_details = []
    total_amount = Decimal("0")
    
    product_ids = [item["product_id"] for item in cart_data["items"]]
    
    # Загрузка товаров из БД
    query = select(Product).where(Product.id.in_(product_ids))
    result = await session.execute(query)
    products = {str(p.id): p for p in result.scalars().all()}
    
    for item in cart_data["items"]:
        product = products.get(item["product_id"])
        
        if product:
            item_price = Decimal(str(product.price))
            item_total = item_price * item["quantity"]
            total_amount += item_total
            
            items_with_details.append(CartItemResponse(
                product_id=item["product_id"],
                size=item.get("size"),
                color=item.get("color"),
                quantity=item["quantity"],
                price=item_price,
                product_name=product.name,
                product_image=product.image_urls[0] if product.image_urls else None,
            ))
    
    # Получение ID корзины из БД (если есть)
    cart_query = select(CartModel).where(CartModel.user_id == user_id)
    cart_result = await session.execute(cart_query)
    cart_model = cart_result.scalar_one_or_none()
    cart_id = str(cart_model.id) if cart_model else ""
    
    return CartResponse(
        id=cart_id,
        user_id=user_id,
        items=items_with_details,
        total_amount=total_amount,
        updated_at=datetime.utcnow(),
    )


@router.post("/items", response_model=CartResponse)
async def add_to_cart(
    item: CartItemCreate,
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Добавление товара в корзину.
    
    Требуется заголовок: X-User-Id
    """
    # Проверка существования товара
    product_query = select(Product).where(Product.id == item.product_id)
    product_result = await session.execute(product_query)
    product = product_result.scalar_one_or_none()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    if not product.in_stock:
        raise HTTPException(status_code=400, detail="Product out of stock")
    
    # Проверка наличия размера
    if item.size and product.sizes and item.size not in product.sizes:
        raise HTTPException(status_code=400, detail=f"Size {item.size} not available")
    
    # Добавление в Redis корзину
    cart_data = await redis_service.add_to_cart(
        user_id=user_id,
        product_id=item.product_id,
        size=item.size,
        color=item.color,
        quantity=item.quantity,
    )
    
    # Синхронизация с БД (ленивая)
    # В реальном приложении можно использовать фоновую задачу
    await _sync_cart_to_db(session, user_id, cart_data)
    
    # Возврат обновленной корзины
    return await _get_cart_response(session, user_id)


@router.patch("/items/{product_id}", response_model=CartResponse)
async def update_cart_item(
    product_id: str,
    item: CartItemUpdate,
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Обновление количества товара в корзине.
    
    Требуется заголовок: X-User-Id
    """
    # Получение текущей корзины
    cart_data = await redis_service.get_cart(user_id)
    
    if not cart_data or not cart_data.get("items"):
        raise HTTPException(status_code=404, detail="Cart item not found")
    
    # Поиск элемента для обновления
    item_found = False
    for cart_item in cart_data["items"]:
        if cart_item["product_id"] == product_id:
            cart_item["quantity"] = item.quantity
            item_found = True
            break
    
    if not item_found:
        raise HTTPException(status_code=404, detail="Cart item not found")
    
    # Обновление в Redis
    await redis_service.set_cart(user_id, cart_data)
    
    # Возврат обновленной корзины
    return await _get_cart_response(session, user_id)


@router.delete("/items/{product_id}", response_model=CartResponse)
async def remove_from_cart(
    product_id: str,
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Удаление товара из корзины.
    
    Требуется заголовок: X-User-Id
    """
    # Удаление из Redis
    await redis_service.remove_from_cart(user_id, product_id)
    
    # Возврат обновленной корзины
    return await _get_cart_response(session, user_id)


@router.delete("", response_model=dict)
async def clear_cart(
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Очистка корзины.
    
    Требуется заголовок: X-User-Id
    """
    await redis_service.clear_cart(user_id)
    
    # Удаление из БД
    cart_query = select(CartModel).where(CartModel.user_id == user_id)
    cart_result = await session.execute(cart_query)
    cart_model = cart_result.scalar_one_or_none()
    
    if cart_model:
        await session.delete(cart_model)
        await session.commit()
    
    return {"message": "Cart cleared"}


# ═══════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════

async def _get_cart_response(
    session: AsyncSession,
    user_id: int,
) -> CartResponse:
    """Получение ответа корзины."""
    cart_data = await redis_service.get_cart(user_id)
    
    if not cart_data or not cart_data.get("items"):
        return CartResponse(
            id="",
            user_id=user_id,
            items=[],
            total_amount=Decimal("0"),
            updated_at=datetime.utcnow(),
        )
    
    items_with_details = []
    total_amount = Decimal("0")
    
    product_ids = [item["product_id"] for item in cart_data["items"]]
    
    query = select(Product).where(Product.id.in_(product_ids))
    result = await session.execute(query)
    products = {str(p.id): p for p in result.scalars().all()}
    
    for item in cart_data["items"]:
        product = products.get(item["product_id"])
        
        if product:
            item_price = Decimal(str(product.price))
            item_total = item_price * item["quantity"]
            total_amount += item_total
            
            items_with_details.append(CartItemResponse(
                product_id=item["product_id"],
                size=item.get("size"),
                color=item.get("color"),
                quantity=item["quantity"],
                price=item_price,
                product_name=product.name,
                product_image=product.image_urls[0] if product.image_urls else None,
            ))
    
    cart_query = select(CartModel).where(CartModel.user_id == user_id)
    cart_result = await session.execute(cart_query)
    cart_model = cart_result.scalar_one_or_none()
    cart_id = str(cart_model.id) if cart_model else ""
    
    return CartResponse(
        id=cart_id,
        user_id=user_id,
        items=items_with_details,
        total_amount=total_amount,
        updated_at=datetime.utcnow(),
    )


async def _sync_cart_to_db(
    session: AsyncSession,
    user_id: int,
    cart_data: dict,
):
    """Синхронизация корзины с БД (ленивая)."""
    try:
        # Проверка существующей корзины
        cart_query = select(CartModel).where(CartModel.user_id == user_id)
        cart_result = await session.execute(cart_query)
        cart_model = cart_result.scalar_one_or_none()
        
        if cart_model:
            cart_model.items = cart_data.get("items", [])
            cart_model.updated_at = datetime.utcnow()
        else:
            # Создание новой корзины
            cart_model = CartModel(
                user_id=user_id,
                items=cart_data.get("items", []),
            )
            session.add(cart_model)
        
        await session.commit()
    except Exception as e:
        logger.error(f"Error syncing cart to DB: {e}")
        # Не прерываем операцию, корзина уже сохранена в Redis
