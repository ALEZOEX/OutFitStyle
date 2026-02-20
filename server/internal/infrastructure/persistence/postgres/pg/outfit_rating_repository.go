package pg

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"go.uber.org/zap"
	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/domain"
)

// outfitRatingRepo реализация OutfitRatingRepository
type outfitRatingRepo struct {
	db     *pgxpool.Pool
	logger *zap.Logger
}

// NewOutfitRatingRepository создаёт новый экземпляр репозитория
func NewOutfitRatingRepository(db *pgxpool.Pool, logger *zap.Logger) *outfitRatingRepo {
	return &outfitRatingRepo{
		db:     db,
		logger: logger,
	}
}

// Create создаёт новую оценку рекомендации
func (r *outfitRatingRepo) Create(ctx context.Context, rating *domain.OutfitRating) error {
	const query = `
		INSERT INTO outfit_ratings (
			user_id,
			recommendation_id,
			outfit_items,
			rating,
			quality_score,
			feedback,
			thermal_feedback
		) VALUES ($1, $2, $3, $4, $5, $6, $7)
		ON CONFLICT (user_id, recommendation_id) DO UPDATE SET
			rating = EXCLUDED.rating,
			quality_score = EXCLUDED.quality_score,
			feedback = EXCLUDED.feedback,
			thermal_feedback = EXCLUDED.thermal_feedback,
			created_at = NOW()
		RETURNING id, created_at
	`

	var createdAt time.Time
	err := r.db.QueryRow(ctx, query,
		rating.UserID,
		rating.RecommendationID,
		rating.OutfitItems,
		rating.Rating,
		rating.QualityScore,
		rating.Feedback,
		rating.ThermalFeedback,
	).Scan(&rating.ID, &createdAt)

	if err != nil {
		return fmt.Errorf("создание оценки рекомендации: %w", err)
	}

	rating.CreatedAt = createdAt
	return nil
}

