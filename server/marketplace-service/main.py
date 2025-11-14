from flask import Flask, jsonify, request
from flask_cors import CORS
import os
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# ============================================
# 📊 КАТЕГОРИИ С WILDBERRIES И OZON
# ============================================

MARKETPLACES = {
    "wildberries": {
        "name": "Wildberries",
        "icon": "🟣",
        "affiliate_id": os.getenv("WB_AFFILIATE_ID", "YOUR_WB_ID"),
        "commission": "5-15%",
    },
    "ozon": {
        "name": "Ozon",
        "icon": "🔵",
        "affiliate_id": os.getenv("OZON_AFFILIATE_ID", "YOUR_OZON_ID"),
        "commission": "3-10%",
    }
}

CATEGORIES = {
    # ВЕРХНЯЯ ОДЕЖДА
    "outerwear": {
        "name": "🧥 Верхняя одежда",
        "subcategories": {
            "puffer_jacket": {
                "name": "🧥 Пуховик",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verkhnyaya-odezhda/puhoviki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-puhoviki-7563/",
                "keywords": ["пуховик", "зимняя куртка", "парка"]
            },
            "winter_jacket": {
                "name": "❄️ Зимняя куртка",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verkhnyaya-odezhda/kurtki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-kurtki-7558/",
                "keywords": ["зимняя куртка", "теплая куртка"]
            },
            "bomber": {
                "name": "✈️ Бомбер",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verkhnyaya-odezhda/bombery",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-bombery-31164/",
                "keywords": ["бомбер", "куртка-бомбер"]
            },
            "raincoat": {
                "name": "☔ Дождевик",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verkhnyaya-odezhda/dozhdeviki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-plashchi-31165/",
                "keywords": ["дождевик", "плащ"]
            }
        }
    },
    
    # ВЕРХ
    "upper": {
        "name": "👕 Верх",
        "subcategories": {
            "sweater": {
                "name": "🧶 Свитер",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verh/svitery",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-svitera-7552/",
                "keywords": ["свитер", "джемпер", "пуловер"]
            },
            "hoodie": {
                "name": "👘 Толстовка",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verh/tolstovki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-tolstovki-7553/",
                "keywords": ["толстовка", "худи", "свитшот"]
            },
            "tshirt": {
                "name": "👕 Футболка",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verh/futbolki-i-mayki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-futbolki-7540/",
                "keywords": ["футболка", "майка"]
            },
            "shirt": {
                "name": "👔 Рубашка",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/verh/rubashki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-rubashki-7541/",
                "keywords": ["рубашка"]
            }
        }
    },
    
    # НИЗ
    "lower": {
        "name": "👖 Низ",
        "subcategories": {
            "jeans": {
                "name": "👖 Джинсы",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/niz/dzhinsy",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-dzhinsy-7545/",
                "keywords": ["джинсы", "джинсы мужские"]
            },
            "pants": {
                "name": "👔 Брюки",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/niz/bryuki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-bryuki-7546/",
                "keywords": ["брюки", "классические брюки"]
            },
            "cargo": {
                "name": "🪖 Карго",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/niz/bryuki?kind=2&subject=275",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-bryuki-kargo-31163/",
                "keywords": ["карго", "брюки карго"]
            },
            "shorts": {
                "name": "🩳 Шорты",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/odezhda/niz/shorty",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-shorty-7547/",
                "keywords": ["шорты"]
            }
        }
    },
    
    # ОБУВЬ
    "footwear": {
        "name": "👟 Обувь",
        "subcategories": {
            "sneakers": {
                "name": "👟 Кроссовки",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/obuv/krossovki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-krossovki-7560/",
                "keywords": ["кроссовки", "спортивная обувь"]
            },
            "boots": {
                "name": "👢 Ботинки",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/obuv/botinki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-botinki-7561/",
                "keywords": ["ботинки", "зимние ботинки"]
            },
            "shoes": {
                "name": "👞 Туфли",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/obuv/tufli",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-tufli-7562/",
                "keywords": ["туфли", "классическая обувь"]
            }
        }
    },
    
    # АКСЕССУАРЫ
    "accessories": {
        "name": "🎒 Аксессуары",
        "subcategories": {
            "hat": {
                "name": "🧢 Шапка",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/aksessuary/golovnye-ubory/shapki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-shapki-7581/",
                "keywords": ["шапка", "головной убор"]
            },
            "scarf": {
                "name": "🧣 Шарф",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/aksessuary/sharfy",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-sharfy-7582/",
                "keywords": ["шарф"]
            },
            "gloves": {
                "name": "🧤 Перчатки",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/aksessuary/perchatki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-perchatki-7583/",
                "keywords": ["перчатки"]
            },
            "bag": {
                "name": "🎒 Рюкзак",
                "wb_url": "https://www.wildberries.ru/catalog/odessa/muzhchinam/aksessuary/ryukzaki",
                "ozon_url": "https://www.ozon.ru/category/muzhskie-ryukzaki-7584/",
                "keywords": ["рюкзак", "сумка"]
            }
        }
    }
}

# ============================================
# 🔗 API ENDPOINTS
# ============================================

@app.route('/')
def home():
    return jsonify({
        "service": "OutfitStyle Marketplace API",
        "version": "1.0.0",
        "status": "active",
        "marketplaces": list(MARKETPLACES.keys()),
        "categories": len(CATEGORIES),
        "affiliate_ready": True
    })

