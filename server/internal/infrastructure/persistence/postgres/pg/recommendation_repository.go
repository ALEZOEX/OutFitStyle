package pg

import (
	"context"
	"fmt"

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

func (r *RecommendationRepository) Save(ctx context.Context, rec *domain.Recommendation) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *RecommendationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.Recommendation, error) {
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