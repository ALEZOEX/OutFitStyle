package services

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"outfitstyle/server/internal/core/domain"
)

func TestTokenService_HS256_GenerateAndValidate(t *testing.T) {
	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key-minimum-32-chars",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)
	require.NotNil(t, service)

	userID := domain.NewID()
	sessionID := domain.NewID()

	// Генерация access токена
	token, expiresAt, err := service.GenerateAccessToken(userID, sessionID)
	require.NoError(t, err)
	assert.NotEmpty(t, token)
	assert.WithinDuration(t, time.Now().Add(15*time.Minute), expiresAt, 2*time.Second)

	// Валидация токена
	validatedUserID, validatedSessionID, _, err := service.ValidateAccessToken(token)
	require.NoError(t, err)
	assert.Equal(t, userID, validatedUserID)
	assert.Equal(t, sessionID, validatedSessionID)
}

func TestTokenService_HS256_InvalidToken(t *testing.T) {
	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	// Неверный токен
	_, _, _, err = service.ValidateAccessToken("invalid.token.here")
	assert.Error(t, err)

	// Пустой токен
	_, _, _, err = service.ValidateAccessToken("")
	assert.Error(t, err)
}

func TestTokenService_HS256_ExpiredToken(t *testing.T) {
	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  1 * time.Millisecond, // Очень короткое время жизни
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	userID := domain.NewID()
	sessionID := domain.NewID()

	token, _, err := service.GenerateAccessToken(userID, sessionID)
	require.NoError(t, err)

	// Ждём истечения токена
	time.Sleep(10 * time.Millisecond)

	_, _, _, err = service.ValidateAccessToken(token)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "expired")
}

func TestTokenService_GenerateRefreshToken(t *testing.T) {
	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	// Генерация refresh токена
	token1, err := service.GenerateRefreshToken()
	require.NoError(t, err)
	assert.NotEmpty(t, token1)

	// Второй токен должен отличаться
	token2, err := service.GenerateRefreshToken()
	require.NoError(t, err)
	assert.NotEqual(t, token1, token2)
}

func TestTokenService_HashRefreshToken(t *testing.T) {
	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	refreshToken, err := service.GenerateRefreshToken()
	require.NoError(t, err)

	// Хеширование токена
	hash1 := service.HashRefreshToken(refreshToken)
	assert.NotEmpty(t, hash1)

	// Тот же токен должен давать тот же хеш
	hash2 := service.HashRefreshToken(refreshToken)
	assert.Equal(t, hash1, hash2)

	// Разные токены дают разные хеши
	refreshToken2, _ := service.GenerateRefreshToken()
	hash3 := service.HashRefreshToken(refreshToken2)
	assert.NotEqual(t, hash1, hash3)
}

func TestTokenService_AccessTTL(t *testing.T) {
	expectedTTL := 30 * time.Minute

	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  expectedTTL,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	assert.Equal(t, expectedTTL, service.AccessTTL())
}

func TestTokenService_RefreshTTL(t *testing.T) {
	expectedTTL := 7 * 24 * time.Hour

	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: expectedTTL,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	assert.Equal(t, expectedTTL, service.RefreshTTL())
}

func TestTokenService_TokenClaims(t *testing.T) {
	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	userID := domain.NewID()
	sessionID := domain.NewID()

	token, _, err := service.GenerateAccessToken(userID, sessionID)
	require.NoError(t, err)

	// Проверяем, что токен содержит правильные claims
	validatedUserID, validatedSessionID, _, err := service.ValidateAccessToken(token)
	require.NoError(t, err)

	assert.Equal(t, userID.String(), validatedUserID.String())
	assert.Equal(t, sessionID.String(), validatedSessionID.String())
}

func TestTokenService_DifferentUsers(t *testing.T) {
	cfg := TokenServiceConfig{
		JWTSecret:  "test-secret-key",
		AccessTTL:  15 * time.Minute,
		RefreshTTL: 24 * time.Hour,
		UseRS256:   false,
	}

	service, err := NewTokenService(cfg)
	require.NoError(t, err)

	userID1 := domain.NewID()
	userID2 := domain.NewID()
	sessionID := domain.NewID()

	// Генерируем токены для разных пользователей
	token1, _, err := service.GenerateAccessToken(userID1, sessionID)
	require.NoError(t, err)

	token2, _, err := service.GenerateAccessToken(userID2, sessionID)
	require.NoError(t, err)

	// Валидируем токены
	validatedUserID1, _, _, err := service.ValidateAccessToken(token1)
	require.NoError(t, err)

	validatedUserID2, _, _, err := service.ValidateAccessToken(token2)
	require.NoError(t, err)

	// Пользователи должны быть разными
	assert.NotEqual(t, validatedUserID1, validatedUserID2)
	assert.Equal(t, userID1, validatedUserID1)
	assert.Equal(t, userID2, validatedUserID2)
}
