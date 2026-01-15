package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type AuditCreate struct {
	UserID *domain.ID

	Action       string
	ResourceType *string
	ResourceID   *domain.ID

	OldValue []byte
	NewValue []byte

	IPAddress *string
	UserAgent *string

	Success      bool
	ErrorMessage *string
}

type AuditRepository interface {
	Create(ctx context.Context, a AuditCreate) error
}
