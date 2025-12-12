"""
Скрипт для валидации каталога одежды перед импортом.
Проверяет:
- category/subcategory строго по словарю
- min_temp <= max_temp, уровни в диапазонах
- materials только из словаря
- распределение по категориям
"""
import json
import sys
from typing import Dict, List, Set, Any
import argparse
from collections import Counter


def load_subcategory_specs(specs_file: str) -> Set[tuple]:
    """Загрузить допустимые комбинации category/subcategory из спецификаций."""
    specs = set()
    # Вместо загрузки из файла, используем канонический словарь
    categories = ['outerwear', 'upper', 'lower', 'footwear', 'accessory']
    
    # Стандартные подкатегории для каждой категории
    subcategories_by_category = {
        'outerwear': ['parka', 'puffer', 'coat', 'softshell', 'raincoat'],
        'upper': ['tshirt', 'longsleeve', 'shirt', 'hoodie', 'sweater', 'thermal_top'],
        'lower': ['shorts', 'jeans', 'pants', 'thermal_pants', 'skirt'],
        'footwear': ['sandals', 'sneakers', 'boots', 'winter_boots', 'loafers'],
        'accessory': ['hat', 'scarf', 'gloves', 'umbrella', 'bag']
    }
    
    for cat in categories:
        for subcat in subcategories_by_category[cat]:
            specs.add((cat, subcat))
    
    return specs


def load_materials_dictionary() -> Set[str]:
    """Загрузить допустимые материалы."""
    # Стандартный словарь материалов
    return {
        'cotton', 'wool', 'polyester', 'silk', 'leather', 'denim', 'linen', 
        'cashmere', 'acrylic', 'nylon', 'spandex', 'rayon', 'tencel', 'modal',
        'viscose', 'suede', 'velvet', 'corduroy', 'chiffon', 'lace', 'chambray'
    }


def validate_item(item: Dict[str, Any], valid_specs: Set[tuple], valid_materials: Set[str]) -> List[str]:
    """Проверить один элемент каталога."""
    errors = []
    
    # Проверка category/subcategory
    category = item.get('category')
    subcategory = item.get('subcategory')
    
    if not category:
        errors.append("Missing category")
    elif not subcategory:
        errors.append("Missing subcategory")
    elif (category, subcategory) not in valid_specs:
        errors.append(f"Invalid category/subcategory combination: {category}/{subcategory}")
    
    # Проверка температурного диапазона
    min_temp = item.get('min_temp')
    max_temp = item.get('max_temp')
    
    if min_temp is not None and max_temp is not None:
        if min_temp > max_temp:
            errors.append(f"min_temp ({min_temp}) > max_temp ({max_temp})")
    
    # Проверка уровней
    formality = item.get('formality_level', item.get('formality', 0))
    warmth = item.get('warmth_level', item.get('warmth', 0))
    
    if not (1 <= formality <= 5):
        errors.append(f"Formality level {formality} out of range [1, 5]")
    
    if not (1 <= warmth <= 10):
        errors.append(f"Warmth level {warmth} out of range [1, 10]")
    
    # Проверка материалов
    materials = item.get('materials', [])
    if not isinstance(materials, list):
        errors.append("Materials should be a list")
    else:
        invalid_materials = [m for m in materials if m not in valid_materials]
        if invalid_materials:
            errors.append(f"Invalid materials: {invalid_materials}")
    
    return errors


def validate_catalog(catalog_file: str) -> Dict[str, Any]:
    """Проверить весь каталог."""
    with open(catalog_file, 'r', encoding='utf-8') as f:
        if catalog_file.endswith('.json'):
            catalog = json.load(f)
        else:
            # Предполагаем NDJSON формат
            catalog = []
            for line in f:
                catalog.append(json.loads(line))
    
    valid_specs = load_subcategory_specs(None)  # используем встроенный словарь
    valid_materials = load_materials_dictionary()
    
    all_errors = []
    category_distribution = Counter()
    total_items = len(catalog)
    
    for i, item in enumerate(catalog):
        try:
            errors = validate_item(item, valid_specs, valid_materials)
            if errors:
                all_errors.append({
                    'index': i,
                    'id': item.get('id', f'unknown_{i}'),
                    'errors': errors
                })
            
            # Считаем распределение по категориям
            category = item.get('category')
            if category:
                category_distribution[category] += 1
                
        except Exception as e:
            all_errors.append({
                'index': i,
                'id': item.get('id', f'unknown_{i}'),
                'errors': [f"Exception during validation: {e}"]
            })
    
    return {
        'total_items': total_items,
        'invalid_items': len(all_errors),
        'errors': all_errors,
        'category_distribution': dict(category_distribution),
        'valid': len(all_errors) == 0
    }


def print_report(report: Dict[str, Any]):
    """Вывести отчет о валидации."""
    print(f"Всего элементов: {report['total_items']}")
    print(f"Невалидных элементов: {report['invalid_items']}")
    print(f"Валидация пройдена: {'Да' if report['valid'] else 'Нет'}")
    
    print("\nРаспределение по категориям:")
    for cat, count in report['category_distribution'].items():
        percentage = (count / report['total_items']) * 100
        print(f"  {cat}: {count} ({percentage:.1f}%)")
    
    if report['errors']:
        print(f"\nПервые 10 ошибок:")
        for error in report['errors'][:10]:
            print(f"  Item {error['id']} (index {error['index']}): {error['errors']}")
        
        if len(report['errors']) > 10:
            print(f"  ... и еще {len(report['errors']) - 10} ошибок")


def main():
    parser = argparse.ArgumentParser(description='Validate clothing catalog before import')
    parser.add_argument('catalog_file', help='Path to catalog file (JSON or NDJSON)')
    parser.add_argument('--fix', action='store_true', help='Attempt to fix common issues')
    
    args = parser.parse_args()
    
    try:
        report = validate_catalog(args.catalog_file)
        print_report(report)
        
        if not report['valid']:
            sys.exit(1)  # Exit with error code if validation failed
        else:
            print("\n✅ Каталог валидный!")
            
    except FileNotFoundError:
        print(f"❌ Файл не найден: {args.catalog_file}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ Ошибка парсинга JSON: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Непредвиденная ошибка: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()