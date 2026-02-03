package adapters

import (
	"context"
	"testing"
	"time"

	"outfitstyle/server/internal/core/domain"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// MockNominatimClient is a mock implementation of the geo client
type MockNominatimClient struct {
	mock.Mock
}

func (m *MockNominatimClient) Autocomplete(ctx context.Context, q string, limit int, lang string) ([]domain.GeoPlace, error) {
	args := m.Called(ctx, q, limit, lang)
	return args.Get(0).([]domain.GeoPlace), args.Error(1)
}

// MockWeatherService is a mock implementation of the weather service
type MockWeatherService struct {
	mock.Mock
}

func (m *MockWeatherService) GetCurrent(ctx context.Context, lat, lon float64) (domain.WeatherSnapshot, time.Time, error) {
	args := m.Called(ctx, lat, lon)
	return args.Get(0).(domain.WeatherSnapshot), args.Get(1).(time.Time), args.Error(2)
}

func (m *MockWeatherService) GetForecast(ctx context.Context, lat, lon float64, days int) (string, []any, []any, time.Time, error) {
	args := m.Called(ctx, lat, lon, days)
	return args.String(0), args.Get(1).([]any), args.Get(2).([]any), args.Get(3).(time.Time), args.Error(4)
}

func (m *MockWeatherService) HealthCheck() error {
	args := m.Called()
	return args.Error(0)
}

func TestWeatherServiceAdapter_GetWeather(t *testing.T) {
	type testCase struct {
		name              string
		city              string
		autocompleteResp  []domain.GeoPlace
		autocompleteErr   error
		currentWeather    domain.WeatherSnapshot
		currentTime       time.Time
		currentErr        error
		expectedWeather   *domain.WeatherData
		expectedError     bool
	}

	tests := []testCase{
		{
			name: "successful weather retrieval",
			city: "London",
			autocompleteResp: []domain.GeoPlace{
				{
					DisplayName: "London, UK",
					Latitude:    51.5074,
					Longitude:   -0.1278,
				},
			},
			autocompleteErr: nil,
			currentWeather: domain.WeatherSnapshot{
				Location:    "London",
				Temperature: 15.5,
				FeelsLike:   14.2,
				Humidity:    70,
				WindSpeed:   3.2,
				WeatherCode: "01d",
				WeatherMain: "Clear",
			},
			currentTime: time.Now(),
			currentErr:  nil,
			expectedWeather: &domain.WeatherData{
				Location:    "London",
				Temperature: 15.5,
				FeelsLike:   14.2,
				Humidity:    70,
				WindSpeed:   3.2,
				Weather:     "Clear",
			},
			expectedError: false,
		},
		{
			name:              "error getting coordinates",
			city:              "InvalidCity",
			autocompleteResp:  nil,
			autocompleteErr:   assert.AnError,
			currentWeather:    domain.WeatherSnapshot{},
			currentTime:       time.Time{},
			currentErr:        nil,
			expectedWeather:   nil,
			expectedError:     true,
		},
		{
			name:              "no coordinates found",
			city:              "NonExistentCity",
			autocompleteResp:  []domain.GeoPlace{},
			autocompleteErr:   nil,
			currentWeather:    domain.WeatherSnapshot{},
			currentTime:       time.Time{},
			currentErr:        nil,
			expectedWeather:   nil,
			expectedError:     true,
		},
		{
			name: "error getting weather",
			city: "London",
			autocompleteResp: []domain.GeoPlace{
				{
					DisplayName: "London, UK",
					Latitude:    51.5074,
					Longitude:   -0.1278,
				},
			},
			autocompleteErr: nil,
			currentWeather:  domain.WeatherSnapshot{},
			currentTime:     time.Time{},
			currentErr:      assert.AnError,
			expectedWeather: nil,
			expectedError:   true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockGeoClient := new(MockNominatimClient)
			mockWeatherService := new(MockWeatherService)

			adapter := NewWeatherServiceAdapter(mockWeatherService, mockGeoClient)

			mockGeoClient.On("Autocomplete", context.Background(), tt.city, 1, "en").Return(tt.autocompleteResp, tt.autocompleteErr).Once()
			if tt.autocompleteErr == nil && len(tt.autocompleteResp) > 0 {
				mockWeatherService.On("GetCurrent", context.Background(), tt.autocompleteResp[0].Latitude, tt.autocompleteResp[0].Longitude).Return(tt.currentWeather, tt.currentTime, tt.currentErr).Once()
			}

			result, err := adapter.GetWeather(context.Background(), tt.city)

			if tt.expectedError {
				assert.Error(t, err)
				assert.Nil(t, result)
			} else {
				assert.NoError(t, err)
				assert.Equal(t, tt.expectedWeather.Location, result.Location)
				assert.Equal(t, tt.expectedWeather.Temperature, result.Temperature)
				assert.Equal(t, tt.expectedWeather.FeelsLike, result.FeelsLike)
				assert.Equal(t, tt.expectedWeather.Humidity, result.Humidity)
				assert.Equal(t, tt.expectedWeather.WindSpeed, result.WindSpeed)
				assert.Equal(t, tt.expectedWeather.Weather, result.Weather)
			}

			mockGeoClient.AssertExpectations(t)
			mockWeatherService.AssertExpectations(t)
		})
	}
}