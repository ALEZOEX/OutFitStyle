"""
Скрипт для тренировки ML-модели ранжирования с сохранением артефактов.
"""
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, classification_report
import pickle
import json
import os
from datetime import datetime
from typing import Dict, Any, Tuple
import argparse


def load_and_prepare_real_data(data_path: str = 'data/raw/styles.csv') -> pd.DataFrame:
    """
    Загрузка и подготовка реальных данных из styles.csv для обучения модели.
    Создает DataFrame с теми же признаками, что и в synthetic_data, но на основе реальных данных.
    """
    # Загрузка данных
    df = pd.read_csv(data_path, on_bad_lines='skip')

    # Проверим, какие колонки доступны
    print(f"Доступные колонки в датасете: {list(df.columns)}")

    # Теперь создадим правильную структуру признаков, эквивалентную synthetic_data
    df_final = pd.DataFrame()

    # Основные категориальные признаки
    if 'masterCategory' in df.columns:
        df_final['category'] = df['masterCategory']
    else:
        df_final['category'] = 'unknown'

    if 'subCategory' in df.columns:
        df_final['subcategory'] = df['subCategory']
    else:
        df_final['subcategory'] = 'unknown'

    # Определяем формальность на основе 'usage' или 'masterCategory'
    if 'usage' in df.columns:
        formal_usages = ['formal', 'work', 'business', 'job interview']
        df_final['formality_level'] = df['usage'].apply(
            lambda x: 5 if any(f in str(x).lower() for f in formal_usages) else
                      1 if 'casual' in str(x).lower() else 3
        )
    else:
        df_final['formality_level'] = 3  # по умолчанию

    # Определяем теплоту на основе 'season'
    if 'season' in df.columns:
        warmth_map = {'Winter': 9, 'Fall': 7, 'Spring': 4, 'Summer': 2}
        df_final['warmth_level'] = df['season'].map(warmth_map).fillna(5)
    else:
        df_final['warmth_level'] = 5  # по умолчанию

    # Температурное соответствие (произвольное значение, так как у нас нет погодной информации)
    df_final['temperature_match'] = np.random.uniform(-5, 5, len(df))  # случайные значения

    # Приоритет источника (предположим, что все вещи из одного источника)
    df_final['source_priority'] = np.random.randint(1, 3, len(df))  # случайные значения 1-2

    # Принадлежность пользователю (пока все не принадлежат)
    df_final['is_owned'] = 0

    # Количество материалов (произвольное значение)
    df_final['material_count'] = np.random.randint(1, 4, len(df))

    # Совпадение сезона (предположим, что большинство вещей соответствуют сезону)
    df_final['season_match'] = 1

    # Совпадение стиля (произвольное значение)
    df_final['style_match'] = np.random.uniform(0.4, 0.9, len(df))

    # Создаем целевую переменную
    if 'rating' in df.columns and 'ratingCount' in df.columns:
        # Вещь считается подходящей, если рейтинг высокий и много голосов
        df_final['target'] = ((df['rating'] > 3.5) & (df['ratingCount'] > 10)).astype(int)
    else:
        # В противном случае - случайный таргет
        df_final['target'] = np.random.choice([0, 1], size=len(df), p=[0.3, 0.7])

    # Проверим, есть ли пропущенные значения
    df_final = df_final.dropna()

    return df_final


def prepare_features(df: pd.DataFrame) -> Tuple[pd.DataFrame, np.ndarray]:
    """
    Подготовка признаков для модели.
    """
    # One-hot кодирование категориальных признаков
    df_encoded = pd.get_dummies(df, columns=['category', 'subcategory'], prefix=['cat', 'sub'])
    
    # Выделение признаков и целевой переменной
    feature_columns = [col for col in df_encoded.columns if col != 'target']
    X = df_encoded[feature_columns]
    y = df_encoded['target'].values
    
    return X, y


def train_ranking_model(X: pd.DataFrame, y: np.ndarray) -> Dict[str, Any]:
    """
    Тренировка модели ранжирования.
    """
    # Разделение данных
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Нормализация признаков
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Обучение модели (Gradient Boosting как в оригинальном проекте)
    model = GradientBoostingClassifier(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    
    model.fit(X_train_scaled, y_train)
    
    # Предсказания для оценки
    y_pred = model.predict(X_test_scaled)
    
    # Метрики
    accuracy = accuracy_score(y_test, y_pred)
    report = classification_report(y_test, y_pred, output_dict=True)
    
    print(f"Точность модели: {accuracy:.3f}")
    print(f"Отчет по классификации: {json.dumps(report, indent=2)}")
    
    return {
        'model': model,
        'scaler': scaler,
        'feature_columns': X.columns.tolist(),
        'accuracy': accuracy,
        'classification_report': report
    }


def save_artifacts(model_artifacts: Dict[str, Any], output_dir: str):
    """
    Сохранение артефактов модели.
    """
    os.makedirs(output_dir, exist_ok=True)
    
    # Версия модели (на основе времени)
    version = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Сохранение модели
    model_path = os.path.join(output_dir, f"model_v{version}.pkl")
    with open(model_path, 'wb') as f:
        pickle.dump({
            'model': model_artifacts['model'],
            'scaler': model_artifacts['scaler'],
            'feature_columns': model_artifacts['feature_columns'],
            'version': version,
            'created_at': datetime.now().isoformat()
        }, f)
    
    # Сохранение метаданных
    metadata = {
        'version': version,
        'created_at': datetime.now().isoformat(),
        'accuracy': model_artifacts['accuracy'],
        'classification_report': model_artifacts['classification_report'],
        'feature_columns': model_artifacts['feature_columns'],
        'model_type': 'GradientBoostingClassifier'
    }
    
    metadata_path = os.path.join(output_dir, 'metadata.json')
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)
    
    print(f"Артефакты сохранены в {output_dir}")
    print(f"Модель: {model_path}")
    print(f"Метаданные: {metadata_path}")
    
    return model_path, metadata_path


def main():
    parser = argparse.ArgumentParser(description='Train ML ranking model with artifact saving')
    parser.add_argument('--data-path', default='data/raw/styles.csv', help='Path to training data CSV file')
    parser.add_argument('--output-dir', default='artifacts', help='Directory to save model artifacts')

    args = parser.parse_args()

    print(f"Загрузка реальных данных из {args.data_path}...")
    df = load_and_prepare_real_data(args.data_path)

    print(f"Загружено {len(df)} записей из реального датасета")
    print("Подготовка признаков...")
    X, y = prepare_features(df)

    print("Тренировка модели...")
    artifacts = train_ranking_model(X, y)

    print("Сохранение артефактов...")
    save_artifacts(artifacts, args.output_dir)

    print("✅ Обучение модели завершено!")


if __name__ == "__main__":
    main()