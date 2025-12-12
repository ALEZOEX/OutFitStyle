from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field


class MLContext(BaseModel):
    """Context for ML ranking including weather, user profile, and preferences"""
    weather: Dict[str, Any] = Field(..., description="Weather information")
    user_profile: Dict[str, Any] = Field(..., description="User profile information") 
    preferences: Dict[str, Any] = Field(default_factory=dict, description="Additional preferences")
    location: str = Field(..., description="Location for weather information")


class MLItem(BaseModel):
    """Represents a clothing item for ML ranking"""
    id: int = Field(..., description="Unique identifier for the item")
    name: str = Field(..., description="Name of the item")
    category: str = Field(..., description="Category of the item (e.g., upper, lower)")
    subcategory: str = Field(..., description="Subcategory of the item (e.g., tshirt, jeans)")
    gender: str = Field(default="unisex", description="Gender specification")
    style: str = Field(..., description="Style of the item")
    usage: str = Field(..., description="Usage context")
    season: str = Field(..., description="Seasonal appropriateness")
    base_colour: str = Field(..., description="Base color")
    formality: int = Field(..., ge=1, le=5, description="Formality level (1-5)")
    warmth: int = Field(..., ge=1, le=10, description="Warmth level (1-10)")
    min_temp: int = Field(..., description="Minimum comfortable temperature")
    max_temp: int = Field(..., description="Maximum comfortable temperature")
    materials: List[str] = Field(default_factory=list, description="List of materials")
    fit: str = Field(..., description="Fit of the item")
    pattern: str = Field(..., description="Pattern of the item")
    icon_emoji: str = Field(..., description="Icon emoji for the item")
    source: str = Field(..., description="Source of the item (user, synthetic, partner, manual)")
    is_owned: bool = Field(default=False, description="Whether item is owned by user")
    created_at: str = Field(..., description="Creation timestamp")
    source_priority: int = Field(default=0, ge=0, le=3, description="Priority of the source (0-3)")


class MLRankRequest(BaseModel):
    """Request for ML ranking of clothing items"""
    context: MLContext = Field(..., description="Context for ranking")
    candidates: List[MLItem] = Field(..., max_length=250, description="Candidate items to rank")


class RankedItem(BaseModel):
    """Represents a ranked item with score"""
    id: int = Field(..., description="Unique identifier of the item")
    score: float = Field(..., description="Ranking score")


class MLRankResponse(BaseModel):
    """Response from ML ranking service"""
    ranked: List[RankedItem] = Field(..., description="List of ranked items")
    model_version: str = Field(..., description="Version of the model used")
    processing_time_ms: float = Field(..., description="Processing time in milliseconds")
    error: Optional[str] = Field(default=None, description="Error message if any")


# Translation-related models
class TranslationRequest(BaseModel):
    """Request for translating text"""
    text: str = Field(..., description="Text to translate")
    source_language: str = Field(default="en", description="Source language code (e.g., 'en')")
    target_language: str = Field(..., description="Target language code (e.g., 'ru')")


class TranslationResponse(BaseModel):
    """Response from translation service"""
    translated_text: str = Field(..., description="Translated text")
    source_language: str = Field(..., description="Detected source language")
    target_language: str = Field(..., description="Target language")
    processing_time_ms: float = Field(..., description="Processing time in milliseconds")


class BatchTranslationRequest(BaseModel):
    """Request for translating multiple texts"""
    texts: List[str] = Field(..., max_length=100, description="List of texts to translate")
    source_language: str = Field(default="en", description="Source language code")
    target_language: str = Field(..., description="Target language code")


class BatchTranslationResponse(BaseModel):
    """Response from batch translation service"""
    translated_texts: List[str] = Field(..., description="List of translated texts")
    source_language: str = Field(..., description="Source language")
    target_language: str = Field(..., description="Target language")
    processing_time_ms: float = Field(..., description="Processing time in milliseconds")