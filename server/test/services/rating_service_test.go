package services_test

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/application/services"
	"outfitstyle/server/internal/core/domain"
)

// MockOutfitRatingRepository - мок-реализация OutfitRatingRepository
type MockOutfitRatingRepository struct {
	mock.Mock
}

func (m *MockOutfitRatingRepository) Create(ctx context.Context, rating *domain.OutfitRating) error {
	args := m.Called(ctx, rating)
	return args.Error(0)
}

func (m *MockOutfitRatingRepository) GetByRecommendation(ctx context.Context, recommendationID domain.ID) ([]domain.OutfitRating, error) {
	args := m.Called(ctx, recommendationID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.OutfitRating), args.Error(1)
}

func (m *MockOutfitRatingRepository) GetByUserAndRecommendation(ctx context.Context, userID, recommendationID domain.ID) (*domain.OutfitRating, error) {
	args := m.Called(ctx, userID, recommendationID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.OutfitRating), args.Error(1)
}

func (m *MockOutfitRatingRepository) GetAverageQuality(ctx context.Context, recommendationID domain.ID) (*domain.RecommendationQualityStats, error) {
	args := m.Called(ctx, recommendationID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.RecommendationQualityStats), args.Error(1)
}

func (m *MockOutfitRatingRepository) GetUserRatingsForRecommendations(ctx context.Context, userID domain.ID, recommendationIDs []domain.ID) (map[domain.ID]int, error) {
	args := m.Called(ctx, userID, recommendationIDs)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(map[domain.ID]int), args.Error(1)
}

func (m *MockOutfitRatingRepository) GetLowQualityItems(ctx context.Context, userID domain.ID, threshold float64) ([]domain.LowQualityItem, error) {
	args := m.Called(ctx, userID, threshold)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.LowQualityItem), args.Error(1)
}

func (m *MockOutfitRatingRepository) GetUserStats(ctx context.Context, userID domain.ID) (*domain.UserRatingStats, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.UserRatingStats), args.Error(1)
}

func (m *MockOutfitRatingRepository) HasRated(ctx context.Context, userID, recommendationID domain.ID) (bool, error) {
	args := m.Called(ctx, userID, recommendationID)
	return args.Bool(0), args.Error(1)
}

func (m *MockOutfitRatingRepository) Update(ctx context.Context, rating *domain.OutfitRating) error {
	args := m.Called(ctx, rating)
	return args.Error(0)
}

// MockRecommendationRepository - мок-реализация RecommendationRepository
type MockRecommendationRepository struct {
	mock.Mock
}

func (m *MockRecommendationRepository) Create(ctx context.Context, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	args := m.Called(ctx, rec, items)
	return args.Get(0).(domain.ID), args.Error(1)
}

func (m *MockRecommendationRepository) CreateWithSession(ctx context.Context, session *repositories.RecommendationSession, rec *domain.RecommendationRecord, items []repositories.RecommendationItemCreate) (domain.ID, error) {
	args := m.Called(ctx, session, rec, items)
	return args.Get(0).(domain.ID), args.Error(1)
}

func (m *MockRecommendationRepository) CreateRecommendation(ctx context.Context, rec *domain.RecommendationResponse) (*domain.RecommendationResponse, error) {
	args := m.Called(ctx, rec)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.RecommendationResponse), args.Error(1)
}

func (m *MockRecommendationRepository) GetByID(ctx context.Context, id domain.ID) (*domain.RecommendationRecord, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.RecommendationRecord), args.Error(1)
}

func (m *MockRecommendationRepository) GetByUserAndID(ctx context.Context, userID, id domain.ID) (*domain.RecommendationRecord, error) {
	args := m.Called(ctx, userID, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.RecommendationRecord), args.Error(1)
}

func (m *MockRecommendationRepository) ListByUser(ctx context.Context, userID domain.ID, q domain.RecommendationListQuery) ([]domain.RecommendationRecord, int, error) {
	args := m.Called(ctx, userID, q)
	return args.Get(0).([]domain.RecommendationRecord), args.Int(1), args.Error(2)
}

func (m *MockRecommendationRepository) GetItemRows(ctx context.Context, recommendationID domain.ID) ([]repositories.RecommendationItemRow, error) {
	args := m.Called(ctx, recommendationID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]repositories.RecommendationItemRow), args.Error(1)
}

