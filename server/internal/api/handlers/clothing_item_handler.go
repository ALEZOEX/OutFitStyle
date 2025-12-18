package handlers

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/google/uuid"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	httputils "outfitstyle/server/internal/pkg/http"
)

// ClothingItemHandler handles clothing item-related HTTP requests
type ClothingItemHandler struct {
	clothingItemService *services.ClothingItemService
	logger              *zap.Logger
}

// NewClothingItemHandler creates a new clothing item handler
func NewClothingItemHandler(clothingItemService *services.ClothingItemService, logger *zap.Logger) *ClothingItemHandler {
	return &ClothingItemHandler{
		clothingItemService: clothingItemService,
		logger:              logger,
	}
}

// GetWardrobeItems retrieves user's wardrobe items
func (h *ClothingItemHandler) GetWardrobeItems(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		http.Error(w, "user not authenticated", http.StatusUnauthorized)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	items, err := h.clothingItemService.GetWardrobeItems(ctx, userID)
	if err != nil {
		h.logger.Error("Failed to get wardrobe items",
			zap.Error(err),
			zap.String("user_id", userID.String()),
		)
		http.Error(w, "failed to get wardrobe items", http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"items": items,
		"count": len(items),
	}

	httputils.Success(w, response)
}

// GetAllClothingItems retrieves all clothing items for users
func (h *ClothingItemHandler) GetAllClothingItems(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	// Получаем все вещи - не привязанные к конкретному пользователю
	items, err := h.clothingItemService.GetAllClothingItems(ctx)
	if err != nil {
		h.logger.Error("Failed to get all clothing items",
			zap.Error(err),
		)
		http.Error(w, "failed to get all clothing items", http.StatusInternalServerError)
		return
	}

	response := map[string]interface{}{
		"items": items,
		"count": len(items),
	}

	httputils.Success(w, response)
}

// AddItemToWardrobe adds an item to user's wardrobe
func (h *ClothingItemHandler) AddItemToWardrobe(w http.ResponseWriter, r *http.Request) {
	authenticatedUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		http.Error(w, "user not authenticated", http.StatusUnauthorized)
		return
	}

	itemIDStr := mux.Vars(r)["item_id"]
	itemID, err := uuid.Parse(itemIDStr)
	if err != nil {
		http.Error(w, "invalid item ID", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	if err := h.clothingItemService.AddItemToWardrobe(ctx, authenticatedUserID, itemID); err != nil {
		h.logger.Error("Failed to add item to wardrobe",
			zap.Error(err),
			zap.String("user_id", authenticatedUserID.String()),
			zap.String("item_id", itemID.String()),
		)
		http.Error(w, "failed to add item to wardrobe", http.StatusInternalServerError)
		return
	}

	httputils.Success(w, map[string]string{
		"message": "Item added to wardrobe successfully",
	})
}

// RemoveItemFromWardrobe removes an item from user's wardrobe
func (h *ClothingItemHandler) RemoveItemFromWardrobe(w http.ResponseWriter, r *http.Request) {
	authenticatedUserID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		http.Error(w, "user not authenticated", http.StatusUnauthorized)
		return
	}

	itemIDStr := mux.Vars(r)["item_id"]
	itemID, err := uuid.Parse(itemIDStr)
	if err != nil {
		http.Error(w, "invalid item ID", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	if err := h.clothingItemService.RemoveItemFromWardrobe(ctx, authenticatedUserID, itemID); err != nil {
		h.logger.Error("Failed to remove item from wardrobe",
			zap.Error(err),
			zap.String("user_id", authenticatedUserID.String()),
			zap.String("item_id", itemID.String()),
		)
		http.Error(w, "failed to remove item from wardrobe", http.StatusInternalServerError)
		return
	}

	httputils.Success(w, map[string]string{
		"message": "Item removed from wardrobe successfully",
	})
}

// CreateClothingItem creates a new clothing item
func (h *ClothingItemHandler) CreateClothingItem(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var item domain.ClothingItem
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		http.Error(w, "invalid JSON", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	err := h.clothingItemService.CreateClothingItem(ctx, item)
	if err != nil {
		h.logger.Error("Failed to create clothing item",
			zap.Error(err),
			zap.String("name", item.Name),
		)
		http.Error(w, "failed to create clothing item", http.StatusInternalServerError)
		return
	}

	httputils.Success(w, map[string]string{
		"message": "clothing item created successfully",
	})
}

// GetClothingItem retrieves a single clothing item by ID
func (h *ClothingItemHandler) GetClothingItem(w http.ResponseWriter, r *http.Request) {
	itemIDStr := mux.Vars(r)["id"]
	itemID, err := uuid.Parse(itemIDStr)
	if err != nil {
		http.Error(w, "invalid item ID", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	item, err := h.clothingItemService.GetItemByID(ctx, itemID)
	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "item not found", http.StatusNotFound)
			return
		}
		h.logger.Error("Failed to get clothing item",
			zap.Error(err),
			zap.String("item_id", itemID.String()),
		)
		http.Error(w, "failed to get clothing item", http.StatusInternalServerError)
		return
	}

	httputils.Success(w, map[string]interface{}{
		"item": item,
	})
}

// UpdateClothingItem updates an existing clothing item
func (h *ClothingItemHandler) UpdateClothingItem(w http.ResponseWriter, r *http.Request) {
	itemIDStr := mux.Vars(r)["id"]
	itemID, err := uuid.Parse(itemIDStr)
	if err != nil {
		http.Error(w, "invalid item ID", http.StatusBadRequest)
		return
	}

	defer r.Body.Close()

	var item domain.ClothingItem
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		http.Error(w, "invalid JSON", http.StatusBadRequest)
		return
	}

	item.ID = itemID

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	err = h.clothingItemService.UpdateClothingItem(ctx, item)
	if err != nil {
		h.logger.Error("Failed to update clothing item",
			zap.Error(err),
			zap.String("item_id", itemID.String()),
		)
		http.Error(w, "failed to update clothing item", http.StatusInternalServerError)
		return
	}

	httputils.Success(w, map[string]string{
		"message": "clothing item updated successfully",
	})
}

// DeleteClothingItem deletes a clothing item
func (h *ClothingItemHandler) DeleteClothingItem(w http.ResponseWriter, r *http.Request) {
	itemIDStr := mux.Vars(r)["id"]
	itemID, err := uuid.Parse(itemIDStr)
	if err != nil {
		http.Error(w, "invalid item ID", http.StatusBadRequest)
		return
	}

	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	if err := h.clothingItemService.DeleteClothingItem(ctx, itemID); err != nil {
		h.logger.Error("Failed to delete clothing item",
			zap.Error(err),
			zap.String("item_id", itemID.String()),
		)
		http.Error(w, "failed to delete clothing item", http.StatusInternalServerError)
		return
	}

	httputils.Success(w, map[string]string{
		"message": "Item deleted successfully",
	})
}
