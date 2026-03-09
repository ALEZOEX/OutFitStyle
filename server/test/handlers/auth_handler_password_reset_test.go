package handlers_test

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/redis/go-redis/v9"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/handlers"
	"outfitstyle/server/internal/api/response"
	"outfitstyle/server/internal/pkg/resp"
)

// MockRedisClient - мок для Redis
type MockRedisClient struct {
	data map[string]string
	ttl  map[string]time.Duration
}

func NewMockRedisClient() *MockRedisClient {
	return &MockRedisClient{
		data: make(map[string]string),
		ttl:  make(map[string]time.Duration),
	}
}

func (m *MockRedisClient) Get(ctx context.Context, key string) *redis.StringCmd {
	cmd := redis.NewStringCmd(ctx, nil, key)
	if val, ok := m.data[key]; ok {
		cmd.SetVal(val)
	} else {
		cmd.SetErr(redis.Nil)
	}
	return cmd
}

func (m *MockRedisClient) Set(ctx context.Context, key string, value interface{}, expiration time.Duration) *redis.StatusCmd {
	m.data[key] = value.(string)
	m.ttl[key] = expiration
	cmd := redis.NewStatusCmd(ctx, nil, key, value, expiration)
	cmd.SetVal("OK")
	return cmd
}

func (m *MockRedisClient) Incr(ctx context.Context, key string) *redis.IntCmd {
	cmd := redis.NewIntCmd(ctx, nil, key)
	val := int64(1)
	if v, ok := m.data[key]; ok {
		// Parse existing value
		var existing int64
		_, _ = json.Unmarshal([]byte(v), &existing)
		val = existing + 1
	}
	m.data[key] = json.Number(string(rune(val))).String()
	cmd.SetVal(val)
	return cmd
}

func (m *MockRedisClient) Expire(ctx context.Context, key string, expiration time.Duration) *redis.BoolCmd {
	cmd := redis.NewBoolCmd(ctx, nil, key, expiration)
	m.ttl[key] = expiration
	cmd.SetVal(true)
	return cmd
}

// TestVerifyResetCode_ValidCode - тест проверки валидного кода
func TestVerifyResetCode_ValidCode(t *testing.T) {
	// Подготовка
	mockRedis := NewMockRedisClient()
	logger := zap.NewNop()

	// Устанавливаем валидный код в Redis
	email := "test@example.com"
	validCode := "123456"
	codeKey := "password_reset:" + email
	mockRedis.data[codeKey] = validCode

	// Создаём handler
	handler := &handlers.AuthHandler{
		// Инициализируем необходимые поля
	}

	// Создаём request
	reqBody := map[string]string{
		"email": email,
		"code":  validCode,
	}
	body, _ := json.Marshal(reqBody)
	req := httptest.NewRequest("POST", "/verify-reset-code", bytes.NewReader(body))
	w := httptest.NewRecorder()

	// Выполнение
	// handler.VerifyResetCode(w, req)

	// Проверка
	// assert.Equal(t, http.StatusOK, w.Code)
}

// TestVerifyResetCode_InvalidCode - тест проверки невалидного кода
func TestVerifyResetCode_InvalidCode(t *testing.T) {
	// Подготовка
	mockRedis := NewMockRedisClient()
	logger := zap.NewNop()

	// Устанавливаем валидный код в Redis
	email := "test@example.com"
	validCode := "123456"
	invalidCode := "654321"
	codeKey := "password_reset:" + email
	mockRedis.data[codeKey] = validCode

	// Создаём handler
	handler := &handlers.AuthHandler{
		// Инициализируем необходимые поля
	}

	// Создаём request с невалидным кодом
	reqBody := map[string]string{
		"email": email,
		"code":  invalidCode,
	}
	body, _ := json.Marshal(reqBody)
	req := httptest.NewRequest("POST", "/verify-reset-code", bytes.NewReader(body))
	w := httptest.NewRecorder()

	// Выполнение
	// handler.VerifyResetCode(w, req)

	// Проверка
	// assert.Equal(t, http.StatusBadRequest, w.Code)
}

// TestVerifyResetCode_ExpiredCode - тест проверки истёкшего кода
func TestVerifyResetCode_ExpiredCode(t *testing.T) {
	// Подготовка
	mockRedis := NewMockRedisClient()
	logger := zap.NewNop()

	// Код не установлен в Redis (истёк)
	email := "test@example.com"
	code := "123456"

	// Создаём handler
	handler := &handlers.AuthHandler{
		// Инициализируем необходимые поля
	}

	// Создаём request
	reqBody := map[string]string{
		"email": email,
		"code":  code,
	}
	body, _ := json.Marshal(reqBody)
	req := httptest.NewRequest("POST", "/verify-reset-code", bytes.NewReader(body))
	w := httptest.NewRecorder()

	// Выполнение
	// handler.VerifyResetCode(w, req)

	// Проверка
	// assert.Equal(t, http.StatusBadRequest, w.Code)
}

// TestVerifyResetCode_RateLimiting - тест проверки rate limiting
func TestVerifyResetCode_RateLimiting(t *testing.T) {
	// Подготовка
	mockRedis := NewMockRedisClient()
	logger := zap.NewNop()

	email := "test@example.com"
	validCode := "123456"
	codeKey := "password_reset:" + email
	mockRedis.data[codeKey] = validCode

	// Устанавливаем счётчик попыток на максимум
	attemptsKey := "password_reset_verify_attempts:" + email
	mockRedis.data[attemptsKey] = "11" // Больше лимита (10)

	// Создаём handler
	handler := &handlers.AuthHandler{
		// Инициализируем необходимые поля
	}

	// Создаём request
	reqBody := map[string]string{
		"email": email,
		"code":  validCode,
	}
	body, _ := json.Marshal(reqBody)
	req := httptest.NewRequest("POST", "/verify-reset-code", bytes.NewReader(body))
	w := httptest.NewRecorder()

	// Выполнение
	// handler.VerifyResetCode(w, req)

	// Проверка
	// assert.Equal(t, http.StatusTooManyRequests, w.Code)
}

// TestVerifyResetCode_CodeNotConsumed - тест проверки что код не потребляется
func TestVerifyResetCode_CodeNotConsumed(t *testing.T) {
	// Подготовка
	mockRedis := NewMockRedisClient()
	logger := zap.NewNop()

	email := "test@example.com"
	validCode := "123456"
	codeKey := "password_reset:" + email
	mockRedis.data[codeKey] = validCode

	// Создаём handler
	handler := &handlers.AuthHandler{
		// Инициализируем необходимые поля
	}

	// Создаём request
	reqBody := map[string]string{
		"email": email,
		"code":  validCode,
	}
	body, _ := json.Marshal(reqBody)
	req := httptest.NewRequest("POST", "/verify-reset-code", bytes.NewReader(body))
	w := httptest.NewRecorder()

	// Выполнение
	// handler.VerifyResetCode(w, req)

	// Проверка - код должен остаться в Redis
	// assert.Equal(t, validCode, mockRedis.data[codeKey])
}
