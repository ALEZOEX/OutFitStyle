package eventing

import (
	"context"
	"outfitstyle/server/internal/core/domain"
)

// EventPublisher определяет интерфейс для публикации событий
type EventPublisher interface {
	PublishRecommendationRequested(ctx context.Context, userID domain.ID, context interface{}, candidates []interface{}) error
	PublishRecommendationProcessed(ctx context.Context, userID domain.ID, requestID string, rankedItems []interface{}) error
	PublishUserFeedback(ctx context.Context, userID domain.ID, recommendationID domain.ID, rating int, feedback string) error
	Close() error
}

// EventConsumer определяет интерфейс для потребления событий
type EventConsumer interface {
	ConsumeRecommendationRequests(ctx context.Context, handler func(domain.ID, interface{}, []interface{})) error
	ConsumeUserFeedback(ctx context.Context, handler func(domain.ID, domain.ID, int, string)) error
	Close() error
}

// EventHandler определяет интерфейс для обработки событий
type EventHandler interface {
	HandleRecommendationRequest(ctx context.Context, userID domain.ID, context interface{}, candidates []interface{}) error
	HandleUserFeedback(ctx context.Context, userID domain.ID, recommendationID domain.ID, rating int, feedback string) error
}
