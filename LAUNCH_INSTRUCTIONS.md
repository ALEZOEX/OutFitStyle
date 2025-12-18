# OutfitStyle MVP - Инструкция по запуску

## Подготовка

1. Убедитесь, что у вас установлены:
   - Docker и Docker Compose
   - Go (для локального запуска бэкенда, если нужно)
   - Flutter SDK (для локального запуска фронтенда, если нужно)

## Запуск с помощью Docker Compose

### 1. Настройка переменных окружения

Создайте файл `.env` в корне проекта на основе `.env.example`:

```bash
cp .env.example .env
```

Отредактируйте `.env`, указав необходимые переменные:
- `JWT_SECRET` - секретный ключ для JWT токенов
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` - для PostgreSQL
- `REDIS_PASSWORD` - для Redis
- `OPENWEATHER_API_KEY` - для погодного API
- `ML_SERVICE_BASE_URL` - URL для ML сервиса
- И другие API ключи по необходимости

### 2. Запуск всей инфраструктуры

```bash
# Запуск всех сервисов
docker-compose up -d

# Проверка статуса сервисов
docker-compose ps
```

### 3. Выполнение миграций БД

```bash
# Запуск миграций
docker-compose run --rm server sh -c "./migrate.sh up"
```

## Запуск в режиме разработки

### Бэкенд (Go)

```bash
cd server
go mod tidy
go run cmd/server/main.go
```

### Фронтенд (Flutter)

```bash
cd client
flutter pub get
flutter run
```

## Структура проекта

```
outfitstyle/
├── server/                 # Go backend
│   ├── cmd/server/         # Точка входа сервера
│   ├── internal/api/       # HTTP handlers
│   ├── internal/core/      # Бизнес-логика
│   ├── internal/infrastructure/ # Внешние зависимости
│   └── migrations/         # SQL миграции
├── client/                 # Flutter frontend
│   ├── lib/
│   │   ├── screens/        # UI экраны
│   │   ├── providers/      # Provider-ы для состояния
│   │   ├── services/       # Сервисы для API
│   │   └── models/         # Модели данных
│   └── assets/             # Ресурсы
├── docker-compose.yml      # Оркестрация сервисов
└── .env.example           # Пример файла окружения
```

## Основные функции MVP

1. **Регистрация/авторизация** - с подтверждением по email
2. **Онбординг** - пошаговая настройка предпочтений
3. **Гардероб** - добавление, фильтрация, пагинация вещей
4. **Рекомендации** - генерация образов с учётом погоды и предпочтений
5. **Персонализация** - предпочтения стилей, цветов, размеров
6. **История** - просмотр предыдущих рекомендаций
7. **Уведомления** - пуш-уведомления
8. **Подписки** - система тарифов и ограничений

## API Endpoints (основные)

### Auth
- `POST /api/v1/auth/register` - регистрация
- `POST /api/v1/auth/login` - вход
- `POST /api/v1/auth/refresh` - обновление токена
- `POST /api/v1/auth/logout` - выход

### User
- `GET /api/v1/user/profile` - профиль пользователя
- `PUT /api/v1/user/profile` - обновление профиля
- `PUT /api/v1/user/preferences` - обновление предпочтений
- `PUT /api/v1/user/body-measurements` - обновление размеров

### Wardrobe
- `GET /api/v1/wardrobe` - список вещей с фильтрами
- `POST /api/v1/wardrobe` - добавить вещь
- `POST /api/v1/wardrobe/{id}/favorite` - избранное
- `POST /api/v1/wardrobe/{id}/archive` - архивировать

### Recommendations
- `POST /api/v1/recommendations` - создать рекомендацию
- `GET /api/v1/recommendations` - история
- `POST /api/v1/recommendations/{id}/rate` - оценить
- `POST /api/v1/recommendations/{id}/favorite` - избранное
- `POST /api/v1/recommendations/{id}/regenerate` - пересобрать

### Weather
- `GET /api/v1/weather` - погода по координатам профиля

## Технологии

### Backend
- **Go** - основной язык
- **PostgreSQL** - основная БД
- **Redis** - кэширование и сессии
- **Docker** - контейнеризация
- **Gorilla Mux** - роутинг
- **pgx** - работа с PostgreSQL

### Frontend
- **Flutter** - кроссплатформенный UI
- **Provider** - управление состоянием
- **http** - HTTP клиент
- **flutter_secure_storage** - безопасное хранение токенов

### Инфраструктура
- **Docker Compose** - оркестрация
- **Asynq** - обработка задач в очереди
- **Sentry** - мониторинг ошибок
- **Prometheus + Grafana** - мониторинг метрик

## Тестирование

### Backend
```bash
cd server
go test ./...
```

### Frontend
```bash
cd client
flutter test
```

## Production деплой

См. `docker-compose.prod.yml` для production конфигурации.

Для деплоя:
1. Обновите образы в `docker-compose.prod.yml`
2. Убедитесь, что все секреты заданы в `.env`
3. Запустите: `docker-compose -f docker-compose.prod.yml up -d`

## Troubleshooting

### Сервер не запускается
- Проверьте, что PostgreSQL и Redis запущены
- Убедитесь, что порты не заняты
- Проверьте файл `.env`

### Клиент не может подключиться к серверу
- Убедитесь, что сервер запущен на правильном хосте/порту
- Для Android эмулятора используйте `10.0.2.2` вместо `localhost`
- Для iOS симулятора используйте `127.0.0.1`

### Проблемы с пуш-уведомлениями
- Проверьте настройки FCM
- Убедитесь, что ключи валидны
- Проверьте права доступа

## Контакты для поддержки

Для вопросов и поддержки обращайтесь к команде разработки.