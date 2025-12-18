package domain

type GeoPlace struct {
	DisplayName string  `json:"display_name"`
	Latitude    float64 `json:"latitude"`
	Longitude   float64 `json:"longitude"`
}

type GeoAutocompleteResponse struct {
	Places []GeoPlace `json:"places"`
}