package services

import (
	"fmt"
	"net/smtp"
	"strings"

	"go.uber.org/zap"
)

// EmailService defines the interface for email operations
type EmailService interface {
	SendVerificationEmail(to, code string) error
	SendPasswordResetEmail(to, token string) error
}

// SMTPConfig holds SMTP configuration
type SMTPConfig struct {
	Host     string
	Port     int
	Username string
	Password string
	From     string
}

// SMTPEmailService implements EmailService using SMTP
type SMTPEmailService struct {
	config SMTPConfig
	logger *zap.Logger
}

// NewEmailService creates a new SMTP email service
func NewEmailService(
	host string,
	port int,
	username string,
	password string,
	from string,
	logger *zap.Logger,
) EmailService {
	return &SMTPEmailService{
		config: SMTPConfig{
			Host:     host,
			Port:     port,
			Username: username,
			Password: password,
			From:     from,
		},
		logger: logger,
	}
}

// sendEmail — общий метод для отправки писем
func (s *SMTPEmailService) sendEmail(to, subject, body string) error {
	addr := fmt.Sprintf("%s:%d", s.config.Host, s.config.Port)

	// PlainAuth: подходит для Mailhog/локального SMTP и многих провайдеров.
	// Для Gmail/Yandex с TLS могут понадобиться доп. настройки.
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

// SendVerificationEmail sends a verification email
func (s *SMTPEmailService) SendVerificationEmail(to, code string) error {
	subject := "OutfitStyle: код подтверждения"
	body := fmt.Sprintf("Ваш код подтверждения: %s\n\nЕсли вы не запрашивали код, просто игнорируйте это письмо.", code)
	return s.sendEmail(to, subject, body)
}

// SendPasswordResetEmail sends a password reset email
func (s *SMTPEmailService) SendPasswordResetEmail(to, token string) error {
	subject := "OutfitStyle: сброс пароля"
	body := fmt.Sprintf("Чтобы сбросить пароль, используйте этот токен: %s\n\nЕсли вы не запрашивали сброс пароля, просто игнорируйте это письмо.", token)
	return s.sendEmail(to, subject, body)
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
