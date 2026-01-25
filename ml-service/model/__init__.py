"""
ML Model Package for OutfitStyle

This package contains the core ML components for outfit recommendation:
- EnhancedPredictor: Main prediction interface
- Feature building utilities: Functions to prepare model inputs
- Internal schema: Canonical data structures
"""

from .enhanced_predictor import EnhancedPredictor
from .features_with_priorities import (
    build_feature_frame,
    build_feature_rows,
    prepare_weather_features,
    prepare_user_features,
    prepare_item_features
)
from .internal_schema import (
    InternalItem,
    InternalRequest,
    InternalContext,
    InternalWeatherData,
    InternalUserProfile
)

__all__ = [
    'EnhancedPredictor',
    'build_feature_frame',
    'build_feature_rows',
    'prepare_weather_features',
    'prepare_user_features',
    'prepare_item_features',
    'InternalItem',
    'InternalRequest',
    'InternalContext',
    'InternalWeatherData',
    'InternalUserProfile'
]