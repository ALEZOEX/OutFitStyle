#!/usr/bin/env python3
"""
Script to train the ML model from scratch
"""
import os
import sys
import shutil
from pathlib import Path

def clean_models_directory():
    """Remove old model artifacts"""
    models_dir = Path("models")
    if models_dir.exists():
        print("Cleaning models directory...")
        for file in models_dir.glob("*"):
            if file.is_file() and file.suffix in ['.pkl', '.cbm', '.json']:
                print(f"  Removing {file.name}")
                file.unlink()
        print("Models directory cleaned")
    else:
        print("Creating models directory...")
        models_dir.mkdir(parents=True, exist_ok=True)

def train_model():
    """Train the model using the updated train_ranker script"""
    print("Starting model training...")

    # Import and run the training
    sys.path.insert(0, os.path.abspath("."))

    from train.train_ranker import main as train_main
    train_main()

def main():
    print("="*60)
    print("OutfitStyle ML Model Training Script")
    print("="*60)

    # Clean previous artifacts
    clean_models_directory()

    # Train the model
    train_model()

    print("\nModel training completed successfully!")
    print("Check the 'artifacts' directory for new model files")

if __name__ == "__main__":
    main()
