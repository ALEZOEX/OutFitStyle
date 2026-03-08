package ml

import (
	"context"
	"fmt"
)

// ClassificationSource represents the source of category classification
type ClassificationSource string

const (
	// ClassificationSourceMapping indicates category was assigned via configuration mapping
	ClassificationSourceMapping ClassificationSource = "mapping"
	// ClassificationSourceMLAuto indicates category was auto-assigned by ML with high confidence
	ClassificationSourceMLAuto ClassificationSource = "ml_auto"
	// ClassificationSourceMLFlagged indicates category was assigned by ML but flagged for review
	ClassificationSourceMLFlagged ClassificationSource = "ml_flagged"
	// ClassificationSourceManual indicates category was manually corrected
	ClassificationSourceManual ClassificationSource = "manual"
)

// AssignmentResult represents the result of category assignment with confidence
type AssignmentResult struct {
	Category   string
	Confidence float64
	Source     ClassificationSource
}

// AssignCategoryWithConfidence applies confidence-based logic to determine category assignment
// Requirements 3.3, 3.4, 3.5:
// - confidence > 0.8: auto-assign (ml_auto)
// - confidence 0.5-0.8: flag for review (ml_flagged)
// - confidence < 0.5: use fallback category (mapping)
func AssignCategoryWithConfidence(mlCategory string, confidence float64, fallbackCategory string) *AssignmentResult {
	// High confidence: auto-assign
	if confidence > 0.8 {
		return &AssignmentResult{
			Category:   mlCategory,
			Confidence: confidence,
			Source:     ClassificationSourceMLAuto,
		}
	}

	// Medium confidence: flag for review
	if confidence >= 0.5 && confidence <= 0.8 {
		return &AssignmentResult{
			Category:   mlCategory,
			Confidence: confidence,
			Source:     ClassificationSourceMLFlagged,
		}
	}

	// Low confidence: use fallback
	return &AssignmentResult{
		Category:   fallbackCategory,
		Confidence: 0,
		Source:     ClassificationSourceMapping,
	}
}

// ClassifyWithFallback attempts ML classification and falls back to default category on failure
// This function handles ML service unavailability gracefully
func ClassifyWithFallback(ctx context.Context, client ClassifierClient, req *ClassifyRequest, fallbackCategory string) *AssignmentResult {
	// Attempt ML classification
	resp, err := client.ClassifyItem(ctx, req)
	if err != nil {
		// ML service unavailable or error - use fallback
		return &AssignmentResult{
			Category:   fallbackCategory,
			Confidence: 0,
			Source:     ClassificationSourceMapping,
		}
	}

	// Apply confidence-based assignment logic
	return AssignCategoryWithConfidence(resp.Category, resp.Confidence, fallbackCategory)
}

// ValidateAssignmentResult validates that an assignment result is valid
func ValidateAssignmentResult(result *AssignmentResult) error {
	if result == nil {
		return fmt.Errorf("assignment result cannot be nil")
	}

	// Validate category
	if !isValidCategory(result.Category) {
		return fmt.Errorf("invalid category: %s", result.Category)
	}

	// Validate confidence range
	if result.Confidence < 0 || result.Confidence > 1 {
		return fmt.Errorf("confidence must be between 0 and 1, got: %f", result.Confidence)
	}

	// Validate source
	validSources := map[ClassificationSource]bool{
		ClassificationSourceMapping:   true,
		ClassificationSourceMLAuto:    true,
		ClassificationSourceMLFlagged: true,
		ClassificationSourceManual:    true,
	}
	if !validSources[result.Source] {
		return fmt.Errorf("invalid classification source: %s", result.Source)
	}

	return nil
}
