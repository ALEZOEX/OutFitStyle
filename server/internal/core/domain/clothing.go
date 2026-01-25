package domain

import (
	"time"
)

// SubcategorySpec структура спецификации подкатегории одежды
type SubcategorySpec struct {
	Category    string `db:"category" json:"category"`       // Категория одежды (например, "top", "bottom", "outerwear")
	Subcategory string `db:"subcategory" json:"subcategory"` // Подкатегория одежды (например, "t-shirt", "jeans", "coat")

	WarmthMin   int16 `db:"warmth_min" json:"warmth_min"`       // Минимальный уровень теплоты для подкатегории (0-10)
	TempMinReco int16 `db:"temp_min_reco" json:"temp_min_reco"` // Рекомендуемая минимальная температура (в градусах Цельсия)
	TempMaxReco int16 `db:"temp_max_reco" json:"temp_max_reco"` // Рекомендуемая максимальная температура (в градусах Цельсия)

	RainOK bool `db:"rain_ok" json:"rain_ok"` // Подходит ли для дождливой погоды
	SnowOK bool `db:"snow_ok" json:"snow_ok"` // Подходит ли для снежной погоды
	WindOK bool `db:"wind_ok" json:"wind_ok"` // Подходит ли для ветреной погоды
}

// CatalogItem структура элемента каталога одежды
type CatalogItem struct {
	ID   int64  `db:"id" json:"id"`     // Уникальный идентификатор элемента
	Name string `db:"name" json:"name"` // Название элемента одежды

	Category    string `db:"category" json:"category"`       // Категория одежды (например, "top", "bottom", "outerwear")
	Subcategory string `db:"subcategory" json:"subcategory"` // Подкатегория одежды (например, "t-shirt", "jeans", "coat")
	Gender      string `db:"gender" json:"gender"`           // Пол (например, "male", "female", "unisex")

	Style      string `db:"style" json:"style"`                     // Стиль одежды (например, "casual", "business", "sport")
	Usage      string `db:"usage" json:"usage"`                     // Назначение использования (например, "work", "casual", "sports")
	Season     string `db:"season" json:"season"`                   // Сезон (например, "spring", "summer", "fall", "winter", "all")
	BaseColour string `db:"base_colour" json:"base_colour"`         // Базовый цвет одежды
	Formality  int16  `db:"formality_level" json:"formality_level"` // Уровень формальности (0-10, где 0 - максимально неформально, 10 - максимально формально)
	Warmth     int16  `db:"warmth_level" json:"warmth_level"`       // Уровень теплоты (0-10, где 0 - летняя одежда, 10 - зимняя)

	MinTemp int16 `db:"min_temp" json:"min_temp"` // Минимальная температура комфорта (в градусах Цельсия)
	MaxTemp int16 `db:"max_temp" json:"max_temp"` // Максимальная температура комфорта (в градусах Цельсия)

	Materials []string `db:"materials" json:"materials"` // Материалы (например, ["cotton", "wool", "polyester"])

	Fit     string `db:"fit" json:"fit"`         // Посадка/фасон (например, "slim", "regular", "loose")
	Pattern string `db:"pattern" json:"pattern"` // Узор/рисунок (например, "solid", "striped", "dotted", "floral")

	IconEmoji string `db:"icon_emoji" json:"icon_emoji"` // Эмодзи-иконка для отображения
	Source    string `db:"source" json:"source"`         // Источник одежды: user|partner|manual|synthetic
	IsOwned   bool   `db:"is_owned" json:"is_owned"`     // Является ли элемент собственностью пользователя

	CreatedAt time.Time `db:"created_at" json:"created_at"` // Дата создания элемента

	// Переведенные поля (не хранятся в БД, заполняются при необходимости)
	TranslatedName        string `db:"-" json:"translated_name,omitempty"`        // Переведенное название
	TranslatedCategory    string `db:"-" json:"translated_category,omitempty"`    // Переведенная категория
	TranslatedSubcategory string `db:"-" json:"translated_subcategory,omitempty"` // Переведенная подкатегория
	TranslatedStyle       string `db:"-" json:"translated_style,omitempty"`       // Переведенный стиль
	TranslatedUsage       string `db:"-" json:"translated_usage,omitempty"`       // Переведенное назначение использования
	TranslatedSeason      string `db:"-" json:"translated_season,omitempty"`      // Переведенный сезон
	TranslatedBaseColour  string `db:"-" json:"translated_base_colour,omitempty"` // Переведенный базовый цвет
	TranslatedFit         string `db:"-" json:"translated_fit,omitempty"`         // Переведенная посадка
	TranslatedPattern     string `db:"-" json:"translated_pattern,omitempty"`     // Переведенный узор
}

