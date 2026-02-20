// Пакет email предоставляет сервисы для отправки электронной почты
package email

import (
	"bytes"
	"fmt"
	"mime/quotedprintable"
	"net/smtp"
	"text/template"
	"time"
)

// SMTPService сервис для отправки email через SMTP
type SMTPService struct {
	host     string
	port     int
	username string
	password string
	from     string
}

// NewSMTPService создает новый экземпляр SMTP сервиса
func NewSMTPService(host string, port int, username, password, from string) *SMTPService {
	return &SMTPService{
		host:     host,
		port:     port,
		username: username,
		password: password,
		from:     from,
	}
}

// SendPasswordReset отправляет email с кодом сброса пароля
func (s *SMTPService) SendPasswordReset(email, code string) error {
	if s.host == "" || s.username == "" || s.password == "" {
		// В режиме разработки без SMTP просто логируем код
		fmt.Printf("[DEV MODE] Password reset code for %s: %s\n", email, code)
		return nil
	}

	subject := "Сброс пароля OutfitStyle"
	htmlBody, err := s.renderPasswordResetTemplate(code)
	if err != nil {
		return fmt.Errorf("failed to render email template: %w", err)
	}

	// Формируем MIME сообщение
	var msg bytes.Buffer
	msg.WriteString(fmt.Sprintf("From: %s\r\n", s.from))
	msg.WriteString(fmt.Sprintf("To: %s\r\n", email))
	msg.WriteString(fmt.Sprintf("Subject: %s\r\n", subject))
	msg.WriteString("MIME-Version: 1.0\r\n")
	msg.WriteString("Content-Type: text/html; charset=UTF-8\r\n")
	msg.WriteString("Content-Transfer-Encoding: quoted-printable\r\n")
	msg.WriteString("\r\n")

	// Кодируем тело в quoted-printable
	qp := quotedprintable.NewWriter(&msg)
	_, err = qp.Write([]byte(htmlBody))
	qp.Close()
	if err != nil {
		return fmt.Errorf("failed to encode email body: %w", err)
	}

	// Отправляем email
	addr := fmt.Sprintf("%s:%d", s.host, s.port)
	auth := smtp.PlainAuth("", s.username, s.password, s.host)

	err = smtp.SendMail(addr, auth, s.from, []string{email}, msg.Bytes())
	if err != nil {
		return fmt.Errorf("failed to send email: %w", err)
	}

	return nil
}

// renderPasswordResetTemplate рендерит HTML шаблон письма
func (s *SMTPService) renderPasswordResetTemplate(code string) (string, error) {
	tmplStr := `<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: #ffffff;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo {
            font-size: 28px;
            font-weight: bold;
            color: #4F46E5;
        }
        .title {
            font-size: 24px;
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 16px;
        }
        .code-container {
            background-color: #f3f4f6;
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 24px 0;
        }
        .code {
            font-size: 36px;
            font-weight: bold;
            color: #4F46E5;
            letter-spacing: 8px;
            font-family: monospace;
        }
        .instructions {
            color: #6b7280;
            font-size: 14px;
            margin-top: 20px;
        }
        .warning {
            background-color: #fef3c7;
            border-left: 4px solid #f59e0b;
            padding: 12px 16px;
            margin-top: 20px;
            font-size: 14px;
            color: #92400e;
        }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
            font-size: 12px;
            color: #9ca3af;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">OutfitStyle</div>
        </div>
        
        <div class="title">Сброс пароля</div>
        
        <p>Вы запросили сброс пароля для вашего аккаунта OutfitStyle.</p>
        
        <div class="code-container">
            <div class="code">{{.Code}}</div>
        </div>
        
        <p class="instructions">
            Введите этот код в приложении для сброса пароля. 
            Код действителен в течение 15 минут.
        </p>
        
        <div class="warning">
            <strong>Важно:</strong> Если вы не запрашивали сброс пароля, просто проигнорируйте это письмо.
            Ваш пароль останется без изменений.
        </div>
        
        <div class="footer">
            © {{.Year}} OutfitStyle. Все права защищены.<br>
            Это автоматическое письмо, пожалуйста, не отвечайте на него.
        </div>
    </div>
</body>
</html>`

	tmpl, err := template.New("password_reset").Parse(tmplStr)
	if err != nil {
		return "", err
	}

	var buf bytes.Buffer
	data := map[string]any{
		"Code":  code,
		"Year":  time.Now().Year(),
	}

	if err := tmpl.Execute(&buf, data); err != nil {
		return "", err
	}

	return buf.String(), nil
}
