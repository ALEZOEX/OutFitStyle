# 🐳 Docker - Запуск OutfitStyle

## 📋 Компоненты проекта

| Сервис | Порт | Описание |
|--------|------|----------|
| **PostgreSQL** | 5432 | База данных |
| **Redis** | 6379 | Кэш и сессии |
| **API Server** | 8080 | Go API сервер |
| **ML Service** | 8000 | Python ML сервис |
| **Nginx** | 80/443 | Reverse proxy |
| **Prometheus** | 9090 | Мониторинг метрик |
| **Grafana** | 3000 | Визуализация метрик |

---

## 🚀 Быстрый старт (Development)

### 1. Запуск всего стека

```bash
# Клонирование репозитория
git clone https://github.com/ALEZOEX/OutFitStyle.git
cd OutFitStyle

# Копирование .env
cp .env.example .env

# Запуск всех сервисов
docker-compose up -d
```

### 2. Проверка статуса

```bash
docker-compose ps
```

### 3. Остановка

```bash
docker-compose down
```

---

## 🛠️ Режимы запуска

### Development (полный стек)

```bash
docker-compose -f docker-compose.dev.yml up -d
```

### Production

```bash
docker-compose -f docker-compose.prod.yml up -d
```

### Только базовые сервисы (минимальный)

```bash
docker-compose -f docker-compose.dev-minimal.yml up -d
```

Включает:
- PostgreSQL
- Redis
- API Server

---

## 📦 Сборка образов

### Сборка всех сервисов

```bash
docker-compose build
```

### Сборка конкретного сервиса

```bash
docker-compose build api
docker-compose build ml-service
```

### Сборка полного образа (все сервисы в одном)

```bash
docker build -f Dockerfile.full -t outfitstyle:latest .
```

---

## 🔧 Управление миграциями

### Запуск миграций

```bash
docker-compose run migrate
```

### Откат миграций

```bash
docker-compose run migrate -down
```

---

## 📊 Мониторинг

### Prometheus

Откройте в браузере: http://localhost:9090

Пример запроса:
```
rate(http_requests_total[5m])
```

### Grafana

Откройте в браузере: http://localhost:3000

- Логин: `admin`
- Пароль: `admin`

Datasource Prometheus уже настроен автоматически.

---

## 📝 Логи

### Просмотр логов всех сервисов

```bash
docker-compose logs -f
```

### Логи конкретного сервиса

```bash
docker-compose logs -f api
docker-compose logs -f ml-service
docker-compose logs -f nginx
```

---

## 🔐 Переменные окружения

Скопируйте `.env.example` в `.env` и настройте:

```bash
# База данных
DB_NAME=outfitstyle
DB_USER=postgres
DB_PASSWORD=your_secure_password

# Redis
REDIS_PASSWORD=your_secure_redis_password

# JWT
JWT_SECRET=your_super_secret_jwt_key_change_in_production
JWT_ACCESS_TOKEN_TTL=15m
JWT_REFRESH_TOKEN_TTL=720h

# ML Service
ML_SERVICE_URL=http://ml-service:8000

# Weather API
WEATHER_API_KEY=your_openweather_api_key

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
```

---

## 🏗️ Архитектура

```
┌─────────────┐
│   Nginx     │ :80/:443
└──────┬──────┘
       │
       ├─────────────┐
       │             │
┌──────▼──────┐ ┌───▼────────┐
│  API Server │ │ ML Service │
│   (Go)      │ │  (Python)  │
│   :8080     │ │   :8000    │
└──────┬──────┘ └────────────┘
       │
       ├─────────────┐
       │             │
┌──────▼──────┐ ┌───▼────────┐
│ PostgreSQL  │ │   Redis    │
│   :5432     │ │   :6379    │
└─────────────┘ └────────────┘

┌─────────────────────────────┐
│    Monitoring Stack         │
│  Prometheus :9090           │
│  Grafana    :3000           │
└─────────────────────────────┘
```

---

## ⚠️ Troubleshooting

### Ошибка "database does not exist"

```bash
docker-compose down -v
docker-compose up -d postgres
docker-compose run migrate
docker-compose up -d
```

### Ошибка подключения к Redis

Проверьте пароль в `.env` и перезапустите:

```bash
docker-compose restart redis api
```

### ML сервис не отвечает

Проверьте логи:

```bash
docker-compose logs ml-service
```

Пересоберите образ:

```bash
docker-compose build ml-service
docker-compose up -d ml-service
```

---

## 📚 Дополнительная документация

- [Kafka Setup](../KAFKA_SETUP.md)
- [Subscription Implementation](../SUBSCRIPTION_IMPLEMENTATION.md)
- [Infrastructure](../infrastructure/)
