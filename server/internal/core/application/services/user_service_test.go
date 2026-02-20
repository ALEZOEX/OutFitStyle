package services

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// MockUserRepositoryForUser - мок-реализация UserRepository для тестов UserService
type MockUserRepositoryForUser struct {
	mock.Mock
}

func (m *MockUserRepositoryForUser) GetUser(ctx context.Context, id domain.ID) (*domain.User, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepositoryForUser) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	args := m.Called(ctx, email)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepositoryForUser) CreateUser(ctx context.Context, user *domain.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func (m *MockUserRepositoryForUser) UpdateUser(ctx context.Context, user *domain.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func (m *MockUserRepositoryForUser) GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepositoryForUser) UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error) {
	args := m.Called(ctx, userID, patch)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepositoryForUser) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.UserStats), args.Error(1)
}

func (m *MockUserRepositoryForUser) GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.Achievement), args.Error(1)
}

func (m *MockUserRepositoryForUser) UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error {
	args := m.Called(ctx, userID, achievementCode)
	return args.Error(0)
}

func (m *MockUserRepositoryForUser) UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error) {
	args := m.Called(ctx, userID, prefs)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepositoryForUser) UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error) {
	args := m.Called(ctx, userID, bm)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepositoryForUser) GetDefaultCoords(ctx context.Context, userID domain.ID) (lat *float64, lon *float64, err error) {
	args := m.Called(ctx, userID)
	return args.Get(0).(*float64), args.Get(1).(*float64), args.Error(2)
}

func (m *MockUserRepositoryForUser) GetUserTimezone(ctx context.Context, userID domain.ID) (tz string, err error) {
	args := m.Called(ctx, userID)
	return args.String(0), args.Error(1)
}

func (m *MockUserRepositoryForUser) DeleteUser(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockUserRepositoryForUser) RateRecommendation(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	args := m.Called(ctx, userID, recommendationID, rating, feedback)
	return args.Error(0)
}

func (m *MockUserRepositoryForUser) UpdatePassword(ctx context.Context, userID domain.ID, newPassword string) error {
	args := m.Called(ctx, userID, newPassword)
	return args.Error(0)
}

// Тесты для UserService

func TestUserService_GetUserProfile(t *testing.T) {
	mockUserRepo := new(MockUserRepositoryForUser)
	logger := zap.NewNop()

	service := NewUserService(mockUserRepo, logger)

	ctx := context.Background()
	userID := domain.NewID()

	expectedUser := &domain.User{
		ID:          userID,
		Email:       "test@example.com",
		DisplayName: strPtr("Test User"),
		IsActive:    true,
	}

	expectedStats := &domain.UserStats{
		UserID:              userID,
		RecommendationsCount: 10,
		WardrobeSize:        5,
		CurrentStreak:       3,
		TotalPoints:         100,
	}

	mockUserRepo.On("GetUserProfile", ctx, userID).Return(expectedUser, nil)
	mockUserRepo.On("GetUserStats", ctx, userID).Return(expectedStats, nil)

	profile, err := service.GetUserProfile(ctx, userID)

	assert.NoError(t, err)
	assert.NotNil(t, profile)
	assert.Equal(t, expectedUser, profile.User)
	assert.Equal(t, expectedStats, profile.Stats)

	mockUserRepo.AssertExpectations(t)
}

func TestUserService_GetUserProfile_StatsNotFound(t *testing.T) {
	mockUserRepo := new(MockUserRepositoryForUser)
	logger := zap.NewNop()

	service := NewUserService(mockUserRepo, logger)

	ctx := context.Background()
	userID := domain.NewID()

	expectedUser := &domain.User{
		ID:          userID,
		Email:       "test@example.com",
		DisplayName: strPtr("Test User"),
		IsActive:    true,
	}

	// GetUserStats возвращает ошибку - это допустимо
	mockUserRepo.On("GetUserProfile", ctx, userID).Return(expectedUser, nil)
	mockUserRepo.On("GetUserStats", ctx, userID).Return((*domain.UserStats)(nil), repositories.ErrNotFound)

	profile, err := service.GetUserProfile(ctx, userID)

	assert.NoError(t, err)
	assert.NotNil(t, profile)
	assert.Equal(t, expectedUser, profile.User)
	assert.Nil(t, profile.Stats) // Stats может быть nil

	mockUserRepo.AssertExpectations(t)
}