@app.route('/health')
def health():
    return jsonify({
        "status": "ok",
        "service": "Marketplace Service",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/marketplaces', methods=['GET'])
def get_marketplaces():
    """Получить список доступных маркетплейсов"""
    return jsonify({
        "success": True,
        "marketplaces": MARKETPLACES
    })

@app.route('/api/categories', methods=['GET'])
def get_all_categories():
    """Получить все категории"""
    result = {}
    for key, value in CATEGORIES.items():
        result[key] = {
            "name": value["name"],
            "subcategories_count": len(value["subcategories"])
        }
    return jsonify({
        "success": True,
        "categories": result
    })

@app.route('/api/categories/<category_name>', methods=['GET'])
def get_category(category_name):
    """Получить подробности категории"""
    if category_name in CATEGORIES:
        return jsonify({
            "success": True,
            "category": category_name,
            "name": CATEGORIES[category_name]["name"],
            "subcategories": CATEGORIES[category_name]["subcategories"]
        })
    else:
        return jsonify({
            "success": False,
            "error": "Category not found"
        }), 404

@app.route('/api/match', methods=['POST'])
def match_item_to_marketplace():
    """
    Сопоставление ML рекомендации с маркетплейсом
    
    Request:
    {
        "item_name": "Пуховик",
        "category": "outerwear",
        "subcategory": "puffer_jacket",
        "marketplace": "wildberries"  // или "ozon" или "all"
    }
    """
    data = request.json
    
    item_name = data.get('item_name', '')
    category = data.get('category', '')
    subcategory = data.get('subcategory', '')
    marketplace = data.get('marketplace', 'all')
    
    if not category or category not in CATEGORIES:
        # Попытка найти по названию
        category, subcategory = _find_category_by_name(item_name)
    
    if not category:
        return jsonify({
            "success": False,
            "error": "Cannot match item to category"
        }), 400
    
    # Получаем ссылки
    links = _get_marketplace_links(category, subcategory, marketplace)
    
    return jsonify({
        "success": True,
        "item_name": item_name,
        "category": category,
        "subcategory": subcategory,
        "links": links
    })

@app.route('/api/outfit/links', methods=['POST'])
def get_outfit_links():
    """
    Получить ссылки для всего комплекта одежды
    
    Request:
    {
        "items": [
            {"name": "Пуховик", "category": "outerwear"},
            {"name": "Джинсы", "category": "lower"}
        ],
        "marketplace": "wildberries"
    }
    """
    data = request.json
    items = data.get('items', [])
    marketplace = data.get('marketplace', 'all')
    
    result = []
    
    for item in items:
        item_name = item.get('name', '')
        category = item.get('category', '')
        subcategory = item.get('subcategory', '')
        
        if not subcategory:
            category, subcategory = _find_category_by_name(item_name)
        
        if category and subcategory:
            links = _get_marketplace_links(category, subcategory, marketplace)
            result.append({
                "item_name": item_name,
                "category": category,
                "links": links
            })
    
    return jsonify({
        "success": True,
        "outfit_links": result,
        "total_items": len(result)
    })

@app.route('/api/affiliate/track', methods=['POST'])
def track_affiliate_click():
    """
    Отслеживание клика по партнерской ссылке
    
    Request:
    {
        "user_id": 1,
        "item_name": "Пуховик",
        "marketplace": "wildberries",
        "category": "outerwear"
    }
    """
    data = request.json
    
    # TODO: Сохранить в БД для аналитики и расчета комиссии
    logger.info(f"Affiliate click tracked: {data}")
    
    return jsonify({
        "success": True,
        "message": "Click tracked",
        "timestamp": datetime.now().isoformat()
    })

# ============================================
# 🛠️ HELPER FUNCTIONS
# ============================================

def _find_category_by_name(item_name):
    """Найти категорию по названию предмета"""
    item_lower = item_name.lower()
    
    for category_key, category_data in CATEGORIES.items():
        for subcat_key, subcat_data in category_data["subcategories"].items():
            keywords = subcat_data.get("keywords", [])
            
            # Проверка по ключевым словам
            for keyword in keywords:
                if keyword.lower() in item_lower or item_lower in keyword.lower():
                    return category_key, subcat_key
    
    return None, None

def _get_marketplace_links(category, subcategory, marketplace='all'):
    """Получить ссылки на маркетплейсы"""
    if category not in CATEGORIES:
        return []
    
    if subcategory not in CATEGORIES[category]["subcategories"]:
        return []
    
    subcat_data = CATEGORIES[category]["subcategories"][subcategory]
    
    links = []
    
    # Wildberries
    if marketplace in ['wildberries', 'all'] and 'wb_url' in subcat_data:
        links.append({
            "marketplace": "wildberries",
            "name": MARKETPLACES["wildberries"]["name"],
            "icon": MARKETPLACES["wildberries"]["icon"],
            "url": _add_affiliate_params(
                subcat_data["wb_url"], 
                MARKETPLACES["wildberries"]["affiliate_id"]
            ),
            "commission": MARKETPLACES["wildberries"]["commission"]
        })
    
    # Ozon
    if marketplace in ['ozon', 'all'] and 'ozon_url' in subcat_data:
        links.append({
            "marketplace": "ozon",
            "name": MARKETPLACES["ozon"]["name"],
            "icon": MARKETPLACES["ozon"]["icon"],
            "url": _add_affiliate_params(
                subcat_data["ozon_url"], 
                MARKETPLACES["ozon"]["affiliate_id"]
            ),
            "commission": MARKETPLACES["ozon"]["commission"]
        })
    
    return links

def _add_affiliate_params(url, affiliate_id):
    """Добавить партнерские параметры к URL"""
    separator = "&" if "?" in url else "?"
    return f"{url}{separator}aff_id={affiliate_id}"

# ============================================
# 🚀 RUN
# ============================================

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5001))
    logger.info(f"🚀 Starting Marketplace Service on port {port}")
    app.run(host='0.0.0.0', port=port, debug=True)