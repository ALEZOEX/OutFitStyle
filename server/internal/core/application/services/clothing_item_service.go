package services

import (
	"context"
	"fmt"
	"log"
	"math"
	"strings"
	"outfitstyle/server/internal/contracts"
	"outfitstyle/server/internal/core/application/planner"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/repo/clothing"
	mlclient "outfitstyle/server/internal/infrastructure/clients"
	"outfitstyle/server/internal/infrastructure/services"
	"time"
)

type ClothingItemService struct {
	clothingRepo repositories.ClothingItemRepository
	specRepo     clothing.SubcategorySpecRepository
	mlClient     *mlclient.Client
	outfitPlanner *planner.OutfitPlanner
	translationService translation.ServiceInterface
}

func NewClothingItemService(clothingRepo repositories.ClothingItemRepository, specRepo clothing.SubcategorySpecRepository, mlClient *mlclient.Client, translationService translation.ServiceInterface) *ClothingItemService {
	return &ClothingItemService{
		clothingRepo: clothingRepo,
		specRepo:     specRepo,
		mlClient:     mlClient,
		translationService: translationService,
		outfitPlanner: planner.NewOutfitPlanner(specRepo),
	}
}

func (s *ClothingItemService) GetClothingItemsByPlan(ctx context.Context, category string, subcategories []string, warmthMin int16, temperature int16, limit int) ([]domain.ClothingItem, error) {
	items, err := s.clothingRepo.GetAll(ctx)
	if err != nil {
		return nil, err
	}

	// Filter items based on criteria
	var filtered []domain.ClothingItem
	for _, item := range items {
		if item.Category == category {
			// For simplicity, we'll just return all items in category with temperature limits
			if (item.MinTemp == nil || *item.MinTemp <= temperature) && (item.MaxTemp == nil || *item.MaxTemp >= temperature) {
				filtered = append(filtered, item)
				if len(filtered) >= limit {
					break
				}
			}
		}
	}

	return filtered, nil
}

func (s *ClothingItemService) BulkInsertItems(ctx context.Context, items []domain.ClothingItem) error {
	return s.clothingRepo.BulkInsert(ctx, items)
}

func (s *ClothingItemService) GetItemByID(ctx context.Context, id domain.ID) (domain.ClothingItem, error) {
	item, err := s.clothingRepo.GetByID(ctx, id)
	if err != nil {
		return domain.ClothingItem{}, err
	}
	return *item, nil
}

// GetWardrobeItems gets all clothing items owned by the user
func (s *ClothingItemService) GetWardrobeItems(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error) {
	return s.clothingRepo.GetByUserWardrobe(ctx, userID)
}

// GetAllClothingItems gets all available clothing items
func (s *ClothingItemService) GetAllClothingItems(ctx context.Context) ([]domain.ClothingItem, error) {
	return s.clothingRepo.GetAll(ctx)
}

// AddItemToWardrobe adds a clothing item to user's wardrobe
func (s *ClothingItemService) AddItemToWardrobe(ctx context.Context, userID domain.ID, itemID domain.ID) error {
	return s.clothingRepo.LinkToWardrobe(ctx, userID, itemID)
}

