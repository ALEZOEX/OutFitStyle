import pandas as pd
import os
from model.advanced_trainer import AdvancedOutfitRecommender
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("="*60)
    logger.info("🚀 Manual Training of OutfitStyle ML Model")
    logger.info("="*60)
    
    # Create models directory if it doesn't exist
    if not os.path.exists('models'):
        os.makedirs('models')
        logger.info("Created models directory")
    
    # Load dataset
    dataset_path = 'data/training_data.csv'
    
    if not os.path.exists(dataset_path):
        logger.error(f"Dataset not found: {dataset_path}")
        return
    
    logger.info(f"Loading dataset from {dataset_path}...")
    df = pd.read_csv(dataset_path)
    
    logger.info(f"Dataset loaded: {len(df)} samples")
    logger.info(f"Columns: {list(df.columns)}")
    
    # Show statistics
    logger.info("\n📊 Dataset Statistics:")
    logger.info(f"  Positive samples: {sum(df['is_recommended'])} ({sum(df['is_recommended'])/len(df)*100:.1f}%)")
    logger.info(f"  Negative samples: {len(df) - sum(df['is_recommended'])} ({(len(df) - sum(df['is_recommended']))/len(df)*100:.1f}%)")
    
    # Create and train model
    logger.info("\n🧠 Training model...")
    model = AdvancedOutfitRecommender(model_type='gradient_boosting')
    
    # Train the model
    try:
        metrics = model.train(df, optimize_hyperparameters=False)
        logger.info("Training completed successfully")
    except Exception as e:
        logger.error(f"Error during training: {str(e)}")
        return
    
    # Save the model
    try:
        model.save('models/advanced_recommender.pkl')
        logger.info("Model saved successfully")
    except Exception as e:
        logger.error(f"Error saving model: {str(e)}")
        return
    
    # Test prediction
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
    
    try:
        result = model.predict_single(test_weather, test_user, test_item)
        
        logger.info(f"\nTest prediction:")
        logger.info(f"  Item: {test_item['item_name']}")
        logger.info(f"  Temperature: {test_weather['temperature']}°C")
        logger.info(f"  Recommended: {result['is_recommended']}")
        logger.info(f"  Confidence: {result['confidence']:.2%}")
    except Exception as e:
        logger.error(f"Error during prediction: {str(e)}")
    
    logger.info("\n✅ Manual training complete!")
    logger.info(f"Model saved to: models/advanced_recommender.pkl")

if __name__ == '__main__':
    main()