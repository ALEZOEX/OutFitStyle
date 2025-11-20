package domain

import "time"

// Базовый ID, которым пользуемся в домене
type ID int64

// Обёртка для типовых ответов
type Response[T any] struct {
	Data T    `json:"data"`
	Meta Meta `json:"meta"`
}

type Meta struct {
	Total int `json:"total"`
}

// Универсальная ошибка приложения
type AppError struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

// --------------------
// Пользователь и профиль
// --------------------

type User struct {
	ID         ID        `json:"id"`
	Email      string    `json:"email"`
	Username   string    `json:"username"`
	Password   string    `json:"-"` // не сериализуем пароль
	AvatarURL  string    `json:"avatar_url"`
	IsVerified bool      `json:"is_verified"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type UserProfile struct {
	ID                     ID        `json:"id"`
	UserID                 ID        `json:"user_id"`
	StylePreferences       string    `json:"style_preferences,omitempty"`
	Size                   string    `json:"size,omitempty"`
	Height                 int       `json:"height,omitempty"`
	Weight                 int       `json:"weight,omitempty"`
	PreferredColors        []string  `json:"preferred_colors,omitempty"`
	DislikedColors         []string  `json:"disliked_colors,omitempty"`
	AgeRange               string    `json:"age_range,omitempty"`
	StylePreference        string    `json:"style_preference,omitempty"`
	TemperatureSensitivity string    `json:"temperature_sensitivity,omitempty"`
	FormalityPreference    string    `json:"formality_preference,omitempty"`
	CreatedAt              time.Time `json:"created_at"`
	UpdatedAt              time.Time `json:"updated_at"`
}

type UserRegistration struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=8"`
	Username string `json:"username" validate:"required"`
}

type VerificationCode struct {
	Code      string    `json:"code"`
	UserID    ID        `json:"user_id"`
	ExpiresAt time.Time `json:"expires_at"`
	Type      string    `json:"type"` // "registration" | "login" | "reset"
}

// --------------------
// Погода
// --------------------

type HourlyWeather struct {
	Time            string  `json:"time"`             // ISO8601
	Temperature     float64 `json:"temperature"`      // C°
	Weather         string  `json:"weather"`          // "Clear", "Rain" и т.п.
	RainProbability float64 `json:"rain_probability"` // 0..1
}

type WeatherData struct {
	Location       string          `json:"location"`
	Temperature    float64         `json:"temperature"`
	FeelsLike      float64         `json:"feels_like"`
	Weather        string          `json:"weather"`
	Humidity       int             `json:"humidity"`
	WindSpeed      float64         `json:"wind_speed"`
	MinTemp        float64         `json:"min_temp"`
	MaxTemp        float64         `json:"max_temp"`
	WillRain       bool            `json:"will_rain"`
	WillSnow       bool            `json:"will_snow"`
	HourlyForecast []HourlyWeather `json:"hourly_forecast"`
}

type ExtendedWeatherData struct {
	WeatherData
	Timestamp time.Time `json:"timestamp"`
}

// --------------------
// Одежда и рекомендации
// --------------------

type ClothingItem struct {
	ID                 ID      `json:"id"`
	UserID             ID      `json:"user_id"`
	Name               string  `json:"name"`
	Category           string  `json:"category"`
	Subcategory        string  `json:"subcategory,omitempty"`
	IconEmoji          string  `json:"icon_emoji"`
	MLScore            float64 `json:"ml_score,omitempty"`
	Confidence         float64 `json:"confidence,omitempty"`
	WeatherSuitability string  `json:"weather_suitability,omitempty"`
}

// OutfitSet представляет комплект одежды (набор вещей).
type OutfitSet struct {
	ID          ID             `json:"id"`
	UserID      ID             `json:"user_id"`
	Name        string         `json:"name"`
	Description string         `json:"description,omitempty"`
	Items       []ClothingItem `json:"items"`
	Confidence  float64        `json:"confidence,omitempty"`
	Reason      string         `json:"reason,omitempty"`
	CreatedAt   time.Time      `json:"created_at"`
}

