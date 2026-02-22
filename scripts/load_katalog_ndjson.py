#!/usr/bin/env python3
"""
Загрузка каталога из synthetic_catalog.ndjson в PostgreSQL
"""
import json
import psycopg2
from psycopg2.extras import execute_batch

# Подключение к БД
conn = psycopg2.connect(
    host="localhost",
    port=5433,
    database="outfitstyle",
    user="postgres",
    password=""
)
conn.autocommit = False

# Маппинг категорий
CATEGORY_MAP = {
    'верх': 'upper',
    'низ': 'lower',
    'обувь': 'footwear',
    'аксессуары': 'accessory',
}

SUBCATEGORY_MAP = {
    'футболка': 'tshirt',
    'рубашка': 'shirt',
    'блузка': 'blouse',
    'свитер': 'sweater',
    'худи': 'hoodie',
    'джемпер': 'sweater',
    'пиджак': 'blazer',
    'кардиган': 'cardigan',
    'джинсы': 'jeans',
    'брюки': 'trousers',
    'штаны': 'trousers',
    'шорты': 'shorts',
    'юбка': 'skirt',
    'леггинсы': 'leggings',
    'чинос': 'trousers',
    'джоггеры': 'joggers',
    'кроссовки': 'sneakers',
    'ботинки': 'boots',
    'туфли': 'loafers',
    'сандалии': 'sandals',
    'сапоги': 'boots',
    'кеды': 'sneakers',
    'лоферы': 'loafers',
    'носки': 'socks',
    'шапка': 'hat',
    'шарф': 'scarf',
    'перчатки': 'gloves',
    'ремень': 'belt',
    'солнцезащитные очки': 'sunglasses',
    'сумка': 'bag',
    'колготки': 'tights',
    'пальто': 'coat',
    'куртка': 'jacket',
    'плащ': 'coat',
    'пуховик': 'parka',
    'жилет': 'vest',
    'пончо': 'poncho',
}

STYLE_MAP = {
    'casual': 'casual',
    'повседневный': 'casual',
    'sport': 'sport',
    'спортивный': 'sport',
    'street': 'street',
    'уличный': 'street',
    'classic': 'classic',
    'классический': 'classic',
    'business': 'business',
    'деловой': 'business',
    'smart_casual': 'smart_casual',
    'outdoor': 'outdoor',
}

USAGE_MAP = {
    'casual': 'daily',
    'повседневный': 'daily',
    'daily': 'daily',
    'work': 'work',
    'работа': 'work',
    'formal': 'formal',
    'торжественный': 'formal',
    'sport': 'sport',
    'спорт': 'sport',
    'outdoor': 'outdoor',
    'активный': 'outdoor',
    'travel': 'travel',
    'путешествия': 'travel',
    'party': 'party',
    'вечеринка': 'party',
}

SEASON_MAP = {
    'зима': 'winter',
    'весна': 'spring',
    'лето': 'summer',
    'осень': 'autumn',
    'всесезон': 'all',
}

COLOUR_MAP = {
    'черный': 'black',
    'белый': 'white',
    'серый': 'gray',
    'светло-серый': 'gray',
    'темно-серый': 'gray',
    'синий': 'blue',
    'темно-синий': 'navy',
    'голубой': 'blue',
    'бирюзовый': 'blue',
    'зеленый': 'green',
    'оливковый': 'green',
    'коричневый': 'brown',
    'бежевый': 'beige',
    'красный': 'red',
    'бордовый': 'red',
    'розовый': 'pink',
    'желтый': 'yellow',
    'оранжевый': 'orange',
    'фиолетовый': 'purple',
}

