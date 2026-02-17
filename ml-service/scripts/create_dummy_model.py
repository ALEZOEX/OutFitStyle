#!/usr/bin/env python3
"""
Создаёт фиктивную CatBoost модель-заглушку для тестирования.
"""
import os
import pickle
import random
from catboost import CatBoostClassifier
import pandas as pd

random.seed(42)

# Создаём простую модель на основе фиктивных данных с вариативностью
weather_conditions = ['clear', 'clouds', 'rain', 'snow']
seasons = ['winter', 'spring', 'summer', 'autumn']
age_ranges = ['18-24', '25-35', '35-45', '45+']
styles = ['casual', 'sporty', 'classic', 'bohemian']
temp_sensitivities = ['cold', 'normal', 'warm']
formality_prefs = ['casual', 'business', 'smart-casual']
genders = ['male', 'female', 'unisex']
categories = ['outerwear', 'upper', 'lower', 'footwear', 'accessory']
subcategories = ['jacket', 'tshirt', 'shirt', 'jeans', 'sneakers', 'hat']
fits = ['slim', 'regular', 'loose']
patterns = ['solid', 'striped', 'checked', 'printed']

train_data = pd.DataFrame({
    'temperature': [random.uniform(-10, 35) for _ in range(200)],
    'feels_like': [random.uniform(-15, 40) for _ in range(200)],
    'humidity': [random.uniform(20, 100) for _ in range(200)],
    'wind_speed': [random.uniform(0, 20) for _ in range(200)],
    'weather_condition': [random.choice(weather_conditions) for _ in range(200)],
    'season': [random.choice(seasons) for _ in range(200)],
    'age_range': [random.choice(age_ranges) for _ in range(200)],
    'style_preference': [random.choice(styles) for _ in range(200)],
    'temperature_sensitivity': [random.choice(temp_sensitivities) for _ in range(200)],
    'formality_preference': [random.choice(formality_prefs) for _ in range(200)],
    'gender': [random.choice(genders) for _ in range(200)],
    'category': [random.choice(categories) for _ in range(200)],
    'subcategory': [random.choice(subcategories) for _ in range(200)],
    'style': [random.choice(styles) for _ in range(200)],
    'usage': ['daily'] * 200,
    'base_colour': ['black', 'white', 'blue', 'gray', 'beige'] * 40,
    'formality_level': [random.randint(1, 5) for _ in range(200)],
    'warmth_level': [random.randint(1, 5) for _ in range(200)],
    'min_temp': [random.uniform(-20, 20) for _ in range(200)],
    'max_temp': [random.uniform(15, 40) for _ in range(200)],
    'fit': [random.choice(fits) for _ in range(200)],
    'pattern': [random.choice(patterns) for _ in range(200)],
    'is_owned': [random.choice([True, False]) for _ in range(200)],
    'source_priority': [random.randint(1, 3) for _ in range(200)],
})

y = [random.randint(0, 1) for _ in range(200)]

cat_features = [
    'weather_condition', 'season', 'age_range', 'style_preference',
    'temperature_sensitivity', 'formality_preference', 'gender',
    'category', 'subcategory', 'style', 'usage', 'base_colour',
    'fit', 'pattern'
]

model = CatBoostClassifier(iterations=10, depth=4, verbose=False)
model.fit(train_data, y, cat_features=cat_features)

# Сохраняем manifest
manifest = {
    'format': 'catboost_cbm',
    'model_kind': 'classifier',
    'version': 'dummy-1.0.0',
    'cat_features': cat_features,
    'feature_columns': list(train_data.columns),
    'cbm_path': 'model.cbm'
}

output_dir = os.path.dirname(__file__)
models_dir = os.path.join(output_dir, '..', 'models')
os.makedirs(models_dir, exist_ok=True)

manifest_path = os.path.join(models_dir, 'model.pkl')
cbm_path = os.path.join(models_dir, 'model.cbm')

with open(manifest_path, 'wb') as f:
    pickle.dump(manifest, f)

model.save_model(cbm_path)

print(f"[OK] Dummy model created:")
print(f"   Manifest: {manifest_path}")
print(f"   Model: {cbm_path}")
print(f"   Version: {manifest['version']}")
print(f"   Features: {len(manifest['feature_columns'])} columns")
