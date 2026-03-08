package catalog

import "time"

// ValidationReport represents the validation results from an import batch
type ValidationReport struct {
	Timestamp         time.Time      `json:"timestamp"`
	TotalItems        int            `json:"total_items"`
	UnknownSubcats    map[string]int `json:"unknown_subcategories"` // subcategory -> count
	FallbackCount     int            `json:"fallback_count"`
	FallbackPercent   float64        `json:"fallback_percent"`
	CategoryDist      map[string]int `json:"category_distribution"` // category -> count
	MLClassified      int            `json:"ml_classified"`
	MLHighConfidence  int            `json:"ml_high_confidence"`  // confidence > 0.8
	MLLowConfidence   int            `json:"ml_low_confidence"`   // confidence 0.5-0.8
	Errors            []string       `json:"errors,omitempty"`
	Warnings          []string       `json:"warnings,omitempty"`
}
