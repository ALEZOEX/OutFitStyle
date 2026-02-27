#!/usr/bin/env python3
"""
Деплой новой ML модели на сервер

Копирует модель из data/raw в models/ и обновляет manifest
"""

import shutil
import json
import pickle
from pathlib import Path
from datetime import datetime


def deploy_model():
    """Деплой модели fashion_model.cbm"""
    
    print("="*60)
    print("ML Model Deployment")
    print("="*60)
    
    # Пути
    models_dir = Path("models")
    source_model = models_dir / "fashion_model.cbm"
    target_model = models_dir / "model.cbm"
    source_metadata = models_dir / "metadata.json"
    target_manifest = models_dir / "model.pkl"
    
    # Проверка существования
    if not source_model.exists():
        print(f"❌ Модель не найдена: {source_model}")
        return False
    
    if not source_metadata.exists():
        print(f"❌ Metadata не найден: {source_metadata}")
        return False
    
    # Копирование модели
    print(f"\nКопирование модели...")
    print(f"  Из: {source_model}")
    print(f"  В: {target_model}")
    shutil.copy2(source_model, target_model)
    print(f"  OK: {target_model.stat().st_size} байт")
    
    # Загрузка metadata
    print(f"\nЗагрузка metadata...")
    with open(source_metadata, 'r', encoding='utf-8') as f:
        metadata = json.load(f)
    
    # Создание manifest (формат для EnhancedPredictor)
    print(f"\nСоздание manifest...")
    manifest = {
        'format': 'catboost_cbm',
        'model_kind': metadata.get('model_kind', 'classifier'),
        'cbm_path': 'model.cbm',
        'version': metadata.get('version', datetime.now().strftime('%Y%m%d_%H%M%S')),
        'cat_features': list(metadata.get('label_encoders', {}).keys()),
        'feature_columns': metadata.get('feature_columns', []),
        'metrics': metadata.get('metrics', {}),
        'deployed_at': datetime.now().isoformat()
    }
    
    # Сохранение manifest
    with open(target_manifest, 'wb') as f:
        pickle.dump(manifest, f)
    
    print(f"  OK Manifest: {target_manifest}")
    print(f"    model_kind: {manifest['model_kind']}")
    print(f"    version: {manifest['version']}")
    print(f"    features: {len(manifest['feature_columns'])}")
    print(f"    cat_features: {len(manifest['cat_features'])}")
    
    # Вывод метрик
    print(f"\n" + "="*60)
    print("Метрики модели:")
    print("="*60)
    for key, value in manifest['metrics'].items():
        print(f"  {key}: {value:.4f}")
    
    print(f"\n" + "="*60)
    print("OK Деплой завершён!")
    print("="*60)
    print(f"\nМодель готова к использованию:")
    print(f"  EnhancedPredictor(manifest_path='models/model.pkl')")
    
    return True


if __name__ == "__main__":
    success = deploy_model()
    if not success:
        exit(1)
