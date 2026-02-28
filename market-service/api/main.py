"""
Main FastAPI application for market-service.
"""
import logging
import os
import sys
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import ValidationError

from core.config import settings
from db.database import database
from services.redis_service import redis_service
from services.ml_integration import ml_integration_service
from services.payment_integration import payment_integration_service
from services.api_integration import api_service

# Настройка логирования
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL.upper()),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Управление жизненным циклом приложения."""
    # Startup
    logger.info("Starting market-service...")
    
    try:
        # Подключение к базе данных
        await database.connect()
        logger.info("Database connected")
        
        # Подключение к Redis
        await redis_service.connect()
        logger.info("Redis connected")
        
        logger.info("Market-service started successfully")
    except Exception as e:
        logger.error(f"Startup error: {e}")
        raise
    
    yield
    
    # Shutdown
    logger.info("Shutting down market-service...")
    
    await database.disconnect()
    await redis_service.disconnect()
    await ml_integration_service.close()
    await payment_integration_service.close()
    await api_service.close()
    
    logger.info("Market-service shutdown complete")


# Создание приложения
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Market service for OutfitStyle platform - clothing marketplace with ML recommendations",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ═══════════════════════════════════════════
# EXCEPTION HANDLERS
# ═══════════════════════════════════════════

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request,
    exc: RequestValidationError,
) -> JSONResponse:
    """Обработчик ошибок валидации."""
    request_id = request.headers.get("X-Request-Id", "unknown")
    
    logger.warning(
        f"Validation error for request {request_id}: {exc.errors()}"
    )
    
    return JSONResponse(
        status_code=422,
        content={
            "code": "VALIDATION_ERROR",
            "message": "Request validation failed",
            "details": exc.errors(),
            "request_id": request_id,
        },
    )


@app.exception_handler(Exception)
async def general_exception_handler(
    request: Request,
    exc: Exception,
) -> JSONResponse:
    """Обработчик общих ошибок."""
    request_id = request.headers.get("X-Request-Id", "unknown")
    
    logger.error(
        f"Unhandled exception for request {request_id}: {exc}",
        exc_info=True,
    )
    
    return JSONResponse(
        status_code=500,
        content={
            "code": "INTERNAL_ERROR",
            "message": "Internal server error",
            "request_id": request_id,
        },
    )


# ═══════════════════════════════════════════
# MIDDLEWARE
# ═══════════════════════════════════════════

@app.middleware("http")
async def request_logging_middleware(
    request: Request,
    call_next,
) -> Response:
    """Логирование запросов."""
    import time
    
    request_id = request.headers.get("X-Request-Id", f"req-{os.urandom(8).hex()}")
    start_time = time.time()
    
    response = await call_next(request)
    
    duration = (time.time() - start_time) * 1000  # ms
    
    logger.info(
        f"{request.method} {request.url.path} - "
        f"status={response.status_code} "
        f"duration={duration:.2f}ms "
        f"request_id={request_id}"
    )
    
    response.headers["X-Request-Id"] = request_id
    
    return response


# ═══════════════════════════════════════════
# ROUTES
# ═══════════════════════════════════════════

from api.routes.products import router as products_router
from api.routes.cart import router as cart_router
from api.routes.orders import router as orders_router
from api.routes.recommendations import router as recommendations_router

# Регистрация роутеров
app.include_router(products_router, prefix="/api/v1/market")
app.include_router(cart_router, prefix="/api/v1/market")
app.include_router(orders_router, prefix="/api/v1/market")
app.include_router(recommendations_router, prefix="/api/v1/market")


# ═══════════════════════════════════════════
# HEALTH ENDPOINTS
# ═══════════════════════════════════════════

@app.get("/health", tags=["Health"])
async def health_check():
    """Проверка здоровья сервиса."""
    db_status = "connected"
    redis_status = "connected"
    ml_status = "connected"
    
    try:
        # Проверка Redis
        if not await redis_service.health_check():
            redis_status = "disconnected"
    except Exception:
        redis_status = "disconnected"
    
    try:
        # Проверка ML сервиса
        if not await ml_integration_service.health_check():
            ml_status = "degraded"
    except Exception:
        ml_status = "degraded"
    
    return {
        "status": "healthy",
        "service": "market-service",
        "version": settings.APP_VERSION,
        "database": db_status,
        "redis": redis_status,
        "ml_service": ml_status,
    }


@app.get("/ready", tags=["Health"])
async def readiness_check():
    """Проверка готовности сервиса."""
    # Проверяем критичные зависимости
    redis_ok = await redis_service.health_check()
    
    if not redis_ok:
        from fastapi import HTTPException
        raise HTTPException(status_code=503, detail="Redis not available")
    
    return {"status": "ready"}


@app.get("/", tags=["Root"])
async def root():
    """Корневой endpoint."""
    return {
        "service": "OutfitStyle Market Service",
        "version": settings.APP_VERSION,
        "docs": "/docs",
    }


# ═══════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════

if __name__ == "__main__":
    import uvicorn
    
    uvicorn.run(
        "api.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
