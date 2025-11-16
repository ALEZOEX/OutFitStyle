from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
import psycopg2.extras
import pandas as pd
import numpy as np
import os
import logging
from datetime import datetime
from model.advanced_trainer import AdvancedOutfitRecommender
from model.predictor import AdvancedOutfitPredictor
from model.enhanced_predictor import EnhancedOutfitPredictor

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

recommender = AdvancedOutfitRecommender(model_type='gradient_boosting')
predictor = EnhancedOutfitPredictor(recommender)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'user': os.getenv('DB_USER', 'Admin'),
    'password': os.getenv('DB_PASSWORD', 'password'),
    'database': os.getenv('DB_NAME', 'outfitstyle')
}

def get_db_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        logger.error(f"DB connection error: {e}")
        raise

def load_user_profile(user_id: int) -> dict:
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute("""
            SELECT gender, age_range, style_preference, temperature_sensitivity, preferred_categories
            FROM user_profiles WHERE user_id = %s
        """, (user_id,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if result:
            profile = dict(result)
            profile['formality_preference'] = 'informal'
            return profile
        else:
            logger.warning(f"Profile not found for user {user_id}, using defaults")
            return {
                'age_range': '25-35',
                'style_preference': 'casual',
                'temperature_sensitivity': 'normal',
                'formality_preference': 'informal'
            }
    except Exception as e:
        logger.error(f"Error loading user profile: {e}")
        return {
            'age_range': '25-35',
            'style_preference': 'casual',
            'temperature_sensitivity': 'normal',
            'formality_preference': 'informal'
        }

def load_clothing_items(weather_data: dict, user_profile: dict) -> list:
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        
        temperature = weather_data.get('temperature', 20)
        
        cursor.execute("""
            SELECT id, name, category, subcategory, min_temp, max_temp, 
                   weather_conditions, style, warmth_level, formality_level, icon_emoji
            FROM clothing_items
            WHERE min_temp <= %s + 10 AND max_temp >= %s - 10
            ORDER BY 
                CASE WHEN style = %s THEN 1 ELSE 2 END,
                ABS(((min_temp + max_temp) / 2) - %s)
            LIMIT 50
        """, (
            temperature,
            temperature,
            user_profile.get('style_preference', 'casual'),
            temperature
        ))
        
        items = cursor.fetchall()
        cursor.close()
        conn.close()
        
        logger.info(f"Loaded {len(items)} clothing items from DB")
        
        for item in items:
            item['min_temp'] = float(item['min_temp']) if item['min_temp'] is not None else None
            item['max_temp'] = float(item['max_temp']) if item['max_temp'] is not None else None
        
        return [dict(item) for item in items]
        
    except Exception as e:
        logger.error(f"Error loading clothing items: {e}")
        return []

def save_recommendation_to_db(user_id: int, weather_data: dict, 
                             recommendations: list, algorithm: str, 
                             confidence: float) -> int:
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO recommendations 
            (user_id, location, temperature, feels_like, weather, 
             humidity, wind_speed, algorithm_version, ml_confidence)
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
                (recommendation_id, clothing_item_id, ml_score, position)
                VALUES (%s, %s, %s, %s)
            """, (
                recommendation_id,
                item['id'],
                item.get('ml_score', 0),
                position
            ))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        logger.info(f"Saved recommendation {recommendation_id}")
        return recommendation_id
        
    except Exception as e:
        logger.error(f"Error saving recommendation: {e}")
        if conn:
            conn.rollback()
        return -1

@app.route('/health', methods=['GET'])
def health():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.close()
        conn.close()
        db_status = "connected"
    except:
        db_status = "disconnected"
    
    return jsonify({
        'status': 'ok',
        'service': 'Advanced ML Service',
        'model_trained': recommender.is_trained,
        'database': db_status
    })

@app.route('/api/ml/recommend', methods=['POST'])
def recommend():
    try:
        data = request.json
        user_id = data.get('user_id', 1)
        weather_data = data.get('weather', {})
        min_confidence = data.get('min_confidence', 0.5)
        
        logger.info(f"🎯 Recommendation request: user={user_id}, temp={weather_data.get('temperature')}°C")
        
        user_profile = load_user_profile(user_id)
        logger.info(f"Loaded user profile: {user_profile}")
        available_items = load_clothing_items(weather_data, user_profile)
        logger.info(f"Loaded {len(available_items)} clothing items")
        
        if not available_items:
            return jsonify({'error': 'No suitable clothing items found'}), 404
        
        # Lower the minimum confidence to ensure we get some recommendations
        adjusted_min_confidence = min(0.3, min_confidence)
        
        outfit = predictor.build_outfit(
            weather_data, 
            user_profile, 
            available_items,
            min_confidence=adjusted_min_confidence
        )
        
        recommendation_id = save_recommendation_to_db(
            user_id,
            weather_data,
            outfit['items'],
            outfit['algorithm'],
            outfit['outfit_score']
        )
        
        response = {
            'recommendation_id': recommendation_id,
            'user_id': user_id,
            'weather': weather_data,
            'recommendations': outfit['items'],
            'outfit_score': outfit['outfit_score'],
            'ml_powered': outfit['ml_powered'],
            'algorithm': outfit['algorithm']
        }
        
        return jsonify(response)
        
    except Exception as e:
        logger.error(f"Error in recommend endpoint: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500

@app.route('/api/ml/train', methods=['POST'])
def train_model():
    try:
        data = request.json or {}
        optimize = data.get('optimize_hyperparameters', False)
        
        conn = get_db_connection()
        query = """
        SELECT ...
        """
        df = pd.read_sql(query, conn)
        conn.close()
        
        if len(df) < 50:
            return jsonify({'error': 'Not enough training data'}), 400
        
        metrics = recommender.train(df, optimize_hyperparameters=optimize)
        recommender.save('models/advanced_recommender.pkl')
        
        return jsonify({'status': 'success', 'metrics': metrics})
    except Exception as e:
        logger.error(f"Training error: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    try:
        # Try to load the Kaggle-trained model first, fallback to default
        model_paths = [
            'models/kaggle_trained_recommender.pkl',
            'models/advanced_recommender.pkl'
        ]
        
        model_loaded = False
        for model_path in model_paths:
            if os.path.exists(model_path):
                recommender.load(model_path)
                predictor = AdvancedOutfitPredictor(recommender)
                logger.info(f"✅ Loaded trained ML model from {model_path}")
                model_loaded = True
                break
        
        if not model_loaded:
            logger.warning("⚠️ No trained model found")
    except Exception as e:
        logger.error(f"Failed to load model: {e}")
    
    logger.info("🚀 Starting Advanced ML Service on port 5000")
    app.run(host='0.0.0.0', port=5000, debug=True)