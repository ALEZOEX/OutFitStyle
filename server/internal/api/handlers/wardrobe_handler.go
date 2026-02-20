package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/validation"
	resp "outfitstyle/server/internal/pkg/http"
)

// WardrobeService интерфейс сервиса гардероба
type WardrobeService interface {
	List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) ([]domain.WardrobeItem, int, error)
	Get(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error)
	Create(ctx context.Context, userID domain.ID, req domain.WardrobeCreateRequest) (*domain.WardrobeItem, error)
	Update(ctx context.Context, userID, wardrobeID domain.ID, req domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error)
	Delete(ctx context.Context, userID, wardrobeID domain.ID) error
	SetFavorite(ctx context.Context, userID, wardrobeID domain.ID, isFavorite bool) error
	SetArchived(ctx context.Context, userID, wardrobeID domain.ID, isArchived bool) error
	MarkWorn(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error)
}

type WardrobeHandler struct {
	svc WardrobeService
	log *zap.Logger
}

func NewWardrobeHandler(svc WardrobeService, log *zap.Logger) *WardrobeHandler {
	return &WardrobeHandler{svc: svc, log: log}
}

func (h *WardrobeHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("", h.List).Methods(http.MethodGet)
	r.HandleFunc("", h.Create).Methods(http.MethodPost)

	r.HandleFunc("/{id}", h.Get).Methods(http.MethodGet)
	r.HandleFunc("/{id}", h.Update).Methods(http.MethodPut)
	r.HandleFunc("/{id}", h.Delete).Methods(http.MethodDelete)

	r.HandleFunc("/{id}/favorite", h.Favorite).Methods(http.MethodPost)
	r.HandleFunc("/{id}/archive", h.Archive).Methods(http.MethodPost)
	r.HandleFunc("/{id}/worn", h.Worn).Methods(http.MethodPost)
}

func (h *WardrobeHandler) List(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	qp := r.URL.Query()
	var page, limit int
	if p := qp.Get("page"); p != "" {
		if pageNum, err := strconv.Atoi(p); err == nil && pageNum > 0 {
			page = pageNum
		} else {
			page = 1
		}
	} else {
		page = 1
	}

	if l := qp.Get("limit"); l != "" {
		if limitNum, err := strconv.Atoi(l); err == nil && limitNum > 0 {
			limit = limitNum
		} else {
			limit = 20
		}
	} else {
		limit = 20
	}

	q := domain.WardrobeListQuery{
		Page:  page,
		Limit: limit,
		Sort:  qp.Get("sort"),
		Order: domain.SortOrder(qp.Get("order")),
	}

	if v := qp.Get("category"); v != "" {
		q.Category = &v
	}
	if v := qp.Get("style"); v != "" {
		q.Style = &v
	}
	if v := qp.Get("season"); v != "" {
		q.Season = &v
	}
	if v := qp.Get("search"); v != "" {
		q.Search = &v
	}

	if v := qp.Get("is_favorite"); v != "" {
		b := (v == "true" || v == "1")
		q.IsFavorite = &b
	}
	if v := qp.Get("is_archived"); v != "" {
		b := (v == "true" || v == "1")
		q.IsArchived = &b
	}

	items, total, err := h.svc.List(r.Context(), userID, q)
	if err != nil {
		h.log.Error("wardrobe list failed", zap.Error(err))
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list wardrobe"))
		return
	}

	resp.Success(w, map[string]any{
		"items": items,
		"pagination": domain.Pagination{
			Page:  q.Page,
			Limit: q.Limit,
			Total: total,
		},
	})
}

