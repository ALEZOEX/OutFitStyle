package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type UploadedFilesRepository interface {
	Create(ctx context.Context, userID *domain.ID, bucket, path, filename, mimeType string, sizeBytes int64) (domain.ID, error)
}
