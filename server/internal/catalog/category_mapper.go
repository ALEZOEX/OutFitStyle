package catalog

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"sync"
)

// CategoryMapper defines the interface for mapping subcategories to categories
type CategoryMapper interface {
	// MapCategory maps a subcategory to a category using configuration rules
	MapCategory(category, subcategory string) (string, error)

	// MapCategoryWithML attempts ML classification for unknown subcategories
	MapCategoryWithML(ctx context.Context, item *ClothingItem) (category string, confidence float64, err error)

	// ReloadConfig hot-reloads the mapping configuration
	ReloadConfig() error

	// GetUnmappedSubcategories returns list of subcategories without mappings
	GetUnmappedSubcategories() []string
}

// CategoryMappingConfig represents the JSON configuration structure
type CategoryMappingConfig struct {
	Version  string            `json:"version"`
	Fallback string            `json:"fallback"`
	Mappings map[string]string `json:"mappings"` // subcategory -> category
}

// ClothingItem represents a clothing item for ML classification
type ClothingItem struct {
	Name        string
	Subcategory string
	Materials   []string
	Style       string
}

// MLClassifierClient defines the interface for ML classification service
// This interface is compatible with ml.ClassifierClient from internal/ml package
type MLClassifierClient interface {
	ClassifyItem(ctx context.Context, req *MLClassifyRequest) (*MLClassifyResponse, error)
}

// MLClassifyRequest represents the request payload for classification
type MLClassifyRequest struct {
	Name        string   `json:"name"`
	Subcategory string   `json:"subcategory"`
	Materials   []string `json:"materials"`
	Style       string   `json:"style"`
}

// MLClassifyResponse represents the response from the ML service
type MLClassifyResponse struct {
	Category   string  `json:"category"`
	Confidence float64 `json:"confidence"`
}

// categoryMapper is the concrete implementation of CategoryMapper
type categoryMapper struct {
	mu               sync.RWMutex
	config           *CategoryMappingConfig
	configPath       string
	unmappedSubcats  map[string]bool
	hardcodedDefault *CategoryMappingConfig
	mlClient         MLClassifierClient // ML Classifier Client for unknown subcategories
}

// NewCategoryMapper creates a new CategoryMapper instance
func NewCategoryMapper(configPath string, mlClient MLClassifierClient) (CategoryMapper, error) {
	mapper := &categoryMapper{
		configPath:      configPath,
		unmappedSubcats: make(map[string]bool),
		mlClient:        mlClient,
		hardcodedDefault: &CategoryMappingConfig{
			Version:  "1.0.0-hardcoded",
			Fallback: "upper",
			Mappings: map[string]string{
				"t-shirt":     "upper",
				"shirt":       "upper",
				"blouse":      "upper",
				"sweater":     "upper",
				"hoodie":      "upper",
				"vest":        "upper",
				"top":         "upper",
				"jeans":       "lower",
				"pants":       "lower",
				"trousers":    "lower",
				"shorts":      "lower",
				"skirt":       "lower",
				"leggings":    "lower",
				"trackpants":  "lower",
				"jacket":      "outerwear",
				"coat":        "outerwear",
				"parka":       "outerwear",
				"raincoat":    "outerwear",
				"puffer":      "outerwear",
				"blazer":      "outerwear",
				"windbreaker": "outerwear",
				"shoes":       "footwear",
				"sneakers":    "footwear",
				"boots":       "footwear",
				"sandals":     "footwear",
				"loafers":     "footwear",
				"oxford":      "footwear",
				"slippers":    "footwear",
				"heels":       "footwear",
				"hat":         "accessory",
				"cap":         "accessory",
				"scarf":       "accessory",
				"gloves":      "accessory",
				"belt":        "accessory",
				"bag":         "accessory",
				"watch":       "accessory",
				"sunglasses":  "accessory",
				"jewelry":     "accessory",
			},
		},
	}

	// Try to load configuration from file
	if err := mapper.loadConfig(); err != nil {
		fmt.Fprintf(os.Stderr, "Error loading category mapping config: %v. Using hardcoded defaults.\n", err)
		mapper.config = mapper.hardcodedDefault
	}

	return mapper, nil
}

// loadConfig loads the configuration from the JSON file
func (m *categoryMapper) loadConfig() error {
	data, err := os.ReadFile(m.configPath)
	if err != nil {
		return fmt.Errorf("failed to read config file: %w", err)
	}

	var config CategoryMappingConfig
	if err := json.Unmarshal(data, &config); err != nil {
		return fmt.Errorf("failed to parse config JSON: %w", err)
	}

	// Validate configuration
	if err := m.validateConfig(&config); err != nil {
		return fmt.Errorf("invalid configuration: %w", err)
	}

	m.mu.Lock()
	m.config = &config
	m.mu.Unlock()

	return nil
}

// validateConfig validates the configuration structure and values
func (m *categoryMapper) validateConfig(config *CategoryMappingConfig) error {
	if config.Version == "" {
		return fmt.Errorf("version field is required")
	}

	if config.Fallback == "" {
		return fmt.Errorf("fallback field is required")
	}

	// Validate fallback category
	if !isValidCategory(config.Fallback) {
		return fmt.Errorf("invalid fallback category: %s", config.Fallback)
	}

	// Validate all mapping values
	for subcategory, category := range config.Mappings {
		if !isValidCategory(category) {
			return fmt.Errorf("invalid category '%s' for subcategory '%s'", category, subcategory)
		}
	}

	return nil
}

