// Package services предоставляет бизнес-логику для отправки push-уведомлений.
package services

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/push"
)

// PushNotificationService — сервис для отправки push-уведомлений через FCM.
type PushNotificationService struct {
	fcmClient     *push.FCMClient
	notifRepo     repositories.NotificationRepository
	tokenRepo     repositories.PushTokenRepository
	userRepo      repositories.UserRepository
	logger        *zap.Logger
}

// NewPushNotificationService создаёт новый сервис push-уведомлений.
func NewPushNotificationService(
	fcmClient *push.FCMClient,
	notifRepo repositories.NotificationRepository,
	tokenRepo repositories.PushTokenRepository,
	userRepo repositories.UserRepository,
	logger *zap.Logger,
) *PushNotificationService {
	return &PushNotificationService{
		fcmClient: fcmClient,
		notifRepo: notifRepo,
		tokenRepo: tokenRepo,
		userRepo:  userRepo,
		logger:    logger,
	}
}

// SendRecommendation отправляет push-уведомление о новой рекомендации одежды.
// userID — ID пользователя.
// weatherDesc — описание погоды (например, "Дождь, +15°C").
// outfitItems — количество предметов в рекомендации.
func (s *PushNotificationService) SendRecommendation(
	ctx context.Context,
	userID domain.ID,
	weatherDesc string,
	outfitItems int,
) error {
	title := "Новая рекомендация по одежде"
	body := fmt.Sprintf("Подобрали outfit для погоды: %s", weatherDesc)

	data := map[string]string{
		"type":        "recommendation",
		"user_id":     userID.String(),
		"weather":     weatherDesc,
		"outfit_items": strconv.Itoa(outfitItems),
	}

	return s.sendToUser(ctx, userID, title, body, data)
}

// SendAchievement отправляет push-уведомление о полученном достижении.
// userID — ID пользователя.
// achievementName — название достижения.
// achievementIcon — иконка достижения (URL или имя).
func (s *PushNotificationService) SendAchievement(
	ctx context.Context,
	userID domain.ID,
	achievementName string,
	achievementIcon string,
) error {
	title := "🏆 Новое достижение!"
	body := fmt.Sprintf("Вы получили достижение: %s", achievementName)

	data := map[string]string{
		"type":      "achievement",
		"user_id":   userID.String(),
		"achievement_name": achievementName,
		"achievement_icon": achievementIcon,
	}

	return s.sendToUser(ctx, userID, title, body, data)
}

// SendWeatherAlert отправляет push-уведомление о изменении погоды.
// userID — ID пользователя.
// alertType — тип предупреждения (например, "rain", "cold", "hot").
// alertMessage — текст предупреждения.
func (s *PushNotificationService) SendWeatherAlert(
	ctx context.Context,
	userID domain.ID,
	alertType string,
	alertMessage string,
) error {
	title := "⚠️ Предупреждение о погоде"
	body := alertMessage

	data := map[string]string{
		"type":         "weather_alert",
		"user_id":      userID.String(),
		"alert_type":   alertType,
		"alert_message": alertMessage,
	}

	return s.sendToUser(ctx, userID, title, body, data)
}

// SendPromotion отправляет push-уведомление о промо-акции.
// userID — ID пользователя.
// promoCode — промокод.
// discount — размер скидки в процентах.
// expiryDays — количество дней до истечения.
func (s *PushNotificationService) SendPromotion(
	ctx context.Context,
	userID domain.ID,
	promoCode string,
	discount int,
	expiryDays int,
) error {
	title := "🎁 Специальное предложение!"
	body := fmt.Sprintf("Ваш промокод: %s — скидка %d%%. Действует %d дн.", promoCode, discount, expiryDays)

	data := map[string]string{
		"type":       "promotion",
		"user_id":    userID.String(),
		"promo_code": promoCode,
		"discount":   strconv.Itoa(discount),
		"expiry_days": strconv.Itoa(expiryDays),
	}

	return s.sendToUser(ctx, userID, title, body, data)
}

// SendCustom отправляет кастомное push-уведомление.
// userID — ID пользователя.
// title — заголовок уведомления.
// body — текст уведомления.
// data — дополнительные данные.
func (s *PushNotificationService) SendCustom(
	ctx context.Context,
	userID domain.ID,
	title string,
	body string,
	data map[string]string,
) error {
	if data == nil {
		data = make(map[string]string)
	}
	data["user_id"] = userID.String()

	return s.sendToUser(ctx, userID, title, body, data)
}

