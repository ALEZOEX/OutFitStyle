# Архитектура OutfitStyle: Объединенный каталог вещей

## Введение

OutfitStyle реализует продвинутую архитектуру с единой моделью вещей и системой Retrieval → Ranking для рекомендаций. 

## Архитектурные изменения

### Единая модель вещей

Все вещи теперь хранятся в одной таблице `clothing_items` с расширенными атрибутами:
- `gender` - пол (Men, Women, Unisex, Boys, Girls)
- `master_category` - основная категория (Apparel, Accessory, Footwear и т.д.)
- `subcategory` - подкатегория (Tshirts, Jeans, Dresses и т.д.)
- `season` - сезон (Spring, Summer, Fall, Winter)
- `base_colour` - базовый цвет
- `usage` - использование (Casual, Formal, Sports и т.д.)
- `source` - источник (wardrobe, catalog, kaggle_seed)
- `is_owned` - принадлежит ли пользователю
- `owner_user_id` - ID владельца (для личных вещей)
- `min_temp`, `max_temp` - температурные границы
- `warmth_level`, `formality_level` - числовые параметры

### Приоритеты источников

Система рекомендаций учитывает приоритеты источников:
1. **Личный гардероб (wardrobe)** - вещи пользователя, если подходят по погоде (наивысший приоритет)
2. **Каталог/рынок (catalog/marketplace)** - реальные товары (средний приоритет)
3. **Kaggle seed** - "образцовые" вещи из датасета (базовая линия)

### Retrieval → Ranking система

#### Retrieval (этап подбора кандидатов)

`get_candidate_items(user_id, weather, profile, limit_per_cat)` возвращает вещи с приоритетами:
1. Сначала ищутся вещи из `wardrobe_items` пользователя
2. Затем недостающие категории из `clothing_items` с `source IN ('catalog', 'marketplace')`
3. Наконец, если всё равно нехватает, из `source='kaggle_seed'`
4. Общее ограничение на 1000 вещей для эффективности

#### Ranking (ML-ранжирование)

EnhancedOutfitPredictor теперь:
- Учитывает `source` и `is_owned` как признаки в модели
- Добавляет +α к score, если `is_owned = True` и вещь подходит по погоде
- Даёт меньший приоритет вещам из `catalog` по сравнению с `wardrobe`
- `kaggle_seed` как базовая линия (0)

## Импорт Kaggle датасета

### CSV файл

Файл `styles.csv` из Kaggle датасета:
- Проходит обработку через `scripts/import_kaggle_styles.py`
- Игнорирует кривые строки с помощью `on_bad_lines="skip"`
- Маппится в нашу систему категорий с помощью `map_category()`
- Загружается в `clothing_items` с `source='kaggle_seed'`

### Поля датасета

Original fields → Our fields:
- `id` → `id` (используется как основной ID)
- `gender` → `gender`
- `masterCategory` → `master_category`
- `articleType` → `category` (и `subcategory`)
- `baseColour` → `base_colour`
- `season` → `season`
- `usage` → `usage`
- `productDisplayName` → `name`

### Маппинг категорий

```
def map_category(master_cat: str, article_type: str) -> str:
    m = master_cat.lower()
    a = article_type.lower()
    if m in ("topwear", "shirts", "tshirts", ...):
        return "upper"
    if m in ("bottomwear", "jeans", "trousers", ...):
        return "lower"
    if m == "footwear":
        return "footwear"
    if m == "accessories":
        return "accessory"
    return "upper"  # default
```

## Безопасность аутентификации

### Восстановление пароля

- Использование токенов с высокой энтропией (32 байта, base64-encoded)
- Ограничение времени жизни токена (24 часа)
- Защита от частых попыток (один раз в 5 минут на email)
- Очистка устаревших токенов
- Безопасная обработка ошибок

## Flutter модель данных

### ClothingItem.fromJson()

```dart
factory ClothingItem.fromJson(Map<String, dynamic> json) {
  return ClothingItem(
    id: JsonConverter.toInt(json['id']) ?? 0,
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? '',
    // ... остальные поля
    source: json['source'] as String? ?? 'catalog',
    isOwned: json['is_owned'] as bool? ?? false,
    minTemp: JsonConverter.toDouble(json['min_temp']),
    maxTemp: JsonConverter.toDouble(json['max_temp']),
    warmthLevel: JsonConverter.toInt(json['warmth_level']),
    formalityLevel: JsonConverter.toInt(json['formality_level']),
  );
}
```

### Безопасная десериализация

- Использование `JsonConverter` для безопасной конвертации типов
- Обработка null значений с помощью `??` и `?.` операторов
- Проверки на `isNotEmpty` перед доступом к спискам
- Параметр `onBadLines: OnBadLines.skip` для CSV парсинга

## ML-сервис архитектура

### Упрощение: Нет CSV в рантайме

- Полностью удалена функция `load_internal_dataset_items()`
- Удалено чтение `styles.csv` в рантайме
- Все вещи теперь из базы данных через `get_candidate_items()`

### Управление приоритетами

В `EnhancedOutfitPredictor` и `features.py`:
- One-hot кодирование для `source`
- Бинарный признак `is_owned`
- Веса при обучении учитывают принадлежность
- При ранжировании - приоритет личным вещам из гардероба

## Тестирование сценариев

### "Богатый" гардероб
- Пользователь имеет все категории вещей
- Система в основном использует его личные вещи

### "Бедный" гардероб
- В гардеробе только летняя одежда, а на улице -20°C
- Система добирает зимние вещи из каталога и kaggle_seed

### Комбинированный сценарий
- Некоторые категории в гардеробе, другие из каталога
- Система комбинирует с учетом приоритетов источников

## Перспективы развития

1. **Расширение источников**: Парсинг реальных интернет-магазинов
2. **CV-модели**: Добавление вещей по фото через компьютерное зрение
3. **Персонализация**: Учет обратной связи пользователя (лайки/дизлайки)
4. **Многопользовательские сценарии**: Совместное планирование образов
5. **Улучшение ML-модели**: Использование эмбеддингов и нейронных сетей

## Заключение

Новая архитектура успешно реализована и готова к использованию. Она обеспечивает:
- Профессиональный подход с единым каталогом
- Четкое разделение Retrieval и Ranking
- Учет приоритетов источников вещей
- Безопасную аутентификацию
- Расширяемую ML-систему
- Надежные фоллбеки