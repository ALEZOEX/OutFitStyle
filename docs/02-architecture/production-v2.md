# Производственная архитектура OutfitStyle V2

## Фаза 0: Контракты и границы ответственности

### 0.1 Контракт Go ↔ ML

**Решение**: ML-сервис — только ранжирование. Он не ходит в Postgres в рантайме.

#### Формат взаимодействия

**POST /api/rank**

Request:
```json
{
  "context": {
    "weather": {
      "temperature": 15.5,
      "feels_like": 13.2,
      "humidity": 70,
      "wind_speed": 5.0,
      "weather": "clouds"
    },
    "user_profile": {
      "age_range": "25-35",
      "style_preference": "casual",
      "temperature_sensitivity": "normal",
      "formality_preference": "informal",
      "gender": "unisex"
    },
    "preferences": {},
    "location": "Moscow"
  },
  "candidates": [
    {
      "id": 123,
      "name": "casual tshirt",
      "category": "upper",
      "subcategory": "tshirt",
      "gender": "unisex",
      "style": "casual",
      "usage": "daily",
      "season": "summer",
      "base_colour": "white",
      "formality": 2,
      "warmth": 1,
      "min_temp": 15,
      "max_temp": 30,
      "materials": ["cotton"],
      "fit": "regular",
      "pattern": "solid",
      "icon_emoji": "👕",
      "source": "synthetic",
      "is_owned": false,
      "created_at": "2023-12-12T10:00:00Z",
      "source_priority": 0
    }
  ]
}
```

Response:
```json
{
  "ranked": [
    {
      "id": 123,
      "score": 0.85
    }
  ],
  "model_version": "v1.2.3",
  "processing_time_ms": 150.5,
  "error": null
}
```

#### Ограничения
- Максимум кандидатов в одном вызове ML: 250
- Максимальный размер тела запроса: 10MB
- Таймаут Go → ML: 800мс
- Time budget: если уже потрачено > 400мс, ML не вызывается
- Circuit breaker: 20 ошибок подряд → переключение в состояние "open" на 30 сек

#### Критерий готовности
Go может отправить 200 кандидатов и получить ответ < 1000мс p95 локально/в стенде.

## Фаза 1: Данные и БД

### 1.1 Санити-валидация каталога перед импортом

**Решение**: Скрипт валидации `scripts/validate_catalog.py` с проверками:
- category/subcategory строго по словарю
- min_temp<=max_temp, уровни в диапазонах [1,5] для formality, [1,10] для warmth
- materials только из словаря
- распределение по категориям

**Импорт**: `scripts/import_catalog_fast.py` с использованием COPY/pgx.CopyFrom для быстрого импорта 20k–100k строк.

### 1.2 Миграции и схема

Миграция: `server/migrations/0001_init_schema.sql`

#### Проверки и ограничения:
- CHECK constraints (диапазоны уровней, min_temp<=max_temp, enum-поля)
- FK на словарь подкатегорий/норм
- Индексы под retrieval:
  - (category, subcategory)
  - (category, warmth_level)
  - (min_temp, max_temp)

#### ML-оценки больше НЕ хранятся в clothing_items:
- ✅ Удалено поле ml_score из clothing_items (ошибка исправлена)
- ✅ ML-оценки хранятся в recommendation_items(score, rank, context_hash, model_version, created_at)

### 1.3 События для будущего обучения

#### Новые таблицы в миграции `server/migrations/0002_add_recommendation_items.sql`:
- recommendation_sessions: контекст рекомендаций с хэшем, версией модели
- recommendation_items: состав рекомендаций с оценками и рангами
- indexes: для эффективного поиска по recommendation_id, clothing_item_id, score, rank

### 1.4 Оптимизация индексов и планов запросов

**Решение**: Скрипт анализа `scripts/analyze_query_plan.py` для:
- EXPLAIN ANALYZE основных retrieval-запросов
- предложения индексов на основе плана запроса
- проверки существующих индексов

## Фаза 2: Go: Planner и Retrieval

### 2.1 Planner: кэш норм + детерминизм

