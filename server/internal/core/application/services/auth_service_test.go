package services

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// MockUserRepository - мок-реализация UserRepository для тестов
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) GetUser(ctx context.Context, id domain.ID) (*domain.User, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	args := m.Called(ctx, email)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func (m *MockUserRepository) UpdateUser(ctx context.Context, user *domain.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func (m *MockUserRepository) GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error) {
	args := m.Called(ctx, userID, patch)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.UserStats), args.Error(1)
}

func (m *MockUserRepository) GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.Achievement), args.Error(1)
}

func (m *MockUserRepository) UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error {
	args := m.Called(ctx, userID, achievementCode)
	return args.Error(0)
}

func (m *MockUserRepository) UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error) {
	args := m.Called(ctx, userID, prefs)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error) {
	args := m.Called(ctx, userID, bm)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetDefaultCoords(ctx context.Context, userID domain.ID) (lat *float64, lon *float64, err error) {
	args := m.Called(ctx, userID)
	return args.Get(0).(*float64), args.Get(1).(*float64), args.Error(2)
}

func (m *MockUserRepository) GetUserTimezone(ctx context.Context, userID domain.ID) (tz string, err error) {
	args := m.Called(ctx, userID)
	return args.String(0), args.Error(1)
}

func (m *MockUserRepository) DeleteUser(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockUserRepository) RateRecommendation(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	args := m.Called(ctx, userID, recommendationID, rating, feedback)
	return args.Error(0)
}

func (m *MockUserRepository) UpdatePassword(ctx context.Context, userID domain.ID, newPassword string) error {
	args := m.Called(ctx, userID, newPassword)
	return args.Error(0)
}

// MockSessionRepository - мок-реализация SessionRepository для тестов
type MockSessionRepository struct {
	mock.Mock
}

func (m *MockSessionRepository) Create(ctx context.Context, p repositories.CreateSessionParams) (domain.ID, error) {
	args := m.Called(ctx, p)
	return args.Get(0).(domain.ID), args.Error(1)
}

func (m *MockSessionRepository) GetByID(ctx context.Context, sessionID domain.ID) (*repositories.Session, error) {
	args := m.Called(ctx, sessionID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*repositories.Session), args.Error(1)
}

func (m *MockSessionRepository) GetByRefreshHash(ctx context.Context, refreshHash string) (*repositories.Session, error) {
	args := m.Called(ctx, refreshHash)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*repositories.Session), args.Error(1)
}

func (m *MockSessionRepository) RotateRefresh(ctx context.Context, sessionID domain.ID, newRefreshHash string, newExpiresAt time.Time) error {
	args := m.Called(ctx, sessionID, newRefreshHash, newExpiresAt)
	return args.Error(0)
}

func (m *MockSessionRepository) Touch(ctx context.Context, sessionID domain.ID) error {
	args := m.Called(ctx, sessionID)
	return args.Error(0)
}

func (m *MockSessionRepository) Revoke(ctx context.Context, sessionID domain.ID) error {
	args := m.Called(ctx, sessionID)
	return args.Error(0)
}

func (m *MockSessionRepository) RevokeAllForUser(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockSessionRepository) RevokeForUser(ctx context.Context, userID domain.ID, sessionID domain.ID) error {
	args := m.Called(ctx, userID, sessionID)
	return args.Error(0)
}

func (m *MockSessionRepository) ListByUser(ctx context.Context, userID domain.ID) ([]repositories.Session, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]repositories.Session), args.Error(1)
}

// MockTokenBlacklist - мок-реализация TokenBlacklist для тестов
type MockTokenBlacklist struct {
	mock.Mock
}

func (m *MockTokenBlacklist) IsBlacklisted(ctx context.Context, jti string) (bool, error) {
	args := m.Called(ctx, jti)
	return args.Bool(0), args.Error(1)
}

func (m *MockTokenBlacklist) Add(ctx context.Context, jti string, ttl time.Duration) error {
	args := m.Called(ctx, jti, ttl)
	return args.Error(0)
}

func (m *MockTokenBlacklist) Remove(ctx context.Context, jti string) error {
	args := m.Called(ctx, jti)
	return args.Error(0)
}

func (m *MockSessionRepository) UpdateDeviceInfo(ctx context.Context, sessionID domain.ID, p repositories.UpdateDeviceInfoParams) error {
	args := m.Called(ctx, sessionID, p)
	return args.Error(0)
}

// MockTokenService - мок-реализация TokenService для тестов
type MockTokenService struct {
	mock.Mock
}

func (m *MockTokenService) GenerateRefreshToken() (string, error) {
	args := m.Called()
	return args.String(0), args.Error(1)
}

