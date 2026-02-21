// Пакет email предоставляет сервисы для отправки электронной почты
package email

import (
	"bytes"
	"embed"
	"fmt"
	"html/template"
	"time"
)

//go:embed templates/*.html
var templateFiles embed.FS

// TemplateRenderer отвечает за рендеринг HTML шаблонов писем
type TemplateRenderer struct {
	templates *template.Template
}

// Outfit представляет информацию об образе в шаблоне
type Outfit struct {
	Name       string // Название образа
	Icon       string // Emoji иконка
	Occasion   string // Случай (работа, прогулка, etc.)
	MatchScore int    // Процент совпадения
}

// TemplateData содержит данные для рендеринга всех шаблонов
type TemplateData struct {
	// Общие поля
	Name           string
	Year           int
	AppUrl         string
	UnsubscribeUrl string
	SupportUrl     string

	// Password reset
	Email    string
	Code     string
	ResetUrl string

	// Recommendation ready
	WeatherCondition   string
	WeatherIcon        string
	Temperature        string
	Location           string
	WeatherDescription string
	Date               string
	OutfitCount        int
	Outfits            []Outfit
	Tips               []string
	ViewUrl            string
	SettingsUrl        string

	// Weather alert
	AlertTitle     string
	AlertIcon      string
	AdditionalInfo string
	WearThis       []string
	Avoid          []string
	HealthTips     []string
	ViewOutfitsUrl string

	// Subscription expiring
	PlanName        string
	ExpiryDate      string
	DaysLeft        int
	PlanFeatures    []string
	LoseFeatures    []string
	DiscountPercent int
	DiscountDays    int
	RenewUrl        string
	PlansUrl        string

	// Achievement
	AchievementName        string
	AchievementIcon        string
	AchievementDescription string
	AchievementTier        string
	PointsEarned           int
	TotalPoints            int
	NextAchievementName    string
	ProgressPercent        int
	ProgressRemaining      string
	TotalAchievements      int
	CurrentStreak          int
	Rank                   string
	ViewProfileUrl         string
	ShareUrl               string
}

// NewTemplateRenderer создает новый экземпляр рендерера шаблонов
func NewTemplateRenderer() (*TemplateRenderer, error) {
	funcMap := template.FuncMap{
		"year": func() int {
			return time.Now().Year()
		},
	}

	tmpl, err := template.New("email").Funcs(funcMap).ParseFS(templateFiles, "templates/*.html")
	if err != nil {
		return nil, fmt.Errorf("failed to parse templates: %w", err)
	}

	return &TemplateRenderer{
		templates: tmpl,
	}, nil
}

// RenderWelcome рендерит шаблон приветственного письма
func (r *TemplateRenderer) RenderWelcome(data TemplateData) (string, error) {
	return r.render("templates/welcome.html", data)
}

// RenderPasswordReset рендерит шаблон сброса пароля
func (r *TemplateRenderer) RenderPasswordReset(data TemplateData) (string, error) {
	return r.render("templates/password_reset.html", data)
}

// RenderRecommendationReady рендерит шаблон готовности рекомендации
func (r *TemplateRenderer) RenderRecommendationReady(data TemplateData) (string, error) {
	return r.render("templates/recommendation_ready.html", data)
}

// RenderWeatherAlert рендерит шаблон погодного предупреждения
func (r *TemplateRenderer) RenderWeatherAlert(data TemplateData) (string, error) {
	return r.render("templates/weather_alert.html", data)
}

// RenderSubscriptionExpiring рендерит шаблон истечения подписки
func (r *TemplateRenderer) RenderSubscriptionExpiring(data TemplateData) (string, error) {
	return r.render("templates/subscription_expiring.html", data)
}

// RenderAchievement рендерит шаблон достижения
func (r *TemplateRenderer) RenderAchievement(data TemplateData) (string, error) {
	return r.render("templates/achievement.html", data)
}

// render — внутренний метод для рендеринга шаблона
func (r *TemplateRenderer) render(templateName string, data TemplateData) (string, error) {
	if data.Year == 0 {
		data.Year = time.Now().Year()
	}

	var buf bytes.Buffer
	tmpl := r.templates.Lookup(templateName)
	if tmpl == nil {
		return "", fmt.Errorf("template %s not found", templateName)
	}

	if err := tmpl.Execute(&buf, data); err != nil {
		return "", fmt.Errorf("failed to execute template: %w", err)
	}

	return buf.String(), nil
}
