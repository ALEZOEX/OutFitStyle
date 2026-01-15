package external

import (
	"context"
	"encoding/json"

	"github.com/google/uuid"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type DummyGateway struct{}

func NewDummyGateway() *DummyGateway { return &DummyGateway{} }

func (g *DummyGateway) InitPayment(ctx context.Context, amount float64, currency string, description string, metadata map[string]any) (domain.PaymentInit, error) {
	_ = ctx
	ext := uuid.NewString()

	// Для web/мобилки удобнее payment_url
	url := "https://example.com/pay/" + ext

	return domain.PaymentInit{
		Provider:          "dummy",
		ExternalPaymentID: ext,
		PaymentURL:        &url,
		ClientSecret:      nil,
	}, nil
}

func (g *DummyGateway) ParseWebhook(ctx context.Context, headers map[string]string, body []byte) (externalPaymentID string, status string, receiptURL *string, errMsg *string, err error) {
	_ = ctx
	_ = headers

	// ожидаем: {"external_payment_id":"...","status":"completed|failed|refunded","receipt_url": "..."}
	var payload struct {
		ExternalPaymentID string  `json:"external_payment_id"`
		Status            string  `json:"status"`
		ReceiptURL        *string `json:"receipt_url"`
		ErrorMessage      *string `json:"error_message"`
	}
	if e := json.Unmarshal(body, &payload); e != nil {
		return "", "", nil, nil, errors.Wrap(e, "bad webhook payload")
	}
	if payload.ExternalPaymentID == "" || payload.Status == "" {
		return "", "", nil, nil, errors.New("missing fields")
	}
	return payload.ExternalPaymentID, payload.Status, payload.ReceiptURL, payload.ErrorMessage, nil
}
