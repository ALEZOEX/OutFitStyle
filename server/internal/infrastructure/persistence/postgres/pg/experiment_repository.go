// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// ExperimentRepository репозиторий для работы с экспериментами
type ExperimentRepository struct {
	db *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
}

// NewExperimentRepository создает новый экземпляр репозитория экспериментов
func NewExperimentRepository(db *pgxpool.Pool) *ExperimentRepository {
	return &ExperimentRepository{db: db}
}

func (r *ExperimentRepository) GetExperiment(ctx context.Context, experimentID string) (*domain.Experiment, error) {
	query := `
		SELECT id, name, description, variants, weights, start_date, end_date, is_active, created_at, updated_at
		FROM experiments
		WHERE id = $1
	`

	var exp domain.Experiment
	var variantsJSON []byte
	var weightsJSON []byte
	var endDate *time.Time

	err := r.db.QueryRow(ctx, query, experimentID).Scan(
		&exp.ID,
		&exp.Name,
		&exp.Description,
		&variantsJSON,
		&weightsJSON,
		&exp.StartDate,
		&endDate,
		&exp.IsActive,
		&exp.CreatedAt,
		&exp.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get experiment")
	}

	// Parse variants
	if len(variantsJSON) > 0 {
		err = json.Unmarshal(variantsJSON, &exp.Variants)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal variants")
		}
	}

	// Parse weights
	if len(weightsJSON) > 0 {
		err = json.Unmarshal(weightsJSON, &exp.Weights)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal weights")
		}
	}

	exp.EndDate = endDate

	return &exp, nil
}

func (r *ExperimentRepository) GetExperiments(ctx context.Context) ([]domain.Experiment, error) {
	query := `
		SELECT id, name, description, variants, weights, start_date, end_date, is_active, created_at, updated_at
		FROM experiments
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query experiments")
	}
	defer rows.Close()

	var experiments []domain.Experiment
	for rows.Next() {
		var exp domain.Experiment
		var variantsJSON []byte
		var weightsJSON []byte
		var endDate *time.Time

		err := rows.Scan(
			&exp.ID,
			&exp.Name,
			&exp.Description,
			&variantsJSON,
			&weightsJSON,
			&exp.StartDate,
			&endDate,
			&exp.IsActive,
			&exp.CreatedAt,
			&exp.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan experiment")
		}

		// Parse variants
		if len(variantsJSON) > 0 {
			err = json.Unmarshal(variantsJSON, &exp.Variants)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal variants")
			}
		}

		// Parse weights
		if len(weightsJSON) > 0 {
			err = json.Unmarshal(weightsJSON, &exp.Weights)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal weights")
			}
		}

		exp.EndDate = endDate

		experiments = append(experiments, exp)
	}

	return experiments, nil
}

func (r *ExperimentRepository) UpdateExperiment(ctx context.Context, experiment *domain.Experiment) error {
	query := `
		UPDATE experiments
		SET name = $1, description = $2, variants = $3, weights = $4, start_date = $5,
		    end_date = $6, is_active = $7, updated_at = $8
		WHERE id = $9
	`

	variantsJSON, err := json.Marshal(experiment.Variants)
	if err != nil {
		return errors.Wrap(err, "failed to marshal variants")
	}

	weightsJSON, err := json.Marshal(experiment.Weights)
	if err != nil {
		return errors.Wrap(err, "failed to marshal weights")
	}

	_, err = r.db.Exec(ctx, query,
		experiment.Name,
		experiment.Description,
		variantsJSON,
		weightsJSON,
		experiment.StartDate,
		experiment.EndDate,
		experiment.IsActive,
		time.Now(),
		experiment.ID,
	)
	if err != nil {
		return errors.Wrap(err, "failed to update experiment")
	}

	return nil
}

func (r *ExperimentRepository) GetUserVariant(ctx context.Context, userID domain.ID, experimentID string) (string, error) {
	query := `
		SELECT variant
		FROM experiment_assignments
		WHERE user_id = $1 AND experiment_id = $2
	`

	var variant string
	err := r.db.QueryRow(ctx, query, userID, experimentID).Scan(&variant)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return "", nil // No assignment found
		}
		return "", errors.Wrap(err, "failed to get user variant")
	}

	return variant, nil
}

func (r *ExperimentRepository) AssignUserToVariant(ctx context.Context, userID domain.ID, experimentID string, variant string) error {
	query := `
		INSERT INTO experiment_assignments (user_id, experiment_id, variant, assigned_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, experiment_id)
		DO UPDATE SET variant = $3, assigned_at = $4
	`

	_, err := r.db.Exec(ctx, query, userID, experimentID, variant, time.Now())
	if err != nil {
		return errors.Wrap(err, "failed to assign user to variant")
	}

	return nil
}

func (r *ExperimentRepository) GetRunningByName(ctx context.Context, name string) (*repositories.Experiment, error) {
	query := `
		SELECT id, name, description, variants, weights, start_date, end_date, is_active, created_at, updated_at
		FROM experiments
		WHERE name = $1 AND is_active = true AND (end_date IS NULL OR end_date > NOW())
	`

	var exp repositories.Experiment
	var variantsJSON []byte
	var weightsJSON []byte
	var endDate *time.Time

	err := r.db.QueryRow(ctx, query, name).Scan(
		&exp.ID,
		&exp.Name,
		&exp.Description,
		&variantsJSON,
		&weightsJSON,
		&exp.StartDate,
		&endDate,
		&exp.IsActive,
		&exp.CreatedAt,
		&exp.UpdatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get running experiment by name")
	}

	// Parse variants
	if len(variantsJSON) > 0 {
		err = json.Unmarshal(variantsJSON, &exp.Variants)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal variants")
		}
	}

	// Parse weights
	if len(weightsJSON) > 0 {
		err = json.Unmarshal(weightsJSON, &exp.Weights)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal weights")
		}
	}

	exp.EndDate = endDate

	return &exp, nil
}

func (r *ExperimentRepository) GetAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID) (*repositories.ExperimentAssignment, error) {
	query := `
		SELECT experiment_id, user_id, variant, assigned_at
		FROM experiment_assignments
		WHERE experiment_id = $1 AND user_id = $2
	`

	var assignment repositories.ExperimentAssignment

	err := r.db.QueryRow(ctx, query, experimentID, userID).Scan(
		&assignment.ExperimentID,
		&assignment.UserID,
		&assignment.Variant,
		&assignment.AssignedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get experiment assignment")
	}

	return &assignment, nil
}

func (r *ExperimentRepository) CreateAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string) error {
	query := `
		INSERT INTO experiment_assignments (experiment_id, user_id, variant, assigned_at)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (experiment_id, user_id)
		DO UPDATE SET variant = $3, assigned_at = $4
	`

	_, err := r.db.Exec(ctx, query, experimentID, userID, variant, time.Now())
	if err != nil {
		return errors.Wrap(err, "failed to create experiment assignment")
	}

	return nil
}

func (r *ExperimentRepository) RecordEvent(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string, eventName string, eventValue *float64, eventData []byte) error {
	query := `
		INSERT INTO experiment_events (experiment_id, user_id, variant, event_name, event_value, event_data, recorded_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7)
	`

	_, err := r.db.Exec(ctx, query,
		experimentID,
		userID,
		variant,
		eventName,
		eventValue,
		eventData,
		time.Now(),
	)
	if err != nil {
		return errors.Wrap(err, "failed to record experiment event")
	}

	return nil
}
