#!/usr/bin/env python3
"""
Конвертирует индонезийский датасет одежды в формат для обучения CatBoost
"""
import pandas as pd
import numpy as np

# Загружаем оригинальный датасет
df = pd.read_csv('data/raw/season fashion dataset - multilabel.csv')

print(f"Загружено {len(df)} записей")
print(f"Колонки: {df.columns.tolist()}")
print(f"\nПример данных:")
print(df.head())

# Создаём целевую переменную (is_recommended) на основе фактических выборов
# Каждая запись в датасете - это реальный выбор человека, значит is_recommended = 1
df['is_recommended'] = 1

# Конвертируем индонезийские категории в английские
weather_map = {
    'Cerah': 'clear',
    'Mendung': 'clouds',
    'Hujan': 'rain',
    'Gerimis': 'drizzle',
    'Berawan': 'clouds'
}

gender_map = {
    'Perempuan': 'female',
    'Laki-laki': 'male'
}

location_map = {
    'Indoor': 'indoor',
    'Outdoor': 'outdoor'
}

activity_map = {
    'Santai': 'casual',
    'Bekerja': 'work',
    'Berjalan': 'walking',
    'Olahraga': 'sport',
    'Kondangan': 'formal'
}

# Применяем маппинг
df['weather_condition'] = df['Kondisi Cuaca'].map(weather_map)
df['gender'] = df['Jenis Kelamin'].map(gender_map)
df['location'] = df['Lokasi'].map(location_map)
df['activity'] = df['Aktivitas'].map(activity_map)

# Создаём признаки для ML модели
training_data = []

for idx, row in df.iterrows():
    # Температурные диапазоны для одежды
    temp = float(row['Suhu'])
    
    # Определяем подходящую одежду на основе температуры
    if temp < 15:
        warmth_needed = 'high'
    elif temp < 25:
        warmth_needed = 'medium'
    else:
        warmth_needed = 'low'
    
    # Создаём записи для каждой категории одежды
    categories = ['Atasan', 'Bawahan', 'Pakaian Luar', 'Alas Kaki']
    
    for cat in categories:
        item = row.get(cat, '')
        if pd.isna(item) or item == '':
            continue
            
        # Определяем характеристики одежды
        warmth_level = 5
        formality_level = 3
        
        if 'Jas' in item or 'Suit' in item:
            formality_level = 9
        elif 'Kemeja' in item or 'Blouse' in item:
            formality_level = 6
        elif 'Kaos' in item or 'T-Shirt' in item:
            formality_level = 3
            
        if 'Jaket' in item or 'Hoodie' in item or 'Bot' in item:
            warmth_level = 7
        elif 'Sweater' in item or 'Cardigan' in item:
            warmth_level = 5
        else:
            warmth_level = 2
        
        sample = {
            'temperature': temp,
            'feels_like': temp - 2,
            'humidity': float(row['Kelembapan']),
            'wind_speed': 5.0,
            'weather_condition': row['weather_condition'],
            'season': 'summer' if temp > 25 else ('winter' if temp < 15 else 'spring'),
            'age_range': '25-35',
            'style_preference': row['activity'],
            'temperature_sensitivity': 'normal',
            'formality_preference': row['activity'],
            'item_name': item,
            'category': cat.lower(),
            'subcategory': item.lower(),
            'style': 'casual',
            'usage': 'daily',
            'base_colour': 'black',
            'formality_level': formality_level,
            'warmth_level': warmth_level,
            'min_temp': temp - 10,
            'max_temp': temp + 10,
            'fit': 'regular',
            'pattern': 'solid',
            'is_owned': True,
            'source_priority': 1,
            'is_recommended': 1
        }
        
        training_data.append(sample)

# Создаём DataFrame
training_df = pd.DataFrame(training_data)

print(f"\nСоздано {len(training_df)} записей для обучения")
print(f"Категории: {training_df['category'].unique()}")

# Сохраняем
training_df.to_csv('data/raw/training_data_converted.csv', index=False)
print("\nСохранено в data/raw/training_data_converted.csv")

# Теперь создадим негативные примеры (неподходящая одежда)
negative_samples = []

for idx, row in training_df.iterrows():
    # Создаём негативный пример с неправильной одеждой
    neg_row = row.copy()

    # Инвертируем warmth_level для создания неподходящей одежды
    if row['warmth_level'] >= 7:
        neg_row['warmth_level'] = 2
    else:
        neg_row['warmth_level'] = 8

    neg_row['is_recommended'] = 0
    negative_samples.append(neg_row)

# Объединяем позитивные и негативные примеры
full_df = pd.concat([training_df, pd.DataFrame(negative_samples)])
full_df = full_df.sample(frac=1, random_state=42).reset_index(drop=True)

# Конвертируем все категориальные колонки в строки
cat_cols = ['weather_condition', 'season', 'age_range', 'style_preference',
            'temperature_sensitivity', 'formality_preference', 'category',
            'subcategory', 'style', 'usage', 'base_colour', 'fit', 'pattern']

for col in cat_cols:
    if col in full_df.columns:
        full_df[col] = full_df[col].astype(str)

full_df.to_csv('data/training_data_balanced.csv', index=False)
print(f"Сохранено сбалансированный датасет: {len(full_df)} записей")
print(f"Позитивные: {sum(full_df['is_recommended'] == 1)}")
print(f"Негативные: {sum(full_df['is_recommended'] == 0)}")
