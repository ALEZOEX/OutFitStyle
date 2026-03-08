package catalog

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
	"time"
)

func TestValidateBatch_EmptyBatch(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)
	report := validator.ValidateBatch(context.Background(), []*ClothingItem{})

	if report.TotalItems != 0 {
		t.Errorf("Expected TotalItems=0, got %d", report.TotalItems)
	}
	if report.FallbackCount != 0 {
		t.Errorf("Expected FallbackCount=0, got %d", report.FallbackCount)
	}
	if report.FallbackPercent != 0 {
		t.Errorf("Expected FallbackPercent=0, got %.2f", report.FallbackPercent)
	}
}

func TestValidateBatch_KnownSubcategories(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)
	items := []*ClothingItem{
		{Name: "Blue Jeans", Subcategory: "jeans"},
		{Name: "White T-Shirt", Subcategory: "t-shirt"},
		{Name: "Winter Jacket", Subcategory: "jacket"},
		{Name: "Running Shoes", Subcategory: "sneakers"},
	}

	report := validator.ValidateBatch(context.Background(), items)

	if report.TotalItems != 4 {
		t.Errorf("Expected TotalItems=4, got %d", report.TotalItems)
	}
	if report.FallbackCount != 0 {
		t.Errorf("Expected FallbackCount=0 for known subcategories, got %d", report.FallbackCount)
	}
	if report.FallbackPercent != 0 {
		t.Errorf("Expected FallbackPercent=0, got %.2f", report.FallbackPercent)
	}

	// Check category distribution
	expectedDist := map[string]int{
		"lower":     1, // jeans
		"upper":     1, // t-shirt
		"outerwear": 1, // jacket
		"footwear":  1, // sneakers
	}

	for category, expectedCount := range expectedDist {
		if report.CategoryDist[category] != expectedCount {
			t.Errorf("Expected %d items in category '%s', got %d", expectedCount, category, report.CategoryDist[category])
		}
	}
}

func TestValidateBatch_UnknownSubcategories(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)
	items := []*ClothingItem{
		{Name: "Item 1", Subcategory: "unknown1"},
		{Name: "Item 2", Subcategory: "unknown2"},
		{Name: "Item 3", Subcategory: "jeans"}, // known
	}

	report := validator.ValidateBatch(context.Background(), items)

	if report.TotalItems != 3 {
		t.Errorf("Expected TotalItems=3, got %d", report.TotalItems)
	}
	if report.FallbackCount != 2 {
		t.Errorf("Expected FallbackCount=2, got %d", report.FallbackCount)
	}

	expectedPercent := (2.0 / 3.0) * 100.0
	if report.FallbackPercent < expectedPercent-0.1 || report.FallbackPercent > expectedPercent+0.1 {
		t.Errorf("Expected FallbackPercent=%.2f, got %.2f", expectedPercent, report.FallbackPercent)
	}

	// Check unknown subcategories are tracked
	if len(report.UnknownSubcats) != 2 {
		t.Errorf("Expected 2 unknown subcategories, got %d", len(report.UnknownSubcats))
	}
}

func TestValidateBatch_FallbackThresholdExactly10Percent(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)

	// Create 10 items: 1 unknown (10%), 9 known
	items := make([]*ClothingItem, 10)
	items[0] = &ClothingItem{Name: "Unknown Item", Subcategory: "unknown_subcat"}
	for i := 1; i < 10; i++ {
		items[i] = &ClothingItem{Name: "Known Item", Subcategory: "jeans"}
	}

	report := validator.ValidateBatch(context.Background(), items)

	if report.FallbackPercent != 10.0 {
		t.Errorf("Expected FallbackPercent=10.0, got %.2f", report.FallbackPercent)
	}

	// At exactly 10%, should NOT trigger error
	hasThresholdError := false
	for _, err := range report.Errors {
		if len(err) > 0 && (len(report.Errors) > 0) {
			hasThresholdError = true
			break
		}
	}
	if hasThresholdError {
		t.Errorf("Expected no threshold error at exactly 10%%, but got errors: %v", report.Errors)
	}
}

func TestValidateBatch_FallbackThresholdExceeded(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)

	// Create 10 items: 2 unknown (20%), 8 known
	items := make([]*ClothingItem, 10)
	items[0] = &ClothingItem{Name: "Unknown Item 1", Subcategory: "unknown1"}
	items[1] = &ClothingItem{Name: "Unknown Item 2", Subcategory: "unknown2"}
	for i := 2; i < 10; i++ {
		items[i] = &ClothingItem{Name: "Known Item", Subcategory: "jeans"}
	}

	report := validator.ValidateBatch(context.Background(), items)

	if report.FallbackPercent != 20.0 {
		t.Errorf("Expected FallbackPercent=20.0, got %.2f", report.FallbackPercent)
	}

	// Should trigger error when >10%
	hasThresholdError := false
	for _, errMsg := range report.Errors {
		if len(errMsg) > 0 {
			hasThresholdError = true
			break
		}
	}
	if !hasThresholdError {
		t.Errorf("Expected threshold error when fallback >10%%, but got no errors")
	}
}

