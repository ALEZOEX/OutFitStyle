package repositories

import (
	"context"
	"time"
)

// UserRepository defines the interface for user data operations
type UserRepository interface {
	GetUser(ctx context.Context, id int) (*User, error)
	GetUserByEmail(ctx context.Context, email string) (*User, error)
	CreateUser(ctx context.Context, user *User) error
	UpdateUser(ctx context.Context, user *User) error
}

// User represents a user in the system
type User struct {
	ID                int       `json:"id"`
	Email             string    `json:"email"`
	Username          string    `json:"username"`
	Password          string    `json:"password"`
	IsVerified        bool      `json:"is_verified"`
	VerificationToken string    `json:"verification_token"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

// UserProfile represents a user's profile information
type UserProfile struct {
	ID              int           `json:"id"`
	UserID          int           `json:"user_id"`
	StylePreferences []string      `json:"style_preferences"`
	Size            string        `json:"size"`
	Height          int           `json:"height"`
	Weight          int           `json:"weight"`
	PreferredColors []string      `json:"preferred_colors"`
	DislikedColors  []string      `json:"disliked_colors"`
	CreatedAt       time.Time     `json:"created_at"`
	UpdatedAt       time.Time     `json:"updated_at"`
}

// VerificationCode represents a verification code for email verification
type VerificationCode struct {
	Code      string    `json:"code"`
	UserID    int       `json:"user_id"`
	ExpiresAt time.Time `json:"expires_at"`
	Type      string    `json:"type"` // "registration" or "login"
}