// RemoveItemFromWardrobe removes a clothing item from user's wardrobe
func (s *ClothingItemService) RemoveItemFromWardrobe(ctx context.Context, userID domain.ID, itemID domain.ID) error {
	return s.clothingRepo.UnlinkFromWardrobe(ctx, userID, itemID)
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
		if (item.MinTemp != nil && float64(*item.MinTemp) > temperature) || (item.MaxTemp != nil && float64(*item.MaxTemp) < temperature) {
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

func (s *ClothingItemService) UpdateClothingItem(ctx context.Context, item domain.ClothingItem) error {
	return s.clothingRepo.Update(ctx, &item)
}

func (s *ClothingItemService) DeleteClothingItem(ctx context.Context, id domain.ID) error {
	return s.clothingRepo.Delete(ctx, id)
}

func (s *ClothingItemService) validateClothingItem(item domain.ClothingItem) error {
	// Check if the subcategory exists in specs
	_, err := s.specRepo.Get(context.Background(), item.Category, item.Subcategory)
	if err != nil {
		return fmt.Errorf("invalid category/subcategory combination: %s/%s", item.Category, item.Subcategory)
	}

	// Validate temperature range
	if item.MinTemp != nil && item.MaxTemp != nil && *item.MinTemp > *item.MaxTemp {
		return fmt.Errorf("min_temp (%d) cannot be greater than max_temp (%d)", *item.MinTemp, *item.MaxTemp)
	}

	// Validate other constraints
	if item.WarmthLevel != nil && (*item.WarmthLevel < 1 || *item.WarmthLevel > 10) {
		return fmt.Errorf("warmth_level must be between 1 and 10, got %d", *item.WarmthLevel)
	}

	if item.FormalityLevel != nil && (*item.FormalityLevel < 1 || *item.FormalityLevel > 5) {
		return fmt.Errorf("formality_level must be between 1 and 5, got %d", *item.FormalityLevel)
	}

	return nil
}

// TranslateItem translates a clothing item to the target language
func (s *ClothingItemService) TranslateItem(ctx context.Context, item domain.ClothingItem, targetLang string) (domain.ClothingItem, error) {
	if s.translationService == nil {
		// If no translation service is configured, return item as-is
		return item, nil
	}

	// Translate all translatable fields
	var err error

	if item.Name != "" {
		item.TranslatedName, err = s.translationService.TranslateSingle(ctx, item.Name, targetLang)
		if err != nil {
			log.Printf("Failed to translate item name: %v", err)
		}
	}

	if item.Category != "" {
		item.TranslatedCategory, err = s.translationService.TranslateSingle(ctx, item.Category, targetLang)
		if err != nil {
			log.Printf("Failed to translate category: %v", err)
		}
	}

	if item.Subcategory != "" {
		item.TranslatedSubcategory, err = s.translationService.TranslateSingle(ctx, item.Subcategory, targetLang)
		if err != nil {
			log.Printf("Failed to translate subcategory: %v", err)
		}
	}

	if item.Style != "" {
		item.TranslatedStyle, err = s.translationService.TranslateSingle(ctx, item.Style, targetLang)
		if err != nil {
			log.Printf("Failed to translate style: %v", err)
		}
	}

	if len(item.Usage) > 0 {
		// Join the usage slice into a comma-separated string for translation
		usageStr := strings.Join(item.Usage, ", ")
		item.TranslatedUsage, err = s.translationService.TranslateSingle(ctx, usageStr, targetLang)
		if err != nil {
			log.Printf("Failed to translate usage: %v", err)
		}
	}

	if item.Season != "" {
		item.TranslatedSeason, err = s.translationService.TranslateSingle(ctx, item.Season, targetLang)
		if err != nil {
			log.Printf("Failed to translate season: %v", err)
		}
	}

	if item.BaseColour != nil && *item.BaseColour != "" {
		item.TranslatedBaseColour, err = s.translationService.TranslateSingle(ctx, *item.BaseColour, targetLang)
		if err != nil {
			log.Printf("Failed to translate base colour: %v", err)
		}
	}

	if item.Fit != "" {
		item.TranslatedFit, err = s.translationService.TranslateSingle(ctx, item.Fit, targetLang)
		if err != nil {
			log.Printf("Failed to translate fit: %v", err)
		}
	}

	if item.Pattern != "" {
		item.TranslatedPattern, err = s.translationService.TranslateSingle(ctx, item.Pattern, targetLang)
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

	// Create mapping from temporary int64 IDs to UUIDs and scores
	idToUUIDMap := make(map[int64]domain.ID)
	scoreMap := make(map[int64]float64)

	for _, rankedItem := range resp.Ranked {
		scoreMap[rankedItem.ID] = rankedItem.Score
	}

	// Create mapping from clothing items to their temporary int64 IDs
	for _, item := range candidates {
		tempID := domain.IDToInt64(item.ID)
		idToUUIDMap[tempID] = item.ID
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
		tempID := domain.IDToInt64(item.ID)
		scoredItems[i] = scoredItem{
			item:  item,
			score: scoreMap[tempID],
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

	// Create a mapping from UUID to sequential integer IDs for ML service
	// This is a temporary ID mapping just for ML communication
	// In a real system, you might maintain a persistent mapping
	tempID := domain.IDToInt64(item.ID) // Using a hash-based conversion to int64

	return contracts.MLItem{
		ID:             tempID,
		Name:           item.Name,
		Category:       item.Category,
		Subcategory:    item.Subcategory,
		Gender:         item.Gender,
		Style:          item.Style,
		Usage:          strings.Join(item.Usage, ", "),  // Convert []string to string
		Season:         item.Season,
		BaseColour:     func() string {
			if item.BaseColour != nil {
				return *item.BaseColour
			}
			return ""
		}(),
		Formality:      func() int16 {
			if item.FormalityLevel != nil {
				return *item.FormalityLevel
			}
			return 0
		}(),
		Warmth:         func() int16 {
			if item.WarmthLevel != nil {
				return *item.WarmthLevel
			}
			return 0
		}(),
		MinTemp:        func() int16 {
			if item.MinTemp != nil {
				return *item.MinTemp
			}
			return 0
		}(),
		MaxTemp:        func() int16 {
			if item.MaxTemp != nil {
				return *item.MaxTemp
			}
			return 0
		}(),
		Materials:      item.Materials,
		Fit:            item.Fit,
		Pattern:        item.Pattern,
		IconEmoji:      func() string {
			if item.IconEmoji != nil {
				return *item.IconEmoji
			}
			return ""
		}(),
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
	if (item.MinTemp == nil || float64(*item.MinTemp) <= temp) && (item.MaxTemp == nil || float64(*item.MaxTemp) >= temp) {
		score += 50 // Base score for temperature match
		// Bonus for closer match to center of range
		var midPoint float64
		if item.MinTemp != nil && item.MaxTemp != nil {
			midPoint = float64(*item.MinTemp+*item.MaxTemp) / 2.0
		} else {
			midPoint = temp // default to current temp if we don't have range
		}
		tempDiff := math.Abs(midPoint - temp)
		score += math.Max(0, 20-tempDiff) // Up to 20 bonus points
	} else {
		score -= 30 // Penalty for temperature mismatch
	}

	// Warmth appropriateness for cold weather
	if temp < 10 { // Cold weather
		warmthValue := int64(0)
		if item.WarmthLevel != nil {
			warmthValue = int64(*item.WarmthLevel)
		}
		warmthFactor := float64(warmthValue) / 10.0
		score += warmthFactor * 30
	}

	// Formality match (simplified)
	if item.Category == "top" || item.Category == "upper" {
		// Add formality matching logic here if needed
	}

	return score
}
