# Тестирование системы рекомендаций

## Обзор

Этот документ описывает процесс проверки работы системы рекомендаций OutfitStyle, включая создание, получение, оценку и удаление рекомендаций.

## Архитектура

### Клиент (Flutter/Dart)

**Репозитории:**
- `RecommendationsRepository` - основной репозиторий для работы с рекомендациями
- `DailyRecommendationsRepository` - ежедневные рекомендации
- `RatingApiService` - сервис оценки рекомендаций

**Провайдеры:**
- `RecommendationsProvider` - state management для рекомендаций
- `RatingProvider` - управление оценками

**Основные методы:**
```dart
// Создание рекомендации
Future<OutfitRecommendation> generateRecommendation({
  required double latitude,
  required double longitude,
  String? occasion,
})

// Получение списка
Future<List<OutfitRecommendation>> getUserRecommendations(String userId)

// Оценка
Future<void> rateRecommendation(String id, double rating)

// Удаление
Future<void> deleteRecommendation(String id)
```

### Сервер (Go)

**Handlers:**
- `RecommendationHandler` - обработка HTTP запросов
- `RatingHandler` - обработка оценок

**Services:**
- `RecommendationService` - бизнес-логика рекомендаций
- `RatingService` - бизнес-логика оценок

**API Endpoints:**
```
POST   /api/v1/recommendations              - Создание рекомендации
GET    /api/v1/recommendations              - Список рекомендаций
GET    /api/v1/recommendations/{id}         - Получение по ID
POST   /api/v1/recommendations/{id}/rate    - Оценка рекомендации
POST   /api/v1/recommendations/{id}/favorite - Добавить в избранное
GET    /api/v1/recommendations/favorites    - Список избранных
DELETE /api/v1/recommendations/{id}         - Удаление рекомендации
```

## Автоматическое тестирование

### Использование скриптов

#### Windows (PowerShell)
```powershell
.\test_recommendations_flow.ps1
```

С параметрами:
```powershell
.\test_recommendations_flow.ps1 -ApiUrl "http://localhost:8080" -TestUserEmail "user@example.com" -TestUserPassword "password"
```

#### Linux/Mac (Bash)
```bash
chmod +x test_recommendations_flow.sh
./test_recommendations_flow.sh
```

С переменными окружения:
```bash
API_URL=http://localhost:8080 TEST_USER_EMAIL=user@example.com ./test_recommendations_flow.sh
```

### Что проверяют скрипты

1. **Авторизация** - получение JWT токена
2. **Создание рекомендации** - POST запрос с координатами
3. **Получение списка** - проверка, что рекомендация появилась
4. **Получение по ID** - проверка корректности данных
5. **Оценка** - добавление рейтинга и отзыва
6. **Избранное** - добавление в избранное и проверка списка
7. **Удаление** - удаление и проверка, что рекомендация недоступна

## Ручное тестирование

### 1. Создание рекомендации

```bash
curl -X POST http://localhost:8080/api/v1/recommendations \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 55.7558,
    "longitude": 37.6173,
    "occasion": "casual"
  }'
```

**Ожидаемый ответ:**
```json
{
  "recommendation": {
    "id": "uuid",
    "user_id": "uuid",
    "created_at": "2024-01-01T12:00:00Z",
    "items": [
      {
        "id": "uuid",
        "name": "Футболка",
        "category": "upper",
        "score": 0.95
      }
    ],
    "temperature": 20.5,
    "weather": {...},
    "ml_powered": true
  }
}
```

### 2. Получение списка рекомендаций

```bash
curl -X GET http://localhost:8080/api/v1/recommendations \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Параметры запроса:**
- `page` - номер страницы (по умолчанию 1)
- `limit` - количество на странице (по умолчанию 20)
- `from_date` - фильтр по дате (ISO 8601)
- `to_date` - фильтр по дате (ISO 8601)
- `is_favorite` - только избранные (true/false)

### 3. Оценка рекомендации

```bash
curl -X POST http://localhost:8080/api/v1/recommendations/{id}/rate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 5,
    "feedback": "Отличная рекомендация!",
    "thermal_feedback": "just_right"
  }'
```

**Параметры:**
- `rating` - оценка от 1 до 5 (обязательно)
- `feedback` - текстовый отзыв (опционально)
- `thermal_feedback` - термальная обратная связь: "too_hot", "too_cold", "just_right" (опционально)

**Конвертация в quality_score:**
- 1 звезда → -10
- 2 звезды → -5
- 3 звезды → 0
- 4 звезды → +5
- 5 звёзд → +10

### 4. Добавление в избранное

```bash
curl -X POST http://localhost:8080/api/v1/recommendations/{id}/favorite \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_favorite": true}'
```

### 5. Удаление рекомендации

```bash
curl -X DELETE http://localhost:8080/api/v1/recommendations/{id} \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Проверка на клиенте (Flutter)

### Тестирование в приложении

1. **Создание рекомендации:**
   - Откройте главный экран
   - Нажмите кнопку "Сгенерировать рекомендацию"
   - Проверьте, что появилась карточка с рекомендацией

2. **Просмотр деталей:**
   - Нажмите на карточку рекомендации
   - Проверьте отображение всех элементов образа
   - Проверьте информацию о погоде

