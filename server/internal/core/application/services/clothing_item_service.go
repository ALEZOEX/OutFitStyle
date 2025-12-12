package service

import (
	"context"
	"fmt"
	"log"
	"math"
	"outfit-style-rec/contracts"
	"outfit-style-rec/server/internal/core/application/planner"
	"outfit-style-rec/server/internal/core/domain"
	"outfit-style-rec/server/internal/core/repo"
	"outfit-style-rec/server/internal/infrastructure/clients"
	"outfit-style-rec/server/internal/infrastructure/services"
	"time"
)

type ClothingItemService struct {
	clothingRepo repo.ClothingItemRepository
	specRepo     repo.SubcategorySpecRepository
	mlClient     *clients.Client
	outfitPlanner *planner.OutfitPlanner
	translationService *translation.ServiceInterface
}

func NewClothingItemService(clothingRepo repo.ClothingItemRepository, specRepo repo.SubcategorySpecRepository, mlClient *clients.Client, translationService *translation.ServiceInterface) *ClothingItemService {
	return &ClothingItemService{
		clothingRepo: clothingRepo,
		specRepo:     specRepo,
		mlClient:     mlClient,
		translationService: translationService,
		outfitPlanner: planner.NewOutfitPlanner(specRepo),
	}
}

func (s *ClothingItemService) GetClothingItemsByPlan(ctx context.Context, category string, subcategories []string, warmthMin int16, temperature int16, limit int) ([]domain.ClothingItem, error) {
	return s.clothingRepo.FindCandidatesByPlan(ctx, category, subcategories, warmthMin, temperature, limit)
}

func (s *ClothingItemService) BulkInsertItems(ctx context.Context, items []domain.ClothingItem) error {
	return s.clothingRepo.BulkInsert(ctx, items)
}

func (s *ClothingItemService) GetItemByID(ctx context.Context, id int64) (domain.ClothingItem, error) {
	return s.clothingRepo.GetByID(ctx, id)
}

// Planner-related methods

func (s *ClothingItemService) GetSubcategorySpecs(ctx context.Context) ([]domain.SubcategorySpec, error) {
	return s.specRepo.ListAll(ctx)
}

func (s *ClothingItemService) GetSubcategorySpec(ctx context.Context, category, subcategory string) (domain.SubcategorySpec, error) {
	return s.specRepo.Get(ctx, category, subcategory)
}

// GenerateOutfitPlan uses the planner logic to recommend appropriate subcategories for given weather conditions
func (s *ClothingItemService) GenerateOutfitPlan(ctx context.Context, temperature float64, weatherCondition string, userPreferences map[string]interface{}) (*planner.OutfitPlan, error) {
	return s.outfitPlanner.GeneratePlan(ctx, temperature, weatherCondition, userPreferences)
}

// GetItemsForPlan retrieves clothing items that match the plan requirements
func (s *ClothingItemService) GetItemsForPlan(ctx context.Context, plan *planner.OutfitPlan, temperature int16, limitPerCategory int) (map[string][]domain.ClothingItem, error) {
	result := make(map[string][]domain.ClothingItem)

	for category, specs := range plan.Plan {
		// Extract subcategories for this category
		var subcategories []string
		for _, spec := range specs {
			subcategories = append(subcategories, spec.Subcategory)
		}

		// Find items matching the plan
		// Use the minimum warmth requirement from the specs
		var minWarmth int16 = 10 // Start with max possible value
		for _, spec := range specs {
			if spec.WarmthMin < minWarmth {
				minWarmth = spec.WarmthMin
			}
		}

		items, err := s.clothingRepo.FindCandidatesByPlan(ctx, category, subcategories, minWarmth, temperature, limitPerCategory)
		if err != nil {
			log.Printf("Error finding candidates for category %s: %v", category, err)
			continue
		}

		// Pre-filter candidates based on temperature and basic compatibility
		filteredItems := s.preFilterCandidates(ctx, items, float64(temperature))

		result[category] = filteredItems
	}

	return result, nil
}

// preFilterCandidates filters items based on basic compatibility before ML ranking
func (s *ClothingItemService) preFilterCandidates(ctx context.Context, candidates []domain.ClothingItem, temperature float64) []domain.ClothingItem {
	var filtered []domain.ClothingItem

	for _, item := range candidates {
		// Basic temperature compatibility check
		if float64(item.MinTemp) > temperature || float64(item.MaxTemp) < temperature {
			continue
		}

		// Additional pre-filtering could be added here:
		// - formality matching (if context provides target formality)
		// - style matching (if context provides target style)
		// - seasonal appropriateness

		filtered = append(filtered, item)
	}

	return filtered
}

func (s *ClothingItemService) CreateClothingItem(ctx context.Context, item domain.ClothingItem) error {
	// Validate the item before inserting
	if err := s.validateClothingItem(item); err != nil {
		return fmt.Errorf("validation error: %w", err)
	}
	
	// Set default values if not provided
	if item.CreatedAt.IsZero() {
		item.CreatedAt = time.Now()
	}
	
	return s.clothingRepo.BulkInsert(ctx, []domain.ClothingItem{item})
}

