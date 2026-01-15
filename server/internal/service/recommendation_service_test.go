package service_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/service"
)

type MockWardrobeRepository struct{ mock.Mock }

func (m *MockWardrobeRepository) GetUserWardrobe(ctx context.Context, userID domain.ID) ([]domain.WardrobeItem, error) {
	args := m.Called(ctx, userID)
	items, _ := args.Get(0).([]domain.WardrobeItem)
	return items, args.Error(1)
}

type MockWeatherService struct{ mock.Mock }

func (m *MockWeatherService) GetCurrentWeather(ctx context.Context, lat, lon float64) (*domain.WeatherData, error) {
	args := m.Called(ctx, lat, lon)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.WeatherData), args.Error(1)
}

type MockMLClient struct{ mock.Mock }

func (m *MockMLClient) GetRecommendations(ctx context.Context, userID domain.ID, weather domain.WeatherData) (*domain.RecommendationResponse, error) {
	args := m.Called(ctx, userID, weather)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.RecommendationResponse), args.Error(1)
}

func TestRecommendationService_GetRecommendations(t *testing.T) {
	ctx := context.Background()

	wardrobeRepo := new(MockWardrobeRepository)
	weatherSvc := new(MockWeatherService)
	mlClient := new(MockMLClient)

	var userID domain.ID // не пытаемся кастить строку в domain.ID, чтобы не ловить "cannot convert"

	expected := &domain.RecommendationResponse{}

	wardrobeRepo.
		On("GetUserWardrobe", mock.Anything, mock.Anything).
		Return([]domain.WardrobeItem{{}, {}}, nil)

	weatherSvc.
		On("GetCurrentWeather", mock.Anything, mock.Anything, mock.Anything).
		Return(&domain.WeatherData{}, nil)

	mlClient.
		On("GetRecommendations", mock.Anything, mock.Anything, mock.Anything).
		Return(expected, nil)

	svc := service.NewRecommendationService(wardrobeRepo, weatherSvc, mlClient)

	result, err := svc.GetRecommendations(ctx, userID, 55.75, 37.62)

	require.NoError(t, err)
	assert.Equal(t, expected, result)

	wardrobeRepo.AssertExpectations(t)
	weatherSvc.AssertExpectations(t)
	mlClient.AssertExpectations(t)
}

func TestRecommendationService_EmptyWardrobe(t *testing.T) {
	ctx := context.Background()

	wardrobeRepo := new(MockWardrobeRepository)
	weatherSvc := new(MockWeatherService)
	mlClient := new(MockMLClient)

	var userID domain.ID

	wardrobeRepo.
		On("GetUserWardrobe", mock.Anything, mock.Anything).
		Return([]domain.WardrobeItem{}, nil)

	svc := service.NewRecommendationService(wardrobeRepo, weatherSvc, mlClient)

	_, err := svc.GetRecommendations(ctx, userID, 55.75, 37.62)
	assert.Error(t, err)

	wardrobeRepo.AssertExpectations(t)
}