def transform_item(item):
    """Трансформация предмета из NDJSON в формат БД"""
    category_raw = item.get('category', 'верх')
    category = CATEGORY_MAP.get(category_raw, 'upper')

    subcategory_raw = item.get('subcategory', 'basic')
    subcategory = SUBCATEGORY_MAP.get(subcategory_raw, 'basic')

    # Если subcategory не найден, используем 'basic' для всех категорий
    if subcategory == 'basic':
        if category == 'upper':
            subcategory = 'tshirt'
        elif category == 'lower':
            subcategory = 'trousers'
        elif category == 'footwear':
            subcategory = 'sneakers'
        elif category == 'accessory':
            subcategory = 'bag'
        else:
            subcategory = 'basic'
    
    # Определяем gender
    gender_raw = item.get('gender', 'unisex')
    if gender_raw == 'male':
        gender = 'men'
    elif gender_raw == 'female':
        gender = 'women'
    else:
        gender = 'unisex'
    
    # Определяем стиль
    usage_raw = item.get('usage', ['casual'])[0] if isinstance(item.get('usage'), list) else item.get('usage', 'casual')
    style = STYLE_MAP.get(usage_raw, 'casual')
    usage = USAGE_MAP.get(usage_raw, 'daily')
    
    # Сезон
    season = SEASON_MAP.get(item.get('season', 'всесезон'), 'all')
    
    # Цвет
    color = item.get('color', 'black')
    base_colour = COLOUR_MAP.get(color, 'black')
    
    # Материалы
    materials = item.get('materials', [])
    
    # Температуры
    min_temp = item.get('min_temp', 10)
    max_temp = item.get('max_temp', 25)
    
    # Warmth level (0-100 -> 1-10)
    warmth_level = max(1, min(10, item.get('warmth_level', 5) // 10))
    
    # Formality level (1-5)
    formality_level = max(1, min(5, item.get('popularity', 5) // 20 + 1))
    
    return {
        'name': item.get('name', 'Без названия'),
        'description': item.get('description', ''),
        'category': category,
        'subcategory': subcategory,
        'gender': gender,
        'style': style,
        'usage': usage,
        'season': season,
        'base_colour': base_colour,
        'warmth_level': warmth_level,
        'formality_level': formality_level,
        'min_temp': min_temp,
        'max_temp': max_temp,
        'materials': materials,
        'brand': item.get('brand', ''),
        'image_url': item.get('image_url', ''),
        'source': 'synthetic',
        'is_owned': False,
        'is_active': item.get('is_active', True),
    }

def main():
    print("Загрузка каталога из synthetic_catalog.ndjson...")
    
    # Сначала заполним subcategory_specs
    subcategory_specs = [
        ('upper', 'tshirt', 1, 15, 30, False, False, False),
        ('upper', 'shirt', 2, 10, 25, False, False, False),
        ('upper', 'blouse', 2, 10, 25, False, False, False),
        ('upper', 'sweater', 5, 5, 15, False, False, True),
        ('upper', 'hoodie', 4, 10, 20, False, False, True),
        ('upper', 'blazer', 3, 10, 20, False, False, False),
        ('upper', 'cardigan', 4, 5, 18, False, False, True),
        ('upper', 'jacket', 3, 5, 20, False, False, True),
        ('upper', 'coat', 5, 0, 15, True, True, True),
        ('upper', 'parka', 7, -10, 5, True, True, True),
        ('upper', 'vest', 2, 10, 20, False, False, True),
        ('upper', 'poncho', 3, 5, 18, True, False, True),
        ('upper', 'basic', 2, 10, 25, False, False, False),
        ('lower', 'jeans', 4, 5, 25, False, False, True),
        ('lower', 'trousers', 3, 10, 25, False, False, True),
        ('lower', 'pants', 3, 10, 25, False, False, True),
        ('lower', 'shorts', 1, 20, 35, False, False, False),
        ('lower', 'skirt', 2, 15, 28, False, False, False),
        ('lower', 'leggings', 3, 5, 20, False, False, True),
        ('lower', 'joggers', 3, 10, 22, False, False, True),
        ('lower', 'basic', 3, 10, 25, False, False, True),
        ('footwear', 'sneakers', 2, 10, 25, True, False, True),
        ('footwear', 'boots', 6, -5, 15, True, True, True),
        ('footwear', 'sandals', 1, 20, 35, False, False, False),
        ('footwear', 'loafers', 2, 10, 25, False, False, False),
        ('footwear', 'heels', 1, 15, 28, False, False, False),
        ('footwear', 'shoes', 2, 10, 25, False, False, True),
        ('footwear', 'basic', 2, 10, 25, False, False, True),
        ('accessory', 'scarf', 4, -5, 15, False, False, True),
        ('accessory', 'hat', 3, -10, 15, False, False, True),
        ('accessory', 'gloves', 5, -15, 10, False, True, True),
        ('accessory', 'belt', 1, 5, 30, False, False, False),
        ('accessory', 'sunglasses', 1, 15, 35, False, False, False),
        ('accessory', 'socks', 2, 5, 25, False, False, False),
        ('accessory', 'bag', 1, 5, 30, False, False, False),
        ('accessory', 'tights', 3, 5, 20, False, False, True),
        ('accessory', 'colgotki', 3, 5, 20, False, False, True),
        ('accessory', 'basic', 1, 5, 30, False, False, False),
        ('outerwear', 'jacket', 3, 5, 20, True, False, True),
        ('outerwear', 'coat', 5, 0, 15, True, True, True),
        ('outerwear', 'parka', 7, -10, 5, True, True, True),
        ('outerwear', 'vest', 2, 10, 20, False, False, True),
        ('outerwear', 'poncho', 3, 5, 18, True, False, True),
        ('outerwear', 'basic', 3, 5, 20, True, False, True),
    ]
    
    with conn.cursor() as cur:
        # Заполняем subcategory_specs
        cur.executemany("""
            INSERT INTO subcategory_specs (category, subcategory, warmth_min, temp_min_reco, temp_max_reco, rain_ok, snow_ok, wind_ok)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT (category, subcategory) DO NOTHING
        """, subcategory_specs)
        print(f"Заполнено subcategory_specs: {len(subcategory_specs)} записей")
        
        # Очищаем старые synthetic данные
        cur.execute("DELETE FROM wardrobe_items WHERE clothing_item_id IN (SELECT id FROM clothing_items WHERE source = 'synthetic')")
        cur.execute("DELETE FROM clothing_items WHERE source = 'synthetic'")
        print("Очищены старые synthetic данные")
    
    # Читаем и загружаем каталог
    items = []
    with open('data/synthetic_catalog.ndjson', 'r', encoding='utf-8') as f:
        for line in f:
            item = json.loads(line.strip())
            items.append(transform_item(item))
    
    print(f"Загружено {len(items)} предметов из NDJSON")
    
    # Вставляем в БД
    with conn.cursor() as cur:
        execute_batch(cur, """
            INSERT INTO clothing_items (
                name, description, category, subcategory, gender, style, usage, season,
                base_colour, warmth_level, formality_level, min_temp, max_temp,
                materials, brand, image_url, source, is_owned, is_active, created_at
            ) VALUES (
                %(name)s, %(description)s, %(category)s, %(subcategory)s, %(gender)s,
                %(style)s, %(usage)s, %(season)s, %(base_colour)s, %(warmth_level)s,
                %(formality_level)s, %(min_temp)s, %(max_temp)s, %(materials)s,
                %(brand)s, %(image_url)s, %(source)s, %(is_owned)s, %(is_active)s, NOW()
            )
        """, items, page_size=100)
    
    conn.commit()
    conn.close()

    print(f"[OK] Загружено {len(items)} предметов в каталог")

if __name__ == '__main__':
    main()
