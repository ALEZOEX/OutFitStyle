package adapters

import (
	"context"
	"errors"
	"testing"
	"time"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockMLClient is a mock implementation of the ML client interface
// ИЗМЕНЕНИЯ (Март 2026): обновлено под новый API с items_by_category
type MockMLClient struct {
	mock.Mock
}

func (m *MockMLClient) Rank(ctx context.Context, req external.TZMLRankRequest) (external.TZMLRankResponse, error) {
	args := m.Called(ctx, req)
	return args.Get(0).(external.TZMLRankResponse), args.Error(1)
}

func (m *MockMLClient) SendAction(ctx context.Context, req external.ActionRequest) (external.ActionResponse, error) {
	args := m.Called(ctx, req)
	return args.Get(0).(external.ActionResponse), args.Error(1)
}

func (m *MockMLClient) HealthCheck(ctx context.Context) external.HealthCheckResult {
	args := m.Called(ctx)
	return args.Get(0).(external.HealthCheckResult)
}

func (m *MockMLClient) GenerateOutfit(ctx context.Context, userID string, meta map[string]any) (external.GenerateOutfitResponse, error) {
	args := m.Called(ctx, userID, meta)
	return args.Get(0).(external.GenerateOutfitResponse), args.Error(1)
}

func (m *MockMLClient) GenerateRecommendation(ctx context.Context, req external.GenerateRecommendationRequest) (external.GenerateRecommendationResponse, error) {
	args := m.Called(ctx, req)
	return args.Get(0).(external.GenerateRecommendationResponse), args.Error(1)
}

func (m *MockMLClient) ProcessFeedback(ctx context.Context, userID string, requestID string, meta map[string]any) error {
	args := m.Called(ctx, userID, requestID, meta)
	return args.Error(0)
}

func (m *MockMLClient) UpdateUserPreferences(ctx context.Context, userID string, requestID string, meta map[string]any) error {
	args := m.Called(ctx, userID, requestID, meta)
	return args.Error(0)
}

func TestMLServiceAdapter_GetRecommendations(t *testing.T) {
	tests := []struct {
		name            string
		userID          domain.ID
		weather         domain.WeatherData
		itemsByCategory map[string][]domain.ClothingItem
		mockReturn      external.GenerateRecommendationResponse
		mockError       error
		expectedError   bool
	}{
		{
			name:   "successful recommendation retrieval",
			userID: domain.NewID(),
			weather: domain.WeatherData{
				Location:    "Test City",
				Temperature: 25.0,
				FeelsLike:   26.0,
				Humidity:    60,
				WindSpeed:   5.0,
				Weather:     "sunny",
			},
			itemsByCategory: map[string][]domain.ClothingItem{
				"upper": {
					{
						ID:          domain.NewID(),
						Name:        "T-Shirt",
						Category:    "upper",
						Subcategory: "tshirt",
						BaseColour:  strPtr("white"),
					},
				},
				"lower": {
					{
						ID:          domain.NewID(),
						Name:        "Jeans",
						Category:    "lower",
						Subcategory: "jeans",
						BaseColour:  strPtr("blue"),
					},
				},
				"footwear": {
					{
						ID:          domain.NewID(),
						Name:        "Sneakers",
						Category:    "footwear",
						Subcategory: "sneakers",
						BaseColour:  strPtr("white"),
					},
				},
			},
			mockReturn: external.GenerateRecommendationResponse{
				Success: true,
			},
			mockError:     nil,
			expectedError: false,
		},
		{
			name:   "ml service returns unsuccessful response",
			userID: domain.NewID(),
			weather: domain.WeatherData{
				Location:    "Test City",
				Temperature: 25.0,
				FeelsLike:   26.0,
				Humidity:    60,
				WindSpeed:   5.0,
				Weather:     "sunny",
			},
			itemsByCategory: map[string][]domain.ClothingItem{},
			mockReturn: external.GenerateRecommendationResponse{
				Success: false,
			},
			mockError:     nil,
			expectedError: true,
		},
		{
			name:   "ml service returns error",
			userID: domain.NewID(),
			weather: domain.WeatherData{
				Location:    "Test City",
				Temperature: 25.0,
				FeelsLike:   26.0,
				Humidity:    60,
				WindSpeed:   5.0,
				Weather:     "sunny",
			},
			itemsByCategory: map[string][]domain.ClothingItem{},
			mockReturn:      external.GenerateRecommendationResponse{},
			mockError:       errors.New("service unavailable"),
			expectedError:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := new(MockMLClient)
			adapter := NewMLServiceAdapter(mockClient)

			// Set up expectations
			mockClient.On("GenerateRecommendation",
				context.Background(),
				mock.MatchedBy(func(req external.GenerateRecommendationRequest) bool {
					return req.UserID == tt.userID.String() &&
						req.ItemsByCategory != nil
				})).Return(tt.mockReturn, tt.mockError).Once()

			result, err := adapter.GetRecommendations(
				context.Background(),
				tt.userID,
				tt.weather,
				tt.itemsByCategory,
			)

			if tt.expectedError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, result)
				assert.Equal(t, tt.userID, result.UserID)
			}

			mockClient.AssertExpectations(t)
		})
	}
}

