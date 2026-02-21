#!/usr/bin/env python3
"""Генерация синтетического каталога одежды (3000 вещей)"""

import json
import random
import sys
from datetime import datetime

# Включаем UTF-8 для Windows
if sys.platform == 'win32':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

# Категории
CATEGORIES = {
    'верх': ['футболка', 'рубашка', 'свитер', 'худи', 'куртка', 'пальто', 'жилет', 'толстовка', 'кардиган', 'джемпер'],
    'низ': ['джинсы', 'брюки', 'шорты', 'юбка', 'легинсы', 'штаны', 'чинос'],
    'обувь': ['кроссовки', 'ботинки', 'туфли', 'сандалии', 'кеды', 'сапоги', 'лоферы'],
    'аксессуары': ['шапка', 'шарф', 'перчатки', 'ремень', 'сумка', 'носки', 'колготки']
}

# Цвета
COLORS = [
    'черный', 'белый', 'серый', 'синий', 'красный', 'зеленый', 'желтый', 
    'оранжевый', 'фиолетовый', 'розовый', 'коричневый', 'бежевый', 'голубой',
    'бирюзовый', 'бордовый', 'оливковый', 'хаки', 'темно-синий', 'светло-серый'
]

# Материалы
MATERIALS = [
    'хлопок', 'шерсть', 'синтетика', 'лен', 'шелк', 'вискоза', 'полиэстер',
    'кашемир', 'джинс', 'кожа', 'замша', 'нейлон', 'акрил'
]

# Сезоны
SEASONS = ['лето', 'зима', 'весна', 'осень', 'всесезон']

# Температурные режимы
TEMP_RANGES = {
    'лето': (20, 35),
    'весна': (10, 20),
    'осень': (5, 15),
    'зима': (-20, 5),
    'всесезон': (10, 25)
}

# Бренды
BRANDS = [
    'Zara', 'H&M', 'Uniqlo', 'Nike', 'Adidas', 'GAP', 'Massimo Dutti',
    'Mango', 'COS', 'Arket', 'Levis', 'Tommy Hilfiger', 'Calvin Klein',
    'Ralph Lauren', 'Lacoste', 'The North Face', 'Columbia', 'Patagonia'
]

# Названия для вещей
ITEM_NAMES = {
    'футболка': ['Футболка базовая', 'Футболка с принтом', 'Футболка оверсайз', 'Футболка классическая'],
    'рубашка': ['Рубашка классическая', 'Рубашка casual', 'Рубашка льняная', 'Рубашка фланелевая'],
    'свитер': ['Свитер шерстяной', 'Свитер кашемировый', 'Свитер с узором', 'Свитер минималистичный'],
    'худи': ['Худи базовое', 'Худи с капюшоном', 'Худи оверсайз', 'Худи спортивное'],
    'куртка': ['Куртка демисезонная', 'Куртка зимняя', 'Куртка легкая', 'Куртка стеганая'],
    'пальто': ['Пальто классическое', 'Пальто шерстяное', 'Пальто кашемировое', 'Пальто бушлат'],
    'джинсы': ['Джинсы прямые', 'Джинсы скинни', 'Джинсы бойфренд', 'Джинсы классические'],
    'брюки': ['Брюки классические', 'Брюки чинос', 'Брюки зауженные', 'Брюки широкие'],
    'шорты': ['Шорты джинсовые', 'Шорты хлопковые', 'Шорты спортивные', 'Шорты бермуды'],
    'кроссовки': ['Кроссовки беговые', 'Кроссовки повседневные', 'Кроссовки белые', 'Кроссовки ретро'],
    'ботинки': ['Ботинки кожаные', 'Ботинки замшевые', 'Ботинки на шнуровке', 'Ботинки челси'],
    'туфли': ['Туфли оксфорды', 'Туфли лоферы', 'Туфли дерби', 'Туфли монки'],
    'шапка': ['Шапка бини', 'Шапка шерстяная', 'Шапка спортивная', 'Шапка классическая'],
    'шарф': ['Шарф шерстяной', 'Шарф кашемировый', 'Шарф легкий', 'Шарф снуд'],
}

def generate_item(item_id):
    """Генерация одной вещи"""
    category = random.choice(list(CATEGORIES.keys()))
    item_type = random.choice(CATEGORIES[category])
    color = random.choice(COLORS)
    material = random.choice(MATERIALS)
    season = random.choice(SEASONS)
    brand = random.choice(BRANDS)
    
    temp_min, temp_max = TEMP_RANGES[season]
    
    # Название
    name_templates = ITEM_NAMES.get(item_type, [f'{item_type.title()}'])
    name = f'{random.choice(name_templates)} {color}'
    
    # Описание
    description = f'{name} от {brand}. Материал: {material}. Сезон: {season}.'
    
    # URL изображения (плейсхолдер)
    image_url = f'https://via.placeholder.com/400x400/{random.randint(0, 0xFFFFFF):06x}/ffffff?text={item_type}'
    
    # Размеры
    sizes = random.sample(['XS', 'S', 'M', 'L', 'XL', 'XXL'], random.randint(2, 5))
    
    # Рейтинг популярности (для синтетических вещей)
    popularity = random.randint(1, 100)
    
    # Теплота (0-100)
    warmth_level = random.randint(20, 90)
    
    item = {
        'id': item_id,
        'name': name,
        'description': description,
        'category': category,
        'subcategory': item_type,
        'color': color,
        'materials': [material],
        'season': season,
        'brand': brand,
        'sizes': sizes,
        'min_temp': temp_min,
        'max_temp': temp_max,
        'warmth_level': warmth_level,
        'popularity': popularity,
        'image_url': image_url,
        'source': 'synthetic',
        'created_at': datetime.utcnow().isoformat() + 'Z',
        'tags': [category, item_type, color, season],
        'usage': ['casual'],
        'is_active': True,
        'gender': random.choice(['unisex', 'male', 'female']),
    }
    
    return item

def main():
    """Генерация каталога"""
    print('Генерация синтетического каталога (3000 вещей)...')
    
    # ID от -90000001 до -90003000
    start_id = -90000001
    items = []
    
    for i in range(3000):
        item_id = start_id - i
        item = generate_item(item_id)
        items.append(item)
        
        if (i + 1) % 500 == 0:
            print(f'Сгенерировано {i + 1} вещей...')
    
    # Сохранение в NDJSON
    output_file = 'data/synthetic_catalog.ndjson'
    with open(output_file, 'w', encoding='utf-8') as f:
        for item in items:
            f.write(json.dumps(item, ensure_ascii=False) + '\n')
    
    print(f'✅ Готово! Сгенерировано {len(items)} вещей')
    print(f'📁 Файл сохранён: {output_file}')
    print(f'🔢 Диапазон ID: {start_id} до {start_id - 2999}')

if __name__ == '__main__':
    main()