3. **Оценка:**
   - На экране деталей нажмите на звёзды
   - Выберите оценку от 1 до 5
   - Добавьте комментарий (опционально)
   - Проверьте, что оценка сохранилась

4. **Избранное:**
   - Нажмите на иконку сердца
   - Перейдите в раздел "Избранное"
   - Проверьте, что рекомендация появилась в списке

5. **Удаление:**
   - Откройте меню рекомендации
   - Выберите "Удалить"
   - Подтвердите удаление
   - Проверьте, что рекомендация исчезла из списка

## Проверка базы данных

### Таблицы

```sql
-- Рекомендации
SELECT * FROM recommendations WHERE user_id = 'USER_UUID' ORDER BY created_at DESC LIMIT 10;

-- Элементы рекомендаций
SELECT * FROM recommendation_items WHERE recommendation_id = 'REC_UUID';

-- Оценки
SELECT * FROM outfit_ratings WHERE recommendation_id = 'REC_UUID';

-- Избранное
SELECT * FROM recommendation_favorites WHERE user_id = 'USER_UUID';
```

### Проверка целостности данных

```sql
-- Проверка, что у каждой рекомендации есть элементы
SELECT r.id, r.created_at, COUNT(ri.id) as items_count
FROM recommendations r
LEFT JOIN recommendation_items ri ON r.id = ri.recommendation_id
GROUP BY r.id, r.created_at
HAVING COUNT(ri.id) = 0;

-- Проверка оценок
SELECT 
    r.id,
    r.created_at,
    or.rating,
    or.quality_score,
    or.feedback
FROM recommendations r
LEFT JOIN outfit_ratings or ON r.id = or.recommendation_id
WHERE r.user_id = 'USER_UUID'
ORDER BY r.created_at DESC;
```

## Типичные проблемы и решения

### 1. Рекомендация не создаётся

**Проблема:** HTTP 500 при создании рекомендации

**Возможные причины:**
- Нет координат в запросе и профиле пользователя
- Сервис погоды недоступен
- Нет вещей в каталоге/гардеробе

**Решение:**
```bash
# Проверить координаты пользователя
SELECT default_latitude, default_longitude FROM users WHERE id = 'USER_UUID';

# Проверить наличие вещей
SELECT COUNT(*) FROM clothing_items WHERE is_active = true;
```

### 2. Пустой список рекомендаций

**Проблема:** GET возвращает пустой массив

**Возможные причины:**
- Рекомендации не были созданы
- Неправильный user_id в токене
- Фильтры исключают все рекомендации

**Решение:**
```sql
-- Проверить рекомендации пользователя
SELECT COUNT(*) FROM recommendations WHERE user_id = 'USER_UUID';
```

### 3. Оценка не сохраняется

**Проблема:** Оценка не отображается после сохранения

**Возможные причины:**
- Неправильный ID рекомендации
- Рекомендация не принадлежит пользователю
- Ошибка валидации (rating не в диапазоне 1-5)

**Решение:**
```sql
-- Проверить оценки
SELECT * FROM outfit_ratings WHERE user_id = 'USER_UUID' AND recommendation_id = 'REC_UUID';
```

### 4. Удаление не работает

**Проблема:** HTTP 403 или 404 при удалении

**Возможные причины:**
- Рекомендация не принадлежит пользователю
- Рекомендация уже удалена
- Недостаточно прав

**Решение:**
```sql
-- Проверить владельца рекомендации
SELECT user_id FROM recommendations WHERE id = 'REC_UUID';
```

## Метрики для мониторинга

### Ключевые показатели

1. **Успешность создания рекомендаций:**
   - Процент успешных запросов POST /api/v1/recommendations
   - Среднее время генерации рекомендации

2. **Качество рекомендаций:**
   - Средний рейтинг (1-5)
   - Средний quality_score (-10 до +10)
   - Процент рекомендаций с оценкой 4-5

3. **Вовлечённость пользователей:**
   - Процент оценённых рекомендаций
   - Процент добавленных в избранное
   - Среднее количество рекомендаций на пользователя

### SQL запросы для метрик

```sql
-- Средний рейтинг за последние 7 дней
SELECT AVG(rating) as avg_rating, AVG(quality_score) as avg_quality
FROM outfit_ratings
WHERE created_at > NOW() - INTERVAL '7 days';

-- Топ-10 пользователей по количеству рекомендаций
SELECT user_id, COUNT(*) as rec_count
FROM recommendations
GROUP BY user_id
ORDER BY rec_count DESC
LIMIT 10;

-- Процент оценённых рекомендаций
SELECT 
    COUNT(DISTINCT r.id) as total_recs,
    COUNT(DISTINCT or.recommendation_id) as rated_recs,
    ROUND(100.0 * COUNT(DISTINCT or.recommendation_id) / COUNT(DISTINCT r.id), 2) as rated_percent
FROM recommendations r
LEFT JOIN outfit_ratings or ON r.id = or.recommendation_id
WHERE r.created_at > NOW() - INTERVAL '7 days';
```

## Заключение

Система рекомендаций включает полный цикл: создание, получение, оценку, избранное и удаление. Используйте предоставленные скрипты для автоматической проверки всех операций или выполняйте ручное тестирование с помощью curl команд.

При возникновении проблем проверяйте логи сервера, состояние базы данных и корректность токенов авторизации.
