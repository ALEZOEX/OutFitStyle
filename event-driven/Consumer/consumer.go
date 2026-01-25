package event_driven

import (
	"context"
	"encoding/json"
	"log"

	"github.com/segmentio/kafka-go"
)

// KafkaConsumer потребляет события из Kafka
type KafkaConsumer struct {
	reader *kafka.Reader
}

// NewKafkaConsumer создает нового Kafka consumer
func NewKafkaConsumer(brokers []string, topic, groupID string) *KafkaConsumer {
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers:  brokers,
		GroupID:  groupID,
		Topic:    topic,
		StartOffset: kafka.FirstOffset,
	})

	return &KafkaConsumer{
		reader: reader,
	}
}

// ConsumeRecommendationEvents начинает потребление событий рекомендаций
func (kc *KafkaConsumer) ConsumeRecommendationEvents(ctx context.Context, handler func(RecommendationRequestedEvent)) error {
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

			var event RecommendationRequestedEvent
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