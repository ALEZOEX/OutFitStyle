"""
Contracts для endpoint /api/recommend с фильтрацией
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


class RecommendRequest(BaseModel):
    """Запрос на рекомендации с фильтрацией"""

    context: RecommendContext
    available_tops: Optional[List[str]] = None
    available_bottoms: Optional[List[str]] = None
    available_outerwears: Optional[List[str]] = None
    available_footwears: Optional[List[str]] = None
    top_k: int = Field(default=5, description="Количество рекомендаций", ge=1, le=50)

    @field_validator("top_k")
    @classmethod
    def validate_top_k(cls, v: int) -> int:
        """Валидация top_k: от 1 до 50"""
        if v < 1:
            raise ValueError("top_k должен быть не менее 1")
        if v > 50:
            raise ValueError("top_k должен быть не более 50")
        return v


class RecommendOutfit(BaseModel):
    """Один вариант одежды"""

    top: str
    bottom: str
    outerwear: str
    footwear: str
    score: float = Field(..., ge=0.0)


class RecommendResponse(BaseModel):
    """Ответ с рекомендациями"""

    outfits: List[RecommendOutfit]
    total_candidates: int
    filtered_from: int
    context: Dict[str, Any]
    model_version: str
    processing_time_ms: float
    error: Optional[str] = None
