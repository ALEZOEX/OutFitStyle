package services

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// AffiliateService сервис для работы с аффилированными программами
type AffiliateService struct {
	affiliateRepo repositories.AffiliateRepository
	partnerRepo   repositories.PartnerRepository
	itemRepo      repositories.ClothingItemRepository
	userRepo      repositories.UserRepository
}

// NewAffiliateService создает новый экземпляр сервиса аффилированных программ
func NewAffiliateService(
	affiliateRepo repositories.AffiliateRepository,
	partnerRepo repositories.PartnerRepository,
	itemRepo repositories.ClothingItemRepository,
	userRepo repositories.UserRepository,
) *AffiliateService {
	return &AffiliateService{
		affiliateRepo: affiliateRepo,
		partnerRepo:   partnerRepo,
		itemRepo:      itemRepo,
		userRepo:      userRepo,
	}
}

// AffiliateClickParams параметры для регистрации аффилированного клика
type AffiliateClickParams struct {
	UserID         *domain.ID  // Идентификатор пользователя (может быть nil для анонимных кликов)
	PartnerID      domain.ID   // Идентификатор партнера
	ClothingItemID *domain.ID  // Идентификатор элемента одежды (если применимо)
	RecommendationID *domain.ID // Идентификатор рекомендации (если клик по рекомендации)
	SessionID      *string     // Идентификатор сессии
	ClickID        *string     // Уникальный идентификатор клика (для трекинга)
}

// RecordClick регистрирует аффилированный клик
func (s *AffiliateService) RecordClick(ctx context.Context, params AffiliateClickParams) error {
	click := &domain.AffiliateClick{
		UserID:           params.UserID,
		PartnerID:        params.PartnerID,
		ClothingItemID:   params.ClothingItemID,
		RecommendationID: params.RecommendationID,
		SessionID:        params.SessionID,
		ClickID:          params.ClickID,
		ClickedAt:        time.Now(),
		Converted:        false,
	}

	return s.affiliateRepo.RecordClick(ctx, click)
}

// RecordConversion регистрирует конверсию по аффилированному клику
func (s *AffiliateService) RecordConversion(ctx context.Context, clickID string, value float64, commission float64) error {
	click, err := s.affiliateRepo.GetClickByClickID(ctx, clickID)
	if err != nil {
		return fmt.Errorf("не удалось найти клик: %w", err)
	}

	if click == nil {
		return errors.New("аффилированный клик не найден")
	}

	now := time.Now()
	click.Converted = true
	click.ConvertedAt = &now
	click.ConversionValue = &value
	click.CommissionEarned = &commission

	return s.affiliateRepo.UpdateClick(ctx, click)
}

// GetPartnerStats возвращает статистику партнера
func (s *AffiliateService) GetPartnerStats(ctx context.Context, partnerID domain.ID, startDate, endDate time.Time) (*domain.PartnerStats, error) {
	return s.affiliateRepo.GetPartnerStats(ctx, partnerID, startDate, endDate)
}

// GetPartnerCommissions возвращает комиссионные партнера
func (s *AffiliateService) GetPartnerCommissions(ctx context.Context, partnerID domain.ID, startDate, endDate time.Time) ([]domain.AffiliateCommission, error) {
	return s.affiliateRepo.GetPartnerCommissions(ctx, partnerID, startDate, endDate)
}

// GenerateAffiliateLink генерирует аффилированную ссылку для партнера
func (s *AffiliateService) GenerateAffiliateLink(ctx context.Context, partnerID domain.ID, destinationURL string, userID *domain.ID) (string, error) {
	partner, err := s.partnerRepo.GetByID(ctx, partnerID)
	if err != nil {
		return "", fmt.Errorf("не удалось получить партнера: %w", err)
	}

	if partner == nil || !partner.IsActive {
		return "", errors.New("партнер не найден или неактивен")
	}

	// Если у партнера есть шаблон аффилированной ссылки, используем его
	if partner.AffiliateURLTemplate != nil && *partner.AffiliateURLTemplate != "" {
		// Создаем уникальный click_id для трекинга
		clickID := domain.NewID().String()

		// Записываем клик в базу данных
		params := AffiliateClickParams{
			UserID:    userID,
			PartnerID: partnerID,
			ClickID:   &clickID,
		}

		if err := s.RecordClick(ctx, params); err != nil {
			return "", fmt.Errorf("не удалось зарегистрировать клик: %w", err)
		}

		// Заменяем плейсхолдеры в шаблоне
		affiliateURL := s.replaceAffiliatePlaceholders(*partner.AffiliateURLTemplate, destinationURL, clickID)
		return affiliateURL, nil
	}

	// Если шаблона нет, возвращаем оригинальный URL
	return destinationURL, nil
}

// replaceAffiliatePlaceholders заменяет плейсхолдеры в шаблоне аффилированной ссылки
func (s *AffiliateService) replaceAffiliatePlaceholders(template, destinationURL, clickID string) string {
	// Заменяем {destination_url} на целевой URL
	template = strings.ReplaceAll(template, "{destination_url}", destinationURL)
	// Заменяем {click_id} на идентификатор клика
	template = strings.ReplaceAll(template, "{click_id}", clickID)
	// Можно добавить другие плейсхолдеры по мере необходимости
	return template
}

// GetAffiliateEarnings возвращает заработок пользователя по аффилированным программам
func (s *AffiliateService) GetAffiliateEarnings(ctx context.Context, userID domain.ID) (*domain.UserAffiliateEarnings, error) {
	return s.affiliateRepo.GetUserEarnings(ctx, userID)
}

// GetAffiliateLinks возвращает аффилированные ссылки пользователя
func (s *AffiliateService) GetAffiliateLinks(ctx context.Context, userID domain.ID) ([]domain.AffiliateLink, error) {
	return s.affiliateRepo.GetUserAffiliateLinks(ctx, userID)
}

// CreateAffiliateProgram создает новую аффилированную программу
func (s *AffiliateService) CreateAffiliateProgram(ctx context.Context, program domain.AffiliateProgram) error {
	return s.partnerRepo.Create(ctx, &program)
}

// UpdateAffiliateProgram обновляет аффилированную программу
func (s *AffiliateService) UpdateAffiliateProgram(ctx context.Context, program domain.AffiliateProgram) error {
	return s.partnerRepo.Update(ctx, &program)
}

// ListAffiliatePrograms возвращает список аффилированных программ
func (s *AffiliateService) ListAffiliatePrograms(ctx context.Context, activeOnly bool) ([]domain.AffiliateProgram, error) {
	return s.partnerRepo.List(ctx, activeOnly)
}

