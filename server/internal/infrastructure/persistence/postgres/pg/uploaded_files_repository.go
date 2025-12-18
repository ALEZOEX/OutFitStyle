package pg

import (
	"context"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type UploadedFilesRepository struct {
	db *dbpkg.DB
}

func NewUploadedFilesRepository(db *dbpkg.DB) repositories.UploadedFilesRepository {
	return &UploadedFilesRepository{db: db}
}

func (r *UploadedFilesRepository) Create(ctx context.Context, userID *domain.ID, bucket, path, filename, mimeType string, sizeBytes int64) (domain.ID, error) {
	var id domain.ID
	err := r.db.Pool().QueryRow(ctx, `
INSERT INTO uploaded_files (user_id, bucket, path, filename, mime_type, size_bytes, status)
VALUES ($1,$2,$3,$4,$5,$6,'active')
RETURNING id
`, userID, bucket, path, filename, mimeType, sizeBytes).Scan(&id)
	if err != nil {
		return domain.ID{}, errors.Wrap(err, "insert uploaded_file")
	}
	return id, nil
}