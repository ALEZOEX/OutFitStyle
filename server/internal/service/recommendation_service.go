// Пакет service содержит бизнес-логику приложения
// Реализует сервисы, которые координируют взаимодействие между различными компонентами системы
package service

import (
	"context"
	"errors"

	"outfitstyle/server/internal/core/domain"
)

// WardrobeRepository интерфейс для работы с репозиторием гардероба
type WardrobeRepository interface {
	GetUserWardrobe(ctx context.Context, userID domain.ID) ([]domain.WardrobeItem, error)
}

// WeatherService интерфейс для получения информации о погоде
// У тебя в usecase уже фигурирует WeatherData, а domain.Weather у тебя отсутствует.
type WeatherService interface {
	GetCurrentWeather(ctx context.Context, lat, lon float64) (*domain.WeatherData, error)
}

// MLClient интерфейс для взаимодействия с ML-сервисом
// Делай контракт максимально простой: userID + weather.
type MLClient interface {
	GetRecommendations(ctx context.Context, userID domain.ID, weather domain.WeatherData) (*domain.RecommendationResponse, error)
}

// RecommendationService структура сервиса рекомендаций
// Объединяет логику получения гардероба пользователя, погоды и ML-рекомендаций
type RecommendationService struct {
	wardrobeRepo WardrobeRepository // Репозиторий для работы с гардеробом пользователя
	weatherSvc   WeatherService     // Сервис для получения информации о погоде
	mlClient     MLClient           // Клиент для взаимодействия с ML-сервисом
}

// NewRecommendationService создает новый экземпляр сервиса рекомендаций
// Принимает зависимости, необходимые для работы сервиса
func NewRecommendationService(wardrobeRepo WardrobeRepository, weatherSvc WeatherService, mlClient MLClient) *RecommendationService {
	return &RecommendationService{
		wardrobeRepo: wardrobeRepo,
		weatherSvc:   weatherSvc,
		mlClient:     mlClient,
	}
}

// GetRecommendations возвращает рекомендации одежды для пользователя на основе погоды
// Получает гардероб пользователя, текущую погоду и запрашивает рекомендации у ML-сервиса
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

// CalculateWarmthLevel вычисляет уровень теплоты на основе температуры
// Возвращает значение от 0 до 5, где 5 - самый холодный уровень
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
