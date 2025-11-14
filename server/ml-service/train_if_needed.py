import pandas as pd
import os
from model.advanced_trainer import AdvancedOutfitRecommender
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    logger.info("="*60)
    logger.info("🔍 Checking if model training is needed")
    logger.info("="*60)
    
    # Check if model already exists
    model_path = 'models/advanced_recommender.pkl'
    if os.path.exists(model_path):
        logger.info("✅ Model already exists. Skipping training.")
        return
    
    logger.info("🔄 Model not found. Starting training process...")
    
    # Create models directory if it doesn't exist
    if not os.path.exists('models'):
        os.makedirs('models')
        logger.info("📁 Created models directory")
    
    # Check if dataset exists
    dataset_path = 'data/training_data.csv'
    if not os.path.exists(dataset_path):
        logger.info("📊 Dataset not found. Generating synthetic dataset...")
        # Import and run dataset preparation
        try:
            from data.prepare_dataset import DatasetPreparer
            preparer = DatasetPreparer()
            df = preparer.generate_training_data(num_samples=2000)
            preparer.save_dataset(df)
            logger.info("✅ Synthetic dataset generated")
        except Exception as e:
            logger.error(f"❌ Error generating dataset: {str(e)}")
            return
    else:
        logger.info(f"📂 Loading existing dataset from {dataset_path}...")
        df = pd.read_csv(dataset_path)
    
    logger.info(f"📊 Dataset loaded: {len(df)} samples")
    
    # Create and train model
    logger.info("🧠 Training model...")
    model = AdvancedOutfitRecommender(model_type='gradient_boosting')
    
    try:
        metrics = model.train(df, optimize_hyperparameters=False)
        logger.info("✅ Training completed successfully")
    except Exception as e:
        logger.error(f"❌ Error during training: {str(e)}")
        return
    
    # Save the model
    try:
        model.save(model_path)
        logger.info(f"💾 Model saved to: {model_path}")
    except Exception as e:
        logger.error(f"❌ Error saving model: {str(e)}")
        return
    
    logger.info("✅ Training process complete!")

if __name__ == '__main__':
    main()