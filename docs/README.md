# Документация OutfitStyle

> AI-powered платформа для умных рекомендаций одежды

## 📚 Структура документации

### [01. Быстрый старт](01-getting-started/)
- [Quick Start](01-getting-started/quickstart.md) — краткое руководство по архитектуре
- [Обзор проекта](01-getting-started/overview.md) — общая информация

### [02. Архитектура](02-architecture/)
- [Детальная архитектура](02-architecture/detailed.md) — полное описание архитектуры
- [Production V2](02-architecture/production-v2.md) — производственная архитектура
- [База данных](02-architecture/database/)
  - [Схема БД](02-architecture/database/schema.md)
  - [ML структура](02-architecture/database/ml-structure.md)

### [03. API](03-api/)
- [API Reference](03-api/reference.md) — документация всех endpoints

### [04. Разработка](04-development/)
- [Руководство разработчика](04-development/guide.md)
- [Управление каталогом](04-development/catalog-management.md)
- [Чек-лист реализации](04-development/implementation-checklist.md)

### [05. Развёртывание](05-deployment/)
- [Руководство по деплою](05-deployment/guide.md) — локальное и production

### [06. Функции](06-features/)
- [Система подписок](06-features/subscriptions.md)

### [07. Эксплуатация](07-operations/)
- [Мониторинг](07-operations/monitoring.md)
- [Troubleshooting](07-operations/troubleshooting/)

### [08. Безопасность](08-security/)
- [Руководство по безопасности](08-security/guide.md)

### [09. Тестирование](09-testing/)
- [Стратегия тестирования](09-testing/strategy.md)

### [Archive](archive/)
Устаревшая документация хранится для истории.

---

## 🏗 Краткий обзор архитектуры

```
┌─────────────────────────────────────────────────────────┐
│                  Flutter Client                          │
│            (com.app.outfitstyle)                        │
└────────────────────┬────────────────────────────────────┘
                     │ HTTP/REST
                     ▼
┌─────────────────────────────────────────────────────────┐
│              Go API Server (:8080)                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐  │
│  │  Auth    │  │ Wardrobe │  │   Recommendations    │  │
│  │  Module  │  │  Module  │  │   (Retrieval+Rank)   │  │
│  └──────────┘  └──────────┘  └──────────────────────┘  │
└─────────┬─────────────┬──────────────────┬─────────────┘
          │             │                  │
          ▼             ▼                  ▼
┌────────────────┐ ┌────────────────┐ ┌──────────────────┐
│  PostgreSQL    │ │    Redis       │ │  Python ML       │
│  (:5432)       │ │    (:6379)     │ │  Service (:8000) │
│                │ │    Cache       │ │  CatBoost Model  │
└────────────────┘ └────────────────┘ └──────────────────┘
```

### Компоненты:

| Компонент | Порт | Описание |
|-----------|------|----------|
| **Go API** | 8080 | REST API, аутентификация, бизнес-логика |
| **PostgreSQL** | 5432 | Основное хранилище данных |
| **Redis** | 6379 | Кэш, сессии, rate limiting |
| **ML Service** | 8000 | Рекомендательная модель (CatBoost) |

### Технологический стек:

**Backend:**
- Go 1.21+ (Chi Router, SQLC, Wire DI)
- Python 3.11+ (FastAPI, CatBoost, Scikit-learn)
- PostgreSQL 16 (Drift ORM)
- Redis 7

**Mobile:**
- Flutter 3.x (Riverpod, GoRouter, Freezed)
- Package: `com.app.outfitstyle`

**Infrastructure:**
- Docker & Docker Compose
- Nginx (reverse proxy)
- Let's Encrypt (SSL)

---

## 🚀 Быстрый старт

### Запуск локально:

```bash
# Клонировать репозиторий
git clone https://github.com/your-org/outfitstyle.git
cd outfitstyle

# Запустить Docker контейнеры
docker-compose -f docker-compose.dev.yml up -d

# Проверить статус
docker-compose ps

# Запустить Flutter клиент
cd client
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

### Проверка работы:

- **API Health:** http://localhost:8080/api/health
- **Swagger UI:** http://localhost:8080/swagger
- **Flutter Client:** http://localhost:8080

---

## 📦 Основные возможности

- ✅ **Google Sign-In** — аутентификация через Google
- ✅ **Гардероб** — управление вещами (12 категорий)
- ✅ **Рекомендации** — ML-based подбор outfit'ов
- ✅ **Погода** — интеграция с погодными сервисами
- ✅ **Подписки** — Premium/Premium Plus планы
- ✅ **Уведомления** — push и email уведомления

---

## 🔗 Полезные ссылки

- [GitHub Repository](https://github.com/your-org/outfitstyle)
- [Firebase Console](https://console.firebase.google.com/project/outfitstyle-ce15f)
- [Google Cloud Console](https://console.cloud.google.com/project/outfitstyle-ce15f)

---

## 📝 Статус документации

| Раздел | Статус | Последнее обновление |
|--------|--------|---------------------|
| Быстрый старт | ✅ Актуально | Февраль 2026 |
| Архитектура | ✅ Актуально | Февраль 2026 |
| API | ✅ Актуально | Февраль 2026 |
| Разработка | ⚠️ Требует обновления | Февраль 2026 |
| Развёртывание | ✅ Актуально | Февраль 2026 |
| Функции | ✅ Актуально | Февраль 2026 |
| Эксплуатация | ⚠️ Требует обновления | Февраль 2026 |
| Безопасность | ✅ Актуально | Февраль 2026 |
| Тестирование | ❌ Не реализовано | — |

---

## 🤝 Вклад в документацию

При внесении изменений в код, пожалуйста, обновляйте соответствующую документацию.

**Перед коммитом:**
1. Проверьте актуальность документации
2. Обновите README если изменилась архитектура
3. Добавьте примеры кода для новых функций

---

**Последнее обновление:** Февраль 2026  
**Версия документации:** 2.0
