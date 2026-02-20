"""
Tests for ML Service contracts (Pydantic schemas)
"""
import pytest
from datetime import datetime
from contracts.rank_contract import (
    MLItem, MLContext, WeatherData, UserProfile,
    MLRankRequest, MLRankResponse, RankedItem, SourceType
)


class TestWeatherData:
    """Tests for WeatherData schema"""

    def test_valid_weather(self):
        weather = WeatherData(
            temperature=20.5,
            feels_like=19.0,
            humidity=65,
            wind_speed=3.2,
            weather="clear"
        )
        assert weather.temperature == 20.5
        assert weather.feels_like == 19.0
        assert weather.humidity == 65
        assert weather.wind_speed == 3.2
        assert weather.weather == "clear"

    def test_negative_temperature(self):
        weather = WeatherData(
            temperature=-10.5,
            feels_like=-15.0,
            humidity=80,
            wind_speed=5.0,
            weather="snow"
        )
        assert weather.temperature == -10.5

    def test_invalid_humidity_type(self):
        with pytest.raises(ValueError):
            WeatherData(
                temperature=20.0,
                feels_like=19.0,
                humidity="high",  # Should be int
                wind_speed=3.0,
                weather="clear"
            )


class TestUserProfile:
    """Tests for UserProfile schema"""

    def test_valid_profile(self):
        profile = UserProfile(
            age_range="25-35",
            style_preference="casual",
            temperature_sensitivity="normal",
            formality_preference="business",
            gender="unisex"
        )
        assert profile.age_range == "25-35"
        assert profile.style_preference == "casual"

    def test_empty_profile(self):
        with pytest.raises(ValueError):
            UserProfile()


class TestMLItem:
    """Tests for MLItem schema"""

    def test_valid_item(self):
        item = MLItem(
            id=1,
            name="T-Shirt",
            category="upper",
            subcategory="tshirt",
            gender="unisex",
            style="casual",
            usage="daily",
            season="all",
            base_colour="white",
            formality=2,
            warmth=3,
            min_temp=15,
            max_temp=25,
            materials=["cotton"],
            fit="regular",
            pattern="solid",
            icon_emoji="👕",
            source=SourceType.USER,
            is_owned=True,
            created_at="2024-01-01T00:00:00Z",
            source_priority=1
        )
        assert item.id == 1
        assert item.category == "upper"
        assert item.formality == 2
        assert item.warmth == 3
        assert item.source == SourceType.USER

    def test_formality_out_of_range(self):
        with pytest.raises(ValueError):
            MLItem(
                id=1,
                name="Test",
                category="upper",
                subcategory="tshirt",
                gender="unisex",
                style="casual",
                usage="daily",
                season="all",
                base_colour="white",
                formality=6,  # Should be 1-5
                warmth=3,
                min_temp=15,
                max_temp=25,
                materials=["cotton"],
                fit="regular",
                pattern="solid",
                icon_emoji="👕",
                source=SourceType.USER,
                is_owned=True,
                created_at="2024-01-01T00:00:00Z",
                source_priority=1
            )

    def test_warmth_out_of_range(self):
        with pytest.raises(ValueError):
            MLItem(
                id=1,
                name="Test",
                category="upper",
                subcategory="tshirt",
                gender="unisex",
                style="casual",
                usage="daily",
                season="all",
                base_colour="white",
                formality=2,
                warmth=11,  # Should be 1-10
                min_temp=15,
                max_temp=25,
                materials=["cotton"],
                fit="regular",
                pattern="solid",
                icon_emoji="👕",
                source=SourceType.USER,
                is_owned=True,
                created_at="2024-01-01T00:00:00Z",
                source_priority=1
            )

    def test_source_priority_range(self):
        # Valid source_priority (0-3)
        item = MLItem(
            id=1,
            name="Test",
            category="upper",
            subcategory="tshirt",
            gender="unisex",
            style="casual",
            usage="daily",
            season="all",
            base_colour="white",
            formality=2,
            warmth=3,
            min_temp=15,
            max_temp=25,
            materials=["cotton"],
            fit="regular",
            pattern="solid",
            icon_emoji="👕",
            source=SourceType.USER,
            is_owned=True,
            created_at="2024-01-01T00:00:00Z",
            source_priority=3  # Maximum valid value
        )
        assert item.source_priority == 3


