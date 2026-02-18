# Документация по API OutfitStyle

## Базовый URL

```
https://api.outfitstyle.app
```

## Аутентификация

Все запросы к API требуют аутентификации с помощью JWT-токена в заголовке Authorization:

```
Authorization: Bearer <jwt_token>
```

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

### Гардероб

#### GET /api/v1/wardrobe
Получить элементы гардероба пользователя

**Параметры запроса:**
- `page` (необязательно): Номер страницы (по умолчанию: 1)
- `limit` (необязательно): Элементов на странице (по умолчанию: 20, максимум: 100)

**Ответ:**
```json
{
  "items": [
    {
      "id": "item_id",
      "name": "Синяя футболка",
      "category": "top",
      "color": "blue",
      "warmth_level": 2,
      "style": "casual",
      "formality_level": 2,
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
  "category": "top",
  "color": "blue",
  "warmth_level": 2,
  "style": "casual",
  "formality_level": 2,
  "image_url": "https://example.com/image.jpg"
}
```

**Ответ:**
```json
{
  "item": {
    "id": "item_id",
    "name": "Синяя футболка",
    "category": "top",
    "color": "blue",
    "warmth_level": 2,
    "style": "casual",
    "formality_level": 2,
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
      "items": ["item_id_1", "item_id_2"],
      "score": 0.95,
      "reason": "Идеально для солнечной погоды",
      "occasion": "daily",
      "weather_condition": "sunny",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 5,
  "page": 1,
  "limit": 20
}
```

#### POST /api/v1/recommendations
Сгенерировать новые рекомендации

**Тело запроса:**
```json
{
  "occasion": "daily",
  "latitude": 55.7558,
  "longitude": 37.6176
}
```

**Ответ:**
```json
{
  "recommendation": {
    "id": "rec_id",
    "items": ["item_id_1", "item_id_2"],
    "score": 0.95,
    "reason": "Идеально для солнечной погоды",
    "occasion": "daily",
    "weather_condition": "sunny",
    "created_at": "2024-01-15T10:30:00Z"
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
    "preferred_categories": ["top", "bottom"],
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
  "preferred_categories": ["top", "bottom"],
  "temperature_sensitivity": 2
}
```

**Ответ:**
```json
{
  "preferences": {
    "preferred_styles": ["casual", "smart casual"],
    "avoid_styles": ["formal"],
    "color_preferences": ["blue", "black"],
    "avoid_colors": ["orange"],
    "preferred_categories": ["top", "bottom"],
    "temperature_sensitivity": 2
  }
}
```

## Ответы об ошибках

Все ответы об ошибках следуют следующему формату:

```json
{
  "error": "error_message",
  "details": "detailed_error_description"
}
```

### Общие HTTP-статусы

- `200 OK` - Запрос выполнен успешно
- `400 Bad Request` - Неверный формат запроса
- `401 Unauthorized` - Требуется аутентификация
- `403 Forbidden` - Доступ запрещен
- `404 Not Found` - Ресурс не найден
- `429 Too Many Requests` - Превышено ограничение на количество запросов
- `500 Internal Server Error` - Ошибка сервера

## Ограничение частоты запросов

Все аутентифицированные конечные точки имеют ограничение частоты:
- 100 запросов в минуту на пользователя
- 1000 запросов в минуту на IP-адрес (для неаутентифицированных)

## Проверка работоспособности

#### GET /health
Проверить работоспособность сервиса

**Ответ:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00Z",
  "checks": {
    "database": {
      "status": "healthy",
      "latency": "10ms"
    },
    "ml_service": {
      "status": "healthy",
      "latency": "50ms"
    }
  }
}
```

#### GET /ready
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