// Запрос на генерацию рекомендации
type RecommendationRequest struct {
	UserID      ID           `json:"user_id"`
	WeatherData WeatherData  `json:"weather_data"`
	UserProfile *UserProfile `json:"user_profile,omitempty"`
}

// Ответ рекомендации (для API/сервиса)
type RecommendationResponse struct {
	ID             ID              `json:"id"`
	UserID         ID              `json:"user_id"`
	Location       string          `json:"location"`
	Temperature    float64         `json:"temperature"`
	FeelsLike      float64         `json:"feels_like"`
	Weather        string          `json:"weather"`
	Humidity       int             `json:"humidity"`
	WindSpeed      float64         `json:"wind_speed"`
	MinTemp        float64         `json:"min_temp"`
	MaxTemp        float64         `json:"max_temp"`
	WillRain       bool            `json:"will_rain"`
	WillSnow       bool            `json:"will_snow"`
	HourlyForecast []HourlyWeather `json:"hourly_forecast"`
	Items          []ClothingItem  `json:"items"`
	OutfitScore    float64         `json:"outfit_score"`
	MLPowered      bool            `json:"ml_powered"`
	Algorithm      string          `json:"algorithm"`
	Timestamp      time.Time       `json:"timestamp"`
}

// --------------------
// Оценки, избранное, ачивки
// --------------------

type UserRating struct {
	ID               ID        `json:"id"`
	UserID           ID        `json:"user_id"`
	RecommendationID ID        `json:"recommendation_id"`
	Rating           int       `json:"rating"` // 1..5
	Feedback         string    `json:"feedback,omitempty"`
	CreatedAt        time.Time `json:"created_at"`
}

type FavoriteOutfit struct {
	ID               ID        `json:"id"`
	UserID           ID        `json:"user_id"`
	RecommendationID ID        `json:"recommendation_id"`
	CreatedAt        time.Time `json:"created_at"`
}

type Achievement struct {
	ID          ID        `json:"id"`
	Code        string    `json:"code"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Icon        string    `json:"icon"`
	CreatedAt   time.Time `json:"created_at"`
}

type UserAchievement struct {
	ID            ID        `json:"id"`
	UserID        ID        `json:"user_id"`
	AchievementID ID        `json:"achievement_id"`
	UnlockedAt    time.Time `json:"unlocked_at"`
}

// --------------------
// Планы нарядов и маркетплейс
// --------------------

type OutfitPlan struct {
	ID        ID        `json:"id"`
	UserID    ID        `json:"user_id"`
	Date      time.Time `json:"date"`
	ItemIDs   []int     `json:"item_ids"`
	Notes     string    `json:"notes,omitempty"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type MarketItem struct {
	ID           ID      `json:"id"`
	Name         string  `json:"name"`
	Price        float64 `json:"price"`
	Currency     string  `json:"currency"`
	Brand        string  `json:"brand"`
	Category     string  `json:"category"`
	ImageURL     string  `json:"image_url"`
	ProductURL   string  `json:"product_url"`
	AffiliateURL string  `json:"affiliate_url,omitempty"`
	Commission   float64 `json:"commission,omitempty"`
}

type MarketplaceMatch struct {
	ClothingItem ClothingItem `json:"clothing_item"`
	Matches      []MarketItem `json:"matches"`
	Confidence   float64      `json:"confidence"`
}

// --------------------
// Статистика пользователя
// --------------------

type UserStats struct {
	TotalRecommendations int       `json:"total_recommendations"`
	AverageRating        float64   `json:"average_rating"`
	FavoriteCount        int       `json:"favorite_count"`
	AchievementCount     int       `json:"achievement_count"`
	LastActive           time.Time `json:"last_active"`
	MostUsedCategory     string    `json:"most_used_category"`
}
