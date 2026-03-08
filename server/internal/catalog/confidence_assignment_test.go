package catalog

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"testing"
)

type testCase struct {
	name                         string
	mlConfidence                 float64
	mlCategory                   string
	mlAvailable                  bool
	expectedCategory             string
	expectedConfidence           float64
	expectedClassificationSource string
	description                  string
}

// TestConfidenceBasedCategoryAssignment verifies that the confidence-based
// category assignment logic works correctly for all confidence ranges.
// This test validates Requirements 3.3, 3.4, and 3.5.
func TestConfidenceBasedCategoryAssignment(t *testing.T) {
	tests := []testCase{
		{
			name:                         "High confidence auto-assignment",
			mlConfidence:                 0.95,
			mlCategory:                   "outerwear",
			mlAvailable:                  true,
			expectedCategory:             "outerwear",
			expectedConfidence:           0.95,
			expectedClassificationSource: "ml_auto",
			description:                  "When confidence > 0.8, should auto-assign with ml_auto source",
		},
		{
			name:                         "Threshold confidence auto-assignment",
			mlConfidence:                 0.81,
			mlCategory:                   "footwear",
			mlAvailable:                  true,
			expectedCategory:             "footwear",
			expectedConfidence:           0.81,
			expectedClassificationSource: "ml_auto",
			description:                  "When confidence = 0.81 (just above 0.8), should auto-assign with ml_auto source",
		},
		{
			name:                         "Upper medium confidence flagging",
			mlConfidence:                 0.79,
			mlCategory:                   "lower",
			mlAvailable:                  true,
			expectedCategory:             "lower",
			expectedConfidence:           0.79,
			expectedClassificationSource: "ml_flagged",
			description:                  "When confidence = 0.79 (0.5-0.8 range), should flag for review with ml_flagged source",
		},
		{
			name:                         "Mid-range confidence flagging",
			mlConfidence:                 0.65,
			mlCategory:                   "accessory",
			mlAvailable:                  true,
			expectedCategory:             "accessory",
			expectedConfidence:           0.65,
			expectedClassificationSource: "ml_flagged",
			description:                  "When confidence = 0.65 (0.5-0.8 range), should flag for review with ml_flagged source",
		},
		{
			name:                         "Lower threshold confidence flagging",
			mlConfidence:                 0.50,
			mlCategory:                   "upper",
			mlAvailable:                  true,
			expectedCategory:             "upper",
			expectedConfidence:           0.50,
			expectedClassificationSource: "ml_flagged",
			description:                  "When confidence = 0.50 (exactly at threshold), should flag for review with ml_flagged source",
		},
		{
			name:                         "Low confidence fallback",
			mlConfidence:                 0.49,
			mlCategory:                   "outerwear",
			mlAvailable:                  true,
			expectedCategory:             "upper",
			expectedConfidence:           0.0,
			expectedClassificationSource: "mapping",
			description:                  "When confidence < 0.5, should use fallback category with mapping source",
		},
		{
			name:                         "Very low confidence fallback",
			mlConfidence:                 0.10,
			mlCategory:                   "footwear",
			mlAvailable:                  true,
			expectedCategory:             "upper",
			expectedConfidence:           0.0,
			expectedClassificationSource: "mapping",
			description:                  "When confidence = 0.10, should use fallback category with mapping source",
		},
		{
			name:                         "ML unavailable fallback",
			mlConfidence:                 0.0,
			mlCategory:                   "",
			mlAvailable:                  false,
			expectedCategory:             "upper",
			expectedConfidence:           0.0,
			expectedClassificationSource: "mapping",
			description:                  "When ML service unavailable, should use fallback category with mapping source",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tmpDir := t.TempDir()
			configPath := filepath.Join(tmpDir, "category_mapping.json")
			configContent := `{
				"version": "1.0.0",
				"fallback": "upper",
				"mappings": {
					"t-shirt": "upper",
					"jeans": "lower"
				}
			}`
			if err := os.WriteFile(configPath, []byte(configContent), 0644); err != nil {
				t.Fatalf("Failed to write config file: %v", err)
			}

			var mlClient MLClassifierClient
			if tt.mlAvailable {
				mlClient = &mockMLClient{
					response: &MLClassifyResponse{
						Category:   tt.mlCategory,
						Confidence: tt.mlConfidence,
					},
				}
			}

			mapper, err := NewCategoryMapper(configPath, mlClient)
			if err != nil {
				t.Fatalf("Failed to create category mapper: %v", err)
			}

			item := &ClothingItem{
				Name:        "Test Item",
				Subcategory: "unknown-subcategory",
				Materials:   []string{"cotton"},
				Style:       "casual",
			}

			category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
			if err != nil {
				t.Fatalf("MapCategoryWithML() error = %v", err)
			}

			if category != tt.expectedCategory {
				t.Errorf("%s: got category = %v, want %v", tt.description, category, tt.expectedCategory)
			}

			if confidence != tt.expectedConfidence {
				t.Errorf("%s: got confidence = %v, want %v", tt.description, confidence, tt.expectedConfidence)
			}

			var classificationSource string
			if confidence > 0.8 {
				classificationSource = "ml_auto"
			} else if confidence >= 0.5 {
				classificationSource = "ml_flagged"
			} else {
				classificationSource = "mapping"
			}

			if classificationSource != tt.expectedClassificationSource {
				t.Errorf("%s: got classification_source = %v, want %v", tt.description, classificationSource, tt.expectedClassificationSource)
			}
		})
	}
}

// TestConfidenceBasedAssignmentWithConfigMapping verifies that items with
// known subcategories use config mapping and don't trigger ML classification.
func TestConfidenceBasedAssignmentWithConfigMapping(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "category_mapping.json")
	configContent := `{
		"version": "1.0.0",
		"fallback": "upper",
		"mappings": {
			"t-shirt": "upper",
			"jeans": "lower",
			"jacket": "outerwear"
		}
	}`
	if err := os.WriteFile(configPath, []byte(configContent), 0644); err != nil {
		t.Fatalf("Failed to write config file: %v", err)
	}

	mlClient := &mockMLClient{
		shouldNotBeCalled: true,
	}

	mapper, err := NewCategoryMapper(configPath, mlClient)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	tests := []struct {
		subcategory      string
		expectedCategory string
	}{
		{"t-shirt", "upper"},
		{"jeans", "lower"},
		{"jacket", "outerwear"},
	}

	for _, tt := range tests {
		t.Run(fmt.Sprintf("Config mapping for %s", tt.subcategory), func(t *testing.T) {
			item := &ClothingItem{
				Name:        "Test Item",
				Subcategory: tt.subcategory,
				Materials:   []string{"cotton"},
				Style:       "casual",
			}

			category, confidence, err := mapper.MapCategoryWithML(context.Background(), item)
			if err != nil {
				t.Fatalf("MapCategoryWithML() error = %v", err)
			}

			if category != tt.expectedCategory {
				t.Errorf("got category = %v, want %v", category, tt.expectedCategory)
			}

			if confidence != 0.0 {
				t.Errorf("got confidence = %v, want 0.0 for config mapping", confidence)
			}

			var classificationSource string
			if confidence > 0.8 {
				classificationSource = "ml_auto"
			} else if confidence >= 0.5 {
				classificationSource = "ml_flagged"
			} else {
				classificationSource = "mapping"
			}

			if classificationSource != "mapping" {
				t.Errorf("got classification_source = %v, want mapping", classificationSource)
			}
		})
	}
}
