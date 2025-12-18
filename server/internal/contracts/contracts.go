package contracts

// MLRankRequest represents the request structure for the ML ranking service
type MLRankRequest struct {
	Context    MLContext        `json:"context"`
	Candidates []MLItem         `json:"candidates"`
}

// MLContext represents contextual information for ranking
type MLContext struct {
	Weather     WeatherData          `json:"weather"`
	UserProfile UserProfile          `json:"user_profile"`
	Preferences map[string]interface{} `json:"preferences"`
	Location    string               `json:"location"`
}

// WeatherData represents weather information
type WeatherData struct {
	Temperature  float64 `json:"temperature"`
	FeelsLike    float64 `json:"feels_like"`
	Humidity     int     `json:"humidity"`
	WindSpeed    float64 `json:"wind_speed"`
	Weather      string  `json:"weather"`
}

// UserProfile represents user preferences
type UserProfile struct {
	AgeRange             string  `json:"age_range"`
	StylePreference      string  `json:"style_preference"`
	TemperatureSensitivity string  `json:"temperature_sensitivity"`
	FormalityPreference  string  `json:"formality_preference"`
	Gender               string  `json:"gender"`
}

// MLItem represents a clothing item for ranking
type MLItem struct {
	ID           int64    `json:"id"`
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

	// Source priority used for ranking
	SourcePriority int `json:"source_priority"`
}

// MLRankResponse represents the response structure from the ML ranking service
type MLRankResponse struct {
	Ranked       []RankedItem `json:"ranked"`
	ModelVersion string       `json:"model_version"`
	ProcessingTimeMs float64  `json:"processing_time_ms"`
	Error        *string      `json:"error,omitempty"`
}

// RankedItem represents a ranked clothing item
type RankedItem struct {
	ID    int64   `json:"id"`
	Score float64 `json:"score"`
}