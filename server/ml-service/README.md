# OutfitStyle ML Service

This is the Machine Learning service for the OutfitStyle recommendation system. It provides outfit recommendations based on weather data, user preferences, and clothing items.

## Features

- **Professional outfit recommendations**: Uses advanced ML algorithms to provide personalized outfit suggestions
- **Real-time weather integration**: Takes current weather conditions into account
- **User profile personalization**: Adapts recommendations based on user's style preferences
- **Production-ready**: Includes monitoring, logging, and health checks
- **Scalable architecture**: Designed for horizontal scaling in production

## Setup

### Prerequisites
- Python 3.9+
- PostgreSQL database
- OpenWeatherMap API key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-repo/outfitstyle-ml-service.git
cd outfitstyle-ml-service
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Start the service:
```bash
python app/main.py
```

## API Endpoints

### GET /health
Health check endpoint for monitoring systems.

**Response**:
```json
{
  "status": "healthy",
  "service": "ml-service",
  "database": "connected",
  "model_status": "loaded",
  "timestamp": "2023-11-20T10:30:00Z"
}
```

### POST /api/ml/recommend
Get outfit recommendations.

**Request Body**:
```json
{
  "user_id": 1,
  "weather": {
    "location": "Moscow",
    "temperature": 15.0,
    "feels_like": 13.0,
    "humidity": 70,
    "wind_speed": 5.0,
    "weather": "Clouds"
  },
  "min_confidence": 0.5
}
```

**Response**:
```json
{
  "recommendation_id": 123,
  "user_id": 1,
  "weather": {
    "location": "Moscow",
    "temperature": 15.0,
    "feels_like": 13.0,
    "humidity": 70,
    "wind_speed": 5.0,
    "weather": "Clouds"
  },
  "recommendations": [
    {
      "id": 456,
      "name": "Light Jacket",
      "category": "outerwear",
      "ml_score": 0.85
    }
  ],
  "outfit_score": 0.82,
  "ml_powered": true,
  "algorithm": "enhanced_ml_v3",
  "timestamp": "2023-11-20T10:30:00Z"
}
```

## Deployment

### Docker
Build and run with Docker:
```bash
docker build -t outfitstyle-ml-service .
docker run -p 5000:5000 outfitstyle-ml-service
```

### Kubernetes
For production deployment, use the provided Kubernetes manifests.

## Monitoring

- Metrics are exposed at `/metrics` for Prometheus
- Grafana dashboard templates are available in the repository

## Model Training

To train a new model:

1. Prepare training data:
```bash
python scripts/generate_comprehensive_training_data.py
```

2. Train the model:
```bash
python scripts/train_comprehensive.py
```

3. Deploy the new model:
```bash
# Copy the new model to production
cp models/advanced_recommender.pkl /path/to/production/models/
```

## Contributing

For development, please:
1. Create a feature branch
2. Write unit tests for new features
3. Update documentation
4. Submit a pull request with clear description

## License

This project is licensed under the MIT License.