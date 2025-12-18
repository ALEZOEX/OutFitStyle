package domain

import "time"

type UserStats struct {
	UserID ID `json:"user_id"`

	RecommendationsCount int `json:"recommendations_count"`
	WardrobeSize         int `json:"wardrobe_size"`

	CurrentStreak int `json:"current_streak"`
	MaxStreak     int `json:"max_streak"`
	LastActiveDate *time.Time `json:"last_active_date,omitempty"`

	PerfectRatingsCount int      `json:"perfect_ratings_count"`
	WeatherTypesSeen    []string `json:"weather_types_seen"`
	StylesUsed          []string `json:"styles_used"`

	TotalPoints int `json:"total_points"`
}