package services

import (
	"context"
	"errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type ShareService struct {
	repo repositories.ShareRepository
}

func NewShareService(repo repositories.ShareRepository) *ShareService {
	return &ShareService{repo: repo}
}

func (s *ShareService) Create(ctx context.Context, userID domain.ID, req domain.ShareCreateRequest) (string, error) {
	hasRec := req.RecommendationID != nil
	hasSaved := req.SavedOutfitID != nil
	if hasRec == hasSaved {
		return "", errors.New("either recommendation_id or saved_outfit_id is required")
	}
	show := false
	if req.ShowUserName != nil {
		show = *req.ShowUserName
	}
	return s.repo.CreateShare(ctx, userID, req.RecommendationID, req.SavedOutfitID, show)
}

func (s *ShareService) GetPublic(ctx context.Context, shareCode string) (outfit any, userName *string, err error) {
	rec, err := s.repo.GetByCode(ctx, shareCode)
	if err != nil || rec == nil {
		return nil, nil, err
	}
	if !rec.IsPublic {
		return nil, nil, nil
	}

	_ = s.repo.IncViews(ctx, shareCode)

	if rec.RecommendationID != nil {
		outfit, err = s.repo.GetRecommendationOutfit(ctx, *rec.RecommendationID)
		if err != nil {
			return nil, nil, err
		}
	} else if rec.SavedOutfitID != nil {
		outfit, err = s.repo.GetSavedOutfit(ctx, *rec.SavedOutfitID)
		if err != nil {
			return nil, nil, err
		}
	}

	if rec.ShowUserName {
		userName, _ = s.repo.GetUserDisplayName(ctx, rec.UserID)
	}

	return outfit, userName, nil
}