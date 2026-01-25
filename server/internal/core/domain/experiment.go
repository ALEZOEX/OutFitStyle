package domain

import "time"

type Experiment struct {
	ID          ID         `json:"id"`
	Name        string     `json:"name"`
	Description string     `json:"description"`
	Variants    []string   `json:"variants"`
	Weights     []float64  `json:"weights"` // веса для каждого варианта (должны суммироваться в 1.0)
	StartDate   time.Time  `json:"start_date"`
	EndDate     *time.Time `json:"end_date,omitempty"`
	IsActive    bool       `json:"is_active"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}
