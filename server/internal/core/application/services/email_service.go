package services

import (
	"fmt"
	"mime/quotedprintable"
	"net/smtp"
	"strings"

	"go.uber.org/zap"

	"outfitstyle/server/internal/infrastructure/email"
)

// Импортируем типы из пакета email
type TemplateRenderer = email.TemplateRenderer
type TemplateData = email.TemplateData
type Outfit = email.Outfit

// EmailService определяет интерфейс для email операций
type EmailService interface {
	// Базовые методы
	SendVerificationEmail(to, code string) error
	SendPasswordResetEmail(to, code string) error

	// Методы для рассылок
	SendWelcome(to, name string) error
	SendRecommendationReady(to, name string, data RecommendationData) error
	SendWeatherAlert(to, name string, data WeatherAlertData) error
	SendSubscriptionExpiring(to, name string, data SubscriptionData) error
	SendAchievement(to, name string, data AchievementData) error
}

// maskEmail маскирует email для логирования (защита PII)
func maskEmail(email string) string {
	parts := strings.Split(email, "@")
	if len(parts) != 2 {
		return "***"
	}
	name := parts[0]
	domain := parts[1]
	if len(name) <= 2 {
		return "*@" + domain
	}
	return string(name[0]) + strings.Repeat("*", len(name)-2) + string(name[len(name)-1]) + "@" + domain
}

// SMTPConfig holds SMTP configuration
type SMTPConfig struct {
	Host     string
	Port     int
	Username string
	Password string
	From     string
	FromName string
}

// SMTPEmailService implements EmailService using SMTP
type SMTPEmailService struct {
	config   SMTPConfig
	logger   *zap.Logger
	renderer *TemplateRenderer
}

// NewEmailService создает новый SMTP email сервис
func NewEmailService(
	host string,
	port int,
	username string,
	password string,
	from string,
	fromName string,
	logger *zap.Logger,
) EmailService {
	renderer, err := email.NewTemplateRenderer()
	if err != nil {
		logger.Warn("Failed to initialize email template renderer, using fallback", zap.Error(err))
	}

	return &SMTPEmailService{
		config: SMTPConfig{
			Host:     host,
			Port:     port,
			Username: username,
			Password: password,
			From:     from,
			FromName: fromName,
		},
		logger:   logger,
		renderer: renderer,
	}
}

// sendHTMLEmail — отправка HTML письма
func (s *SMTPEmailService) sendHTMLEmail(to, subject, htmlBody string) error {
	addr := fmt.Sprintf("%s:%d", s.config.Host, s.config.Port)

	var auth smtp.Auth
	if s.config.Username != "" && s.config.Password != "" {
		auth = smtp.PlainAuth("", s.config.Username, s.config.Password, s.config.Host)
	}

	fromHeader := s.config.From
	if s.config.FromName != "" {
		fromHeader = fmt.Sprintf("%s <%s>", s.config.FromName, s.config.From)
	}

	headers := map[string]string{
		"From":                      fromHeader,
		"To":                        to,
		"Subject":                   subject,
		"MIME-Version":              "1.0",
		"Content-Type":              "text/html; charset=UTF-8",
		"Content-Transfer-Encoding": "quoted-printable",
	}

	var msgBuilder strings.Builder
	for k, v := range headers {
		msgBuilder.WriteString(fmt.Sprintf("%s: %s\r\n", k, v))
	}
	msgBuilder.WriteString("\r\n")

	// Кодируем тело в quoted-printable
	qp := quotedprintable.NewWriter(&msgBuilder)
	_, err := qp.Write([]byte(htmlBody))
	qp.Close()
	if err != nil {
		return fmt.Errorf("failed to encode email body: %w", err)
	}

	msg := []byte(msgBuilder.String())

	if err := smtp.SendMail(addr, auth, s.config.From, []string{to}, msg); err != nil {
		s.logger.Error("Failed to send email",
			zap.String("to", to),
			zap.String("subject", subject),
			zap.Error(err))
		return err
	}

	s.logger.Info("Email sent",
		zap.String("to", to),
		zap.String("subject", subject))
	return nil
}

