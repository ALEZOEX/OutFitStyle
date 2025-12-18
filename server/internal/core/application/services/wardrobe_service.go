package services

import (
	"context"
	"errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type WardrobeService struct {
	wardrobeRepo repositories.WardrobeRepository
	clothingRepo repositories.ClothingRepository
}

func NewWardrobeService(w repositories.WardrobeRepository, c repositories.ClothingRepository) *WardrobeService {
	return &WardrobeService{wardrobeRepo: w, clothingRepo: c}
}

func (s *WardrobeService) List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) ([]domain.WardrobeItem, int, error) {
	return s.wardrobeRepo.List(ctx, userID, q)
}

func (s *WardrobeService) Get(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	return s.wardrobeRepo.GetByID(ctx, userID, wardrobeID)
}

func (s *WardrobeService) Create(ctx context.Context, userID domain.ID, req domain.WardrobeCreateRequest) (*domain.WardrobeItem, error) {
	if req.ClothingItemID != nil {
		return s.wardrobeRepo.Add(ctx, userID, *req.ClothingItemID, req.CustomName, req.Notes, req.Tags)
	}

	// создать новую вещь пользователя
	if req.Name == nil || req.Category == nil || req.Subcategory == nil || req.Style == nil {
		return nil, errors.New("either clothing_item_id or (name, category, subcategory, style) is required")
	}

	item := domain.ClothingItem{
		Name:        *req.Name,
		Category:    *req.Category,
		Subcategory: *req.Subcategory,
		Style:       *req.Style,
		BaseColour:  req.BaseColour,
		Pattern:     "solid",
		Fit:         "regular",
		Gender:      "unisex",
		Season:      "all",
		Source:      "user",
		IsOwned:     true,
		IsActive:    true,
	}

	itemID, err := s.clothingRepo.CreateUserItem(ctx, userID, item)
	if err != nil {
		return nil, err
	}

	return s.wardrobeRepo.Add(ctx, userID, itemID, req.CustomName, req.Notes, req.Tags)
}

func (s *WardrobeService) Update(ctx context.Context, userID, wardrobeID domain.ID, req domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error) {
	return s.wardrobeRepo.Update(ctx, userID, wardrobeID, req)
}

func (s *WardrobeService) Delete(ctx context.Context, userID, wardrobeID domain.ID) error {
	return s.wardrobeRepo.Delete(ctx, userID, wardrobeID)
}

func (s *WardrobeService) SetFavorite(ctx context.Context, userID, wardrobeID domain.ID, isFavorite bool) error {
	return s.wardrobeRepo.SetFavorite(ctx, userID, wardrobeID, isFavorite)
}

func (s *WardrobeService) SetArchived(ctx context.Context, userID, wardrobeID domain.ID, isArchived bool) error {
	return s.wardrobeRepo.SetArchived(ctx, userID, wardrobeID, isArchived)
}

func (s *WardrobeService) MarkWorn(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	return s.wardrobeRepo.MarkWorn(ctx, userID, wardrobeID)
}