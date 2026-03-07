from pydantic import BaseModel, Field, field_validator
from typing import List, Dict, Optional, Any
from enum import Enum


class TZCandidateFeatures(BaseModel):
    model_config = {"protected_namespaces": ()}
    warmth_level: int = Field(ge=1, le=10)
    min_temp: int
    max_temp: int
    rain_ok: bool = False
    snow_ok: bool = False
    wind_ok: bool = False
    style: str
    formality_level: int = Field(ge=1, le=5)
    base_colour: str = ""
    pattern: str = "solid"
    user_rating: Optional[float] = None
    wear_count: Optional[int] = None


class TZCandidate(BaseModel):
    id: str
    category: str
    subcategory: str
    source: str
    source_priority: int = Field(ge=0, le=3, default=0)
    features: TZCandidateFeatures


class TZContext(BaseModel):
    temperature: float = Field(..., ge=-50, le=50, description="Temperature in Celsius")
    feels_like: float = Field(..., ge=-50, le=50, description="Feels like temperature in Celsius")
    humidity: int = Field(..., ge=0, le=100, description="Humidity percentage")
    wind_speed: float = Field(..., ge=0, le=200, description="Wind speed in km/h")
    wind_direction: int = Field(default=0, ge=0, le=360, description="Wind direction in degrees")
    weather_code: str = ""
    precipitation_chance: int = Field(default=0, ge=0, le=100, description="Precipitation chance percentage")
    occasion: str = ""
    formality: int = Field(default=2, ge=1, le=5, description="Formality level")
    time_of_day: str = "day"
    day_of_week: int = Field(default=0, ge=0, le=6, description="Day of week (0=Monday, 6=Sunday)")

    @field_validator("time_of_day")
    @classmethod
    def validate_time_of_day(cls, v: str) -> str:
        """Validate time of day against allowed values"""
        allowed_values = {"morning", "day", "evening", "night"}
        if v.lower() not in allowed_values:
            raise ValueError(
                f"time_of_day must be one of: {allowed_values}, got: {v}"
            )
        return v.lower()


class TZUserPreferences(BaseModel):
    preferred_styles: List[str] = Field(default_factory=list)
    avoid_styles: List[str] = Field(default_factory=list)
    color_preferences: List[str] = Field(default_factory=list)
    avoid_colors: List[str] = Field(default_factory=list)
    preferred_categories: List[str] = Field(default_factory=list)
    temperature_sensitivity: int = Field(default=0, ge=-2, le=2, description="Temperature sensitivity (-2=very cold, 2=very warm)")


class TZUserHistory(BaseModel):
    recent_items: List[str] = Field(default_factory=list)
    highly_rated_items: List[str] = Field(default_factory=list)
    low_rated_items: List[str] = Field(default_factory=list)
    style_distribution: Dict[str, float] = Field(default_factory=dict)


class TZRankRequest(BaseModel):
    request_id: str
    user_id: str
    context: TZContext
    user_preferences: TZUserPreferences = Field(default_factory=TZUserPreferences)
    user_history: TZUserHistory = Field(default_factory=TZUserHistory)
    candidates: List[TZCandidate] = Field(..., min_length=1, max_length=100, description="Candidates to rank (1-100)")

    @field_validator("candidates")
    @classmethod
    def validate_candidates_count(cls, v: List[TZCandidate]) -> List[TZCandidate]:
        """Validate candidate count is within bounds"""
        if len(v) < 1:
            raise ValueError("candidates must contain at least 1 item")
        if len(v) > 100:
            raise ValueError(f"candidates must not exceed 100 items, got: {len(v)}")
        return v


class TZRankedItem(BaseModel):
    id: str
    score: float
    confidence: float = 0.5
    factors: Dict[str, Any] = Field(default_factory=dict)


class TZRankResponse(BaseModel):
    model_config = {"protected_namespaces": ()}
    request_id: str
    rankings: Dict[str, List[TZRankedItem]]
    outfit_score: float
    style_coherence: float
    color_harmony: float
    model_version: str
    processing_time_ms: int
