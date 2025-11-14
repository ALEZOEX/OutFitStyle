import pandas as pd
import numpy as np
from model.advanced_trainer import AdvancedOutfitRecommender
from data.prepare_dataset import DatasetPreparer
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def preprocess_kaggle_data(df):
    """
    Preprocess the Kaggle dataset to match our model's expected format
    """
    logger.info("Preprocessing Kaggle dataset...")
    
    # Map Indonesian column names to English
    column_mapping = {
        'Jenis Kelamin': 'gender',
        'Kondisi Cuaca': 'weather_condition',
        'Suhu': 'temperature',
        'Kelembapan': 'humidity',
        'Lokasi': 'location',
        'Aktivitas': 'activity',
        'Durasi': 'duration',
        'Atasan': 'upper_body',
        'Bawahan': 'lower_body',
        'Pakaian Luar': 'outerwear',
        'Alas Kaki': 'footwear'
    }
    
    df = df.rename(columns=column_mapping)
    
    # Create a list to store our transformed data
    processed_data = []
    
    # Weather condition mapping
    weather_mapping = {
        'Cerah': 'clear',
        'Mendung': 'clouds',
        'Hujan': 'rain',
        'Berawan': 'clouds',
        'Gerimis': 'drizzle'
    }
    
    # Location mapping
    location_mapping = {
        'Indoor': 'indoor',
        'Outdoor': 'outdoor'
    }
    
    # Activity mapping
    activity_mapping = {
        'Berjalan': 'walking',
        'Santai': 'leisure',
        'Kondangan': 'formal_event',
        'Bekerja': 'working',
        'Olahraga': 'sports'
    }
    
    # Gender mapping
    gender_mapping = {
        'Laki-laki': 'male',
        'Perempuan': 'female'
    }
    
    # Process each row
    for _, row in df.iterrows():
        # Process temperature and humidity
        temperature = float(row['temperature'])
        humidity = float(row['humidity'])
        
        # Process categorical variables
        weather = weather_mapping.get(row['weather_condition'], row['weather_condition'].lower())
        location = location_mapping.get(row['location'], row['location'].lower())
        activity = activity_mapping.get(row['activity'], row['activity'].lower())
        gender = gender_mapping.get(row['gender'], row['gender'].lower())
        
        # Create season based on temperature
        if temperature < 10:
            season = 'winter'
        elif temperature < 20:
            season = 'spring'
        elif temperature < 30:
            season = 'summer'
        else:
            season = 'autumn'
        
        # Process clothing items
        clothing_items = [
            {'item': row['upper_body'], 'category': 'upper'},
            {'item': row['lower_body'], 'category': 'lower'},
            {'item': row['outerwear'] if row['outerwear'] != 'Tanpa Pakaian Luar' else None, 'category': 'outerwear'},
            {'item': row['footwear'], 'category': 'footwear'}
        ]
        
        # Filter out None items
        clothing_items = [item for item in clothing_items if item['item'] is not None]
        
        # For each clothing item, create a positive training sample
        for item in clothing_items:
            processed_data.append({
                'gender': gender,
                'age_range': '25-35',  # Default value as not in dataset
                'temperature': temperature,
                'feels_like': temperature,  # Approximation
                'humidity': humidity,
                'wind_speed': 5.0,  # Default value as not in dataset
                'weather_condition': weather,
                'season': season,
                'location': location,
                'activity': activity,
                'duration': float(row['duration']),
                'style_preference': 'casual',  # Default value as not in dataset
                'temperature_sensitivity': 'normal',  # Default value as not in dataset
                'formality_preference': 'informal' if activity in ['leisure', 'sports'] else 'formal',  # Inferred
                'item_name': item['item'],
                'category': item['category'],
                'min_temp': temperature - 5 if item['category'] == 'outerwear' else temperature,  # Approximation
                'max_temp': temperature + 5 if item['category'] == 'outerwear' else temperature + 10,  # Approximation
                'warmth_level': 5,  # Default value as not in dataset
                'formality_level': 8 if activity == 'formal_event' else 3 if activity == 'sports' else 5,  # Inferred
                'item_style': 'casual',  # Default value as not in dataset
                'is_recommended': 1  # Since this is what people actually wore, we assume it's recommended
            })
        
        # Generate negative samples to balance the dataset
        # Create a clothing dataset similar to the existing one
        preparer = DatasetPreparer()
        clothing_dataset = preparer.create_clothing_dataset()
        
        # For each positive sample, try to generate a negative one
        # Limit attempts to prevent infinite loops
        negative_samples_generated = 0
        max_attempts = len(clothing_dataset)  # Limit attempts to dataset size
        attempts = 0
        
        while negative_samples_generated < len(clothing_items) and attempts < max_attempts:
            # Randomly select an item from our clothing dataset
            random_item = clothing_dataset.sample(1).iloc[0]
            
            # Create a user profile for evaluation
            user_profile = {
                'age_range': '25-35',
                'style_preference': 'casual',
                'temperature_sensitivity': 'normal',
                'formality_preference': 'informal' if activity in ['leisure', 'sports'] else 'formal'
            }
            
            # Create weather profile for evaluation
            weather_profile = {
                'temperature': temperature,
                'feels_like': temperature,
                'humidity': humidity,
                'wind_speed': 5.0,
                'weather_condition': weather,
                'season': season
            }
            
            # Use the existing evaluation method to determine if this is a good choice
            is_recommended = preparer._evaluate_choice(weather_profile, user_profile, random_item)
            
            # Only add if it's not recommended (negative sample)
            if is_recommended == 0:
                processed_data.append({
                    'gender': gender,
                    'age_range': '25-35',
                    'temperature': temperature,
                    'feels_like': temperature,
                    'humidity': humidity,
                    'wind_speed': 5.0,
                    'weather_condition': weather,
                    'season': season,
                    'location': location,
                    'activity': activity,
                    'duration': float(row['duration']),
                    'style_preference': 'casual',
                    'temperature_sensitivity': 'normal',
                    'formality_preference': 'informal' if activity in ['leisure', 'sports'] else 'formal',
                    'item_name': random_item['name'],
                    'category': random_item['category'],
                    'min_temp': random_item['min_temp'],
                    'max_temp': random_item['max_temp'],
                    'warmth_level': random_item['warmth'],
                    'formality_level': random_item['formality'],
                    'item_style': random_item['style'],
                    'is_recommended': 0
                })
                negative_samples_generated += 1
            
            attempts += 1
    
    processed_df = pd.DataFrame(processed_data)
    logger.info(f"Processed {len(processed_df)} training samples from {len(df)} original rows")
    return processed_df

