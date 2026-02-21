// Пакет handlers содержит HTTP-обработчики для тестирования email шаблонов
package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"outfitstyle/server/internal/infrastructure/email"
)

// EmailTestHandler обработчик для тестирования email шаблонов
type EmailTestHandler struct {
	renderer *email.TemplateRenderer
}

// NewEmailTestHandler создает новый обработчик для тестирования email
func NewEmailTestHandler() (*EmailTestHandler, error) {
	renderer, err := email.NewTemplateRenderer()
	if err != nil {
		return nil, fmt.Errorf("failed to create template renderer: %w", err)
	}

	return &EmailTestHandler{
		renderer: renderer,
	}, nil
}

// RegisterRoutes регистрирует маршруты для тестирования email
func (h *EmailTestHandler) RegisterRoutes(r *mux.Router) {
	r.HandleFunc("/email/{template}", h.RenderTemplate).Methods(http.MethodGet)
	r.HandleFunc("/email/{template}/send", h.SendTestEmail).Methods(http.MethodPost)
}

// RenderTemplate рендерит указанный шаблон и возвращает HTML
// GET /api/v1/test/email/{template}
// Templates: welcome, password_reset, recommendation_ready, weather_alert, subscription_expiring, achievement
func (h *EmailTestHandler) RenderTemplate(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	templateName := vars["template"]

	var html string
	var err error

	data := email.TemplateData{
		Name:           "Александр",
		Year:           time.Now().Year(),
		AppUrl:         "https://outfitstyle.app",
		UnsubscribeUrl: "https://outfitstyle.app/unsubscribe",
		SupportUrl:     "https://outfitstyle.app/support",
		ResetUrl:       "https://outfitstyle.app/reset-password?token=test123",
		Email:          "test@example.com",
		Code:           "847291",
		ViewUrl:        "https://outfitstyle.app/recommendations/today",
		SettingsUrl:    "https://outfitstyle.app/settings/notifications",
		ViewOutfitsUrl: "https://outfitstyle.app/outfits",
		RenewUrl:       "https://outfitstyle.app/billing/renew",
		PlansUrl:       "https://outfitstyle.app/billing/plans",
		ViewProfileUrl: "https://outfitstyle.app/profile/achievements",
		ShareUrl:       "https://outfitstyle.app/share/achievement/123",
	}

	switch templateName {
	case "welcome":
		html, err = h.renderer.RenderWelcome(data)

	case "password_reset":
		html, err = h.renderer.RenderPasswordReset(data)

	case "recommendation_ready":
		data.WeatherCondition = "Солнечно"
		data.WeatherIcon = "☀️"
		data.Temperature = "+22°C"
		data.Location = "Москва"
		data.WeatherDescription = "Ясно, без осадков"
		data.Date = "21 февраля 2026"
		data.OutfitCount = 3
		data.Outfits = []email.Outfit{
			{Name: "Деловой стиль", Icon: "👔", Occasion: "Работа", MatchScore: 95},
			{Name: "Кэжуал лук", Icon: "👕", Occasion: "Прогулка", MatchScore: 88},
			{Name: "Вечерний образ", Icon: "🌙", Occasion: "Ужин", MatchScore: 92},
		}
		data.Tips = []string{
			"Лёгкая куртка пригодится к вечеру",
			"Солнцезащитные очки будут кстати",
			"Выбирайте дышащие ткани",
		}
		html, err = h.renderer.RenderRecommendationReady(data)

	case "weather_alert":
		data.AlertTitle = "Сильный дождь и ветер"
		data.AlertIcon = "🌧️"
		data.WeatherCondition = "Дождь"
		data.WeatherIcon = "🌧️"
		data.Temperature = "+12°C"
		data.Location = "Санкт-Петербург"
		data.Date = "21 февраля 2026"
		data.WeatherDescription = "Ожидаются сильные осадки, порывы ветра до 15 м/с"
		data.AdditionalInfo = "Влажность: 85%, Давление: 742 мм рт.ст."
		data.WearThis = []string{
			"Водонепроницаемую куртку с капюшоном",
			"Резиновые сапоги или непромокаемую обувь",
			"Зонт с прочным каркасом",
			"Тёплый свитер или флиску",
		}
		data.Avoid = []string{
			"Замшевую и тканевую обувь",
			"Светлую одежду (будут видны брызги)",
			"Объёмные шарфы (могут намокнуть)",
		}
		data.HealthTips = []string{
			"Избегайте длительного пребывания на улице",
			"Держите ноги в тепле и сухости",
			"Пейте тёплые напитки для профилактики простуды",
		}
		html, err = h.renderer.RenderWeatherAlert(data)

	case "subscription_expiring":
		data.PlanName = "Premium"
		data.ExpiryDate = "28 февраля 2026"
		data.DaysLeft = 7
		data.PlanFeatures = []string{
			"Безлимитные рекомендации",
			"Приоритетная поддержка",
			"Расширенная аналитика гардероба",
			"Доступ к эксклюзивным функциям",
		}
		data.LoseFeatures = []string{
			"Доступ к премиум рекомендациям",
			"Персональные советы стилиста",
			"История образов за все время",
		}
		data.DiscountPercent = 20
		data.DiscountDays = 7
		html, err = h.renderer.RenderSubscriptionExpiring(data)

	case "achievement":
		data.AchievementName = "Модный гуру"
		data.AchievementIcon = "🌟"
		data.AchievementDescription = "Создайте 50 уникальных образов"
		data.AchievementTier = "Золотой уровень"
		data.PointsEarned = 500
		data.TotalPoints = 2450
		data.NextAchievementName = "Икона стиля"
		data.ProgressPercent = 75
		data.ProgressRemaining = "25 образов до следующего достижения"
		data.TotalAchievements = 12
		data.CurrentStreak = 14
		data.Rank = "Эксперт"
		html, err = h.renderer.RenderAchievement(data)

	default:
		http.Error(w, fmt.Sprintf("Unknown template: %s. Available: welcome, password_reset, recommendation_ready, weather_alert, subscription_expiring, achievement", templateName), http.StatusBadRequest)
		return
	}

	if err != nil {
		http.Error(w, fmt.Sprintf("Error rendering template: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(html))
}

// SendTestEmail отправляет тестовое email
// POST /api/v1/test/email/{template}/send
// Body: {"email": "test@example.com"}
func (h *EmailTestHandler) SendTestEmail(w http.ResponseWriter, r *http.Request) {
	// Эта функция требует интеграции с EmailService
	// Для безопасности требует API ключ или аутентификацию
	vars := mux.Vars(r)
	templateName := vars["template"]

	// В продакшене здесь должна быть проверка прав доступа
	// и реальная отправка через EmailService

	response := map[string]string{
		"status":   "not_implemented",
		"message":  "Для отправки тестового письма настройте EmailService и добавьте аутентификацию",
		"template": templateName,
		"hint":     "Используйте GET /api/v1/test/email/{template} для просмотра HTML шаблона",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotImplemented)
	json.NewEncoder(w).Encode(response)
}
