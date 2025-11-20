package external

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

// WeatherService handles weather data retrieval.
type WeatherService struct {
	baseURL string
	apiKey  string
	client  *http.Client
	logger  *zap.Logger
}

// ExtendedWeatherData — алиас доменного типа, чтобы не дублировать структуру.
type ExtendedWeatherData = domain.ExtendedWeatherData

// weatherAPIResponse represents the response from the weather API
type weatherAPIResponse struct {
	Location struct {
		Name string `json:"name"`
	} `json:"location"`
	Current struct {
		TempC      float64 `json:"temp_c"`
		FeelsLikeC float64 `json:"feelslike_c"`
		Humidity   int     `json:"humidity"`
		WindKph    float64 `json:"wind_kph"`
		Condition  struct {
			Text string `json:"text"`
		} `json:"condition"`
	} `json:"current"`
	Forecast struct {
		ForecastDay []struct {
			Hour []struct {
				TimeEpoch int64   `json:"time_epoch"`
				TempC     float64 `json:"temp_c"`
				Condition struct {
					Text string `json:"text"`
				} `json:"condition"`
				WillItRain int `json:"will_it_rain"`
				WillItSnow int `json:"will_it_snow"`
			} `json:"hour"`
		} `json:"forecastday"`
	} `json:"forecast"`
}

// HourlyForecastItem — если тебе нужен отдельный тип для внешнего API,
// но в домене уже есть domain.HourlyWeather, лучше использовать его.
// Оставляю пример корректного объявления на будущее.
type HourlyForecastItem struct {
	Time          time.Time `json:"time"`
	Temperature   float64   `json:"temperature"`
	Weather       string    `json:"weather"`
	Precipitation float64   `json:"precipitation,omitempty"`
}

// NewWeatherService creates a new weather service.
func NewWeatherService(apiKey, baseURL string, timeout time.Duration, logger *zap.Logger) *WeatherService {
	if logger == nil {
		logger = zap.NewNop()
	}

	return &WeatherService{
		baseURL: baseURL,
		apiKey:  apiKey,
		client: &http.Client{
			Timeout: timeout,
		},
		logger: logger,
	}
}

// GetWeather retrieves weather data for a given city.
func (s *WeatherService) GetWeather(ctx context.Context, city string) (*ExtendedWeatherData, error) {
	// If we don't have API credentials, return mock data
	if s.apiKey == "" || s.baseURL == "" {
		s.logger.Warn("Using mock weather data - API key or base URL not configured")
		return s.getMockWeather(city), nil
	}

	// Make real API call
	url := fmt.Sprintf("%s/current.json?key=%s&q=%s&lang=ru", s.baseURL, s.apiKey, city)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("create weather request: %w", err)
	}

	resp, err := s.client.Do(req)
	if err != nil {
		s.logger.Error("Weather API request failed", zap.Error(err))
		// Fallback to mock data on API failure
		return s.getMockWeather(city), nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		s.logger.Error("Weather API returned error status",
			zap.Int("status", resp.StatusCode),
			zap.String("body", string(body)))
		// Fallback to mock data on API error
		return s.getMockWeather(city), nil
	}

	var apiResp weatherAPIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		s.logger.Error("Failed to decode weather API response", zap.Error(err))
		// Fallback to mock data on decode error
		return s.getMockWeather(city), nil
	}

	// Convert API response to domain model
	hourlyForecasts := make([]domain.HourlyWeather, 0)
	if len(apiResp.Forecast.ForecastDay) > 0 && len(apiResp.Forecast.ForecastDay[0].Hour) > 0 {
		for _, hour := range apiResp.Forecast.ForecastDay[0].Hour {
			hourlyForecasts = append(hourlyForecasts, domain.HourlyWeather{
				Time:            time.Unix(hour.TimeEpoch, 0).Format(time.RFC3339),
				Temperature:     hour.TempC,
				Weather:         hour.Condition.Text,
				RainProbability: float64(hour.WillItRain),
			})
		}
	}

	weather := &domain.ExtendedWeatherData{
		WeatherData: domain.WeatherData{
			Location:       apiResp.Location.Name,
			Temperature:    apiResp.Current.TempC,
			FeelsLike:      apiResp.Current.FeelsLikeC,
			Weather:        apiResp.Current.Condition.Text,
			Humidity:       apiResp.Current.Humidity,
			WindSpeed:      apiResp.Current.WindKph / 3.6, // kph -> m/s
			HourlyForecast: hourlyForecasts,
		},
		Timestamp: time.Now(),
	}

	return weather, nil
}

// getMockWeather returns mock weather data for testing purposes
func (s *WeatherService) getMockWeather(city string) *ExtendedWeatherData {
	return &domain.ExtendedWeatherData{
		WeatherData: domain.WeatherData{
			Location:    city,
			Temperature: 20.0,
			FeelsLike:   22.0,
			Weather:     "Clear",
			Humidity:    65,
			WindSpeed:   3.5,
			MinTemp:     15.0,
			MaxTemp:     25.0,
			WillRain:    false,
			WillSnow:    false,
			// HourlyForecast заполняется доменным типом domain.HourlyWeather.
			HourlyForecast: []domain.HourlyWeather{
				{
					Time:            time.Now().Add(1 * time.Hour).Format(time.RFC3339),
					Temperature:     21.0,
					Weather:         "Clear",
					RainProbability: 0,
				},
			},
		},
		Timestamp: time.Now(),
	}
}

// HealthCheck implements the health check for the weather service.
func (s *WeatherService) HealthCheck() error {
	if s.apiKey == "" {
		return fmt.Errorf("weather service api key is missing")
	}
	// Дополнительно можно проверить baseURL или сделать лёгкий HEAD-запрос.
	if s.baseURL == "" {
		return fmt.Errorf("weather service base url is missing")
	}
	return nil
}
