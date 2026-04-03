package services

import (
	"crypto/rand"
	"math/big"
	"sort"
	"strings"
	"time"

	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/infrastructure/external"
)

// FallbackRecommendationService — резервный сервис рекомендаций без ML
// Используется при недоступности ML-сервиса для graceful degradation
type FallbackRecommendationService struct {
	logger *zap.Logger
}

// FallbackRankResult — результат работы fallback алгоритма
type FallbackRankResult struct {
	ModelVersion     string
	ProcessingTimeMs int
	StyleCoherence   float64
	ColorHarmony     float64
	Rankings         map[string][]RankedItem
}

// RankedItem — ранжированный элемент одежды
type RankedItem struct {
	ID         domain.ID
	Score      float64
	Confidence float64
}

// NewFallbackRecommendationService создает новый экземпляр fallback сервиса
func NewFallbackRecommendationService(logger *zap.Logger) *FallbackRecommendationService {
	return &FallbackRecommendationService{
		logger: logger,
	}
}

// Rank выполняет резервное ранжирование кандидатов без ML
// Алгоритм учитывает:
// 1. Соответствие температуре (min_temp, max_temp, warmth_level)
// 2. Погодные условия (rain_ok, snow_ok, wind_ok)
// 3. Категорию и стиль
// 4. Предпочтения пользователя (если есть)
// 5. Рандомизацию для разнообразия выдачи
func (s *FallbackRecommendationService) Rank(
	weather domain.WeatherSnapshot,
	candidates []domain.CandidateLite,
	excluded map[domain.ID]bool,
	requestedStyle string,
	requestedFormality int,
	occasion string,
) FallbackRankResult {

	start := time.Now()

	// Группировка по категориям
	byCategory := make(map[string][]domain.CandidateLite)
	for _, c := range candidates {
		if excluded != nil && excluded[c.ID] {
			continue
		}
		byCategory[c.Category] = append(byCategory[c.Category], c)
	}

	// Подсчёт обязательных категорий (upper, lower, footwear)
	mandatoryCats := []string{"upper", "lower", "footwear"}
	mandatoryFound := 0
	for _, cat := range mandatoryCats {
		if len(byCategory[cat]) > 0 {
			mandatoryFound++
		}
	}

	// Режим выживания: если обязательных категорий < 3, отключаем агрессивные штрафы
	survivalMode := mandatoryFound < 3

	if survivalMode {
		s.logger.Warn("[Fallback] SURVIVAL MODE activated — relaxing filters",
			zap.Int("mandatory_categories_found", mandatoryFound),
			zap.Int("total_candidates", len(candidates)),
			zap.Float64("temperature", weather.Temperature),
		)
	}

	rankings := make(map[string][]RankedItem)

	// Ранжирование по каждой категории
	allCategories := []string{"outerwear", "upper", "lower", "footwear", "accessory"}
	for _, cat := range allCategories {
		cats := byCategory[cat]
		if len(cats) == 0 {
			continue
		}

		// Вычисляем scores для всех кандидатов категории
		scored := make([]RankedItem, 0, len(cats))
		for _, c := range cats {
			var score float64
			if survivalMode {
				// В режиме выживания: приоритет температуры, минимум штрафов
				score = s.calculateSurvivalScore(weather, c)
			} else {
				score = s.calculateScore(weather, c, requestedStyle, requestedFormality, occasion)
			}
			scored = append(scored, RankedItem{
				ID:         c.ID,
				Score:      score,
				Confidence: 0.6, // Уверенность fallback алгоритма
			})
		}

		// Сортировка по убыванию score
		sort.Slice(scored, func(i, j int) bool {
			return scored[i].Score > scored[j].Score
		})

		// Добавляем небольшую рандомизацию в топ-3 для разнообразия
		if len(scored) > 3 {
			s.shuffleTop3(scored)
		}

		rankings[cat] = scored
	}

	// Вычисляем метрики качества
	styleCoherence := s.calculateStyleCoherence(rankings, requestedStyle)
	colorHarmony := s.calculateColorHarmony(rankings)

	return FallbackRankResult{
		ModelVersion:     "fallback-v2",
		ProcessingTimeMs: int(time.Since(start).Milliseconds()),
		StyleCoherence:   styleCoherence,
		ColorHarmony:     colorHarmony,
		Rankings:         rankings,
	}
}

