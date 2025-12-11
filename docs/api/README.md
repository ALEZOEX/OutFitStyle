# API документация OutfitStyle

## Введение

API OutfitStyle предоставляет следующие основные функции:
- Аутентификация и регистрация пользователей
- Подбор рекомендаций одежды на основе погоды
- Управление личным гардеробом
- Работа с рекомендациями

## Базовый URL

`/api/v1/`

## Аутентификация

Для аутентифицированных запросов используйте заголовок:

```
Authorization: Bearer <access_token>
```

## Эндпоинты

### Аутентификация

#### POST /auth/register
Регистрация нового пользователя

**Тело запроса:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "username": "username"
}
```

#### POST /auth/login
Вход пользователя

**Тело запроса:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

#### POST /auth/verify
Подтверждение кода

**Тело запроса:**
```json
{
  "code": "123456"
}
```

#### POST /auth/forgot-password
Запрос на восстановление пароля

**Тело запроса:**
```json
{
  "email": "user@example.com"
}
```

#### POST /auth/reset-password
Сброс пароля

**Тело запроса:**
```json
{
  "token": "reset_token",
  "newPassword": "newPassword123"
}
```

#### POST /auth/google
Вход через Google

**Тело запроса:**
```json
{
  "idToken": "google_id_token"
}
```

### Рекомендации

#### GET /recommendations
Получить рекомендации одежды

**Параметры:**
- `city` (обязательный) - город
- `user_id` (обязательный) - ID пользователя
- `source` (опциональный) - источник вещей (wardrobe, catalog, mixed)

**Пример:**
```
GET /recommendations?city=Moscow&user_id=1&source=mixed
```

#### GET /recommendations/history
Получить историю рекомендаций

**Параметры:**
- `user_id` (обязательный) - ID пользователя
- `limit` (опциональный) - количество рекомендаций (по умолчанию 10)

#### POST /recommendations/{id}/rate
Оценить рекомендацию

**Тело запроса:**
```json
{
  "user_id": 1,
  "rating": 5,
  "feedback": "Отличный образ!"
}
```

#### POST /recommendations/{id}/favorite
Добавить в избранное

**Тело запроса:**
```json
{
  "user_id": 1
}
```

#### DELETE /recommendations/{id}/favorite
Удалить из избранного

**Тело запроса:**
```json
{
  "user_id": 1
}
```

### Пользователь

#### GET /users/{id}/profile
Получить профиль пользователя

#### PUT /users/{id}/profile
Обновить профиль пользователя

#### GET /users/{id}/outfit-plans
Получить планы образов пользователя

#### POST /users/{id}/outfit-plans
Создать план образа

#### DELETE /users/{id}/outfit-plans/{plan_id}
Удалить план образа

#### GET /users/{id}/stats
Получить статистику пользователя

### Статус

#### GET /health
Проверить статус сервиса

### Метрики

#### GET /metrics
Получить Prometheus-метрики