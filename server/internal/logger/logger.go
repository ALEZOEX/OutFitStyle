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
