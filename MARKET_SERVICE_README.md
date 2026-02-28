# Market Service - Инструкция по запуску

## 📋 Обзор

Реализован полноценный маркет-сервис для платформы OutfitStyle, позволяющий пользователям покупать одежду из рекомендаций.

## 🏗 Архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Market        │    │   PostgreSQL    │
│                 │◄──►│   Service       │◄──►│   (market DB)   │
│                 │    │   (FastAPI)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │    Redis        │
                       │  (cache/cart)   │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   ML Service    │
                       │ (recommendations)│
                       └─────────────────┘
```

## 📁 Структура проекта

```
outfitstyle/
├── market-service/              # Новый микросервис маркета
│   ├── api/
│   │   ├── main.py              # FastAPI приложение
│   │   └── routes/
│   │       ├── products.py      # Каталог товаров
│   │       ├── cart.py          # Корзина
│   │       ├── orders.py        # Заказы
│   │       └── recommendations.py # Рекомендации
│   ├── core/
│   │   └── config.py            # Конфигурация
│   ├── db/
│   │   ├── database.py          # DB подключение
│   │   └── models.py            # SQLAlchemy модели
│   ├── schemas/
│   │   └── schemas.py           # Pydantic схемы
│   ├── services/
│   │   ├── ml_integration.py    # ML интеграция
│   │   ├── payment_integration.py # Платежи
│   │   ├── api_integration.py   # API интеграция
│   │   └── redis_service.py     # Redis сервис
│   ├── alembic/
│   │   └── versions/            # Миграции БД
│   ├── scripts/
│   │   ├── seed_data.py         # Seed данные
│   │   └── generate_migration.py
│   ├── tests/
│   │   ├── conftest.py
│   │   ├── test_products.py
│   │   ├── test_cart.py
│   │   └── test_services.py
│   ├── Dockerfile
│   ├── Dockerfile.prod
│   ├── requirements.txt
│   ├── pytest.ini
│   └── README.md
│
├── client/lib/src/features/market/  # Flutter клиент
│   ├── data/
│   │   ├── models/
│   │   ├── market_api_client.dart
│   │   └── market_repository.dart
│   ├── domain/entities/
│   ├── presentation/providers/
│   ├── screens/
│   │   ├── market_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   └── orders_screen.dart
│   └── widgets/
│       ├── product_card.dart
│       ├── cart_item_card.dart
│       └── order_card.dart
│
├── k8s/market-service.yaml      # Kubernetes манифест
└── docker-compose.yml           # Обновлен с market-service
```

## 🚀 Быстрый старт

### Вариант 1: Docker Compose (рекомендуется)

```bash
# 1. Создать базу данных для market-service
docker-compose exec postgres psql -U postgres -c "CREATE DATABASE market;"

# 2. Применить миграции
docker-compose --profile market run --rm market-db-migrate

# 3. Запустить market-service
docker-compose --profile market up -d market-service

# 4. Заполнить тестовыми данными (опционально)
docker-compose --profile market exec market-service python scripts/seed_data.py

# 5. Проверить работу
curl http://localhost:8001/health
```

### Вариант 2: Локальная разработка

#### Предварительные требования

- Python 3.11+
- PostgreSQL 15+
- Redis 7+

#### Установка

```bash
cd market-service

# 1. Создать виртуальное окружение
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# 2. Установить зависимости
pip install -r requirements.txt

# 3. Создать базу данных
psql -U postgres -c "CREATE DATABASE market;"

# 4. Настроить окружение
cp .env.example .env
# Отредактировать .env при необходимости

# 5. Применить миграции
alembic upgrade head

# 6. Заполнить тестовыми данными
python scripts/seed_data.py

# 7. Запустить сервис
uvicorn api.main:app --reload --host 0.0.0.0 --port 8001
```

## 📡 API Endpoints

### Products (Товары)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/market/products` | Каталог товаров |
| GET | `/api/v1/market/products/{id}` | Детали товара |
| GET | `/api/v1/market/products/categories` | Категории |

**Пример запроса:**
```bash
curl http://localhost:8001/api/v1/market/products?category=top&page_size=10
```

### Cart (Корзина)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/market/cart` | Получить корзину |
| POST | `/api/v1/market/cart/items` | Добавить товар |
| PATCH | `/api/v1/market/cart/items/{id}` | Обновить количество |
| DELETE | `/api/v1/market/cart/items/{id}` | Удалить товар |
| DELETE | `/api/v1/market/cart` | Очистить корзину |

**Требуется заголовок:** `X-User-Id: <user_id>`

**Пример добавления в корзину:**
```bash
curl -X POST http://localhost:8001/api/v1/market/cart/items \
  -H "X-User-Id: 12345" \
  -H "Content-Type: application/json" \
  -d '{"product_id": "<uuid>", "size": "M", "quantity": 1}'
```

### Orders (Заказы)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/v1/market/orders` | Создать заказ |
| GET | `/api/v1/market/orders` | История заказов |
| GET | `/api/v1/market/orders/{id}` | Детали заказа |
| POST | `/api/v1/market/orders/{id}/cancel` | Отменить заказ |

### Recommendations (Рекомендации)

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/market/recommendations` | Персональные рекомендации |
| GET | `/api/v1/market/recommendations/similar/{id}` | Похожие товары |

### Product Import (Импорт товаров)

Импорт товаров с маркетплейсов Wildberries и Ozon по ссылке.

| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/v1/market/products/import` | Импортировать товар по URL |

**Требуется заголовок:** `X-User-Id: <user_id>`

**Поддерживаемые форматы URL:**
- `https://www.wildberries.ru/catalog/...`
- `https://www.ozon.ru/product/...`
- `wb/12345678` (короткая ссылка WB)
- `oz/12345678` (короткая ссылка Ozon)

