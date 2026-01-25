// Пакет pg содержит реализацию репозиториев для работы с PostgreSQL
// Реализует интерфейсы репозиториев с использованием библиотеки pgx
package pg

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

// ExportRepository репозиторий для работы с задачами экспорта данных
type ExportRepository struct {
	db *pgxpool.Pool // Пул подключений к базе данных PostgreSQL
}

// NewExportRepository создает новый экземпляр репозитория экспорта
func NewExportRepository(db *pgxpool.Pool) *ExportRepository {
	return &ExportRepository{db: db}
}

func (r *ExportRepository) Create(ctx context.Context, export *domain.ExportJob) error {
	query := `
		INSERT INTO export_jobs (
			id, user_id, type, status, progress, file_url, error_msg, created_at, started_at, completed_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	`

	var startedAt, completedAt *time.Time
	if export.StartedAt != nil {
		startedAt = export.StartedAt
	}
	if export.CompletedAt != nil {
		completedAt = export.CompletedAt
	}

	_, err := r.db.Exec(ctx, query,
		export.ID,
		export.UserID,
		export.Type,
		export.Status,
		export.Progress,
		export.FileURL,
		export.ErrorMsg,
		export.CreatedAt,
		startedAt,
		completedAt,
	)
	if err != nil {
		return errors.Wrap(err, "failed to create export job")
	}

	return nil
}

func (r *ExportRepository) GetByID(ctx context.Context, jobID domain.ID) (*domain.ExportJob, error) {
	query := `
		SELECT id, user_id, type, status, progress, file_url, error_msg, created_at, started_at, completed_at
		FROM export_jobs
		WHERE id = $1
	`

	var export domain.ExportJob
	var startedAt, completedAt *time.Time

	err := r.db.QueryRow(ctx, query, jobID).Scan(
		&export.ID,
		&export.UserID,
		&export.Type,
		&export.Status,
		&export.Progress,
		&export.FileURL,
		&export.ErrorMsg,
		&export.CreatedAt,
		&startedAt,
		&completedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get export job by ID")
	}

	export.StartedAt = startedAt
	export.CompletedAt = completedAt

	return &export, nil
}

func (r *ExportRepository) UpdateStatus(ctx context.Context, jobID domain.ID, status domain.ExportStatus) error {
	query := `
		UPDATE export_jobs
		SET status = $1, updated_at = NOW()
		WHERE id = $2
	`

	_, err := r.db.Exec(ctx, query, status, jobID)
	if err != nil {
		return errors.Wrap(err, "failed to update export job status")
	}

	return nil
}

