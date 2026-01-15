package pg

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type FeedbackRepository struct {
	db *dbpkg.DB
}

func NewFeedbackRepository(db *dbpkg.DB) repositories.FeedbackRepository {
	return &FeedbackRepository{db: db}
}

func (r *FeedbackRepository) CreateFeedback(ctx context.Context, userID domain.ID, req domain.CreateFeedbackRequest) (domain.ID, error) {
	if req.Type == "" || req.Message == "" {
		return domain.ID{}, errors.New("type and message are required")
	}

	var id domain.ID
	err := r.db.Pool().QueryRow(ctx, `
INSERT INTO app_feedback (user_id, type, screen, message, attachments)
VALUES ($1,$2,$3,$4,$5)
RETURNING id
`, userID, req.Type, req.Screen, req.Message, req.Attachments).Scan(&id)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "insert feedback")
	}
	return id, nil
}
