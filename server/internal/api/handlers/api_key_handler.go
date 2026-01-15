package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

type APIKeyHandler struct {
	svc *services.APIKeyService
}

func NewAPIKeyHandler(svc *services.APIKeyService) *APIKeyHandler {
	return &APIKeyHandler{svc: svc}
}

func (h *APIKeyHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.List).Methods(http.MethodGet)
	r.HandleFunc("", h.Create).Methods(http.MethodPost)
	r.HandleFunc("/{id}", h.Delete).Methods(http.MethodDelete)
}

func (h *APIKeyHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	keys, err := h.svc.List(r.Context(), userID)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list api keys"))
		return
	}
	resp.Success(w, domain.APIKeyListResponse{Keys: keys})
}

func (h *APIKeyHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.APIKeyCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}
	out, err := h.svc.Create(r.Context(), userID, req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	resp.Success(w, out)
}

func (h *APIKeyHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid id"))
		return
	}
	if err := h.svc.Delete(r.Context(), userID, id); err != nil {
		resp.Error(w, http.StatusNotFound, err)
		return
	}
	resp.Success(w, map[string]any{"success": true})
}
