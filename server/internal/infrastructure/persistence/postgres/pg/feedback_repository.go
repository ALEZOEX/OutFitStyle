package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type FeedbackRepository struct {
	db *pgxpool.Pool
}

func NewFeedbackRepository(db *pgxpool.Pool) *FeedbackRepository {
	return &FeedbackRepository{db: db}
}

func (r *FeedbackRepository) GetFeedback(ctx context.Context, feedbackID domain.ID) (*domain.Feedback, error) {
	query := `
		SELECT id, user_id, type, message, rating, metadata, is_resolved, resolved_at, resolved_by, created_at, updated_at
		FROM feedback
		WHERE id = $1
	`

	var feedback domain.Feedback
	var metadataJSON []byte
	var resolvedAt *time.Time
	var resolvedBy *uuid.UUID

	err := r.db.QueryRow(ctx, query, feedbackID).Scan(
		&feedback.ID,
		&feedback.UserID,
		&feedback.Type,
		&feedback.Message,
		&feedback.Rating,
		&metadataJSON,
		&feedback.IsResolved,
		&resolvedAt,
		&resolvedBy,
		&feedback.CreatedAt,
		&feedback.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get feedback")
	}

	// Parse metadata
	if len(metadataJSON) > 0 {
		err = json.Unmarshal(metadataJSON, &feedback.Metadata)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal feedback metadata")
		}
	}

	// Set nullable fields
	if resolvedAt != nil {
		feedback.ResolvedAt = resolvedAt
	}
	if resolvedBy != nil {
		rid := domain.ID(*resolvedBy)
		feedback.ResolvedBy = &rid
	}

	return &feedback, nil
}

func (r *FeedbackRepository) GetFeedbackByUser(ctx context.Context, userID domain.ID) ([]domain.Feedback, error) {
	query := `
		SELECT id, user_id, type, message, rating, metadata, is_resolved, resolved_at, resolved_by, created_at, updated_at
		FROM feedback
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query feedback by user")
	}
	defer rows.Close()

	var feedbacks []domain.Feedback
	for rows.Next() {
		var feedback domain.Feedback
		var metadataJSON []byte
		var resolvedAt *time.Time
		var resolvedBy *uuid.UUID

		err := rows.Scan(
			&feedback.ID,
			&feedback.UserID,
			&feedback.Type,
			&feedback.Message,
			&feedback.Rating,
			&metadataJSON,
			&feedback.IsResolved,
			&resolvedAt,
			&resolvedBy,
			&feedback.CreatedAt,
			&feedback.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan feedback")
		}

		// Parse metadata
		if len(metadataJSON) > 0 {
			err = json.Unmarshal(metadataJSON, &feedback.Metadata)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal feedback metadata")
			}
		}

		// Set nullable fields
		if resolvedAt != nil {
			feedback.ResolvedAt = resolvedAt
		}
		if resolvedBy != nil {
			rid := domain.ID(*resolvedBy)
			feedback.ResolvedBy = &rid
		}

		feedbacks = append(feedbacks, feedback)
	}

	return feedbacks, nil
}

func (r *FeedbackRepository) CreateFeedback(ctx context.Context, userID domain.ID, req domain.CreateFeedbackRequest) (domain.ID, error) {
	id := domain.NewID()

	query := `
		INSERT INTO feedback (
			id, user_id, type, message, rating, metadata, is_resolved, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	`

	metadataJSON, err := json.Marshal(req.Metadata)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to marshal feedback metadata")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		userID,
		req.Type,
		req.Message,
		req.Rating,
		metadataJSON,
		false, // is_resolved defaults to false
		time.Now(),
		time.Now(),
	)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to create feedback")
	}

	return id, nil
}
