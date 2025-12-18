package external

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type YooKassaGateway struct {
	// В вашем ТЗ webhook ожидает header X-Signature.
	// Здесь используем HMAC-SHA256(body) с этим secret.
	WebhookSecret string
}

func NewYooKassaGateway(webhookSecret string) *YooKassaGateway {
	return &YooKassaGateway{WebhookSecret: webhookSecret}
}

func (g *YooKassaGateway) InitPayment(ctx context.Context, amount float64, currency string, description string, metadata map[string]any) (domain.PaymentInit, error) {
	_ = ctx; _ = amount; _ = currency; _ = description; _ = metadata
	return domain.PaymentInit{}, errors.New("yookassa init not implemented in this module")
}

func (g *YooKassaGateway) ParseWebhook(ctx context.Context, headers map[string]string, body []byte) (string, string, *string, *string, error) {
	_ = ctx

	sig := headers["x-signature"]
	if err := VerifyHMACSHA256Hex(body, sig, g.WebhookSecret); err != nil {
		return "", "", nil, nil, err
	}

	// YooKassa webhook often has { "object": { "id": "...", "status": "succeeded|canceled|pending" }, ... }
	var payload map[string]any
	if err := json.Unmarshal(body, &payload); err != nil {
		return "", "", nil, nil, errors.Wrap(err, "bad yookassa json")
	}

	obj, _ := payload["object"].(map[string]any)
	extID, _ := obj["id"].(string)
	rawStatus, _ := obj["status"].(string)
	if extID == "" || rawStatus == "" {
		return "", "", nil, nil, errors.New("yookassa webhook missing object.id/status")
	}

	status := "pending"
	switch rawStatus {
	case "succeeded":
		status = "completed"
	case "canceled":
		status = "failed"
	default:
		status = "pending"
	}

	return extID, status, nil, nil, nil
}