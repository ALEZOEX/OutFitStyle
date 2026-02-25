#!/bin/bash
#
# Скрипт периодической перегенерации рекомендаций
# Запускается по cron или вручную при обновлении каталога
#
# Usage:
#   ./scripts/regenerate_recommendations.sh [--full] [--users USER_ID,...]
#
# Переменные окружения:
#   DB_DSN - connection string к PostgreSQL
#   ML_SERVICE_URL - URL ML сервиса (по умолчанию: http://localhost:8000)
#   BATCH_SIZE - количество пользователей для обработки за раз (по умолчанию: 100)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Default values
FULL_REGENERATE=false
USER_IDS=""
BATCH_SIZE="${BATCH_SIZE:-100}"
ML_SERVICE_URL="${ML_SERVICE_URL:-http://localhost:8000}"
LOG_FILE="${PROJECT_ROOT}/data/logs/recommendations_regeneration.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

info() { log "${GREEN}INFO${NC}" "$@"; }
warn() { log "${YELLOW}WARN${NC}" "$@"; }
error() { log "${RED}ERROR${NC}" "$@"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --full)
            FULL_REGENERATE=true
            shift
            ;;
        --users)
            USER_IDS="$2"
            shift 2
            ;;
        --batch-size)
            BATCH_SIZE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--full] [--users USER_ID,...] [--batch-size N]"
            echo ""
            echo "Options:"
            echo "  --full        Regenerate recommendations for all users"
            echo "  --users       Comma-separated list of user IDs to process"
            echo "  --batch-size  Number of users to process per batch (default: 100)"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

info "Starting recommendations regeneration..."
info "Mode: $([ "$FULL_REGENERATE" = true ] && echo 'FULL' || echo 'INCREMENTAL')"
info "ML Service URL: $ML_SERVICE_URL"

# Check database connection
if [[ -z "${DB_DSN:-}" ]]; then
    error "DB_DSN environment variable is not set"
    exit 1
fi

# Check ML service availability
if ! curl -s -o /dev/null -w "%{http_code}" "$ML_SERVICE_URL/health" | grep -q "200"; then
    warn "ML service is not available at $ML_SERVICE_URL"
    warn "Continuing without ML scoring..."
fi

# Python script for regeneration
python3 << 'PYTHON_SCRIPT'
import os
import sys
import json
import logging
import psycopg2
from psycopg2.extras import execute_batch, RealDictCursor
from datetime import datetime, timezone
from typing import List, Dict, Any, Optional
import requests

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('regenerate_recommendations')

# Configuration
DB_DSN = os.getenv('DB_DSN')
ML_SERVICE_URL = os.getenv('ML_SERVICE_URL', 'http://localhost:8000')
BATCH_SIZE = int(os.getenv('BATCH_SIZE', '100'))
FULL_REGENERATE = os.getenv('FULL_REGENERATE', 'false').lower() == 'true'
USER_IDS_FILTER = os.getenv('USER_IDS_FILTER', '')

def get_db_connection():
    return psycopg2.connect(DB_DSN)