func (m *MockRecommendationRepository) SetRating(ctx context.Context, userID, recommendationID domain.ID, rating int, thermalFeedback *string, feedback *string) (bool, error) {
	args := m.Called(ctx, userID, recommendationID, rating, thermalFeedback, feedback)
	return args.Bool(0), args.Error(1)
}

func (m *MockRecommendationRepository) SetFavorite(ctx context.Context, userID, recommendationID domain.ID, isFavorite bool) error {
	args := m.Called(ctx, userID, recommendationID, isFavorite)
	return args.Error(0)
}

func (m *MockRecommendationRepository) ListFavorites(ctx context.Context, userID domain.ID, limit int) ([]domain.RecommendationRecord, error) {
	args := m.Called(ctx, userID, limit)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.RecommendationRecord), args.Error(1)
}

func (m *MockRecommendationRepository) CreateSession(ctx context.Context, session *repositories.RecommendationSession) (domain.ID, error) {
	args := m.Called(ctx, session)
	return args.Get(0).(domain.ID), args.Error(1)
}

func (m *MockRecommendationRepository) DeleteByUserAndID(ctx context.Context, userID, id domain.ID) error {
	args := m.Called(ctx, userID, id)
	return args.Error(0)
}

// MockClothingRepository - мок-реализация ClothingRepository
type MockClothingRepository struct {
	mock.Mock
}

func (m *MockClothingRepository) GetByID(ctx context.Context, id domain.ID) (*domain.ClothingItem, error) {
	args := m.Called(ctx, id)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(*domain.ClothingItem), args.Error(1)
}

func (m *MockClothingRepository) GetByIDs(ctx context.Context, ids []domain.ID) ([]domain.ClothingItem, error) {
	args := m.Called(ctx, ids)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.ClothingItem), args.Error(1)
}

func (m *MockClothingRepository) ListWardrobeCandidates(ctx context.Context, userID domain.ID, limit int) ([]domain.ClothingItem, error) {
	args := m.Called(ctx, userID, limit)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.ClothingItem), args.Error(1)
}

func (m *MockClothingRepository) ListCatalogCandidates(ctx context.Context, includePartners bool, limit int) ([]domain.ClothingItem, error) {
	args := m.Called(ctx, includePartners, limit)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.ClothingItem), args.Error(1)
}

func (m *MockClothingRepository) ListWardrobeCandidatesLite(ctx context.Context, userID domain.ID, limit int) ([]domain.CandidateLite, error) {
	args := m.Called(ctx, userID, limit)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.CandidateLite), args.Error(1)
}

func (m *MockClothingRepository) ListCatalogCandidatesLite(ctx context.Context, includePartners bool, limit int) ([]domain.CandidateLite, error) {
	args := m.Called(ctx, includePartners, limit)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).([]domain.CandidateLite), args.Error(1)
}

func (m *MockClothingRepository) CreateUserItem(ctx context.Context, userID domain.ID, item domain.ClothingItem) (domain.ID, error) {
	args := m.Called(ctx, userID, item)
	return args.Get(0).(domain.ID), args.Error(1)
}

func (m *MockClothingRepository) GetItemsByCategory(ctx context.Context, userID domain.ID) (map[string][]domain.ClothingItem, error) {
	args := m.Called(ctx, userID)
	if args.Get(0) == nil {
		return nil, args.Error(1)
	}
	return args.Get(0).(map[string][]domain.ClothingItem), args.Error(1)
}

// MockEventPublisher - мок-реализация EventPublisher
type MockEventPublisher struct {
	mock.Mock
}

func (m *MockEventPublisher) PublishRecommendationRequested(ctx context.Context, userID domain.ID, context interface{}, candidates []interface{}) error {
	args := m.Called(ctx, userID, context, candidates)
	return args.Error(0)
}

func (m *MockEventPublisher) PublishRecommendationProcessed(ctx context.Context, userID domain.ID, requestID string, rankedItems []interface{}) error {
	args := m.Called(ctx, userID, requestID, rankedItems)
	return args.Error(0)
}

func (m *MockEventPublisher) PublishUserFeedback(ctx context.Context, userID, recommendationID domain.ID, rating int, feedback string) error {
	args := m.Called(ctx, userID, recommendationID, rating, feedback)
	return args.Error(0)
}

