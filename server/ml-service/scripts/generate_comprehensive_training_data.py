#!/usr/bin/env python3
"""
Script to generate comprehensive training data considering all parameters:
- Weather (temperature, humidity, wind, conditions)
- User profiles (gender, age, preferences)
- Clothing characteristics (warmth, formality, style)
"""

import pandas as pd
import numpy as np
import random
from datetime import datetime

def generate_weather_conditions(n_samples=1000):
    """Generate diverse weather conditions"""
    weather_data = []
    
    weather_types = ['clear', 'clouds', 'rain', 'drizzle', 'snow', 'mist', 'thunderstorm']
    seasons = ['winter', 'spring', 'summer', 'autumn']
    
    for i in range(n_samples):
        # Generate realistic temperature ranges for each season
        season = random.choice(seasons)
        
        if season == 'winter':
            temp = np.random.normal(-5, 10)  # -30 to 10
        elif season == 'spring':
            temp = np.random.normal(12, 8)   # 0 to 25
        elif season == 'summer':
            temp = np.random.normal(25, 7)   # 15 to 40
        else:  # autumn
            temp = np.random.normal(10, 8)   # -5 to 25
        
        # Ensure realistic ranges
        temp = max(-35, min(45, temp))
        
        # Feels like temperature (affected by wind)
        wind_speed = np.random.uniform(0, 15)
        feels_like = temp - (wind_speed / 5) + np.random.uniform(-3, 3)
        feels_like = max(-40, min(50, feels_like))
        
        # Humidity (varies with temperature and weather)
        if temp < 0:
            humidity = np.random.randint(40, 90)
        elif temp > 30:
            humidity = np.random.randint(30, 70)
        else:
            humidity = np.random.randint(40, 95)
        
        # Weather condition (correlated with season)
        if season == 'winter':
            weather = random.choices(weather_types, weights=[0.3, 0.3, 0.1, 0.05, 0.2, 0.05, 0.0], k=1)[0]
        elif season == 'summer':
            weather = random.choices(weather_types, weights=[0.5, 0.3, 0.1, 0.05, 0.0, 0.05, 0.0], k=1)[0]
        else:
            weather = random.choices(weather_types, weights=[0.3, 0.3, 0.15, 0.1, 0.05, 0.05, 0.05], k=1)[0]
        
        weather_data.append({
            'temperature': round(temp, 1),
            'feels_like': round(feels_like, 1),
            'humidity': humidity,
            'wind_speed': round(wind_speed, 1),
            'weather_condition': weather,
            'season': season
        })
    
    return weather_data

def generate_user_profiles(n_profiles=200):
    """Generate diverse user profiles with all parameters"""
    genders = ['male', 'female']
    age_ranges = ['18-25', '25-35', '35-45', '45+']
    styles = ['casual', 'business', 'sporty', 'elegant']
    sensitivities = ['very_cold', 'cold', 'normal', 'warm', 'very_warm']
    formalities = ['informal', 'semi_formal', 'formal']
    
    profiles = []
    for i in range(n_profiles):
        profiles.append({
            'gender': random.choice(genders),
            'age_range': random.choice(age_ranges),
            'style_preference': random.choice(styles),
            'temperature_sensitivity': random.choice(sensitivities),
            'formality_preference': random.choice(formalities)
        })
    
    return profiles

