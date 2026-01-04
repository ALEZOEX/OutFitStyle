markdown
# 👔 OutfitStyle - Профессиональная архитектура рекомендательной системы

OutfitStyle - это масштабируемая архитектура рекомендательной системы для подбора одежды, реализующая концепцию Planner → Retrieval → Ranking с учётом приоритетов источников и норм для различных подкатегорий одежды.

## Особенности архитектуры

### 1. Централизованные нормы (Planner)
- Таблица `subcategory_specs` содержит нормы для каждой подкатегории: минимальную теплоту, рекомендуемый температурный диапазон, устойчивость к погодным условиям
- Planner использует эти нормы для генерации плана подбора одежды

### 2. Эффективное извлечение (Retrieval)
- Использует индексы для быстрого поиска кандидатов по плану
- Фильтрация по категории, подкатегории, диапазону температур и уровню теплоты

### 3. ML-ранжирование с учетом приоритетов (Ranking)
- Учет источников: user > manual > partner > synthetic
- Расширенные признаки для более точного предсказания

### 4. Расширенная схема данных
- Хранение материалов как массива (TEXT[])
- Поддержка норм по погодным условиям (дождь, снег, ветер)
- Четкая иерархия источников и принадлежности вещей

## 🔐 Безопасность и защита данных

- JWT-аутентификация с короткими токенами и refresh токенами
- Проверка принадлежности ресурсов: пользователь может получить/изменить только свои данные
- Rate limiting для защиты от DoS-атак
- Валидация всех входных параметров
- Защита от SQL-инъекций и XSS через подготовленные выражения и санитизацию
- Проверка принадлежности ресурсов при сохранении оценок: пользователь может оценить только свои рекомендации

---

Умное приложение для рекомендаций одежды с ML‑персонализацией.

## 🏗️ Архитектура системы

```text
outfitstyle/
├── client/                  # Flutter‑клиент (iOS/Android/Web)
├── server/                  # Go REST API (порт 8080)
│   ├── cmd/                 # Точка входа приложения
│   ├── internal/            # Внутренние пакеты
│   │   ├── api/             # HTTP‑слой (middleware, handlers)
│   │   ├── core/            # Бизнес‑логика (domain, services)
│   │   ├── infrastructure/  # Внешние зависимости (БД, HTTP‑клиенты)
│   │   └── pkg/             # Общие утилиты
│   ├── database/            # init.sql и миграции базы данных
│   ├── migrations/          # SQL миграции для расширения схемы
│   ├── scripts/             # Скрипты для разработки
│   ├── .env.example         # Пример конфигурации
│   ├── Makefile             # Сборка и запуск
│   ├── go.mod               # Зависимости Go
│   └── go.sum               # Контрольные суммы зависимостей
├── server/ml-service/       # Python ML‑сервис (порт 5000)
│   ├── api/                 # FastAPI приложение
│   │   └── main.py          # Точка входа FastAPI
│   ├── model/               # Модель, фичи, предиктор
│   │   ├── enhanced_predictor.py        # Улучшенный предиктор с приоритетами источников
│   │   ├── features_v2_with_priorities.py # Подготовка фичей с приоритетами и нормами
│   │   └── contracts/       # Контракты Python ↔ Go
│   │       └── rank_contract.py         # Определение контрактов для ML-ранжирования
│   ├── models/              # Обученные .pkl‑модели
│   ├── data/                # Датасеты (styles.csv и пр.)
│   └── scripts/             # Скрипты обучения
├── server/marketplace-service/  # Flask‑сервис каталога (порт 5002)
├── contracts/               # Контракты Go ↔ Python
│   └── ml_rank_contract.go  # Определение контрактов для ML-ранжирования
├── scripts/                 # Внешние скрипты (например, import_kaggle_styles.py)
├── docs/                    # Документация
│   ├── README.md            # Объединенная документация
│   ├── architecture.md      # Описание архитектуры
│   ├── import_guide.md      # Руководство по импорту данных
│   ├── professional_architecture.md  # Профессиональная архитектура
│   ├── backup_recovery.md   # Стратегия бэкапов и восстановления
│   ├── migration_strategy.md # Стратегия миграций БД
│   └── api/                 # API документация
│       └── README.md        # API эндпоинты
├── .github/                 # Шаблоны для GitHub
├── docker-compose.yml       # Оркестрация всех сервисов
├── Dockerfile.ml-service    # Dockerfile для ML-сервиса
├── go.work                  # Go workspace файл для модулей
└── PRODUCTION_ARCHITECTURE.md # Документация по production архитектуре
```

