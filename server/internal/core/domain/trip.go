package domain

import "time"

type Trip struct {
	ID     ID `json:"id"`
	UserID ID `json:"user_id"`

	Name        string `json:"name"`
	Destination string `json:"destination"`

	DestinationLat *float64 `json:"destination_lat,omitempty"`
	DestinationLon *float64 `json:"destination_lon,omitempty"`

	StartDate string `json:"start_date"` // YYYY-MM-DD
	EndDate   string `json:"end_date"`   // YYYY-MM-DD

	Occasions   []string `json:"occasions,omitempty"`
	PackingList any      `json:"packing_list,omitempty"` // JSON

	Status    string    `json:"status"`
	CreatedAt time.Time `json:"created_at"`
}

type TripCreateRequest struct {
	Name        string   `json:"name"`
	Destination string   `json:"destination"`
	StartDate   string   `json:"start_date"`
	EndDate     string   `json:"end_date"`
	Occasions   []string `json:"occasions,omitempty"`

	DestinationLat *float64 `json:"destination_lat,omitempty"`
	DestinationLon *float64 `json:"destination_lon,omitempty"`
}

type TripUpdateRequest struct {
	Name        *string  `json:"name,omitempty"`
	Destination *string  `json:"destination,omitempty"`
	StartDate   *string  `json:"start_date,omitempty"`
	EndDate     *string  `json:"end_date,omitempty"`
	Occasions   []string `json:"occasions,omitempty"`

	DestinationLat *float64 `json:"destination_lat,omitempty"`
	DestinationLon *float64 `json:"destination_lon,omitempty"`

	Status *string `json:"status,omitempty"`
}
