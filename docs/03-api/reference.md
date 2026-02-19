# Документация по API OutfitStyle

## Базовый URL

```
# Development
http://localhost:8080

# Production
https://api.outfitstyle.app
```

## Аутентификация

Все запросы к API требуют аутентификации с помощью JWT-токена в заголовке Authorization:

```
Authorization: Bearer <jwt_token>
```

### Типы токенов

- **Access Token** — короткоживущий токен (15 минут)
- **Refresh Token** — долгоживущий токен (30 дней) для обновления access token

## Конечные точки

### Аутентификация

#### POST /api/v1/auth/google
Аутентификация с помощью аккаунта Google

**Тело запроса:**
```json
{
  "id_token": "google_id_token"
}
```

**Ответ:**
```json
{
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "access_token": "jwt_access_token",
  "refresh_token": "jwt_refresh_token"
}
```

#### POST /api/v1/auth/refresh
Обновление access токена

**Тело запроса:**
```json
{
  "refresh_token": "jwt_refresh_token"
}
```

**Ответ:**
```json
{
  "access_token": "new_jwt_access_token",
  "refresh_token": "new_jwt_refresh_token"
}
```

#### POST /api/v1/auth/logout
Выход из системы

**Заголовки:**
```
Authorization: Bearer <jwt_token>
```

**Ответ:**
```json
{
  "success": true
}
```

### Гардероб

#### GET /api/v1/wardrobe
Получить элементы гардероба пользователя

**Параметры запроса:**
- `page` (необязательно): Номер страницы (по умолчанию: 1)
- `limit` (необязательно): Элементов на странице (по умолчанию: 20, максимум: 100)
- `category` (необязательно): Фильтр по категории

**Ответ:**
```json
{
  "items": [
    {
      "id": 123,
      "name": "Синяя футболка",
      "category": "upper",
      "subcategory": "tshirt",
      "color": "blue",
      "warmth_level": 2,
      "formality_level": 2,
      "season": "summer",
      "source": "user",
      "is_owned": true,
      "image_url": "https://example.com/image.jpg",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 15,
  "page": 1,
  "limit": 20
}
```

#### POST /api/v1/wardrobe
Добавить новый элемент гардероба

**Тело запроса:**
```json
{
  "name": "Синяя футболка",
  "category": "upper",
  "subcategory": "tshirt",
  "color": "blue",
  "warmth_level": 2,
  "formality_level": 2,
  "season": "summer",
  "image_url": "https://example.com/image.jpg"
}
```

