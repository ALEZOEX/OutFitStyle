package services

import (
	"crypto/sha256"
	"encoding/binary"
	"math"
	"sort"
	"strings"

	"outfitstyle/server/internal/core/domain"
)

type FallbackRanker struct{}

func NewFallbackRanker() *FallbackRanker { return &FallbackRanker{} }

type Pick struct {
	Item  domain.ClothingItem
	Score float64
}

// PickOutfit выбирает по одному item на категорию.
// requestedStyle может быть пустым.
func (r *FallbackRanker) PickOutfit(
	weather domain.WeatherSnapshot,
	requestedStyle string,
	candidates []domain.ClothingItem,
) map[string]Pick {
	requestedStyle = strings.ToLower(strings.TrimSpace(requestedStyle))

	byCat := map[string][]Pick{}
	for _, it := range candidates {
		if !it.IsActive {
			continue
		}
		cat := strings.ToLower(it.Category)
		if cat == "" {
			continue
		}
		score := r.scoreItem(weather, requestedStyle, it)
		byCat[cat] = append(byCat[cat], Pick{Item: it, Score: score})
	}

	out := map[string]Pick{}
	for _, cat := range []string{"outerwear", "upper", "lower", "footwear", "accessory"} {
		list := byCat[cat]
		if len(list) == 0 {
			continue
		}
		sort.Slice(list, func(i, j int) bool { return list[i].Score > list[j].Score })
		out[cat] = list[0]
	}

	return out
}

func (r *FallbackRanker) scoreItem(w domain.WeatherSnapshot, requestedStyle string, it domain.ClothingItem) float64 {
	// База
	score := 0.0

	// 1) Температурное соответствие
	score += tempMatchScore(w.Temperature, it) * 0.55

	// 2) Осадки/ветер (мягко, но заметно)
	isRain := strings.Contains(strings.ToLower(w.WeatherMain), "rain")
	isSnow := strings.Contains(strings.ToLower(w.WeatherMain), "snow")

	if isRain && !it.RainOK {
		score -= 0.40
	}
	if isSnow && !it.SnowOK {
		score -= 0.35
	}
	if w.WindSpeed >= 10 && !it.WindOK {
		score -= 0.20
	}

	// 3) Стиль
	if requestedStyle != "" {
		if strings.ToLower(it.Style) == requestedStyle {
			score += 0.20
		} else {
			score -= 0.05
		}
	}

	// 4) Приоритет источника: user > manual > partner > synthetic
	switch strings.ToLower(it.Source) {
	case "user":
		score += 0.10
	case "manual":
		score += 0.06
	case "partner":
		score += 0.03
	default:
		score += 0.00
	}

	// 5) Стабильный "шумик", чтобы не всё было одинаковым
	score += stableJitter(it.ID.String()) * 0.01

	// clamp 0..1
	if score < 0 {
		score = 0
	}
	if score > 1 {
		score = 1
	}
	return score
}

func tempMatchScore(temp float64, it domain.ClothingItem) float64 {
	// если есть min/max temp — используем их
	if it.MinTemp != nil && it.MaxTemp != nil && *it.MinTemp <= *it.MaxTemp {
		minT := float64(*it.MinTemp)
		maxT := float64(*it.MaxTemp)

		if temp >= minT && temp <= maxT {
			return 1.0
		}
		// штрафуем за расстояние до ближайшей границы
		var d float64
		if temp < minT {
			d = minT - temp
		} else {
			d = temp - maxT
		}
		// 0..30 градусов -> 1..0
		return math.Max(0.0, 1.0-(d/30.0))
	}

	// иначе используем warmth_level как прокси
	warmth := 5.0
	if it.WarmthLevel != nil {
		warmth = float64(*it.WarmthLevel)
	}
	target := desiredWarmth(temp) // 1..10
	diff := math.Abs(warmth - target)
	return math.Max(0.0, 1.0-(diff/9.0))
}

// желаемая "теплота" 1..10
func desiredWarmth(temp float64) float64 {
	// линейно: -20 => 10, +30 => 1
	if temp <= -20 {
		return 10
	}
	if temp >= 30 {
		return 1
	}
	// -20..30 (50 градусов)
	return 10 - ((temp+20)/50.0)*9
}

func stableJitter(s string) float64 {
	h := sha256.Sum256([]byte(s))
	n := binary.BigEndian.Uint32(h[:4])
	return float64(n%1000) / 1000.0
}
