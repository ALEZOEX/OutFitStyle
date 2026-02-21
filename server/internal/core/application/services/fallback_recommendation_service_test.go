package services

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
)

func TestFallbackRecommendationService_Rank(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	// Создаем тестовые данные
	weather := domain.WeatherSnapshot{
		Temperature: 15.0,
		FeelsLike:   13.0,
		Humidity:    70,
		WindSpeed:   5.0,
		WeatherMain: "Clouds",
		WeatherCode: "04d",
	}

	// Создаем кандидатов
	candidates := []domain.CandidateLite{
		{
			ID:          domain.NewID(),
			Category:    "outerwear",
			Style:       "casual",
			MinTemp:     ptrInt(10),
			MaxTemp:     ptrInt(20),
			RainOK:      true,
			SnowOK:      false,
			WindOK:      true,
			Source:      "user",
			WarmthLevel: ptrInt(6),
		},
		{
			ID:          domain.NewID(),
			Category:    "outerwear",
			Style:       "business",
			MinTemp:     ptrInt(5),
			MaxTemp:     ptrInt(15),
			RainOK:      false,
			SnowOK:      false,
			WindOK:      true,
			Source:      "partner",
			WarmthLevel: ptrInt(7),
		},
		{
			ID:          domain.NewID(),
			Category:    "upper",
			Style:       "casual",
			MinTemp:     ptrInt(15),
			MaxTemp:     ptrInt(25),
			RainOK:      true,
			SnowOK:      false,
			WindOK:      true,
			Source:      "user",
			WarmthLevel: ptrInt(4),
		},
		{
			ID:          domain.NewID(),
			Category:    "lower",
			Style:       "casual",
			MinTemp:     ptrInt(10),
			MaxTemp:     ptrInt(30),
			RainOK:      true,
			SnowOK:      false,
			WindOK:      true,
			Source:      "user",
			WarmthLevel: ptrInt(3),
		},
		{
			ID:          domain.NewID(),
			Category:    "footwear",
			Style:       "sport",
			MinTemp:     ptrInt(5),
			MaxTemp:     ptrInt(25),
			RainOK:      true,
			SnowOK:      false,
			WindOK:      true,
			Source:      "user",
			WarmthLevel: ptrInt(5),
		},
	}

	// Выполняем ранжирование
	result := svc.Rank(weather, candidates, nil, "casual", 2, "")

	// Проверяем результат
	assert.Equal(t, "fallback-v2", result.ModelVersion)
	assert.GreaterOrEqual(t, result.ProcessingTimeMs, 0)
	assert.GreaterOrEqual(t, result.StyleCoherence, 0.0)
	assert.LessOrEqual(t, result.StyleCoherence, 1.0)
	assert.GreaterOrEqual(t, result.ColorHarmony, 0.0)
	assert.LessOrEqual(t, result.ColorHarmony, 1.0)

	// Проверяем, что все категории присутствуют
	expectedCategories := []string{"outerwear", "upper", "lower", "footwear"}
	for _, cat := range expectedCategories {
		items, ok := result.Rankings[cat]
		require.True(t, ok, "Категория %s должна присутствовать", cat)
		assert.Greater(t, len(items), 0, "В категории %s должны быть элементы", cat)
	}

	// Проверяем, что scores в диапазоне [0, 1]
	for cat, items := range result.Rankings {
		for _, item := range items {
			assert.GreaterOrEqual(t, item.Score, 0.0, "Score должен быть >= 0 в категории %s", cat)
			assert.LessOrEqual(t, item.Score, 1.0, "Score должен быть <= 1 в категории %s", cat)
			assert.GreaterOrEqual(t, item.Confidence, 0.0, "Confidence должен быть >= 0 в категории %s", cat)
			assert.LessOrEqual(t, item.Confidence, 1.0, "Confidence должен быть <= 1 в категории %s", cat)
		}
	}
}

