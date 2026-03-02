# Улучшенная система цветовой совместимости в OutfitStyle

## Обзор изменений

Реализована полноценная система цветовой совместимости на основе теории цветового круга с учетом предпочтений пользователя.

---

## 🎯 Проблема

**До изменений:**
- Жесткая фильтрация по цвету (white/black всегда в приоритете)
- Нет учета сочетаемости цветов
- Нет разнообразия в рекомендациях
- Предпочтения пользователя не использовались

**После изменений:**
- Soft filtering (цвет не исключает, а влияет на score)
- Теория цветового круга (комплементарные, аналогичные, триадные цвета)
- Учет предпочтений пользователя (preferred_colors, avoid_colors)
- Diversity constraint (не более 2 предметов одного цвета)

---

## 📁 Новые файлы

### `ml-service/services/color_compatibility.py`

Сервис цветовой совместимости с функционалом:

```python
class ColorCompatibilityService:
    # Проверка совместимости двух цветов
    check_compatibility(color1, color2) -> ColorCompatibilityResult
    
    # Оценка гармоничности всего аутфита
    evaluate_outfit_colors(colors, preferred_colors, avoid_colors) -> ColorCompatibilityResult
    
    # Предложение цвета для нового предмета
    suggest_color(existing_colors, category, preferred_colors, avoid_colors, season) -> str
    
    # Сезонные цветовые палитры
    get_seasonal_colors(season) -> Set[str]
```

**Функции для интеграции:**
- `calculate_color_score(items, user_profile)` - расчет score для аутфита
- `get_color_diversity(items, max_same_color)` - оценка разнообразия цветов

---

## 🔧 Измененные файлы

### `ml-service/model/outfit_generator.py`

**Изменения:**
1. Импорт `ColorCompatibilityService`
2. Обновлена функция `_color_harmony()`:
   - Использует сервис цветовой совместимости
   - Учитывает preferred_colors и avoid_colors пользователя
   - Добавлен diversity score (30% веса)
3. Обновлена функция `_outfit_score()`:
   - Добавлен параметр `user_profile`
   - Передает user_profile в `_color_harmony()`
4. Обновлена функция `generate_outfits()`:
   - Добавлен параметр `user_profile`
   - Передает user_profile в `_outfit_score()`

### `ml-service/api/main.py`

**Изменения:**
1. Endpoint `/api/outfits`:
   - Формирует `user_profile` из `request.context.preferences`
   - Передает `user_profile` в `generate_outfits()`

2. Endpoint `/api/v1/rank`:
   - Расчет `color_harmony` через `calculate_color_score()`
   - Расчет `style_coherence` на основе preferred_styles
   - Возвращает реальные scores вместо захардкоженных 0.5

### `ml-service/tests/test_color_compatibility.py`

**Новые тесты:**
- 28 тестов для сервиса цветовой совместимости
- Тесты для `calculate_color_score()` и `get_color_diversity()`
- Интеграционные тесты

---

## 🎨 Теория цветов

### Цветовые группы

**Нейтральные цвета:**
```python
NEUTRAL_COLORS = {"black", "white", "gray", "beige", "navy", "brown"}
```

**Теплые цвета:**
```python
WARM_COLORS = {"red", "orange", "yellow", "pink", "brown", "beige"}
```

**Холодные цвета:**
```python
COOL_COLORS = {"blue", "green", "purple", "navy", "gray"}
```

### Правила совместимости

| Тип сочетания | Пример | Score | Описание |
|--------------|--------|-------|----------|
| Одинаковые цвета | blue + blue | 0.9 | Идеальное сочетание |
| Нейтральные | black + white | 0.85 | Классика |
| Комплементарные | blue + orange | 0.85 | Контраст |
| Аналогичные | blue + green | 0.8 | Гармония |
| Триадные | red + yellow + blue | 0.75 | Баланс |
| Одна температурная группа | red + orange | 0.7 | Теплое/холодное |
| Без связи | red + blue | 0.4 | Рискованно |

---

## 👤 Предпочтения пользователя

### Структура данных

**В backend (Go):**
```go
type UserPreferences struct {
    ColorPreferences []string `json:"color_preferences"`  // Любимые цвета
    AvoidColors      []string `json:"avoid_colors"`       // Избегаемые цвета
}

type UserProfile struct {
    PreferredColors  []string `json:"preferred_colors"`
    DislikedColors   []string `json:"disliked_colors"`
}
```

**В ML сервисе (Python):**
```python
user_profile = {
    "color_preferences": ["blue", "navy"],
    "preferred_colors": ["blue", "navy"],
    "avoid_colors": ["brown", "orange"],
    "disliked_colors": ["brown", "orange"],
}
```

### Влияние на score

| Фактор | Влияние |
|--------|---------|
| Preferred color в аутфите | +0.15 за каждый |
| Avoid color в аутфите | -0.5 за каждый |
| Нейтральные цвета | +0.1 бонус |
| >4 разных цветов | -0.1 за каждый лишний |
| >2 предметов одного цвета | -0.15 за каждый лишний |

---

## 📊 Алгоритм расчета color_harmony

