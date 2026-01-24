package domain

type CatalogFilters struct {
	Categories    []string `json:"categories,omitempty"`
	Subcategories []string `json:"subcategories,omitempty"`
	Genders       []string `json:"genders,omitempty"`
	Styles        []string `json:"styles,omitempty"`
	Seasons       []string `json:"seasons,omitempty"`
	MinTemp       *float64 `json:"min_temp,omitempty"`
	MaxTemp       *float64 `json:"max_temp,omitempty"`
	MinWarmth     *int     `json:"min_warmth,omitempty"`
	MaxWarmth     *int     `json:"max_warmth,omitempty"`
	MinFormality  *int     `json:"min_formality,omitempty"`
	MaxFormality  *int     `json:"max_formality,omitempty"`
	Colors        []string `json:"colors,omitempty"`
	Materials     []string `json:"materials,omitempty"`
	Availability  *bool    `json:"availability,omitempty"`
	Page          int      `json:"page,omitempty"`
	Limit         int      `json:"limit,omitempty"`
}