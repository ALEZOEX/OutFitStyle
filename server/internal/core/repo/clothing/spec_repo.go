package clothing

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

// SubcategorySpecRepository интерфейс для работы со спецификациями подкатегорий
type SubcategorySpecRepository interface {
	ListAll(ctx context.Context) ([]domain.SubcategorySpec, error)
	Get(ctx context.Context, category, subcategory string) (domain.SubcategorySpec, error)
}
