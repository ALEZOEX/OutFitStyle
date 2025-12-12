package domain

import "time"

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

type ClothingItem struct {
	ID   int64  `db:"id" json:"id"`
	Name string `db:"name" json:"name"`

	Category    string `db:"category" json:"category"`
	Subcategory string `db:"subcategory" json:"subcategory"`
	Gender      string `db:"gender" json:"gender"`

	Style       string `db:"style" json:"style"`
	Usage       string `db:"usage" json:"usage"`
	Season      string `db:"season" json:"season"`
	BaseColour  string `db:"base_colour" json:"base_colour"`
	Formality   int16  `db:"formality_level" json:"formality_level"`
	Warmth      int16  `db:"warmth_level" json:"warmth_level"`

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
	TranslatedName       string `db:"-" json:"translated_name,omitempty"`
	TranslatedCategory   string `db:"-" json:"translated_category,omitempty"`
	TranslatedSubcategory string `db:"-" json:"translated_subcategory,omitempty"`
	TranslatedStyle      string `db:"-" json:"translated_style,omitempty"`
	TranslatedUsage      string `db:"-" json:"translated_usage,omitempty"`
	TranslatedSeason     string `db:"-" json:"translated_season,omitempty"`
	TranslatedBaseColour string `db:"-" json:"translated_base_colour,omitempty"`
	TranslatedFit        string `db:"-" json:"translated_fit,omitempty"`
	TranslatedPattern    string `db:"-" json:"translated_pattern,omitempty"`
}