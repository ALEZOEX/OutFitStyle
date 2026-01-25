package domain

import "time"

type UploadStatus string

const (
	UploadStatusPending    UploadStatus = "pending"
	UploadStatusProcessing UploadStatus = "processing"
	UploadStatusProcessed  UploadStatus = "processed"
	UploadStatusFailed     UploadStatus = "failed"
)

type UploadedFile struct {
	ID           ID           `json:"id"`
	UserID       ID           `json:"user_id"`
	FileName     string       `json:"file_name"`
	FileType     string       `json:"file_type"` // image/jpeg, image/png, etc.
	FileSize     int64        `json:"file_size"`
	URL          string       `json:"url"`
	ThumbnailURL *string      `json:"thumbnail_url,omitempty"`
	UploadStatus UploadStatus `json:"upload_status"` // pending, processed, failed
	Metadata     any          `json:"metadata,omitempty"`
	CreatedAt    time.Time    `json:"created_at"`
	UpdatedAt    time.Time    `json:"updated_at"`
}
