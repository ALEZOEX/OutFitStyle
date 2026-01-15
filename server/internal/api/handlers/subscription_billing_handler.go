package handlers

import (
	"encoding/json"
	"io"
	"net/http"
	"strconv"
	"strings"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	resp "outfitstyle/server/internal/pkg/http"
)

type SubscriptionBillingHandler struct {
	billing *services.BillingService
	log     *zap.Logger
}

func NewSubscriptionBillingHandler(b *services.BillingService, log *zap.Logger) *SubscriptionBillingHandler {
	return &SubscriptionBillingHandler{billing: b, log: log}
}

func (h *SubscriptionBillingHandler) RegisterProtected(r *mux.Router) {
	r.HandleFunc("/subscribe", h.Subscribe).Methods(http.MethodPost)
	r.HandleFunc("/cancel", h.Cancel).Methods(http.MethodPost)
	r.HandleFunc("/reactivate", h.Reactivate).Methods(http.MethodPost)
	r.HandleFunc("/promo", h.Promo).Methods(http.MethodPost)
	r.HandleFunc("/payments", h.Payments).Methods(http.MethodGet)
}

func (h *SubscriptionBillingHandler) RegisterWebhook(r *mux.Router) {
	// public: /subscription/webhook/{provider}
	r.HandleFunc("/webhook/{provider}", h.Webhook).Methods(http.MethodPost)
}

func (h *SubscriptionBillingHandler) Subscribe(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.SubscribeRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	out, err := h.billing.Subscribe(r.Context(), userID, req)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	resp.Success(w, out)
}

func (h *SubscriptionBillingHandler) Cancel(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}
	defer r.Body.Close()

	var req domain.CancelSubscriptionRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	immediate := false
	if req.Immediate != nil {
		immediate = *req.Immediate
	}

	if err := h.billing.Cancel(r.Context(), userID, immediate); err != nil {
		if errors.Is(err, services.ErrUnauthorized) {
			resp.Error(w, http.StatusUnauthorized, err)
			return
		}
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	resp.Success(w, map[string]any{"success": true})
}

func (h *SubscriptionBillingHandler) Reactivate(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	if err := h.billing.Reactivate(r.Context(), userID); err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}
	resp.Success(w, map[string]any{"success": true})
}

func (h *SubscriptionBillingHandler) Promo(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()

	var req domain.PromoRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	promo, err := h.billing.Promo(r.Context(), req.Code)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"promo": promo})
}

func (h *SubscriptionBillingHandler) Payments(w http.ResponseWriter, r *http.Request) {
	userID, ok := middleware.GetUserIDFromContext(r.Context())
	if !ok {
		resp.Error(w, http.StatusUnauthorized, errors.New("auth required"))
		return
	}

	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	limit, _ := strconv.Atoi(q.Get("limit"))

	items, pagination, err := h.billing.ListPayments(r.Context(), userID, page, limit)
	if err != nil {
		resp.Error(w, http.StatusInternalServerError, errors.New("failed to list payments"))
		return
	}

	resp.Success(w, map[string]any{
		"payments":   items,
		"pagination": pagination,
	})
}

func (h *SubscriptionBillingHandler) Webhook(w http.ResponseWriter, r *http.Request) {
	provider := strings.ToLower(mux.Vars(r)["provider"])
	if provider == "" {
		resp.Error(w, http.StatusBadRequest, errors.New("provider required"))
		return
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		resp.Error(w, http.StatusBadRequest, errors.New("invalid body"))
		return
	}

	headers := map[string]string{}
	for k, v := range r.Header {
		if len(v) > 0 {
			headers[strings.ToLower(k)] = v[0]
		}
	}

	if err := h.billing.HandleWebhook(r.Context(), provider, headers, body); err != nil {
		h.log.Warn("webhook failed", zap.String("provider", provider), zap.Error(err))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}
