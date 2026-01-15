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

type ShareHandler struct {
	svc *services.ShareService
	log *zap.Logger
}

func NewShareHandler(svc *services.ShareService, log *zap.Logger) *ShareHandler {
	return &ShareHandler{svc: svc, log: log}
}

func (h *ShareHandler) RegisterProtected(r *mux.Router) {
	r.HandleFunc("", h.Create).Methods(http.MethodPost)
}

func (h *ShareHandler) RegisterPublic(r *mux.Router) {
	r.HandleFunc("/{share_code}", h.GetPublic).Methods(http.MethodGet)
}

func (h *ShareHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.ShareCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	code, err := h.svc.Create(r.Context(), userID, req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	shareURL := "/api/v1/share/" + code
	resp.Success(w, domain.ShareCreateResponse{ShareCode: code, ShareURL: shareURL})
}

func (h *ShareHandler) GetPublic(w http.ResponseWriter, r *http.Request) {
	code := mux.Vars(r)["share_code"]
	outfit, userName, err := h.svc.GetPublic(r.Context(), code)
	if err != nil {
		h.log.Warn("share get failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to load shared outfit"))
		return
	}
	if outfit == nil {
		resp.Error(w, http.StatusNotFound, errors.New("not found"))
		return
	}

	resp.Success(w, domain.SharedOutfitPublicResponse{Outfit: outfit, UserName: userName})
}
