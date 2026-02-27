#!/usr/bin/env python3
"""
Обучение модели на реальном датасете "Season Fashion Dataset"

Датасет содержит:
- Погодные условия (температура, влажность, погода)
- Контекст (локация, активность, длительность)
- Выбор одежды (верх, низ, обувь, верхняя одежда)

Задача: предсказать подходит ли одежда для данных условий
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, accuracy_score, roc_auc_score
from catboost import CatBoostClassifier
import pickle
import json
import os
from pathlib import Path
from datetime import datetime


def load_and_prepare_data(data_path: str) -> pd.DataFrame:
    """
    Загрузка и подготовка данных
    
    Датасет: season fashion dataset - multilabel.csv
    Язык: индонезийский
    """
    print(f"Загрузка датасета из {data_path}...")
    df = pd.read_csv(data_path)
    print(f"Загружено {len(df)} записей")
    
    # Переименование колонок на английский
    rename_map = {
        'Jenis Kelamin': 'gender',
        'Kondisi Cuaca': 'weather_condition',
        'Suhu': 'temperature',
        'Kelembapan': 'humidity',
        'Lokasi': 'location',
        'Aktivitas': 'activity',
        'Durasi': 'duration',
        'Atasan': 'top',
        'Bawahan': 'bottom',
        'Pakaian Luar': 'outerwear',
        'Alas Kaki': 'footwear'
    }
    
    df.rename(columns=rename_map, inplace=True)
    
    # Статистика
    print("\nСтатистика:")
    print(f"  Температуры: {df['temperature'].min()}°C ... {df['temperature'].max()}°C")
    print(f"  Влажность: {df['humidity'].min()}% ... {df['humidity'].max()}%")
    print(f"  Погода: {df['weather_condition'].unique()}")
    print(f"  Одежда (top): {df['top'].nunique()} уникальных")
    print(f"  Одежда (bottom): {df['bottom'].nunique()} уникальных")
    
    return df


def encode_categorical_features(df: pd.DataFrame) -> tuple:
    """
    Кодирование категориальных признаков
    
    Returns:
        X_encoded, y, label_encoders, feature_columns
    """
    print("\nКодирование категориальных признаков...")
    
    # Создаём копию
    df_encoded = df.copy()
    
    # Список категориальных колонок
    categorical_cols = [
        'gender', 'weather_condition', 'location', 'activity',
        'top', 'bottom', 'outerwear', 'footwear'
    ]
    
    # Label encoding для каждой колонки
    label_encoders = {}
    for col in categorical_cols:
        le = LabelEncoder()
        df_encoded[col] = le.fit_transform(df_encoded[col].astype(str))
        label_encoders[col] = le
        print(f"  {col}: {len(le.classes_)} категорий")
    
    # Числовые колонки
    numerical_cols = ['temperature', 'humidity', 'duration']
    
    # Фичи для модели
    feature_columns = categorical_cols + numerical_cols
    X = df_encoded[feature_columns]
    
    # Целевая переменная: 1 = подходит (все записи в датасете = реальный выбор)
    # Для бинарной классификации считаем что все записи = positive примеры
    y = np.ones(len(df))
    
    # Индексы категориальных фичей для CatBoost
    categorical_indices = [i for i, col in enumerate(feature_columns) if col in categorical_cols]
    
    print(f"\nИтого фичей: {len(feature_columns)}")
    print(f"Категориальных: {len(categorical_cols)}")
    print(f"Числовых: {len(numerical_cols)}")
    
    return X, y, label_encoders, feature_columns, categorical_indices


def generate_negative_samples(
    df: pd.DataFrame, 
    X: pd.DataFrame, 
    y: np.ndarray,
    n_negatives: int = 1000,
    random_state: int = 42
) -> tuple:
    """
    Генерация negative samples (неподходящая одежда)
    
    Перемешиваем одежду с погодой чтобы создать "плохие" примеры
    """
    print(f"\nГенерация {n_negatives} negative samples...")
    
    np.random.seed(random_state)
    
    # Создаём negative примеры перемешиванием
    negative_indices = np.random.permutation(len(df))[:n_negatives]
    
    X_negative = X.iloc[negative_indices].copy()
    
    # "Портим" данные: перемешиваем одежду относительно погоды
    shuffle_indices = np.random.permutation(len(negative_indices))
    for col in ['top', 'bottom', 'outerwear', 'footwear']:
        col_idx = list(X.columns).index(col)
        X_negative.iloc[:, col_idx] = X.iloc[negative_indices[shuffle_indices]][col].values
    
    y_negative = np.zeros(n_negatives)
    
    # Объединяем
    X_balanced = pd.concat([X, X_negative], ignore_index=True)
    y_balanced = np.concatenate([y, y_negative])
    
    print(f"  Positive: {sum(y_balanced == 1)}")
    print(f"  Negative: {sum(y_balanced == 0)}")
    print(f"  Баланс: {sum(y_balanced == 1) / sum(y_balanced == 0):.2f}")
    
    return X_balanced, y_balanced


def train_model(
    X_train: pd.DataFrame, 
    y_train: np.ndarray,
    X_test: pd.DataFrame, 
    y_test: np.ndarray,
    categorical_indices: list
) -> dict:
    """
    Обучение CatBoost модели
    """
    print("\n" + "="*60)
    print("Обучение CatBoost модели...")
    print("="*60)
    
    model = CatBoostClassifier(
        iterations=1000,
        learning_rate=0.05,
        depth=6,
        loss_function='Logloss',
        cat_features=categorical_indices,
        verbose=100,
        random_seed=42,
        early_stopping_rounds=50,
        eval_metric='AUC'
    )
    
    model.fit(
        X_train, y_train,
        eval_set=(X_test, y_test),
        use_best_model=True
    )
    
    # Предсказания
    y_pred = model.predict(X_test)
    y_pred_proba = model.predict_proba(X_test)[:, 1]
    
    # Метрики
    print("\n" + "="*60)
    print("Метрики на тесте:")
    print("="*60)
    print(f"  Accuracy: {accuracy_score(y_test, y_pred):.4f}")
    print(f"  AUC-ROC: {roc_auc_score(y_test, y_pred_proba):.4f}")
    print(f"\nClassification report:\n{classification_report(y_test, y_pred)}")
    
    # Feature importance
    feature_importance = model.get_feature_importance()
    print("\nTop-10 фичей по важности:")
    for i, (name, importance) in enumerate(sorted(
        zip(X_train.columns, feature_importance),
        key=lambda x: x[1],
        reverse=True
    )[:10]):
        print(f"  {i+1}. {name}: {importance:.2f}%")
    
    return {
        'model': model,
        'accuracy': accuracy_score(y_test, y_pred),
        'auc_roc': roc_auc_score(y_test, y_pred_proba),
        'feature_importance': feature_importance,
        'classification_report': classification_report(y_test, y_pred, output_dict=True)
    }


def save_model_and_metadata(
    model: CatBoostClassifier,
    label_encoders: dict,
    feature_columns: list,
    metrics: dict,
    output_dir: str
):
    """Сохранение модели и метаданных"""
    print(f"\nСохранение модели в {output_dir}...")
    
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Модель
    model_path = output_path / "fashion_model.cbm"
    model.save_model(model_path)
    print(f"  Модель: {model_path}")
    
    # Label encoders
    encoders_path = output_path / "label_encoders.pkl"
    with open(encoders_path, 'wb') as f:
        pickle.dump(label_encoders, f)
    print(f"  Encoders: {encoders_path}")
    
    # Метаданные
    metadata = {
        'format': 'catboost_cbm',
        'model_kind': 'fashion_classifier',
        'model_path': str(model_path.name),
        'version': datetime.now().strftime('%Y%m%d_%H%M%S'),
        'feature_columns': feature_columns,
        'label_encoders': {k: list(v.classes_) for k, v in label_encoders.items()},
        'metrics': {
            'accuracy': float(metrics['accuracy']),
            'auc_roc': float(metrics['auc_roc']),
            'precision': float(metrics['classification_report']['weighted avg']['precision']),
            'recall': float(metrics['classification_report']['weighted avg']['recall']),
            'f1_score': float(metrics['classification_report']['weighted avg']['f1-score'])
        },
        'dataset': {
            'name': 'Season Fashion Dataset (multilabel)',
            'source': 'Kaggle',
            'language': 'Indonesian',
            'samples': 1001,
            'negative_samples_generated': 1000
        },
        'created_at': datetime.now().isoformat()
    }
    
    metadata_path = output_path / "metadata.json"
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    print(f"  Metadata: {metadata_path}")
    
    print("\n" + "="*60)
    print("Метрики модели:")
    print("="*60)
    for key, value in metadata['metrics'].items():
        print(f"  {key}: {value:.4f}")
    
    return metadata


def main():
    """Основной пайплайн"""
    print("="*60)
    print("OutFitStyle ML Model Training")
    print("Dataset: Season Fashion (Real Data)")
    print("="*60)
    
    # Пути
    data_path = "data/raw/season fashion dataset - multilabel.csv"
    output_dir = "models"
    
    # 1. Загрузка данных
    df = load_and_prepare_data(data_path)
    
    # 2. Кодирование признаков
    X, y, label_encoders, feature_columns, categorical_indices = encode_categorical_features(df)
    
    # 3. Генерация negative samples
    X_balanced, y_balanced = generate_negative_samples(df, X, y, n_negatives=1000)
    
    # 4. Разделение на train/test
    X_train, X_test, y_train, y_test = train_test_split(
        X_balanced, y_balanced,
        test_size=0.2,
        random_state=42,
        stratify=y_balanced
    )
    
    print(f"\nTrain: {len(X_train)} samples")
    print(f"Test: {len(X_test)} samples")
    
    # 5. Обучение модели
    metrics = train_model(
        X_train, y_train,
        X_test, y_test,
        categorical_indices
    )
    
    # 6. Сохранение
    save_model_and_metadata(
        metrics['model'],
        label_encoders,
        feature_columns,
        metrics,
        output_dir
    )
    
    print("\n" + "="*60)
    print("Обучение завершено!")
    print("="*60)


if __name__ == "__main__":
    main()
