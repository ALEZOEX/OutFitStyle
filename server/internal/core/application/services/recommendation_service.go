package services

import (
	"context"
	"encoding/json"
	"math"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/eventing"
	"outfitstyle/server/internal/infrastructure/external"
)

// RecommendationService сервис для рекомендаций одежды
type RecommendationService struct {
	recRepo         repositories.RecommendationRepository  // Репозиторий рекомендаций
	clothingRepo    repositories.ClothingRepository        // Репозиторий одежды
	userRepo        repositories.UserRepository            // Репозиторий пользователей
	personalization repositories.PersonalizationRepository // Репозиторий персонализации

	eventPublisher eventing.EventPublisher  // Паблишер событий
	weather        *external.WeatherService // Сервис погоды
	ml             *external.MLClient       // ML-клиент

	fallback *FallbackRanker // Резервный ранжировщик
	logger   *zap.Logger     // Логгер
}

// NewRecommendationService создает новый экземпляр сервиса рекомендаций
func NewRecommendationService(
	recRepo repositories.RecommendationRepository,
	clothingRepo repositories.ClothingRepository,
	userRepo repositories.UserRepository,
	weather *external.WeatherService,
	ml *external.MLClient,
	personalization repositories.PersonalizationRepository,
	eventPublisher eventing.EventPublisher,
	logger *zap.Logger,
) *RecommendationService {
	return &RecommendationService{
		recRepo:         recRepo,
		clothingRepo:    clothingRepo,
		userRepo:        userRepo,
		personalization: personalization,
		eventPublisher:  eventPublisher,
		weather:         weather,
		ml:              ml,
		fallback:        NewFallbackRanker(),
		logger:          logger,
	}
}

// rankedLite структура для ранжированного элемента
type rankedLite struct {
	ID         domain.ID // Идентификатор
	Score      float64   // Оценка
	Confidence float64   // Уверенность
}

// altItem структура альтернативного элемента
type altItem struct {
	ID         string  `json:"id"`         // Идентификатор
	Score      float64 `json:"score"`      // Оценка
	Confidence float64 `json:"confidence"` // Уверенность
}

// Create создает новую рекомендацию
func (s *RecommendationService) Create(ctx context.Context, userID domain.ID, req domain.RecommendationCreateRequest) (*domain.RecommendationRecord, error) {
	lat := req.Latitude
	lon := req.Longitude

	if lat == nil || lon == nil {
		dLat, dLon, err := s.userRepo.GetDefaultCoords(ctx, userID)
		if err != nil {
			return nil, errors.Wrap(err, "загрузка координат пользователя по умолчанию")
		}
		lat = dLat
		lon = dLon
	}

	if lat == nil || lon == nil {
		return nil, errors.New("широта/долгота обязательны (установите местоположение в профиле)")
	}

	ws, _, err := s.weather.GetCurrent(ctx, *lat, *lon)
	if err != nil {
		return nil, errors.Wrap(err, "получение погоды")
	}
	weatherJSON, _ := json.Marshal(ws)

	includePartners := req.IncludePartnerItems != nil && *req.IncludePartnerItems

	wardrobeLite, _ := s.clothingRepo.ListWardrobeCandidatesLite(ctx, userID, 140)
	catalogLite, _ := s.clothingRepo.ListCatalogCandidatesLite(ctx, includePartners, 140)

	// удаление дубликатов и ограничение до 250
	candByID := make(map[domain.ID]domain.CandidateLite, 250)
	add := func(c domain.CandidateLite) {
		if len(candByID) >= 250 {
			return
		}
		if _, ok := candByID[c.ID]; ok {
			return
		}
		candByID[c.ID] = c
	}

	for _, c := range wardrobeLite {
		add(c)
	}
	for _, c := range catalogLite {
		add(c)
	}

	candidates := make([]domain.CandidateLite, 0, len(candByID))
	for _, c := range candByID {
		candidates = append(candidates, c)
	}

	reqStyle := ""
	if req.Style != nil {
		reqStyle = *req.Style
	}
	reqFormality := 2
	if req.Formality != nil {
		reqFormality = *req.Formality
	}
	occ := ""
	if req.Occasion != nil {
		occ = *req.Occasion
	}

	// Вместо синхронного вызова ML-сервиса, публикуем событие
	contextData := map[string]interface{}{
		"temperature":         ws.Temperature,
		"feels_like":          ws.FeelsLike,
		"humidity":            ws.Humidity,
		"wind_speed":          ws.WindSpeed,
		"weather_code":        ws.WeatherCode,
		"occasion":            occ,
		"requested_style":     reqStyle,
		"requested_formality": reqFormality,
		"location":            req.Location,
		"latitude":            lat,
		"longitude":           lon,
	}

	// Публикуем событие запроса рекомендации
	err = s.eventPublisher.PublishRecommendationRequested(ctx, userID, contextData, convertCandidatesToInterface(candidates))
	if err != nil {
		s.logger.Error("Не удалось опубликовать событие запроса рекомендации", zap.Error(err))
		// Возвращаемся к синхронному вызову в случае ошибки публикации события
		modelVersion, processingMs, styleC, colorH, rankings := s.rankLiteOrFallback(ctx, userID, ws, occ, reqStyle, reqFormality, candidates, nil)

		rec, itemsCreate, err := s.buildRecommendationFromRankings(ctx, userID, req, weatherJSON, modelVersion, processingMs, styleC, colorH, rankings, candByID, wardrobeLite, lat, lon)
		if err != nil {
			return nil, err
		}

		// Создаем сессию для логирования в ML сервисе
		session := &repositories.RecommendationSession{
			UserID:          userID,
			ContextHash:     nil, // Можно вычислить хэш от контекста
			ModelVersion:    &modelVersion,
			WeatherData:     weatherJSON,
			UserPreferences: nil, // Можно сериализовать предпочтения пользователя
		}

		_, err = s.recRepo.CreateWithSession(ctx, session, rec, itemsCreate)
		if err != nil {
			return nil, errors.Wrap(err, "сохранение рекомендации с сессией")
		}

		return rec, nil
	}

	// Возвращаем заглушку рекомендации, пока асинхронная обработка не завершена
	// В реальной системе здесь может быть логика возврата промиса или ID задачи
	status := "processing"
	rec := &domain.RecommendationRecord{
		ID:        domain.NewID(),
		UserID:    userID,
		Status:    &status, // Статус указывает, что рекомендация обрабатывается
		CreatedAt: time.Now(),
	}

	return rec, nil
}