**Лимиты:** 10 импортов в день на пользователя (настраивается через `PRODUCT_IMPORT_LIMIT_PER_DAY`)

**Пример запроса:**
```bash
curl -X POST http://localhost:8001/api/v1/market/products/import \
  -H "X-User-Id: 12345" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.wildberries.ru/catalog/12345678/detail.aspx"}'
```

**Пример ответа (успех):**
```json
{
  "status": "success",
  "product": {
    "id": "uuid",
    "name": "Футболка базовая",
    "brand": "BrandName",
    "price": 1500.00,
    "currency": "RUB",
    "category": "top",
    "image_urls": ["https://..."],
    "in_stock": true,
    "created_at": "2026-02-28T10:00:00",
    "updated_at": "2026-02-28T10:00:00"
  },
  "message": "Товар из wildberries успешно импортирован",
  "remaining_imports": 9
}
```

**Пример ответа (ошибка):**
```json
{
  "status": "error",
  "product": null,
  "message": "Неподдерживаемый маркетплейс. URL: https://example.com/...",
  "remaining_imports": 10
}
```

**Коды ошибок HTTP:**
- `400` — Некорректный URL или отсутствует заголовок X-User-Id
- `429` — Превышен лимит импортов
- `500` — Ошибка парсинга или сервера

## 🧪 Тестирование

```bash
cd market-service

# Запустить все тесты
pytest

# Запустить с покрытием
pytest --cov=api --cov=db --cov=services --cov-report=html

# Запустить конкретный тест
pytest tests/test_products.py -v
```

## 🔧 Конфигурация

### Переменные окружения

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `DATABASE_URL` | PostgreSQL URL | `postgresql://postgres:password@postgres:5432/market` |
| `REDIS_URL` | Redis URL | `redis://:password@redis:6379` |
| `ML_SERVICE_URL` | ML сервис URL | `http://ml-service:8000` |
| `API_SERVICE_URL` | Go API URL | `http://api:8080` |
| `PORT` | Порт сервиса | `8001` |
| `LOG_LEVEL` | Уровень логов | `INFO` |
| `PYRUSTSCRAPERAPI_TOKEN` | Токен для pyRustScraperApi | `None` (бесплатный доступ) |
| `PRODUCT_IMPORT_LIMIT_PER_DAY` | Лимит импортов в день | `10` |

### Получение токена pyRustScraperApi

Для парсинга товаров с Wildberries и Ozon используется библиотека `pyRustScraperApi`.

**Варианты:**

1. **Бесплатный тестовый доступ** — работает без токена с ограничениями
2. **Платный доступ** — получите токен на сайте [pyRustScraperApi](https://pyrustscraperapi.com/)

**Настройка:**
```bash
# В .env файле market-service
PYRUSTSCRAPERAPI_TOKEN=your_token_here
```

**Установка зависимости:**
```bash
pip install pyRustScraperApi beautifulsoup4
```

## 📦 Миграции БД

```bash
# Создать новую миграцию
alembic revision --autogenerate -m "Description"

# Применить все миграции
alembic upgrade head

# Откатить одну миграцию
alembic downgrade -1

# Откатить все миграции
alembic downgrade base
```

## 🚢 Развертывание

### Kubernetes

```bash
# Создать secret с credentials
kubectl create secret generic market-service-secrets \
  --from-literal=database-url='postgresql://...' \
  --from-literal=redis-url='redis://...' \
  -n outfitstyle

# Применить манифесты
kubectl apply -f k8s/market-service.yaml

# Проверить статус
kubectl get pods -n outfitstyle -l app=market-service
kubectl logs -n outfitstyle -l app=market-service
```

### Docker Compose (Production)

```bash
docker-compose -f docker-compose.prod.yml --profile market up -d market-service
```

## 🔍 Наблюдаемость

### Health Checks

- `GET /health` - Проверка здоровья
- `GET /ready` - Проверка готовности

### Swagger UI

Откройте http://localhost:8001/docs для интерактивной документации API.

### Логи

Структурированные JSON логи с полями:
- `timestamp`
- `level`
- `message`
- `request_id`
- `duration_ms`

## 🔐 Безопасность

- Все эндпоинты корзины/заказов требуют `X-User-Id` заголовок
- Валидация всех входных данных через Pydantic
- Параметризованные SQL запросы (защита от SQL injection)
- CORS настройка
- Rate limiting (настраивается)

## 🤝 Интеграция

### С ML Service

Market Service запрашивает рекомендации по категориям на основе погоды и предпочтений.

### С Go API

Проверка существования пользователей через основной API.

### С платежной системой

Интеграция с YooKassa (опционально, через `PAYMENT_ENABLED`).

## 📝 Seed данные

Скрипт `scripts/seed_data.py` создает 300+ тестовых товаров:

```bash
python scripts/seed_data.py
```

Товары включают:
- 6 категорий (top, bottom, shoes, accessories, outerwear, headwear)
- 10 брендов (Nike, Adidas, Zara, H&M, Uniqlo, etc.)
- Разные ценовые категории
- Разные стили и размеры

## ⚠️ Риски и откат

### Риски

1. **Отсутствие ML сервиса**: Рекомендации работают в fallback режиме
2. **Отсутствие Redis**: Кэширование отключено, корзина работает медленнее
3. **Блокировки БД**: Используется asyncpg с connection pool

### Откат

```bash
# Docker Compose
docker-compose --profile market down

# Kubernetes
kubectl delete -f k8s/market-service.yaml

# Откат миграций
alembic downgrade base
```

## 📄 Лицензия

MIT
