from typing import Dict, List, Optional, Any
from pydantic import BaseModel, Field
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
    temperature: float
    feels_like: float
    humidity: int
    wind_speed: float
    weather: str


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
    candidates: List[MLItem] = Field(max_items=250)


class RankedItem(BaseModel):
    id: int
    score: float


class MLRankResponse(BaseModel):
    ranked: List[RankedItem]
    model_version: str
    processing_time_ms: float
    error: Optional[str] = None