# Развёртывание OutfitStyle на VPS с 4 GB RAM (k3s)

Пошаговая инструкция по развёртыванию платформы OutfitStyle на VPS тарифе LC-2 (2 ядра, 4 GB RAM, ~280₽/мес).

> **Примечание:** Ubuntu 24.04 без лишних панелей — только k3s.

## Содержание

1. [Покупка сервера](#1-покупка-сервера)
2. [Подключение по SSH](#2-подключение-по-ssh)
3. [Установка k3s](#3-установка-k3s)
4. [Настройка secrets.yaml](#4-настройка-secretsyaml)
5. [Деплой скриптом](#5-деплой-скриптом)
6. [Проверка работы](#6-проверка-работы)
7. [Проброс портов (для разработки)](#7-проброс-портов-для-разработки)

---

## 1. Покупка сервера

### Рекомендуемые характеристики

| Параметр | Значение | Примечание |
|----------|----------|------------|
| CPU | 2 ядра | Минимум для k3s + приложений |
| RAM | 4 GB | Обязательно + swap 2GB |
| Disk | 40-80 GB SSD | Для БД, логов, образов |
| ОС | **Ubuntu 24.04 LTS** | Выбери при создании |
| Локация | Ближайшая к пользователям | Для минимальной задержки |

### Провайдеры (бюджетные)

| Провайдер | Тариф | Цена/мес | Примечание |
|-----------|-------|----------|------------|
| **Timeweb Cloud** | LC-2 | ~280₽ | ✅ Рекомендуется |
| Aeza | VPS-2 | ~250₽ | Дешевле |
| Selectel | Cloud-2 | ~300₽ | Надёжно |

> ⚠️ **Не бери тариф с 2 GB RAM** — не хватит для проекта.

---

## 2. Подключение по SSH

```bash
# Подключение к серверу
ssh root@<ваш-ip>
```

### Первоначальная настройка (5 минут)

```bash
# 1. Обновление пакетов
apt update && apt upgrade -y

# 2. Установка утилит
apt install -y curl git netcat-openbsd

# 3. Настройка swap 2GB (обязательно для 4 GB RAM!)
fallocate -l 2G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 4. Проверка
free -h
# Должно показать: Swap: 2.0G
```

---

## 3. Установка k3s

k3s — лёгкий Kubernetes для production на edge-устройствах и VPS.

```bash
# Установка k3s (одной командой)
curl -sfL https://get.k3s.io | sh -
```

### Проверка установки

```bash
kubectl get nodes
```

> k3s автоматически создаёт kubeconfig. Для root пользователя конфиг доступен по пути `/etc/rancher/k3s/k3s.yaml`.

---

## 4. Настройка secrets.yaml

### Шаг 4.1: Клонирование репозитория

```bash
# На сервере
git clone <ваш-repo-url> outfitstyle
cd outfitstyle
```

### Шаг 4.2: Создание secrets.yaml

```bash
# Копирование примера
cp k8s/secrets.yaml.example k8s/secrets.yaml

# Редактирование
nano k8s/secrets.yaml
```

### Шаг 4.3: Заполнение секретов

| Ключ | Описание | Пример |
|------|----------|--------|
| `database-url` | Connection string PostgreSQL | `postgresql://user:pass@postgres:5432/outfitstyle` |
| `jwt-secret` | Секрет для JWT (мин. 32 символа) | `x7K9mP2nQ5wR8tY3vL6jH4cF1bN0aS7d` |
| `openweather-api-key` | API ключ погоды | Получите на openweathermap.org |
| `db-user` | Пользователь БД | `outfitstyle` |
| `db-password` | Пароль БД | Случайная строка 20+ символов |
| `db-name` | Имя БД | `outfitstyle` |
| `redis-url` | Redis connection | `redis://redis:6379` |
| `s3-endpoint` | S3 endpoint | `https://s3.timeweb.com` |
| `s3-access-key` | S3 access key | Из панели провайдера |
| `s3-secret-key` | S3 secret key | Из панели провайдера |

### Генерация случайных строк

```bash
# JWT secret (32 символа)
openssl rand -hex 16

# Пароль БД (24 символа)
openssl rand -base64 18
```

---

## 5. Деплой скриптом

### Шаг 5.1: Подготовка

```bash
# Перейдите в директорию проекта
cd /path/to/outfitstyle

# Убедитесь, что скрипт исполняемый
chmod +x scripts/deploy-k8s.sh
```

### Шаг 5.2: Запуск деплоя

```bash
# Запуск скрипта деплоя
./scripts/deploy-k8s.sh
```

### Шаг 5.3: Ожидаемый вывод

```
🚀 Деплой OutfitStyle на k3s...
📦 Создание namespace...
🔐 Применение секретов...
💾 Создание PersistentVolumeClaim...
🔄 Применение миграций базы данных...
⏳ Ожидание завершения миграций (до 300 секунд)...
✅ Миграции завершены успешно.
🚀 Деплой основных сервисов (LC-2 оптимизация)...
🌐 Деплой nginx...
✅ Деплой завершён!
```

### Шаг 5.4: Проверка подов

```bash
kubectl get pods -n outfitstyle

# Ожидаемый статус:
# NAME                          READY   STATUS    RESTARTS   AGE
# api-xxxxx                     1/1     Running   0          2m
# ml-service-xxxxx              1/1     Running   0          2m
# postgres-xxxxx                1/1     Running   0          2m
# redis-xxxxx                   1/1     Running   0          2m
# nginx-xxxxx                   1/1     Running   0          2m
```

---

## 6. Проверка работы

### Диагностика подов

```bash
# Статус всех подов
kubectl get pods -n outfitstyle

# Детали конкретного пода
kubectl describe pod -n outfitstyle api-xxxxx

# Логи API
kubectl logs -n outfitstyle -l app=api

# Логи ML-сервиса
kubectl logs -n outfitstyle -l app=ml-service

# Логи PostgreSQL
kubectl logs -n outfitstyle -l app=postgres
```

### Проверка сервисов

```bash
kubectl get svc -n outfitstyle
```

### Проверка миграций

```bash
# Статус job миграций
kubectl get jobs -n outfitstyle

# Если миграции не завершены
kubectl logs -n outfitstyle job/migrate
```

### Тестирование API

```bash
# Health endpoint (через port-forward)
curl http://localhost:8080/health

# Swagger UI (если включён)
open http://localhost:8080/swagger/index.html
```

---

## 7. Проброс портов (для разработки)

Для доступа к сервисам с локальной машины:

```bash
# На локальной машине
chmod +x scripts/k8s-port-forward.sh
./scripts/k8s-port-forward.sh
```

### Доступные эндпоинты

| Сервис | Локальный порт | Описание |
|--------|----------------|----------|
| API | http://localhost:8080 | Основное API |
| ML Service | http://localhost:8000 | ML инференс |
| PostgreSQL | localhost:5432 | База данных (отладка) |
| Redis | localhost:6379 | Кэш (отладка) |
| Nginx | http://localhost:8081 | Reverse proxy |

---

## Приложение A: Полезные команды

### Мониторинг ресурсов

```bash
# Использование CPU/RAM подами
kubectl top pods -n outfitstyle

# Использование узлами
kubectl top nodes

# Статистика swap
free -h
```

### Перезапуск сервисов

```bash
# Перезапуск deployment
kubectl rollout restart deployment/api -n outfitstyle
kubectl rollout restart deployment/ml-service -n outfitstyle

# Откат к предыдущей версии
kubectl rollout undo deployment/api -n outfitstyle
```

### Резервное копирование БД

```bash
# Дамп PostgreSQL
kubectl exec -n outfitstyle postgres-xxxxx -- \
  pg_dump -U outfitstyle outfitstyle > backup.sql

# Восстановление
kubectl exec -n outfitstyle postgres-xxxxx -- \
  psql -U outfitstyle outfitstyle < backup.sql
```

### Очистка ресурсов

```bash
# Удаление namespace (внимание: удалит всё!)
kubectl delete namespace outfitstyle

# Удаление PVC (данные будут потеряны!)
kubectl delete pvc -n outfitstyle postgres-data
kubectl delete pvc -n outfitstyle redis-data
```

---

## Приложение B: Решение проблем

### Поды не запускаются

```bash
# Проверка событий
kubectl get events -n outfitstyle --sort-by='.lastTimestamp'

# Проверка ресурсов узла
kubectl describe node <node-name>
```

### Ошибки миграций

```bash
# Проверка подключения к БД
kubectl exec -n outfitstyle api-xxxxx -- \
  nc -zv postgres 5432

# Логи миграции
kubectl logs -n outfitstyle job/migrate
```

### Недостаточно памяти

```bash
# Проверка использования памяти
kubectl top pods -n outfitstyle

# Увеличение swap (на сервере)
# См. scripts/setup-swap.sh
```

---

## Приложение C: Обновление приложения

```bash
# 1. Собрать новый образ
docker build -t outfitstyle-backend:latest ./server

# 2. Запушить в registry
docker push outfitstyle-backend:latest

# 3. Обновить deployment
kubectl set image deployment/api api=outfitstyle-backend:latest -n outfitstyle

# 4. Проверить статус
kubectl rollout status deployment/api -n outfitstyle
```

---

## Контакты и поддержка

- Документация: `/docs`
- Issues: GitHub Issues
- Чат: [ссылка на чат команды]