// WeatherData структура данных о погоде
type WeatherData struct {
	Temperature    float64         `json:"temperature"`     // Температура в градусах Цельсия
	FeelsLike      float64         `json:"feels_like"`      // Ощущаемая температура в градусах Цельсия
	Humidity       int             `json:"humidity"`        // Влажность в процентах
	WindSpeed      float64         `json:"wind_speed"`      // Скорость ветра в м/с
	Weather        string          `json:"weather"`         // Краткое описание погоды (например, "clear", "rain", "snow")
	WeatherMain    string          `json:"weather_main"`    // Основной тип погоды (например, "Clear", "Rain", "Snow")
	Description    string          `json:"description"`     // Подробное описание погоды
	Visibility     int             `json:"visibility"`      // Видимость в метрах
	Uvi            float64         `json:"uvi"`             // Ультрафиолетовый индекс
	Pressure       int             `json:"pressure"`        // Атмосферное давление в гПа
	Location       string          `json:"location"`        // Местоположение
	MinTemp        float64         `json:"min_temp"`        // Минимальная температура за день
	MaxTemp        float64         `json:"max_temp"`        // Максимальная температура за день
	WillRain       bool            `json:"will_rain"`       // Будет ли дождь
	WillSnow       bool            `json:"will_snow"`       // Будет ли снег
	HourlyForecast []WeatherHourly `json:"hourly_forecast"` // Прогноз почасовой погоды
}

// WeatherHourly структура почасового прогноза погоды
type WeatherHourly struct {
	Time         int64   `json:"time"`           // Время в формате Unix timestamp
	Temperature  float64 `json:"temperature"`    // Температура в градусах Цельсия
	FeelsLike    float64 `json:"feels_like"`     // Ощущаемая температура в градусах Цельсия
	Weather      string  `json:"weather"`        // Краткое описание погоды
	WeatherMain  string  `json:"weather_main"`   // Основной тип погоды
	Description  string  `json:"description"`    // Подробное описание погоды
	Rain         float64 `json:"rain,omitempty"` // Ожидаемое количество осадков в мм
	Snow         float64 `json:"snow,omitempty"` // Ожидаемое количество снега в мм
	ChanceOfRain float64 `json:"chance_of_rain"` // Вероятность дождя в процентах
	ChanceOfSnow float64 `json:"chance_of_snow"` // Вероятность снега в процентах
}

// ExtendedWeatherData структура расширенных данных о погоде
type ExtendedWeatherData struct {
	WeatherData
	City      string    `json:"city"`      // Город
	Country   string    `json:"country"`   // Страна
	Longitude float64   `json:"longitude"` // Долгота
	Latitude  float64   `json:"latitude"`  // Широта
	Sunrise   int64     `json:"sunrise"`   // Время восхода в формате Unix timestamp
	Sunset    int64     `json:"sunset"`    // Время заката в формате Unix timestamp
	Timestamp time.Time `json:"timestamp"` // Время получения данных
}