## 🔐 Безопасность и аутентификация

### 1. JWT-аутентификация
- Короткие access token (24 часа) + refresh token (7 дней)
- Подпись токенов с использованием безопасного секрета
- Проверка токенов через middleware

### 2. Zero Friction Authentication (Бесфрикционная аутентификация)
- **Silent Login (Тихий вход)**: При открытии приложения проверяется валидность существующего токена, позволяя пользователю мгновенно войти без повторного ввода учетных данных
- **Smart Account Linking (Умная связка аккаунтов)**: При входе через Google с email, который уже используется в системе, аккаунты автоматически объединяются
- **Token Validation Endpoint**: Новый эндпоинт `/api/v1/auth/validate` позволяет клиенту проверить валидность токена без необходимости в полной аутентификации
- **Google Sign-In**: Поддержка входа через Google с автоматической синхронизацией профиля (имя, аватар)

### 3. Авторизация
- Пользователи могут получить/изменить только свои данные
- Проверка через middleware: запрашиваемый user_id должен совпадать с аутентифицированным
- Rate limiting для защиты от аттак

### 4. Защита приватных данных
- Нельзя получить чужие профили, достижения, рейтинги и т.д.
- Все endpoints требуют аутентификации, кроме публичных
- Валидация идентификаторов и параметров запросов

---

## 🚀 Запуск

### Подготовка

1. Установите зависимости:
   - Docker и Docker Compose
   - Go 1.24+
   - Python 3.11+

2. Скопируйте файл `.env.example` в `.env` и укажите:
   - `DB_PASSWORD` - пароль для базы данных
   - `JWT_SECRET` - секретный ключ для JWT (не менее 32 символов)
   - `YANDEX_TRANSLATE_API_KEY` - API ключ для Yandex Translate (получите в облаке Яндекса)
   - `WEATHER_API_KEY` - ключ для OpenWeatherMap API
   - Другие настройки по необходимости

### Запуск с Docker Compose

1. **Создайте файл `.env`** в корне проекта и укажите:
   ```bash
   cp .env.example .env
   ```
   Затем установите:
   - `DB_PASSWORD` - надежный пароль для базы данных
   - `JWT_SECRET` - секретный ключ для JWT (не менее 32 символов)
   - `YANDEX_TRANSLATE_API_KEY` - API ключ для Yandex Cloud Translate (получите в облаке Яндекса)
   - `WEATHER_API_KEY` - ключ для OpenWeatherMap API

2. **Выполните миграции базы данных**:
   ```bash
   docker-compose run --rm api-gateway migrate
   ```

3. **Запустите все сервисы**:
   ```bash
   docker-compose up -d
   ```

4. **API будет доступен на** `http://localhost:8080`
   - Swagger UI: `http://localhost:8080/swagger/index.html`
   - Health check: `http://localhost:8080/health`

## 🚀 Production-готовность

### Архитектура V2: Planner → Retrieval → Ranking
- **Planner**: Генерирует план подбора на основе норм подкатегорий
- **Retrieval**: Эффективно извлекает кандидатов из базы данных
- **Ranking**: ML-ранжирование с учетом приоритетов источников

### Безопасность
- JWT-аутентификация с короткими токенами
- Пользователь может получить/изменить только свои данные
- Rate limiting для защиты от DDoS-атак
- Валидация всех входных параметров
- Защита от SQL-инъекций и XSS
- Проверка принадлежности ресурсов при сохранении оценок: пользователь может оценить только свои рекомендации

### Система перевода
- Интеграция с Yandex Cloud Translate API
- Кэширование переводов через Redis на 24 часа
- Поддержка многоязычности с встроенными переводами для часто используемых терминов
- Поддержка русского/английского языка для названий одежды

### ML-ранжирование
- Градиентный бустинг для точных рекомендаций
- Учет предпочтений пользователя
- Ранжирование с учетом приоритетов источников (пользовательские > синтетические)

