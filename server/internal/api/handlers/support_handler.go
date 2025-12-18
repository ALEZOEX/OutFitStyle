package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

type SupportHandler struct {
	svc *services.SupportService
}

func NewSupportHandler(svc *services.SupportService) *SupportHandler {
	return &SupportHandler{svc: svc}
}

func (h *SupportHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/tickets", h.CreateTicket).Methods(http.MethodPost)
	r.HandleFunc("/tickets", h.ListTickets).Methods(http.MethodGet)
	r.HandleFunc("/tickets/{id}", h.GetTicket).Methods(http.MethodGet)
	r.HandleFunc("/tickets/{id}/messages", h.AddMessage).Methods(http.MethodPost)
}

func (h *SupportHandler) CreateTicket(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.CreateTicketRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	t, err := h.svc.CreateTicket(r.Context(), userID, req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	resp.Success(w, map[string]any{"ticket": t})
}

func (h *SupportHandler) ListTickets(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	items, total, err := h.svc.ListTickets(r.Context(), userID, page, limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list tickets"))
		return
	}
	if page <= 0 { page = 1 }
	if limit <= 0 { limit = 20 }

	resp.Success(w, map[string]any{
		"tickets": items,
		"pagination": domain.Pagination{Page: page, Limit: limit, Total: total},
	})
}

func (h *SupportHandler) GetTicket(w http.ResponseWriter, r *http.Request) {
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

	t, msgs, err := h.svc.GetTicket(r.Context(), userID, id)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to load ticket"))
		return
	}
	if t == nil {
		resp.Error(w, http.StatusNotFound, errors.New("not found"))
		return
	}

	resp.Success(w, map[string]any{"ticket": t, "messages": msgs})
}

func (h *SupportHandler) AddMessage(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	ticketID, err := domain.ParseID(mux.Vars(r)["id"])
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid id"))
		return
	}

	var req domain.AddTicketMessageRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	msg, err := h.svc.AddMessage(r.Context(), userID, ticketID, req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	if msg == nil {
		resp.Error(w, http.StatusNotFound, errors.New("ticket not found"))
		return
	}

	resp.Success(w, map[string]any{"message": msg})
}