package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type PersonalizationRepository interface {
	GetUserPreferences(ctx context.Context, userID domain.ID) (domain.UserPreferences, error)

	GetRecentItems(ctx context.Context, userID domain.ID, limit int) ([]domain.ID, error)
	GetRatedItems(ctx context.Context, userID domain.ID, highMin int, lowMax int, limit int) (high []domain.ID, low []domain.ID, err error)

	GetStyleDistribution(ctx context.Context, userID domain.ID, limit int) (map[string]float64, error)

	GetItemRatingsMap(ctx context.Context, userID domain.ID, itemIDs []domain.ID) (map[domain.ID]float64, error)
}
