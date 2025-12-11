package services

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log"
	"time"

	"outfitstyle/server/internal/core/domain"

	"golang.org/x/crypto/bcrypt"
)

// UserRepository defines the interface for user data operations
type UserRepository interface {
	GetUser(ctx context.Context, id int) (*domain.User, error)
	GetUserByEmail(ctx context.Context, email string) (*domain.User, error)
	CreateUser(ctx context.Context, user *domain.User) error
	UpdateUser(ctx context.Context, user *domain.User) error
}

// AuthService handles authentication-related operations
type AuthService struct {
	userRepo            UserRepository
	emailService        EmailService
	tokenService        *TokenService
	verificationDB      map[string]domain.VerificationCode
	blacklistDB         map[string]bool
	passwordResetTokens map[string]PasswordResetToken
	passwordResetLimiter map[string]time.Time // email -> время последнего запроса
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
	config AuthConfig,
) *AuthService {
	return &AuthService{
		userRepo:            userRepo,
		emailService:        emailService,
		tokenService:        tokenService,
		verificationDB:      make(map[string]domain.VerificationCode),
		blacklistDB:         make(map[string]bool),
		passwordResetTokens: make(map[string]PasswordResetToken),
		passwordResetLimiter: make(map[string]time.Time),
	}
}

// RegisterUser registers a new user
func (s *AuthService) RegisterUser(ctx context.Context, userInput domain.UserRegistration) (*domain.User, error) {
	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(userInput.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, fmt.Errorf("failed to hash password: %w", err)
	}

	// Create user
	user := &domain.User{
		Email:      userInput.Email,
		Password:   string(hashedPassword),
		Username:   userInput.Username,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
		IsVerified: false,
	}

	// Сохраняем пользователя в БД
	if err := s.userRepo.CreateUser(ctx, user); err != nil {
		return nil, fmt.Errorf("failed to create user: %w", err)
	}

	// Generate verification code
	code, err := s.generateVerificationCode(6)
	if err != nil {
		return nil, fmt.Errorf("failed to generate verification code: %w", err)
	}

	// Save verification code
	verification := domain.VerificationCode{
		Code:      code,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(10 * time.Minute),
		Type:      "registration",
	}
	s.verificationDB[code] = verification

	// Send verification email
	if err := s.emailService.SendVerificationEmail(user.Email, code); err != nil {
		log.Printf("Warning: failed to send verification email: %v", err)
	}

	return user, nil
}

// LoginUser initiates login process
func (s *AuthService) LoginUser(ctx context.Context, email, password string) (string, error) {
	// Ищем пользователя по email
	user, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil || user == nil {
		return "", fmt.Errorf("invalid credentials")
	}

	// Проверяем пароль
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
		return "", fmt.Errorf("invalid credentials")
	}

	// Generate verification code
	code, err := s.generateVerificationCode(6)
	if err != nil {
		return "", fmt.Errorf("failed to generate verification code: %w", err)
	}

	verification := domain.VerificationCode{
		Code:      code,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(10 * time.Minute),
		Type:      "login",
	}
	s.verificationDB[code] = verification

	if err := s.emailService.SendVerificationEmail(user.Email, code); err != nil {
		log.Printf("Warning: failed to send verification email: %v", err)
	}

	return code, nil
}

// VerifyCode verifies a verification code
func (s *AuthService) VerifyCode(ctx context.Context, code string) (*domain.User, string, error) {
	verification, ok := s.verificationDB[code]
	if !ok {
		return nil, "", fmt.Errorf("invalid verification code")
	}

	if time.Now().After(verification.ExpiresAt) {
		delete(s.verificationDB, code)
		return nil, "", fmt.Errorf("verification code expired")
	}

	user, err := s.userRepo.GetUser(ctx, int(verification.UserID))
	if err != nil {
		return nil, "", fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return nil, "", fmt.Errorf("user not found")
	}

	if verification.Type == "registration" {
		user.IsVerified = true
		user.UpdatedAt = time.Now()
		if err := s.userRepo.UpdateUser(ctx, user); err != nil {
			return nil, "", fmt.Errorf("failed to update user: %w", err)
		}
	}

	accessToken, err := s.tokenService.GenerateAccessToken(user)
	if err != nil {
		return nil, "", fmt.Errorf("failed to generate access token: %w", err)
	}

	delete(s.verificationDB, code)

	return user, accessToken, nil
}

// RefreshToken refreshes an access token
func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string) (string, error) {
	userID, err := s.tokenService.ValidateRefreshToken(refreshToken)
	if err != nil {
		return "", fmt.Errorf("invalid refresh token: %w", err)
	}

	if s.blacklistDB[refreshToken] {
		return "", fmt.Errorf("token has been revoked")
	}

	user, err := s.userRepo.GetUser(ctx, int(userID))
	if err != nil {
		return "", fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return "", fmt.Errorf("user not found")
	}

	accessToken, err := s.tokenService.GenerateAccessToken(user)
	if err != nil {
		return "", fmt.Errorf("failed to generate accesstoken: %w", err)
	}

	return accessToken, nil
}

// RevokeToken revokes a refresh token
func (s *AuthService) RevokeToken(refreshToken string) {
	s.blacklistDB[refreshToken] = true
}

