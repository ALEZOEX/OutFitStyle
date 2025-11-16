import logging
from typing import List, Dict
from .advanced_trainer import AdvancedOutfitRecommender
import pandas as pd
import random

logger = logging.getLogger(__name__)

class AdvancedOutfitPredictor:
    """
    Улучшенный предиктор с учетом профиля пользователя
    """
    
    def __init__(self, model: AdvancedOutfitRecommender):
        self.model = model
    
    def build_outfit(self,
                    weather_data: Dict,
                    user_profile: Dict,
                    all_items: List[Dict],
                    min_confidence: float = 0.5) -> Dict:
        """
        Собирает полный комплект с учетом профиля пользователя
        """
        logger.info("Building ML-powered outfit with user preferences...")
        logger.info(f"Input data - Weather: {weather_data}, User profile: {user_profile}, Items count: {len(all_items)}")
        
        # Группируем предметы по категориям
        items_by_category = self._group_by_category(all_items)
        logger.info(f"Items by category: { {k: len(v) for k, v in items_by_category.items()} }")
        
        # Определяем необходимые категории на основе погоды
        temp = weather_data.get('temperature', 20)
        weather = weather_data.get('weather', 'Ясно')
        required_categories = self._get_required_categories(temp, weather)
        logger.info(f"Required categories: {required_categories}")
        
        # Проверяем, нужны ли аксессуары
        should_add_accessories = self._should_add_accessories(
            temp, weather, user_profile
        )
        logger.info(f"Should add accessories: {should_add_accessories}")
        
        outfit_items = []
        category_confidences = {}
        
        # Для каждой обязательной категории
        for category in required_categories:
            items_in_category = items_by_category.get(category, [])
            
            if not items_in_category:
                logger.warning(f"No items in category: {category}")
                continue
            
            # Фильтруем по профилю пользователя
            filtered_items = self._filter_by_user_profile(
                items_in_category, user_profile, category
            )
            
            if not filtered_items:
                logger.debug(f"No filtered items for {category}, using all items in category")
                filtered_items = items_in_category  # Fallback
            
            logger.debug(f"Items in category {category}: {len(items_in_category)}, filtered: {len(filtered_items)}")
            
            # Получаем рекомендации для этой категории
            category_recommendations = self.recommend_items(
                weather_data,
                user_profile,
                filtered_items,
                top_n=3,  # Берем топ-3 для разнообразия
                min_confidence=min_confidence
            )
            
            if category_recommendations:
                # Добавляем элемент рандомности (80% топ-1, 20% топ-2/3)
                if len(category_recommendations) > 1 and random.random() < 0.2:
                    best_item = random.choice(category_recommendations[:3])
                else:
                    best_item = category_recommendations[0]
                
                outfit_items.append(best_item)
                category_confidences[category] = best_item['ml_score']
                
                logger.debug(f"Selected for {category}: {best_item['name']} "
                           f"(confidence: {best_item['ml_score']:.2%})")
            else:
                # Use fallback recommendations if ML recommendations are empty
                fallback_recommendations = self._fallback_recommendations(
                    weather_data, filtered_items, 1
                )
                if fallback_recommendations:
                    outfit_items.append(fallback_recommendations[0])
                    category_confidences[category] = fallback_recommendations[0]['ml_score']
                    logger.debug(f"Fallback selected for {category}: {fallback_recommendations[0]['name']}")
        
        # Аксессуары (опционально)
        if should_add_accessories and 'accessories' in items_by_category:
            accessories = self._select_accessories(
                weather_data,
                user_profile,
                items_by_category['accessories'],
                min_confidence=0.6
            )
            
            for acc in accessories:
                outfit_items.append(acc)
                category_confidences[f"accessory_{acc['name']}"] = acc['ml_score']
        
        # Вычисляем реалистичную общую оценку
        if outfit_items:
            # Добавляем небольшой случайный шум для разнообразия
            base_score = sum(item['ml_score'] for item in outfit_items) / len(outfit_items)
            # Снижаем слишком высокие оценки
            outfit_score = min(0.95, base_score * random.uniform(0.95, 1.0))
        else:
            outfit_score = 0.0
        
        result = {
            'items': outfit_items,
            'outfit_score': float(outfit_score),
            'ml_powered': self.model.is_trained,
            'confidence_breakdown': category_confidences,
            'total_items': len(outfit_items),
            'algorithm': 'advanced_ml_v2_personalized',
            'user_preferences_applied': True,
        }
        
        logger.info(f"Built outfit: {len(outfit_items)} items, "
                   f"score: {outfit_score:.2%}, "
                   f"accessories: {should_add_accessories}")
        
        return result
    
    def _filter_by_user_profile(
        self, 
        items: List[Dict], 
        user_profile: Dict,
        category: str
    ) -> List[Dict]:
        """Фильтрует предметы по профилю пользователя"""
        
        filtered = []
        user_style = user_profile.get('style_preference', 'casual')
        temp_sensitivity = user_profile.get('temperature_sensitivity', 'normal')
        
        for item in items:
            item_style = item.get('style', 'casual')
            warmth = item.get('warmth_level', 5)
            
            # Фильтр по стилю (приоритет пользовательскому стилю)
            style_match = (item_style == user_style or 
                          user_style == 'casual' or  # casual универсальный
                          item_style == 'casual')
            
            # Фильтр по теплоте
            warmth_match = True
            if temp_sensitivity == 'cold' and warmth < 5:
                warmth_match = False  # Мерзлякам - теплее
            elif temp_sensitivity == 'warm' and warmth > 6:
                warmth_match = False  # Жарким - легче
            
            if style_match and warmth_match:
                filtered.append(item)
        
        logger.debug(f"Filtered {len(filtered)}/{len(items)} items for {category} "
                    f"(style: {user_style}, temp_sens: {temp_sensitivity})")
        
        return filtered
    
    def _should_add_accessories(
        self, 
        temperature: float, 
        weather: str, 
        user_profile: Dict
    ) -> bool:
        """Определяет, нужны ли аксессуары"""
        
        weather_lower = weather.lower()
        
        # Холодная погода - обязательно
        if temperature < 0:
            return True
        
        # Дождь/снег - обязательно
        if any(cond in weather_lower for cond in ['дождь', 'снег', 'морось', 'гроза', 'rain', 'snow', 'drizzle', 'thunderstorm']):
            return True
        
        # Прохладно - 70% вероятность
        if temperature < 10:
            return random.random() < 0.7
        
        # Умеренно - 30% вероятность
        if temperature < 20:
            return random.random() < 0.3
        
        # Тепло - 10% вероятность (солнечные очки, кепка)
        return random.random() < 0.1
    
    def _select_accessories(
        self, 
        weather_data: Dict, 
        user_profile: Dict, 
        accessories: List[Dict],
        min_confidence: float
    ) -> List[Dict]:
        """Выбирает подходящие аксессуары"""
        
        temp = weather_data.get('temperature', 20)
        weather = weather_data.get('weather', 'Ясно')
        recommendations = []
        
        # Сначала получаем рекомендации для аксессуаров
        try:
            recommendations = self.recommend_items(
                weather_data, user_profile, accessories, 
                top_n=len(accessories), min_confidence=min_confidence
            )
        except Exception as e:
            logger.warning(f"Failed to get ML recommendations for accessories: {e}")
            # Используем фолбэк
            recommendations = self._fallback_recommendations(
                weather_data, accessories, len(accessories)
            )
        
        selected = []
        
        # Выбираем подходящие аксессуары
        for rec in recommendations:
            name_lower = rec['name'].lower()
            
            # Зонт при дожде или прогнозе дождя
            if ('umbrella' in name_lower or 'зонт' in name_lower) and \
               (temp < 20 and ('дождь' in weather.lower() or 'rain' in weather.lower())):
                selected.append(rec)
                break
        
        # Если ничего не выбрано, берем случайный аксессуар с высокой оценкой
        if not selected and recommendations:
            selected.append(random.choice(recommendations[:2]))
        
        logger.debug(f"Selected {len(selected)} accessories for temp={temp}°C, weather={weather}")
        
        return selected
    
    def recommend_items(self, 
                       weather_data: Dict, 
                       user_profile: Dict,
                       available_items: List[Dict],
                       top_n: int = 10,
                       min_confidence: float = 0.5) -> List[Dict]:
        """
        Возвращает топ-N рекомендованных предметов с ML оценками
        """
        if not self.model or not self.model.is_trained:
            # Если модель не обучена, возвращаем ошибку
            raise ValueError("ML model is not trained. Please train the model first.")
        
        logger.info(f"Generating ML recommendations for {len(available_items)} items...")
        
        predictions_data = []
        
        for item in available_items:
            sample = {
                **self._prepare_weather_features(weather_data),
                **self._prepare_user_features(user_profile),
                **self._prepare_item_features(item)
            }
            predictions_data.append(sample)
        
        df = pd.DataFrame(predictions_data)
        
        try:
            predictions, probabilities = self.model.predict(df)
            
            scored_items = []
            for i, item in enumerate(available_items):
                # Добавляем шум для разнообразия (±5%)
                noise = random.uniform(0.95, 1.05)
                adjusted_prob = min(0.99, probabilities[i] * noise)
                
                if adjusted_prob >= min_confidence:
                    item_copy = item.copy()
                    item_copy['ml_score'] = float(adjusted_prob)
                    item_copy['is_recommended'] = bool(predictions[i])
                    scored_items.append(item_copy)
            
            scored_items.sort(key=lambda x: x['ml_score'], reverse=True)
            recommendations = scored_items[:top_n]
            
            if recommendations:
                avg_conf = sum(item['ml_score'] for item in recommendations) / len(recommendations)
                logger.info(f"Generated {len(recommendations)} ML-powered recommendations")
                logger.info(f"Average confidence: {avg_conf:.2%}")
            else:
                max_prob = max(probabilities) if probabilities.size > 0 else 0
                logger.info(f"No recommendations above threshold. Max probability: {max_prob:.2%}, threshold: {min_confidence:.2%}")
                # Если ничего не найдено, возвращаем пустой список, а не ошибку
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Prediction error: {e}")
            raise
    
    def _prepare_weather_features(self, weather_data: Dict) -> Dict:
        """Подготавливает погодные признаки"""
        weather_map = {
            'ясно': 'clear',
            'облачно': 'clouds',
            'дождь': 'rain',
            'морось': 'drizzle',
            'снег': 'snow',
            'туман': 'mist',
            'гроза': 'thunderstorm'
        }
        
        weather_condition = weather_data.get('weather', 'Ясно').lower()
        weather_condition = weather_map.get(weather_condition, 'clear')
        
        temp = weather_data.get('temperature', 20)
        if temp < 0:
            season = 'winter'
        elif temp < 15:
            season = 'spring'
        elif temp < 25:
            season = 'summer'
        else:
            season = 'autumn'
        
        return {
            'temperature': weather_data.get('temperature', 20),
            'feels_like': weather_data.get('feels_like', weather_data.get('temperature', 20)),
            'humidity': weather_data.get('humidity', 50),
            'wind_speed': weather_data.get('wind_speed', 0),
            'weather_condition': weather_condition,
            'season': season,
        }
    
    def _prepare_user_features(self, user_profile: Dict) -> Dict:
        """Подготавливает признаки пользователя"""
        return {
            'age_range': user_profile.get('age_range', '25-35'),
            'style_preference': user_profile.get('style_preference', 'casual'),
            'temperature_sensitivity': user_profile.get('temperature_sensitivity', 'normal'),
            'formality_preference': user_profile.get('formality_preference', 'informal'),
        }
    
    def _prepare_item_features(self, item: Dict) -> Dict:
        """Подготавливает признаки предмета одежды"""
        return {
            'item_name': item.get('name', ''),
            'category': item.get('category', 'upper'),
            'min_temp': item.get('min_temp', 0),
            'max_temp': item.get('max_temp', 30),
            'warmth_level': item.get('warmth_level', 5),
            'formality_level': item.get('formality_level', 5),
            'item_style': item.get('style', 'casual'),
        }
    
    def _group_by_category(self, items: List[Dict]) -> Dict[str, List[Dict]]:
        """Группирует предметы по категориям"""
        grouped = {}
        for item in items:
            category = item.get('category', 'unknown')
            if category not in grouped:
                grouped[category] = []
            grouped[category].append(item)
        logger.debug(f"Grouped items by category: { {k: len(v) for k, v in grouped.items()} }")
        return grouped
    
    def _get_required_categories(self, temperature: float, weather: str) -> List[str]:
        """Определяет обязательные категории одежды"""
        categories = ['upper', 'lower', 'footwear']
        
        # Верхняя одежда при холоде или дожде
        if temperature < 18 or weather.lower() in ['дождь', 'морось', 'снег']:
            categories.insert(0, 'outerwear')
        
        return categories
    
    def _fallback_recommendations(self, weather_data: Dict, items: List[Dict], top_n: int) -> List[Dict]:
        """Резервные рекомендации без ML"""
        temp = weather_data.get('temperature', 20)
        
        scored_items = []
        for item in items:
            min_temp = item.get('min_temp', 0)
            max_temp = item.get('max_temp', 30)
            
            # Calculate temperature suitability score
            if min_temp <= temp <= max_temp:
                # Perfect temperature range
                score = 0.9
            elif min_temp - 5 <= temp <= max_temp + 5:
                # Close to suitable range
                score = 0.7
            elif min_temp - 10 <= temp <= max_temp + 10:
                # Somewhat suitable
                score = 0.4
            else:
                # Not suitable
                score = 0.1
            
            # Adjust score based on weather conditions
            weather = weather_data.get('weather', '').lower()
            if 'дождь' in weather or 'rain' in weather:
                # Prefer waterproof items in rain
                if 'waterproof' in item.get('name', '').lower() or 'rain' in item.get('name', '').lower():
                    score += 0.1
            elif temp < 5:
                # Prefer warmer items in cold weather
                if item.get('warmth_level', 0) > 6:
                    score += 0.1
            elif temp > 25:
                # Prefer lighter items in hot weather
                if item.get('warmth_level', 10) < 4:
                    score += 0.1
            
            # Ensure score is within bounds
            score = max(0.1, min(0.95, score))
            
            item_copy = item.copy()
            item_copy['ml_score'] = score * random.uniform(0.95, 1.05)
            item_copy['is_recommended'] = score >= 0.3
            scored_items.append(item_copy)
        
        scored_items.sort(key=lambda x: x['ml_score'], reverse=True)
        logger.info(f"Fallback recommendations generated: {len(scored_items)} items, top score: {scored_items[0]['ml_score'] if scored_items else 0:.2%}")
        return scored_items[:top_n]