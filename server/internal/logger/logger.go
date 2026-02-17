// Пакет logger предоставляет унифицированный интерфейс для логирования в приложении
// Использует библиотеку zap для эффективного и гибкого логирования
package logger

import (
	"context"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

// contextKey определяет тип для ключей контекста
type contextKey string

// Константы для ключей контекста, используемых в логировании
const (
	RequestIDKey contextKey = "request_id" // Ключ для идентификатора запроса в контексте
	UserIDKey    contextKey = "user_id"    // Ключ для идентификатора пользователя в контексте
)

// globalLogger глобальный экземпляр логгера zap
var globalLogger *zap.Logger

// Init инициализирует глобальный логгер в зависимости от окружения
// Устанавливает соответствующую конфигурацию для production или development среды
func Init(env string) error {
	var config zap.Config

	if env == "production" {
		config = zap.NewProductionConfig()
		config.EncoderConfig.TimeKey = "timestamp"
		config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
		config.Level = zap.NewAtomicLevelAt(zap.InfoLevel)
	} else {
		config = zap.NewDevelopmentConfig()
		config.EncoderConfig.EncodeLevel = zapcore.CapitalColorLevelEncoder
		config.Level = zap.NewAtomicLevelAt(zap.DebugLevel)
	}

	// Добавляем информацию о вызывающем объекте
	config.EncoderConfig.CallerKey = "caller"
	config.EncoderConfig.EncodeCaller = zapcore.ShortCallerEncoder

	var err error
	globalLogger, err = config.Build(
		zap.AddCallerSkip(1),
		zap.AddStacktrace(zapcore.ErrorLevel),
	)
	if err != nil {
		return err
	}

	return nil
}

// WithContext создает экземпляр логгера с дополнительными полями из контекста
// Добавляет идентификатор запроса и пользователя к записям лога, если они присутствуют в контексте
func WithContext(ctx context.Context) *zap.Logger {
	logger := globalLogger

	if requestID, ok := ctx.Value(RequestIDKey).(string); ok {
		logger = logger.With(zap.String("request_id", requestID))
	}

	if userID, ok := ctx.Value(UserIDKey).(string); ok {
		logger = logger.With(zap.String("user_id", userID))
	}

	return logger
}

// Info записывает информационное сообщение в лог с контекстом
func Info(ctx context.Context, msg string, fields ...zap.Field) {
	WithContext(ctx).Info(msg, fields...)
}

// Error записывает сообщение об ошибке в лог с контекстом
func Error(ctx context.Context, msg string, fields ...zap.Field) {
	WithContext(ctx).Error(msg, fields...)
}

// Warn записывает предупреждение в лог с контекстом
func Warn(ctx context.Context, msg string, fields ...zap.Field) {
	WithContext(ctx).Warn(msg, fields...)
}

// Debug записывает отладочное сообщение в лог с контекстом
func Debug(ctx context.Context, msg string, fields ...zap.Field) {
	WithContext(ctx).Debug(msg, fields...)
}

// Fatal записывает фатальное сообщение в лог с контекстом и завершает программу
func Fatal(ctx context.Context, msg string, fields ...zap.Field) {
	WithContext(ctx).Fatal(msg, fields...)
}

// Sugar возвращает сахарный логгер для удобного логирования
// Предоставляет более простой интерфейс для логирования без необходимости явного указания типов полей
func Sugar() *zap.SugaredLogger {
	return globalLogger.Sugar()
}

// =============================================================================
// PII MASKING - Маскирование персональных данных
// =============================================================================

// MaskEmail маскирует email адрес, оставляя первые 2 и последние 4 символа
// Пример: user@example.com → us**@example.com
func MaskEmail(email string) string {
	if len(email) < 6 {
		return "***"
	}

	atIndex := -1
	for i, c := range email {
		if c == '@' {
			atIndex = i
			break
		}
	}

	if atIndex <= 0 || atIndex >= len(email)-1 {
		return "***"
	}

	// Оставляем первые 2 символа имени и домен полностью
	if atIndex <= 2 {
		return email[:atIndex] + email[atIndex:]
	}

	return email[:2] + "***" + email[atIndex:]
}

// MaskToken маскирует токен (JWT, API key), показывая только первые 8 и последние 4 символа
// Пример: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... → eyJhbGc***...***xyz123
func MaskToken(token string) string {
	if len(token) < 16 {
		return "***"
	}
	if len(token) < 32 {
		return token[:4] + "***" + token[len(token)-4:]
	}
	return token[:8] + "***...***" + token[len(token)-4:]
}

// MaskUserID маскирует ID пользователя, оставляя только последние 4 символа
// Пример: 550e8400-e29b-41d4-a716-446655440000 → ***40000
func MaskUserID(id string) string {
	if len(id) < 4 {
		return "***"
	}
	return "***" + id[len(id)-4:]
}

// MaskIP маскирует IP адрес, оставляя только последнюю часть
// Пример: 192.168.1.100 → ***.***.***.100
func MaskIP(ip string) string {
	if ip == "" {
		return "***"
	}

	// Находим последнюю точку
	lastDot := -1
	for i := len(ip) - 1; i >= 0; i-- {
		if ip[i] == '.' {
			lastDot = i
			break
		}
	}

	if lastDot < 0 {
		return "***"
	}

	return "***.***.***" + ip[lastDot:]
}

// MaskPassword возвращает заглушку вместо пароля
// Пароли никогда не должны логироваться даже в маскированном виде
func MaskPassword() string {
	return "[REDACTED]"
}

// SafeField создаёт поле zap.String с маскированием чувствительных данных
func SafeField(key, value string, sensitive bool) zap.Field {
	if sensitive {
		return zap.String(key, "***"+value[len(value)-min(4, len(value)):]+"***")
	}
	return zap.String(key, value)
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
