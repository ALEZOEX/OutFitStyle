package domain

import (
	"time"
)

type SubcategorySpec struct {
	Category    string `db:"category" json:"category"`
	Subcategory string `db:"subcategory" json:"subcategory"`

	WarmthMin   int16 `db:"warmth_min" json:"warmth_min"`
	TempMinReco int16 `db:"temp_min_reco" json:"temp_min_reco"`
	TempMaxReco int16 `db:"temp_max_reco" json:"temp_max_reco"`

	RainOK bool `db:"rain_ok" json:"rain_ok"`
	SnowOK bool `db:"snow_ok" json:"snow_ok"`
	WindOK bool `db:"wind_ok" json:"wind_ok"`
}

type CatalogItem struct {
	ID   int64  `db:"id" json:"id"`
	Name string `db:"name" json:"name"`

	Category    string `db:"category" json:"category"`
	Subcategory string `db:"subcategory" json:"subcategory"`
	Gender      string `db:"gender" json:"gender"`

	Style      string `db:"style" json:"style"`
	Usage      string `db:"usage" json:"usage"`
	Season     string `db:"season" json:"season"`
	BaseColour string `db:"base_colour" json:"base_colour"`
	Formality  int16  `db:"formality_level" json:"formality_level"`
	Warmth     int16  `db:"warmth_level" json:"warmth_level"`

	MinTemp int16 `db:"min_temp" json:"min_temp"`
	MaxTemp int16 `db:"max_temp" json:"max_temp"`

	Materials []string `db:"materials" json:"materials"`

	Fit     string `db:"fit" json:"fit"`
	Pattern string `db:"pattern" json:"pattern"`

	IconEmoji string `db:"icon_emoji" json:"icon_emoji"`
	Source    string `db:"source" json:"source"`
	IsOwned   bool   `db:"is_owned" json:"is_owned"`

	CreatedAt time.Time `db:"created_at" json:"created_at"`

	// Translated fields (not stored in DB, populated when needed)
	TranslatedName        string `db:"-" json:"translated_name,omitempty"`
	TranslatedCategory    string `db:"-" json:"translated_category,omitempty"`
	TranslatedSubcategory string `db:"-" json:"translated_subcategory,omitempty"`
	TranslatedStyle       string `db:"-" json:"translated_style,omitempty"`
	TranslatedUsage       string `db:"-" json:"translated_usage,omitempty"`
	TranslatedSeason      string `db:"-" json:"translated_season,omitempty"`
	TranslatedBaseColour  string `db:"-" json:"translated_base_colour,omitempty"`
	TranslatedFit         string `db:"-" json:"translated_fit,omitempty"`
	TranslatedPattern     string `db:"-" json:"translated_pattern,omitempty"`
}

type WeatherData struct {
	Temperature    float64         `json:"temperature"`
	FeelsLike      float64         `json:"feels_like"`
	Humidity       int             `json:"humidity"`
	WindSpeed      float64         `json:"wind_speed"`
	Weather        string          `json:"weather"`
	WeatherMain    string          `json:"weather_main"`
	Description    string          `json:"description"`
	Visibility     int             `json:"visibility"`
	Uvi            float64         `json:"uvi"`
	Pressure       int             `json:"pressure"`
	Location       string          `json:"location"`        // Added field
	MinTemp        float64         `json:"min_temp"`        // Added field
	MaxTemp        float64         `json:"max_temp"`        // Added field
	WillRain       bool            `json:"will_rain"`       // Added field
	WillSnow       bool            `json:"will_snow"`       // Added field
	HourlyForecast []WeatherHourly `json:"hourly_forecast"` // Added field
}

