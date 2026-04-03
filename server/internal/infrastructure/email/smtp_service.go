package email

import (
	"fmt"
	"net/smtp"
)

// SMTPService отвечает за отправку email через SMTP
type SMTPService struct {
	host     string
	port     int
	user     string
	password string
	from     string
	auth     smtp.Auth
}

// NewSMTPService создает новый SMTP сервис
func NewSMTPService(host string, port int, user, password, from string) *SMTPService {
	auth := smtp.PlainAuth("", user, password, host)
	return &SMTPService{
		host:     host,
		port:     port,
		user:     user,
		password: password,
		from:     from,
		auth:     auth,
	}
}

// SendPasswordReset отправляет email с кодом сброса пароля
func (s *SMTPService) SendPasswordReset(to, code string) error {
	subject := "Сброс пароля — OutfitStyle"
	body := fmt.Sprintf(`
		<html>
		<body>
			<h2>Сброс пароля</h2>
			<p>Ваш код для сброса пароля:</p>
			<h1 style="letter-spacing: 5px; font-size: 32px;">%s</h1>
			<p>Если вы не запрашивали сброс пароля, проигнорируйте это письмо.</p>
		</body>
		</html>
	`, code)

	return s.send(to, subject, body)
}

// send отправляет email с заданной темой и телом
func (s *SMTPService) send(to, subject, body string) error {
	addr := fmt.Sprintf("%s:%d", s.host, s.port)

	msg := fmt.Sprintf(
		"From: %s\r\nTo: %s\r\nSubject: %s\r\nMIME-Version: 1.0\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n%s",
		s.from, to, subject, body,
	)

	return smtp.SendMail(addr, s.auth, s.from, []string{to}, []byte(msg))
}
