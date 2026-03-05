"""
Contracts для endpoint /api/recommend с фильтрацией

ИЗМЕНЕНИЯ (Март 2026):
- Переход на items_by_category вместо available_*
- Формат предметов из БД: {"id": "uuid", "category": "upper", "subcategory": "tshirt", ...}
"""

from pydantic import BaseModel, Field, field_validator
from typing import List, Optional, Dict, Any


class RecommendContext(BaseModel):
    """Контекст для рекомендаций"""

    temperature: float = Field(..., description="Температура (°C)", ge=-40, le=60)
    humidity: float = Field(..., description="Влажность (%)", ge=0, le=100)
    weather_condition: str = Field(
        ..., description="Погода (Cerah, Mendung, Hujan, Berawan)"
    )
    location: str = Field(..., description="Локация (Indoor, Outdoor)")
    activity: str = Field(
        ..., description="Активность (Olahraga, Kerja, Jalan-jalan, Pesta)"
    )
    gender: str = Field(..., description="Пол (Laki-laki, Perempuan)")
    duration: float = Field(
        default=2.0, description="Длительность (часы)", ge=0.5, le=24.0
    )


class UserPreferences(BaseModel):
    """
    Предпочтения пользователя для персонализации рекомендаций.

    Attributes:
        style_preferences: Список предпочитаемых стилей (casual, sport, classic, streetwear, etc.)
        budget_range: Диапазон бюджета (economy, medium, premium)
        favorite_brands: Список любимых брендов (Nike, Adidas, Zara, etc.)
    """
    style_preferences: Optional[List[str]] = Field(
        default=None,
        description="Предпочитаемые стили: casual, sport, classic, streetwear, bohemian, minimal"
    )
    budget_range: Optional[str] = Field(
        default=None,
        description="Диапазон бюджета: economy (до 3000₽), medium (3000-10000₽), premium (10000+₽)"
    )
    favorite_brands: Optional[List[str]] = Field(
        default=None,
        description="Любимые бренды для повышения приоритета"
    )

    @field_validator("budget_range")
    @classmethod
    def validate_budget_range(cls, v: Optional[str]) -> Optional[str]:
        """Валидация budget_range: допустимые значения"""
        if v is None:
            return v
        allowed_values = {"economy", "medium", "premium"}
        if v.lower() not in allowed_values:
            raise ValueError(
                f"budget_range должен быть одним из: {allowed_values}, получено: {v}"
            )
        return v.lower()


class Item(BaseModel):
    """
    Предмет одежды из БД.

    Attributes:
        id: UUID предмета
        category: категория (upper, lower, footwear, outerwear, accessory)
        subcategory: подкатегория (tshirt, jeans, sneakers, etc.)
        base_colour: базовый цвет
        name: название предмета
    """
    id: str = Field(..., description="UUID предмета")
    category: str = Field(..., description="Категория: upper, lower, footwear, outerwear, accessory")
    subcategory: str = Field(..., description="Подкатегория: tshirt, jeans, sneakers, etc.")
    base_colour: str = Field(..., description="Базовый цвет")
    name: str = Field(..., description="Название предмета")


class RecommendRequest(BaseModel):
    """Запрос на рекомендации с фильтрацией"""

    context: RecommendContext
    items_by_category: Dict[str, List[Item]] = Field(
        ...,
        description="Предметы по категориям: {'upper': [...], 'lower': [...], ...}"
    )
    top_k: int = Field(default=5, description="Количество рекомендаций", ge=1, le=50)

    # Предпочтения пользователя для персонализации
    user_preferences: Optional[UserPreferences] = Field(
        default=None,
        description="Предпочтения пользователя для персонализации рекомендаций"
    )

    @field_validator("top_k")
    @classmethod
    def validate_top_k(cls, v: int) -> int:
        """Валидация top_k: от 1 до 50"""
        if v < 1:
            raise ValueError("top_k должен быть не менее 1")
        if v > 50:
            raise ValueError("top_k должен быть не более 50")
        return v


class RecommendOutfitItem(BaseModel):
    """Предмет в составе outfit"""
    id: str
    category: str
    subcategory: str
    name: str
    base_colour: str


class RecommendOutfit(BaseModel):
    """Один вариант одежды (outfit)"""

    upper: RecommendOutfitItem
    lower: RecommendOutfitItem
    footwear: RecommendOutfitItem
    outerwear: Optional[RecommendOutfitItem] = None
    score: float = Field(..., ge=0.0, description="Оценка CatBoost модели")


class RecommendResponse(BaseModel):
    """Ответ с рекомендациями"""

    outfits: List[RecommendOutfit]
    total_combinations: int = Field(..., description="Количество сгенерированных комбинаций")
    filtered_from: int = Field(..., description="Количество комбинаций после фильтрации")
    context: Dict[str, Any]
    model_version: str
    processing_time_ms: float
    error: Optional[str] = None
