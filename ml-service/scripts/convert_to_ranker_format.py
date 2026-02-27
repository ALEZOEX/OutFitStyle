#!/usr/bin/env python3
"""
Конвертация данных из формата Classifier в формат Ranker

Classifier данные:
  (weather, context, item) → label (0/1)

Ranker данные:
  (weather, context, item_A, item_B) → label (A лучше B)

Для обучения Ranker нужны парные предпочтения.
"""

import pandas as pd
import numpy as np
from typing import List, Tuple
import json
from pathlib import Path


def load_classifier_data(data_path: str) -> pd.DataFrame:
    """Загрузка данных из Classifier формата"""
    print(f"Загрузка данных из {data_path}...")
    df = pd.read_csv(data_path)
    print(f"Загружено {len(df)} примеров")
    return df


def create_pairs_from_classifier(
    df: pd.DataFrame,
    max_pairs_per_user: int = 10,
    random_state: int = 42
) -> pd.DataFrame:
    """
    Создание парных сравнений из Classifier данных
    
    Логика:
    - Группируем по weather_condition + temperature (округлённой)
    - В каждой группе создаём пары (positive, negative)
    - positive = item с label=1, negative = item с label=0
    """
    print("\nСоздание парных сравнений...")
    
    np.random.seed(random_state)
    
    # Округление температуры для группировки
    df['temp_rounded'] = (df['temperature'] / 5).round() * 5
    
    # Группировка по погоде
    groups = df.groupby(['weather_condition', 'temp_rounded'])
    
    pairs_data = []
    
    for (weather, temp), group in groups:
        positive_items = group[group['is_recommended'] == 1]
        negative_items = group[group['is_recommended'] == 0]
        
        if len(positive_items) == 0 or len(negative_items) == 0:
            continue
        
        # Создаём пары (positive, negative)
        n_pairs = min(
            len(positive_items) * len(negative_items),
            max_pairs_per_user
        )
        
        for _ in range(n_pairs):
            pos_item = positive_items.sample(1).iloc[0]
            neg_item = negative_items.sample(1).iloc[0]
            
            pair = {
                # Общие признаки (погода, контекст)
                'weather_condition': weather,
                'temperature': temp,
                'humidity': pos_item['humidity'],
                'activity': pos_item['activity'],
                'location': pos_item['location'],
                
                # Item A (лучший)
                'item_A_top': pos_item['top'],
                'item_A_bottom': pos_item['bottom'],
                'item_A_outerwear': pos_item['outerwear'],
                'item_A_footwear': pos_item['footwear'],
                'label_A_better': 1,  # A лучше B
                
                # Item B (худший)
                'item_B_top': neg_item['top'],
                'item_B_bottom': neg_item['bottom'],
                'item_B_outerwear': neg_item['outerwear'],
                'item_B_footwear': neg_item['footwear'],
            }
            
            pairs_data.append(pair)
    
    pairs_df = pd.DataFrame(pairs_data)
    print(f"Создано {len(pairs_df)} пар")
    return pairs_df


