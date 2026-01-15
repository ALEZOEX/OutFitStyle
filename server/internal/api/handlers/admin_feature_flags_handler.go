package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

type AdminFeatureFlagsHandler struct {
	svc *services.FeatureFlagService
}

func NewAdminFeatureFlagsHandler(svc *services.FeatureFlagService) *AdminFeatureFlagsHandler {
	return &AdminFeatureFlagsHandler{svc: svc}
}

func (h *AdminFeatureFlagsHandler) List(w http.ResponseWriter, r *http.Request) {
	items, err := h.svc.List(r.Context())
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list feature flags"))
		return
	}
	resp.Success(w, map[string]any{"flags": items})
}

type setFlagRequest struct {
	Enabled bool `json:"enabled"`
}

func (h *AdminFeatureFlagsHandler) SetEnabled(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req setFlagRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	key := r.URL.Query().Get("key")
	if key == "" {
		resp.Error(w, http.StatusBadRequest, errors.New("key is required"))
		return
	}

	if err := h.svc.SetEnabled(r.Context(), key, req.Enabled); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}
