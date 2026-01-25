package integration

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/eventing"
)

// APIIntegrationExample показывает пример интеграции event-driven архитектуры с API
type APIIntegrationExample struct {
	recommendationService *services.RecommendationService
	eventPublisher        eventing.EventPublisher
}

// NewAPIIntegrationExample создает новый экземпляр интеграции
func NewAPIIntegrationExample(recService *services.RecommendationService, eventPub eventing.EventPublisher) *APIIntegrationExample {
	return &APIIntegrationExample{
		recommendationService: recService,
		eventPublisher:        eventPub,
	}
}

// ProcessRecommendationRequest обрабатывает запрос рекомендации через event-driven архитектуру
func (a *APIIntegrationExample) ProcessRecommendationRequest(ctx context.Context, userID domain.ID, req domain.RecommendationCreateRequest) error {
	// Подготовка контекста для ML-сервиса
	contextData := map[string]interface{}{
		"temperature":         req.Weather.Temperature,
		"feels_like":          req.Weather.FeelsLike,
		"humidity":            req.Weather.Humidity,
		"wind_speed":          req.Weather.WindSpeed,
		"weather_code":        req.Weather.WeatherCode,
		"occasion":            req.Occasion,
		"requested_style":     req.Style,
		"requested_formality": req.Formality,
		"location":            req.Location,
		"latitude":            req.Latitude,
		"longitude":           req.Longitude,
	}

	// Загрузка кандидатов для рекомендаций
	candidates, err := a.loadCandidates(ctx, userID)
	if err != nil {
		return fmt.Errorf("не удалось загрузить кандидатов: %w", err)
	}

	// Публикация события запроса рекомендации
	err = a.eventPublisher.PublishRecommendationRequested(ctx, userID, contextData, candidates)
	if err != nil {
		return fmt.Errorf("не удалось опубликовать событие запроса рекомендации: %w", err)
	}

	return nil
}

// HandleRecommendationResponse обрабатывает ответ от ML-сервиса
func (a *APIIntegrationExample) HandleRecommendationResponse(ctx context.Context, userID domain.ID, requestID string, rankedItems []interface{}) error {
	// Здесь мы можем сохранить результаты рекомендаций в базу данных
	// или выполнить другие действия с результатами

	// Пример сохранения результата
	result := &domain.RecommendationRecord{
		ID:        domain.NewID(),
		UserID:    userID,
		Status:    "completed",
		CreatedAt: time.Now(),
	}

	// Сохраняем рекомендацию
	err := a.saveRecommendationResult(ctx, result, rankedItems)
	if err != nil {
		return fmt.Errorf("не удалось сохранить результат рекомендации: %w", err)
	}

	// Публикуем событие обработки рекомендации
	err = a.eventPublisher.PublishRecommendationProcessed(ctx, userID, requestID, rankedItems)
	if err != nil {
		return fmt.Errorf("не удалось опубликовать событие обработки рекомендации: %w", err)
	}

	return nil
}

// HandleUserFeedback обрабатывает обратную связь пользователя
func (a *APIIntegrationExample) HandleUserFeedback(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	// Публикуем событие обратной связи пользователя
	err := a.eventPublisher.PublishUserFeedback(ctx, userID, recommendationID, rating, feedback)
	if err != nil {
		return fmt.Errorf("не удалось опубликовать событие обратной связи пользователя: %w", err)
	}

	// Также можем сохранить обратную связь в базу данных
	err = a.saveUserFeedback(ctx, userID, recommendationID, rating, feedback)
	if err != nil {
		return fmt.Errorf("не удалось сохранить обратную связь пользователя: %w", err)
	}

	return nil
}

// loadCandidates загружает кандидатов для рекомендаций
func (a *APIIntegrationExample) loadCandidates(ctx context.Context, userID domain.ID) ([]interface{}, error) {
	// Загружаем кандидатов из репозитория
	candidates, err := a.recommendationService.GetWardrobeCandidates(ctx, userID)
	if err != nil {
		return nil, err
	}

	// Преобразуем кандидатов в интерфейсы для публикации события
	interfaces := make([]interface{}, len(candidates))
	for i, candidate := range candidates {
		interfaces[i] = candidate
	}

	return interfaces, nil
}

// saveRecommendationResult сохраняет результат рекомендации
func (a *APIIntegrationExample) saveRecommendationResult(ctx context.Context, rec *domain.RecommendationRecord, rankedItems []interface{}) error {
	// В реальной реализации здесь будет сохранение в базу данных
	// через recommendation repository

	// Преобразуем rankedItems обратно в нужный формат
	items := make([]domain.RecommendationItem, 0, len(rankedItems))
	for _, item := range rankedItems {
		if itemMap, ok := item.(map[string]interface{}); ok {
			idStr, ok := itemMap["id"].(string)
			if !ok {
				continue
			}

			id, err := domain.ParseID(idStr)
			if err != nil {
				continue
			}

			score, _ := itemMap["score"].(float64)

			items = append(items, domain.RecommendationItem{
				ID:    id,
				Score: score,
			})
		}
	}

	// Сохраняем рекомендацию и элементы
	return a.recommendationService.SaveRecommendation(ctx, rec, items)
}

// saveUserFeedback сохраняет обратную связь пользователя
func (a *APIIntegrationExample) saveUserFeedback(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	// В реальной реализации здесь будет сохранение в базу данных
	// через feedback repository

	// Отправляем информацию в ML сервис для обучения
	go func() {
		// Создаем фоновый контекст с таймаутом
		bgCtx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		// Отправляем обратную связь в ML сервис
		_ = a.sendFeedbackToMLService(bgCtx, userID, recommendationID, rating, feedback)
	}()

	return nil
}

// sendFeedbackToMLService отправляет обратную связь в ML сервис для обучения
func (a *APIIntegrationExample) sendFeedbackToMLService(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	// В реальной реализации здесь будет вызов ML сервиса
	// для обновления модели на основе обратной связи
	fmt.Printf("Отправка обратной связи в ML сервис: userID=%s, recID=%s, rating=%d, feedback=%s\n", 
		userID.String(), recommendationID.String(), rating, feedback)
	return nil
}

// ProcessRecommendationWithFallback обрабатывает рекомендацию с резервной стратегией
func (a *APIIntegrationExample) ProcessRecommendationWithFallback(ctx context.Context, userID domain.ID, req domain.RecommendationCreateRequest) error {
	// Пытаемся обработать через event-driven архитектуру
	err := a.ProcessRecommendationRequest(ctx, userID, req)
	if err != nil {
		// Если не удалось опубликовать событие, используем резервную стратегию
		fmt.Printf("Ошибка event-driven архитектуры: %v, используем резервную стратегию\n", err)
		
		// Выполняем синхронную обработку
		rec, err := a.recommendationService.CreateRecommendationSync(ctx, userID, req)
		if err != nil {
			return fmt.Errorf("не удалось обработать рекомендацию синхронно: %w", err)
		}

		// Публикуем событие о резервной обработке
		contextData := map[string]interface{}{
			"fallback": true,
			"original_error": err.Error(),
		}
		
		candidates := []interface{}{} // Пустой массив кандидатов для резервной обработки
		
		publishErr := a.eventPublisher.PublishRecommendationRequested(ctx, userID, contextData, candidates)
		if publishErr != nil {
			// Если не удалось опубликовать событие даже для резервной стратегии,
			// просто логируем ошибку, но не прерываем выполнение
			fmt.Printf("Не удалось опубликовать событие для резервной стратегии: %v\n", publishErr)
		}

		return nil
	}

	return nil
}