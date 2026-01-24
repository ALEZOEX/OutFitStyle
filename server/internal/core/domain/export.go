package domain

import "time"

type ExportStatus string

const (
	ExportStatusPending ExportStatus = "pending"
	ExportStatusProcessing ExportStatus = "processing"
	ExportStatusCompleted ExportStatus = "completed"
	ExportStatusFailed ExportStatus = "failed"
	ExportStatusCancelled ExportStatus = "cancelled"
)

type ExportJob struct {
	ID          ID           `json:"id"`
	UserID      ID           `json:"user_id"`
	Type        string       `json:"type"` // wardrobe, outfits, etc.
	Status      ExportStatus `json:"status"`
	Progress    int          `json:"progress"` // percentage
	FileURL     *string      `json:"file_url,omitempty"`
	ErrorMsg    *string      `json:"error_msg,omitempty"`
	CreatedAt   time.Time    `json:"created_at"`
	StartedAt   *time.Time   `json:"started_at,omitempty"`
	CompletedAt *time.Time   `json:"completed_at,omitempty"`
}