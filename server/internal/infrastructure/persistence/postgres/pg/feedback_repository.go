package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type FeedbackRepository struct {
	db *pgxpool.Pool
}

func NewFeedbackRepository(db *pgxpool.Pool) *FeedbackRepository {
	return &FeedbackRepository{db: db}
}

func (r *FeedbackRepository) CreateFeedback(ctx context.Context, feedback *domain.Feedback) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *FeedbackRepository) GetFeedback(ctx context.Context, feedbackID domain.ID) (*domain.Feedback, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *FeedbackRepository) GetFeedbackByUser(ctx context.Context, userID domain.ID) ([]domain.Feedback, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}