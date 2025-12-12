package planner

import (
	"context"
	"fmt"
	"outfit-style-rec/server/internal/core/domain"
	"outfit-style-rec/server/internal/core/repo"
)

type WeatherCondition string

const (
	Clear        WeatherCondition = "clear"
	Clouds       WeatherCondition = "clouds"
	Rain         WeatherCondition = "rain"
	Drizzle      WeatherCondition = "drizzle"
	Snow         WeatherCondition = "snow"
	Mist         WeatherCondition = "mist"
	Thunderstorm WeatherCondition = "thunderstorm"
)

type OutfitPlanner struct {
	specRepo repo.SubcategorySpecRepository
}

func NewOutfitPlanner(specRepo repo.SubcategorySpecRepository) *OutfitPlanner {
	return &OutfitPlanner{
		specRepo: specRepo,
	}
}

type OutfitPlan struct {
	Temperature     float64                           `json:"temperature"`
	WeatherCondition string                           `json:"weather_condition"`
	UserPreferences map[string]interface{}           `json:"user_preferences"`
	Plan           map[string][]domain.SubcategorySpec `json:"plan"`
}

func (p *OutfitPlanner) GeneratePlan(ctx context.Context, temperature float64, weatherCondition string, userPreferences map[string]interface{}) (*OutfitPlan, error) {
	specs, err := p.specRepo.ListAll(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get subcategory specs: %w", err)
	}

	plan := make(map[string][]domain.SubcategorySpec)
	
	for _, spec := range specs {
		// Check if temperature is within recommended range
		if float64(spec.TempMinReco) <= temperature && float64(spec.TempMaxReco) >= temperature {
			// Check weather condition appropriateness
			weatherOK := p.isWeatherConditionAppropriate(spec, WeatherCondition(weatherCondition))
			if weatherOK {
				plan[spec.Category] = append(plan[spec.Category], spec)
			}
		}
	}
	
	// Sort each category's subcategories by warmth level (descending) for cold weather preference
	for category := range plan {
		categorySpecs := plan[category]
		// Simple bubble sort by warmth level (descending)
		for i := 0; i < len(categorySpecs); i++ {
			for j := i + 1; j < len(categorySpecs); j++ {
				if categorySpecs[i].WarmthMin < categorySpecs[j].WarmthMin {
					categorySpecs[i], categorySpecs[j] = categorySpecs[j], categorySpecs[i]
				}
			}
		}
		// Keep only top 3 for each category to avoid too many options
		if len(categorySpecs) > 3 {
			plan[category] = categorySpecs[:3]
		}
	}

	return &OutfitPlan{
		Temperature:      temperature,
		WeatherCondition: weatherCondition,
		UserPreferences:  userPreferences,
		Plan:            plan,
	}, nil
}

func (p *OutfitPlanner) isWeatherConditionAppropriate(spec domain.SubcategorySpec, weather WeatherCondition) bool {
	switch weather {
	case Rain, Drizzle:
		return spec.RainOK
	case Snow:
		return spec.SnowOK
	case Mist, Thunderstorm:
		return spec.RainOK
	default:
		// For clear, clouds, etc., assume all are OK unless specifically excluded
		return true
	}
}