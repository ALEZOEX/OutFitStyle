import logging
import random
from typing import List, Dict, Any

from .advanced_trainer import AdvancedOutfitRecommender
from . import features

logger = logging.getLogger(__name__)


class EnhancedOutfitPredictor:
    """
    Улучшенный предиктор с расширенными возможностями рекомендаций.
    Собирает полный образ с учётом погоды и профиля пользователя.
    """

    def __init__(self, model: AdvancedOutfitRecommender):
        self.model = model

    # ======================= ПУБЛИЧНЫЙ МЕТОД =======================

    def build_outfit(
        self,
        weather_data: Dict[str, Any],
        user_profile: Dict[str, Any],
        all_items: List[Dict[str, Any]],
        min_confidence: float = 0.3,
    ) -> Dict[str, Any]:
        """
        Собирает полный комплект с учетом профиля пользователя и погоды.
        """

        logger.info("Building enhanced outfit with user preferences...")

        # Группируем предметы по категориям
        items_by_category = self._group_by_category(all_items)
        logger.info(
            "Items by category: %s",
            {k: len(v) for k, v in items_by_category.items()},
        )

        # Определяем необходимые категории на основе погоды
        temp = weather_data.get("temperature", 20.0)
        weather = weather_data.get("weather", "Ясно")
        required_categories = self._get_required_categories(temp, weather)
        logger.info("Required categories: %s", required_categories)

        # Проверяем, нужны ли аксессуары
        should_add_accessories = self._should_add_accessories(
            temp, weather, user_profile
        )
        logger.info("Should add accessories: %s", should_add_accessories)

        outfit_items: List[Dict[str, Any]] = []
        category_confidences: Dict[str, float] = {}

        # Для каждой обязательной категории
        for category in required_categories:
            items_in_category = items_by_category.get(category, [])

            if not items_in_category:
                logger.warning("No items in category: %s", category)
                continue

            # Фильтруем по профилю пользователя
            filtered_items = self._filter_by_user_profile(
                items_in_category, user_profile, category
            )

            if not filtered_items:
                logger.debug(
                    "No filtered items for %s, using all items in category", category
                )
                filtered_items = items_in_category  # fallback

            logger.debug(
                "Items in category %s: total=%d, filtered=%d",
                category,
                len(items_in_category),
                len(filtered_items),
            )

            # ML‑рекомендации для этой категории
            category_recommendations = self.recommend_items(
                weather_data,
                user_profile,
                filtered_items,
                top_n=3,  # берём топ-3 для разнообразия
                min_confidence=min_confidence,
            )

            if category_recommendations:
                # Добавляем элемент рандомности (80% топ-1, 20% топ-2/3)
                if len(category_recommendations) > 1 and random.random() < 0.2:
                    best_item = random.choice(category_recommendations[:3])
                else:
                    best_item = category_recommendations[0]

                outfit_items.append(best_item)
                category_confidences[category] = best_item["ml_score"]

                logger.debug(
                    "Selected for %s: %s (confidence: %.2f%%)",
                    category,
                    best_item["name"],
                    best_item["ml_score"] * 100,
                )
            else:
                # Если ML ничего не дал — fallback
                fallback_recommendations = self._fallback_recommendations(
                    weather_data, filtered_items, 1
                )
                if fallback_recommendations:
                    chosen = fallback_recommendations[0]
                    outfit_items.append(chosen)
                    category_confidences[category] = chosen["ml_score"]
                    logger.debug(
                        "Fallback selected for %s: %s (score: %.2f%%)",
                        category,
                        chosen["name"],
                        chosen["ml_score"] * 100,
                    )

        # Аксессуары (опционально)
        if should_add_accessories and "accessories" in items_by_category:
            accessories = self._select_accessories(
                weather_data,
                user_profile,
                items_by_category["accessories"],
                min_confidence=0.3,  # порог для аксессуаров можно держать ниже
            )

            for acc in accessories:
                outfit_items.append(acc)
                category_confidences[f"accessory_{acc['name']}"] = acc["ml_score"]

        # Итоговый скор комплекта
        if outfit_items:
            base_score = sum(it["ml_score"] for it in outfit_items) / len(outfit_items)
            outfit_score = min(0.95, base_score * random.uniform(0.95, 1.0))
        else:
            outfit_score = 0.0

        result = {
            "items": outfit_items,
            "outfit_score": float(outfit_score),
            "ml_powered": self.model.is_trained,
            "confidence_breakdown": category_confidences,
            "total_items": len(outfit_items),
            "algorithm": "enhanced_ml_v3_personalized",
            "user_preferences_applied": True,
        }

        logger.info(
            "Built outfit: %d items, score: %.2f%%, accessories: %s",
            len(outfit_items),
            outfit_score * 100,
            should_add_accessories,
        )

        return result

    # ---------- ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДЛЯ ЧИСЛОВЫХ ПРИЗНАКОВ ----------

    def _get_warmth_level(self, item: Dict[str, Any], default: float = 5.0) -> float:
        """Безопасно получает warmth_level как число (float)."""
        raw = item.get("warmth_level", default)
        try:
            return float(raw)
        except (TypeError, ValueError):
            logger.debug(
                "Cannot parse warmth_level=%r for item %s, using default=%s",
                raw,
                item.get("name"),
                default,
            )
            return float(default)

    def _get_formality_level(self, item: Dict[str, Any], default: float = 5.0) -> float:
        """
        Безопасно получает formality_level как число.
        Модель ожидает numeric‑признак, в БД могут быть строки ('casual', 'formal' и т.п.).
        """
        raw = item.get("formality_level", default)
        try:
            return float(raw)
        except (TypeError, ValueError):
            if isinstance(raw, str):
                label = raw.strip().lower()
                mapping = {
                    "casual": 3.0,
                    "smart": 6.0,
                    "business": 7.0,
                    "formal": 8.0,
                    "sport": 2.0,
                }
                val = mapping.get(label)
                if val is not None:
                    return val
            return float(default)

    def _get_temp_value(
        self, item: Dict[str, Any], key: str, default: float
    ) -> float:
        """Безопасно получает температурные значения (min_temp / max_temp) как float."""
        raw = item.get(key, default)
        try:
            return float(raw)
        except (TypeError, ValueError):
            logger.debug(
                "Cannot parse %s=%r for item %s, using default=%s",
                key,
                raw,
                item.get("name"),
                default,
            )
            return float(default)

    # -------------------- ФИЛЬТРАЦИЯ / АКСЕССУАРЫ --------------------

    def _filter_by_user_profile(
        self, items: List[Dict[str, Any]], user_profile: Dict[str, Any], category: str
    ) -> List[Dict[str, Any]]:
        """Фильтрует предметы по профилю пользователя (стиль + чувствительность к температуре)."""

        filtered: List[Dict[str, Any]] = []
        user_style = user_profile.get("style_preference", "casual")
        temp_sensitivity = user_profile.get("temperature_sensitivity", "normal")

        for item in items:
            item_style = item.get("style", "casual")
            warmth = self._get_warmth_level(item, default=5.0)

            # Фильтр по стилю (приоритет пользовательскому стилю)
            style_match = (
                item_style == user_style
                or user_style == "casual"  # casual – универсальный
                or item_style == "casual"
            )

            # Фильтр по теплоте
            warmth_match = True
            if temp_sensitivity == "cold" and warmth < 5:
                warmth_match = False  # мерзлякам – теплее
            elif temp_sensitivity == "warm" and warmth > 6:
                warmth_match = False  # тем, кому жарко – легче

            if style_match and warmth_match:
                filtered.append(item)

        logger.debug(
            "Filtered %d/%d items for %s (style=%s, temp_sens=%s)",
            len(filtered),
            len(items),
            category,
            user_style,
            temp_sensitivity,
        )

        return filtered

    def _should_add_accessories(
        self, temperature: float, weather: str, user_profile: Dict[str, Any]
    ) -> bool:
        """Решает, стоит ли добавлять аксессуары."""

        weather_lower = weather.lower()

        # Холодная погода – обязательно
        if temperature < 0:
            return True

        # Дождь/снег – обязательно
        if any(
            cond in weather_lower
            for cond in [
                "дождь",
                "снег",
                "морось",
                "гроза",
                "rain",
                "snow",
                "drizzle",
                "thunderstorm",
            ]
        ):
            return True

        # Прохладно – 70% вероятность
        if temperature < 10:
            return random.random() < 0.7

        # Умеренно – 30% вероятность
        if temperature < 20:
            return random.random() < 0.3

        # Тепло – 10% вероятность (очки, кепка)
        return random.random() < 0.1

    def _select_accessories(
        self,
        weather_data: Dict[str, Any],
        user_profile: Dict[str, Any],
        accessories: List[Dict[str, Any]],
        min_confidence: float = 0.3,
    ) -> List[Dict[str, Any]]:
        """Выбирает подходящие аксессуары."""
        temp = weather_data.get("temperature", 20.0)
        weather = weather_data.get("weather", "Ясно")
        weather_lower = weather.lower()

        recommendations = self.recommend_items(
            weather_data,
            user_profile,
            accessories,
            top_n=5,
            min_confidence=min_confidence,
        )

        selected: List[Dict[str, Any]] = []

        # Холодная погода – шапка, шарф, перчатки
        if temp < 0:
            for rec in recommendations:
                name_lower = rec["name"].lower()
                if any(word in name_lower for word in ["шапка", "шарф", "перчатк"]):
                    if len(selected) < 3:
                        selected.append(rec)

        # Прохладно – шапка или шарф
        elif temp < 10:
            for rec in recommendations:
                name_lower = rec["name"].lower()
                if any(word in name_lower for word in ["шапка", "шарф"]):
                    if len(selected) < 2:
                        selected.append(rec)

        # Дождь – зонт
        elif any(
            cond in weather_lower for cond in ["дождь", "морось", "rain", "drizzle"]
        ):
            for rec in recommendations:
                if (
                    "зонт" in rec["name"].lower()
                    or "umbrella" in rec["name"].lower()
                ):
                    selected.append(rec)
                    break

        # Солнечно и тепло – очки
        elif any(cond in weather_lower for cond in ["ясно", "clear"]) and temp > 20:
            for rec in recommendations:
                if (
                    "очки" in rec["name"].lower()
                    or "sunglasses" in rec["name"].lower()
                ):
                    selected.append(rec)
                    break

        # Если ничего не выбрано, берём случайный аксессуар из топ‑2
        if not selected and recommendations:
            selected.append(random.choice(recommendations[:2]))

        logger.debug(
            "Selected %d accessories for temp=%.1f°C, weather=%s",
            len(selected),
            temp,
            weather,
        )

        return selected

    # ---------------------- ОСНОВНАЯ РЕКОМЕНДАЦИЯ ----------------------

    def recommend_items(
        self,
        weather_data: Dict[str, Any],
        user_profile: Dict[str, Any],
        available_items: List[Dict[str, Any]],
        top_n: int = 10,
        min_confidence: float = 0.3,
    ) -> List[Dict[str, Any]]:
        """
        Возвращает топ-N рекомендованных предметов с ML‑оценками.
        Использует единый слой фичей из features.py.
        """
        if not self.model.is_trained:
            logger.warning("Model not trained, using fallback")
            return self._fallback_recommendations(weather_data, available_items, top_n)

        logger.info("Generating ML recommendations for %d items...", len(available_items))

        df = features.build_feature_frame(weather_data, user_profile, available_items)
        if df.empty:
            logger.warning("Feature frame is empty, using fallback")
            return self._fallback_recommendations(weather_data, available_items, top_n)

        try:
            predictions, probabilities = self.model.predict(df)

            scored_items: List[Dict[str, Any]] = []
            for i, item in enumerate(available_items):
                # Добавляем небольшой шум (±5%) для разнообразия
                noise = random.uniform(0.95, 1.05)
                adjusted_prob = min(0.99, probabilities[i] * noise)

                if adjusted_prob >= min_confidence:
                    item_copy = item.copy()
                    item_copy["ml_score"] = float(adjusted_prob)
                    item_copy["is_recommended"] = bool(predictions[i])
                    scored_items.append(item_copy)

            scored_items.sort(key=lambda x: x["ml_score"], reverse=True)
            recommendations = scored_items[:top_n]

            if recommendations:
                avg_conf = sum(it["ml_score"] for it in recommendations) / len(
                    recommendations
                )
                logger.info(
                    "Generated %d ML-powered recommendations (avg_conf=%.2f%%)",
                    len(recommendations),
                    avg_conf * 100,
                )
            else:
                max_prob = max(probabilities) if len(probabilities) > 0 else 0.0
                logger.info(
                    "No recommendations above threshold. "
                    "Max probability: %.2f%%, threshold: %.2f%%",
                    max_prob * 100,
                    min_confidence * 100,
                )

            return recommendations

        except Exception as e:
            logger.error("Prediction error: %s", e, exc_info=True)
            return self._fallback_recommendations(weather_data, available_items, top_n)

    # ---------------- ГРУППИРОВКА / ОБЯЗАТ. КАТЕГОРИИ / FALLBACK ----------------

    def _group_by_category(self, items: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
        """Группирует предметы по категориям."""
        grouped: Dict[str, List[Dict[str, Any]]] = {}
        for item in items:
            category = item.get("category", "unknown")
            grouped.setdefault(category, []).append(item)

        logger.debug(
            "Grouped items by category: %s",
            {k: len(v) for k, v in grouped.items()},
        )
        return grouped

    def _get_required_categories(self, temperature: float, weather: str) -> List[str]:
        """Определяет обязательные категории одежды."""
        categories = ["upper", "lower", "footwear"]

        # Верхняя одежда при холоде или дожде
        if temperature < 18 or weather.lower() in ["дождь", "морось", "снег"]:
            categories.insert(0, "outerwear")

        return categories

    def _fallback_recommendations(
        self,
        weather_data: Dict[str, Any],
        items: List[Dict[str, Any]],
        top_n: int,
    ) -> List[Dict[str, Any]]:
        """Резервные рекомендации без ML (temperature + простые правила)."""

        temp = weather_data.get("temperature", 20.0)
        scored_items: List[Dict[str, Any]] = []

        for item in items:
            min_temp = self._get_temp_value(item, "min_temp", 0.0)
            max_temp = self._get_temp_value(item, "max_temp", 30.0)

            # Базовый скор по температурному диапазону
            if min_temp <= temp <= max_temp:
                score = 0.9
            elif min_temp - 5 <= temp <= max_temp + 5:
                score = 0.7
            elif min_temp - 10 <= temp <= max_temp + 10:
                score = 0.4
            else:
                score = 0.1

            weather = (weather_data.get("weather") or "").lower()

            # Дождь – предпочитаем "waterproof"/"rain"
            if "дождь" in weather or "rain" in weather:
                if (
                    "waterproof" in item.get("name", "").lower()
                    or "rain" in item.get("name", "").lower()
                ):
                    score += 0.1
            elif temp < 5:
                # В холод – более тёплые вещи
                warmth = self._get_warmth_level(item, default=0.0)
                if warmth > 6:
                    score += 0.1
            elif temp > 25:
                # В жару – более лёгкие
                warmth = self._get_warmth_level(item, default=10.0)
                if warmth < 4:
                    score += 0.1

            score = max(0.1, min(0.95, score))

            item_copy = item.copy()
            item_copy["ml_score"] = score * random.uniform(0.95, 1.05)
            item_copy["is_recommended"] = score >= 0.3
            scored_items.append(item_copy)

        scored_items.sort(key=lambda x: x["ml_score"], reverse=True)
        top = scored_items[:top_n]

        logger.info(
            "Fallback recommendations generated: %d items, top score: %.2f%%",
            len(scored_items),
            (top[0]["ml_score"] * 100) if top else 0.0,
        )

        return top