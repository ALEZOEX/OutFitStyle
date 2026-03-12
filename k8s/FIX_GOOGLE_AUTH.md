# 🔧 Инструкция по исправлению проблемы с Google аутентификацией

## Проблема

Backend в Kubernetes возвращает **503 Service Unavailable** или **401 Unauthorized** на все запросы, включая `/api/v1/auth/google`.

**Причина:** Firebase Admin SDK не может инициализироваться без credentials, что приводит к падению backend или невозможности верификации Google токенов.

---

## Решение

### Шаг 1: Подключись к серверу k3s

```bash
ssh root@<твой-сервер>
# или использешь SSH ключ
ssh -i ~/.ssh/your-key.pem root@<твой-сервер>
```

### Шаг 2: Проверь статус backend

```bash
kubectl get pods -n outfitstyle
kubectl logs -n outfitstyle deploy/backend --tail=100
```

**Что искать в логах:**
- `[Firebase] [ERROR] Firebase Admin SDK не инициализирован`
- `panic:` или `fatal:`
- `connection refused` к базе данных

### Шаг 3: Добавь Firebase credentials

**Вариант A: Автоматически (рекомендуется)**

```bash
cd /root/OutFitStyle/k8s

# Запусти скрипт настройки (файл firebase-credentials.json должен быть на сервере)
./setup-firebase-secret.sh /root/OutFitStyle/firebase-credentials.json
```

**Вариант B: Вручную**

```bash
# Перейди в директорию с проектом
cd /root/OutFitStyle

# Создай секрет из файла credentials
kubectl create secret generic firebase-credentials-secret \
  --from-file=credentials.json=firebase-credentials.json \
  -n outfitstyle
```

### Шаг 4: Перезапусти backend

```bash
kubectl rollout restart deployment/backend -n outfitstyle
```

### Шаг 5: Проверь логи

```bash
# Следи за логами в реальном времени
kubectl logs -n outfitstyle deploy/backend -f

# Ищи успешную инициализацию:
# [Firebase] [INFO] Admin SDK инициализирован
# [Server] [INFO] Server started on :8080
```

### Шаг 6: Проверь доступность API

```bash
# Health check
curl https://app.outfitstyle.ru/api/health

# Тест аутентификации (должен вернуть 400 с ошибкой валидации, а не 401)
curl -X POST https://app.outfitstyle.ru/api/v1/auth/google \
  -H "Content-Type: application/json" \
  -d '{"firebase_id_token": "test"}'
```

---

## Проверка успешности

### ✅ Успешные признаки

1. **Backend под в статусе Running:**
   ```bash
   kubectl get pods -n outfitstyle
   # backend   1/1   Running   0   2m
   ```

2. **В логах нет ошибок Firebase:**
   ```bash
   kubectl logs -n outfitstyle deploy/backend | grep -i firebase
   # [Firebase] [INFO] Admin SDK инициализирован
   ```

3. **Health check работает:**
   ```bash
   curl -I https://app.outfitstyle.ru/api/health
   # HTTP/1.1 200 OK
   ```

4. **Аутентификация работает:**
   - Открой https://app.outfitstyle.ru
   - Нажми "Войти через Google"
   - После успешного входа API запросы должны возвращать 200, а не 401

---

## Диагностика проблем

### Backend не запускается

```bash
# Проверь детальную информацию о поде
kubectl describe pod -n outfitstyle -l app=backend

# Проверь логи предыдущей попытки запуска
kubectl logs -n outfitstyle deploy/backend --previous
```

### Ошибка "Secret not found"

```bash
# Проверь наличие секрета
kubectl get secrets -n outfitstyle | grep firebase

# Если нет - создай (см. Шаг 3)
```

### Ошибка "Database connection failed"

```bash
# Проверь secret с database-url
kubectl get secret outfitstyle-secrets -n outfitstyle -o jsonpath='{.data.database-url}' | base64 -d

# Проверь доступность PostgreSQL
kubectl exec -n outfitstyle deploy/backend -- wget --quiet --tries=1 --spider postgres://...
```

### Ошибка "Firebase token verification failed"

```bash
# Проверь, что GOOGLE_CLIENT_ID правильный
kubectl get secret outfitstyle-secrets -n outfitstyle -o jsonpath='{.data.google-client-id}' | base64 -d

# Сверь с Firebase Console:
# https://console.firebase.google.com/project/outfitstyle-ce15f/settings/general/web
```

---

## Откат изменений

Если что-то пошло не так:

```bash
# Откат backend deployment к предыдущей версии
kubectl rollout undo deployment/backend -n outfitstyle

# Проверка статуса отката
kubectl rollout status deployment/backend -n outfitstyle
```

---

## Дополнительные команды

### Просмотр логов в реальном времени

```bash
kubectl logs -n outfitstyle deploy/backend -f --tail=100
```

### Проверка всех ресурсов в namespace

```bash
kubectl get all -n outfitstyle
```

### Проверка секретов

```bash
kubectl get secrets -n outfitstyle
kubectl describe secret firebase-credentials-secret -n outfitstyle
```

### Проверка переменных окружения в поде

```bash
kubectl exec -n outfitstyle deploy/backend -- env | grep -E "FIREBASE|GOOGLE"
```

---

## Контакты

Если проблема не решена:
1. Собери логи: `kubectl logs -n outfitstyle deploy/backend --tail=200 > backend-logs.txt`
2. Проверь статус подов: `kubectl get pods -n outfitstyle -o wide > pods-status.txt`
3. Отправь файлы логов для анализа
