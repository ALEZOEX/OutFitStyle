"""
Скрипт для тренировки ML-модели ранжирования с сохранением артефактов.
Теперь использует CatBoost для лучшей обработки категориальных признаков.
"""
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import accuracy_score, classification_report
from catboost import CatBoostClassifier
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


def prepare_features(df: pd.DataFrame) -> Tuple[pd.DataFrame, np.ndarray, list]:
    """
    Подготовка признаков для модели.

    Returns:
        X: DataFrame с признаками
        y: массив целевых значений
        categorical_features_indices: индексы категориальных признаков
    """
    # Определяем категориальные колонки
    categorical_columns = ['category', 'subcategory']
    # Проверяем, какие из этих колонок существуют в датасете
    existing_categorical = [col for col in categorical_columns if col in df.columns]

    # Выделение признаков и целевой переменной
    feature_columns = [col for col in df.columns if col != 'target']
    X = df[feature_columns].copy()
    y = df['target'].values

    # Получаем индексы категориальных признаков
    categorical_features_indices = [i for i, col in enumerate(feature_columns) if col in existing_categorical]

    return X, y, categorical_features_indices


def train_ranking_model(X: pd.DataFrame, y: np.ndarray, categorical_features_indices: list) -> Dict[str, Any]:
    """
    Тренировка модели ранжирования с использованием CatBoost.

    Args:
        X: DataFrame с признаками
        y: массив целевых значений
        categorical_features_indices: индексы категориальных признаков
    """
    # Разделение данных
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Для CatBoost не нужна нормализация признаков
    # Обучение модели CatBoost
    model = CatBoostClassifier(
        iterations=100,
        learning_rate=0.1,
        depth=5,
        loss_function='Logloss',  # для бинарной классификации
        eval_metric='Accuracy',
        cat_features=categorical_features_indices,  # указываем индексы категориальных признаков
        random_seed=42,
        verbose=100  # выводить информацию о процессе обучения каждые 100 итераций
    )

    # Обучаем модель
    model.fit(
        X_train,
        y_train,
        eval_set=(X_test, y_test),
        early_stopping_rounds=10
    )

    # Предсказания для оценки
    y_pred = model.predict(X_test)

    # Метрики
    accuracy = accuracy_score(y_test, y_pred)
    report = classification_report(y_test, y_pred, output_dict=True)

    print(f"Точность модели: {accuracy:.3f}")
    print(f"Отчет по классификации: {json.dumps(report, indent=2)}")

    return {
        'model': model,
        'feature_columns': X.columns.tolist(),
        'categorical_features_indices': categorical_features_indices,
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

    # Путь для сохранения модели CatBoost
    cbm_model_path = os.path.join(output_dir, f"model_v{version}.cbm")

    # Сохраняем модель CatBoost в формате .cbm
    model_artifacts['model'].save_model(cbm_model_path)

    # Сохраняем метаданные в pickle файле
    pickle_metadata_path = os.path.join(output_dir, f"model_v{version}_metadata.pkl")
    with open(pickle_metadata_path, 'wb') as f:
        pickle.dump({
            'format': 'catboost_cbm',  # указываем формат
            'version': version,
            'created_at': datetime.now().isoformat(),
            'feature_columns': model_artifacts['feature_columns'],
            'categorical_features': model_artifacts.get('categorical_features_indices', []),
            'cbm_path': os.path.basename(cbm_model_path),  # сохраняем относительный путь к .cbm файлу
            'model_type': 'CatBoostClassifier',
            'accuracy': model_artifacts['accuracy'],
            'classification_report': model_artifacts['classification_report']
        }, f)

    # Также сохраняем метаданные в JSON для удобства просмотра
    metadata = {
        'version': version,
        'created_at': datetime.now().isoformat(),
        'accuracy': model_artifacts['accuracy'],
        'classification_report': model_artifacts['classification_report'],
        'feature_columns': model_artifacts['feature_columns'],
        'categorical_features_indices': model_artifacts.get('categorical_features_indices', []),
        'cbm_model_path': cbm_model_path,
        'model_type': 'CatBoostClassifier'
    }

    metadata_path = os.path.join(output_dir, 'metadata.json')
    with open(metadata_path, 'w', encoding='utf-8') as f:
        json.dump(metadata, f, indent=2, ensure_ascii=False)

    print(f"Артефакты сохранены в {output_dir}")
    print(f"CatBoost модель: {cbm_model_path}")
    print(f"Pickle метаданные: {pickle_metadata_path}")
    print(f"JSON метаданные: {metadata_path}")

    return cbm_model_path, metadata_path


def main():
    parser = argparse.ArgumentParser(description='Train ML ranking model with artifact saving')
    parser.add_argument('--data-path', default='data/raw/styles.csv', help='Path to training data CSV file')
    parser.add_argument('--output-dir', default='artifacts', help='Directory to save model artifacts')

    args = parser.parse_args()

    print(f"Загрузка реальных данных из {args.data_path}...")
    df = load_and_prepare_real_data(args.data_path)

    print(f"Загружено {len(df)} записей из реального датасета")
    print("Подготовка признаков...")
    X, y, categorical_features_indices = prepare_features(df)

    print("Тренировка модели...")
    artifacts = train_ranking_model(X, y, categorical_features_indices)

    print("Сохранение артефактов...")
    save_artifacts(artifacts, args.output_dir)

    print("✅ Обучение модели завершено!")


if __name__ == "__main__":
    main()
