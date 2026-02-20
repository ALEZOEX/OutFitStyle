package services

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// TestAuthService_Register_DuplicateEmail тестирует регистрацию с существующим email
func TestAuthService_Register_DuplicateEmail(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	input := domain.UserRegistration{
		Email:    "existing@example.com",
		Password: "password123",
	}

	existingUser := &domain.User{
		ID:           domain.NewID(),
		Email:        "existing@example.com",
		PasswordHash: "hashed_password",
	}

	mockUserRepo.On("GetUserByEmail", mock.Anything, "existing@example.com").Return(existingUser, nil)

	result, err := authService.Register(context.Background(), input, DeviceInfo{})

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.ErrorIs(t, err, repositories.ErrEmailAlreadyExists)

	mockUserRepo.AssertExpectations(t)
}

// TestAuthService_Register_ValidationError тестирует валидацию при регистрации
func TestAuthService_Register_ValidationError(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	input := domain.UserRegistration{
		Email:    "", // Неверный email
		Password: "", // Неверный пароль
	}

	result, err := authService.Register(context.Background(), input, DeviceInfo{})

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.IsType(t, &ValidationError{}, err)
}

// TestAuthService_Login_UserNotFound тестирует вход с несуществующим пользователем
func TestAuthService_Login_UserNotFound(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	loginInput := domain.UserLogin{
		Email:    "nonexistent@example.com",
		Password: "password123",
	}

	mockUserRepo.On("GetUserByEmail", mock.Anything, "nonexistent@example.com").Return(nil, repositories.ErrNotFound)

	result, err := authService.Login(context.Background(), loginInput, DeviceInfo{})

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.ErrorIs(t, err, ErrInvalidCredentials)

	mockUserRepo.AssertExpectations(t)
}

// TestAuthService_Login_WrongPassword тестирует вход с неверным паролем
func TestAuthService_Login_WrongPassword(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	password := "password123"
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	require.NoError(t, err)

	user := &domain.User{
		ID:           domain.NewID(),
		Email:        "test@example.com",
		PasswordHash: string(passwordHash),
		IsActive:     true,
		IsVerified:   true,
	}

	loginInput := domain.UserLogin{
		Email:    "test@example.com",
		Password: "wrongpassword",
	}

	mockUserRepo.On("GetUserByEmail", mock.Anything, "test@example.com").Return(user, nil)

	result, err := authService.Login(context.Background(), loginInput, DeviceInfo{})

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.ErrorIs(t, err, ErrInvalidCredentials)

	mockUserRepo.AssertExpectations(t)
}

// TestAuthService_Login_EmptyCredentials тестирует вход с пустыми учетными данными
func TestAuthService_Login_EmptyCredentials(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	loginInput := domain.UserLogin{
		Email:    "",
		Password: "",
	}

	result, err := authService.Login(context.Background(), loginInput, DeviceInfo{})

	assert.Error(t, err)
	assert.Nil(t, result)
	assert.ErrorIs(t, err, ErrInvalidCredentials)
}

// TestAuthService_Refresh_EmptyToken тестирует обновление с пустым refresh-токеном
func TestAuthService_Refresh_EmptyToken(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	result, err := authService.Refresh(context.Background(), "")

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrUnauthorized)
	assert.Empty(t, result.AccessToken)
	assert.Empty(t, result.RefreshToken)
}

// TestAuthService_Refresh_InvalidToken тестирует обновление с недействительным refresh-токеном
func TestAuthService_Refresh_InvalidToken(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	mockTokenSvc.On("HashRefreshToken", "invalid_token").Return("hashed_invalid_token")
	mockSessionRepo.On("GetByRefreshHash", mock.Anything, "hashed_invalid_token").Return(nil, repositories.ErrNotFound)

	result, err := authService.Refresh(context.Background(), "invalid_token")

	assert.Error(t, err)
	assert.Empty(t, result.AccessToken)
	assert.Empty(t, result.RefreshToken)

	mockTokenSvc.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
}

// TestAuthService_Refresh_ExpiredSession тестирует обновление с истекшей сессией
func TestAuthService_Refresh_ExpiredSession(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	expiredTime := time.Now().Add(-time.Hour)
	session := &repositories.Session{
		ID:        domain.NewID(),
		UserID:    domain.NewID(),
		IsActive:  true,
		ExpiresAt: &expiredTime,
	}

	mockTokenSvc.On("HashRefreshToken", "expired_token").Return("hashed_expired_token")
	mockSessionRepo.On("GetByRefreshHash", mock.Anything, "hashed_expired_token").Return(session, nil)

	result, err := authService.Refresh(context.Background(), "expired_token")

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrUnauthorized)
	assert.Empty(t, result.AccessToken)
	assert.Empty(t, result.RefreshToken)

	mockTokenSvc.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
}