// Regenerate: берём старую рекомендацию, исключаем items, предпочтение стиля.
// 1) пытаемся заменить по сохранённым alternatives
// 2) если не смогли собрать полный сет — делаем rerank (ML/fallback) с exclude.
func (s *RecommendationService) Regenerate(
	ctx context.Context,
	userID domain.ID,
	oldID domain.ID,
	exclude []domain.ID,
	preferStyle *string,
) (*domain.RecommendationRecord, error) {

	oldRec, err := s.recRepo.GetByID(ctx, oldID)
	if err != nil {
		return nil, err
	}
	if oldRec == nil || oldRec.UserID != userID {
		return nil, repositories.ErrNotFound
	}

	// снимок погоды: используем старый (консистентность), иначе fallback на запрос погоды
	var ws domain.WeatherSnapshot
	if len(oldRec.WeatherData) > 0 {
		_ = json.Unmarshal(oldRec.WeatherData, &ws)
	}
	if ws.Location == "" && oldRec.Latitude != nil && oldRec.Longitude != nil {
		w, _, e := s.weather.GetCurrent(ctx, *oldRec.Latitude, *oldRec.Longitude)
		if e == nil {
			ws = w
		}
	}
	weatherJSON := oldRec.WeatherData
	if len(weatherJSON) == 0 {
		weatherJSON, _ = json.Marshal(ws)
	}

	excluded := map[domain.ID]bool{}
	for _, id := range exclude {
		excluded[id] = true
	}

	// 1) быстрый путь: подмена из alternatives
	itemRows, err := s.recRepo.GetItemRows(ctx, oldID)
	if err != nil {
		return nil, err
	}

	quickChosen := map[string]domain.ID{} // category -> clothing_item_id
	needRerank := false

	includePartners := false
	for _, row := range itemRows {
		// если была partner вещь — разрешим partner кандидатов при rerank
		if row.Source == "partner" {
			includePartners = true
		}
	}

	for _, row := range itemRows {
		cat := row.Category
		chosen := row.ClothingItemID

		// если текущая вещь не исключена — оставляем
		if !excluded[chosen] {
			quickChosen[cat] = chosen
			continue
		}

		// иначе ищем первую альтернативу не в exclude
		var alts []altItem
		if len(row.AlternativesJSON) > 0 {
			_ = json.Unmarshal(row.AlternativesJSON, &alts)
		}

		found := false
		for _, a := range alts {
			id, e := domain.ParseID(a.ID)
			if e != nil {
				continue
			}
			if excluded[id] {
				continue
			}
			quickChosen[cat] = id
			found = true
			break
		}
		if !found {
			needRerank = true
		}
	}

	// 2) Если не хватает категорий — делаем rerank с exclude
	var rankings map[string][]rankedLite
	var modelVersion string
	var processingMs int
	var styleC float64
	var colorH float64

	if needRerank {
		wardrobeLite, _ := s.clothingRepo.ListWardrobeCandidatesLite(ctx, userID, 140)
		catalogLite, _ := s.clothingRepo.ListCatalogCandidatesLite(ctx, includePartners, 140)

		candByID := make(map[domain.ID]domain.CandidateLite, 250)
		add := func(c domain.CandidateLite) {
			if len(candByID) >= 250 {
				return
			}
			if excluded[c.ID] {
				return
			}
			if _, ok := candByID[c.ID]; ok {
				return
			}
			candByID[c.ID] = c
		}
		for _, c := range wardrobeLite {
			add(c)
		}
		for _, c := range catalogLite {
			add(c)
		}

		candidates := make([]domain.CandidateLite, 0, len(candByID))
		for _, c := range candByID {
			candidates = append(candidates, c)
		}

		style := ""
		if preferStyle != nil {
			style = *preferStyle
		} else if oldRec.RequestedStyle != nil {
			style = *oldRec.RequestedStyle
		}

		formality := 2
		if oldRec.RequestedFormality != nil {
			formality = *oldRec.RequestedFormality
		}
		occasion := ""
		if oldRec.Occasion != nil {
			occasion = *oldRec.Occasion
		}

		modelVersion, processingMs, styleC, colorH, rankings = s.rankLiteOrFallback(ctx, userID, ws, occasion, style, formality, candidates, excluded)
		// quickChosen мы можем "заблокировать" то, что удалось заменить ранее (оставим как есть)
		for cat, id := range quickChosen {
			// ничего, если id не в рейтинге — мы подгрузим item напрямую
			_ = cat
			_ = id
		}

		// теперь выберем итоговые chosen per category:
		// если quickChosen[cat] есть — используем его, иначе берём top из rankings
		finalChosen := map[string]domain.ID{}
		for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
			if id, ok := quickChosen[cat]; ok && !excluded[id] {
				finalChosen[cat] = id
				continue
			}
			list := rankings[cat]
			if len(list) == 0 {
				continue
			}
			finalChosen[cat] = list[0].ID
		}

		// построим новую рекомендацию как Create, но используя finalChosen и rankings
		return s.persistRegenerated(ctx, userID, oldRec, weatherJSON, modelVersion, processingMs, styleC, colorH, rankings, finalChosen, excluded, wardrobeLite)
	}

	// Если quickChosen полностью достаточно — сохраним "быструю" regen без rerank:
	// для alternatives пересчитаем их "как есть": возьмём старые alternatives, выкинем exclude и выбранный.
	finalChosen := map[string]domain.ID{}
	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		if id, ok := quickChosen[cat]; ok && !excluded[id] {
			finalChosen[cat] = id
		}
	}

	return s.persistRegeneratedQuick(ctx, userID, oldRec, weatherJSON, finalChosen, excluded)
}

