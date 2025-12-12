"""
Скрипт для быстрого импорта каталога одежды в PostgreSQL с использованием COPY.
"""
import json
import psycopg2
from psycopg2.extras import execute_values
import sys
import argparse
from typing import List, Dict, Any
import logging
import time
from contextlib import contextmanager


# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


@contextmanager
def get_db_connection(connection_params: Dict[str, Any]):
    """Контекстный менеджер для подключения к БД."""
    conn = psycopg2.connect(**connection_params)
    try:
        yield conn
    finally:
        conn.close()


def prepare_items_for_insert(items: List[Dict[str, Any]]) -> List[tuple]:
    """Подготовить данные для вставки в БД."""
    prepared_items = []
    
    for item in items:
        # Преобразование материалов в строку массива PostgreSQL
        materials = item.get('materials', [])
        if isinstance(materials, list):
            materials_str = "{" + ",".join([f'"{m}"' for m in materials]) + "}"
        else:
            materials_str = "{}"  # пустой массив
        
        # Преобразование булевых значений
        is_owned = bool(item.get('is_owned', False))
        
        # Преобразование уровней
        formality = int(item.get('formality_level', item.get('formality', 1)))
        warmth = int(item.get('warmth_level', item.get('warmth', 1)))
        
        prepared_item = (
            item.get('id'),
            item.get('name', ''),
            item.get('category', ''),
            item.get('subcategory', ''),
            item.get('gender', 'unisex'),
            item.get('style', ''),
            item.get('usage', ''),
            item.get('season', ''),
            item.get('base_colour', ''),
            formality,
            warmth,
            item.get('min_temp', 0),
            item.get('max_temp', 30),
            materials_str,
            item.get('fit', ''),
            item.get('pattern', ''),
            item.get('icon_emoji', ''),
            item.get('source', 'synthetic'),
            is_owned
        )
        prepared_items.append(prepared_item)
    
    return prepared_items


def bulk_insert_items(connection_params: Dict[str, Any], items: List[Dict[str, Any]], batch_size: int = 10000):
    """Массовая вставка элементов с использованием COPY."""
    logger.info(f"Начинаю импорт {len(items)} элементов в БД")
    
    # Подготовка данных
    start_time = time.time()
    prepared_items = prepare_items_for_insert(items)
    logger.info(f"Подготовлено {len(prepared_items)} записей за {time.time() - start_time:.2f}с")
    
    # Вставка в БД
    with get_db_connection(connection_params) as conn:
        with conn.cursor() as cur:
            # Подготовка SQL запроса
            insert_sql = """
                INSERT INTO clothing_items (
                    id, name, category, subcategory, gender, style, usage, season, 
                    base_colour, formality_level, warmth_level, min_temp, max_temp, 
                    materials, fit, pattern, icon_emoji, source, is_owned
                ) VALUES %s
                ON CONFLICT (id) DO UPDATE SET
                    name = EXCLUDED.name,
                    category = EXCLUDED.category,
                    subcategory = EXCLUDED.subcategory,
                    gender = EXCLUDED.gender,
                    style = EXCLUDED.style,
                    usage = EXCLUDED.usage,
                    season = EXCLUDED.season,
                    base_colour = EXCLUDED.base_colour,
                    formality_level = EXCLUDED.formality_level,
                    warmth_level = EXCLUDED.warmth_level,
                    min_temp = EXCLUDED.min_temp,
                    max_temp = EXCLUDED.max_temp,
                    materials = EXCLUDED.materials,
                    fit = EXCLUDED.fit,
                    pattern = EXCLUDED.pattern,
                    icon_emoji = EXCLUDED.icon_emoji,
                    source = EXCLUDED.source,
                    is_owned = EXCLUDED.is_owned
            """
            
            total_inserted = 0
            start_time = time.time()
            
            # Разделение на батчи
            for i in range(0, len(prepared_items), batch_size):
                batch = prepared_items[i:i + batch_size]
                
                execute_values(cur, insert_sql, batch, template=None, page_size=len(batch))
                conn.commit()
                
                total_inserted += len(batch)
                elapsed = time.time() - start_time
                rate = total_inserted / elapsed if elapsed > 0 else 0
                
                logger.info(f"Вставлено {total_inserted}/{len(prepared_items)} записей, "
                           f"скорость: {rate:.1f} записей/сек")
            
            total_time = time.time() - start_time
            logger.info(f"Импорт завершен за {total_time:.2f}с, средняя скорость: {len(prepared_items)/total_time:.1f} записей/сек")


def load_catalog_from_file(catalog_file: str) -> List[Dict[str, Any]]:
    """Загрузить каталог из файла (JSON или NDJSON)."""
    items = []
    
    with open(catalog_file, 'r', encoding='utf-8') as f:
        if catalog_file.endswith('.json'):
            # Полагаем, что файл содержит массив JSON объектов
            data = json.load(f)
            if isinstance(data, list):
                items = data
            else:
                raise ValueError("JSON файл должен содержать массив объектов")
        else:
            # NDJSON формат - по одному JSON объекту на строку
            for line_num, line in enumerate(f, 1):
                line = line.strip()
                if line:
                    try:
                        items.append(json.loads(line))
                    except json.JSONDecodeError as e:
                        logger.error(f"Ошибка парсинга JSON на строке {line_num}: {e}")
                        raise
    
    logger.info(f"Загружено {len(items)} элементов из {catalog_file}")
    return items


def main():
    parser = argparse.ArgumentParser(description='Bulk import clothing catalog to PostgreSQL using COPY')
    parser.add_argument('catalog_file', help='Path to catalog file (JSON or NDJSON)')
    parser.add_argument('--host', default='localhost', help='Database host')
    parser.add_argument('--port', type=int, default=5432, help='Database port')
    parser.add_argument('--dbname', default='outfitstyle', help='Database name')
    parser.add_argument('--user', default='Admin', help='Database user')
    parser.add_argument('--password', default='password', help='Database password')
    parser.add_argument('--batch-size', type=int, default=10000, help='Batch size for inserts')
    
    args = parser.parse_args()
    
    connection_params = {
        'host': args.host,
        'port': args.port,
        'dbname': args.dbname,
        'user': args.user,
        'password': args.password
    }
    
    try:
        # Загрузка каталога
        items = load_catalog_from_file(args.catalog_file)
        
        # Валидация (опционально - можно добавить вызов validate_catalog)
        logger.info("Начинаю импорт в БД...")
        bulk_insert_items(connection_params, items, args.batch_size)
        
        logger.info("✅ Импорт успешно завершен!")
        
    except FileNotFoundError:
        logger.error(f"❌ Файл не найден: {args.catalog_file}")
        sys.exit(1)
    except psycopg2.Error as e:
        logger.error(f"❌ Ошибка работы с БД: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"❌ Непредвиденная ошибка: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()