### Наблюдаемость
- Prometheus метрики для мониторинга
- Структурированные логи через Zap
- Health check endpoints
- Docker-контейнеризация всех сервисов

### Запуск вручную (для разработки)

1. Запустите зависимости:
   ```bash
   docker-compose up -d postgres redis
   ```

2. Установите переменные окружения:
   ```bash
   export DB_HOST=localhost
   export DB_PORT=5432
   export DB_USER=postgres
   export DB_PASSWORD=your_password
   export DB_NAME=outfitstyle
   export ML_SERVICE_URL=http://localhost:5000
   export REDIS_URL=redis://localhost:6379
   export JWT_SECRET=your_secret_key
   export YANDEX_TRANSLATE_API_KEY=your_yandex_translate_key
   export WEATHER_API_KEY=your_weather_api_key
   ```

3. Запустите ML-сервис:
   ```bash
   cd server/ml-service
   pip install -r requirements.txt
   python api/main.py
   ```

4. В другом терминале запустите Go-сервер:
   ```bash
   cd server
   go run cmd/server/main.go
   ```

### Через Docker (рекомендуется)

```bash
# Запуск всех сервисов с пересборкой
docker compose up --build

# Запуск в фоновом режиме
docker compose up -d --build
```

Все сервисы:

- API‑сервер: `http://localhost:8080`
- ML‑сервис: `http://localhost:5000`
- Marketplace‑сервис: `http://localhost:5002`
- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`

Проверка:

```bash
curl http://localhost:8080/health
curl http://localhost:5000/health
curl http://localhost:5002/health
```

---

### Ручной запуск (без полного docker compose)

#### 1. База данных (PostgreSQL)

```bash
# Запуск только Postgres через docker compose
docker compose up -d postgres

# Применение миграций (одна миграция с полной схемой)
psql -h localhost -U Admin -d outfitstyle -f server/migrations/0001_init_schema.sql
```

#### 2. Импорт Kaggle датасета (однократно)

```bash
# Установка зависимостей
cd scripts
pip install -r requirements.txt

# Запуск импорта
python import_kaggle_styles.py
```

#### 3. API (Go)

```bash
cd server
cp .env.example .env     # настроить при необходимости
make run                 # или go run ./cmd/server
```

#### 4. ML‑сервис (Python)

```bash
cd server/ml-service
pip install -r requirements.txt
python main.py           # поднимется на http://localhost:5000
```

#### 5. Marketplace‑сервис (Python)

```bash
cd server/marketplace-service
pip install -r requirements.txt
python main.py           # поднимется на http://localhost:5002
```

#### 6. Клиент (Flutter)

```bash
cd client
flutter pub get
flutter run              # эмулятор Android/iOS или Web
```

> Для Android‑эмулятора backend доступен по `http://10.0.2.2:8080`
> (в коде клиента это уже учтено через AppConfig).

---

## 📚 Технологии

### Backend

- **Go 1.21+** – основной REST API
- **Python 3.9+/3.11** – ML‑сервис
- **PostgreSQL 15** – основная БД
- **Redis 7** – кэш и rate limiting
- **Docker / Docker Compose** – контейнеризация
- **(опционально) Kubernetes** – оркестрация
- **Prometheus** – метрики
- **Gorilla Mux** – маршрутизация в Go
- **JWT** – аутентификация/авторизация

### Frontend

- **Flutter 3.x** – кроссплатформенный клиент:
    - Android
    - iOS
    - Web

---

## 🎯 Основные фичи

- 🌤 Интеграция с реальной погодой (OpenWeatherMap)
- 🤖 ML‑персонализация:
    - Professional approach: Unified catalog → Retrieval → Ranking
    - Gradient Boosting (основной алгоритм)
    - приоритеты источников: wardrobe → catalog → kaggle_seed
    - резервная rule‑based логика, если модель недоступна
- 👤 Профиль пользователя:
    - возрастной диапазон,
    - стиль (casual/formal/…),
    - чувствительность к холоду.
- 👔 Личный гардероб:
    - хранение вещей пользователя в `clothing_items`,
    - учёт гардероба при рекомендациях с приоритетом.
