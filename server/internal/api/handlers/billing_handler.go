package handlers

import (
	"io"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/services"
	resp "outfitstyle/server/internal/pkg/http"
)

type BillingHandler struct {
	svc *services.BillingService
	log *zap.Logger
}

func NewBillingHandler(svc *services.BillingService, log *zap.Logger) *BillingHandler {
	return &BillingHandler{svc: svc, log: log}
}

func (h *BillingHandler) RegisterWebhook(r *mux.Router) {
	r.HandleFunc("/webhook/{provider}", h.Webhook).Methods(http.MethodPost)
}

func (h *BillingHandler) RegisterProtected(r *mux.Router) {
	// Add protected routes for billing operations if needed
}

func (h *BillingHandler) Webhook(w http.ResponseWriter, r *http.Request) {
	provider := mux.Vars(r)["provider"]
	defer r.Body.Close()

	body, err := io.ReadAll(r.Body)
	if err != nil {
		h.log.Error("webhook read body", zap.Error(err))
		resp.Error(w, http.StatusBadRequest, errors.New("failed to read body"))
		return
	}

	headers := map[string]string{}
	for k, v := range r.Header {
		if len(v) > 0 {
			headers[k] = v[0]
		}
	}

	if err := h.svc.HandleWebhook(r.Context(), provider, headers, body); err != nil {
		h.log.Error("webhook handle", zap.Error(err), zap.String("provider", provider))
		resp.Error(w, http.StatusBadRequest, err)
		return
	}

	resp.Success(w, map[string]any{"success": true})
}
