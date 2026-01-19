from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field


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