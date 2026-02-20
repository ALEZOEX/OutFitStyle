package services

import (
	"context"

	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/eventing"
)

// RatingService сервис для управления рейтингом рекомендаций
type RatingService struct {
	ratingRepo     repositories.OutfitRatingRepository  // Репозиторий оценок
	recRepo        repositories.RecommendationRepository // Репозиторий рекомендаций
	clothingRepo   repositories.ClothingRepository      // Репозиторий одежды
	eventPublisher eventing.EventPublisher              // Паблишер событий
	logger         *zap.Logger                          // Логгер
}

// NewRatingService создаёт новый экземпляр сервиса рейтинга
func NewRatingService(
	ratingRepo repositories.OutfitRatingRepository,
	recRepo repositories.RecommendationRepository,
	clothingRepo repositories.ClothingRepository,
	eventPublisher eventing.EventPublisher,
	logger *zap.Logger,
) *RatingService {
	return &RatingService{
		ratingRepo:     ratingRepo,
		recRepo:        recRepo,
		clothingRepo:   clothingRepo,
		eventPublisher: eventPublisher,
		logger:         logger,
	}
}

// RateOutfit создаёт или обновляет оценку рекомендации
func (s *RatingService) RateOutfit(
	ctx context.Context,
	userID domain.ID,
	recommendationID domain.ID,
	rating int,
	outfitItems []int64,
	feedback *string,
	thermalFeedback *string,
) (*domain.OutfitRating, error) {
	// Валидация рейтинга
	if !domain.IsValidRating(rating) {
		return nil, errors.New("рейтинг должен быть от 1 до 5")
	}

	// Проверяем существование рекомендации
	rec, err := s.recRepo.GetByUserAndID(ctx, userID, recommendationID)
	if err != nil {
		return nil, errors.Wrap(err, "получение рекомендации")
	}
	if rec == nil {
		return nil, repositories.ErrNotFound
	}

	// Конвертация рейтинга в quality_score
	qualityScore := domain.RatingToQualityScore(rating)

	// Создаём оценку
	ratingEntity := &domain.OutfitRating{
		UserID:           userID,
		RecommendationID: recommendationID,
		OutfitItems:      outfitItems,
		Rating:           rating,
		QualityScore:     qualityScore,
		Feedback:         feedback,
		ThermalFeedback:  thermalFeedback,
	}

	// Сохраняем оценку (с upsert через ON CONFLICT)
	if err := s.ratingRepo.Create(ctx, ratingEntity); err != nil {
		return nil, errors.Wrap(err, "сохранение оценки")
	}

	// Обновляем рейтинг в самой рекомендации (для обратной совместимости)
	_, err = s.recRepo.SetRating(ctx, userID, recommendationID, rating, thermalFeedback, feedback)
	if err != nil {
		s.logger.Warn("Не удалось обновить рейтинг в рекомендации", zap.Error(err))
	}

	// Публикуем событие оценки
	err = s.eventPublisher.PublishUserFeedback(ctx, userID, recommendationID, rating, derefString(feedback, ""))
	if err != nil {
		s.logger.Error("Не удалось опубликовать событие оценки", zap.Error(err))
	}

	s.logger.Info("Пользователь оценил рекомендацию",
		zap.String("user_id", userID.String()),
		zap.String("recommendation_id", recommendationID.String()),
		zap.Int("rating", rating),
		zap.Int("quality_score", qualityScore),
	)

	return ratingEntity, nil
}

// GetRecommendationQuality возвращает статистику качества рекомендации
func (s *RatingService) GetRecommendationQuality(
	ctx context.Context,
	userID domain.ID,
	recommendationID domain.ID,
) (*domain.RecommendationQualityResponse, error) {
	// Получаем агрегированную статистику
	stats, err := s.ratingRepo.GetAverageQuality(ctx, recommendationID)
	if err != nil {
		return nil, errors.Wrap(err, "получение статистики качества")
	}

	// Если статистики нет, возвращаем пустой ответ
	if stats == nil {
		return &domain.RecommendationQualityResponse{
			RecommendationID: recommendationID,
			AvgRating:        0,
			AvgQualityScore:  0,
			RatingCount:      0,
			PositiveCount:    0,
			NegativeCount:    0,
		}, nil
	}

	// Получаем оценку текущего пользователя (если есть)
	userRating, err := s.ratingRepo.GetByUserAndRecommendation(ctx, userID, recommendationID)
	var userRatingValue *int
	if err == nil && userRating != nil {
		userRatingValue = &userRating.Rating
	}

	return &domain.RecommendationQualityResponse{
		RecommendationID: recommendationID,
		AvgRating:        stats.AvgRating,
		AvgQualityScore:  stats.AvgQualityScore,
		RatingCount:      stats.RatingCount,
		PositiveCount:    stats.PositiveCount,
		NegativeCount:    stats.NegativeCount,
		UserRating:       userRatingValue,
	}, nil
}

