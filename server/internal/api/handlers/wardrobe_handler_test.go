package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gorilla/mux"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.uber.org/zap"

	"outfitstyle/server/internal/api/middleware"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
)

// MockWardrobeService - мок-реализация WardrobeService для тестов
type MockWardrobeService struct {
	mock.Mock
}

func (m *MockWardrobeService) List(ctx context.Context, userID domain.ID, q domain.WardrobeListQuery) ([]domain.WardrobeItem, int, error) {
	args := m.Called(ctx, userID, q)
	if args.Get(0) == nil {
		return nil, args.Int(1), args.Error(2)
	}
	return args.Get(0).([]domain.WardrobeItem), args.Int(1), args.Error(2)
}

func (m *MockWardrobeService) Get(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	args := m.Called(ctx, userID, wardrobeID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.WardrobeItem), args.Error(1)
}

func (m *MockWardrobeService) Create(ctx context.Context, userID domain.ID, req domain.WardrobeCreateRequest) (*domain.WardrobeItem, error) {
	args := m.Called(ctx, userID, req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.WardrobeItem), args.Error(1)
}

func (m *MockWardrobeService) Update(ctx context.Context, userID, wardrobeID domain.ID, req domain.WardrobeUpdateRequest) (*domain.WardrobeItem, error) {
	args := m.Called(ctx, userID, wardrobeID, req)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.WardrobeItem), args.Error(1)
}

func (m *MockWardrobeService) Delete(ctx context.Context, userID, wardrobeID domain.ID) error {
	args := m.Called(ctx, userID, wardrobeID)
	return args.Error(0)
}

func (m *MockWardrobeService) SetFavorite(ctx context.Context, userID, wardrobeID domain.ID, isFavorite bool) error {
	args := m.Called(ctx, userID, wardrobeID, isFavorite)
	return args.Error(0)
}

func (m *MockWardrobeService) SetArchived(ctx context.Context, userID, wardrobeID domain.ID, isArchived bool) error {
	args := m.Called(ctx, userID, wardrobeID, isArchived)
	return args.Error(0)
}

func (m *MockWardrobeService) MarkWorn(ctx context.Context, userID, wardrobeID domain.ID) (*domain.WardrobeItem, error) {
	args := m.Called(ctx, userID, wardrobeID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.WardrobeItem), args.Error(1)
}

// createTestWardrobeHandler создает тестовый обработчик с моками
func createTestWardrobeHandler() (*WardrobeHandler, *MockWardrobeService) {
	logger, _ := zap.NewDevelopment()
	mockService := new(MockWardrobeService)

	// Создаем обработчик напрямую, используя мок-сервис
	handler := &WardrobeHandler{
		svc: mockService,
		log: logger,
	}

	return handler, mockService
}

// TestWardrobeHandler_List_Success тестирует успешный список гардероба
func TestWardrobeHandler_List_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	req := httptest.NewRequest(http.MethodGet, "/wardrobe", nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	userID := domain.NewID()
	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)

	items := []domain.WardrobeItem{
		{
			ID:       domain.NewID(),
			UserID:   userID,
			Item: domain.ClothingItem{
				Name:     "T-Shirt",
				Category: "upper",
			},
		},
	}

	mockService.On("List", mock.Anything, userID, mock.Anything).Return(items, 1, nil)

	handler.List(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "items")
	assert.Contains(t, rr.Body.String(), "T-Shirt")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_List_Unauthorized тестирует список без аутентификации
func TestWardrobeHandler_List_Unauthorized(t *testing.T) {
	handler, _ := createTestWardrobeHandler()

	req := httptest.NewRequest(http.MethodGet, "/wardrobe", nil)
	rr := httptest.NewRecorder()

	handler.List(rr, req)

	assert.Equal(t, http.StatusUnauthorized, rr.Code)
	assert.Contains(t, rr.Body.String(), "auth required")
}