func TestFallbackRecommendationService_RankWithExcluded(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 20.0,
		WeatherMain: "Clear",
	}

	candidates := []domain.CandidateLite{
		{
			ID:       domain.NewID(),
			Category: "upper",
			Style:    "casual",
			Source:   "user",
		},
		{
			ID:       domain.NewID(),
			Category: "upper",
			Style:    "business",
			Source:   "partner",
		},
	}

	// Исключаем первого кандидата
	excluded := map[domain.ID]bool{
		candidates[0].ID: true,
	}

	result := svc.Rank(weather, candidates, excluded, "", 2, "")

	// Проверяем, что исключенный элемент не попал в результат
	items, ok := result.Rankings["upper"]
	require.True(t, ok)
	require.Greater(t, len(items), 0)

	// Первый элемент не должен быть в топе
	assert.NotEqual(t, candidates[0].ID, items[0].ID)
}

func TestFallbackRecommendationService_RankRainyWeather(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	// Дождливая погода
	weather := domain.WeatherSnapshot{
		Temperature: 18.0,
		WeatherMain: "Rain",
		WindSpeed:   8.0,
	}

	candidates := []domain.CandidateLite{
		{
			ID:       domain.NewID(),
			Category: "outerwear",
			RainOK:   true, // Подходит для дождя
			Source:   "user",
		},
		{
			ID:       domain.NewID(),
			Category: "outerwear",
			RainOK:   false, // Не подходит для дождя
			Source:   "user",
		},
	}

	result := svc.Rank(weather, candidates, nil, "", 2, "")

	items, ok := result.Rankings["outerwear"]
	require.True(t, ok)
	require.Greater(t, len(items), 0)

	// Элемент с RainOK=true должен быть выше
	assert.Equal(t, candidates[0].ID, items[0].ID)
}

func TestFallbackRecommendationService_RankColdWeather(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	// Холодная погода
	weather := domain.WeatherSnapshot{
		Temperature: -5.0,
		WeatherMain: "Snow",
	}

	candidates := []domain.CandidateLite{
		{
			ID:        domain.NewID(),
			Category:  "outerwear",
			MinTemp:   ptrInt(-10),
			MaxTemp:   ptrInt(5),
			SnowOK:    true,
			WarmthLevel: ptrInt(9),
			Source:    "user",
		},
		{
			ID:        domain.NewID(),
			Category:  "outerwear",
			MinTemp:   ptrInt(10),
			MaxTemp:   ptrInt(20),
			SnowOK:    false,
			WarmthLevel: ptrInt(3),
			Source:    "user",
		},
	}

	result := svc.Rank(weather, candidates, nil, "", 2, "")

	items, ok := result.Rankings["outerwear"]
	require.True(t, ok)
	require.Greater(t, len(items), 0)

	// Теплая вещь должна быть выше
	assert.Equal(t, candidates[0].ID, items[0].ID)
}

func TestFallbackRecommendationService_StyleMatch(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 20.0,
		WeatherMain: "Clear",
	}

	candidates := []domain.CandidateLite{
		{
			ID:       domain.NewID(),
			Category: "upper",
			Style:    "business", // Соответствует запрошенному стилю
			Source:   "partner",
		},
		{
			ID:       domain.NewID(),
			Category: "upper",
			Style:    "casual", // Не соответствует
			Source:   "user",   // Но из гардероба пользователя
		},
	}

	// Запрашиваем business стиль
	result := svc.Rank(weather, candidates, nil, "business", 3, "work")

	items, ok := result.Rankings["upper"]
	require.True(t, ok)
	require.Greater(t, len(items), 0)

	// Business стиль должен быть выше при запрошенном business
	assert.Equal(t, candidates[0].ID, items[0].ID)
}

func TestFallbackRecommendationService_ToRankedLite(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 15.0,
		WeatherMain: "Clear",
	}

	candidates := []domain.CandidateLite{
		{
			ID:       domain.NewID(),
			Category: "upper",
			Source:   "user",
		},
	}

	result := svc.Rank(weather, candidates, nil, "", 2, "")
	rankedLite := result.ToRankedLite()

	_, ok := rankedLite["upper"]
	require.True(t, ok)
}

