import numpy as np
from typing import Dict, List

class FeatureExtractor:
    """Извлечение признаков для ML модели"""
    
    # Словари для кодирования категориальных признаков
    SENSITIVITY_MAP = {
        'very_cold': 0,
        'cold': 1,
        'normal': 2,
        'warm': 3,
        'very_warm': 4
    }
    
    STYLE_MAP = {
        'casual': 0,
        'business': 1,
        'sporty': 2,
        'elegant': 3
    }
    
    WEATHER_MAP = {
        'ясно': 0,
        'облачно': 1,
        'дождь': 2,
        'морось': 2,
        'снег': 3,
        'туман': 4,
        'гроза': 5
    }
    
    CATEGORY_MAP = {
        'upper': 0,
        'lower': 1,
        'outerwear': 2,
        'footwear': 3,
        'accessories': 4
    }
    
    @staticmethod
    def extract_weather_features(weather_data: Dict) -> np.ndarray:
        """
        Извлекает признаки из погодных данных
        
        Features:
        - temperature (numeric)
        - feels_like (numeric)
        - humidity (numeric)
        - wind_speed (numeric)
        - weather_condition (one-hot encoded)
        - temperature_category (one-hot encoded)
        """
        temp = weather_data.get('temperature', 20)
        feels = weather_data.get('feels_like', temp)
        humidity = weather_data.get('humidity', 50)
        wind = weather_data.get('wind_speed', 0)
        weather = weather_data.get('weather', 'Ясно').lower()
        
        # Числовые признаки
        numeric_features = [
            temp,
            feels,
            humidity,
            wind,
            abs(temp - feels),  # Разница между реальной и ощущаемой температурой
        ]
        
        # Погодные условия (one-hot)
        weather_encoded = FeatureExtractor.WEATHER_MAP.get(weather, 0)
        weather_onehot = [0] * 6
        weather_onehot[weather_encoded] = 1
        
        # Температурные категории
        temp_categories = [
            1 if temp < -10 else 0,  # Экстремальный холод
            1 if -10 <= temp < 0 else 0,  # Мороз
            1 if 0 <= temp < 10 else 0,  # Холод
            1 if 10 <= temp < 18 else 0,  # Прохладно
            1 if 18 <= temp < 25 else 0,  # Комфорт
            1 if temp >= 25 else 0,  # Жара
        ]
        
        return np.array(numeric_features + weather_onehot + temp_categories)
    
    @staticmethod
    def extract_user_features(user_profile: Dict) -> np.ndarray:
        """
        Извлекает признаки профиля пользователя
        
        Features:
        - temperature_sensitivity (encoded)
        - style_preference (encoded)
        - age_range (one-hot encoded)
        """
        sensitivity = user_profile.get('temperature_sensitivity', 'normal')
        style = user_profile.get('style_preference', 'casual')
        age_range = user_profile.get('age_range', '25-35')
        
        # Чувствительность к температуре
        sensitivity_encoded = FeatureExtractor.SENSITIVITY_MAP.get(sensitivity, 2)
        
        # Стиль
        style_encoded = FeatureExtractor.STYLE_MAP.get(style, 0)
        
        # Возрастные группы
        age_features = [
            1 if age_range == '18-25' else 0,
            1 if age_range == '25-35' else 0,
            1 if age_range == '35-45' else 0,
            1 if age_range == '45+' else 0,
        ]
        
        return np.array([sensitivity_encoded, style_encoded] + age_features)
    
    @staticmethod
    def extract_item_features(item: Dict) -> np.ndarray:
        """
        Извлекает признаки предмета одежды
        
        Features:
        - warmth_level (numeric)
        - formality_level (numeric)
        - min_temp (numeric)
        - max_temp (numeric)
        - avg_temp (numeric)
        - temp_range (numeric)
        - category (one-hot encoded)
        - style (encoded)
        """
        warmth = item.get('warmth_level', 5)
        formality = item.get('formality_level', 5)
        min_temp = item.get('min_temp', 0)
        max_temp = item.get('max_temp', 30)
        avg_temp = (min_temp + max_temp) / 2
        temp_range = max_temp - min_temp
        category = item.get('category', 'upper')
        style = item.get('style', 'casual')
        
        # Числовые признаки
        numeric_features = [
            warmth,
            formality,
            min_temp,
            max_temp,
            avg_temp,
            temp_range,
        ]
        
        # Категория (one-hot)
        category_encoded = FeatureExtractor.CATEGORY_MAP.get(category, 0)
        category_onehot = [0] * 5
        category_onehot[category_encoded] = 1
        
        # Стиль
        style_encoded = FeatureExtractor.STYLE_MAP.get(style, 0)
        
        return np.array(numeric_features + category_onehot + [style_encoded])
    
    @staticmethod
    def extract_interaction_features(weather_data: Dict, user_profile: Dict, item: Dict) -> np.ndarray:
        """
        Извлекает признаки взаимодействия между погодой, пользователем и предметом
        """
        temp = weather_data.get('temperature', 20)
        min_temp = item.get('min_temp', 0)
        max_temp = item.get('max_temp', 30)
        warmth = item.get('warmth_level', 5)
        sensitivity = user_profile.get('temperature_sensitivity', 'normal')
        user_style = user_profile.get('style_preference', 'casual')
        item_style = item.get('style', 'casual')
        
        # Насколько температура подходит для предмета
        if min_temp <= temp <= max_temp:
            temp_suitability = 1.0
        elif min_temp - 5 <= temp <= max_temp + 5:
            temp_suitability = 0.5
        else:
            temp_suitability = 0.0
        
        # Насколько предмет теплый для пользователя
        sensitivity_warmth_match = 0.5
        if sensitivity == 'cold' and warmth >= 7:
            sensitivity_warmth_match = 1.0
        elif sensitivity == 'warm' and warmth <= 3:
            sensitivity_warmth_match = 1.0
        elif sensitivity == 'normal' and 4 <= warmth <= 6:
            sensitivity_warmth_match = 1.0
        
        # Совпадение стилей
        style_match = 1.0 if user_style == item_style else 0.3
        
        # Расстояние до оптимальной температуры
        optimal_temp = (min_temp + max_temp) / 2
        temp_distance = abs(temp - optimal_temp)
        
        return np.array([
            temp_suitability,
            sensitivity_warmth_match,
            style_match,
            temp_distance,
        ])
    
    @staticmethod
    def combine_features(weather_features: np.ndarray, 
                         user_features: np.ndarray,
                         item_features: np.ndarray,
                         interaction_features: np.ndarray) -> np.ndarray:
        """
        Объединяет все признаки в один вектор
        """
        return np.concatenate([
            weather_features,
            user_features,
            item_features,
            interaction_features
        ])
    
    @staticmethod
    def get_feature_names() -> List[str]:
        """Возвращает названия всех признаков"""
        weather_names = [
            'temp', 'feels_like', 'humidity', 'wind_speed', 'temp_diff',
            'weather_clear', 'weather_clouds', 'weather_rain', 'weather_snow', 
            'weather_mist', 'weather_thunder',
            'temp_extreme_cold', 'temp_frost', 'temp_cold', 'temp_cool', 'temp_comfort', 'temp_hot'
        ]
        
        user_names = [
            'sensitivity', 'style_pref',
            'age_18_25', 'age_25_35', 'age_35_45', 'age_45_plus'
        ]
        
        item_names = [
            'warmth', 'formality', 'min_temp', 'max_temp', 'avg_temp', 'temp_range',
            'cat_upper', 'cat_lower', 'cat_outerwear', 'cat_footwear', 'cat_accessories',
            'item_style'
        ]
        
        interaction_names = [
            'temp_suitability', 'sensitivity_warmth_match', 'style_match', 'temp_distance'
        ]
        
        return weather_names + user_names + item_names + interaction_names