// TestWardrobeHandler_List_WithFilters тестирует список с фильтрами
func TestWardrobeHandler_List_WithFilters(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	req := httptest.NewRequest(http.MethodGet, "/wardrobe?category=upper&season=summer&is_favorite=true&page=2&limit=10", nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	userID := domain.NewID()
	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)

	items := []domain.WardrobeItem{
		{
			ID:       domain.NewID(),
			UserID:     userID,
			IsFavorite: true,
			Item: domain.ClothingItem{
				Name:       "Summer Shirt",
				Category:   "upper",
			},
		},
	}

	mockService.On("List", mock.Anything, userID, mock.Anything).Return(items, 1, nil)

	handler.List(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "Summer Shirt")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Create_Success тестирует успешное создание элемента
func TestWardrobeHandler_Create_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	reqBody := domain.WardrobeCreateRequest{
		Name:        strPtr("New Jacket"),
		Category:    strPtr("outerwear"),
		Subcategory: strPtr("jacket"),
		Style:       strPtr("casual"),
		BaseColour:  strPtr("black"),
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPost, "/wardrobe", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	userID := domain.NewID()
	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)

	createdItem := &domain.WardrobeItem{
		ID:       domain.NewID(),
		UserID:   userID,
		Item: domain.ClothingItem{
			Name:     "New Jacket",
			Category: "outerwear",
		},
	}

	mockService.On("Create", mock.Anything, userID, mock.Anything).Return(createdItem, nil)

	handler.Create(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "wardrobe_item")
	assert.Contains(t, rr.Body.String(), "New Jacket")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Create_Unauthorized тестирует создание без аутентификации
func TestWardrobeHandler_Create_Unauthorized(t *testing.T) {
	handler, _ := createTestWardrobeHandler()

	reqBody := domain.WardrobeCreateRequest{
		Name:     strPtr("Test"),
		Category: strPtr("upper"),
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPost, "/wardrobe", bytes.NewReader(body))
	rr := httptest.NewRecorder()

	handler.Create(rr, req)

	assert.Equal(t, http.StatusUnauthorized, rr.Code)
}

// TestWardrobeHandler_Create_InvalidJSON тестирует создание с невалидным JSON
func TestWardrobeHandler_Create_InvalidJSON(t *testing.T) {
	handler, _ := createTestWardrobeHandler()

	req := httptest.NewRequest(http.MethodPost, "/wardrobe", strings.NewReader("invalid json"))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	userID := domain.NewID()
	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)

	handler.Create(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

// TestWardrobeHandler_Get_Success тестирует успешное получение элемента
func TestWardrobeHandler_Get_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	req := httptest.NewRequest(http.MethodGet, "/wardrobe/"+itemID.String(), nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)

	// Добавляем ID в маршрут
	router := mux.NewRouter()
	router.HandleFunc("/wardrobe/{id}", handler.Get).Methods(http.MethodGet)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	item := &domain.WardrobeItem{
		ID:       itemID,
		UserID:   userID,
		Item: domain.ClothingItem{
			Name:     "Test Item",
			Category: "upper",
		},
	}

	mockService.On("Get", mock.Anything, userID, itemID).Return(item, nil)

	handler.Get(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "Test Item")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Get_NotFound тестирует получение несуществующего элемента
func TestWardrobeHandler_Get_NotFound(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	req := httptest.NewRequest(http.MethodGet, "/wardrobe/"+itemID.String(), nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	mockService.On("Get", mock.Anything, userID, itemID).Return(nil, nil)

	handler.Get(rr, req)

	assert.Equal(t, http.StatusNotFound, rr.Code)
	assert.Contains(t, rr.Body.String(), "not found")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Get_InvalidID тестирует получение с невалидным ID
func TestWardrobeHandler_Get_InvalidID(t *testing.T) {
	handler, _ := createTestWardrobeHandler()

	req := httptest.NewRequest(http.MethodGet, "/wardrobe/invalid-id", nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	userID := domain.NewID()
	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": "invalid-id"})

	handler.Get(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
}

// TestWardrobeHandler_Update_Success тестирует успешное обновление элемента
func TestWardrobeHandler_Update_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	reqBody := domain.WardrobeUpdateRequest{
		CustomName: strPtr("Updated Name"),
		Notes:      strPtr("Updated notes"),
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPut, "/wardrobe/"+itemID.String(), bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	updatedItem := &domain.WardrobeItem{
		ID:         itemID,
		UserID:     userID,
		CustomName: strPtr("Updated Name"),
		Notes:      strPtr("Updated notes"),
		Item: domain.ClothingItem{
			Name:     "Test Item",
			Category: "upper",
		},
	}

	mockService.On("Get", mock.Anything, userID, itemID).Return(updatedItem, nil)
	mockService.On("Update", mock.Anything, userID, itemID, mock.Anything).Return(updatedItem, nil)

	handler.Update(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "Updated Name")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Delete_Success тестирует успешное удаление элемента
func TestWardrobeHandler_Delete_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	req := httptest.NewRequest(http.MethodDelete, "/wardrobe/"+itemID.String(), nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	mockService.On("Delete", mock.Anything, userID, itemID).Return(nil)

	handler.Delete(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "success")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Delete_NotFound тестирует удаление несуществующего элемента
func TestWardrobeHandler_Delete_NotFound(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	req := httptest.NewRequest(http.MethodDelete, "/wardrobe/"+itemID.String(), nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	mockService.On("Delete", mock.Anything, userID, itemID).Return(assert.AnError)

	handler.Delete(rr, req)

	assert.Equal(t, http.StatusNotFound, rr.Code)

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Favorite_Success тестирует установку статуса избранного
func TestWardrobeHandler_Favorite_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	reqBody := domain.WardrobeToggleRequest{
		IsFavorite: boolPtr(true),
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPost, "/wardrobe/"+itemID.String()+"/favorite", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	mockService.On("SetFavorite", mock.Anything, userID, itemID, true).Return(nil)

	handler.Favorite(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "success")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Favorite_MissingValue тестирует установку без значения
func TestWardrobeHandler_Favorite_MissingValue(t *testing.T) {
	handler, _ := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	req := httptest.NewRequest(http.MethodPost, "/wardrobe/"+itemID.String()+"/favorite", bytes.NewReader([]byte("{}")))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	handler.Favorite(rr, req)

	assert.Equal(t, http.StatusBadRequest, rr.Code)
	assert.Contains(t, rr.Body.String(), "is_favorite is required")
}

// TestWardrobeHandler_Archive_Success тестирует установку статуса архивного
func TestWardrobeHandler_Archive_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	reqBody := domain.WardrobeToggleRequest{
		IsArchived: boolPtr(true),
	}
	body, _ := json.Marshal(reqBody)

	req := httptest.NewRequest(http.MethodPost, "/wardrobe/"+itemID.String()+"/archive", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	mockService.On("SetArchived", mock.Anything, userID, itemID, true).Return(nil)

	handler.Archive(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "success")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Worn_Success тестирует отметку элемента как надетого
func TestWardrobeHandler_Worn_Success(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	req := httptest.NewRequest(http.MethodPost, "/wardrobe/"+itemID.String()+"/worn", nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	wornItem := &domain.WardrobeItem{
		ID:         itemID,
		UserID:     userID,
		WearCount:  5,
		LastWornAt: timePtr(time.Now()),
		Item: domain.ClothingItem{
			Name:     "Test Item",
			Category: "upper",
		},
	}

	mockService.On("MarkWorn", mock.Anything, userID, itemID).Return(wornItem, nil)

	handler.Worn(rr, req)

	assert.Equal(t, http.StatusOK, rr.Code)
	assert.Contains(t, rr.Body.String(), "wear_count")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Worn_NotFound тестирует отметку несуществующего элемента
func TestWardrobeHandler_Worn_NotFound(t *testing.T) {
	handler, mockService := createTestWardrobeHandler()

	userID := domain.NewID()
	itemID := domain.NewID()

	req := httptest.NewRequest(http.MethodPost, "/wardrobe/"+itemID.String()+"/worn", nil)
	req.Header.Set("Content-Type", "application/json")
	rr := httptest.NewRecorder()

	ctx := middleware.WithUserID(req.Context(), userID)
	req = req.WithContext(ctx)
	req = mux.SetURLVars(req, map[string]string{"id": itemID.String()})

	mockService.On("MarkWorn", mock.Anything, userID, itemID).Return(nil, nil)

	handler.Worn(rr, req)

	assert.Equal(t, http.StatusNotFound, rr.Code)
	assert.Contains(t, rr.Body.String(), "not found")

	mockService.AssertExpectations(t)
}

// TestWardrobeHandler_Routes тестирует регистрацию маршрутов
func TestWardrobeHandler_Routes(t *testing.T) {
	handler, _ := createTestWardrobeHandler()

	router := mux.NewRouter()
	subRouter := router.PathPrefix("/wardrobe").Subrouter()
	handler.RegisterRoutes(subRouter)

	routes := []struct {
		path   string
		method string
	}{
		{"/wardrobe", http.MethodGet},
		{"/wardrobe", http.MethodPost},
		{"/wardrobe/{id}", http.MethodGet},
		{"/wardrobe/{id}", http.MethodPut},
		{"/wardrobe/{id}", http.MethodDelete},
		{"/wardrobe/{id}/favorite", http.MethodPost},
		{"/wardrobe/{id}/archive", http.MethodPost},
		{"/wardrobe/{id}/worn", http.MethodPost},
	}

	for _, route := range routes {
		req := httptest.NewRequest(route.method, route.path, nil)
		rr := httptest.NewRecorder()

		router.ServeHTTP(rr, req)

		// Проверяем, что маршрут существует (не 404)
		// 401 будет для маршрутов, требующих аутентификацию
		assert.NotEqual(t, http.StatusNotFound, rr.Code, "Route %s %s should exist", route.method, route.path)
	}
}