// generateVerificationCode generates a random verification code
func (s *AuthService) generateVerificationCode(length int) (string, error) {
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(bytes)[:length], nil
}

// PasswordResetToken holds information about a password reset token
type PasswordResetToken struct {
	Token     string
	UserID    domain.ID
	ExpiresAt time.Time
}

// ForgotPassword initiates password reset process
func (s *AuthService) ForgotPassword(ctx context.Context, email string) error {
	// Очищаем устаревшие данные
	s.cleanupExpiredData()

	user, err := s.userRepo.GetUserByEmail(ctx, email)
	if err != nil || user == nil {
		// не раскрываем, есть ли пользователь
		return nil
	}

	// Проверяем ограничение частоты запросов - один раз в 5 минут
	if lastRequest, exists := s.passwordResetLimiter[email]; exists {
		if time.Since(lastRequest) < 5*time.Minute {
			// Не раскрываем причину, просто выходим
			return nil
		}
	}
	s.passwordResetLimiter[email] = time.Now()

	resetToken, err := s.generatePasswordResetToken(32) // 32-byte token
	if err != nil {
		return fmt.Errorf("failed to generate password reset token: %w", err)
	}

	// Сохраняем токен с временем истечения
	reset := PasswordResetToken{
		Token:     resetToken,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(24 * time.Hour), // токен действителен 24 часа
	}

	s.passwordResetTokens[resetToken] = reset

	if err := s.emailService.SendPasswordResetEmail(user.Email, resetToken); err != nil {
		log.Printf("Warning: failed to send password reset email: %v", err)
	}

	return nil
}

// ResetPassword resets a user's password
func (s *AuthService) ResetPassword(ctx context.Context, token, newPassword string) error {
	// Очищаем устаревшие данные
	s.cleanupExpiredData()

	// Проверяем токен
	reset, exists := s.passwordResetTokens[token]
	if !exists {
		return fmt.Errorf("invalid or expired reset token")
	}

	user, err := s.userRepo.GetUser(ctx, int(reset.UserID))
	if err != nil {
		return fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return fmt.Errorf("user not found")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	user.Password = string(hashedPassword)
	user.UpdatedAt = time.Now()

	if err := s.userRepo.UpdateUser(ctx, user); err != nil {
		return fmt.Errorf("failed to update user password: %w", err)
	}

	// Удаляем использованный токен
	delete(s.passwordResetTokens, token)

	return nil
}

// generatePasswordResetToken generates a random password reset token
func (s *AuthService) generatePasswordResetToken(length int) (string, error) {
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return base64.URLEncoding.EncodeToString(bytes), nil
}

// cleanupExpiredData удаляет устаревшие данные из хранилищ
func (s *AuthService) cleanupExpiredData() {
	now := time.Now()

	// Очищаем устаревшие токены сброса пароля
	for token, reset := range s.passwordResetTokens {
		if now.After(reset.ExpiresAt) {
			delete(s.passwordResetTokens, token)
		}
	}

	// Очищаем устаревшие ограничения частоты (старше 1 часа)
	for email, lastRequest := range s.passwordResetLimiter {
		if now.Sub(lastRequest) > time.Hour {
			delete(s.passwordResetLimiter, email)
		}
	}
}

// ValidateToken validates an access token and returns the associated user.
func (s *AuthService) ValidateToken(tokenString string) (*domain.User, error) {
	// Очищаем устаревшие данные периодически
	s.cleanupExpiredData()

	userID, err := s.tokenService.ValidateAccessToken(tokenString)
	if err != nil {
		return nil, fmt.Errorf("invalid token: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	user, err := s.userRepo.GetUser(ctx, int(userID))
	if err != nil {
		return nil, fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return nil, fmt.Errorf("user not found")
	}

	return user, nil
}

// ===== Дополнения для Google OAuth =====

// GetUserByEmail ищет пользователя по email
func (s *AuthService) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	return s.userRepo.GetUserByEmail(ctx, email)
}

// RegisterOAuthUser регистрирует пользователя через OAuth (Google)
func (s *AuthService) RegisterOAuthUser(ctx context.Context, input domain.UserRegistration) (*domain.User, error) {
	user := &domain.User{
		Email:      input.Email,
		Password:   "",
		Username:   input.Username,
		IsVerified: true,
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	if err := s.userRepo.CreateUser(ctx, user); err != nil {
		return nil, fmt.Errorf("failed to create oauth user: %w", err)
	}

	return user, nil
}

// GenerateTokens генерирует access + (пока пустой) refresh токен
func (s *AuthService) GenerateTokens(userID domain.ID) (string, string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	user, err := s.userRepo.GetUser(ctx, int(userID))
	if err != nil {
		return "", "", fmt.Errorf("failed to get user: %w", err)
	}
	if user == nil {
		return "", "", fmt.Errorf("user not found")
	}

	accessToken, err := s.tokenService.GenerateAccessToken(user)
	if err != nil {
		return "", "", fmt.Errorf("failed to generate access token: %w", err)
	}

	// Пока refresh-токен не используем
	refreshToken := ""

	return accessToken, refreshToken, nil
}
