

# 📦 Гайд по продакшен‑деплою OutfitStyle

Этот раздел описывает, как развернуть OutfitStyle в продакшене.

## Обзор архитектуры (prod)

В продакшене используется микросервисная архитектура:

1. **Go API‑сервер** – основной backend.
2. **ML‑сервис** – Python/Flask ML‑модуль.
3. **PostgreSQL** – основная БД приложения.
4. **Redis** – кэш и сессии/лимиты.
5. **Nginx** – reverse proxy + SSL‑терминация (если используется HTTPS).

Все сервисы упакованы в Docker‑образы и стартуют через `docker-compose` или Kubernetes.

---

## Предварительные требования

Перед деплоем нужно:

- установленный Docker и Docker Compose на сервере;
- домен для HTTPS (если нужен SSL);
- подготовленные переменные окружения:
    - настройки БД,
    - секреты JWT,
    - ключи для внешних API (OpenWeatherMap и т.п.);
- сгенерированные SSL‑сертификаты (если используете HTTPS через Nginx).

---

## Шаг 1. Подготовка переменных окружения

Создаём `.env.prod`:

```bash
cp infrastructure/docker-compose/.env.example infrastructure/docker-compose/.env.prod
```

Правим `infrastructure/docker-compose/.env.prod`:

```env
# База данных
DB_USER=prod_db_user
DB_PASSWORD=prod_db_password
DB_NAME=outfitstyle

# JWT
JWT_SECRET=prod_secure_jwt_secret

# Погода
WEATHER_API_KEY=your_openweathermap_api_key

# CORS
CORS_ALLOWED_ORIGINS=https://yourdomain.com

# Общий режим
ENVIRONMENT=production
```

---

## Шаг 2. Сборка продакшен‑образов

```bash
# Go API
cd server
docker build -t outfitstyle/api:latest -f Dockerfile.prod .

# ML-сервис
cd ../ml-service
docker build -t outfitstyle/ml-service:latest -f Dockerfile.prod .

# Marketplace-сервис (при необходимости)
cd ../marketplace-service
docker build -t outfitstyle/marketplace-service:latest -f Dockerfile.prod .
```

(Теги можно поменять на свои, например, с указанием версии.)

---

## Шаг 3. Запуск через docker-compose.prod.yml

```bash
cd infrastructure/docker-compose
docker compose -f docker-compose.prod.yml up -d
```

Проверка статусов:

```bash
docker compose -f docker-compose.prod.yml ps
```

Проверка health‑эндпоинтов:

```bash
curl http://yourdomain.com/health           # проксируется через Nginx на API
curl http://yourdomain.com/api/ml/health    # если пробрасываете ML напрямую или через под-путь
```

---

## Шаг 4. Логи и мониторинг

Просмотр логов:

```bash
docker compose -f docker-compose.prod.yml logs -f
docker compose -f docker-compose.prod.yml logs -f api
docker compose -f docker-compose.prod.yml logs -f ml-service
```

Мониторинг:

- `/metrics` на API‑сервере – метрики для Prometheus.
- Nginx‑логи – для анализа трафика и статуса.

---

## Чек‑лист готовности к продакшену

✅ **ML‑сервис**

- [x] `/health` реализован.
- [x] Метрики и логирование включены (по мере необходимости).
- [x] Обновление модели через файл/volume.
- [x] Продакшен‑Dockerfile.

✅ **Go API**

- [x] Обработка ошибок с человекочитаемыми сообщениями и корректными статусами.
- [x] Graceful shutdown (контекст с таймаутом, закрытие соединений).
- [x] Rate limiting и защита от DDoS на уровне middleware + Nginx.
- [x] CORS настроен только на доверенные origin’ы.

✅ **Инфраструктура**

- [x] `docker-compose.prod.yml` c отдельными сетями и volume’ами.
- [x] Nginx‑конфиг с SSL (Let’s Encrypt/Certbot или ваши сертификаты).
- [x] Health‑чеки для всех сервисов.
- [x] Мониторинг и алерты на основе метрик и логов.

---

## Поддержка и обслуживание

### Health‑чеки

- API‑сервер: `GET /health`
- ML‑сервис: `GET /health`
- (Nginx часто проксирует их наружу для систем мониторинга.)

### Метрики

- API:
    - `GET /metrics` – Prometheus‑формат
- ML‑сервис:
    - либо отдельный `/metrics`,
    - либо экспорт логов/метрик в общую систему.

### Резервные копии

Регулярно бэкапим:

- БД `PostgreSQL`:

  ```bash
  docker compose -f docker-compose.prod.yml exec postgres \
    pg_dump -U "$DB_USER" "$DB_NAME" > backup_$(date +%F).sql
  ```

- Модельные файлы (`ml-service/models/*`).
- Важные логи (если нужны для аналитики/отладки).

---

## Масштабирование

Для горизонтального масштабирования:

- в Docker Swarm / Kubernetes:
    - увеличиваем `replicas` API, ML‑сервиса;
    - ставим общий Redis/БД;
    - используем Ingress / LoadBalancer.

Для простого docker‑compose:

```yaml
services:
  api:
    deploy:
      replicas: 3
```

(в чистом docker‑compose `deploy`‑секция не обрабатывается; для реального масштабирования лучше Swarm/K8s.)

---

## Итог

- Архитектура разделена на:
    - Go API,
    - ML‑сервис,
    - marketplace‑сервис (каталог),
    - PostgreSQL,
    - Redis,
    - Nginx.
- Для разработки есть удобный `docker compose up --build`.
- Для продакшена – `docker-compose.prod.yml` + понятный набор ENV.
- ML‑сервис и API готовы к постепенному улучшению (переобучение на логах, расширение фичей и персонализации).

Дальше можно спокойно углубляться в качество модели (features, loss, A/B‑тесты), не трогая инфраструктурный скелет.