package pg

import (
	"context"
	"encoding/json"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/pkg/errors"

	"outfitstyle/server/internal/core/domain"
)

type TripRepository struct {
	db *pgxpool.Pool
}

func NewTripRepository(db *pgxpool.Pool) *TripRepository {
	return &TripRepository{db: db}
}

func (r *TripRepository) GetByUser(ctx context.Context, userID domain.ID) ([]domain.Trip, error) {
	query := `
		SELECT
			id, user_id, name, destination, destination_lat, destination_lon,
			start_date, end_date, occasions, packing_list, status, created_at, updated_at
		FROM trips
		WHERE user_id = $1
		ORDER BY created_at DESC
	`

	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, errors.Wrap(err, "failed to query trips by user")
	}
	defer rows.Close()

	var trips []domain.Trip
	for rows.Next() {
		var trip domain.Trip
		var destinationLat *float64
		var destinationLon *float64
		var occasionsJSON []byte
		var packingListJSON []byte
		var createdAt time.Time
		var updatedAt time.Time

		err := rows.Scan(
			&trip.ID,
			&trip.UserID,
			&trip.Name,
			&trip.Destination,
			&destinationLat,
			&destinationLon,
			&trip.StartDate,
			&trip.EndDate,
			&occasionsJSON,
			&packingListJSON,
			&trip.Status,
			&createdAt,
			&updatedAt,
		)
		if err != nil {
			return nil, errors.Wrap(err, "failed to scan trip")
		}

		// Parse JSON fields
		if len(occasionsJSON) > 0 {
			err = json.Unmarshal(occasionsJSON, &trip.Occasions)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal occasions")
			}
		}

		if len(packingListJSON) > 0 {
			err = json.Unmarshal(packingListJSON, &trip.PackingList)
			if err != nil {
				return nil, errors.Wrap(err, "failed to unmarshal packing list")
			}
		}

		// Set nullable fields
		trip.DestinationLat = destinationLat
		trip.DestinationLon = destinationLon
		trip.CreatedAt = createdAt

		trips = append(trips, trip)
	}

	return trips, nil
}

func (r *TripRepository) GetByID(ctx context.Context, tripID domain.ID) (*domain.Trip, error) {
	query := `
		SELECT
			id, user_id, name, destination, destination_lat, destination_lon,
			start_date, end_date, occasions, packing_list, status, created_at, updated_at
		FROM trips
		WHERE id = $1
	`

	var trip domain.Trip
	var destinationLat *float64
	var destinationLon *float64
	var occasionsJSON []byte
	var packingListJSON []byte
	var createdAt time.Time
	var updatedAt time.Time

	err := r.db.QueryRow(ctx, query, tripID).Scan(
		&trip.ID,
		&trip.UserID,
		&trip.Name,
		&trip.Destination,
		&destinationLat,
		&destinationLon,
		&trip.StartDate,
		&trip.EndDate,
		&occasionsJSON,
		&packingListJSON,
		&trip.Status,
		&createdAt,
		&updatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get trip by ID")
	}

	// Parse JSON fields
	if len(occasionsJSON) > 0 {
		err = json.Unmarshal(occasionsJSON, &trip.Occasions)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal occasions")
		}
	}

	if len(packingListJSON) > 0 {
		err = json.Unmarshal(packingListJSON, &trip.PackingList)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal packing list")
		}
	}

	// Set nullable fields
	trip.DestinationLat = destinationLat
	trip.DestinationLon = destinationLon
	trip.CreatedAt = createdAt

	return &trip, nil
}

func (r *TripRepository) List(ctx context.Context, userID domain.ID) ([]domain.Trip, error) {
	return r.GetByUser(ctx, userID)
}

func (r *TripRepository) Create(ctx context.Context, userID domain.ID, req domain.TripCreateRequest) (*domain.Trip, error) {
	id := domain.NewID()
	now := time.Now()

	query := `
		INSERT INTO trips (
			id, user_id, name, destination, destination_lat, destination_lon,
			start_date, end_date, occasions, packing_list, status, created_at, updated_at
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
	`

	occasionsJSON, err := json.Marshal(req.Occasions)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal occasions")
	}

	packingListJSON := []byte("[]") // Default to empty array

	_, err = r.db.Exec(ctx, query,
		id,
		userID,
		req.Name,
		req.Destination,
		req.DestinationLat,
		req.DestinationLon,
		req.StartDate,
		req.EndDate,
		occasionsJSON,
		packingListJSON,
		"planning", // Default status
		now,
		now,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to create trip")
	}

	trip := &domain.Trip{
		ID:             id,
		UserID:         userID,
		Name:           req.Name,
		Destination:    req.Destination,
		DestinationLat: req.DestinationLat,
		DestinationLon: req.DestinationLon,
		StartDate:      req.StartDate,
		EndDate:        req.EndDate,
		Occasions:      req.Occasions,
		Status:         "planning",
		CreatedAt:      now,
	}

	return trip, nil
}

