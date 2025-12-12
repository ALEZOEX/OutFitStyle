import json
import random
import uuid
from datetime import datetime

# Справочник подкатегорий с нормами (для генерации данных)
SUBCATEGORIES_WITH_NORMS = [
    # outerwear (5)
    {"category": "outerwear", "subcategory": "parka", "warmth_min": 8, "temp_min_reco": -25, "temp_max_reco": 5, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "outerwear", "subcategory": "puffer", "warmth_min": 9, "temp_min_reco": -30, "temp_max_reco": 2, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "outerwear", "subcategory": "coat", "warmth_min": 6, "temp_min_reco": -10, "temp_max_reco": 10, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "outerwear", "subcategory": "softshell", "warmth_min": 4, "temp_min_reco": -5, "temp_max_reco": 15, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "outerwear", "subcategory": "raincoat", "warmth_min": 3, "temp_min_reco": -5, "temp_max_reco": 15, "rain_ok": True, "snow_ok": True, "wind_ok": False},
    
    # upper (6)
    {"category": "upper", "subcategory": "tshirt", "warmth_min": 1, "temp_min_reco": 15, "temp_max_reco": 30, "rain_ok": True, "snow_ok": True, "wind_ok": False},
    {"category": "upper", "subcategory": "longsleeve", "warmth_min": 2, "temp_min_reco": 10, "temp_max_reco": 22, "rain_ok": True, "snow_ok": True, "wind_ok": False},
    {"category": "upper", "subcategory": "shirt", "warmth_min": 2, "temp_min_reco": 10, "temp_max_reco": 25, "rain_ok": True, "snow_ok": True, "wind_ok": False},
    {"category": "upper", "subcategory": "hoodie", "warmth_min": 4, "temp_min_reco": 0, "temp_max_reco": 15, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "upper", "subcategory": "sweater", "warmth_min": 5, "temp_min_reco": -5, "temp_max_reco": 12, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "upper", "subcategory": "thermal_top", "warmth_min": 7, "temp_min_reco": -25, "temp_max_reco": 5, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    
    # lower (5)
    {"category": "lower", "subcategory": "shorts", "warmth_min": 1, "temp_min_reco": 18, "temp_max_reco": 35, "rain_ok": True, "snow_ok": True, "wind_ok": False},
    {"category": "lower", "subcategory": "jeans", "warmth_min": 3, "temp_min_reco": 5, "temp_max_reco": 20, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "lower", "subcategory": "pants", "warmth_min": 3, "temp_min_reco": 0, "temp_max_reco": 22, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "lower", "subcategory": "thermal_pants", "warmth_min": 7, "temp_min_reco": -25, "temp_max_reco": 5, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "lower", "subcategory": "skirt", "warmth_min": 2, "temp_min_reco": 10, "temp_max_reco": 25, "rain_ok": True, "snow_ok": True, "wind_ok": False},
    
    # footwear (5)
    {"category": "footwear", "subcategory": "sandals", "warmth_min": 1, "temp_min_reco": 15, "temp_max_reco": 35, "rain_ok": True, "snow_ok": False, "wind_ok": False},
    {"category": "footwear", "subcategory": "sneakers", "warmth_min": 2, "temp_min_reco": 5, "temp_max_reco": 25, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "footwear", "subcategory": "boots", "warmth_min": 5, "temp_min_reco": -5, "temp_max_reco": 15, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "footwear", "subcategory": "winter_boots", "warmth_min": 8, "temp_min_reco": -30, "temp_max_reco": 5, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "footwear", "subcategory": "loafers", "warmth_min": 2, "temp_min_reco": 10, "temp_max_reco": 25, "rain_ok": True, "snow_ok": False, "wind_ok": False},
    
    # accessory (5)
    {"category": "accessory", "subcategory": "hat", "warmth_min": 3, "temp_min_reco": -10, "temp_max_reco": 10, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "accessory", "subcategory": "scarf", "warmth_min": 4, "temp_min_reco": -20, "temp_max_reco": 5, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "accessory", "subcategory": "gloves", "warmth_min": 4, "temp_min_reco": -20, "temp_max_reco": 5, "rain_ok": True, "snow_ok": True, "wind_ok": True},
    {"category": "accessory", "subcategory": "umbrella", "warmth_min": 1, "temp_min_reco": 0, "temp_max_reco": 25, "rain_ok": True, "snow_ok": False, "wind_ok": False},
    {"category": "accessory", "subcategory": "bag", "warmth_min": 1, "temp_min_reco": -35, "temp_max_reco": 35, "rain_ok": True, "snow_ok": True, "wind_ok": True},
]

# Дополнительные справочники
STYLES = ['casual', 'sport', 'street', 'classic', 'business', 'smart_casual', 'outdoor']
USAGES = ['daily', 'work', 'formal', 'sport', 'outdoor', 'travel', 'party']
SEASONS = ['winter', 'spring', 'summer', 'autumn', 'all']
BASE_COLOURS = ['black', 'white', 'gray', 'navy', 'beige', 'brown', 'green', 'blue', 'red', 'pink', 'yellow', 'orange', 'purple']
FITS = ['slim', 'regular', 'relaxed', 'oversized']
PATTERNS = ['solid', 'striped', 'checked', 'printed', 'camo']
MATERIALS = ['cotton', 'wool', 'polyester', 'silk', 'leather', 'denim', 'linen', 'cashmere', 'acrylic', 'nylon', 'spandex']
ICON_EMOJIS = ['👕', '👔', '👖', '👗', '🧥', '👞', '👟', '🧢', '🧤', '🧥', '🥿', '🎒', '🌂', '🧦', '👗', '👘', '🥻', '🩳', '🩱', '👘', '🧥', '🧤', '🧢', '🎒', '🌂']

# Источники
SOURCES = ['synthetic', 'user', 'partner', 'manual']

def generate_clothing_item(item_id):
    # Случайная подкатегория с нормами
    spec = random.choice(SUBCATEGORIES_WITH_NORMS)
    
    # Генерация диапазона температур в пределах норм
    min_temp = random.randint(spec['temp_min_reco'], spec['temp_max_reco'] - 5)
    max_temp = random.randint(min_temp + 5, spec['temp_max_reco'])
    
    # Генерация уровня теплоты и формальности
    warmth_level = random.randint(spec['warmth_min'], 10)
    formality_level = random.randint(1, 5)
    
    # Выбор случайных материалов
    num_materials = random.randint(1, 3)
    materials = random.sample(MATERIALS, num_materials)
    
    # Генерация названия на основе подкатегории
    style_adjectives = ['casual', 'elegant', 'sporty', 'professional', 'comfortable', 'trendy', 'classic']
    name = f"{random.choice(style_adjectives)} {spec['subcategory']}"
    
    return {
        "id": item_id,
        "name": name,
        "category": spec["category"],
        "subcategory": spec["subcategory"],
        "gender": "unisex",
        "style": random.choice(STYLES),
        "usage": random.choice(USAGES),
        "season": random.choice(SEASONS),
        "base_colour": random.choice(BASE_COLOURS),
        "formality_level": formality_level,
        "warmth_level": warmth_level,
        "min_temp": min_temp,
        "max_temp": max_temp,
        "materials": materials,
        "fit": random.choice(FITS),
        "pattern": random.choice(PATTERNS),
        "icon_emoji": random.choice(ICON_EMOJIS),
        "source": random.choice(SOURCES),
        "is_owned": random.choice([True, False]),  # 50% шанс, что вещь принадлежит пользователю
        "created_at": datetime.utcnow().isoformat() + "Z"
    }

def generate_wardrobe_item(user_id, clothing_item_id):
    return {
        "user_id": user_id,
        "clothing_item_id": clothing_item_id,
        "quantity": random.randint(1, 3),
        "created_at": datetime.utcnow().isoformat() + "Z",
        "updated_at": datetime.utcnow().isoformat() + "Z"
    }

# Генерация 10,000 записей для примера
if __name__ == "__main__":
    # Генерация clothing_items
    clothing_items = []
    for i in range(1, 10001):  # 10,000 items
        item = generate_clothing_item(i)
        clothing_items.append(item)
    
    # Сохранение в JSON файл
    with open('clothing_items_v2.json', 'w', encoding='utf-8') as f:
        json.dump(clothing_items, f, ensure_ascii=False, indent=2)
    
    print(f"Generated {len(clothing_items)} clothing items for V2 schema")
    
    # Пример генерации wardrobe_items для первых 1000 вещей
    wardrobe_items = []
    for i in range(1, 1001):  # 1000 wardrobe entries
        # Случайный пользователь (предположим, у нас 100 пользователей)
        user_id = random.randint(1, 100)
        clothing_item_id = random.randint(1, len(clothing_items))
        wardrobe_item = generate_wardrobe_item(user_id, clothing_item_id)
        wardrobe_items.append(wardrobe_item)
    
    # Сохранение в JSON файл
    with open('wardrobe_items_v2.json', 'w', encoding='utf-8') as f:
        json.dump(wardrobe_items, f, ensure_ascii=False, indent=2)
    
    print(f"Generated {len(wardrobe_items)} wardrobe items for V2 schema")