def create_ranking_dataset_from_real_choices(
    df: pd.DataFrame,
    n_samples: int = 500
) -> pd.DataFrame:
    """
    Создание данных для Ranker из реальных выборов
    
    Логика:
    - Берём реальные примеры (все label=1)
    - Создаём пары где оба варианта = реальный выбор
    - Сравниваем разные комбинации
    """
    print("\nСоздание данных из реальных выборов...")
    
    # Все примеры = положительные (реальный выбор)
    positive_only = df[df['is_recommended'] == 1].copy()
    
    # Группировка по погоде
    positive_only['temp_rounded'] = (positive_only['temperature'] / 5).round() * 5
    groups = positive_only.groupby(['weather_condition', 'temp_rounded'])
    
    pairs_data = []
    
    for (weather, temp), group in groups:
        if len(group) < 2:
            continue
        
        # Создаём пары из реальных выборов
        # Считаем что более популярный вариант = лучше
        item_counts = group.groupby(['top', 'bottom', 'outerwear', 'footwear']).size()
        item_counts = item_counts.sort_values(ascending=False)
        
        # Создаём пары (популярный, менее популярный)
        items = item_counts.index.tolist()
        n_pairs = min(len(items) * (len(items) - 1) // 2, n_samples)
        
        for i in range(min(n_pairs, len(items) - 1)):
            for j in range(i + 1, min(i + 5, len(items))):
                item_A = items[i]
                item_B = items[j]
                
                pair = {
                    'weather_condition': weather,
                    'temperature': temp,
                    'humidity': group['humidity'].median(),
                    'activity': group['activity'].mode()[0] if len(group['activity'].mode()) > 0 else 'unknown',
                    'location': group['location'].mode()[0] if len(group['location'].mode()) > 0 else 'unknown',
                    
                    'item_A_top': item_A[0],
                    'item_A_bottom': item_A[1],
                    'item_A_outerwear': item_A[2],
                    'item_A_footwear': item_A[3],
                    
                    'item_B_top': item_B[0],
                    'item_B_bottom': item_B[1],
                    'item_B_outerwear': item_B[2],
                    'item_B_footwear': item_B[3],
                    
                    'label_A_better': 1,  # A популярнее B
                }
                
                pairs_data.append(pair)
    
    pairs_df = pd.DataFrame(pairs_data)
    print(f"Создано {len(pairs_df)} пар из реальных выборов")
    return pairs_df


def save_ranker_dataset(
    pairs_df: pd.DataFrame,
    output_path: str
):
    """Сохранение датасета для Ranker"""
    print(f"\nСохранение в {output_path}...")
    
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    pairs_df.to_csv(output_path, index=False)
    
    print(f"Сохранено {len(pairs_df)} пар")
    print(f"\nСтатистика:")
    print(f"  Колонок: {len(pairs_df.columns)}")
    print(f"  Примеров: {len(pairs_df)}")
    
    # Пример
    print(f"\nПример пары:")
    print(pairs_df.iloc[0].to_dict())


def create_catboost_ranker_pool(
    pairs_df: pd.DataFrame,
    output_dir: str,
    label_encoders: dict = None
):
    """
    Создание файла в формате CatBoost Ranker pool
    
    Формат:
      target\tqueryid\titem_id\tfeat1\tfeat2\t...
      
    где:
      target: 0 или 1 (какой вариант лучше)
      queryid: ID группы (погода + контекст)
      item_id: ID варианта (A или B)
    """
    print(f"\nСоздание CatBoost Ranker pool...")
    
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Для каждой пары создаём 2 строки (A и B)
    pool_data = []
    
    for idx, row in pairs_df.iterrows():
        query_id = f"q{idx}"
        
        # Строка для A
        feat_A = [
            row['weather_condition'],
            str(row['temperature']),
            str(row['humidity']),
            row['activity'],
            row['location'],
            row['item_A_top'],
            row['item_A_bottom'],
            row['item_A_outerwear'],
            row['item_A_footwear']
        ]
        pool_data.append(f"1\t{query_id}\tA\t{' '.join(feat_A)}")
        
        # Строка для B
        feat_B = [
            row['weather_condition'],
            str(row['temperature']),
            str(row['humidity']),
            row['activity'],
            row['location'],
            row['item_B_top'],
            row['item_B_bottom'],
            row['item_B_outerwear'],
            row['item_B_footwear']
        ]
        pool_data.append(f"0\t{query_id}\tB\t{' '.join(feat_B)}")
    
    # Сохранение
    pool_file = output_path / "ranker_train.pool"
    with open(pool_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(pool_data))
    
    print(f"Создан pool файл: {pool_file}")
    print(f"  Строк: {len(pool_data)}")
    
    # Feature names
    feature_names = [
        'weather_condition', 'temperature', 'humidity',
        'activity', 'location',
        'top', 'bottom', 'outerwear', 'footwear'
    ]
    
    with open(output_path / "feature_names.txt", 'w') as f:
        f.write('\n'.join(feature_names))
    
    print(f"  Feature names: {len(feature_names)}")


def main():
    """Основной пайплайн"""
    print("="*60)
    print("Classifier → Ranker Data Conversion")
    print("="*60)
    
    # Пути
    classifier_data_path = "data/processed/hm_weather_dataset.csv"
    real_data_path = "data/raw/season fashion dataset - multilabel.csv"
    output_dir = "data/ranker"
    
    # Проверка существования файлов
    if not Path(real_data_path).exists():
        print(f"Файл {real_data_path} не найден!")
        print("Используем синтетические данные для демонстрации...")
        return
    
    # 1. Загрузка реальных данных
    df = load_classifier_data(real_data_path)
    
    # 2. Добавление label (все примеры = положительные)
    df['is_recommended'] = 1
    
    # 3. Создание пар для Ranker
    pairs_df = create_ranking_dataset_from_real_choices(df, n_samples=500)
    
    # 4. Сохранение
    save_ranker_dataset(pairs_df, output_dir / "ranker_pairs.csv")
    
    # 5. Создание CatBoost pool
    create_catboost_ranker_pool(pairs_df, output_dir)
    
    print("\n" + "="*60)
    print("Конвертация завершена!")
    print("="*60)
    print("\nСледующие шаги:")
    print("  1. Проверить данные в data/ranker/")
    print("  2. Обучить CatBoost Ranker:")
    print("     python scripts/train_ranker_model.py")
    print("  3. Интегрировать в ML сервис")


if __name__ == "__main__":
    main()
