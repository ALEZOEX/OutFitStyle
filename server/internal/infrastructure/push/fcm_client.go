// Package push предоставляет интеграцию с Firebase Cloud Messaging (FCM)
// для отправки push-уведомлений на устройства пользователей.
package push

import (
	"context"
	"fmt"
	"os"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"go.uber.org/zap"
	"google.golang.org/api/option"
)

// FCMClient — клиент для отправки push-уведомлений через Firebase Cloud Messaging.
type FCMClient struct {
	client *messaging.Client
	logger *zap.Logger
}

// FCMClientConfig — конфигурация для создания FCM клиента.
type FCMClientConfig struct {
	// CredentialsFile — путь к JSON файлу с сервисными учётными данными Firebase.
	// Если пуст, используется переменная окружения GOOGLE_APPLICATION_CREDENTIALS
	// или Application Default Credentials.
	CredentialsFile string
}

// NewFCMClient создаёт новый FCM клиент.
// Если credentialsFile пуст, используются Application Default Credentials.
func NewFCMClient(cfg FCMClientConfig, logger *zap.Logger) (*FCMClient, error) {
	ctx := context.Background()

	var opt option.ClientOption
	if cfg.CredentialsFile != "" {
		// Проверяем существование файла
		if _, err := os.Stat(cfg.CredentialsFile); os.IsNotExist(err) {
			return nil, fmt.Errorf("FCM credentials file not found: %s", cfg.CredentialsFile)
		}
		opt = option.WithCredentialsFile(cfg.CredentialsFile)
		logger.Info("FCM: using credentials file", zap.String("file", cfg.CredentialsFile))
	} else {
		// Используем Application Default Credentials
		logger.Info("FCM: using Application Default Credentials")
		opt = option.WithCredentialsJSON([]byte("{}")) // Пустые креды, ADC найдёт сам
	}

	// Создаём Firebase app
	app, err := firebase.NewApp(ctx, nil, opt)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize Firebase App: %w", err)
	}

	// Получаем messaging client
	messagingClient, err := app.Messaging(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize FCM Messaging client: %w", err)
	}

	logger.Info("FCM client initialized successfully")

	return &FCMClient{
		client: messagingClient,
		logger: logger,
	}, nil
}

// Send отправляет push-уведомление на устройство.
// token — FCM registration token устройства.
// title — заголовок уведомления.
// body — текст уведомления.
// data — дополнительные данные (ключ-значение), передаваемые в приложении.
func (c *FCMClient) Send(token, title, body string, data map[string]string) error {
	return c.SendWithContext(context.Background(), token, title, body, data)
}

// SendWithContext отправляет push-уведомление с поддержкой отмены через context.
func (c *FCMClient) SendWithContext(ctx context.Context, token, title, body string, data map[string]string) error {
	if token == "" {
		return fmt.Errorf("FCM token is required")
	}

	message := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Data: data,
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				// Звук по умолчанию
				Sound: "default",
			},
		},
		APNS: &messaging.APNSConfig{
			Headers: map[string]string{
				"apns-priority": "10",
			},
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound: "default",
				},
			},
		},
	}

	response, err := c.client.Send(ctx, message)
	if err != nil {
		c.logger.Error("FCM send failed",
			zap.String("token", maskToken(token)),
			zap.String("title", title),
			zap.Error(err),
		)
		return fmt.Errorf("FCM send error: %w", err)
	}

	c.logger.Debug("FCM send successful",
		zap.String("message_id", response),
		zap.String("token", maskToken(token)),
	)

	return nil
}

// SendMulticast отправляет push-уведомление нескольким устройствам.
// Возвращает количество успешных отправок и ошибки по каждому токену.
func (c *FCMClient) SendMulticast(ctx context.Context, tokens []string, title, body string, data map[string]string) (successCount int, errors map[string]error) {
	if len(tokens) == 0 {
		return 0, nil
	}

	errors = make(map[string]error)

	// FCM поддерживает до 500 токенов в одном запросе
	const maxTokens = 500
	for i := 0; i < len(tokens); i += maxTokens {
		end := i + maxTokens
		if end > len(tokens) {
			end = len(tokens)
		}
		batch := tokens[i:end]

		message := &messaging.MulticastMessage{
			Tokens: batch,
			Notification: &messaging.Notification{
				Title: title,
				Body:  body,
			},
			Data: data,
			Android: &messaging.AndroidConfig{
				Priority: "high",
				Notification: &messaging.AndroidNotification{
					Sound: "default",
				},
			},
			APNS: &messaging.APNSConfig{
				Headers: map[string]string{
					"apns-priority": "10",
				},
				Payload: &messaging.APNSPayload{
					Aps: &messaging.Aps{
						Sound: "default",
					},
				},
			},
		}

		br, err := c.client.SendMulticast(ctx, message)
		if err != nil {
			c.logger.Error("FCM multicast failed", zap.Error(err))
			// Записываем ошибку для всех токенов в батче
			for _, t := range batch {
				errors[t] = err
			}
			continue
		}

		successCount += br.SuccessCount

		// Записываем ошибки для неуспешных токенов
		for idx, resp := range br.Responses {
			if !resp.Success {
				errors[batch[idx]] = resp.Error
			}
		}
	}

	return successCount, errors
}

// ValidateToken проверяет валидность FCM токена без отправки уведомления.
// Возвращает true если токен валиден, false если нет.
func (c *FCMClient) ValidateToken(ctx context.Context, token string) (bool, error) {
	if token == "" {
		return false, fmt.Errorf("FCM token is required")
	}

	// Пытаемся отправить тестовое сообщение
	message := &messaging.Message{
		Token: token,
		Data: map[string]string{
			"type": "validation",
		},
	}

	_, err := c.client.Send(ctx, message)
	if err != nil {
		// Ошибки валидации токена
		if isInvalidTokenError(err) {
			return false, nil
		}
		return false, fmt.Errorf("FCM validation error: %w", err)
	}

	return true, nil
}

// isInvalidTokenError проверяет, является ли ошибка ошибкой невалидного токена.
func isInvalidTokenError(err error) bool {
	if err == nil {
		return false
	}

	errStr := err.Error()
	// Firebase возвращает разные коды ошибок для невалидных токенов
	invalidErrors := []string{
		"messaging/invalid-registration-token",
		"messaging/registration-token-not-registered",
		"messaging/invalid-argument",
		"Requested entity was not found",
	}

	for _, invalid := range invalidErrors {
		if contains(errStr, invalid) {
			return true
		}
	}

	return false
}

// contains проверяет, содержит ли строка s подстроку substr.
func contains(s, substr string) bool {
	return len(s) >= len(substr) && (s == substr || len(s) > len(substr) && findSubstring(s, substr))
}

func findSubstring(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

// maskToken маскирует токен для безопасного логирования.
func maskToken(token string) string {
	if len(token) <= 8 {
		return "***"
	}
	return token[:4] + "..." + token[len(token)-4:]
}

// Close закрывает соединения FCM клиента.
// Вызывайте при завершении приложения.
func (c *FCMClient) Close() error {
	// Firebase SDK не требует явного закрытия,
	// но оставляем метод для совместимости с интерфейсом
	c.logger.Debug("FCM client closed")
	return nil
}
