package catalog

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func TestCategoryMapper_MapCategory(t *testing.T) {
	tests := []struct {
		name          string
		subcategory   string
		wantCategory  string
		wantErr       bool
	}{
		// Upper category mappings (Requirements 2.2)
		{"t-shirt maps to upper", "t-shirt", "upper", false},
		{"shirt maps to upper", "shirt", "upper", false},
		{"blouse maps to upper", "blouse", "upper", false},
		{"sweater maps to upper", "sweater", "upper", false},
		{"hoodie maps to upper", "hoodie", "upper", false},
		{"vest maps to upper", "vest", "upper", false},
		{"top maps to upper", "top", "upper", false},

		// Lower category mappings (Requirements 2.3)
		{"jeans maps to lower", "jeans", "lower", false},
		{"pants maps to lower", "pants", "lower", false},
		{"trousers maps to lower", "trousers", "lower", false},
		{"shorts maps to lower", "shorts", "lower", false},
		{"skirt maps to lower", "skirt", "lower", false},
		{"leggings maps to lower", "leggings", "lower", false},
		{"trackpants maps to lower", "trackpants", "lower", false},

		// Outerwear category mappings (Requirements 2.4)
		{"jacket maps to outerwear", "jacket", "outerwear", false},
		{"coat maps to outerwear", "coat", "outerwear", false},
		{"parka maps to outerwear", "parka", "outerwear", false},
		{"raincoat maps to outerwear", "raincoat", "outerwear", false},
		{"puffer maps to outerwear", "puffer", "outerwear", false},
		{"blazer maps to outerwear", "blazer", "outerwear", false},
		{"windbreaker maps to outerwear", "windbreaker", "outerwear", false},

		// Footwear category mappings (Requirements 2.5)
		{"shoes maps to footwear", "shoes", "footwear", false},
		{"sneakers maps to footwear", "sneakers", "footwear", false},
		{"boots maps to footwear", "boots", "footwear", false},
		{"sandals maps to footwear", "sandals", "footwear", false},
		{"loafers maps to footwear", "loafers", "footwear", false},
		{"oxford maps to footwear", "oxford", "footwear", false},
		{"slippers maps to footwear", "slippers", "footwear", false},
		{"heels maps to footwear", "heels", "footwear", false},

		// Accessory category mappings (Requirements 2.6)
		{"hat maps to accessory", "hat", "accessory", false},
		{"cap maps to accessory", "cap", "accessory", false},
		{"scarf maps to accessory", "scarf", "accessory", false},
		{"gloves maps to accessory", "gloves", "accessory", false},
		{"belt maps to accessory", "belt", "accessory", false},
		{"bag maps to accessory", "bag", "accessory", false},
		{"watch maps to accessory", "watch", "accessory", false},
		{"sunglasses maps to accessory", "sunglasses", "accessory", false},
		{"jewelry maps to accessory", "jewelry", "accessory", false},

		// Case-insensitive matching
		{"T-Shirt maps to upper", "T-Shirt", "upper", false},
		{"JEANS maps to lower", "JEANS", "lower", false},
		{"Jacket maps to outerwear", "Jacket", "outerwear", false},
		{"SNEAKERS maps to footwear", "SNEAKERS", "footwear", false},
		{"Hat maps to accessory", "Hat", "accessory", false},

		// Whitespace handling
		{"  shirt  maps to upper", "  shirt  ", "upper", false},
		{"  pants  maps to lower", "  pants  ", "lower", false},

		// Unknown subcategory - should use fallback (Requirements 2.7)
		{"unknown subcategory uses fallback", "unknown-item", "upper", false},
		{"another unknown uses fallback", "mystery-clothing", "upper", false},
	}

	// Create a temporary config file for testing
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
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
	}

	configData, err := json.Marshal(config)
	if err != nil {
		t.Fatalf("Failed to marshal config: %v", err)
	}

	if err := os.WriteFile(configPath, configData, 0644); err != nil {
		t.Fatalf("Failed to write config file: %v", err)
	}

	mapper, err := NewCategoryMapper(configPath, nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := mapper.MapCategory("", tt.subcategory)
			if (err != nil) != tt.wantErr {
				t.Errorf("MapCategory() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if got != tt.wantCategory {
				t.Errorf("MapCategory() = %v, want %v", got, tt.wantCategory)
			}
		})
	}
}

