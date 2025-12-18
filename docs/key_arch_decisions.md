# Ключевые архитектурные решения OutfitStyle

## 1. Структура БД

### 1.1. subcategory_specs - централизованный словарь и нормы
```sql
CREATE TABLE subcategory_specs (
  category        TEXT NOT NULL,
  subcategory     TEXT NOT NULL,
  warmth_min      SMALLINT NOT NULL CHECK (warmth_min BETWEEN 1 AND 10),
  temp_min_reco   SMALLINT NOT NULL,
  temp_max_reco   SMALLINT NOT NULL CHECK (temp_min_reco <= temp_max_reco),
  rain_ok         BOOLEAN NOT NULL DEFAULT TRUE,
  snow_ok         BOOLEAN NOT NULL DEFAULT TRUE,
  wind_ok         BOOLEAN NOT NULL DEFAULT TRUE,
  PRIMARY KEY (category, subcategory),
  CONSTRAINT subcategory_specs_category_check
    CHECK (category IN ('outerwear','upper','lower','footwear','accessory'))
);
```

**Решение**: Централизованный словарь подкатегорий с нормами, который используется Planner'ом для генерации плана.

**Почему**: 
- Planner может получать нормы из БД, а не из кода
- Упрощается добавление новых подкатегорий
- Автоматическая валидация через CHECK-ограничения

### 1.2. clothing_items - хранение материалов как массива
```sql
CREATE TABLE clothing_items (
  -- ... другие поля ...
  materials        TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  -- ... остальные поля ...
);
```

**Решение**: Хранение материалов как массива TEXT[] вместо одного поля material.

**Почему**:
- Соответствует реальности (вещь может состоять из нескольких материалов)
- Позволяет генератору возвращать список материалов без потерь
- Поддержка более точного ML-анализа

### 1.3. FK-связь с нормами
```sql
CONSTRAINT clothing_items_subcategory_fk
  FOREIGN KEY (category, subcategory)
  REFERENCES subcategory_specs (category, subcategory)
  ON UPDATE CASCADE
  ON DELETE RESTRICT
```

**Решение**: Связь между clothing_items и subcategory_specs через композитный внешний ключ.

**Почему**:
- Обеспечивает целостность данных
- Не позволяет использовать несуществующие подкатегории
- Автоматическая валидация при вставке/обновлении

## 2. Архитектура ML-сервиса

### 2.1. Приоритеты источников
```python
_SOURCE_MAP = {
    "synthetic": 0,  # lowest priority
    "partner": 1,
    "manual": 2,
    "user": 3,       # highest priority (wardrobe items)
}
```

**Решение**: Явное определение приоритетов источников с числовыми значениями.

**Почему**:
- Четко определенная иерархия источников
- Легко учитывается в ML-модели через признак source_priority
- Приоритеты можно легко изменить без изменения логики

### 2.2. Расширенные признаки
```python
# В features_v2_with_priorities.py
def prepare_item_features(item):
    # ... 
    # One-hot кодирование различных атрибутов
    "is_outerwear": is_outerwear,
    "is_upper": is_upper,
    "is_lower": is_lower,
    "is_footwear": is_footwear,
    "is_accessory": is_accessory,
    # ... другие one-hot признаки
    "source_priority": source_priority,  # приоритет источника для финального скоринга
```

**Решение**: Генерация расширенных признаков для ML-модели, включая source_priority.

**Почему**:
- Позволяет модели учитывать все аспекты вещи
- source_priority напрямую влияет на финальный скоринг
- One-hot кодирование улучшает производительность модели

## 3. Архитектура Go-сервиса

### 3.1. Интерфейсный подход
```go
type SubcategorySpecRepository interface {
    ListAll(ctx context.Context) ([]domain.SubcategorySpec, error)
    Get(ctx context.Context, category, subcategory string) (domain.SubcategorySpec, error)
}

type ClothingItemRepository interface {
    BulkInsert(ctx context.Context, items []domain.ClothingItem) error
    GetByID(ctx context.Context, id int64) (domain.ClothingItem, error)
    FindCandidatesByPlan(ctx context.Context, category string, subcategories []string, warmthMin int16, temp int16, limit int) ([]domain.ClothingItem, error)
}
```

**Решение**: Четко определенные интерфейсы для репозиториев.

**Почему**:
- Упрощает тестирование и замену реализаций
- Явно выражает контракты между слоями
- Облегчает масштабирование и поддержку

### 3.2. Валидация на уровне сервиса
```go
func (s *ClothingItemService) validateClothingItem(item domain.ClothingItem) error {
    // Check if the subcategory exists in specs
    _, err := s.specRepo.Get(context.Background(), item.Category, item.Subcategory)
    if err != nil {
        return fmt.Errorf("invalid category/subcategory combination: %s/%s", item.Category, item.Subcategory)
    }
    // ... другие проверки
}
```

**Решение**: Валидация на уровне сервиса с проверкой по нормам.

**Почему**:
- Обеспечивает согласованность данных
- Использует централизованные нормы из subcategory_specs
- Предотвращает вставку вещей с недопустимыми подкатегориями

## 4. Pipeline: Planner → Retrieval → Ranking

### 4.1. Генерация плана
```go
func (s *ClothingItemService) GenerateOutfitPlan(ctx context.Context, temperature float64, weatherCondition string) (map[string][]domain.SubcategorySpec, error) {
    // Использует нормы из subcategory_specs
    // Применяет фильтрацию по температуре и погодным условиям
}
```

**Решение**: Четкое разделение ответственности между Planner, Retrieval и Ranking.

**Почему**:
- Упрощает отладку и тестирование каждого компонента
- Позволяет оптимизировать каждый этап независимо
- Упрощает добавление новых этапов или изменение существующих

### 4.2. Поиск кандидатов по плану
```go
func (r *ClothingRepo) FindCandidatesByPlan(...) {
    const q = `
    SELECT ... FROM clothing_items
    WHERE category = $1
      AND subcategory = ANY($2::text[])
      AND warmth_level >= $3
      AND $4 BETWEEN min_temp AND max_temp
    ORDER BY warmth_level DESC, formality_level ASC, id ASC
    LIMIT $5;
    `
}
```

**Решение**: Эффективный SQL-запрос для поиска кандидатов по плану с использованием индексов.

**Почему**:
- Использует индексы для быстрого поиска
- Фильтрует по нескольким критериям одновременно
- Возвращает отсортированные результаты для более релевантного ранжирования