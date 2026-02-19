# Troubleshooting — Решение проблем

## Содержание

1. [Проблемы с запуском](#проблемы-с-запуском)
2. [Проблемы с базой данных](#проблемы-с-базой-данных)
3. [Проблемы с аутентификацией](#проблемы-с-аутентификацией)
4. [Проблемы с ML-сервисом](#проблемы-с-ml-сервисом)
5. [Проблемы с Flutter клиентом](#проблемы-с-flutter-клиентом)
6. [Проблемы с Docker](#проблемы-с-docker)

---

## Проблемы с запуском

### API сервер не запускается

**Симптом:**
```
panic: dial tcp [::1]:5432: connect: connection refused
```

**Причина:** PostgreSQL не запущен или недоступен.

**Решение:**
```bash
# Проверить статус контейнера PostgreSQL
docker-compose ps postgres

# Если не запущен - перезапустить
docker-compose restart postgres

# Проверить логи
docker-compose logs postgres
```

### ML сервис недоступен

**Симптом:**
```
Error: Connection refused to localhost:5000
```

**Причина:** ML сервис не запущен или использует другой порт.

**Решение:**
```bash
# Проверить контейнер ML сервиса
docker-compose ps ml-service

# Проверить логи
docker-compose logs ml-service

# Убедиться что порт указан верно в .env
# ML_SERVICE_URL=http://localhost:5000
```

---

## Проблемы с базой данных

### Ошибки миграций

**Симптом:**
```
ERROR: relation "users" does not exist
```

**Причина:** Миграции не применены или применены не полностью.

**Решение:**
```bash
# Применить все миграции
cd server
migrate -path migrations -database "postgres://user:pass@localhost:5432/dbname?sslmode=disable" up

# Проверить статус миграций
migrate -path migrations -database "postgres://..." version

# Откатить последнюю миграцию (если нужно)
migrate -path migrations -database "postgres://..." down 1
```

### Ошибки подключения к БД

**Симптом:**
```
FATAL: password authentication failed for user "outfitstyle"
```

**Причина:** Неверный пароль или пользователь не существует.

**Решение:**
```bash
# Проверить переменные окружения в .env
DB_USER=postgres
DB_PASSWORD=your_secure_db_password
DB_NAME=outfitstyle

# Перезапустить контейнер БД
docker-compose restart postgres

# Проверить логи
docker-compose logs postgres
```

### Медленные запросы

**Симптом:** Запросы выполняются дольше 1 секунды.

**Решение:**
```sql
-- Включить логирование медленных запросов
ALTER SYSTEM SET log_min_duration_statement = 1000;
SELECT pg_reload_conf();

-- Проверить индексы
EXPLAIN ANALYZE <ваш запрос>;

-- Добавить индексы при необходимости
CREATE INDEX CONCURRENTLY idx_clothing_items_category ON clothing_items(category, subcategory);
```

---

## Проблемы с аутентификацией

### Google Sign-In не работает

**Симптом:**
```
Error: invalid_grant
```

**Причина:** Неверный Google Client ID или Secret.

**Решение:**
1. Проверьте credentials в [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
2. Убедитесь что redirect URI настроен правильно
3. Проверьте переменные окружения:
```env
GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
```

### JWT токен не валиден

**Симптом:**
```
Error: token is expired
```

**Причина:** Истек срок действия токена или неверный секрет.

**Решение:**
```bash
# Проверить настройки JWT в .env
JWT_SECRET=your_super_secret_jwt_key_that_is_at_least_32_characters_long
JWT_ACCESS_TOKEN_TTL=15m
JWT_REFRESH_TOKEN_TTL=720h

# Для RS256 проверить наличие ключей
ls -la config/jwt/
```

---

## Проблемы с ML-сервисом

### Модель не загружается

**Симптом:**
```
FileNotFoundError: [Errno 2] No such file or directory: 'models/model.cbm'
```

**Причина:** Файл модели отсутствует.

**Решение:**
```bash
# Проверить наличие модели
ls -la ml-service/models/

# Если модели нет - переобучить
cd ml-service
python train/train_ranker.py

# Или скопировать из бэкапа
cp /path/to/backup/model.cbm ml-service/models/
```

### ML сервис возвращает таймаут

**Симптом:**
```
context deadline exceeded (Client.Timeout exceeded)
```

**Причина:** ML сервис обрабатывает запрос слишком долго.

**Решение:**
1. Увеличить таймаут в Go API:
```env
ML_SERVICE_TIMEOUT=60s
```

2. Оптимизировать модель:
```bash
# Проверить размер модели
ls -lh ml-service/models/model.cbm

# Если модель большая - уменьшить количество признаков
```

3. Проверить логи ML сервиса:
```bash
docker-compose logs ml-service | grep ERROR
```

---

## Проблемы с Flutter клиентом

### Приложение не подключается к API

**Симптом:**
```
SocketException: Connection refused
```

**Решение:**
```bash
# Для Android эмулятора использовать
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080

# Для физического устройства использовать IP компьютера
flutter run --dart-define=API_BASE_URL=http://YOUR_IP:8080

# Проверить что API сервер запущен
curl http://localhost:8080/api/health
```

### Ошибки сборки Flutter

**Симптом:**
```
Error: The method 'xxx' isn't defined for the class 'yyy'
```

**Решение:**
```bash
# Очистить кэш
flutter clean
flutter pub get

# Перегенерировать код (если используется build_runner)
flutter pub run build_runner build --delete-conflicting-outputs

# Проверить версию Flutter
flutter --version
flutter upgrade
```

---

## Проблемы с Docker

### Контейнеры не запускаются

**Симптом:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:5432: bind: address already in use
```

**Причина:** Порт уже занят другим процессом.

**Решение:**
```bash
# Найти процесс занимающий порт
# Windows
netstat -ano | findstr :5432

# Остановить процесс или изменить порт в docker-compose.yml
```

### Контейнер постоянно перезапускается

**Симптом:**
```
Restarting (1) 2 seconds ago
```

**Решение:**
```bash
# Проверить логи контейнера
docker-compose logs <service_name>

# Проверить health check
docker-compose ps

# Проверить зависимости между сервисами
docker-compose up --abort-on-container-exit
```

### Нехватка места на диске

**Симптом:**
```
no space left on device
```

**Решение:**
```bash
# Очистить неиспользуемые образы
docker system prune -a

# Очистить volumes (осторожно: удалит данные!)
docker volume prune

# Проверить использование диска
docker system df
```

---

## Диагностика

### Полезные команды

```bash
# Проверить статус всех сервисов
docker-compose ps

# Просмотреть логи всех сервисов
docker-compose logs -f

# Просмотреть логи конкретного сервиса
docker-compose logs -f api

# Проверить использование ресурсов
docker stats

# Подключиться к контейнеру
docker-compose exec api bash

# Проверить сеть
docker-compose exec api ping postgres
```

### Health check эндпоинты

```bash
# API сервер
curl http://localhost:8080/api/health

# ML сервис
curl http://localhost:5000/health

# PostgreSQL
docker-compose exec postgres pg_isready -U postgres

# Redis
docker-compose exec redis redis-cli ping
```

---

## Сбор логов для отладки

### Включение debug логирования

```bash
# В .env установить
LOG_LEVEL=debug

# Перезапустить сервисы
docker-compose restart api ml-service
```

### Экспорт логов

```bash
# Сохранить логи в файл
docker-compose logs > logs.txt

# Логи за последний час
docker-compose logs --since 1h > logs_1h.txt
```

---

## Обратная связь

Если вы не нашли решение вашей проблемы:

1. Проверьте [GitHub Issues](https://github.com/your-org/outfitstyle/issues)
2. Создайте новый issue с подробным описанием проблемы
3. Приложите логи и шаги для воспроизведения

---

**Обновлено:** Февраль 2026
