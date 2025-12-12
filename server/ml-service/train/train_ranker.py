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


def generate_synthetic_training_data(n_samples: int = 10000) -> pd.DataFrame:
    """
    Генерация синтетических обучающих данных для модели ранжирования.
    """
    np.random.seed(42)  # для воспроизводимости
    
    data = {
        'category': np.random.choice(['outerwear', 'upper', 'lower', 'footwear', 'accessory'], n_samples),
        'subcategory': np.random.choice(['tshirt', 'jeans', 'sneakers', 'hat', 'coat', 'pants'], n_samples),
        'formality_level': np.random.randint(1, 6, n_samples),
        'warmth_level': np.random.randint(1, 11, n_samples),
        'temperature_match': np.random.uniform(-10, 15, n_samples),  # разница между температурой и диапазоном вещи
        'source_priority': np.random.randint(0, 4, n_samples),  # 0-3
        'is_owned': np.random.choice([0, 1], n_samples),
        'material_count': np.random.randint(1, 4, n_samples),
        'season_match': np.random.choice([0, 1], n_samples),  # соответствует ли сезон
        'style_match': np.random.uniform(0, 1, n_samples),  # насколько стиль соответствует предпочтениям
    }
    
    df = pd.DataFrame(data)
    
    # Создание целевой переменной (подходит/не подходит) на основе логики
    # Вещь считается подходящей, если:
    # - температурное соответствие в пределах нормы
    # - формальность близка к предпочтениям
    # - высокий приоритет источника
    # - принадлежит пользователю
    
    temperature_fit = (df['temperature_match'].abs() < 5).astype(int)
    formality_balance = (df['formality_level'].between(2, 4)).astype(int)  # средние уровни
    source_good = (df['source_priority'] > 1).astype(int)  # высокий приоритет
    owned = df['is_owned']
    
    # Комбинируем факторы для создания целевой переменной
    df['target'] = (
        0.3 * temperature_fit + 
        0.2 * formality_balance + 
        0.3 * source_good + 
        0.2 * owned + 
        0.1 * df['style_match']
    ).round().astype(int)
    
    # Убедиться, что target в диапазоне [0, 1]
    df['target'] = df['target'].clip(0, 1)
    
    return df


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
    parser.add_argument('--samples', type=int, default=10000, help='Number of synthetic samples to generate')
    parser.add_argument('--output-dir', default='artifacts', help='Directory to save model artifacts')
    
    args = parser.parse_args()
    
    print(f"Генерация {args.samples} синтетических образцов...")
    df = generate_synthetic_training_data(args.samples)
    
    print("Подготовка признаков...")
    X, y = prepare_features(df)
    
    print("Тренировка модели...")
    artifacts = train_ranking_model(X, y)
    
    print("Сохранение артефактов...")
    save_artifacts(artifacts, args.output_dir)
    
    print("✅ Обучение модели завершено!")


if __name__ == "__main__":
    main()