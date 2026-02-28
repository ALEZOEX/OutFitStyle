"""
Подключение к базе данных и сессии.
"""
from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    create_async_engine,
    async_sessionmaker,
    AsyncEngine,
)
from sqlalchemy.orm import sessionmaker

from core.config import settings


class Database:
    """Управление подключением к базе данных."""
    
    def __init__(self):
        self.engine: AsyncEngine | None = None
        self.async_session_maker: async_sessionmaker | None = None
    
    async def connect(self):
        """Подключение к базе данных."""
        self.engine = create_async_engine(
            settings.DATABASE_URL,
            echo=settings.DEBUG,
            pool_size=settings.DATABASE_POOL_SIZE,
            max_overflow=settings.DATABASE_MAX_OVERFLOW,
            pool_pre_ping=True,  # Проверка соединения перед использованием
        )
        self.async_session_maker = async_sessionmaker(
            self.engine,
            class_=AsyncSession,
            expire_on_commit=False,
            autocommit=False,
            autoflush=False,
        )
    
    async def disconnect(self):
        """Отключение от базы данных."""
        if self.engine:
            await self.engine.dispose()
    
    async def get_session(self) -> AsyncGenerator[AsyncSession, None]:
        """Получение сессии базы данных."""
        if not self.async_session_maker:
            raise RuntimeError("Database not connected. Call connect() first.")
        
        async with self.async_session_maker() as session:
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise
            finally:
                await session.close()


# Глобальный экземпляр базы данных
database = Database()


async def get_db_session() -> AsyncGenerator[AsyncSession, None]:
    """Зависимость FastAPI для получения сессии БД."""
    async for session in database.get_session():
        yield session