// HourlyWeather структура почасовой погоды
type HourlyWeather struct {
	Time         int64   `json:"time"`           // Время в формате Unix timestamp
	Temperature  float64 `json:"temperature"`    // Температура в градусах Цельсия
	FeelsLike    float64 `json:"feels_like"`     // Ощущаемая температура в градусах Цельсия
	Weather      string  `json:"weather"`        // Краткое описание погоды
	WeatherMain  string  `json:"weather_main"`   // Основной тип погоды
	Description  string  `json:"description"`    // Подробное описание погоды
	Rain         float64 `json:"rain,omitempty"` // Ожидаемое количество осадков в мм
	Snow         float64 `json:"snow,omitempty"` // Ожидаемое количество снега в мм
	ChanceOfRain float64 `json:"chance_of_rain"` // Вероятность дождя в процентах
	ChanceOfSnow float64 `json:"chance_of_snow"` // Вероятность снега в процентах
}

// RecommendationResponse структура ответа на запрос рекомендации
type RecommendationResponse struct {
	ID          ID                   `json:"id"`           // Уникальный идентификатор рекомендации
	UserID      ID                   `json:"user_id"`      // Идентификатор пользователя
	City        string               `json:"city"`         // Город, для которого создана рекомендация
	Weather     WeatherData          `json:"weather"`      // Данные о погоде
	Outfit      []RecommendationItem `json:"outfit"`       // Рекомендованный наряд
	CreatedAt   time.Time            `json:"created_at"`   // Время создания рекомендации
	Source      string               `json:"source"`       // Источник рекомендации (например, "ml", "rule_based")
	Score       float64              `json:"score"`        // Общий рейтинг рекомендации
	OutfitScore float64              `json:"outfit_score"` // Рейтинг наряда
	Algorithm   string               `json:"algorithm"`    // Алгоритм, использованный для генерации рекомендации
	Items       []RecommendationItem `json:"items"`        // Элементы рекомендованного наряда
	Location    string               `json:"location"`     // Местоположение
	Temperature float64              `json:"temperature"`  // Температура
	FeelsLike   float64              `json:"feels_like"`   // Ощущаемая температура
	WindSpeed   float64              `json:"wind_speed"`   // Скорость ветра
	MinTemp     float64              `json:"min_temp"`     // Минимальная температура
	MaxTemp     float64              `json:"max_temp"`     // Максимальная температура
	WillRain    bool                 `json:"will_rain"`    // Будет ли дождь
	WillSnow    bool                 `json:"will_snow"`    // Будет ли снег
	Humidity    int                  `json:"humidity"`     // Влажность
	Timestamp   time.Time            `json:"timestamp"`    // Временная метка
	MLPowered   bool                 `json:"ml_powered"`   // Использовалась ли машинное обучение
}

// RecommendationItem структура элемента рекомендации
type RecommendationItem struct {
	ID             ID      `json:"id"`               // Уникальный идентификатор элемента
	ClothingItemID ID      `json:"clothing_item_id"` // Идентификатор элемента одежды
	Category       string  `json:"category"`         // Категория одежды
	Name           string  `json:"name"`             // Название элемента
	Score          float64 `json:"score"`            // Рейтинг элемента
	IconEmoji      string  `json:"icon_emoji"`       // Эмодзи-иконка
	MLScore        float64 `json:"ml_score"`         // Рейтинг от ML-модели
	Confidence     float64 `json:"confidence"`       // Уверенность в рекомендации
}

