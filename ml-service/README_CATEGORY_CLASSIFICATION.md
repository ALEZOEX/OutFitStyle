# Category Classification Service

This document describes the category classification functionality added to the ML service.

## Overview

The category classification service provides ML-based classification for clothing items into five categories:
- `outerwear` - Jackets, coats, parkas, blazers, etc.
- `upper` - T-shirts, shirts, blouses, sweaters, hoodies, etc.
- `lower` - Jeans, pants, shorts, skirts, leggings, etc.
- `footwear` - Shoes, sneakers, boots, sandals, etc.
- `accessory` - Hats, scarves, bags, belts, jewelry, etc.

## Project Structure

```
ml-service/
├── api/
│   ├── main.py                # FastAPI app entry point (updated)
│   └── routes.py              # HTTP endpoints for classification
├── services/
│   ├── category_classifier.py # ML classifier logic
│   └── ...                    # Other services
├── requirements.txt           # Python dependencies (updated)
└── README_CATEGORY_CLASSIFICATION.md  # This file
```

## Setup Instructions

### 1. Install Dependencies

The required dependencies are already listed in `requirements.txt`. To install them:

```bash
cd ml-service
pip install -r requirements.txt
```

Key dependencies for category classification:
- `fastapi` - Web framework
- `uvicorn` - ASGI server
- `scikit-learn` - ML library (for future model training)
- `pandas` - Data manipulation
- `pydantic` - Data validation

### 2. Run the Service

Start the FastAPI server:

```bash
# From ml-service directory
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

Or using the existing Docker setup:

```bash
# From project root
docker-compose up ml-service
```

### 3. Test the Classification Endpoint

The classification endpoint is available at `POST /api/v1/classify`.

Example request:

```bash
curl -X POST "http://localhost:8000/api/v1/classify" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Blue Denim Jeans",
    "subcategory": "jeans",
    "materials": ["cotton", "denim"],
    "style": "casual"
  }'
```

Example response:

```json
{
  "category": "lower",
  "confidence": 0.95
}
```

### 4. Health Check

Check if the classification service is running:

```bash
curl http://localhost:8000/api/v1/health
```

Response:

```json
{
  "status": "healthy",
  "service": "category-classification"
}
```

## API Endpoints

### POST /api/v1/classify

Classify a clothing item into a category.

**Request Body:**

```json
{
  "name": "string",           // Item name
  "subcategory": "string",    // Item subcategory
  "materials": ["string"],    // List of materials (optional)
  "style": "string"           // Item style (optional)
}
```

**Response:**

```json
{
  "category": "string",       // Predicted category (outerwear/upper/lower/footwear/accessory)
  "confidence": 0.95          // Confidence score (0.0 to 1.0)
}
```

**Status Codes:**
- `200 OK` - Classification successful
- `422 Unprocessable Entity` - Invalid request body
- `500 Internal Server Error` - Classification failed

### GET /api/v1/health

Health check endpoint for the classification service.

**Response:**

```json
{
  "status": "healthy",
  "service": "category-classification"
}
```

## Current Implementation

The current implementation uses a **rule-based classifier** as a placeholder. It:

1. Maps known subcategories to categories using a predefined mapping
2. Returns high confidence (0.95) for known subcategories
3. Falls back to name-based inference for unknown subcategories
4. Returns lower confidence (0.6) for inferred categories

### Subcategory Mapping

The classifier includes mappings for 40+ subcategories as specified in the requirements:

- **Upper**: t-shirt, shirt, blouse, sweater, hoodie, vest, top
- **Lower**: jeans, pants, trousers, shorts, skirt, leggings, trackpants
- **Outerwear**: jacket, coat, parka, raincoat, puffer, blazer, windbreaker
- **Footwear**: shoes, sneakers, boots, sandals, loafers, oxford, slippers, heels
- **Accessory**: hat, cap, scarf, gloves, belt, bag, watch, sunglasses, jewelry

## Future Enhancements

The following features will be implemented in later tasks:

1. **ML Model Training** - Train a scikit-learn model on corrected data from the audit trail
2. **Feature Engineering** - Use TF-IDF for text features, one-hot encoding for categorical features
3. **Model Persistence** - Save and load trained models
4. **Confidence Thresholds** - Implement confidence-based decision logic:
   - Confidence > 0.8: Auto-assign category
   - Confidence 0.5-0.8: Flag for manual review
   - Confidence < 0.5: Use fallback category
5. **Training API** - Endpoint to retrain the model with new data

## Integration with Go Backend

The Go backend's ML Classifier Client will call this service:

```go
// Example Go client code
type ClassifyRequest struct {
    Name        string   `json:"name"`
    Subcategory string   `json:"subcategory"`
    Materials   []string `json:"materials"`
    Style       string   `json:"style"`
}

type ClassifyResponse struct {
    Category   string  `json:"category"`
    Confidence float64 `json:"confidence"`
}

// HTTP POST to http://ml-service:8000/api/v1/classify
```

## Testing

To test the classification service:

```bash
# Test with known subcategory
curl -X POST "http://localhost:8000/api/v1/classify" \
  -H "Content-Type: application/json" \
  -d '{"name": "Cotton T-Shirt", "subcategory": "t-shirt", "materials": ["cotton"], "style": "casual"}'

# Test with unknown subcategory
curl -X POST "http://localhost:8000/api/v1/classify" \
  -H "Content-Type: application/json" \
  -d '{"name": "Winter Jacket", "subcategory": "unknown", "materials": ["polyester"], "style": "outdoor"}'
```

## Troubleshooting

### Import Errors

If you see import errors when running the service, make sure you're running from the correct directory:

```bash
# Run from ml-service directory
cd ml-service
python -m uvicorn api.main:app --reload
```

Or set the PYTHONPATH:

```bash
export PYTHONPATH=/path/to/ml-service:$PYTHONPATH
```

### Port Already in Use

If port 8000 is already in use, specify a different port:

```bash
uvicorn api.main:app --reload --port 8001
```

## Related Documentation

- [Requirements Document](../.kiro/specs/clothing-category-classification-improvement/requirements.md)
- [Design Document](../.kiro/specs/clothing-category-classification-improvement/design.md)
- [Tasks Document](../.kiro/specs/clothing-category-classification-improvement/tasks.md)
