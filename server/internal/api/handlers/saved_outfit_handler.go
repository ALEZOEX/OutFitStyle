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

type SavedOutfitHandler struct{ svc *services.SavedOutfitService }

func NewSavedOutfitHandler(svc *services.SavedOutfitService) *SavedOutfitHandler { return &SavedOutfitHandler{svc: svc} }

func (h *SavedOutfitHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.List).Methods(http.MethodGet)
	r.HandleFunc("", h.Create).Methods(http.MethodPost)
	r.HandleFunc("/{id}", h.Get).Methods(http.MethodGet)
	r.HandleFunc("/{id}", h.Update).Methods(http.MethodPut)
	r.HandleFunc("/{id}", h.Delete).Methods(http.MethodDelete)
	r.HandleFunc("/{id}/worn", h.Worn).Methods(http.MethodPost)
}

func (h *SavedOutfitHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }

	items, err := h.svc.List(r.Context(), userID)
	if err != nil { resp.Error(w, 500, errors.New("failed")); return }
	resp.Success(w, map[string]any{"outfits": items})
}

func (h *SavedOutfitHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }
	defer r.Body.Close()

	var req domain.SavedOutfitCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil { resp.Error(w, 400, errors.New("invalid body")); return }

	o, err := h.svc.Create(r.Context(), userID, req)
	if err != nil { resp.Error(w, 400, err); return }
	resp.Success(w, map[string]any{"outfit": o})
}

func (h *SavedOutfitHandler) Get(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	o, err := h.svc.Get(r.Context(), userID, id)
	if err != nil { resp.Error(w, 500, errors.New("failed")); return }
	if o == nil { resp.Error(w, 404, errors.New("not found")); return }
	resp.Success(w, o)
}

func (h *SavedOutfitHandler) Update(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }
	defer r.Body.Close()

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	var req domain.SavedOutfitUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil { resp.Error(w, 400, errors.New("invalid body")); return }

	o, err := h.svc.Update(r.Context(), userID, id, req)
	if err != nil { resp.Error(w, 400, err); return }
	if o == nil { resp.Error(w, 404, errors.New("not found")); return }
	resp.Success(w, map[string]any{"outfit": o})
}

func (h *SavedOutfitHandler) Delete(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	if err := h.svc.Delete(r.Context(), userID, id); err != nil { resp.Error(w, 404, err); return }
	resp.Success(w, map[string]any{"success": true})
}

func (h *SavedOutfitHandler) Worn(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok { resp.Error(w, 401, errors.New("auth required")); return }

	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	o, err := h.svc.Worn(r.Context(), userID, id)
	if err != nil { resp.Error(w, 500, errors.New("failed")); return }
	if o == nil { resp.Error(w, 404, errors.New("not found")); return }
	resp.Success(w, map[string]any{"times_worn": o.TimesWorn, "last_worn_at": o.LastWornAt})
}