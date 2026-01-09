# OutfitStyle API Documentation

## Base URL

```
https://api.outfitstyle.app
```

## Authentication

All API requests require authentication via JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Endpoints

### Authentication

#### POST /api/v1/auth/google
Authenticate with Google account

**Request Body:**
```json
{
  "id_token": "google_id_token"
}
```

**Response:**
```json
{
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "John Doe"
  },
  "access_token": "jwt_access_token",
  "refresh_token": "jwt_refresh_token"
}
```

### Wardrobe

#### GET /api/v1/wardrobe
Get user's wardrobe items

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)

**Response:**
```json
{
  "items": [
    {
      "id": "item_id",
      "name": "Blue T-Shirt",
      "category": "top",
      "color": "blue",
      "warmth_level": 2,
      "style": "casual",
      "formality_level": 2,
      "image_url": "https://example.com/image.jpg",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 15,
  "page": 1,
  "limit": 20
}
```

#### POST /api/v1/wardrobe
Add a new wardrobe item

**Request Body:**
```json
{
  "name": "Blue T-Shirt",
  "category": "top",
  "color": "blue",
  "warmth_level": 2,
  "style": "casual",
  "formality_level": 2,
  "image_url": "https://example.com/image.jpg"
}
```

**Response:**
```json
{
  "item": {
    "id": "item_id",
    "name": "Blue T-Shirt",
    "category": "top",
    "color": "blue",
    "warmth_level": 2,
    "style": "casual",
    "formality_level": 2,
    "image_url": "https://example.com/image.jpg",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

#### DELETE /api/v1/wardrobe/{item_id}
Remove a wardrobe item

**Response:**
```json
{
  "success": true
}
```

### Recommendations

#### GET /api/v1/recommendations
Get recommendation history

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20, max: 100)

**Response:**
```json
{
  "recommendations": [
    {
      "id": "rec_id",
      "items": ["item_id_1", "item_id_2"],
      "score": 0.95,
      "reason": "Perfect for sunny weather",
      "occasion": "daily",
      "weather_condition": "sunny",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 5,
  "page": 1,
  "limit": 20
}
```

#### POST /api/v1/recommendations
Generate new recommendations

**Request Body:**
```json
{
  "occasion": "daily",
  "latitude": 55.7558,
  "longitude": 37.6176
}
```

**Response:**
```json
{
  "recommendation": {
    "id": "rec_id",
    "items": ["item_id_1", "item_id_2"],
    "score": 0.95,
    "reason": "Perfect for sunny weather",
    "occasion": "daily",
    "weather_condition": "sunny",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### User Preferences

#### GET /api/v1/preferences
Get user preferences

**Response:**
```json
{
  "preferences": {
    "preferred_styles": ["casual", "smart casual"],
    "avoid_styles": ["formal"],
    "color_preferences": ["blue", "black"],
    "avoid_colors": ["orange"],
    "preferred_categories": ["top", "bottom"],
    "temperature_sensitivity": 2
  }
}
```

#### PUT /api/v1/preferences
Update user preferences

**Request Body:**
```json
{
  "preferred_styles": ["casual", "smart casual"],
  "avoid_styles": ["formal"],
  "color_preferences": ["blue", "black"],
  "avoid_colors": ["orange"],
  "preferred_categories": ["top", "bottom"],
  "temperature_sensitivity": 2
}
```

**Response:**
```json
{
  "preferences": {
    "preferred_styles": ["casual", "smart casual"],
    "avoid_styles": ["formal"],
    "color_preferences": ["blue", "black"],
    "avoid_colors": ["orange"],
    "preferred_categories": ["top", "bottom"],
    "temperature_sensitivity": 2
  }
}
```

## Error Responses

All error responses follow this format:

```json
{
  "error": "error_message",
  "details": "detailed_error_description"
}
```

### Common HTTP Status Codes

- `200 OK` - Request successful
- `400 Bad Request` - Invalid request format
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Access denied
- `404 Not Found` - Resource not found
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

## Rate Limiting

All authenticated endpoints have rate limiting:
- 100 requests per minute per user
- 1000 requests per minute per IP (unauthenticated)

## Health Check

#### GET /health
Check service health

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00Z",
  "checks": {
    "database": {
      "status": "healthy",
      "latency": "10ms"
    },
    "ml_service": {
      "status": "healthy",
      "latency": "50ms"
    }
  }
}
```

#### GET /ready
Check service readiness for traffic

**Response:**
```json
{
  "status": "ready",
  "ready": true
}
```

## Metrics

#### GET /metrics
Prometheus metrics endpoint

Returns metrics in Prometheus format for monitoring and alerting.