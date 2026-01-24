package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// ExportRepository интерфейс репозитория экспорта
type ExportRepository interface {
	// BuildUserExport создает экспорт данных пользователя
	BuildUserExport(ctx context.Context, userID domain.ID) (any, error)
}