def generate_comprehensive_clothing_database():
    """Generate a comprehensive clothing database with all parameters"""
    clothing_items = [
        # Winter outerwear
        {'name': 'Heavy Winter Coat', 'category': 'outerwear', 'min_temp': -40, 'max_temp': -5, 'warmth_level': 10, 'formality_level': 6, 'style': 'casual'},
        {'name': 'Down Parka', 'category': 'outerwear', 'min_temp': -30, 'max_temp': 0, 'warmth_level': 9, 'formality_level': 5, 'style': 'casual'},
        {'name': 'Wool Overcoat', 'category': 'outerwear', 'min_temp': -20, 'max_temp': 5, 'warmth_level': 8, 'formality_level': 9, 'style': 'business'},
        {'name': 'Fur Coat', 'category': 'outerwear', 'min_temp': -25, 'max_temp': -2, 'warmth_level': 10, 'formality_level': 8, 'style': 'elegant'},
        
        # Winter upper body
        {'name': 'Thermal Underwear', 'category': 'upper', 'min_temp': -40, 'max_temp': 5, 'warmth_level': 9, 'formality_level': 2, 'style': 'sporty'},
        {'name': 'Wool Sweater', 'category': 'upper', 'min_temp': -20, 'max_temp': 10, 'warmth_level': 8, 'formality_level': 6, 'style': 'casual'},
        {'name': 'Cashmere Sweater', 'category': 'upper', 'min_temp': -15, 'max_temp': 12, 'warmth_level': 7, 'formality_level': 8, 'style': 'elegant'},
        {'name': 'Hoodie', 'category': 'upper', 'min_temp': -10, 'max_temp': 15, 'warmth_level': 6, 'formality_level': 3, 'style': 'casual'},
        
        # Winter lower body
        {'name': 'Thermal Leggings', 'category': 'lower', 'min_temp': -35, 'max_temp': 0, 'warmth_level': 9, 'formality_level': 2, 'style': 'sporty'},
        {'name': 'Wool Pants', 'category': 'lower', 'min_temp': -25, 'max_temp': 5, 'warmth_level': 8, 'formality_level': 7, 'style': 'business'},
        {'name': 'Fleece Pants', 'category': 'lower', 'min_temp': -15, 'max_temp': 10, 'warmth_level': 7, 'formality_level': 4, 'style': 'casual'},
        
        # Winter footwear
        {'name': 'Insulated Boots', 'category': 'footwear', 'min_temp': -35, 'max_temp': -5, 'warmth_level': 10, 'formality_level': 4, 'style': 'casual'},
        {'name': 'Wool Socks', 'category': 'accessories', 'min_temp': -40, 'max_temp': 10, 'warmth_level': 9, 'formality_level': 2, 'style': 'casual'},
        
        # Cold weather items
        {'name': 'Light Jacket', 'category': 'outerwear', 'min_temp': -5, 'max_temp': 15, 'warmth_level': 5, 'formality_level': 6, 'style': 'casual'},
        {'name': 'Cardigan', 'category': 'upper', 'min_temp': 5, 'max_temp': 20, 'warmth_level': 4, 'formality_level': 6, 'style': 'casual'},
        {'name': 'Jeans', 'category': 'lower', 'min_temp': -10, 'max_temp': 25, 'warmth_level': 3, 'formality_level': 5, 'style': 'casual'},
        {'name': 'Sneakers', 'category': 'footwear', 'min_temp': 0, 'max_temp': 30, 'warmth_level': 3, 'formality_level': 4, 'style': 'casual'},
        
        # Cool weather items
        {'name': 'Blazer', 'category': 'outerwear', 'min_temp': 10, 'max_temp': 25, 'warmth_level': 3, 'formality_level': 9, 'style': 'business'},
        {'name': 'Long Sleeve Shirt', 'category': 'upper', 'min_temp': 5, 'max_temp': 22, 'warmth_level': 3, 'formality_level': 7, 'style': 'business'},
        {'name': 'Chinos', 'category': 'lower', 'min_temp': 5, 'max_temp': 28, 'warmth_level': 2, 'formality_level': 7, 'style': 'business'},
        {'name': 'Loafers', 'category': 'footwear', 'min_temp': 10, 'max_temp': 30, 'warmth_level': 2, 'formality_level': 8, 'style': 'business'},
        
        # Warm weather items
        {'name': 'T-Shirt', 'category': 'upper', 'min_temp': 18, 'max_temp': 35, 'warmth_level': 1, 'formality_level': 3, 'style': 'casual'},
        {'name': 'Shorts', 'category': 'lower', 'min_temp': 22, 'max_temp': 40, 'warmth_level': 1, 'formality_level': 2, 'style': 'casual'},
        {'name': 'Sandals', 'category': 'footwear', 'min_temp': 20, 'max_temp': 40, 'warmth_level': 1, 'formality_level': 2, 'style': 'casual'},
        {'name': 'Linen Shirt', 'category': 'upper', 'min_temp': 23, 'max_temp': 38, 'warmth_level': 1, 'formality_level': 6, 'style': 'casual'},
        
        # Rain items
        {'name': 'Raincoat', 'category': 'outerwear', 'min_temp': 5, 'max_temp': 25, 'warmth_level': 3, 'formality_level': 4, 'style': 'casual'},
        {'name': 'Umbrella', 'category': 'accessories', 'min_temp': -10, 'max_temp': 35, 'warmth_level': 0, 'formality_level': 3, 'style': 'casual'},
        {'name': 'Waterproof Boots', 'category': 'footwear', 'min_temp': -5, 'max_temp': 20, 'warmth_level': 4, 'formality_level': 3, 'style': 'casual'},
        
        # Accessories
        {'name': 'Scarf', 'category': 'accessories', 'min_temp': -20, 'max_temp': 10, 'warmth_level': 7, 'formality_level': 5, 'style': 'casual'},
        {'name': 'Gloves', 'category': 'accessories', 'min_temp': -30, 'max_temp': 5, 'warmth_level': 8, 'formality_level': 3, 'style': 'casual'},
        {'name': 'Winter Hat', 'category': 'accessories', 'min_temp': -35, 'max_temp': 0, 'warmth_level': 9, 'formality_level': 3, 'style': 'casual'},
        {'name': 'Sunglasses', 'category': 'accessories', 'min_temp': 15, 'max_temp': 45, 'warmth_level': 0, 'formality_level': 5, 'style': 'casual'},
        {'name': 'Baseball Cap', 'category': 'accessories', 'min_temp': 15, 'max_temp': 40, 'warmth_level': 0, 'formality_level': 3, 'style': 'sporty'},
    ]
    
    return clothing_items

