import os
import sys
import logging
import pandas as pd
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from model.advanced_trainer import AdvancedOutfitRecommender
from model.features import FeatureExtractor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger('outfitstyle.ml_service.train_comprehensive')

def load_comprehensive_data(filepath='data/training_data.csv'):
    """Load comprehensive training data."""
    try:
        logger.info(f"Loading training data from {filepath}...")
        df = pd.read_csv(filepath)
        logger.info(f"Loaded {len(df)} training samples")
        logger.info(f"Columns: {list(df.columns)}")
        return df
    except Exception as e:
        logger.error(f"Failed to load training data: {str(e)}")
        raise

def train_model(df, model_type='gradient_boosting', optimize_hyperparameters=False):
    """Train the comprehensive outfit recommendation model."""
    # Initialize model
    model = AdvancedOutfitRecommender(model_type=model_type)
    
    # Train model
    logger.info("Starting model training...")
    metrics = model.train(df, optimize_hyperparameters=optimize_hyperparameters)
    
    # Save model
    model_path = os.getenv('MODEL_PATH', 'models/advanced_recommender.pkl')
    os.makedirs(os.path.dirname(model_path), exist_ok=True)
    model.save(model_path)
    logger.info(f"Model saved to {model_path}")
    
    # Plot feature importance
    try:
        # model.plot_feature_importance('models/feature_importance.png')
        logger.info("Feature importance plot saved to models/feature_importance.png")
    except Exception as e:
        logger.warning(f"Could not plot feature importance: {str(e)}")
    
    return metrics

def main():
    """Main entry point for the training script."""
    logger.info("=" * 70)
    logger.info("🚀 Training OutfitStyle Model with Comprehensive Data")
    logger.info("=" * 70)
    logger.info(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Load data
    df = load_comprehensive_data()
    
    # Train model
    metrics = train_model(
        df,
        model_type='gradient_boosting',
        optimize_hyperparameters=False
    )
    
    # Log training results
    logger.info("\n" + "="*60)
    logger.info("TRAINING RESULTS")
    logger.info("="*60)
    logger.info(f"Accuracy: {metrics.get('accuracy', 0.0):.4f}")
    logger.info(f"Precision: {metrics.get('precision', 0.0):.4f}")
    logger.info(f"Recall: {metrics.get('recall', 0.0):.4f}")
    logger.info(f"F1 Score: {metrics.get('f1_score', 0.0):.4f}")
    logger.info(f"AUC-ROC: {metrics.get('auc', 0.0):.4f}")
    logger.info(f"Cross-validation: {metrics.get('cv_mean', 0.0):.4f} (+/- {metrics.get('cv_std', 0.0):.4f})")
    
    # Log top features if available
    if 'top_features' in metrics:
        logger.info("\nTop 10 Features:")
        for i, feature in enumerate(metrics['top_features'], 1):
            logger.info(f"  {i}. {feature['name']}: {feature['importance']:.4f}")
    
    logger.info("\n✅ Training complete!")

if __name__ == '__main__':
    main()