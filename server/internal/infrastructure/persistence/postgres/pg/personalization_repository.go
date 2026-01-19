package pg

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

type PersonalizationRepository struct {
	db *pgxpool.Pool
}

func NewPersonalizationRepository(db *pgxpool.Pool) *PersonalizationRepository {
	return &PersonalizationRepository{db: db}
}

func (r *PersonalizationRepository) GetUserStylePreferences(ctx context.Context, userID domain.ID) (*domain.UserStylePreferences, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *PersonalizationRepository) UpdateUserStylePreferences(ctx context.Context, userID domain.ID, prefs domain.UserStylePreferences) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}

func (r *PersonalizationRepository) GetUserWeatherPreferences(ctx context.Context, userID domain.ID) (*domain.UserWeatherPreferences, error) {
	// TODO: Implement
	return nil, fmt.Errorf("not implemented")
}

func (r *PersonalizationRepository) UpdateUserWeatherPreferences(ctx context.Context, userID domain.ID, prefs domain.UserWeatherPreferences) error {
	// TODO: Implement
	return fmt.Errorf("not implemented")
}