- 🛒 Каталог (псевдо‑маркетплейс):
    - импорт одежды из Kaggle‑датасета в каталог как `source='kaggle_seed'`,
    - смешанный режим рекомендаций: гардероб + каталог + датасет.
- 📊 История рекомендаций и оценок:
    - `recommendations` / `recommendation_items`,
    - `user_ratings` / избранное.
- 📈 Обучение на отзывах:
    - ML‑сервис умеет переобучаться на логах.
- 🔐 JWT‑аутентификация (Go‑сервер).
- 🛡 Rate limiting, логирование, метрики Prometheus.
- 🐳 Полная Docker‑поддержка для dev/prod.

---

## 🗄️ База данных (схема)

Реализует архитектуру Planner → Retrieval → Ranking с централизованными нормами и приоритетами источников.

### Основные таблицы

- `users` – пользователи
- `subcategory_specs` – словарь подкатегорий с нормами для Planner'а:
    - `category`, `subcategory`
    - `warmth_min`, `temp_min_reco`, `temp_max_reco`
    - `rain_ok`, `snow_ok`, `wind_ok`
- `clothing_items` – каталог одежды с расширенными атрибутами:
    - `category`, `subcategory` (связаны с subcategory_specs)
    - `gender`, `style`, `usage`, `season`, `base_colour`
    - `formality_level` (1-5), `warmth_level` (1-10)
    - `min_temp`, `max_temp` (температурные диапазоны)
    - `materials` (массив TEXT[])
    - `source` (enum: synthetic, user, partner, manual)
    - `is_owned` (флаг принадлежности пользователю)
- `wardrobe_items` – связь пользователей с их личными вещами

### Сервисные таблицы

- `weather_data` – исторические погодные данные
- `recommendations` – факты выдачи рекомендаций
- `recommendation_items` – вещи внутри конкретной рекомендации
- `user_favorites` – избранные рекомендации
- `achievements`, `user_achievements` – ачивки
- `user_ratings` – оценки рекомендаций

Схема инициализируется одной миграцией `server/migrations/0001_init_schema.sql`, которая загружает полную структуру из `server/database/init.sql`.

---

## 🧠 ML‑сервис (обновленный)

### Профессиональная архитектура: Retrieval → Ranking

#### 1. Retrieval (подбор кандидатов)
- Сначала ищутся вещи из личного гардероба пользователя
- Затем добавляются вещи из каталога для недостающих категорий
- Наконец, добавляются "образцовые" вещи из Kaggle-датасета для полного покрытия
- Всё через эффективные SQL-запросы к `clothing_items`

#### 2. Ranking (ранжирование)
- ML-модель учитывает приоритеты источников:
    - +α к score, если `is_owned = True` и вещь подходит по погоде (личные вещи)
    - чуть меньший приоритет для catalog по сравнению с wardrobe
    - Kaggle_seed — базовая линия (0)
- Бинарный признак `is_owned` и one-hot кодирование `source` используются как фичи
- Модель ранжирует отобранные кандидаты (до 1000, а не 44k)

#### Что делает
- принимает запросы на `/api/ml/recommend`:
    - `user_id`, погодные данные, опционально `source` (`wardrobe` / `catalog` / `mixed`);
- поднимает профиль пользователя из `user_profiles`;
- получает список кандидатов через Retrieval (из базы данных, не из CSV!)
- готовит фичи (погода + пользователь + вещь + source + is_owned);
- прогоняет через ML‑модель (Gradient Boosting);
- собирает полный образ (outerwear + top + bottom + footwear + аксессуары);
- сохраняет факт рекомендации в БД;
- возвращает JSON с выбранными предметами и score.

### Алгоритмы

- **Gradient Boosting Classifier** – основной алгоритм склонности «подойдёт / не подойдёт».
- **Rule‑based fallback** – если модель сломалась или не обучена:
    - подбирает вещи по температурному диапазону, теплоте (`warmth_level`) и погоде.
- (Потенциал) RandomForest / нейросеть – экспериментальные варианты (отдельные модели).

### API эндпоинты (ML‑сервис)

```text
POST /api/ml/recommend      # Получить рекомендации
POST /api/ml/train          # Переобучить модель по логам
GET  /health                # Проверка состояния ML-сервиса
```

---

## 📱 Клиент (Flutter) (обновленный)

