import pandas as pd
from model.advanced_trainer import AdvancedOutfitRecommender
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("="*60)
    logger.info("🚀 Training OutfitStyle ML Model from Dataset")
    logger.info("="*60)
    
    # 1. Загружаем датасет
    dataset_path = 'data/training_data.csv'
    
    if not os.path.exists(dataset_path):
        logger.error(f"Dataset not found: {dataset_path}")
        logger.info("Please run: python data/prepare_dataset.py")
        return
    
    logger.info(f"Loading dataset from {dataset_path}...")
    df = pd.read_csv(dataset_path)
    
    logger.info(f"Dataset loaded: {len(df)} samples")
    logger.info(f"Columns: {list(df.columns)}")
    
    # 2. Показываем статистику
    logger.info("\n📊 Dataset Statistics:")
    logger.info(f"  Positive samples: {sum(df['is_recommended'])} ({sum(df['is_recommended'])/len(df)*100:.1f}%)")
    logger.info(f"  Negative samples: {len(df) - sum(df['is_recommended'])} ({(len(df) - sum(df['is_recommended']))/len(df)*100:.1f}%)")
    logger.info(f"  Categories: {df['category'].nunique()}")
    logger.info(f"  Temperature range: {df['temperature'].min():.1f}°C to {df['temperature'].max():.1f}°C")
    
    # 3. Создаем и обучаем модель
    logger.info("\n🧠 Training model...")
    
    # Можно выбрать: 'gradient_boosting' или 'random_forest'
    model = AdvancedOutfitRecommender(model_type='gradient_boosting')
    
    # Обучение (optimize_hyperparameters=True для лучшего качества, но дольше)
    metrics = model.train(df, optimize_hyperparameters=False)
    
    # 4. Сохраняем модель
    os.makedirs('models', exist_ok=True)
    model.save('models/advanced_recommender.pkl')
    
    # 5. Визуализация важности признаков
    try:
        model.plot_feature_importance('models/feature_importance.png')
    except:
        logger.warning("Could not plot feature importance")
    
    # 6. Тестовое предсказание
    logger.info("\n🧪 Testing model prediction...")
    
    test_weather = {
        'temperature': 15.0,
        'feels_like': 13.0,
        'humidity': 70,
        'wind_speed': 5.0,
        'weather_condition': 'clouds',
        'season': 'spring'
    }
    
    test_user = {
        'age_range': '25-35',
        'style_preference': 'casual',
        'temperature_sensitivity': 'normal',
        'formality_preference': 'informal'
    }
    
    test_item = {
        'item_name': 'Light Jacket',
        'category': 'outerwear',
        'min_temp': 10,
        'max_temp': 20,
        'warmth_level': 4,
        'formality_level': 6,
        'item_style': 'casual'
    }
    
    result = model.predict_single(test_weather, test_user, test_item)
    
    logger.info(f"\nTest prediction:")
    logger.info(f"  Item: {test_item['item_name']}")
    logger.info(f"  Temperature: {test_weather['temperature']}°C")
    logger.info(f"  Recommended: {result['is_recommended']}")
    logger.info(f"  Confidence: {result['confidence']:.2%}")
    
    logger.info("\n✅ Training complete!")
    logger.info(f"Model saved to: models/advanced_recommender.pkl")
    logger.info(f"You can now use this model in the ML service!")

if __name__ == '__main__':
    main()