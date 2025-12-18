package pg

import (
	"context"

	"github.com/Masterminds/squirrel"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/domain"
	"outfitstyle/server/internal/core/repo/clothing"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

// SubcategorySpecRepository реализация интерфейса для работы со спецификациями подкатегорий
type SubcategorySpecRepositoryImpl struct {
	db     *dbpkg.DB
	logger *zap.Logger
}

// NewSubcategorySpecRepository создает новую реализацию репозитория спецификаций подкатегорий
func NewSubcategorySpecRepository(db *dbpkg.DB, logger *zap.Logger) clothing.SubcategorySpecRepository {
	return &SubcategorySpecRepositoryImpl{
		db:     db,
		logger: logger,
	}
}

// ListAll возвращает все спецификации подкатегорий
func (r *SubcategorySpecRepositoryImpl) ListAll(ctx context.Context) ([]domain.SubcategorySpec, error) {
	query, args, err := squirrel.Select(
		"category",
		"subcategory", 
		"warmth_min",
		"temp_min_reco",
		"temp_max_reco",
		"rain_ok",
		"snow_ok",
		"wind_ok",
	).From("subcategory_specs").PlaceholderFormat(squirrel.Dollar).ToSql()

	if err != nil {
		return nil, errors.Wrap(err, "failed to build query")
	}

	rows, err := r.db.Pool().Query(ctx, query, args...)
	if err != nil {
		return nil, errors.Wrap(err, "failed to execute query")
	}
	defer rows.Close()

	var specs []domain.SubcategorySpec
	for rows.Next() {
		var spec domain.SubcategorySpec
		err := rows.Scan(
			&spec.Category,
			&spec.Subcategory,
			&spec.WarmthMin,
			&spec.TempMinReco,
			&spec.TempMaxReco,
			&spec.RainOK,
			&spec.SnowOK,
			&spec.WindOK,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan subcategory spec")
		}
		specs = append(specs, spec)
	}

	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "row iteration error")
	}

	return specs, nil
}

// Get возвращает спецификацию подкатегории по категории и подкатегории
func (r *SubcategorySpecRepositoryImpl) Get(ctx context.Context, category, subcategory string) (domain.SubcategorySpec, error) {
	var spec domain.SubcategorySpec

	query, args, err := squirrel.Select(
		"category",
		"subcategory", 
		"warmth_min",
		"temp_min_reco",
		"temp_max_reco",
		"rain_ok",
		"snow_ok",
		"wind_ok",
	).From("subcategory_specs").
		Where(squirrel.Eq{"category": category, "subcategory": subcategory}).
		PlaceholderFormat(squirrel.Dollar).
		ToSql()

	if err != nil {
		return spec, errors.Wrap(err, "failed to build query")
	}

	err = r.db.Pool().QueryRow(ctx, query, args...).Scan(
		&spec.Category,
		&spec.Subcategory,
		&spec.WarmthMin,
		&spec.TempMinReco,
		&spec.TempMaxReco,
		&spec.RainOK,
		&spec.SnowOK,
		&spec.WindOK,
	)

	if err != nil {
		return spec, errors.Wrap(err, "failed to scan subcategory spec")
	}

	return spec, nil
}