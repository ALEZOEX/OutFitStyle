package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

// Experiment структура эксперимента (A/B тестирование)
type Experiment struct {
	ID             domain.ID  // Уникальный идентификатор эксперимента
	Name           string     // Название эксперимента
	Description    string     // Описание эксперимента
	Variants       []string   // Варианты эксперимента
	Weights        []int      // Веса вариантов (процент участников для каждого варианта)
	VariantsJSON   []byte     // Варианты эксперимента в формате JSON
	StartDate      time.Time  // Дата начала эксперимента
	EndDate        *time.Time // Дата окончания эксперимента
	IsActive       bool       // Активен ли эксперимент
	CreatedAt      time.Time  // Дата создания
	UpdatedAt      time.Time  // Дата последнего обновления
	Status         string     // Статус: draft/running/stopped и т.д.
	UserPercentage int        // Процент пользователей, участвующих в эксперименте
}

// ExperimentAssignment структура присвоения эксперимента пользователю
type ExperimentAssignment struct {
	ExperimentID domain.ID // Идентификатор эксперимента
	UserID       domain.ID // Идентификатор пользователя
	Variant      string    // Назначенный вариант (например, A или B)
	AssignedAt   time.Time // Дата назначения
}

// ExperimentRepository интерфейс репозитория экспериментов
type ExperimentRepository interface {
	// GetRunningByName возвращает запущенный эксперимент по названию
	GetRunningByName(ctx context.Context, name string) (*Experiment, error)

	// GetAssignment возвращает назначение эксперимента пользователю
	GetAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID) (*ExperimentAssignment, error)

	// CreateAssignment создает новое назначение эксперимента пользователю
	CreateAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string) error

	// RecordEvent записывает событие эксперимента (для анализа результатов)
	RecordEvent(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string, eventName string, eventValue *float64, eventData []byte) error
}
