package domain

type UserProfile struct {
	ID                ID       `json:"id"`
	UserID            ID       `json:"user_id"`  // for database mapping
	DisplayName       *string  `json:"display_name,omitempty"`
	AvatarURL         *string  `json:"avatar_url,omitempty"`
	Gender            *string  `json:"gender,omitempty"`
	BirthDate         *string  `json:"birth_date,omitempty"` // ISO date YYYY-MM-DD
	DefaultLocation   *string  `json:"default_location,omitempty"`
	DefaultLatitude   *float64 `json:"default_latitude,omitempty"`
	DefaultLongitude  *float64 `json:"default_longitude,omitempty"`
	Timezone          *string  `json:"timezone,omitempty"`
	Locale            *string  `json:"locale,omitempty"`
	IsPublic          bool     `json:"is_public"`
	StylePreferences  *string  `json:"style_preferences,omitempty"`
	Size              *string  `json:"size,omitempty"`
	Height            *int     `json:"height,omitempty"`  // in cm
	Weight            *int     `json:"weight,omitempty"`  // in kg
	PreferredColors   []string `json:"preferred_colors,omitempty"`
	DislikedColors    []string `json:"disliked_colors,omitempty"`

	CreatedAt string `json:"created_at"`
	UpdatedAt string `json:"updated_at"`
}

type UserProfileResponse struct {
	User  *User      `json:"user"`
	Stats *UserStats `json:"stats,omitempty"`
	// Subscription добавим в следующих модулях
}

type UserProfileUpdate struct {
	DisplayName     *string  `json:"display_name,omitempty"`
	AvatarURL       *string  `json:"avatar_url,omitempty"`
	Gender          *string  `json:"gender,omitempty"`
	BirthDate       *string  `json:"birth_date,omitempty"` // ISO date YYYY-MM-DD (упростим в handler)
	DefaultLocation *string  `json:"default_location,omitempty"`
	DefaultLatitude  *float64 `json:"default_latitude,omitempty"`
	DefaultLongitude *float64 `json:"default_longitude,omitempty"`
	Timezone        *string  `json:"timezone,omitempty"`
	Locale          *string  `json:"locale,omitempty"`
}