func TestCategoryMapper_GetUnmappedSubcategories(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{
			"shirt": "upper",
			"jeans": "lower",
		},
	}

	configData, err := json.Marshal(config)
	if err != nil {
		t.Fatalf("Failed to marshal config: %v", err)
	}

	if err := os.WriteFile(configPath, configData, 0644); err != nil {
		t.Fatalf("Failed to write config file: %v", err)
	}

	mapper, err := NewCategoryMapper(configPath, nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	// Map some known and unknown subcategories
	mapper.MapCategory("", "shirt")  // known
	mapper.MapCategory("", "jeans")  // known
	mapper.MapCategory("", "unknown1") // unknown
	mapper.MapCategory("", "unknown2") // unknown
	mapper.MapCategory("", "unknown1") // duplicate unknown

	unmapped := mapper.GetUnmappedSubcategories()

	// Should have exactly 2 unmapped subcategories
	if len(unmapped) != 2 {
		t.Errorf("GetUnmappedSubcategories() returned %d items, want 2", len(unmapped))
	}

	// Check that both unknown subcategories are in the list
	unmappedMap := make(map[string]bool)
	for _, subcat := range unmapped {
		unmappedMap[subcat] = true
	}

	if !unmappedMap["unknown1"] {
		t.Error("GetUnmappedSubcategories() missing 'unknown1'")
	}
	if !unmappedMap["unknown2"] {
		t.Error("GetUnmappedSubcategories() missing 'unknown2'")
	}
}

func TestCategoryMapper_InvalidConfiguration(t *testing.T) {
	tests := []struct {
		name       string
		config     interface{}
		shouldFail bool
	}{
		{
			name: "valid configuration",
			config: CategoryMappingConfig{
				Version:  "1.0.0",
				Fallback: "upper",
				Mappings: map[string]string{"shirt": "upper"},
			},
			shouldFail: false,
		},
		{
			name: "invalid JSON",
			config: "invalid json {{{",
			shouldFail: true,
		},
		{
			name: "missing version",
			config: map[string]interface{}{
				"fallback": "upper",
				"mappings": map[string]string{"shirt": "upper"},
			},
			shouldFail: true,
		},
		{
			name: "missing fallback",
			config: map[string]interface{}{
				"version":  "1.0.0",
				"mappings": map[string]string{"shirt": "upper"},
			},
			shouldFail: true,
		},
		{
			name: "invalid fallback category",
			config: CategoryMappingConfig{
				Version:  "1.0.0",
				Fallback: "invalid-category",
				Mappings: map[string]string{"shirt": "upper"},
			},
			shouldFail: true,
		},
		{
			name: "invalid mapping category",
			config: CategoryMappingConfig{
				Version:  "1.0.0",
				Fallback: "upper",
				Mappings: map[string]string{"shirt": "invalid-category"},
			},
			shouldFail: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tmpDir := t.TempDir()
			configPath := filepath.Join(tmpDir, "category_mapping.json")

			var configData []byte
			var err error

			if str, ok := tt.config.(string); ok {
				configData = []byte(str)
			} else {
				configData, err = json.Marshal(tt.config)
				if err != nil {
					t.Fatalf("Failed to marshal config: %v", err)
				}
			}

			if err := os.WriteFile(configPath, configData, 0644); err != nil {
				t.Fatalf("Failed to write config file: %v", err)
			}

			mapper, err := NewCategoryMapper(configPath, nil)
			if err != nil {
				t.Fatalf("Failed to create category mapper: %v", err)
			}

			// If configuration is invalid, mapper should use hardcoded defaults
			// and still be able to map categories
			category, err := mapper.MapCategory("", "shirt")
			if err != nil {
				t.Errorf("MapCategory() failed: %v", err)
			}

			// With hardcoded defaults, shirt should map to upper
			if !tt.shouldFail && category != "upper" {
				t.Errorf("MapCategory() = %v, want upper", category)
			}
		})
	}
}

