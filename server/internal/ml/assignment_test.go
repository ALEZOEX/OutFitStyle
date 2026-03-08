package ml

import (
	"testing"
)

func TestAssignCategoryWithConfidence_HighConfidence(t *testing.T) {
	result := AssignCategoryWithConfidence("upper", 0.85, "lower")

	if result.Category != "upper" {
		t.Errorf("Expected category 'upper', got '%s'", result.Category)
	}
	if result.Confidence != 0.85 {
		t.Errorf("Expected confidence 0.85, got %f", result.Confidence)
	}
	if result.Source != ClassificationSourceMLAuto {
		t.Errorf("Expected source 'ml_auto', got '%s'", result.Source)
	}
}

func TestAssignCategoryWithConfidence_MediumConfidence(t *testing.T) {
	result := AssignCategoryWithConfidence("footwear", 0.65, "upper")

	if result.Category != "footwear" {
		t.Errorf("Expected category 'footwear', got '%s'", result.Category)
	}
	if result.Confidence != 0.65 {
		t.Errorf("Expected confidence 0.65, got %f", result.Confidence)
	}
	if result.Source != ClassificationSourceMLFlagged {
		t.Errorf("Expected source 'ml_flagged', got '%s'", result.Source)
	}
}

func TestAssignCategoryWithConfidence_LowConfidence(t *testing.T) {
	result := AssignCategoryWithConfidence("outerwear", 0.3, "upper")

	if result.Category != "upper" {
		t.Errorf("Expected fallback category 'upper', got '%s'", result.Category)
	}
	if result.Confidence != 0 {
		t.Errorf("Expected confidence 0, got %f", result.Confidence)
	}
	if result.Source != ClassificationSourceMapping {
		t.Errorf("Expected source 'mapping', got '%s'", result.Source)
	}
}

func TestAssignCategoryWithConfidence_BoundaryHighConfidence(t *testing.T) {
	// Test boundary at 0.8 (should be flagged, not auto)
	result := AssignCategoryWithConfidence("lower", 0.8, "upper")

	if result.Source != ClassificationSourceMLFlagged {
		t.Errorf("Expected source 'ml_flagged' for confidence 0.8, got '%s'", result.Source)
	}
}

func TestAssignCategoryWithConfidence_BoundaryLowConfidence(t *testing.T) {
	// Test boundary at 0.5 (should be flagged, not fallback)
	result := AssignCategoryWithConfidence("accessory", 0.5, "upper")

	if result.Source != ClassificationSourceMLFlagged {
		t.Errorf("Expected source 'ml_flagged' for confidence 0.5, got '%s'", result.Source)
	}
}

func TestValidateAssignmentResult_Valid(t *testing.T) {
	result := &AssignmentResult{
		Category:   "upper",
		Confidence: 0.9,
		Source:     ClassificationSourceMLAuto,
	}

	err := ValidateAssignmentResult(result)
	if err != nil {
		t.Errorf("Expected valid result, got error: %v", err)
	}
}

func TestValidateAssignmentResult_InvalidCategory(t *testing.T) {
	result := &AssignmentResult{
		Category:   "invalid",
		Confidence: 0.9,
		Source:     ClassificationSourceMLAuto,
	}

	err := ValidateAssignmentResult(result)
	if err == nil {
		t.Error("Expected error for invalid category, got nil")
	}
}

func TestValidateAssignmentResult_InvalidConfidence(t *testing.T) {
	result := &AssignmentResult{
		Category:   "upper",
		Confidence: 1.5,
		Source:     ClassificationSourceMLAuto,
	}

	err := ValidateAssignmentResult(result)
	if err == nil {
		t.Error("Expected error for confidence > 1, got nil")
	}
}

func TestValidateAssignmentResult_NegativeConfidence(t *testing.T) {
	result := &AssignmentResult{
		Category:   "upper",
		Confidence: -0.1,
		Source:     ClassificationSourceMLAuto,
	}

	err := ValidateAssignmentResult(result)
	if err == nil {
		t.Error("Expected error for negative confidence, got nil")
	}
}

func TestValidateAssignmentResult_NilResult(t *testing.T) {
	err := ValidateAssignmentResult(nil)
	if err == nil {
		t.Error("Expected error for nil result, got nil")
	}
}