// sendEmail — отправка простого текстового письма (fallback)
func (s *SMTPEmailService) sendEmail(to, subject, body string) error {
	addr := fmt.Sprintf("%s:%d", s.config.Host, s.config.Port)

	var auth smtp.Auth
	if s.config.Username != "" && s.config.Password != "" {
		auth = smtp.PlainAuth("", s.config.Username, s.config.Password, s.config.Host)
	}

	headers := map[string]string{
		"From":         s.config.From,
		"To":           to,
		"Subject":      subject,
		"MIME-Version": "1.0",
		"Content-Type": "text/plain; charset=\"UTF-8\"",
	}

	var msgBuilder strings.Builder
	for k, v := range headers {
		msgBuilder.WriteString(fmt.Sprintf("%s: %s\r\n", k, v))
	}
	msgBuilder.WriteString("\r\n")
	msgBuilder.WriteString(body)
	msg := []byte(msgBuilder.String())

	if err := smtp.SendMail(addr, auth, s.config.From, []string{to}, msg); err != nil {
		s.logger.Error("Failed to send email",
			zap.String("to", to),
			zap.String("subject", subject),
			zap.Error(err))
		return err
	}

	s.logger.Info("Email sent",
		zap.String("to", to),
		zap.String("subject", subject))
	return nil
}

// RecommendationData данные для письма о готовности рекомендации
type RecommendationData struct {
	WeatherCondition   string
	WeatherIcon        string
	Temperature        string
	Location           string
	WeatherDescription string
	Date               string
	Outfits            []OutfitPreview
	Tips               []string
	ViewUrl            string
	SettingsUrl        string
}

// OutfitPreview превью образа
type OutfitPreview struct {
	Name       string
	Icon       string
	Occasion   string
	MatchScore int
}

// WeatherAlertData данные для погодного предупреждения
type WeatherAlertData struct {
	AlertTitle         string
	AlertIcon          string
	WeatherCondition   string
	WeatherIcon        string
	Temperature        string
	Location           string
	Date               string
	WeatherDescription string
	AdditionalInfo     string
	WearThis           []string
	Avoid              []string
	HealthTips         []string
	ViewOutfitsUrl     string
}

// SubscriptionData данные для письма об истечении подписки
type SubscriptionData struct {
	PlanName        string
	ExpiryDate      string
	DaysLeft        int
	PlanFeatures    []string
	LoseFeatures    []string
	DiscountPercent int
	DiscountDays    int
	RenewUrl        string
	PlansUrl        string
}