func (s *ClothingItemService) validateClothingItem(item domain.ClothingItem) error {
	// Check if the subcategory exists in specs
	_, err := s.specRepo.Get(context.Background(), item.Category, item.Subcategory)
	if err != nil {
		return fmt.Errorf("invalid category/subcategory combination: %s/%s", item.Category, item.Subcategory)
	}

	// Validate temperature range
	if item.MinTemp > item.MaxTemp {
		return fmt.Errorf("min_temp (%d) cannot be greater than max_temp (%d)", item.MinTemp, item.MaxTemp)
	}

	// Validate other constraints
	if item.Warmth < 1 || item.Warmth > 10 {
		return fmt.Errorf("warmth_level must be between 1 and 10, got %d", item.Warmth)
	}

	if item.Formality < 1 || item.Formality > 5 {
		return fmt.Errorf("formality_level must be between 1 and 5, got %d", item.Formality)
	}

	return nil
}

// TranslateItem translates a clothing item to the target language
func (s *ClothingItemService) TranslateItem(ctx context.Context, item domain.ClothingItem, targetLang string) (domain.ClothingItem, error) {
	if s.translationService == nil {
		// If no translation service is configured, return item as-is
		return item, nil
	}

	// Define source language (assuming all items are stored in English)
	sourceLang := "en"

	// Translate all translatable fields
	var err error

	if item.Name != "" {
		item.TranslatedName, err = s.translationService.Translate(ctx, item.Name, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate item name: %v", err)
		}
	}

	if item.Category != "" {
		item.TranslatedCategory, err = s.translationService.Translate(ctx, item.Category, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate category: %v", err)
		}
	}

	if item.Subcategory != "" {
		item.TranslatedSubcategory, err = s.translationService.Translate(ctx, item.Subcategory, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate subcategory: %v", err)
		}
	}

	if item.Style != "" {
		item.TranslatedStyle, err = s.translationService.Translate(ctx, item.Style, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate style: %v", err)
		}
	}

	if item.Usage != "" {
		item.TranslatedUsage, err = s.translationService.Translate(ctx, item.Usage, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate usage: %v", err)
		}
	}

	if item.Season != "" {
		item.TranslatedSeason, err = s.translationService.Translate(ctx, item.Season, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate season: %v", err)
		}
	}

	if item.BaseColour != "" {
		item.TranslatedBaseColour, err = s.translationService.Translate(ctx, item.BaseColour, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate base colour: %v", err)
		}
	}

	if item.Fit != "" {
		item.TranslatedFit, err = s.translationService.Translate(ctx, item.Fit, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate fit: %v", err)
		}
	}

	if item.Pattern != "" {
		item.TranslatedPattern, err = s.translationService.Translate(ctx, item.Pattern, sourceLang, targetLang)
		if err != nil {
			log.Printf("Failed to translate pattern: %v", err)
		}
	}

	return item, nil
}

// TranslateItems translates a slice of clothing items
func (s *ClothingItemService) TranslateItems(ctx context.Context, items []domain.ClothingItem, targetLang string) ([]domain.ClothingItem, error) {
	if s.translationService == nil {
		// If no translation service is configured, return items as-is
		return items, nil
	}

	translatedItems := make([]domain.ClothingItem, len(items))
	for i, item := range items {
		translatedItem, err := s.TranslateItem(ctx, item, targetLang)
		if err != nil {
			log.Printf("Failed to translate item %d: %v", i, err)
			// Still add the item with original text
			translatedItems[i] = item
		} else {
			translatedItems[i] = translatedItem
		}
	}

	return translatedItems, nil
}

