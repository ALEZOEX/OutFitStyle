#!/usr/bin/env python3
"""
Импорт синтетического каталога в PostgreSQL.

Поддерживает идемпотентность через external_id.
При повторном запуске обновляет существующие записи.

Usage:
    python scripts/import_synthetic_catalog.py [--file PATH] [--dsn URL]

Переменные окружения:
    DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
    или DB_DSN (полный connection string)
"""

import json
import psycopg2
import sys
import codecs
import os
import argparse
from typing import Optional, List, Dict, Any

# Включаем UTF-8 для Windows
if sys.platform == 'win32':
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Параметры подключения (через env или дефолты)
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5433')
DB_NAME = os.getenv('DB_NAME', 'outfitstyle')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'postgres')
DB_DSN = os.getenv('DB_DSN')  # опционально полный DSN

# Маппинг цветов
COLOR_MAP = {
    'черный': 'black', 'белый': 'white', 'серый': 'gray', 'синий': 'navy',
    'красный': 'red', 'зеленый': 'green', 'желтый': 'yellow', 'оранжевый': 'orange',
    'фиолетовый': 'purple', 'розовый': 'pink', 'коричневый': 'brown', 'бежевый': 'beige',
    'голубой': 'blue', 'бирюзовый': 'blue', 'бордовый': 'red', 'оливковый': 'green',
    'хаки': 'green', 'темно-синий': 'navy', 'светло-серый': 'gray'
}

# Маппинг сезонов
SEASON_MAP = {
    'зима': 'winter', 'весна': 'spring', 'лето': 'summer', 'осень': 'autumn', 'всесезон': 'all'
}

# Маппинг полов
GENDER_MAP = {
    'male': 'men', 'female': 'women', 'unisex': 'unisex'
}

# Маппинг категорий (русский -> английский)
CATEGORY_MAP = {
    'верх': 'upper',
    'низ': 'lower',
    'обувь': 'footwear',
    'аксессуары': 'accessory'
}

def connect():
    """Подключение к БД"""
    if DB_DSN:
        return psycopg2.connect(DB_DSN)
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )


def to_external_id(item_id: int, source: str) -> int:
    """
    Генерирует external_id для идемпотентности.
    synthetic -> отрицательный, остальные -> положительный
    """
    abs_id = abs(item_id)
    if source == 'synthetic' or item_id < 0:
        return -abs_id
    return abs_id


def import_catalog(filepath: str, batch_size: int = 300):
    """Импорт каталога из NDJSON с поддержкой upsert через external_id"""
    print('Подключение к базе данных...')

    conn = connect()
    cur = conn.cursor()

    print(f'Чтение файла {filepath}...')

    with open(filepath, 'r', encoding='utf-8') as f:
        items = [json.loads(line) for line in f]

    print(f'Загружено {len(items)} вещей для импорта...')

    inserted = 0
    updated = 0
    errors = 0
    batch: List[Dict[str, Any]] = []

    def flush_batch():
        nonlocal inserted, updated, errors, batch
        if not batch:
            return

        try:
            for item in batch:
                color_en = COLOR_MAP.get(item['color'], 'gray')
                season_en = SEASON_MAP.get(item['season'], 'all')
                gender_en = 'unisex'  # В БД пока только unisex
                category_en = CATEGORY_MAP.get(item['category'], 'upper')

                # Нормализация warmth_level (1-10)
                warmth = max(1, min(10, item['warmth_level'] // 10))

                # external_id для идемпотентности
                external_id = to_external_id(item.get('id', 0), item.get('source', 'synthetic'))

                # Сначала确保 subcategory_specs существует
                cur.execute("""
                    INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok)
                    VALUES (%s, %s, %s, %s, %s, true, true, true)
                    ON CONFLICT (category, subcategory) DO NOTHING
                """, (category_en, item['subcategory'], warmth, item['min_temp'], item['max_temp']))

                # Upsert clothing_items через external_id
                cur.execute("""
                    INSERT INTO clothing_items (
                        external_id, name, description, category, subcategory, gender, style, usage,
                        season, base_colour, warmth_level, min_temp, max_temp,
                        materials, brand, image_url, source, created_at, is_active,
                        rain_ok, snow_ok, wind_ok
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    ON CONFLICT (external_id) DO UPDATE SET
                        name = EXCLUDED.name,
                        description = EXCLUDED.description,
                        category = EXCLUDED.category,
                        subcategory = EXCLUDED.subcategory,
                        season = EXCLUDED.season,
                        base_colour = EXCLUDED.base_colour,
                        warmth_level = EXCLUDED.warmth_level,
                        min_temp = EXCLUDED.min_temp,
                        max_temp = EXCLUDED.max_temp,
                        materials = EXCLUDED.materials,
                        brand = EXCLUDED.brand,
                        image_url = EXCLUDED.image_url,
                        is_active = EXCLUDED.is_active
                """, (
                    external_id,
                    item['name'],
                    item.get('description', ''),
                    category_en,
                    item['subcategory'],
                    gender_en,
                    'casual',
                    'daily',
                    season_en,
                    color_en,
                    warmth,
                    item['min_temp'],
                    item['max_temp'],
                    item['materials'],
                    item['brand'],
                    item['image_url'],
                    'synthetic',
                    item['created_at'],
                    item['is_active'],
                    True,
                    True,
                    True,
                ))

                # Проверяем, был ли INSERT или UPDATE
                if cur.rowcount == 1:
                    inserted += 1
                else:
                    updated += 1

        except Exception as e:
            errors += 1
            if errors <= 5:
                print(f'Ошибка: {e}')
            conn.rollback()
            return False

        conn.commit()
        batch = []
        return True

    for item in items:
        batch.append(item)

        if len(batch) >= batch_size:
            if not flush_batch():
                continue
            print(f'Обработано {inserted + updated} из {len(items)}...')

    # Финальный flush
    flush_batch()

    # Проверка количества
    cur.execute("SELECT COUNT(*) FROM clothing_items WHERE source = 'synthetic'")
    count = cur.fetchone()[0]

    print(f'\n✅ Импорт завершён!')
    print(f'📊 В базе данных: {count} синтетических вещей')
    print(f'📥 Добавлено: {inserted}, Обновлено: {updated}')
    if errors > 0:
        print(f'⚠️ Ошибок: {errors}')

    cur.close()
    conn.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Импорт синтетического каталога в PostgreSQL')
    parser.add_argument('--file', '-f', default='data/synthetic_catalog.ndjson',
                        help='Путь к NDJSON файлу (по умолчанию: data/synthetic_catalog.ndjson)')
    parser.add_argument('--batch', '-b', type=int, default=300,
                        help='Размер батча для commit (по умолчанию: 300)')
    args = parser.parse_args()

    filepath = args.file
    if not os.path.exists(filepath):
        print(f'❌ Файл не найден: {filepath}')
        sys.exit(1)

    import_catalog(filepath, batch_size=args.batch)
