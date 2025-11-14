package models

import (
	"database/sql"
	"time"
)

// WeatherData - погодные данные
type WeatherData struct {
	Location    string  `json:"location"`
	Temperature float64 `json:"temperature"`
	FeelsLike   float64 `json:"feels_like"`
	Weather     string  `json:"weather"`
	Humidity    int     `json:"humidity"`
	WindSpeed   float64 `json:"wind_speed"`
}

// ClothingItem - предмет одежды
type ClothingItem struct {
	ID          int      `json:"id"`
	Name        string   `json:"name"`
	Category    string   `json:"category"`
	Subcategory string   `json:"subcategory,omitempty"`
	MinTemp     *float64 `json:"min_temp,omitempty"`
	MaxTemp     *float64 `json:"max_temp,omitempty"`
	Style       string   `json:"style,omitempty"`
	WarmthLevel *int     `json:"warmth_level,omitempty"`
	IconEmoji   string   `json:"icon_emoji"`
	Score       *float64 `json:"ml_score,omitempty"`
}

// Recommendation - рекомендация для API ответа
type Recommendation struct {
	Location    string         `json:"location"`
	Temperature float64        `json:"temperature"`
	Weather     string         `json:"weather"`
	Message     string         `json:"message"`
	Items       []ClothingItem `json:"items"`
	Humidity    int            `json:"humidity"`
	WindSpeed   float64        `json:"wind_speed"`
	MLPowered   bool           `json:"ml_powered"`
	OutfitScore *float64       `json:"outfit_score,omitempty"`
	Algorithm   string         `json:"algorithm,omitempty"`
}

// RecommendationDB - рекомендация из БД
type RecommendationDB struct {
	ID               int            `json:"id"`
	UserID           int            `json:"user_id"`
	Location         string         `json:"location"`
	Temperature      float64        `json:"temperature"`
	FeelsLike        float64        `json:"feels_like"`
	Weather          string         `json:"weather"`
	Humidity         int            `json:"humidity"`
	WindSpeed        float64        `json:"wind_speed"`
	Items            []ClothingItem `json:"items"`
	AlgorithmVersion string         `json:"algorithm_version"`
	MLConfidence     *float64       `json:"ml_confidence,omitempty"`
	CreatedAt        time.Time      `json:"created_at"`
}

// User - пользователь
type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"`
	Name      string    `json:"name"`
	CreatedAt time.Time `json:"created_at"`
}

// UserProfile - профиль пользователя
type UserProfile struct {
	ID                     int            `json:"id"`
	UserID                 int            `json:"user_id"`
	Gender                 sql.NullString `json:"gender,omitempty"`
	AgeRange               sql.NullString `json:"age_range,omitempty"`
	StylePreference        sql.NullString `json:"style_preference,omitempty"`
	TemperatureSensitivity sql.NullString `json:"temperature_sensitivity,omitempty"`
	PreferredCategories    interface{}    `json:"preferred_categories,omitempty"` // PostgreSQL array
}

// UserStats - статистика пользователя
type UserStats struct {
	UserID               int      `json:"user_id"`
	TotalRecommendations int      `json:"total_recommendations"`
	TotalRatings         int      `json:"total_ratings"`
	AverageRating        float64  `json:"average_rating"`
	FavoriteCategories   []string `json:"favorite_categories"`
}

// Rating - оценка рекомендации
type Rating struct {
	ID                 int       `json:"id"`
	UserID             int       `json:"user_id"`
	RecommendationID   int       `json:"recommendation_id"`
	ClothingItemID     *int      `json:"clothing_item_id,omitempty"`
	OverallRating      int       `json:"overall_rating"`
	ComfortRating      *int      `json:"comfort_rating,omitempty"`
	StyleRating        *int      `json:"style_rating,omitempty"`
	WeatherMatchRating *int      `json:"weather_match_rating,omitempty"`
	TooWarm            bool      `json:"too_warm"`
	TooCold            bool      `json:"too_cold"`
	Comment            string    `json:"comment,omitempty"`
	CreatedAt          time.Time `json:"created_at"`
}