package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type ExportRepository struct {
	db *pgxpool.Pool
}

func NewExportRepository(db *pgxpool.Pool) *ExportRepository {
	return &ExportRepository{db: db}
}

func (r *ExportRepository) Create(ctx context.Context, export *domain.ExportJob) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ExportRepository) GetByID(ctx context.Context, jobID domain.ID) (*domain.ExportJob, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *ExportRepository) UpdateStatus(ctx context.Context, jobID domain.ID, status domain.ExportStatus) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *ExportRepository) GetUserExports(ctx context.Context, userID domain.ID) ([]domain.ExportJob, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}