// persistRegeneratedQuick сохраняет быструю регенерацию рекомендации
func (s *RecommendationService) persistRegeneratedQuick(
	ctx context.Context,
	userID domain.ID,
	oldRec *domain.RecommendationRecord,
	weatherJSON []byte,
	finalChosen map[string]domain.ID,
	excluded map[domain.ID]bool,
) (*domain.RecommendationRecord, error) {

	// загружаем полные элементы только для выбранных
	chosenIDs := make([]domain.ID, 0, len(finalChosen))
	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		if id, ok := finalChosen[cat]; ok {
			chosenIDs = append(chosenIDs, id)
		}
	}

	fullItems, err := s.clothingRepo.GetByIDs(ctx, chosenIDs)
	if err != nil {
		return nil, err
	}
	fullByID := map[domain.ID]domain.ClothingItem{}
	for _, it := range fullItems {
		fullByID[it.ID] = it
	}

	outfitItems := []map[string]any{}
	itemCreates := []repositories.RecommendationItemCreate{}

	total := 0.0
	n := 0

	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		id, ok := finalChosen[cat]
		if !ok || excluded[id] {
			continue
		}
		it, ok := fullByID[id]
		if !ok {
			continue
		}

		// score неизвестен (т.к. не rerank). Ставим 0.5 как нейтральный.
		score := 0.5
		outfitItems = append(outfitItems, map[string]any{
			"category":         cat,
			"item":             it,
			"score":            score,
			"is_from_wardrobe": (it.Source == "user"),
			"alternatives":     []any{},
		})

		itemCreates = append(itemCreates, repositories.RecommendationItemCreate{
			ClothingItemID:   it.ID,
			Category:         cat,
			Score:            &score,
			Source:           it.Source,
			IsFromWardrobe:   (it.Source == "user"),
			AlternativesJSON: nil,
		})

		total += score
		n++
	}

	outfitScore := 0.0
	if n > 0 {
		outfitScore = total / float64(n)
	}

	tips := regenTips(oldRec, len(finalChosen))
	outfitJSON, _ := json.Marshal(map[string]any{
		"outfit": outfitItems,
		"tips":   tips,
	})

	modelVersion := "regen-quick"
	processingMs := 1
	styleC := 0.5
	colorH := 0.5

	rec := &domain.RecommendationRecord{
		UserID:    userID,
		Location:  oldRec.Location,
		Latitude:  oldRec.Latitude,
		Longitude: oldRec.Longitude,

		Occasion:           oldRec.Occasion,
		RequestedStyle:     oldRec.RequestedStyle,
		RequestedFormality: oldRec.RequestedFormality,

		WeatherData: weatherJSON,
		OutfitData:  outfitJSON,

		TotalScore:     &outfitScore,
		StyleCoherence: &styleC,
		ColorHarmony:   &colorH,

		ModelVersion:     &modelVersion,
		ProcessingTimeMs: &processingMs,
		ABTestVariant:    oldRec.ABTestVariant,

		IsFavorite: false,
	}

	_, err = s.recRepo.Create(ctx, rec, itemCreates)
	if err != nil {
		return nil, err
	}
	return rec, nil
}

