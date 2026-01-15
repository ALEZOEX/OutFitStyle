package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type ExportRepository interface {
	BuildUserExport(ctx context.Context, userID domain.ID) (any, error)
}
