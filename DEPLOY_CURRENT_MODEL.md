# Деплой ML модели на OutFitStyle production

## 📦 Файлы модели

```
ml-service/models/
├── model.cbm       # CatBoost модель (300KB)
├── model.pkl       # Manifest (704 bytes)
└── metadata.json   # Метрики и информация
```

## ✅ Готово к деплою

**Модель:**
- Version: `20260227_210635`
- Accuracy: `95.25%`
- AUC-ROC: `98.94%`
- Inference time: `0.65ms p95`

**Фичи:** 11 (8 категориальных + 3 числовых)

---

## 🚀 Деплой на сервер

### Вариант 1: PowerShell (Windows)

```powershell
# 1. Копирование модели на сервер
scp ml-service\models\model.cbm root@outfitstyle.ru:/opt/outfitstyle/ml-models/model.cbm
scp ml-service\models\model.pkl root@outfitstyle.ru:/opt/outfitstyle/ml-models/model.pkl

# 2. Подключение к серверу
ssh root@outfitstyle.ru

# 3. Перезапуск ML сервиса
cd /opt/outfitstyle
docker-compose restart ml-service

# 4. Проверка
docker-compose logs ml-service | tail -20
```

### Вариант 2: Bash скрипт (Linux/Mac)

```bash
cd D:\outfitstyle
bash scripts/deploy_ml_model.sh ml-service/models/model.cbm
```

---

## ✅ Проверка после деплоя

### 1. Health check

```bash
curl http://outfitstyle.ru:8000/health
```

**Ожидаемый ответ:**
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

### 2. Версия модели

```bash
curl http://outfitstyle.ru:8000/ready
```

**Ожидаемый ответ:**
```json
{
  "status": "ready",
  "model_version": "20260227_210635"
}
```

### 3. Тестовое предсказание

```bash
curl -X POST http://outfitstyle.ru:8000/api/rank \
  -H "Content-Type: application/json" \
  -d '{
    "context": {
      "weather": {"temperature": 12, "feels_like": 10, "humidity": 85, "wind_speed": 3, "weather": "rain"},
      "user_profile": {"age_range": "25-35", "style_preference": "casual", "temperature_sensitivity": "normal", "formality_preference": "casual", "gender": "unisex"},
      "preferences": {},
      "location": "Moscow"
    },
    "candidates": [
      {"id": 1, "name": "Куртка", "category": "outerwear", "subcategory": "jacket", "gender": "unisex", "style": "casual", "usage": "daily", "season": "winter", "base_colour": "black", "formality": 5, "warmth": 8, "min_temp": -10, "max_temp": 10, "materials": [], "fit": "regular", "pattern": "solid", "icon_emoji": "🧥", "source": "synthetic", "is_owned": false, "created_at": "2024-01-01T00:00:00Z", "source_priority": 1}
    ]
  }'
```

---

## 📊 Метрики модели

```
Accuracy:     95.25%
AUC-ROC:      98.94%
Precision:    95.66%
Recall:       95.25%
F1-Score:     95.24%

Inference time:
  Single p50:  0.50ms
  Single p95:  0.65ms
  Batch p95:   1.06ms (100 items)
```

---

## 🔧 Откат к предыдущей версии

```bash
# На сервере
cd /opt/outfitstyle/ml-models

# Бэкап текущей
cp model.cbm model.cbm.backup
cp model.pkl model.pkl.backup

# Восстановление
docker-compose restart ml-service
```

---

## 📝 Чеклист

```
□ Модель обучена (train_on_real_data.py ✅)
□ Метрики проверены (Accuracy 95.25%, AUC 98.94% ✅)
□ Файлы скопированы на сервер
□ ML сервис перезапущен
□ Health check пройден
□ Prediction test пройден
□ Логи проверены
```

---

**Дата деплоя:** 27.02.2026
**Версия модели:** 20260227_210635
**Dataset:** Season Fashion Dataset (1001 запись + 1000 negative)
