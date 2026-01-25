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

type UploadedFilesRepository struct {
	db *pgxpool.Pool
}

func NewUploadedFilesRepository(db *pgxpool.Pool) *UploadedFilesRepository {
	return &UploadedFilesRepository{db: db}
}

func (r *UploadedFilesRepository) Create(ctx context.Context, userID *domain.ID, bucket, path, filename, mimeType string, sizeBytes int64) (domain.ID, error) {
	id := domain.NewID()
	now := time.Now()

	query := `
		INSERT INTO uploaded_files (
			id, user_id, bucket, path, filename, file_type, file_size, upload_status, metadata, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
	`

	// Create default metadata
	metadata := map[string]interface{}{
		"bucket": bucket,
		"path":   path,
	}

	metadataJSON, err := json.Marshal(metadata)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to marshal metadata")
	}

	_, err = r.db.Exec(ctx, query,
		id,
		userID,
		bucket,
		path,
		filename,
		mimeType,
		sizeBytes,
		domain.UploadStatusPending, // Default status
		metadataJSON,
		now,
		now,
	)
	if err != nil {
		return domain.NilID, errors.Wrap(err, "failed to create uploaded file record")
	}

	return id, nil
}

func (r *UploadedFilesRepository) GetByID(ctx context.Context, fileID domain.ID) (*domain.UploadedFile, error) {
	query := `
		SELECT 
			id, user_id, file_name, file_type, file_size, url, thumbnail_url, upload_status, metadata, created_at, updated_at
		FROM uploaded_files
		WHERE id = $1
	`

	var file domain.UploadedFile
	var userID *uuid.UUID
	var fileName string
	var fileType string
	var fileSize int64
	var url *string
	var thumbnailURL *string
	var uploadStatus string
	var metadataJSON []byte
	var createdAt time.Time
	var updatedAt time.Time

	err := r.db.QueryRow(ctx, query, fileID).Scan(
		&file.ID,
		&userID,
		&fileName,
		&fileType,
		&fileSize,
		&url,
		&thumbnailURL,
		&uploadStatus,
		&metadataJSON,
		&createdAt,
		&updatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get uploaded file by ID")
	}

	// Set fields
	if fileName != "" {
		file.FileName = fileName
	}
	file.FileType = fileType
	file.FileSize = fileSize
	if url != nil {
		file.URL = *url
	}
	file.ThumbnailURL = thumbnailURL
	file.CreatedAt = createdAt
	file.UpdatedAt = updatedAt

	// Set upload status
	switch uploadStatus {
	case "pending":
		file.UploadStatus = domain.UploadStatusPending
	case "processing":
		file.UploadStatus = domain.UploadStatusProcessing
	case "processed":
		file.UploadStatus = domain.UploadStatusProcessed
	case "failed":
		file.UploadStatus = domain.UploadStatusFailed
	}

	// Set user ID if not null
	if userID != nil {
		uid := domain.ID(*userID)
		file.UserID = uid
	}

	// Parse metadata
	if len(metadataJSON) > 0 {
		err = json.Unmarshal(metadataJSON, &file.Metadata)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal metadata")
		}
	}

	return &file, nil
}

func (r *UploadedFilesRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.UploadedFile, error) {
	query := `
		SELECT 
			id, user_id, file_name, file_type, file_size, url, thumbnail_url, upload_status, metadata, created_at, updated_at
		FROM uploaded_files
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query uploaded files by user")
	}
	defer rows.Close()

	var files []domain.UploadedFile
	for rows.Next() {
		var file domain.UploadedFile
		var fileName string
		var fileType string
		var fileSize int64
		var url *string
		var thumbnailURL *string
		var uploadStatus string
		var metadataJSON []byte
		var createdAt time.Time
		var updatedAt time.Time

		err := rows.Scan(
			&file.ID,
			&file.UserID,
			&fileName,
			&fileType,
			&fileSize,
			&url,
			&thumbnailURL,
			&uploadStatus,
			&metadataJSON,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan uploaded file")
		}

		// Set fields
		if fileName != "" {
			file.FileName = fileName
		}
		file.FileType = fileType
		file.FileSize = fileSize
		if url != nil {
			file.URL = *url
		}
		file.ThumbnailURL = thumbnailURL
		file.CreatedAt = createdAt
		file.UpdatedAt = updatedAt

		// Set upload status
		switch uploadStatus {
		case "pending":
			file.UploadStatus = domain.UploadStatusPending
		case "processing":
			file.UploadStatus = domain.UploadStatusProcessing
		case "processed":
			file.UploadStatus = domain.UploadStatusProcessed
		case "failed":
			file.UploadStatus = domain.UploadStatusFailed
		}

		// Parse metadata
		if len(metadataJSON) > 0 {
			err = json.Unmarshal(metadataJSON, &file.Metadata)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal metadata")
			}
		}

		files = append(files, file)
	}

	return files, nil
}

func (r *UploadedFilesRepository) UpdateStatus(ctx context.Context, fileID domain.ID, status domain.UploadStatus) error {
	query := `
		UPDATE uploaded_files
		SET upload_status = $1, updated_at = $2
		WHERE id = $3
	`

	var statusStr string
	switch status {
	case domain.UploadStatusPending:
		statusStr = "pending"
	case domain.UploadStatusProcessing:
		statusStr = "processing"
	case domain.UploadStatusProcessed:
		statusStr = "processed"
	case domain.UploadStatusFailed:
		statusStr = "failed"
	}

	_, err := r.db.Exec(ctx, query, statusStr, time.Now(), fileID)
	if err != nil {
		return errors.Wrap(err, "failed to update uploaded file status")
	}

	return nil
}
