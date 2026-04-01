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
	contracts "outfitstyle/event-driven/contracts"
)

// KafkaConsumer потребляет события из Kafka
type KafkaConsumer struct {
	reader     *kafka.Reader
	signingKey string
}

// NewKafkaConsumer создает нового Kafka consumer
// signingKey should be retrieved from secure secret manager before calling this function
func NewKafkaConsumer(brokers []string, topic, groupID string, signingKey string) (*KafkaConsumer, error) {
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers:     brokers,
		GroupID:     groupID,
		Topic:       topic,
		StartOffset: kafka.FirstOffset,
	})

	if signingKey == "" {
		return nil, fmt.Errorf("Kafka signing key cannot be empty")
	}

	return &KafkaConsumer{
		reader:     reader,
		signingKey: signingKey,
	}, nil
}

// verifySignature verifies the HMAC-SHA256 signature of message data
func (kc *KafkaConsumer) verifySignature(data []byte, signature string) bool {
	h := hmac.New(sha256.New, []byte(kc.signingKey))
	h.Write(data)
	expectedSignature := h.Sum(nil)
	expectedSignatureStr := base64.StdEncoding.EncodeToString(expectedSignature)

	// Use constant-time comparison to prevent timing attacks
	return hmac.Equal([]byte(expectedSignatureStr), []byte(signature))
}

// getSignatureFromHeaders extracts the signature from Kafka message headers
func getSignatureFromHeaders(headers []kafka.Header) (string, bool) {
	for _, header := range headers {
		if header.Key == "X-Message-Signature" {
			return string(header.Value), true
		}
	}
	return "", false
}

// ConsumeRecommendationEvents начинает потребление событий рекомендаций
func (kc *KafkaConsumer) ConsumeRecommendationEvents(ctx context.Context, handler func(contracts.RecommendationRequestedEvent)) error {
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
			msg, err := kc.reader.FetchMessage(context.Background())
			if err != nil {
				log.Printf("Ошибка получения сообщения: %v", err)
				continue
			}

			// Extract signature from headers
			signature, found := getSignatureFromHeaders(msg.Headers)
			if !found {
				log.Printf("SECURITY WARNING: Unsigned message rejected - missing signature header")
				kc.reader.CommitMessages(context.Background(), msg)
				continue
			}

			// Verify signature
			if !kc.verifySignature(msg.Value, signature) {
				log.Printf("SECURITY WARNING: Message with invalid signature rejected")
				kc.reader.CommitMessages(context.Background(), msg)
				continue
			}

			var event contracts.RecommendationRequestedEvent
			err = json.Unmarshal(msg.Value, &event)
			if err != nil {
				log.Printf("Ошибка демаршалинга события: %v", err)
				kc.reader.CommitMessages(context.Background(), msg)
				continue
			}

			// Обработка события
			handler(event)

			// Подтверждение получения сообщения
			err = kc.reader.CommitMessages(context.Background(), msg)
			if err != nil {
				log.Printf("Ошибка подтверждения сообщения: %v", err)
			}
		}
	}
}

// Close закрывает Kafka consumer
func (kc *KafkaConsumer) Close() error {
	return kc.reader.Close()
}