// RankCandidatesByML ranks a set of clothing items using the ML service
func (s *ClothingItemService) RankCandidatesByML(ctx context.Context, contextData *contracts.MLContext, candidates []domain.ClothingItem) ([]domain.ClothingItem, error) {
	// Convert domain.ClothingItem to contracts.MLItem
	mlCandidates := make([]contracts.MLItem, len(candidates))
	for i, item := range candidates {
		mlCandidates[i] = s.domainToMLItem(item)
	}

	// Create request
	req := &contracts.MLRankRequest{
		Context:    *contextData,
		Candidates: mlCandidates,
	}

	// Call ML service with retry logic and time budget (0 time spent initially)
	resp, err := s.mlClient.RankCandidatesWithRetry(ctx, req, 1, 0) // 1 retry max, 0 time spent initially
	if err != nil {
		log.Printf("ML ranking failed: %v, falling back to rule-based", err)
		// Fallback to rule-based ranking
		return s.ruleBasedRank(candidates, contextData), nil
	}

	if resp.Error != nil {
		log.Printf("ML service returned error: %s, falling back to rule-based", *resp.Error)
		return s.ruleBasedRank(candidates, contextData), nil
	}

	// Create map of scores for easy lookup
	scoreMap := make(map[int64]float64)
	for _, rankedItem := range resp.Ranked {
		scoreMap[rankedItem.ID] = rankedItem.Score
	}

	// Sort candidates by ML scores
	sortedCandidates := make([]domain.ClothingItem, len(candidates))
	copy(sortedCandidates, candidates)

	// Create slice of indices with scores for sorting
	type scoredItem struct {
		item  domain.ClothingItem
		score float64
		index int  // to maintain stable sort
	}

	scoredItems := make([]scoredItem, len(candidates))
	for i, item := range candidates {
		scoredItems[i] = scoredItem{
			item:  item,
			score: scoreMap[item.ID],
			index: i,
		}
	}

	// Sort by score (descending), maintaining original order for equal scores
	for i := 0; i < len(scoredItems); i++ {
		for j := i + 1; j < len(scoredItems); j++ {
			if scoredItems[i].score < scoredItems[j].score {
				scoredItems[i], scoredItems[j] = scoredItems[j], scoredItems[i]
			} else if scoredItems[i].score == scoredItems[j].score && scoredItems[i].index > scoredItems[j].index {
				// Maintain original order for equal scores
				scoredItems[i], scoredItems[j] = scoredItems[j], scoredItems[i]
			}
		}
	}

	// Extract sorted items
	for i, scoredItem := range scoredItems {
		sortedCandidates[i] = scoredItem.item
	}

	return sortedCandidates, nil
}

// domainToMLItem converts a domain.ClothingItem to contracts.MLItem
func (s *ClothingItemService) domainToMLItem(item domain.ClothingItem) contracts.MLItem {
	sourcePriority := 0
	switch item.Source {
	case "user":
		sourcePriority = 3
	case "manual":
		sourcePriority = 2
	case "partner":
		sourcePriority = 1
	case "synthetic":
		sourcePriority = 0
	}

	return contracts.MLItem{
		ID:             item.ID,
		Name:           item.Name,
		Category:       item.Category,
		Subcategory:    item.Subcategory,
		Gender:         item.Gender,
		Style:          item.Style,
		Usage:          item.Usage,
		Season:         item.Season,
		BaseColour:     item.BaseColour,
		Formality:      item.Formality,
		Warmth:         item.Warmth,
		MinTemp:        item.MinTemp,
		MaxTemp:        item.MaxTemp,
		Materials:      item.Materials,
		Fit:            item.Fit,
		Pattern:        item.Pattern,
		IconEmoji:      item.IconEmoji,
		Source:         item.Source,
		IsOwned:        item.IsOwned,
		CreatedAt:      item.CreatedAt.Format(time.RFC3339),
		SourcePriority: sourcePriority,
	}
}

// ruleBasedRank provides a fallback ranking when ML service is unavailable
func (s *ClothingItemService) ruleBasedRank(candidates []domain.ClothingItem, contextData *contracts.MLContext) []domain.ClothingItem {
	// Implement rule-based ranking logic:
	// 1. Prioritize by source (user > manual > partner > synthetic)
	// 2. Prioritize by temperature suitability
	// 3. Prioritize by formality match

	sortedCandidates := make([]domain.ClothingItem, len(candidates))
	copy(sortedCandidates, candidates)

	// Sort with rule-based prioritization
	for i := 0; i < len(sortedCandidates); i++ {
		for j := i + 1; j < len(sortedCandidates); j++ {
			if s.calculateRuleScore(sortedCandidates[i], contextData) < s.calculateRuleScore(sortedCandidates[j], contextData) {
				sortedCandidates[i], sortedCandidates[j] = sortedCandidates[j], sortedCandidates[i]
			}
		}
	}

	return sortedCandidates
}

// calculateRuleScore calculates a rule-based score for ranking
func (s *ClothingItemService) calculateRuleScore(item domain.ClothingItem, contextData *contracts.MLContext) float64 {
	score := 0.0

	// Source priority
	switch item.Source {
	case "user":
		score += 100
	case "manual":
		score += 80
	case "partner":
		score += 60
	case "synthetic":
		score += 40
	}

	// Temperature appropriateness
	temp := contextData.Weather.Temperature
	if float64(item.MinTemp) <= temp && float64(item.MaxTemp) >= temp {
		score += 50 // Base score for temperature match
		// Bonus for closer match to center of range
		midPoint := float64(item.MinTemp+item.MaxTemp) / 2.0
		tempDiff := math.Abs(midPoint - temp)
		score += math.Max(0, 20-tempDiff) // Up to 20 bonus points
	} else {
		score -= 30 // Penalty for temperature mismatch
	}

	// Warmth appropriateness for cold weather
	if temp < 10 { // Cold weather
		warmthFactor := float64(item.Warmth) / 10.0
		score += warmthFactor * 30
	}

	// Formality match (simplified)
	if item.Category == "top" || item.Category == "upper" {
		// Add formality matching logic here if needed
	}

	return score
}