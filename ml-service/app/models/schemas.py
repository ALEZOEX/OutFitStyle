"""Schema definitions for the recommendation engine"""
from dataclasses import dataclass
from typing import List, Optional
from enum import Enum


class RecommendationType(Enum):
    RANKING = "ranking"
    OUTFIT_GENERATION = "outfit_generation"
    SIMILAR_ITEMS = "similar_items"


@dataclass
class WardrobeItem:
    id: str
    category: str
    color: str
    warmth_level: int
    style: str
    occasions: List[str]


@dataclass
class Weather:
    temperature: float
    feels_like: float
    humidity: int
    condition: str
    wind_speed: float
    precipitation_probability: int


@dataclass
class RecommendationRequest:
    user_id: str
    wardrobe: List[WardrobeItem]
    weather: Weather
    occasion: str
    max_recommendations: int = 5