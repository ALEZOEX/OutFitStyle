package postgres

import (
	"context"
	"database/sql"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"
	"go.uber.org/zap"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
)

// RecommendationRepository реализует repositories.RecommendationRepository для PostgreSQL через pgxpool.
type RecommendationRepository struct {
	db     *DB
	logger *zap.Logger
}

// NewRecommendationRepository создаёт новый репозиторий.
// Сигнатура совпадает с тем, как он вызывается в cmd/server/main.go.
func NewRecommendationRepository(db *DB, logger *zap.Logger) repositories.RecommendationRepository {
	return &RecommendationRepository{
		db:     db,
		logger: logger,
	}
}

// CreateRecommendation сохраняет рекомендацию и связанные recommendation_items.
// Возвращает сгенерированный ID рекомендации.
func (r *RecommendationRepository) CreateRecommendation(
	ctx context.Context,
	rec *domain.RecommendationResponse,
) (int, error) {
	tx, err := r.db.pool.Begin(ctx)
	if err != nil {
		return 0, errors.Wrap(err, "begin tx")
	}
	defer func() {
		if p := recover(); p != nil {
			_ = tx.Rollback(ctx)
			panic(p)
		}
	}()

	createdAt := rec.Timestamp
	if createdAt.IsZero() {
		createdAt = time.Now()
	}

	// --- INSERT INTO recommendations ---
	var recommendationID int
	err = tx.QueryRow(ctx, `
		INSERT INTO recommendations (
			user_id,
			temperature,
			weather,
			min_temp,
			max_temp,
			will_rain,
			will_snow,
			location,
			outfit_score,
			ml_powered,
			algorithm,
			created_at
		)
		VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
		RETURNING id
	`,
		int(rec.UserID),
		rec.Temperature,
		rec.Weather,
		rec.MinTemp,
		rec.MaxTemp,
		rec.WillRain,
		rec.WillSnow,
		rec.Location,
		rec.OutfitScore,
		rec.MLPowered,
		rec.Algorithm,
		createdAt,
	).Scan(&recommendationID)
	if err != nil {
		_ = tx.Rollback(ctx)
		return 0, errors.Wrap(err, "insert into recommendations")
	}

	// --- INSERT INTO recommendation_items ---
	// Таблица:
	//   recommendation_id, clothing_item_id, name, category, icon_emoji,
	//   ml_score, confidence, confidence_score, position
	//
	// В домене Items []domain.ClothingItem:
	//   ID, UserID, Name, Category, Subcategory, IconEmoji, MLScore, Confidence, WeatherSuitability.
	// Позиции в домене нет — используем индекс+1.
	for i, it := range rec.Items {
		position := i + 1

		_, err = tx.Exec(ctx, `
			INSERT INTO recommendation_items (
				recommendation_id,
				clothing_item_id,
				name,
				category,
				icon_emoji,
				ml_score,
				confidence,
				confidence_score,
				position
			)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
		`,
			recommendationID,
			int(it.ID),
			nullOrString(it.Name),
			nullOrString(it.Category),
			nullOrString(it.IconEmoji),
			it.MLScore,
			it.Confidence,
			it.MLScore, // для простоты confidence_score = ml_score
			position,
		)
		if err != nil {
			_ = tx.Rollback(ctx)
			return 0, errors.Wrap(err, "insert into recommendation_items")
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return 0, errors.Wrap(err, "commit tx")
	}

	rec.ID = domain.ID(recommendationID)
	return recommendationID, nil
}

// GetUserRecommendations возвращает последние N рекомендаций пользователя.
func (r *RecommendationRepository) GetUserRecommendations(
	ctx context.Context,
	userID, limit int,
) ([]domain.RecommendationResponse, error) {

	rows, err := r.db.pool.Query(ctx, `
		SELECT
			id,
			user_id,
			temperature,
			weather,
			min_temp,
			max_temp,
			will_rain,
			will_snow,
			location,
			outfit_score,
			ml_powered,
			algorithm,
			created_at
		FROM recommendations
		WHERE user_id = $1
		ORDER BY created_at DESC
		LIMIT $2
	`, userID, limit)
	if err != nil {
		return nil, errors.Wrap(err, "query recommendations")
	}
	defer rows.Close()

	var result []domain.RecommendationResponse

	for rows.Next() {
		var rec domain.RecommendationResponse
		var (
			idDB, userIDDB     int
			minTemp, maxTemp   sql.NullFloat64
			willRain, willSnow sql.NullBool
			location           sql.NullString
			outfitScore        sql.NullFloat64
			algorithm          sql.NullString
			createdAt          time.Time
		)

		if err := rows.Scan(
			&idDB,
			&userIDDB,
			&rec.Temperature,
			&rec.Weather,
			&minTemp,
			&maxTemp,
			&willRain,
			&willSnow,
			&location,
			&outfitScore,
			&rec.MLPowered,
			&algorithm,
			&createdAt,
		); err != nil {
			return nil, errors.Wrap(err, "scan recommendation")
		}

		rec.ID = domain.ID(idDB)
		rec.UserID = domain.ID(userIDDB)
		rec.MinTemp = nullFloat64ToFloat64(minTemp)
		rec.MaxTemp = nullFloat64ToFloat64(maxTemp)
		rec.WillRain = willRain.Valid && willRain.Bool
		rec.WillSnow = willSnow.Valid && willSnow.Bool
		rec.Location = location.String
		if outfitScore.Valid {
			rec.OutfitScore = outfitScore.Float64
		}
		rec.Algorithm = algorithm.String
		rec.Timestamp = createdAt

		// Humidity / WindSpeed / HourlyForecast в БД не храним — остаются нулевые значения.

		items, err := r.loadRecommendationItems(ctx, idDB)
		if err != nil {
			return nil, errors.Wrap(err, "load recommendation items")
		}
		rec.Items = items

		result = append(result, rec)
	}

	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "rows err")
	}

	return result, nil
}

