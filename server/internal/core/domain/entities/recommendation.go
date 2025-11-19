package entities

import (
	"time"
)

// WeatherData represents weather information
type WeatherData struct {
	Location       string          `json:"location"`
	Temperature    float64         `json:"temperature"`
	FeelsLike      float64         `json:"feels_like"`
	Weather        string          `json:"weather"`
	Humidity       int             `json:"humidity"`
	WindSpeed      float64         `json:"wind_speed"`
	MinTemp        float64         `json:"min_temp"`
	MaxTemp        float64         `json:"max_temp"`
	WillRain       bool            `json:"will_rain"`
	WillSnow       bool            `json:"will_snow"`
	HourlyForecast []HourlyWeather `json:"hourly_forecast"`
}

// HourlyWeather represents hourly weather forecast
type HourlyWeather struct {
	Time            string  `json:"time"`
	Temperature     float64 `json:"temperature"`
	Weather         string  `json:"weather"`
	RainProbability float64 `json:"rain_probability"`
}

// ClothingItem represents a clothing item in a recommendation
type ClothingItem struct {
	ID                 int64   `json:"id"`
	UserID             int64   `json:"user_id"`
	Name               string  `json:"name"`
	Category           string  `json:"category"`
	Subcategory        string  `json:"subcategory,omitempty"`
	IconEmoji          string  `json:"icon_emoji"`
	MLScore            float64 `json:"ml_score,omitempty"`
	Confidence         float64 `json:"confidence,omitempty"`
	WeatherSuitability string  `json:"weather_suitability,omitempty"`
}

// Recommendation represents an outfit recommendation
type Recommendation struct {
	ID             int64          `json:"id"`
	UserID         int64          `json:"user_id"`
	Location       string         `json:"location"`
	Temperature    float64        `json:"temperature"`
	FeelsLike      float64        `json:"feels_like"`
	Weather        string         `json:"weather"`
	Humidity       int            `json:"humidity"`
	WindSpeed      float64        `json:"wind_speed"`
	MinTemp        float64        `json:"min_temp"`
	MaxTemp        float64        `json:"max_temp"`
	WillRain       bool           `json:"will_rain"`
	WillSnow       bool           `json:"will_snow"`
	HourlyForecast []HourlyWeather `json:"hourly_forecast"`
	Items          []ClothingItem `json:"items"`
	OutfitScore    float64        `json:"outfit_score"`
	MLPowered      bool           `json:"ml_powered"`
	Algorithm      string         `json:"algorithm"`
	Message        string         `json:"message"`
	Timestamp      time.Time      `json:"timestamp"`
}

// UserRating represents a user's rating for a recommendation
type UserRating struct {
	ID              int64     `json:"id"`
	UserID          int64     `json:"user_id"`
	RecommendationID int64    `json:"recommendation_id"`
	Rating          int       `json:"rating"`
	Feedback        string    `json:"feedback,omitempty"`
	CreatedAt       time.Time `json:"created_at"`
}

// FavoriteOutfit represents a user's favorite outfit recommendation
type FavoriteOutfit struct {
	ID              int64     `json:"id"`
	UserID          int64     `json:"user_id"`
	RecommendationID int64    `json:"recommendation_id"`
	CreatedAt       time.Time `json:"created_at"`
}

// Achievement represents a user achievement
type Achievement struct {
	ID          int64     `json:"id"`
	Code        string    `json:"code"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Icon        string    `json:"icon"`
	CreatedAt   time.Time `json:"created_at"`
}

// UserAchievement represents a user's unlocked achievement
type UserAchievement struct {
	ID           int64     `json:"id"`
	UserID       int64     `json:"user_id"`
	AchievementID int64    `json:"achievement_id"`
	UnlockedAt   time.Time `json:"unlocked_at"`
}

// OutfitPlan represents a planned outfit for a specific date
type OutfitPlan struct {
	ID        int64     `json:"id"`
	UserID    int64     `json:"user_id"`
	Date      time.Time `json:"date"`
	ItemIDs   []int     `json:"item_ids"`
	Notes     string    `json:"notes,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// MarketItem represents an item from a marketplace
type MarketItem struct {
	ID           int64   `json:"id"`
	Name         string  `json:"name"`
	Price        float64 `json:"price"`
	Currency     string  `json:"currency"`
	Brand        string  `json:"brand"`
	Category     string  `json:"category"`
	ImageURL     string  `json:"image_url"`
	ProductURL   string  `json:"product_url"`
	AffiliateURL string  `json:"affiliate_url,omitempty"`
	Commission   float64 `json:"commission,omitempty"`
}

// MarketplaceMatch represents a match between a clothing item and marketplace items
type MarketplaceMatch struct {
	ClothingItem ClothingItem `json:"clothing_item"`
	Matches      []MarketItem `json:"matches"`
	Confidence   float64      `json:"confidence"`
}

// UserStats represents user statistics
type UserStats struct {
	TotalRecommendations int       `json:"total_recommendations"`
	AverageRating        float64   `json:"average_rating"`
	FavoriteCount        int       `json:"favorite_count"`
	AchievementCount     int       `json:"achievement_count"`
	LastActive           time.Time `json:"last_active"`
	MostUsedCategory     string    `json:"most_used_category"`
}