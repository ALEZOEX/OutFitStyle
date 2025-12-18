package handlers

import (
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

type CatalogHandler struct{ svc *services.CatalogService }

func NewCatalogHandler(svc *services.CatalogService) *CatalogHandler { return &CatalogHandler{svc: svc} }

func (h *CatalogHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/search", h.Search).Methods(http.MethodGet)
	r.HandleFunc("/categories", h.Categories).Methods(http.MethodGet)
	r.HandleFunc("/items/{id}", h.GetItem).Methods(http.MethodGet)
	r.HandleFunc("/items/{id}/similar", h.Similar).Methods(http.MethodGet)
	r.HandleFunc("/items/{id}/click", h.Click).Methods(http.MethodPost)
}

func (h *CatalogHandler) Search(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	var page, limit int
	if p := q.Get("page"); p != "" {
		if pageNum, err := strconv.Atoi(p); err == nil && pageNum > 0 {
			page = pageNum
		} else {
			page = 1
		}
	} else {
		page = 1
	}

	if l := q.Get("limit"); l != "" {
		if limitNum, err := strconv.Atoi(l); err == nil && limitNum > 0 {
			limit = limitNum
		} else {
			limit = 20
		}
	} else {
		limit = 20
	}

	p := repositories.CatalogSearchParams{
		Page:  page,
		Limit: limit,
	}
	if v := q.Get("q"); v != "" { p.Q = &v }
	if v := q.Get("category"); v != "" { p.Category = &v }
	if v := q.Get("subcategory"); v != "" { p.Subcategory = &v }
	if v := q.Get("style"); v != "" { p.Style = &v }
	if v := q.Get("color"); v != "" { p.Color = &v }
	if v := q.Get("partner"); v != "" { p.Partner = &v }
	if v := q.Get("min_price"); v != "" {
		if f, err := strconv.ParseFloat(v, 64); err == nil { p.MinPrice = &f }
	}
	if v := q.Get("max_price"); v != "" {
		if f, err := strconv.ParseFloat(v, 64); err == nil { p.MaxPrice = &f }
	}

	items, total, err := h.svc.Search(r.Context(), p)
	if err != nil { resp.Error(w, 500, errors.New("search failed")); return }

	if p.Page <= 0 { p.Page = 1 }
	if p.Limit <= 0 { p.Limit = 20 }
	resp.Success(w, map[string]any{
		"items": items,
		"pagination": domain.Pagination{Page: p.Page, Limit: p.Limit, Total: total},
	})
}

func (h *CatalogHandler) Categories(w http.ResponseWriter, r *http.Request) {
	out, err := h.svc.Categories(r.Context())
	if err != nil { resp.Error(w, 500, errors.New("failed")); return }
	resp.Success(w, out)
}

func (h *CatalogHandler) GetItem(w http.ResponseWriter, r *http.Request) {
	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	it, err := h.svc.GetItem(r.Context(), id)
	if err != nil { resp.Error(w, 500, errors.New("failed")); return }
	if it == nil { resp.Error(w, 404, errors.New("not found")); return }
	resp.Success(w, it)
}

func (h *CatalogHandler) Similar(w http.ResponseWriter, r *http.Request) {
	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }
	queryLimitStr := r.URL.Query().Get("limit")
	var queryLimit int
	if queryLimitStr != "" {
		if parsedLimit, err := strconv.Atoi(queryLimitStr); err == nil && parsedLimit > 0 {
			queryLimit = parsedLimit
		} else {
			queryLimit = 20  // default
		}
	} else {
		queryLimit = 20  // default
	}
	limit := queryLimit
	items, err := h.svc.Similar(r.Context(), id, limit)
	if err != nil { resp.Error(w, 500, errors.New("failed")); return }
	resp.Success(w, map[string]any{"items": items})
}

func (h *CatalogHandler) Click(w http.ResponseWriter, r *http.Request) {
	id, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil { resp.Error(w, 400, errors.New("invalid id")); return }

	// user_id optional
	var uid *domain.ID
	if u, ok := middleware.GetUserIDFromContext(r.Context()); ok {
		uid = &u
	}

	redirect, err := h.svc.Click(r.Context(), uid, id)
	if err != nil { resp.Error(w, 400, err); return }
	resp.Success(w, map[string]any{"redirect_url": redirect})
}



