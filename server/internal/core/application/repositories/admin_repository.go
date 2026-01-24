package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// AdminStats структура для статистики администратора
type AdminStats struct {
	UsersTotal           int     `json:"users_total"`           // Всего пользователей
	RecommendationsTotal int     `json:"recommendations_total"` // Всего рекомендаций
	WardrobeTotal        int     `json:"wardrobe_total"`        // Всего вещей в гардеробах
	PaymentsTotal        int     `json:"payments_total"`        // Всего платежей
	PaymentsRevenue      float64 `json:"payments_revenue_completed"` // Доход от завершенных платежей
	ActiveSubscriptions  int     `json:"active_subscriptions"`  // Активные подписки
	NotificationsTotal   int     `json:"notifications_total"`   // Всего уведомлений
}

// AdminUserRow структура для строки информации о пользователе в админке
type AdminUserRow struct {
	ID          domain.ID  `json:"id"`                    // Уникальный идентификатор пользователя
	Email       string     `json:"email"`                 // Электронная почта
	DisplayName *string    `json:"display_name,omitempty"` // Отображаемое имя
	IsActive    bool       `json:"is_active"`             // Активен ли пользователь
	IsVerified  bool       `json:"is_verified"`           // Подтвержден ли аккаунт
	CreatedAt   time.Time  `json:"created_at"`            // Дата создания аккаунта
	LastLoginAt *time.Time `json:"last_login_at,omitempty"` // Дата последнего входа
}

// AuditRow структура для строки аудита
type AuditRow struct {
	ID           domain.ID  `json:"id"`                      // Уникальный идентификатор записи аудита
	UserID       *domain.ID `json:"user_id,omitempty"`       // Идентификатор пользователя (если применимо)
	Action       string     `json:"action"`                  // Выполненное действие
	ResourceType *string    `json:"resource_type,omitempty"` // Тип ресурса (если применимо)
	ResourceID   *domain.ID `json:"resource_id,omitempty"`   // Идентификатор ресурса (если применимо)
	IP           *string    `json:"ip_address,omitempty"`    // IP-адрес пользователя
	Success      bool       `json:"success"`                 // Успешно ли выполнено действие
	ErrorMessage *string    `json:"error_message,omitempty"` // Сообщение об ошибке (если было)
	CreatedAt    time.Time  `json:"created_at"`              // Дата создания записи
}

// CreatePromoRequest структура запроса на создание промо-акции
type CreatePromoRequest struct {
	Code            string      `json:"code"`                   // Код промо-акции
	DiscountType    string      `json:"discount_type"`          // Тип скидки: percent|fixed|trial_days
	DiscountValue   float64     `json:"discount_value"`         // Значение скидки
	ApplicablePlans []domain.ID `json:"applicable_plans,omitempty"` // Применимые планы подписки
	MaxUses         *int        `json:"max_uses,omitempty"`     // Максимальное количество использований
	ValidUntil      *time.Time  `json:"valid_until,omitempty"`  // Дата окончания действия
	IsActive        *bool       `json:"is_active,omitempty"`    // Активна ли промо-акция
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
