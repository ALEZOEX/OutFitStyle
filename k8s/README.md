# Развёртывание OutfitStyle в Kubernetes (k3s)

Этот каталог содержит манифесты Kubernetes для развёртывания платформы OutfitStyle на сервере с k3s.

## 📋 Требования

- Kubernetes кластер (k3s v1.34.4+)
- `kubectl` настроен на подключение к кластеру
- Docker образы для backend и ml-service (или используйте плейсхолдеры)

## 🏗 Архитектура развёртывания

```
OutFitStyle.play2go.cloud
         │
         ▼
┌────────────────────────┐
│   Traefik Ingress      │
│   (SSL + маршрутизация)│
└───────────┬────────────┘
            │
    ┌───────┴────────┐
    ▼                ▼
┌─────────┐    ┌──────────────┐
│ Landing │    │ Flutter Web  │
│  /      │    │  /app        │
└─────────┘    └──────────────┘
                      │
                      ▼
              ┌───────────────┐
              │   Go Backend  │
              │     /api      │
              └───────┬───────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌────────────┐
│  PostgreSQL  │ │  Redis   │ │ ML-service │
│   (данные)   │ │  (кэш)   │ │ (Python)   │
└──────────────┘ └──────────┘ └────────────┘
```

## 📁 Структура файлов

```
k8s/
├── namespace.yaml              # Namespace для приложения
├── secrets.yaml.example        # Шаблон для секретов (скопировать в secrets.yaml)
├── landing-page-configmap.yaml # Лендинг страница (ConfigMap)
├── postgres.yaml               # PostgreSQL Deployment + Service + PVC
├── redis.yaml                  # Redis Deployment + Service + PVC
├── backend.yaml                # Go Backend Deployment + Service
├── ml-service.yaml             # Python ML Service Deployment + Service
├── frontend.yaml               # Nginx Frontend (Landing + Flutter Web)
├── ingress.yaml                # Traefik Ingress с маршрутизацией
└── deploy.sh                   # Скрипт автоматического развёртывания
```

## 🚀 Быстрый старт

### 1. Настройка секретов

Скопируйте шаблон и заполните своими значениями:

```bash
cp secrets.yaml.example secrets.yaml
nano secrets.yaml
```

**Необходимые секреты:**

| Ключ | Описание | Пример |
|------|----------|--------|
| `db-name` | Имя базы данных | `outfitstyle` |
| `db-user` | Пользователь БД | `outfitstyle` |
| `db-password` | Пароль БД | `secure-password-here` |
| `database-url` | URL подключения к БД | `postgres://user:pass@postgres:5432/dbname?sslmode=disable` |
| `jwt-secret` | Секрет для JWT токенов | `your-super-secret-jwt-key` |
| `openweather-api-key` | API ключ погоды | `your-openweather-api-key` |

### 2. Развёртывание

```bash
# Сделать скрипт исполняемым
chmod +x deploy.sh

# Запустить развёртывание
./deploy.sh apply
```

Или вручную применить манифесты:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f secrets.yaml
kubectl apply -f landing-page-configmap.yaml
kubectl apply -f postgres.yaml
kubectl apply -f redis.yaml
kubectl apply -f backend.yaml
kubectl apply -f ml-service.yaml
kubectl apply -f frontend.yaml
kubectl apply -f ingress.yaml
```

### 3. Проверка статуса

```bash
# Проверить поды
kubectl get pods -n outfitstyle

# Проверить сервисы
kubectl get svc -n outfitstyle

# Проверить ingress
kubectl get ingress -n outfitstyle

# Использовать скрипт
./deploy.sh status
```

### 4. Доступ к приложению

После развёртывания приложение доступно по адресу:

- **Лендинг**: http://OutFitStyle.play2go.cloud/
- **Приложение**: http://OutFitStyle.play2go.cloud/app
- **API**: http://OutFitStyle.play2go.cloud/api

## 🔧 Управление

### Проверка логов

```bash
# Backend
kubectl logs -n outfitstyle -l app=backend -f

# ML Service
kubectl logs -n outfitstyle -l app=ml-service -f

# Frontend
kubectl logs -n outfitstyle -l app=frontend -f

# PostgreSQL
kubectl logs -n outfitstyle -l app=postgres -f