type WeatherHourly struct {
	Time         int64   `json:"time"` // Unix timestamp
	Temperature  float64 `json:"temperature"`
	FeelsLike    float64 `json:"feels_like"`
	Weather      string  `json:"weather"`
	WeatherMain  string  `json:"weather_main"`
	Description  string  `json:"description"`
	Rain         float64 `json:"rain,omitempty"` // mm precipitation expected
	Snow         float64 `json:"snow,omitempty"` // mm snowfall expected
	ChanceOfRain float64 `json:"chance_of_rain"` // percentage
	ChanceOfSnow float64 `json:"chance_of_snow"` // percentage
}

type ExtendedWeatherData struct {
	WeatherData
	City      string    `json:"city"`
	Country   string    `json:"country"`
	Longitude float64   `json:"longitude"`
	Latitude  float64   `json:"latitude"`
	Sunrise   int64     `json:"sunrise"`
	Sunset    int64     `json:"sunset"`
	Timestamp time.Time `json:"timestamp"` // Added field
}

type HourlyWeather struct {
	Time         int64   `json:"time"` // Unix timestamp
	Temperature  float64 `json:"temperature"`
	FeelsLike    float64 `json:"feels_like"`
	Weather      string  `json:"weather"`
	WeatherMain  string  `json:"weather_main"`
	Description  string  `json:"description"`
	Rain         float64 `json:"rain,omitempty"` // mm precipitation expected
	Snow         float64 `json:"snow,omitempty"` // mm snowfall expected
	ChanceOfRain float64 `json:"chance_of_rain"` // percentage
	ChanceOfSnow float64 `json:"chance_of_snow"` // percentage
}

type RecommendationResponse struct {
	ID          int64                `json:"id"`
	UserID      int64                `json:"user_id"`
	City        string               `json:"city"`
	Weather     WeatherData          `json:"weather"`
	Outfit      []RecommendationItem `json:"outfit"`
	CreatedAt   time.Time            `json:"created_at"`
	Source      string               `json:"source"`
	Score       float64              `json:"score"`
	OutfitScore float64              `json:"outfit_score"` // Added field
	Algorithm   string               `json:"algorithm"`    // Added field
	Items       []RecommendationItem `json:"items"`        // Added field
	Location    string               `json:"location"`     // Added field
	Temperature float64              `json:"temperature"`  // Added field
	FeelsLike   float64              `json:"feels_like"`   // Added field
	WindSpeed   float64              `json:"wind_speed"`   // Added field
	MinTemp     float64              `json:"min_temp"`     // Added field
	MaxTemp     float64              `json:"max_temp"`     // Added field
	WillRain    bool                 `json:"will_rain"`    // Added field
	WillSnow    bool                 `json:"will_snow"`    // Added field
	Humidity    int                  `json:"humidity"`     // Added field
	Timestamp   time.Time            `json:"timestamp"`    // Added field
	MLPowered   bool                 `json:"ml_powered"`   // Added field
}

type RecommendationItem struct {
	ID             int64   `json:"id"`
	ClothingItemID int64   `json:"clothing_item_id"`
	Category       string  `json:"category"`
	Name           string  `json:"name"`
	Score          float64 `json:"score"`
	IconEmoji      string  `json:"icon_emoji"`
	MLScore        float64 `json:"ml_score"`
	Confidence     float64 `json:"confidence"`
}

type Recommendation struct {
	ID        int64       `db:"id" json:"id"`
	UserID    int64       `db:"user_id" json:"user_id"`
	City      string      `db:"city" json:"city"`
	Weather   WeatherData `db:"-" json:"weather"`
	CreatedAt time.Time   `db:"created_at" json:"created_at"`
	Source    string      `db:"source" json:"source"`
}

type RecommendationItemEntity struct {
	ID               int64     `db:"id" json:"id"`
	RecommendationID int64     `db:"recommendation_id" json:"recommendation_id"`
	ClothingItemID   int64     `db:"clothing_item_id" json:"clothing_item_id"`
	Score            float64   `db:"score" json:"score"`
	Category         string    `db:"category" json:"category"`
	CreatedAt        time.Time `db:"created_at" json:"created_at"`
}

