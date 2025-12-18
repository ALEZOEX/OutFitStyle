package pg

import (
	"context"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type ExperimentRepository struct{ db *dbpkg.DB }

func NewExperimentRepository(db *dbpkg.DB) repositories.ExperimentRepository {
	return &ExperimentRepository{db: db}
}

func (r *ExperimentRepository) GetRunningByName(ctx context.Context, name string) (*repositories.Experiment, error) {
	var e repositories.Experiment
	err := r.db.Pool().QueryRow(ctx, `
SELECT id, name, status, variants, user_percentage, created_at
FROM experiments
WHERE name = $1 AND status = 'running'
LIMIT 1
`, name).Scan(&e.ID, &e.Name, &e.Status, &e.VariantsJSON, &e.UserPercentage, &e.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get running experiment")
	}
	return &e, nil
}

func (r *ExperimentRepository) GetAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID) (*repositories.ExperimentAssignment, error) {
	var a repositories.ExperimentAssignment
	err := r.db.Pool().QueryRow(ctx, `
SELECT experiment_id, user_id, variant, assigned_at
FROM experiment_assignments
WHERE experiment_id = $1 AND user_id = $2
`, experimentID, userID).Scan(&a.ExperimentID, &a.UserID, &a.Variant, &a.AssignedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "get assignment")
	}
	return &a, nil
}

func (r *ExperimentRepository) CreateAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string) error {
	_, err := r.db.Pool().Exec(ctx, `
INSERT INTO experiment_assignments (experiment_id, user_id, variant)
VALUES ($1,$2,$3)
ON CONFLICT (experiment_id, user_id) DO NOTHING
`, experimentID, userID, variant)
	return errors.Wrap(err, "create assignment")
}

func (r *ExperimentRepository) RecordEvent(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string, eventName string, eventValue *float64, eventData []byte) error {
	_, err := r.db.Pool().Exec(ctx, `
INSERT INTO experiment_events (experiment_id, user_id, variant, event_name, event_value, event_data)
VALUES ($1,$2,$3,$4,$5,$6)
`, experimentID, userID, variant, eventName, eventValue, nullJSON(eventData))
	return errors.Wrap(err, "record event")
}

