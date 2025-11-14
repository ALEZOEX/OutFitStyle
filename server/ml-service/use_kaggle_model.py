#!/usr/bin/env python3
"""
Script to use the Kaggle-trained model as the main model
"""

import os
import shutil
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def main():
    kaggle_model_path = 'models/kaggle_trained_recommender.pkl'
    main_model_path = 'models/advanced_recommender.pkl'
    
    if os.path.exists(kaggle_model_path):
        logger.info(f"Found Kaggle-trained model at {kaggle_model_path}")
        logger.info(f"Copying to {main_model_path}")
        
        try:
            shutil.copy2(kaggle_model_path, main_model_path)
            logger.info("✅ Successfully copied Kaggle model to main model location")
        except Exception as e:
            logger.error(f"❌ Failed to copy model: {e}")
    else:
        logger.info("No Kaggle-trained model found. Using default model.")

if __name__ == '__main__':
    main()