// GetUserRating возвращает оценку пользователя для рекомендации
func (s *RatingService) GetUserRating(
	ctx context.Context,
	userID domain.ID,
	recommendationID domain.ID,
) (*domain.OutfitRating, error) {
	rating, err := s.ratingRepo.GetByUserAndRecommendation(ctx, userID, recommendationID)
	if err != nil {
		return nil, errors.Wrap(err, "получение оценки пользователя")
	}
	return rating, nil
}

// FilterLowQualityItems фильтрует вещи с низким рейтингом для пользователя
// threshold: порог quality_score, ниже которого вещи исключаются (рекомендуется -5)
func (s *RatingService) FilterLowQualityItems(
	ctx context.Context,
	userID domain.ID,
	candidateIDs []domain.ID,
	threshold float64,
) ([]domain.ID, error) {
	// Получаем вещи с низким рейтингом
	lowQualityItems, err := s.ratingRepo.GetLowQualityItems(ctx, userID, threshold)
	if err != nil {
		return nil, errors.Wrap(err, "получение вещей с низким рейтингом")
	}

	if len(lowQualityItems) == 0 {
		return candidateIDs, nil
	}

	// Создаём множество ID вещей с низким рейтингом
	// LowQualityItem.ClothingItemID - это int64, а candidateIDs - domain.ID (UUID)
	// Для корректной фильтрации нужно получить полные данные о вещах
	
	// Получаем все candidate вещи для сопоставления
	allClothingItems, err := s.clothingRepo.GetByIDs(ctx, candidateIDs)
	if err != nil {
		return nil, errors.Wrap(err, "получение вещей кандидатов")
	}

	// Создаём мапу ID вещей с низким рейтингом для быстрого поиска
	lowQualitySet := make(map[int64]bool)
	for _, item := range lowQualityItems {
		lowQualitySet[item.ClothingItemID] = true
		s.logger.Debug("Вещь с низким рейтингом",
			zap.Int64("clothing_item_id", item.ClothingItemID),
			zap.Float64("avg_quality_score", item.AvgQualityScore),
		)
	}

	// Фильтруем кандидатов
	filteredIDs := make([]domain.ID, 0, len(candidateIDs))
	for _, item := range allClothingItems {
		// Конвертируем UUID в int64 для сравнения
		itemIDInt64 := domain.IDToInt64(item.ID)
		if !lowQualitySet[itemIDInt64] {
			filteredIDs = append(filteredIDs, item.ID)
		} else {
			s.logger.Debug("Исключена вещь с низким рейтингом",
				zap.String("item_id", item.ID.String()),
				zap.Int64("item_id_int64", itemIDInt64),
			)
		}
	}

	s.logger.Info("Фильтрация вещей с низким рейтингом",
		zap.Int("total_candidates", len(candidateIDs)),
		zap.Int("filtered_out", len(candidateIDs)-len(filteredIDs)),
		zap.Int("remaining", len(filteredIDs)),
	)

	return filteredIDs, nil
}

// GetUserRatingStats возвращает статистику оценок пользователя
func (s *RatingService) GetUserRatingStats(
	ctx context.Context,
	userID domain.ID,
) (*domain.UserRatingStats, error) {
	stats, err := s.ratingRepo.GetUserStats(ctx, userID)
	if err != nil {
		return nil, errors.Wrap(err, "получение статистики пользователя")
	}
	return stats, nil
}

// HasUserRated проверяет, оценил ли пользователь рекомендацию
func (s *RatingService) HasUserRated(
	ctx context.Context,
	userID domain.ID,
	recommendationID domain.ID,
) (bool, error) {
	return s.ratingRepo.HasRated(ctx, userID, recommendationID)
}

