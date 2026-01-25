package docs

import (
	"outfitstyle/server/internal/core/domain"
)

// SwaggerUserProfileResponse представляет собой структуру ответа профиля пользователя для Swagger
// потому что оригинальная структура содержит json.RawMessage, который не поддерживается Swagger
type SwaggerUserProfileResponse struct {
	User  *SwaggerUser      `json:"user"`
	Stats *domain.UserStats `json:"stats,omitempty"`
}

// SwaggerUser представляет собой структуру пользователя для Swagger
// потому что оригинальная структура содержит json.RawMessage, который не поддерживается Swagger
type SwaggerUser struct {
	ID ID `json:"id"`

	Email        string `json:"email"`
	PasswordHash string `json:"-"`

	DisplayName *string `json:"display_name,omitempty"`
	AvatarURL   *string `json:"avatar_url,omitempty"`
	Gender      *string `json:"gender,omitempty"`
	BirthDate   *string `json:"birth_date,omitempty"` // ISO date YYYY-MM-DD (преобразованный из time.Time)

	DefaultLocation  *string  `json:"default_location,omitempty"`
	DefaultLatitude  *float64 `json:"default_latitude,omitempty"`
	DefaultLongitude *float64 `json:"default_longitude,omitempty"`
	Timezone         string   `json:"timezone"`
	Locale           string   `json:"locale"`

	// Заменяем json.RawMessage на interface{} для совместимости со Swagger
	BodyMeasurements interface{} `json:"body_measurements,omitempty"`
	Preferences      interface{} `json:"preferences,omitempty"`

	IsActive   bool    `json:"is_active"`
	IsVerified bool    `json:"is_verified"`
	VerifiedAt *string `json:"verified_at,omitempty"` // Преобразованный из time.Time

	OAuthProvider *string `json:"oauth_provider,omitempty"`
	OAuthID       *string `json:"oauth_id,omitempty"`

	LastLoginAt *string `json:"last_login_at,omitempty"` // Преобразованный из time.Time
	LoginCount  int     `json:"login_count"`

	CreatedAt string `json:"created_at"` // Преобразованный из time.Time
	UpdatedAt string `json:"updated_at"` // Преобразованный из time.Time
}

// ID представляет собой идентификатор для Swagger
type ID string
