package domain

import (
	"encoding/json"
	"time"
)

// User соответствует таблице users из ТЗ (основные поля).
type User struct {
	ID ID `json:"id"`

	Email        string `json:"email"`
	PasswordHash string `json:"-"`

	DisplayName *string    `json:"display_name,omitempty"`
	AvatarURL   *string    `json:"avatar_url,omitempty"`
	Gender      *string    `json:"gender,omitempty"`
	BirthDate   *time.Time `json:"birth_date,omitempty"`

	DefaultLocation  *string  `json:"default_location,omitempty"`
	DefaultLatitude  *float64 `json:"default_latitude,omitempty"`
	DefaultLongitude *float64 `json:"default_longitude,omitempty"`
	Timezone         *string  `json:"timezone,omitempty"`
	Locale           *string  `json:"locale,omitempty"`

	BodyMeasurements json.RawMessage `json:"body_measurements,omitempty"`
	Preferences      json.RawMessage `json:"preferences,omitempty"`

	IsActive   bool       `json:"is_active"`
	IsVerified bool       `json:"is_verified"`
	VerifiedAt *time.Time `json:"verified_at,omitempty"`

	OAuthProvider *string `json:"oauth_provider,omitempty"`
	OAuthID       *string `json:"oauth_id,omitempty"`

	LastLoginAt *time.Time `json:"last_login_at,omitempty"`
	LoginCount  int        `json:"login_count"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Запрос регистрации (из ТЗ: email, password, display_name?, locale?)
type UserRegistration struct {
	Email       string  `json:"email"`
	Password    string  `json:"password"`
	DisplayName *string `json:"display_name,omitempty"`
	Locale      *string `json:"locale,omitempty"`
}

// Запрос логина (минимум)
type UserLogin struct {
	Email      string  `json:"email"`
	Password   string  `json:"password"`
	DeviceID   *string `json:"device_id,omitempty"`
	DeviceName *string `json:"device_name,omitempty"`
}