### Возможности

- Авторизация / регистрация (email+password, код подтверждения; Google Sign‑In – для Web).
- Получение рекомендаций по текущей погоде и городу.
- Просмотр состава комплекта с разбивкой по источникам:
    - "Что из твоего гардероба" (isOwned == true)
    - "Что стоит докупить" (isOwned == false и source != 'kaggle_seed')
    - "Образцовые варианты" (source == 'kaggle_seed')
- Оценка рекомендаций (лайк/оценка) и избранное.
- История рекомендаций.
- Редактирование профиля (предпочтения по стилю, чувствительность к холоду).
- Визуализация «уверенности» модели:
    - прогресс‑бары, «кольца уверенности».

### Обновленная модель данных

```dart
class ClothingItem {
  final int id;
  final String name;
  final String category;
  final String? subcategory;
  final String source;   // 'wardrobe', 'catalog', 'kaggle_seed'
  final bool isOwned;
  final double? minTemp;
  final double? maxTemp;
  final int warmthLevel;
  final int formalityLevel;
  final String iconEmoji;
  // ...
}
```

### Поддерживаемые платформы

- Android (эмулятор и реальные устройства)
- iOS (симулятор и реальные устройства)
- Web (Chrome/Firefox/Safari/Edge)

---

## 🔧 Конфигурация (основные ENV для dev)

```bash
# API
HOST=0.0.0.0
PORT=8080

# База данных
DB_HOST=postgres
DB_PORT=5432
DB_USER=Admin
DB_PASSWORD=password
DB_NAME=outfitstyle
DB_SSL_MODE=disable

# Redis
CACHE_ENABLED=true
REDIS_URL=redis://redis:6379
CACHE_EXPIRATION=300

# OpenWeatherMap
WEATHER_API_KEY=your_openweather_api_key
WEATHER_API_URL=https://api.openweathermap.org/data/2.5
WEATHER_API_TIMEOUT=10

# ML-сервис
ML_SERVICE_URL=http://ml-service:5000
ML_SERVICE_TIMEOUT=30

# JWT
JWT_SECRET=your-jwt-secret-key
```

---

## 📈 Обучение модели (концептуально)

1. Пользователь получает рекомендации (Go‑сервер + ML‑сервис логируют их).
2. Пользователь оценивает рекомендации / добавляет в избранное.
3. ML‑сервис периодически собирает логи (`recommendations + user_ratings`), строит тренировочный датасет.
4. Скрипт обучения (`scripts/train_from_logs.py`) переобучает модель и сохраняет новый `.pkl`.
5. При старте ML‑сервис подхватывает актуальную модель; качество рекомендаций постепенно улучшается.

---

## 🧪 Тестирование и отладка ML‑API

Примеры ручной проверки ML‑сервиса:

```bash
# Проверка состояния
curl http://localhost:5000/health

# Получение рекомендаций (через сервер)
curl "http://localhost:8080/api/v1/recommendations?city=Moscow&user_id=1"

# Прямой вызов ML-сервиса (если нужно обойти Go-сервер)
curl -X POST http://localhost:5000/api/ml/recommend \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "weather": {
      "location": "Moscow",
      "temperature": 5,
      "feels_like": 3,
      "weather": "Облачно",
      "humidity": 70,
      "wind_speed": 5
    },
    "source": "mixed"
  }'
```

---

## 🚀 Продакшен‑деплой

Для подробного гида см. файл
`docs/PRODUCTION_DEPLOYMENT.md`.

Кратко:

- отдельный `docker-compose.prod.yml` / Kubernetes‑манифесты;
- Nginx как reverse‑proxy и SSL‑терминация;
- сборка прод‑образов:
    - `server/Dockerfile.prod`,
    - `ml-service/Dockerfile.prod`,
    - (опционально) client web build;
- переменные окружения для прод окружения — в `infrastructure/docker-compose/.env.prod`.

---

## 📚 Документация

Вся документация собрана в директории `docs/`:

- `docs/README.md` — объединенная документация
- `docs/architecture.md` — подробное описание архитектуры
- `docs/import_guide.md` — руководство по импорту данных
- `docs/professional_architecture.md` — описание профессионального подхода
- `docs/api/README.md` — API документация