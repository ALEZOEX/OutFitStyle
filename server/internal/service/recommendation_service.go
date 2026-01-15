package service

import (
	"context"
	"errors"

	"outfitstyle/server/internal/core/domain"
)

type WardrobeRepository interface {
	GetUserWardrobe(ctx context.Context, userID domain.ID) ([]domain.WardrobeItem, error)
}

type WeatherService interface {
	// У тебя в usecase уже фигурирует WeatherData, а domain.Weather у тебя отсутствует.
	GetCurrentWeather(ctx context.Context, lat, lon float64) (*domain.WeatherData, error)
}

type MLClient interface {
	// Делай контракт максимально простой: userID + weather.
	GetRecommendations(ctx context.Context, userID domain.ID, weather domain.WeatherData) (*domain.RecommendationResponse, error)
}

type RecommendationService struct {
	wardrobeRepo WardrobeRepository
	weatherSvc   WeatherService
	mlClient     MLClient
}

func NewRecommendationService(wardrobeRepo WardrobeRepository, weatherSvc WeatherService, mlClient MLClient) *RecommendationService {
	return &RecommendationService{
		wardrobeRepo: wardrobeRepo,
		weatherSvc:   weatherSvc,
		mlClient:     mlClient,
	}
}

func (s *RecommendationService) GetRecommendations(ctx context.Context, userID domain.ID, lat, lon float64) (*domain.RecommendationResponse, error) {
	items, err := s.wardrobeRepo.GetUserWardrobe(ctx, userID)
	if err != nil {
		return nil, err
	}
	if len(items) == 0 {
		return nil, errors.New("wardrobe is empty")
	}

	w, err := s.weatherSvc.GetCurrentWeather(ctx, lat, lon)
	if err != nil {
		return nil, err
	}
	if w == nil {
		return nil, errors.New("weather is nil")
	}

	return s.mlClient.GetRecommendations(ctx, userID, *w)
}

func CalculateWarmthLevel(temperature float64) int {
	if temperature < -10 {
		return 5
	} else if temperature < 0 {
		return 4
	} else if temperature < 10 {
		return 3
	} else if temperature < 20 {
		return 2
	} else if temperature < 30 {
		return 1
	}
	return 0
}
