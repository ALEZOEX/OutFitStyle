package services

import (
	"context"
	"fmt"
	"log"
	"math"
	"outfitstyle/server/internal/contracts"
	"outfitstyle/server/internal/core/application/planner"
	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/repo/clothing"
	mlclient "outfitstyle/server/internal/infrastructure/clients"
	translation "outfitstyle/server/internal/infrastructure/services"
	"outfitstyle/server/internal/validation"
	"strings"
	"time"
)

// ClothingItemService сервис для работы с элементами одежды
type ClothingItemService struct {
	clothingRepo       repositories.ClothingItemRepository // Репозиторий элементов одежды
	specRepo           clothing.SubcategorySpecRepository  // Репозиторий спецификаций подкатегорий
	mlClient           *mlclient.Client                    // ML-клиент для ранжирования
	outfitPlanner      *planner.OutfitPlanner              // Планировщик нарядов
	translationService translation.ServiceInterface        // Сервис перевода
}

// NewClothingItemService создает новый экземпляр сервиса элементов одежды
func NewClothingItemService(clothingRepo repositories.ClothingItemRepository, specRepo clothing.SubcategorySpecRepository, mlClient *mlclient.Client, translationService translation.ServiceInterface) *ClothingItemService {
	return &ClothingItemService{
		clothingRepo:       clothingRepo,
		specRepo:           specRepo,
		mlClient:           mlClient,
		translationService: translationService,
		outfitPlanner:      planner.NewOutfitPlanner(specRepo),
	}
}