func TestUserService_UpdateUserProfile(t *testing.T) {
	mockUserRepo := new(MockUserRepositoryForUser)
	logger := zap.NewNop()

	service := NewUserService(mockUserRepo, logger)

	ctx := context.Background()
	userID := domain.NewID()

	patch := domain.UserProfileUpdate{
		DisplayName: strPtr("Updated Name"),
	}

	expectedUser := &domain.User{
		ID:          userID,
		Email:       "test@example.com",
		DisplayName: patch.DisplayName,
		IsActive:    true,
	}

	expectedStats := &domain.UserStats{
		UserID:              userID,
		RecommendationsCount: 10,
		WardrobeSize:        5,
		CurrentStreak:       3,
		TotalPoints:         100,
	}

	mockUserRepo.On("UpdateUserProfile", ctx, userID, patch).Return(expectedUser, nil)
	mockUserRepo.On("GetUserStats", ctx, userID).Return(expectedStats, nil)

	profile, err := service.UpdateUserProfile(ctx, userID, patch)

	assert.NoError(t, err)
	assert.NotNil(t, profile)
	assert.Equal(t, "Updated Name", *profile.User.DisplayName)

	mockUserRepo.AssertExpectations(t)
}

func TestUserService_GetUserAchievements(t *testing.T) {
	mockUserRepo := new(MockUserRepositoryForUser)
	logger := zap.NewNop()

	service := NewUserService(mockUserRepo, logger)

	ctx := context.Background()
	userID := domain.NewID()

	expectedAchievements := []domain.Achievement{
		{Code: "first_outfit", Name: "First Outfit", Description: "Create your first outfit"},
		{Code: "week_streak", Name: "Week Streak", Description: "Use the app for 7 days in a row"},
	}

	mockUserRepo.On("GetUserAchievements", ctx, userID).Return(expectedAchievements, nil)

	achievements, err := service.GetUserAchievements(ctx, userID)

	assert.NoError(t, err)
	assert.Len(t, achievements, 2)
	assert.Equal(t, "first_outfit", achievements[0].Code)

	mockUserRepo.AssertExpectations(t)
}

func TestUserService_GetUserStats(t *testing.T) {
	mockUserRepo := new(MockUserRepositoryForUser)
	logger := zap.NewNop()

	service := NewUserService(mockUserRepo, logger)

	ctx := context.Background()
	userID := domain.NewID()

	expectedStats := &domain.UserStats{
		UserID:              userID,
		RecommendationsCount: 10,
		WardrobeSize:        5,
		CurrentStreak:       3,
		TotalPoints:         100,
	}

	mockUserRepo.On("GetUserStats", ctx, userID).Return(expectedStats, nil)

	stats, err := service.GetUserStats(ctx, userID)

	assert.NoError(t, err)
	assert.NotNil(t, stats)
	assert.Equal(t, 10, stats.RecommendationsCount)
	assert.Equal(t, 5, stats.WardrobeSize)

	mockUserRepo.AssertExpectations(t)
}

func TestUserService_UpdatePreferences(t *testing.T) {
	mockUserRepo := new(MockUserRepositoryForUser)
	logger := zap.NewNop()

	service := NewUserService(mockUserRepo, logger)

	ctx := context.Background()
	userID := domain.NewID()

	prefs := domain.UserPreferences{
		PreferredStyles:        []string{"casual", "sporty"},
		TemperatureSensitivity: intPtr(1),
		FormalityDefault:       intPtr(3),
	}

	expectedUser := &domain.User{
		ID:           userID,
		Email:        "test@example.com",
		IsActive:     true,
	}

	expectedStats := &domain.UserStats{
		UserID:              userID,
		RecommendationsCount: 10,
		WardrobeSize:        5,
		CurrentStreak:       3,
		TotalPoints:         100,
	}

	mockUserRepo.On("UpdatePreferences", ctx, userID, prefs).Return(expectedUser, nil)
	mockUserRepo.On("GetUserStats", ctx, userID).Return(expectedStats, nil)

	profile, err := service.UpdatePreferences(ctx, userID, prefs)

	assert.NoError(t, err)
	assert.NotNil(t, profile)

	mockUserRepo.AssertExpectations(t)
}

func TestUserService_UpdateBodyMeasurements(t *testing.T) {
	mockUserRepo := new(MockUserRepositoryForUser)
	logger := zap.NewNop()

	service := NewUserService(mockUserRepo, logger)

	ctx := context.Background()
	userID := domain.NewID()

	measurements := domain.BodyMeasurements{
		Height: intPtr(175),
		Weight: intPtr(70),
	}

	expectedUser := &domain.User{
		ID:             userID,
		Email:          "test@example.com",
		IsActive:       true,
	}

	expectedStats := &domain.UserStats{
		UserID:              userID,
		RecommendationsCount: 10,
		WardrobeSize:        5,
		CurrentStreak:       3,
		TotalPoints:         100,
	}

	mockUserRepo.On("UpdateBodyMeasurements", ctx, userID, measurements).Return(expectedUser, nil)
	mockUserRepo.On("GetUserStats", ctx, userID).Return(expectedStats, nil)

	profile, err := service.UpdateBodyMeasurements(ctx, userID, measurements)

	assert.NoError(t, err)
	assert.NotNil(t, profile)

	mockUserRepo.AssertExpectations(t)
}

// Вспомогательная функция для получения указателя на int
func intPtr(i int) *int {
	return &i
}

// Вспомогательная функция для получения указателя на строку
func strPtr(s string) *string {
	return &s
}
