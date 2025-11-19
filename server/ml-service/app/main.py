#!/usr/bin/env python3
"""
OutfitStyle ML Service - Production-Ready Entry Point

This is the main entry point for the OutfitStyle ML Service.
It initializes the Flask application, loads necessary components,
and sets up the production environment for the recommendation model.
"""
import os
import sys
import logging
from flask import Flask, request, jsonify, Response
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from prometheus_client import Counter, Histogram, generate_latest, multiprocess
from prometheus_client import start_http_server
from healthcheck import HealthCheck
import psycopg2
import psycopg2.extras
import pandas as pd
import numpy as np
from datetime import datetime
import time

# Add parent directory to path for module imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from model.advanced_trainer import AdvancedOutfitRecommender
from model.enhanced_predictor import EnhancedOutfitPredictor
from model.features import FeatureExtractor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger('outfitstyle.ml_service')

# Initialize Prometheus metrics
REQUEST_COUNT = Counter('outfitstyle_ml_service_request_count', 
                      'Total request count', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('outfitstyle_ml_service_request_latency_seconds', 
                          'Request latency in seconds', ['method', 'endpoint'])

# Global configuration
DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'user': os.getenv('DB_USER', 'outfitstyle'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'outfitstyle')
}

# Create Flask app
app = Flask(__name__)
CORS(app)

# Rate limiting
limiter = Limiter(
    key_func=get_remote_address,
    app=app,
    default_limits=["100 per minute"],
    storage_uri="memory://"
)

# Health check
health = HealthCheck(app)

def get_db_connection():
    """Create a new database connection."""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.cursor_factory = psycopg2.extras.RealDictCursor
        return conn
    except Exception as e:
        logger.exception("Database connection error")
        raise

def load_user_profile(user_id: int) -> dict:
    """Load user profile from database with fallback to default values."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT age_range, style_preference, temperature_sensitivity, formality_preference
                FROM user_profiles 
                WHERE user_id = %s
            """, (user_id,))
            result = cursor.fetchone()
            if result:
                return {
                    'age_range': result.get('age_range', '25-35'),
                    'style_preference': result.get('style_preference', 'casual'),
                    'temperature_sensitivity': result.get('temperature_sensitivity', 'normal'),
                    'formality_preference': result.get('formality_preference', 'informal')
                }
            return {
                'age_range': '25-35',
                'style_preference': 'casual',
                'temperature_sensitivity': 'normal',
                'formality_preference': 'informal'
            }
    except Exception as e:
        logger.error(f"Error loading user profile: {str(e)}")
        return {
            'age_range': '25-35',
            'style_preference': 'casual',
            'temperature_sensitivity': 'normal',
            'formality_preference': 'informal'
        }
    finally:
        if 'conn' in locals():
            conn.close()

def load_clothing_items(weather_data: dict, user_profile: dict) -> list:
    """Load clothing items from database based on weather and user profile."""
    try:
        conn = get_db_connection()
        with conn.cursor() as cursor:
            temperature = weather_data.get('temperature', 20)
            cursor.execute("""
                SELECT id, name, category, min_temp, max_temp, warmth_level, formality_level, style
                FROM clothing_items
                WHERE min_temp <= %s + 10 AND max_temp >= %s - 10
                ORDER BY 
                    CASE WHEN style = %s THEN 1 ELSE 2 END,
                    ABS(((min_temp + max_temp) / 2) - %s)
                LIMIT 100
            """, (temperature, temperature, user_profile.get('style_preference', 'casual'), temperature))
            items = cursor.fetchall()
            return items if items else []
    except Exception as e:
        logger.error(f"Error loading clothing items: {str(e)}")
        return []
    finally:
        if 'conn' in locals():
            conn.close()