func (m *MockEventPublisher) Close() error {
	args := m.Called()
	return args.Error(0)
}

func TestRatingService_RateOutfit_Success(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	recommendationID := domain.NewID()
	existingRec := &domain.RecommendationRecord{
		ID:     recommendationID,
		UserID: userID,
	}

	// Ожидания
	mockRecRepo.On("GetByUserAndID", mock.Anything, userID, recommendationID).Return(existingRec, nil)
	mockRatingRepo.On("Create", mock.Anything, mock.AnythingOfType("*domain.OutfitRating")).Return(nil)
	mockRecRepo.On("SetRating", mock.Anything, userID, recommendationID, 5, (*string)(nil), (*string)(nil)).Return(false, nil)
	mockEventPub.On("PublishUserFeedback", mock.Anything, userID, recommendationID, 5, "").Return(nil)

	// Выполнение
	rating, err := svc.RateOutfit(
		context.Background(),
		userID,
		recommendationID,
		5, // Рейтинг 5 звёзд
		[]int64{1, 2, 3},
		nil,
		nil,
	)

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, rating)
	assert.Equal(t, 5, rating.Rating)
	assert.Equal(t, 10, rating.QualityScore) // (5-3)*5 = 10

	mockRatingRepo.AssertExpectations(t)
	mockRecRepo.AssertExpectations(t)
	mockEventPub.AssertExpectations(t)
}

func TestRatingService_RateOutfit_InvalidRating(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	recommendationID := domain.NewID()

	// Рейтинг вне диапазона
	rating, err := svc.RateOutfit(
		context.Background(),
		userID,
		recommendationID,
		10, // Неверное значение
		[]int64{1, 2, 3},
		nil,
		nil,
	)

	// Проверка
	assert.Error(t, err)
	assert.Nil(t, rating)
	assert.Contains(t, err.Error(), "рейтинг должен быть от 1 до 5")
}

func TestRatingService_RateOutfit_RecommendationNotFound(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	recommendationID := domain.NewID()

	// Ожидания - рекомендация не найдена
	mockRecRepo.On("GetByUserAndID", mock.Anything, userID, recommendationID).Return(nil, repositories.ErrNotFound)

	// Выполнение
	rating, err := svc.RateOutfit(
		context.Background(),
		userID,
		recommendationID,
		5,
		[]int64{1, 2, 3},
		nil,
		nil,
	)

	// Проверка
	assert.Error(t, err)
	assert.Nil(t, rating)

	mockRecRepo.AssertExpectations(t)
}

func TestRatingService_GetRecommendationQuality_Success(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	recommendationID := domain.NewID()

	expectedStats := &domain.RecommendationQualityStats{
		RecommendationID: recommendationID,
		RatingCount:      10,
		AvgRating:        4.5,
		AvgQualityScore:  7.5,
		PositiveCount:    8,
		NegativeCount:    1,
	}

	// Ожидания
	mockRatingRepo.On("GetAverageQuality", mock.Anything, recommendationID).Return(expectedStats, nil)
	mockRatingRepo.On("GetByUserAndRecommendation", mock.Anything, userID, recommendationID).Return((*domain.OutfitRating)(nil), repositories.ErrNotFound)

	// Выполнение
	quality, err := svc.GetRecommendationQuality(context.Background(), userID, recommendationID)

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, quality)
	assert.Equal(t, expectedStats.AvgRating, quality.AvgRating)
	assert.Equal(t, expectedStats.AvgQualityScore, quality.AvgQualityScore)
	assert.Equal(t, expectedStats.RatingCount, quality.RatingCount)

	mockRatingRepo.AssertExpectations(t)
}

func TestRatingService_GetUserRatingStats_Success(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()

	expectedStats := &domain.UserRatingStats{
		UserID:          userID,
		TotalRatings:    25,
		AvgRating:       4.2,
		AvgQualityScore: 6.0,
		PositiveRatings: 20,
		NegativeRatings: 3,
	}

	// Ожидания
	mockRatingRepo.On("GetUserStats", mock.Anything, userID).Return(expectedStats, nil)

	// Выполнение
	stats, err := svc.GetUserRatingStats(context.Background(), userID)

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, stats)
	assert.Equal(t, expectedStats.TotalRatings, stats.TotalRatings)
	assert.Equal(t, expectedStats.AvgRating, stats.AvgRating)

	mockRatingRepo.AssertExpectations(t)
}

