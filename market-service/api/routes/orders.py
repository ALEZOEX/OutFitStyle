"""
API routes для работы с заказами.
"""
import logging
from typing import List, Optional
from decimal import Decimal
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Request, Header, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import get_db_session
from db.models import Order, OrderStatus, Product, Cart as CartModel
from schemas.schemas import (
    OrderResponse,
    OrderListResponse,
    OrderCreate,
    OrderStatus as OrderStatusSchema,
)
from services.redis_service import redis_service
from services.payment_integration import payment_integration_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/orders", tags=["Orders"])


async def get_user_id(x_user_id: int = Header(..., alias="X-User-Id")) -> int:
    """Получение ID пользователя из заголовка."""
    return x_user_id


@router.post("", response_model=OrderResponse, status_code=201)
async def create_order(
    order_data: OrderCreate,
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Создание заказа из корзины.
    
    Требуется заголовок: X-User-Id
    
    **shipping_address**: Адрес доставки (JSON объект)
    **payment_method**: Метод оплаты (yookassa, card, etc.)
    """
    # Получение корзины пользователя
    cart_data = await redis_service.get_cart(user_id)
    
    if not cart_data or not cart_data.get("items"):
        raise HTTPException(status_code=400, detail="Cart is empty")
    
    # Получение товаров и расчет суммы
    items = cart_data["items"]
    product_ids = [item["product_id"] for item in items]
    
    query = select(Product).where(Product.id.in_(product_ids))
    result = await session.execute(query)
    products = {str(p.id): p for p in result.scalars().all()}
    
    # Проверка наличия всех товаров
    order_items = []
    total_amount = Decimal("0")
    
    for cart_item in items:
        product = products.get(cart_item["product_id"])
        
        if not product:
            raise HTTPException(
                status_code=400,
                detail=f"Product {cart_item['product_id']} not found",
            )
        
        if not product.in_stock or product.stock_count < cart_item["quantity"]:
            raise HTTPException(
                status_code=400,
                detail=f"Product {product.name} out of stock",
            )
        
        item_price = Decimal(str(product.price))
        item_total = item_price * cart_item["quantity"]
        total_amount += item_total
        
        order_items.append({
            "product_id": cart_item["product_id"],
            "product_name": product.name,
            "size": cart_item.get("size"),
            "color": cart_item.get("color"),
            "quantity": cart_item["quantity"],
            "price": str(item_price),
        })
    
    # Создание заказа в БД
    order = Order(
        user_id=user_id,
        status=OrderStatus.PENDING,
        total_amount=total_amount,
        items=order_items,
        shipping_address=order_data.shipping_address,
        payment_method=order_data.payment_method,
    )
    
    session.add(order)
    await session.commit()
    await session.refresh(order)
    
    logger.info(f"Order created: {order.id} for user {user_id}, amount: {total_amount}")
    
    # Создание платежа (если требуется)
    payment_url = None
    if order_data.payment_method == "yookassa":
        try:
            payment_data = await payment_integration_service.create_payment(
                order_id=str(order.id),
                amount=total_amount,
                description=f"Заказ #{order.id}",
            )
            payment_url = payment_data.get("confirmation_url")
            logger.info(f"Payment created for order {order.id}: {payment_url}")
        except Exception as e:
            logger.error(f"Payment creation failed: {e}")
            # Не прерываем создание заказа, платеж можно создать позже
    
    # Очистка корзины
    await redis_service.clear_cart(user_id)
    
    # Удаление корзины из БД
    cart_query = select(CartModel).where(CartModel.user_id == user_id)
    cart_result = await session.execute(cart_query)
    cart_model = cart_result.scalar_one_or_none()
    
    if cart_model:
        await session.delete(cart_model)
        await session.commit()
    
    # Возврат заказа
    response = OrderResponse.model_validate(order)
    
    # Добавляем payment_url в response (через dict)
    response_dict = response.model_dump()
    if payment_url:
        response_dict["payment_url"] = payment_url
    
    return response_dict


@router.get("", response_model=OrderListResponse)
async def get_orders(
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
    status: Optional[OrderStatusSchema] = Query(None, description="Фильтр по статусу"),
    page: int = Query(1, ge=1, description="Номер страницы"),
    page_size: int = Query(20, ge=1, le=100, description="Размер страницы"),
):
    """
    Получение истории заказов пользователя.
    
    Требуется заголовок: X-User-Id
    """
    # Построение запроса
    query = select(Order).where(Order.user_id == user_id)
    
    if status:
        query = query.where(Order.status == OrderStatus(status.value))
    
    # Сортировка по дате создания (новые сначала)
    query = query.order_by(Order.created_at.desc())
    
    # Получение общего количества
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await session.execute(count_query)
    total = total_result.scalar() or 0
    
    # Пагинация
    offset = (page - 1) * page_size
    query = query.offset(offset).limit(page_size)
    
    # Выполнение запроса
    result = await session.execute(query)
    orders = result.scalars().all()
    
    return OrderListResponse(
        items=[OrderResponse.model_validate(o) for o in orders],
        total=total,
    )


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: str,
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Получение деталей заказа по ID.
    
    Требуется заголовок: X-User-Id
    """
    query = select(Order).where(Order.id == order_id, Order.user_id == user_id)
    result = await session.execute(query)
    order = result.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    return OrderResponse.model_validate(order)


@router.post("/{order_id}/cancel", response_model=OrderResponse)
async def cancel_order(
    order_id: str,
    request: Request,
    user_id: int = Depends(get_user_id),
    session: AsyncSession = Depends(get_db_session),
):
    """
    Отмена заказа.
    
    Требуется заголовок: X-User-Id
    
    Можно отменить только заказы со статусом pending или paid.
    """
    query = select(Order).where(Order.id == order_id, Order.user_id == user_id)
    result = await session.execute(query)
    order = result.scalar_one_or_none()
    
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if order.status not in [OrderStatus.PENDING, OrderStatus.PAID]:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot cancel order with status {order.status.value}",
        )
    
    order.status = OrderStatus.CANCELLED
    await session.commit()
    await session.refresh(order)
    
    logger.info(f"Order cancelled: {order_id} by user {user_id}")
    
    # Возврат средств (если заказ был оплачен)
    if order.status == OrderStatus.PAID:
        # TODO: Вызов payment_integration_service.refund_payment
        logger.info(f"Refund initiated for order {order_id}")
    
    return OrderResponse.model_validate(order)
