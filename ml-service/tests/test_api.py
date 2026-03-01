"""
Tests for ML Service API endpoints
"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch, MagicMock
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


@pytest.fixture
def mock_predictor():
    """Create a mock predictor for testing"""
    mock = Mock()
    mock.get_model_version.return_value = "test-1.0.0"
    mock.predict.return_value = [0.85, 0.75, 0.90]
    return mock


@pytest.fixture
def client(mock_predictor):
    """Create test client with mocked predictor"""
    with patch('api.main.predictor', mock_predictor):
        from api.main import app
        with TestClient(app) as client:
            yield client


class TestHealthEndpoints:
    """Tests for health check endpoints"""

    def test_health_check(self, mock_predictor):
        """Test health endpoint"""
        with patch('api.main.predictor', mock_predictor):
            from api.main import app
            with TestClient(app) as client:
                response = client.get("/health")
                assert response.status_code == 200
                data = response.json()
                assert data["status"] == "healthy"
                assert "model_loaded" in data

    def test_readiness_check(self, mock_predictor):
        """Test readiness endpoint"""
        with patch('api.main.predictor', mock_predictor):
            from api.main import app
            with TestClient(app) as client:
                response = client.get("/ready")
                assert response.status_code == 200
                data = response.json()
                assert data["status"] == "ready"

    def test_readiness_check_model_not_loaded(self):
        """Test readiness endpoint when model not loaded"""
        with patch('api.main.predictor', None):
            from api.main import app
            with TestClient(app) as client:
                response = client.get("/ready")
                assert response.status_code == 503


class TestRankEndpoint:
    """Tests for /api/rank endpoint"""

    def test_rank_success(self, mock_predictor):
        """Test successful ranking request"""
        request_data = {
            "context": {
                "weather": {
                    "temperature": 20.0,
                    "feels_like": 19.0,
                    "humidity": 60,
                    "wind_speed": 3.0,
                    "weather": "clear"
                },
                "user_profile": {
                    "age_range": "25-35",
                    "style_preference": "casual",
                    "temperature_sensitivity": "normal",
                    "formality_preference": "casual",
                    "gender": "unisex"
                },
                "preferences": {},
                "location": "Moscow"
            },
            "candidates": [
                {
                    "id": 1,
                    "name": "T-Shirt",
                    "category": "upper",
                    "subcategory": "tshirt",
                    "gender": "unisex",
                    "style": "casual",
                    "usage": "daily",
                    "season": "all",
                    "base_colour": "white",
                    "formality": 2,
                    "warmth": 3,
                    "min_temp": 15,
                    "max_temp": 25,
                    "materials": ["cotton"],
                    "fit": "regular",
                    "pattern": "solid",
                    "icon_emoji": "👕",
                    "source": "user",
                    "is_owned": True,
                    "created_at": "2024-01-01T00:00:00Z",
                    "source_priority": 1
                }
            ]
        }

        with patch('api.main.predictor', mock_predictor):
            from api.main import app
            with TestClient(app) as client:
                response = client.post("/api/rank", json=request_data)
                assert response.status_code == 200
                data = response.json()
                assert "ranked" in data
                assert "model_version" in data
                assert "processing_time_ms" in data

    def test_rank_empty_candidates(self, mock_predictor):
        """Test ranking with empty candidates list"""
        request_data = {
            "context": {
                "weather": {
                    "temperature": 20.0,
                    "feels_like": 19.0,
                    "humidity": 60,
                    "wind_speed": 3.0,
                    "weather": "clear"
                },
                "user_profile": {
                    "age_range": "25-35",
                    "style_preference": "casual",
                    "temperature_sensitivity": "normal",
                    "formality_preference": "casual",
                    "gender": "unisex"
                },
                "preferences": {},
                "location": "Moscow"
            },
            "candidates": []
        }

        with patch('api.main.predictor', mock_predictor):
            from api.main import app
            with TestClient(app) as client:
                response = client.post("/api/rank", json=request_data)
                assert response.status_code == 200
                data = response.json()
                assert data["ranked"] == []

    def test_rank_too_many_candidates(self, mock_predictor):
        """Test ranking with too many candidates"""
        # Create 251 candidates
        candidates = []
        for i in range(251):
            candidates.append({
                "id": i,
                "name": f"Item {i}",
                "category": "upper",
                "subcategory": "tshirt",
                "gender": "unisex",
                "style": "casual",
                "usage": "daily",
                "season": "all",
                "base_colour": "white",
                "formality": 2,
                "warmth": 3,
                "min_temp": 15,
                "max_temp": 25,
                "materials": ["cotton"],
                "fit": "regular",
                "pattern": "solid",
                "icon_emoji": "👕",
                "source": "user",
                "is_owned": True,
                "created_at": "2024-01-01T00:00:00Z",
                "source_priority": 1
            })

        request_data = {
            "context": {
                "weather": {
                    "temperature": 20.0,
                    "feels_like": 19.0,
                    "humidity": 60,
                    "wind_speed": 3.0,
                    "weather": "clear"
                },
                "user_profile": {
                    "age_range": "25-35",
                    "style_preference": "casual",
                    "temperature_sensitivity": "normal",
                    "formality_preference": "casual",
                    "gender": "unisex"
                },
                "preferences": {},
                "location": "Moscow"
            },
            "candidates": candidates
        }

        with patch('api.main.predictor', mock_predictor):
            from api.main import app
            with TestClient(app) as client:
                response = client.post("/api/rank", json=request_data)
                assert response.status_code == 422

    def test_rank_model_not_available(self):
        """Test ranking when model is not available"""
        request_data = {
            "context": {
                "weather": {
                    "temperature": 20.0,
                    "feels_like": 19.0,
                    "humidity": 60,
                    "wind_speed": 3.0,
                    "weather": "clear"
                },
                "user_profile": {
                    "age_range": "25-35",
                    "style_preference": "casual",
                    "temperature_sensitivity": "normal",
                    "formality_preference": "casual",
                    "gender": "unisex"
                },
                "preferences": {},
                "location": "Moscow"
            },
            "candidates": [{"id": 1, "name": "Test", "category": "upper", "subcategory": "tshirt", "gender": "unisex", "style": "casual", "usage": "daily", "season": "all", "base_colour": "white", "formality": 2, "warmth": 3, "min_temp": 15, "max_temp": 25, "materials": ["cotton"], "fit": "regular", "pattern": "solid", "icon_emoji": "👕", "source": "user", "is_owned": True, "created_at": "2024-01-01T00:00:00Z", "source_priority": 1}]
        }

        with patch('api.main.predictor', None):
            from api.main import app
            with TestClient(app) as client:
                response = client.post("/api/rank", json=request_data)
                assert response.status_code == 503


class TestMetricsEndpoint:
    """Tests for /metrics endpoint"""

    def test_metrics(self, mock_predictor):
        """Test metrics endpoint"""
        with patch('api.main.predictor', mock_predictor):
            from api.main import app
            with TestClient(app) as client:
                response = client.get("/metrics")
                assert response.status_code == 200
                data = response.json()
                assert "message" in data


class TestRequestHeaders:
    """Tests for request header handling"""

    def test_x_request_id_header(self, mock_predictor):
        """Test X-Request-Id header is returned"""
        request_data = {
            "context": {
                "weather": {
                    "temperature": 20.0,
                    "feels_like": 19.0,
                    "humidity": 60,
                    "wind_speed": 3.0,
                    "weather": "clear"
                },
                "user_profile": {
                    "age_range": "25-35",
                    "style_preference": "casual",
                    "temperature_sensitivity": "normal",
                    "formality_preference": "casual",
                    "gender": "unisex"
                },
                "preferences": {},
                "location": "Moscow"
            },
            "candidates": [{
                "id": 1,
                "name": "T-Shirt",
                "category": "upper",
                "subcategory": "tshirt",
                "gender": "unisex",
                "style": "casual",
                "usage": "daily",
                "season": "all",
                "base_colour": "white",
                "formality": 2,
                "warmth": 3,
                "min_temp": 15,
                "max_temp": 25,
                "materials": ["cotton"],
                "fit": "regular",
                "pattern": "solid",
                "icon_emoji": "👕",
                "source": "user",
                "is_owned": True,
                "created_at": "2024-01-01T00:00:00Z",
                "source_priority": 1
            }]
        }

        with patch('api.main.predictor', mock_predictor):
            from api.main import app
            with TestClient(app) as client:
                response = client.post(
                    "/api/rank",
                    json=request_data,
                    headers={"X-Request-Id": "test-123"}
                )
                assert response.status_code == 200
                assert response.headers.get("X-Request-Id") == "test-123"