def save_recommendation_to_db(user_id: int, weather_data: dict, recommendations: list, 
                           algorithm: str, confidence: float) -> int:
    """Save recommendation to database with error handling and transaction management."""
    try:
        conn = get_db_connection()
        conn.autocommit = False
        with conn.cursor() as cursor:
            cursor.execute("""
                INSERT INTO recommendations 
                (user_id, location, temperature, feels_like, weather, 
                 humidity, wind_speed, algorithm, confidence)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING id
            """, (
                user_id,
                weather_data.get('location', 'Unknown'),
                weather_data.get('temperature'),
                weather_data.get('feels_like'),
                weather_data.get('weather'),
                weather_data.get('humidity'),
                weather_data.get('wind_speed'),
                algorithm,
                confidence
            ))
            recommendation_id = cursor.fetchone()[0]
            
            for position, item in enumerate(recommendations, 1):
                cursor.execute("""
                    INSERT INTO recommendation_items 
                    (recommendation_id, clothing_item_id, confidence, position)
                    VALUES (%s, %s, %s, %s)
                """, (
                    recommendation_id,
                    item['id'],
                    item.get('ml_score', 0.0),
                    position
                ))
        conn.commit()
        return recommendation_id
    except Exception as e:
        if 'conn' in locals():
            conn.rollback()
        logger.exception("Error saving recommendation to database")
        return -1
    finally:
        if 'conn' in locals():
            conn.close()

def load_ml_model(model_path: str) -> AdvancedOutfitRecommender:
    """Load ML model from file with error handling and fallbacks."""
    model = AdvancedOutfitRecommender()
    try:
        model.load(model_path)
        logger.info(f"✅ Loaded ML model from {model_path}")
        return model
    except FileNotFoundError:
        logger.warning(f"⚠️ Model file not found: {model_path}")
        return None
    except Exception as e:
        logger.exception(f"Error loading model from {model_path}")
        return None

@app.before_request
def log_request_info():
    """Log request details for monitoring and debugging."""
    logger.info(f"Request: {request.method} {request.path}")
    if request.data:
        logger.debug(f"Request data: {request.data}")
    request.start_time = time.time()

@app.after_request
def log_response_info(response):
    """Log response details and update Prometheus metrics."""
    # Calculate request duration
    duration = time.time() - request.start_time
    REQUEST_LATENCY.labels(
        method=request.method, 
        endpoint=request.path
    ).observe(duration)
    
    # Update request counter
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.path,
        status=response.status_code
    ).inc()
    
    # Add request duration header for debugging
    response.headers['X-Request-Duration'] = f"{duration:.4f}"
    return response

