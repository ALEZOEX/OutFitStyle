package catalog

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// ImportValidator defines the interface for validating import batches
type ImportValidator interface {
	// ValidateBatch validates a batch of items during import
	ValidateBatch(ctx context.Context, items []*ClothingItem) *ValidationReport

	// GenerateReport creates a validation report file
	GenerateReport(report *ValidationReport, outputPath string) error
}

// importValidator is the concrete implementation of ImportValidator
type importValidator struct {
	mapper CategoryMapper
}

// NewImportValidator creates a new ImportValidator instance
func NewImportValidator(mapper CategoryMapper) ImportValidator {
	return &importValidator{
		mapper: mapper,
	}
}

// ValidateBatch validates a batch of items during import
func (v *importValidator) ValidateBatch(ctx context.Context, items []*ClothingItem) *ValidationReport {
	report := &ValidationReport{
		Timestamp:      time.Now(),
		TotalItems:     len(items),
		UnknownSubcats: make(map[string]int),
		CategoryDist:   make(map[string]int),
		Errors:         []string{},
		Warnings:       []string{},
	}

	// Handle empty batch
	if len(items) == 0 {
		return report
	}

	// Track which subcategories we've already warned about in this batch
	warnedSubcats := make(map[string]bool)

	// Process each item
	for _, item := range items {
		if item == nil {
			continue
		}

		// Map the category - this will log warnings for unknown subcategories
		mappedCategory, err := v.mapper.MapCategory("", item.Subcategory)
		if err != nil {
			report.Errors = append(report.Errors, fmt.Sprintf("Error mapping item '%s': %v", item.Name, err))
			continue
		}

		// Update category distribution
		report.CategoryDist[mappedCategory]++
	}

	// After processing all items, get the list of unmapped subcategories
	// The mapper tracks these internally when MapCategory is called
	unmappedSubcats := v.mapper.GetUnmappedSubcategories()
	unmappedSet := make(map[string]bool)
	for _, subcat := range unmappedSubcats {
		unmappedSet[subcat] = true
	}

	// Now count how many items in this batch used unmapped subcategories
	for _, item := range items {
		if item == nil {
			continue
		}

		normalizedSubcat := strings.ToLower(strings.TrimSpace(item.Subcategory))

		if unmappedSet[normalizedSubcat] {
			report.UnknownSubcats[normalizedSubcat]++
			report.FallbackCount++

			// Add warning for each unique unknown subcategory (only once per subcategory)
			if !warnedSubcats[normalizedSubcat] {
				report.Warnings = append(report.Warnings,
					fmt.Sprintf("Unknown subcategory '%s' detected in item '%s'", item.Subcategory, item.Name))
				warnedSubcats[normalizedSubcat] = true
			}
		}
	}

	// Calculate fallback percentage
	if report.TotalItems > 0 {
		report.FallbackPercent = (float64(report.FallbackCount) / float64(report.TotalItems)) * 100.0
	}

	// Check fallback threshold (>10%)
	if report.FallbackPercent > 10.0 {
		errorMsg := fmt.Sprintf("ALERT: Fallback category usage (%.2f%%) exceeds 10%% threshold", report.FallbackPercent)
		report.Errors = append(report.Errors, errorMsg)
		// Log error-level message to stderr
		fmt.Fprintf(os.Stderr, "ERROR: %s\n", errorMsg)
	}

	return report
}

// GenerateReport creates a validation report file
func (v *importValidator) GenerateReport(report *ValidationReport, outputPath string) error {
	// Ensure the output directory exists
	// G301: Используем 0750 вместо 0755 для безопасности
	dir := filepath.Dir(outputPath)
	if err := os.MkdirAll(dir, 0750); err != nil {
		return fmt.Errorf("failed to create output directory: %w", err)
	}

	// Marshal report to JSON with indentation
	data, err := json.MarshalIndent(report, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal report to JSON: %w", err)
	}

	// Write to file
	// G306: Отчёт валидации должен быть доступен только владельцу
	if err := os.WriteFile(outputPath, data, 0600); err != nil {
		return fmt.Errorf("failed to write report file: %w", err)
	}

	return nil
}

// GenerateReportPath creates a timestamped report file path
// baseDir should be the directory where reports are stored (e.g., "server/validation_reports")
func GenerateReportPath(baseDir string, timestamp time.Time) string {
	filename := fmt.Sprintf("import_%s.json", timestamp.Format("20060102_150405"))
	return filepath.Join(baseDir, filename)
}
