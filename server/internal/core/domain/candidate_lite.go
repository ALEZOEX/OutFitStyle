package domain

// CandidateLite — минимальный набор данных для ранжирования и сборки образа.
type CandidateLite struct {
	ID ID `json:"id"`

	Category    string `json:"category"`
	Subcategory string `json:"subcategory"`

	Source string `json:"source"` // clothing_source: user|partner|manual|synthetic

	// климат/ограничения
	MinTemp     *int `json:"min_temp,omitempty"`
	MaxTemp     *int `json:"max_temp,omitempty"`
	WarmthLevel *int `json:"warmth_level,omitempty"`
	RainOK      bool `json:"rain_ok"`
	SnowOK      bool `json:"snow_ok"`
	WindOK      bool `json:"wind_ok"`

	// стиль
	Style          string `json:"style"`
	FormalityLevel *int   `json:"formality_level,omitempty"`
	BaseColour     *string `json:"base_colour,omitempty"`
	Pattern        string  `json:"pattern"`

	// гардеробные признаки
	WearCount *int `json:"wear_count,omitempty"`

	// флаг откуда кандидат (для is_from_wardrobe)
	IsFromWardrobe bool `json:"is_from_wardrobe"`
}