// calculateScore вычисляет интегральную оценку кандидата
func (s *FallbackRecommendationService) calculateScore(
	weather domain.WeatherSnapshot,
	c domain.CandidateLite,
	requestedStyle string,
	requestedFormality int,
	occasion string,
) float64 {

	score := 0.0

	// 1. Соответствие температуре (вес 40%)
	tempScore := s.temperatureMatchScore(weather.Temperature, c)
	score += tempScore * 0.40

	// 2. Погодные условия (вес 25%)
	weatherScore := s.weatherConditionScore(weather, c)
	score += weatherScore * 0.25

	// 3. Стиль (вес 15%)
	styleScore := s.styleMatchScore(c.Style, requestedStyle)
	score += styleScore * 0.15

	// 4. Формальность (вес 10%)
	formalityScore := s.formalityMatchScore(c.FormalityLevel, requestedFormality)
	score += formalityScore * 0.10

	// 5. Occasion (вес 10%)
	occasionScore := s.occasionMatchScore(c.Category, c.Subcategory, occasion)
	score += occasionScore * 0.10

	// 6. Источник вещи (вес 5%) — предпочитаем вещи из гардероба пользователя
	sourceScore := s.sourceScore(c.Source)
	score += sourceScore * 0.05

	// 7. Случайный фактор для разнообразия (вес 5%)
	// G404: Используем crypto/rand вместо math/rand
	randomScore := cryptoRandFloat64() * 0.05
	score += randomScore

	// Нормализация [0, 1]
	if score < 0 {
		score = 0
	}
	if score > 1 {
		score = 1
	}

	return score
}

// calculateSurvivalScore — упрощённый скоринг для «режима выживания».
// Штрафы за погоду минимальны (только температура важна).
// Стиль и формальность игнорируются.
// Цель: гарантировать, что пользователь получит комплект даже при экстремальной погоде.
func (s *FallbackRecommendationService) calculateSurvivalScore(
	weather domain.WeatherSnapshot,
	c domain.CandidateLite,
) float64 {
	score := 0.5 // базовый скор — все вещи имеют шанс

	// Только температура (вес 50%)
	tempScore := s.temperatureMatchScore(weather.Temperature, c)
	score += tempScore * 0.30

	// Минимальный штраф за погоду: -0.10 вместо -0.50
	weatherMain := strings.ToLower(weather.WeatherMain)
	isRain := strings.Contains(weatherMain, "rain")
	isSnow := strings.Contains(weatherMain, "snow")

	if isRain && !c.RainOK {
		score -= 0.10
	}
	if isSnow && !c.SnowOK {
		score -= 0.10
	}
	if weather.WindSpeed >= 10 && !c.WindOK {
		score -= 0.05
	}

	// Источник (5%)
	switch c.Source {
	case "user":
		score += 0.05
	}

	// Случайный фактор для разнообразия
	score += cryptoRandFloat64() * 0.10

	if score < 0.05 {
		score = 0.05 // минимальный скор — никто не должен быть полностью исключён
	}
	if score > 1 {
		score = 1
	}

	return score
}

// temperatureMatchScore оценивает соответствие температуры
// Использует min_temp, max_temp и warmth_level
func (s *FallbackRecommendationService) temperatureMatchScore(temp float64, c domain.CandidateLite) float64 {
	// Если есть min/max температура — используем их
	if c.MinTemp != nil && c.MaxTemp != nil {
		minT := float64(*c.MinTemp)
		maxT := float64(*c.MaxTemp)

		if minT <= maxT {
			// Идеальное попадание в диапазон
			if temp >= minT && temp <= maxT {
				// Чем ближе к центру диапазона, тем лучше
				center := (minT + maxT) / 2.0
				deviation := abs(temp - center)
				rangeSize := maxT - minT
				if rangeSize > 0 {
					return 1.0 - (deviation/rangeSize)*0.3
				}
				return 1.0
			}

			// Выход за пределы диапазона
			var deviation float64
			if temp < minT {
				deviation = minT - temp
			} else {
				deviation = temp - maxT
			}

			// Линейное затухание: -30°C от диапазона = 0 очков
			if deviation >= 30 {
				return 0.0
			}
			return 1.0 - (deviation / 30.0)
		}
	}

	// Fallback на warmth_level (1-10)
	warmth := float64(valInt(c.WarmthLevel, 5))
	desiredWarmth := s.desiredWarmth(temp)
	diff := abs(warmth - desiredWarmth)

	// diff=0 -> 1.0, diff=9 -> 0.0
	score := 1.0 - (diff / 9.0)
	if score < 0 {
		return 0
	}
	return score
}

