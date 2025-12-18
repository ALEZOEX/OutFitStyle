package pg

import (
	"context"
	"encoding/json"

	"github.com/jackc/pgx/v5"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/application/repositories"
	"outfitstyle/server/internal/core/domain"
	dbpkg "outfitstyle/server/internal/infrastructure/persistence/postgres"
)

type TripRepository struct{ db *dbpkg.DB }

func NewTripRepository(db *dbpkg.DB) repositories.TripRepository { return &TripRepository{db: db} }

func (r *TripRepository) List(ctx context.Context, userID domain.ID) ([]domain.Trip, error) {
	rows, err := r.db.Pool().Query(ctx, `
SELECT id, user_id, name, destination, destination_lat, destination_lon, start_date::text, end_date::text, occasions, packing_list, status, created_at
FROM trips
WHERE user_id = $1
ORDER BY start_date DESC
`, userID)
	if err != nil { return nil, errors.Wrap(err, "list trips") }
	defer rows.Close()

	var out []domain.Trip
	for rows.Next() {
		var t domain.Trip
		var packing []byte
		if err := rows.Scan(&t.ID, &t.UserID, &t.Name, &t.Destination, &t.DestinationLat, &t.DestinationLon, &t.StartDate, &t.EndDate, &t.Occasions, &packing, &t.Status, &t.CreatedAt); err != nil {
			return nil, errors.Wrap(err, "scan trip")
		}
		if len(packing) > 0 {
			var obj any
			_ = json.Unmarshal(packing, &obj)
			t.PackingList = obj
		}
		out = append(out, t)
	}
	return out, rows.Err()
}

func (r *TripRepository) Create(ctx context.Context, userID domain.ID, req domain.TripCreateRequest) (*domain.Trip, error) {
	var t domain.Trip
	err := r.db.Pool().QueryRow(ctx, `
INSERT INTO trips (user_id, name, destination, destination_lat, destination_lon, start_date, end_date, occasions, status)
VALUES ($1,$2,$3,$4,$5,$6,$7,$8,'planning')
RETURNING id, user_id, name, destination, destination_lat, destination_lon, start_date::text, end_date::text, occasions, packing_list, status, created_at
`, userID, req.Name, req.Destination, req.DestinationLat, req.DestinationLon, req.StartDate, req.EndDate, req.Occasions).Scan(
		&t.ID, &t.UserID, &t.Name, &t.Destination, &t.DestinationLat, &t.DestinationLon, &t.StartDate, &t.EndDate, &t.Occasions, new([]byte), &t.Status, &t.CreatedAt,
	)
	if err != nil { return nil, errors.Wrap(err, "create trip") }
	return &t, nil
}

func (r *TripRepository) Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.Trip, error) {
	var t domain.Trip
	var packing []byte
	err := r.db.Pool().QueryRow(ctx, `
SELECT id, user_id, name, destination, destination_lat, destination_lon, start_date::text, end_date::text, occasions, packing_list, status, created_at
FROM trips
WHERE id = $1 AND user_id = $2
`, id, userID).Scan(
		&t.ID, &t.UserID, &t.Name, &t.Destination, &t.DestinationLat, &t.DestinationLon, &t.StartDate, &t.EndDate, &t.Occasions, &packing, &t.Status, &t.CreatedAt,
	)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) { return nil, nil }
		return nil, errors.Wrap(err, "get trip")
	}
	if len(packing) > 0 {
		var obj any
		_ = json.Unmarshal(packing, &obj)
		t.PackingList = obj
	}
	return &t, nil
}

func (r *TripRepository) Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.TripUpdateRequest) (*domain.Trip, error) {
	_, err := r.db.Pool().Exec(ctx, `
UPDATE trips
SET
name = COALESCE($1, name),
destination = COALESCE($2, destination),
destination_lat = COALESCE($3, destination_lat),
destination_lon = COALESCE($4, destination_lon),
start_date = COALESCE($5::date, start_date),
end_date = COALESCE($6::date, end_date),
occasions = COALESCE($7, occasions),
status = COALESCE($8, status)
WHERE id = $9 AND user_id = $10
`, req.Name, req.Destination, req.DestinationLat, req.DestinationLon, req.StartDate, req.EndDate, req.Occasions, req.Status, id, userID)
	if err != nil { return nil, errors.Wrap(err, "update trip") }
	return r.Get(ctx, userID, id)
}

func (r *TripRepository) Delete(ctx context.Context, userID domain.ID, id domain.ID) error {
	cmd, err := r.db.Pool().Exec(ctx, `DELETE FROM trips WHERE id=$1 AND user_id=$2`, id, userID)
	if err != nil { return errors.Wrap(err, "delete trip") }
	if cmd.RowsAffected() == 0 { return repositories.ErrNotFound }
	return nil
}