import pandas as pd
import numpy as np
import os

class DatasetPreparer:
    """Подготовка датасета для обучения ML модели"""
    
    def __init__(self):
        self.weather_conditions = ['clear', 'clouds', 'rain', 'snow', 'drizzle']
        self.seasons = ['winter', 'spring', 'summer', 'autumn']
        self.age_ranges = ['18-25', '25-35', '35-45', '45+']
        self.styles = ['casual', 'business', 'sporty', 'elegant']
        self.sensitivities = ['very_cold', 'cold', 'normal', 'warm', 'very_warm']
        self.formality_levels = ['informal', 'semi_formal', 'formal']
        
    def generate_weather_data(self, num_samples=5000):
        """
        Генерирует разнообразные погодные условия
        """
        print("Generating weather data...")
        
        np.random.seed(42)
        
        data = {
            'temperature': [],
            'feels_like': [],
            'humidity': [],
            'wind_speed': [],
            'weather_condition': [],
            'season': [],
        }
        
        seasons = ['winter', 'spring', 'summer', 'autumn']
        weather_conditions = ['clear', 'clouds', 'rain', 'snow', 'drizzle']
        
        for i in range(num_samples):
            # Выбираем сезон
            season = np.random.choice(seasons)
            
            # Генерируем температуру в зависимости от сезона
            if season == 'winter':
                temp = np.random.normal(-5, 10)
            elif season == 'spring':
                temp = np.random.normal(12, 8)
            elif season == 'summer':
                temp = np.random.normal(25, 7)
            else:  # autumn
                temp = np.random.normal(10, 8)
            
            # Ощущаемая температура
            wind = np.random.uniform(0, 15)
            feels_like = temp - (wind / 5) + np.random.uniform(-3, 3)
            
            # Влажность
            humidity = np.random.randint(30, 95)
            
            # Погодные условия в зависимости от сезона
            if season == 'winter':
                weather = np.random.choice(['clear', 'clouds', 'snow'], p=[0.3, 0.4, 0.3])
            elif season == 'summer':
                weather = np.random.choice(['clear', 'clouds', 'rain'], p=[0.6, 0.3, 0.1])
            else:
                weather = np.random.choice(weather_conditions, p=[0.3, 0.3, 0.2, 0.1, 0.1])
            
            data['temperature'].append(round(temp, 1))
            data['feels_like'].append(round(feels_like, 1))
            data['humidity'].append(humidity)
            data['wind_speed'].append(round(wind, 1))
            data['weather_condition'].append(weather)
            data['season'].append(season)
        
        df = pd.DataFrame(data)
        print(f"Generated {len(df)} weather samples")
        return df
    
    def generate_user_preferences(self, num_users=100):
        """
        Генерирует профили пользователей с разными предпочтениями
        """
        print("Generating user preferences...")
        
        np.random.seed(42)
        
        data = {
            'user_id': [],
            'age_range': [],
            'style_preference': [],
            'temperature_sensitivity': [],
            'formality_preference': [],
        }
        
        age_ranges = ['18-25', '25-35', '35-45', '45+']
        styles = ['casual', 'business', 'sporty', 'elegant']
        sensitivities = ['very_cold', 'cold', 'normal', 'warm', 'very_warm']
        formality = ['informal', 'semi_formal', 'formal']
        
        for i in range(num_users):
            data['user_id'].append(i + 1)
            data['age_range'].append(np.random.choice(age_ranges))
            data['style_preference'].append(np.random.choice(styles))
            data['temperature_sensitivity'].append(np.random.choice(sensitivities))
            data['formality_preference'].append(np.random.choice(formality))
        
        df = pd.DataFrame(data)
        print(f"Generated {len(df)} user profiles")
        return df
    
    def create_clothing_dataset(self):
        """
        Создает датасет одежды с характеристиками
        """
        print("Creating clothing dataset...")
        
        clothing_data = [
            # Winter (very cold: -30 to 0)
            {'name': 'Heavy Parka', 'category': 'outerwear', 'min_temp': -30, 'max_temp': 0, 'warmth': 10, 'formality': 4, 'style': 'casual', 'weather': ['clear', 'snow', 'clouds']},
            {'name': 'Down Jacket', 'category': 'outerwear', 'min_temp': -25, 'max_temp': 5, 'warmth': 9, 'formality': 5, 'style': 'casual', 'weather': ['clear', 'snow']},
            {'name': 'Wool Coat', 'category': 'outerwear', 'min_temp': -15, 'max_temp': 5, 'warmth': 8, 'formality': 8, 'style': 'business', 'weather': ['clear', 'clouds']},
            {'name': 'Thermal Underwear', 'category': 'upper', 'min_temp': -30, 'max_temp': 0, 'warmth': 9, 'formality': 2, 'style': 'sporty', 'weather': ['clear', 'snow']},
            {'name': 'Heavy Sweater', 'category': 'upper', 'min_temp': -10, 'max_temp': 10, 'warmth': 7, 'formality': 5, 'style': 'casual', 'weather': ['clear', 'clouds']},
            {'name': 'Winter Boots', 'category': 'footwear', 'min_temp': -30, 'max_temp': 5, 'warmth': 9, 'formality': 5, 'style': 'casual', 'weather': ['snow', 'clouds']},
            
            # Cold (0 to 10)
            {'name': 'Winter Jacket', 'category': 'outerwear', 'min_temp': -5, 'max_temp': 10, 'warmth': 7, 'formality': 5, 'style': 'casual', 'weather': ['clear', 'clouds', 'rain']},
            {'name': 'Fleece Jacket', 'category': 'outerwear', 'min_temp': 0, 'max_temp': 15, 'warmth': 6, 'formality': 4, 'style': 'sporty', 'weather': ['clear', 'clouds']},
            {'name': 'Cardigan', 'category': 'upper', 'min_temp': 5, 'max_temp': 18, 'warmth': 5, 'formality': 6, 'style': 'casual', 'weather': ['clear', 'clouds']},
            {'name': 'Long Sleeve Shirt', 'category': 'upper', 'min_temp': 0, 'max_temp': 20, 'warmth': 4, 'formality': 7, 'style': 'business', 'weather': ['clear', 'clouds']},
            {'name': 'Jeans', 'category': 'lower', 'min_temp': -5, 'max_temp': 25, 'warmth': 4, 'formality': 5, 'style': 'casual', 'weather': ['clear', 'clouds', 'rain']},
            
            # Cool (10 to 18)
            {'name': 'Light Jacket', 'category': 'outerwear', 'min_temp': 10, 'max_temp': 20, 'warmth': 4, 'formality': 6, 'style': 'casual', 'weather': ['clear', 'clouds']},
            {'name': 'Denim Jacket', 'category': 'outerwear', 'min_temp': 12, 'max_temp': 22, 'warmth': 3, 'formality': 5, 'style': 'casual', 'weather': ['clear', 'clouds']},
            {'name': 'Hoodie', 'category': 'upper', 'min_temp': 8, 'max_temp': 20, 'warmth': 5, 'formality': 3, 'style': 'sporty', 'weather': ['clear', 'clouds']},
            {'name': 'Polo Shirt', 'category': 'upper', 'min_temp': 15, 'max_temp': 28, 'warmth': 2, 'formality': 6, 'style': 'casual', 'weather': ['clear', 'clouds']},
            {'name': 'Chinos', 'category': 'lower', 'min_temp': 10, 'max_temp': 28, 'warmth': 3, 'formality': 7, 'style': 'business', 'weather': ['clear', 'clouds']},
            {'name': 'Sneakers', 'category': 'footwear', 'min_temp': 5, 'max_temp': 35, 'warmth': 3, 'formality': 4, 'style': 'casual', 'weather': ['clear', 'clouds']},
            
            # Warm (18 to 25)
            {'name': 'T-Shirt', 'category': 'upper', 'min_temp': 18, 'max_temp': 35, 'warmth': 1, 'formality': 3, 'style': 'casual', 'weather': ['clear', 'clouds']},
            {'name': 'Shorts', 'category': 'lower', 'min_temp': 20, 'max_temp': 40, 'warmth': 1, 'formality': 3, 'style': 'casual', 'weather': ['clear']},
            {'name': 'Summer Dress', 'category': 'upper', 'min_temp': 20, 'max_temp': 35, 'warmth': 1, 'formality': 6, 'style': 'elegant', 'weather': ['clear']},
            {'name': 'Linen Shirt', 'category': 'upper', 'min_temp': 22, 'max_temp': 38, 'warmth': 1, 'formality': 7, 'style': 'business', 'weather': ['clear']},
            
            # Hot (25+)
            {'name': 'Tank Top', 'category': 'upper', 'min_temp': 25, 'max_temp': 45, 'warmth': 1, 'formality': 2, 'style': 'casual', 'weather': ['clear']},
            {'name': 'Swim Shorts', 'category': 'lower', 'min_temp': 28, 'max_temp': 45, 'warmth': 1, 'formality': 1, 'style': 'sporty', 'weather': ['clear']},
            {'name': 'Sandals', 'category': 'footwear', 'min_temp': 22, 'max_temp': 45, 'warmth': 1, 'formality': 2, 'style': 'casual', 'weather': ['clear']},
            
            # Rain gear
            {'name': 'Raincoat', 'category': 'outerwear', 'min_temp': 5, 'max_temp': 25, 'warmth': 3, 'formality': 4, 'style': 'casual', 'weather': ['rain', 'drizzle']},
            {'name': 'Umbrella', 'category': 'accessories', 'min_temp': -10, 'max_temp': 35, 'warmth': 0, 'formality': 5, 'style': 'casual', 'weather': ['rain', 'drizzle']},
            {'name': 'Waterproof Boots', 'category': 'footwear', 'min_temp': 0, 'max_temp': 20, 'warmth': 5, 'formality': 5, 'style': 'casual', 'weather': ['rain', 'snow']},
            
            # Business
            {'name': 'Suit', 'category': 'upper', 'min_temp': 15, 'max_temp': 28, 'warmth': 3, 'formality': 10, 'style': 'business', 'weather': ['clear', 'clouds']},
            {'name': 'Blazer', 'category': 'outerwear', 'min_temp': 15, 'max_temp': 28, 'warmth': 3, 'formality': 9, 'style': 'business', 'weather': ['clear', 'clouds']},
            {'name': 'Dress Pants', 'category': 'lower', 'min_temp': 10, 'max_temp': 30, 'warmth': 3, 'formality': 9, 'style': 'business', 'weather': ['clear', 'clouds']},
            {'name': 'Oxford Shoes', 'category': 'footwear', 'min_temp': 5, 'max_temp': 35, 'warmth': 2, 'formality': 10, 'style': 'business', 'weather': ['clear', 'clouds']},
            
            # Accessories
            {'name': 'Scarf', 'category': 'accessories', 'min_temp': -30, 'max_temp': 10, 'warmth': 7, 'formality': 6, 'style': 'elegant', 'weather': ['clear', 'clouds', 'snow']},
            {'name': 'Gloves', 'category': 'accessories', 'min_temp': -30, 'max_temp': 5, 'warmth': 8, 'formality': 5, 'style': 'casual', 'weather': ['clear', 'snow']},
            {'name': 'Winter Hat', 'category': 'accessories', 'min_temp': -30, 'max_temp': 5, 'warmth': 8, 'formality': 4, 'style': 'casual', 'weather': ['clear', 'snow']},
            {'name': 'Sunglasses', 'category': 'accessories', 'min_temp': 15, 'max_temp': 45, 'warmth': 0, 'formality': 5, 'style': 'casual', 'weather': ['clear']},
            {'name': 'Baseball Cap', 'category': 'accessories', 'min_temp': 15, 'max_temp': 40, 'warmth': 0, 'formality': 3, 'style': 'sporty', 'weather': ['clear']},
        ]
        
        df = pd.DataFrame(clothing_data)
        print(f"Created {len(df)} clothing items")
        return df
    
    def generate_training_data(self, num_samples=10000):
        """
        Генерирует полный датасет для обучения
        """
        print("\nGenerating complete training dataset...")
        
        weather_df = self.generate_weather_data(num_samples)
        users_df = self.generate_user_preferences(100)
        clothing_df = self.create_clothing_dataset()
        
        training_data = []

        print("Creating training samples...")
        for idx in range(num_samples):
            user = users_df.sample(1).iloc[0]
            weather = weather_df.iloc[idx]
            
            for _, item in clothing_df.iterrows():
                is_good_choice = self._evaluate_choice(weather, user, item)
                
                sample = {
                    # Weather features
                    'temperature': weather['temperature'],
                    'feels_like': weather['feels_like'],
                    'humidity': weather['humidity'],
                    'wind_speed': weather['wind_speed'],
                    'weather_condition': weather['weather_condition'],
                    'season': weather['season'],
                    
                    # User features
                    'age_range': user['age_range'],
                    'style_preference': user['style_preference'],
                    'temperature_sensitivity': user['temperature_sensitivity'],
                    'formality_preference': user['formality_preference'],
                    
                    # Item features
                    'item_name': item['name'],
                    'category': item['category'],
                    'min_temp': item['min_temp'],
                    'max_temp': item['max_temp'],
                    'warmth_level': item['warmth'],
                    'formality_level': item['formality'],
                    'item_style': item['style'],
                    
                    # Target
                    'is_recommended': is_good_choice
                }
                
                training_data.append(sample)
            
            if (idx + 1) % 1000 == 0:
                print(f"  Processed {idx + 1}/{num_samples} samples...")
        
        df = pd.DataFrame(training_data)
        
        # Балансируем датасет
        positive = df[df['is_recommended'] == 1]
        negative = df[df['is_recommended'] == 0]
        
        n_samples = min(len(positive), len(negative))
        
        balanced_df = pd.concat([
            positive.sample(n_samples, random_state=42),
            negative.sample(n_samples, random_state=42)
        ]).sample(frac=1, random_state=42).reset_index(drop=True)
        
        print(f"\nGenerated {len(balanced_df)} balanced training samples")
        print(f"   Positive: {sum(balanced_df['is_recommended'])} ({sum(balanced_df['is_recommended'])/len(balanced_df)*100:.1f}%)")
        print(f"   Negative: {len(balanced_df) - sum(balanced_df['is_recommended'])} ({(len(balanced_df) - sum(balanced_df['is_recommended']))/len(balanced_df)*100:.1f}%)")
        
        return balanced_df
    
    def _evaluate_choice(self, weather, user, item):
        """Оценивает подходит ли предмет одежды"""
        score = 0
        max_score = 100
        
        temp = weather['temperature']
        
        # 1. Температурное соответствие (40 баллов)
        if item['min_temp'] <= temp <= item['max_temp']:
            score += 40
        elif item['min_temp'] - 5 <= temp <= item['max_temp'] + 5:
            score += 20
        elif item['min_temp'] - 10 <= temp <= item['max_temp'] + 10:
            score += 5
        
        # 2. Чувствительность (20 баллов)
        sensitivity = user['temperature_sensitivity']
        warmth = item['warmth']
        
        if sensitivity == 'very_cold' and warmth >= 8:
            score += 20
        elif sensitivity == 'cold' and warmth >= 6:
            score += 20
        elif sensitivity == 'normal' and 3 <= warmth <= 7:
            score += 20
        elif sensitivity == 'warm' and warmth <= 4:
            score += 20
        elif sensitivity == 'very_warm' and warmth <= 2:
            score += 20
        
        # 3. Стиль (20 баллов)
        if user['style_preference'] == item['style']:
            score += 20
        elif user['style_preference'] == 'casual':
            score += 10
        
        # 4. Формальность (10 баллов)
        user_formality = user['formality_preference']
        item_formality = item['formality']
        
        if user_formality == 'formal' and item_formality >= 7:
            score += 10
        elif user_formality == 'semi_formal' and 4 <= item_formality <= 8:
            score += 10
        elif user_formality == 'informal' and item_formality <= 5:
            score += 10
        
        # 5. Погода (10 баллов)
        if weather['weather_condition'] in item['weather']:
            score += 10
        
        return 1 if score >= 60 else 0
    
    def save_dataset(self, df, filename='training_data.csv'):
        """Сохраняет датасет"""
        os.makedirs('data', exist_ok=True)
        filepath = f'data/{filename}'
        df.to_csv(filepath, index=False)
        print(f"\nDataset saved to {filepath}")
        print(f"   Size: {len(df)} samples")
        return filepath

if __name__ == '__main__':
    print("=" * 60)
    print("OutfitStyle ML Dataset Preparation")
    print("=" * 60)
    
    preparer = DatasetPreparer()
    
    df = preparer.generate_training_data(num_samples=5000)
    
    print("\nDataset Statistics:")
    print(f"   Total samples: {len(df)}")
    print(f"   Features: {len(df.columns)}")
    print("\n   Categories distribution:")
    print(df['category'].value_counts())
    print(f"\n   Temperature range: {df['temperature'].min():.1f}°C to {df['temperature'].max():.1f}°C")

    filepath = preparer.save_dataset(df)

    print("\nDataset preparation complete!")
    print(f"   Use this file to train your ML model: {filepath}")