import os
import logging
import psycopg2
import psycopg2.extras
import pandas as pd

# Берём функции маппинга из твоего train_styles_only.py
from train_styles_only import map_category_to_warmth, map_formality

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': os.getenv('DB_PORT', '5432'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD'),
    'dbname': os.getenv('DB_NAME', 'outfitstyle'),
}

def get_db_connection():
    conn = psycopg2.connect(**DB_CONFIG)
    return conn

def main():
    styles_path = 'data/styles.csv'
    if not os.path.exists(styles_path):
        logger.error(f"styles.csv not found at {styles_path}")
        return

    logger.info(f"Loading styles from {styles_path} ...")
    df = pd.read_csv(styles_path, on_bad_lines='skip')
    logger.info(f"Loaded {len(df)} rows from styles.csv")

    # Чтобы не забить БД, возьмем, например, первые 5000 строк (потом можно увеличить)
    df = df.head(5000)

    conn = get_db_connection()
    cur = conn.cursor()

    inserted = 0
    for idx, row in df.iterrows():
        gender = str(row.get('gender', 'Unisex'))
        master_category = str(row.get('masterCategory', 'unknown'))
        sub_category = str(row.get('subCategory', 'unknown'))
        article_type = str(row.get('articleType', 'unknown'))
        base_colour = str(row.get('baseColour', 'unknown'))
        season = str(row.get('season', 'unknown'))
        usage = str(row.get('usage', 'unknown'))
        product_display_name = str(row.get('productDisplayName', f'Item_{idx}'))

        # Расчёт «теплоты» и формальности — те же, что в train_styles_only
        warmth_level = map_category_to_warmth(article_type)
        formality_level = map_formality(article_type, usage)

        # Примерный диапазон температур (как в train_styles_only)
        min_temp_for_item = 15 - warmth_level * 2
        max_temp_for_item = 30 - warmth_level

        # Стиль для БД — usage в нижнем регистре
        style = (usage or 'Casual').lower()

        # Простая иконка по категории
        if master_category == 'Footwear':
            icon = '👟'
        elif master_category == 'Accessories':
            icon = '🧢'
        elif article_type in ['Jackets', 'Coats', 'Blazers', 'Rain Jacket']:
            icon = '🧥'
        elif article_type in ['Sweatshirts', 'Sweaters']:
            icon = '🧶'
        elif article_type in ['Jeans', 'Trousers', 'Track Pants', 'Shorts', 'Skirts']:
            icon = '👖'
        elif article_type in ['Dresses', 'Kurta Sets', 'Kurtas', 'Sarees']:
            icon = '👗'
        else:
            icon = '👕'

        # ВНИМАНИЕ: здесь я не трогаю weather_conditions — пусть будет NULL
        # Список полей должен совпадать с колонками таблицы clothing_items
        sql = """
            INSERT INTO clothing_items (
                name,
                category,
                subcategory,
                min_temp,
                max_temp,
                style,
                warmth_level,
                formality_level,
                icon_emoji
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """

        values = (
            product_display_name,
            master_category,   # category
            sub_category,      # subcategory
            min_temp_for_item,
            max_temp_for_item,
            style,
            warmth_level,
            formality_level,
            icon,
        )

        cur.execute(sql, values)
        inserted += 1

        if inserted % 500 == 0:
            conn.commit()
            logger.info(f"Inserted {inserted} items...")

    conn.commit()
    cur.close()
    conn.close()
    logger.info(f"✅ Done. Inserted total {inserted} rows into clothing_items")

if __name__ == '__main__':
    main()