# Документация OutfitStyle

Проект: ML-сервис подбора одежды по погоде  
Авторы: Гаврилов А., Курганский С., Харламов И.  
Университетский лицей №1511, НИЯУ МИФИ  
Конкурс: ЮНИОР 2026

---

## Что здесь есть

**Для запуска проекта:**
- [Быстрый старт](01-getting-started/quickstart.md) — как запустить за 5 минут
- [Обзор проекта](01-getting-started/overview.md) — что делает OutfitStyle

**Для разработки:**
- [Руководство разработчика](04-development/guide.md) — настройка окружения
- [Управление каталогом](04-development/catalog-management.md) — работа с вещами
- [Чек-лист реализации](04-development/implementation-checklist.md) — что не забыть

**Архитектура:**
- [Общая архитектура](02-architecture/detailed.md) — как всё устроено
- [Production архитектура](02-architecture/production-v2.md) — для развёртывания
- [Схема БД](02-architecture/database/schema.md) — структура данных

**API:**
- [API Reference](03-api/reference.md) — документация endpoints

**Развёртывание:**
- [Руководство по деплою](05-deployment/guide.md) — локально и production

**Функции:**
- [Система подписок](06-features/subscriptions.md) — платные планы
- [Уведомления](06-features/notifications.md) — push и email

**Эксплуатация:**
- [Мониторинг](07-operations/monitoring.md) — метрики и логи
- [Troubleshooting](07-operations/troubleshooting/) — решение проблем

**Безопасность:**
- [Руководство по безопасности](08-security/guide.md) — политики и практики

**Тестирование:**
- [Стратегия тестирования](09-testing/strategy.md) — уровни и подходы

---

## Кратко об архитектуре

```
Flutter App (Web/Mobile)
       │
       ▼
Go API Server (:8080)
       │
       ├── PostgreSQL (:5432) — пользователи, вещи, рекомендации
       ├── Redis (:6379) — кэш, сессии, rate limiting
       └── ML Service (:5000) — CatBoost модель рекомендаций
```

**Технологии:**
- Backend: Go 1.25, Python 3.11 (FastAPI, CatBoost)
- Frontend: Flutter 3.35 (Riverpod, GoRouter)
- Базы: PostgreSQL 16, Redis 7
- Инфраструктура: Docker, k3s, Nginx

---

## Быстрый старт

```bash
# Клонировать
git clone https://github.com/ALEZOEX/OutFitStyle.git
cd OutFitStyle

# Запустить Docker
docker-compose -f docker-compose.dev.yml up -d

# Проверить API
curl http://localhost:8080/api/health

# Запустить Flutter (опционально)
cd client
flutter run
```

**Проверка:**
- API: http://localhost:8080/api/health
- Swagger: http://localhost:8080/swagger

---

## Основные возможности

- Аутентификация: Email/Password + Google Sign-In
- Гардероб: 12 категорий вещей
- Рекомендации: ML на основе CatBoost (accuracy 95%)
- Погода: OpenWeatherMap API
- Подписки: Free, Premium, Pro
- Уведомления: Email через SMTP

---

## Ссылки

- [GitHub](https://github.com/ALEZOEX/OutFitStyle)
- [Основной README](../README.md)

---

**Обновлено:** Март 2026
