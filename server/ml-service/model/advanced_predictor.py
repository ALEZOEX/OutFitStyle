import pandas as pd
import numpy as np
from typing import Dict, List
import logging

logger = logging.getLogger(__name__)

class AdvancedOutfitPredictor:
    """Предиктор для продвинутой ML модели"""
    
    def __init__(self, model):
        self.model = model
    
    def build_outfit(self, weather_data: Dict, user_profile: Dict, available_items: List[Dict]) -> Dict:
        """
        Создает комплект одежды используя продвинутую ML модель
        """
        try:
            if not self.model or not self.model.is_trained:
                logger.warning("Advanced model not available, using rule-based approach")
                return self._rule_based_outfit(weather_data, user_profile, available_items)
            
            # Подготовка данных для каждого предмета
            item_scores = []
            
            for item in available_items:
                # Создаем предсказание для каждого предмета
                prediction = self.model.predict_single(weather_data, user_profile, item)
                
                item_scores.append({
                    'item': item,
                    'score': prediction['confidence'],
                    'is_recommended': prediction['is_recommended']
                })
            
            # Сортируем по убыванию уверенности
            item_scores.sort(key=lambda x: x['score'], reverse=True)
            
            # Формируем комплект одежды (берем по одной категории)
            outfit_items = []
            used_categories = set()
            
            for item_score in item_scores:
                if item_score['is_recommended']:
                    category = item_score['item']['category']
                    if category not in used_categories:
                        outfit_items.append({
                            **item_score['item'],
                            'ml_score': item_score['score']
                        })
                        used_categories.add(category)
            
            # Если не нашли рекомендованные предметы, берем топ-5 по скору
            if not outfit_items and item_scores:
                outfit_items = [
                    {**item_score['item'], 'ml_score': item_score['score']}
                    for item_score in item_scores[:5]
                ]
            
            outfit_scorenp.mean([item.get('ml_score', 0) for item in outfit_items]) if outfit_items else 0
            
            return {
                'items': outfit_items,
                'outfit_score': float(outfit_score),
                'ml_powered': True
            }
            
        except Exception as e:
            logger.error(f"Error in advanced prediction: {e}")
            return self._rule_based_outfit(weather_data, user_profile, available_items)
    
    def _rule_based_outfit(self, weather_data: Dict, user_profile: Dict, available_items: List[Dict]) -> Dict:
        """
        Резервный метод на случай ошибок ML
        """
        logger.info("Using rule-based outfit building as fallback")
        
        temperature = weather_data.get('temperature', 20)
        weather_condition = weather_data.get('weather', 'clear').lower()
        
        # Map weather conditions to simpler categories
        weather_map = {
            'ясно': 'clear',
            'облачно': 'clouds',
            'дождь': 'rain',
            'морось': 'drizzle',
            'снег': 'snow',
            'туман': 'mist',
            'гроза': 'thunderstorm'
        }
        
        weather_condition = weather_map.get(weather_condition, 'clear')
        
        # Categorize items by type
        categorized_items = {}
        for item in available_items:
            category = item['category']
            if category not in categorized_items:
                categorized_items[category] = []
            categorized_items[category].append(item)
        
        # Select items based on weather and temperature
        outfit_items = []
        
        # Outerwear for cold temperatures
        if temperature <= 15 and 'outerwear' in categorized_items:
            # Sort by warmth level for cold weather
            outerwear = sorted(
                categorized_items['outerwear'], 
                key=lambda x: x['warmth_level'], 
                reverse=True
            )
            outfit_items.append(outerwear[0])
        elif temperature > 25 and 'upper' in categorized_items:
            # Light clothing for hot weather
            light_tops = [item for item in categorized_items['upper'] 
                         if item['warmth_level'] <= 2]
            if light_tops:
                outfit_items.append(light_tops[0])
        
        # Always add lower body item
        if 'lower' in categorized_items:
            outfit_items.append(categorized_items['lower'][0])
        
        # Footwear
        if 'footwear' in categorized_items:
            footwear = categorized_items['footwear']
            # Choose based on weather
            if weather_condition in ['rain', 'drizzle'] and any('waterproof' in item['name'].lower() for item in footwear):
                waterproof = [item for item in footwear if 'waterproof' in item['name'].lower()]
                outfit_items.append(waterproof[0])
            else:
                outfit_items.append(footwear[0])
        
        return {
            'items': outfit_items,
            'outfit_score': 0.5,  # Medium confidence for rule-based
            'ml_powered': False
        }