def main():
    logger.info("="*60)
    logger.info("🚀 Training OutfitStyle ML Model from Kaggle Dataset")
    logger.info("="*60)
    
    # 1. Load the Kaggle dataset
    dataset_path = 'data/season fashion dataset - multilabel.csv'
    
    if not os.path.exists(dataset_path):
        logger.error(f"Dataset not found: {dataset_path}")
        logger.info("Please place the Kaggle dataset in the data folder")
        return
    
    logger.info(f"Loading dataset from {dataset_path}...")
    df = pd.read_csv(dataset_path)
    
    logger.info(f"Dataset loaded: {len(df)} samples")
    logger.info(f"Columns: {list(df.columns)}")
    
    # 2. Preprocess the data
    processed_df = preprocess_kaggle_data(df)
    
    # 3. Show statistics
    logger.info("\n📊 Dataset Statistics:")
    logger.info(f"  Total samples: {len(processed_df)}")
    logger.info(f"  Positive samples: {sum(processed_df['is_recommended'])} ({sum(processed_df['is_recommended'])/len(processed_df)*100:.1f}%)")
    logger.info(f"  Negative samples: {len(processed_df) - sum(processed_df['is_recommended'])} ({(len(processed_df) - sum(processed_df['is_recommended']))/len(processed_df)*100:.1f}%)")
    logger.info(f"  Categories: {processed_df['category'].nunique()}")
    logger.info(f"  Temperature range: {processed_df['temperature'].min():.1f}°C to {processed_df['temperature'].max():.1f}°C")
    
    # 4. Create and train the model
    logger.info("\n🧠 Training model...")
    
    # Can choose: 'gradient_boosting' or 'random_forest'
    model = AdvancedOutfitRecommender(model_type='gradient_boosting')
    
    # Train (optimize_hyperparameters=True for better quality but slower)
    metrics = model.train(processed_df, optimize_hyperparameters=False)
    
    # 5. Save the model
    os.makedirs('models', exist_ok=True)
    model.save('models/kaggle_trained_recommender.pkl')
    
    # Also save as the main model
    model.save('models/advanced_recommender.pkl')
    
    # 6. Plot feature importance
    try:
        model.plot_feature_importance('models/kaggle_feature_importance.png')
        logger.info("Feature importance plot saved to models/kaggle_feature_importance.png")
    except Exception as e:
        logger.warning(f"Could not plot feature importance: {e}")
    
    # 7. Test prediction
    logger.info("\n🧪 Testing model prediction...")
    
    test_weather = {
        'temperature': 25.0,
        'feels_like': 25.0,
        'humidity': 70,
        'wind_speed': 5.0,
        'weather_condition': 'clear',
        'season': 'summer'
    }
    
    test_user = {
        'age_range': '25-35',
        'style_preference': 'casual',
        'temperature_sensitivity': 'normal',
        'formality_preference': 'informal'
    }
    
    test_item = {
        'item_name': 'T-shirt',
        'category': 'upper',
        'min_temp': 15,
        'max_temp': 30,
        'warmth_level': 3,
        'formality_level': 3,
        'item_style': 'casual'
    }
    
    result = model.predict_single(test_weather, test_user, test_item)
    
    logger.info(f"\nTest prediction:")
    logger.info(f"  Item: {test_item['item_name']}")
    logger.info(f"  Temperature: {test_weather['temperature']}°C")
    logger.info(f"  Recommended: {result['is_recommended']}")
    logger.info(f"  Confidence: {result['confidence']:.2%}")
    
    logger.info("\n✅ Training complete!")
    logger.info(f"Model saved to: models/kaggle_trained_recommender.pkl")
    logger.info("You can now use this model in the ML service!")

if __name__ == '__main__':
    main()