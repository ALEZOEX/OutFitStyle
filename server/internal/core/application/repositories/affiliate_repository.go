package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// AffiliateRepository интерфейс репозитория аффилированных программ
type AffiliateRepository interface {
	// RecordClick регистрирует аффилированный клик
	RecordClick(ctx context.Context, click *domain.AffiliateClick) error
	
	// GetClickByClickID возвращает аффилированный клик по идентификатору
	GetClickByClickID(ctx context.Context, clickID string) (*domain.AffiliateClick, error)
	
	// UpdateClick обновляет информацию о клике
	UpdateClick(ctx context.Context, click *domain.AffiliateClick) error
	
	// GetPartnerStats возвращает статистику партнера
	GetPartnerStats(ctx context.Context, partnerID domain.ID, startDate, endDate time.Time) (*domain.PartnerStats, error)
	
	// GetPartnerCommissions возвращает комиссионные партнера
	GetPartnerCommissions(ctx context.Context, partnerID domain.ID, startDate, endDate time.Time) ([]domain.AffiliateCommission, error)
	
	// GetUserEarnings возвращает заработок пользователя по аффилированным программам
	GetUserEarnings(ctx context.Context, userID domain.ID) (*domain.UserAffiliateEarnings, error)
	
	// GetUserAffiliateLinks возвращает аффилированные ссылки пользователя
	GetUserAffiliateLinks(ctx context.Context, userID domain.ID) ([]domain.AffiliateLink, error)
}

// PartnerRepository интерфейс репозитория партнеров
type PartnerRepository interface {
	// GetByID возвращает партнера по идентификатору
	GetByID(ctx context.Context, id domain.ID) (*domain.AffiliateProgram, error)
	
	// Create создает нового партнера
	Create(ctx context.Context, partner *domain.AffiliateProgram) error
	
	// Update обновляет информацию о партнере
	Update(ctx context.Context, partner *domain.AffiliateProgram) error
	
	// List возвращает список партнеров
	List(ctx context.Context, activeOnly bool) ([]domain.AffiliateProgram, error)
}