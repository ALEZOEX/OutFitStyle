package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// UploadedFilesRepository интерфейс репозитория загруженных файлов
type UploadedFilesRepository interface {
	// Create создает запись о загруженном файле
	Create(ctx context.Context, userID *domain.ID, bucket, path, filename, mimeType string, sizeBytes int64) (domain.ID, error)
}