class TestMLContext:
    """Tests for MLContext schema"""

    def test_valid_context(self):
        weather = WeatherData(
            temperature=20.0,
            feels_like=19.0,
            humidity=60,
            wind_speed=3.0,
            weather="clear"
        )
        profile = UserProfile(
            age_range="25-35",
            style_preference="casual",
            temperature_sensitivity="normal",
            formality_preference="casual",
            gender="unisex"
        )
        context = MLContext(
            weather=weather,
            user_profile=profile,
            preferences={"occasion": "daily"},
            location="Moscow"
        )
        assert context.location == "Moscow"
        assert context.weather.temperature == 20.0


class TestMLRankRequest:
    """Tests for MLRankRequest schema"""

    def test_valid_request(self):
        weather = WeatherData(
            temperature=20.0,
            feels_like=19.0,
            humidity=60,
            wind_speed=3.0,
            weather="clear"
        )
        profile = UserProfile(
            age_range="25-35",
            style_preference="casual",
            temperature_sensitivity="normal",
            formality_preference="casual",
            gender="unisex"
        )
        context = MLContext(
            weather=weather,
            user_profile=profile,
            preferences={},
            location="Moscow"
        )
        candidate = MLItem(
            id=1,
            name="T-Shirt",
            category="upper",
            subcategory="tshirt",
            gender="unisex",
            style="casual",
            usage="daily",
            season="all",
            base_colour="white",
            formality=2,
            warmth=3,
            min_temp=15,
            max_temp=25,
            materials=["cotton"],
            fit="regular",
            pattern="solid",
            icon_emoji="👕",
            source=SourceType.USER,
            is_owned=True,
            created_at="2024-01-01T00:00:00Z",
            source_priority=1
        )
        request = MLRankRequest(
            context=context,
            candidates=[candidate]
        )
        assert len(request.candidates) == 1

    def test_too_many_candidates(self):
        weather = WeatherData(
            temperature=20.0,
            feels_like=19.0,
            humidity=60,
            wind_speed=3.0,
            weather="clear"
        )
        profile = UserProfile(
            age_range="25-35",
            style_preference="casual",
            temperature_sensitivity="normal",
            formality_preference="casual",
            gender="unisex"
        )
        context = MLContext(
            weather=weather,
            user_profile=profile,
            preferences={},
            location="Moscow"
        )

        # Create 251 candidates (exceeds limit)
        candidates = []
        for i in range(251):
            candidates.append(MLItem(
                id=i,
                name=f"Item {i}",
                category="upper",
                subcategory="tshirt",
                gender="unisex",
                style="casual",
                usage="daily",
                season="all",
                base_colour="white",
                formality=2,
                warmth=3,
                min_temp=15,
                max_temp=25,
                materials=["cotton"],
                fit="regular",
                pattern="solid",
                icon_emoji="👕",
                source=SourceType.USER,
                is_owned=True,
                created_at="2024-01-01T00:00:00Z",
                source_priority=1
            ))

        with pytest.raises(ValueError):
            MLRankRequest(context=context, candidates=candidates)


class TestMLRankResponse:
    """Tests for MLRankResponse schema"""

    def test_valid_response(self):
        ranked_item = RankedItem(id=1, score=0.95)
        response = MLRankResponse(
            ranked=[ranked_item],
            model_version="1.0.0",
            processing_time_ms=150.5
        )
        assert len(response.ranked) == 1
        assert response.model_version == "1.0.0"
        assert response.processing_time_ms == 150.5

    def test_response_with_error(self):
        response = MLRankResponse(
            ranked=[],
            model_version="1.0.0",
            processing_time_ms=10.0,
            error="Model not loaded"
        )
        assert response.error == "Model not loaded"

    def test_multiple_ranked_items(self):
        ranked_items = [
            RankedItem(id=i, score=0.9 - i * 0.1)
            for i in range(5)
        ]
        response = MLRankResponse(
            ranked=ranked_items,
            model_version="1.0.0",
            processing_time_ms=200.0
        )
        assert len(response.ranked) == 5
        assert response.ranked[0].score > response.ranked[4].score


class TestSourceType:
    """Tests for SourceType enum"""

    def test_source_types(self):
        assert SourceType.SYNTHETIC.value == "synthetic"
        assert SourceType.USER.value == "user"
        assert SourceType.PARTNER.value == "partner"
        assert SourceType.MANUAL.value == "manual"

    def test_source_type_from_string(self):
        source = SourceType("user")
        assert source == SourceType.USER
