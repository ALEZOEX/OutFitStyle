# Импорт каталога и генерация рекомендаций

## Обзор

Этот документ описывает процесс импорта синтетического каталога вещей в PostgreSQL и автоматической генерации рекомендаций.

## Структура данных

### NDJSON формат

Файл `data/synthetic_catalog.ndjson` содержит 3000 синтетических записей в формате NDJSON (JSON Lines):

```json
{"id": -90000001, "name": "Носки бежевый", "category": "аксессуары", "subcategory": "носки", "color": "бежевый", ...}
```

**Поля:**
| Поле | Тип | Описание |
|------|-----|----------|
| id | int | Уникальный ID (отрицательный для synthetic) |
| name | string | Название вещи |
| category | string | Категория (верх/низ/обувь/аксессуары) |
| subcategory | string | Подкатегория |
| color | string | Цвет (на русском) |
| materials | array | Материалы |
| season | string | Сезон (зима/весна/лето/осень/всесезон) |
| brand | string | Бренд |
| min_temp, max_temp | int | Диапазон температур |
| warmth_level | int | Уровень тепла (1-100) |
| gender | string | Пол (male/female/unisex) |
| is_active | bool | Активность |

---

## Импорт каталога

### Вариант 1: Python скрипт (рекомендуется для разработки)

```bash
# Установка зависимостей
pip install psycopg2-binary

# Запуск импорта
python scripts/import_synthetic_catalog.py

# С опциями
python scripts/import_synthetic_catalog.py --file data/synthetic_catalog.ndjson --batch 500
```

**Переменные окружения:**
```bash
export DB_HOST=localhost
export DB_PORT=5433
export DB_NAME=outfitstyle
export DB_USER=postgres
export DB_PASSWORD=postgres
# или полный DSN
export DB_DSN="postgres://postgres:postgres@localhost:5433/outfitstyle?sslmode=disable"
```

### Вариант 2: Go скрипт (для продакшена)

```bash
cd server/scripts/import_catalog
go run main.go -file ../../data/synthetic_catalog.ndjson \
    -dsn "postgres://postgres:postgres@localhost:5433/outfitstyle?sslmode=disable" \
    -batch 300
```

### Идемпотентность

Оба скрипта поддерживают идемпотентность через `external_id`:
- Повторный запуск обновляет существующие записи
- Synthetic вещи получают отрицательный external_id
- Конфликты разрешаются через `ON CONFLICT DO UPDATE`

---

## Генерация рекомендаций

### ML сервис

ML сервис предоставляет API для генерации рекомендаций:

| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/api/rank` | POST | Ранжирование кандидатов |
| `/api/outfits` | POST | Генерация комплектов одежды |
| `/api/v1/rank` | POST | Расширенное ранжирование |

### Ручная генерация

```bash
bash scripts/regenerate_recommendations.sh --full
```

**Опции:**
- `--full` - перегенерировать для всех пользователей
- `--users USER_ID,...` - только для указанных пользователей
- `--batch-size N` - размер батча (по умолчанию: 100)

### Автоматическая генерация

#### Cron jobs

Установка cron jobs:
```bash
crontab scripts/cronjobs
```

**Расписание:**
| Задача | Расписание | Описание |
|--------|------------|----------|
| Импорт каталога | 03:00 воскресенье | Еженедельный переимпорт |
| Генерация рекомендаций | */6 * * * * | Каждые 6 часов |
| Полная перегенерация | 04:00 воскресенье | Для всех пользователей |
| Очистка логов | 05:00 ежедневно | Удаление логов > 30 дней |
| VACUUM ANALYZE | 05:00 ежедневно | Оптимизация БД |

#### Проверка cron
```bash
# Просмотр установленных jobs
crontab -l

# Просмотр логов
tail -f data/logs/regenerate_recommendations.log
```

---

## Хранение данных

### Таблицы БД

```
clothing_items          - Каталог вещей
├── external_id         - Уникальный ID для идемпотентности
├── category            - Категория (outerwear/upper/lower/footwear/accessory)
├── warmth_level        - Уровень тепла (1-10)
└── source              - Источник (synthetic/user/partner/manual)

subcategory_specs       - Спецификации подкатегорий
├── category, subcategory
├── warmth_min          - Мин. уровень тепла
└── temp_min_reco, temp_max_reco - Рекомендованный диапазон температур

recommendations         - Снимки рекомендаций
├── user_id             - Пользователь
├── outfit_score        - Общая оценка комплекта
└── ml_powered          - Использован ли ML

recommendation_items    - Элементы рекомендаций
├── recommendation_id   - Ссылка на рекомендацию
├── clothing_item_id    - Ссылка на вещь
├── score               - ML оценка
└── rank                - Позиция в рейтинге
```

### Логи

ML сервис логирует импрессии в JSONL файлы:
```
data/logs/
├── impressions_YYYY-MM-DD.jsonl  - Показы рекомендаций
└── actions_YYYY-MM-DD.jsonl      - Действия пользователей
```

---

## CI/CD интеграция

### GitHub Actions

В пайплайне `.github/workflows/ci-cd.yml`:

```yaml
- name: Validate synthetic catalog NDJSON
  run: |
    python -c "
    import json
    with open('data/synthetic_catalog.ndjson', 'r') as f:
        for line in f:
            json.loads(line)
    print('NDJSON validation passed')
    "
```

### Деплой

После деплоя на продакшен:
```bash
# 1. Импорт каталога
python scripts/import_synthetic_catalog.py

# 2. Установка cron jobs
crontab scripts/cronjobs

# 3. Проверка
crontab -l
tail -f data/logs/import_catalog.log
```

---

## Мониторинг

### Проверка статуса

```bash
# Количество вещей в каталоге
psql "$DB_DSN" -c "SELECT source, COUNT(*) FROM clothing_items GROUP BY source;"

# Последние рекомендации
psql "$DB_DSN" -c "SELECT user_id, created_at, ml_powered FROM recommendations ORDER BY created_at DESC LIMIT 10;"

# Здоровье сервисов
curl http://localhost:8080/healthz
curl http://localhost:8000/health
```

### Метрики

- Количество импортированных вещей
- Количество сгенерированных рекомендаций
- Время генерации (processing_time_ms)
- Ошибки ML сервиса

---

## Troubleshooting

### Ошибка: "relation subcategory_specs does not exist"
```bash
# Применить миграции
cd server && go run cmd/migrate/main.go up
```

### Ошибка: "duplicate key value violates unique constraint"
- Нормально при повторном запуске (upsert работает корректно)
- Проверьте логи на наличие реальных ошибок

### ML сервис недоступен
- Рекомендации генерируются без ML scoring
- Проверьте: `curl http://localhost:8000/health`
- Перезапустите: `docker-compose restart ml-service`

### Долгая генерация
- Уменьшите `BATCH_SIZE` в `scripts/regenerate_recommendations.sh`
- Увеличьте таймауты в ML сервисе
- Проверьте индексы в БД

---

## Безопасность

- Не коммитьте `.env` файлы с паролями
- Используйте secrets в CI/CD
- Ограничьте доступ к БД по сети
- Ротируйте логи с чувствительными данными