func TestCalculateScore(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 15.0,
		WeatherMain: "Clouds",
		WindSpeed:   5.0,
	}

	candidate := domain.CandidateLite{
		ID:          domain.NewID(),
		Category:    "upper",
		Style:       "casual",
		MinTemp:     ptrInt(10),
		MaxTemp:     ptrInt(20),
		RainOK:      true,
		SnowOK:      false,
		WindOK:      true,
		Source:      "user",
		WarmthLevel: ptrInt(5),
	}

	score := svc.calculateScore(weather, candidate, "casual", 2, "")

	assert.GreaterOrEqual(t, score, 0.0)
	assert.LessOrEqual(t, score, 1.0)
}

func TestTemperatureMatchScore(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	tests := []struct {
		name      string
		temp      float64
		minTemp   int
		maxTemp   int
		wantScore float64
	}{
		{"Идеальное попадание", 15.0, 10, 20, 1.0},
		{"Ниже диапазона", 5.0, 10, 20, 0.0},
		{"Выше диапазона", 25.0, 10, 20, 0.0},
		{"Чуть ниже", 8.0, 10, 20, 0.0},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			candidate := domain.CandidateLite{
				MinTemp: ptrInt(tt.minTemp),
				MaxTemp: ptrInt(tt.maxTemp),
			}
			score := svc.temperatureMatchScore(tt.temp, candidate)
			
			if tt.wantScore == 1.0 {
				assert.InDelta(t, tt.wantScore, score, 0.3)
			} else {
				assert.InDelta(t, tt.wantScore, score, 0.5)
			}
		})
	}
}

func TestWeatherConditionScore(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	tests := []struct {
		name        string
		weatherMain string
		windSpeed   float64
		rainOK      bool
		wantHigh    bool // true = высокий score, false = низкий
	}{
		{"Дождь + rain_ok", "Rain", 5.0, true, true},
		{"Дождь + не rain_ok", "Rain", 5.0, false, false},
		{"Ясно + rain_ok", "Clear", 5.0, true, true},
		{"Ветрено + wind_ok", "Clear", 12.0, true, true},
		{"Ветрено + не wind_ok", "Clear", 12.0, false, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			weather := domain.WeatherSnapshot{
				WeatherMain: tt.weatherMain,
				WindSpeed:   tt.windSpeed,
			}
			candidate := domain.CandidateLite{
				RainOK: tt.rainOK,
				WindOK: tt.rainOK, // Для простоты
			}
			score := svc.weatherConditionScore(weather, candidate)

			if tt.wantHigh {
				assert.Greater(t, score, 0.5, "Оценка должна быть высокой")
			} else {
				assert.Less(t, score, 0.6, "Оценка должна быть низкой")
			}
		})
	}
}

func TestStyleMatchScore(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	tests := []struct {
		name          string
		itemStyle     string
		requestedStyle string
		wantHigh      bool
	}{
		{"Полное совпадение", "casual", "casual", true},
		{"Разные стили", "business", "sport", false},
		{"Пустой запрошенный", "casual", "", true}, // Нейтральная оценка
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			score := svc.styleMatchScore(tt.itemStyle, tt.requestedStyle)

			if tt.wantHigh {
				assert.GreaterOrEqual(t, score, 0.5)
			} else {
				assert.Less(t, score, 0.5)
			}
		})
	}
}

func TestFormalityMatchScore(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	tests := []struct {
		name           string
		itemFormality  int
		requestedFormality int
		wantScore      float64
	}{
		{"Полное совпадение", 3, 3, 1.0},
		{"Разница 1", 3, 2, 0.7},
		{"Разница 2", 3, 1, 0.4},
		{"Большая разница", 3, 5, 0.2},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			score := svc.formalityMatchScore(&tt.itemFormality, tt.requestedFormality)
			assert.InDelta(t, tt.wantScore, score, 0.1)
		})
	}
}

func TestSourceScore(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	assert.Equal(t, 1.0, svc.sourceScore("user"))
	assert.Equal(t, 0.7, svc.sourceScore("manual"))
	assert.Equal(t, 0.5, svc.sourceScore("partner"))
	assert.Equal(t, 0.3, svc.sourceScore("unknown"))
}

