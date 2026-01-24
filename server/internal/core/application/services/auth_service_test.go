package services

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"

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

func (m *MockSessionRepository) UpdateDeviceInfo(ctx context.Context, sessionID domain.ID, p repositories.UpdateDeviceInfoParams) error {
	args := m.Called(ctx, sessionID, p)
	return args.Error(0)
}

// Тест для AuthService
func TestAuthService_Register(t *testing.T) {
	// Подготовка
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	
	authService := NewAuthService(mockUserRepo, mockSessionRepo, nil, nil)

	// Тестовые данные
	input := domain.UserRegistration{
		Email:    "test@example.com",
		Password: "password123",
	}

	// Ожидания
	mockUserRepo.On("GetUserByEmail", mock.Anything, "test@example.com").Return(nil, repositories.ErrNotFound)
	mockUserRepo.On("CreateUser", mock.Anything, mock.AnythingOfType("*domain.User")).Return(nil)

	// Выполнение
	result, err := authService.Register(context.Background(), input, DeviceInfo{})

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, result.User)
	assert.NotEmpty(t, result.Tokens.AccessToken)
	assert.NotEmpty(t, result.Tokens.RefreshToken)

	// Проверка вызовов
	mockUserRepo.AssertExpectations(t)
}

func TestAuthService_Login_Success(t *testing.T) {
	// Подготовка
	mockUserRepo := new(MockUserRepository)
	mockSessionRepo := new(MockSessionRepository)
	
	authService := NewAuthService(mockUserRepo, mockSessionRepo, nil, nil)

	// Тестовые данные
	passwordHash := "$2a$10$N9qo8uLOickgxRVrF80HM.ALX9.HB2rOEq21Mp8zJEMpivZJz7z1O" // bcrypt хэш для "password123"
	user := &domain.User{
		ID:           domain.NewID(),
		Email:        "test@example.com",
		PasswordHash: passwordHash,
		IsActive:     true,
		IsVerified:   true,
	}
	loginInput := domain.UserLogin{
		Email:    "test@example.com",
		Password: "password123",
	}

	// Ожидания
	mockUserRepo.On("GetUserByEmail", mock.Anything, "test@example.com").Return(user, nil)
	mockSessionRepo.On("Create", mock.Anything, mock.AnythingOfType("repositories.CreateSessionParams")).Return(domain.NewID(), nil)

	// Выполнение
	result, err := authService.Login(context.Background(), loginInput, DeviceInfo{})

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, result.User)
	assert.NotEmpty(t, result.Tokens.AccessToken)
	assert.NotEmpty(t, result.Tokens.RefreshToken)

	// Проверка вызовов
	mockUserRepo.AssertExpectations(t)
	mockSessionRepo.AssertExpectations(t)
}