// Recommendation структура рекомендации
type Recommendation struct {
	ID          ID                   `db:"id" json:"id"`                             // Уникальный идентификатор рекомендации
	UserID      ID                   `db:"user_id" json:"user_id"`                   // Идентификатор пользователя
	City        string               `db:"city" json:"city"`                         // Город, для которого создана рекомендация
	Weather     WeatherData          `db:"-" json:"weather"`                         // Данные о погоде
	CreatedAt   time.Time            `db:"created_at" json:"created_at"`             // Время создания рекомендации
	Source      string               `db:"source" json:"source"`                     // Источник рекомендации (например, "ml", "rule_based")
	Score       float64              `db:"score" json:"score"`                       // Общий рейтинг рекомендации
	OutfitScore float64              `db:"outfit_score" json:"outfit_score"`         // Рейтинг наряда
	Algorithm   string               `db:"algorithm" json:"algorithm"`               // Алгоритм, использованный для генерации рекомендации
	Location    string               `db:"location" json:"location"`                 // Местоположение
	Outfit      []RecommendationItem `db:"-" json:"outfit"`                          // Рекомендованный наряд
	Temperature *float64             `db:"temperature" json:"temperature,omitempty"` // Температура
	FeelsLike   *float64             `db:"feels_like" json:"feels_like,omitempty"`   // Ощущаемая температура
	WindSpeed   *float64             `db:"wind_speed" json:"wind_speed,omitempty"`   // Скорость ветра
	MinTemp     *float64             `db:"min_temp" json:"min_temp,omitempty"`       // Минимальная температура
	MaxTemp     *float64             `db:"max_temp" json:"max_temp,omitempty"`       // Максимальная температура
	WillRain    *bool                `db:"will_rain" json:"will_rain,omitempty"`     // Будет ли дождь
	WillSnow    *bool                `db:"will_snow" json:"will_snow,omitempty"`     // Будет ли снег
	Humidity    *int                 `db:"humidity" json:"humidity,omitempty"`       // Влажность
	Timestamp   *time.Time           `db:"timestamp" json:"timestamp,omitempty"`     // Временная метка
	MLPowered   *bool                `db:"ml_powered" json:"ml_powered,omitempty"`   // Использовалась ли машинное обучение
	Items       []RecommendationItem `db:"-" json:"items"`                           // Элементы рекомендованного наряда
}

// RecommendationItemEntity структура элемента рекомендации в базе данных
type RecommendationItemEntity struct {
	ID               ID        `db:"id" json:"id"`                               // Уникальный идентификатор элемента
	RecommendationID ID        `db:"recommendation_id" json:"recommendation_id"` // Идентификатор рекомендации
	ClothingItemID   ID        `db:"clothing_item_id" json:"clothing_item_id"`   // Идентификатор элемента одежды
	Score            float64   `db:"score" json:"score"`                         // Рейтинг элемента
	Category         string    `db:"category" json:"category"`                   // Категория одежды
	CreatedAt        time.Time `db:"created_at" json:"created_at"`               // Время создания элемента
}

// MarketItem структура товара из маркетплейса
type MarketItem struct {
	ID         int64   `json:"id"`          // Уникальный идентификатор товара
	Name       string  `json:"name"`        // Название товара
	Price      float64 `json:"price"`       // Цена товара
	URL        string  `json:"url"`         // URL товара на маркетплейсе
	ImageURL   string  `json:"image_url"`   // URL изображения товара
	Store      string  `json:"store"`       // Название магазина/маркетплейса
	MatchScore float64 `json:"match_score"` // Оценка соответствия рекомендации (0-1)
}

// MarketplaceMatch структура соответствия между рекомендацией и товарами на маркетплейсе
type MarketplaceMatch struct {
	RecommendedItemID int64        `json:"recommended_item_id"` // Идентификатор рекомендованного элемента
	MarketItems       []MarketItem `json:"market_items"`        // Список соответствующих товаров на маркетплейсе
}

// ClothingItemFilters структура фильтров для поиска элементов одежды
type ClothingItemFilters struct {
	Category    *string  `json:"category,omitempty"`    // Фильтр по категории одежды
	Subcategory *string  `json:"subcategory,omitempty"` // Фильтр по подкатегории одежды
	Gender      *string  `json:"gender,omitempty"`      // Фильтр по полу
	Style       *string  `json:"style,omitempty"`       // Фильтр по стилю
	MinWarmth   *int16   `json:"min_warmth,omitempty"`  // Минимальный уровень теплоты (0-10)
	MaxWarmth   *int16   `json:"max_warmth,omitempty"`  // Максимальный уровень теплоты (0-10)
	Season      *string  `json:"season,omitempty"`      // Фильтр по сезону
	Materials   []string `json:"materials,omitempty"`   // Фильтр по материалам
	Colors      []string `json:"colors,omitempty"`      // Фильтр по цветам
	MinTemp     *int16   `json:"min_temp,omitempty"`    // Минимальная температура комфорта
	MaxTemp     *int16   `json:"max_temp,omitempty"`    // Максимальная температура комфорта
}

