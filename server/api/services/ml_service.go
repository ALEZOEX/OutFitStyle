package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"outfitstyle/server/api/models"
	"time"
)

type MLService struct {
	baseURL string
	client  *http.Client
}

func NewMLService(baseURL string) *MLService {
	return &MLService{
		baseURL: baseURL,
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// ML Request/Response структуры
type MLRecommendRequest struct {
	UserID  int                `json:"user_id"`
	Weather models.WeatherData `json:"weather"`
}

type MLRecommendResponse struct {
	RecommendationID int                   `json:"recommendation_id"`
	UserID           int                   `json:"user_id"`
	Weather          models.WeatherData    `json:"weather"`
	Recommendations  []models.ClothingItem `json:"recommendations"`
	OutfitScore      float64               `json:"outfit_score"`
	MLPowered        bool                  `json:"ml_powered"`
	Algorithm        string                `json:"algorithm"`
	Timestamp        string                `json:"timestamp"`
}

type MLTrainResponse struct {
	Status          string                 `json:"status"`
	Metrics         map[string]interface{} `json:"metrics"`
	TrainingSamples int                    `json:"training_samples"`
	Timestamp       string                 `json:"timestamp"`
}

type MLRateRequest struct {
	UserID             int     `json:"user_id"`
	RecommendationID   int     `json:"recommendation_id"`
	ItemID             int     `json:"item_id"`
	OverallRating      int     `json:"overall_rating"`
	ComfortRating      *int    `json:"comfort_rating,omitempty"`
	StyleRating        *int    `json:"style_rating,omitempty"`
	WeatherMatchRating *int    `json:"weather_match_rating,omitempty"`
	TooWarm            bool    `json:"too_warm"`
	TooCold            bool    `json:"too_cold"`
	Comment            string  `json:"comment"`
}

type MLStatsResponse struct {
	Recommendations map[string]interface{} `json:"recommendations"`
	Ratings         map[string]interface{} `json:"ratings"`
	ModelTrained    bool                   `json:"model_trained"`
	Timestamp       string                 `json:"timestamp"`
}

// GetRecommendations получает ML-рекомендации
func (s *MLService) GetRecommendations(userID int, weather *models.WeatherData) (*MLRecommendResponse, error) {
	reqBody := MLRecommendRequest{
		UserID:  userID,
		Weather: *weather,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal error: %w", err)
	}

	log.Printf("🧠 Requesting ML recommendations for user %d", userID)

	resp, err := s.client.Post(
		s.baseURL+"/api/ml/recommend",
		"application/json",
		bytes.NewBuffer(jsonData),
	)
	if err != nil {
		return nil, fmt.Errorf("request error: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("ML service returned %d: %s", resp.StatusCode, string(body))
	}

	var mlResp MLRecommendResponse
	if err := json.NewDecoder(resp.Body).Decode(&mlResp); err != nil {
		return nil, fmt.Errorf("decode error: %w", err)
	}

	log.Printf("✅ Got %d recommendations (score: %.2f, ML: %v)", 
		len(mlResp.Recommendations), mlResp.OutfitScore, mlResp.MLPowered)

	return &mlResp, nil
}

// TrainModel запускает переобучение ML модели
func (s *MLService) TrainModel() (*MLTrainResponse, error) {
	log.Println("🎓 Starting ML model training...")

	resp, err := s.client.Post(
		s.baseURL+"/api/ml/train",
		"application/json",
		nil,
	)
	if err != nil {
		return nil, fmt.Errorf("request error: %w", err)
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("training failed (%d): %s", resp.StatusCode, string(body))
	}

	var trainResp MLTrainResponse
	if err := json.Unmarshal(body, &trainResp); err != nil {
		return nil, fmt.Errorf("decode error: %w", err)
	}

	log.Printf("✅ Model trained: %v samples", trainResp.TrainingSamples)

	return &trainResp, nil
}

// RateRecommendation отправляет рейтинг рекомендации
func (s *MLService) RateRecommendation(req MLRateRequest) error {
	jsonData, err := json.Marshal(req)
	if err != nil {
		return fmt.Errorf("marshal error: %w", err)
	}

	resp, err := s.client.Post(
		s.baseURL+"/api/ml/rate",
		"application/json",
		bytes.NewBuffer(jsonData),
	)
	if err != nil {
		return fmt.Errorf("request error: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("rating failed (%d): %s", resp.StatusCode, string(body))
	}

	log.Printf("✅ Rating saved for recommendation %d", req.RecommendationID)
	return nil
}

// GetStats получает статистику ML сервиса
func (s *MLService) GetStats() (*MLStatsResponse, error) {
	resp, err := s.client.Get(s.baseURL + "/api/ml/stats")
	if err != nil {
		return nil, fmt.Errorf("request error: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("stats request failed (%d): %s", resp.StatusCode, string(body))
	}

	var stats MLStatsResponse
	if err := json.NewDecoder(resp.Body).Decode(&stats); err != nil {
		return nil, fmt.Errorf("decode error: %w", err)
	}

	return &stats, nil
}

// HealthCheck проверяет доступность ML сервиса
func (s *MLService) HealthCheck() error {
	resp, err := s.client.Get(s.baseURL + "/health")
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("ML service unhealthy: status %d", resp.StatusCode)
	}

	return nil
}