// isValidCategory checks if a category is one of the allowed values
func isValidCategory(category string) bool {
	validCategories := map[string]bool{
		"outerwear": true,
		"upper":     true,
		"lower":     true,
		"footwear":  true,
		"accessory": true,
	}
	return validCategories[category]
}

// MapCategory maps a subcategory to a category using configuration rules
func (m *categoryMapper) MapCategory(category, subcategory string) (string, error) {
	m.mu.RLock()
	config := m.config
	m.mu.RUnlock()

	// Normalize subcategory to lowercase for case-insensitive matching
	normalizedSubcat := strings.ToLower(strings.TrimSpace(subcategory))

	// Look up in mappings
	if mappedCategory, found := config.Mappings[normalizedSubcat]; found {
		return mappedCategory, nil
	}

	// Track unmapped subcategory
	m.mu.Lock()
	if !m.unmappedSubcats[normalizedSubcat] {
		m.unmappedSubcats[normalizedSubcat] = true
		fmt.Fprintf(os.Stderr, "Warning: Unknown subcategory '%s', using fallback category '%s'\n", subcategory, config.Fallback)
	}
	m.mu.Unlock()

	// Return fallback category
	return config.Fallback, nil
}

// MapCategoryWithML attempts ML classification for unknown subcategories
// Implements fallback chain: config mapping → ML classification → default fallback
func (m *categoryMapper) MapCategoryWithML(ctx context.Context, item *ClothingItem) (category string, confidence float64, err error) {
	// Step 1: Try config-based mapping first
	mappedCategory, mapErr := m.MapCategory("", item.Subcategory)
	if mapErr != nil {
		return "", 0, mapErr
	}

	// Check if the result is the fallback category (indicates unknown subcategory)
	m.mu.RLock()
	fallbackCategory := m.config.Fallback
	m.mu.RUnlock()

	// If config mapping found a specific mapping (not fallback), use it
	normalizedSubcat := strings.ToLower(strings.TrimSpace(item.Subcategory))
	m.mu.RLock()
	_, foundInConfig := m.config.Mappings[normalizedSubcat]
	m.mu.RUnlock()

	if foundInConfig {
		// Config mapping succeeded, return with confidence 0 (config-based)
		return mappedCategory, 0, nil
	}

	// Step 2: Subcategory is unknown, try ML classification if client is available
	if m.mlClient != nil {
		mlReq := &MLClassifyRequest{
			Name:        item.Name,
			Subcategory: item.Subcategory,
			Materials:   item.Materials,
			Style:       item.Style,
		}

		mlResp, mlErr := m.mlClient.ClassifyItem(ctx, mlReq)
		if mlErr != nil {
			// ML service unavailable or error, log and fall back to default
			fmt.Fprintf(os.Stderr, "ML classification failed for item '%s': %v. Using fallback category '%s'\n",
				item.Name, mlErr, fallbackCategory)
			return fallbackCategory, 0, nil
		}

		// ML classification succeeded, check confidence thresholds
		if mlResp.Confidence > 0.8 {
			// High confidence: use ML category with ml_auto source
			return mlResp.Category, mlResp.Confidence, nil
		} else if mlResp.Confidence >= 0.5 {
			// Medium confidence: use ML category but flag for review (ml_flagged source)
			return mlResp.Category, mlResp.Confidence, nil
		} else {
			// Low confidence: fall back to default category
			fmt.Fprintf(os.Stderr, "ML confidence too low (%.3f) for item '%s'. Using fallback category '%s'\n",
				mlResp.Confidence, item.Name, fallbackCategory)
			return fallbackCategory, 0, nil
		}
	}

	// Step 3: ML client not available, use default fallback
	return fallbackCategory, 0, nil
}

// ReloadConfig hot-reloads the mapping configuration
func (m *categoryMapper) ReloadConfig() error {
	// Load new configuration
	data, err := os.ReadFile(m.configPath)
	if err != nil {
		return fmt.Errorf("failed to read config file: %w", err)
	}

	var newConfig CategoryMappingConfig
	if err := json.Unmarshal(data, &newConfig); err != nil {
		return fmt.Errorf("failed to parse config JSON: %w", err)
	}

	// Validate new configuration before applying
	if err := m.validateConfig(&newConfig); err != nil {
		return fmt.Errorf("invalid configuration, keeping previous config: %w", err)
	}

	// Apply new configuration
	m.mu.Lock()
	m.config = &newConfig
	m.mu.Unlock()

	fmt.Printf("Configuration reloaded successfully (version: %s)\n", newConfig.Version)
	return nil
}

// GetUnmappedSubcategories returns list of subcategories without mappings
func (m *categoryMapper) GetUnmappedSubcategories() []string {
	m.mu.RLock()
	defer m.mu.RUnlock()

	unmapped := make([]string, 0, len(m.unmappedSubcats))
	for subcat := range m.unmappedSubcats {
		unmapped = append(unmapped, subcat)
	}
	return unmapped
}
