"""
Internal canonical schema for ML service
Used to standardize item representation across different API versions
"""
from typing import Dict, List, Optional, Any
from pydantic import BaseModel, Field
from enum import Enum


class InternalSourceType(str, Enum):
    SYNTHETIC = "synthetic"
    USER = "user"
    PARTNER = "partner"
    MANUAL = "manual"


class InternalItem(BaseModel):
    """
    Internal canonical representation of a clothing item
    Ensures consistent field names across all API versions
    """
    id: int
    name: str
    category: str
    subcategory: str
    gender: str
    style: str
    usage: str
    season: str
    base_colour: str
    formality_level: int = Field(ge=1, le=5)  # Consistent with feature builder
    warmth_level: int = Field(ge=1, le=10)    # Consistent with feature builder
    min_temp: int
    max_temp: int
    materials: List[str]
    fit: str
    pattern: str
    icon_emoji: str
    source: InternalSourceType
    is_owned: bool
    created_at: str
    source_priority: int = Field(ge=0, le=3)


class InternalWeatherData(BaseModel):
    temperature: float
    feels_like: float
    humidity: int
    wind_speed: float
    weather: str


class InternalUserProfile(BaseModel):
    age_range: str
    style_preference: str
    temperature_sensitivity: str
    formality_preference: str
    gender: str


class InternalContext(BaseModel):
    weather: InternalWeatherData
    user_profile: InternalUserProfile
    preferences: Dict[str, Any]
    location: str


class InternalRequest(BaseModel):
    context: InternalContext
    candidates: List[InternalItem] = Field(max_length=250)