package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// AdminStats структура для статистики администратора
type AdminStats struct {
	TotalUsers           int `json:"total_users"`           // Общее количество пользователей
	ActiveUsers          int `json:"active_users"`          // Количество активных пользователей
	TotalRecommendations int `json:"total_recommendations"` // Общее количество рекомендаций
	TotalOutfitsSaved    int `json:"total_outfits_saved"`   // Общее количество сохраненных нарядов
	TotalWardrobeItems   int `json:"total_wardrobe_items"`  // Общее количество вещей в гардеробах
	TotalAchievements    int `json:"total_achievements"`    // Общее количество полученных достижений
	TotalPayments        int `json:"total_payments"`        // Общее количество платежей
	TotalSupportTickets  int `json:"total_support_tickets"` // Общее количество тикетов поддержки
	TotalFeedback        int `json:"total_feedback"`        // Общее количество отзывов
}

// AdminUserRow структура для строки информации о пользователе в админке
type AdminUserRow struct {
	ID          domain.ID  `json:"id"`                      // Уникальный идентификатор пользователя
	Email       string     `json:"email"`                   // Электронная почта
	DisplayName *string    `json:"display_name,omitempty"`  // Отображаемое имя
	IsActive    bool       `json:"is_active"`               // Активен ли пользователь
	IsVerified  bool       `json:"is_verified"`             // Подтвержден ли аккаунт
	CreatedAt   time.Time  `json:"created_at"`              // Дата создания аккаунта
	LastLoginAt *time.Time `json:"last_login_at,omitempty"` // Дата последнего входа
}

// AuditRow структура для строки аудита
type AuditRow struct {
	ID           domain.ID  `json:"id"`                      // Уникальный идентификатор записи аудита
	UserID       *domain.ID `json:"user_id,omitempty"`       // Идентификатор пользователя (если применимо)
	Action       string     `json:"action"`                  // Выполненное действие
	EntityID     string     `json:"entity_id"`               // Идентификатор сущности
	EntityType   string     `json:"entity_type"`             // Тип сущности
	ResourceType *string    `json:"resource_type,omitempty"` // Тип ресурса (если применимо)
	ResourceID   *domain.ID `json:"resource_id,omitempty"`   // Идентификатор ресурса (если применимо)
	IP           *string    `json:"ip_address,omitempty"`    // IP-адрес пользователя
	Success      bool       `json:"success"`                 // Успешно ли выполнено действие
	ErrorMessage *string    `json:"error_message,omitempty"` // Сообщение об ошибке (если было)
	CreatedAt    time.Time  `json:"created_at"`              // Дата создания записи
}

// CreatePromoRequest структура запроса на создание промо-акции
type CreatePromoRequest struct {
	Code              string      `json:"code"`                       // Код промо-акции
	Type              string      `json:"type"`                       // Тип промо-акции
	Value             float64     `json:"value"`                      // Значение промо-акции
	Currency          string      `json:"currency"`                   // Валюта
	MinOrderAmount    float64     `json:"min_order_amount"`           // Минимальная сумма заказа
	MaxDiscount       float64     `json:"max_discount"`               // Максимальная скидка
	UsageLimit        int         `json:"usage_limit"`                // Лимит использования
	UsageLimitPerUser int         `json:"usage_limit_per_user"`       // Лимит использования на пользователя
	StartDate         time.Time   `json:"start_date"`                 // Дата начала
	EndDate           time.Time   `json:"end_date"`                   // Дата окончания
	IsActive          bool        `json:"is_active"`                  // Активна ли промо-акция
	ApplicablePlans   []domain.ID `json:"applicable_plans,omitempty"` // Применимые планы подписки
	DiscountType      string      `json:"discount_type"`              // Тип скидки: percent|fixed|trial_days
	DiscountValue     float64     `json:"discount_value"`             // Значение скидки
}

// AdminRepository интерфейс репозитория административных функций
type AdminRepository interface {
	// Stats возвращает общую статистику по приложению
	Stats(ctx context.Context) (AdminStats, error)

	// ListUsers возвращает список пользователей с пагинацией
	ListUsers(ctx context.Context, page, limit int) ([]AdminUserRow, int, error)

	// ListAudit возвращает журнал аудита с пагинацией
	ListAudit(ctx context.Context, page, limit int) ([]AuditRow, int, error)

	// CreatePromo создает новую промо-акцию
	CreatePromo(ctx context.Context, createdBy *domain.ID, req CreatePromoRequest) (domain.ID, error)
}
