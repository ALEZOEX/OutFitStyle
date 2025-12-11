# Профессиональная архитектура OutfitStyle

## Обзор

OutfitStyle реализует продвинутую архитектуру с единой моделью вещей и системой Retrieval + Ranking для подбора рекомендаций. 

## Продовый подход: единая модель вещей → Retrieval → Ranking

### Цели архитектуры
- Единый каталог вещей в Postgres с различными источниками:
  - Реальные вещи гардероба пользователя
  - Вещи из интернет-каталога/парсинга
  - "Образцовые" Kaggle-вещи
- Приоритеты источников:
  - Личный гардероб (если по погоде подходит)
  - Реальные новые вещи (catalog/marketplace)
  - Kaggle seed как "учебный магазин"
- Retrieval (подбор кандидатов): быстрый SQL/правила по погоде, полу, стилю, сезону и источнику
- Ranking (ML-модель): ранжирует и комбинирует уже малое число кандидатов (до 500–1000, а не 44k)
- Никаких таймаутов/404 от ML, никакого "ручного затыкания дыр"

## Структура БД

### clothing_items
Расширенная таблица с атрибутами:
- `gender`, `master_category`, `subcategory`, `season`, `base_colour`, `usage`
- `source` ('wardrobe', 'catalog', 'kaggle_seed', ...)
- `is_owned`, `owner_user_id`
- `min_temp`, `max_temp`, `warmth_level`, `formality_level`

### wardrobe_items
Связь между пользователями и их личными вещами:
- `user_id`, `clothing_item_id`

## ML-ранжирование: приоритеты источников

### При подготовке фичей
- One-hot/label-encoding для `source` (wardrobe, catalog, kaggle_seed)
- Бинарный признак `is_owned`

### При финальном скоринге
- +α к score, если `is_owned = True` и вещь подходит по погоде
- Чуть меньший приоритет для catalog по сравнению с wardrobe
- Kaggle_seed — базовая линия (0)

## Go-бэкенд: упрощённый ML-клиент

- ML-сервис теперь всегда работает через `clothing_items`, никаких CSV/404/таймаутов на 40 секунд
- Убраны почти все костыли в `RecommendationService.GetRecommendations`
- Теперь все рекомендации сохраняются в БД, так как все вещи из базы данных

## Flutter: нормальная обработка источников

### Модель ClothingItem
Обновлена для парсинга всех новых полей:
```dart
class ClothingItem {
  final int id;
  final String name;
  final String category;
  final String? subcategory;
  final String source;   // 'wardrobe', 'catalog', 'kaggle_seed'
  final bool isOwned;
  final double? minTemp;
  final double? maxTemp;
  final int warmthLevel;
  final int formalityLevel;
  final String iconEmoji;
  // ...
}
```

### Визуальное разделение в UI
- "Что из твоего гардероба" (isOwned == true)
- "Что стоит докупить" (isOwned == false и source != 'kaggle_seed')
- "Образцовые варианты" (source == 'kaggle_seed')

### Пустой список
Если items.isEmpty → показываем "нет вещей, добавь одежду в гардероб"

## Преимущества подхода

1. **Профессиональный**: 
   - Единая схема
   - Чёткое разделение Retrieval/Ranking
   - Предсказуемые таймауты
   - Приоритеты источников

2. **Гибкий**:
   - Можно добавлять реальные вещи, парсеры
   - Менять веса без ломки архитектуры

3. **Учитывает сценарии**:
   - Бедный/непосезонный гардероб
   - Комбинирование Wardrobe + Catalog + Kaggle
   - Сохранение разнообразия и "крутости" рекомендаций за счёт десятков тысяч seed-вещей