// persistRegenerated сохраняет регенерированную рекомендацию
func (s *RecommendationService) persistRegenerated(
	ctx context.Context,
	userID domain.ID,
	oldRec *domain.RecommendationRecord,
	weatherJSON []byte,
	modelVersion string,
	processingMs int,
	styleC float64,
	colorH float64,
	rankings map[string][]rankedLite,
	finalChosen map[string]domain.ID,
	excluded map[domain.ID]bool,
	wardrobeLite []domain.CandidateLite,
) (*domain.RecommendationRecord, error) {

	// загружаем полные элементы только для выбранных
	chosenIDs := make([]domain.ID, 0, len(finalChosen))
	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		if id, ok := finalChosen[cat]; ok && !excluded[id] {
			chosenIDs = append(chosenIDs, id)
		}
	}
	fullItems, err := s.clothingRepo.GetByIDs(ctx, chosenIDs)
	if err != nil {
		return nil, err
	}
	fullByID := map[domain.ID]domain.ClothingItem{}
	for _, it := range fullItems {
		fullByID[it.ID] = it
	}

	// множество гардероба для is_from_wardrobe (по wardrobeLite)
	wardrobeSet := map[domain.ID]bool{}
	for _, w := range wardrobeLite {
		wardrobeSet[w.ID] = true
	}

	outfitItems := []map[string]any{}
	itemCreates := []repositories.RecommendationItemCreate{}

	total := 0.0
	n := 0

	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		chID, ok := finalChosen[cat]
		if !ok || excluded[chID] {
			continue
		}
		it, ok := fullByID[chID]
		if !ok {
			continue
		}

		// score/confidence берём из rankings (если есть), иначе нейтральный
		score := 0.5
		conf := 0.5
		list := rankings[cat]
		for _, rr := range list {
			if rr.ID == chID {
				score = rr.Score
				conf = rr.Confidence
				break
			}
		}

		alts := make([]map[string]any, 0, 3)
		for _, rr := range list {
			if rr.ID == chID || excluded[rr.ID] {
				continue
			}
			alts = append(alts, map[string]any{
				"id":         rr.ID.String(),
				"score":      rr.Score,
				"confidence": rr.Confidence,
			})
			if len(alts) >= 3 {
				break
			}
		}
		altsJSON, _ := json.Marshal(alts)

		isFromWardrobe := wardrobeSet[chID]
		outfitItems = append(outfitItems, map[string]any{
			"category":         cat,
			"item":             it,
			"score":            score,
			"confidence":       conf,
			"is_from_wardrobe": isFromWardrobe,
			"alternatives":     alts,
		})

		scr := score
		itemCreates = append(itemCreates, repositories.RecommendationItemCreate{
			ClothingItemID:   it.ID,
			Category:         cat,
			Score:            &scr,
			Source:           it.Source,
			IsFromWardrobe:   isFromWardrobe,
			AlternativesJSON: altsJSON,
		})

		total += score
		n++
	}

	outfitScore := 0.0
	if n > 0 {
		outfitScore = total / float64(n)
	}

	tips := regenTips(oldRec, len(finalChosen))
	outfitJSON, _ := json.Marshal(map[string]any{
		"outfit": outfitItems,
		"tips":   tips,
	})

	rec := &domain.RecommendationRecord{
		UserID:    userID,
		Location:  oldRec.Location,
		Latitude:  oldRec.Latitude,
		Longitude: oldRec.Longitude,

		Occasion:           oldRec.Occasion,
		RequestedStyle:     oldRec.RequestedStyle,
		RequestedFormality: oldRec.RequestedFormality,

		WeatherData: weatherJSON,
		OutfitData:  outfitJSON,

		TotalScore:     &outfitScore,
		StyleCoherence: &styleC,
		ColorHarmony:   &colorH,

		ModelVersion:     &modelVersion,
		ProcessingTimeMs: &processingMs,
		ABTestVariant:    oldRec.ABTestVariant,

		IsFavorite: false,
	}

	_, err = s.recRepo.Create(ctx, rec, itemCreates)
	if err != nil {
		return nil, err
	}
	return rec, nil
}

