# Market Service - OutfitStyle

Сервис маркетплейса для платформы OutfitStyle. Предоставляет возможность покупки одежды из рекомендаций.

## 📋 Обзор

Market Service - это микросервис на FastAPI, который управляет:
- Каталогом товаров (products)
- Корзиной пользователя (cart)
- Заказами (orders)
- Персональными рекомендациями товаров

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

## 🚀 Быстрый старт

### Предварительные требования

- Python 3.11+
- PostgreSQL 15+
- Redis 7+
- Docker & Docker Compose (опционально)

### Локальная разработка

1. **Установка зависимостей**

```bash
cd market-service
pip install -r requirements.txt
```

2. **Настройка окружения**

```bash
cp .env.example .env
# Отредактируйте .env с вашими настройками
```

3. **Запуск миграций**

```bash
alembic upgrade head
```

4. **Заполнение тестовыми данными**

```bash
python scripts/seed_data.py
```

5. **Запуск сервиса**

```bash
uvicorn api.main:app --reload --host 0.0.0.0 --port 8001
```

6. **Проверка**

Откройте http://localhost:8001/docs для Swagger UI.

### Запуск через Docker Compose

```bash
# Запуск market-service с зависимостями
docker-compose --profile market up -d market-service

# Просмотр логов
docker-compose logs -f market-service
```

## 📡 API Endpoints

### Products

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/market/products` | Каталог товаров (с фильтрами) |
| GET | `/api/v1/market/products/{id}` | Детали товара |
| GET | `/api/v1/market/products/categories` | Список категорий |

### Cart

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/market/cart` | Корзина пользователя |
| POST | `/api/v1/market/cart/items` | Добавить в корзину |
| PATCH | `/api/v1/market/cart/items/{id}` | Обновить количество |
| DELETE | `/api/v1/market/cart/items/{id}` | Удалить из корзины |
| DELETE | `/api/v1/market/cart` | Очистить корзину |

### Orders

| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/v1/market/orders` | Создать заказ |
| GET | `/api/v1/market/orders` | История заказов |
| GET | `/api/v1/market/orders/{id}` | Детали заказа |
| POST | `/api/v1/market/orders/{id}/cancel` | Отменить заказ |

### Recommendations

| Метод | Endpoint | Описание |
|-------|----------|----------|
| GET | `/api/v1/market/recommendations` | Персональные рекомендации |
| GET | `/api/v1/market/recommendations/similar/{id}` | Похожие товары |

## 🔧 Конфигурация

### Переменные окружения

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `DATABASE_URL` | URL подключения к PostgreSQL | `postgresql://postgres:password@localhost:5432/market` |
| `REDIS_URL` | URL подключения к Redis | `redis://localhost:6379` |
| `ML_SERVICE_URL` | URL ML сервиса | `http://localhost:8000` |
| `API_SERVICE_URL` | URL основного API | `http://localhost:8080` |
| `LOG_LEVEL` | Уровень логирования | `INFO` |
| `PORT` | Порт сервиса | `8001` |

## 🧪 Тестирование

```bash
# Запуск тестов
pytest

# Запуск с покрытием
pytest --cov=api --cov=db --cov=services

# Запуск конкретного теста
pytest tests/test_products.py -v
```

## 📦 Миграции

```bash
# Создать новую миграцию
alembic revision --autogenerate -m "Description"

# Применить миграции
alembic upgrade head

# Откатить миграцию
alembic downgrade -1
```

## 🔍 Наблюдаемость

### Health Checks

- `/health` - Проверка здоровья сервиса
- `/ready` - Проверка готовности

### Метрики

- `/metrics` - Prometheus метрики (TODO)

### Логи

Структурированные JSON логи с полями:
- `timestamp`
- `level`
- `message`
- `request_id`
- `duration_ms`

## 🚢 Развертывание

### Kubernetes

```bash
# Применить манифесты
kubectl apply -f k8s/market-service.yaml

# Проверить статус
kubectl get pods -n outfitstyle -l app=market-service
```

## 🔐 Безопасность

- Все эндпоинты требуют заголовок `X-User-Id`
- Валидация всех входных данных
- Rate limiting (настраивается)
- CORS настройка

## 📝 Структура проекта

```
market-service/
├── api/
│   ├── main.py              # FastAPI приложение
│   └── routes/
│       ├── products.py      # Products endpoints
│       ├── cart.py          # Cart endpoints
│       ├── orders.py        # Orders endpoints
│       └── recommendations.py # Recommendations endpoints
├── core/
│   └── config.py            # Конфигурация
├── db/
│   ├── database.py          # DB подключение
│   └── models.py            # SQLAlchemy модели
├── schemas/
│   └── schemas.py           # Pydantic схемы
├── services/
│   ├── ml_integration.py    # ML сервис интеграция
│   ├── payment_integration.py # Payment интеграция
│   ├── api_integration.py   # API интеграция
│   └── redis_service.py     # Redis сервис
├── alembic/
│   └── versions/            # Миграции
├── scripts/
│   ├── seed_data.py         # Seed данные
│   └── generate_migration.py # Генерация миграций
├── tests/
│   ├── conftest.py          # Fixtures
│   ├── test_products.py     # Products тесты
│   ├── test_cart.py         # Cart тесты
│   └── test_services.py     # Services тесты
├── Dockerfile
├── Dockerfile.prod
├── requirements.txt
└── pytest.ini
```

## 🤝 Интеграция

### С ML Service

Market Service запрашивает у ML Service рекомендации по категориям на основе:
- Погоды
- Предпочтений пользователя
- Контекста

### С основным API

Проверка существования пользователей через Go API.

### С платежной системой

Интеграция с YooKassa для обработки платежей (опционально).

## 📄 Лицензия

MIT
