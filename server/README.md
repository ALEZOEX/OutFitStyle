# OutfitStyle Server

Go backend for the OutfitStyle application.  
Отвечает за REST‑API, работу с БД, пользователями, гардеробом и интеграцию с ML‑сервисом рекомендаций.

## Overview

Архитектура сейчас состоит из трёх сервисов:

- **server** (Go) – основной HTTP‑API
- **ml-service** (Python/Flask) – ML‑рекомендатель (отдельный контейнер)
- **marketplace-service** (Python/Flask) – сервис каталога/гардероба (отдельный контейнер)

Все они поднимаются через `docker compose` и общаются по HTTP внутри общей сети.

## Features

- RESTful API (`/api/v1/...`) для:
    - outfit‑рекомендаций по погоде,
    - управления пользователями и профилями,
    - личного гардероба и истории рекомендаций,
    - избранного, оценок и ачивок.
- Интеграция с:
    - **OpenWeatherMap** для получения погоды,
    - **ML‑сервисом** для вычисления образов,
    - **marketplace‑сервисом** для выбора кандидатов из гардероба/каталога.
- Хранение:
    - рекомендаций (`recommendations`),
    - элементов рекомендаций (`recommendation_items`),
    - вещей (`clothing_items`) – и гардероб пользователя, и общий каталог,
    - профилей пользователей (`user_profiles`), статистики и фидбэка.
- Кэширование через Redis.
- Swagger/OpenAPI документация.
- Prometheus‑метрики для мониторинга.
- Полная Docker‑конфигурация для локальной разработки и деплоя.

## Architecture (Go server)

Сервер следует упрощённому clean‑architecture / hexagonal‑подходу:

```text
cmd/
  └── server/           # Точка входа приложения (main.go)

internal/
  ├── api/              # HTTP слой (middleware, routes, handlers)
  │   ├── handlers/     # RecommendationHandler, UserHandler и т.д.
  │   └── middleware/   # CORS, логирование, rate limiting, recovery
  ├── core/
  │   ├── domain/       # Бизнес‑сущности (User, ClothingItem, Recommendation …)
  │   └── application/  # Сервисы/UseCases (RecommendationService, UserService …)
  ├── infrastructure/
  │   ├── config/       # Загрузка конфигурации (env, .env, RUN_IN_DOCKER)
  │   ├── postgres/     # Подключение к PostgreSQL
  │   ├── redis/        # Кэш
  │   ├── persistence/  # Реализации репозиториев (RecommendationRepository …)
  │   └── external/     # Клиенты внешних сервисов (WeatherService, MLService …)
  └── pkg/              # Вспомогательные утилиты (errors, http, security …)