# OutFitStyle - Платформа умных рекомендаций одежды
## Информация для плаката (Junior Poster Session)

---

## 🎯 Краткое описание (Elevator Pitch)

**OutFitStyle** — это AI-платформа, которая подбирает идеальный наряд на основе:
- 🌤 Погоды в реальном времени
- 👤 Личных предпочтений пользователя
- 👗 Содержимого гардероба
- 🎨 Стиля и случая (работа, прогулка, вечеринка)

**Аналоги:** Stylebook, Cladwell, Smart Closet — но с AI-рекомендациями на основе погоды и ML-ранжированием.

---

## 🏗 Архитектура проекта

```
┌─────────────────────────────────────────────────────────────────┐
│                        KLIENT (Flutter)                         │
│  Web / Android / iOS • Riverpod • Go Router • Drift (SQLite)   │
└────────────────────────┬────────────────────────────────────────┘
                         │ REST API / WebSocket
┌────────────────────────▼────────────────────────────────────────┐
│                     BACKEND (Go 1.24+)                          │
│  Fiber • JWT (RS256) • Kafka • Redis • PostgreSQL • Istio      │
└────────────────────────┬────────────────────────────────────────┘
                         │ gRPC / HTTP
┌────────────────────────▼────────────────────────────────────────┐
│                   ML SERVICE (Python 3.11+)                     │
│  FastAPI • CatBoost • Scikit-learn • Pandas • NumPy            │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📱 КЛИЕНТ (Flutter)

### Технологии
- **Flutter 3.24+** — кроссплатформенный UI (Web, Android, iOS)
- **Riverpod 2.6+** — управление состоянием
- **Go Router 14.8+** — навигация
- **Drift 2.31+** — офлайн-база данных (SQLite)
- **Dio 5.7+** — HTTP-клиент
- **Firebase** — аналитика, Crashlytics, Remote Config

### Ключевые функции
- ✅ Google Sign-In (Firebase Auth для Web, google_sign_in для Mobile)
- ✅ Refresh токены (автоматическое обновление access токена)
- ✅ Офлайн-режим с синхронизацией
- ✅ CitySelector — выбор города через Nominatim API (для Web)
- ✅ Темизация (светлая/тёмная)
- ✅ Push-уведомления (FCM)

### Минимальные требования
- **Android:** API 23+ (Android 6.0+)
- **iOS:** 14.0+
- **Web:** Современные браузеры

---

## 🔧 BACKEND (Go)

### Технологии
- **Go 1.24+** — высокопроизводительный бэкенд
- **Fiber** — веб-фреймворк (Express-подобный)
- **PostgreSQL** — основная БД
- **Redis** — кэш, сессии, rate limiting
- **Apache Kafka** — событийная архитектура
- **Istio** — service mesh (mTLS, observability)
- **JWT RS256** — аутентификация

### Микросервисы
1. **Auth Service** — аутентификация, JWT, OAuth 2.0 (Google)
2. **Wardrobe Service** — управление гардеробом
3. **Recommendation Service** — ML-интеграция, персонализация
4. **Weather Service** — погода (OpenWeatherMap)
5. **User Service** — профили, предпочтения
6. **Notification Service** — push, email
7. **Subscription Service** — платные подписки (YooKassa)

### API Endpoints (ключевые)
```
POST   /api/v1/auth/google          — вход через Google
POST   /api/v1/auth/refresh         — refresh токена
GET    /api/v1/wardrobe             — гардероб пользователя
GET    /api/v1/recommendations      — история рекомендаций
POST   /api/v1/recommendations/generate — генерация новых
GET    /api/v1/recommendations/by-city   — по городу
POST   /api/v1/recommendations/{id}/favorite — в избранное
GET    /api/v1/weather/current      — текущая погода
```

### Безопасность
- JWT токены (Access: 1 час, Refresh: 90 дней)
- mTLS между сервисами
- Rate limiting (100 запросов/мин)
- Валидация всех входных данных

---

## 🤖 ML SERVICE (Python)

### Технологии
- **Python 3.11+**
- **FastAPI** — API для ML-моделей
- **CatBoost** — градиентный бустинг для ранжирования
- **Scikit-learn** — предобработка, метрики
- **Pandas / NumPy** — работа с данными

### ML-пайплайн
```
1. Retrieval (поиск кандидатов)
   └─ Фильтрация по погоде, сезону, стилю
   └─ 250 кандидатов из каталога

2. Ranking (ранжирование CatBoost)
   └─ Предсказание релевантности
   └─ Сортировка по score

3. Персонализация
   └─ Учёт предпочтений пользователя
   └─ История лайков/дизлайков