// TestAuthService_Refresh_InactiveSession тестирует обновление с неактивной сессией
func TestAuthService_Refresh_InactiveSession(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	futureTime := time.Now().Add(time.Hour)
	session := &repositories.Session{
		ID:        domain.NewID(),
		UserID:    domain.NewID(),
		IsActive:  false, // Неактивная сессия
		ExpiresAt: &futureTime,
	}

	mockTokenSvc.On("HashRefreshToken", "inactive_token").Return("hashed_inactive_token")
	mockSessionRepo.On("GetByRefreshHash", mock.Anything, "hashed_inactive_token").Return(session, nil)

	result, err := authService.Refresh(context.Background(), "inactive_token")

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrUnauthorized)
	assert.Empty(t, result.AccessToken)
	assert.Empty(t, result.RefreshToken)

	mockTokenSvc.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
}

// TestAuthService_Logout_AllDevices тестирует выход со всех устройств
func TestAuthService_Logout_AllDevices(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	userID := domain.NewID()
	sessionID := domain.NewID()

	mockSessionRepo.On("RevokeAllForUser", mock.Anything, userID).Return(nil)

	err := authService.Logout(context.Background(), userID, sessionID, true)

	require.NoError(t, err)
	mockSessionRepo.AssertExpectations(t)
}

// TestAuthService_Logout_SingleDevice тестирует выход с одного устройства
func TestAuthService_Logout_SingleDevice(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	userID := domain.NewID()
	sessionID := domain.NewID()

	mockSessionRepo.On("Revoke", mock.Anything, sessionID).Return(nil)

	err := authService.Logout(context.Background(), userID, sessionID, false)

	require.NoError(t, err)
	mockSessionRepo.AssertExpectations(t)
}

// TestAuthService_ValidateAccessToken_InvalidToken тестирует проверку недействительного access-токена
func TestAuthService_ValidateAccessToken_InvalidToken(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	mockTokenSvc.On("ValidateAccessToken", "invalid_token").Return(domain.ID{}, domain.ID{}, assert.AnError)

	userID, sessionID, err := authService.ValidateAccessToken(context.Background(), "invalid_token")

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrUnauthorized)
	assert.Empty(t, userID)
	assert.Empty(t, sessionID)

	mockTokenSvc.AssertExpectations(t)
}

// TestAuthService_ValidateAccessToken_SessionNotFound тестирует проверку токена с несуществующей сессией
func TestAuthService_ValidateAccessToken_SessionNotFound(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	userID := domain.NewID()
	sessionID := domain.NewID()

	mockTokenSvc.On("ValidateAccessToken", "valid_token").Return(userID, sessionID, nil)
	mockSessionRepo.On("GetByID", mock.Anything, sessionID).Return(nil, repositories.ErrNotFound)

	resultUserID, resultSessionID, err := authService.ValidateAccessToken(context.Background(), "valid_token")

	assert.Error(t, err)
	assert.ErrorIs(t, err, ErrUnauthorized)
	assert.Empty(t, resultUserID)
	assert.Empty(t, resultSessionID)

	mockTokenSvc.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
}

// TestAuthService_ValidateAccessToken_Success тестирует успешную проверку токена
func TestAuthService_ValidateAccessToken_Success(t *testing.T) {
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil)

	userID := domain.NewID()
	sessionID := domain.NewID()
	now := time.Now()

	session := &repositories.Session{
		ID:        sessionID,
		UserID:    userID,
		IsActive:  true,
		ExpiresAt: &now,
	}
	// Устанавливаем время истечения в будущее
	futureTime := time.Now().Add(time.Hour)
	session.ExpiresAt = &futureTime

	mockTokenSvc.On("ValidateAccessToken", "valid_token").Return(userID, sessionID, nil)
	mockSessionRepo.On("GetByID", mock.Anything, sessionID).Return(session, nil)
	mockSessionRepo.On("Touch", mock.Anything, sessionID).Return(nil)

	resultUserID, resultSessionID, err := authService.ValidateAccessToken(context.Background(), "valid_token")

	require.NoError(t, err)
	assert.Equal(t, userID, resultUserID)
	assert.Equal(t, sessionID, resultSessionID)

	mockTokenSvc.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
}

// TestExtractIP тестирует функцию извлечения IP-адреса
func TestExtractIP(t *testing.T) {
	tests := []struct {
		name       string
		remoteAddr string
		want       string
	}{
		{"valid IPv4 with port", "192.168.1.1:8080", "192.168.1.1"},
		{"valid IPv4 without port", "192.168.1.1", "192.168.1.1"},
		{"empty string", "", ""},
		{"localhost with port", "127.0.0.1:3000", "127.0.0.1"},
		{"IPv6 with port", "[::1]:8080", "::1"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := ExtractIP(tt.remoteAddr)
			if tt.want == "" {
				assert.Nil(t, got)
			} else {
				require.NotNil(t, got)
				assert.Equal(t, tt.want, *got)
			}
		})
	}
}