// FavoriteOutfit структура избранного наряда
type FavoriteOutfit struct {
	ID         int64     `db:"id" json:"id"`                   // Уникальный идентификатор избранного наряда
	UserID     int64     `db:"user_id" json:"user_id"`         // Идентификатор пользователя
	Name       string    `db:"name" json:"name"`               // Название наряда
	Items      []int64   `db:"-" json:"items"`                 // Список идентификаторов элементов одежды
	CreatedAt  time.Time `db:"created_at" json:"created_at"`   // Дата создания наряда
	SharedWith []int64   `db:"-" json:"shared_with,omitempty"` // Список идентификаторов пользователей, с которыми поделились
}

// UserRating структура оценки пользователя
type UserRating struct {
	ID        int64     `db:"id" json:"id"`                     // Уникальный идентификатор оценки
	UserID    int64     `db:"user_id" json:"user_id"`           // Идентификатор пользователя
	OutfitID  int64     `db:"outfit_id" json:"outfit_id"`       // Идентификатор наряда
	Rating    int       `db:"rating" json:"rating"`             // Оценка (1-5 звезд)
	Comment   *string   `db:"comment" json:"comment,omitempty"` // Комментарий к оценке
	CreatedAt time.Time `db:"created_at" json:"created_at"`     // Дата создания оценки
}

// OutfitPlan структура плана наряда
type OutfitPlan struct {
	ID          int64     `db:"id" json:"id"`                   // Уникальный идентификатор плана
	UserID      int64     `db:"user_id" json:"user_id"`         // Идентификатор пользователя
	Date        time.Time `db:"date" json:"date"`               // Дата, на которую запланирован наряд
	OutfitItems []int64   `db:"-" json:"outfit_items"`          // Список идентификаторов элементов одежды
	Notes       *string   `db:"notes" json:"notes,omitempty"`   // Примечания к плану
	CreatedAt   time.Time `db:"created_at" json:"created_at"`   // Дата создания плана
	ModifiedAt  time.Time `db:"modified_at" json:"modified_at"` // Дата последнего изменения плана
}

// VerificationCode структура кода верификации
type VerificationCode struct {
	ID        int64      `db:"id" json:"id"`                     // Уникальный идентификатор кода
	UserID    int64      `db:"user_id" json:"user_id"`           // Идентификатор пользователя
	Code      string     `db:"code" json:"code"`                 // Текст кода верификации
	Type      string     `db:"code_type" json:"type"`            // Тип кода (например, "email_verification", "password_reset")
	ExpiresAt time.Time  `db:"expires_at" json:"expires_at"`     // Время истечения срока действия
	CreatedAt time.Time  `db:"created_at" json:"created_at"`     // Дата создания кода
	UsedAt    *time.Time `db:"used_at" json:"used_at,omitempty"` // Время использования (если код уже использован)
}

// RecommendationRequest структура запроса рекомендации
type RecommendationRequest struct {
	UserID            int64              `json:"user_id"`               // Идентификатор пользователя
	City              string             `json:"city"`                  // Город
	Country           string             `json:"country"`               // Страна
	Latitude          float64            `json:"latitude"`              // Широта
	Longitude         float64            `json:"longitude"`             // Долгота
	TargetDate        *time.Time         `json:"target_date,omitempty"` // Целевая дата для планирования нарядов заранее
	Purpose           string             `json:"purpose"`               // Назначение ("work", "casual", "party", и т.д.)
	Formality         *int               `json:"formality,omitempty"`   // Уровень формальности (1-5)
	Gender            string             `json:"gender"`                // Пол для гендерно-специфичных рекомендаций
	ExcludeItems      []int64            `json:"exclude_items"`         // Идентификаторы элементов для исключения из рекомендаций
	PreferenceWeights map[string]float64 `json:"preference_weights"`    // Пользовательские веса для различных критериев
	WeatherData       WeatherData        `json:"weather_data"`          // Данные о погоде
}
