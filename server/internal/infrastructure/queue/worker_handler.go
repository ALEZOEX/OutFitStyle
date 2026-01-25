// Пакет queue предоставляет функциональность для работы с очередью задач
// Использует библиотеку asynq для асинхронной обработки задач через Redis
package queue

import (
	"context"
	"encoding/json"

	"github.com/hibiken/asynq"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/infrastructure/external"
	"outfitstyle/server/internal/infrastructure/queue/tasks"
)

// WorkerDeps структура зависимостей для обработчиков задач воркера
type WorkerDeps struct {
	Logger *zap.Logger

	NotifRepo repositories.NotificationRepository // Репозиторий для работы с уведомлениями
	TokenRepo repositories.PushTokenRepository    // Репозиторий для работы с токенами пуш-уведомлений

	Push *external.PushMux  // Внешний сервис для отправки пуш-уведомлений
	ML   *external.MLClient // Внешний ML-клиент
}

// NewMux создает новый мультиплексор задач для воркера
// Регистрирует обработчики для различных типов задач
func NewMux(deps WorkerDeps) *asynq.ServeMux {
	mux := asynq.NewServeMux()
	mux.HandleFunc(TaskSendNotification, deps.handleSendNotification)
	mux.HandleFunc(tasks.TypeMLAction, deps.handleMLAction)
	return mux
}

// handleSendNotification обрабатывает задачу отправки уведомления
// Получает уведомление из репозитория и отправляет его на устройства пользователя
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

// handleMLAction обрабатывает задачу, связанную с ML-действием
// Выполняет различные ML-операции в зависимости от типа действия
func (d WorkerDeps) handleMLAction(ctx context.Context, t *asynq.Task) error {
	var p tasks.MLActionPayload
	if err := json.Unmarshal(t.Payload(), &p); err != nil {
		return errors.Wrap(err, "bad ML action payload")
	}

	d.Logger.Info("Processing ML action",
		zap.String("request_id", p.RequestID),
		zap.String("user_id", p.UserID),
		zap.String("action_type", p.ActionType),
		zap.String("entity_type", p.EntityType),
		zap.String("entity_id", p.EntityID),
	)

	// В зависимости от типа действия выполняем разные ML-операции
	switch p.ActionType {
	case "outfit_generation":
		// Обработка генерации наряда
		return d.handleOutfitGeneration(ctx, p)
	case "recommendation":
		// Обработка рекомендации
		return d.handleRecommendation(ctx, p)
	case "feedback_processing":
		// Обработка обратной связи
		return d.handleFeedbackProcessing(ctx, p)
	case "user_preference_learning":
		// Обновление предпочтений пользователя
		return d.handleUserPreferenceLearning(ctx, p)
	default:
		d.Logger.Warn("Unknown ML action type", zap.String("action_type", p.ActionType))
		return nil // Не возвращаем ошибку, чтобы не делать retry для неизвестных действий
	}
}

// handleOutfitGeneration обрабатывает генерацию наряда с помощью ML
func (d WorkerDeps) handleOutfitGeneration(ctx context.Context, p tasks.MLActionPayload) error {
	if d.ML == nil {
		d.Logger.Error("ML client not configured")
		return errors.New("ML client not configured")
	}

	// Вызываем ML-сервис для генерации наряда
	// В реальной реализации здесь будет вызов соответствующего метода ML-клиента
	_, err := d.ML.GenerateOutfit(ctx, p.UserID, p.Meta)
	if err != nil {
		d.Logger.Error("Failed to generate outfit with ML",
			zap.String("request_id", p.RequestID),
			zap.String("user_id", p.UserID),
			zap.Error(err),
		)
		return errors.Wrap(err, "failed to generate outfit with ML")
	}

	d.Logger.Info("Successfully generated outfit with ML",
		zap.String("request_id", p.RequestID),
		zap.String("user_id", p.UserID),
	)

	return nil
}

// handleRecommendation обрабатывает рекомендацию с помощью ML
func (d WorkerDeps) handleRecommendation(ctx context.Context, p tasks.MLActionPayload) error {
	if d.ML == nil {
		d.Logger.Error("ML client not configured")
		return errors.New("ML client not configured")
	}

	// Вызываем ML-сервис для генерации рекомендации
	// В реальной реализации здесь будет вызов соответствующего метода ML-клиента
	_, err := d.ML.GenerateRecommendation(ctx, p.UserID, p.Meta)
	if err != nil {
		d.Logger.Error("Failed to generate recommendation with ML",
			zap.String("request_id", p.RequestID),
			zap.String("user_id", p.UserID),
			zap.Error(err),
		)
		return errors.Wrap(err, "failed to generate recommendation with ML")
	}

	d.Logger.Info("Successfully generated recommendation with ML",
		zap.String("request_id", p.RequestID),
		zap.String("user_id", p.UserID),
	)

	return nil
}

// handleFeedbackProcessing обрабатывает обратную связь с помощью ML
func (d WorkerDeps) handleFeedbackProcessing(ctx context.Context, p tasks.MLActionPayload) error {
	if d.ML == nil {
		d.Logger.Error("ML client not configured")
		return errors.New("ML client not configured")
	}

	// Вызываем ML-сервис для обработки обратной связи
	// В реальной реализации здесь будет вызов соответствующего метода ML-клиента
	err := d.ML.ProcessFeedback(ctx, p.UserID, p.EntityID, p.Meta)
	if err != nil {
		d.Logger.Error("Failed to process feedback with ML",
			zap.String("request_id", p.RequestID),
			zap.String("user_id", p.UserID),
			zap.String("entity_id", p.EntityID),
			zap.Error(err),
		)
		return errors.Wrap(err, "failed to process feedback with ML")
	}

	d.Logger.Info("Successfully processed feedback with ML",
		zap.String("request_id", p.RequestID),
		zap.String("user_id", p.UserID),
		zap.String("entity_id", p.EntityID),
	)

	return nil
}

// handleUserPreferenceLearning обновляет предпочтения пользователя на основе ML
func (d WorkerDeps) handleUserPreferenceLearning(ctx context.Context, p tasks.MLActionPayload) error {
	if d.ML == nil {
		d.Logger.Error("ML client not configured")
		return errors.New("ML client not configured")
	}

	// Вызываем ML-сервис для обновления предпочтений пользователя
	// В реальной реализации здесь будет вызов соответствующего метода ML-клиента
	err := d.ML.UpdateUserPreferences(ctx, p.UserID, p.RequestID, p.Meta)
	if err != nil {
		d.Logger.Error("Failed to update user preferences with ML",
			zap.String("request_id", p.RequestID),
			zap.String("user_id", p.UserID),
			zap.Error(err),
		)
		return errors.Wrap(err, "failed to update user preferences with ML")
	}

	d.Logger.Info("Successfully updated user preferences with ML",
		zap.String("request_id", p.RequestID),
		zap.String("user_id", p.UserID),
	)

	return nil
}

// prefix возвращает префикс строки длиной до 8 символов
// Используется для логирования токенов, чтобы не выводить полные токены
func prefix(s string) string {
	if len(s) <= 8 {
		return s
	}
	return s[:8]
}
