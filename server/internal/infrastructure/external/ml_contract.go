package external

import "outfitstyle/server/internal/core/domain"

type TZMLRankRequest struct {
	RequestID string   `json:"request_id"`
	UserID    domain.ID `json:"user_id"`

	Context TZMLContext `json:"context"`

	UserPreferences TZMLUserPreferences `json:"user_preferences"`
	UserHistory     TZMLUserHistory     `json:"user_history"`

	Candidates []TZMLCandidate `json:"candidates"`
}

type TZMLContext struct {
	Temperature          float64 `json:"temperature"`
	FeelsLike            float64 `json:"feels_like"`
	Humidity             int     `json:"humidity"`
	WindSpeed            float64 `json:"wind_speed"`
	WindDirection        int     `json:"wind_direction"`
	WeatherCode          string  `json:"weather_code"`
	PrecipitationChance  int     `json:"precipitation_chance"`

	Occasion   string `json:"occasion"`
	Formality  int    `json:"formality"`
	TimeOfDay  string `json:"time_of_day"`
	DayOfWeek  int    `json:"day_of_week"`
}

type TZMLUserPreferences struct {
	PreferredStyles        []string `json:"preferred_styles"`
	AvoidStyles            []string `json:"avoid_styles"`
	ColorPreferences       []string `json:"color_preferences"`
	AvoidColors            []string `json:"avoid_colors"`
	TemperatureSensitivity int      `json:"temperature_sensitivity"`
}

type TZMLUserHistory struct {
	RecentItems       []domain.ID            `json:"recent_items"`
	HighlyRatedItems  []domain.ID            `json:"highly_rated_items"`
	LowRatedItems     []domain.ID            `json:"low_rated_items"`
	StyleDistribution map[string]float64     `json:"style_distribution"`
}

type TZMLCandidate struct {
	ID             domain.ID `json:"id"`
	Category       string    `json:"category"`
	Subcategory    string    `json:"subcategory"`
	Source         string    `json:"source"`
	SourcePriority int       `json:"source_priority"`

	Features TZMLCandidateFeatures `json:"features"`
}

type TZMLCandidateFeatures struct {
	WarmthLevel     int    `json:"warmth_level"`
	MinTemp         int    `json:"min_temp"`
	MaxTemp         int    `json:"max_temp"`
	RainOK          bool   `json:"rain_ok"`
	SnowOK          bool   `json:"snow_ok"`
	WindOK          bool   `json:"wind_ok"`
	Style           string `json:"style"`
	FormalityLevel  int    `json:"formality_level"`
	BaseColour      string `json:"base_colour"`
	Pattern         string `json:"pattern"`

	UserRating *float64 `json:"user_rating,omitempty"`
	WearCount  *int     `json:"wear_count,omitempty"`
}

type TZMLRankResponse struct {
	RequestID string `json:"request_id"`

	Rankings map[string][]TZMLRankedItem `json:"rankings"`

	OutfitScore      float64 `json:"outfit_score"`
	StyleCoherence   float64 `json:"style_coherence"`
	ColorHarmony     float64 `json:"color_harmony"`

	ModelVersion      string `json:"model_version"`
	ProcessingTimeMs  int    `json:"processing_time_ms"`
}

type TZMLRankedItem struct {
	ID         domain.ID `json:"id"`
	Score      float64   `json:"score"`
	Confidence float64   `json:"confidence"`
	Factors    map[string]any `json:"factors"`
}