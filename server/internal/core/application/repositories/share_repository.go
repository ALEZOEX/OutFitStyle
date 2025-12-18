package repositories

import (
	"context"

	"outfitstyle/server/internal/core/domain"
)

type SharedOutfitRecord struct {
	ID domain.ID

	UserID domain.ID
	ShowUserName bool
	IsPublic bool

	RecommendationID *domain.ID
	SavedOutfitID *domain.ID

	ShareCode string
}

type ShareRepository interface {
	CreateShare(ctx context.Context, userID domain.ID, recommendationID *domain.ID, savedOutfitID *domain.ID, showUserName bool) (shareCode string, err error)
	GetByCode(ctx context.Context, code string) (*SharedOutfitRecord, error)

	IncViews(ctx context.Context, code string) error

	GetUserDisplayName(ctx context.Context, userID domain.ID) (*string, error)
	GetRecommendationOutfit(ctx context.Context, recommendationID domain.ID) (outfit any, err error)
	GetSavedOutfit(ctx context.Context, savedOutfitID domain.ID) (outfit any, err error)
}