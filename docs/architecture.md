# Документация по архитектуре OutfitStyle

## Оглавление
1. [Введение](#введение)
2. [Архитектурные изменения](#архитектурные-изменения)
3. [База данных](#база-данных)
4. [ML-Сервис](#ml-сервис)
5. [Импорт данных Kaggle](#импорт-данных-kaggle)
6. [Процесс рекомендаций](#процесс-рекомендаций)

## Введение

OutfitStyle - это приложение для подбора рекомендаций одежды на основе погоды, личных предпочтений и гардероба пользователя. В проекте реализована продвинутая архитектура с единым каталогом вещей и многоуровневой системой рекомендаций.

## Архитектурные изменения

### Единая модель вещей

Все вещи теперь хранятся в одной таблице `clothing_items` с расширенными атрибутами:
- `gender` - пол (Men, Women, Unisex, Boys, Girls)
- `master_category` - основная категория (Apparel, Accessory, Footwear и т.д.)
- `subcategory` - подкатегория (Tshirts, Jeans, Dresses и т.д.)
- `season` - сезон (Spring, Summer, Fall, Winter)
- `base_colour` - базовый цвет
- `usage` - использование (Casual, Formal, Sports и т.д.)
- `source` - источник (wardrobe, catalog, kaggle_seed, marketplace)
- `is_owned` - принадлежит ли пользователю
- `owner_user_id` - ID владельца (для личных вещей)

### Приоритеты источников данных

1. **Личный гардероб (wardrobe)** - вещи пользователя, если подходят по погоде
2. **Реальные новые вещи (catalog/marketplace)** - реальные товары
3. **Kaggle seed** - "образцовые" вещи из датасета для обучения

## База данных

### Таблица clothing_items

Расширена схема таблицы для поддержки новых атрибутов:

```sql
ALTER TABLE clothing_items
    ADD COLUMN IF NOT EXISTS gender           TEXT,
    ADD COLUMN IF NOT EXISTS master_category  TEXT,
    ADD COLUMN IF NOT EXISTS subcategory      TEXT,
    ADD COLUMN IF NOT EXISTS season           TEXT,
    ADD COLUMN IF NOT EXISTS base_colour      TEXT,
    ADD COLUMN IF NOT EXISTS usage            TEXT,
    ADD COLUMN IF NOT EXISTS source           TEXT DEFAULT 'catalog',
    ADD COLUMN IF NOT EXISTS is_owned         BOOLEAN DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS owner_user_id    BIGINT,
    ADD COLUMN IF NOT EXISTS min_temp         DECIMAL(4, 2),
    ADD COLUMN IF NOT EXISTS max_temp         DECIMAL(4, 2),
    ADD COLUMN IF NOT EXISTS warmth_level     INTEGER,
    ADD COLUMN IF NOT EXISTS formality_level  INTEGER;
```

### Новая таблица wardrobe_items

Для хранения связей между пользователями и их личными вещами:

```sql
CREATE TABLE IF NOT EXISTS wardrobe_items (
    user_id          BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    clothing_item_id BIGINT NOT NULL REFERENCES clothing_items(id) ON DELETE CASCADE,
    created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, clothing_item_id)
);
```

## ML-Сервис

### Упрощение архитектуры

ML-сервис теперь использует Retrieval систему для подбора кандидатов из базы данных вместо чтения CSV-файла:

```python
def get_candidate_items(user_id, weather, profile, limit_per_cat=300):
    """
    Возвращает список candidate-вещей с приоритетом:
    1) гардероб (wardrobe),
    2) реальные новые (catalog/marketplace),
    3) kaggle_seed.
    """
```

### Удаление старого датасета

Функция `load_internal_dataset_items()` и чтение CSV файла `styles.csv` теперь не используются, так как датасет импортирован в базу данных.

## Импорт данных Kaggle

Для импорта датасета из Kaggle используется скрипт `scripts/import_kaggle_styles.py`, который:

1. Читает `styles.csv` с пропуском кривых строк
2. Маппит категории в нашу систему
3. Вставляет данные в `clothing_items` с `source='kaggle_seed'`
4. Использует `ON CONFLICT (id) DO NOTHING` для предотвращения дубликатов

## Процесс рекомендаций

### Retrieval (подбор кандидатов)

1. Сначала ищутся вещи из личного гардероба пользователя
2. Затем добавляются вещи из каталога для недостающих категорий
3. Наконец, добавляются "образцовые" вещи из Kaggle-датасета для полного покрытия

### Ranking (ранжирование)

ML-модель ранжирует отобранные кандидаты на основе:
- Погодных условий
- Предпочтений пользователя
- Стилевой совместимости
- Тепловых характеристик одежды

### Безопасные фоллбеки

Если ни на одном этапе не найдены подходящие вещи, система возвращает:
- Пустой ответ с информацией об отсутствии подходящих рекомендаций
- Ни в коем случае не вызывает таймауты или 404 от ML-сервиса