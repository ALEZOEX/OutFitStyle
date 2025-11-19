#!/usr/bin/env python3
"""
Production-ready ML Service for OutfitStyle
"""
import os
import sys
import logging
import time
from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI, HTTPException, Request, Depends
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import start_http_server, Counter, Histogram

# Add project root to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from app.config import settings
from app.services.recommendation_service import RecommendationService
from app.services.training_service import TrainingService
from app.models.schemas import (
    RecommendationRequest,
    RecommendationResponse,
    TrainingRequest,
    TrainingResponse
)
from app.utils.metrics import setup_metrics
from app.utils.logging import setup_logging
from app.utils.security import verify_api_key

# Setup logging
logger = setup_logging()

# Prometheus metrics
REQUEST_COUNT = Counter('ml_service_requests_total', 'Total ML service requests', ['endpoint', 'status'])
REQUEST_LATENCY = Histogram('ml_service_request_latency_seconds', 'Request latency in seconds', ['endpoint'])

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle - startup and shutdown events"""
    # Startup
    logger.info("🚀 Starting OutfitStyle ML Service")
    logger.info(f"Environment: {settings.ENVIRONMENT}")
    logger.info(f"Model path: {settings.MODEL_PATH}")
    
    # Initialize services
    try:
        app.state.recommendation_service = RecommendationService()
        app.state.training_service = TrainingService()
        logger.info("✅ Services initialized successfully")
    except Exception as e:
        logger.critical(f"❌ Failed to initialize services: {str(e)}")
        raise
    
    # Start metrics server
    try:
        start_http_server(settings.METRICS_PORT)
        logger.info(f"📈 Prometheus metrics server started on port {settings.METRICS_PORT}")
    except Exception as e:
        logger.warning(f"⚠️ Could not start metrics server: {str(e)}")
    
    yield
    
    # Shutdown
    logger.info("🔧 Shutting down OutfitStyle ML Service...")

# Create FastAPI app
app = FastAPI(
    title="OutfitStyle ML Service",
    description="Advanced machine learning service for outfit recommendations",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/api/ml/recommend", response_model=RecommendationResponse)
async def recommend(
    request: RecommendationRequest,
    api_key: str = Depends(verify_api_key)
):
    """Main recommendation endpoint"""
    start_time = time.time()
    logger.info(f"📍 Recommendation request for user_id={request.user_id}, city={request.weather.location}")
    
    try:
        # Get recommendations
        recommendations = await app.state.recommendation_service.get_recommendations(
            user_id=request.user_id,
            weather_data=request.weather.dict(),
            min_confidence=request.min_confidence
        )
        
        processing_time = time.time() - start_time
        logger.info(
            f"✅ Generated {len(recommendations['items'])} recommendations "
            f"(score: {recommendations['outfit_score']:.2f}), "
            f"processing time: {processing_time:.2f}s"
        )
        
        REQUEST_COUNT.labels("recommend", "200").inc()
        return recommendations
        
    except ValueError as e:
        logger.warning(f"Validation error: {str(e)}")
        REQUEST_COUNT.labels("recommend", "400").inc()
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.exception(f"Unexpected error: {str(e)}")
        REQUEST_COUNT.labels("recommend", "500").inc()
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.post("/api/ml/train", response_model=TrainingResponse)
async def train_model(
    request: TrainingRequest,
    api_key: str = Depends(verify_api_key)
):
    """Train model endpoint"""
    logger.info("🤖 Starting model training process...")
    
    try:
        training_result = await app.state.training_service.train_model(
            optimize_hyperparameters=request.optimize_hyperparameters,
            dataset_path=request.dataset_path
        )
        
        logger.info(
            f"✅ Training completed successfully. "
            f"Accuracy: {training_result['metrics']['accuracy']:.2%}, "
            f"F1 Score: {training_result['metrics']['f1_score']:.2%}"
        )
        
        REQUEST_COUNT.labels("train", "200").inc()
        return training_result
        
    except ValueError as e:
        logger.warning(f"Training validation error: {str(e)}")
        REQUEST_COUNT.labels("train", "400").inc()
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.exception(f"Unexpected training error: {str(e)}")
        REQUEST_COUNT.labels("train", "500").inc()
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring systems"""
    try:
        # Check model status
        model_status = "loaded" if app.state.recommendation_service.is_model_loaded() else "not_loaded"
        
        # Check database connection
        db_status = "connected" if await app.state.recommendation_service.check_database() else "disconnected"
        
        return {
            "status": "healthy",
            "service": "ml-service",
            "database": db_status,
            "model_status": model_status,
            "timestamp": time.time()
        }
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return {
            "status": "unhealthy",
            "service": "ml-service",
            "error": str(e),
            "timestamp": time.time()
        }

if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.ENVIRONMENT == "development",
        workers=settings.WORKERS,
        log_config=None,
        timeout_keep_alive=30
    )