package domain

import (
	"encoding/json"
	"time"
)

// RecommendationRecord — то, что мы храним в таблице recommendations по ТЗ.
type RecommendationRecord struct {
	ID     ID `json:"id"`
	UserID ID `json:"user_id"`

	Location  *string  `json:"location,omitempty"`
	Latitude  *float64 `json:"latitude,omitempty"`
	Longitude *float64 `json:"longitude,omitempty"`

	Occasion          *string `json:"occasion,omitempty"`
	RequestedStyle    *string `json:"requested_style,omitempty"`
	RequestedFormality *int   `json:"requested_formality,omitempty"`

	WeatherData json.RawMessage `json:"weather_data"`
	OutfitData  json.RawMessage `json:"outfit_data"`

	TotalScore      *float64 `json:"total_score,omitempty"`
	StyleCoherence  *float64 `json:"style_coherence,omitempty"`
	ColorHarmony    *float64 `json:"color_harmony,omitempty"`
	WeatherMatch    *float64 `json:"weather_match,omitempty"`

	ModelVersion      *string `json:"model_version,omitempty"`
	ProcessingTimeMs  *int    `json:"processing_time_ms,omitempty"`
	ABTestVariant     *string `json:"ab_test_variant,omitempty"`

	UserRating      *int       `json:"user_rating,omitempty"`
	UserFeedback    *string    `json:"user_feedback,omitempty"`
	ThermalFeedback *string    `json:"thermal_feedback,omitempty"`
	RatedAt         *time.Time `json:"rated_at,omitempty"`

	IsFavorite bool      `json:"is_favorite"`
	CreatedAt  time.Time `json:"created_at"`
}