from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field


class OutfitItem(BaseModel):
    id: Any
    score: float


class Outfit(BaseModel):
    outfit_score: float
    breakdown: Dict[str, float] = Field(default_factory=dict)
    items: Dict[str, OutfitItem] = Field(default_factory=dict)  # category -> item


class OutfitsResponse(BaseModel):
    model_config = {"protected_namespaces": ()}
    outfits: List[Outfit] = Field(default_factory=list)
    model_version: str
    processing_time_ms: float
    error: Optional[str] = None
