package repositories

import (
	"context"
	"time"

	"outfitstyle/server/internal/core/domain"
)

type Experiment struct {
	ID             domain.ID
	Name           string
	Status         string // draft/running/stopped etc
	VariantsJSON   []byte
	UserPercentage int
	CreatedAt      time.Time
}

type ExperimentAssignment struct {
	ExperimentID domain.ID
	UserID       domain.ID
	Variant      string
	AssignedAt   time.Time
}

type ExperimentRepository interface {
	GetRunningByName(ctx context.Context, name string) (*Experiment, error)
	GetAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID) (*ExperimentAssignment, error)
	CreateAssignment(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string) error

	RecordEvent(ctx context.Context, experimentID domain.ID, userID domain.ID, variant string, eventName string, eventValue *float64, eventData []byte) error
}
