from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
import psycopg2.extras
import pandas as pd
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
    """Загружаем профиль пользователя из user_profiles."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cursor.execute("""
            SELECT gender,
                   age_range,
                   style_preference,
                   temperature_sensitivity,
                   preferred_categories
            FROM user_profiles
            WHERE user_id = %s
        """, (user_id,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()

        if result:
            profile = dict(result)
            profile.setdefault('formality_preference', 'informal')
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
    """Загружаем одежду из clothing_items по температуре и стилю."""
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        temperature = float(weather_data.get('temperature', 20.0))

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
            temperature,
        ))

        items = cursor.fetchall()
        cursor.close()
        conn.close()

        logger.info(f"Loaded {len(items)} clothing items from DB")

        normalized = []
        for item in items:
            d = dict(item)
            if d.get('min_temp') is not None:
                d['min_temp'] = float(d['min_temp'])
            if d.get('max_temp') is not None:
                d['max_temp'] = float(d['max_temp'])
            normalized.append(d)

        return normalized

    except Exception as e:
        logger.error(f"Error loading clothing items: {e}")
        return []


def save_recommendation_to_db(
    user_id: int,
    weather_data: dict,
    recommendations: list,
    algorithm: str,
    outfit_score: float,
    ml_powered: bool,
) -> int:
    """
    Сохраняем рекомендацию в recommendations и recommendation_items
    под новую схему (init.sql):

    recommendations:
      user_id, temperature, weather, min_temp, max_temp,
      will_rain, will_snow, location, outfit_score, ml_powered, algorithm

    recommendation_items:
      recommendation_id, clothing_item_id, confidence_score, position
    """
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        temp = weather_data.get('temperature')
        weather = weather_data.get('weather', '')
        location = weather_data.get('location', 'Unknown')

        min_temp = None
        max_temp = None
        if recommendations:
            temps_min = [it.get('min_temp') for it in recommendations if it.get('min_temp') is not None]
            temps_max = [it.get('max_temp') for it in recommendations if it.get('max_temp') is not None]
            if temps_min:
                min_temp = min(temps_min)
            if temps_max:
                max_temp = max(temps_max)

        will_rain = False
        will_snow = False
        if isinstance(weather, str):
            low = weather.lower()
            if 'rain' in low or 'дожд' in low:
                will_rain = True
            if 'snow' in low or 'снег' in low:
                will_snow = True

        cursor.execute("""
            INSERT INTO recommendations (
                user_id, temperature, weather, min_temp, max_temp,
                will_rain, will_snow, location, outfit_score, ml_powered, algorithm
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            user_id,
            temp,
            weather,
            min_temp,
            max_temp,
            will_rain,
            will_snow,
            location,
            outfit_score,
            ml_powered,
            algorithm,
        ))

        recommendation_id = cursor.fetchone()[0]

        for position, item in enumerate(recommendations, 1):
            cursor.execute("""
                INSERT INTO recommendation_items (
                    recommendation_id, clothing_item_id, confidence_score, position
                )
                VALUES (%s, %s, %s, %s)
            """, (
                recommendation_id,
                item['id'],
                item.get('ml_score', 0.0),
                position,
            ))

        conn.commit()
        cursor.close()
        conn.close()

        logger.info(f"Saved recommendation {recommendation_id}")
        return recommendation_id

    except Exception as e:
        logger.error(f"Error saving recommendation: {e}", exc_info=True)
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
    except Exception:
        db_status = "disconnected"

    return jsonify({
        'status': 'ok',
        'service': 'Advanced ML Service',
        'model_trained': getattr(recommender, "is_trained", False),
        'database': db_status,
    })


