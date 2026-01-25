package event_driven

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/segmentio/kafka-go"
)

// KafkaPublisher публикует события в Kafka
type KafkaPublisher struct {
	writer *kafka.Writer
}

// NewKafkaPublisher создает нового Kafka publisher
func NewKafkaPublisher(brokers []string, topic string) *KafkaPublisher {
	writer := &kafka.Writer{
		Addr:     kafka.TCP(brokers...),
		Topic:    topic,
		Balancer: &kafka.LeastBytes{},
	}

	return &KafkaPublisher{
		writer: writer,
	}
}

// PublishRecommendationRequestedEvent публикует событие запроса рекомендации
func (kp *KafkaPublisher) PublishRecommendationRequestedEvent(ctx context.Context, event RecommendationRequestedEvent) error {
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("не удалось маршализовать событие: %w", err)
	}

	err = kp.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
	})
	if err != nil {
		return fmt.Errorf("не удалось опубликовать событие: %w", err)
	}

	log.Printf("Опубликовано RecommendationRequestedEvent для пользователя %s", event.UserID)
	return nil
}

// PublishRecommendationProcessedEvent публикует событие обработки рекомендации
func (kp *KafkaPublisher) PublishRecommendationProcessedEvent(ctx context.Context, event RecommendationProcessedEvent) error {
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("не удалось маршализовать событие: %w", err)
	}

	err = kp.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
	})
	if err != nil {
		return fmt.Errorf("не удалось опубликовать событие: %w", err)
	}

	log.Printf("Опубликовано RecommendationProcessedEvent для запроса %s", event.RequestID)
	return nil
}

// PublishUserFeedbackEvent публикует событие обратной связи пользователя
func (kp *KafkaPublisher) PublishUserFeedbackEvent(ctx context.Context, event UserFeedbackEvent) error {
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("не удалось маршализовать событие: %w", err)
	}

	err = kp.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
	})
	if err != nil {
		return fmt.Errorf("не удалось опубликовать событие: %w", err)
	}

	log.Printf("Опубликовано UserFeedbackEvent для пользователя %s", event.UserID)
	return nil
}

// Close закрывает Kafka publisher
func (kp *KafkaPublisher) Close() error {
	return kp.writer.Close()
}