package domain

import "time"

type UserStylePreferences struct {
	ID                 ID        `json:"id"`
	UserID             ID        `json:"user_id"`
	PreferredStyles    []string  `json:"preferred_styles"`
	DislikedStyles     []string  `json:"disliked_styles"`
	PreferredColors    []string  `json:"preferred_colors"`
	DislikedColors     []string  `json:"disliked_colors"`
	PreferredBrands    []string  `json:"preferred_brands"`
	DislikedBrands     []string  `json:"disliked_brands"`
	MaxPrice           *float64  `json:"max_price,omitempty"`
	MinQualityRating   *float64  `json:"min_quality_rating,omitempty"`
	PreferredFit       *string   `json:"preferred_fit,omitempty"`
	PreferredMaterials []string  `json:"preferred_materials"`
	CreatedAt          time.Time `json:"created_at"`
	UpdatedAt          time.Time `json:"updated_at"`
}

type UserWeatherPreferences struct {
	ID                     ID        `json:"id"`
	UserID                 ID        `json:"user_id"`
	PreferredTemperature   *float64  `json:"preferred_temperature,omitempty"`
	TemperatureSensitivity int       `json:"temperature_sensitivity"`     // -2 to 2: cold, slightly cold, neutral, slightly warm, warm
	PreferredWeather       []string  `json:"preferred_weather,omitempty"` // clear, clouds, rain, snow, etc.
	MaxWindSpeed           *float64  `json:"max_wind_speed,omitempty"`
	MaxHumidity            *float64  `json:"max_humidity,omitempty"`
	CreatedAt              time.Time `json:"created_at"`
	UpdatedAt              time.Time `json:"updated_at"`
}
