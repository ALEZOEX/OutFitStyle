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

// categoryMapper is the concrete implementation of CategoryMapper
type categoryMapper struct {
	mu               sync.RWMutex
	config           *CategoryMappingConfig
	configPath       string
	unmappedSubcats  map[string]bool
	hardcodedDefault *CategoryMappingConfig
}

// NewCategoryMapper creates a new CategoryMapper instance
func NewCategoryMapper(configPath string) (CategoryMapper, error) {
	mapper := &categoryMapper{
		configPath:      configPath,
		unmappedSubcats: make(map[string]bool),
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
// This is a placeholder implementation - will be integrated with ML service later
func (m *categoryMapper) MapCategoryWithML(ctx context.Context, item *ClothingItem) (category string, confidence float64, err error) {
	// For now, just use the regular mapping
	// This will be implemented in Task 10-11 when ML classifier is added
	mappedCategory, mapErr := m.MapCategory("", item.Subcategory)
	if mapErr != nil {
		return "", 0, mapErr
	}
	return mappedCategory, 0, nil
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
