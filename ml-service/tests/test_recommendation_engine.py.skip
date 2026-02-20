import pytest
from unittest.mock import Mock, patch, AsyncMock
import numpy as np
import pandas as pd

from app.services.recommendation_engine import RecommendationEngine
from app.models.schemas import WardrobeItem, Weather, RecommendationRequest
from app.exceptions import InsufficientDataError


@pytest.fixture
def sample_wardrobe():
    return [
        WardrobeItem(
            id="item-1",
            category="top",
            color="blue",
            warmth_level=3,
            style="casual",
            occasions=["daily", "work"]
        ),
        WardrobeItem(
            id="item-2",
            category="bottom",
            color="black",
            warmth_level=3,
            style="casual",
            occasions=["daily", "work"]
        ),
        WardrobeItem(
            id="item-3",
            category="shoes",
            color="white",
            warmth_level=2,
            style="casual",
            occasions=["daily"]
        ),
    ]


@pytest.fixture
def sample_weather():
    return Weather(
        temperature=15.0,
        feels_like=13.0,
        humidity=60,
        condition="cloudy",
        wind_speed=5.0,
        precipitation_probability=20
    )


@pytest.fixture
def recommendation_engine():
    return RecommendationEngine()


class TestRecommendationEngine:
    
    def test_calculate_outfit_score_perfect_match(
        self, 
        recommendation_engine, 
        sample_wardrobe, 
        sample_weather
    ):
        """Test scoring for a well-matched outfit"""
        outfit = [sample_wardrobe[0], sample_wardrobe[1], sample_wardrobe[2]]
        
        score = recommendation_engine.calculate_outfit_score(
            outfit=outfit,
            weather=sample_weather,
            occasion="daily",
            user_preferences={"preferred_colors": ["blue", "black"]}
        )
        
        assert 0.0 <= score <= 1.0
        assert score >= 0.7  # Should be a good match
    
    def test_calculate_outfit_score_temperature_mismatch(
        self, 
        recommendation_engine, 
        sample_wardrobe
    ):
        """Test that cold weather penalizes light clothing"""
        cold_weather = Weather(
            temperature=-10.0,
            feels_like=-15.0,
            humidity=40,
            condition="snow",
            wind_speed=10.0,
            precipitation_probability=80
        )
        
        # Light outfit for cold weather
        outfit = [sample_wardrobe[0], sample_wardrobe[1], sample_wardrobe[2]]
        
        score = recommendation_engine.calculate_outfit_score(
            outfit=outfit,
            weather=cold_weather,
            occasion="daily",
            user_preferences={}
        )
        
        assert score < 0.5  # Should be a poor match
    
    def test_filter_by_occasion(self, recommendation_engine, sample_wardrobe):
        """Test filtering items by occasion"""
        filtered = recommendation_engine.filter_by_occasion(
            items=sample_wardrobe,
            occasion="work"
        )
        
        assert len(filtered) == 2  # Top and bottom have "work" occasion
        item_ids = [item.id for item in filtered]
        assert "item-1" in item_ids
        assert "item-2" in item_ids
        assert "item-3" not in item_ids  # Shoes don't have "work" occasion
    
    def test_color_compatibility(self, recommendation_engine):
        """Test color matching logic"""
        compatible_pairs = [
            ("blue", "white"),
            ("black", "white"),
            ("gray", "blue"),
        ]
        
        incompatible_pairs = [
            ("red", "orange"),
            ("green", "blue"),
        ]
        
        for color1, color2 in compatible_pairs:
            score = recommendation_engine.color_compatibility_score(color1, color2)
            assert score >= 0.6, f"{color1} and {color2} should be compatible"
        
        for color1, color2 in incompatible_pairs:
            score = recommendation_engine.color_compatibility_score(color1, color2)
            assert score < 0.6, f"{color1} and {color2} should be less compatible"
    
    def test_warmth_recommendation(self, recommendation_engine):
        """Test warmth level calculation based on temperature"""
        test_cases = [
            (-20, 5),  # Very cold
            (-5, 4),   # Cold
            (5, 3),    # Cool
            (15, 2),   # Mild
            (25, 1),   # Warm
            (35, 0),   # Hot
        ]
        
        for temperature, expected_warmth in test_cases:
            result = recommendation_engine.recommend_warmth_level(temperature)
            assert result == expected_warmth, \
                f"Temperature {temperature}°C should recommend warmth level {expected_warmth}"


@pytest.mark.asyncio
class TestRecommendationEngineAsync:
    
    async def test_generate_recommendations_success(
        self, 
        recommendation_engine,
        sample_wardrobe,
        sample_weather
    ):
        """Test full recommendation generation"""
        request = RecommendationRequest(
            user_id="user-123",
            wardrobe=sample_wardrobe,
            weather=sample_weather,
            occasion="daily",
            max_recommendations=3
        )
        
        recommendations = await recommendation_engine.generate_recommendations(request)
        
        assert len(recommendations) <= 3
        assert all(rec.score >= 0 for rec in recommendations)
        assert all(len(rec.items) >= 2 for rec in recommendations)
    
    async def test_generate_recommendations_insufficient_items(
        self, 
        recommendation_engine,
        sample_weather
    ):
        """Test error when wardrobe is too small"""
        request = RecommendationRequest(
            user_id="user-123",
            wardrobe=[],  # Empty wardrobe
            weather=sample_weather,
            occasion="daily",
            max_recommendations=3
        )
        
        with pytest.raises(InsufficientDataError):
            await recommendation_engine.generate_recommendations(request)


@pytest.mark.parametrize("temperature,condition,expected_outerwear", [
    (-15, "snow", True),
    (0, "rain", True),
    (10, "cloudy", True),
    (25, "sunny", False),
    (35, "clear", False),
])
def test_outerwear_recommendation(
    recommendation_engine,
    temperature,
    condition,
    expected_outerwear
):
    """Test outerwear recommendation based on weather"""
    weather = Weather(
        temperature=temperature,
        feels_like=temperature - 2,
        humidity=50,
        condition=condition,
        wind_speed=5.0,
        precipitation_probability=0
    )
    
    needs_outerwear = recommendation_engine.should_include_outerwear(weather)
    assert needs_outerwear == expected_outerwear