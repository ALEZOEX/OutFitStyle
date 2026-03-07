from typing import Dict, List, Optional, Any
from pydantic import BaseModel, Field, field_validator
from enum import Enum


class SourceType(str, Enum):
    SYNTHETIC = "synthetic"
    USER = "user"
    PARTNER = "partner"
    MANUAL = "manual"


class MLItem(BaseModel):
    id: int
    name: str
    category: str
    subcategory: str
    gender: str
    style: str
    usage: str
    season: str
    base_colour: str
    formality: int = Field(ge=1, le=5)
    warmth: int = Field(ge=1, le=10)
    min_temp: int
    max_temp: int
    materials: List[str]
    fit: str
    pattern: str
    icon_emoji: str
    source: SourceType
    is_owned: bool
    created_at: str

    # Source priority used for ranking
    source_priority: int = Field(ge=0, le=3)


class WeatherData(BaseModel):
    temperature: float = Field(..., ge=-50, le=50, description="Temperature in Celsius")
    feels_like: float = Field(..., ge=-50, le=50, description="Feels like temperature in Celsius")
    humidity: int = Field(..., ge=0, le=100, description="Humidity percentage")
    wind_speed: float = Field(..., ge=0, le=200, description="Wind speed in km/h")
    weather: str = Field(..., description="Weather condition")

    @field_validator("weather")
    @classmethod
    def validate_weather(cls, v: str) -> str:
        """Validate weather type against allowed values"""
        allowed_values = {
            "clear", "cloudy", "rain", "snow", "fog", "thunderstorm",
            "drizzle", "mist", "overcast", "partly_cloudy",
            "Cerah", "Mendung", "Hujan", "Berawan"
        }
        if v.lower() not in {w.lower() for w in allowed_values}:
            raise ValueError(
                f"weather must be one of: {allowed_values}, got: {v}"
            )
        return v


class UserProfile(BaseModel):
    age_range: str
    style_preference: str
    temperature_sensitivity: str
    formality_preference: str
    gender: str


class MLContext(BaseModel):
    weather: WeatherData
    user_profile: UserProfile
    preferences: Dict[str, Any]
    location: str


class MLRankRequest(BaseModel):
    context: MLContext
    candidates: List[MLItem] = Field(..., min_length=1, max_length=100, description="Candidates to rank (1-100)")

    @field_validator("candidates")
    @classmethod
    def validate_candidates_count(cls, v: List[MLItem]) -> List[MLItem]:
        """Validate candidate count is within bounds"""
        if len(v) < 1:
            raise ValueError("candidates must contain at least 1 item")
        if len(v) > 100:
            raise ValueError(f"candidates must not exceed 100 items, got: {len(v)}")
        return v


class RankedItem(BaseModel):
    id: int
    score: float


class MLRankResponse(BaseModel):
    model_config = {"protected_namespaces": ()}
    ranked: List[RankedItem]
    model_version: str
    processing_time_ms: float
    error: Optional[str] = None
