package domain

// CatalogFilters структура для фильтрации каталога одежды
type CatalogFilters struct {
	Categories    []string `json:"categories,omitempty"`    // Фильтр по категориям одежды (например, ["top", "bottom", "outerwear"])
	Subcategories []string `json:"subcategories,omitempty"` // Фильтр по подкатегориям одежды (например, ["t-shirt", "jeans", "coat"])
	Genders       []string `json:"genders,omitempty"`       // Фильтр по полу (например, ["male", "female", "unisex"])
	Styles        []string `json:"styles,omitempty"`        // Фильтр по стилю (например, ["casual", "business", "sport"])
	Seasons       []string `json:"seasons,omitempty"`       // Фильтр по сезону (например, ["spring", "summer", "fall", "winter", "all"])
	MinTemp       *float64 `json:"min_temp,omitempty"`      // Минимальная температура комфорта (в градусах Цельсия)
	MaxTemp       *float64 `json:"max_temp,omitempty"`      // Максимальная температура комфорта (в градусах Цельсия)
	MinWarmth     *int     `json:"min_warmth,omitempty"`    // Минимальный уровень теплоты (0-10, где 0 - летняя одежда, 10 - зимняя)
	MaxWarmth     *int     `json:"max_warmth,omitempty"`    // Максимальный уровень теплоты (0-10, где 0 - летняя одежда, 10 - зимняя)
	MinFormality  *int     `json:"min_formality,omitempty"` // Минимальный уровень формальности (0-10, где 0 - максимально неформально, 10 - максимально формально)
	MaxFormality  *int     `json:"max_formality,omitempty"` // Максимальный уровень формальности (0-10, где 0 - максимально неформально, 10 - максимально формально)
	Colors        []string `json:"colors,omitempty"`        // Фильтр по цветам (например, ["red", "blue", "black"])
	Materials     []string `json:"materials,omitempty"`     // Фильтр по материалам (например, ["cotton", "wool", "polyester"])
	Availability  *bool    `json:"availability,omitempty"`  // Фильтр по доступности (true - в наличии, false - под заказ)
	Page          int      `json:"page,omitempty"`          // Номер страницы для пагинации (по умолчанию 1)
	Limit         int      `json:"limit,omitempty"`         // Количество элементов на странице (по умолчанию 20, максимум 100)
}