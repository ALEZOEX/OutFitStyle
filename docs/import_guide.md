# Руководство по импорту данных Kaggle

## Подготовка

1. Убедитесь, что файл `styles.csv` находится в `server/ml-service/data/raw/`

2. Установите Python зависимости:
```bash
pip install -r scripts/requirements.txt
```

3. Убедитесь, что база данных запущена и доступна

4. Создайте файл `.env` в директории `scripts/` с настройками подключения к базе данных:
```
DB_HOST=localhost
DB_NAME=outfitstyle
DB_USER=admin
DB_PASSWORD=admin123
DB_PORT=5432
```

## Запуск миграций

Прежде чем запускать импорт, убедитесь, что применены все миграции:

```bash
# Применение миграций (пример для PostgreSQL)
psql -h localhost -U admin -d outfitstyle -f server/migrations/001_initial_schema.up.sql
psql -h localhost -U admin -d outfitstyle -f server/migrations/002_expand_clothing_schema.up.sql
psql -h localhost -U admin -d outfitstyle -f server/migrations/003_add_ml_attributes.up.sql
```

## Запуск скрипта импорта

```bash
cd scripts
python import_kaggle_styles.py
```

## Проверка импорта

После выполнения скрипта можно проверить, что данные импортированы:

```sql
SELECT source, COUNT(*) FROM clothing_items GROUP BY source;
```

Должны появиться записи с `source = 'kaggle_seed'`.

## Дальнейшие действия

После импорта данных:

1. ML-сервис теперь будет использовать `kaggle_seed` вещи через систему Retrieval
2. Файл `styles.csv` больше не используется в рантайме
3. Можно запустить ML-сервис с новой архитектурой