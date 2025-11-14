# Training with Kaggle Fashion Dataset

This guide explains how to train the OutfitStyle ML model using the Kaggle Fashion by Season Multi-label dataset.

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
   docker build -t outfitstyle-ml-kaggle .
   ```

2. Run the training (you can override the CMD to run training instead of the service):
   ```bash
   docker run --rm -v $(pwd)/data:/app/data -v $(pwd)/models:/app/models outfitstyle-ml-kaggle python train_kaggle_dataset.py
   ```

## Using the Trained Model

After training, the model will be saved as `models/kaggle_trained_recommender.pkl`. You can configure the service to use this model by modifying the model loading path in the main application.

## Dataset Transformation

The Kaggle dataset contains clothing recommendations based on weather conditions and activities. The script transforms this data to match our model's expected format by:

1. Converting Indonesian column names to English
2. Mapping categorical values to our standard format
3. Creating season information based on temperature
4. Converting the multi-label format to individual training samples
5. Adding default values for missing features

## Docker Configuration

If you want to make the Docker image use the Kaggle-trained model by default, you can modify the Dockerfile to run the Kaggle training script instead:

```dockerfile
# Replace this line in the Dockerfile:
RUN python train_if_needed.py

# With:
RUN python train_kaggle_dataset.py
```

Or create a new Dockerfile specifically for Kaggle training:

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create directories
RUN mkdir -p data models

# Train model with Kaggle dataset if data is available
RUN python train_kaggle_dataset.py

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "main.py"]
```

## Comparing Models

You can compare the performance of models trained on different datasets by examining the metrics output during training and the feature importance plots.