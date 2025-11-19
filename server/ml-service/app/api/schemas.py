from pydantic import BaseModel
from typing import List, Optional

class WeatherData(BaseModel):
    location: str
    temperature: float
    feels_like: float
    weather: str
    humidity: int
    wind_speed: float

class RecommendationRequest(BaseModel):
    user_id: int
    weather: WeatherData

class RecommendationItem(BaseModel):
    item_id: int
    name: str
    confidence: float

class RecommendationResponse(BaseModel):
    recommendations: List[RecommendationItem]