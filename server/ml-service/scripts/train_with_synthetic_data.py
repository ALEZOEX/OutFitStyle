#!/usr/bin/env python3
"""
Script to train the model with synthetic data
"""

import pandas as pd
import sys
import os

# Add the parent directory to the path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from model.advanced_trainer import AdvancedOutfitRecommender

def load_synthetic_data(filepath='data/synthetic_training_data.csv'):
    """Load synthetic training data"""
    try:
        df = pd.read_csv(filepath)
        print(f"✅ Loaded {len(df)} training samples from {filepath}")
        return df
    except FileNotFoundError:
        print(f"❌ File not found: {filepath}")
        print("Please generate synthetic data first by running:")
        print("  python scripts/generate_synthetic_data.py")
        return None
    except Exception as e:
        print(f"❌ Error loading data: {e}")
        return None

def train_model_with_synthetic_data(df, model_type='gradient_boosting', optimize=False):
    """Train model with synthetic data"""
    print(f"\n🚀 Training {model_type} model with {len(df)} samples...")
    
    # Initialize model
    model = AdvancedOutfitRecommender(model_type=model_type)
    
    # Train model
    metrics = model.train(df, optimize_hyperparameters=optimize)
    
    # Print results
    print("\n" + "="*60)
    print("📊 TRAINING RESULTS")
    print("="*60)
    print(f"Accuracy: {metrics['accuracy']:.2%}")
    print(f"Precision: {metrics['precision']:.2%}")
    print(f"Recall: {metrics['recall']:.2%}")
    print(f"F1-Score: {metrics['f1']:.2%}")
    print(f"AUC-ROC: {metrics['auc_roc']:.2%}")
    print(f"Cross-validation: {metrics['cv_mean']:.2%} (±{metrics['cv_std']:.2%})")
    
    if 'top_features' in metrics:
        print(f"\n🏆 Top 5 Features:")
        for i, feature in enumerate(metrics['top_features'][:5]):
            print(f"  {i+1}. {feature['name']}: {feature['importance']:.3f}")
    
    return model, metrics

def save_model(model, filepath='models/synthetic_trained_model.pkl'):
    """Save trained model"""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    model.save(filepath)
    print(f"\n✅ Model saved to {filepath}")

def plot_feature_importance(model, filepath='models/synthetic_feature_importance.png'):
    """Plot feature importance"""
    try:
        model.plot_feature_importance(filepath)
        print(f"📈 Feature importance plot saved to {filepath}")
    except Exception as e:
        print(f"⚠️ Could not plot feature importance: {e}")

def main():
    print("=" * 60)
    print("🤖 Training OutfitStyle Model with Synthetic Data")
    print("=" * 60)
    
    # Load synthetic data
    df = load_synthetic_data()
    if df is None:
        return
    
    # Show data info
    print(f"\n📊 Data Overview:")
    print(f"  Samples: {len(df)}")
    print(f"  Features: {len(df.columns) - 1}")  # -1 for target column
    print(f"  Positive: {sum(df['is_recommended'])} ({sum(df['is_recommended'])/len(df)*100:.1f}%)")
    print(f"  Negative: {len(df) - sum(df['is_recommended'])} ({(len(df) - sum(df['is_recommended']))/len(df)*100:.1f}%)")
    
    # Train model
    model, metrics = train_model_with_synthetic_data(df, model_type='gradient_boosting')
    
    # Save model
    save_model(model, 'models/synthetic_trained_model.pkl')
    
    # Plot feature importance
    plot_feature_importance(model, 'models/synthetic_feature_importance.png')
    
    # Test prediction
    print("\n🧪 Testing prediction with sample data...")
    test_prediction(model)
    
    print("\n✅ Training complete!")

def test_prediction(model):
    """Test model with sample data"""
    # This is just a placeholder - in a real scenario, you would prepare
    # features in the same format as training data
    print("   (Actual prediction would require preparing features)")
    print("   See model/predictor.py for implementation details")

if __name__ == '__main__':
    main()