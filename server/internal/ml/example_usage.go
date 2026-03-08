package ml

// This file provides example usage of the ML Classifier Client
// It is not meant to be executed, but serves as documentation

/*
Example 1: Basic ML classification with confidence-based assignment

	import (
		"context"
		"fmt"
		"log"
		"outfitstyle/server/internal/ml"
	)

	func classifyItem() {
		// Initialize the ML classifier client
		// The ML service should be running at the specified URL
		client := ml.NewClassifierClient("http://localhost:8001")

		// Check if ML service is available
		ctx := context.Background()
		if err := client.HealthCheck(ctx); err != nil {
			log.Printf("ML service unavailable: %v", err)
			// Fall back to configuration-based mapping
			return
		}

		// Prepare classification request
		req := &ml.ClassifyRequest{
			Name:        "Blue Denim Jacket",
			Subcategory: "unknown-type",
			Materials:   []string{"denim", "cotton"},
			Style:       "casual",
		}

		// Classify the item
		resp, err := client.ClassifyItem(ctx, req)
		if err != nil {
			log.Printf("Classification failed: %v", err)
			// Fall back to default category
			return
		}

		fmt.Printf("Predicted category: %s\n", resp.Category)
		fmt.Printf("Confidence: %.2f\n", resp.Confidence)

		// Apply confidence-based assignment logic
		fallbackCategory := "upper"
		result := ml.AssignCategoryWithConfidence(resp.Category, resp.Confidence, fallbackCategory)

		fmt.Printf("Final category: %s\n", result.Category)
		fmt.Printf("Classification source: %s\n", result.Source)
	}

Example 2: Classification with automatic fallback handling

	func classifyWithFa
sult.Confidence)
		fmt.Printf("Source: %s\n", result.Source)

		// Handle different classification sources
		switch result.Source {
		case ml.ClassificationSourceMLAuto:
			fmt.Println("High confidence ML classification - auto-assigned")
		case ml.ClassificationSourceMLFlagged:
			fmt.Println("Medium confidence ML classification - flagged for review")
		case ml.ClassificationSourceMapping:
			fmt.Println("Used fallback category (ML unavailable or low confidence)")
		}
	}

Example 3: Integration with category mapper

	import (
		"context"
		"outfitstyle/server/internal/catalog"
		"outfitstyle/server/internal/ml"
	)

	func integrateWithMapper() {
		// Initialize ML client
		mlClient := ml.NewClassifierClient("http://localhost:8001")

		// Initialize category mapper
		mapper, err := catalog.NewCategoryMapper("config/category_mapping.json", nil)
		if err != nil {
			log.Fatalf("Failed to create mapper: %v", err)
		}

		// For items with unknown subcategories, use ML classification
		item := &catalog.ClothingItem{
			Name:        "Stylish Cardigan",
			Subcategory: "cardigan",
			Materials:   []string{"wool", "acrylic"},
			Style:       "smart-casual",
		}

		// First try configuration-based mapping
		category, err := mapper.MapCategory("", item.Subcategory)
		if err != nil {
			log.Printf("Mapping failed: %v", err)
		}

		// If subcategory is unmapped, use ML classification
		unmappedSubcats := mapper.GetUnmappedSubcategories()
		isUnmapped := false
		for _, subcat := range unmappedSubcats {
			if subcat == item.Subcategory {
				isUnmapped = true
				break
			}
		}

		if isUnmapped {
			// Use ML classification for unknown subcategory
			mlReq := &ml.ClassifyRequest{
				Name:        item.Name,
				Subcategory: item.Subcategory,
				Materials:   item.Materials,
				Style:       item.Style,
			}

			result := ml.ClassifyWithFallback(context.Background(), mlClient, mlReq, category)
			category = result.Category

			log.Printf("ML classified '%s' as '%s' (confidence: %.2f, source: %s)",
				item.Name, result.Category, result.Confidence, result.Source)
		}
	}

Example 4: Confidence thresholds explained

	// Requirement 3.3: confidence > 0.8 → auto-assign (ml_auto)
	result1 := ml.AssignCategoryWithConfidence("outerwear", 0.85, "upper")
	// result1.Category = "outerwear"
	// result1.Source = "ml_auto"
	// Item is automatically assigned to the ML-predicted category

	// Requirement 3.4: confidence 0.5-0.8 → flag for review (ml_flagged)
	result2 := ml.AssignCategoryWithConfidence("footwear", 0.65, "upper")
	// result2.Category = "footwear"
	// result2.Source = "ml_flagged"
	// Item is assigned to ML category but flagged for manual review

	// Requirement 3.5: confidence < 0.5 → use fallback (mapping)
	result3 := ml.AssignCategoryWithConfidence("accessory", 0.3, "upper")
	// result3.Category = "upper" (fallback)
	// result3.Source = "mapping"
	// ML confidence too low, use fallback category instead

Example 5: Validation and error handling

	func validateClassification() {
		client := ml.NewClassifierClient("http://localhost:8001")

		req := &ml.ClassifyRequest{
			Name:        "Test Item",
			Subcategory: "test",
			Materials:   []string{"cotton"},
			Style:       "casual",
		}

		resp, err := client.ClassifyItem(context.Background(), req)
		if err != nil {
			// Handle various error cases:
			// - ML service unavailable (connection timeout)
			// - Service returns 5xx error
			// - Invalid response format
			// - Confidence score out of range
			// - Invalid category in response
			log.Printf("Classification error: %v", err)
			return
		}

		// Create assignment result
		result := &ml.AssignmentResult{
			Category:   resp.Category,
			Confidence: resp.Confidence,
			Source:     ml.ClassificationSourceMLAuto,
		}

		// Validate the result
		if err := ml.ValidateAssignmentResult(result); err != nil {
			log.Printf("Invalid assignment result: %v", err)
			return
		}

		// Result is valid, proceed with assignment
		fmt.Printf("Valid classification: %s (%.2f)\n", result.Category, result.Confidence)
	}

Example 6: Performance considerations

	// Requirement 8.2: Classification must complete within 50ms
	// The HTTP client is configured with a 50ms timeout

	func performanceExample() {
		client := ml.NewClassifierClient("http://localhost:8001")

		// The client will timeout after 50ms
		ctx := context.Background()
		req := &ml.ClassifyRequest{
			Name:        "Test Item",
			Subcategory: "test",
			Materials:   []string{"cotton"},
			Style:       "casual",
		}

		// If the ML service takes longer than 50ms, an error is returned
		_, err := client.ClassifyItem(ctx, req)
		if err != nil {
			// Timeout error - fall back to configuration-based mapping
			log.Printf("ML classification timeout: %v", err)
		}
	}
*/
