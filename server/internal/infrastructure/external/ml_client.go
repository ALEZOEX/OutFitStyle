package external

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/pkg/errors"
)

type MLClient struct {
	baseURL string
	http    *http.Client
}

func NewMLClient(baseURL string, timeout time.Duration) *MLClient {
	return &MLClient{
		baseURL: baseURL,
		http:    &http.Client{Timeout: timeout},
	}
}

func (c *MLClient) Rank(ctx context.Context, req TZMLRankRequest) (TZMLRankResponse, error) {
	var out TZMLRankResponse

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal rank request")
	}

	u := fmt.Sprintf("%s/api/v1/rank", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	// Пробрасываем request_id в заголовке (он также есть в теле запроса)
	httpReq.Header.Set("X-Request-Id", req.RequestID)
	httpReq.Header.Set("X-User-Id", req.UserID.String())

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("ml bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode response")
	}
	return out, nil
}

// ActionRequest представляет запрос для отправки действия пользователя
type ActionRequest struct {
	RequestID  string                 `json:"request_id"`
	UserID     string                 `json:"user_id"`
	ActionType string                 `json:"action_type"`
	EntityID   string                 `json:"entity_id"`
	EntityType string                 `json:"entity_type"`
	Meta       map[string]interface{} `json:"meta,omitempty"`
}

// ActionResponse представляет ответ от ML сервиса
type ActionResponse struct {
	Ok bool `json:"ok"`
}

// SendAction отправляет действие пользователя в ML сервис
func (c *MLClient) SendAction(ctx context.Context, req ActionRequest) (ActionResponse, error) {
	var out ActionResponse

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal action request")
	}

	u := fmt.Sprintf("%s/api/action", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	// Устанавливаем заголовки для отслеживания
	httpReq.Header.Set("X-Request-Id", req.RequestID)
	httpReq.Header.Set("X-User-Id", req.UserID)

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("ml action bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode action response")
	}
	return out, nil
}

func (c *MLClient) HealthCheck(ctx context.Context) bool {
	u := fmt.Sprintf("%s/health", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
	if err != nil {
		return false
	}

	res, err := c.http.Do(httpReq)
	if err != nil {
		return false
	}
	defer res.Body.Close()

	// Проверяем, что статус успешный (2xx)
	return res.StatusCode >= 200 && res.StatusCode < 300
}

// GenerateOutfitRequest структура запроса для генерации наряда
type GenerateOutfitRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// GenerateOutfitResponse структура ответа для генерации наряда
type GenerateOutfitResponse struct {
	Success bool `json:"success"`
}

// GenerateOutfit вызывает ML-сервис для генерации наряда
func (c *MLClient) GenerateOutfit(ctx context.Context, userID string, meta map[string]interface{}) (GenerateOutfitResponse, error) {
	var out GenerateOutfitResponse

	req := GenerateOutfitRequest{
		RequestID: "req-" + userID, // В реальной системе это будет нормальный request ID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal generate outfit request")
	}

	u := fmt.Sprintf("%s/api/v1/outfit/generate", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("generate outfit bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode generate outfit response")
	}
	return out, nil
}

// GenerateRecommendationRequest структура запроса для генерации рекомендации
type GenerateRecommendationRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// GenerateRecommendationResponse структура ответа для генерации рекомендации
type GenerateRecommendationResponse struct {
	Success bool `json:"success"`
}

// GenerateRecommendation вызывает ML-сервис для генерации рекомендации
func (c *MLClient) GenerateRecommendation(ctx context.Context, userID string, meta map[string]interface{}) (GenerateRecommendationResponse, error) {
	var out GenerateRecommendationResponse

	req := GenerateRecommendationRequest{
		RequestID: "req-" + userID, // В реальной системе это будет нормальный request ID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return out, errors.Wrap(err, "marshal generate recommendation request")
	}

	u := fmt.Sprintf("%s/api/v1/recommendation/generate", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return out, errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return out, errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return out, errors.Errorf("generate recommendation bad status: %d", res.StatusCode)
	}

	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		return out, errors.Wrap(err, "decode generate recommendation response")
	}
	return out, nil
}

// ProcessFeedbackRequest структура запроса для обработки обратной связи
type ProcessFeedbackRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// ProcessFeedbackResponse структура ответа для обработки обратной связи
type ProcessFeedbackResponse struct {
	Success bool `json:"success"`
}

// ProcessFeedback вызывает ML-сервис для обработки обратной связи
func (c *MLClient) ProcessFeedback(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error {
	req := ProcessFeedbackRequest{
		RequestID: requestID, // Используем переданный requestID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return errors.Wrap(err, "marshal process feedback request")
	}

	u := fmt.Sprintf("%s/api/v1/feedback/process", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return errors.Errorf("process feedback bad status: %d", res.StatusCode)
	}

	return nil
}

// UpdateUserPreferencesRequest структура запроса для обновления пользовательских предпочтений
type UpdateUserPreferencesRequest struct {
	RequestID string                 `json:"request_id"`
	UserID    string                 `json:"user_id"`
	Meta      map[string]interface{} `json:"meta,omitempty"`
}

// UpdateUserPreferencesResponse структура ответа для обновления пользовательских предпочтений
type UpdateUserPreferencesResponse struct {
	Success bool `json:"success"`
}

// UpdateUserPreferences вызывает ML-сервис для обновления пользовательских предпочтений
func (c *MLClient) UpdateUserPreferences(ctx context.Context, userID string, requestID string, meta map[string]interface{}) error {
	req := UpdateUserPreferencesRequest{
		RequestID: requestID, // Используем переданный requestID
		UserID:    userID,
		Meta:      meta,
	}

	body, err := json.Marshal(req)
	if err != nil {
		return errors.Wrap(err, "marshal update user preferences request")
	}

	u := fmt.Sprintf("%s/api/v1/preferences/update", c.baseURL)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, u, bytes.NewReader(body))
	if err != nil {
		return errors.Wrap(err, "new request")
	}
	httpReq.Header.Set("Content-Type", "application/json")

	res, err := c.http.Do(httpReq)
	if err != nil {
		return errors.Wrap(err, "do request")
	}
	defer res.Body.Close()

	if res.StatusCode/100 != 2 {
		return errors.Errorf("update user preferences bad status: %d", res.StatusCode)
	}

	return nil
}