// GetUserRatingsForRecommendations возвращает оценки пользователя для списка рекомендаций
func (s *RatingService) GetUserRatingsForRecommendations(
	ctx context.Context,
	userID domain.ID,
	recommendationIDs []domain.ID,
) (map[domain.ID]int, error) {
	return s.ratingRepo.GetUserRatingsForRecommendations(ctx, userID, recommendationIDs)
}

// GetLowQualityItemsForML возвращает вещи с низким рейтингом для ML фильтрации
// Используется при генерации новых рекомендаций
func (s *RatingService) GetLowQualityItemsForML(
	ctx context.Context,
	userID domain.ID,
) ([]int64, error) {
	// Порог -5: исключаем вещи со средним quality_score < -5
	lowQualityItems, err := s.ratingRepo.GetLowQualityItems(ctx, userID, -5.0)
	if err != nil {
		return nil, errors.Wrap(err, "получение вещей с низким рейтингом для ML")
	}

	itemIDs := make([]int64, len(lowQualityItems))
	for i, item := range lowQualityItems {
		itemIDs[i] = item.ClothingItemID
	}

	s.logger.Debug("Получены вещи с низким рейтингом для ML",
		zap.String("user_id", userID.String()),
		zap.Int("count", len(itemIDs)),
	)

	return itemIDs, nil
}

// derefString разыменовывает указатель или возвращает значение по умолчанию
func derefString(p *string, def string) string {
	if p == nil {
		return def
	}
	return *p
}

// SendUserActionToML отправляет действие пользователя в ML сервис для обучения
func (s *RatingService) SendUserActionToML(
	ctx context.Context,
	userID domain.ID,
	requestID string,
	actionType string,
	entityID string,
	entityType string,
	meta map[string]interface{},
) error {
	// Эта функция может быть использована для отправки действий в ML сервис
	// Реализация зависит от наличия ML клиента в сервисе
	// Пока оставляем заглушку для будущего расширения
	s.logger.Debug("Отправка действия пользователя в ML",
		zap.String("user_id", userID.String()),
		zap.String("action_type", actionType),
		zap.String("entity_id", entityID),
	)
	return nil
}

// CalculateOutfitQualityScore вычисляет средний quality_score для набора вещей
func (s *RatingService) CalculateOutfitQualityScore(
	ctx context.Context,
	userID domain.ID,
	outfitItemIDs []int64,
) (float64, error) {
	if len(outfitItemIDs) == 0 {
		return 0, nil
	}

	// Получаем все оценки пользователя
	lowQualityItems, err := s.ratingRepo.GetLowQualityItems(ctx, userID, 0) // Получаем все
	if err != nil {
		return 0, errors.Wrap(err, "получение оценок вещей")
	}

	// Создаём мапу quality_score по ID вещи
	qualityMap := make(map[int64]float64)
	for _, item := range lowQualityItems {
		qualityMap[item.ClothingItemID] = item.AvgQualityScore
	}

	// Вычисляем средний score для outfit
	totalScore := 0.0
	count := 0
	for _, itemID := range outfitItemIDs {
		if score, ok := qualityMap[itemID]; ok {
			totalScore += score
			count++
		}
	}

	if count == 0 {
		return 0, nil
	}

	return totalScore / float64(count), nil
}

// GetRecommendationsWithUserRatings возвращает рекомендации с оценками пользователя
func (s *RatingService) GetRecommendationsWithUserRatings(
	ctx context.Context,
	userID domain.ID,
	recommendations []domain.RecommendationRecord,
) ([]domain.RecommendationRecord, error) {
	// Извлекаем ID рекомендаций
	recIDs := make([]domain.ID, len(recommendations))
	for i, rec := range recommendations {
		recIDs[i] = rec.ID
	}

	// Получаем оценки пользователя
	userRatings, err := s.ratingRepo.GetUserRatingsForRecommendations(ctx, userID, recIDs)
	if err != nil {
		return nil, errors.Wrap(err, "получение оценок пользователя")
	}

	// Добавляем оценки к рекомендациям
	// В реальной реализации нужно добавить поле UserRating в RecommendationRecord
	// Пока просто логируем
	for _, rec := range recommendations {
		if rating, ok := userRatings[rec.ID]; ok {
			s.logger.Debug("Рекомендация с оценкой пользователя",
				zap.String("recommendation_id", rec.ID.String()),
				zap.Int("user_rating", rating),
			)
		}
	}

	return recommendations, nil
}