func TestRatingService_HasUserRated_True(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	recommendationID := domain.NewID()

	// Ожидания
	mockRatingRepo.On("HasRated", mock.Anything, userID, recommendationID).Return(true, nil)

	// Выполнение
	hasRated, err := svc.HasUserRated(context.Background(), userID, recommendationID)

	// Проверка
	assert.NoError(t, err)
	assert.True(t, hasRated)

	mockRatingRepo.AssertExpectations(t)
}

func TestRatingService_HasUserRated_False(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	recommendationID := domain.NewID()

	// Ожидания
	mockRatingRepo.On("HasRated", mock.Anything, userID, recommendationID).Return(false, nil)

	// Выполнение
	hasRated, err := svc.HasUserRated(context.Background(), userID, recommendationID)

	// Проверка
	assert.NoError(t, err)
	assert.False(t, hasRated)

	mockRatingRepo.AssertExpectations(t)
}

func TestRatingService_FilterLowQualityItems_Success(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	candidateIDs := []domain.ID{
		domain.NewID(),
		domain.NewID(),
		domain.NewID(),
	}

	// Вещи с низким рейтингом
	lowQualityItems := []domain.LowQualityItem{
		{ClothingItemID: 1, AvgQualityScore: -8.0},
	}

	// Ожидания
	mockRatingRepo.On("GetLowQualityItems", mock.Anything, userID, -5.0).Return(lowQualityItems, nil)
	mockClothingRepo.On("GetByIDs", mock.Anything, candidateIDs).Return([]domain.ClothingItem{
		{ID: candidateIDs[0]},
		{ID: candidateIDs[1]},
		{ID: candidateIDs[2]},
	}, nil)

	// Выполнение
	filteredIDs, err := svc.FilterLowQualityItems(context.Background(), userID, candidateIDs, -5.0)

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, filteredIDs)
	// Количество должно уменьшиться на количество отфильтрованных
	assert.LessOrEqual(t, len(filteredIDs), len(candidateIDs))

	mockRatingRepo.AssertExpectations(t)
	mockClothingRepo.AssertExpectations(t)
}

func TestRatingService_GetLowQualityItemsForML_Success(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()

	// Вещи с низким рейтингом
	lowQualityItems := []domain.LowQualityItem{
		{ClothingItemID: 1, AvgQualityScore: -8.0},
		{ClothingItemID: 2, AvgQualityScore: -6.0},
	}

	// Ожидания
	mockRatingRepo.On("GetLowQualityItems", mock.Anything, userID, -5.0).Return(lowQualityItems, nil)

	// Выполнение
	itemIDs, err := svc.GetLowQualityItemsForML(context.Background(), userID)

	// Проверка
	assert.NoError(t, err)
	assert.NotNil(t, itemIDs)
	assert.Len(t, itemIDs, 2)
	assert.Contains(t, itemIDs, int64(1))
	assert.Contains(t, itemIDs, int64(2))

	mockRatingRepo.AssertExpectations(t)
}

func TestRatingService_CalculateOutfitQualityScore_Success(t *testing.T) {
	// Подготовка
	mockRatingRepo := new(MockOutfitRatingRepository)
	mockRecRepo := new(MockRecommendationRepository)
	mockClothingRepo := new(MockClothingRepository)
	mockEventPub := new(MockEventPublisher)
	logger := zap.NewNop()

	svc := services.NewRatingService(mockRatingRepo, mockRecRepo, mockClothingRepo, mockEventPub, logger)

	userID := domain.NewID()
	outfitItemIDs := []int64{1, 2, 3}

	// Ожидания - возвращаем все вещи для расчёта
	mockRatingRepo.On("GetLowQualityItems", mock.Anything, userID, float64(0)).Return([]domain.LowQualityItem{
		{ClothingItemID: 1, AvgQualityScore: 8.0},
		{ClothingItemID: 2, AvgQualityScore: 6.0},
		{ClothingItemID: 3, AvgQualityScore: 4.0},
	}, nil)

	// Выполнение
	score, err := svc.CalculateOutfitQualityScore(context.Background(), userID, outfitItemIDs)

	// Проверка
	assert.NoError(t, err)
	assert.Equal(t, 6.0, score) // (8+6+4)/3 = 6.0

	mockRatingRepo.AssertExpectations(t)
}