func TestCategoryMapper_ReloadConfig(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	// Initial configuration
	initialConfig := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{
			"shirt": "upper",
		},
	}

	configData, err := json.Marshal(initialConfig)
	if err != nil {
		t.Fatalf("Failed to marshal config: %v", err)
	}

	if err := os.WriteFile(configPath, configData, 0644); err != nil {
		t.Fatalf("Failed to write config file: %v", err)
	}

	mapper, err := NewCategoryMapper(configPath, nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	// Verify initial mapping
	category, err := mapper.MapCategory("", "shirt")
	if err != nil || category != "upper" {
		t.Errorf("Initial MapCategory() = %v, %v; want upper, nil", category, err)
	}

	// Unknown subcategory should use fallback
	category, err = mapper.MapCategory("", "jacket")
	if err != nil || category != "upper" {
		t.Errorf("Initial MapCategory() for unknown = %v, %v; want upper, nil", category, err)
	}

	// Update configuration
	updatedConfig := CategoryMappingConfig{
		Version:  "2.0.0",
		Fallback: "lower",
		Mappings: map[string]string{
			"shirt":  "upper",
			"jacket": "outerwear",
		},
	}

	configData, err = json.Marshal(updatedConfig)
	if err != nil {
		t.Fatalf("Failed to marshal updated config: %v", err)
	}

	if err := os.WriteFile(configPath, configData, 0644); err != nil {
		t.Fatalf("Failed to write updated config file: %v", err)
	}

	// Reload configuration
	if err := mapper.ReloadConfig(); err != nil {
		t.Fatalf("ReloadConfig() failed: %v", err)
	}

	// Verify updated mapping
	category, err = mapper.MapCategory("", "jacket")
	if err != nil || category != "outerwear" {
		t.Errorf("After reload MapCategory() = %v, %v; want outerwear, nil", category, err)
	}

	// Verify fallback changed
	category, err = mapper.MapCategory("", "unknown-item")
	if err != nil || category != "lower" {
		t.Errorf("After reload MapCategory() for unknown = %v, %v; want lower, nil", category, err)
	}
}

func TestCategoryMapper_ReloadConfig_InvalidConfig(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	// Initial valid configuration
	initialConfig := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{
			"shirt": "upper",
		},
	}

	configData, err := json.Marshal(initialConfig)
	if err != nil {
		t.Fatalf("Failed to marshal config: %v", err)
	}

	if err := os.WriteFile(configPath, configData, 0644); err != nil {
		t.Fatalf("Failed to write config file: %v", err)
	}

	mapper, err := NewCategoryMapper(configPath, nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	// Write invalid configuration
	invalidConfig := CategoryMappingConfig{
		Version:  "2.0.0",
		Fallback: "invalid-category",
		Mappings: map[string]string{
			"shirt": "upper",
		},
	}

	configData, err = json.Marshal(invalidConfig)
	if err != nil {
		t.Fatalf("Failed to marshal invalid config: %v", err)
	}

	if err := os.WriteFile(configPath, configData, 0644); err != nil {
		t.Fatalf("Failed to write invalid config file: %v", err)
	}

	// Reload should fail and keep previous configuration
	if err := mapper.ReloadConfig(); err == nil {
		t.Error("ReloadConfig() should have failed with invalid configuration")
	}

	// Verify previous configuration is still active
	category, err := mapper.MapCategory("", "shirt")
	if err != nil || category != "upper" {
		t.Errorf("After failed reload MapCategory() = %v, %v; want upper, nil", category, err)
	}
}

func TestCategoryMapper_MapCategoryWithML(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")

	config := CategoryMappingConfig{
		Version:  "1.0.0",
		Fallback: "upper",
		Mappings: map[string]string{
			"shirt": "upper",
		},
	}

	configData, err := json.Marshal(config)
	if err != nil {
		t.Fatalf("Failed to marshal config: %v", err)
	}

	if err := os.WriteFile(configPath, configData, 0644); err != nil {
		t.Fatalf("Failed to write config file: %v", err)
	}

	mapper, err := NewCategoryMapper(configPath, nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	// Test ML classification (placeholder implementation for now)
	item := &ClothingItem{
		Name:        "Test Shirt",
		Subcategory: "shirt",
		Materials:   []string{"cotton"},
		Style:       "casual",
	}

	category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
	if err != nil {
		t.Errorf("MapCategoryWithML() error = %v", err)
	}

	if category != "upper" {
		t.Errorf("MapCategoryWithML() category = %v, want upper", category)
	}

	// Placeholder implementation returns 0 confidence
	if confidence != 0 {
		t.Errorf("MapCategoryWithML() confidence = %v, want 0", confidence)
	}
}
