# Деплой ML модели на production

## Быстрый старт

### Вариант 1: Автоматический деплой (рекомендуется)

```bash
# 1. Активируйте виртуальное окружение (если есть)
cd ml-service
python -m venv venv
source venv/bin/activate  # Linux/Mac
# или
venv\Scripts\activate  # Windows

# 2. Запустите деплой модели
cd ..
bash scripts/deploy_ml_model.sh ml-service/models/model.cbm
```

**Что делает скрипт:**
1. Копирует `model.cbm` и `model.pkl` на сервер
2. Перезапускает ML сервис
3. Проверяет что модель загрузилась

---

### Вариант 2: Ручной деплой

#### Шаг 1: Подключение к серверу

```bash
ssh root@outfitstyle.ru
```

#### Шаг 2: Копирование модели

```bash
# На локальной машине
cd D:\outfitstyle\ml-service\models

# Копирование на сервер
scp model.cbm root@outfitstyle.ru:/opt/outfitstyle/ml-models/model.cbm
scp model.pkl root@outfitstyle.ru:/opt/outfitstyle/ml-models/model.pkl
```

#### Шаг 3: Проверка файлов на сервере

```bash
# На сервере
cd /opt/outfitstyle/ml-models
ls -lh

# Должно быть:
# model.cbm (300KB)
# model.pkl (535 bytes)
```

#### Шаг 4: Перезапуск ML сервиса

```bash
cd /opt/outfitstyle
docker-compose restart ml-service

# Проверка
docker-compose ps ml-service
docker-compose logs ml-service | tail -20
```

#### Шаг 5: Проверка здоровья

```bash
# Проверка что модель загружена
curl http://localhost:8000/health | jq

# Ожидаемый ответ:
# {
#   "status": "healthy",
#   "model_loaded": true
# }

# Проверка версии модели
curl http://localhost:8000/ready

# Тестирование ML сервиса
curl -X POST http://localhost:8000/api/rank \
  -H "Content-Type: application/json" \
  -d '{
    "context": {
      "weather": {"temperature": 5, "feels_like": 3, "humidity": 80, "wind_speed": 5, "weather": "rain"},
      "user_profile": {"age_range": "25-35", "style_preference": "casual", "temperature_sensitivity": "normal", "formality_preference": "casual", "gender": "unisex"},
      "preferences": {},
      "location": "Moscow"
    },
    "candidates": [
      {"id": 1, "name": "Куртка", "category": "outerwear", "subcategory": "jacket", "gender": "unisex", "style": "casual", "usage": "daily", "season": "winter", "base_colour": "black", "formality": 5, "warmth": 8, "min_temp": -10, "max_temp": 10, "materials": [], "fit": "regular", "pattern": "solid", "icon_emoji": "🧥", "source": "synthetic", "is_owned": false, "created_at": "2024-01-01T00:00:00Z", "source_priority": 1}
    ]
  }' | jq
```

---

## Проверка что модель работает

### Тест 1: Health check

```bash
curl http://localhost:8000/health
```

**Ожидаемый ответ:**
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

Если `model_loaded: false`:
- Проверьте что файлы модели существуют
- Проверьте логи: `docker-compose logs ml-service`

### Тест 2: Prediction test

```bash
curl -X POST http://localhost:8000/api/rank \
  -H "Content-Type: application/json" \
  -d '{"context":{"weather":{"temperature":5,"feels_like":3,"humidity":80,"wind_speed":5,"weather":"rain"},"user_profile":{"age_range":"25-35","style_preference":"casual","temperature_sensitivity":"normal","formality_preference":"casual","gender":"unisex"},"preferences":{},"location":"Moscow"},"candidates":[{"id":1,"name":"Куртка","category":"outerwear","subcategory":"jacket","gender":"unisex","style":"casual","usage":"daily","season":"winter","base_colour":"black","formality":5,"warmth":8,"min_temp":-10,"max_temp":10,"materials":[],"fit":"regular","pattern":"solid","icon_emoji":"🧥","source":"synthetic","is_owned":false,"created_at":"2024-01-01T00:00:00Z","source_priority":1}]}'
```

**Ожидаемый ответ:**
```json
{
  "ranked": [
    {"id": 1, "score": 0.95}
  ],
  "model_version": "20260227_204255",
  "processing_time_ms": 50.5
}
```

---

## Откат к предыдущей версии

Если новая модель работает некорректно:

```bash
# На сервере
cd /opt/outfitstyle/ml-models

# Бэкап текущей модели
cp model.cbm model.cbm.backup
cp model.pkl model.pkl.backup

# Восстановление старой модели
# (предварительно скопируйте старую модель)
cp model.cbm.backup model.cbm
cp model.pkl.backup model.pkl

# Перезапуск
docker-compose restart ml-service
```

---

## Мониторинг

### Логи ML сервиса

```bash
# Последние 50 строк
docker-compose logs --tail=50 ml-service

# В реальном времени
docker-compose logs -f ml-service

# С фильтрацией по уровню
docker-compose logs ml-service | grep ERROR
```

### Метрики

```bash
# Prometheus метрики
curl http://localhost:8000/metrics
```

---

## Переменные окружения

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `MODEL_PATH` | Путь к manifest модели | `models/model.pkl` |
| `API_KEY` | API ключ для доступа к ML сервису | - |
| `DATABASE_URL` | Подключение к PostgreSQL | - |
| `REDIS_HOST` | Redis хост | `redis` |
| `REDIS_PORT` | Redis порт | `6379` |

---

## Чеклист деплоя

```
□ Модель обучена (train_on_real_data.py)
□ Модель задеплоена локально (deploy_model.py)
□ Метрики проверены (Accuracy 95%, AUC 99%)
□ Файлы скопированы на сервер (model.cbm, model.pkl)
□ ML сервис перезапущен
□ Health check пройден (model_loaded: true)
□ Prediction test пройден (score > 0.5)
□ Логи проверены (нет ошибок)
□ Бэкап старой модели сделан
```

---

## Контакты

При проблемах обращайтесь:
- GitHub Issues: https://github.com/ALEZOEX/OutFitStyle/issues
- Логи: `docker-compose logs ml-service`
