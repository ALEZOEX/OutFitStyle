# Запуск OutfitStyle Production-архитектуры (V2)

## Подготовка

1. Установите Docker и Docker Compose
2. Установите Go 1.24+ (если хотите запускать локально)
3. Установите Python 3.11+ для ML-сервиса

## Конфигурация

Создайте файл `.env` в корне проекта на основе `.env.example`:

```bash
cp .env.example .env
```

Заполните обязательные переменные:

- `DB_PASSWORD` - надежный пароль для PostgreSQL
- `JWT_SECRET` - секретный ключ для JWT (не менее 32 символов)
- `YANDEX_TRANSLATE_API_KEY` - ключ для Yandex Cloud Translate API
- `WEATHER_API_KEY` - ключ для OpenWeatherMap API

## Запуск с Docker Compose

1. Сначала выполните миграции базы данных:
   ```bash
   docker-compose run --rm api-gateway migrate
   ```

2. Затем запустите все сервисы:
   ```bash
   docker-compose up -d
   ```

3. API будет доступен на `http://localhost:8080`
   - Swagger UI: `http://localhost:8080/swagger/index.html`
   - Health check: `http://localhost:8080/health`

## Структура проекта

- `server/` - Go API Gateway (порт 8080)
- `server/ml-service/` - Python ML-ранжирование (порт 5000)
- `client/` - Flutter мобильное приложение
- `docs/` - документация
- `migrations/` - SQL миграции БД
- `contracts/` - контракты между сервисами

## Архитектура V2

Planner → Retrieval → Ranking pipeline:

1. **Planner** - генерирует план по подкатегориям с учетом норм
2. **Retrieval** - эффективно извлекает кандидатов из БД
3. **Ranking** - ML-ранжирование с учетом приоритетов источников

## Безопасность

- JWT-аутентификация и авторизация
- Пользователь может получить/изменить только свои данные
- Rate limiting для защиты от DDoS
- Защита от SQL-инъекций и XSS
- Кэширование переводов через Redis

## Сервис перевода

- Yandex Cloud Translate API с ключом `aje36hbuc3e2ntrh5e21`
- Кэширование через Redis на 24 часа
- Поддержка многоязычности с fallback

## API endpoints

- `/api/v1/auth/*` - аутентификация
- `/api/v1/recommendations/*` - рекомендации
- `/api/v1/clothing-items/*` - вещи
- `/api/v1/users/*` - пользователи
- `/health` - проверка состояния
- `/metrics` - Prometheus метрики
- `/swagger/*` - документация API

## Мониторинг

- Health checks для всех сервисов
- Логирование через Zap
- Prometheus метрики
- Structured logging

## Production-готовность

Проект полностью готов к production с архитектурой V2:
- Чистая структура кода
- Безопасность реализована
- ML-ранжирование интегрировано
- Переводы работают с кэшированием
- Надежные контракты между сервисами
- Контейнеризация с Docker