// GetRecommendationByID возвращает одну рекомендацию по ID.
func (r *RecommendationRepository) GetRecommendationByID(
	ctx context.Context,
	id int,
) (*domain.RecommendationResponse, error) {

	row := r.db.pool.QueryRow(ctx, `
		SELECT
			id,
			user_id,
			temperature,
			weather,
			min_temp,
			max_temp,
			will_rain,
			will_snow,
			location,
			outfit_score,
			ml_powered,
			algorithm,
			created_at
		FROM recommendations
		WHERE id = $1
	`, id)

	var rec domain.RecommendationResponse
	var (
		idDB, userIDDB     int
		minTemp, maxTemp   sql.NullFloat64
		willRain, willSnow sql.NullBool
		location           sql.NullString
		outfitScore        sql.NullFloat64
		algorithm          sql.NullString
		createdAt          time.Time
	)

	if err := row.Scan(
		&idDB,
		&userIDDB,
		&rec.Temperature,
		&rec.Weather,
		&minTemp,
		&maxTemp,
		&willRain,
		&willSnow,
		&location,
		&outfitScore,
		&rec.MLPowered,
		&algorithm,
		&createdAt,
	); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, nil
		}
		return nil, errors.Wrap(err, "scan recommendation by id")
	}

	rec.ID = domain.ID(idDB)
	rec.UserID = domain.ID(userIDDB)
	rec.MinTemp = nullFloat64ToFloat64(minTemp)
	rec.MaxTemp = nullFloat64ToFloat64(maxTemp)
	rec.WillRain = willRain.Valid && willRain.Bool
	rec.WillSnow = willSnow.Valid && willSnow.Bool
	rec.Location = location.String
	if outfitScore.Valid {
		rec.OutfitScore = outfitScore.Float64
	}
	rec.Algorithm = algorithm.String
	rec.Timestamp = createdAt

	items, err := r.loadRecommendationItems(ctx, idDB)
	if err != nil {
		return nil, errors.Wrap(err, "load recommendation items by id")
	}
	rec.Items = items

	return &rec, nil
}

// loadRecommendationItems подтягивает вещи для рекомендации и маппит в []domain.ClothingItem.
func (r *RecommendationRepository) loadRecommendationItems(
	ctx context.Context,
	recommendationID int,
) ([]domain.ClothingItem, error) {

	rows, err := r.db.pool.Query(ctx, `
		SELECT
			clothing_item_id,
			name,
			category,
			icon_emoji,
			ml_score,
			confidence,
			position
		FROM recommendation_items
		WHERE recommendation_id = $1
		ORDER BY position, id
	`, recommendationID)
	if err != nil {
		return nil, errors.Wrap(err, "query recommendation_items")
	}
	defer rows.Close()

	var items []domain.ClothingItem

	for rows.Next() {
		var (
			itemID     int
			name       sql.NullString
			category   sql.NullString
			iconEmoji  sql.NullString
			mlScore    sql.NullFloat64
			confidence sql.NullFloat64
			position   sql.NullInt32 // сейчас не используется в домене
		)

		if err := rows.Scan(
			&itemID,
			&name,
			&category,
			&iconEmoji,
			&mlScore,
			&confidence,
			&position,
		); err != nil {
			return nil, errors.Wrap(err, "scan recommendation_item")
		}

		var it domain.ClothingItem
		it.ID = domain.ID(itemID)
		it.Name = name.String
		it.Category = category.String
		it.IconEmoji = iconEmoji.String
		if mlScore.Valid {
			it.MLScore = mlScore.Float64
		}
		if confidence.Valid {
			it.Confidence = confidence.Float64
		}

		items = append(items, it)
	}

	if err := rows.Err(); err != nil {
		return nil, errors.Wrap(err, "rows err")
	}

	return items, nil
}

// --------------------
// Вспомогательные функции
// --------------------

func nullOrString(s string) sql.NullString {
	if s == "" {
		return sql.NullString{}
	}
	return sql.NullString{String: s, Valid: true}
}

func nullFloat64ToFloat64(n sql.NullFloat64) float64 {
	if !n.Valid {
		return 0
	}
	return n.Float64
}