**Ответ:**
```json
{
  "item": {
    "id": 123,
    "name": "Синяя футболка",
    "category": "upper",
    "subcategory": "tshirt",
    "color": "blue",
    "warmth_level": 2,
    "formality_level": 2,
    "season": "summer",
    "source": "user",
    "is_owned": true,
    "image_url": "https://example.com/image.jpg",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### DELETE /api/v1/wardrobe/{item_id}
Удалить элемент гардероба

**Ответ:**
```json
{
  "success": true
}
```

### Рекомендации

#### GET /api/v1/recommendations
Получить историю рекомендаций

**Параметры запроса:**
- `page` (необязательно): Номер страницы (по умолчанию: 1)
- `limit` (необязательно): Элементов на странице (по умолчанию: 20, максимум: 100)

**Ответ:**
```json
{
  "recommendations": [
    {
      "id": "rec_id",
      "items": [
        {
          "id": 123,
          "name": "Футболка",
          "category": "upper",
          "score": 0.95
        },
        {
          "id": 456,
          "name": "Джинсы",
          "category": "lower",
          "score": 0.92
        }
      ],
      "total_score": 0.93,
      "weather": {
        "temperature": 20,
        "condition": "sunny"
      },
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 5,
  "page": 1,
  "limit": 20
}
```

#### POST /api/v1/recommendations/generate
Сгенерировать новые рекомендации

**Тело запроса:**
```json
{
  "latitude": 55.7558,
  "longitude": 37.6176,
  "occasion": "daily"
}
```

**Ответ:**
```json
{
  "recommendation": {
    "id": "rec_id",
    "items": [
      {
        "id": 123,
        "name": "Футболка",
        "category": "upper",
        "score": 0.95
      }
    ],
    "total_score": 0.93,
    "weather": {
      "temperature": 20,
      "condition": "sunny"
    },
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### Подписки

#### GET /api/v1/subscription/plans
Получить список планов подписок

**Ответ:**
```json
{
  "plans": [
    {
      "id": "free",
      "name": "Free",
      "price_monthly": 0,
      "price_yearly": 0,
      "features": {
        "recommendations_per_day": 3,
        "wardrobe_items": 50,
        "history_days": 7
      }
    },
    {
      "id": "premium",
      "name": "Premium",
      "price_monthly": 299,
      "price_yearly": 2990,
      "features": {
        "recommendations_per_day": 20,
        "wardrobe_items": 500,
        "history_days": 90
      }
    }
  ]
}
```

#### GET /api/v1/subscription/current
Получить текущую подписку пользователя

**Ответ:**
```json
{
  "subscription": {
    "plan_id": "premium",
    "status": "active",
    "started_at": "2024-01-01T00:00:00Z",
    "ends_at": "2024-02-01T00:00:00Z",
    "trial_ends_at": null
  }
}
```

### Предпочтения пользователя

#### GET /api/v1/preferences
Получить предпочтения пользователя

**Ответ:**
```json
{
  "preferences": {
    "preferred_styles": ["casual", "smart casual"],
    "avoid_styles": ["formal"],
    "color_preferences": ["blue", "black"],
    "avoid_colors": ["orange"],
    "temperature_sensitivity": 2
  }
}
```

#### PUT /api/v1/preferences
Обновить предпочтения пользователя

**Тело запроса:**
```json
{
  "preferred_styles": ["casual", "smart casual"],
  "avoid_styles": ["formal"],
  "color_preferences": ["blue", "black"],
  "avoid_colors": ["orange"],
  "temperature_sensitivity": 2
}
```

### Погода

#### GET /api/v1/weather/current
Получить текущую погоду

**Параметры запроса:**
- `latitude`: Широта
- `longitude`: Долгота

**Ответ:**
```json
{
  "temperature": 20.5,
  "feels_like": 19.2,
  "condition": "sunny",
  "humidity": 65,
  "wind_speed": 3.5,
  "updated_at": "2024-01-15T10:30:00Z"
}
```

## Ответы об ошибках

Все ответы об ошибках следуют следующему формату:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Человекочитаемое описание ошибки",
    "details": {}
  }
}
```

### Коды ошибок

| Код | HTTP статус | Описание |
|-----|-------------|----------|
| `INVALID_ARGUMENT` | 400 | Неверный формат запроса |
| `UNAUTHENTICATED` | 401 | Требуется аутентификация |
| `PERMISSION_DENIED` | 403 | Доступ запрещен |
| `NOT_FOUND` | 404 | Ресурс не найден |
| `ALREADY_EXISTS` | 409 | Ресурс уже существует |
| `RESOURCE_EXHAUSTED` | 429 | Превышено ограничение на количество запросов |
| `INTERNAL` | 500 | Внутренняя ошибка сервера |
| `UNAVAILABLE` | 503 | Сервис недоступен |

## Ограничение частоты запросов (Rate Limiting)

Все аутентифицированные конечные точки имеют ограничение частоты:
- 100 запросов в минуту на пользователя
- 1000 запросов в минуту на IP-адрес (для неаутентифицированных)

Заголовки rate limiting:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642234567
```

## Проверка работоспособности

#### GET /api/health
Проверить работоспособность сервиса

**Ответ:**
```json
{
  "status": "healthy",
  "version": "2.0.0",
  "timestamp": "2024-01-15T10:30:00Z",
  "checks": {
    "database": {
      "status": "healthy",
      "latency_ms": 10
    },
    "redis": {
      "status": "healthy",
      "latency_ms": 2
    },
    "ml_service": {
      "status": "healthy",
      "latency_ms": 50
    }
  }
}
```

#### GET /api/ready
Проверить готовность сервиса к работе

**Ответ:**
```json
{
  "status": "ready",
  "ready": true
}
```

## Метрики

#### GET /metrics
Конечная точка метрик Prometheus

Возвращает метрики в формате Prometheus для мониторинга и оповещения.

## Swagger документация

Интерактивная документация API доступна по адресу:
- Development: http://localhost:8080/swagger
- Production: https://api.outfitstyle.app/swagger

---

**Обновлено:** Февраль 2026