package domain

import "time"

// OutfitRating представляет оценку пользователем рекомендации одежды
// Рейтинг конвертируется из 1-5 звёзд в quality_score от -10 до +10
type OutfitRating struct {
	ID               int64      `json:"id"`                // Внутренний ID (BIGSERIAL)
	UserID           ID         `json:"user_id"`           // ID пользователя (UUID)
	RecommendationID ID         `json:"recommendation_id"` // ID рекомендации (UUID)
	OutfitItems      []int64    `json:"outfit_items"`      // ID вещей в наряде
	Rating           int        `json:"rating"`            // Оценка 1-5 звёзд
	QualityScore     int        `json:"quality_score"`     // Конвертированная оценка -10..+10
	Feedback         *string    `json:"feedback,omitempty"`// Текстовый отзыв
	ThermalFeedback  *string    `json:"thermal_feedback,omitempty"` // "too_hot", "too_cold", "just_right"
	CreatedAt        time.Time  `json:"created_at"`        // Время создания
}

// RecommendationQualityStats представляет агрегированную статистику качества рекомендации
type RecommendationQualityStats struct {
	RecommendationID   ID      `json:"recommendation_id"`   // ID рекомендации
	RatingCount        int64   `json:"rating_count"`        // Количество оценок
	AvgRating          float64 `json:"avg_rating"`          // Средний рейтинг (1-5)
	AvgQualityScore    float64 `json:"avg_quality_score"`   // Средний quality_score (-10..+10)
	MinRating          int     `json:"min_rating"`          // Минимальный рейтинг
	MaxRating          int     `json:"max_rating"`          // Максимальный рейтинг
	QualityScoreStdDev float64 `json:"quality_score_stddev"`// Стандартное отклонение
	PositiveCount      int64   `json:"positive_count"`      // Количество положительных (4-5)
	NegativeCount      int64   `json:"negative_count"`      // Количество отрицательных (1-2)
}

// UserRatingStats представляет статистику оценок пользователя
type UserRatingStats struct {
	UserID           ID      `json:"user_id"`            // ID пользователя
	TotalRatings     int64   `json:"total_ratings"`      // Всего оценок
	AvgRating        float64 `json:"avg_rating"`         // Средний рейтинг
	AvgQualityScore  float64 `json:"avg_quality_score"`  // Средний quality_score
	PositiveRatings  int64   `json:"positive_ratings"`   // Положительных оценок
	NegativeRatings  int64   `json:"negative_ratings"`   // Отрицательных оценок
	LastRatedAt      *time.Time `json:"last_rated_at"`   // Последняя оценка
}

// LowQualityItem представляет вещь с низким рейтингом для ML фильтрации
type LowQualityItem struct {
	ClothingItemID   int64   `json:"clothing_item_id"`    // ID вещи
	TimesInLowRating int64   `json:"times_in_low_rating"` // Сколько раз в нарядах с низким рейтингом
	AvgQualityScore  float64 `json:"avg_quality_score"`   // Средний quality_score
}

// RatingToQualityScore конвертирует оценку 1-5 звёзд в quality_score -10..+10
// Формула: (rating - 3) * 5
// 1 звезда → -10, 2 → -5, 3 → 0, 4 → 5, 5 → 10
func RatingToQualityScore(rating int) int {
	if rating < 1 || rating > 5 {
		return 0 // Защита от некорректных значений
	}
	return (rating - 3) * 5
}

// QualityScoreToRating конвертирует quality_score -10..+10 обратно в рейтинг 1-5
// Формула: (quality_score / 5) + 3
func QualityScoreToRating(qualityScore int) int {
	rating := (qualityScore / 5) + 3
	if rating < 1 {
		return 1
	}
	if rating > 5 {
		return 5
	}
	return rating
}

// IsValidRating проверяет корректность рейтинга 1-5
func IsValidRating(rating int) bool {
	return rating >= 1 && rating <= 5
}

// IsValidQualityScore проверяет корректность quality_score -10..+10
func IsValidQualityScore(score int) bool {
	return score >= -10 && score <= 10
}

// IsPositive возвращает true если оценка положительная (rating >= 4)
func (r *OutfitRating) IsPositive() bool {
	return r.Rating >= 4
}

// IsNegative возвращает true если оценка отрицательная (rating <= 2)
func (r *OutfitRating) IsNegative() bool {
	return r.Rating <= 2
}

// OutfitRatingCreateRequest запрос на создание оценки
type OutfitRatingCreateRequest struct {
	Rating          int     `json:"rating"`           // 1-5 звёзд
	OutfitItems     []int64 `json:"outfit_items"`     // ID вещей в наряде
	Feedback        *string `json:"feedback,omitempty"` // Текстовый отзыв
	ThermalFeedback *string `json:"thermal_feedback,omitempty"` // "too_hot", "too_cold", "just_right"
}

// OutfitRatingResponse ответ с информацией об оценке
type OutfitRatingResponse struct {
	ID               int64      `json:"id"`
	UserID           ID         `json:"user_id"`
	RecommendationID ID         `json:"recommendation_id"`
	OutfitItems      []int64    `json:"outfit_items"`
	Rating           int        `json:"rating"`
	QualityScore     int        `json:"quality_score"`
	Feedback         *string    `json:"feedback,omitempty"`
	ThermalFeedback  *string    `json:"thermal_feedback,omitempty"`
	CreatedAt        time.Time  `json:"created_at"`
}

// RecommendationQualityResponse ответ со статистикой качества рекомендации
type RecommendationQualityResponse struct {
	RecommendationID   ID      `json:"recommendation_id"`
	AvgRating          float64 `json:"avg_rating"`
	AvgQualityScore    float64 `json:"avg_quality_score"`
	RatingCount        int64   `json:"rating_count"`
	PositiveCount      int64   `json:"positive_count"`
	NegativeCount      int64   `json:"negative_count"`
	UserRating         *int    `json:"user_rating,omitempty"` // Оценка текущего пользователя (если есть)
}
