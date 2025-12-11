"""
Скрипт для импорта данных из Kaggle styles.csv в таблицу clothing_items
"""

import pandas as pd
import psycopg2
import os
from typing import Dict, Any

def map_category(master_cat: str, article_type: str) -> str:
    """
    Преобразует категории из Kaggle в наши категории
    """
    if not master_cat and not article_type:
        return "upper"
        
    m = master_cat.lower() if master_cat else ""
    a = article_type.lower() if article_type else ""
    
    if m in ("topwear", "shirts", "tshirts", "sweatshirts", "dress", "dresses", "tops", "blouses"):
        return "upper"
    if m in ("bottomwear", "jeans", "trousers", "shorts", "skirts", "track pants"):
        return "lower"
    if m == "footwear":
        return "footwear"
    if m in ("accessories", "watches", "bags", "jewellery", "belts", "sunglasses", "scarves"):
        return "accessory"
    if m in ("innerwear", "sleep & lounge"):
        return "underwear"
    if m in ("apparel", "personal care"):
        # Если статья более специфична
        if a in ("shirts", "tshirts", "sweatshirts", "tops", "blouses", "dresses"):
            return "upper"
        elif a in ("jeans", "trousers", "shorts", "skirts"):
            return "lower"
        elif a in ("shoes", "casual shoes", "formal shoes", "sandals", "flip flops"):
            return "footwear"
        elif a in ("watches", "bags", "jewellery", "belts", "sunglasses"):
            return "accessory"
        else:
            return "upper"
            
    return "upper"  # по умолчанию верхняя одежда


def get_db_connection():
    """
    Создает подключение к базе данных
    """
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'postgres'),
        database=os.getenv('DB_NAME', 'outfitstyle'),
        user=os.getenv('DB_USER', 'Admin'),
        password=os.getenv('DB_PASSWORD', 'admin123'),
        port=os.getenv('DB_PORT', '5432')
    )


def import_kaggle_data():
    """
    Импортирует данные из styles.csv в таблицу clothing_items
    """
    # Проверяем, существует ли файл
    csv_path = "/app/data/raw/styles.csv"
    if not os.path.exists(csv_path):
        print(f"Файл {csv_path} не найден!")
        return
    
    print("Чтение CSV файла...")
    df = pd.read_csv(
        csv_path,
        on_bad_lines="skip",
        usecols=[
            "id",
            "gender",
            "masterCategory",
            "subCategory", 
            "articleType",
            "baseColour",
            "season",
            "year",
            "usage",
            "productDisplayName",
        ],
    )
    
    print(f"Загружено {len(df)} записей из CSV")
    
    # Удаляем дубликаты по ID
    df = df.drop_duplicates(subset=['id'])
    print(f"После удаления дубликатов: {len(df)} записей")
    
    # Проверяем соединение с базой данных
    try:
        conn = get_db_connection()
        print("Подключение к базе данных успешно")
    except Exception as e:
        print(f"Ошибка подключения к базе данных: {e}")
        return
    
    cursor = conn.cursor()
    
    successful_inserts = 0
    failed_inserts = 0
    
    print("Начинаем импорт в базу данных...")
    
    for idx, row in df.iterrows():
        try:
            cid = int(row["id"])
            name = str(row["productDisplayName"] or row["articleType"] or "Item")
            category = map_category(row["masterCategory"], row["articleType"])
            subcategory = str(row["articleType"] or "").lower() or None

            cursor.execute(
                """
                INSERT INTO clothing_items (
                    id, name, category, subcategory,
                    icon_emoji, gender, season, base_colour, usage, source,
                    is_owned, owner_user_id,
                    min_temp, max_temp, warmth_level, formality_level,
                    created_at, updated_at
                )
                VALUES (%(id)s, %(name)s, %(category)s, %(subcategory)s,
                        %(icon_emoji)s, %(gender)s, %(season)s, %(base_colour)s, %(usage)s, 'kaggle_seed',
                        FALSE, NULL,
                        NULL, NULL, NULL, NULL,
                        NOW(), NOW())
                ON CONFLICT (id) DO NOTHING
                """,
                {
                    "id": cid,
                    "name": name[:255] if len(name) > 255 else name,  # Ограничение для VARCHAR(255)
                    "category": category,
                    "subcategory": subcategory[:50] if subcategory and len(subcategory) > 50 else subcategory,
                    "icon_emoji": "👕",  # значение по умолчанию
                    "gender": str(row.get("gender"))[:20] if row.get("gender") else None,
                    "season": str(row.get("season"))[:20] if row.get("season") else None,
                    "base_colour": str(row.get("baseColour"))[:30] if row.get("baseColour") else None,
                    "usage": str(row.get("usage"))[:50] if row.get("usage") else None,
                },
            )
            
            successful_inserts += 1
            
            # Показываем прогресс каждые 1000 записей
            if successful_inserts % 1000 == 0:
                print(f"Обработано {successful_inserts} записей...")
                
        except Exception as e:
            print(f"Ошибка при вставке строки {idx}, ID {row['id']}: {e}")
            failed_inserts += 1
            continue
    
    # Фиксируем изменения
    conn.commit()
    cursor.close()
    conn.close()
    
    print(f"\nИмпорт завершен!")
    print(f"Успешно вставлено: {successful_inserts}")
    print(f"Неудачных вставок: {failed_inserts}")
    print(f"Всего обработано: {successful_inserts + failed_inserts}")


if __name__ == "__main__":
    import_kaggle_data()