// weatherConditionScore оценивает соответствие погодным условиям
func (s *FallbackRecommendationService) weatherConditionScore(weather domain.WeatherSnapshot, c domain.CandidateLite) float64 {
	score := 1.0

	weatherMain := strings.ToLower(weather.WeatherMain)

	// Дождь
	isRain := strings.Contains(weatherMain, "rain")
	if isRain && !c.RainOK {
		score -= 0.50 // Сильный штраф за неподходящую вещь
	} else if isRain && c.RainOK {
		score += 0.10 // Бонус за подходящую вещь
	}

	// Снег
	isSnow := strings.Contains(weatherMain, "snow")
	if isSnow && !c.SnowOK {
		score -= 0.45
	} else if isSnow && c.SnowOK {
		score += 0.10
	}

	// Ветер
	if weather.WindSpeed >= 10 {
		if !c.WindOK {
			score -= 0.25
		} else {
			score += 0.05
		}
	}

	if score < 0 {
		return 0
	}
	if score > 1 {
		return 1
	}
	return score
}

// styleMatchScore оценивает соответствие запрошенному стилю
func (s *FallbackRecommendationService) styleMatchScore(itemStyle, requestedStyle string) float64 {
	if requestedStyle == "" {
		return 0.5 // Нейтральная оценка если стиль не запрошен
	}

	itemStyle = strings.ToLower(strings.TrimSpace(itemStyle))
	requestedStyle = strings.ToLower(strings.TrimSpace(requestedStyle))

	if itemStyle == requestedStyle {
		return 1.0
	}

	// Частичное совпадение
	styleSynonyms := map[string][]string{
		"casual":       {"casual", "повседневный", "relaxed"},
		"business":     {"business", "деловой", "formal", "официальный"},
		"sport":        {"sport", "спортивный", "athletic"},
		"smart casual": {"smart casual", "повседневно-деловой"},
		"evening":      {"evening", "вечерний", "cocktail"},
	}

	for style, synonyms := range styleSynonyms {
		if strings.Contains(requestedStyle, style) {
			for _, syn := range synonyms {
				if strings.Contains(itemStyle, syn) {
					return 0.7
				}
			}
		}
	}

	return 0.3
}

// formalityMatchScore оценивает соответствие уровню формальности
func (s *FallbackRecommendationService) formalityMatchScore(itemFormality *int, requestedFormality int) float64 {
	if itemFormality == nil {
		return 0.5
	}

	diff := abs(float64(*itemFormality - requestedFormality))
	switch int(diff) {
	case 0:
		return 1.0
	case 1:
		return 0.7
	case 2:
		return 0.4
	default:
		return 0.2
	}
}

// sourceScore оценивает приоритет источника вещи
func (s *FallbackRecommendationService) sourceScore(source string) float64 {
	switch source {
	case "user":
		return 1.0 // Вещи из гардероба пользователя — высший приоритет
	case "manual":
		return 0.7
	case "partner":
		return 0.5
	default:
		return 0.3
	}
}

// occasionMatchScore оценивает соответствие категории случаю
func (s *FallbackRecommendationService) occasionMatchScore(category, subcategory, occasion string) float64 {
	if occasion == "" || occasion == "casual" || occasion == "everyday" {
		return 0.7 // Повседневное — подходит почти всё
	}

	occ := strings.ToLower(strings.TrimSpace(occasion))
	cat := strings.ToLower(strings.TrimSpace(category))
	sub := strings.ToLower(strings.TrimSpace(subcategory))

	// Деловой стиль
	if occ == "business" || occ == "work" {
		if cat == "upper" && (strings.Contains(sub, "рубашк") || strings.Contains(sub, "блуз") || strings.Contains(sub, "пиджак")) {
			return 1.0
		}
		if cat == "lower" && (strings.Contains(sub, "брюк") || strings.Contains(sub, "классик")) {
			return 1.0
		}
		if cat == "outerwear" && (strings.Contains(sub, "пальт") || strings.Contains(sub, "классик")) {
			return 0.9
		}
		if cat == "footwear" && (strings.Contains(sub, "туфл") || strings.Contains(sub, "оксфорд") || strings.Contains(sub, "лофер")) {
			return 0.9
		}
		return 0.4
	}

	// Спорт
	if occ == "sport" {
		if strings.Contains(sub, "спорт") || strings.Contains(sub, "трениров") || strings.Contains(sub, "кроссов") {
			return 1.0
		}
		if cat == "upper" && strings.Contains(sub, "футбол") {
			return 0.8
		}
		return 0.3
	}

	// Вечерний
	if occ == "evening" || occ == "party" {
		if strings.Contains(sub, "вечерн") || strings.Contains(sub, "нарядн") || strings.Contains(sub, "шелк") {
			return 1.0
		}
		if cat == "footwear" && (strings.Contains(sub, "туфл") || strings.Contains(sub, "каблук")) {
			return 0.9
		}
		return 0.5
	}

	// Романтичный
	if occ == "romantic" || occ == "date" {
		if strings.Contains(sub, "романт") || strings.Contains(sub, "элегант") {
			return 1.0
		}
		return 0.6
	}

	// По умолчанию — нейтральный скор
	return 0.5
}