// buildRecommendationFromRankings: используется Create (новая рекомендация)
func (s *RecommendationService) buildRecommendationFromRankings(
	ctx context.Context,
	userID domain.ID,
	req domain.RecommendationCreateRequest,
	weatherJSON []byte,
	modelVersion string,
	processingMs int,
	styleC float64,
	colorH float64,
	rankings map[string][]rankedLite,
	candByID map[domain.ID]domain.CandidateLite,
	wardrobeLite []domain.CandidateLite,
	lat *float64,
	lon *float64,
) (*domain.RecommendationRecord, []repositories.RecommendationItemCreate, error) {

	// выбранные по категории
	finalChosen := map[string]domain.ID{}
	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		list := rankings[cat]
		if len(list) == 0 {
			continue
		}
		finalChosen[cat] = list[0].ID
	}

	// загружаем полные элементы только для выбранных
	chosenIDs := make([]domain.ID, 0, len(finalChosen))
	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		if id, ok := finalChosen[cat]; ok {
			chosenIDs = append(chosenIDs, id)
		}
	}
	fullItems, err := s.clothingRepo.GetByIDs(ctx, chosenIDs)
	if err != nil {
		return nil, nil, errors.Wrap(err, "загрузка выбранных элементов")
	}
	fullByID := map[domain.ID]domain.ClothingItem{}
	for _, it := range fullItems {
		fullByID[it.ID] = it
	}

	wardrobeSet := map[domain.ID]bool{}
	for _, w := range wardrobeLite {
		wardrobeSet[w.ID] = true
	}

	outfitItems := []map[string]any{}
	itemCreates := []repositories.RecommendationItemCreate{}
	total := 0.0
	n := 0

	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		chID, ok := finalChosen[cat]
		if !ok {
			continue
		}
		it, ok := fullByID[chID]
		if !ok {
			continue
		}

		list := rankings[cat]
		score := list[0].Score
		conf := list[0].Confidence

		alts := make([]map[string]any, 0, 3)
		for i := 1; i < len(list) && len(alts) < 3; i++ {
			alts = append(alts, map[string]any{
				"id":         list[i].ID.String(),
				"score":      list[i].Score,
				"confidence": list[i].Confidence,
			})
		}
		altsJSON, _ := json.Marshal(alts)

		isFromWardrobe := wardrobeSet[chID]
		outfitItems = append(outfitItems, map[string]any{
			"category":         cat,
			"item":             it,
			"score":            score,
			"confidence":       conf,
			"is_from_wardrobe": isFromWardrobe,
			"alternatives":     alts,
		})

		scr := score
		itemCreates = append(itemCreates, repositories.RecommendationItemCreate{
			ClothingItemID:   it.ID,
			Category:         cat,
			Score:            &scr,
			Source:           it.Source,
			IsFromWardrobe:   isFromWardrobe,
			AlternativesJSON: altsJSON,
		})

		total += score
		n++
	}

	outfitScore := 0.0
	if n > 0 {
		outfitScore = total / float64(n)
	}

	// советы: холодный старт если гардероб пустой
	tips := []string{}
	if len(wardrobeLite) == 0 {
		tips = append(tips, "Добавьте 5–10 вещей в гардероб — так рекомендации станут точнее.")
	}
	if len(finalChosen) < 4 {
		tips = append(tips, "Образ получился неполным — попробуйте добавить больше вещей по недостающим категориям.")
	}

	outfitJSON, _ := json.Marshal(map[string]any{
		"outfit": outfitItems,
		"tips":   tips,
	})

	rec := &domain.RecommendationRecord{
		UserID: userID,

		Location:  req.Location,
		Latitude:  lat,
		Longitude: lon,

		Occasion:           req.Occasion,
		RequestedStyle:     req.Style,
		RequestedFormality: req.Formality,

		WeatherData: weatherJSON,
		OutfitData:  outfitJSON,

		TotalScore:     &outfitScore,
		StyleCoherence: &styleC,
		ColorHarmony:   &colorH,

		ModelVersion:     &modelVersion,
		ProcessingTimeMs: &processingMs,

		IsFavorite: false,
	}

	_ = candByID // сохранено для возможного будущего использования

	return rec, itemCreates, nil
}

// regenTips возвращает советы для регенерации
func regenTips(oldRec *domain.RecommendationRecord, chosenCount int) []string {
	tips := []string{}
	if chosenCount < 4 {
		tips = append(tips, "Не удалось подобрать полный образ из альтернатив — попробуйте убрать меньше исключений.")
	}
	_ = oldRec
	return tips
}

