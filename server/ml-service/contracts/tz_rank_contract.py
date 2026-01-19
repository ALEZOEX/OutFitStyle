from pydantic import BaseModel, Field
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
    temperature: float
    feels_like: float
    humidity: int
    wind_speed: float
    wind_direction: int = 0
    weather_code: str = ""
    precipitation_chance: int = 0
    occasion: str = ""
    formality: int = 2
    time_of_day: str = "day"
    day_of_week: int = 0


class TZUserPreferences(BaseModel):
    preferred_styles: List[str] = Field(default_factory=list)
    avoid_styles: List[str] = Field(default_factory=list)
    color_preferences: List[str] = Field(default_factory=list)
    avoid_colors: List[str] = Field(default_factory=list)
    preferred_categories: List[str] = Field(default_factory=list)
    temperature_sensitivity: int = 0


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
    candidates: List[TZCandidate] = Field(max_length=250)


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