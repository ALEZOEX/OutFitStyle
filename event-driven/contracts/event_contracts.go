package event_driven

import (
	"time"
)

// RecommendationRequestedEvent представляет событие, когда запрашивается рекомендация
type RecommendationRequestedEvent struct {
	EventID     string                 `json:"event_id"`
	UserID      string                 `json:"user_id"`
	Timestamp   time.Time              `json:"timestamp"`
	Context     RecommendationContext  `json:"context"`
	Candidates  []ItemCandidate        `json:"candidates"`
	RequestID   string                 `json:"request_id"`
}

// RecommendationContext содержит контекстную информацию для рекомендации
type RecommendationContext struct {
	Weather     WeatherData          `json:"weather"`
	UserProfile UserProfile          `json:"user_profile"`
	Preferences map[string]interface{} `json:"preferences"`
	Location    string               `json:"location"`
	SessionID   string               `json:"session_id"`
}

// WeatherData представляет информацию о погоде
type WeatherData struct {
	Temperature  float64 `json:"temperature"`
	FeelsLike    float64 `json:"feels_like"`
	Humidity     int     `json:"humidity"`
	WindSpeed    float64 `json:"wind_speed"`
	Weather      string  `json:"weather"`
}

// UserProfile представляет пользовательские предпочтения
type UserProfile struct {
	AgeRange             string  `json:"age_range"`
	StylePreference      string  `json:"style_preference"`
	TemperatureSensitivity string  `json:"temperature_sensitivity"`
	FormalityPreference  string  `json:"formality_preference"`
	Gender               string  `json:"gender"`
}

// ItemCandidate представляет кандидата на одежду для рекомендации
type ItemCandidate struct {
	ID           string   `json:"id"`
	Name         string   `json:"name"`
	Category     string   `json:"category"`
	Subcategory  string   `json:"subcategory"`
	Gender       string   `json:"gender"`
	Style        string   `json:"style"`
	Usage        string   `json:"usage"`
	Season       string   `json:"season"`
	BaseColour   string   `json:"base_colour"`
	Formality    int16    `json:"formality"`
	Warmth       int16    `json:"warmth"`
	MinTemp      int16    `json:"min_temp"`
	MaxTemp      int16    `json:"max_temp"`
	Materials    []string `json:"materials"`
	Fit          string   `json:"fit"`
	Pattern      string   `json:"pattern"`
	IconEmoji    string   `json:"icon_emoji"`
	Source       string   `json:"source"`
	IsOwned      bool     `json:"is_owned"`
	CreatedAt    string   `json:"created_at"`
	SourcePriority int    `json:"source_priority"`
}

// RecommendationProcessedEvent представляет событие, когда рекомендация обработана
type RecommendationProcessedEvent struct {
	EventID     string    `json:"event_id"`
	RequestID   string    `json:"request_id"`
	UserID      string    `json:"user_id"`
	Timestamp   time.Time `json:"timestamp"`
	RankedItems []RankedItem `json:"ranked_items"`
	ModelVersion string   `json:"model_version"`
	ProcessingTimeMs float64 `json:"processing_time_ms"`
	Error       *string   `json:"error,omitempty"`
}

// RankedItem представляет ранжированную одежду
type RankedItem struct {
	ID    string  `json:"id"`
	Score float64 `json:"score"`
}

// UserFeedbackEvent представляет событие, когда пользователь предоставляет обратную связь о рекомендации
type UserFeedbackEvent struct {
	EventID     string    `json:"event_id"`
	UserID      string    `json:"user_id"`
	RecommendationID string `json:"recommendation_id"`
	Timestamp   time.Time `json:"timestamp"`
	Rating      int       `json:"rating"` // шкала 1-5
	Feedback    string    `json:"feedback,omitempty"`
	SessionID   string    `json:"session_id"`
}