@app.route('/api/ml/recommend', methods=['POST'])
def recommend():
    try:
        data = request.json or {}
        user_id = data.get('user_id', 1)
        weather_data = data.get('weather', {})
        min_confidence = float(data.get('min_confidence', 0.5))

        logger.info(
            f"🎯 Recommendation request: user={user_id}, temp={weather_data.get('temperature')}°C"
        )

        user_profile = load_user_profile(user_id)
        logger.info(f"Loaded user profile: {user_profile}")

        available_items = load_clothing_items(weather_data, user_profile)
        logger.info(f"Loaded {len(available_items)} clothing items")

        if not available_items:
            return jsonify({'error': 'No suitable clothing items found'}), 404

        adjusted_min_confidence = min(0.3, min_confidence)

        outfit = predictor.build_outfit(
            weather_data,
            user_profile,
            available_items,
            min_confidence=adjusted_min_confidence,
        )

        outfit_items = outfit.get('items', [])
        outfit_score = float(outfit.get('outfit_score', 0.0))
        ml_powered = bool(outfit.get('ml_powered', True))
        algorithm = outfit.get('algorithm', 'advanced_recommender')

        recommendation_id = save_recommendation_to_db(
            user_id=user_id,
            weather_data=weather_data,
            recommendations=outfit_items,
            algorithm=algorithm,
            outfit_score=outfit_score,
            ml_powered=ml_powered,
        )

        response = {
            'recommendation_id': recommendation_id,
            'user_id': user_id,
            'weather': weather_data,
            'recommendations': outfit_items,
            'outfit_score': outfit_score,
            'ml_powered': ml_powered,
            'algorithm': algorithm,
        }

        return jsonify(response)

    except Exception as e:
        logger.error(f"Error in recommend endpoint: {e}", exc_info=True)
        return jsonify({'error': str(e)}), 500


@app.route('/api/ml/train', methods=['POST'])
def train_model():
    try:
        data = request.json or {}
        optimize = bool(data.get('optimize_hyperparameters', False))

        conn = get_db_connection()
        query = """
        SELECT
            r.temperature,
            r.weather,
            NULL::DOUBLE PRECISION    AS humidity,
            NULL::DOUBLE PRECISION    AS wind_speed,
            up.gender,
            up.age_range,
            up.style_preference,
            up.temperature_sensitivity,
            ci.category,
            ci.style,
            ci.warmth_level,
            ci.formality_level,
            ri.confidence_score       AS ml_score,
            1                         AS is_liked
        FROM recommendations r
        JOIN user_profiles up
            ON r.user_id = up.user_id
        JOIN recommendation_items ri
            ON r.id = ri.recommendation_id
        JOIN clothing_items ci
            ON ri.clothing_item_id = ci.id
        WHERE r.created_at >= NOW() - INTERVAL '30 days'
        ORDER BY r.created_at DESC
        LIMIT 10000
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
    model_loaded = False

    model_paths = [
        'models/kaggle_trained_recommender.pkl',
        'models/advanced_recommender.pkl',
    ]

    # Создаём папку models если не существует
    os.makedirs('models', exist_ok=True)

    for model_path in model_paths:
        if os.path.exists(model_path):
            try:
                recommender.load(model_path)
                predictor = EnhancedOutfitPredictor(recommender)
                logger.info(f"✅ Loaded trained ML model from {model_path}")
                model_loaded = True
                break
            except ModuleNotFoundError as e:
                # Несовместимая версия sklearn - удаляем старую модель
                logger.warning(f"⚠️ Model {model_path} incompatible with current sklearn: {e}")
                try:
                    os.remove(model_path)
                    logger.info(f"🗑️ Removed incompatible model: {model_path}")
                except Exception as del_err:
                    logger.warning(f"Could not delete {model_path}: {del_err}")
            except Exception as e:
                logger.warning(f"⚠️ Failed to load {model_path}: {e}")

    if not model_loaded:
        logger.warning("⚠️ No trained model found - using rule-based recommendations")
        logger.info("💡 Train a new model via POST /api/ml/train")

    logger.info("🚀 Starting Advanced ML Service on port 5000")
    app.run(host='0.0.0.0', port=5000, debug=True)