def fetch_users(conn, limit: Optional[int] = None) -> List[Dict[str, Any]]:
    """Fetch users for recommendation generation"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        if USER_IDS_FILTER:
            user_ids = [uid.strip() for uid in USER_IDS_FILTER.split(',') if uid.strip()]
            placeholders = ','.join(['%s'] * len(user_ids))
            cur.execute(f"""
                SELECT id, email, preferences 
                FROM users 
                WHERE id = ANY(ARRAY[{placeholders}])
                ORDER BY id
            """, user_ids)
        elif not FULL_REGENERATE:
            # Only users without recent recommendations (last 7 days)
            cur.execute("""
                SELECT u.id, u.email, u.preferences
                FROM users u
                LEFT JOIN recommendations r ON u.id = r.user_id 
                    AND r.created_at > NOW() - INTERVAL '7 days'
                WHERE r.id IS NULL
                ORDER BY u.id
                LIMIT %s
            """, (limit or BATCH_SIZE,))
        else:
            # All users
            cur.execute("""
                SELECT id, email, preferences 
                FROM users 
                ORDER BY id
                LIMIT %s
            """, (limit or BATCH_SIZE,))
        
        return cur.fetchall()

def fetch_catalog_items(conn) -> List[Dict[str, Any]]:
    """Fetch active catalog items for recommendations"""
    with conn.cursor(cursor_factory=RealDictCursor) as cur:
        cur.execute("""
            SELECT 
                id, name, category, subcategory, gender, style, usage,
                season, base_colour, warmth_level, min_temp, max_temp,
                materials, brand, image_url, source
            FROM clothing_items
            WHERE is_active = true
            ORDER BY category, subcategory
        """)
        return cur.fetchall()

def get_current_weather() -> Dict[str, Any]:
    """Get current weather (mock for now, should use weather API)"""
    # TODO: Integrate with weather API (OpenWeather/Open-Meteo)
    return {
        "temperature": 20,
        "feels_like": 18,
        "humidity": 65,
        "wind_speed": 3.5,
        "weather": "clear"
    }

def generate_recommendations_for_user(
    user: Dict[str, Any],
    items: List[Dict[str, Any]],
    weather: Dict[str, Any]
) -> Optional[Dict[str, Any]]:
    """Generate recommendations for a single user via ML service"""
    try:
        # Prepare candidates for ML ranking
        candidates = []
        for item in items:
            candidates.append({
                "id": str(item['id']),
                "name": item['name'],
                "category": item['category'],
                "subcategory": item['subcategory'],
                "gender": item['gender'] or 'unisex',
                "style": item['style'],
                "usage": item['usage'],
                "season": item['season'],
                "base_colour": item['base_colour'],
                "warmth": item['warmth_level'] or 5,
                "min_temp": item['min_temp'],
                "max_temp": item['max_temp'],
                "materials": item['materials'] or [],
                "source": item['source'],
                "source_priority": 1 if item['source'] == 'user' else 2
            })

        # Prepare request to ML service
        payload = {
            "context": {
                "weather": weather,
                "user_profile": {
                    "age_range": "25-35",
                    "style_preference": user.get('preferences', {}).get('style_preference', 'casual'),
                    "temperature_sensitivity": "normal",
                    "formality_preference": "casual",
                    "gender": "unisex"
                },
                "preferences": user.get('preferences', {}),
                "location": "Moscow"
            },
            "candidates": candidates[:250]  # ML service limit
        }

        # Call ML ranking API
        response = requests.post(
            f"{ML_SERVICE_URL}/api/rank",
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            return {
                "ranked": result.get('ranked', []),
                "model_version": result.get('model_version', 'unknown'),
                "processing_time_ms": result.get('processing_time_ms', 0)
            }
        else:
            logger.warning(f"ML service returned {response.status_code}: {response.text}")
            return None

    except requests.exceptions.RequestException as e:
        logger.warning(f"Failed to call ML service: {e}")
        return None
    except Exception as e:
        logger.error(f"Error generating recommendations: {e}")
        return None

def save_recommendations(
    conn,
    user_id: str,
    ranked_items: List[Dict[str, Any]],
    model_version: str,
    weather: Dict[str, Any]
) -> int:
    """Save generated recommendations to database"""
    with conn.cursor() as cur:
        # Create recommendation session
        cur.execute("""
            INSERT INTO recommendations (user_id, outfit_score, algorithm_used, ml_powered)
            VALUES (%s, %s, %s, %s)
            RETURNING id
        """, (user_id, 0.75, model_version, True))
        recommendation_id = cur.fetchone()[0]

        # Save ranked items
        items_data = []
        for rank, item in enumerate(ranked_items[:20], 1):  # Top 20
            items_data.append((
                recommendation_id,
                item['id'],
                item['score'],
                rank
            ))

        if items_data:
            execute_batch(cur, """
                INSERT INTO recommendation_items 
                (recommendation_id, clothing_item_id, score, rank)
                VALUES (%s, %s, %s, %s)
            """, items_data)

        conn.commit()
        return len(items_data)

def main():
    logger.info("Starting recommendations regeneration")
    
    conn = get_db_connection()
    try:
        users = fetch_users(conn, limit=BATCH_SIZE)
        logger.info(f"Found {len(users)} users to process")

        if not users:
            logger.info("No users to process")
            return

        items = fetch_catalog_items(conn)
        logger.info(f"Loaded {len(items)} catalog items")

        weather = get_current_weather()
        logger.info(f"Weather: {weather}")

        total_users = 0
        total_recommendations = 0
        failed_users = 0

        for user in users:
            try:
                result = generate_recommendations_for_user(user, items, weather)
                
                if result and result['ranked']:
                    count = save_recommendations(
                        conn,
                        str(user['id']),
                        result['ranked'],
                        result['model_version'],
                        weather
                    )
                    total_recommendations += count
                    total_users += 1
                    logger.info(f"User {user['id']}: {count} items ranked")
                else:
                    failed_users += 1
                    logger.warning(f"User {user['id']}: No recommendations generated")

            except Exception as e:
                failed_users += 1
                logger.error(f"User {user['id']}: Error - {e}")

        logger.info(f"Completed: {total_users} users, {total_recommendations} items, {failed_users} failed")

    finally:
        conn.close()

if __name__ == '__main__':
    main()
PYTHON_SCRIPT

info "Recommendations regeneration completed"
