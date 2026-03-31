# OutfitStyle

Приложение для подбора одежды по погоде с использованием машинного обучения.

Проект выполнен в рамках конкурса ЮНИОР.

## Что делает приложение

- Получает данные о погоде по геолокации (OpenWeatherMap API)
- Подбирает подходящую одежду из гардероба пользователя
- Учитывает личные предпочтения (стиль, чувствительность к температуре)
- Работает офлайн с синхронизацией данных

## Технологии

| Компонент   | Стек                        |
|-------------|-----------------------------|
| Backend API | Go + Gorilla Mux            |
| ML-сервис   | Python + FastAPI + CatBoost |
| Клиент      | Flutter + Riverpod          |
| База данных | PostgreSQL                  |
| Кэш         | Redis                       |
| Деплой      | Docker, k3s, GitHub Actions |

## Архитектура

```
Flutter App ──► Go API ──► ML Service (CatBoost)
                  │
                  ▼
            PostgreSQL + Redis
```

## ML-модель

- **Алгоритм:** CatBoostClassifier
- **Датасет:** Season Fashion Dataset (Kaggle)
- **Разделение:** 80% train / 20% test

**Метрики на тесте:**
| Метрика   | Значение |
|-----------|----------|
| Accuracy  | 95.25%   |
| AUC-ROC   | 98.94%   |
| Precision | 95.66%   |
| Recall    | 95.25%   |
| F1-Score  | 95.24%   |

## Запуск

```bash
# Клонировать
git clone https://github.com/ALEZOX/OutFitStyle.git
cd OutFitStyle

# Настроить переменные окружения
cp .env.example .env

# Запустить через Docker
docker-compose up -d
```

### Для разработки

```bash
# Backend
cd server
go run cmd/server/main.go

# ML-сервис
cd ml-service
python main.py

# Клиент
cd client
flutter pub get
flutter run
```

## Тесты

```bash
# Backend
cd server && go test ./...

# ML
cd ml-service && pytest tests/

# Flutter
cd client && flutter test
```

## Структура проекта

```
├── server/          # Go API
├── ml-service/      # Python ML
├── client/          # Flutter
├── k8s/             # Kubernetes манифесты
├── infrastructure/  # Nginx, конфиги
└── docs/            # Документация
```

## Авторы

Гаврилов Андрей, Курганский Сергей, Харламов Иван
Университетский лицей №1511, НИЯУ МИФИ
Научный руководитель: Горбунов Сергей Михайлович
