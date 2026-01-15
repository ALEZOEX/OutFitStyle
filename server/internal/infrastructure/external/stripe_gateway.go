package external

import (
	"context"
	"encoding/json"
	"time"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type StripeGateway struct {
	WebhookSecret string
}

func NewStripeGateway(webhookSecret string) *StripeGateway {
	return &StripeGateway{WebhookSecret: webhookSecret}
}

func (g *StripeGateway) InitPayment(ctx context.Context, amount float64, currency string, description string, metadata map[string]any) (domain.PaymentInit, error) {
	// MVP: инициирование Stripe PaymentIntent через API не делаем в этом модуля в (чтобы не раздувать).
	// Возвращаем ошибку, если кто-то попытается реально подписаться через Stripe без отдельного модуля.
	_ = ctx
	_ = amount
	_ = currency
	_ = description
	_ = metadata
	return domain.PaymentInit{}, errors.New("stripe init not implemented in this module")
}

func (g *StripeGateway) ParseWebhook(ctx context.Context, headers map[string]string, body []byte) (string, string, *string, *string, error) {
	_ = ctx

	sig := headers["stripe-signature"]
	if err := VerifyStripeSignature(body, sig, g.WebhookSecret, 5*time.Minute); err != nil {
		return "", "", nil, nil, err
	}

	// Stripe event envelope
	var evt map[string]any
	if err := json.Unmarshal(body, &evt); err != nil {
		return "", "", nil, nil, errors.Wrap(err, "bad stripe json")
	}

	eventType, _ := evt["type"].(string)

	// external_payment_id: data.object.id
	var extID string
	if data, ok := evt["data"].(map[string]any); ok {
		if obj, ok := data["object"].(map[string]any); ok {
			if id, ok := obj["id"].(string); ok {
				extID = id
			}
		}
	}
	if extID == "" {
		return "", "", nil, nil, errors.New("stripe webhook missing data.object.id")
	}

	status := "pending"
	switch eventType {
	case "payment_intent.succeeded":
		status = "completed"
	case "payment_intent.payment_failed":
		status = "failed"
	case "charge.refunded":
		status = "refunded"
	default:
		// оставляем pending (или игнорируем)
	}

	return extID, status, nil, nil, nil
}
