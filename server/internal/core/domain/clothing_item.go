package domain

import "time"

type ClothingItem struct {
	ID          ID      `json:"id"`
	Name        string  `json:"name"`
	Description *string `json:"description,omitempty"`

	Category    string `json:"category"`
	Subcategory string `json:"subcategory"`

	MinTemp     *int16 `json:"min_temp,omitempty"`
	MaxTemp     *int16 `json:"max_temp,omitempty"`
	WarmthLevel *int16 `json:"warmth_level,omitempty"`

	RainOK bool `json:"rain_ok"`
	SnowOK bool `json:"snow_ok"`
	WindOK bool `json:"wind_ok"`

	Style          string  `json:"style"`
	FormalityLevel *int16  `json:"formality_level,omitempty"`
	BaseColour     *string `json:"base_colour,omitempty"`
	Pattern        string  `json:"pattern"`
	Fit            string  `json:"fit"`

	Gender string `json:"gender"`
	Season string `json:"season"`

	Usage     []string `json:"usage,omitempty"`
	Materials []string `json:"materials,omitempty"`

	Brand *string `json:"brand,omitempty"`

	ImageURL     *string `json:"image_url,omitempty"`
	ThumbnailURL *string `json:"thumbnail_url,omitempty"`
	IconEmoji    *string `json:"icon_emoji,omitempty"`

	Source  string `json:"source"` // enum clothing_source in DB
	OwnerID *ID    `json:"owner_id,omitempty"`
	IsOwned bool   `json:"is_owned"`

	IsActive  bool      `json:"is_active"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Translated fields (not stored in DB, populated when needed)
	TranslatedName        string `json:"translated_name,omitempty"`
	TranslatedCategory    string `json:"translated_category,omitempty"`
	TranslatedSubcategory string `json:"translated_subcategory,omitempty"`
	TranslatedStyle       string `json:"translated_style,omitempty"`
	TranslatedUsage       string `json:"translated_usage,omitempty"`
	TranslatedSeason      string `json:"translated_season,omitempty"`
	TranslatedBaseColour  string `json:"translated_base_colour,omitempty"`
	TranslatedFit         string `json:"translated_fit,omitempty"`
	TranslatedPattern     string `json:"translated_pattern,omitempty"`
}
