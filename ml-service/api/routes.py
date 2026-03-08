"""
API Routes for Category Classification

This module provides HTTP endpoints for the category classification service.
"""

from fastapi import APIRouter, HTTPException
from services.category_classifier import (
    ClassifyRequest,
    ClassifyResponse,
    get_classifier,
)
import logging

logger = logging.getLogger(__name__)

# Create router for classification endpoints
router = APIRouter(prefix="/api/v1", tags=["classification"])


@router.post("/classify", response_model=ClassifyResponse)
async def classify_item(request: ClassifyRequest) -> ClassifyResponse:
    """
    Classify a clothing item into a category.

    This endpoint accepts item attributes and returns a predicted category
    with a confidence score.

    Args:
        request: Classification request with item attributes

    Returns:
        Classification response with predicted category and confidence

    Raises:
        HTTPException: If classification fails
    """
    try:
        classifier = get_classifier()
        response = classifier.classify(request)

        logger.info(
            f"Classification successful: subcategory='{request.subcategory}' -> "
            f"category='{response.category}' (confidence={response.confidence})"
        )

        return response

    except Exception as e:
        logger.error(f"Classification failed: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Classification failed: {str(e)}"
        )


@router.get("/health")
async def health_check():
    """
    Health check endpoint for the classification service.

    Returns:
        Health status
    """
    return {
        "status": "healthy",
        "service": "category-classification"
    }