// rankLiteOrFallback: теперь поддерживает exclude map (может быть nil)
func (s *RecommendationService) rankLiteOrFallback(
	ctx context.Context,
	userID domain.ID,
	ws domain.WeatherSnapshot,
	occasion string,
	style string,
	formality int,
	candidates []domain.CandidateLite,
	excluded map[domain.ID]bool,
) (modelVersion string, processingMs int, styleC float64, colorH float64, rankings map[string][]rankedLite) {

	modelVersion = "fallback-v1"
	styleC = 0.5
	colorH = 0.5
	rankings = map[string][]rankedLite{}

	// Загружаем данные персонализации
	prefs, _ := s.personalization.GetUserPreferences(ctx, userID)
	recent, _ := s.personalization.GetRecentItems(ctx, userID, 50)
	high, low, _ := s.personalization.GetRatedItems(ctx, userID, 4, 2, 50)
	styleDist, _ := s.personalization.GetStyleDistribution(ctx, userID, 200)

	// Получаем часовой пояс пользователя и определяем время суток
	tz, _ := s.userRepo.GetUserTimezone(ctx, userID)
	timeOfDay := TimeOfDayInTZ(time.Now(), tz)

	mlReq := external.TZMLRankRequest{
		RequestID: uuid.NewString(),
		UserID:    userID,
		Context: external.TZMLContext{
			Temperature:         ws.Temperature,
			FeelsLike:           ws.FeelsLike,
			Humidity:            ws.Humidity,
			WindSpeed:           ws.WindSpeed,
			WindDirection:       0,
			WeatherCode:         ws.WeatherCode,
			PrecipitationChance: 0,
			Occasion:            occasion,
			Formality:           formality,
			TimeOfDay:           timeOfDay,
			DayOfWeek:           int(time.Now().Weekday()),
		},
		UserPreferences: external.TZMLUserPreferences{
			PreferredStyles:        append(prefs.PreferredStyles, preferredStyleList(style)...),
			AvoidStyles:            prefs.AvoidStyles,
			ColorPreferences:       prefs.ColorPreferences,
			AvoidColors:            prefs.AvoidColors,
			PreferredCategories:    prefs.PreferredCategories,
			TemperatureSensitivity: derefInt(prefs.TemperatureSensitivity, 0),
		},
		UserHistory: external.TZMLUserHistory{
			RecentItems:       recent,
			HighlyRatedItems:  high,
			LowRatedItems:     low,
			StyleDistribution: styleDist,
		},
		Candidates: make([]external.TZMLCandidate, 0, len(candidates)),
	}

	// Получаем оценки для кандидатов
	ids := make([]domain.ID, 0, len(candidates))
	for _, c := range candidates {
		ids = append(ids, c.ID)
	}
	ratingMap, _ := s.personalization.GetItemRatingsMap(ctx, userID, ids)

	for _, c := range candidates {
		if excluded != nil && excluded[c.ID] {
			continue
		}

		warmth := valInt(c.WarmthLevel, 5)
		minT := valInt(c.MinTemp, 0)
		maxT := valInt(c.MaxTemp, 30)
		form := valInt(c.FormalityLevel, 3)
		base := valStr(c.BaseColour, "")

		srcPriority := 0
		switch c.Source {
		case "user":
			srcPriority = 3
		case "manual":
			srcPriority = 2
		case "partner":
			srcPriority = 1
		default:
			srcPriority = 0
		}

		candidate := external.TZMLCandidate{
			ID:             c.ID,
			Category:       c.Category,
			Subcategory:    c.Subcategory,
			Source:         c.Source,
			SourcePriority: srcPriority,
			Features: external.TZMLCandidateFeatures{
				WarmthLevel:    warmth,
				MinTemp:        minT,
				MaxTemp:        maxT,
				RainOK:         c.RainOK,
				SnowOK:         c.SnowOK,
				WindOK:         c.WindOK,
				Style:          c.Style,
				FormalityLevel: form,
				BaseColour:     base,
				Pattern:        c.Pattern,
				WearCount:      c.WearCount,
			},
		}

		// Добавляем оценку пользователя, если она есть
		if v, ok := ratingMap[c.ID]; ok {
			candidate.Features.UserRating = &v
		}

		mlReq.Candidates = append(mlReq.Candidates, candidate)
	}

	// Создаем сессию для логирования в ML сервисе
	session := &repositories.RecommendationSession{
		UserID:          userID,
		ContextHash:     nil, // Можно вычислить хэш от контекста
		ModelVersion:    nil, // Будет заполнено из ответа ML
		WeatherData:     nil, // Может быть заполнено позже
		UserPreferences: nil, // Можно сериализовать предпочтения пользователя
	}

	sessionID, err := s.recRepo.CreateSession(ctx, session)
	if err != nil {
		s.logger.Error("Не удалось создать сессию рекомендации", zap.Error(err))
		// Продолжаем без сессии
		sessionID = domain.NewID() // Используем временный ID
	}

	// Используем ID сессии как request_id для ML сервиса
	mlReq.RequestID = sessionID.String()

	start := time.Now()
	mlResp, err := s.ml.Rank(ctx, mlReq)
	if err != nil {
		// ЛОГ ОШИБКИ ML:
		s.logger.Warn("ML ранжирование не удалось, используем резервный вариант", zap.Error(err))
	}
	if err == nil {
		modelVersion = mlResp.ModelVersion
		processingMs = mlResp.ProcessingTimeMs
		styleC = mlResp.StyleCoherence
		colorH = mlResp.ColorHarmony

		for cat, list := range mlResp.Rankings {
			out := make([]rankedLite, 0, len(list))
			for _, it := range list {
				if excluded != nil && excluded[it.ID] {
					continue
				}
				out = append(out, rankedLite{ID: it.ID, Score: it.Score, Confidence: it.Confidence})
			}
			rankings[cat] = out
		}
		return
	}

	s.logger.Warn("ML ранжирование не удалось, используем резервный вариант", zap.Error(err))
	processingMs = int(time.Since(start).Milliseconds())

	byCat := map[string][]rankedLite{}
	for _, c := range candidates {
		if excluded != nil && excluded[c.ID] {
			continue
		}
		score := fallbackScoreLite(ws, style, c)
		byCat[c.Category] = append(byCat[c.Category], rankedLite{
			ID:         c.ID,
			Score:      score,
			Confidence: 0.5,
		})
	}

	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		list := byCat[cat]
		if len(list) == 0 {
			continue
		}
		sort.Slice(list, func(i, j int) bool { return list[i].Score > list[j].Score })
		rankings[cat] = list
	}

	return
}