// desiredWarmth вычисляет желаемый уровень тепла для температуры
func (s *FallbackRecommendationService) desiredWarmth(temp float64) float64 {
	if temp <= -20 {
		return 10
	}
	if temp >= 30 {
		return 1
	}
	// Линейная интерполяция: -20°C -> 10, 30°C -> 1
	return 10 - ((temp+20)/50.0)*9
}

// calculateStyleCoherence вычисляет согласованность стиля в рекомендациях
func (s *FallbackRecommendationService) calculateStyleCoherence(rankings map[string][]RankedItem, requestedStyle string) float64 {
	if len(rankings) == 0 {
		return 0.5
	}

	// Собираем стили всех выбранных вещей
	styles := make([]string, 0)
	for _, items := range rankings {
		if len(items) > 0 {
			// Берем топ-1 из каждой категории
			styles = append(styles, items[0].ID.String())
		}
	}

	if len(styles) == 0 {
		return 0.5
	}

	// Если запрошен стиль — оцениваем соответствие
	if requestedStyle != "" {
		return 0.7 + 0.3*cryptoRandFloat64() // Fallback не может точно оценить без полных данных
	}

	return 0.6 + 0.2*cryptoRandFloat64()
}

// calculateColorHarmony вычисляет гармоничность цветов
func (s *FallbackRecommendationService) calculateColorHarmony(rankings map[string][]RankedItem) float64 {
	if len(rankings) == 0 {
		return 0.5
	}

	// Fallback не имеет полных данных о цветах, возвращаем оценку по умолчанию
	return 0.6 + 0.2*cryptoRandFloat64()
}

// shuffleTop3 добавляет небольшую рандомизацию в топ-3 элементов
// для предотвращения однообразия рекомендаций
func (s *FallbackRecommendationService) shuffleTop3(items []RankedItem) {
	if len(items) < 3 {
		return
	}

	// Перемешиваем только топ-3 (первые 3 элемента)
	// G404: Используем crypto/rand
	for i := 2; i > 0; i-- {
		j := cryptoRandInt(i + 1)
		items[i], items[j] = items[j], items[i]
	}
}

// cryptoRandFloat64 генерирует криптографически безопасное случайное число [0, 1)
func cryptoRandFloat64() float64 {
	max := big.NewInt(1 << 53)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return 0.5 // fallback
	}
	return float64(n.Int64()) / float64(max.Int64())
}

// cryptoRandInt генерирует криптографически безопасное случайное целое число [0, max)
func cryptoRandInt(max int) int {
	if max <= 0 {
		return 0
	}
	n, err := rand.Int(rand.Reader, big.NewInt(int64(max)))
	if err != nil {
		return 0 // fallback
	}
	return int(n.Int64())
}

// ToRankedLite конвертирует результат в формат rankedLite для совместимости
func (r *FallbackRankResult) ToRankedLite() map[string][]rankedLite {
	result := make(map[string][]rankedLite)
	for cat, items := range r.Rankings {
		lite := make([]rankedLite, len(items))
		for i, item := range items {
			lite[i] = rankedLite{
				ID:         item.ID,
				Score:      item.Score,
				Confidence: item.Confidence,
			}
		}
		result[cat] = lite
	}
	return result
}

// abs возвращает модуль числа
func abs(x float64) float64 {
	if x < 0 {
		return -x
	}
	return x
}

// ConvertFallbackToMLResponse конвертирует fallback результат в формат ML ответа
func ConvertFallbackToMLResponse(result FallbackRankResult, requestID string) external.TZMLRankResponse {
	rankings := make(map[string][]external.TZMLRankedItem)
	for cat, items := range result.Rankings {
		mlItems := make([]external.TZMLRankedItem, len(items))
		for i, item := range items {
			mlItems[i] = external.TZMLRankedItem{
				ID:         item.ID,
				Score:      item.Score,
				Confidence: item.Confidence,
				Factors: map[string]any{
					"algorithm": "fallback",
					"version":   result.ModelVersion,
				},
			}
		}
		rankings[cat] = mlItems
	}

	return external.TZMLRankResponse{
		RequestID:        requestID,
		Rankings:         rankings,
		OutfitScore:      0.7,
		StyleCoherence:   result.StyleCoherence,
		ColorHarmony:     result.ColorHarmony,
		ModelVersion:     result.ModelVersion,
		ProcessingTimeMs: result.ProcessingTimeMs,
	}
}
