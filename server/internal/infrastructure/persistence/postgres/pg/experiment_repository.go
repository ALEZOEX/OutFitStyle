package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type ExperimentRepository struct {
	db *pgxpool.Pool
}

func NewExperimentRepository(db *pgxpool.Pool) *ExperimentRepository {
	return &ExperimentRepository{db: db}
}

func (r *ExperimentRepository) GetExperiment(ctx context.Context, experimentID string) (*domain.Experiment, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) GetExperiments(ctx context.Context) ([]domain.Experiment, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) UpdateExperiment(ctx context.Context, experiment *domain.Experiment) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) GetUserVariant(ctx context.Context, userID domain.ID, experimentID string) (string, error) {
	// TODO: Implement
	return "", fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) AssignUserToVariant(ctx context.Context, userID domain.ID, experimentID string, variant string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) GetRunningByName(ctx context.Context, name string) (*repositories.Experiment, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) GetAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID) (*repositories.ExperimentAssignment, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) CreateAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ExperimentRepository) RecordEvent(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string, eventName string, eventValue *float64, eventData []byte) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}