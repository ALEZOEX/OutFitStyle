package adapters

import (
	"context"
	"fmt"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// WeatherServiceInterface defines the interface for weather service
type WeatherServiceInterface interface {
	GetCurrent(ctx context.Context, lat, lon float64) (domain.WeatherSnapshot, time.Time, error)
	GetForecast(ctx context.Context, lat, lon float64, days int) (string, []any, []any, time.Time, error)
	HealthCheck() error
}

// GeoClientInterface defines the interface for geo client
type GeoClientInterface interface {
	Autocomplete(ctx context.Context, q string, limit int, lang string) ([]domain.GeoPlace, error)
}

// WeatherServiceAdapter adapts the external weather service to the use case interface
type WeatherServiceAdapter struct {
	weatherService WeatherServiceInterface
	geoClient      GeoClientInterface
}

// NewWeatherServiceAdapter creates a new weather service adapter
func NewWeatherServiceAdapter(weatherService WeatherServiceInterface, geoClient GeoClientInterface) *WeatherServiceAdapter {
	return &WeatherServiceAdapter{
		weatherService: weatherService,
		geoClient:      geoClient,
	}
}

// GetWeather implements the WeatherService interface
func (a *WeatherServiceAdapter) GetWeather(ctx context.Context, city string) (*domain.WeatherData, error) {
	// First, get coordinates for the city using the geo client
	places, err := a.geoClient.Autocomplete(ctx, city, 1, "en")
	if err != nil {
		return nil, fmt.Errorf("failed to get coordinates for city %s: %w", city, err)
	}

	if len(places) == 0 {
		return nil, fmt.Errorf("no coordinates found for city %s", city)
	}

	// Get the first result (most relevant)
	place := places[0]

	// Get weather data using the coordinates
	weather, _, err := a.weatherService.GetCurrent(ctx, place.Latitude, place.Longitude)
	if err != nil {
		return nil, fmt.Errorf("failed to get weather for coordinates (%f, %f): %w", place.Latitude, place.Longitude, err)
	}

	// Convert domain.WeatherSnapshot to domain.WeatherData
	weatherData := &domain.WeatherData{
		Location:    weather.Location,
		Temperature: weather.Temperature,
		FeelsLike:   weather.FeelsLike,
		Humidity:    weather.Humidity,
		WindSpeed:   weather.WindSpeed,
		Weather:     weather.WeatherMain, // Using WeatherMain as the primary weather description
	}

	return weatherData, nil
}