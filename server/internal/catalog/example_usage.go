package catalog

// This file provides example usage of the Validation System
// It is not meant to be executed, but serves as documentation

/*
Example 1: Basic validation workflow

	// Initialize the category mapper
	mapper, err := NewCategoryMapper("config/category_mapping.json")
	if err != nil {
		log.Fatalf("Failed to create mapper: %v", err)
	}

	// Create the validator
	validator := NewImportValidator(mapper)

	// Prepare a batch of items to validate
	items := []*ClothingItem{
		{Name: "Blue Jeans", Subcategory: "jeans"},
		{Name: "White T-Shirt", Subcategory: "t-shirt"},
		{Name: "Unknown Item", Subcategory: "unknown-type"},
	}

	// Validate the batch
	report := validator.ValidateBatch(context.Background(), items)

	// Check the results
	fmt.Printf("Total items: %d\n", report.TotalItems)
	fmt.Printf("Fallback usage: %.2f%%\n", report.FallbackPercent)
	fmt.Printf("Unknown subcategories: %v\n", report.UnknownSubcats)

	// Generate a report file
	reportPath := GenerateReportPath("validation_reports", report.Timestamp)
	if err := validator.GenerateReport(report, reportPath); err != nil {
		log.Fatalf("Failed to generate report: %v", err)
	}

Example 2: Integration with import pipeline

	func ImportCatalog(filename string) error {
		// Load items from NDJSON file
		items, err := loadItemsFromFile(filename)
		if err != nil {
			return err
		}

		// Initialize mapper and validator
		mapper, _ := NewCategoryMapper("config/category_mapping.json")
		validator := NewImportValidator(mapper)

		// Process in batches
		batchSize := 1000
		for i := 0; i < len(items); i += batchSize {
			end := i + batchSize
			if end > len(items) {
				end = len(items)
			}
			batch := items[i:end]

			// Validate batch
			report := validator.ValidateBatch(context.Background(), batch)

			// Check for critical issues
			if report.FallbackPercent > 10.0 {
				log.Printf("WARNING: High fallback usage in batch: %.2f%%", report.FallbackPercent)
			}

			// Save validation report
			reportPath := GenerateReportPath("validation_reports", report.Timestamp)
			validator.GenerateReport(report, reportPath)

			// Continue with import...
			// insertItemsToDatabase(batch)
		}

		return nil
	}

Example 3: Checking validation report contents

	// After validation, the report contains:
	// - Timestamp: when validation was performed
	// - TotalItems: number of items in the batch
	// - UnknownSubcats: map of unknown subcategory -> count
	// - FallbackCount: total items using fallback category
	// - FallbackPercent: percentage of items using fallback
	// - CategoryDist: distribution of items across categories
	// - MLClassified: count of items classified by ML (future)
	// - MLHighConfidence: count of high-confidence ML classifications (future)
	// - MLLowConfidence: count of low-confidence ML classifications (future)
	// - Errors: list of error messages (e.g., threshold exceeded)
	// - Warnings: list of warning messages (e.g., unknown subcategories)

	if len(report.Errors) > 0 {
		for _, err := range report.Errors {
			log.Printf("ERROR: %s", err)
		}
	}

	if len(report.Warnings) > 0 {
		for _, warning := range report.Warnings {
			log.Printf("WARNING: %s", warning)
		}
	}
*/