// preferredStyleList возвращает список предпочтительных стилей
func preferredStyleList(style string) []string {
	style = strings.TrimSpace(style)
	if style == "" {
		return []string{}
	}
	return []string{style}
}

// fallbackScoreLite вычисляет резервную оценку
func fallbackScoreLite(w domain.WeatherSnapshot, requestedStyle string, c domain.CandidateLite) float64 {
	score := 0.0
	score += tempMatchScoreLite(w.Temperature, c) * 0.55

	isRain := strings.Contains(strings.ToLower(w.WeatherMain), "rain")
	isSnow := strings.Contains(strings.ToLower(w.WeatherMain), "snow")

	if isRain && !c.RainOK {
		score -= 0.40
	}
	if isSnow && !c.SnowOK {
		score -= 0.35
	}
	if w.WindSpeed >= 10 && !c.WindOK {
		score -= 0.20
	}

	if requestedStyle != "" {
		if strings.EqualFold(c.Style, requestedStyle) {
			score += 0.20
		} else {
			score -= 0.05
		}
	}

	switch c.Source {
	case "user":
		score += 0.10
	case "manual":
		score += 0.06
	case "partner":
		score += 0.03
	default:
		score += 0.00
	}

	if c.WearCount != nil && *c.WearCount > 0 {
		score += 0.02
	}

	if score < 0 {
		score = 0
	}
	if score > 1 {
		score = 1
	}
	return score
}

// tempMatchScoreLite вычисляет оценку соответствия температуре
func tempMatchScoreLite(temp float64, c domain.CandidateLite) float64 {
	if c.MinTemp != nil && c.MaxTemp != nil && *c.MinTemp <= *c.MaxTemp {
		minT := float64(*c.MinTemp)
		maxT := float64(*c.MaxTemp)
		if temp >= minT && temp <= maxT {
			return 1.0
		}
		d := 0.0
		if temp < minT {
			d = minT - temp
		} else {
			d = temp - maxT
		}
		if d >= 30 {
			return 0.0
		}
		return 1.0 - (d / 30.0)
	}

	warmth := float64(valInt(c.WarmthLevel, 5))
	target := recommendationServiceDesiredWarmth(temp)
	diff := math.Abs(warmth - target)
	v := 1.0 - (diff / 9.0)
	if v < 0 {
		return 0
	}
	return v
}

// recommendationServiceDesiredWarmth вычисляет желаемый уровень тепла
func recommendationServiceDesiredWarmth(temp float64) float64 {
	if temp <= -20 {
		return 10
	}
	if temp >= 30 {
		return 1
	}
	return 10 - ((temp+20)/50.0)*9
}

// valInt возвращает значение или значение по умолчанию
func valInt(p *int, def int) int {
	if p == nil {
		return def
	}
	return *p
}

// valStr возвращает значение или значение по умолчанию
func valStr(p *string, def string) string {
	if p == nil {
		return def
	}
	return *p
}

// derefInt разыменовывает указатель или возвращает значение по умолчанию
func derefInt(p *int, def int) int {
	if p == nil {
		return def
	}
	return *p
}

// derefString разыменовывает указатель или возвращает значение по умолчанию
func derefString(p *string, def string) string {
	if p == nil {
		return def
	}
	return *p
}

