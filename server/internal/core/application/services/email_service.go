package services

import (
	"fmt"
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

// SendVerificationEmail sends a verification email
func (s *SMTPEmailService) SendVerificationEmail(to, code string) error {
	// In a real implementation, you would connect to an SMTP server and send the email
	s.logger.Info("Sending verification email",
		zap.String("to", to),
		zap.String("code", code))
	return nil
}

// SendPasswordResetEmail sends a password reset email
func (s *SMTPEmailService) SendPasswordResetEmail(to, token string) error {
	// In a real implementation, you would connect to an SMTP server and send the email
	s.logger.Info("Sending password reset email",
		zap.String("to", to),
		zap.String("token", token))
	return nil
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