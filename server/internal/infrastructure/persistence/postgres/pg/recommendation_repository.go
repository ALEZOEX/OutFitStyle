package pg

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type RecommendationRepository struct {
	db *pgxpool.Pool
}

func NewRecommendationRepository(db *pgxpool.Pool, logger interface{}) *RecommendationRepository {
	return &RecommendationRepository{db: db}
}

func (r *RecommendationRepository) Create(ctx context.Context, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	// Реализация осталась прежней
	return r.createWithSessionInternal(ctx, nil, rec, items)
}

func (r *RecommendationRepository) CreateWithSession(ctx context.Context, session *repositories.RecommendationSession, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	return r.createWithSessionInternal(ctx, session, rec, items)
}

func (r *RecommendationRepository) createWithSessionInternal(ctx context.Context, session *repositories.RecommendationSession, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()

	tx, err := r.db.Begin(ctx)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to begin transaction: %w", err)
	}

	defer func() {
		if err != nil {
			_ = tx.Rollback(ctx)
		}
	}()

	// Создаем сессию, если она передана
	var sessionID *uuid.UUID
	if session != nil {
		sessionUUID := uuid.New()
		sessionID = &sessionUUID

		weatherData := session.WeatherData
		if weatherData == nil {
			weatherData = []byte("{}")
		}

		userPrefs := session.UserPreferences
		if userPrefs == nil {
			userPrefs = []byte("{}")
		}

		_, err = tx.Exec(ctx, `
			INSERT INTO recommendation_sessions (
				id, user_id, context_hash, model_version, weather_data, user_preferences
			) VALUES ($1, $2, $3, $4, $5, $6)
		`, sessionID, session.UserID, session.ContextHash, session.ModelVersion, weatherData, userPrefs)
		if err != nil {
			return domain.NilID, fmt.Errorf("failed to insert recommendation session: %w", err)
		}
	}

	// Insert recommendation
	recID := domain.NewID()
	outfitScore := 0.0
	if rec.TotalScore != nil {
		outfitScore = *rec.TotalScore
	}

	algorithm := "default"
	if rec.ModelVersion != nil {
		algorithm = *rec.ModelVersion
	}

	location := ""
	if rec.Location != nil {
		location = *rec.Location
	}

	_, err = tx.Exec(ctx, `
		INSERT INTO recommendations (
			id, user_id, temperature, weather, outfit_score, ml_powered, algorithm, location
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
	`, recID, rec.UserID, 0.0, "", outfitScore, true, algorithm, location)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to insert recommendation: %w", err)
	}

	// Insert recommendation items
	for _, item := range items {
		var score *float64
		if item.Score != nil {
			score = item.Score
		}

		_, err = tx.Exec(ctx, `
			INSERT INTO recommendation_items (
				id, recommendation_id, clothing_item_id, category, source, is_from_wardrobe, alternatives_json, session_id, score, rank
			) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, 0)
			ON CONFLICT (recommendation_id, clothing_item_id)
			DO UPDATE SET
				category = EXCLUDED.category,
				source = EXCLUDED.source,
				is_from_wardrobe = EXCLUDED.is_from_wardrobe,
				alternatives_json = EXCLUDED.alternatives_json,
				session_id = EXCLUDED.session_id,
				score = EXCLUDED.score
		`,
			recID, item.ClothingItemID, item.Category, item.Source, item.IsFromWardrobe, item.AlternativesJSON, sessionID, score)
		if err != nil {
			return domain.NilID, fmt.Errorf("failed to insert recommendation item: %w", err)
		}
	}

	// Update user stats
	_, err = tx.Exec(ctx, `
		INSERT INTO user_stats (user_id, total_recommendations, last_active)
		VALUES ($1, 1, NOW())
		ON CONFLICT (user_id)
		DO UPDATE SET
			total_recommendations = user_stats.total_recommendations + 1,
			last_active = NOW()
	`, rec.UserID)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to update user stats: %w", err)
	}

	// Commit transaction
	if err = tx.Commit(ctx); err != nil {
		return domain.NilID, fmt.Errorf("failed to commit transaction: %w", err)
	}

	return recID, nil
}

func (r *RecommendationRepository) CreateRecommendation(ctx context.Context, rec *domain.RecommendationResponse) (*domain.RecommendationResponse, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.RecommendationRecord, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) GetByUser(ctx context.Context, userID domain.ID, limit, offset int) ([]domain.Recommendation, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) GetByUserAndDateRange(ctx context.Context, userID domain.ID, from, to *string) ([]domain.Recommendation, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) Update(ctx context.Context, rec *domain.Recommendation) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) Delete(ctx context.Context, id domain.ID) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) GetItemRows(ctx context.Context, recommendationID domain.ID) ([]repositories.RecommendationItemRow, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) SetRating(ctx context.Context, userID, recommendationID domain.ID, rating int, thermalFeedback *string, feedback *string) (bool, error) {
	// TODO: Implement
	return false, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) SetFavorite(ctx context.Context, userID, recommendationID domain.ID, isFavorite bool) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) ListFavorites(ctx context.Context, userID domain.ID, limit int) ([]domain.RecommendationRecord, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) ListByUser(ctx context.Context, userID domain.ID, q domain.RecommendationListQuery) ([]domain.RecommendationRecord, int, error) {
	// TODO: Implement
	return nil, 0, fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) CreateSession(ctx context.Context, session *repositories.RecommendationSession) (domain.ID, error) {
	sessionID := domain.NewID()

	weatherData := session.WeatherData
	if weatherData == nil {
		weatherData = []byte("{}")
	}

	userPrefs := session.UserPreferences
	if userPrefs == nil {
		userPrefs = []byte("{}")
	}

	_, err := r.db.Exec(ctx, `
		INSERT INTO recommendation_sessions (
			id, user_id, context_hash, model_version, weather_data, user_preferences
		) VALUES ($1, $2, $3, $4, $5, $6)
	`, sessionID, session.UserID, session.ContextHash, session.ModelVersion, weatherData, userPrefs)
	if err != nil {
		return domain.NilID, fmt.Errorf("failed to insert recommendation session: %w", err)
	}

	return sessionID, nil
}