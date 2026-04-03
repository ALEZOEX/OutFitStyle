package domain

import (
	"encoding/json"
	"time"
)

// RecommendationRecord — то, что мы храним в таблице recommendations по ТЗ.
type RecommendationRecord struct {
	ID     ID `json:"id"`
	UserID ID `json:"user_id"`

	Location  *string  `json:"location,omitempty"`
	Latitude  *float64 `json:"latitude,omitempty"`
	Longitude *float64 `json:"longitude,omitempty"`

	Occasion           *string `json:"occasion,omitempty"`
	RequestedStyle     *string `json:"requested_style,omitempty"`
	RequestedFormality *int    `json:"requested_formality,omitempty"`

	WeatherData json.RawMessage `json:"weather_data"`
	OutfitData  json.RawMessage `json:"outfit_data"`

	TotalScore     *float64 `json:"total_score,omitempty"`
	StyleCoherence *float64 `json:"style_coherence,omitempty"`
	ColorHarmony   *float64 `json:"color_harmony,omitempty"`
	WeatherMatch   *float64 `json:"weather_match,omitempty"`

	ModelVersion     *string `json:"model_version,omitempty"`
	ProcessingTimeMs *int    `json:"processing_time_ms,omitempty"`
	ABTestVariant    *string `json:"ab_test_variant,omitempty"`

	UserRating      *int       `json:"user_rating,omitempty"`
	UserFeedback    *string    `json:"user_feedback,omitempty"`
	ThermalFeedback *string    `json:"thermal_feedback,omitempty"`
	RatedAt         *time.Time `json:"rated_at,omitempty"`

	City        *string              `json:"city,omitempty"`         // Город, для которого создана рекомендация
	Source      *string              `json:"source,omitempty"`       // Источник рекомендации (например, "ml", "rule_based")
	Score       *float64             `json:"score,omitempty"`        // Общий рейтинг рекомендации
	OutfitScore *float64             `json:"outfit_score,omitempty"` // Рейтинг наряда
	Algorithm   *string              `json:"algorithm,omitempty"`    // Алгоритм, использованный для генерации рекомендации
	Temperature *float64             `json:"temperature,omitempty"`  // Температура
	FeelsLike   *float64             `json:"feels_like,omitempty"`   // Ощущаемая температура
	WindSpeed   *float64             `json:"wind_speed,omitempty"`   // Скорость ветра
	MinTemp     *float64             `json:"min_temp,omitempty"`     // Минимальная температура
	MaxTemp     *float64             `json:"max_temp,omitempty"`     // Максимальная температура
	WillRain    *bool                `json:"will_rain,omitempty"`    // Будет ли дождь
	WillSnow    *bool                `json:"will_snow,omitempty"`    // Будет ли снег
	Humidity    *int                 `json:"humidity,omitempty"`     // Влажность
	Timestamp   *time.Time           `json:"timestamp,omitempty"`    // Временная метка
	Weather     *WeatherData         `json:"weather,omitempty"`             // Данные о погоде
	Outfit      []RecommendationItem `json:"outfit,omitempty"`              // Рекомендованный наряд
	Items       []RecommendationItem `json:"-"`   // Элементы рекомендованного наряда (загружаются отдельно)

	MLPowered *bool `json:"ml_powered,omitempty"` // Использовалась ли машинное обучение

	Status     *string   `json:"status,omitempty"` // Статус рекомендации (например, "processing", "completed", "failed")
	IsFavorite bool      `json:"is_favorite"`
	CreatedAt  time.Time `json:"created_at"`
}

// MarshalJSON кастомная сериализация для Flutter
func (r RecommendationRecord) MarshalJSON() ([]byte, error) {
	names := make([]string, len(r.Items))
	for i, item := range r.Items {
		if item.Name != "" {
			names[i] = item.Name
		} else {
			names[i] = "Предмет"
		}
	}
	return json.Marshal(map[string]any{
		"id":                r.ID,
		"user_id":           r.UserID,
		"created_at":        r.CreatedAt,
		"city":              r.City,
		"is_favorite":       r.IsFavorite,
		"temperature":       r.Temperature,
		"weather":           r.Weather,
		"ml_powered":        r.MLPowered,
		"recommended_items": names,
		"title":             "Образ на " + r.CreatedAt.Format("02.01"),
		"description":       "Подобрано автоматически",
	})
}
