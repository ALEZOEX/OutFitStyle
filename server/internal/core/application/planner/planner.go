package planner

import (
	"context"
	"fmt"
	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/repo/clothing"
)

// WeatherCondition представляет погодные условия
type WeatherCondition string

const (
	Clear        WeatherCondition = "clear"        // Ясно
	Clouds       WeatherCondition = "clouds"       // Облачно
	Rain         WeatherCondition = "rain"         // Дождь
	Drizzle      WeatherCondition = "drizzle"      // Морось
	Snow         WeatherCondition = "snow"         // Снег
	Mist         WeatherCondition = "mist"         // Туман
	Thunderstorm WeatherCondition = "thunderstorm" // Гроза
)

// OutfitPlanner представляет планировщик наряда
type OutfitPlanner struct {
	specRepo clothing.SubcategorySpecRepository
}

// NewOutfitPlanner создает новый экземпляр планировщика наряда
func NewOutfitPlanner(specRepo clothing.SubcategorySpecRepository) *OutfitPlanner {
	return &OutfitPlanner{
		specRepo: specRepo,
	}
}

// OutfitPlan представляет план наряда
type OutfitPlan struct {
	Temperature      float64                             `json:"temperature"`       // Температура
	WeatherCondition string                              `json:"weather_condition"` // Погодные условия
	UserPreferences  map[string]interface{}              `json:"user_preferences"`  // Пользовательские предпочтения
	Plan             map[string][]domain.SubcategorySpec `json:"plan"`              // План наряда
}

// GeneratePlan генерирует план наряда на основе температуры, погодных условий и пользовательских предпочтений
func (p *OutfitPlanner) GeneratePlan(ctx context.Context, temperature float64, weatherCondition string, userPreferences map[string]interface{}) (*OutfitPlan, error) {
	specs, err := p.specRepo.ListAll(ctx)
	if err != nil {
		return nil, fmt.Errorf("не удалось получить спецификации подкатегорий: %w", err)
	}

	plan := make(map[string][]domain.SubcategorySpec)

	for _, spec := range specs {
		// Проверяем, находится ли температура в рекомендуемом диапазоне
		if float64(spec.TempMinReco) <= temperature && float64(spec.TempMaxReco) >= temperature {
			// Проверяем, подходят ли погодные условия
			weatherOK := p.isWeatherConditionAppropriate(spec, WeatherCondition(weatherCondition))
			if weatherOK {
				plan[spec.Category] = append(plan[spec.Category], spec)
			}
		}
	}

	// Сортируем подкатегории каждой категории по уровню теплоты (по убыванию) для предпочтений холодной погоды
	for category := range plan {
		categorySpecs := plan[category]
		// Простая пузырьковая сортировка по уровню теплоты (по убыванию)
		for i := 0; i < len(categorySpecs); i++ {
			for j := i + 1; j < len(categorySpecs); j++ {
				if categorySpecs[i].WarmthMin < categorySpecs[j].WarmthMin {
					categorySpecs[i], categorySpecs[j] = categorySpecs[j], categorySpecs[i]
				}
			}
		}
		// Оставляем только топ-3 для каждой категории, чтобы избежать слишком большого количества вариантов
		if len(categorySpecs) > 3 {
			plan[category] = categorySpecs[:3]
		}
	}

	return &OutfitPlan{
		Temperature:      temperature,
		WeatherCondition: weatherCondition,
		UserPreferences:  userPreferences,
		Plan:             plan,
	}, nil
}

// isWeatherConditionAppropriate проверяет, подходят ли погодные условия для спецификации
func (p *OutfitPlanner) isWeatherConditionAppropriate(spec domain.SubcategorySpec, weather WeatherCondition) bool {
	switch weather {
	case Rain, Drizzle:
		return spec.RainOK
	case Snow:
		return spec.SnowOK
	case Mist, Thunderstorm:
		return spec.RainOK
	default:
		// Для ясной погоды, облачности и т.д. считаем, что все подходит, если не исключено специально
		return true
	}
}