def evaluate_recommendation_comprehensive(weather, user, item):
    """
    Comprehensive evaluation of whether an item is suitable
    Considers all parameters: weather, user profile, and item characteristics
    """
    score = 0
    max_score = 100
    
    temp = weather['temperature']
    feels_like = weather['feels_like']
    humidity = weather['humidity']
    wind_speed = weather['wind_speed']
    weather_condition = weather['weather_condition']
    
    # 1. Temperature suitability (30 points)
    if item['min_temp'] <= temp <= item['max_temp']:
        score += 30
    elif item['min_temp'] - 5 <= temp <= item['max_temp'] + 5:
        score += 15
    elif item['min_temp'] - 10 <= temp <= item['max_temp'] + 10:
        score += 5
    
    # 2. Feels-like temperature adjustment (10 points)
    if item['min_temp'] <= feels_like <= item['max_temp']:
        score += 10
    elif item['min_temp'] - 5 <= feels_like <= item['max_temp'] + 5:
        score += 5
    
    # 3. Temperature sensitivity matching (15 points)
    sensitivity = user['temperature_sensitivity']
    warmth = item['warmth_level']
    
    if sensitivity == 'very_cold' and warmth >= 8:
        score += 15
    elif sensitivity == 'cold' and warmth >= 6:
        score += 15
    elif sensitivity == 'normal' and 3 <= warmth <= 7:
        score += 15
    elif sensitivity == 'warm' and warmth <= 4:
        score += 15
    elif sensitivity == 'very_warm' and warmth <= 2:
        score += 15
    
    # 4. Style preference matching (10 points)
    if user['style_preference'] == item['style']:
        score += 10
    elif user['style_preference'] == 'casual':
        score += 5  # Casual is versatile
    
    # 5. Formality matching (10 points)
    user_formality = 1
    if user['formality_preference'] == 'formal':
        user_formality = 9
    elif user['formality_preference'] == 'semi_formal':
        user_formality = 6
    
    item_formality = item['formality_level']
    
    if abs(user_formality - item_formality) <= 2:
        score += 10
    elif abs(user_formality - item_formality) <= 4:
        score += 5
    
    # 6. Weather condition matching (10 points)
    if weather_condition == 'rain' and item['category'] in ['outerwear', 'accessories']:
        if 'rain' in item['name'].lower() or 'waterproof' in item['name'].lower():
            score += 10
        else:
            score += 5
    elif weather_condition == 'snow' and warmth >= 7:
        score += 10
    elif weather_condition == 'clear' or weather_condition == 'clouds':
        score += 7  # Most items are okay
    elif weather_condition == 'thunderstorm' and item['category'] == 'accessories':
        score += 5  # Some accessories might be useful
    
    # 7. Wind consideration (5 points)
    if wind_speed > 10 and item['category'] in ['outerwear', 'accessories']:
        # Windy conditions favor outerwear and accessories
        score += 5
    
    # 8. Humidity consideration (5 points)
    if humidity > 80 and 'breathable' in item['name'].lower():
        # High humidity favors breathable materials
        score += 5
    elif humidity < 40 and 'wool' in item['name'].lower():
        # Low humidity is good for wool
        score += 3
    
    # 9. Gender consideration (5 points)
    if user['gender'] == 'female' and 'dress' in item['name'].lower():
        score += 5
    elif user['gender'] == 'male' and 'shirt' in item['name'].lower():
        score += 3
    
    # Good recommendation if score >= 60
    return 1 if score >= 60 else 0

