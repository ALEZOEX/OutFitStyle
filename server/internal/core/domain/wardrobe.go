package domain

import "time"

// WardrobeItem — запись user_wardrobe + вложенная clothing_item.
type WardrobeItem struct {
	ID           ID `json:"id"`
	UserID       ID `json:"user_id"`
	ClothingItemID ID `json:"clothing_item_id"`

	CustomName *string  `json:"custom_name,omitempty"`
	Notes      *string  `json:"notes,omitempty"`
	Tags       []string `json:"tags,omitempty"`

	PurchaseDate    *time.Time `json:"purchase_date,omitempty"`
	PurchasePrice   *float64   `json:"purchase_price,omitempty"`
	PurchaseCurrency *string   `json:"purchase_currency,omitempty"`

	WearCount  int        `json:"wear_count"`
	LastWornAt *time.Time `json:"last_worn_at,omitempty"`

	IsFavorite bool `json:"is_favorite"`
	IsArchived bool `json:"is_archived"`
	Condition  string `json:"condition"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	Item ClothingItem `json:"item"`
}

type WardrobeCreateRequest struct {
	// Вариант 1: добавить существующую вещь
	ClothingItemID *ID `json:"clothing_item_id,omitempty"`

	// Вариант 2: создать "ручную" вещь
	Name        *string `json:"name,omitempty"`
	Category    *string `json:"category,omitempty"`
	Subcategory *string `json:"subcategory,omitempty"`
	Style       *string `json:"style,omitempty"`
	BaseColour  *string `json:"base_colour,omitempty"`

	// пользовательские поля wardrobe
	CustomName *string  `json:"custom_name,omitempty"`
	Notes      *string  `json:"notes,omitempty"`
	Tags       []string `json:"tags,omitempty"`
}

type WardrobeUpdateRequest struct {
	CustomName    *string  `json:"custom_name,omitempty"`
	Notes         *string  `json:"notes,omitempty"`
	Tags          []string `json:"tags,omitempty"`
	PurchasePrice *float64 `json:"purchase_price,omitempty"`
	Condition     *string  `json:"condition,omitempty"`
}

type WardrobeToggleRequest struct {
	IsFavorite *bool `json:"is_favorite,omitempty"`
	IsArchived *bool `json:"is_archived,omitempty"`
}