```

### Модели
- **CatBoost Classifier** — классификация подходящих вещей
- **CatBoost Ranker** — ранжирование лучших комбинаций
- **Weather-based filtering** — подбор по температуре/погоде

### Интеграция
- gRPC/HTTP API для бэкенда
- Кэширование рекомендаций (10 минут)
- Fallback на правила при недоступности ML

---

## 📊 БАЗЫ ДАННЫХ

### PostgreSQL (основная БД)
- **users** — профили пользователей
- **clothing_items** — каталог вещей (3000+ синтетических)
- **wardrobe_items** — гардероб пользователей
- **recommendations** — история рекомендаций
- **recommendation_items** — вещи в рекомендациях
- **achievements** — достижения
- **user_achievements** — прогресс пользователей
- **notifications** — уведомления
- **subscriptions** — подписки

### Redis (кэш/сессии)
- Сессии пользователей
- Rate limiting
- Кэш переводов (10 минут)
- Кэш погоды (10 минут)

### Kafka (события)
- `user.created` — регистрация пользователя
- `wardrobe.item_added` — добавление вещи
- `recommendation.generated` — создана рекомендация
- `notification.sent` — отправлено уведомление

---

## 🚀 ДЕПЛОЙ И ИНФРАСТРУКТУРА

### Развёртывание
- **k3s** — лёгкий Kubernetes для production
- **Docker** — контейнеризация всех сервисов
- **GitHub Actions** — CI/CD пайплайн
- **Istio** — service mesh (mTLS, traffic management)

### Компоненты
- **Backend** — Go API (реплицируется)
- **ML Service** — Python ML (реплицируется)
- **PostgreSQL** — база данных (StatefulSet)
- **Redis** — кэш (StatefulSet)
- **Kafka** — брокер сообщений
- **Frontend** — Flutter Web (Nginx)

### Мониторинг
- **Prometheus** — метрики
- **Grafana** — дашборды
- **Loki** — логи
- **Firebase Crashlytics** — краши клиента

---

## 🎯 КЛЮЧЕВЫЕ ФИЧИ ДЛЯ ПЛАКАТА

### 1. AI-рекомендации
> "Умный подбор одежды на основе погоды и стиля"

- CatBoost ранжирование
- Персонализация под пользователя
- Учёт температуры, влажности, ветра

### 2. Кроссплатформенность
> "Одно приложение для Web, Android и iOS"

- Flutter 3.24+
- 95% общего кода
- Нативная производительность

### 3. Офлайн-режим
> "Работает без интернета"

- Drift (SQLite) база
- Синхронизация при подключении
- Queue для отложенных операций

### 4. Безопасность
> "Защита данных на всех уровнях"

- JWT RS256 токены
- mTLS между сервисами
- Rate limiting

### 5. Событийная архитектура
> "Масштабируемость через Kafka"

- Асинхронная обработка
- Отказоустойчивость
- Легкое добавление новых фич

---

## 📈 МЕТРИКИ (для плаката)

### Технические
- **Время ответа API:** < 200ms (p95)
- **ML инференс:** < 100ms
- **Доступность:** 99.9%
- **Количество вещей:** 3000+ в каталоге
- **Токены:** Access 1h, Refresh 90 дней

### Бизнес-метрики (план)
- **DAU:** Daily Active Users
- **Конверсия:** Free → Premium
- **Retention:** Day 1, Day 7, Day 30

---

## 🎨 ВИЗУАЛИЗАЦИИ ДЛЯ ПЛАКАТА

### 1. Архитектурная схема
```
[Клиент Flutter] → [Go API] → [ML Service] → [PostgreSQL]
       ↓              ↓           ↓
   [Firebase]    [Kafka]    [Redis]
```

### 2. ML пайплайн
```
Погода + Профиль → Retrieval → Ranking → Персонализация → Рекомендация
```

### 3. Скриншоты приложения
- Главный экран с рекомендациями
- Экран гардероба
- CitySelector (выбор города)
- Профиль с достижениями

---

## 💡 УНИКАЛЬНЫЕ ОСОБЕННОСТИ (USP)

1. **Weather-based AI** — единственное приложение с погодными рекомендациями на CatBoost
2. **CitySelector** — выбор города для Web (Nominatim OSM API)
3. **Refresh токены 90 дней** — не нужно часто логиниться
4. **Офлайн-режим** — полная работа без интернета
5. **Service Mesh** — production-grade инфраструктура с Istio

---

## 📚 ТЕХНОЛОГИЧЕСКИЙ СТЕК (кратко)

| Компонент | Технологии |
|-----------|------------|
| **Client** | Flutter 3.7.0+, Riverpod, Go Router, Drift |
| **Backend** | Go 1.24.12, Fiber, Kafka, Redis, PostgreSQL |
| **ML** | Python 3.11+, FastAPI, CatBoost, Scikit-learn |
| **Infra** | k3s, Docker, Istio, Prometheus, Grafana |
| **Auth** | Firebase Auth, JWT RS256, OAuth 2.0 |
| **CI/CD** | GitHub Actions, Docker Hub |

---

## 🔗 ССЫЛКИ

- **GitHub:** https://github.com/ALEZOEX/OutFitStyle
- **Документация:** `/docs` в репозитории
- **API Docs:** Swagger на `/api/docs`

---

## 📝 ЧТО ВЫНЕСТИ НА ПЛАКАТ ( ТОП-5 )

1. **Архитектурная схема** — все 3 уровня (Client, Backend, ML)
2. **AI/ML пайплайн** — CatBoost ранжирование
3. **Кроссплатформенность** — Flutter + офлайн-режим
4. **Безопасность** — JWT RS256 + mTLS + Rate limiting
5. **Событийная архитектура** — Kafka + микросервисы

**Девиз проекта:**
> "Умный гардероб в твоём кармане — AI подберёт, погода подскажет!"
