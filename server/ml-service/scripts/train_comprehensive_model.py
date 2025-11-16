#!/usr/bin/env python3
"""
Script to train the model with comprehensive data including all parameters
"""

import pandas as pd
import sys
import os
from datetime import datetime

# Add the parent directory to the path so we can import our modules
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from model.advanced_trainer import AdvancedOutfitRecommender

def load_comprehensive_data(filepath='data/comprehensive_training_data.csv'):
    """Load comprehensive training data"""
    try:
        df = pd.read_csv(filepath)
        print(f"✅ Loaded {len(df)} training samples from {filepath}")
        return df
    except FileNotFoundError:
        print(f"❌ File not found: {filepath}")
        print("Please generate comprehensive data first by running:")
        print("  python scripts/generate_comprehensive_training_data.py")
        return None
    except Exception as e:
        print(f"❌ Error loading data: {e}")
        return None

def train_comprehensive_model(df, model_type='gradient_boosting', optimize=False):
    """Train model with comprehensive data"""
    print(f"\n🚀 Training {model_type} model with {len(df)} samples...")
    print(f"   Features: {len(df.columns) - 1}")  # -1 for target column
    
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
        print(f"\n🏆 Top 10 Features:")
        for i, feature in enumerate(metrics['top_features'][:10]):
            print(f"  {i+1:2d}. {feature['name']:25s}: {feature['importance']:.3f}")
    
    return model, metrics

def save_comprehensive_model(model, filepath='models/comprehensive_trained_model.pkl'):
    """Save trained model"""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    model.save(filepath)
    print(f"\n✅ Model saved to {filepath}")

def plot_comprehensive_feature_importance(model, filepath='models/comprehensive_feature_importance.png'):
    """Plot feature importance"""
    try:
        model.plot_feature_importance(filepath)
        print(f"📈 Feature importance plot saved to {filepath}")
    except Exception as e:
        print(f"⚠️ Could not plot feature importance: {e}")

def main():
    print("=" * 70)
    print("🤖 Training OutfitStyle Model with COMPREHENSIVE Data")
    print("=" * 70)
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("\nParameters considered:")
    print("  🌡️  Weather: Temperature, Feels-like, Humidity, Wind, Conditions")
    print("  👤 User: Gender, Age, Style Preference, Temp Sensitivity, Formality")
    print("  👕 Clothing: Name, Category, Temp Range, Warmth, Formality, Style")
    print("  🧮 Engineered: Temp Range, Suitability, Distance, Feels-like Diff")
    
    # Load comprehensive data
    df = load_comprehensive_data()
    if df is None:
        return
    
    # Show data info
    print(f"\n📊 Data Overview:")
    print(f"  Samples: {len(df)}")
    print(f"  Features: {len(df.columns) - 1}")  # -1 for target column
    print(f"  Positive: {sum(df['is_recommended'])} ({sum(df['is_recommended'])/len(df)*100:.1f}%)")
    print(f"  Negative: {len(df) - sum(df['is_recommended'])} ({(len(df) - sum(df['is_recommended']))/len(df)*100:.1f}%)")
    
    # Show feature names
    print(f"\n📋 Feature Names:")
    feature_cols = [col for col in df.columns if col != 'is_recommended']
    for i, feature in enumerate(feature_cols, 1):
        print(f"  {i:2d}. {feature}")
    
    # Train model
    model, metrics = train_comprehensive_model(df, model_type='gradient_boosting')
    
    # Save model
    save_comprehensive_model(model, 'models/comprehensive_trained_model.pkl')
    
    # Plot feature importance
    plot_comprehensive_feature_importance(model, 'models/comprehensive_feature_importance.png')
    
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