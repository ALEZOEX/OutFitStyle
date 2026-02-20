"""
Pytest configuration and fixtures for ML Service tests
"""
import pytest
import sys
import os
from unittest.mock import Mock, MagicMock, patch
import pandas as pd
import numpy as np

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


@pytest.fixture(scope="session")
def sample_weather_data():
    """Sample weather data for tests"""
    return {
        "temperature": 20.0,
        "feels_like": 19.0,
        "humidity": 60,
        "wind_speed": 3.0,
        "weather": "clear"
    }


@pytest.fixture(scope="session")
def sample_user_profile():
    """Sample user profile for tests"""
    return {
        "age_range": "25-35",
        "style_preference": "casual",
        "temperature_sensitivity": "normal",
        "formality_preference": "casual",
        "gender": "unisex"
    }


@pytest.fixture(scope="session")
def sample_clothing_item():
    """Sample clothing item for tests"""
    return {
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


@pytest.fixture(scope="session")
def sample_feature_dataframe():
    """Sample feature DataFrame for tests"""
    return pd.DataFrame({
        'temperature': [20.0, 25.0, 15.0],
        'feels_like': [19.0, 24.0, 14.0],
        'humidity': [60, 65, 70],
        'wind_speed': [3.0, 2.5, 4.0],
        'category': ['upper', 'lower', 'outerwear'],
        'style': ['casual', 'sporty', 'casual'],
        'formality_level': [2, 3, 4],
        'warmth_level': [3, 5, 8],
        'min_temp': [15, 10, 5],
        'max_temp': [25, 20, 15],
        'base_colour': ['white', 'black', 'navy'],
        'pattern': ['solid', 'striped', 'solid'],
    })


@pytest.fixture
def mock_catboost_model():
    """Mock CatBoost model for tests"""
    mock_model = MagicMock()
    mock_model.predict_proba.return_value = np.array([[0.2, 0.8], [0.3, 0.7], [0.1, 0.9]])
    mock_model.predict.return_value = [0.8, 0.7, 0.9]
    return mock_model


@pytest.fixture
def mock_manifest():
    """Mock model manifest for tests"""
    return {
        "format": "catboost_cbm",
        "model_kind": "classifier",
        "version": "test-1.0.0",
        "cat_features": ["category", "style", "pattern"],
        "feature_columns": [
            "temperature", "feels_like", "humidity", "wind_speed",
            "category", "style", "formality_level", "warmth_level"
        ],
        "cbm_path": "model.cbm"
    }


@pytest.fixture
def temp_model_files(tmp_path, mock_manifest):
    """Create temporary model files for tests"""
    import pickle
    
    # Create manifest file
    manifest_path = tmp_path / "model.pkl"
    with open(manifest_path, "wb") as f:
        pickle.dump(mock_manifest, f)
    
    # Create dummy CBM file
    cbm_path = tmp_path / "model.cbm"
    cbm_path.write_text("dummy model content")
    
    return {
        "manifest": manifest_path,
        "cbm": cbm_path,
        "dir": tmp_path
    }


@pytest.fixture
def ranking_request(sample_weather_data, sample_user_profile, sample_clothing_item):
    """Create a sample ranking request"""
    from contracts.rank_contract import (
        MLRankRequest, MLContext, WeatherData, UserProfile, MLItem, SourceType
    )
    
    weather = WeatherData(**sample_weather_data)
    profile = UserProfile(**sample_user_profile)
    context = MLContext(
        weather=weather,
        user_profile=profile,
        preferences={},
        location="Moscow"
    )
    candidate = MLItem(**sample_clothing_item)
    
    return MLRankRequest(context=context, candidates=[candidate])


@pytest.fixture
def mock_redis():
    """Mock Redis client for tests"""
    mock = MagicMock()
    mock.ping.return_value = True
    mock.set.return_value = True
    mock.get.return_value = None
    return mock


@pytest.fixture
def mock_http_client():
    """Mock HTTP client for tests"""
    mock = MagicMock()
    mock.get.return_value.status_code = 200
    mock.post.return_value.status_code = 200
    return mock