// convertCandidatesToInterface преобразует кандидатов в интерфейс для event publisher
func convertCandidatesToInterface(candidates []domain.CandidateLite) []interface{} {
	interfaces := make([]interface{}, len(candidates))
	for i, candidate := range candidates {
		interfaces[i] = candidate
	}
	return interfaces
}

// List/Get/Rate/Favorite — оставляем как в вашем текущем сервисе (из Модуля 19).
// List возвращает список рекомендаций пользователя
func (s *RecommendationService) List(ctx context.Context, userID domain.ID, q domain.RecommendationListQuery) ([]domain.RecommendationRecord, int, error) {
	return s.recRepo.ListByUser(ctx, userID, q)
}

// Get возвращает рекомендацию по идентификатору
func (s *RecommendationService) Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.RecommendationRecord, error) {
	rec, err := s.recRepo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if rec == nil || rec.UserID != userID {
		return nil, nil
	}
	return rec, nil
}

// Rate оценивает рекомендацию
func (s *RecommendationService) Rate(ctx context.Context, userID domain.ID, id domain.ID, rating int, thermal *string, feedback *string) (bool, error) {
	if rating < 1 || rating > 5 {
		return false, errors.New("оценка должна быть от 1 до 5")
	}

	changed, err := s.recRepo.SetRating(ctx, userID, id, rating, thermal, feedback)
	if err != nil {
		return changed, err
	}

	// Публикуем событие обратной связи пользователя
	err = s.eventPublisher.PublishUserFeedback(ctx, userID, id, rating, derefString(feedback, ""))
	if err != nil {
		s.logger.Error("Не удалось опубликовать событие обратной связи пользователя", zap.Error(err))
		// Продолжаем выполнение, даже если не удалось опубликовать событие
	}

	// Отправляем действие в ML сервис для обучения Ranker
	meta := map[string]interface{}{
		"rating":   rating,
		"thermal":  thermal,
		"feedback": feedback,
	}

	// Здесь мы используем ID рекомендации как request_id (в реальности нужно использовать session_id)
	// Но для простоты используем ID рекомендации
	go func() {
		// Создаем фоновый контекст с таймаутом
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		_ = s.SendUserAction(ctx, userID, id.String(), "rate", id.String(), "recommendation", meta)
	}()

	return changed, err
}

// SetFavorite устанавливает/снимает статус избранного для рекомендации
func (s *RecommendationService) SetFavorite(ctx context.Context, userID domain.ID, id domain.ID, fav bool) error {
	err := s.recRepo.SetFavorite(ctx, userID, id, fav)
	if err != nil {
		return err
	}

	// Публикуем событие обратной связи пользователя (избранное)
	rating := 5
	if !fav {
		rating = 1
	}
	err = s.eventPublisher.PublishUserFeedback(ctx, userID, id, rating, "favorite")
	if err != nil {
		s.logger.Error("Не удалось опубликовать событие обратной связи пользователя (избранное)", zap.Error(err))
		// Продолжаем выполнение, даже если не удалось опубликовать событие
	}

	// Отправляем действие в ML сервис для обучения Ranker
	meta := map[string]interface{}{
		"favorite": fav,
	}

	// Здесь мы используем ID рекомендации как request_id (в реальности нужно использовать session_id)
	go func() {
		// Создаем фоновый контекст с таймаутом
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		_ = s.SendUserAction(ctx, userID, id.String(), "favorite", id.String(), "recommendation", meta)
	}()

	return nil
}

// Favorites возвращает избранные рекомендации пользователя
func (s *RecommendationService) Favorites(ctx context.Context, userID domain.ID, limit int) ([]domain.RecommendationRecord, error) {
	return s.recRepo.ListFavorites(ctx, userID, limit)
}

// SendUserAction отправляет действие пользователя в ML сервис для обучения Ranker
func (s *RecommendationService) SendUserAction(ctx context.Context, userID domain.ID, requestID string, actionType string, entityID string, entityType string, meta map[string]interface{}) error {
	if s.ml == nil {
		s.logger.Warn("ML клиент не настроен, пропускаем логирование действий")
		return nil
	}

	actionReq := external.ActionRequest{
		RequestID:  requestID,
		UserID:     userID.String(),
		ActionType: actionType,
		EntityID:   entityID,
		EntityType: entityType,
		Meta:       meta,
	}

	_, err := s.ml.SendAction(ctx, actionReq)
	if err != nil {
		s.logger.Error("Не удалось отправить действие пользователя в ML сервис",
			zap.Error(err),
			zap.String("request_id", requestID),
			zap.String("user_id", userID.String()),
			zap.String("action_type", actionType))
		return err
	}

	s.logger.Info("Действие пользователя отправлено в ML сервис",
		zap.String("request_id", requestID),
		zap.String("user_id", userID.String()),
		zap.String("action_type", actionType))

	return nil
}
