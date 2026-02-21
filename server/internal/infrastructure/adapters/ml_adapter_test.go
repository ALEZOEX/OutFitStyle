package adapters

import (
	"context"
	"errors"
	"testing"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockMLClient is a mock implementation of the ML client interface
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

func (m *MockMLClient) GenerateOutfit(ctx context.Context, userID string, meta map[string]interface{}) (external.GenerateOutfitResponse, error) {
	args := m.Called(ctx, userID, meta)
	return args.Get(0).(external.GenerateOutfitResponse), args.Error(1)
}

func (m *MockMLClient) GenerateRecommendation(ctx context.Context, userID string, meta map[string]interface{}) (external.GenerateRecommendationResponse, error) {
	args := m.Called(ctx, userID, meta)
	return args.Get(0).(external.GenerateRecommendationResponse), args.Error(1)
}

func (m *MockMLClient) ProcessFeedback(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error {
	args := m.Called(ctx, userID, requestID, meta)
	return args.Error(0)
}

func (m *MockMLClient) UpdateUserPreferences(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error {
	args := m.Called(ctx, userID, requestID, meta)
	return args.Error(0)
}

func TestMLServiceAdapter_GetRecommendations(t *testing.T) {
	tests := []struct {
		name           string
		userID         domain.ID
		weather        domain.WeatherData
		mockReturn     external.GenerateRecommendationResponse
		mockError      error
		expectedError  bool
		expectedResult *domain.RecommendationResponse
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
			mockReturn: external.GenerateRecommendationResponse{
				Success: true,
			},
			mockError:      nil,
			expectedError:  false,
			expectedResult: &domain.RecommendationResponse{}, // Partial check - we mainly verify the call
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
			mockReturn:    external.GenerateRecommendationResponse{},
			mockError:     errors.New("service unavailable"),
			expectedError: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockClient := new(MockMLClient)

			adapter := NewMLServiceAdapter(mockClient)

			// Set up expectations
			expectedMeta := map[string]interface{}{
				"user_id": tt.userID.String(),
				"weather": map[string]interface{}{
					"temperature": tt.weather.Temperature,
					"feels_like":  tt.weather.FeelsLike,
					"humidity":    tt.weather.Humidity,
					"wind_speed":  tt.weather.WindSpeed,
					"weather":     tt.weather.Weather,
				},
				"context": map[string]interface{}{
					"location": tt.weather.Location,
				},
			}

			mockClient.On("GenerateRecommendation",
				context.Background(),
				tt.userID.String(),
				expectedMeta).Return(tt.mockReturn, tt.mockError).Once()

			result, err := adapter.GetRecommendations(context.Background(), tt.userID, tt.weather)

			if tt.expectedError {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
				assert.NotNil(t, result)
			}

			mockClient.AssertExpectations(t)
		})
	}
}

func TestMLServiceAdapter_RankCandidates(t *testing.T) {
	// Create a mock client
	mockClient := new(MockMLClient)

	adapter := NewMLServiceAdapter(mockClient)

	// Create test request
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
	// Create a mock client
	mockClient := new(MockMLClient)

	adapter := NewMLServiceAdapter(mockClient)

	userID := domain.NewID()
	requestID := "test-request"
	feedback := domain.RecommendationRateRequest{
		Rating:          5,
		ThermalFeedback: nil,
		Feedback:        nil,
	}

	expectedMeta := map[string]interface{}{
		"rating":           feedback.Rating,
		"thermal_feedback": feedback.ThermalFeedback,
		"feedback":         feedback.Feedback,
	}

	mockClient.On("ProcessFeedback",
		context.Background(),
		userID.String(),
		requestID,
		expectedMeta).Return(nil).Once()

	err := adapter.ProcessFeedback(context.Background(), userID, requestID, feedback)

	assert.NoError(t, err)

	mockClient.AssertExpectations(t)
}

func TestMLServiceAdapter_GenerateOutfit(t *testing.T) {
	// Create a mock client
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

	expectedMeta := map[string]interface{}{
		"occasion": occasion,
		"weather": map[string]interface{}{
			"temperature": weather.Temperature,
			"feels_like":  weather.FeelsLike,
			"humidity":    weather.Humidity,
			"wind_speed":  weather.WindSpeed,
			"weather":     weather.Weather,
		},
	}

	mockClient.On("GenerateOutfit",
		context.Background(),
		userID.String(),
		expectedMeta).Return(external.GenerateOutfitResponse{Success: true}, nil).Once()

	err := adapter.GenerateOutfit(context.Background(), userID, occasion, weather)

	assert.NoError(t, err)

	mockClient.AssertExpectations(t)
}