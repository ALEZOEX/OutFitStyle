# Быстрый старт

## Что нужно для запуска

**Минимальные требования:**
- Docker (для запуска базы данных и Redis)
- Go 1.21+ (для backend)
- Python 3.11+ (для ML сервиса)
- Flutter 3.x (для клиента, опционально)

## Запуск за 5 минут

### 1. Клонировать репозиторий

```bash
git clone https://github.com/ALEZOEX/OutFitStyle.git
cd OutFitStyle
```

### 2. Запустить базу данных и Redis

```bash
docker-compose -f docker-compose.dev-minimal.yml up -d
```

Проверить:
```bash
docker-compose ps
# Должны быть запущены: postgres и redis
```

### 3. Запустить Backend (Go)

```bash
cd server
go run cmd/server/main.go
```

Backend запустится на http://localhost:8080

Проверить:
```bash
curl http://localhost:8080/api/health
# Должен вернуть: {"status":"ok"}
```

### 4. Запустить ML сервис (Python, опционально)

```bash
cd ml-service
pip install -r requirements.txt
python main.py
```

ML сервис запустится на http://localhost:5000

### 5. Запустить Flutter клиент (опционально)

```bash
cd client
flutter pub get
flutter run
```

## Проверка работы

1. **API доступно**: http://localhost:8080/api/health
2. **Swagger документация**: http://localhost:8080/swagger
3. **ML сервис**: http://localhost:5000/health

## Что дальше?

- [Обзор проекта](overview.md) — узнайте что делает OutfitStyle
- [Руководство разработчика](../04-development/guide.md) — настройка окружения
- [API документация](../03-api/reference.md) — как работать с API
