package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/domain"
)

// MockUserRepository - мок-репозиторий пользователей для тестов
type MockUserRepository struct {
	mock.Mock
}

func (m *MockUserRepository) GetUser(ctx context.Context, id domain.ID) (*domain.User, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetUserByEmail(ctx context.Context, email string) (*domain.User, error) {
	args := m.Called(ctx, email)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) CreateUser(ctx context.Context, user *domain.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func (m *MockUserRepository) UpdateUser(ctx context.Context, user *domain.User) error {
	args := m.Called(ctx, user)
	return args.Error(0)
}

func (m *MockUserRepository) UpdatePassword(ctx context.Context, userID domain.ID, newPassword string) error {
	args := m.Called(ctx, userID, newPassword)
	return args.Error(0)
}

func (m *MockUserRepository) GetUserByOAuthID(ctx context.Context, provider string, oauthID string) (*domain.User, error) {
	args := m.Called(ctx, provider, oauthID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetUserProfile(ctx context.Context, userID domain.ID) (*domain.User, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) UpdateUserProfile(ctx context.Context, userID domain.ID, patch domain.UserProfileUpdate) (*domain.User, error) {
	args := m.Called(ctx, userID, patch)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserStats, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.UserStats), args.Error(1)
}

func (m *MockUserRepository) GetUserAchievements(ctx context.Context, userID domain.ID) ([]domain.Achievement, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.Achievement), args.Error(1)
}

func (m *MockUserRepository) UnlockAchievement(ctx context.Context, userID domain.ID, achievementCode string) error {
	args := m.Called(ctx, userID, achievementCode)
	return args.Error(0)
}

func (m *MockUserRepository) UpdatePreferences(ctx context.Context, userID domain.ID, prefs domain.UserPreferences) (*domain.User, error) {
	args := m.Called(ctx, userID, prefs)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) UpdateBodyMeasurements(ctx context.Context, userID domain.ID, bm domain.BodyMeasurements) (*domain.User, error) {
	args := m.Called(ctx, userID, bm)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.User), args.Error(1)
}

func (m *MockUserRepository) GetDefaultCoords(ctx context.Context, userID domain.ID) (lat *float64, lon *float64, err error) {
	args := m.Called(ctx, userID)
	return args.Get(0).(*float64), args.Get(1).(*float64), args.Error(2)
}

func (m *MockUserRepository) DeleteUser(ctx context.Context, userID domain.ID) error {
	args := m.Called(ctx, userID)
	return args.Error(0)
}

func (m *MockUserRepository) RateRecommendation(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	args := m.Called(ctx, userID, recommendationID, rating, feedback)
	return args.Error(0)
}

func (m *MockUserRepository) GetUserTimezone(ctx context.Context, userID domain.ID) (string, error) {
	args := m.Called(ctx, userID)
	return args.String(0), args.Error(1)
}

// Тест установки пароля для Google-пользователя
func TestPasswordHandler_SetPassword_GoogleUser(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	// Создаем Google-пользователя без пароля
	googleProvider := "google"
	userID := domain.NewID()
	user := &domain.User{
		ID:            userID,
		Email:         "test@example.com",
		PasswordHash:  "", // Нет пароля
		OAuthProvider: &googleProvider,
		OAuthID:       ptr("google-sub-123"),
	}

	// Ожидаем получение пользователя
	mockRepo.On("GetUser", mock.Anything, userID).Return(user, nil)
	// Ожидаем обновление пароля
	mockRepo.On("UpdatePassword", mock.Anything, userID, "NewPassword123!").Return(nil)

	// Создаем запрос
	body := SetPasswordRequest{
		NewPassword: "NewPassword123!",
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/set-password", bytes.NewReader(jsonBody))
	req = req.WithContext(middleware.WithUserID(req.Context(), userID))

	// Создаем recorder
	rr := httptest.NewRecorder()

	// Вызываем handler
	handler.SetPassword(rr, req)

	// Проверяем ответ
	assert.Equal(t, http.StatusOK, rr.Code)

	var response map[string]interface{}
	err := json.Unmarshal(rr.Body.Bytes(), &response)
	assert.NoError(t, err)
	assert.Equal(t, true, response["success"])

	mockRepo.AssertExpectations(t)
}

// Тест установки пароля для обычного пользователя (с проверкой текущего)
func TestPasswordHandler_SetPassword_WithCurrentPassword(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	// Создаем пользователя с паролем
	userID := domain.NewID()
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("OldPassword123!"), 12)
	user := &domain.User{
		ID:           userID,
		Email:        "test@example.com",
		PasswordHash: string(hashedPassword),
	}

	// Ожидаем получение пользователя
	mockRepo.On("GetUser", mock.Anything, userID).Return(user, nil)
	// Ожидаем обновление пароля
	mockRepo.On("UpdatePassword", mock.Anything, userID, "NewPassword123!").Return(nil)

	// Создаем запрос с текущим паролем
	body := SetPasswordRequest{
		CurrentPassword: "OldPassword123!",
		NewPassword:     "NewPassword123!",
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/set-password", bytes.NewReader(jsonBody))
	req = req.WithContext(middleware.WithUserID(req.Context(), userID))

	// Создаем recorder
	rr := httptest.NewRecorder()

	// Вызываем handler
	handler.SetPassword(rr, req)

	// Проверяем ответ
	assert.Equal(t, http.StatusOK, rr.Code)

	mockRepo.AssertExpectations(t)
}

// Тест: ошибка при отсутствии текущего пароля для пользователя с паролем
func TestPasswordHandler_SetPassword_MissingCurrentPassword(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	userID := domain.NewID()
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("OldPassword123!"), 12)
	user := &domain.User{
		ID:           userID,
		Email:        "test@example.com",
		PasswordHash: string(hashedPassword),
	}

	mockRepo.On("GetUser", mock.Anything, userID).Return(user, nil)

	body := SetPasswordRequest{
		NewPassword: "NewPassword123!",
		// CurrentPassword отсутствует
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/set-password", bytes.NewReader(jsonBody))
	req = req.WithContext(middleware.WithUserID(req.Context(), userID))

	rr := httptest.NewRecorder()
	handler.SetPassword(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
	mockRepo.AssertExpectations(t)
}

// Тест: ошибка при неверном текущем пароле
func TestPasswordHandler_SetPassword_WrongCurrentPassword(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	userID := domain.NewID()
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("OldPassword123!"), 12)
	user := &domain.User{
		ID:           userID,
		Email:        "test@example.com",
		PasswordHash: string(hashedPassword),
	}

	mockRepo.On("GetUser", mock.Anything, userID).Return(user, nil)

	body := SetPasswordRequest{
		CurrentPassword: "WrongPassword123!",
		NewPassword:     "NewPassword123!",
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/set-password", bytes.NewReader(jsonBody))
	req = req.WithContext(middleware.WithUserID(req.Context(), userID))

	rr := httptest.NewRecorder()
	handler.SetPassword(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
	mockRepo.AssertExpectations(t)
}

// Тест: валидация слабого пароля
func TestPasswordHandler_SetPassword_WeakPassword(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	userID := domain.NewID()

	// Слабый пароль (менее 12 символов) - валидация происходит до получения пользователя
	body := SetPasswordRequest{
		NewPassword: "weak",
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/set-password", bytes.NewReader(jsonBody))
	req = req.WithContext(middleware.WithUserID(req.Context(), userID))

	rr := httptest.NewRecorder()
	handler.SetPassword(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
	// Мок не вызывается, т.к. валидация не проходит
	mockRepo.AssertExpectations(t)
}

// Тест: отсутствие авторизации
func TestPasswordHandler_SetPassword_NoAuth(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	body := SetPasswordRequest{
		NewPassword: "NewPassword123!",
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/set-password", bytes.NewReader(jsonBody))
	// Нет user_id в контексте

	rr := httptest.NewRecorder()
	handler.SetPassword(rr, req)

	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

// Тест: смена пароля (change-password)
func TestPasswordHandler_ChangePassword_Success(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	userID := domain.NewID()
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("OldPassword123!"), 12)
	user := &domain.User{
		ID:           userID,
		Email:        "test@example.com",
		PasswordHash: string(hashedPassword),
	}

	mockRepo.On("GetUser", mock.Anything, userID).Return(user, nil)
	mockRepo.On("UpdatePassword", mock.Anything, userID, "NewPassword123!").Return(nil)

	body := SetPasswordRequest{
		CurrentPassword: "OldPassword123!",
		NewPassword:     "NewPassword123!",
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/change-password", bytes.NewReader(jsonBody))
	req = req.WithContext(middleware.WithUserID(req.Context(), userID))

	rr := httptest.NewRecorder()
	handler.ChangePassword(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	mockRepo.AssertExpectations(t)
}

// Тест: смена пароля без текущего пароля
func TestPasswordHandler_ChangePassword_MissingCurrent(t *testing.T) {
	logger, _ := zap.NewDevelopment()
	mockRepo := new(MockUserRepository)
	handler := NewPasswordHandler(mockRepo, logger)

	userID := domain.NewID()

	// Валидация current_password происходит до получения пользователя
	body := SetPasswordRequest{
		NewPassword: "NewPassword123!",
	}
	jsonBody, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/user/change-password", bytes.NewReader(jsonBody))
	req = req.WithContext(middleware.WithUserID(req.Context(), userID))

	rr := httptest.NewRecorder()
	handler.ChangePassword(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
	// Мок не вызывается, т.к. валидация не проходит
	mockRepo.AssertExpectations(t)
}

// Вспомогательная функция для создания указателя на string
func ptr(s string) *string {
	return &s
}