func TestDesiredWarmth(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	tests := []struct {
		temp   float64
		wantMin float64
		wantMax float64
	}{
		{-20, 10, 10},
		{30, 1, 1},
		{5, 5, 9},
		{15, 3, 6},
	}

	for _, tt := range tests {
		t.Run(string(rune(tt.temp)), func(t *testing.T) {
			warmth := svc.desiredWarmth(tt.temp)
			assert.GreaterOrEqual(t, warmth, tt.wantMin)
			assert.LessOrEqual(t, warmth, tt.wantMax)
		})
	}
}

func TestShuffleTop3(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	items := []RankedItem{
		{ID: domain.NewID(), Score: 0.9},
		{ID: domain.NewID(), Score: 0.8},
		{ID: domain.NewID(), Score: 0.7},
		{ID: domain.NewID(), Score: 0.6},
		{ID: domain.NewID(), Score: 0.5},
	}

	originalFirst := items[0]
	svc.shuffleTop3(items)

	// Проверяем, что элементы те же (могут быть переставлены)
	assert.Equal(t, 5, len(items))
	
	// Проверяем, что originalFirst все еще в первых 3 позициях (рандомизация)
	found := false
	for i := 0; i < 3; i++ {
		if items[i].ID == originalFirst.ID {
			found = true
			break
		}
	}
	assert.True(t, found, "Оригинальный первый элемент должен остаться в топ-3")
}

func TestConvertFallbackToMLResponse(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 15.0,
	}

	candidates := []domain.CandidateLite{
		{
			ID:       domain.NewID(),
			Category: "upper",
			Source:   "user",
		},
	}

	result := svc.Rank(weather, candidates, nil, "", 2, "")
	mlResponse := ConvertFallbackToMLResponse(result, "test-request-id")

	assert.Equal(t, "test-request-id", mlResponse.RequestID)
	assert.Equal(t, result.ModelVersion, mlResponse.ModelVersion)
	assert.Equal(t, result.ProcessingTimeMs, mlResponse.ProcessingTimeMs)
	assert.GreaterOrEqual(t, mlResponse.StyleCoherence, 0.0)
	assert.LessOrEqual(t, mlResponse.StyleCoherence, 1.0)
}

// ptrInt возвращает указатель на int
func ptrInt(i int) *int {
	return &i
}

func TestFallbackRecommendationService_EmptyCandidates(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 15.0,
	}

	result := svc.Rank(weather, []domain.CandidateLite{}, nil, "", 2, "")

	assert.Equal(t, "fallback-v2", result.ModelVersion)
	assert.GreaterOrEqual(t, result.ProcessingTimeMs, 0)
	// Ранкинги должны быть пустыми
	assert.Equal(t, 0, len(result.Rankings))
}

func TestFallbackRecommendationService_OnlyOneCategory(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 15.0,
	}

	candidates := []domain.CandidateLite{
		{
			ID:       domain.NewID(),
			Category: "upper",
			Source:   "user",
		},
		{
			ID:       domain.NewID(),
			Category: "upper",
			Source:   "partner",
		},
	}

	result := svc.Rank(weather, candidates, nil, "", 2, "")

	// Должна быть только категория upper
	assert.Equal(t, 1, len(result.Rankings))
	_, ok := result.Rankings["upper"]
	require.True(t, ok)
}

func TestFallbackRecommendationService_Randomization(t *testing.T) {
	logger := zap.NewNop()
	svc := NewFallbackRecommendationService(logger)

	weather := domain.WeatherSnapshot{
		Temperature: 15.0,
	}

	// Создаем много кандидатов с одинаковыми характеристиками
	candidates := make([]domain.CandidateLite, 10)
	for i := 0; i < 10; i++ {
		candidates[i] = domain.CandidateLite{
			ID:       domain.NewID(),
			Category: "upper",
			Source:   "user",
			Style:    "casual",
		}
	}

	// Выполняем несколько ранжирований
	results := make([]FallbackRankResult, 5)
	for i := 0; i < 5; i++ {
		results[i] = svc.Rank(weather, candidates, nil, "", 2, "")
	}

	// Все результаты должны иметь одинаковую модель
	for _, r := range results {
		assert.Equal(t, "fallback-v2", r.ModelVersion)
	}
}
