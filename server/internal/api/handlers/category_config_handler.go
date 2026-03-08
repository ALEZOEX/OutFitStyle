package handlers

import (
	"net/http"

	"go.uber.org/zap"

	"outfitstyle/server/internal/catalog"
	resp "outfitstyle/server/internal/pkg/http"
)

type CategoryConfigHandler struct {
	mapper catalog.CategoryMapper
	log    *zap.Logger
}

func NewCategoryConfigHandler(mapper catalog.CategoryMapper, log *zap.Logger) *CategoryConfigHandler {
	return &CategoryConfigHandler{
		mapper: mapper,
		log:    log,
	}
}

// ReloadConfig handles POST /api/v1/admin/category-config/reload
func (h *CategoryConfigHandler) ReloadConfig(w http.ResponseWriter, r *http.Request) {
	if err := h.mapper.ReloadConfig(); err != nil {
		h.log.Error("failed to reload category config", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, err)
		return
	}

	h.log.Info("category mapping configuration reloaded successfully")
	resp.Success(w, map[string]string{
		"message": "Configuration reloaded successfully",
	})
}

// GetUnmappedSubcategories handles GET /api/v1/admin/category-config/unmapped
func (h *CategoryConfigHandler) GetUnmappedSubcategories(w http.ResponseWriter, r *http.Request) {
	unmapped := h.mapper.GetUnmappedSubcategories()

	resp.Success(w, map[string]interface{}{
		"unmapped_subcategories": unmapped,
		"count":                  len(unmapped),
	})
}
