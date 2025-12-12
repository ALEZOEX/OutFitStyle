# Структура БД и ML-сервиса

## Таблица subcategory_specs (словарь + нормы для Planner)
```
- category (TEXT, NOT NULL)           # outerwear, upper, lower, footwear, accessory
- subcategory (TEXT, NOT NULL)        # parka, puffer, coat, softshell, raincoat, tshirt, etc.
- warmth_min (SMALLINT, NOT NULL)     # 1-10 scale
- temp_min_reco (SMALLINT, NOT NULL)  # минимальная рекомендуемая температура
- temp_max_reco (SMALLINT, NOT NULL)  # максимальная рекомендуемая температура (CHECK: temp_min_reco <= temp_max_reco)
- rain_ok (BOOLEAN, NOT NULL)         # TRUE если подходит для дождя
- snow_ok (BOOLEAN, NOT NULL)         # TRUE если подходит для снега
- wind_ok (BOOLEAN, NOT NULL)         # TRUE если подходит для ветра
- PRIMARY KEY (category, subcategory)
- CHECK (category IN ('outerwear','upper','lower','footwear','accessory'))
```

## Таблица clothing_items (каталог)
```
- id (BIGINT, PRIMARY KEY)                    # уникальный ID вещи
- name (TEXT, NOT NULL)                       # название вещи
- category (TEXT, NOT NULL)                   # outerwear, upper, lower, footwear, accessory
- subcategory (TEXT, NOT NULL)                # parka, puffer, tshirt, jeans, etc.
- gender (TEXT, NOT NULL)                     # 'unisex' (CHECK: IN ('unisex'))
- style (TEXT, NOT NULL)                      # casual, sport, street, classic, business, smart_casual, outdoor
- usage (TEXT, NOT NULL)                      # daily, work, formal, sport, outdoor, travel, party
- season (TEXT, NOT NULL)                     # winter, spring, summer, autumn, all
- base_colour (TEXT, NOT NULL)                # black, white, gray, navy, beige, brown, green, blue, red, pink, yellow, orange, purple
- formality_level (SMALLINT, NOT NULL)        # 1-5 scale
- warmth_level (SMALLINT, NOT NULL)           # 1-10 scale
- min_temp (SMALLINT, NOT NULL)               # минимальная температура использования
- max_temp (SMALLINT, NOT NULL)               # максимальная температура использования (CHECK: min_temp <= max_temp)
- materials (TEXT[], NOT NULL)                # массив материалов: ['cotton', 'wool', 'polyester']
- fit (TEXT, NOT NULL)                        # slim, regular, relaxed, oversized
- pattern (TEXT, NOT NULL)                    # solid, striped, checked, printed, camo
- icon_emoji (TEXT, NOT NULL)                 # эмодзи для отображения
- source (TEXT, NOT NULL)                     # synthetic, user, partner, manual (CHECK: IN (...))
- is_owned (BOOLEAN, NOT NULL)                # TRUE если вещь принадлежит пользователю
- created_at (TIMESTAMPTZ, NOT NULL)          # дата создания
- FOREIGN KEY (category, subcategory) REFERENCES subcategory_specs (category, subcategory)
```

## Индексы для эффективного Retrieval
```
- clothing_items_cat_subcat_idx (category, subcategory)     # для быстрого поиска по категории/подкатегории
- clothing_items_cat_warmth_idx (category, warmth_level)    # для быстрого поиска по категории/теплоте
- clothing_items_cat_style_idx (category, style)            # для быстрого поиска по категории/стилю
- clothing_items_temp_idx (min_temp, max_temp)              # для быстрого поиска по температуре
```

## Таблица wardrobe_items (связь пользователей с их вещами)
```
- id (BIGINT, PRIMARY KEY)
- user_id (BIGINT REFERENCES users(id) ON DELETE CASCADE)
- clothing_item_id (BIGINT REFERENCES clothing_items(id) ON DELETE CASCADE)
- quantity (INTEGER)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
- INDEX (user_id)
- INDEX (clothing_item_id)
```

## Таблица users (без изменений)
```
- id (BIGINT, PRIMARY KEY)
- email (TEXT, UNIQUE)
- name (TEXT)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

## ML-сервис (ml-service/)

### model/features_with_priorities.py
```python
# Признаки, используемые моделью:
- category_idx: one-hot для категории (outerwear, upper, lower, footwear, accessory)
- subcategory_idx: one-hot для подкатегории (parka, puffer, tshirt, etc.)
- formality_level: числовое значение 1-5
- warmth_level: числовое значение 1-10
- temperature_match: разница между запрошенной температурой и диапазоном вещи
- is_synthetic, is_user, is_partner, is_manual: one-hot для источника
- is_owned: бинарное (0/1) при наличии в гардеробе
- source_priority: приоритет источника (0-3), где 3 - highest (user/wardrobe items)
- material_count: количество материалов в вещи
- fit_encoded: one-hot для фасона
- pattern_encoded: one-hot для рисунка
- season_encoded: one-hot для сезона
- style_encoded: one-hot для стиля
- цвета: one-hot для основного цвета
```

### model/enhanced_predictor.py
- Учет приоритетов источников: user > manual > partner > synthetic
- Формирование итогового скоринга с учетом source_priority
- Обработка NaN значений
- Предсказание вероятности соответствия запросу

### application/planner/planner.go
- Использует нормы из subcategory_specs для генерации плана
- Рекомендует подходящие subcategory для заданных условий
- Учитывает температуру и погодные условия (дождь, снег, ветер)

### api/main.py
- `/predict/` endpoint для получения рекомендаций
- Принимает параметры: temperature, weather_condition, user_preferences
- Использует Planner → Retrieval → Ranking pipeline
- Возвращает оцененные вещи с scores
```

## Go-сервис (server/internal/)

### domain/clothing.go
- Поддерживает все новые атрибуты из схемы
- Включает материалы как []string
- Поддерживает валидацию по нормам из subcategory_specs

### application/services/clothing_item_service.go
- GenerateOutfitPlan: использует Planner для генерации плана
- GetItemsForPlan: находит вещи, соответствующие плану
- Поддерживает полный цикл: Planner → Retrieval → Ranking

### infrastructure/persistence/postgres/clothing_repository.go
- Реализует интерфейсы для работы с новыми таблицами
- Поддерживает bulk insert для больших объемов данных
- Эффективные запросы для Retrieval по плану