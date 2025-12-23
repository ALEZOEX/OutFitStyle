import json
import uuid
import random

CATEGORIES = {
    "outerwear": ["coat", "jacket", "raincoat", "puffer", "parka"],
    "upper": ["tshirt", "shirt", "hoodie", "sweater", "blouse", "top"],
    "lower": ["jeans", "pants", "shorts", "skirt", "leggings"],
    "footwear": ["sneakers", "boots", "shoes", "sandals", "heels"],
    "accessory": ["hat", "scarf", "gloves", "bag", "belt"]
}

STYLES = ["casual", "business", "sport", "street", "classic"]
COLORS = ["Black", "White", "Gray", "Navy", "Beige", "Red", "Blue", "Green"]
EMOJIS = {
    "coat": "🧥", "jacket": "🧥", "tshirt": "👕", "hoodie": "🧢", 
    "jeans": "👖", "pants": "👖", "sneakers": "👟", "boots": "🥾",
    "hat": "🧢", "bag": "👜"
}

items = []
count = 0

for cat, subs in CATEGORIES.items():
    for sub in subs:
        for style in STYLES:
            # Генерируем по 2-3 цвета для каждой комбинации
            for _ in range(2):
                color = random.choice(COLORS)
                name = f"{color} {style.capitalize()} {sub.capitalize()}"
                
                item = {
                    "name": name,
                    "category": cat,
                    "subcategory": sub,
                    "gender": "unisex",
                    "style": style,
                    "formality_level": 2 if style == "casual" else 4,
                    "warmth_level": 5 if cat == "outerwear" else 2,
                    "min_temp": -10 if cat == "outerwear" else 10,
                    "max_temp": 15 if cat == "outerwear" else 30,
                    "season": "all",
                    "base_colour": color,
                    "usage": "daily",
                    "materials": ["cotton" if cat == "upper" else "synthetic"],
                    "fit": "regular",
                    "pattern": "solid",
                    "icon_emoji": EMOJIS.get(sub, "👕"),
                    "source": "synthetic",
                    "is_owned": False
                }
                items.append(item)
                count += 1

with open("basic_catalog.ndjson", "w", encoding="utf-8") as f:
    for item in items:
        f.write(json.dumps(item, ensure_ascii=False) + "\n")

print(f"Generated {count} items into basic_catalog.ndjson")