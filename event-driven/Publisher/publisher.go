package event_driven

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"

	"github.com/segmentio/kafka-go"
)

// KafkaPublisher публикует события в Kafka
type KafkaPublisher struct {
	writer     *kafka.Writer
	signingKey string
}

// NewKafkaPublisher создает нового Kafka publisher
// signingKey should be retrieved from secure secret manager before calling this function
func NewKafkaPublisher(brokers []string, topic string, signingKey string) (*KafkaPublisher, error) {
	writer := &kafka.Writer{
		Addr:     kafka.TCP(brokers...),
		Topic:    topic,
		Balancer: &kafka.LeastBytes{},
	}

	if signingKey == "" {
		return nil, fmt.Errorf("Kafka signing key cannot be empty")
	}

	return &KafkaPublisher{
		writer:     writer,
		signingKey: signingKey,
	}, nil
}

// computeSignature generates HMAC-SHA256 signature for message data
func (kp *KafkaPublisher) computeSignature(data []byte) string {
	h := hmac.New(sha256.New, []byte(kp.signingKey))
	h.Write(data)
	signature := h.Sum(nil)
	return base64.StdEncoding.EncodeToString(signature)
}

// PublishRecommendationRequestedEvent публикует событие запроса рекомендации
func (kp *KafkaPublisher) PublishRecommendationRequestedEvent(ctx context.Context, event RecommendationRequestedEvent) error {
	data, err := json.Marshal(event)
	if err != nil {
		return fmt.Errorf("не удалось маршализовать событие: %w", err)
	}

	// Generate signature
	signature := kp.computeSignature(data)

	err = kp.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
		Headers: []kafka.Header{
			{Key: "X-Message-Signature", Value: []byte(signature)},
		},
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

	// Generate signature
	signature := kp.computeSignature(data)

	err = kp.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
		Headers: []kafka.Header{
			{Key: "X-Message-Signature", Value: []byte(signature)},
		},
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

	// Generate signature
	signature := kp.computeSignature(data)

	err = kp.writer.WriteMessages(ctx, kafka.Message{
		Value: data,
		Headers: []kafka.Header{
			{Key: "X-Message-Signature", Value: []byte(signature)},
		},
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
