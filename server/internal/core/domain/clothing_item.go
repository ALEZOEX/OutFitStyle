package domain

import "time"

// ClothingItem структура для представления элемента одежды
type ClothingItem struct {
	ID          ID      `json:"id"`                    // Уникальный идентификатор элемента одежды
	Name        string  `json:"name"`                  // Название элемента одежды
	Description *string `json:"description,omitempty"` // Описание элемента одежды (опционально)

	Category    string `json:"category"`    // Категория одежды (например, "top", "bottom", "outerwear")
	Subcategory string `json:"subcategory"` // Подкатегория одежды (например, "t-shirt", "jeans", "coat")

	// Климатические характеристики
	MinTemp     *int16 `json:"min_temp,omitempty"`      // Минимальная температура комфорта (в градусах Цельсия)
	MaxTemp     *int16 `json:"max_temp,omitempty"`      // Максимальная температура комфорта (в градусах Цельсия)
	WarmthLevel *int16 `json:"warmth_level,omitempty"`  // Уровень теплоты (0-10, где 0 - летняя одежда, 10 - зимняя)

	// Погодные характеристики
	RainOK bool `json:"rain_ok"` // Подходит ли для дождливой погоды
	SnowOK bool `json:"snow_ok"` // Подходит ли для снежной погоды
	WindOK bool `json:"wind_ok"` // Подходит ли для ветреной погоды

	// Стилистические характеристики
	Style          string  `json:"style"`                    // Стиль одежды (например, "casual", "business", "sport")
	FormalityLevel *int16  `json:"formality_level,omitempty"` // Уровень формальности (0-10, где 0 - максимально неформально, 10 - максимально формально)
	BaseColour     *string `json:"base_colour,omitempty"`     // Базовый цвет одежды
	Pattern        string  `json:"pattern"`                   // Узор/рисунок (например, "solid", "striped", "dotted", "floral")
	Fit            string  `json:"fit"`                       // Посадка/фасон (например, "slim", "regular", "loose")

	// Демографические характеристики
	Gender string `json:"gender"` // Пол (например, "male", "female", "unisex")
	Season string `json:"season"` // Сезон (например, "spring", "summer", "fall", "winter", "all")

	// Дополнительные характеристики
	Usage     []string `json:"usage,omitempty"`     // Назначение использования (например, ["work", "casual", "sports", "formal"])
	Materials []string `json:"materials,omitempty"` // Материалы (например, ["cotton", "wool", "polyester"])

	Brand *string `json:"brand,omitempty"` // Бренд одежды (опционально)

	// Визуальные атрибуты
	ImageURL     *string `json:"image_url,omitempty"`      // URL полноразмерного изображения
	ThumbnailURL *string `json:"thumbnail_url,omitempty"`  // URL миниатюры изображения
	IconEmoji    *string `json:"icon_emoji,omitempty"`     // Эмодзи-иконка для отображения

	// Информация о владельце и источнике
	Source  string `json:"source"`            // Источник одежды: user|partner|manual|synthetic (enum clothing_source в БД)
	OwnerID *ID    `json:"owner_id,omitempty"` // Идентификатор владельца (если элемент принадлежит конкретному пользователю)
	IsOwned bool   `json:"is_owned"`          // Является ли элемент собственностью пользователя

	// Статус и даты
	IsActive  bool      `json:"is_active"`   // Активен ли элемент
	CreatedAt time.Time `json:"created_at"`  // Дата создания
	UpdatedAt time.Time `json:"updated_at"`  // Дата последнего обновления

	// Переведенные поля (не хранятся в БД, заполняются при необходимости)
	TranslatedName        string `json:"translated_name,omitempty"`         // Переведенное название
	TranslatedCategory    string `json:"translated_category,omitempty"`     // Переведенная категория
	TranslatedSubcategory string `json:"translated_subcategory,omitempty"`  // Переведенная подкатегория
	TranslatedStyle       string `json:"translated_style,omitempty"`        // Переведенный стиль
	TranslatedUsage       string `json:"translated_usage,omitempty"`        // Переведенное назначение использования
	TranslatedSeason      string `json:"translated_season,omitempty"`       // Переведенный сезон
	TranslatedBaseColour  string `json:"translated_base_colour,omitempty"`  // Переведенный базовый цвет
	TranslatedFit         string `json:"translated_fit,omitempty"`          // Переведенная посадка
	TranslatedPattern     string `json:"translated_pattern,omitempty"`      // Переведенный узор
}
