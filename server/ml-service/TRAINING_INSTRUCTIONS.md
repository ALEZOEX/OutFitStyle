# OutfitStyle ML Model Training Instructions

## Overview
This document explains how to train the ML model for the OutfitStyle recommendation system.

## Prerequisites
1. Ensure you have installed all required packages from `requirements.txt`:
   ```
   pip install -r requirements.txt
   ```

## Training Process

### 1. Dataset Preparation
The system requires a dataset with the following columns:
- Weather features: temperature, feels_like, humidity, wind_speed, weather_condition, season
- User features: age_range, style_preference, temperature_sensitivity, formality_preference
- Item features: item_name, category, min_temp, max_temp, warmth_level, formality_level, item_style
- Target variable: is_recommended (1 or 0)

### 2. Training Execution
Run the training script:
```
python manual_train.py
```

This will:
1. Load the dataset from `data/training_data.csv`
2. Train a Gradient Boosting model
3. Save the trained model to `models/advanced_recommender.pkl`

### 3. Model Details
The training uses a Gradient Boosting Classifier with the following parameters:
- n_estimators: 300
- learning_rate: 0.05
- max_depth: 7
- min_samples_split: 20
- min_samples_leaf: 10
- subsample: 0.8

### 4. Output
After successful training, you'll get:
- Trained model saved in `models/advanced_recommender.pkl`
- Performance metrics printed to console
- Test prediction results

## Using the Trained Model
The trained model can be used in the ML service (`main.py`) to provide outfit recommendations based on:
- Current weather conditions
- User preferences
- Available clothing items