func (m *MockTokenService) HashRefreshToken(refreshToken string) string {
	args := m.Called(refreshToken)
	return args.String(0)
}

func (m *MockTokenService) GenerateAccessToken(userID, sessionID domain.ID) (token string, expiresAt time.Time, err error) {
	args := m.Called(userID, sessionID)
	return args.String(0), args.Get(1).(time.Time), args.Error(2)
}

func (m *MockTokenService) ValidateAccessToken(tokenString string) (userID domain.ID, sessionID domain.ID, jti string, err error) {
	args := m.Called(tokenString)
	return args.Get(0).(domain.ID), args.Get(1).(domain.ID), args.String(2), args.Error(3)
}

func (m *MockTokenService) AccessTTL() time.Duration {
	args := m.Called()
	return args.Get(0).(time.Duration)
}

func (m *MockTokenService) RefreshTTL() time.Duration {
	args := m.Called()
	return args.Get(0).(time.Duration)
}

// Тест для AuthService
func TestAuthService_Register(t *testing.T) {
	// Подготовка
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil, new(MockTokenBlacklist), zap.NewNop())

	// Тестовые данные
	input := domain.UserRegistration{
		Email:    "test@example.com",
		Password: "SecureP@ssw0rd123",  // 12+ символов: uppercase, lowercase, digit, special
	}

	// Ожидания
	mockUserRepo.On("GetUserByEmail", mock.Anything, "test@example.com").Return(nil, repositories.ErrNotFound)
	mockUserRepo.On("CreateUser", mock.Anything, mock.AnythingOfType("*domain.User")).Return(nil)

	// Mock token service calls
	mockTokenSvc.On("GenerateRefreshToken").Return("refresh_token_mock", nil)
	mockTokenSvc.On("HashRefreshToken", "refresh_token_mock").Return("hashed_refresh_token")
	mockTokenSvc.On("GenerateAccessToken", mock.Anything, mock.Anything).Return("access_token_mock", time.Now().Add(time.Hour), nil)
	mockTokenSvc.On("RefreshTTL").Return(time.Hour)
	mockSessionRepo.On("Create", mock.Anything, mock.Anything).Return(domain.NewID(), nil)

	// Выполнение
	result, err := authService.Register(context.Background(), input, DeviceInfo{})

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, result.User)
	assert.NotEmpty(t, result.Tokens.AccessToken)
	assert.NotEmpty(t, result.Tokens.RefreshToken)

	// Проверка вызовов
	mockUserRepo.AssertExpectations(t)
	mockTokenSvc.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
}

func TestAuthService_Login_Success(t *testing.T) {
	// Подготовка
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	mockTokenSvc := new(MockTokenService)

	authService := NewAuthService(mockUserRepo, mockSessionRepo, mockTokenSvc, nil, new(MockTokenBlacklist), zap.NewNop())

	// Тестовые данные
	password := "SecureP@ssw0rd123"  // 12+ символов: uppercase, lowercase, digit, special
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(password), 12)
	if err != nil {
		t.Fatalf("Failed to generate password hash: %v", err)
	}
	user := &domain.User{
		ID:           domain.NewID(),
		Email:        "test@example.com",
		PasswordHash: string(passwordHash),
		IsActive:     true,
		IsVerified:   true,
	}
	loginInput := domain.UserLogin{
		Email:    "test@example.com",
		Password: "SecureP@ssw0rd123",
	}

	// Ожидания
	mockUserRepo.On("GetUserByEmail", mock.Anything, mock.Anything).Return(user, nil)

	// Mock token service calls
	mockTokenSvc.On("GenerateRefreshToken").Return("refresh_token_mock", nil)
	mockTokenSvc.On("HashRefreshToken", "refresh_token_mock").Return("hashed_refresh_token")
	mockTokenSvc.On("GenerateAccessToken", mock.Anything, mock.Anything).Return("access_token_mock", time.Now().Add(time.Hour), nil)
	mockTokenSvc.On("RefreshTTL").Return(time.Hour)
	mockSessionRepo.On("Create", mock.Anything, mock.Anything).Return(domain.NewID(), nil)

	// Выполнение
	result, err := authService.Login(context.Background(), loginInput, DeviceInfo{})

	// Проверка
	require.NoError(t, err)
	assert.NotNil(t, result.User)
	assert.NotEmpty(t, result.Tokens.AccessToken)
	assert.NotEmpty(t, result.Tokens.RefreshToken)

	// Проверка вызовов
	mockUserRepo.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
	mockTokenSvc.AssertExpectations(t)
}