func (r *TripRepository) Get(ctx context.Context, userID domain.ID, id domain.ID) (*domain.Trip, error) {
	query := `
		SELECT
			id, user_id, name, destination, destination_lat, destination_lon,
			start_date, end_date, occasions, packing_list, status, created_at, updated_at
		FROM trips
		WHERE user_id = $1 AND id = $2
	`

	var trip domain.Trip
	var destinationLat *float64
	var destinationLon *float64
	var occasionsJSON []byte
	var packingListJSON []byte
	var createdAt time.Time
	var updatedAt time.Time

	err := r.db.QueryRow(ctx, query, userID, id).Scan(
		&trip.ID,
		&trip.UserID,
		&trip.Name,
		&trip.Destination,
		&destinationLat,
		&destinationLon,
		&trip.StartDate,
		&trip.EndDate,
		&occasionsJSON,
		&packingListJSON,
		&trip.Status,
		&createdAt,
		&updatedAt,
	)
	if err != nil {
		if err.Error() == "no rows in result set" {
			return nil, nil
		}
		return nil, errors.Wrap(err, "failed to get trip")
	}

	// Parse JSON fields
	if len(occasionsJSON) > 0 {
		err = json.Unmarshal(occasionsJSON, &trip.Occasions)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal occasions")
		}
	}

	if len(packingListJSON) > 0 {
		err = json.Unmarshal(packingListJSON, &trip.PackingList)
		if err != nil {
			return nil, errors.Wrap(err, "failed to unmarshal packing list")
		}
	}

	// Set nullable fields
	trip.DestinationLat = destinationLat
	trip.DestinationLon = destinationLon
	trip.CreatedAt = createdAt

	return &trip, nil
}

func (r *TripRepository) Update(ctx context.Context, userID domain.ID, id domain.ID, req domain.TripUpdateRequest) (*domain.Trip, error) {
	// First, get the existing trip to preserve unchanged fields
	existingTrip, err := r.Get(ctx, userID, id)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get existing trip")
	}
	if existingTrip == nil {
		return nil, errors.New("trip not found")
	}

	// Prepare update values, using existing values if not provided in request
	name := existingTrip.Name
	if req.Name != nil {
		name = *req.Name
	}

	destination := existingTrip.Destination
	if req.Destination != nil {
		destination = *req.Destination
	}

	destinationLat := existingTrip.DestinationLat
	if req.DestinationLat != nil {
		destinationLat = req.DestinationLat
	}

	destinationLon := existingTrip.DestinationLon
	if req.DestinationLon != nil {
		destinationLon = req.DestinationLon
	}

	startDate := existingTrip.StartDate
	if req.StartDate != nil {
		startDate = *req.StartDate
	}

	endDate := existingTrip.EndDate
	if req.EndDate != nil {
		endDate = *req.EndDate
	}

	occasions := existingTrip.Occasions
	if req.Occasions != nil {
		occasions = req.Occasions
	}

	status := existingTrip.Status
	if req.Status != nil {
		status = *req.Status
	}

	// Update the trip
	query := `
		UPDATE trips
		SET name = $1, destination = $2, destination_lat = $3, destination_lon = $4,
			start_date = $5, end_date = $6, occasions = $7, status = $8, updated_at = $9
		WHERE user_id = $10 AND id = $11
	`

	occasionsJSON, err := json.Marshal(occasions)
	if err != nil {
		return nil, errors.Wrap(err, "failed to marshal occasions")
	}

	_, err = r.db.Exec(ctx, query,
		name,
		destination,
		destinationLat,
		destinationLon,
		startDate,
		endDate,
		occasionsJSON,
		status,
		time.Now(),
		userID,
		id,
	)
	if err != nil {
		return nil, errors.Wrap(err, "failed to update trip")
	}

	// Return the updated trip
	updatedTrip, err := r.Get(ctx, userID, id)
	if err != nil {
		return nil, errors.Wrap(err, "failed to get updated trip")
	}

	return updatedTrip, nil
}

func (r *TripRepository) Delete(ctx context.Context, userID domain.ID, id domain.ID) error {
	query := `DELETE FROM trips WHERE user_id = $1 AND id = $2`

	_, err := r.db.Exec(ctx, query, userID, id)
	if err != nil {
		return errors.Wrap(err, "failed to delete trip")
	}

	return nil
}
