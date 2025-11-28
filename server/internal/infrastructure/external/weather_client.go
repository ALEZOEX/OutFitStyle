package external

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

// ErrCityNotFound возвращается, если OpenWeatherMap вернул 404 по городу.
var ErrCityNotFound = fmt.Errorf("city not found")

// WeatherService инкапсулирует работу с OpenWeatherMap.
type WeatherService struct {
	baseURL string
	apiKey  string
	client  *http.Client
	logger  *zap.Logger
}

// NewWeatherService создаёт новый сервис погоды.
func NewWeatherService(apiKey, baseURL string, timeout time.Duration, logger *zap.Logger) *WeatherService {
	if logger == nil {
		logger = zap.NewNop()
	}

	baseURL = strings.TrimRight(baseURL, "/")

	return &WeatherService{
		baseURL: baseURL,
		apiKey:  apiKey,
		client: &http.Client{
			Timeout: timeout,
		},
		logger: logger,
	}
}

// структура ответа OpenWeatherMap для current weather
type owmCurrentResponse struct {
	Name  string `json:"name"`
	Coord struct {
		Lat float64 `json:"lat"`
		Lon float64 `json:"lon"`
	} `json:"coord"`
	Weather []struct {
		Main        string `json:"main"`
		Description string `json:"description"`
	} `json:"weather"`
	Main struct {
		Temp      float64 `json:"temp"`
		FeelsLike float64 `json:"feels_like"`
		TempMin   float64 `json:"temp_min"`
		TempMax   float64 `json:"temp_max"`
		Humidity  int     `json:"humidity"`
	} `json:"main"`
	Wind struct {
		Speed float64 `json:"speed"`
	} `json:"wind"`
	Dt int64 `json:"dt"`
}

// GetWeather возвращает доменную погоду по имени города.
func (s *WeatherService) GetWeather(ctx context.Context, city string) (*domain.ExtendedWeatherData, error) {
	if s.apiKey == "" || s.baseURL == "" {
		return nil, fmt.Errorf("weather service is not configured: empty apiKey or baseURL")
	}

	endpoint := s.baseURL + "/weather"

	// Собираем query-параметры
	q := url.Values{}
	q.Set("q", city)
	q.Set("appid", s.apiKey)
	q.Set("units", "metric")
	q.Set("lang", "ru")

	u, err := url.Parse(endpoint)
	if err != nil {
		return nil, fmt.Errorf("parse weather endpoint: %w", err)
	}
	u.RawQuery = q.Encode()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
	if err != nil {
		return nil, fmt.Errorf("create weather request: %w", err)
	}

	resp, err := s.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("weather api request failed: %w", err)
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	// 404 — такого города нет
	if resp.StatusCode == http.StatusNotFound {
		s.logger.Warn("city not found in OpenWeatherMap",
			zap.String("city", city),
			zap.ByteString("body", body),
		)
		return nil, ErrCityNotFound
	}

	// Любой не 200 — ошибка провайдера или ключа
	if resp.StatusCode != http.StatusOK {
		s.logger.Error("OpenWeatherMap returned error",
			zap.Int("status", resp.StatusCode),
			zap.ByteString("body", body),
		)
		return nil, fmt.Errorf("weather api error: status=%d", resp.StatusCode)
	}

	var apiResp owmCurrentResponse
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("decode weather response: %w", err)
	}

	desc := ""
	if len(apiResp.Weather) > 0 {
		if apiResp.Weather[0].Description != "" {
			desc = apiResp.Weather[0].Description
		} else {
			desc = apiResp.Weather[0].Main
		}
	}

	weather := &domain.ExtendedWeatherData{
		WeatherData: domain.WeatherData{
			Location:       apiResp.Name,
			Temperature:    apiResp.Main.Temp,
			FeelsLike:      apiResp.Main.FeelsLike,
			Weather:        desc,
			Humidity:       apiResp.Main.Humidity,
			WindSpeed:      apiResp.Wind.Speed, // m/s при units=metric
			MinTemp:        apiResp.Main.TempMin,
			MaxTemp:        apiResp.Main.TempMax,
			WillRain:       false,
			WillSnow:       false,
			HourlyForecast: []domain.HourlyWeather{},
		},
		Timestamp: time.Now().UTC(),
	}

	return weather, nil
}

// HealthCheck реализует интерфейс health.Checker.
func (s *WeatherService) HealthCheck() error {
	if s.apiKey == "" {
		return fmt.Errorf("weather service api key is missing")
	}
	if s.baseURL == "" {
		return fmt.Errorf("weather service base url is missing")
	}
	return nil
}
