package service_test

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"

	"outfitstyle/internal/domain"
)

// Mock репозиториев
type MockWardrobeRepository struct {
	mock.Mock
}

func (m *MockWardrobeRepository) GetUserWardrobe(ctx context.Context, userID string) ([]domain.WardrobeItem, error) {
	args := m.Called(ctx, userID)
	return args.Get(0).([]domain.WardrobeItem), args.Error(1)
}

func (m *MockWardrobeRepository) SaveItem(ctx context.Context, item domain.WardrobeItem) error {
	args := m.Called(ctx, item)
	return args.Error(0)
}

type MockWeatherService struct {
	mock.Mock
}

func (m *MockWeatherService) GetCurrentWeather(ctx context.Context, lat, lon float64) (*domain.Weather, error) {
	args := m.Called(ctx, lat, lon)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.Weather), args.Error(1)
}

type MockMLClient struct {
	mock.Mock
}

func (m *MockMLClient) GetRecommendations(ctx context.Context, req domain.RecommendationRequest) ([]domain.Recommendation, error) {
	args := m.Called(ctx, req)
	return args.Get(0).([]domain.Recommendation), args.Error(1)
}

func TestRecommendationService_GetRecommendations(t *testing.T) {
	tests := []struct {
		name           string
		userID         string
		setupMocks     func(*MockWardrobeRepository, *MockWeatherService, *MockMLClient)
		expectedResult []domain.Recommendation
		expectError    bool
	}{
		{
			name:   "success_with_recommendations",
			userID: "user-123",
			setupMocks: func(wardrobeRepo *MockWardrobeRepository, weatherSvc *MockWeatherService, mlClient *MockMLClient) {
				wardrobeRepo.On("GetUserWardrobe", mock.Anything, "user-123").Return([]domain.WardrobeItem{
					{ID: "item-1", Category: "top", WarmthLevel: 3},
					{ID: "item-2", Category: "bottom", WarmthLevel: 3},
				}, nil)

				weatherSvc.On("GetCurrentWeather", mock.Anything, mock.AnythingOfType("float64"), mock.AnythingOfType("float64")).Return(&domain.Weather{
					Temperature: 20.0,
					Condition:   "sunny",
				}, nil)

				mlClient.On("GetRecommendations", mock.Anything, mock.AnythingOfType("domain.RecommendationRequest")).Return([]domain.Recommendation{
					{Items: []string{"item-1", "item-2"}, Score: 0.9},
				}, nil)
			},
			expectedResult: []domain.Recommendation{
				{Items: []string{"item-1", "item-2"}, Score: 0.9},
			},
			expectError: false,
		},
		{
			name:   "empty_wardrobe_returns_error",
			userID: "user-empty",
			setupMocks: func(wardrobeRepo *MockWardrobeRepository, weatherSvc *MockWeatherService, mlClient *MockMLClient) {
				wardrobeRepo.On("GetUserWardrobe", mock.Anything, "user-empty").Return([]domain.WardrobeItem{}, nil)
			},
			expectedResult: nil,
			expectError:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ctx := context.Background()

			wardrobeRepo := new(MockWardrobeRepository)
			weatherSvc := new(MockWeatherService)
			mlClient := new(MockMLClient)

			if tt.setupMocks != nil {
				tt.setupMocks(wardrobeRepo, weatherSvc, mlClient)
			}

			svc := NewRecommendationService(wardrobeRepo, weatherSvc, mlClient)

			result, err := svc.GetRecommendations(ctx, tt.userID, 55.75, 37.62)

			if tt.expectError {
				assert.Error(t, err)
			} else {
				require.NoError(t, err)
				assert.Equal(t, tt.expectedResult, result)
			}

			wardrobeRepo.AssertExpectations(t)
			weatherSvc.AssertExpectations(t)
			mlClient.AssertExpectations(t)
		})
	}
}

func TestRecommendationService_CalculateWarmthLevel(t *testing.T) {
	tests := []struct {
		temperature float64
		expected    int
	}{
		{-20, 5}, // Very cold
		{-5, 4},  // Cold
		{5, 3},   // Cool
		{15, 2},  // Mild
		{25, 1},  // Warm
		{35, 0},  // Hot
	}

	for _, tt := range tests {
		t.Run("", func(t *testing.T) {
			result := CalculateWarmthLevel(tt.temperature)
			assert.Equal(t, tt.expected, result)
		})
	}
}