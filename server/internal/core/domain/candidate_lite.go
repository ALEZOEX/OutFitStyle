package domain

// CandidateLite — минимальный набор данных для ранжирования и сборки образа.
type CandidateLite struct {
	ID ID `json:"id"` // Уникальный идентификатор кандидата

	Category    string `json:"category"`    // Категория одежды (например, "top", "bottom", "outerwear")
	Subcategory string `json:"subcategory"` // Подкатегория одежды (например, "t-shirt", "jeans", "coat")

	Source string `json:"source"` // Источник одежды: user|partner|manual|synthetic

	// Климатические характеристики и ограничения
	MinTemp     *int `json:"min_temp,omitempty"`     // Минимальная температура комфорта (в градусах Цельсия)
	MaxTemp     *int `json:"max_temp,omitempty"`     // Максимальная температура комфорта (в градусах Цельсия)
	WarmthLevel *int `json:"warmth_level,omitempty"` // Уровень теплоты (0-10, где 0 - летняя одежда, 10 - зимняя)
	RainOK      bool `json:"rain_ok"`                // Подходит ли для дождливой погоды
	SnowOK      bool `json:"snow_ok"`                // Подходит ли для снежной погоды
	WindOK      bool `json:"wind_ok"`                // Подходит ли для ветреной погоды

	// Стилистические характеристики
	Style          string  `json:"style"`                     // Стиль одежды (например, "casual", "business", "sport")
	FormalityLevel *int    `json:"formality_level,omitempty"` // Уровень формальности (0-10, где 0 - максимально неформально, 10 - максимально формально)
	BaseColour     *string `json:"base_colour,omitempty"`     // Базовый цвет одежды
	Pattern        string  `json:"pattern"`                   // Узор/рисунок (например, "solid", "striped", "dotted", "floral")

	// Характеристики использования
	WearCount *int `json:"wear_count,omitempty"` // Количество носок (для анализа популярности)

	// Флаг, указывающий, является ли элемент частью гардероба пользователя
	IsFromWardrobe bool `json:"is_from_wardrobe"` // Является ли элемент частью личного гардероба пользователя
}
