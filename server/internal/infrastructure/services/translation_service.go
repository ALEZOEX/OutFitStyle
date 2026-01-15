package translation

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"
)

// TranslationService handles translations with Redis caching
type TranslationService struct {
	yandexAPIKey string
	redisClient  *redis.Client
	cacheTTL     time.Duration
	httpClient   *http.Client
}

// TranslationRequest represents a request to Yandex Translate API
type TranslationRequest struct {
	FolderID   string   `json:"folderId"`
	TargetLang string   `json:"targetLanguageCode"`
	Texts      []string `json:"texts"`
	SourceLang string   `json:"sourceLanguageCode"`
}

// TranslationResponse represents a response from Yandex Translate API
type TranslationResponse struct {
	Translations []struct {
		Text string `json:"text"`
	} `json:"translations"`
}

// NewTranslationService creates a new translation service
func NewTranslationService(redisClient *redis.Client, apiKey string) *TranslationService {
	return &TranslationService{
		yandexAPIKey: apiKey,
		redisClient:  redisClient,
		cacheTTL:     24 * time.Hour,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// translateViaYandex translates text using Yandex Translate API
func (ts *TranslationService) translateViaYandex(ctx context.Context, texts []string, targetLang string) ([]string, error) {
	reqBody := TranslationRequest{
		FolderID:   "your-folder-id", // In real implementation, this would come from config
		TargetLang: targetLang,
		Texts:      texts,
		SourceLang: "auto", // Auto-detect source language
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, "POST", "https://translate.api.cloud.yandex.net/translate/v2/translate", strings.NewReader(string(jsonData)))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Authorization", "Api-Key "+ts.yandexAPIKey)
	req.Header.Set("Content-Type", "application/json")

	resp, err := ts.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("yandex translate api returned status %d", resp.StatusCode)
	}

	var apiResp TranslationResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	var translatedTexts []string
	for _, trans := range apiResp.Translations {
		translatedTexts = append(translatedTexts, trans.Text)
	}

	return translatedTexts, nil
}

// TranslateSingle translates a single text to target language
func (ts *TranslationService) TranslateSingle(ctx context.Context, text, targetLang string) (string, error) {
	// Create cache key
	cacheKey := fmt.Sprintf("translate:%s:%s", targetLang, text)

	// Try to get from cache first
	cached, err := ts.redisClient.Get(ctx, cacheKey).Result()
	if err == nil {
		// Cache hit
		return cached, nil
	}

	// Cache miss - translate via Yandex
	translatedTexts, err := ts.translateViaYandex(ctx, []string{text}, targetLang)
	if err != nil {
		return "", err
	}

	if len(translatedTexts) == 0 {
		return "", fmt.Errorf("no translations returned")
	}

	translatedText := translatedTexts[0]

	// Cache the result
	err = ts.redisClient.Set(ctx, cacheKey, translatedText, ts.cacheTTL).Err()
	if err != nil {
		// Log error but continue - cache failure shouldn't break translation
		fmt.Printf("Warning: failed to cache translation: %v\n", err)
	}

	return translatedText, nil
}

// TranslateMultiple translates multiple texts to target language
func (ts *TranslationService) TranslateMultiple(ctx context.Context, texts []string, targetLang string) ([]string, error) {
	// Try to get from cache first
	var results []string
	var remainingTexts []string
	var remainingIndices []int

	for i, text := range texts {
		cacheKey := fmt.Sprintf("translate:%s:%s", targetLang, text)
		cached, err := ts.redisClient.Get(ctx, cacheKey).Result()
		if err == nil {
			// Cache hit
			results = append(results, cached)
		} else {
			// Cache miss
			results = append(results, "") // Placeholder
			remainingTexts = append(remainingTexts, text)
			remainingIndices = append(remainingIndices, i)
		}
	}

	if len(remainingTexts) > 0 {
		// Translate remaining texts via Yandex
		translatedTexts, err := ts.translateViaYandex(ctx, remainingTexts, targetLang)
		if err != nil {
			return nil, err
		}

		if len(translatedTexts) != len(remainingTexts) {
			return nil, fmt.Errorf("mismatch in translation count: expected %d, got %d", len(remainingTexts), len(translatedTexts))
		}

		// Update cache and results
		for i, idx := range remainingIndices {
			translatedText := translatedTexts[i]
			results[idx] = translatedText

			// Cache the result
			cacheKey := fmt.Sprintf("translate:%s:%s", targetLang, remainingTexts[i])
			err = ts.redisClient.Set(ctx, cacheKey, translatedText, ts.cacheTTL).Err()
			if err != nil {
				// Log error but continue - cache failure shouldn't break translation
				fmt.Printf("Warning: failed to cache translation: %v\n", err)
			}
		}
	}

	return results, nil
}

// TranslateToEnglish translates texts to English
func (ts *TranslationService) TranslateToEnglish(ctx context.Context, texts []string) ([]string, error) {
	return ts.TranslateMultiple(ctx, texts, "en")
}

// TranslateToRussian translates texts to Russian
func (ts *TranslationService) TranslateToRussian(ctx context.Context, texts []string) ([]string, error) {
	return ts.TranslateMultiple(ctx, texts, "ru")
}

// TranslateToChinese translates texts to Chinese
func (ts *TranslationService) TranslateToChinese(ctx context.Context, texts []string) ([]string, error) {
	return ts.TranslateMultiple(ctx, texts, "zh")
}

// TranslateToFashionTerms translates fashion-specific terms
func (ts *TranslationService) TranslateToFashionTerms(ctx context.Context, texts []string, targetLang string) ([]string, error) {
	return ts.TranslateMultiple(ctx, texts, targetLang)
}

// GetSupportedLanguages returns a list of supported languages
func (ts *TranslationService) GetSupportedLanguages(ctx context.Context) []string {
	// For Yandex Translate API, most common languages are supported
	return []string{"ru", "en", "de", "fr", "es", "it", "pt", "zh", "ja", "ko", "ar", "tr"}
}

// HealthCheck implements the health.Checker interface
func (s *TranslationService) HealthCheck() error {
	ctx := context.Background()
	err := s.redisClient.Ping(ctx).Err()
	if err != nil {
		return fmt.Errorf("translation service health check failed: %w", err)
	}
	return nil
}

// ServiceInterface defines the interface for translation service
type ServiceInterface interface {
	TranslateSingle(ctx context.Context, text, targetLang string) (string, error)
	TranslateMultiple(ctx context.Context, texts []string, targetLang string) ([]string, error)
	TranslateToEnglish(ctx context.Context, texts []string) ([]string, error)
	TranslateToRussian(ctx context.Context, texts []string) ([]string, error)
	TranslateToChinese(ctx context.Context, texts []string) ([]string, error)
	TranslateToFashionTerms(ctx context.Context, texts []string, targetLang string) ([]string, error)
}