func (r *ExportRepository) GetUserExports(ctx context.Context, userID domain.ID) ([]domain.ExportJob, error) {
	query := `
		SELECT id, user_id, type, status, progress, file_url, error_msg, created_at, started_at, completed_at
		FROM export_jobs
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user export jobs")
	}
	defer rows.Close()

	var exports []domain.ExportJob
	for rows.Next() {
		var export domain.ExportJob
		var startedAt, completedAt *time.Time

		err := rows.Scan(
			&export.ID,
			&export.UserID,
			&export.Type,
			&export.Status,
			&export.Progress,
			&export.FileURL,
			&export.ErrorMsg,
			&export.CreatedAt,
			&startedAt,
			&completedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan export job")
		}

		export.StartedAt = startedAt
		export.CompletedAt = completedAt

		exports = append(exports, export)
	}

	return exports, nil
}

func (r *ExportRepository) BuildUserExport(ctx context.Context, userID domain.ID) (any, error) {
	// This function would typically gather user data from various tables
	// and structure it for export. For now, we'll return a placeholder
	// with the basic user information and related data.

	// First, get user profile
	var user struct {
		ID        uuid.UUID
		Email     string
		CreatedAt time.Time
		UpdatedAt time.Time
	}

	userQuery := `SELECT id, email, created_at, updated_at FROM users WHERE id = $1`
	err := r.db.QueryRow(ctx, userQuery, userID).Scan(&user.ID, &user.Email, &user.CreatedAt, &user.UpdatedAt)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get user for export")
	}

	// Get user's wardrobe items
	wardrobeQuery := `SELECT id, user_id, clothing_item_id, custom_name, notes, tags, purchase_date, purchase_price, condition, is_favorite, is_archived, created_at, updated_at FROM user_wardrobe WHERE user_id = $1`
	wardrobeRows, err := r.db.Query(ctx, wardrobeQuery, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user wardrobe for export")
	}
	defer wardrobeRows.Close()

	var wardrobeItems []map[string]interface{}
	for wardrobeRows.Next() {
		var item struct {
			ID             uuid.UUID
			UserID         uuid.UUID
			ClothingItemID uuid.UUID
			CustomName     *string
			Notes          *string
			Tags           []string
			PurchaseDate   *time.Time
			PurchasePrice  *float64
			Condition      string
			IsFavorite     bool
			IsArchived     bool
			CreatedAt      time.Time
			UpdatedAt      time.Time
		}

		err := wardrobeRows.Scan(
			&item.ID,
			&item.UserID,
			&item.ClothingItemID,
			&item.CustomName,
			&item.Notes,
			&item.Tags,
			&item.PurchaseDate,
			&item.PurchasePrice,
			&item.Condition,
			&item.IsFavorite,
			&item.IsArchived,
			&item.CreatedAt,
			&item.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan wardrobe item for export")
		}

		itemMap := map[string]interface{}{
			"id":               item.ID,
			"user_id":          item.UserID,
			"clothing_item_id": item.ClothingItemID,
			"custom_name":      item.CustomName,
			"notes":            item.Notes,
			"tags":             item.Tags,
			"purchase_date":    item.PurchaseDate,
			"purchase_price":   item.PurchasePrice,
			"condition":        item.Condition,
			"is_favorite":      item.IsFavorite,
			"is_archived":      item.IsArchived,
			"created_at":       item.CreatedAt,
			"updated_at":       item.UpdatedAt,
		}
		wardrobeItems = append(wardrobeItems, itemMap)
	}

	// Get user's saved outfits
	outfitsQuery := `SELECT id, user_id, name, items, created_at, updated_at FROM saved_outfits WHERE user_id = $1`
	outfitsRows, err := r.db.Query(ctx, outfitsQuery, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user outfits for export")
	}
	defer outfitsRows.Close()

	var outfitItems []map[string]interface{}
	for outfitsRows.Next() {
		var item struct {
			ID        uuid.UUID
			UserID    uuid.UUID
			Name      string
			Items     []byte // This would typically be JSON
			CreatedAt time.Time
			UpdatedAt time.Time
		}

		err := outfitsRows.Scan(
			&item.ID,
			&item.UserID,
			&item.Name,
			&item.Items,
			&item.CreatedAt,
			&item.UpdatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan outfit item for export")
		}

		itemMap := map[string]interface{}{
			"id":         item.ID,
			"user_id":    item.UserID,
			"name":       item.Name,
			"items":      item.Items, // This would need to be properly handled as JSON
			"created_at": item.CreatedAt,
			"updated_at": item.UpdatedAt,
		}
		outfitItems = append(outfitItems, itemMap)
	}

	// Get user's recommendations
	recsQuery := `SELECT id, user_id, city, weather, outfit, created_at, source, score FROM recommendations WHERE user_id = $1`
	recsRows, err := r.db.Query(ctx, recsQuery, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query user recommendations for export")
	}
	defer recsRows.Close()

	var recommendationItems []map[string]interface{}
	for recsRows.Next() {
		var item struct {
			ID        uuid.UUID
			UserID    uuid.UUID
			City      string
			Weather   []byte // This would typically be JSON
			Outfit    []byte // This would typically be JSON
			CreatedAt time.Time
			Source    string
			Score     float64
		}

		err := recsRows.Scan(
			&item.ID,
			&item.UserID,
			&item.City,
			&item.Weather,
			&item.Outfit,
			&item.CreatedAt,
			&item.Source,
			&item.Score,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan recommendation item for export")
		}

		itemMap := map[string]interface{}{
			"id":         item.ID,
			"user_id":    item.UserID,
			"city":       item.City,
			"weather":    item.Weather, // This would need to be properly handled as JSON
			"outfit":     item.Outfit,  // This would need to be properly handled as JSON
			"created_at": item.CreatedAt,
			"source":     item.Source,
			"score":      item.Score,
		}
		recommendationItems = append(recommendationItems, itemMap)
	}

	// Structure the export data
	exportData := map[string]interface{}{
		"user": map[string]interface{}{
			"id":         user.ID,
			"email":      user.Email,
			"created_at": user.CreatedAt,
			"updated_at": user.UpdatedAt,
		},
		"wardrobe":        wardrobeItems,
		"saved_outfits":   outfitItems,
		"recommendations": recommendationItems,
	}

	return exportData, nil
}