func TestValidateBatch_FallbackThresholdJustOver10Percent(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)

	// Create 9 items: 1 unknown (11.11%), 8 known
	items := make([]*ClothingItem, 9)
	items[0] = &ClothingItem{Name: "Unknown Item", Subcategory: "unknown_subcat"}
	for i := 1; i < 9; i++ {
		items[i] = &ClothingItem{Name: "Known Item", Subcategory: "jeans"}
	}

	report := validator.ValidateBatch(context.Background(), items)

	expectedPercent := (1.0 / 9.0) * 100.0 // ~11.11%
	if report.FallbackPercent < expectedPercent-0.1 || report.FallbackPercent > expectedPercent+0.1 {
		t.Errorf("Expected FallbackPercent=%.2f, got %.2f", expectedPercent, report.FallbackPercent)
	}

	// Should trigger error when >10%
	hasThresholdError := false
	for _, errMsg := range report.Errors {
		if len(errMsg) > 0 {
			hasThresholdError = true
			break
		}
	}
	if !hasThresholdError {
		t.Errorf("Expected threshold error when fallback >10%%, but got no errors")
	}
}

func TestGenerateReport_CreatesFile(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)

	// Create a test report
	report := &ValidationReport{
		Timestamp:       time.Now(),
		TotalItems:      10,
		UnknownSubcats:  map[string]int{"unknown1": 2},
		FallbackCount:   2,
		FallbackPercent: 20.0,
		CategoryDist:    map[string]int{"upper": 8, "lower": 2},
		Errors:          []string{"Test error"},
		Warnings:        []string{"Test warning"},
	}

	// Create temp directory for test
	tempDir := t.TempDir()
	reportPath := filepath.Join(tempDir, "test_report.json")

	// Generate report
	err = validator.GenerateReport(report, reportPath)
	if err != nil {
		t.Fatalf("Failed to generate report: %v", err)
	}

	// Verify file exists
	if _, err := os.Stat(reportPath); os.IsNotExist(err) {
		t.Errorf("Report file was not created at %s", reportPath)
	}

	// Verify file content
	data, err := os.ReadFile(reportPath)
	if err != nil {
		t.Fatalf("Failed to read report file: %v", err)
	}

	var loadedReport ValidationReport
	if err := json.Unmarshal(data, &loadedReport); err != nil {
		t.Fatalf("Failed to parse report JSON: %v", err)
	}

	if loadedReport.TotalItems != report.TotalItems {
		t.Errorf("Expected TotalItems=%d, got %d", report.TotalItems, loadedReport.TotalItems)
	}
	if loadedReport.FallbackCount != report.FallbackCount {
		t.Errorf("Expected FallbackCount=%d, got %d", report.FallbackCount, loadedReport.FallbackCount)
	}
}

func TestGenerateReportPath_FormatsCorrectly(t *testing.T) {
	baseDir := "server/validation_reports"
	timestamp := time.Date(2024, 1, 15, 14, 30, 45, 0, time.UTC)

	path := GenerateReportPath(baseDir, timestamp)

	expectedFilename := "import_20240115_143045.json"
	expectedPath := filepath.Join(baseDir, expectedFilename)

	if path != expectedPath {
		t.Errorf("Expected path=%s, got %s", expectedPath, path)
	}
}

func TestValidateBatch_CaseInsensitiveSubcategory(t *testing.T) {
	mapper, err := NewCategoryMapper("../../config/category_mapping.json", nil)
	if err != nil {
		t.Fatalf("Failed to create category mapper: %v", err)
	}

	validator := NewImportValidator(mapper)
	items := []*ClothingItem{
		{Name: "Item 1", Subcategory: "JEANS"},
		{Name: "Item 2", Subcategory: "T-Shirt"},
		{Name: "Item 3", Subcategory: "JaCkEt"},
	}

	report := validator.ValidateBatch(context.Background(), items)

	if report.FallbackCount != 0 {
		t.Errorf("Expected FallbackCount=0 for case variations of known subcategories, got %d", report.FallbackCount)
	}

	// All should be mapped correctly
	if report.CategoryDist["lower"] != 1 {
		t.Errorf("Expected 1 lower item (JEANS), got %d", report.CategoryDist["lower"])
	}
	if report.CategoryDist["upper"] != 1 {
		t.Errorf("Expected 1 upper item (T-Shirt), got %d", report.CategoryDist["upper"])
	}
	if report.CategoryDist["outerwear"] != 1 {
		t.Errorf("Expected 1 outerwear item (JaCkEt), got %d", report.CategoryDist["outerwear"])
	}
}
