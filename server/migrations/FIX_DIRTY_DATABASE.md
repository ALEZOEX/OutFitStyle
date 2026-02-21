# Исправление ошибки "Dirty database version 12"

## Проблема

При применении миграций через `golang-migrate` возникает ошибка:
```
Dirty database version 12. Fix and force version.
```

Это означает, что миграция `000012_performance_optimization` частично выполнилась:
- SQL-команды UP-миграции выполнились
- Но запись в таблицу `schema_migrations` не успела завершиться
- Флаг `dirty = true` остался установленным

## Причины

1. **Прерывание процесса**: Сервер перезагрузился или процесс миграции был убит во время выполнения
2. **Таймаут соединения**: Соединение с БД прервалось во время миграции
3. **Дублирование индексов**: Индексы `idx_recommendations_ml_powered`, `idx_recommendations_algorithm`, `idx_wardrobe_items_tags_gin` дублируются в миграциях 000012 и 000014

## Найденные проблемы в миграциях

### 1. Дублирование индексов между 000012 и 000014

| Индекс | 000012 | 000014 | Конфликт |
|--------|--------|--------|----------|
| `idx_recommendations_ml_powered` | `ON recommendations(ml_powered)` | `ON recommendations(ml_powered, created_at DESC) WHERE ml_powered = true` | **Разные определения** |
| `idx_recommendations_algorithm` | `ON recommendations(algorithm_used)` | `ON recommendations(algorithm_used)` | Одинаковые |
| `idx_wardrobe_items_tags_gin` | `ON wardrobe_items USING gin(tags)` | `ON wardrobe_items USING gin(tags)` | Одинаковые |

### 2. Отсутствие таблицы (проверено - есть в 000002)
- `recommendation_sessions` — существует, создана в миграции 000002

## Решение

### Вариант 1: Автоматическое исправление (рекомендуется)

Используйте подготовленный SQL-скрипт `FIX_DIRTY_000012.sql`:

```bash
# Подключиться к базе данных
psql -h localhost -U postgres -d outfitstyle -f server/migrations/FIX_DIRTY_000012.sql

# Или через Docker
docker-compose exec postgres psql -U postgres -d outfitstyle -f /migrations/FIX_DIRTY_000012.sql
```

Скрипт выполняет:
1. Сбрасывает флаг `dirty` для версии 12
2. Удаляет дублирующиеся индексы
3. Создаёт отсутствующие индексы из миграции 000012
4. Отмечает миграцию 12 как применённую

### Вариант 2: Ручное исправление через psql

```sql
-- 1. Проверить текущее состояние
SELECT version, dirty FROM schema_migrations ORDER BY version DESC LIMIT 1;

-- 2. Сбросить dirty флаг
UPDATE schema_migrations SET dirty = false WHERE version = 12 AND dirty = true;

-- 3. Удалить дублирующиеся индексы (будут созданы в 000014)
DROP INDEX IF EXISTS idx_recommendations_ml_powered;
DROP INDEX IF EXISTS idx_recommendations_algorithm;
DROP INDEX IF EXISTS idx_wardrobe_items_tags_gin;

-- 4. Применить миграцию 000012 через golang-migrate
migrate -path server/migrations -database "postgresql://user:pass@host:5432/dbname" up

-- ИЛИ пропустить версию 12 и перейти к 000013
migrate -path server/migrations -database "postgresql://user:pass@host:5432/dbname" force 12
migrate -path server/migrations -database "postgresql://user:pass@host:5432/dbname" up
```

### Вариант 3: Force version (если индексы уже созданы)

```bash
# Принудительно установить версию 12 как применённую
migrate -path server/migrations -database "postgresql://user:pass@host:5432/dbname" force 12

# Затем применить остальные миграции
migrate -path server/migrations -database "postgresql://user:pass@host:5432/dbname" up
```

### Вариант 4: Полная очистка (только для dev!)

```sql
-- ⚠️ ТОЛЬКО ДЛЯ РАЗРАБОТКИ! Удаляет все данные!
TRUNCATE schema_migrations;
DROP INDEX IF EXISTS idx_recommendations_ml_powered;
DROP INDEX IF EXISTS idx_recommendations_algorithm;
DROP INDEX IF EXISTS idx_wardrobe_items_tags_gin;
DROP INDEX IF EXISTS idx_clothing_items_owner_active;
DROP INDEX IF EXISTS idx_clothing_items_source_active;
DROP INDEX IF EXISTS idx_clothing_items_category_active;
DROP INDEX IF EXISTS idx_clothing_items_warmth_temp;
DROP INDEX IF EXISTS idx_wardrobe_items_user_active;
DROP INDEX IF EXISTS idx_wardrobe_items_clothing_user;
DROP INDEX IF EXISTS idx_recommendation_items_rec_cloth;
DROP INDEX IF EXISTS idx_recommendation_items_category;
DROP INDEX IF EXISTS idx_recommendation_sessions_user_model;
DROP INDEX IF EXISTS idx_clothing_items_materials_gin;

# Затем применить все миграции заново
migrate -path server/migrations -database "postgresql://user:pass@host:5432/dbname" up
```

## Проверка результата

```sql
-- 1. Проверить версию схемы
SELECT version, dirty FROM schema_migrations ORDER BY version DESC LIMIT 1;
-- Ожидаемый результат: version = последняя миграция, dirty = false

-- 2. Проверить индексы
SELECT 
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE indexname LIKE 'idx_%'
  AND tablename IN ('clothing_items', 'wardrobe_items', 'recommendations', 
                    'recommendation_items', 'recommendation_sessions')
ORDER BY tablename, indexname;

-- 3. Проверить что дублирующиеся индексы имеют правильное определение
-- idx_recommendations_ml_powered должен быть из 000014 (составной)
SELECT indexdef FROM pg_indexes WHERE indexname = 'idx_recommendations_ml_powered';
-- Ожидаемый результат: CREATE INDEX ... ON recommendations(ml_powered, created_at DESC) WHERE ml_powered = true
```

## Профилактика

1. **Используйте транзакции**: Убедитесь что миграции выполняются в транзакции
   ```bash
   migrate -path server/migrations -database "postgresql://..." -lock-timeout 300 up
   ```

2. **Настройте таймауты**: Увеличьте таймаут соединения для миграций
   ```bash
   export PGCONNECT_TIMEOUT=30
   ```

3. **Проверяйте дубликаты**: Перед добавлением индексов проверяйте существующие
   ```sql
   SELECT indexname FROM pg_indexes WHERE schemaname = 'public' ORDER BY indexname;
   ```

4. **Используйте IF NOT EXISTS**: Все CREATE INDEX должны использовать `IF NOT EXISTS`

## Откат

Если что-то пошло не так:

```sql
-- Вернуть dirty флаг (если нужно откатить миграцию)
UPDATE schema_migrations SET dirty = true WHERE version = 12;

-- Откатить миграцию 000012
migrate -path server/migrations -database "postgresql://..." down 000011

-- Или откатить все миграции после 000011
migrate -path server/migrations -database "postgresql://..." down 1
```

## Дополнительные ресурсы

- [golang-migrate documentation](https://github.com/golang-migrate/migrate)
- [PostgreSQL indexes documentation](https://www.postgresql.org/docs/current/indexes.html)
