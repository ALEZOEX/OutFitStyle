package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type UploadedFilesRepository struct {
	db *pgxpool.Pool
}

func NewUploadedFilesRepository(db *pgxpool.Pool) *UploadedFilesRepository {
	return &UploadedFilesRepository{db: db}
}

func (r *UploadedFilesRepository) Create(ctx context.Context, file *domain.UploadedFile) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *UploadedFilesRepository) GetByID(ctx context.Context, fileID domain.ID) (*domain.UploadedFile, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UploadedFilesRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.UploadedFile, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *UploadedFilesRepository) UpdateStatus(ctx context.Context, fileID domain.ID, status domain.UploadStatus) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}