// GetClothingItemsByPlan возвращает элементы одежды по плану (категория, подкатегории, уровень тепла, температура)
func (s *ClothingItemService) GetClothingItemsByPlan(ctx context.Context, category string, subcategories []string, warmthMin int16, temperature int16, limit int) ([]domain.ClothingItem, error) {
	items, err := s.clothingRepo.GetAll(ctx)
	if err != nil {
		return nil, err
	}

	// Фильтрация элементов по критериям
	var filtered []domain.ClothingItem
	for _, item := range items {
		if item.Category == category {
			// Для простоты, возвращаем все элементы в категории с ограничениями по температуре
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

// BulkInsertItems массово вставляет элементы одежды
func (s *ClothingItemService) BulkInsertItems(ctx context.Context, items []domain.ClothingItem) error {
	return s.clothingRepo.BulkInsert(ctx, items)
}

// GetItemByID возвращает элемент одежды по идентификатору
func (s *ClothingItemService) GetItemByID(ctx context.Context, id domain.ID) (domain.ClothingItem, error) {
	item, err := s.clothingRepo.GetByID(ctx, id)
	if err != nil {
		return domain.ClothingItem{}, err
	}
	return *item, nil
}

// GetWardrobeItems возвращает все элементы одежды, принадлежащие пользователю
func (s *ClothingItemService) GetWardrobeItems(ctx context.Context, userID domain.ID) ([]domain.ClothingItem, error) {
	return s.clothingRepo.GetByUserWardrobe(ctx, userID)
}

// GetAllClothingItems возвращает все доступные элементы одежды
func (s *ClothingItemService) GetAllClothingItems(ctx context.Context) ([]domain.ClothingItem, error) {
	return s.clothingRepo.GetAll(ctx)
}

// AddItemToWardrobe добавляет элемент одежды в гардероб пользователя
func (s *ClothingItemService) AddItemToWardrobe(ctx context.Context, userID domain.ID, itemID domain.ID) error {
	return s.clothingRepo.LinkToWardrobe(ctx, userID, itemID)
}

// RemoveItemFromWardrobe удаляет элемент одежды из гардероба пользователя
func (s *ClothingItemService) RemoveItemFromWardrobe(ctx context.Context, userID domain.ID, itemID domain.ID) error {
	return s.clothingRepo.UnlinkFromWardrobe(ctx, userID, itemID)
}

// Planner-related methods (методы, связанные с планированием)

// GetSubcategorySpecs возвращает все спецификации подкатегорий
func (s *ClothingItemService) GetSubcategorySpecs(ctx context.Context) ([]domain.SubcategorySpec, error) {
	return s.specRepo.ListAll(ctx)
}

// GetSubcategorySpec возвращает спецификацию подкатегории
func (s *ClothingItemService) GetSubcategorySpec(ctx context.Context, category, subcategory string) (domain.SubcategorySpec, error) {
	return s.specRepo.Get(ctx, category, subcategory)
}

// GenerateOutfitPlan использует логику планировщика для рекомендации подходящих подкатегорий для заданных погодных условий
func (s *ClothingItemService) GenerateOutfitPlan(ctx context.Context, temperature float64, weatherCondition string, userPreferences map[string]interface{}) (*planner.OutfitPlan, error) {
	return s.outfitPlanner.GeneratePlan(ctx, temperature, weatherCondition, userPreferences)
}

// GetItemsForPlan извлекает элементы одежды, соответствующие требованиям плана
func (s *ClothingItemService) GetItemsForPlan(ctx context.Context, plan *planner.OutfitPlan, temperature int16, limitPerCategory int) (map[string][]domain.ClothingItem, error) {
	result := make(map[string][]domain.ClothingItem)

	for category, specs := range plan.Plan {
		// Извлечение подкатегорий для этой категории
		var subcategories []string
		for _, spec := range specs {
			subcategories = append(subcategories, spec.Subcategory)
		}

		// Поиск элементов, соответствующих плану
		// Использование минимального требования тепла из спецификаций
		var minWarmth int16 = 10 // Начинаем с максимального возможного значения
		for _, spec := range specs {
			if spec.WarmthMin < minWarmth {
				minWarmth = spec.WarmthMin
			}
		}

		items, err := s.clothingRepo.FindCandidatesByPlan(ctx, category, subcategories, minWarmth, temperature, limitPerCategory)
		if err != nil {
			log.Printf("Ошибка поиска кандидатов для категории %s: %v", category, err)
			continue
		}

		// Предварительная фильтрация кандидатов по температуре и базовой совместимости
		filteredItems := s.preFilterCandidates(ctx, items, float64(temperature))

		result[category] = filteredItems
	}

	return result, nil
}

// preFilterCandidates фильтрует элементы по базовой совместимости перед ML-ранжированием
func (s *ClothingItemService) preFilterCandidates(ctx context.Context, candidates []domain.ClothingItem, temperature float64) []domain.ClothingItem {
	var filtered []domain.ClothingItem

	for _, item := range candidates {
		// Базовая проверка совместимости по температуре
		if (item.MinTemp != nil && float64(*item.MinTemp) > temperature) || (item.MaxTemp != nil && float64(*item.MaxTemp) < temperature) {
			continue
		}

		// Дополнительная предварительная фильтрация может быть добавлена здесь:
		// - соответствие формальности (если контекст предоставляет целевую формальность)
		// - соответствие стилю (если контекст предоставляет целевой стиль)
		// - сезонная актуальность

		filtered = append(filtered, item)
	}

	return filtered
}

// CreateClothingItem создает новый элемент одежды
func (s *ClothingItemService) CreateClothingItem(ctx context.Context, item domain.ClothingItem) error {
	// Валидация элемента перед вставкой
	if err := s.validateClothingItem(item); err != nil {
		return fmt.Errorf("ошибка валидации: %w", err)
	}

	// Установка значений по умолчанию, если не предоставлены
	if item.CreatedAt.IsZero() {
		item.CreatedAt = time.Now()
	}

	return s.clothingRepo.BulkInsert(ctx, []domain.ClothingItem{item})
}

// UpdateClothingItem обновляет элемент одежды
func (s *ClothingItemService) UpdateClothingItem(ctx context.Context, item domain.ClothingItem) error {
	return s.clothingRepo.Update(ctx, &item)
}

// DeleteClothingItem удаляет элемент одежды
func (s *ClothingItemService) DeleteClothingItem(ctx context.Context, id domain.ID) error {
	return s.clothingRepo.Delete(ctx, id)
}

// validateClothingItem валидирует элемент одежды
func (s *ClothingItemService) validateClothingItem(item domain.ClothingItem) error {
	// Использование централизованной валидации
	v := validation.NewValidator()
	validation.ValidateClothingItem(v, item)

	if !v.Valid() {
		// Преобразование ошибок валидации в одну ошибку для обратной совместимости
		var errorMessages []string
		for _, msg := range v.Errors {
			errorMessages = append(errorMessages, msg)
		}
		return NewValidationError(v.Errors) // Использование ValidationError, созданного ранее
	}

	// Проверка, существует ли подкатегория в спецификациях
	_, err := s.specRepo.Get(context.Background(), item.Category, item.Subcategory)
	if err != nil {
		return fmt.Errorf("недопустимая комбинация категории/подкатегории: %s/%s", item.Category, item.Subcategory)
	}

	return nil
}

// TranslateItem переводит элемент одежды на целевой язык
func (s *ClothingItemService) TranslateItem(ctx context.Context, item domain.ClothingItem, targetLang string) (domain.ClothingItem, error) {
	if s.translationService == nil {
		// Если сервис перевода не настроен, возвращаем элемент как есть
		return item, nil
	}

	// Перевод всех переводимых полей
	var err error

	if item.Name != "" {
		item.TranslatedName, err = s.translationService.TranslateSingle(ctx, item.Name, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести название элемента: %v", err)
		}
	}

	if item.Category != "" {
		item.TranslatedCategory, err = s.translationService.TranslateSingle(ctx, item.Category, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести категорию: %v", err)
		}
	}

	if item.Subcategory != "" {
		item.TranslatedSubcategory, err = s.translationService.TranslateSingle(ctx, item.Subcategory, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести подкатегорию: %v", err)
		}
	}

	if item.Style != "" {
		item.TranslatedStyle, err = s.translationService.TranslateSingle(ctx, item.Style, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести стиль: %v", err)
		}
	}

	if len(item.Usage) > 0 {
		// Объединение среза использования в строку, разделенную запятыми, для перевода
		usageStr := strings.Join(item.Usage, ", ")
		item.TranslatedUsage, err = s.translationService.TranslateSingle(ctx, usageStr, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести использование: %v", err)
		}
	}

	if item.Season != "" {
		item.TranslatedSeason, err = s.translationService.TranslateSingle(ctx, item.Season, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести сезон: %v", err)
		}
	}

	if item.BaseColour != nil && *item.BaseColour != "" {
		item.TranslatedBaseColour, err = s.translationService.TranslateSingle(ctx, *item.BaseColour, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести базовый цвет: %v", err)
		}
	}

	if item.Fit != "" {
		item.TranslatedFit, err = s.translationService.TranslateSingle(ctx, item.Fit, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести посадку: %v", err)
		}
	}

	if item.Pattern != "" {
		item.TranslatedPattern, err = s.translationService.TranslateSingle(ctx, item.Pattern, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести узор: %v", err)
		}
	}

	return item, nil
}

// TranslateItems переводит срез элементов одежды
func (s *ClothingItemService) TranslateItems(ctx context.Context, items []domain.ClothingItem, targetLang string) ([]domain.ClothingItem, error) {
	if s.translationService == nil {
		// Если сервис перевода не настроен, возвращаем элементы как есть
		return items, nil
	}

	translatedItems := make([]domain.ClothingItem, len(items))
	for i, item := range items {
		translatedItem, err := s.TranslateItem(ctx, item, targetLang)
		if err != nil {
			log.Printf("Не удалось перевести элемент %d: %v", i, err)
			// Все равно добавляем элемент с оригинальным текстом
			translatedItems[i] = item
		} else {
			translatedItems[i] = translatedItem
		}
	}

	return translatedItems, nil
}

// RankCandidatesByML ранжирует набор элементов одежды с использованием ML-сервиса
func (s *ClothingItemService) RankCandidatesByML(ctx context.Context, contextData *contracts.MLContext, candidates []domain.ClothingItem) ([]domain.ClothingItem, error) {
	// Преобразование domain.ClothingItem в contracts.MLItem
	mlCandidates := make([]contracts.MLItem, len(candidates))
	for i, item := range candidates {
		mlCandidates[i] = s.domainToMLItem(item)
	}

	// Создание запроса
	req := &contracts.MLRankRequest{
		Context:    *contextData,
		Candidates: mlCandidates,
	}

	// Вызов ML-сервиса с логикой повторных попыток и бюджетом времени (0 времени потрачено изначально)
	resp, err := s.mlClient.RankCandidatesWithRetry(ctx, req, 1, 0) // максимум 1 повтор, 0 времени потрачено изначально
	if err != nil {
		log.Printf("ML-ранжирование не удалось: %v, возврат к правилам", err)
		// Возврат к правилам ранжирования
		return s.ruleBasedRank(candidates, contextData), nil
	}

	if resp.Error != nil {
		log.Printf("ML-сервис вернул ошибку: %s, возврат к правилам", *resp.Error)
		return s.ruleBasedRank(candidates, contextData), nil
	}

	// Создание сопоставления из временных int64 ID в UUID и оценки
	idToUUIDMap := make(map[int64]domain.ID)
	scoreMap := make(map[int64]float64)

	for _, rankedItem := range resp.Ranked {
		scoreMap[rankedItem.ID] = rankedItem.Score
	}

	// Создание сопоставления из элементов одежды в их временные int64 ID
	for _, item := range candidates {
		tempID := domain.IDToInt64(item.ID)
		idToUUIDMap[tempID] = item.ID
	}

	// Сортировка кандидатов по ML-оценкам
	sortedCandidates := make([]domain.ClothingItem, len(candidates))
	copy(sortedCandidates, candidates)

	// Создание среза индексов с оценками для сортировки
	type scoredItem struct {
		item  domain.ClothingItem
		score float64
		index int // для сохранения стабильной сортировки
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

	// Сортировка по оценке (по убыванию), сохранение исходного порядка для равных оценок
	for i := 0; i < len(scoredItems); i++ {
		for j := i + 1; j < len(scoredItems); j++ {
			if scoredItems[i].score < scoredItems[j].score {
				scoredItems[i], scoredItems[j] = scoredItems[j], scoredItems[i]
			} else if scoredItems[i].score == scoredItems[j].score && scoredItems[i].index > scoredItems[j].index {
				// Сохранение исходного порядка для равных оценок
				scoredItems[i], scoredItems[j] = scoredItems[j], scoredItems[i]
			}
		}
	}

	// Извлечение отсортированных элементов
	for i, scoredItem := range scoredItems {
		sortedCandidates[i] = scoredItem.item
	}

	return sortedCandidates, nil
}

// domainToMLItem преобразует domain.ClothingItem в contracts.MLItem
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

	// Создание сопоставления из UUID в последовательные целочисленные ID для ML-сервиса
	// Это временная схема сопоставления только для ML-коммуникации
	// В реальной системе вы можете поддерживать постоянное сопоставление
	tempID := domain.IDToInt64(item.ID) // Использование хэш-преобразования в int64

	return contracts.MLItem{
		ID:          tempID,
		Name:        item.Name,
		Category:    item.Category,
		Subcategory: item.Subcategory,
		Gender:      item.Gender,
		Style:       item.Style,
		Usage:       strings.Join(item.Usage, ", "), // Преобразование []string в строку
		Season:      item.Season,
		BaseColour: func() string {
			if item.BaseColour != nil {
				return *item.BaseColour
			}
			return ""
		}(),
		Formality: func() int16 {
			if item.FormalityLevel != nil {
				return *item.FormalityLevel
			}
			return 0
		}(),
		Warmth: func() int16 {
			if item.WarmthLevel != nil {
				return *item.WarmthLevel
			}
			return 0
		}(),
		MinTemp: func() int16 {
			if item.MinTemp != nil {
				return *item.MinTemp
			}
			return 0
		}(),
		MaxTemp: func() int16 {
			if item.MaxTemp != nil {
				return *item.MaxTemp
			}
			return 0
		}(),
		Materials: item.Materials,
		Fit:       item.Fit,
		Pattern:   item.Pattern,
		IconEmoji: func() string {
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

// ruleBasedRank предоставляет резервное ранжирование, когда ML-сервис недоступен
func (s *ClothingItemService) ruleBasedRank(candidates []domain.ClothingItem, contextData *contracts.MLContext) []domain.ClothingItem {
	// Реализация логики ранжирования по правилам:
	// 1. Приоритет по источнику (пользователь > ручной > партнер > синтетический)
	// 2. Приоритет по соответствию температуре
	// 3. Приоритет по соответствию формальности

	sortedCandidates := make([]domain.ClothingItem, len(candidates))
	copy(sortedCandidates, candidates)

	// Сортировка с приоритезацией по правилам
	for i := 0; i < len(sortedCandidates); i++ {
		for j := i + 1; j < len(sortedCandidates); j++ {
			if s.calculateRuleScore(sortedCandidates[i], contextData) < s.calculateRuleScore(sortedCandidates[j], contextData) {
				sortedCandidates[i], sortedCandidates[j] = sortedCandidates[j], sortedCandidates[i]
			}
		}
	}

	return sortedCandidates
}

// calculateRuleScore вычисляет правило-ориентированную оценку для ранжирования
func (s *ClothingItemService) calculateRuleScore(item domain.ClothingItem, contextData *contracts.MLContext) float64 {
	score := 0.0

	// Приоритет источника
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

	// Соответствие температуре
	temp := contextData.Weather.Temperature
	if (item.MinTemp == nil || float64(*item.MinTemp) <= temp) && (item.MaxTemp == nil || float64(*item.MaxTemp) >= temp) {
		score += 50 // Базовая оценка за соответствие температуре
		// Бонус за более близкое соответствие центру диапазона
		var midPoint float64
		if item.MinTemp != nil && item.MaxTemp != nil {
			midPoint = float64(*item.MinTemp+*item.MaxTemp) / 2.0
		} else {
			midPoint = temp // по умолчанию текущая температура, если у нас нет диапазона
		}
		tempDiff := math.Abs(midPoint - temp)
		score += math.Max(0, 20-tempDiff) // До 20 бонусных баллов
	} else {
		score -= 30 // Штраф за несоответствие температуре
	}

	// Соответствие теплу для холодной погоды
	if temp < 10 { // Холодная погода
		warmthValue := int64(0)
		if item.WarmthLevel != nil {
			warmthValue = int64(*item.WarmthLevel)
		}
		warmthFactor := float64(warmthValue) / 10.0
		score += warmthFactor * 30
	}

	// Соответствие формальности (упрощенное)
	if item.Category == "top" || item.Category == "upper" {
		// Добавьте логику соответствия формальности, если необходимо
	}

	return score
}
