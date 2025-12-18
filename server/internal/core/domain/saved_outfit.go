package domain

import "time"

type SavedOutfit struct {
	ID             ID         `json:"id"`
	UserID         ID         `json:"user_id"`

	Name           string     `json:"name"`
	Description    *string    `json:"description,omitempty"`

	Items          any        `json:"items"` // JSON

	Occasions      []string   `json:"occasions,omitempty"`
	Seasons        []string   `json:"seasons,omitempty"`
	MinTemp        *int       `json:"min_temp,omitempty"`
	MaxTemp        *int       `json:"max_temp,omitempty"`

	ThumbnailURL   *string    `json:"thumbnail_url,omitempty"`
	IsFavorite     bool       `json:"is_favorite"`
	TimesWorn      int        `json:"times_worn"`
	LastWornAt     *time.Time `json:"last_worn_at,omitempty"`

	CreatedAt      time.Time  `json:"created_at"`
}

type SavedOutfitCreateRequest struct {
	Name        string  `json:"name"`
	Items       any     `json:"items"`

	Occasions   []string `json:"occasions,omitempty"`
	Seasons     []string `json:"seasons,omitempty"`
	Description *string  `json:"description,omitempty"`
}

type SavedOutfitUpdateRequest struct {
	Name        *string `json:"name,omitempty"`
	Items       any     `json:"items,omitempty"`
	Occasions   []string `json:"occasions,omitempty"`
	Seasons     []string `json:"seasons,omitempty"`
	Description *string  `json:"description,omitempty"`
	IsFavorite  *bool    `json:"is_favorite,omitempty"`
}