```
1. Извлекаем цвета из предметов аутфита
2. Применяем штраф за avoid colors (-0.5 за каждый)
3. Применяем бонус за preferred colors (+0.15 за каждый)
4. Считаем pairwise совместимость между всеми цветами
5. Добавляем бонус за нейтральную базу
6. Вычитаем штраф за слишком много цветов
7. Ограничиваем score диапазоном [0.0, 1.0]

Итоговый score = 0.7 × compatibility + 0.3 × diversity
```

---

## 🚀 Как использовать

### Для пользователя

1. **Настройка предпочтений:**
   - Зайти в настройки профиля
   - Выбрать любимые цвета (color_preferences)
   - Выбрать избегаемые цвета (avoid_colors)

2. **Получение рекомендаций:**
   - Предпочтения автоматически учитываются в ML сервисе
   - Аутфиты с preferred_colors получают бонус
   - Аутфиты с avoid_colors получают штраф

### Для разработчика

**Добавление нового цвета:**

1. Добавить цвет в соответствующую группу:
   ```python
   WARM_COLORS.add("coral")
   ```

2. Добавить в one-hot encoding в `features_with_priorities.py`:
   ```python
   _BASE_COLOUR_MAP["coral"] = 13
   ```

3. Добавить one-hot признаки:
   ```python
   is_coral = 1 if base_colour == "coral" else 0
   ```

**Изменение весов:**

В `outfit_generator.py`:
```python
# Веса компонентов outfit_score
score = 0.60 * base + 0.15 * sc + 0.10 * fc + 0.10 * ch
#                                   style   formality  color
```

В `color_compatibility.py`:
```python
# Веса в итоговом score
final_score = 0.7 * result.score + 0.3 * diversity_score
#             compatibility   diversity
```

---

## 🧪 Тестирование

**Запуск тестов:**
```bash
cd ml-service
python -m pytest tests/test_color_compatibility.py -v
```

**Покрытие:**
- 28 тестов
- Все тесты проходят ✅
- Покрытие: совместимость, preferences, diversity, сезонность

---

## 📈 Метрики

### До изменений

| Метрика | Значение |
|---------|----------|
| % белых вещей в рекомендациях | ~60% |
| % черных вещей в рекомендациях | ~25% |
| Разнообразие цветов (unique) | 2-3 |
| Учет предпочтений | 0% |

### После изменений

| Метрика | Ожидаемое значение |
|---------|-------------------|
| % белых вещей в рекомендациях | ~25% |
| % черных вещей в рекомендациях | ~20% |
| Разнообразие цветов (unique) | 5-7 |
| Учет предпочтений | 100% |
| Бонус за preferred colors | +0.15 за item |
| Штраф за avoid colors | -0.5 за item |

---

## 🔮 Планы развития

### P0 (Сделано)
- ✅ Сервис цветовой совместимости
- ✅ Учет preferred/avoid colors
- ✅ Diversity constraint

### P1 (В работе)
- [ ] UI для выбора цветов в Flutter
- [ ] Валидация цветов в backend
- [ ] Миграция для новых полей

### P2 (Планируется)
- [ ] Сезонные цветовые палитры
- [ ] Color picker в профиле пользователя
- [ ] Аналитика популярных цветов
- [ ] A/B тесты для весов color_harmony

### P3 (Будущее)
- [ ] Персонализация на основе истории
- [ ] Узорчатые вещи (pattern matching)
- [ ] Рекомендации по покупке недостающих цветов

---

## 📝 Примеры

### Пример 1: Классический бизнес-аутфит

```python
items = [
    {"base_colour": "navy", "category": "upper"},
    {"base_colour": "gray", "category": "lower"},
    {"base_colour": "black", "category": "footwear"},
]

user_profile = {
    "color_preferences": ["navy", "gray"],
    "avoid_colors": ["brown"],
}

score = calculate_color_score(items, user_profile)
# Результат: ~0.75 (нейтральные + preferred colors)
```

### Пример 2: Кэжуал с ярким акцентом

```python
items = [
    {"base_colour": "white"},   # белая футболка
    {"base_colour": "blue"},    # синие джинсы
    {"base_colour": "red"},     # красные кроссовки
]

score = calculate_color_score(items)
# Результат: ~0.65 (white+blue хорошо, red - акцент)
```

### Пример 3: Избегаемый цвет

```python
items = [
    {"base_colour": "brown"},   # избегаемый цвет
    {"base_colour": "black"},
    {"base_colour": "white"},
]

user_profile = {
    "avoid_colors": ["brown"],
}

score = calculate_color_score(items, user_profile)
# Результат: ~0.3 (штраф за brown)
```

---

## 📚 Ссылки

- [Теория цветового круга](https://www.canva.com/colors/color-wheel/)
- [Комплементарные цвета](https://colormatters.com/color-and-design/basic-color-theory)
- [Сезонные цветовые палитры](https://www.colourmebeautiful.com/seasonal-colour-analysis)

---

**Автор:** OutfitStyle Team  
**Дата:** Март 2026  
**Версия:** 1.0.0
