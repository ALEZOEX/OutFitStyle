package services

import (
	"context"
	"encoding/json"

	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/queue"
)

type NotificationService struct {
	notifRepo repositories.NotificationRepository
	tokenRepo repositories.PushTokenRepository
	queue     *queue.Client
}

func NewNotificationService(n repositories.NotificationRepository, t repositories.PushTokenRepository, q *queue.Client) *NotificationService {
	return &NotificationService{notifRepo: n, tokenRepo: t, queue: q}
}

func (s *NotificationService) List(ctx context.Context, userID domain.ID, unreadOnly bool, page, limit int) (items []domain.Notification, total int, unreadCount int, err error) {
	return s.notifRepo.List(ctx, userID, unreadOnly, page, limit)
}

func (s *NotificationService) MarkRead(ctx context.Context, userID domain.ID, notificationID domain.ID) error {
	return s.notifRepo.MarkRead(ctx, userID, notificationID)
}

func (s *NotificationService) MarkReadAll(ctx context.Context, userID domain.ID) (int, error) {
	return s.notifRepo.MarkReadAll(ctx, userID)
}

func (s *NotificationService) RegisterToken(ctx context.Context, userID domain.ID, req domain.RegisterPushTokenRequest) error {
	return s.tokenRepo.Upsert(ctx, userID, req.Token, req.Platform, req.DeviceID)
}

func (s *NotificationService) DeleteToken(ctx context.Context, userID domain.ID, token string) error {
	return s.tokenRepo.Deactivate(ctx, userID, token)
}

// CreateAndDispatch — внутренний метод для событий (recommendation, achievement, etc.)
func (s *NotificationService) CreateAndDispatch(ctx context.Context, userID domain.ID, notifType, title string, body *string, data map[string]any) (domain.ID, error) {
	var dataJSON []byte
	if data != nil {
		b, _ := json.Marshal(data)
		dataJSON = b
	}

	id, err := s.notifRepo.Create(ctx, repositories.CreateNotificationParams{
		UserID:   userID,
		Type:     notifType,
		Title:    title,
		Body:     body,
		DataJSON: dataJSON,
	})
	if err != nil {
		return domain.ID{}, err
	}

	// enqueue push (если queue nil — просто создаём inbox запись)
	if s.queue != nil {
		_ = s.queue.EnqueueSendNotification(id)
	}

	return id, nil
}

func (s *NotificationService) EnsureReady() error {
	// для будущих проверок
	return errors.New("not implemented")
}
