package eventing

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/segmentio/kafka-go"
	"outfitstyle/server/internal/core/domain"
)

// KafkaEventPublisher реализация EventPublisher с использованием Kafka
type KafkaEventPublisher struct {
	writer *kafka.Writer
}

// NewKafkaEventPublisher создает новый экземпляр KafkaEventPublisher
func NewKafkaEventPublisher(brokers []string, topic string) *KafkaEventPublisher {
	writer := &kafka.Writer{
		Addr:     kafka.TCP(brokers...),
		Topic:    topic,
		Balancer: &kafka.LeastBytes{},
	}

	return &KafkaEventPublisher{
		writer: writer,
	}
}

// PublishRecommendationRequested публикует событие запроса рекомендации
func (k *KafkaEventPublisher) PublishRecommendationRequested(ctx context.Context, userID domain.ID, context interface{}, candidates []interface{}) error {
	event := map[string]interface{}{
		"event_type": "recommendation_requested",
		"event_id":   fmt.Sprintf("rec_req_%d", time.Now().UnixNano()),
		"user_id":    userID.String(),
		"timestamp":  time.Now().Format(time.RFC3339),
		"context":    context,
		"candidates": candidates,
		"request_id": fmt.Sprintf("req_%d", time.Now().UnixNano()),
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal recommendation requested event: %w", err)
	}

	err = k.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
	})
	if err != nil {
		return fmt.Errorf("failed to publish recommendation requested event: %w", err)
	}

	return nil
}

// PublishRecommendationProcessed публикует событие обработки рекомендации
func (k *KafkaEventPublisher) PublishRecommendationProcessed(ctx context.Context, userID domain.ID, requestID string, rankedItems []interface{}) error {
	event := map[string]interface{}{
		"event_type":      "recommendation_processed",
		"event_id":        fmt.Sprintf("rec_proc_%d", time.Now().UnixNano()),
		"request_id":      requestID,
		"user_id":         userID.String(),
		"timestamp":       time.Now().Format(time.RFC3339),
		"ranked_items":    rankedItems,
		"model_version":   "v1.0.0", // This would come from the ML model
		"processing_time": 0.0,      // This would be calculated
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal recommendation processed event: %w", err)
	}

	err = k.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
	})
	if err != nil {
		return fmt.Errorf("failed to publish recommendation processed event: %w", err)
	}

	return nil
}

// PublishUserFeedback публикует событие обратной связи пользователя
func (k *KafkaEventPublisher) PublishUserFeedback(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	event := map[string]interface{}{
		"event_type":        "user_feedback",
		"event_id":          fmt.Sprintf("feedback_%d", time.Now().UnixNano()),
		"user_id":           userID.String(),
		"recommendation_id": recommendationID.String(),
		"timestamp":         time.Now().Format(time.RFC3339),
		"rating":            rating,
		"feedback":          feedback,
		"session_id":        "", // Would come from context
	}

	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("failed to marshal user feedback event: %w", err)
	}

	err = k.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
	})
	if err != nil {
		return fmt.Errorf("failed to publish user feedback event: %w", err)
	}

	return nil
}

// Close закрывает Kafka publisher
func (k *KafkaEventPublisher) Close() error {
	return k.writer.Close()
}