@app.route('/metrics', methods=['GET'])
def metrics():
    """Prometheus metrics endpoint."""
    return Response(generate_latest(), mimetype='text/plain; version=0.0.4; charset=utf-8')

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint for Kubernetes and monitoring systems."""
    try:
        # Check database connection
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1")
        conn.close()
        
        # Check model loading
        model_path = os.getenv('MODEL_PATH', 'models/advanced_recommender.pkl')
        model = load_ml_model(model_path)
        model_status = "loaded" if model and model.is_trained else "not_loaded"
        
        return jsonify({
            'status': 'healthy',
            'service': 'ml-service',
            'database': 'connected',
            'model_status': model_status,
            'timestamp': datetime.utcnow().isoformat()
        }), 200
    except Exception as e:
        logger.exception("Health check failed")
        return jsonify({
            'status': 'unhealthy',
            'service': 'ml-service',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 500

@app.route('/api/ml/recommend', methods=['POST'])
@REQUEST_LATENCY.labels('POST', '/api/ml/recommend').time()
def recommend():
    """Main recommendation endpoint with comprehensive error handling."""
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No JSON data provided'}), 400
        
        user_id = data.get('user_id', 1)
        weather_data = data.get('weather', {})
        min_confidence = data.get('min_confidence', 0.5)
        
        # Validate required parameters
        if not weather_data:
            return jsonify({'error': 'Weather data is required'}), 400
        
        # Load model
        model_path = os.getenv('MODEL_PATH', 'models/advanced_recommender.pkl')
        model = load_ml_model(model_path)
        if not model or not model.is_trained:
            logger.error("ML model is not trained or could not be loaded")
            return jsonify({'error': 'ML model is not available'}), 503
        
        # Load user profile
        user_profile = load_user_profile(user_id)
        
        # Load clothing items
        available_items = load_clothing_items(weather_data, user_profile)
        if not available_items:
            return jsonify({'error': 'No suitable clothing items found'}), 404
        
        # Create predictor
        predictor = EnhancedOutfitPredictor(model)
        
        # Build outfit
        outfit = predictor.build_outfit(
            weather_data,
            user_profile,
            available_items,
            min_confidence=min_confidence
        )
        
        # Save to database
        recommendation_id = save_recommendation_to_db(
            user_id,
            weather_data,
            outfit['items'],
            outfit['algorithm'],
            outfit['outfit_score']
        )
        
        # Prepare response
        response = {
            'recommendation_id': recommendation_id,
            'user_id': user_id,
            'weather': weather_data,
            'recommendations': outfit['items'],
            'outfit_score': outfit['outfit_score'],
            'ml_powered': outfit['ml_powered'],
            'algorithm': outfit['algorithm'],
            'timestamp': datetime.utcnow().isoformat()
        }
        
        return jsonify(response)
    
    except Exception as e:
        logger.exception("Recommendation error")
        return jsonify({
            'error': 'Internal server error',
            'details': str(e)
        }), 500

@app.route('/api/ml/train', methods=['POST'])
def train_model():
    """Train model endpoint with comprehensive monitoring and logging."""
    try:
        data = request.json or {}
        optimize = data.get('optimize_hyperparameters', False)
        
        # Load training data
        conn = get_db_connection()
        query = """
        SELECT 
            r.temperature,
            r.weather,
            r.humidity,
            r.wind_speed,
            up.age_range,
            up.style_preference,
            up.temperature_sensitivity,
            up.formality_preference,
            ci.category,
            ci.style,
            ci.warmth_level,
            ci.formality_level,
            ri.confidence as ml_score,
            CASE WHEN rat.overall_rating >= 4 THEN 1 ELSE 0 END as is_recommended
        FROM recommendations r
        JOIN user_profiles up ON r.user_id = up.user_id
        JOIN recommendation_items ri ON r.id = ri.recommendation_id
        JOIN clothing_items ci ON ri.clothing_item_id = ci.id
        LEFT JOIN ratings rat ON r.id = rat.recommendation_id AND ci.id = rat.clothing_item_id
        WHERE r.created_at >= NOW() - INTERVAL '30 days'
            AND ri.confidence IS NOT NULL
        ORDER BY r.created_at DESC
        LIMIT 10000
        """
        df = pd.read_sql(query, conn)
        conn.close()
        
        if len(df) < 50:
            return jsonify({
                'status': 'error',
                'message': 'Not enough training data'
            }), 400
        
        # Train model
        model = AdvancedOutfitRecommender()
        metrics = model.train(df, optimize_hyperparameters=optimize)
        
        # Save model
        model_path = os.getenv('MODEL_PATH', 'models/advanced_recommender.pkl')
        os.makedirs(os.path.dirname(model_path), exist_ok=True)
        model.save(model_path)
        
        # Prepare response
        response = {
            'status': 'success',
            'metrics': {
                'accuracy': metrics.get('accuracy', 0.0),
                'precision': metrics.get('precision', 0.0),
                'recall': metrics.get('recall', 0.0),
                'f1_score': metrics.get('f1_score', 0.0),
                'auc': metrics.get('auc', 0.0),
                'cv_mean': metrics.get('cv_mean', 0.0),
                'cv_std': metrics.get('cv_std', 0.0),
                'samples': len(df),
                'timestamp': datetime.utcnow().isoformat()
            }
        }
        
        return jsonify(response)
    
    except Exception as e:
        logger.exception("Training error")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

def initialize_service():
    """Initialize the ML service with necessary setup."""
    # Set up Prometheus multiprocess mode
    if 'PROMETHEUS_MULTIPROC_DIR' in os.environ:
        multiprocess.MultiProcessCollector(os.environ['PROMETHEUS_MULTIPROC_DIR'])
    
    # Start Prometheus metrics server in a separate thread
    metrics_port = int(os.getenv('METRICS_PORT', '9090'))
    start_http_server(metrics_port)
    logger.info(f"✅ Prometheus metrics server started on port {metrics_port}")
    
    # Load model
    model_path = os.getenv('MODEL_PATH', 'models/advanced_recommender.pkl')
    model = load_ml_model(model_path)
    
    if not model or not model.is_trained:
        logger.warning("⚠️ No trained model found, using fallback model")
        # Here we could load a default model or set up model training
    else:
        logger.info("✅ ML service initialized with trained model")

if __name__ == '__main__':
    # Initialize service
    initialize_service()
    
    # Run Flask app
    port = int(os.getenv('PORT', '5000'))
    logger.info(f"🚀 Starting ML service on port {port}")
    app.run(
        host='0.0.0.0',
        port=port,
        debug=os.getenv('DEBUG', 'false').lower() == 'true',
        threaded=True
    )