def generate_comprehensive_training_data(n_samples=20000):
    """Generate comprehensive training dataset with all parameters"""
    print("Generating comprehensive training data...")
    print(f"Parameters: Weather, User Profiles, Clothing Characteristics")
    print(f"Target samples: {n_samples}")
    
    # Generate components
    weather_data = generate_weather_conditions(n_samples // 10)  # Generate fewer unique weather conditions
    user_profiles = generate_user_profiles(300)  # Generate 300 diverse profiles
    clothing_items = generate_comprehensive_clothing_database()
    
    training_data = []
    
    print(f"Generating {n_samples} training samples...")
    
    for i in range(n_samples):
        # Randomly select weather, user, and item
        weather = random.choice(weather_data)
        user = random.choice(user_profiles)
        item = random.choice(clothing_items)
        
        # Evaluate if this is a good recommendation
        is_recommended = evaluate_recommendation_comprehensive(weather, user, item)
        
        # Create training sample with ALL parameters
        sample = {
            # Weather features
            'temperature': weather['temperature'],
            'feels_like': weather['feels_like'],
            'humidity': weather['humidity'],
            'wind_speed': weather['wind_speed'],
            'weather_condition': weather['weather_condition'],
            'season': weather['season'],
            
            # User features
            'gender': user['gender'],
            'age_range': user['age_range'],
            'style_preference': user['style_preference'],
            'temperature_sensitivity': user['temperature_sensitivity'],
            'formality_preference': user['formality_preference'],
            
            # Item features
            'item_name': item['name'],
            'category': item['category'],
            'min_temp': item['min_temp'],
            'max_temp': item['max_temp'],
            'warmth_level': item['warmth_level'],
            'formality_level': item['formality_level'],
            'item_style': item['style'],
            
            # Engineered features
            'temp_range': item['max_temp'] - item['min_temp'],
            'temp_suitability': 1 if item['min_temp'] <= weather['temperature'] <= item['max_temp'] else 0,
            'temp_distance': abs(weather['temperature'] - (item['min_temp'] + item['max_temp']) / 2),
            'feels_like_diff': weather['temperature'] - weather['feels_like'],
            
            # Target
            'is_recommended': is_recommended
        }
        
        training_data.append(sample)
        
        if (i + 1) % 2000 == 0:
            print(f"  Generated {i + 1}/{n_samples} samples...")
    
    # Convert to DataFrame
    df = pd.DataFrame(training_data)
    
    # Balance the dataset
    print("Balancing dataset...")
    positive = df[df['is_recommended'] == 1]
    negative = df[df['is_recommended'] == 0]
    
    n_samples_balanced = min(len(positive), len(negative))
    
    if n_samples_balanced > 0:
        balanced_df = pd.concat([
            positive.sample(n_samples_balanced, random_state=42),
            negative.sample(n_samples_balanced, random_state=42)
        ]).sample(frac=1, random_state=42).reset_index(drop=True)
    else:
        balanced_df = df  # Fallback if one class is missing
    
    print(f"\nDataset Statistics:")
    print(f"  Total samples: {len(balanced_df)}")
    print(f"  Positive samples: {sum(balanced_df['is_recommended'])} ({sum(balanced_df['is_recommended'])/len(balanced_df)*100:.1f}%)")
    print(f"  Negative samples: {len(balanced_df) - sum(balanced_df['is_recommended'])} ({(len(balanced_df) - sum(balanced_df['is_recommended']))/len(balanced_df)*100:.1f}%)")
    
    return balanced_df

def save_training_data(df, filename='comprehensive_training_data.csv'):
    """Save training data to CSV"""
    import os
    os.makedirs('data', exist_ok=True)
    filepath = f'data/{filename}'
    df.to_csv(filepath, index=False)
    print(f"\n✅ Training data saved to {filepath}")
    return filepath

def show_sample_data(df, n_samples=10):
    """Show sample of the generated data"""
    print(f"\n📊 Sample of generated data ({n_samples} rows):")
    print(df.head(n_samples).to_string(index=False))

if __name__ == '__main__':
    print("=" * 70)
    print("🤖 Generating COMPREHENSIVE Training Data for OutfitStyle")
    print("=" * 70)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("\nParameters considered:")
    print("  🌡️  Weather: Temperature, Feels-like, Humidity, Wind, Conditions")
    print("  👤 User: Gender, Age, Style Preference, Temp Sensitivity, Formality")
    print("  👕 Clothing: Name, Category, Temp Range, Warmth, Formality, Style")
    print("  🧮 Engineered: Temp Range, Suitability, Distance, Feels-like Diff")
    
    # Generate training data
    df = generate_comprehensive_training_data(n_samples=25000)
    
    # Show sample
    show_sample_data(df, 10)
    
    # Save to file
    filepath = save_training_data(df, 'comprehensive_training_data.csv')
    
    print(f"\n✅ Data generation complete!")
    print(f"   File: {filepath}")
    print(f"   Samples: {len(df)}")
    print(f"   Features: {len(df.columns) - 1}")  # -1 for target column
    print(f"\n💡 Next steps:")
    print(f"   1. Use this data to train your model:")
    print(f"      python scripts/train_with_synthetic_data.py")
    print(f"   2. Or manually:")
    print(f"      from model.advanced_trainer import AdvancedOutfitRecommender")
    print(f"      model = AdvancedOutfitRecommender()")
    print(f"      model.train(df)")