package handlers

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

type TripHandler struct {
	svc *services.TripService
	log *zap.Logger
}

func NewTripHandler(svc *services.TripService, log *zap.Logger) *TripHandler {
	return &TripHandler{svc: svc, log: log}
}

func (h *TripHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.List).Methods(http.MethodGet)
	r.HandleFunc("", h.Create).Methods(http.MethodPost)
	r.HandleFunc("/{id}", h.Get).Methods(http.MethodGet)
	r.HandleFunc("/{id}", h.Update).Methods(http.MethodPut)
	r.HandleFunc("/{id}", h.Delete).Methods(http.MethodDelete)
}

func (h *TripHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, http.StatusUnauthorized, errors.New("auth required")); return }

	items, err := h.svc.List(r.Context(), userID)
	if err != nil { h.log.Error("trips list", zap.Error(err)); resp.Error(w, 500, errors.New("failed")); return }
	resp.Success(w, map[string]any{"trips": items})
}

func (h *TripHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }
	defer r.Body.Close()

	var req domain.TripCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil { resp.Error(w, 400, errors.New("invalid body")); return }

	t, err := h.svc.Create(r.Context(), userID, req)
	if err != nil { resp.Error(w, 400, err); return }
	resp.Success(w, map[string]any{"trip": t})
}

func (h *TripHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	t, err := h.svc.Get(r.Context(), userID, id)
	if err != nil { resp.Error(w, 500, errors.New("failed")); return }
	if t == nil { resp.Error(w, 404, errors.New("not found")); return }
	resp.Success(w, t)
}

func (h *TripHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }
	defer r.Body.Close()

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	var req domain.TripUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil { resp.Error(w, 400, errors.New("invalid body")); return }

	t, err := h.svc.Update(r.Context(), userID, id, req)
	if err != nil { resp.Error(w, 400, err); return }
	if t == nil { resp.Error(w, 404, errors.New("not found")); return }
	resp.Success(w, map[string]any{"trip": t})
}

func (h *TripHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	if err := h.svc.Delete(r.Context(), userID, id); err != nil { resp.Error(w, 404, err); return }
	resp.Success(w, map[string]any{"success": true})
}