// AchievementData данные для письма о достижении
type AchievementData struct {
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

// SendVerificationEmail sends a verification email
func (s *SMTPEmailService) SendVerificationEmail(to, code string) error {
	if s.config.Host == "" || s.config.Username == "" || s.config.Password == "" {
		s.logger.Info("DEV MODE: Would send verification email", zap.String("to", to), zap.String("code", code))
		return nil
	}

	subject := "OutfitStyle: код подтверждения"
	body := fmt.Sprintf("Ваш код подтверждения: %s\n\nЕсли вы не запрашивали код, просто игнорируйте это письмо.", code)
	return s.sendEmail(to, subject, body)
}

// SendPasswordResetEmail sends a password reset email with HTML template
func (s *SMTPEmailService) SendPasswordResetEmail(to, code string) error {
	// DEV mode fallback
	if s.config.Host == "" || s.config.Username == "" || s.config.Password == "" {
		s.logger.Info("DEV MODE: Password reset code sent", zap.String("to", maskEmail(to)))
		return nil
	}

	subject := "Сброс пароля OutfitStyle"

	// Используем рендерер шаблонов если доступен
	if s.renderer != nil {
		htmlBody, err := s.renderer.RenderPasswordReset(TemplateData{
			Email:      to,
			Code:       code,
			ResetUrl:   "https://outfitstyle.app/reset-password",
			SupportUrl: "https://outfitstyle.app/support",
		})
		if err == nil {
			return s.sendHTMLEmail(to, subject, htmlBody)
		}
		s.logger.Warn("Template render failed, using fallback", zap.Error(err))
	}

	// Fallback: возвращаем ошибку, так как старый метод удалён
	return fmt.Errorf("template renderer failed and fallback is not available")
}

// SendWelcome отправляет приветственное письмо
func (s *SMTPEmailService) SendWelcome(to, name string) error {
	if s.config.Host == "" || s.config.Username == "" || s.config.Password == "" {
		s.logger.Info("DEV MODE: Would send welcome email", zap.String("to", to), zap.String("name", name))
		return nil
	}

	subject := "Добро пожаловать в OutfitStyle! 🎉"

	if s.renderer != nil {
		htmlBody, err := s.renderer.RenderWelcome(TemplateData{
			Name:           name,
			AppUrl:         "https://outfitstyle.app",
			UnsubscribeUrl: "https://outfitstyle.app/unsubscribe",
			SupportUrl:     "https://outfitstyle.app/support",
		})
		if err != nil {
			return fmt.Errorf("failed to render welcome template: %w", err)
		}
		return s.sendHTMLEmail(to, subject, htmlBody)
	}

	return fmt.Errorf("template renderer not available")
}

// SendRecommendationReady отправляет уведомление о готовой рекомендации
func (s *SMTPEmailService) SendRecommendationReady(to, name string, data RecommendationData) error {
	if s.config.Host == "" || s.config.Username == "" || s.config.Password == "" {
		s.logger.Info("DEV MODE: Would send recommendation ready email", zap.String("to", to))
		return nil
	}

	subject := fmt.Sprintf("🌤️ %s: %d готовых образа для вас", data.Location, len(data.Outfits))

	if s.renderer != nil {
		outfits := make([]Outfit, len(data.Outfits))
		for i, o := range data.Outfits {
			outfits[i] = Outfit{
				Name:       o.Name,
				Icon:       o.Icon,
				Occasion:   o.Occasion,
				MatchScore: o.MatchScore,
			}
		}

		htmlBody, err := s.renderer.RenderRecommendationReady(TemplateData{
			Name:               name,
			WeatherCondition:   data.WeatherCondition,
			WeatherIcon:        data.WeatherIcon,
			Temperature:        data.Temperature,
			Location:           data.Location,
			WeatherDescription: data.WeatherDescription,
			Date:               data.Date,
			OutfitCount:        len(data.Outfits),
			Outfits:            outfits,
			Tips:               data.Tips,
			ViewUrl:            data.ViewUrl,
			SettingsUrl:        data.SettingsUrl,
			AppUrl:             "https://outfitstyle.app",
			UnsubscribeUrl:     "https://outfitstyle.app/unsubscribe",
		})
		if err != nil {
			return fmt.Errorf("failed to render recommendation template: %w", err)
		}
		return s.sendHTMLEmail(to, subject, htmlBody)
	}

	return fmt.Errorf("template renderer not available")
}

// SendWeatherAlert отправляет погодное предупреждение
func (s *SMTPEmailService) SendWeatherAlert(to, name string, data WeatherAlertData) error {
	if s.config.Host == "" || s.config.Username == "" || s.config.Password == "" {
		s.logger.Info("DEV MODE: Would send weather alert email", zap.String("to", to))
		return nil
	}

	subject := fmt.Sprintf("⚠️ %s: %s", data.Location, data.AlertTitle)

	if s.renderer != nil {
		htmlBody, err := s.renderer.RenderWeatherAlert(TemplateData{
			Name:               name,
			AlertTitle:         data.AlertTitle,
			AlertIcon:          data.AlertIcon,
			WeatherCondition:   data.WeatherCondition,
			WeatherIcon:        data.WeatherIcon,
			Temperature:        data.Temperature,
			Location:           data.Location,
			Date:               data.Date,
			WeatherDescription: data.WeatherDescription,
			AdditionalInfo:     data.AdditionalInfo,
			WearThis:           data.WearThis,
			Avoid:              data.Avoid,
			HealthTips:         data.HealthTips,
			ViewOutfitsUrl:     data.ViewOutfitsUrl,
			AppUrl:             "https://outfitstyle.app",
			UnsubscribeUrl:     "https://outfitstyle.app/unsubscribe",
		})
		if err != nil {
			return fmt.Errorf("failed to render weather alert template: %w", err)
		}
		return s.sendHTMLEmail(to, subject, htmlBody)
	}

	return fmt.Errorf("template renderer not available")
}

// SendSubscriptionExpiring отправляет напоминание об истечении подписки
func (s *SMTPEmailService) SendSubscriptionExpiring(to, name string, data SubscriptionData) error {
	if s.config.Host == "" || s.config.Username == "" || s.config.Password == "" {
		s.logger.Info("DEV MODE: Would send subscription expiring email", zap.String("to", to))
		return nil
	}

	subject := fmt.Sprintf("⏰ Подписка %s заканчивается через %d дн.", data.PlanName, data.DaysLeft)

	if s.renderer != nil {
		htmlBody, err := s.renderer.RenderSubscriptionExpiring(TemplateData{
			Name:            name,
			PlanName:        data.PlanName,
			ExpiryDate:      data.ExpiryDate,
			DaysLeft:        data.DaysLeft,
			PlanFeatures:    data.PlanFeatures,
			LoseFeatures:    data.LoseFeatures,
			DiscountPercent: data.DiscountPercent,
			DiscountDays:    data.DiscountDays,
			RenewUrl:        data.RenewUrl,
			PlansUrl:        data.PlansUrl,
			SupportUrl:      "https://outfitstyle.app/support",
			UnsubscribeUrl:  "https://outfitstyle.app/unsubscribe",
		})
		if err != nil {
			return fmt.Errorf("failed to render subscription template: %w", err)
		}
		return s.sendHTMLEmail(to, subject, htmlBody)
	}

	return fmt.Errorf("template renderer not available")
}

// SendAchievement отправляет уведомление о достижении
func (s *SMTPEmailService) SendAchievement(to, name string, data AchievementData) error {
	if s.config.Host == "" || s.config.Username == "" || s.config.Password == "" {
		s.logger.Info("DEV MODE: Would send achievement email", zap.String("to", to))
		return nil
	}

	subject := fmt.Sprintf("🏆 Поздравляем! Вы получили достижение \"%s\"", data.AchievementName)

	if s.renderer != nil {
		htmlBody, err := s.renderer.RenderAchievement(TemplateData{
			Name:                   name,
			AchievementName:        data.AchievementName,
			AchievementIcon:        data.AchievementIcon,
			AchievementDescription: data.AchievementDescription,
			AchievementTier:        data.AchievementTier,
			PointsEarned:           data.PointsEarned,
			TotalPoints:            data.TotalPoints,
			NextAchievementName:    data.NextAchievementName,
			ProgressPercent:        data.ProgressPercent,
			ProgressRemaining:      data.ProgressRemaining,
			TotalAchievements:      data.TotalAchievements,
			CurrentStreak:          data.CurrentStreak,
			Rank:                   data.Rank,
			ViewProfileUrl:         data.ViewProfileUrl,
			ShareUrl:               data.ShareUrl,
			UnsubscribeUrl:         "https://outfitstyle.app/unsubscribe",
		})
		if err != nil {
			return fmt.Errorf("failed to render achievement template: %w", err)
		}
		return s.sendHTMLEmail(to, subject, htmlBody)
	}

	return fmt.Errorf("template renderer not available")
}

// NoopEmailService implements EmailService with no-op operations
type NoopEmailService struct{}

// NewNoopEmailService creates a new no-op email service
func NewNoopEmailService() EmailService {
	return &NoopEmailService{}
}

// SendVerificationEmail does nothing
func (n *NoopEmailService) SendVerificationEmail(to, code string) error {
	fmt.Printf("NOOP: Would send verification email to %s with code %s\n", to, code)
	return nil
}

// SendPasswordResetEmail does nothing
func (n *NoopEmailService) SendPasswordResetEmail(to, token string) error {
	fmt.Printf("NOOP: Would send password reset email to %s with token %s\n", to, token)
	return nil
}

// SendWelcome does nothing
func (n *NoopEmailService) SendWelcome(to, name string) error {
	fmt.Printf("NOOP: Would send welcome email to %s\n", to)
	return nil
}

// SendRecommendationReady does nothing
func (n *NoopEmailService) SendRecommendationReady(to, name string, data RecommendationData) error {
	fmt.Printf("NOOP: Would send recommendation ready email to %s\n", to)
	return nil
}

// SendWeatherAlert does nothing
func (n *NoopEmailService) SendWeatherAlert(to, name string, data WeatherAlertData) error {
	fmt.Printf("NOOP: Would send weather alert email to %s\n", to)
	return nil
}

// SendSubscriptionExpiring does nothing
func (n *NoopEmailService) SendSubscriptionExpiring(to, name string, data SubscriptionData) error {
	fmt.Printf("NOOP: Would send subscription expiring email to %s\n", to)
	return nil
}

// SendAchievement does nothing
func (n *NoopEmailService) SendAchievement(to, name string, data AchievementData) error {
	fmt.Printf("NOOP: Would send achievement email to %s\n", to)
	return nil
}