type MarketItem struct {
	ID         int64   `json:"id"`
	Name       string  `json:"name"`
	Price      float64 `json:"price"`
	URL        string  `json:"url"`
	ImageURL   string  `json:"image_url"`
	Store      string  `json:"store"`
	MatchScore float64 `json:"match_score"`
}

type MarketplaceMatch struct {
	RecommendedItemID int64        `json:"recommended_item_id"`
	MarketItems       []MarketItem `json:"market_items"`
}

type ClothingItemFilters struct {
	Category    *string  `json:"category,omitempty"`
	Subcategory *string  `json:"subcategory,omitempty"`
	Gender      *string  `json:"gender,omitempty"`
	Style       *string  `json:"style,omitempty"`
	MinWarmth   *int16   `json:"min_warmth,omitempty"`
	MaxWarmth   *int16   `json:"max_warmth,omitempty"`
	Season      *string  `json:"season,omitempty"`
	Materials   []string `json:"materials,omitempty"`
	Colors      []string `json:"colors,omitempty"`
	MinTemp     *int16   `json:"min_temp,omitempty"`
	MaxTemp     *int16   `json:"max_temp,omitempty"`
}

type FavoriteOutfit struct {
	ID         int64     `db:"id" json:"id"`
	UserID     int64     `db:"user_id" json:"user_id"`
	Name       string    `db:"name" json:"name"`
	Items      []int64   `db:"-" json:"items"` // IDs of clothing items
	CreatedAt  time.Time `db:"created_at" json:"created_at"`
	SharedWith []int64   `db:"-" json:"shared_with,omitempty"` // User IDs
}

type UserRating struct {
	ID        int64     `db:"id" json:"id"`
	UserID    int64     `db:"user_id" json:"user_id"`
	OutfitID  int64     `db:"outfit_id" json:"outfit_id"`
	Rating    int       `db:"rating" json:"rating"` // 1-5 stars
	Comment   *string   `db:"comment" json:"comment,omitempty"`
	CreatedAt time.Time `db:"created_at" json:"created_at"`
}

type OutfitPlan struct {
	ID          int64     `db:"id" json:"id"`
	UserID      int64     `db:"user_id" json:"user_id"`
	Date        time.Time `db:"date" json:"date"`
	OutfitItems []int64   `db:"-" json:"outfit_items"` // IDs of clothing items
	Notes       *string   `db:"notes" json:"notes,omitempty"`
	CreatedAt   time.Time `db:"created_at" json:"created_at"`
	ModifiedAt  time.Time `db:"modified_at" json:"modified_at"`
}

type VerificationCode struct {
	ID        int64      `db:"id" json:"id"`
	UserID    int64      `db:"user_id" json:"user_id"`
	Code      string     `db:"code" json:"code"`
	Type      string     `db:"code_type" json:"type"`
	ExpiresAt time.Time  `db:"expires_at" json:"expires_at"`
	CreatedAt time.Time  `db:"created_at" json:"created_at"`
	UsedAt    *time.Time `db:"used_at" json:"used_at,omitempty"`
}

type RecommendationRequest struct {
	UserID            int64              `json:"user_id"`
	City              string             `json:"city"`
	Country           string             `json:"country"`
	Latitude          float64            `json:"latitude"`
	Longitude         float64            `json:"longitude"`
	TargetDate        *time.Time         `json:"target_date,omitempty"` // For planning outfits in advance
	Purpose           string             `json:"purpose"`               // "work", "casual", "party", etc.
	Formality         *int               `json:"formality,omitempty"`   // 1-5 scale
	Gender            string             `json:"gender"`                // For gender-specific recommendations
	ExcludeItems      []int64            `json:"exclude_items"`         // IDs of items to exclude from recommendations
	PreferenceWeights map[string]float64 `json:"preference_weights"`    // Custom weights for different criteria
	WeatherData       WeatherData        `json:"weather_data"`          // Added field to hold weather data
}