func (h *WardrobeHandler) Create(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.WardrobeCreateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()

	if req.Name != nil {
		validation.ValidateStringLength(v, *req.Name, 1, 200, "name", "name")
	}

	if req.Category != nil {
		validation.ValidateStringLength(v, *req.Category, 1, 100, "category", "category")
	}

	if req.Subcategory != nil {
		validation.ValidateStringLength(v, *req.Subcategory, 1, 100, "subcategory", "subcategory")
	}

	if req.Style != nil {
		validation.ValidateStringLength(v, *req.Style, 1, 100, "style", "style")
	}

	if req.BaseColour != nil {
		validation.ValidateStringLength(v, *req.BaseColour, 1, 50, "base_colour", "base colour")
	}

	if req.CustomName != nil {
		validation.ValidateStringLength(v, *req.CustomName, 1, 200, "custom_name", "custom name")
	}

	if req.Notes != nil {
		validation.ValidateStringLength(v, *req.Notes, 1, 1000, "notes", "notes")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	item, err := h.svc.Create(r.Context(), userID, req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	resp.Success(w, map[string]any{"wardrobe_item": item})
}

func (h *WardrobeHandler) Get(w http.ResponseWriter, r *http.Request) {
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

	item, err := h.svc.Get(r.Context(), userID, id)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to get wardrobe item"))
		return
	}
	if item == nil {
		resp.Error(w, http.StatusNotFound, errors.New("not found"))
		return
	}
	resp.Success(w, item)
}

func (h *WardrobeHandler) Update(w http.ResponseWriter, r *http.Request) {
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
	defer r.Body.Close()

	var req domain.WardrobeUpdateRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	// Validate input data
	v := validation.NewValidator()

	if req.CustomName != nil {
		validation.ValidateStringLength(v, *req.CustomName, 1, 200, "custom_name", "custom name")
	}

	if req.Notes != nil {
		validation.ValidateStringLength(v, *req.Notes, 1, 1000, "notes", "notes")
	}

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	// перед update возьми текущее состояние
	oldItem, _ := h.svc.Get(r.Context(), userID, id)
	if env := middleware.AuditFromContext(r.Context()); env != nil {
		env.ResourceType = "wardrobe"
		env.ResourceID = &id
		if oldItem != nil {
			b, _ := json.Marshal(oldItem)
			env.OldJSON = b
		}
	}

	item, err := h.svc.Update(r.Context(), userID, id, req)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to update"))
		return
	}
	if item == nil {
		resp.Error(w, http.StatusNotFound, errors.New("not found"))
		return
	}

	// после успешного update
	if env := middleware.AuditFromContext(r.Context()); env != nil {
		b, _ := json.Marshal(item)
		env.NewJSON = b
	}

	resp.Success(w, item)
}

func (h *WardrobeHandler) Delete(w http.ResponseWriter, r *http.Request) {
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

func (h *WardrobeHandler) Favorite(w http.ResponseWriter, r *http.Request) {
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
	defer r.Body.Close()

	var req domain.WardrobeToggleRequest
	_ = json.NewDecoder(r.Body).Decode(&req)
	if req.IsFavorite == nil {
		resp.Error(w, http.StatusBadRequest, errors.New("is_favorite required"))
		return
	}

	// Validate input data
	v := validation.NewValidator()
	v.Check(req.IsFavorite != nil, "is_favorite", "is_favorite is required")
	v.Check(*req.IsFavorite == true || *req.IsFavorite == false, "is_favorite", "is_favorite must be a boolean value")

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	if err := h.svc.SetFavorite(r.Context(), userID, id, *req.IsFavorite); err != nil {
		resp.Error(w, http.StatusNotFound, err)
		return
	}
	resp.Success(w, map[string]any{"success": true})
}

func (h *WardrobeHandler) Archive(w http.ResponseWriter, r *http.Request) {
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
	defer r.Body.Close()

	var req domain.WardrobeToggleRequest
	_ = json.NewDecoder(r.Body).Decode(&req)
	if req.IsArchived == nil {
		resp.Error(w, http.StatusBadRequest, errors.New("is_archived required"))
		return
	}

	// Validate input data
	v := validation.NewValidator()
	v.Check(req.IsArchived != nil, "is_archived", "is_archived is required")
	v.Check(*req.IsArchived == true || *req.IsArchived == false, "is_archived", "is_archived must be a boolean value")

	if !v.Valid() {
		resp.ValidationError(w, v.Errors)
		return
	}

	if err := h.svc.SetArchived(r.Context(), userID, id, *req.IsArchived); err != nil {
		resp.Error(w, http.StatusNotFound, err)
		return
	}
	resp.Success(w, map[string]any{"success": true})
}

func (h *WardrobeHandler) Worn(w http.ResponseWriter, r *http.Request) {
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

	item, err := h.svc.MarkWorn(r.Context(), userID, id)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to mark worn"))
		return
	}
	if item == nil {
		resp.Error(w, http.StatusNotFound, errors.New("not found"))
		return
	}
	resp.Success(w, map[string]any{"wear_count": item.WearCount, "last_worn_at": item.LastWornAt})
}
