package entities

import (
	"time"
)

// User represents a user of the application
type User struct {
	ID         int64     `json:"id"`
	Email      string    `json:"email"`
	Username   string    `json:"username"`
	Password   string    `json:"-"` // Never serialize password
	AvatarURL  string    `json:"avatar_url"`
	IsVerified bool      `json:"is_verified"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// UserProfile represents user preferences and settings
type UserProfile struct {
	ID                     int64     `json:"id"`
	UserID                 int64     `json:"user_id"`
	StylePreferences       string    `json:"style_preferences,omitempty"`
	Size                   string    `json:"size,omitempty"`
	Height                 int       `json:"height,omitempty"`
	Weight                 int       `json:"weight,omitempty"`
	PreferredColors        []string  `json:"preferred_colors,omitempty"`
	DislikedColors         []string  `json:"disliked_colors,omitempty"`
	AgeRange               string    `json:"age_range"`
	StylePreference        string    `json:"style_preference"`
	TemperatureSensitivity string    `json:"temperature_sensitivity"`
	FormalityPreference    string    `json:"formality_preference"`
	CreatedAt              time.Time `json:"created_at"`
	UpdatedAt              time.Time `json:"updated_at"`
}

// UserRegistration represents user registration data
type UserRegistration struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=8"`
	Username string `json:"username" validate:"required"`
}

// VerificationCode represents a verification code for email confirmation
type VerificationCode struct {
	Code      string    `json:"code"`
	UserID    int64     `json:"user_id"`
	ExpiresAt time.Time `json:"expires_at"`
	Type      string    `json:"type"` // "registration" or "login"
}