// GetByRecommendation возвращает все оценки для рекомендации
func (r *outfitRatingRepo) GetByRecommendation(ctx context.Context, recommendationID domain.ID) ([]domain.OutfitRating, error) {
	const query = `
		SELECT 
			id,
			user_id,
			recommendation_id,
			outfit_items,
			rating,
			quality_score,
			feedback,
			thermal_feedback,
			created_at
		FROM outfit_ratings
		WHERE recommendation_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, recommendationID)
	if err != nil {
		return nil, fmt.Errorf("получение оценок для рекомендации: %w", err)
	}
	defer rows.Close()

	var ratings []domain.OutfitRating
	for rows.Next() {
		var rating domain.OutfitRating
		err := rows.Scan(
			&rating.ID,
			&rating.UserID,
			&rating.RecommendationID,
			&rating.OutfitItems,
			&rating.Rating,
			&rating.QualityScore,
			&rating.Feedback,
			&rating.ThermalFeedback,
			&rating.CreatedAt,
		)
		if err != nil {
			return nil, fmt.Errorf("сканирование оценки: %w", err)
		}
		ratings = append(ratings, rating)
	}

	if err = rows.Err(); err != nil {
		return nil, fmt.Errorf("ошибка итерации по оценкам: %w", err)
	}

	return ratings, nil
}

// GetByUserAndRecommendation возвращает оценку пользователя для рекомендации
func (r *outfitRatingRepo) GetByUserAndRecommendation(ctx context.Context, userID, recommendationID domain.ID) (*domain.OutfitRating, error) {
	const query = `
		SELECT 
			id,
			user_id,
			recommendation_id,
			outfit_items,
			rating,
			quality_score,
			feedback,
			thermal_feedback,
			created_at
		FROM outfit_ratings
		WHERE user_id = $1 AND recommendation_id = $2
	`

	var rating domain.OutfitRating
	err := r.db.QueryRow(ctx, query, userID, recommendationID).Scan(
		&rating.ID,
		&rating.UserID,
		&rating.RecommendationID,
		&rating.OutfitItems,
		&rating.Rating,
		&rating.QualityScore,
		&rating.Feedback,
		&rating.ThermalFeedback,
		&rating.CreatedAt,
	)

	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}

	return &rating, nil
}

// GetAverageQuality возвращает среднюю оценку качества для рекомендации
func (r *outfitRatingRepo) GetAverageQuality(ctx context.Context, recommendationID domain.ID) (*domain.RecommendationQualityStats, error) {
	const query = `
		SELECT 
			recommendation_id,
			COUNT(*) as rating_count,
			COALESCE(AVG(rating), 0) as avg_rating,
			COALESCE(AVG(quality_score), 0) as avg_quality_score,
			COALESCE(MIN(rating), 0) as min_rating,
			COALESCE(MAX(rating), 0) as max_rating,
			COALESCE(STDDEV(quality_score), 0) as quality_score_stddev,
			COUNT(*) FILTER (WHERE rating >= 4) as positive_count,
			COUNT(*) FILTER (WHERE rating <= 2) as negative_count
		FROM outfit_ratings
		WHERE recommendation_id = $1
		GROUP BY recommendation_id
	`

	var stats domain.RecommendationQualityStats
	var minRating, maxRating int
	var stddev pgtype.Float8

	err := r.db.QueryRow(ctx, query, recommendationID).Scan(
		&stats.RecommendationID,
		&stats.RatingCount,
		&stats.AvgRating,
		&stats.AvgQualityScore,
		&minRating,
		&maxRating,
		&stddev,
		&stats.PositiveCount,
		&stats.NegativeCount,
	)

	if err != nil {
		return nil, fmt.Errorf("получение статистики качества: %w", err)
	}

	stats.MinRating = minRating
	stats.MaxRating = maxRating
	if stddev.Valid {
		stats.QualityScoreStdDev = stddev.Float64
	}

	return &stats, nil
}

// GetUserRatingsForRecommendations возвращает оценки пользователя для списка рекомендаций
func (r *outfitRatingRepo) GetUserRatingsForRecommendations(ctx context.Context, userID domain.ID, recommendationIDs []domain.ID) (map[domain.ID]int, error) {
	if len(recommendationIDs) == 0 {
		return make(map[domain.ID]int), nil
	}

	const query = `
		SELECT recommendation_id, rating
		FROM outfit_ratings
		WHERE user_id = $1 AND recommendation_id = ANY($2)
	`

	rows, err := r.db.Query(ctx, query, userID, recommendationIDs)
	if err != nil {
		return nil, fmt.Errorf("получение оценок пользователя: %w", err)
	}
	defer rows.Close()

	ratingsMap := make(map[domain.ID]int)
	for rows.Next() {
		var recID domain.ID
		var rating int
		if err := rows.Scan(&recID, &rating); err != nil {
			return nil, fmt.Errorf("сканирование оценки: %w", err)
		}
		ratingsMap[recID] = rating
	}

	return ratingsMap, nil
}

// GetLowQualityItems возвращает вещи с низким рейтингом для пользователя
func (r *outfitRatingRepo) GetLowQualityItems(ctx context.Context, userID domain.ID, threshold float64) ([]domain.LowQualityItem, error) {
	const query = `
		SELECT 
			unnest(outfit_items) as clothing_item_id,
			COUNT(*) as times_in_low_rating,
			AVG(quality_score) as avg_quality_score
		FROM outfit_ratings
		WHERE user_id = $1 AND quality_score < $2
		GROUP BY unnest(outfit_items)
		HAVING AVG(quality_score) < $2
	`

	rows, err := r.db.Query(ctx, query, userID, threshold)
	if err != nil {
		return nil, fmt.Errorf("получение вещей с низким рейтингом: %w", err)
	}
	defer rows.Close()

	var items []domain.LowQualityItem
	for rows.Next() {
		var item domain.LowQualityItem
		if err := rows.Scan(
			&item.ClothingItemID,
			&item.TimesInLowRating,
			&item.AvgQualityScore,
		); err != nil {
			return nil, fmt.Errorf("сканирование вещи: %w", err)
		}
		items = append(items, item)
	}

	return items, nil
}

// GetUserStats возвращает статистику оценок пользователя
func (r *outfitRatingRepo) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserRatingStats, error) {
	const query = `
		SELECT 
			user_id,
			COUNT(*) as total_ratings,
			COALESCE(AVG(rating), 0) as avg_rating,
			COALESCE(AVG(quality_score), 0) as avg_quality_score,
			COUNT(*) FILTER (WHERE rating >= 4) as positive_ratings,
			COUNT(*) FILTER (WHERE rating <= 2) as negative_ratings,
			MAX(created_at) as last_rated_at
		FROM outfit_ratings
		WHERE user_id = $1
		GROUP BY user_id
	`

	var stats domain.UserRatingStats
	var lastRatedAt pgtype.Timestamptz

	err := r.db.QueryRow(ctx, query, userID).Scan(
		&stats.UserID,
		&stats.TotalRatings,
		&stats.AvgRating,
		&stats.AvgQualityScore,
		&stats.PositiveRatings,
		&stats.NegativeRatings,
		&lastRatedAt,
	)

	if err != nil {
		return nil, fmt.Errorf("получение статистики пользователя: %w", err)
	}

	if lastRatedAt.Valid {
		stats.LastRatedAt = &lastRatedAt.Time
	}

	return &stats, nil
}

// HasRated проверяет, оценил ли пользователь рекомендацию
func (r *outfitRatingRepo) HasRated(ctx context.Context, userID, recommendationID domain.ID) (bool, error) {
	const query = `SELECT EXISTS(SELECT 1 FROM outfit_ratings WHERE user_id = $1 AND recommendation_id = $2)`

	var exists bool
	err := r.db.QueryRow(ctx, query, userID, recommendationID).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("проверка наличия оценки: %w", err)
	}

	return exists, nil
}

// Update обновляет существующую оценку
func (r *outfitRatingRepo) Update(ctx context.Context, rating *domain.OutfitRating) error {
	const query = `
		UPDATE outfit_ratings
		SET 
			rating = $3,
			quality_score = $4,
			feedback = $5,
			thermal_feedback = $6,
			outfit_items = $7
		WHERE id = $1 AND user_id = $2
	`

	result, err := r.db.Exec(ctx, query,
		rating.ID,
		rating.UserID,
		rating.Rating,
		rating.QualityScore,
		rating.Feedback,
		rating.ThermalFeedback,
		rating.OutfitItems,
	)
	if err != nil {
		return fmt.Errorf("обновление оценки: %w", err)
	}

	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.New("оценка не найдена")
	}

	return nil
}
