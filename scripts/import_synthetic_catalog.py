#!/usr/bin/env python3
"""Импорт синтетического каталога в PostgreSQL"""

import json
import psycopg2
import sys
import codecs

# Включаем UTF-8 для Windows
if sys.platform == 'win32':
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Параметры подключения
DB_HOST = 'localhost'
DB_PORT = '5433'
DB_NAME = 'outfitstyle'
DB_USER = 'postgres'
DB_PASSWORD = 'postgres'

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
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

def import_catalog(filepath):
    """Импорт каталога из NDJSON"""
    print('Подключение к базе данных...')
    
    conn = connect()
    cur = conn.cursor()
    
    print(f'Чтение файла {filepath}...')
    
    with open(filepath, 'r', encoding='utf-8') as f:
        items = [json.loads(line) for line in f]
    
    print(f'Загружено {len(items)} вещей для импорта...')
    
    inserted = 0
    errors = 0
    
    for item in items:
        color_en = COLOR_MAP.get(item['color'], 'gray')
        season_en = SEASON_MAP.get(item['season'], 'all')
        gender_en = GENDER_MAP.get(item['gender'], 'unisex')
        category_en = CATEGORY_MAP.get(item['category'], 'upper')
        
        # Нормализация warmth_level (1-10)
        warmth = max(1, min(10, item['warmth_level'] // 10))
        
        try:
            cur.execute("""
                INSERT INTO clothing_items (
                    name, description, category, subcategory, gender, style, usage,
                    season, base_colour, warmth_level, min_temp, max_temp,
                    materials, brand, image_url, source, created_at, is_active,
                    rain_ok, snow_ok, wind_ok
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                )
            """, (
                item['name'],
                item['description'],
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
            inserted += 1
            
            if inserted % 500 == 0:
                print(f'Импортировано {inserted} из {len(items)}...')
                
        except Exception as e:
            errors += 1
            if errors <= 5:
                print(f'Ошибка: {item["name"]} - {e}')
    
    conn.commit()
    
    # Проверка количества
    cur.execute("SELECT COUNT(*) FROM clothing_items WHERE source = 'synthetic'")
    count = cur.fetchone()[0]
    
    print(f'\n✅ Импорт завершён!')
    print(f'📊 В базе данных: {count} синтетических вещей')
    if errors > 0:
        print(f'⚠️ Ошибок: {errors}')
    
    cur.close()
    conn.close()

if __name__ == '__main__':
    filepath = 'data/synthetic_catalog.ndjson'
    import_catalog(filepath)
