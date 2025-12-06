package services

import (
	"context"
	"time"

	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

// ErrUserNotFound возвращается, если пользователь не найден в БД.
var ErrUserNotFound = errors.New("user not found")

// RecommendationService handles recommendation-related business logic.
type RecommendationService struct {
	recommendationRepo repositories.RecommendationRepository
	userRepo           repositories.UserRepository
	weatherService     *external.WeatherService
	mlService          *external.MLService
	logger             *zap.Logger
}

// NewRecommendationService creates a new recommendation service.
func NewRecommendationService(
	recommendationRepo repositories.RecommendationRepository,
	userRepo repositories.UserRepository,
	weatherService *external.WeatherService,
	mlService *external.MLService,
	logger *zap.Logger,
) *RecommendationService {
	return &RecommendationService{
		recommendationRepo: recommendationRepo,
		userRepo:           userRepo,
		weatherService:     weatherService,
		mlService:          mlService,
		logger:             logger,
	}
}

// GetRecommendations generates outfit recommendations for a user based on weather data.
//
// source управляет источником вещей для ML:
// - "wardrobe"    -> личный гардероб пользователя (clothing_items.user_id = userID)
// - "catalog"     -> общий каталог (user_id IS NULL)
// - "mixed"       -> и гардероб, и каталог.
func (s *RecommendationService) GetRecommendations(
	ctx context.Context,
	req domain.RecommendationRequest,
	source string,
) (*domain.RecommendationResponse, error) {

	if req.UserID <= 0 {
		return nil, ErrUserNotFound
	}

	// 1. Проверяем, что пользователь существует
	user, err := s.userRepo.GetUser(ctx, int(req.UserID))
	if err != nil {
		s.logger.Error("Failed to load user",
			zap.Error(err),
			zap.Int64("user_id", int64(req.UserID)),
		)
		return nil, errors.Wrap(err, "failed to load user")
	}
	if user == nil {
		return nil, ErrUserNotFound
	}

	if source == "" {
		source = "wardrobe"
	}

	// 2. Подготавливаем данные погоды для ML‑сервиса
	mlWeather := domain.WeatherData{
		Location:       req.WeatherData.Location,
		Temperature:    req.WeatherData.Temperature,
		FeelsLike:      req.WeatherData.FeelsLike,
		Weather:        req.WeatherData.Weather,
		Humidity:       req.WeatherData.Humidity,
		WindSpeed:      req.WeatherData.WindSpeed,
		MinTemp:        req.WeatherData.MinTemp,
		MaxTemp:        req.WeatherData.MaxTemp,
		WillRain:       req.WeatherData.WillRain,
		WillSnow:       req.WeatherData.WillSnow,
		HourlyForecast: req.WeatherData.HourlyForecast,
	}

	// ML‑сервис ожидает int, а в домене у нас ID (int64)
	userID := int(req.UserID)

	// 3. Получаем рекомендацию от ML‑сервиса (ML только считает, без записи в БД)
	mlRec, err := s.mlService.GetRecommendations(ctx, userID, mlWeather, source)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get ML recommendations")
	}

	// 4. Гарантируем корректный UserID и Timestamp в доменной модели
	mlRec.UserID = req.UserID
	if mlRec.Timestamp.IsZero() {
		mlRec.Timestamp = time.Now()
	}

	recommendation := mlRec

	// 5. Асинхронно сохраняем рекомендацию в БД (единая точка записи)
	go func(rec *domain.RecommendationResponse, uid domain.ID) {
		saveCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		if _, err := s.recommendationRepo.CreateRecommendation(saveCtx, rec); err != nil {
			s.logger.Error("Failed to save recommendation",
				zap.Int64("user_id", int64(uid)),
				zap.Error(err),
			)
		}
	}(recommendation, req.UserID)

	return recommendation, nil
}

// GetRecommendationHistory retrieves recommendation history for a user.
func (s *RecommendationService) GetRecommendationHistory(
	ctx context.Context,
	userID int,
	limit int,
) ([]domain.RecommendationResponse, error) {

	recommendations, err := s.recommendationRepo.GetUserRecommendations(ctx, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get recommendation history")
	}
	return recommendations, nil
}

// GetRecommendationByID retrieves a specific recommendation by ID.
func (s *RecommendationService) GetRecommendationByID(
	ctx context.Context,
	id int,
) (*domain.RecommendationResponse, error) {

	recommendation, err := s.recommendationRepo.GetRecommendationByID(ctx, id)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get recommendation by ID")
	}
	return recommendation, nil
}

// RateRecommendation allows a user to rate a recommendation.
func (s *RecommendationService) RateRecommendation(
	ctx context.Context,
	userID, recommendationID, rating int,
	feedback string,
) error {

	if rating < 1 || rating > 5 {
		return errors.New("rating must be between 1 and 5")
	}

	if err := s.userRepo.RateRecommendation(ctx, userID, recommendationID, rating, feedback); err != nil {
		return errors.Wrap(err, "failed to rate recommendation")
	}
	return nil
}

// AddFavorite adds a recommendation to user's favorites.
func (s *RecommendationService) AddFavorite(
	ctx context.Context,
	userID, recommendationID int,
) error {

	if err := s.userRepo.AddFavorite(ctx, userID, recommendationID); err != nil {
		return errors.Wrap(err, "failed to add favorite")
	}
	return nil
}

// RemoveFavorite removes a recommendation from user's favorites.
func (s *RecommendationService) RemoveFavorite(
	ctx context.Context,
	userID, favoriteID int,
) error {

	if err := s.userRepo.RemoveFavorite(ctx, userID, favoriteID); err != nil {
		return errors.Wrap(err, "failed to remove favorite")
	}
	return nil
}

// GetUserFavorites retrieves user's favorite recommendations.
func (s *RecommendationService) GetUserFavorites(
	ctx context.Context,
	userID int,
) ([]domain.FavoriteOutfit, error) {

	favorites, err := s.userRepo.GetUserFavorites(ctx, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get user favorites")
	}
	return favorites, nil
}
