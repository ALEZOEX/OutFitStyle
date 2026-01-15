package queue

import (
	"context"
	"encoding/json"

	"github.com/hibiken/asynq"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/infrastructure/external"
)

type WorkerDeps struct {
	Logger *zap.Logger

	NotifRepo repositories.NotificationRepository
	TokenRepo repositories.PushTokenRepository

	Push *external.PushMux
}

func NewMux(deps WorkerDeps) *asynq.ServeMux {
	mux := asynq.NewServeMux()
	mux.HandleFunc(TaskSendNotification, deps.handleSendNotification)
	return mux
}

func (d WorkerDeps) handleSendNotification(ctx context.Context, t *asynq.Task) error {
	var p SendNotificationPayload
	if err := json.Unmarshal(t.Payload(), &p); err != nil {
		return errors.Wrap(err, "bad payload")
	}

	n, err := d.NotifRepo.GetByID(ctx, p.NotificationID)
	if err != nil {
		return err
	}
	if n == nil {
		return nil // nothing to do
	}
	if n.PushSent {
		return nil // idempotent
	}

	tokens, err := d.TokenRepo.ListActiveByUser(ctx, n.UserID)
	if err != nil {
		return err
	}
	if len(tokens) == 0 {
		// нет токенов — помечаем как "не отправлено", но без ошибки (или можно оставить false)
		msg := "no active push tokens"
		_ = d.NotifRepo.MarkPushResult(ctx, n.ID, false, &msg)
		return nil
	}

	title := n.Title
	body := ""
	if n.Body != nil {
		body = *n.Body
	}

	data := map[string]string{
		"notification_id": n.ID.String(),
		"type":            n.Type,
	}
	// если есть n.Data — мы не парсим глубоко; отправим "как строку" (можно улучшить позже)
	if len(n.Data) > 0 {
		data["data_json"] = string(n.Data)
	}

	var firstErr error
	for _, tok := range tokens {
		if d.Push == nil {
			firstErr = errors.New("push sender not configured")
			break
		}
		err := d.Push.Send(ctx, tok.Platform, tok.Token, external.PushMessage{
			Title: title,
			Body:  body,
			Data:  data,
		})
		if err != nil {
			d.Logger.Warn("push send failed",
				zap.String("platform", tok.Platform),
				zap.String("token_prefix", prefix(tok.Token)),
				zap.Error(err),
			)
			if firstErr == nil {
				firstErr = err
			}
		}
	}

	if firstErr != nil {
		msg := firstErr.Error()
		_ = d.NotifRepo.MarkPushResult(ctx, n.ID, false, &msg)
		// возвращаем ошибку → Asynq сделает retry
		return firstErr
	}

	_ = d.NotifRepo.MarkPushResult(ctx, n.ID, true, nil)
	return nil
}

func prefix(s string) string {
	if len(s) <= 8 {
		return s
	}
	return s[:8]
}
