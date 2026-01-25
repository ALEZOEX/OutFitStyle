import os
import logging
from typing import Tuple

import pandas as pd
import psycopg2
from psycopg2.extras import execute_batch

# ---------------------------------------
# Логирование
# ---------------------------------------
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("seed-catalog")

# ---------------------------------------
# Настройки БД (те же, что в main.py)
# ---------------------------------------
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "postgres"),
    "port": os.getenv("DB_PORT", "5432"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD"),
    "database": os.getenv("DB_NAME", "outfitstyle"),
}

# Путь к датасету (в контейнере: /app/data/raw/styles.csv)
STYLES_CSV_PATH = os.getenv("STYLES_CSV_PATH", "data/raw/styles.csv")


# ---------------------------------------
# Маппинг категорий и температур
# ---------------------------------------
def map_category(master: str, sub: str, article: str) -> str:
    m = (master or "").lower()
    s = (sub or "").lower()
    a = (article or "").lower()

    # subCategory на Kaggle: Topwear / Bottomwear / Watches / Bags / Flip Flops / ...
    if s == "topwear":
        return "upper"
    if s == "bottomwear":
        return "lower"

    # Footwear
    if m == "footwear" or s in ("flip flops", "sandal", "sandals") or "shoe" in a:
        return "footwear"

    # Outerwear (если появится)
    if any(x in a for x in ("jacket", "coat", "blazer", "parka")):
        return "outerwear"

    # Остальное считаем верхом
    return "upper"


def estimate_temp_and_warmth(category: str, article: str) -> Tuple[float, float, float]:
    """
    Очень грубые эвристики по температуре и "теплоте" вещи.
    """
    c = (category or "").lower()
    a = (article or "").lower()

    # Верхняя одежда — холодная погода
    if c == "outerwear":
        return -20.0, 10.0, 9.0

    # Обувь
    if c == "footwear":
        if "boot" in a:
            return -15.0, 5.0, 8.0
        return 0.0, 25.0, 5.0

    # Верх
    if c == "upper":
        if any(x in a for x in ("sweatshirt", "hoodie", "knit", "sweater")):
            return -5.0, 15.0, 7.0
        if any(x in a for x in ("shirt", "blouse", "top")):
            return 5.0, 25.0, 4.0
        if "t-shirt" in a or "tee" in a:
            return 10.0, 30.0, 3.0

    # Низ
    if c == "lower":
        if "short" in a:
            return 15.0, 35.0, 2.0
        return -5.0, 25.0, 5.0

    # Дефолт
    return 0.0, 25.0, 5.0


def map_icon(category: str) -> str:
    c = (category or "").lower()
    if c == "upper":
        return "👕"
    if c == "lower":
        return "👖"
    if c == "footwear":
        return "👟"
    if c == "outerwear":
        return "🧥"
    return "🧩"


# ---------------------------------------
# Основная логика
# ---------------------------------------
def seed_catalog():
    logger.info(f"Loading styles dataset from {STYLES_CSV_PATH!r}")

    if not os.path.exists(STYLES_CSV_PATH):
        logger.error(f"Styles CSV not found at {STYLES_CSV_PATH}")
        return

    df = pd.read_csv(
        STYLES_CSV_PATH,
        on_bad_lines="skip",
        engine="python",
    )

    # Ожидаемые колонки датасета Kaggle Fashion: id, gender, masterCategory, subCategory,
    # articleType, baseColour, season, year, usage, productDisplayName
    required_cols = ["masterCategory", "subCategory", "articleType", "productDisplayName"]
    for col in required_cols:
        if col not in df.columns:
            logger.error(f"Column {col!r} not found in {STYLES_CSV_PATH}")
            return

    # Ограничимся, например, 500 записями для начала
    df = df.head(500)

    items_to_insert = []
    for _, row in df.iterrows():
        name = str(row.get("productDisplayName") or "").strip()
        if not name:
            continue

        master = str(row.get("masterCategory") or "").strip()
        sub = str(row.get("subCategory") or "").strip()
        article = str(row.get("articleType") or "").strip()

        category = map_category(master, sub, article)
        min_temp, max_temp, warmth = estimate_temp_and_warmth(category, article)
        icon = map_icon(category)

        item = (
            None,           # user_id (NULL -> каталог, не личный гардероб)
            name,
            category,
            sub,
            icon,
            None,           # ml_score
            None,           # confidence
            None,           # weather_suitability
            float(min_temp),
            float(max_temp),
            None,           # weather_conditions
            "casual",       # style
            float(warmth),  # warmth_level
            "casual",       # formality_level
        )
        items_to_insert.append(item)

    logger.info(f"Prepared {len(items_to_insert)} catalog items for insertion")

    if not items_to_insert:
        logger.warning("No items to insert, exiting")
        return

    insert_sql = """
        INSERT INTO clothing_items (
            user_id, name, category, subcategory, icon_emoji,
            ml_score, confidence, weather_suitability,
            min_temp, max_temp, weather_conditions,
            style, warmth_level, formality_level
        )
        VALUES (
            %s, %s, %s, %s, %s,
            %s, %s, %s,
            %s, %s, %s,
            %s, %s, %s
        )
    """

    conn = None
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        with conn:
            with conn.cursor() as cur:
                execute_batch(cur, insert_sql, items_to_insert, page_size=100)
        logger.info("Catalog seeding completed successfully")
    except Exception as e:
        logger.error(f"Error while inserting catalog items: {e}", exc_info=True)
        if conn:
            conn.rollback()
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    logger.info("Starting catalog seeding from styles.csv")
    seed_catalog()