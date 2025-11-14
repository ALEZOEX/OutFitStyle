import logging
from typing import List, Dict
from .advanced_trainer import AdvancedOutfitRecommender
import pandas as pd

logger = logging.getLogger(__name__)

class AdvancedOutfitPredictor:
    """
    Предиктор для работы с обученной моделью
    """
    
    def __init__(self, model: AdvancedOutfitRecommender):
        self.model = model
    
    def recommend_items(self, 
                       weather_data: Dict, 
                       user_profile: Dict,
                       available_items: List[Dict],
                       top_n: int = 10,
                       min_confidence: float = 0.5) -> List[Dict]:
        """
        Возвращает топ-N рекомендованных предметов с ML оценками
        
        Args:
            weather_data: Погодные данные
            user_profile: Профиль пользователя
            available_items: Доступные предметы одежды
            top_n: Количество рекомендаций
            min_confidence: Минимальная уверенность модели
        
        Returns:
            Список предметов с confidence scores
        """
        if not self.model.is_trained:
            logger.warning("Model not trained, using fallback")
            return self._fallback_recommendations(weather_data, available_items, top_n)
        
        logger.info(f"Generating ML recommendations for {len(available_items)} items...")
        
        # Подготавливаем данные для предсказания
        predictions_data = []
        
        for item in available_items:
            # Комбинируем все данные
            sample = {
                **self._prepare_weather_features(weather_data),
                **self._prepare_user_features(user_profile),
                **self._prepare_item_features(item)
            }
            predictions_data.append(sample)
        
        # Создаем DataFrame
        df = pd.DataFrame(predictions_data)
        
        # Получаем предсказания
        try:
            predictions, probabilities = self.model.predict(df)
            
            # Добавляем оценки к предметам
            scored_items = []
            for i, item in enumerate(available_items):
                if probabilities[i] >= min_confidence:
                    item_copy = item.copy()
                    item_copy['ml_score'] = float(probabilities[i])
                    item_copy['is_recommended'] = bool(predictions[i])
                    scored_items.append(item_copy)
            
            # Сортируем по уверенности
            scored_items.sort(key=lambda x: x['ml_score'], reverse=True)
            
            # Берем топ-N
            recommendations = scored_items[:top_n]
            
            logger.info(f"Generated {len(recommendations)} ML-powered recommendations")
            logger.info(f"Average confidence: {sum(item['ml_score'] for item in recommendations) / len(recommendations):.2%}")
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Prediction error: {e}")
            return self._fallback_recommendations(weather_data, available_items, top_n)
    
    def build_outfit(self,
                    weather_data: Dict,
                    user_profile: Dict,
                    all_items: List[Dict],
                    min_confidence: float = 0.5) -> Dict:
        """
        Собирает полный комплект одежды с ML оценками
        
        Returns:
            {
                'items': [...],
                'outfit_score': float,
                'ml_powered': bool,
                'confidence_breakdown': {...}
            }
        """
        logger.info("Building ML-powered outfit...")
        
        # Группируем предметы по категориям
        items_by_category = self._group_by_category(all_items)
        
        # Определяем необходимые категории
        temp = weather_data.get('temperature', 20)
        weather = weather_data.get('weather', 'Ясно')
        required_categories = self._get_required_categories(temp, weather)
        
        outfit_items = []
        category_confidences = {}
        
        # Для каждой категории получаем лучший предмет
        for category in required_categories:
            items_in_category = items_by_category.get(category, [])
            
            if not items_in_category:
                logger.warning(f"No items in category: {category}")
                continue
            
            # Получаем рекомендации для этой категории
            category_recommendations = self.recommend_items(
                weather_data,
                user_profile,
                items_in_category,
                top_n=1,
                min_confidence=min_confidence
            )
            
            if category_recommendations:
                best_item = category_recommendations[0]
                outfit_items.append(best_item)
                category_confidences[category] = best_item['ml_score']
                
                logger.debug(f"Selected for {category}: {best_item['name']} "
                           f"(confidence: {best_item['ml_score']:.2%})")
        
        # Добавляем аксессуары (опционально)
        if 'accessories' in items_by_category:
            accessories = self.recommend_items(
                weather_data,
                user_profile,
                items_by_category['accessories'],
                top_n=2,
                min_confidence=0.6  # Выше порог для аксессуаров
            )
            
            for acc in accessories:
                outfit_items.append(acc)
                category_confidences[f"accessory_{acc['name']}"] = acc['ml_score']
        
        # Вычисляем общую оценку
        if outfit_items:
            outfit_score = sum(item['ml_score'] for item in outfit_items) / len(outfit_items)
        else:
            outfit_score = 0.0
        
        result = {
            'items': outfit_items,
            'outfit_score': float(outfit_score),
            'ml_powered': self.model.is_trained,
            'confidence_breakdown': category_confidences,
            'total_items': len(outfit_items),
            'algorithm': 'advanced_ml_v1'
        }
        
        logger.info(f"Built outfit: {len(outfit_items)} items, "
                   f"score: {outfit_score:.2%}")
        
        return result
    
    def explain_recommendation(self, 
                              weather_data: Dict,
                              user_profile: Dict,
                              item: Dict) -> str:
        """
        Генерирует объяснение рекомендации
        """
        temp = weather_data.get('temperature', 20)
        item_name = item.get('name', 'предмет')
        min_temp = item.get('min_temp', 0)
        max_temp = item.get('max_temp', 30)
        confidence = item.get('ml_score', 0)
        
        explanations = []
        
        # Уверенность модели
        if confidence >= 0.9:
            explanations.append("ML модель очень уверена в этом выборе")
        elif confidence >= 0.7:
            explanations.append("ML модель рекомендует с высокой уверенностью")
        elif confidence >= 0.5:
            explanations.append("ML модель считает это приемлемым выбором")
        
        # Температурное соответствие
        if min_temp <= temp <= max_temp:
            explanations.append(f"идеально для температуры {temp}°C")
        
        # Стиль
        user_style = user_profile.get('style_preference', 'casual')
        item_style = item.get('style', 'casual')
        if user_style == item_style:
            explanations.append(f"соответствует вашему стилю ({user_style})")
        
        # Формальность
        formality = item.get('formality_level', 5)
        if formality >= 8:
            explanations.append("подходит для делового стиля")
        elif formality <= 3:
            explanations.append("отлично для повседневной носки")
        
        if explanations:
            return f"{item_name}: " + ", ".join(explanations) + f" (уверенность: {confidence:.0%})"
        else:
            return f"{item_name} рекомендован ML моделью (уверенность: {confidence:.0%})"
    
    def _prepare_weather_features(self, weather_data: Dict) -> Dict:
        """Подготавливает погодные признаки"""
        # Маппинг погодных условий
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
        
        # Определяем сезон по температуре
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
        return grouped
    
    def _get_required_categories(self, temperature: float, weather: str) -> List[str]:
        """Определяет необходимые категории одежды"""
        categories = ['upper', 'lower', 'footwear']
        
        # Верхняя одежда
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
            
            # Простая оценка по температуре
            if min_temp <= temp <= max_temp:
                score = 0.8
            elif min_temp - 5 <= temp <= max_temp + 5:
                score = 0.5
            else:
                score = 0.2
            
            item_copy = item.copy()
            item_copy['ml_score'] = score
            item_copy['is_recommended'] = score >= 0.5
            scored_items.append(item_copy)
        
        scored_items.sort(key=lambda x: x['ml_score'], reverse=True)
        return scored_items[:top_n]