func TestMLServiceAdapter_GetRecommendations_ItemsConversion(t *testing.T) {
	// Проверяем корректную конвертацию items из домена в ML формат
	mockClient := new(MockMLClient)
	adapter := NewMLServiceAdapter(mockClient)

	userID := domain.NewID()
	upperID := domain.NewID()
	lowerID := domain.NewID()

	itemsByCategory := map[string][]domain.ClothingItem{
		"upper": {
			{
				ID:          upperID,
				Name:        "White T-Shirt",
				Category:    "upper",
				Subcategory: "tshirt",
				BaseColour:  strPtr("white"),
			},
		},
		"lower": {
			{
				ID:          lowerID,
				Name:        "Blue Jeans",
				Category:    "lower",
				Subcategory: "jeans",
				BaseColour:  strPtr("blue"),
			},
		},
	}

	mockClient.On("GenerateRecommendation",
		context.Background(),
		mock.MatchedBy(func(req external.GenerateRecommendationRequest) bool {
			// Проверяем, что items корректно сконвертированы
			upperItems, ok := req.ItemsByCategory["upper"]
			if !ok || len(upperItems) != 1 {
				return false
			}
			if upperItems[0].ID != upperID.String() {
				return false
			}
			if upperItems[0].Subcategory != "tshirt" {
				return false
			}
			if upperItems[0].BaseColour != "white" {
				return false
			}

			lowerItems, ok := req.ItemsByCategory["lower"]
			if !ok || len(lowerItems) != 1 {
				return false
			}
			if lowerItems[0].ID != lowerID.String() {
				return false
			}
			if lowerItems[0].Subcategory != "jeans" {
				return false
			}

			return true
		})).Return(external.GenerateRecommendationResponse{Success: true}, nil).Once()

	result, err := adapter.GetRecommendations(
		context.Background(),
		userID,
		domain.WeatherData{
			Location:    "Test",
			Temperature: 20.0,
			Humidity:    50,
			Weather:     "clear",
		},
		itemsByCategory,
	)

	assert.NoError(t, err)
	assert.NotNil(t, result)
	mockClient.AssertExpectations(t)
}

func TestMLServiceAdapter_RankCandidates(t *testing.T) {
	mockClient := new(MockMLClient)
	adapter := NewMLServiceAdapter(mockClient)

	testReq := &external.TZMLRankRequest{
		RequestID: "test-request",
		UserID:    domain.NewID(),
	}

	expectedResp := external.TZMLRankResponse{
		RequestID: "test-response",
	}

	mockClient.On("Rank", context.Background(), *testReq).Return(expectedResp, nil).Once()

	result, err := adapter.RankCandidates(context.Background(), testReq)

	assert.NoError(t, err)
	assert.Equal(t, expectedResp, *result)

	mockClient.AssertExpectations(t)
}

func TestMLServiceAdapter_ProcessFeedback(t *testing.T) {
	mockClient := new(MockMLClient)
	adapter := NewMLServiceAdapter(mockClient)

	userID := domain.NewID()
	requestID := "test-request"
	feedback := domain.RecommendationRateRequest{
		Rating:          5,
		ThermalFeedback: nil,
		Feedback:        nil,
	}

	mockClient.On("ProcessFeedback",
		context.Background(),
		userID.String(),
		requestID,
		mock.Anything).Return(nil).Once()

	err := adapter.ProcessFeedback(context.Background(), userID, requestID, feedback)

	assert.NoError(t, err)
	mockClient.AssertExpectations(t)
}

func TestMLServiceAdapter_GenerateOutfit(t *testing.T) {
	mockClient := new(MockMLClient)
	adapter := NewMLServiceAdapter(mockClient)

	userID := domain.NewID()
	occasion := "business"
	weather := domain.WeatherData{
		Location:    "Test City",
		Temperature: 25.0,
		FeelsLike:   26.0,
		Humidity:    60,
		WindSpeed:   5.0,
		Weather:     "sunny",
	}

	mockClient.On("GenerateOutfit",
		context.Background(),
		userID.String(),
		mock.Anything).Return(external.GenerateOutfitResponse{Success: true}, nil).Once()

	err := adapter.GenerateOutfit(context.Background(), userID, occasion, weather)

	assert.NoError(t, err)
	mockClient.AssertExpectations(t)
}

func TestMLServiceAdapter_UpdateUserPreferences(t *testing.T) {
	mockClient := new(MockMLClient)
	adapter := NewMLServiceAdapter(mockClient)

	userID := domain.NewID()
	requestID := "test-request"
	preferences := map[string]any{
		"style": "casual",
	}

	mockClient.On("UpdateUserPreferences",
		context.Background(),
		userID.String(),
		requestID,
		mock.Anything).Return(nil).Once()

	err := adapter.UpdateUserPreferences(context.Background(), userID, requestID, preferences)

	assert.NoError(t, err)
	mockClient.AssertExpectations(t)
}

// Helper functions
func strPtr(s string) *string {
	return &s
}

func int16Ptr(i int16) *int16 {
	return &i
}

func timePtr(t time.Time) *time.Time {
	return &t
}
