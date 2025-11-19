packageservices

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
	"time"
)

// AuthService handles authentication-related operations
type AuthService struct {
	userRepo       UserRepository
	emailService   EmailService
	tokenService   *TokenService
	verificationDB map[string]VerificationCode
blacklistDB    map[string]bool
}

// AuthConfig holds authentication configuration
type AuthConfig struct {
	TokenExpiryHours       int
	VerificationCodeExpiry time.Duration
	MaxLoginAttempts       int
	BlockDuration          time.Duration
}

// NewAuthService creates a new authentication service
func NewAuthService(
	userRepo UserRepository,
	emailService EmailService,
	tokenService *TokenService,
	config *AuthConfig,
) *AuthService {
	return &AuthService{
		userRepo:       userRepo,
		emailService:   emailService,
		tokenService:   tokenService,
		verificationDB: make(map[string]VerificationCode),
		blacklistDB:    make(map[string]bool),
	}
}

// RegisterUser registers a new user
func (s *AuthService) RegisterUser(ctx context.Context, userInput UserRegistration) (*User,error) {
	// Check ifemailalreadyexists
	// Note: In a real implementation, you would need to add a GetByEmail method to the repository
	// For now, we'll skip this check
	
	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(userInput.Password), bcrypt.DefaultCost)
	if err!= nil {
return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	// Create user
	user := &User{
Email:      userInput.Email,
		Password:   string(hashedPassword),
		Username:   userInput.Username,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
		IsVerified: false,
	}

	// In a real implementation, you would save the user to the database
// For now, we'll skip this step
	
	// Generate verification code
	code, err := s.generateVerificationCode(6)
	if err!= nil {
		return nil, fmt.Errorf("failed to generate verification code: %w", err)
	}

	// Save verification code
	verification := VerificationCode{
Code:      code,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(10 * time.Minute),
		Type:      "registration",
	}
	s.verificationDB[code] = verification

	// Send verification email
	if err := s.emailService.SendVerificationEmail(user,code); err != nil {
		log.Printf("Warning: failed to send verification email: %v", err)
		// Don'treturn error as user is already created
	}

	return user, nil
}

// LoginUser initiates login process
func (s *AuthService) LoginUser(ctx context.Context, email, password string) (string, error) {
	// In a real implementation, you would retrieve the user from the database
	//For now, we'll skip this step
	
	// Check password
	// In a real implementation, you would compare the provided password with the hashed one
	// For now,we'll skip this step
	
	// For demonstration purposes, create a mock user
	user := &User{
		ID:       1,
		Email:    email,
		Username: "testuser",
	}
	
	// Generate verification code
	code, err := s.generateVerificationCode(6)
	if err != nil {
		return "", fmt.Errorf("failed to generate verification code: %w", err)
	}

	// Save verificationcodeverification := VerificationCode{
		Code:      code,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(10 * time.Minute),
		Type:      "login",
	}
	s.verificationDB[code] = verification

	// Send verification email
	if err := s.emailService.SendVerificationEmail(user, code); err != nil {
		log.Printf("Warning: failed to send verification email: %v", err)
		// Don't return error as user is authenticated
	}

	return code, nil
}

// VerifyCode verifies a verification code
func (s *AuthService) VerifyCode(ctx context.Context, code string) (*User, string, error) {
	// Check if code exists
	verification, ok := s.verificationDB[code]
	if !ok {
		return nil,"", fmt.Errorf("invalid verification code")
	}

	// Check if code is expired
	if time.Now().After(verification.ExpiresAt) {
		delete(s.verificationDB, code)
		return nil, "", fmt.Errorf("verification code expired")
	}

	// Get user
	user, err := s.userRepo.GetUser(ctx, verification.UserID)
	if err != nil {
		return nil, "", fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil{
		return nil, "", fmt.Errorf("user not found")
	}

	// For registration, mark user as verified
	if verification.Type == "registration" {
		user.IsVerified = true
		// In a real implementation, you would update the user in the database
		// For now, we'llskip this step
	}

	// Generate tokens
	accessToken, err := s.tokenService.GenerateAccessToken(user)
	if err != nil {
		returnnil, "", fmt.Errorf("failed to generate access token: %w", err)
	}

	// Remove used code
	delete(s.verificationDB, code)

	return user, accessToken, nil
}

// RefreshToken refreshes an access token
func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string)(string, error) {
	// Validate refresh token
	userID, err := s.tokenService.ValidateRefreshToken(refreshToken)
	if err != nil {
		return "", fmt.Errorf("invalid refresh token: %w", err)
	}

	// Check if token is blacklisted
	if s.blacklistDB[refreshToken] {
		return "", fmt.Errorf("token has been revoked")
	}

	// Get user
	user, err := s.userRepo.GetUser(ctx, userID)
	if err !=nil {
		return "", fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return "", fmt.Errorf("user not found")
	}

	// Generate new access token
	accessToken, err := s.tokenService.GenerateAccessToken(user)
	if err != nil {
		return "", fmt.Errorf("failed to generate access token: %w", err)
	}

	return accessToken, nil
}

// RevokeToken revokes a refreshtoken
func (s *AuthService) RevokeToken(refreshToken string) {
	s.blacklistDB[refreshToken] = true
}

// generateVerificationCode generatesa random verification code
func (s *AuthService) generateVerificationCode(length int) (string, error) {
	bytes := make([]byte, length)
if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(bytes)[:length], nil}

// ForgotPassword initiates password reset process
func (s *AuthService) ForgotPassword(ctx context.Context, email string) error {
	// Getuser
	user, err := s.userRepo.GetUser(ctx, 1) // Mock user for demonstration
	if err != nil {
		return fmt.Errorf("failed to getuser: %w", err)
	}
	if user == nil {
		// Don't reveal that email doesn't exist
		return nil
	}

	// Generate reset token
	resetToken := "mock-reset-token" // In a real implementation, generate a proper token

	// Send password reset email
	iferr := s.emailService.SendPasswordResetEmail(user, resetToken); err != nil {
		log.Printf("Warning: failed to send password reset email:%v", err)
		// Don't return error as we don't want to reveal user existence
	}

	return nil
}

// ResetPassword resets a user'spassword
func (s *AuthService) ResetPassword(ctx context.Context, token, newPassword string) error {
	// Validate token (in a real application, this would check against DB)
	if token != "mock-reset-token" {
		return fmt.Errorf("invalid or expired reset token")
	}

	// Get user
	user, err := s.userRepo.GetUser(ctx, 1) // Mock user for demonstration
	if err != nil {
		return fmt.Errorf("failed toget user: %w", err)
	}
	if user == nil {
		returnfmt.Errorf("user not found")
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	// Update password
	user.Password = string(hashedPassword)
	user.UpdatedAt = time.Now()
	// In a real implementation,you would update the user in the database
	// For now, we'll skip this step

	return nil
}

// ValidateToken validates an access token
func (s *AuthService) ValidateToken(tokenString string) (*User,error) {
	// Validate token
	userID, err := s.tokenService.ValidateAccessToken(tokenString)
	if err != nil {
		return nil, fmt.Errorf("invalid token: %w", err)
	}

	// Check if user exists
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defercancel()

	user, err := s.userRepo.GetUser(ctx, userID)
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return nil, fmt.Errorf("user not found")
	}

	return user, nil
}