// sendToUser отправляет push-уведомление всем активным токенам пользователя.
func (s *PushNotificationService) sendToUser(
	ctx context.Context,
	userID domain.ID,
	title string,
	body string,
	data map[string]string,
) error {
	// Получаем все активные токены пользователя
	tokens, err := s.tokenRepo.ListActiveByUser(ctx, userID)
	if err != nil {
		s.logger.Error("Failed to get user push tokens",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		return fmt.Errorf("failed to get push tokens: %w", err)
	}

	if len(tokens) == 0 {
		s.logger.Debug("No active push tokens for user",
			zap.String("user_id", userID.String()),
		)
		return nil
	}

	// Собираем токены в срез
	tokenStrings := make([]string, 0, len(tokens))
	for _, t := range tokens {
		if t.IsActive && t.Token != "" {
			tokenStrings = append(tokenStrings, t.Token)
		}
	}

	if len(tokenStrings) == 0 {
		s.logger.Debug("No valid push tokens for user",
			zap.String("user_id", userID.String()),
		)
		return nil
	}

	// Отправляем через multicast (до 500 токенов за запрос)
	successCount, errors := s.fcmClient.SendMulticast(ctx, tokenStrings, title, body, data)

	// Логируем результат
	s.logger.Info("Push notification sent",
		zap.String("user_id", userID.String()),
		zap.String("title", title),
		zap.Int("tokens_total", len(tokenStrings)),
		zap.Int("tokens_success", successCount),
		zap.Int("tokens_failed", len(errors)),
	)

	// Если все токены вернули ошибки валидации — деактивируем их
	s.handleInvalidTokens(ctx, userID, tokenStrings, errors)

	return nil
}

// handleInvalidTokens деактивирует токены, которые вернули ошибку невалидности.
func (s *PushNotificationService) handleInvalidTokens(
	ctx context.Context,
	userID domain.ID,
	tokens []string,
	errors map[string]error,
) {
	invalidTokens := make([]string, 0)

	for token, err := range errors {
		if err != nil && isInvalidTokenError(err) {
			invalidTokens = append(invalidTokens, token)
		}
	}

	if len(invalidTokens) > 0 {
		s.logger.Warn("Deactivating invalid push tokens",
			zap.String("user_id", userID.String()),
			zap.Int("count", len(invalidTokens)),
		)

		for _, token := range invalidTokens {
			if err := s.tokenRepo.Deactivate(ctx, userID, token); err != nil {
				s.logger.Error("Failed to deactivate invalid token",
					zap.String("user_id", userID.String()),
					zap.String("token", maskToken(token)),
					zap.Error(err),
				)
			}
		}
	}
}

// isInvalidTokenError проверяет, является ли ошибка ошибкой невалидного токена.
func isInvalidTokenError(err error) bool {
	if err == nil {
		return false
	}

	errStr := err.Error()
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

func contains(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}

func maskToken(token string) string {
	if len(token) <= 8 {
		return "***"
	}
	return token[:4] + "..." + token[len(token)-4:]
}

// CreateAndDispatchPush создаёт уведомление в БД и отправляет push.
// Это обёртка над NotificationService.CreateAndDispatch с отправкой через FCM.
func (s *PushNotificationService) CreateAndDispatchPush(
	ctx context.Context,
	userID domain.ID,
	notifType string,
	title string,
	body *string,
	data map[string]any,
) (domain.ID, error) {
	// Сериализуем данные в JSON
	var dataJSON []byte
	if data != nil {
		b, err := json.Marshal(data)
		if err != nil {
			s.logger.Error("Failed to marshal notification data",
				zap.Error(err),
			)
		} else {
			dataJSON = b
		}
	}

	// Создаём запись в БД
	id, err := s.notifRepo.Create(ctx, repositories.CreateNotificationParams{
		UserID:   userID,
		Type:     notifType,
		Title:    title,
		Body:     body,
		DataJSON: dataJSON,
	})
	if err != nil {
		s.logger.Error("Failed to create notification",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		return domain.ID{}, fmt.Errorf("failed to create notification: %w", err)
	}

	// Отправляем push
	bodyStr := ""
	if body != nil {
		bodyStr = *body
	}

	// Конвертируем data в map[string]string для FCM
	fcmData := make(map[string]string)
	for k, v := range data {
		switch val := v.(type) {
		case string:
			fcmData[k] = val
		case int:
			fcmData[k] = strconv.Itoa(val)
		case int64:
			fcmData[k] = strconv.FormatInt(val, 10)
		case bool:
			fcmData[k] = strconv.FormatBool(val)
		default:
			// Сериализуем сложные типы в JSON строку
			if b, err := json.Marshal(val); err == nil {
				fcmData[k] = string(b)
			}
		}
	}

	pushErr := s.sendToUser(ctx, userID, title, bodyStr, fcmData)

	// Обновляем статус отправки push в БД
	if pushErr != nil {
		pushErrMsg := pushErr.Error()
		if err := s.notifRepo.MarkPushResult(ctx, id, false, &pushErrMsg); err != nil {
			s.logger.Error("Failed to update push status",
				zap.String("notification_id", id.String()),
				zap.Error(err),
			)
		}
	} else {
		if err := s.notifRepo.MarkPushResult(ctx, id, true, nil); err != nil {
			s.logger.Error("Failed to update push status",
				zap.String("notification_id", id.String()),
				zap.Error(err),
			)
		}
	}

	return id, nil
}