# Redis
kubectl logs -n outfitstyle -l app=redis -f
```

### Масштабирование

```bash
# Backend (2 реплики по умолчанию)
kubectl scale deployment backend -n outfitstyle --replicas=3

# Frontend (2 реплики по умолчанию)
kubectl scale deployment frontend -n outfitstyle --replicas=4
```

### Откат развёртывания

```bash
# Удалить все ресурсы (кроме PVC)
./deploy.sh rollback

# Или вручную
kubectl delete -f ingress.yaml
kubectl delete -f frontend.yaml
kubectl delete -f ml-service.yaml
kubectl delete -f backend.yaml
kubectl delete -f redis.yaml
kubectl delete -f postgres.yaml
kubectl delete -f landing-page-configmap.yaml
kubectl delete -f secrets.yaml
kubectl delete -f namespace.yaml
```

### Полная очистка (включая данные)

```bash
# Удалить всё включая PVC
./deploy.sh cleanup
```

## 📊 Ресурсы (лимиты)

| Компонент | CPU (запрос/лимит) | RAM (запрос/лимит) |
|-----------|-------------------|-------------------|
| PostgreSQL | 250m / 500m | 256Mi / 512Mi |
| Redis | 50m / 100m | 64Mi / 128Mi |
| Backend (каждая реплика) | 150m / 300m | 128Mi / 256Mi |
| ML Service | 250m / 500m | 256Mi / 512Mi |
| Frontend (каждая реплика) | 50m / 100m | 64Mi / 128Mi |

**Итого (минимум):** ~1.5 vCPU / ~1.5GB RAM  
**Итого (максимум):** ~2.5 vCPU / ~2.5GB RAM

## 🔍 Мониторинг

### Prometheus метрики

Backend экспортирует метрики Prometheus на эндпоинте `/metrics`:

```bash
# Проверить метрики
kubectl port-forward -n outfitstyle svc/backend 8080:80
curl http://localhost:8080/metrics
```

### Health checks

| Эндпоинт | Описание |
|----------|----------|
| `/healthz` | Liveness probe (жив ли сервис) |
| `/readyz` | Readiness probe (готов ли принимать запросы) |

## 🔄 Обновление образов

```bash
# Обновить образ backend
kubectl set image deployment/backend backend=outfitstyle-backend:v1.2.0 -n outfitstyle

# Обновить образ ml-service
kubectl set image deployment/ml-service ml-service=outfitstyle-ml-service:v1.2.0 -n outfitstyle

# Отследить статус
kubectl rollout status deployment/backend -n outfitstyle
kubectl rollout status deployment/ml-service -n outfitstyle
```

## 🐛 Troubleshooting

### Поды не запускаются

```bash
# Проверить события
kubectl get events -n outfitstyle --sort-by='.lastTimestamp'

# Проверить логи
kubectl describe pod <pod-name> -n outfitstyle
```

### Проблемы с подключением к БД

```bash
# Проверить переменные окружения
kubectl exec -n outfitstyle deployment/backend -- env | grep DATABASE

# Проверить подключение из backend
kubectl exec -n outfitstyle deployment/backend -- nc -zv postgres 5432
```

### Ingress не работает

```bash
# Проверить Traefik
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Проверить конфигурацию ingress
kubectl describe ingress outfitstyle-ingress -n outfitstyle
```

## 📝 Примечания

1. **Flutter Web**: В текущей версии используется placeholder. После сборки Flutter Web замените `app-index.html` в ConfigMap `frontend-app-placeholder` на реальный билд.

2. **SSL/TLS**: Для продакшена рекомендуется настроить SSL сертификаты через cert-manager или вручную добавить TLS secret.

3. **Backup**: Не забывайте регулярно делать бэкапы PostgreSQL:
   ```bash
   kubectl exec -n outfitstyle deployment/postgres -- pg_dump -U $POSTGRES_USER $POSTGRES_DB > backup.sql
   ```

4. **Безопасность**: 
   - Никогда не коммитьте `secrets.yaml` в git
   - Используйте внешнее хранилище секретов (Vault) для продакшена
   - Настройте NetworkPolicies для ограничения трафика между сервисами

## 📚 Дополнительные ресурсы

- [Документация k3s](https://docs.k3s.io/)
- [Документация Traefik](https://doc.traefik.io/traefik/)
- [Основная документация OutfitStyle](../README.md)
