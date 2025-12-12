package translation

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/go-redis/redis/v8"
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
	FolderID    string   `json:"folderId"`
	TargetLang  string   `json:"targetLanguageCode"`
	Texts       []string `json:"texts"`
	SourceLang  string   `json:"sourceLanguageCode"`
}

// TranslationResponse represents a response from Yandex Translate API
type TranslationResponse struct {
	Translations []struct {
		TargetText string `json:"text"`
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

// Translate translates text with Redis caching and Yandex API fallback
func (ts *TranslationService) Translate(ctx context.Context, text, sourceLang, targetLang string) (string, error) {
	cacheKey := fmt.Sprintf("translation:%s:%s:%s", sourceLang, targetLang, text)
	
	// Try to get translation from cache first
	cached, err := ts.redisClient.Get(ctx, cacheKey).Result()
	if err == nil {
		log.Printf("Cache hit for translation: %s -> %s", text, cached)
		return cached, nil
	}
	
	log.Printf("Cache miss for translation: %s", text)
	
	// Use built-in translation if available
	builtin := ts.getBuiltinTranslation(text, sourceLang, targetLang)
	if builtin != "" {
		// Cache the result
		ts.redisClient.Set(ctx, cacheKey, builtin, ts.cacheTTL)
		return builtin, nil
	}
	
	// Fallback to Yandex Translate API
	translated, err := ts.translateViaYandex(ctx, text, sourceLang, targetLang)
	if err != nil {
		log.Printf("Yandex Translate API error: %v", err)
		// Return original text if translation fails
		return text, nil
	}
	
	// Cache the result
	ts.redisClient.Set(ctx, cacheKey, translated, ts.cacheTTL)
	
	return translated, nil
}

// TranslateSlice translates multiple texts at once
func (ts *TranslationService) TranslateSlice(ctx context.Context, texts []string, sourceLang, targetLang string) ([]string, error) {
	results := make([]string, len(texts))
	
	for i, text := range texts {
		translated, err := ts.Translate(ctx, text, sourceLang, targetLang)
		if err != nil {
			log.Printf("Error translating '%s': %v", text, err)
			results[i] = text // Fallback to original text
		} else {
			results[i] = translated
		}
	}
	
	return results, nil
}

// getBuiltinTranslation provides built-in translations for common terms
func (ts *TranslationService) getBuiltinTranslation(text, sourceLang, targetLang string) string {
	if sourceLang == targetLang {
		return text
	}
	
	// Common clothing terms translations (English to Russian as example)
	enRuMap := map[string]string{
		// Categories
		"outerwear": "верхняя одежда",
		"upper":     "верх",
		"lower":     "низ",
		"footwear":  "обувь",
		"accessory": "аксессуар",
		
		// Subcategories
		"tshirt":      "футболка",
		"shirt":       "рубашка",
		"hoodie":      "худи",
		"sweater":     "свитер",
		"pants":       "брюки",
		"jeans":       "джинсы",
		"shorts":      "шорты",
		"skirt":       "юбка",
		"coat":        "пальто",
		"jacket":      "куртка",
		"sneakers":    "кроссовки",
		"boots":       "ботинки",
		"sandals":     "сандалии",
		"hat":         "шляпа",
		"scarf":       "шарф",
		"gloves":      "перчатки",
		"bag":         "сумка",
		"umbrella":    "зонтик",
		
		// Styles
		"casual":        "повседневный",
		"business":      "деловой",
		"formal":        "формальный",
		"sport":         "спортивный",
		"street":        "уличный",
		"classic":       "классический",
		"smart_casual":  "умный кэжуал",
		"outdoor":       "походный",
		
		// Colors
		"black":  "черный",
		"white":  "белый",
		"red":    "красный",
		"blue":   "синий",
		"green":  "зеленый",
		"yellow": "желтый",
		"purple": "фиолетовый",
		"pink":   "розовый",
		
		// Seasons
		"winter": "зима",
		"spring": "весна",
		"summer": "лето",
		"autumn": "осень",
		"fall":   "осень",
		
		// Materials
		"cotton":   "хлопок",
		"wool":     "шерсть",
		"polyester": "полиэстер",
		"denim":    "джинсовка",
		"leather":  "кожа",
		"silk":     "шелк",
		"linen":    "лен",
	}
	
	// Common Russian to English translations
	ruEnMap := map[string]string{
		// Categories
		"верхняя одежда": "outerwear",
		"верх":           "upper", 
		"низ":            "lower",
		"обувь":          "footwear",
		"аксессуар":      "accessory",
		
		// Subcategories
		"футболка": "tshirt",
		"рубашка":  "shirt", 
		"худи":     "hoodie",
		"свитер":   "sweater",
		"брюки":    "pants",
		"джинсы":   "jeans",
		"шорты":    "shorts", 
		"юбка":     "skirt",
		"пальто":   "coat",
		"куртка":   "jacket",
		"кроссовки": "sneakers",
		"ботинки":  "boots",
		"сандалии": "sandals",
		"шляпа":    "hat",
		"шарф":     "scarf",
		"перчатки": "gloves",
		"сумка":    "bag",
		"зонтик":   "umbrella",
		
		// Styles
		"повседневный":    "casual",
		"деловой":         "business",
		"формальный":      "formal", 
		"спортивный":      "sport",
		"уличный":         "street",
		"классический":    "classic",
		"умный кэжуал":    "smart_casual",
		"походный":        "outdoor",
	}
	
	// Select appropriate map based on languages
	var translationMap map[string]string
	if sourceLang == "en" && targetLang == "ru" {
		translationMap = enRuMap
	} else if sourceLang == "ru" && targetLang == "en" {
		translationMap = ruEnMap
	} else {
		// For other language pairs, return empty string to trigger API call
		return ""
	}
	
	if translation, exists := translationMap[strings.ToLower(text)]; exists {
		return translation
	}
	
	return ""
}

// translateViaYandex calls Yandex Translate API
func (ts *TranslationService) translateViaYandex(ctx context.Context, text, sourceLang, targetLang string) (string, error) {
	apiURL := "https://translate.api.cloud.yandex.net/translate/v2/translate"
	
	requestBody := TranslationRequest{
		FolderID:   "", // Folder ID if needed
		TargetLang: targetLang,
		Texts:      []string{text},
		SourceLang: sourceLang,
	}
	
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		return "", fmt.Errorf("failed to marshal translation request: %w", err)
	}
	
	req, err := http.NewRequestWithContext(ctx, "POST", apiURL, strings.NewReader(string(jsonData)))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}
	
	req.Header.Set("Authorization", "Api-Key "+ts.yandexAPIKey)
	req.Header.Set("Content-Type", "application/json")
	
	resp, err := ts.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to make request: %w", err)
	}
	defer resp.Body.Close()
	
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("Yandex Translate API returned status %d", resp.StatusCode)
	}
	
	var apiResp TranslationResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return "", fmt.Errorf("failed to decode response: %w", err)
	}
	
	if len(apiResp.Translations) == 0 {
		return "", fmt.Errorf("no translations returned")
	}
	
	return apiResp.Translations[0].TargetText, nil
}

// GetSupportedLanguages returns a list of supported languages
func (ts *TranslationService) GetSupportedLanguages(ctx context.Context) []string {
	// For Yandex Translate API, most common languages are supported
	return []string{"ru", "en", "de", "fr", "es", "it", "pt", "zh", "ja", "ko", "ar", "tr"}
}