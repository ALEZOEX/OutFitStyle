# Training with Kaggle Fashion Dataset

This guide explains how to train the OutfitStyle ML model using the Kaggle Fashion by Season Multi-label dataset.

## Important Fix

The previous version of this script had an issue where it only generated positive examples (items that were recommended), which caused a training error. This has been fixed by generating both positive and negative examples using the same evaluation logic as the original dataset preparation.

## Prerequisites

1. Download the Kaggle dataset from: https://www.kaggle.com/datasets/mottie/fashion-by-season-multi-label
2. Extract the CSV file and place it in the `data` folder with the name `season fashion dataset - multilabel.csv`

## Training the Model

### Option 1: Local Training

1. Navigate to the ml-service directory:
   ```bash
   cd server/ml-service
   ```

2. Ensure you have the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the training script:
   ```bash
   python train_kaggle_dataset.py
   ```

### Option 2: Docker Training

1. Build the Docker image:
   ```bash
   docker build -f Dockerfile.kaggle -t outfitstyle-ml-kaggle .
   ```

2. Run the training with Docker:
   
   On Unix/Linux/macOS:
   ```bash
   docker run --rm -v $(pwd)/data:/app/data -v $(pwd)/models:/app/models outfitstyle-ml-kaggle
   ```
   
   On Windows PowerShell:
   ```powershell
   docker run --rm -v ${pwd}/data:/app/data -v ${pwd}/models:/app/models outfitstyle-ml-kaggle
   ```
   
   On Windows Command Prompt:
   ```cmd
   docker run --rm -v %cd%/data:/app/data -v %cd%/models:/app/models outfitstyle-ml-kaggle
   ```

## Using the Trained Model

After training, the model will be saved as both `models/kaggle_trained_recommender.pkl` and `models/advanced_recommender.pkl`. The application automatically looks for `advanced_recommender.pkl`, so your trained model will be used immediately.

If you want to manually switch between models, you can:

1. Use the provided script:
   ```bash
   python use_kaggle_model.py
   ```

2. Or manually copy the file:
   ```bash
   cp models/kaggle_trained_recommender.pkl models/advanced_recommender.pkl
   ```

## Dataset Transformation

The Kaggle dataset contains clothing recommendations based on weather conditions and activities. The script transforms this data to match our model's expected format by:

1. Converting Indonesian column names to English
2. Mapping categorical values to our standard format
3. Creating season information based on temperature
4. Converting the multi-label format to individual training samples
5. Adding default values for missing features
6. Generating negative examples for proper model training (e.g., winter coats in hot weather)

## Docker Configuration

The Dockerfile.kaggle will automatically detect if the Kaggle dataset is present and train the model accordingly. It will fall back to the default training if the Kaggle dataset is not present.

To build and run with Docker:

```bash
docker build -f Dockerfile.kaggle -t outfitstyle-ml-kaggle .
```

On Unix/Linux/macOS:
```bash
docker run --rm -v $(pwd)/data:/app/data -v $(pwd)/models:/app/models outfitstyle-ml-kaggle
```

On Windows PowerShell:
```powershell
docker run --rm -v ${pwd}/data:/app/data -v ${pwd}/models:/app/models outfitstyle-ml-kaggle
```

On Windows Command Prompt:
```cmd
docker run --rm -v %cd%/data:/app/data -v %cd%/models:/app/models outfitstyle-ml-kaggle
```

## How the Training Works

The Kaggle dataset only contains positive examples (clothing combinations that were actually worn). To properly train a machine learning model, we need both positive and negative examples. The script automatically generates negative examples by:

1. Taking the existing clothing database
2. Randomly selecting items that would not be appropriate for the given weather conditions
3. Using the same evaluation logic as the original dataset preparation to ensure proper labeling

This approach ensures a balanced dataset that can effectively train the recommendation model.

## Improvements Made

We've also made several improvements to the accessory selection logic:

1. Fixed the umbrella recommendation issue by making weather condition matching more robust
2. Added support for both Russian and English weather condition names
3. Improved the model loading to automatically use your trained model
4. Made the accessory selection logic more flexible for different weather conditions

## Comparing Models

You can compare the performance of models trained on different datasets by examining the metrics output during training and the feature importance plots.