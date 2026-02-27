#!/usr/bin/env python3
"""
Получение реальных scores от модели для примера на плакате

Контекст: +3°C, дождь, outdoor, прогулка
"""

import pandas as pd
import pickle
from catboost import CatBoostClassifier


def load_model_and_encoders():
    """Загрузка модели и энкодеров"""
    with open('models/model.pkl', 'rb') as f:
        manifest = pickle.load(f)
    
    model = CatBoostClassifier()
    model.load_model('models/model.cbm')
    
    with open('models/label_encoders.pkl', 'rb') as f:
        label_encoders = pickle.load(f)
    
    return model, label_encoders, manifest['feature_columns']


def encode_sample(label_encoders, sample_dict):
    """Кодирование примера"""
    encoded = {}
    for col, value in sample_dict.items():
        if col in label_encoders:
            le = label_encoders[col]
            # Проверка есть ли значение в classes
            if value in le.classes_:
                encoded[col] = le.transform([value])[0]
            else:
                # Если значения нет, берём первое (для демо)
                print(f"  Warning: '{value}' нет в {col}, используем '{le.classes_[0]}'")
                encoded[col] = 0
        else:
            encoded[col] = value
    return encoded


def main():
    print("="*60)
    print("Получение реальных scores для примера")
    print("="*60)
    
    # Загрузка
    model, label_encoders, feature_columns = load_model_and_encoders()
    
    print(f"\nФичи: {feature_columns}")
    print(f"\nLabel encoders:")
    for col, le in label_encoders.items():
        print(f"  {col}: {list(le.classes_)}")
    
    # Примеры комбинаций для контекста: +12°C, дождь, outdoor, прогулка
    samples = [
        {
            'gender': 'Perempuan',
            'weather_condition': 'Hujan',
            'temperature': 12,
            'humidity': 85,
            'location': 'Outdoor',
            'activity': 'Santai',
            'duration': 2,
            'top': 'Kemeja',
            'bottom': 'Celana Panjang',
            'outerwear': 'Jaket',
            'footwear': 'Sepatu Bot'
        },
        {
            'gender': 'Perempuan',
            'weather_condition': 'Hujan',
            'temperature': 12,
            'humidity': 85,
            'location': 'Outdoor',
            'activity': 'Santai',
            'duration': 2,
            'top': 'Kaos',
            'bottom': 'Celana Panjang',
            'outerwear': 'Jaket',
            'footwear': 'Sneakers'
        },
        {
            'gender': 'Perempuan',
            'weather_condition': 'Hujan',
            'temperature': 12,
            'humidity': 85,
            'location': 'Outdoor',
            'activity': 'Santai',
            'duration': 2,
            'top': 'Jas',
            'bottom': 'Celana Panjang',
            'outerwear': 'Hoodie',
            'footwear': 'Sneakers'
        },
        {
            'gender': 'Perempuan',
            'weather_condition': 'Hujan',
            'temperature': 12,
            'humidity': 85,
            'location': 'Outdoor',
            'activity': 'Santai',
            'duration': 2,
            'top': 'Blouse',
            'bottom': 'Celana Panjang',
            'outerwear': 'Hoodie',
            'footwear': 'Sepatu Bot'
        },
        {
            'gender': 'Perempuan',
            'weather_condition': 'Hujan',
            'temperature': 12,
            'humidity': 85,
            'location': 'Outdoor',
            'activity': 'Santai',
            'duration': 2,
            'top': 'Kaos',
            'bottom': 'Celana Pendek',
            'outerwear': 'Tanpa Pakaian Luar',
            'footwear': 'Sandal'
        }
    ]
    
    print("\n" + "="*60)
    print("Предсказания:")
    print("="*60)
    
    results = []
    for i, sample in enumerate(samples, 1):
        encoded = encode_sample(label_encoders, sample)
        
        # Создание DataFrame с правильным порядком колонок
        df = pd.DataFrame([encoded])[feature_columns]
        
        # Предсказание
        proba = model.predict_proba(df)[0][1]
        
        result = {
            'rank': i,
            'top': sample['top'],
            'bottom': sample['bottom'],
            'outerwear': sample['outerwear'],
            'footwear': sample['footwear'],
            'score': proba
        }
        results.append(result)
        
        print(f"\n{i}. {sample['top']} + {sample['bottom']} + {sample['outerwear']} + {sample['footwear']}")
        print(f"   Score: {proba:.4f}")
    
    # Сортировка по score
    results_sorted = sorted(results, key=lambda x: x['score'], reverse=True)
    
    print("\n" + "="*60)
    print("Топ комбинаций (для плаката):")
    print("="*60)
    print("┌─────────────────────────────────────────────────┐")
    print("│ #  Верх      Низ         Верхн.  Обувь    Score │")
    print("├─────────────────────────────────────────────────┤")
    for r in results_sorted:
        # Сокращения для красивого вывода
        top_short = r['top'][:8] if len(r['top']) > 8 else r['top']
        bottom_short = r['bottom'][:8] if len(r['bottom']) > 8 else r['bottom']
        outer_short = r['outerwear'][:6] if len(r['outerwear']) > 6 else r['outerwear']
        foot_short = r['footwear'][:6] if len(r['footwear']) > 6 else r['footwear']
        
        print(f"│ {r['rank']}  {top_short:<8} {bottom_short:<10} {outer_short:<6} {foot_short:<6} {r['score']:.2f}  │")
    print("└─────────────────────────────────────────────────┘")
    
    # Сохранение для плаката
    print("\n" + "="*60)
    print("Для вставки в POSTER_LOCAL.md:")
    print("="*60)
    print("```")
    print("Модель оценивает комбинации:")
    print("┌─────────────────────────────────────────────────┐")
    print("│ #  Верх      Низ         Верхн.  Обувь    Score │")
    print("├─────────────────────────────────────────────────┤")
    for r in results_sorted:
        top_short = r['top'][:8] if len(r['top']) > 8 else r['top']
        bottom_short = r['bottom'][:8] if len(r['bottom']) > 8 else r['bottom']
        outer_short = r['outerwear'][:6] if len(r['outerwear']) > 6 else r['outerwear']
        foot_short = r['footwear'][:6] if len(r['footwear']) > 6 else r['footwear']
        
        print(f"│ {r['rank']}  {top_short:<8} {bottom_short:<10} {outer_short:<6} {foot_short:<6} {r['score']:.2f}  │")
    print("└─────────────────────────────────────────────────┘")
    print("```")


if __name__ == "__main__":
    main()
