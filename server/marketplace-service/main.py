import logging
import os
from typing import Dict, Any, List, Optional

from flask import Flask, jsonify, request
from flask_cors import CORS
import psycopg2
import psycopg2.extras

# ---------------------------------------
# Логирование
# ---------------------------------------
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("marketplace-service")

# ---------------------------------------
# Flask
# ---------------------------------------
app = Flask(__name__)
CORS(app)

# ---------------------------------------
# Подключение к БД
# ---------------------------------------
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "postgres"),
    "port": os.getenv("DB_PORT", "5432"),
    "user": os.getenv("DB_USER", "Admin"),
    "password": os.getenv("DB_PASSWORD", "password"),
    "database": os.getenv("DB_NAME", "outfitstyle"),
}


def get_db_connection():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        logger.error(f"DB connection error: {e}")
        raise


def load_clothing_items_for_ml(
    user_id: Optional[int],
    weather_data: Dict[str, Any],
    user_profile: Dict[str, Any],
    limit: int = 50,
    source: str = "wardrobe",
) -> List[Dict[str, Any]]:
    """
    Загружает вещи из clothing_items.

    source:
      - "wardrobe" -> только вещи пользователя (user_id = ...)
      - "catalog"  -> общий каталог (user_id IS NULL)
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)

        temperature = float(weather_data.get("temperature", 20.0))
        style_pref = user_profile.get("style_preference", "casual")

        where_clauses = [
            "(min_temp IS NULL OR min_temp <= %s + 10)",
            "(max_temp IS NULL OR max_temp >= %s - 10)",
        ]
        params: List[Any] = [temperature, temperature]

        # Режим гардероба пользователя
        if source == "wardrobe" and user_id is not None:
            where_clauses.append("user_id = %s")
            params.append(user_id)

        # Режим общего каталога
        if source == "catalog":
            where_clauses.append("user_id IS NULL")

        sql = f"""
            SELECT
                id,
                name,
                category,
                subcategory,
                min_temp,
                max_temp,
                weather_conditions,
                style,
                warmth_level,
                formality_level,
                icon_emoji
            FROM clothing_items
            WHERE {" AND ".join(where_clauses)}
            ORDER BY
                CASE WHEN style = %s THEN 1 ELSE 2 END,
                ABS(COALESCE((min_temp + max_temp) / 2, %s) - %s)
            LIMIT %s
        """
        params.extend([style_pref, temperature, temperature, limit])

        cursor.execute(sql, params)
        items = cursor.fetchall()
        cursor.close()
        conn.close()

        logger.info(
            f"Loaded {len(items)} clothing items from DB for ML "
            f"(source={source}, user_id={user_id})"
        )

        normalized: List[Dict[str, Any]] = []
        for item in items:
            d = dict(item)
            if d.get("min_temp") is not None:
                d["min_temp"] = float(d["min_temp"])
            if d.get("max_temp") is not None:
                d["max_temp"] = float(d["max_temp"])
            normalized.append(d)

        return normalized

    except Exception as e:
        logger.error(f"Error loading clothing items for ML: {e}", exc_info=True)
        return []


# ---------------------------------------
# Маршруты
# ---------------------------------------


@app.route("/health", methods=["GET"])
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

    return jsonify(
        {
            "status": "ok",
            "service": "Marketplace Service",
            "database": db_status,
        }
    )


@app.route("/api/marketplace/items-for-ml", methods=["POST"])
def items_for_ml():
    """
    Ожидает JSON:
      {
        "user_id": 1,
        "weather": { ... },
        "user_profile": { ... },
        "limit": 50,
        "source": "wardrobe" | "catalog"
      }

    Возвращает:
      { "items": [ {...}, ... ] }
    """
    try:
        data = request.get_json() or {}
        user_id = data.get("user_id")
        weather = data.get("weather") or {}
        user_profile = data.get("user_profile") or {}
        limit = int(data.get("limit", 50))
        source = data.get("source", "wardrobe")

        logger.info(
            f"Items-for-ML request: user_id={user_id}, source={source}, "
            f"temp={weather.get('temperature')}, "
            f"style={user_profile.get('style_preference')}, limit={limit}"
        )

        items = load_clothing_items_for_ml(
            user_id=user_id,
            weather_data=weather,
            user_profile=user_profile,
            limit=limit,
            source=source,
        )
        return jsonify({"items": items})

    except Exception as e:
        logger.error(f"Error in items_for_ml endpoint: {e}", exc_info=True)
        return jsonify({"error": str(e)}), 500


@app.route("/")
def root():
    return "Marketplace Service"


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    logger.info(f"Starting Marketplace Service on port {port}")
    app.run(host="0.0.0.0", port=port)