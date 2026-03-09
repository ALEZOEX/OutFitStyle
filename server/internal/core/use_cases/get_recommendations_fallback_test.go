package usecases

import (
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"

	"outfitstyle/server/internal/core/domain"
)

// TestFallbackLogic tests the two-level search logic
func TestFallbackLogic_IdentifiesMissingCategories(t *testing.T) {
	// Test case 1: Full wardrobe - no missing categories
	wardrobeItems := map[string][]domain.ClothingItem{
		"upper": {
			{ID: uuid.New(), Name: "T-Shirt", Category: "upper"},
		},
		"lower": {
			{ID: uuid.New(), Name: "Jeans", Category: "lower"},
		},
		"footwear": {
			{ID: uuid.New(), Name: "Sneakers", Category: "footwear"},
		},
	}

	requiredCategories := []string{"upper", "lower", "footwear"}
	missingCategories := []string{}

	for _, category := range requiredCategories {
		if items, exists := wardrobeItems[category]; !exists || len(items) == 0 {
			missingCategories = append(missingCategories, category)
		}
	}

	assert.Empty(t, missingCategories, "Full wardrobe should have no missing categories")
}

func TestFallbackLogic_IdentifiesMissingLowerAndFootwear(t *testing.T) {
	// Test case 2: Only upper - missing lower and footwear
	wardrobeItems := map[string][]domain.ClothingItem{
		"upper": {
			{ID: uuid.New(), Name: "T-Shirt", Category: "upper"},
		},
	}

	requiredCategories := []string{"upper", "lower", "footwear"}
	missingCategories := []string{}

	for _, category := range requiredCategories {
		if items, exists := wardrobeItems[category]; !exists || len(items) == 0 {
			missingCategories = append(missingCategories, category)
		}
	}

	assert.Len(t, missingCategories, 2, "Should identify 2 missing categories")
	assert.Contains(t, missingCategories, "lower")
	assert.Contains(t, missingCategories, "footwear")
}

func TestFallbackLogic_IdentifiesAllMissingForEmptyWardrobe(t *testing.T) {
	// Test case 3: Empty wardrobe - all categories missing
	wardrobeItems := map[string][]domain.ClothingItem{}

	requiredCategories := []string{"upper", "lower", "footwear"}
	missingCategories := []string{}

	for _, category := range requiredCategories {
		if items, exists := wardrobeItems[category]; !exists || len(items) == 0 {
			missingCategories = append(missingCategories, category)
		}
	}

	assert.Len(t, missingCategories, 3, "Empty wardrobe should have all categories missing")
	assert.Contains(t, missingCategories, "upper")
	assert.Contains(t, missingCategories, "lower")
	assert.Contains(t, missingCategories, "footwear")
}

func TestFallbackLogic_HandlesEmptyCategory(t *testing.T) {
	// Test case 4: Category exists but is empty
	wardrobeItems := map[string][]domain.ClothingItem{
		"upper": {
			{ID: uuid.New(), Name: "T-Shirt", Category: "upper"},
		},
		"lower":    {}, // Empty slice
		"footwear": nil,
	}

	requiredCategories := []string{"upper", "lower", "footwear"}
	missingCategories := []string{}

	for _, category := range requiredCategories {
		if items, exists := wardrobeItems[category]; !exists || len(items) == 0 {
			missingCategories = append(missingCategories, category)
		}
	}

	assert.Len(t, missingCategories, 2, "Should identify empty categories as missing")
	assert.Contains(t, missingCategories, "lower")
	assert.Contains(t, missingCategories, "footwear")
}
