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

# Train model if needed (this will only run if no model exists)
RUN python train_if_needed.py

# If we have a Kaggle-trained model, use it instead
RUN if [ -f "models/kaggle_trained_recommender.pkl" ]; then \
        cp models/kaggle_trained_recommender.pkl models/advanced_recommender.pkl; \
    fi

# Expose port
EXPOSE 5000

# Run the application
CMD ["python", "main.py"]