**Решение**:
- Кэширование норм subcategory_specs в памяти с TTL
- Unit-тесты на детерминированность плана
- Planner возвращает одинаковый план для одинакового входа

### 2.2 Формирование кандидатов и pre-rank сортировка

**Решение**: Скрипт `scripts/pre_rank_filter.py` для:
- Предварительной фильтрации кандидатов по температуре, формальности и использованию
- Предварительной оценки и сортировки до ML (pre-rank)
- Ограничения количества кандидатов до ML (max_candidates: 250)

### 2.3 Клиент ML: circuit breaker + бюджеты времени

**Решение**: Обновленный `server/internal/infrastructure/clients/ml_client.go` с:
- Circuit breaker (20 ошибок → 30сек таймаут)
- Time budget (не вызывать ML если уже потрачено > 400мс)
- Обновленный retry mechanism с учётом новых ограничений

## Фаза 3: ML-сервис

### 3.1 Воспроизводимость и версионирование

**Решение**:
- Артефакты модели в `ml-service/artifacts/`:
  - model.pkl
  - scaler.pkl (для нормализации)
  - metadata.json (версия, дата, метрики)
- ML-сервис загружает артефакты при старте
- `/ready` endpoint только после успешной загрузки

### 3.2 Training pipeline

**Решение**: Скрипт `ml-service/train/train_ranker.py` для:
- Генерации синтетических обучающих данных
- Тренировки модели с сохранением артефактов
- Обновления при появлении реальных фидбэков

## Фаза 4: Наблюдаемость

### 4.1 Трассировка и метрики

**Решение**:
- request_id: передача из Go в ML для сквозной трассировки
- Prometheus метрики: латентность, ошибки, batch_size, model_version
- OpenTelemetry трейсинг (минимум: Go→ML span)

## Фаза 5: Безопасность

### 5.1 Rate limiting и защита

**Решение**:
- Rate limiting в Go (Redis-based): per user-id и per IP
- Ограничение payload и количества кандидатов
- Правильное управление секретами
- Читает нормы из subcategory_specs
- Выход: план по категориям (подкатегории + требования)

### 2.2 Retrieval
- Запрос "кандидаты по плану"
- Лимит: 20-30 кандидатов на категорию (максимум 200)
- Сортировка: температура + источник

### 2.3 ML вызов с fallback
- Таймаут 800-900мс
- Retry на сетевые ошибки
- Fallback на rule-based ранжирование

## Фаза 3: ML-сервис

### 3.1 API
- /api/rank: основной endpoint
- /health, /ready: для проверки состояния
- /metrics: для мониторинга

### 3.2 Feature pipeline
- Единый pipeline для train и inference
- Multi-hot encoding для материалов
- Source priority как признак

### 3.3 Performance
- Батч-скоринг: вся выборка за один вызов
- Модель кэшируется при старте
- Метрики и логирование

## Фаза 4: Наблюдаемость

### 4.1 Метрики
- Prometheus: latency, throughput, error rates
- Model version tracking
- Batch size metrics

### 4.2 Логи
- Request ID для трейсинга
- Структурированные логи (Zap/structlog)
- Отслеживание SLA

## Фаза 5: Безопасность

### 5.1 Аутентификация
- JWT токены
- Refresh/Access токены
- Проверка подписи

### 5.2 Rate limiting
- Redis-based ограничения
- По user-id и IP
- Защита от DoS

## Фаза 6: Отказоустойчивость

### 6.1 Бэкап
- pgBackRest или WAL-G
- Расписание и восстановление

### 6.2 Пул соединений
- PgBouncer
- Лимиты в приложениях

## Фаза 7: CI/CD

### 7.1 GitHub Actions
- Линтинг и тесты
- Сборка Docker образов
- Миграции в CI

### 7.2 Контрактные тесты
- Golden JSON тесты
- Проверка совместимости

## Фаза 8: Нагрузочное тестирование

### 8.1 Инструменты
- k6 для нагрузки
- Тесты на разных сценариях
- SLA проверки