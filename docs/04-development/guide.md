# Руководство разработчика OutfitStyle

## 🛠 Настройка окружения

### Требования

- **Go** 1.21+
- **Python** 3.11+
- **Flutter** 3.x
- **Docker** 24+
- **PostgreSQL** 16 (через Docker)
- **Redis** 7 (через Docker)

### Установка зависимостей

```bash
# Backend (Go)
cd server
go mod download

# ML Service (Python)
cd ml-service
pip install -r requirements.txt

# Client (Flutter)
cd client
flutter pub get
```

---

## 🏃 Запуск локально

### 1. Запуск Docker контейнеров

```bash
# Development версия (минимальная)
docker-compose -f docker-compose.dev-minimal.yml up -d

# Или полная версия
docker-compose -f docker-compose.dev.yml up -d

# Проверка статуса
docker-compose ps
```

**Контейнеры:**
- `outfitstyle-postgres` (:5432)
- `outfitstyle-redis` (:6379)
- `outfitstyle-api` (:8080)
- `outfitstyle-ml-service` (:5000)

### 2. Запуск API сервера (опционально)

```bash
cd server
go run cmd/server/main.go
```

### 3. Запуск Flutter клиента

```bash
cd client

# Android эмулятор
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Или для физического устройства
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8080
```

---

## 📝 Стандарты кода

### Go

```go
// Используйте golint и gofmt
go fmt ./...
go vet ./...
golint ./...

// Тесты
go test ./...
```

**Style guide:**
- CamelCase для экспортируемых идентификаторов
- camelCase для внутренних
- Обработка ошибок через if err != nil
- Context первым параметром

### Flutter/Dart

```bash
# Форматирование
flutter format .

# Анализ
flutter analyze

# Тесты
flutter test
```

**Style guide:**
- snake_case для файлов
- CamelCase для классов
- camelCase для переменных
- Riverpod для state management

### Python

```bash
# Форматирование
black ml-service/
flake8 ml-service/

# Тесты
pytest ml-service/
```

---

## 🗂 Структура проекта

### Backend (Go)

```
server/
├── cmd/
│   └── main.go          # Точка входа
├── internal/
│   ├── handlers/        # HTTP handlers
│   ├── services/        # Бизнес-логика
│   ├── repository/      # SQL запросы
│   └── middleware/      # Middleware
├── pkg/                 # Публичные пакеты
└── go.mod
```

### Flutter

```
client/
├── lib/
│   ├── src/
│   │   ├── features/    # Фичи по папкам
│   │   │   ├── auth/
│   │   │   ├── wardrobe/
│   │   │   └── recommendations/
│   │   ├── core/        # Общее (API, errors)
│   │   └── ui/          # UI компоненты
│   └── main.dart
└── pubspec.yaml
```

### ML Service

```
ml-service/
├── train/               # Скрипты обучения
├── inference/           # Инференс сервис
├── models/              # Обученные модели
└── requirements.txt
```

---

## 🧪 Тестирование

### Backend

```bash
cd server

# Unit тесты
go test ./internal/...

# Integration тесты
go test -tags=integration ./...

# Coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Flutter

```bash
cd client

# Unit тесты
flutter test

# Integration тесты
flutter test integration_test/

# Coverage
flutter test --coverage
```

### ML Service

```bash
cd ml-service

# Тесты
pytest tests/

# Coverage
pytest --cov=ml_service tests/
```

---

## 🔧 Полезные команды

### Docker

```bash
# Перезапуск контейнеров
docker-compose restart

# Просмотр логов
docker-compose logs -f api
docker-compose logs -f ml-service

# Очистка
docker-compose down -v
```

### Database

```bash
# Подключение к PostgreSQL
docker-compose exec postgres psql -U outfitstyle -d outfitstyle

# Миграции
cd server
sqlc generate
```

### ML

```bash
# Переобучение модели
cd ml-service
python train/train_ranker.py

# Тестирование инференса
python inference/test.py
```

---

## 🐛 Отладка

### API Server

```bash
# Debug логирование
export LOG_LEVEL=debug
go run cmd/server/main.go

# Delve debugger
dlv debug cmd/server/main.go
```

### Flutter

```bash
# Verbose логирование
flutter run -v

# DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### ML Service

```bash
# Debug режим
export DEBUG=true
uvicorn inference.app:app --reload
```

---

## 📦 Деплой

Смотрите [Deployment Guide](../05-deployment/guide.md)

---

## 🆘 Troubleshooting

### Частые проблемы

**1. Ошибка подключения к БД**
```
panic: dial tcp [::1]:5432: connect: connection refused
```
**Решение:** Проверьте что PostgreSQL запущен
```bash
docker-compose ps postgres
```

**2. Flutter не видит API**
```
SocketException: Connection refused
```
**Решение:** Используйте правильный IP
- Эмулятор: `http://10.0.2.2:8080`
- Физическое устройство: `http://YOUR_IP:8080`

**3. ML service недоступен**
```
Error: Connection refused to localhost:8000
```
**Решение:** Проверьте контейнер
```bash
docker-compose logs ml-service
```

---

## 📚 Дополнительные ресурсы

- [Architecture](../02-architecture/detailed.md)
- [API Reference](../03-api/reference.md)
- [Database Schema](../02-architecture/database/schema.md)

---

**Обновлено:** Февраль 2026
