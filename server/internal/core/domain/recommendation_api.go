package domain

type RecommendationCreateRequest struct {
	Location  *string  `json:"location,omitempty"`
	Latitude  *float64 `json:"latitude,omitempty"`
	Longitude *float64 `json:"longitude,omitempty"`

	Occasion  *string `json:"occasion,omitempty"`
	Style     *string `json:"style,omitempty"`
	Formality *int    `json:"formality,omitempty"`

	IncludePartnerItems *bool `json:"include_partner_items,omitempty"`
}

type RecommendationRateRequest struct {
	Rating          int     `json:"rating"`
	ThermalFeedback *string `json:"thermal_feedback,omitempty"`
	Feedback        *string `json:"feedback,omitempty"`
}

type RecommendationRegenerateRequest struct {
	ExcludeItems []ID     `json:"exclude_items,omitempty"`
	PreferStyle  *string  `json:"prefer_style,omitempty"`
}

type FavoriteRequest struct {
	IsFavorite bool `json:"is_favorite"`
}